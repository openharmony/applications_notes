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

import {FolderListComp} from '../../../../../../../common/component/src/main/ets/default/FolderListComp.ets'
import {NoteListComp} from '../../../../../../../common/component/src/main/ets/default/NoteListComp.ets'
import {NoteContentComp} from '../../../../../../../common/component/src/main/ets/default/NoteContentComp'
import StyleConstants from '../../../../../../../common/utils/src/main/ets/default/constants/StyleConstants.ets'
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets'
import {circleColorArray} from '../../../../../../../common/utils/src/main/ets/default/model/NoteBaseData.ets'
import FolderData from '../../../../../../../common/utils/src/main/ets/default/model/databaseModel/FolderData.ets'
import NoteData from '../../../../../../../common/utils/src/main/ets/default/model/databaseModel/NoteData.ets'
import {SysDefFolderUuid} from '../../../../../../../common/utils/src/main/ets/default/model/databaseModel/EnumData.ets'
import LayoutUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LayoutUtil.ets'
import NoteUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/NoteUtil.ets'

@Entry
@Component
export struct NoteHomeComp {
  @Provide('RefreshFlag') refreshFlag: number = 0
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = AppStorage.Link('AllNoteArray')
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = AppStorage.Link('AllFolderArray')
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[]  = []

// 当前文件夹、笔记、分栏
  @Provide('SelectedFolderData') selectedFolderData: FolderData = AppStorage.Get('Folder')
  @Provide('SelectedNoteData') selectedNoteData: NoteData = AppStorage.Get('Note')
  @Provide('SectionStatus') sectionStatus: number = AppStorage.Get('Section')
  @Provide('SelectedColor') selectedColor: string = circleColorArray[0]
  @Provide('Longpress') longpress: boolean = false // 第二栏长按状态
  @Provide('ExpandStatus') expandStatus: boolean = false // 笔记本折叠展开状态
  @Provide('ChooseNote') chooseNote: boolean = true // 是否选择笔记进行打开
  @Provide('Search') search: boolean = false // 是否处于搜索状态
  @Provide('SearchResultList') searchResultList: NoteData[] = [] // 搜索得到的笔记列表
  @Provide('InputKeyword') inputKeyword: string = '' // 搜索的字串

  TAG = "NoteHomeComp"

  build() {
    Flex({ justifyContent: FlexAlign.Start }) {
      // Folder list display area
      Flex({ direction: FlexDirection.Column, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.Center }) {
        FolderListComp()
      }
      .flexShrink(0)
      .backgroundColor($r("app.color.folderlist_bgcolor_f1f3f5"))
      .width(LayoutUtil.getWidthWeightMessage(this.sectionStatus).folderListWeight)
      .height(StyleConstants.PERCENTAGE_100)
      .visibility(
          LayoutUtil.getWidthWeightMessage(this.sectionStatus)
          .folderListVisibility == 0 ? Visibility.None : Visibility.Visible)
      .opacity(this.search ? StyleConstants.OPACITY_40 : StyleConstants.OPACITY_100)
      .enabled(this.search ? false : true)

      Divider()
        .vertical(true)
        .strokeWidth(1)
        .color($r("app.color.divider_color_182431"))
        .height("100%")
        .opacity(StyleConstants.OPACITY_10)
      // Note list display area
      Flex({ direction: FlexDirection.Column, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        NoteListComp()
      }
      .flexShrink(0)
      .backgroundColor($r("app.color.notelist_bgcolor_f1f3f5"))
      .width(LayoutUtil.getWidthWeightMessage(this.sectionStatus).noteListWeight)
      .height(StyleConstants.PERCENTAGE_100)
      .visibility(
          LayoutUtil.getWidthWeightMessage(this.sectionStatus)
          .noteListVisibility == 0 ? Visibility.None : Visibility.Visible)

      Divider()
        .vertical(true)
        .strokeWidth(1)
        .color($r("app.color.divider_color_182431"))
        .height("100%")
        .opacity(StyleConstants.OPACITY_10)
      // Note content display area
      Flex({ direction: FlexDirection.Column, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        NoteContentComp()
      }
      .flexShrink(0)
      .backgroundColor(this.search && this.inputKeyword.length == 0 ? $r("app.color.notecontent_color_000000") : $r("app.color.notecontent_color_ffffff"))
      .width(LayoutUtil.getWidthWeightMessage(this.sectionStatus).noteCotentWeight)
      .height(StyleConstants.PERCENTAGE_100)
      .opacity(this.longpress ? StyleConstants.OPACITY_40 : this.search && this.inputKeyword.length == 0 ? StyleConstants.OPACITY_20 : StyleConstants.OPACITY_100)
      .enabled(this.longpress || this.search && this.inputKeyword.length == 0 ? false : true)
    }
    .width(StyleConstants.PERCENTAGE_100).height(StyleConstants.PERCENTAGE_100)
  }

  aboutToAppear(): void{
    LogUtil.info(this.TAG, "aboutToAppear")
  }

  aboutToDisappear(): void{
    LogUtil.info(this.TAG, "aboutToDisappear")
  }
}