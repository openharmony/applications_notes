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

import fileio from '@ohos.file.fs'
import { NoteHomeComp } from './NoteHome'
import { NoteHomePortraitComp } from './NoteHomePortrait'
import { LogUtil } from '@ohos/utils/src/main/ets/default/baseUtil/LogUtil'
import RdbStoreUtil from '@ohos/utils/src/main/ets/default/baseUtil/RdbStoreUtil'
import inputMethod from '@ohos.inputMethod';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import webview from '@ohos.web.webview';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';

@Entry
@Component
export struct MyNoteHomeComp {
  @StorageLink('topHeight') topHeight: number = 0; // 窗口规避区域高
  @StorageLink('topWidth') topWidth: number = 0; // 窗口规避区域宽
  @StorageLink('DBQueryFinished') dBQueryFinished: number = 0
  @Provide('PortraitModel') portraitModel: boolean = true
  @Provide('RefreshFlag') refreshFlag: number = 0
  private controllerShow: WebviewController = new webview.WebviewController()
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  TAG = "MyNoteHomeComp_Tablet"
  @StorageLink('breakPoint') @Watch('onBreakPointChange') breakPoints: string = 'lg'

  onBreakPointChange() {
    LogUtil.info(this.TAG, "onBreakPointChange, breakPoints = "+this.breakPoints)
    if (this.breakPoints == 'sm' || this.breakPoints == 'md') {
      this.portraitModel = true
    } else {
      this.portraitModel = false
    }
  }

  build() {
    Column() {
      // 窗口顶部规避区域
      Row()
        .width(this.getUIContext().px2vp(this.topWidth))
        .height(this.getUIContext().px2vp(this.topHeight))
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
  }

  aboutToAppear(): void {
    LogUtil.info(this.TAG, "aboutToAppear")
    this.breakPoints = AppStorage.get('breakPoint')!;
    if (this.breakPoints == 'sm' || this.breakPoints == 'md') {
      this.portraitModel = true
    } else {
      this.portraitModel = false
    }
    if (this.context == undefined || this.context == null) {
      LogUtil.warn(this.TAG, "context is error")
      return
    }
    let permissionList: Array<string> = [
      "ohos.permission.DISTRIBUTED_DATASYNC"
    ]
    LogUtil.info(this.TAG, 'permissions need to require from user')
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    let AtManager = abilityAccessCtrl.createAtManager();
    //requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    AtManager.requestPermissionsFromUser(context, ["ohos.permission.MANAGE_DISPOSED_APP_STATUS"]).then((data) => {
      LogUtil.info(this.TAG, 'data permissions : ' + data.permissions)
      LogUtil.info(this.TAG, 'data result: ' + data.authResults)
      let sum = 0
      for (let i = 0; i < data.authResults.length; i++) {
        sum += data.authResults[i]
      }
      LogUtil.info(this.TAG, 'request permissions sum: ' + sum)
    }).catch((err: BusinessError) => {
      LogUtil.warn(this.TAG, 'failed to requestPermissionsFromUser : ' + err.code);
    })
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
    let continueFromTablet = AppStorage.get<boolean>('ContinueFromTablet')
    LogUtil.info(this.TAG, "onPageShow, continueFromTablet : " + continueFromTablet)
    let noteContentHomeExist = AppStorage.get<boolean>('NoteContentHomeExist')
    LogUtil.info(this.TAG, "onPageShow, noteContentHomeExist : " + noteContentHomeExist)
    if (continueFromTablet && !noteContentHomeExist) {
      this.getUIContext().getRouter().pushUrl({ url: 'pages/NoteContentHome' })
      AppStorage.setOrCreate<boolean>('ContinueFromTablet', false)
    }
    this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
  }

  onBackPress() {
    LogUtil.info(this.TAG, "onBackPress")
    // 退出键盘
    inputMethod.getController().stopInputSession();
    setTimeout(() => {
      LogUtil.info(this.TAG, "wait save cotext")
    }, 50)
  }
}