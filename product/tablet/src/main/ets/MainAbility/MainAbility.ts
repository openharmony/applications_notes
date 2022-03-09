import Ability from '@ohos.application.Ability'

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        console.log("MainAbility onCreate, launchReason is " + launchParam.launchReason)
        if (launchParam.launchReason == 3) {
            // 获取对端的迁移数据
            let continueFolder: string = want.parameters["ContinueFolder"]
            let continueNote: string = want.parameters["ContinueNote"]
            let continueSection: number = want.parameters["ContinueSection"]
            console.log("MainAbility launchReason = 3, continueFolder is " + continueFolder)
            console.log("MainAbility launchReason = 3, continueNote is " + continueNote)
            console.log("MainAbility launchReason = 3, continueSection is " + continueSection)
            // 迁移数据存入AppStorage
            AppStorage.SetOrCreate<string>('ContinueFolder', continueFolder)
            AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
            AppStorage.SetOrCreate<number>('ContinueSection', continueSection)
            // 设置迁移标记
            AppStorage.SetOrCreate<number>('IsContinue', 1)
            this.context.restoreWindowStage(null);
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
    }

    onContinue(wantParam: { [key: string]: any }) {
        console.log("MainAbility onContinue")

        // 获取本端的迁移数据
        let continueFolder = AppStorage.Get<string>('ContinueFolder')
        if (continueFolder == undefined || continueFolder == null) {
            console.log("MainAbility onContinue, continue first folder")
            continueFolder = JSON.stringify(AppStorage.Get('AllFolderArray')[0].toFolderObject())
        }
        console.log("MainAbility onContinue, continueFolder is " + continueFolder)

        let continueNote = AppStorage.Get<string>('ContinueNote')
        if (continueNote == undefined || continueNote == null) {
            console.log("MainAbility onContinue, continue first note")
            continueNote = JSON.stringify(AppStorage.Get('AllNoteArray')[0].toNoteObject())
        }
        console.log("MainAbility onContinue, continueNote is " + continueNote)

        let continueSection = AppStorage.Get<number>('ContinueSection')
        if (continueSection == undefined || continueSection == null) {
            console.log("MainAbility onContinue, continue section 3")
            continueSection = 3
        }
        console.log("MainAbility onContinue, continueSection is " + continueSection)

        // 保存本端的迁移数据
        wantParam["ContinueFolder"] = continueFolder;
        wantParam["ContinueNote"] = continueNote;
        wantParam["ContinueSection"] = continueSection;

        return true
    }
};
