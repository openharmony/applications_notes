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

import {FolderListComp} from '../../../../../../../common/component/src/main/ets/default/FolderListComp.ets'
import {NoteListComp} from '../../../../../../../common/component/src/main/ets/default/NoteListComp.ets'
import {NoteContentComp} from '../../../../../../../common/component/src/main/ets/default/NoteContentComp'
import StyleConstants from '../../../../../../../common/utils/src/main/ets/default/constants/StyleConstants.ets'
import {LogUtil} from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets'
import {circleColorArray} from '../../../../../../../common/utils/src/main/ets/default/model/NoteBaseData.ets'
import FolderData from '../../../../../../../common/utils/src/main/ets/default/model/databaseModel/FolderData.ets'
import NoteData from '../../../../../../../common/utils/src/main/ets/default/model/databaseModel/NoteData.ets'
import {SysDefFolderUuid} from '../../../../../../../common/utils/src/main/ets/default/model/databaseModel/EnumData.ets'
import LayoutUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LayoutUtil.ets'
import NoteUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/NoteUtil.ets'
import mediaquery from '@ohos.mediaquery'

@Entry
@Component
export struct NoteHomeComp {
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = AppStorage.Link('AllFolderArray')
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[]  = []

  // 当前文件夹、笔记、分栏
  @Provide('SelectedFolderData') selectedFolderData: FolderData = AppStorage.Get('Folder')
  @Provide('SelectedNoteData') selectedNoteData: NoteData = AppStorage.Get('Note')
  @Provide('SectionStatus') sectionStatus: number = AppStorage.Get('Section')
  @Provide('SelectedColor') selectedColor: string = circleColorArray[0]
  @Provide('LastSectionStatus') lastSectionStatus: number = 3 // 记录分栏上一次的状态
  @Provide('Longpress') longpress: boolean = false // 第二栏长按状态
  @Provide('ExpandStatus') expandStatus: boolean = false // 笔记本折叠展开状态
  @Provide('ChooseNote') chooseNote: boolean = true // 是否选择笔记进行打开
  @Provide('Search') search: boolean = false // 是否处于搜索状态
  @Provide('SearchResultList') searchResultList: NoteData[] = [] // 搜索得到的笔记列表
  @Provide('InputKeyword') inputKeyword: string = '' // 搜索的字串
  @Provide('SelectedAll') selectedAll: boolean = false
  @Provide('EditModel') editModel: boolean = false //编辑模式：临时方案
  @Provide('Issave') issave: number = 0
  controllerShow: WebController

  TAG = "NoteHomeComp_Tablet"

  narrowWinListener = mediaquery.matchMediaSync('(width < 2000)')
  onWinSizeChange(mediaQueryResult) {
    if (this.sectionStatus != 1) {
      this.sectionStatus = (mediaQueryResult.matches) ? 2 : 3
      // save continue data
      AppStorage.SetOrCreate<number>('ContinueSection', this.sectionStatus)
      LogUtil.info(this.TAG, "onWinSizeChange, set continue section success")
    }
  }

  build() {
    Flex({ justifyContent: FlexAlign.Start }) {
      // Folder list display area
      Flex({ direction: FlexDirection.Column, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.Center }) {
        FolderListComp({ controllerShow: this.controllerShow })
      }
      .flexShrink(0)
      .backgroundColor($r("app.color.folderlist_bgcolor_f1f3f5"))
      .width(200)
      .height(StyleConstants.PERCENTAGE_100)
      .visibility(
          LayoutUtil.getWidthWeightMessage(this.sectionStatus)
          .folderListVisibility == 0 ? Visibility.None : Visibility.Visible)
      .enabled(this.search ? false : true)

      // Note list display area
      Flex({ direction: FlexDirection.Column, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        Divider()
          .vertical(true)
          .strokeWidth(1)
          .color($r("app.color.divider_color_182431"))
          .height("100%")
          .opacity(StyleConstants.OPACITY_10)
        NoteListComp({ controllerShow: this.controllerShow })
      }
      .flexShrink(0)
      .backgroundColor($r("app.color.notelist_bgcolor_f1f3f5"))
      .layoutWeight(2)
      .height(StyleConstants.PERCENTAGE_100)
      .visibility(
          LayoutUtil.getWidthWeightMessage(this.sectionStatus)
          .noteListVisibility == 0 ? Visibility.None : Visibility.Visible)
      // Note content display area
      Flex({ direction: FlexDirection.Column, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        Divider()
          .vertical(true)
          .strokeWidth(1)
          .color($r("app.color.divider_color_182431"))
          .height("100%")
          .opacity(StyleConstants.OPACITY_10)
        NoteContentComp({ controllerShow: this.controllerShow })
      }
      .flexShrink(0)
      .backgroundColor($r("app.color.notecontent_color_ffffff"))
      .layoutWeight(this.sectionStatus != 1 ? 3 : null)
      .height(StyleConstants.PERCENTAGE_100)
      .enabled(this.longpress || this.search && this.inputKeyword.length == 0 ? false : true)
    }
    .width(StyleConstants.PERCENTAGE_100)
    .height(StyleConstants.PERCENTAGE_100)
  }

  aboutToAppear(): void{
    LogUtil.info(this.TAG, "aboutToAppear")
    this.narrowWinListener.on('change', this.onWinSizeChange.bind(this))
    this.sectionStatus = this.narrowWinListener.matches ? 2 : 3
    let isContinue = AppStorage.Get<boolean>('IsContinue')
    LogUtil.info(this.TAG, "aboutToAppear, isContinue : " + isContinue)
    if (isContinue) {
      this.sectionStatus = AppStorage.Get('Section')
    }
    // continue from phone
    let continueFromPhone = AppStorage.Get<boolean>('ContinueFromPhone')
    LogUtil.info(this.TAG, "aboutToAppear, continueFromPhone : " + continueFromPhone)
    if (continueFromPhone) {
      this.sectionStatus = 3
    }
    // save continue data
    AppStorage.SetOrCreate<number>('ContinueSection', this.sectionStatus)
    LogUtil.info(this.TAG, "aboutToAppear, set continue section success")
  }

  aboutToDisappear(): void{
    LogUtil.info(this.TAG, "aboutToDisappear")
  }
}