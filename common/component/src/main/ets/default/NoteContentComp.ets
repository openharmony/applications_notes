/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import DateUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/DateUtil.ets'
import RdbStoreUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/RdbStoreUtil.ets'
import FolderData from '../../../../../../common/utils/src/main/ets/default/model/databaseModel/FolderData.ets'
import NoteData from '../../../../../../common/utils/src/main/ets/default/model/databaseModel/NoteData.ets'
import {TableName, NoteTableColumn, SysDefFolderUuid, Favorite, Delete
} from '../../../../../../common/utils/src/main/ets/default/model/databaseModel/EnumData.ets'
import StyleConstants from '../../../../../../common/utils/src/main/ets/default/constants/StyleConstants.ets'
import {EditContentDialog,DeleteDialog,EditTitleDialog} from './CusDialogComp.ets'
import FolderUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/FolderUtil.ets'
import NoteUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/NoteUtil.ets'
import prompt from '@system.prompt'
import featureAbility from '@ohos.ability.featureAbility';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets'

const TAG = "NoteContentComp"

// Note content component
@Component
export struct NoteContentComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData;
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Consume('SelectedFolderData') selectedFolderData: FolderData
  @Consume('RefreshFlag') refreshFlag: number
  @Consume('EditModel') editModel:boolean
  @Consume('SectionStatus') sectionStatus: number
  @Consume('LastSectionStatus') lastSectionStatus: number
  controllerShow: WebController
  private editContentFlag = false
  @State uri1 : string = "";
  private context = getContext(this)

  noteContent = {
    callbackhtml: (html) => {
      LogUtil.info(TAG, 'html content is:' + html)
      LogUtil.info(TAG, 'note uuid is:' + this.selectedNoteData.uuid)
      this.selectedNoteData.content_text = html
      this.selectedNoteData.modified_time = new Date().getTime()
      let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
      predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
      RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
      LogUtil.info(TAG, 'update note success:' + this.selectedNoteData)
      // 删除空白笔记
      NoteUtil.deleteEmptyNote(this.selectedNoteData,this.AllNoteArray,this.controllerShow)
      return "AceString";
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Flex({ direction: FlexDirection.Column, wrap: FlexWrap.Wrap,
        alignItems: ItemAlign.Start, alignContent: FlexAlign.SpaceAround }) {
        Column() {
          ToolBarComp({controllerShow: this.controllerShow})
        }

        Column() {
          NoteContentOverViewComp()
          Text(this.refreshFlag.toString()).visibility(Visibility.None)
          Text(this.AllNoteArray.length.toString()).visibility(Visibility.None) // 用于强制刷新使用

          Web({ src: $rawfile('editor.html'), controller: this.controllerShow })
            .javaScriptAccess(true)
            .onPageEnd((e) => {
              if (this.editContentFlag == false) {
                this.controllerShow.registerJavaScriptProxy({
                  obj: this.noteContent,
                  name: "callBackToApp", // html-->  name.method
                  methodList: ["callbackhtml"],
                });
                LogUtil.info(TAG, "finish register")
                this.controllerShow.refresh()
                this.editContentFlag = true
              }
              LogUtil.info(TAG, "finish loadurl")
              console.log('onPageEnd:' + e.url)
              this.controllerShow.runJavaScript({script:"RE.setHtml('" + this.selectedNoteData.content_text + "')"})
              // 初次加载为为小屏预览模式
              if(this.sectionStatus != 1) {
                this.controllerShow.runJavaScript({script:"RE.setInputEnabled(false)"})
              }
            })
            .zoomAccess(false)
            .height(450)
            .width('100%')
        }
        .margin({ top: 16 }).width(StyleConstants.PERCENTAGE_100)
        .opacity(this.selectedNoteData.is_deleted == Delete.Yes ? 0.4 : 1)
        .enabled(this.selectedNoteData.is_deleted == Delete.Yes ? false : true)
        .onClick(() => {
          // 点击第三屏进入全屏编辑模式
          if(this.sectionStatus != 1) {
            this.lastSectionStatus = this.sectionStatus
            this.sectionStatus = 1
            this.controllerShow.runJavaScript({script:"RE.setInputEnabled(true)"})
            this.editModel = !this.editModel
          }
        })
      }
      .height(StyleConstants.PERCENTAGE_100)
      .margin({ left: 24, right: 24 })
      .visibility(FolderUtil.getNoteCount(AppStorage.Get('AllNoteArray'), this.selectedFolderData.uuid) == 0 ? Visibility.Hidden : Visibility.Visible)

      DeleteNoteComp()
    }
    .height(StyleConstants.PERCENTAGE_100)
    .width(StyleConstants.PERCENTAGE_100)
  }
}

@Component
export struct NoteContentOverViewComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData;
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = []
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[]  = []
  @Consume('EditModel') editModel:boolean
  @Consume('SectionStatus') sectionStatus: number

  editTitleDialogCtl: CustomDialogController = new CustomDialogController({
    builder: EditTitleDialog({ confirm: this.confirm.bind(this), dialogType: 0 }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true,
  })

  confirm(newTitle: string) {
    this.selectedNoteData.title = newTitle
    this.selectedNoteData.modified_time = new Date().getTime()
    let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
    predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
    RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
  }

  @Builder MenuBuilder() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      List() {
        ForEach(this.AllFolderArray, (item) => {
          ListItem() {
            NoteDataMoveItemComp({ folderItem: item })
          }
          .onClick(() => {
            this.selectedNoteData.folder_uuid = item.uuid
          })
        }, noteItem => noteItem.uuid)
      }.listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .height(this.AllFolderArray.length > 12 ? 504 : (this.AllFolderArray.length - 3) * 56)
    }
    .width(148)
    .backgroundColor($r("app.color.color_fffffB"))
    .padding({left:24,right:24})
  }

  build() {
    Flex({ direction: FlexDirection.Column, wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Text(this.selectedNoteData.title).fontSize(30)
          .onClick(() => {
            this.editModel = true
            this.sectionStatus = 1
            this.editTitleDialogCtl.open()
          })
      }.height(40).width(StyleConstants.PERCENTAGE_100)

      Row() {
        Text(DateUtil.formateDateForNoteContent(new Date(this.selectedNoteData.modified_time))).fontSize(12)
          .padding({ top: 4, bottom: 4 })
        Row() {
          Text(FolderUtil.getFolderText(FolderUtil.getFolderData(AppStorage.Get('AllFolderArray'), this.selectedNoteData.folder_uuid)))
            .fontSize(12)
          Image($r('app.media.triangle'))
            .width(6)
            .height(12)
            .margin({ left: 4 })
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .margin({ left: 8 })
        .borderRadius(16)
        .backgroundColor(NoteUtil.getNoteBgColor(AppStorage.Get('AllFolderArray'), this.selectedNoteData.folder_uuid, SysDefFolderUuid.AllNotes, false))
        .bindMenu(this.MenuBuilder)
      }.alignItems(VerticalAlign.Top).height(40).width(StyleConstants.PERCENTAGE_100)
    }
    .width(StyleConstants.PERCENTAGE_100)
    .height(80)
  }
}

@Component
export struct ToolBarComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData;
  @Consume('RefreshFlag') refreshFlag: number
  @Consume('SectionStatus') sectionStatus: number
  @Consume('LastSectionStatus') lastSectionStatus: number
  @Consume('SelectedFolderData') selectedFolderData: FolderData
  @Consume('ChooseNote') chooseNote: boolean
  @Consume('PortraitModel') portraitModel: boolean
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Consume('EditModel') editModel:boolean
  controllerShow: WebController
  private context = getContext(this)

//private lastSectionStatus: number
  noteDataDeleteDialogCtl: CustomDialogController = new CustomDialogController({
    builder: DeleteDialog({ onConfirm: this.onDeleteConfirm.bind(this) }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true,
  })
  noteDataDeleteDialogCtlBottom: CustomDialogController = new CustomDialogController({
    builder: DeleteDialog({ onConfirm: this.onDeleteConfirm.bind(this) }),
    alignment: DialogAlignment.Bottom,
    autoCancel: false,
    customStyle: true,
  })

  onDeleteConfirm() {
    if (this.selectedFolderData.uuid != SysDefFolderUuid.RecentDeletes) {
      this.selectedNoteData.is_deleted = Delete.Yes
      this.selectedNoteData.deleted_time = new Date().getTime()
      // update note to db
      let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
      predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
      RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
    } else {
      NoteUtil.removeNoteData(this.AllNoteArray, this.selectedNoteData.uuid)
      // delete note from db
      let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
      predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
      RdbStoreUtil.delete(predicates_note, null)
    }
    this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
    this.selectedNoteData = NoteUtil.getFirstNoteData(AppStorage.Get('AllNoteArray'), this.selectedFolderData.uuid)
    this.controllerShow.runJavaScript({script:"RE.setHtml('" + this.selectedNoteData.content_text + "')"})
    this.chooseNote = false
    // 迁移
    console.log("ToolBarComp, onDeleteConfirm, set continue note")
    let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
    console.log("ToolBarComp, onDeleteConfirm, continueNote : " + continueNote)
    AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
    console.log("ToolBarComp, onDeleteConfirm, set continue note success")
  }

  editContentDialogCtl: CustomDialogController = new CustomDialogController({
    builder: EditContentDialog({ confirm: this.confirm.bind(this), dialogType: 0 }),
    alignment: DialogAlignment.Bottom,
    autoCancel: true,
    customStyle: true,
  })

  confirm(excuteJs: string) {
    prompt.showToast({ message: excuteJs, duration: 2000 })
    this.controllerShow.runJavaScript({script:excuteJs})
  }


  build() {
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      if (this.portraitModel == true) {
        Image($r('app.media.back')).height(24).width(24)
          .onClick(() => {
            this.chooseNote = false
          })
      } else {
        Image($r('app.media.zoom')).height(24).width(24)
          .onClick(() => {
            if (this.sectionStatus != 1) {
              this.lastSectionStatus = this.sectionStatus
              this.sectionStatus = 1
              this.controllerShow.runJavaScript({script:"RE.setInputEnabled(true)"})
            } else {
              if (this.lastSectionStatus != undefined) {
                this.sectionStatus = this.lastSectionStatus
                // 切换为小屏预览模式
                this.controllerShow.runJavaScript({script:"RE.setInputEnabled(false)"})
                // 退出全屏时存库
                LogUtil.info(TAG, "close note"+ this.selectedNoteData.uuid)
                this.controllerShow.runJavaScript({script:"get_html_content()"})
              } else {
                this.sectionStatus = 3
              }
            }
            this.editModel = !this.editModel
            // 迁移
            console.log("ToolBarComp, set continue section")
            AppStorage.SetOrCreate<number>('ContinueSection', this.sectionStatus)
            console.log("ToolBarComp, set continue section success")
          })
          .visibility(this.selectedNoteData.is_deleted == Delete.Yes ? Visibility.None : Visibility.Visible)
      }

      if (this.selectedNoteData.is_deleted == Delete.Yes) {
        Row({ space: StyleConstants.SPACE_24 }) {
          Image($r('app.media.delete')).height(24).width(24)
            .onClick(() => {
              this.noteDataDeleteDialogCtl.open()
            })
          Image($r('app.media.recover')).height(24).width(24)
            .onClick(() => {
              this.selectedNoteData.is_deleted = Delete.No
              this.selectedNoteData.deleted_time = 0
              prompt.showToast({ message: "已恢复", duration: 2000 })
              this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
              this.chooseNote = false
              // update note to db
              let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
              predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
              RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)

              this.selectedNoteData = NoteUtil.getFirstNoteData(AppStorage.Get('AllNoteArray'), this.selectedFolderData.uuid)
              this.controllerShow.runJavaScript({script:"RE.setHtml('" + this.selectedNoteData.content_text + "')"})
            })
        }.width(72)
        .visibility(this.portraitModel ? Visibility.None : Visibility.Visible)
      } else if(this.portraitModel == true && this.editModel == true) {
        Row({ space: StyleConstants.SPACE_24 }) {
          Image($r('app.media.undo')).height(24).width(24)
            .onClick(() => {
              this.controllerShow.runJavaScript({script:"javascript:RE.undo()"})
            })
          Image($r('app.media.todo')).height(24).width(24)
            .onClick(() => {
              this.controllerShow.runJavaScript({script:"javascript:RE.redo()"})
            })
          Image($r('app.media.tick_thin')).height(24).width(24)
            .onClick(() => {
              // 保存笔记信息到数据库
              this.controllerShow.runJavaScript({script:"get_html_content()"})
            })
        }.width(120)
      } else if(this.editModel == true) {
        Row({ space: StyleConstants.SPACE_24 }) {
          Image($r('app.media.circle_tick1')).height(24).width(24)
            .onClick(() => {
              // 清单
              this.controllerShow.runJavaScript({script:"javascript:RE.setTodo()"})
            })
          Image($r('app.media.styles')).height(24).width(24)
            .onClick(() => {
              if(this.portraitModel) {
                this.editContentDialogCtl.open()
              }else{
                this.editContentDialogCtl.open()
              }
            })
          Image($r('app.media.picture_white')).height(24).width(24)
            .onClick(() => {
              console.info('test select single select!')
              this.controllerShow.runJavaScript({script:"javascript:RE.insertImage()"})
            })
          Image($r('app.media.tick_thick')).height(24).width(24)
            .onClick(() => {
              // 保存笔记信息到数据库
              this.controllerShow.runJavaScript({script:"get_html_content()"})
            })
          Image($r('app.media.undo')).height(24).width(24)
            .onClick(() => {

              this.controllerShow.runJavaScript({script:"RE.undo()"})
            })
          Image($r('app.media.todo')).height(24).width(24)
            .onClick(() => {
              this.controllerShow.runJavaScript({script:"RE.redo()"})
            })
        }.width(268)
      } else {
        Row({ space: StyleConstants.SPACE_24 }) {
          Image(this.selectedNoteData.is_favorite == Favorite.Yes ? $r('app.media.favorite') : $r('app.media.favorite_cancel'))
            .height(24).width(24)
            .onClick(() => {
              this.selectedNoteData.is_favorite = (this.selectedNoteData.is_favorite == Favorite.Yes ? Favorite.No : Favorite.Yes)
              this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
              // update note to db
              let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
              predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
              RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
              if (this.selectedFolderData.uuid === SysDefFolderUuid.MyFavorites) {
                this.selectedNoteData = NoteUtil.getFirstNoteData(AppStorage.Get('AllNoteArray'), SysDefFolderUuid.MyFavorites)
                // 迁移
                console.log("ToolBarComp, set continue note")
                let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
                console.log("ToolBarComp, continueNote : " + continueNote)
                AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
                console.log("ToolBarComp, set continue note success")
              }
            })
          Image($r('app.media.delete')).height(24).width(24)
            .onClick(() => {
              if (this.portraitModel) {
                this.noteDataDeleteDialogCtlBottom.open()
              } else {
                this.noteDataDeleteDialogCtl.open()
              }
            })
        }.width(72)
      }
    }
    .width(StyleConstants.PERCENTAGE_100)
    .height(80)
  }
}

@Component
export struct DeleteNoteComp {
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[]  = []
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Consume('SelectedFolderData') selectedFolderData: FolderData
  @Consume('RefreshFlag') refreshFlag: number
  @Consume('SelectedNoteData') selectedNoteData: NoteData;
  @Consume('PortraitModel') portraitModel: boolean
  @Consume('ChooseNote') chooseNote: boolean
  noteDataDeleteDialogCtlBottom: CustomDialogController = new CustomDialogController({
    builder: DeleteDialog({ onConfirm: this.onDeleteConfirm.bind(this), multiSelect: true }),
    alignment: DialogAlignment.Bottom,
    autoCancel: false,
    customStyle: true,
  })

  onDeleteConfirm() {
    if (this.selectedFolderData.uuid != SysDefFolderUuid.RecentDeletes) {
      this.selectedNoteData.is_deleted = Delete.Yes
      this.selectedNoteData.deleted_time = new Date().getTime()
      // update note to db
      let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
      predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
      RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
    } else {
      NoteUtil.removeNoteData(this.AllNoteArray, this.selectedNoteData.uuid)
      // delete note from db
      let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
      predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
      RdbStoreUtil.delete(predicates_note, null)
    }
    this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
    this.selectedNoteData = NoteUtil.getFirstNoteData(AppStorage.Get('AllNoteArray'), this.selectedFolderData.uuid)
    this.chooseNote = false
    // 迁移
    console.log("DeleteNoteComp, onDeleteConfirm, set continue note")
    let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
    console.log("DeleteNoteComp, onDeleteConfirm, continueNote : " + continueNote)
    AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
    console.log("DeleteNoteComp, onDeleteConfirm, set continue note success")
  }

  build() {
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
      Column() {
        Image($r('app.media.delete'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.noteDataDeleteDialogCtlBottom.open()
          })
        Text($r("app.string.delete"))
          .fontSize(10).fontColor('#182431')
          .padding({ top: 5 })
      }
      .alignItems(HorizontalAlign.Center)

      Column() {
        Image($r('app.media.recover'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.selectedNoteData.is_deleted = Delete.No
            this.selectedNoteData.deleted_time = 0
            prompt.showToast({ message: "已恢复", duration: 2000 })
            this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
            this.chooseNote = false
            // update note to db
            let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
            predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
            RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
          })
        Text($r("app.string.recover"))
          .fontSize(10).fontColor('#182431')
          .padding({ top: 5 })
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width(360)
    .height(56)
    .visibility(this.selectedNoteData.is_deleted == Delete.Yes && this.portraitModel == true ?
      Visibility.Visible : Visibility.None)
  }
}

@Component
struct NoteDataMoveItemComp {
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[] = []
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = []
  private folderItem: FolderData

  build() {
    Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap,justifyContent: FlexAlign.Center }) {
      Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap }) {
        Image(FolderUtil.getFolderIcon(this.folderItem.uuid))
          .objectFit(ImageFit.ScaleDown)
          .width(24)
          .height(24)
          .fillColor(FolderUtil.getFolderIconColor(this.AllFolderArray, this.folderItem.uuid, false))
      }
      .width(24)

      Column() {
        Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween }) {
          Text(FolderUtil.getFolderText(this.folderItem))
            .fontSize(16)
            .fontColor(FolderUtil.getFolderIconColor(this.AllFolderArray, this.folderItem.uuid, false))
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .flexShrink(1)
        }
        .width('100%')
        .height(55)

        Divider().color($r("app.color.divider_color_e4e4e4")).strokeWidth(1)
      }
      .padding({ left: 16 })
    }
    .width('100%')
    .height(56)
    .visibility(FolderUtil.isFolderMoveIn(this.folderItem) ? Visibility.Visible : Visibility.None)
  }
}
