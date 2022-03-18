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
import {EditContentDialogPortrait, DeleteDialog, EditTitleDialog} from './CusDialogComp.ets'
import FolderUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/FolderUtil.ets'
import NoteUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/NoteUtil.ets'
import prompt from '@system.prompt'
import featureAbility from '@ohos.ability.featureAbility';
import {LogUtil} from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets'
import OperationUtils from '../../../../../../common/utils/src/main/ets/default/baseUtil/OperationUtils.ets'

const TAG = "NoteContentComp"

// Note content component
@Component
export struct NoteContentCompPortrait {
  @Consume('SelectedNoteData') selectedNoteData: NoteData;
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Consume('SelectedFolderData') selectedFolderData: FolderData
  @Consume('RefreshFlag') refreshFlag: number
  @Consume('SectionStatus') sectionStatus: number
  @Consume('ChooseNote') chooseNote: boolean
  @Consume('EditModel') editModel: boolean
  private controllerShow: WebController = new WebController()
  private editContentFlag = false
  @State uri1: string = "";
  private context = getContext(this)
  noteContent = {
    callbackhtml: (html) => {
      LogUtil.info(TAG, 'note uuid is:' + this.selectedNoteData.uuid)
      this.selectedNoteData.content_text = html
      this.selectedNoteData.modified_time = new Date().getTime()
      // updata note image
      this.selectedNoteData.content_img = RdbStoreUtil.updataNoteImage(this.selectedNoteData.content_text)
      let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
      predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
      RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
      LogUtil.info(TAG, 'update note success:' + this.selectedNoteData.uuid)
      return "AceString";
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Flex({ direction: FlexDirection.Column, wrap: FlexWrap.Wrap,
        alignItems: ItemAlign.Start, alignContent: FlexAlign.SpaceAround }) {
        Column() {
          ToolBarComp({ controllerShow: this.controllerShow })
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
              // 初次进入预览模式
              this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setInputEnabled(false)" })
              this.controllerShow.runJavaScript({
                script: "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')"
              })
            })
            .zoomAccess(false)
            .height(450)
            .width('100%')
        }
        .margin({ top: 16 })
        .width(StyleConstants.PERCENTAGE_100)
        .opacity(this.selectedNoteData.is_deleted == Delete.Yes ? 0.4 : 1)
        .enabled(this.selectedNoteData.is_deleted == Delete.Yes ? false : true)
        .onClick(() => {
          this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setInputEnabled(true)" })
          this.editModel = true
        })
      }
      .height(StyleConstants.PERCENTAGE_100)
      .margin({ left: 24, right: 24 })
      .visibility(FolderUtil.getNoteCount(AppStorage.Get('AllNoteArray'), this.selectedFolderData.uuid) == 0 ? Visibility.Hidden : Visibility.Visible)

      EditNoteCompForPortrait({ controllerShow: this.controllerShow })
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
    .padding({ left: 24, right: 24 })
  }

  build() {
    Flex({ direction: FlexDirection.Column, wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Text(this.selectedNoteData.title).fontSize(30)
          .onClick(() => {
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
  @Consume('SelectedFolderData') selectedFolderData: FolderData
  @Consume('ChooseNote') chooseNote: boolean
  @Consume('PortraitModel') portraitModel: boolean
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Consume('EditModel') editModel: boolean
  controllerShow: WebController

  build() {
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {

      Image($r('app.media.back')).height(24).width(24)
        .onClick(() => {
          // 退出全屏时存库
          this.controllerShow.runJavaScript({ script: "get_html_content()" })
          // 删除空白笔记
          NoteUtil.deleteEmptyNote(this.selectedNoteData, this.AllNoteArray, this.controllerShow)
          this.chooseNote = false
          // 进入预览模式
          this.controllerShow.runJavaScript({ script: "RE.setInputEnabled(false)" })
          this.editModel = false
        })

      if (this.editModel == false) {
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
                LogUtil.info(TAG, "ToolBarComp, set continue note")
                let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
                AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
                LogUtil.info(TAG, "ToolBarComp, set continue note success")
              }
            })
        }.width(36)
        .visibility(this.selectedNoteData.is_deleted == Delete.Yes ? Visibility.None : Visibility.Visible)
      } else {
        Row({ space: StyleConstants.SPACE_6 }) {
          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Image($r('app.media.undo')).height(24).width(24)
              .onClick(() => {
                this.controllerShow.runJavaScript({ script: "javascript:RICH_EDITOR.undo()" })
              })
          }.width(42)
          .height(42)
          .borderRadius(8)
          .backgroundColor($r('app.color.color_ffffff'))

          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Image($r('app.media.todo')).height(24).width(24)
              .onClick(() => {
                this.controllerShow.runJavaScript({ script: "javascript:RICH_EDITOR.redo()" })
              })
          }.width(42)
          .height(42)
          .borderRadius(8)
          .backgroundColor($r('app.color.color_ffffff'))

          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Image($r('app.media.tick_thin')).height(24).width(24)
              .onClick(() => {
                // 保存笔记信息到数据库
                this.controllerShow.runJavaScript({ script: "get_html_content()" })
                if (this.selectedNoteData.title == "标题" && this.selectedNoteData.content_text == "") {
                  LogUtil.info(TAG, "note is empty,save note failed")
                }
                // 进入预览模式
                this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setInputEnabled(false)" })
                this.editModel = false
              })
          }.width(42)
          .height(42)
          .borderRadius(8)
          .backgroundColor($r('app.color.color_ffffff'))
        }
        .width(130)
        .visibility(this.selectedNoteData.is_deleted == Delete.Yes ? Visibility.None : Visibility.Visible)
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
            prompt.showToast({ message: $r('app.string.restore'), duration: 2000 })
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
export struct EditNoteCompForPortrait {
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[]  = []
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Consume('SelectedFolderData') selectedFolderData: FolderData
  @Consume('RefreshFlag') refreshFlag: number
  @Consume('SelectedNoteData') selectedNoteData: NoteData;
  @Consume('PortraitModel') portraitModel: boolean
  @Consume('ChooseNote') chooseNote: boolean
  @Consume('EditModel') editModel: boolean
  controllerShow: WebController
  editContentDialogCtl: CustomDialogController = new CustomDialogController({
    builder: EditContentDialogPortrait({ confirm: this.confirm.bind(this), dialogType: 0 }),
    alignment: DialogAlignment.Bottom,
    autoCancel: true,
    customStyle: true,
  })

  confirm(excuteJs: string) {
    this.controllerShow.runJavaScript({ script: excuteJs })
  }

  build() {
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
      Column() {
        Image($r('app.media.circle_tick'))
          .width(24)
          .height(24)
          .onClick(() => {
            // 清单
            this.controllerShow.runJavaScript({ script: "javascript:RICH_EDITOR.setTodo()" })
          })
        Text($r("app.string.list"))
          .fontSize(10).fontColor('#182431')
          .padding({ top: 5 })
      }
      .alignItems(HorizontalAlign.Center)

      Column() {
        Image($r('app.media.font_style'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.editContentDialogCtl.open()
          })
        Text($r("app.string.style"))
          .fontSize(10).fontColor('#182431')
          .padding({ top: 5 })
      }
      .alignItems(HorizontalAlign.Center)

      Column() {
        Image($r('app.media.picture_white'))
          .width(24)
          .height(24)

        Text($r("app.string.photo"))
          .fontSize(10).fontColor('#182431')
          .padding({ top: 5 })
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width(360)
    .height(56)
    .visibility(this.selectedNoteData.is_deleted == Delete.No && this.editModel == true ?
      Visibility.Visible : Visibility.None)
  }
}

@Component
struct NoteDataMoveItemComp {
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[] = []
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = []
  private folderItem: FolderData

  build() {
    Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.Center }) {
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
