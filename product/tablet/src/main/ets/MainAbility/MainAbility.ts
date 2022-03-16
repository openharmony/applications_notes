import Ability from '@ohos.application.Ability'
import {WebViewUtil} from './WebViewUtil.ets'
import fileio from '@ohos.fileio'
import accessControl from "@ohos.abilityAccessCtrl"
import bundle from '@ohos.bundle'

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
        AppStorage.SetOrCreate<number>('openPhoto', 0)
        globalThis.noteContext = this.context
    }

    onDestroy() {
        console.log("MainAbility onDestroy")
    }

    onWindowStageCreate(windowStage) {
        console.log("MainAbility onWindowStageCreate")
        // 动态申请权限
        globalThis.requestPermissions = async () => {
            let array: Array<string> = [
                "ohos.permission.READ_MEDIA",
                "ohos.permission.GET_BUNDLE_INFO_PRIVILEGED",
                "ohos.permission.DISTRIBUTED_DATASYNC"];
            let needGrantPermission = false
            let accessManger = accessControl.createAtManager()
            let bundleInfo = await bundle.getApplicationInfo("com.ohos.note", 0, 100)
            console.info("onWindowStageCreate, accessTokenId : " + bundleInfo.accessTokenId.toString())
            for (const permission of array) {
                console.info("onWindowStageCreate, query permission : " + permission)
                try {
                    let grantStatus = await accessManger.verifyAccessToken(bundleInfo.accessTokenId, permission)
                    if (grantStatus == -1) {
                        needGrantPermission = true
                        break
                    }
                } catch (err) {
                    console.warn("onWindowStageCreate, verifyAccessToken error : " + JSON.stringify(err))
                    needGrantPermission = true
                    break
                }
            }
            console.info("onWindowStageCreate, needGrantPermission : " + needGrantPermission)
            if (needGrantPermission) {
                try {
                    await this.context.requestPermissionsFromUser(array)
                } catch (err) {
                    console.warn("onWindowStageCreate, requestPermissionsFromUser err : " + JSON.stringify(err))
                }
            } else {
                console.info("onWindowStageCreate, requestPermissionsFromUser, already granted")
            }
        }
        globalThis.requestPermissions()
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

        // save img to DisFileDir
        console.log("MainAbility onContinue, save img to DisFileDir")
        let continueNoteObj = JSON.parse(continueNote)
        let srcArray = this.getSrcFromHtml(decodeURI(continueNoteObj.content_text))
        srcArray.forEach((src: string) => {
            let lastIndex = src.lastIndexOf('/')
            if (lastIndex != -1) {
                let imgName = src.substring(lastIndex + 1)
                this.writeToDisFileDir(imgName)
            }
        })
        console.log("MainAbility onContinue, save img to DisFileDir success")

        // 保存本端的迁移数据
        wantParam["ContinueFolder"] = continueFolder
        wantParam["ContinueNote"] = continueNote
        wantParam["ContinueSection"] = continueSection

        return true
    }

    getSrcFromHtml(html: string): any{
        let imgReg = /<img[^>]+>/g
        let srcReg = /src=[\'\"]?([^\'\"]*)[\'\"]?/i
        let imgArray = html.match(imgReg)
        let srcArray = []
        if (imgArray != null) {
            for (let i = 0; i < imgArray.length; i++) {
                let src = imgArray[i].match(srcReg)
                srcArray.push(src[1])
            }
        }
        return srcArray
    }

    writeToDisFileDir(fileName: string) {
        console.log("MainAbility writeToDisFileDir, fileName : " + fileName)
        let filesDir = this.context.filesDir
        let srcPath = filesDir + "/" + fileName
        let distributedFilesDir = this.context.distributedFilesDir
        let desPath = distributedFilesDir + "/" + fileName
        try {
            fileio.copyFileSync(srcPath, desPath)
            console.info("MainAbility onContinue, writeToDisFileDir, copyFile successfully")
        } catch (err) {
            console.warn("MainAbility onContinue, writeToDisFileDir, copyFile failed : " + err)
        }
    }

}