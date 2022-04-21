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

import {NoteContent} from '@ohos/component/src/main/ets/components/NoteContent'
import {LogUtil} from '@ohos/utils/src/main/ets/default/baseUtil/LogUtil'
import RdbStoreUtil from '@ohos/utils/src/main/ets/default/baseUtil/RdbStoreUtil'

@Entry
@Component
struct NoteContentHome {
  private controllerShow: WebController = new WebController()
  @StorageLink('DBQueryFinished') dBQueryFinished: number = 0
  TAG = "NoteContentHome_Tablet"

  build() {
    // Note content display area
    Flex({ direction: FlexDirection.Column, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      if (this.dBQueryFinished == 1) {
        NoteContent({ controllerShow: this.controllerShow })
      }
    }
    .backgroundColor($r("app.color.notecontent_color_ffffff"))
    .width('100%')
    .height('100%')
  }

  onBackPress():void{
     LogUtil.info(this.TAG, "onBackPress")
     this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setInputEnabled(false)" })
     this.controllerShow.runJavaScript({ script: "get_html_content()" })
  }

  aboutToAppear(): void{
    LogUtil.info(this.TAG, "aboutToAppear")
    let isContinue = AppStorage.Get<boolean>('IsContinue')
    LogUtil.info(this.TAG, "aboutToAppear, isContinue : " + isContinue)
    if (isContinue) {
      RdbStoreUtil.initAppStorage(globalThis.noteContext)
    }
  }

}