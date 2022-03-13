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

import Ability from '@ohos.application.Ability'
import {WebViewUtil} from './WebViewUtil.ets'

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        console.log("MainAbility onCreate, launchReason is " + launchParam.launchReason)
        if (launchParam.launchReason == 3) {
            // 获取对端的迁移数据
            let continueFolder: string = want.parameters["ContinueFolder"]
            let continueNote: string = want.parameters["ContinueNote"]
            let continueSection: number = want.parameters["ContinueSection"]
            // 迁移数据存入AppStorage
            AppStorage.SetOrCreate<string>('ContinueFolder', continueFolder)
            AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
            AppStorage.SetOrCreate<number>('ContinueSection', continueSection)
            // 设置迁移标记
            AppStorage.SetOrCreate<number>('IsContinue', 1)
            this.context.restoreWindowStage(null)
        }
    }

    onDestroy() {
        console.log("MainAbility onDestroy")
    }

    onWindowStageCreate(windowStage) {
        console.log("MainAbility onWindowStageCreate")
        windowStage.setUIContent(this.context, "pages/MyNoteHome", null)
    }

    onWindowStageDestroy() {
        console.log("MainAbility onWindowStageDestroy")
    }

    onForeground() {
        console.log("MainAbility onForeground")
    }

    onBackground() {
        console.log("MainAbility onBackground")
        let controllerShow = WebViewUtil.getWebController()
        if (controllerShow == undefined || controllerShow == null) {
            console.info("MainAbility onBackground, controllerShow is error")
        }
        console.log("MainAbility controllerShow : " + controllerShow)
        controllerShow.runJavaScript({
            script: "get_html_content()"
        })
        console.log("MainAbility controllerShow end")
    }

    onContinue(wantParam: { [key: string]: any }) {
        console.log("MainAbility onContinue")
        // 获取本端的迁移数据
        let continueFolder = AppStorage.Get<string>('ContinueFolder')
        if (continueFolder == undefined || continueFolder == null) {
            console.log("MainAbility onContinue, continue first folder")
            continueFolder = JSON.stringify(AppStorage.Get('AllFolderArray')[0].toFolderObject())
        }

        let continueNote = AppStorage.Get<string>('ContinueNote')
        if (continueNote == undefined || continueNote == null) {
            console.log("MainAbility onContinue, continue first note")
            continueNote = JSON.stringify(AppStorage.Get('AllNoteArray')[0].toNoteObject())
        }

        let continueSection = AppStorage.Get<number>('ContinueSection')
        if (continueSection == undefined || continueSection == null) {
            console.log("MainAbility onContinue, continue section 3")
            continueSection = 3
        }

        // 保存本端的迁移数据
        wantParam["ContinueFolder"] = continueFolder
        wantParam["ContinueNote"] = continueNote
        wantParam["ContinueSection"] = continueSection

        return true
    }
}
