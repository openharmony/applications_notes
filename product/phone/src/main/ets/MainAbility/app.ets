import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets'

const TAG = "NoteApp"

export default {
  onCreate() {
    LogUtil.info(TAG, "Application onCreate")
    AppStorage.SetOrCreate('AllFolderArray', [])
    AppStorage.SetOrCreate('AllNoteArray', [])
    AppStorage.SetOrCreate('DBQueryFinished', 0)
    LogUtil.info(TAG, "AppStorage SetOrCreate : AllFolderArray, AllNoteArray, DBQueryFinished")
  },

  onDestroy() {
    LogUtil.info(TAG, 'Application onDestroy')
  },
}