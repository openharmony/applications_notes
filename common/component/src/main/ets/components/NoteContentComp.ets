/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import DateUtil from '@ohos/utils/src/main/ets/default/baseUtil/DateUtil'
import RdbStoreUtil from '@ohos/utils/src/main/ets/default/baseUtil/RdbStoreUtil'
import FolderData from '@ohos/utils/src/main/ets/default/model/databaseModel/FolderData'
import NoteData from '@ohos/utils/src/main/ets/default/model/databaseModel/NoteData'
import {TableName, NoteTableColumn, SysDefFolderUuid, Favorite, Delete} from '@ohos/utils/src/main/ets/default/model/databaseModel/EnumData'
import StyleConstants from '@ohos/utils/src/main/ets/default/constants/StyleConstants'
import {EditContentDialog, DeleteDialog, EditTitleDialog} from './CusDialogComp'
import FolderUtil from '@ohos/utils/src/main/ets/default/baseUtil/FolderUtil'
import NoteUtil from '@ohos/utils/src/main/ets/default/baseUtil/NoteUtil'
import prompt from '@system.prompt'
import featureAbility from '@ohos.ability.featureAbility'
import {LogUtil} from '@ohos/utils/src/main/ets/default/baseUtil/LogUtil'
import OperationUtils from '@ohos/utils/src/main/ets/default/baseUtil/OperationUtils'
import mediaquery from '@ohos.mediaquery'
import inputMethod from '@ohos.inputmethod';
import {folderTextMap} from '@ohos/utils/src/main/ets/default/model/NoteBaseData'

const TAG = "NoteContentComp"

var timeId : number

// Note content component
let inSetValue = AppStorage.Link('inSetValue')
@Component
export struct NoteContentComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Consume('SelectedFolderData') selectedFolderData: FolderData
  @Consume('RefreshFlag') refreshFlag: number
  @Consume('EditModel') editModel: boolean
  @Consume('SectionStatus') sectionStatus: number
  @Consume('LastSectionStatus') lastSectionStatus: number
  @Consume('Issave') issave: number
  controllerShow: WebController
  private editContentFlag = false
  @State uri1: string = ""
  private context = getContext(this)
  noteContent = {
    callbackhtml: (html) => {
      LogUtil.info(TAG, 'note uuid is:' + this.selectedNoteData.uuid)
      this.selectedNoteData.content_text = html
      this.selectedNoteData.modified_time = new Date().getTime()
      // updata note image
      this.selectedNoteData.content_img = RdbStoreUtil.updataNoteImage(this.selectedNoteData)
      let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
      predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
      RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
      LogUtil.info(TAG, 'update note success:' + this.selectedNoteData.uuid)
      // save continue data
      let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
      AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
      LogUtil.info(TAG, "callbackhtml, set continue note success")
      return "AceString"
    },

    callbackhtmlSave: (html) => {
      LogUtil.info(TAG, 'note uuid is:' + this.selectedNoteData.uuid)
      this.selectedNoteData.content_text = html
      this.selectedNoteData.modified_time = new Date().getTime()
      // updata note image
      this.selectedNoteData.content_img = RdbStoreUtil.updataNoteImage(this.selectedNoteData)
      let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
      predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
      RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
      LogUtil.info(TAG, 'update note success:' + this.selectedNoteData.uuid)
      this.sectionStatus = this.lastSectionStatus
      this.sectionStatus = mediaquery.matchMediaSync('(width < 2000)').matches ? 2 : 3
      // save continue data
      let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
      AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
      AppStorage.SetOrCreate<number>('ContinueSection', this.sectionStatus)
      LogUtil.info(TAG, "callbackhtmlSave, set continue note and section success")
      return "AceString"
    },

    callbackScheduledSave: (html) => {
      LogUtil.info(TAG, 'callbackScheduledSave')
      this.selectedNoteData.content_text = html
      this.selectedNoteData.modified_time = new Date().getTime()
      // updata note image
      this.selectedNoteData.content_img = RdbStoreUtil.updataNoteImage(this.selectedNoteData)
      let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
      predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
      RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
      LogUtil.info(TAG, 'callbackScheduledSave, update note success:' + this.selectedNoteData.uuid)
      // save continue data
      let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
      AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
      LogUtil.info(TAG, 'callbackScheduledSave, set continue note success')
    },

    callbackGetSize: (size) => {
      if(size) {
        AppStorage.Set<number>('inSetValue', parseInt(size.slice(0,-2)) - 12)
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Flex({ direction: FlexDirection.Column, wrap: FlexWrap.NoWrap,
        alignItems: ItemAlign.Start, alignContent: FlexAlign.SpaceAround }) {
        Column() {
          ToolBarComp({ controllerShow: this.controllerShow })
        }
        .margin({ left: 24, right: 24 })

        Column() {
          NoteContentOverViewComp({ controllerShow: this.controllerShow })
          Text(this.refreshFlag.toString()).visibility(Visibility.None)
          Text(this.AllNoteArray.length.toString()).visibility(Visibility.None) // 用于强制刷新使用

          Web({ src: $rawfile('editor.html'), controller: this.controllerShow })
            .javaScriptAccess(true)
            .onPageEnd((e) => {
              if (this.editContentFlag == false) {
                this.controllerShow.registerJavaScriptProxy({
                  object: this.noteContent,
                  name: "callBackToApp", // html-->  name.method
                  methodList: ["callbackhtml", "callbackhtmlSave", "callbackScheduledSave", "callbackGetSize"],
                })
                LogUtil.info(TAG, "finish register")
                this.controllerShow.refresh()
                this.editContentFlag = true
              }
              LogUtil.info(TAG, "finish loadurl")
              this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')" })
              // 初次加载为为小屏预览模式
              if (this.sectionStatus != 1) {
                this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setInputEnabled(false)" })
              }
            })
            .zoomAccess(false)
            .height('70%')
            .width('100%')
        }
        .margin({ left: 12, right: 24 })
        .width(StyleConstants.PERCENTAGE_100)
        .enabled(this.selectedNoteData && this.selectedNoteData.is_deleted == Delete.Yes ? false : true)
        .onClick(() => {
          this.issave = 0
          LogUtil.info(TAG, "editModel : " + this.editModel + ", sectionStatus : " + this.sectionStatus)
          let isContinue = AppStorage.Get<boolean>('IsContinue')
          LogUtil.info(TAG, "isContinue : " + isContinue)
          // 点击第三屏进入全屏编辑模式
          if (this.sectionStatus != 1 || isContinue) {
            this.lastSectionStatus = this.sectionStatus
            this.sectionStatus = 1
            this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setInputEnabled(true)" })
            // 添加定时器：3s自动保存
            timeId = setInterval(() => {
              this.controllerShow.runJavaScript({ script: "scheduledSaveContent()" })
            }, 3000)
            LogUtil.info(TAG, "setInterval timeId : " + timeId)
            // save continue data
            AppStorage.SetOrCreate<number>('ContinueSection', this.sectionStatus)
            LogUtil.info(TAG, "set continue section success")
            this.editModel = !this.editModel
            AppStorage.SetOrCreate<boolean>('IsContinue', false)
          }
        })
      }
      .height(StyleConstants.PERCENTAGE_100)
      .visibility(FolderUtil.getNoteCount(AppStorage.Get('AllNoteArray'), this.selectedFolderData.uuid) == 0 ? Visibility.Hidden : Visibility.Visible)
    }
    .height(StyleConstants.PERCENTAGE_100)
    .width(StyleConstants.PERCENTAGE_100)
  }

  aboutToAppear(): void{
    LogUtil.info(TAG, "aboutToAppear")
  }

  aboutToDisappear(): void{
    LogUtil.info(TAG, "aboutToDisappear")
  }

}

@Component
export struct NoteContentOverViewComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData
  @StorageLink('AllFolderArray') @Watch('getArray') AllFolderArray: FolderData[]  = []
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[]  = []
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Consume('SelectedFolderData') selectedFolderData: FolderData
  @Consume('EditModel') editModel: boolean
  @Consume('SectionStatus') sectionStatus: number
  @Consume('RefreshFlag') refreshFlag: number
  NoteDataMoveArray: FolderData[]
  controllerShow: WebController
  editTitleDialogCtl: CustomDialogController = new CustomDialogController({
    builder: EditTitleDialog({ confirm: this.confirm.bind(this) }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true,
  })

  getArray() {
    this.NoteDataMoveArray = this.AllFolderArray.slice(2, this.AllFolderArray.length);
    this.NoteDataMoveArray.push(this.AllFolderArray[1]);
  }
  aboutToAppear() {
    this.NoteDataMoveArray = this.AllFolderArray.slice(2, this.AllFolderArray.length);
    this.NoteDataMoveArray.push(this.AllFolderArray[1]);
  }

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
        ForEach(this.NoteDataMoveArray, (item) => {
          ListItem() {
            NoteDataMoveItemCompTablet({ folderItem: item, uuid: this.selectedNoteData.folder_uuid })
          }
          .onClick(() => {
            this.selectedNoteData.folder_uuid = item.uuid
            let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
            predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
            RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
            if(this.sectionStatus != 1) {
              this.selectedNoteData = NoteUtil.getFirstNoteData(this.AllNoteArray, this.selectedFolderData.uuid)
              this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')" })
              this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
            } else {
              this.selectedFolderData = FolderUtil.getFolderData(AppStorage.Get('AllFolderArray'), item.uuid)
            }
            // save continue data
            let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
            AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
            LogUtil.info(TAG, "NoteContentOverViewComp, MenuBuilder, set continue note success")
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
        Text(this.selectedNoteData.title)
          .fontSize(30)
          .margin({ left: 12, right: 24 })
          .onClick(() => {
            this.editModel = true
            this.sectionStatus = 1
            this.editTitleDialogCtl.open()
            // save continue data
            AppStorage.SetOrCreate<number>('ContinueSection', this.sectionStatus)
            LogUtil.info(TAG, "NoteContentComp, set continue section success")
          })
      }.height(40)
      .width(StyleConstants.PERCENTAGE_100)

      Row() {
        Text(DateUtil.formateDateForNoteContent(new Date(this.selectedNoteData.modified_time)))
          .fontSize(12)
          .padding({ top: 4, bottom: 4 })
          .fontColor($r("app.color.modified_time_font_color"))
          .margin({ left: 12 })
        Row() {
          Text(FolderUtil.getFolderText(FolderUtil.getFolderData(AppStorage.Get('AllFolderArray'), this.selectedNoteData.folder_uuid)) ==
               folderTextMap["sys_def_myFavorites_uuid"] ? folderTextMap["sys_def_unClassified_uuid"] :
               FolderUtil.getFolderText(FolderUtil.getFolderData(AppStorage.Get('AllFolderArray'), this.selectedNoteData.folder_uuid)))
            .fontSize(12)
            .fontColor($r("app.color.list_modified_time_font_color"))
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
    .opacity(this.selectedNoteData.is_deleted == Delete.Yes ? 0.4 : 1)
    .width(StyleConstants.PERCENTAGE_100)
    .height(80)
  }
}

@Component
export struct ToolBarComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData
  @Consume('RefreshFlag') refreshFlag: number
  @Consume('SectionStatus') sectionStatus: number
  @Consume('LastSectionStatus') lastSectionStatus: number
  @Consume('SelectedFolderData') selectedFolderData: FolderData
  @Consume('ChooseNote') chooseNote: boolean
  @Consume('PortraitModel') portraitModel: boolean
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Consume('EditModel') editModel: boolean
  @Consume('Issave') issave: number
  controllerShow: WebController
  private context = getContext(this)

  noteDataDeleteDialogCtl: CustomDialogController = new CustomDialogController({
    builder: DeleteDialog({ onConfirm: this.onDeleteConfirm.bind(this) }),
    alignment: DialogAlignment.Center,
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
    this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')" })
    this.chooseNote = false
    // save continue data
    let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
    AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
    LogUtil.info(TAG, "NoteContentOverViewComp, set continue note success")
  }

  editContentDialogCtl: CustomDialogController = new CustomDialogController({
    builder: EditContentDialog({ confirm: this.confirm.bind(this) }),
    alignment: DialogAlignment.Bottom,
    autoCancel: true,
    customStyle: true,
  })

  confirm(excuteJs: string) {
    this.controllerShow.runJavaScript({ script: excuteJs })
  }

  build() {
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Image(this.sectionStatus == 1 ? $r('app.media.narrow') : $r('app.media.zoom'))
        .height(24)
        .width(24)
        .onClick(() => {
          if (this.sectionStatus != 1) {
            this.lastSectionStatus = this.sectionStatus
            this.sectionStatus = 1
            this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setInputEnabled(true)" })
          } else {
            if (this.lastSectionStatus != undefined) {
              // 切换为小屏预览模式
              this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setInputEnabled(false)" })
              this.sectionStatus = this.lastSectionStatus
              // 退出全屏时存库
              LogUtil.info(TAG, "close note" + this.selectedNoteData.uuid)
              this.controllerShow.runJavaScript({ script: "saveHtmlContent()" })
              //退出键盘
              inputMethod.getInputMethodController().stopInput();
              // 清除定时器
              if (timeId != undefined) {
                LogUtil.info(TAG, "zoom, clearInterval timeId : " + timeId)
                clearInterval(timeId)
              }
            } else {
              this.sectionStatus = 3
            }
          }
          this.editModel = !this.editModel
          // save continue data
          AppStorage.SetOrCreate<number>('ContinueSection', this.sectionStatus)
          LogUtil.info(TAG, "ToolBarComp, set continue section success")
        })
        .visibility(!this.selectedNoteData ? Visibility.None : this.selectedNoteData.is_deleted == Delete.Yes ? Visibility.None : Visibility.Visible)

      if (this.selectedNoteData) {
        if (this.selectedNoteData.is_deleted == Delete.Yes) {
          Row({ space: StyleConstants.SPACE_24 }) {
            Image($r('app.media.delete'))
              .height(24)
              .width(24)
              .onClick(() => {
                this.noteDataDeleteDialogCtl.open()
              })
            Image($r('app.media.recover'))
              .height(24)
              .width(24)
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
                this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')" })
                // save continue data
                let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
                AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
                LogUtil.info(TAG, "recover, set continue note success")
              })
          }.width(72)
        } else if (this.editModel == true) {
          Row({ space: StyleConstants.SPACE_6 }) {
            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.circle_tick1'))
                .height(24)
                .width(24)
                .onClick(() => {
                  // 清单
                  this.controllerShow.runJavaScript({ script: "javascript:RICH_EDITOR.setTodo()" })
                  // 退出键盘
                  inputMethod.getInputMethodController().stopInput();
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_ffffff'))

            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.styles'))
                .height(24)
                .width(24)
                .onClick(() => {
                  // 退出键盘
                  inputMethod.getInputMethodController().stopInput();
                  this.editContentDialogCtl.open()
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_ffffff'))

            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.picture_white'))
                .height(24)
                .width(24)
                .onClick(async () => {
                  // 退出键盘
                  inputMethod.getInputMethodController().stopInput();
                  LogUtil.info(TAG, 'startAbility start')
                  await globalThis.noteContext.startAbilityForResult({
                    parameters: { uri: "singleselect" },
                    bundleName: "com.ohos.photos",
                    abilityName: "com.ohos.photos.MainAbility",
                  })
                    .then(v => {
                      let want = v['want'];
                      if (want != null && want != undefined) {
                        let param = want['parameters'];
                        let imageUri = ""
                        if (param != null && param != undefined) {
                          let uri = param['select-item-list'];
                          imageUri = uri;
                        }
                        // 拷贝
                        if(imageUri != null && imageUri != "") {
                          OperationUtils.copy(imageUri).then((uriPath) => {
                            var path = "file://" + uriPath
                            LogUtil.info(TAG, 'image uri is:' + path)
                            this.controllerShow.runJavaScript({script:"javascript:RICH_EDITOR.insertImage('" + path + "')"})
                          })
                        }
                      }
                    });
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_ffffff'))


            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.undo'))
                .height(24)
                .width(24)
                .onClick(() => {
                  // 退出键盘
                  inputMethod.getInputMethodController().stopInput();
                  this.controllerShow.runJavaScript({ script: "RICH_EDITOR.undo()" })
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_ffffff'))

            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.todo'))
                .height(24)
                .width(24)
                .onClick(() => {
                  // 退出键盘
                  inputMethod.getInputMethodController().stopInput();
                  this.controllerShow.runJavaScript({ script: "RICH_EDITOR.redo()" })
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_ffffff'))


            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.tick_thick'))
                .height(24)
                .width(24)
                .fillColor(this.issave == 0 ? Color.Black : Color.Grey)
                .onClick(() => {
                  // 保存笔记信息到数据库
                  this.controllerShow.runJavaScript({ script: "getHtmlContent()" })
                  if (this.selectedNoteData.title == "标题" && this.selectedNoteData.content_text == "") {
                    LogUtil.info(TAG, "note is empty,save note failed")
                  }
                  this.issave = 1
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_ffffff'))
          }.width(274)
        } else {
          Row({ space: StyleConstants.SPACE_24 }) {
            Image(this.selectedNoteData.is_favorite == Favorite.Yes ? $r('app.media.favorite') : $r('app.media.favorite_cancel'))
              .height(24)
              .width(24)
              .onClick(() => {
                this.selectedNoteData.is_favorite = (this.selectedNoteData.is_favorite == Favorite.Yes ? Favorite.No : Favorite.Yes)
                this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
                // update note to db
                let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
                predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
                RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
                if (this.selectedFolderData.uuid === SysDefFolderUuid.MyFavorites) {
                  this.selectedNoteData = NoteUtil.getFirstNoteData(AppStorage.Get('AllNoteArray'), SysDefFolderUuid.MyFavorites)
                  this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')" })
                  // save continue data
                  let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
                  AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
                  LogUtil.info(TAG, "ToolBarComp, set continue note success")
                }
              })
            Image($r('app.media.delete'))
              .height(24)
              .width(24)
              .onClick(() => {
                this.noteDataDeleteDialogCtl.open()
              })
          }.width(72)
        }
      }
    }
    .width(StyleConstants.PERCENTAGE_100)
    .height(80)
  }
}

@Component
struct NoteDataMoveItemCompTablet {
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[] = []
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = []
  folderItem: FolderData
  uuid: String

  build() {
    Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.Center }) {
      Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap }) {
        Image(FolderUtil.getFolderIcon(this.folderItem.uuid))
          .objectFit(ImageFit.Fill)
          .width(24)
          .height(24)
          .flexShrink(0)
          .fillColor(FolderUtil.getFolderIconColor(this.AllFolderArray, this.folderItem.uuid, this.folderItem.uuid == this.uuid))
      }
      .width(24)

      Column() {
        Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween }) {
          Text(FolderUtil.getFolderText(this.folderItem))
            .fontSize(16)
            .fontColor(FolderUtil.getFolderIconColor(this.AllFolderArray, this.folderItem.uuid == this.uuid ? this.folderItem.uuid : '', this.folderItem.uuid == this.uuid))
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .flexShrink(1)
        }
        .width('100%')
        .height(55)

        if (this.folderItem.uuid != SysDefFolderUuid.UnClassified) {
          Divider()
            .color($r("app.color.divider_color_e4e4e4"))
            .strokeWidth(1)
        }
      }
      .padding({ left: 16 })
    }
    .width('100%')
    .height(56)
    .visibility(FolderUtil.isFolderMoveIn(this.folderItem) ? Visibility.Visible : Visibility.None)
  }
}
