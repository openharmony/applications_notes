/*
 * Copyright (c) 2022-2025 Huawei Device Co., Ltd.
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

import DateUtil from '@ohos/utils/src/main/ets/default/baseUtil/DateUtil';
import RdbStoreUtil from '@ohos/utils/src/main/ets/default/baseUtil/RdbStoreUtil';
import FolderData from '@ohos/utils/src/main/ets/default/model/databaseModel/FolderData';
import NoteData from '@ohos/utils/src/main/ets/default/model/databaseModel/NoteData';
import {
  Delete,
  Favorite,
  FolderType,
  NoteTableColumn,
  SysDefFolderUuid,
  TableName
} from '@ohos/utils/src/main/ets/default/model/databaseModel/EnumData';
import StyleConstants from '@ohos/utils/src/main/ets/default/constants/StyleConstants';
import { DeleteDialog, EditContentDialog } from './CusDialogComp';
import FolderUtil from '@ohos/utils/src/main/ets/default/baseUtil/FolderUtil';
import NoteUtil from '@ohos/utils/src/main/ets/default/baseUtil/NoteUtil';
import util from '@ohos.util';
import { LogUtil } from '@ohos/utils/src/main/ets/default/baseUtil/LogUtil';
import OperationUtils from '@ohos/utils/src/main/ets/default/baseUtil/OperationUtils';
import inputMethod from '@ohos.inputMethod';
import { folderTextMap } from '@ohos/utils/src/main/ets/default/model/NoteBaseData';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import webview from '@ohos.web.webview';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import resourceManager from '@ohos.resourceManager';

const TAG = 'NoteContentComp';

let timeId: number = 0;
let noteContext = AppStorage.get<common.UIAbilityContext>('noteContext')!;

// Note content component
let inSetValue: string = AppStorage.Link('inSetValue');

interface NoteContentType {
  callbackhtml: (html: string) => void;
  callbackImagePath: (imgName: string) => void;
  callbackhtmlSave: (html: string) => void;
  callbackScheduledSave: (html: string) => void;
  callbackPasteImage: (html: string) => void;
  callbackGetSize: (fontSize: number) => void;
}

@Component
export struct NoteContentComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData;
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[] = AppStorage.Link('AllNoteArray');
  @Consume('SelectedFolderData') selectedFolderData: FolderData;
  @Consume('RefreshFlag') refreshFlag: number;
  @Consume('EditModel') editModel: boolean;
  @Consume('SectionStatus') sectionStatus: number;
  @Consume('LastSectionStatus') lastSectionStatus: number;
  @Consume('Issave') issave: number;
  @Consume('Search') search: boolean;
  @StorageLink('dpi') dpi: number = 240;
  controllerShow: webview.WebviewController = new webview.WebviewController();
  @State uri1: string = "";
  @StorageLink('ScrollTopPercent') scrollTopPercent: number = 0.0;
  @StorageLink('isUpdate') isUpdate: boolean = false;
  @StorageLink('refreshCurrentNote') @Watch('isDataChange') refreshCurrentNote: boolean = false;
  @Consume('AsideWidth') asideWidth: number;

  isDataChange() {
    if (!this.refreshCurrentNote) {
      return;
    }
    try {
      LogUtil.info(TAG, `isDataChange runJavaScript setHtml ` + this.selectedNoteData.content_text);
      this.controllerShow.runJavaScript("RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')");
      LogUtil.info(TAG, `runJavaScript setHtml success.`);
    } catch (error) {
      LogUtil.error(TAG, `runJavaScript setHtml failed.code:${JSON.stringify(error.code)},
        message:${JSON.stringify(error.message)}`);
    }
    this.refreshCurrentNote = false;
  }

  storeScrollTop(scrollTop: number) {
    if (scrollTop < 0) {
      return;
    }
    AppStorage.setOrCreate<number>('ScrollTopPercent', scrollTop / this.controllerShow.getPageHeight());
  }

  restoreScrollTop() {
    try {
      LogUtil.info(TAG, 'restoreScrollTop');
      if (!AppStorage.has('remoteScrollTopPercent')) {
        return;
      }
      let scrollTopPercent = AppStorage.Get<number>('remoteScrollTopPercent')!;
      if (scrollTopPercent < 0) {
        return;
      }
      LogUtil.info(TAG,
        'runJavaScript document.documentElement.scrollTop = ' + this.controllerShow.getPageHeight() * scrollTopPercent);
      this.controllerShow.runJavaScript(
        'document.documentElement.scrollTop = ' + this.controllerShow.getPageHeight() * scrollTopPercent
      )
    } catch (error) {
      LogUtil.error(TAG, `restoreScrollTop failed.code:${JSON.stringify(error.code)},
      message:${JSON.stringify(error.message)}`);
    }
  }

  restoreFocus() {
    LogUtil.info(TAG, 'restoreFocus');
    if (!AppStorage.Has('isRemoteFocusOnSearch')) {
      return;
    }
    LogUtil.info(TAG, 'restoreFocus not return');
    let isRemoteFocusOnSearch = AppStorage.Get<boolean>('isRemoteFocusOnSearch');
    if (isRemoteFocusOnSearch) {
      LogUtil.info(TAG, 'restoreFocus isRemoteFocusOnSearch');
      focusControl.requestFocus('searchInput');
    }
    AppStorage.delete('isRemoteFocusOnSearch');
  }

  noteContent: NoteContentType = {
    callbackhtml: (html) => {
      try {
        LogUtil.info(TAG, 'note uuid is:' + this.selectedNoteData.uuid);
        this.selectedNoteData.content_text = NoteUtil.contrastInitType(this.selectedNoteData.content_text);
        if (this.selectedNoteData.content_text === html) {
          return;
        }
        ;
        this.selectedNoteData.content_text = html;
        this.selectedNoteData.modified_time = new Date().getTime();
        let predicatesNote = RdbStoreUtil.getRdbPredicates(TableName.NoteTable);
        predicatesNote.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid);
        RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicatesNote, null);
        LogUtil.info(TAG, 'update note success:' + JSON.stringify(this.selectedNoteData));
        // save continue data
        let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject());
        AppStorage.setOrCreate<string>('ContinueNote', continueNote);
        LogUtil.info(TAG, 'callbackhtml, set continue note success');
        return 'AceString';
      } catch (error) {
        LogUtil.error(TAG, 'callbackhtml error: ' + JSON.stringify(error));
        return 'AceString';
      }
    },
    callbackImagePath: (imgName) => {
      // updata note image
      try {
        LogUtil.info(TAG, 'note imgName is:' + imgName);
        this.selectedNoteData.content_img = imgName;
        LogUtil.info(TAG, 'set content_img success');
      } catch (error) {
        LogUtil.error(TAG, 'callbackImagePath error: ' + JSON.stringify(error));
      }
    },

    callbackhtmlSave: (html) => {
      try {
        LogUtil.info(TAG, 'note uuid is:' + this.selectedNoteData.uuid);
        this.selectedNoteData.content_text = html;
        this.selectedNoteData.modified_time = new Date().getTime();
        let predicatesNote = RdbStoreUtil.getRdbPredicates(TableName.NoteTable);
        predicatesNote.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid);
        RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicatesNote, null);
        LogUtil.info(TAG, 'update note success:' + JSON.stringify(this.selectedNoteData));
        this.sectionStatus = this.lastSectionStatus;
        this.sectionStatus = this.getUIContext().getMediaQuery().matchMediaSync('(width < 2000)').matches ? 2 : 3;
        // save continue data
        let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject());
        AppStorage.setOrCreate<string>('ContinueNote', continueNote);
        AppStorage.setOrCreate<number>('ContinueSection', this.sectionStatus);
        LogUtil.info(TAG, 'callbackhtmlSave, set continue note and section success');
        return 'AceString';
      } catch (error) {
        LogUtil.error(TAG, 'callbackhtmlSave error: ' + JSON.stringify(error));
        return 'AceString';
      }
    },

    callbackScheduledSave: (html) => {
      try {
        LogUtil.info(TAG, 'callbackScheduledSave');
        if (this.selectedNoteData.content_text == html) {
          LogUtil.info(TAG, 'callbackScheduledSave the same value return');
          return;
        }
        this.selectedNoteData.content_text = html;
        this.selectedNoteData.modified_time = new Date().getTime();
        let predicatesNote = RdbStoreUtil.getRdbPredicates(TableName.NoteTable);
        predicatesNote.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid);
        RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicatesNote, null);
        LogUtil.info(TAG, 'callbackScheduledSave, update note success:' + JSON.stringify(this.selectedNoteData));
        // save continue data
        let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject());
        AppStorage.SetOrCreate<string>('ContinueNote', continueNote);
        LogUtil.info(TAG, 'callbackScheduledSave, set continue note success');
      } catch (error) {
        LogUtil.error(TAG, 'callbackScheduledSave error: ' + JSON.stringify(error));
      }
    },

    callbackPasteImage: (html) => {
      try {
        LogUtil.info(TAG, 'paste image callback start');
        if (html) {
          LogUtil.info(TAG, 'paste info' + html);
          let realHtml = "";
          let base64regex: RegExp = new RegExp('/^([0-9a-zA-Z+/]{4})*(([0-9a-zA-Z+/]{2}==)|([0-9a-zA-Z+/]{3}=))?$/');
          if (html && html.indexOf('base64') > 0) {
            LogUtil.info(TAG, ' getSrcFromHtml, src[1] : ' + html);
            let imgData = html.split(',')[1];
            let imgType = 'png';
            if (html.indexOf('jpeg') > 0) {
              imgType = 'jpg';
            } else if (html.indexOf('gif') > 0) {
              imgType = 'gif';
            }
            let filePath = "";
            if (base64regex.test(imgData)) {
              let base64 = new util.Base64Helper();
              let decodeArr = base64.decodeSync(imgData);
              filePath = OperationUtils.saveImageData(decodeArr, imgType);
            } else {
              filePath = OperationUtils.saveImage(imgData, imgType);
            }
            realHtml = 'file://' + filePath;
          }
          LogUtil.info(TAG, 'paste info11-' + realHtml);
          this.controllerShow.runJavaScript("javascript:RICH_EDITOR.insertImageHtml('" + realHtml + "')");
          LogUtil.info(TAG, 'paste info11--' + realHtml);
        } else {
          LogUtil.info(TAG, 'paste info22225');
        }
      } catch (error) {
        LogUtil.error(TAG, `callbackPasteImage failed.code:${JSON.stringify(error.code)},
        message:${JSON.stringify(error.message)}`);
      }
    },
    callbackGetSize: (fontSize) => {
      if (fontSize === 16) {
        this.selectedNoteData.slider_value = 0;
      } else if (fontSize === 18) {
        this.selectedNoteData.slider_value = 4;
      } else if (fontSize === 24) {
        this.selectedNoteData.slider_value = 8;
      } else if (fontSize === 32) {
        this.selectedNoteData.slider_value = 12;
      } else if (fontSize === 48) {
        this.selectedNoteData.slider_value = 16;
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Flex({
        direction: FlexDirection.Column,
        wrap: FlexWrap.NoWrap,
        alignItems: ItemAlign.Start,
        alignContent: FlexAlign.SpaceAround
      }) {
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
            .javaScriptProxy({
              object: this.noteContent,
              name: 'callBackToApp', // html-->  name.method
              methodList: ['callbackhtml', 'callbackhtmlSave', 'callbackScheduledSave', 'callbackGetSize',
                'callbackPasteImage', 'callbackImagePath'],
              controller: this.controllerShow
            })
            .enabled(this.sectionStatus !== 1 ? false : true)
            .onPageEnd((e) => {
              try {
                LogUtil.info(TAG, `dpi：${this.dpi}}`);
                if (this.dpi <= 240) {
                  this.controllerShow.runJavaScript('changeSizeToRk()');
                } else if (this.dpi <= 320 && this.dpi > 240) {
                  this.controllerShow.runJavaScript('changeSizeToPhone()');
                } else {
                  this.controllerShow.runJavaScript('changeSizeToTablet()');
                }
                if (AppStorage.Get('breakPoint') !== 'sm') {
                  this.controllerShow.runJavaScript('hiddenButton()');
                }
                LogUtil.info(TAG, 'finish loadurl');
                if (this.selectedNoteData) {
                  let self = this;
                  LogUtil.info(TAG, 'runJavaScript setHtml ：' + this.selectedNoteData.content_text);
                  this.controllerShow.runJavaScript(
                    "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')",
                    () => {
                      LogUtil.info(TAG, 'runJavaScript setHtml success');
                      // wait for the image in the note to load
                      setTimeout(() => {
                        self.restoreScrollTop();
                        self.restoreFocus();
                      }, 100)
                    }
                  );
                }
                // 初次加载为为小屏预览模式
                if (this.sectionStatus != 1) {
                  this.controllerShow.runJavaScript('RICH_EDITOR.setInputEnabled(false)');
                }
              } catch (error) {
                LogUtil.info(TAG,
                  `runJavaScript onPageEnd error. code:${JSON.stringify(error.code)},message:${error.message}`);
              }
            })
            .imageAccess(true)
            .onlineImageAccess(true)
            .fileAccess(true)
            .domStorageAccess(true)
            .zoomAccess(false)
            .height('88%')
            .width('100%')
            .onScroll((event) => {
              this.storeScrollTop(event.yOffset);
            })
        }
        .margin({ left: 24, right: 24 })
        //        .width(StyleConstants.PERCENTAGE_100)
        .enabled(this.selectedNoteData && this.selectedNoteData.is_deleted == Delete.Yes ? false : true)
        .onClick(() => {
          try {
            this.issave = 0;
            LogUtil.info(TAG, 'editModel : ' + this.editModel + ', sectionStatus : ' + this.sectionStatus);
            let isContinue = AppStorage.get<boolean>('IsContinue');
            LogUtil.info(TAG, 'isContinue : ' + isContinue);
            // 点击第三屏进入全屏编辑模式
            if (this.sectionStatus != 1 || isContinue) {
              LogUtil.info(TAG, 'Third Screen Full Screen Edit Mode');
              this.asideWidth = 0;
              this.lastSectionStatus = this.sectionStatus;
              this.sectionStatus = 1;
              this.controllerShow.runJavaScript('RICH_EDITOR.setInputEnabled(true)');
              // 添加定时器：3s自动保存
              if (timeId) {
                clearInterval(timeId);
              }
              timeId = setInterval(() => {
                LogUtil.info(TAG, 'runJavaScript(scheduledSaveContent) start');
                this.controllerShow.runJavaScript('scheduledSaveContent()');
                LogUtil.info(TAG, 'runJavaScript(scheduledSaveContent) end');
              }, 3000)
              LogUtil.info(TAG, 'setInterval timeId : ' + timeId);
              // save continue data
              AppStorage.SetOrCreate<number>('ContinueSection', this.sectionStatus);
              LogUtil.info(TAG, 'set continue section success');
              this.editModel = !this.editModel;
              AppStorage.SetOrCreate<boolean>('IsContinue', false);
            }
          } catch (error) {
            LogUtil.error(TAG, `Column failed.code:${JSON.stringify(error.code)},
            message:${JSON.stringify(error.message)}`);
          }
        })
      }
      .id(this.isUpdate + '')
      .height(StyleConstants.PERCENTAGE_100)
      .visibility(FolderUtil.getNoteCount(AppStorage.get('AllNoteArray'), this.selectedFolderData.uuid) == 0 ?
      Visibility.Hidden : Visibility.Visible)

      Column() {
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#18181A')
      .opacity(0.1)
      .visibility(this.search ? Visibility.Visible : Visibility.Hidden)
    }
    .height(StyleConstants.PERCENTAGE_100)
    .width(StyleConstants.PERCENTAGE_100)
  }

  aboutToAppear(): void {
    LogUtil.info(TAG, 'aboutToAppear')
  }

  aboutToDisappear(): void {
    clearInterval(timeId)
    LogUtil.info(TAG, 'aboutToDisappear')
  }

  onPageShow(): void {
    LogUtil.info(TAG, 'onPageShow')
  }

  onPageHide(): void {
    LogUtil.info(TAG, 'onPageHide')
  }
}

@Component
export struct NoteContentOverViewComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData;
  @StorageLink('AllFolderArray') @Watch('getArray') AllFolderArray: FolderData[] = [];
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[] = [];
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[] = AppStorage.Link('AllNoteArray');
  @Consume('SelectedFolderData') selectedFolderData: FolderData;
  @Consume('EditModel') editModel: boolean;
  @Consume('SectionStatus') sectionStatus: number;
  @Consume('RefreshFlag') refreshFlag: number;
  @StorageLink('isUpdate') isUpdate: boolean = false;
  NoteDataMoveArray: FolderData[] = [];
  controllerShow: webview.WebviewController = new webview.WebviewController();
  editTitleDialogCtl: CustomDialogController | null = new CustomDialogController({
    builder: EditContentDialog({
      confirm: (newTitle: string) => {
        this.confirm(newTitle);
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true,
  })

  getArray() {
    this.NoteDataMoveArray = this.AllFolderArray.slice(2, this.AllFolderArray.length);
    if (this.AllFolderArray[1] === undefined || this.AllFolderArray[1] === null) {
      LogUtil.info(TAG, 'NoteContentOverViewComp this AllFolderArray[1] undefined');
      return;
    }
    this.NoteDataMoveArray.push(this.AllFolderArray[1]);
  }

  aboutToAppear() {
    LogUtil.info(TAG, 'NoteContentOverViewComp aboutToAppear');
    this.NoteDataMoveArray = this.AllFolderArray.slice(2, this.AllFolderArray.length);
    if (this.AllFolderArray[1] === undefined || this.AllFolderArray[1] === null) {
      LogUtil.info(TAG, 'NoteContentOverViewComp this AllFolderArray[1] undefined');
      return;
    }
    LogUtil.info(TAG, 'NoteContentOverViewComp ' + JSON.stringify(this.AllFolderArray));
    this.NoteDataMoveArray.push(this.AllFolderArray[1]);
  }

  aboutToDisappear() {
    LogUtil.info(TAG, 'NoteContentOverViewComp aboutToDisappear');
    this.editTitleDialogCtl = null;
  }

  confirm(newTitle: string) {
    try {
      LogUtil.info(TAG, 'NoteContentOverViewComp confirm');
      this.selectedNoteData.title = newTitle;
      this.selectedNoteData.modified_time = new Date().getTime();
      let predicatesNote = RdbStoreUtil.getRdbPredicates(TableName.NoteTable);
      predicatesNote.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid);
      RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicatesNote, null);
      NoteUtil.refreshAll();
      LogUtil.info(TAG, 'NoteContentOverViewComp confirm end');
    } catch (error) {
      LogUtil.error(TAG, 'NoteContentOverViewComp confirm error: ' + JSON.stringify(error));
    }
  }

  @Builder
  MenuBuilder() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      List() {
        if (this.NoteDataMoveArray !== undefined && this.NoteDataMoveArray !== null &&
          this.NoteDataMoveArray.length > 0) {
          ForEach(this.NoteDataMoveArray, (item: FolderData) => {
            ListItem() {
              NoteDataMoveItemCompTablet({ folderItem: item, uuid: this.selectedNoteData.folder_uuid })
            }
            .onClick(() => {
              try {
                LogUtil.info(TAG, 'NoteContentOverViewComp MenuBuilder onClick');
                this.selectedNoteData.folder_uuid = item.uuid;
                let predicatesNote = RdbStoreUtil.getRdbPredicates(TableName.NoteTable);
                predicatesNote.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid);
                RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicatesNote, null);
                LogUtil.info(TAG, 'NoteContentOverViewComp MenuBuilder onClick, selectionStatus:' + this.sectionStatus);
                if (this.sectionStatus != 1) {
                  this.selectedNoteData = NoteUtil.getFirstNoteData(this.AllNoteArray, this.selectedFolderData.uuid)!;
                  LogUtil.info(TAG,
                    'NoteContentOverViewComp MenuBuilder onClick, runJavaScript(RICH_EDITOR.setHtml)' + this.selectedNoteData.content_text);
                  this.controllerShow.runJavaScript(
                    "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')"
                  )
                  this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0);
                } else {
                  this.selectedFolderData = FolderUtil.getFolderData(AppStorage.get('AllFolderArray')!, item.uuid);
                  LogUtil.info(TAG,
                    'NoteContentOverViewComp MenuBuilder onClick, selectedFolderData :' + JSON.stringify(this.selectedFolderData));
                }
                // save continue data
                let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject());
                AppStorage.setOrCreate<string>('ContinueNote', continueNote);
                LogUtil.info(TAG, 'NoteContentOverViewComp, MenuBuilder, set continue note success');
                NoteUtil.refreshAll();
              } catch (error) {
                LogUtil.error(TAG, 'NoteContentOverViewComp ListItem click error: ' + JSON.stringify(error));
              }
            })
          }, (noteItem: NoteData) => noteItem.uuid)
        }
      }.listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .height(this.AllFolderArray.length > 12 ? 504 : (this.AllFolderArray.length - 3) * 56)
    }
    .width(148)
    .backgroundColor($r('app.color.color_fffffB'))
    .padding({ left: 24, right: 24 })
  }

  build() {
    if (this.selectedNoteData) {
      Flex({
        direction: FlexDirection.Column,
        wrap: FlexWrap.NoWrap,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center
      }) {
        Row() {
          Text(this.selectedNoteData.title)
            .id(this.isUpdate + '')
            .fontSize(30)
            .margin({ left: 0, right: 24 })
            .onClick(() => {
              clearInterval(timeId);
              this.editTitleDialogCtl!.open();
              // save continue data
              AppStorage.setOrCreate<number>('ContinueSection', this.sectionStatus);
              LogUtil.info(TAG, 'NoteContentOverViewComp, set continue section success');
            })
        }.height(40)
        .width(StyleConstants.PERCENTAGE_100)

        Row() {
          Text(DateUtil.formateDateForNoteContent(new Date(this.selectedNoteData.modified_time)))
            .id(this.isUpdate + '')
            .fontSize(12)
            .padding({ top: 4, bottom: 4 })
            .fontColor($r('app.color.modified_time_font_color'))
            .margin({ left: 0 })
          Row() {
            Text(FolderUtil.getFolderText(FolderUtil.getFolderData(AppStorage.get('AllFolderArray'),
              this.selectedNoteData.folder_uuid)) ==
            folderTextMap.sys_def_myFavorites_uuid ? folderTextMap.sys_def_unClassified_uuid :
            FolderUtil.getFolderText(FolderUtil.getFolderData(AppStorage.get('AllFolderArray'),
              this.selectedNoteData.folder_uuid)))
              .id(this.isUpdate + '')
              .fontSize(12)
              .fontColor($r('app.color.list_modified_time_font_color'))
              .padding({ top: 1 })
            Image($r('app.media.triangle'))
              .width(6)
              .height(12)
              .margin({ left: 4 })
          }
          .id(this.isUpdate + '')
          .padding({
            left: 8,
            right: 8,
            top: 4,
            bottom: 4
          })
          .margin({ left: 8 })
          .borderRadius(16)
          .backgroundColor(NoteUtil.getNoteBgColor(AppStorage.get('AllFolderArray')!, this.selectedNoteData.folder_uuid,
            SysDefFolderUuid.AllNotes, false))
          .bindMenu(this.MenuBuilder)
        }.alignItems(VerticalAlign.Top).height(40).width(StyleConstants.PERCENTAGE_100)
      }
      .opacity(this.selectedNoteData.is_deleted == Delete.Yes ? 0.4 : 1)
      .width(StyleConstants.PERCENTAGE_100)
      .height(80)
    }
  }
}

@Component
export struct ToolBarComp {
  @Consume('SelectedNoteData') selectedNoteData: NoteData;
  @Consume('RefreshFlag') refreshFlag: number;
  @Consume('SectionStatus') sectionStatus: number;
  @Consume('LastSectionStatus') lastSectionStatus: number;
  @Consume('SelectedFolderData') selectedFolderData: FolderData;
  @Consume('ChooseNote') chooseNote: boolean;
  @Consume('PortraitModel') portraitModel: boolean;
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[] = AppStorage.Link('AllNoteArray');
  @Consume('EditModel') editModel: boolean;
  @Consume('Issave') issave: number;
  controllerShow: webview.WebviewController = new webview.WebviewController();
  noteDataDeleteDialogCtl: CustomDialogController | null = new CustomDialogController({
    builder: DeleteDialog({
      onConfirm: () => {
        this.onDeleteConfirm();
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true,
  });
  @Consume('AsideWidth') asideWidth: number;

  aboutToDisappear() {
    LogUtil.info(TAG, 'ToolBarComp, aboutToDisappear');
    this.noteDataDeleteDialogCtl = null;
    this.editContentDialogCtl = null;
  }

  onDeleteConfirm() {
    try {
      LogUtil.info(TAG, 'ToolBarComp, onDeleteConfirm selectedFolderData: ' + JSON.stringify(this.selectedFolderData));
      LogUtil.info(TAG,
        'ToolBarComp, onDeleteConfirm RecentDeletes: ' + JSON.stringify(SysDefFolderUuid.RecentDeletes));
      if (this.selectedFolderData.uuid != SysDefFolderUuid.RecentDeletes) {
        this.selectedNoteData.is_deleted = Delete.Yes;
        this.selectedNoteData.deleted_time = new Date().getTime();
        // update note to db
        let predicatesNote = RdbStoreUtil.getRdbPredicates(TableName.NoteTable);
        predicatesNote.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid);
        RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicatesNote, null);
      } else {
        NoteUtil.removeNoteData(this.AllNoteArray, this.selectedNoteData.uuid);
        // delete note from db
        let predicatesNote = RdbStoreUtil.getRdbPredicates(TableName.NoteTable);
        predicatesNote.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid);
        RdbStoreUtil.delete(predicatesNote, null);
      }
      LogUtil.info(TAG, 'ToolBarComp, onDeleteConfirm, delete note success');
      this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0);
      this.selectedNoteData = NoteUtil.getFirstNoteData(AppStorage.get('AllNoteArray')!, this.selectedFolderData.uuid)!;
      try {
        LogUtil.info(TAG, 'ToolBarComp, onDeleteConfirm, set html ' + this.selectedNoteData.content_text);
        this.controllerShow.runJavaScript("RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text! + "')");
      } catch (error) {
        LogUtil.info(TAG, `ToolBarComp setHtml error. code:${JSON.stringify(error.code)},message:${error.message}`);
      }
      this.chooseNote = false;
      // save continue data
      let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject());
      AppStorage.setOrCreate<string>('ContinueNote', continueNote);
      LogUtil.info(TAG, 'ToolBarComp, set continue note success');
      AppStorage.setOrCreate('isUpdate', true);
    } catch (error) {
      LogUtil.error(TAG, 'ToolBarComp onDeleteConfirm error: ' + JSON.stringify(error));
    }
  }

  editContentDialogCtl: CustomDialogController | null = new CustomDialogController({
    builder: EditContentDialog({
      confirm: (newTitle: string) => {
        this.confirm(newTitle);
      }
    }),
    alignment: DialogAlignment.Bottom,
    autoCancel: true,
    customStyle: true,
  })

  confirm(excuteJs: string) {
    this.controllerShow.runJavaScript(excuteJs);
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      Image(this.sectionStatus == 1 ? $r('app.media.narrow') : $r('app.media.zoom'))
        .height(24)
        .width(24)
        .onClick(() => {
          try {
            if (this.sectionStatus != 1) {
              LogUtil.info(TAG, 'ToolBarComp zoom, sectionStatus : ' + this.sectionStatus);
              this.lastSectionStatus = this.sectionStatus;
              this.sectionStatus = 1;
              this.asideWidth = 0;
              this.controllerShow.runJavaScript('RICH_EDITOR.setInputEnabled(true)');
              LogUtil.info(TAG, 'ToolBarComp zoom, runJavaScript : RICH_EDITOR.setInputEnabled(true)');
            } else {
              LogUtil.info(TAG, 'ToolBarComp zoom, sectionStatus : ' + this.sectionStatus);
              if (this.lastSectionStatus != undefined) {
                this.asideWidth = 200;
                // 切换为小屏预览模式
                this.controllerShow.runJavaScript('RICH_EDITOR.setInputEnabled(false)');
                this.sectionStatus = this.lastSectionStatus;
                // 退出全屏时存库
                LogUtil.info(TAG, 'ToolBarComp close note' + this.selectedNoteData.uuid);
                this.controllerShow.runJavaScript('saveHtmlContent()');
                //退出键盘
                inputMethod.getController().stopInputSession();
                // 清除定时器
                if (timeId != undefined) {
                  LogUtil.info(TAG, 'ToolBarComp zoom, clearInterval timeId : ' + timeId);
                  clearInterval(timeId);
                }
              } else {
                this.sectionStatus = 3;
              }
            }
            this.editModel = !this.editModel;
            // save continue data
            AppStorage.setOrCreate<number>('ContinueSection', this.sectionStatus);
            LogUtil.info(TAG, 'ToolBarComp, set continue section success');
            NoteUtil.refreshAll();
          } catch (error) {
            LogUtil.error(TAG,
              `ToolBarComp  Image ${this.sectionStatus == 1 ? 'narrow' :
                'zoom'} click failed.code:${JSON.stringify(error.code)},
            message:${JSON.stringify(error.message)}`);
          }
        })
        .visibility(!this.selectedNoteData ? Visibility.None :
          this.selectedNoteData.is_deleted == Delete.Yes ? Visibility.None : Visibility.Visible)

      if (this.selectedNoteData) {
        if (this.selectedNoteData.is_deleted == Delete.Yes) {
          Row({ space: StyleConstants.SPACE_24 }) {
            Image($r('app.media.delete'))
              .height(24)
              .width(24)
              .onClick(() => {
                this.noteDataDeleteDialogCtl!.open();
              })
            Image($r('app.media.recover'))
              .height(24)
              .width(24)
              .onClick(() => {
                try {
                  LogUtil.info(TAG, 'ToolBarComp, onClick, recover note');
                  this.selectedNoteData.is_deleted = Delete.No;
                  this.selectedNoteData.deleted_time = 0;
                  let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
                  let resource: resourceManager.Resource = {
                    bundleName: 'com.ohos.note',
                    moduleName: 'default',
                    id: $r('app.string.restore').id
                  };
                  context.resourceManager.getStringValue(resource, (error: BusinessError, value: string) => {
                    if (error != null) {
                      LogUtil.error(TAG, 'error is ' + error);
                    } else {
                      this.getUIContext().getPromptAction().showToast({ message: value, duration: 2000 });
                    }
                  });
                  this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0);
                  this.chooseNote = false;
                  LogUtil.info(TAG, 'ToolBarComp, onClick, recover note , update note to db');
                  // update note to db
                  let predicatesNote = RdbStoreUtil.getRdbPredicates(TableName.NoteTable);
                  predicatesNote.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid);
                  RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicatesNote, null);

                  this.selectedNoteData =
                    NoteUtil.getFirstNoteData(AppStorage.get('AllNoteArray')!, this.selectedFolderData.uuid)!;
                  LogUtil.info(TAG,
                    'ToolBarComp, onClick, recover note, setHtml ' + this.selectedNoteData!.content_text);
                  this.controllerShow.runJavaScript(
                    "RICH_EDITOR.setHtml('" + this.selectedNoteData!.content_text + "')"
                  )
                  // save continue data
                  let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject());
                  AppStorage.SetOrCreate<string>('ContinueNote', continueNote);
                  LogUtil.info(TAG, 'recover, set continue note success');
                  NoteUtil.refreshAll();
                } catch (error) {
                  LogUtil.error(TAG,
                    `ToolBarComp recover failed.code:${JSON.stringify(error.code)}, message:${JSON.stringify(error.message)}`);
                }
              })
          }.width(72)
        } else if (this.editModel == true) {
          Row({ space: StyleConstants.SPACE_6 }) {
            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.circle_tick1'))
                .height(24)
                .width(24)
                .onClick(() => {
                  try {
                    // 清单
                    LogUtil.info(TAG,
                      'ToolBarComp, onClick, circle_tick1, runJavaScript javascript:RICH_EDITOR.setTodo()');
                    this.controllerShow.runJavaScript('javascript:RICH_EDITOR.setTodo()');
                    // 退出键盘
                    inputMethod.getController().stopInputSession();
                  } catch (error) {
                    LogUtil.error(TAG, `ToolBarComp Image circle_tick1 click failed.code:${JSON.stringify(error.code)},
                    message:${JSON.stringify(error.message)}`);
                  }
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_fffffB'))

            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.styles'))
                .height(24)
                .width(24)
                .onClick(() => {
                  // 退出键盘
                  LogUtil.info(TAG, 'ToolBarComp, onClick, styles, exit keyboard');
                  inputMethod.getController().stopInputSession();
                  this.editContentDialogCtl!.open();
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_fffffB'))

            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.picture_white'))
                .height(24)
                .width(24)
                .onClick(async () => {
                  LogUtil.info(TAG, 'ToolBarComp, onClick, picture_white');
                  let permissionList: Permissions[] = [
                    'ohos.permission.READ_MEDIA',
                    'ohos.permission.WRITE_MEDIA',
                  ];
                  let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
                  let AtManager = abilityAccessCtrl.createAtManager();
                  await AtManager.requestPermissionsFromUser(context, permissionList).then((data) => {
                    LogUtil.info(TAG, 'ToolBarComp data permissions : ' + data.permissions);
                    LogUtil.info(TAG, 'ToolBarComp data result: ' + data.authResults);
                    let sum = 0;
                    for (let i = 0; i < data.authResults.length; i++) {
                      sum += data.authResults[i];
                    }
                    LogUtil.info(TAG, 'ToolBarComp request permissions sum: ' + sum);
                  }).catch((err: BusinessError) => {
                    LogUtil.warn(TAG, 'ToolBarComp failed to requestPermissionsFromUser : ' + err.code);
                  })
                  // 退出键盘
                  inputMethod.getController().stopInputSession();
                  LogUtil.info(TAG, 'ToolBarComp startAbility start');
                  await noteContext.startAbilityForResult({
                    parameters: { uri: 'singleselect' },
                    bundleName: 'com.ohos.photos',
                    abilityName: 'com.ohos.photos.MainAbility',
                  })
                    .then((v: common.AbilityResult) => {
                      LogUtil.info(TAG, 'ToolBarComp startAbility success');
                      try {
                        let want = v['want'];
                        if (want != null && want != undefined) {
                          let param = want['parameters'];
                          let imageUri = "";
                          if (param != null && param != undefined) {
                            let uri = param['select-item-list'];
                            imageUri = uri as string;
                          }
                          // 拷贝
                          LogUtil.info(TAG, 'ToolBarComp, onClick, picture_white, copy image ' + imageUri);
                          if (imageUri != null && imageUri != "") {
                            OperationUtils.copy(imageUri).then((uriPath) => {
                              let path = 'file://' + uriPath;
                              LogUtil.info(TAG, 'image uri is:' + path);
                              LogUtil.info(TAG,
                                'ToolBarComp, onClick, picture_white, runJavaScript javascript:RICH_EDITOR.insertImage()');
                              this.controllerShow.runJavaScript(
                                "javascript:RICH_EDITOR.insertImage('" + path + "')"
                              );
                              this.issave = 1;
                              // 保存笔记信息到数据库
                              LogUtil.info(TAG, 'ToolBarComp, onClick, picture_white, runJavaScript getHtmlContent()');
                              this.controllerShow.runJavaScript('getHtmlContent()');
                            })
                          }
                        }
                        NoteUtil.refreshAll();
                      } catch (error) {
                        LogUtil.error(TAG, `ToolBarComp startAbilityForResult failed.code:${JSON.stringify(error.code)},
                        message:${JSON.stringify(error.message)}`);
                      }
                    });
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_fffffB'))

            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.undo'))
                .height(24)
                .width(24)
                .onClick(() => {
                  try {
                    // 退出键盘
                    LogUtil.info(TAG, 'ToolBarComp, onClick, undo, exit keyboard');
                    inputMethod.getController().stopInputSession();
                    this.controllerShow.runJavaScript('RICH_EDITOR.undo()');
                  } catch (error) {
                    LogUtil.error(TAG, `ToolBarComp Image undo click failed.code:${JSON.stringify(error.code)},
                    message:${JSON.stringify(error.message)}`);
                  }
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_fffffB'))

            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.todo'))
                .height(24)
                .width(24)
                .onClick(() => {
                  try {
                    // 退出键盘
                    LogUtil.info(TAG, 'ToolBarComp, onClick, todo, exit keyboard');
                    inputMethod.getController().stopInputSession();
                    this.controllerShow.runJavaScript('RICH_EDITOR.redo()');
                  } catch (error) {
                    LogUtil.error(TAG, `ToolBarComp Image todo click failed.code:${JSON.stringify(error.code)},
                    message:${JSON.stringify(error.message)}`);
                  }
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_fffffB'))


            Button({ type: ButtonType.Normal, stateEffect: true }) {
              Image($r('app.media.tick_thin'))
                .height(24)
                .width(24)
                .fillColor(this.issave == 0 ? Color.Black : Color.Grey)
                .onClick(() => {
                  try {
                    // 保存笔记信息到数据库
                    LogUtil.info(TAG, 'ToolBarComp, onClick, tick_thin, runJavaScript getHtmlContent()');
                    this.controllerShow.runJavaScript('getHtmlContent()');
                    LogUtil.info(TAG, 'ToolBarComp, onClick, tick_thin, runJavaScript getBlur()');
                    this.controllerShow.runJavaScript('javascript:RICH_EDITOR.getBlur()');
                    if (this.selectedNoteData.title == '标题' && this.selectedNoteData.content_text == "") {
                      LogUtil.info(TAG, 'note is empty,save note failed');
                    }
                    this.issave = 1;
                  } catch (error) {
                    LogUtil.error(TAG, `ToolBarComp Image tick_thin click failed.code:${JSON.stringify(error.code)},
                    message:${JSON.stringify(error.message)}`);
                  }
                })
            }.width(42)
            .height(42)
            .borderRadius(8)
            .backgroundColor($r('app.color.color_fffffB'))
          }.width(274)
        } else {
          Row({ space: StyleConstants.SPACE_24 }) {
            Image(this.selectedNoteData.is_favorite == Favorite.Yes ? $r('app.media.favorite') :
            $r('app.media.favorite_cancel'))
              .height(24)
              .width(24)
              .onClick(() => {
                try {
                  LogUtil.info(TAG, 'ToolBarComp, onClick, favorite, favorite note');
                  this.selectedNoteData.is_favorite =
                    (this.selectedNoteData.is_favorite == Favorite.Yes ? Favorite.No : Favorite.Yes);
                  this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0);
                  // update note to db
                  let predicatesNote = RdbStoreUtil.getRdbPredicates(TableName.NoteTable);
                  predicatesNote.equalTo(NoteTableColumn.Uuid, this.selectedNoteData.uuid);
                  RdbStoreUtil.update(this.selectedNoteData.toNoteObject(), predicatesNote, null);
                  LogUtil.info(TAG,
                    'ToolBarComp, onClick, favorite, selectedFolderData ' + JSON.stringify(this.selectedFolderData));
                  LogUtil.info(TAG,
                    'ToolBarComp, onClick, favorite, MyFavorites ' + JSON.stringify(SysDefFolderUuid.MyFavorites));
                  if (this.selectedFolderData.uuid === SysDefFolderUuid.MyFavorites) {
                    this.selectedNoteData =
                      NoteUtil.getFirstNoteData(AppStorage.Get('AllNoteArray')!, SysDefFolderUuid.MyFavorites)!;
                    try {
                      LogUtil.info(TAG, `ToolBarComp, favorite, MyFavorites, setHtml` +
                      JSON.stringify(this.selectedNoteData.content_text));
                      this.controllerShow.runJavaScript(
                        "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')"
                      );
                      LogUtil.info(TAG, `ToolBarComp setHtml success`);
                    } catch (error) {
                      LogUtil.error(TAG, `ToolBarComp setHtml failed.code:${JSON.stringify(error.code)},
                        message:${JSON.stringify(error.message)}`);
                    }
                    // save continue data
                    let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject());
                    AppStorage.setOrCreate<string>('ContinueNote', continueNote);
                    LogUtil.info(TAG, 'ToolBarComp, set continue note success');
                  }
                  NoteUtil.refreshAll();
                } catch (error) {
                  LogUtil.error(TAG, 'ToolBarComp favorite error: ' + JSON.stringify(error));
                }
              })
            Image($r('app.media.delete'))
              .height(24)
              .width(24)
              .onClick(() => {
                this.noteDataDeleteDialogCtl!.open();
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
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[] = [];
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[] = [];
  @StorageLink('isUpdate') isUpdate: boolean = false;
  folderItem: FolderData =
    new FolderData(0, '', new Date().getTime() + '', '', FolderType.CusDef, Delete.No, new Date().getTime(),
      new Date().getTime());
  uuid: string = '';

  build() {
    Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.Center }) {
      Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap }) {
        Image(FolderUtil.getFolderIcon(this.folderItem.uuid))
          .id(this.isUpdate + '')
          .objectFit(ImageFit.Fill)
          .width(24)
          .height(24)
          .flexShrink(0)
          .fillColor(FolderUtil.getFolderIconColor(this.AllFolderArray, this.folderItem.uuid,
            this.folderItem.uuid == this.uuid))
      }
      .width(24)

      Column() {
        Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween }) {
          Text(FolderUtil.getFolderText(this.folderItem))
            .id(this.isUpdate + '')
            .padding({ top: 3 })
            .fontSize(16)
            .fontColor(FolderUtil.getFolderIconColor(this.AllFolderArray,
              this.folderItem.uuid == this.uuid ? this.folderItem.uuid : '', this.folderItem.uuid == this.uuid))
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .flexShrink(1)
        }
        .width('100%')
        .height(55)

        if (this.folderItem.uuid != SysDefFolderUuid.UnClassified) {
          Divider()
            .color($r('app.color.divider_color_e4e4e4'))
            .strokeWidth(1)
        }
      }
      .padding({ left: 16 })
    }
    .id(this.isUpdate + '')
    .width('100%')
    .height(56)
    .visibility(FolderUtil.isFolderMoveIn(this.folderItem) ? Visibility.Visible : Visibility.None)
  }
}
