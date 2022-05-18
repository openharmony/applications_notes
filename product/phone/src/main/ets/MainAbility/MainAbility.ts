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
import AbilityConstant from '@ohos.application.AbilityConstant'
import fileio from '@ohos.fileio'
import inputMethod from '@ohos.inputmethod'

export default class MainAbility extends Ability {
    private Tag = "MainAbility_Phone"

    onCreate(want, launchParam) {
        console.info(this.Tag + " onCreate, launchReason is " + launchParam.launchReason)
        AppStorage.SetOrCreate<boolean>('Expand', false)
        AppStorage.SetOrCreate<boolean>('Choose', true)
        if (launchParam.launchReason == 3) {
            // 设置迁移标记
            AppStorage.SetOrCreate<boolean>('IsContinue', true)
            // 获取对端的迁移数据
            let continueNote: string = want.parameters["ContinueNote"]
            AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
            // 来自手机的迁移
            let continueChoose: boolean = want.parameters["ContinueChoose"]
            if (continueChoose) {
                console.info(this.Tag + " continue from phone")
            }else{
                AppStorage.SetOrCreate<boolean>('ContinueFromTablet', true)
                console.info(this.Tag + " continue from tablet")
            }
            this.context.restoreWindowStage(null)
        }
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

    onContinue(wantParam: { [key: string]: any }) {
        console.info(this.Tag + " onContinue")
        // 获取本端的迁移数据
        let continueNote = AppStorage.Get<string>('ContinueNote')
        if (continueNote == undefined || continueNote == null) {
            console.info(this.Tag + " onContinue, continueNote is error, default [0]")
            continueNote = JSON.stringify(AppStorage.Get('AllNoteArray')[0].toNoteObject())
        }

        // 保存本端的迁移数据
        wantParam["ContinueNote"] = continueNote
        wantParam["ContinueChoose"] = true

        // save img to DisFileDir
        console.info(this.Tag + " onContinue, save img to DisFileDir")
        let continueNoteObj = JSON.parse(continueNote)
        let srcArray = this.getSrcFromHtml(continueNoteObj.content_text)
        srcArray.forEach((src: string) => {
            let lastIndex = src.lastIndexOf('/')
            if (lastIndex != -1) {
                let imgName = src.substring(lastIndex + 1)
                this.writeToDisFileDir(imgName)
            }
        })
        console.info(this.Tag + " onContinue end")
        return AbilityConstant.OnContinueResult.AGREE;
    }

    getSrcFromHtml(html: string): any{
        let srcArray = []
        if (html == undefined || html == null || html == "") {
            return srcArray
        }
        let imgReg = /<img[^>]+>/g
        let srcReg = /src=[\'\"]?([^\'\"]*)[\'\"]?/i
        let imgArray = html.match(imgReg)
        if (imgArray != null) {
            for (let i = 0; i < imgArray.length; i++) {
                let src = imgArray[i].match(srcReg)
                if (src != null && src.length > 1) {
                    srcArray.push(src[1])
                }
            }
        }
        return srcArray
    }

    writeToDisFileDir(fileName: string) {
        console.info(this.Tag + " writeToDisFileDir, fileName : " + fileName)
        let filesDir = this.context.filesDir
        let srcPath = filesDir + "/" + fileName
        let distributedFilesDir = this.context.distributedFilesDir
        let desPath = distributedFilesDir + "/" + fileName
        try {
            fileio.copyFileSync(srcPath, desPath)
            console.info(this.Tag + " onContinue, writeToDisFileDir, copyFile successfully")
        } catch (err) {
            console.warn(this.Tag + " onContinue, writeToDisFileDir, copyFile failed : " + err)
        }
    }
}