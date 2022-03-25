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

import Ability from '@ohos.application.Ability'
import fileio from '@ohos.fileio'
import inputMethod from '@ohos.inputMethod';

export default class MainAbility extends Ability {
    private Tag = "Phone_Note_MainAbility"

    onCreate(want, launchParam) {
        console.info(this.Tag + " onCreate, launchReason is " + launchParam.launchReason)
        // 折叠状态
        AppStorage.SetOrCreate<boolean>('Expand', false)
        AppStorage.SetOrCreate<boolean>('Choose', false)
        if (launchParam.launchReason == 3) {
            // 获取对端的迁移数据
            let continueNote: string = want.parameters["ContinueNote"]
            let continueSection: number = want.parameters["ContinueSection"]
            console.info(this.Tag + " continueSection : " + continueSection)
            AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
            AppStorage.SetOrCreate<number>('ContinueSection', continueSection)
            // 折叠状态
            let continueExpand: boolean = want.parameters["ContinueExpand"]
            let continueChoose: boolean = want.parameters["ContinueChoose"]
            console.info(this.Tag + " continueExpand : " + continueExpand + " , continueChoose : " + continueChoose)
            AppStorage.SetOrCreate<boolean>('Expand', continueExpand)
            AppStorage.SetOrCreate<boolean>('Choose', continueChoose)
            // 设置迁移标记
            AppStorage.SetOrCreate<boolean>('IsContinue', true)

            // 来自平板的迁移
            if (continueExpand == undefined && continueChoose == undefined) {
                console.info(this.Tag + " from tablet")
                AppStorage.SetOrCreate<boolean>('Choose', true)
                AppStorage.SetOrCreate<boolean>('Expand', false)
                AppStorage.SetOrCreate('ContinueChoose', true)
            }

            this.context.restoreWindowStage(null)
        }
        AppStorage.SetOrCreate<number>('openPhoto', 0)
        AppStorage.SetOrCreate<number>('openPerm', 0)
        globalThis.noteContext = this.context
    }

    onDestroy() {
        console.info(this.Tag + " onDestroy")
    }

    onWindowStageCreate(windowStage) {
        console.info(this.Tag + " onWindowStageCreate")
        windowStage.setUIContent(this.context, "pages/MyNoteHome", null)
    }

    onWindowStageDestroy() {
        console.info(this.Tag + " onWindowStageDestroy")
    }

    onForeground() {
        console.info(this.Tag + " onForeground")
    }

    onBackground() {
        console.info(this.Tag + " onBackground")
        // 退出键盘
        inputMethod.getInputMethodController().stopInput();
    }
}