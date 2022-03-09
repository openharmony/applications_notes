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

import LogUtil from '../../common/baseUtil/LogUtil.ets'
import SysDefData from '../../model/databaseModel/SysDefData.ets'
import FolderData from '../../model/databaseModel/FolderData.ets'
import NoteData from '../../model/databaseModel/NoteData.ets'

const TAG = "FakerRdbStoreUtil"
let folderDataArray = []
let noteDataArray = []

function FakerInitFolder(folderdata: any) {
  return new FolderData(0, folderdata.name, folderdata.uuid, folderdata.color, folderdata.folder_type, folderdata.is_deleted,
    folderdata.created_time, folderdata.modified_time)
}

function FakerInitFolderArray(folderdataList: any[]) {
  folderdataList.forEach((folderData) => {
    folderDataArray.push(FakerInitFolder(folderData))
  })
}

function FakerInitNote(noteData: any) :NoteData{
  return new NoteData(0, noteData.title, noteData.uuid, noteData.folder_uuid, noteData.content_text, noteData.content_img,
    noteData.note_type, 0, 0, 0, noteData.created_time, noteData.modified_time, noteData.deleted_time)
}

function FakerInitNoteArray(noteDataList: any[]) {
  noteDataList.forEach((noteData) => {
    noteDataArray.push(FakerInitNote(noteData))
  })
}

export default {
  FakerInitAppStorage() {
    FakerInitFolderArray([SysDefData.sys_def_allNotes, SysDefData.sys_def_unClassified, SysDefData.sys_def_life,SysDefData.sys_def_recentDeletes, SysDefData.sys_def_myFavorites,
    SysDefData.sys_def_personal, SysDefData.sys_def_work])
    FakerInitNoteArray([SysDefData.sys_def_note1,SysDefData.sys_def_note2, SysDefData.sys_def_note3, SysDefData.sys_def_note4])
    AppStorage.SetOrCreate('AllNoteArray', noteDataArray)
    AppStorage.SetOrCreate('AllFolderArray', folderDataArray)
    for (let folderData of folderDataArray) {
      LogUtil.info(TAG, "folderData : " + JSON.stringify(folderData))
    }
    for (let noteData of noteDataArray) {
      LogUtil.info(TAG, "noteDataArray : " + JSON.stringify(noteData))
    }
    AppStorage.SetOrCreate('DBQueryFinished', 1)
  }

}