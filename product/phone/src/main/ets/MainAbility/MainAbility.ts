import Ability from '@ohos.application.Ability'
import {WebViewUtil} from './WebViewUtil.ets'

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        console.log("MainAbility onCreate, launchReason is " + launchParam.launchReason)
        AppStorage.SetOrCreate<number>('openPhoto', 0)
        globalThis.noteContext = this.context
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
};
