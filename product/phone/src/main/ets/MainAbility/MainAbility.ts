import Ability from '@ohos.application.Ability'

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        console.log("MainAbility onCreate, launchReason is " + launchParam.launchReason)
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
    }
};
