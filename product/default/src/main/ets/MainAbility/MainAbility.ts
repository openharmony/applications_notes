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

import UIAbility from '@ohos.app.ability.UIAbility';
import deviceInfo from '@ohos.deviceInfo';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import fileio from '@ohos.fileio';
import inputMethod from '@ohos.inputMethod';
import { LogUtil } from '@ohos/utils/src/main/ets/default/baseUtil/LogUtil';
import display from '@ohos.display';
import window from '@ohos.window';
import util from '@ohos.util';
import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { Configuration } from '@ohos.app.ability.Configuration';

AppStorage.setOrCreate<relationalStore.RdbStore>('rdbStore', undefined);

export default class MainAbility extends UIAbility {
  private Tag = 'MainAbility_Tablet';

  onCreate(want, launchParam) {

    AppStorage.setOrCreate('context', this.context);
    LogUtil.info(this.Tag,
      " onCreate, launchReason is " + launchParam.launchReason + ", deviceType" + deviceInfo.deviceType);
    if (deviceInfo.deviceType === 'phone' || deviceInfo.deviceType === 'default') {
      AppStorage.setOrCreate<boolean>('Expand', false);
      AppStorage.setOrCreate<boolean>('Choose', true);
    }
    if (launchParam.launchReason == AbilityConstant.LaunchReason.CONTINUATION) {
      // 设置迁移标记
      AppStorage.setOrCreate<boolean>('IsContinue', true);
      // 获取对端的迁移数据
      let Search: boolean = want.parameters["Search"];
      let continueNote: string = want.parameters["ContinueNote"];
      let continueSection: number = want.parameters["ContinueSection"];
      let scrollTopPercent: number = want.parameters["ScrollTopPercent"];
      let isFocusOnSearch: boolean = want.parameters["isFocusOnSearch"];
      LogUtil.info(this.Tag, " continueSection : " + continueSection);
      AppStorage.setOrCreate<boolean>('Search', Search);
      AppStorage.setOrCreate<string>('ContinueNote', continueNote);
      AppStorage.setOrCreate<number>('ContinueSection', continueSection);
      // 使用新的key保存数据，防止迁移过来的数据在使用前被本地操作覆盖
      AppStorage.setOrCreate<number>('remoteScrollTopPercent', scrollTopPercent);
      AppStorage.setOrCreate<boolean>('isRemoteFocusOnSearch', isFocusOnSearch);
      // 来自手机的迁移
      let continueChoose: boolean = want.parameters["ContinueChoose"];
      if (continueChoose) {
        LogUtil.info(this.Tag, " continue from phone");
        AppStorage.setOrCreate<boolean>('ContinueFromPhone', true);
      } else {
        AppStorage.setOrCreate<boolean>('ContinueFromTablet', true);
        LogUtil.error(this.Tag, " continue from tablet");
      }
      this.context.restoreWindowStage(null);
    }
    AppStorage.setOrCreate<common.UIAbilityContext>('noteContext', this.context);

  }

  onDestroy() {
    LogUtil.info(this.Tag, " onDestroy");
  }

  onWindowStageCreate(windowStage) {
    windowStage.getMainWindow((err, data) => {
      LogUtil.info(this.Tag, " getMainWindow");
      let windowClass = data;
      try {
        windowClass.on('windowSizeChange', (data) => {
          LogUtil.info(this.Tag, " --------------- windowSizeChange ---------------");
          this.screenBreakPoints(data.width);
        })
        // 窗口规避区域
        windowClass.on('avoidAreaChange', ({ type, area }) => {
          if (type === window.AvoidAreaType.TYPE_SYSTEM) {
            AppStorage.setOrCreate<number>('topHeight', area.topRect.height);
            AppStorage.setOrCreate<number>('topWidth', area.topRect.width);
          }
        });
        windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        // 设置主窗口沉浸式
        windowClass.setWindowLayoutFullScreen(true);
        // 设置主窗口导航栏、状态栏、文字颜色等属性
        const sysBarProps: window.SystemBarProperties = {
          statusBarColor: "#ffffff",
          navigationBarColor: '#ffffff',
          statusBarContentColor: '#000000',
          navigationBarContentColor: '#000000'
        };
        // 加载状态变量
        windowClass.setWindowSystemBarProperties(sysBarProps);
      } catch (exception) {
        LogUtil.error(this.Tag, 'windowSizeChange fail');
      }
    })
    window.getLastWindow(this.context, (err, data) => {
      LogUtil.info(this.Tag, " --------------- getLastWindow ----------------");
      if (data && data.getWindowProperties()) {
        let windowWidth = data.getWindowProperties().windowRect.width;
        LogUtil.info(this.Tag, " getLastWindow：" + windowWidth);
        this.screenBreakPoints(windowWidth);
      } else {
        LogUtil.error(this.Tag, "getWindowProperties error:" + JSON.stringify(err));
      }
    })
    LogUtil.info(this.Tag, " onWindowStageCreate");
    windowStage.setUIContent(this.context, "pages/MyNoteHome", null);
  }

  onWindowStageDestroy() {
    LogUtil.info(this.Tag, " onWindowStageDestroy");
  }

  onForeground() {
    LogUtil.info(this.Tag, " ------------- onForeground ------------- ");
  }

  onBackground() {
    LogUtil.info(this.Tag, " ------------- onBackground ------------- ");
    // 退出键盘
    inputMethod.getController().stopInputSession();
  }

  onWillBackground(): void {
    LogUtil.info(this.Tag, " ------------- onWillBackground ------------- ");
  }

  onDidBackground(): void {
    LogUtil.info(this.Tag, " ------------- onDidBackground ------------- ");
  }

  onWillForeground(): void {
    LogUtil.info(this.Tag, " ------------- onWillForeground ------------- ");
  }

  onDidForeground(): void {
    LogUtil.info(this.Tag, " ------------- onDidForeground ------------- ");
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    LogUtil.info(this.Tag, " ------------- onConfigurationUpdate : " + JSON.stringify(newConfig) + " ------------- ");
  }

  onMemoryLevel(level: AbilityConstant.MemoryLevel): void {
    LogUtil.info(this.Tag, " ------------- onMemoryLevel : " + JSON.stringify(level) + " ------------- ");
  }

  onContinue(wantParam: { [key: string]: any }) {
    LogUtil.info(this.Tag, " onContinue");
    // 获取本端的迁移数据
    let Search = AppStorage.get<boolean>('Search');
    let continueNote = AppStorage.get<string>('ContinueNote');
    if (continueNote == undefined || continueNote == null) {
      LogUtil.info(this.Tag, " onContinue, continueNote is error, default [0]");
      continueNote = JSON.stringify(AppStorage.get('AllNoteArray')[0].toNoteObject());
    }

    let continueSection = AppStorage.get<number>('ContinueSection');
    if (continueSection == undefined || continueSection == null) {
      LogUtil.info(this.Tag, " onContinue, continueSection is error, default 3");
      continueSection = 3;
    }
    LogUtil.info(this.Tag, " onContinue, continueSection : " + continueSection);

    let scrollTopPercent = AppStorage.get<number>('ScrollTopPercent');
    if (scrollTopPercent == undefined || scrollTopPercent == null) {
      LogUtil.info(this.Tag, " onContinue, scrollTopPercent is error, default 0");
      scrollTopPercent = 0;
    }

    let isFocusOnSearch = AppStorage.get<boolean>('isFocusOnSearch');
    if (isFocusOnSearch == undefined || isFocusOnSearch == null) {
      LogUtil.info(this.Tag, " onContinue, isFocusOnSearch is error, default true");
      isFocusOnSearch = true;
    }

    // 保存本端的迁移数据
    wantParam["Search"] = Search;
    wantParam["ContinueNote"] = continueNote;
    wantParam["ContinueSection"] = continueSection;
    wantParam["ScrollTopPercent"] = scrollTopPercent;
    wantParam["isFocusOnSearch"] = isFocusOnSearch;
    if (deviceInfo.deviceType === 'phone' || deviceInfo.deviceType === 'default') {
      wantParam["ContinueChoose"] = true;
    }

    // save img to DisFileDir
    LogUtil.info(this.Tag, " onContinue, save img to DisFileDir");
    let continueNoteObj = JSON.parse(continueNote);
    let srcArray = this.getSrcFromHtml(continueNoteObj.content_text);
    srcArray.forEach((src: string) => {
      let lastIndex = src.lastIndexOf('/');
      if (lastIndex != -1) {
        let imgName = src.substring(lastIndex + 1);
        this.writeToDisFileDir(imgName);
      }
    })
    LogUtil.info(this.Tag, " onContinue end");
    return AbilityConstant.OnContinueResult.AGREE;
  }

  getSrcFromHtml(html: string): any {
    LogUtil.info(this.Tag, " getSrcFromHtml " + html);
    let srcArray = [];
    if (html == undefined || html == null || html == "") {
      return srcArray;
    }
    let base64regex = /^([0-9a-zA-Z+/]{4})*(([0-9a-zA-Z+/]{2}==)|([0-9a-zA-Z+/]{3}=))?$/;
    let realHtml;
    if (base64regex.test(html)) {
      let base64 = new util.Base64Helper;
      realHtml = base64.decodeSync(html).toString();
    } else {
      realHtml = html;
    }
    let imgReg = /<img[^>]+>/g;
    let srcReg = /src=[\'\"]?([^\'\"]*)[\'\"]?/i;
    let imgArray = realHtml.match(imgReg);
    if (imgArray != null) {
      for (let i = 0; i < imgArray.length; i++) {
        let src = imgArray[i].match(srcReg);
        if (src != null && src.length > 1) {
          LogUtil.info(this.Tag, " getSrcFromHtml, src[1] : " + src[1]);
          srcArray.push(src[1]);
        }
      }
    }
    return srcArray
  }

  writeToDisFileDir(fileName: string) {
    LogUtil.info(this.Tag, " writeToDisFileDir, fileName : " + fileName);
    let filesDir = this.context.filesDir;
    let srcPath = filesDir + "/" + fileName;
    let distributedFilesDir = this.context.distributedFilesDir;
    let desPath = distributedFilesDir + "/" + fileName;
    try {
      fileio.copyFileSync(srcPath, desPath);
      LogUtil.info(this.Tag, " onContinue, writeToDisFileDir, copyFile successfully" + desPath + " " + srcPath);
    } catch (err) {
      LogUtil.error(this.Tag, " onContinue, writeToDisFileDir, copyFile failed : " + err);
    }
  }

  screenBreakPoints(data) {
    let displayClass = null;
    let screenDpi = null;
    displayClass = display.getDefaultDisplaySync();
    screenDpi = displayClass.densityDPI;
    AppStorage.setOrCreate('dpi', screenDpi);
    let windowWidth = data / (screenDpi / 160);
    LogUtil.info(this.Tag, " screenBreakPoints windowWidth: " + windowWidth);
    if (windowWidth >= 320 && windowWidth < 520 || windowWidth < 320) {
      AppStorage.setOrCreate('breakPoint', 'sm');
    } else if (windowWidth >= 520 && windowWidth < 840) {
      AppStorage.setOrCreate('breakPoint', 'md');
    } else if (windowWidth >= 840) {
      AppStorage.setOrCreate('breakPoint', 'lg');
    }
  }
}