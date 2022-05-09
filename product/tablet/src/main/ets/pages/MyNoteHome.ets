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

import fileio from '@ohos.fileio'
import bundle from '@ohos.bundle'
import abilityAccessCtrl from '@ohos.abilityAccessCtrl'
import {NoteHomeComp} from './NoteHome'
import {LogUtil} from '@ohos/utils/src/main/ets/default/baseUtil/LogUtil'
import RdbStoreUtil from '@ohos/utils/src/main/ets/default/baseUtil/RdbStoreUtil'
import NoteData from '@ohos/utils/src/main/ets/default/model/databaseModel/NoteData'
import inputMethod from '@ohos.inputmethod';

@Entry
@Component
export struct MyNoteHomeComp {
  @StorageLink('DBQueryFinished') dBQueryFinished: number = 0
  @Provide('PortraitModel') portraitModel: boolean = false
  @Provide('RefreshFlag') refreshFlag: number = 0
  private controllerShow: WebController = new WebController()
  private context = getContext(this)
  TAG = "MyNoteHomeComp_Tablet"

  build() {
    Row() {
      if (this.dBQueryFinished == 1) {
        NoteHomeComp({ controllerShow: this.controllerShow })
      }
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void{
    LogUtil.info(this.TAG, "aboutToAppear")

    if (this.context == undefined || this.context == null) {
      LogUtil.warn(this.TAG, "context is error")
      return
    }

    let permissionList: Array<string> = [
      "ohos.permission.READ_MEDIA",
      "ohos.permission.DISTRIBUTED_DATASYNC"
    ]
    LogUtil.info(this.TAG, 'permissions need to require from user')
    this.context.requestPermissionsFromUser(permissionList).then((data) => {
      LogUtil.info(this.TAG, 'data permissions : ' + data.permissions)
      LogUtil.info(this.TAG, 'data result: ' + data.authResults)
      let sum = 0
      for (let i = 0; i < data.authResults.length; i++) {
        sum += data.authResults[i]
      }
      LogUtil.info(this.TAG, 'request permissions sum: ' + sum)
    }, (err) => {
      LogUtil.warn(this.TAG, 'failed to requestPermissionsFromUser : ' + err.code);
    })

    let dbPath = this.context.databaseDir + "/db/note.db"
    try {
      fileio.accessSync(dbPath)
      LogUtil.info(this.TAG, "db has created")
      RdbStoreUtil.initAppStorage(this.context)
    } catch (err) {
      LogUtil.info(this.TAG, "db has not created, start to create db")
      RdbStoreUtil.createRdbStore(this.context)
    }
  }

  aboutToDisappear(): void{
    LogUtil.info(this.TAG, "aboutToDisappear")
  }

  onPageShow(): void{
    LogUtil.info(this.TAG, "onPageShow")
    let currentNote = AppStorage.Get<NoteData>('NewNote')
    let needRefesh = AppStorage.Get<boolean>('needRefresh')
    if (currentNote != null && needRefesh == true) {
      this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setHtml('" + currentNote.content_text + "')" })
      AppStorage.SetOrCreate<boolean>('needRefresh',false)
    }
    this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
  }

  onBackPress() {
    LogUtil.info(this.TAG, "onBackPress")
    // 退出键盘
    inputMethod.getInputMethodController().stopInput();
  }
}