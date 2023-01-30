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
import deviceInfo from '@ohos.deviceInfo';
import { NoteHomeComp } from './NoteHome'
import { NoteHomePortraitComp } from './NoteHomePortrait'
import { LogUtil } from '@ohos/utils/src/main/ets/default/baseUtil/LogUtil'
import RdbStoreUtil from '@ohos/utils/src/main/ets/default/baseUtil/RdbStoreUtil'
import NoteData from '@ohos/utils/src/main/ets/default/model/databaseModel/NoteData'
import inputMethod from '@ohos.inputmethod';
import router from '@system.router';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';

@Entry
@Component
export struct MyNoteHomeComp {
  @StorageLink('DBQueryFinished') dBQueryFinished: number = 0
  @Provide('PortraitModel') portraitModel: boolean = true
  @Provide('RefreshFlag') refreshFlag: number = 0
  private controllerShow: WebController = new WebController()
  private context = getContext(this)
  TAG = "MyNoteHomeComp_Tablet"
  @StorageLink('breakPoint') @Watch('onBreakPointChange') breakPoints: string = 'lg'

  onBreakPointChange() {
    if (this.breakPoints == 'sm' || this.breakPoints == 'md') {
      this.portraitModel = true
    } else {
      this.portraitModel = false
    }
  }

  build() {
    Row() {
      if (this.dBQueryFinished == 1) {
        if (this.breakPoints == 'sm') {
          NoteHomePortraitComp()
        } else {
          NoteHomeComp({ controllerShow: this.controllerShow })
        }

      }
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(this.TAG, "aboutToAppear")
    this.breakPoints = AppStorage.Get('breakPoint')
    if (this.breakPoints == 'sm' || this.breakPoints == 'md') {
      this.portraitModel = true
    } else {
      this.portraitModel = false
    }
    if (this.context == undefined || this.context == null) {
      LogUtil.warn(this.TAG, "context is error")
      return
    }

    let context: any = getContext(this);
    let dbExist = false;
    let dbPath = context.databaseDir + "/db/note.db"
    try {
      fileio.accessSync(dbPath)
      LogUtil.info(this.TAG, "db has created")
      RdbStoreUtil.initAppStorage(this.context)
      dbExist = true
    } catch (err) {
      LogUtil.info(this.TAG, "db has not created, find to rdb folder")
    }
    if (!dbExist) {
      dbPath = context.databaseDir + "/rdb/note.db"
      try {
        fileio.accessSync(dbPath)
        LogUtil.info(this.TAG, "db has created")
        RdbStoreUtil.initAppStorage(this.context)
      } catch (err) {
        LogUtil.info(this.TAG, "db has not created, start to create db")
        RdbStoreUtil.createRdbStore(this.context)
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(this.TAG, "aboutToDisappear")
  }

  onPageShow(): void {
    LogUtil.info(this.TAG, "onPageShow")
    // continue from tablet
    let continueFromTablet = AppStorage.Get<boolean>('ContinueFromTablet')
    LogUtil.info(this.TAG, "onPageShow, continueFromTablet : " + continueFromTablet)
    let noteContentHomeExist = AppStorage.Get<boolean>('NoteContentHomeExist')
    LogUtil.info(this.TAG, "onPageShow, noteContentHomeExist : " + noteContentHomeExist)
    if (continueFromTablet && !noteContentHomeExist) {
      router.push({ uri: 'pages/NoteContentHome' })
      AppStorage.SetOrCreate<boolean>('ContinueFromTablet', false)
    }
    this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
  }

  onBackPress() {
    LogUtil.info(this.TAG, "onBackPress")
    // 退出键盘
    // @ts-ignore
    inputMethod.getController().stopInputSession();
  }
}