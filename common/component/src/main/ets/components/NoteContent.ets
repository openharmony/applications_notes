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
import {TableName, NoteTableColumn, SysDefFolderUuid, Favorite, Delete
} from '@ohos/utils/src/main/ets/default/model/databaseModel/EnumData'
import StyleConstants from '@ohos/utils/src/main/ets/default/constants/StyleConstants'
import {EditContentDialog, DeleteDialog, EditTitleDialog} from './CusDialogComp'
import FolderUtil from '@ohos/utils/src/main/ets/default/baseUtil/FolderUtil'
import NoteUtil from '@ohos/utils/src/main/ets/default/baseUtil/NoteUtil'
import prompt from '@system.prompt'
import featureAbility from '@ohos.ability.featureAbility'
import {LogUtil} from '@ohos/utils/src/main/ets/default/baseUtil/LogUtil'
import OperationUtils from '@ohos/utils/src/main/ets/default/baseUtil/OperationUtils'
import mediaquery from '@ohos.mediaquery'
import router from '@system.router';
import inputMethod from '@ohos.inputmethod';

const TAG = "NoteContent"

var timeID: number

@Component
export struct NoteContent {
  @Provide('SelectedNoteData') selectedNoteData: NoteData = AppStorage.Get('NewNote')
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Provide('Issave') issave: number = 0
  @Provide('EditModel') editModel: boolean = false
  controllerShow: WebController
  private editContentFlag = false

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
      AppStorage.SetOrCreate<NoteData>('NewNote', this.selectedNoteData)
      AppStorage.SetOrCreate<boolean>('needRefresh',true)
      // save continue data
      let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
      AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
      LogUtil.info(TAG, "callbackhtml, set continue note success")
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
      LogUtil.info(TAG, 'continueNote content', continueNote)
      AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
      LogUtil.info(TAG, 'callbackScheduledSave, set continue note success')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Flex({ direction: FlexDirection.Column, wrap: FlexWrap.NoWrap,
        alignItems: ItemAlign.Start, alignContent: FlexAlign.SpaceAround }) {
        Column() {
          ToolBarComp({ controllerShow: this.controllerShow })
        }.margin({ left: 24, right: 24 })

        Column() {
          NoteContentOverViewComp()

          Web({ src: $rawfile('editor.html'), controller: this.controllerShow })
            .javaScriptAccess(true)
            .onPageEnd((e) => {
              if (this.editContentFlag == false) {
                this.controllerShow.registerJavaScriptProxy({
                  object: this.noteContent,
                  name: "callBackToApp", // html-->  name.method
                  methodList: ["callbackhtml", "callbackScheduledSave"],
                })
                LogUtil.info(TAG, "finish register")
                this.controllerShow.refresh()
                this.editContentFlag = true
              }
              LogUtil.info(TAG, "finish loadurl")
              this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')" })
            })
            .zoomAccess(false)
            .height('70%')
            .width('100%')
        }
        .margin({ left: 12, right: 24, top: 16 })
        .width(StyleConstants.PERCENTAGE_100)
        .onClick(() => {
          // 添加定时器：3s自动保存
          if (timeID == undefined) {
            timeID = setInterval(() => {
              this.controllerShow.runJavaScript({ script: "scheduledSaveContent()" })
            }, 3000)
          }
          LogUtil.info(TAG, "setInterval timeID : " + timeID)
          this.issave = 0
          this.editModel = true
        })
      }
      .height(StyleConstants.PERCENTAGE_100)
    }
    .height(StyleConstants.PERCENTAGE_100)
    .width(StyleConstants.PERCENTAGE_100)
  }

  aboutToAppear(): void{
    LogUtil.info(TAG, "aboutToAppear")
  }

  aboutToDisappear(): void{
    clearInterval(timeID)
    LogUtil.info(TAG, "aboutToDisappear")
  }
}

@Component
export struct ToolBarComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @Consume('Issave') issave: number
  @Consume('EditModel') editModel: boolean
  controllerShow: WebController

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
      Image($r('app.media.narrow'))
        .height(24)
        .width(24)
        .onClick(() => {
          this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setInputEnabled(false)" })
          this.controllerShow.runJavaScript({ script: "getHtmlContent()" })
          // 清除定时器
          if (timeID != undefined) {
            LogUtil.info(TAG, "zoom, clearInterval timeID : " + timeID)
            clearInterval(timeID)
          }
          router.back()
        })
        .visibility(this.selectedNoteData.is_deleted == Delete.Yes ? Visibility.None : Visibility.Visible)

      if (this.editModel == false) {
        Row({ space: StyleConstants.SPACE_24 }) {
          Image(this.selectedNoteData.is_favorite == Favorite.Yes ? $r('app.media.favorite') : $r('app.media.favorite_cancel'))
            .height(24).width(24)
            .onClick(() => {
              this.selectedNoteData.is_favorite = (this.selectedNoteData.is_favorite == Favorite.Yes ? Favorite.No : Favorite.Yes)
              // update note to db
              let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
              predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
              RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
              // save continue data
              let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
              AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
              LogUtil.info(TAG, 'ToolBarComp, set continue note success')
            })
        }.width(36)
        .visibility(this.selectedNoteData.is_deleted == Delete.Yes ? Visibility.None : Visibility.Visible)
      } else {
        Row({ space: StyleConstants.SPACE_6 }) {
          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Image($r('app.media.circle_tick1'))
              .height(24)
              .width(24)
              .onClick(() => {
                // 退出键盘
                inputMethod.getInputMethodController().stopInput();
                // 清单
                this.controllerShow.runJavaScript({ script: "javascript:RICH_EDITOR.setTodo()" })
              })
          }.width(42)
          .height(42)
          .borderRadius(8)
          .backgroundColor($r('app.color.color_ffffff'))

          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Image($r('app.media.font_style'))
              .height(24)
              .width(24)
              .onClick(() => {
                // 退出键盘
                inputMethod.getInputMethodController().stopInput();
                LogUtil.info(TAG, 'editContentDialogCtl start')
                this.editContentDialogCtl.open()
              })
          }.width(42)
          .height(42)
          .borderRadius(8)
          .backgroundColor($r('app.color.color_ffffff'))

          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Image($r('app.media.picture_white')).height(24).width(24)
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
                this.issave = 1
                // 保存笔记信息到数据库
                this.controllerShow.runJavaScript({ script: "getHtmlContent()" })
              })
          }.width(42)
          .height(42)
          .borderRadius(8)
          .backgroundColor($r('app.color.color_ffffff'))
        }.width(274)
      }
    }
    .width(StyleConstants.PERCENTAGE_100)
    .height(80)
  }
}

@Component
export struct NoteContentOverViewComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = []
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[]  = []
  editTitleDialogCtl: CustomDialogController = new CustomDialogController({
    builder: EditTitleDialog({ confirm: this.confirm.bind(this) }),
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
    // save continue data
    let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
    AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
    LogUtil.info(TAG, "NoteContentOverViewComp confirm, set continue note success")
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
            let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
            predicates_note.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid)
            RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicates_note, null)
            // save continue data
            let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
            AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
            LogUtil.info(TAG, "NoteContentOverViewComp MenuBuilder, set continue note success")
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
            this.editTitleDialogCtl.open()
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
          Text(FolderUtil.getFolderText(FolderUtil.getFolderData(AppStorage.Get('AllFolderArray'), this.selectedNoteData.folder_uuid)))
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
struct NoteDataMoveItemComp {
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[] = []
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = []
  private folderItem: FolderData

  build() {
    Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.Center }) {
      Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap }) {
        Image(FolderUtil.getFolderIcon(this.folderItem.uuid))
          .objectFit(ImageFit.Fill)
          .width(24)
          .height(24)
          .flexShrink(0)
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

        Divider()
          .color($r("app.color.divider_color_e4e4e4"))
          .strokeWidth(1)
      }
      .padding({ left: 16 })
    }
    .width('100%')
    .height(56)
    .visibility(FolderUtil.isFolderMoveIn(this.folderItem) ? Visibility.Visible : Visibility.None)
  }
}