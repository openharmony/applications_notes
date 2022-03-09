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

import fileio from '@ohos.fileio'
import {NoteHomeComp} from './NoteHome.ets'
import {NoteHomePortraitComp} from './NoteHomePortrait.ets'
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets'
import RdbStoreUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/RdbStoreUtil.ets'

@Entry
@Component
export struct MyNoteHomeComp {
  @StorageLink('DBQueryFinished') dBQueryFinished: number = 0
  @Provide('PortraitModel') portraitModel:boolean = true
  private context = getContext(this)
  TAG = "MyNoteHomeComp"

  build() {
    Flex() {
      if (this.dBQueryFinished == 1) {
        if (this.portraitModel == true){
          NoteHomePortraitComp()
        } else {
          NoteHomeComp()
        }
      }
    }
    .width('100%').height('100%')
  }

  aboutToAppear(): void{
    LogUtil.info(this.TAG, "aboutToAppear")

    if (this.context == undefined || this.context == null) {
      LogUtil.error(this.TAG, "context is error")
      return
    }

    LogUtil.info(this.TAG, "databaseDir is " + this.context.databaseDir)
    // /data/storage/el2/database/tablet

    let dbPath = "/data/app/el2/100/database/com.ohos.note/phone/db/note.db"
    try {
      if (fileio.accessSync(dbPath) == undefined) {
        LogUtil.info(this.TAG, "db has created")
        RdbStoreUtil.initAppStorage(this.context)
      }
    } catch (err) {
      LogUtil.info(this.TAG, "db has not created, start to create db")
      RdbStoreUtil.createRdbStore(this.context)
    }
  }

  aboutToDisappear(): void{
    LogUtil.info(this.TAG, "aboutToDisappear")
  }
}