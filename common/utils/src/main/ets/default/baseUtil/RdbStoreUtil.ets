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

import ohosDataRdb from '@ohos.data.rdb'
import LogUtil from './LogUtil.ets'
import SysDefData from '../model/databaseModel/SysDefData.ets'
import FolderData from '../model/databaseModel/FolderData.ets'
import NoteData from '../model/databaseModel/NoteData.ets'
import {TableSql, TableName, FolderTableColumn, NoteTableColumn} from '../model/databaseModel/EnumData.ets'

const TAG = "RdbStoreUtil"

/**
 * db instance
 */
var rdbStore = undefined

export default {
  /**
   * create db and table
   */
  createRdbStore(context) {
    ohosDataRdb.getRdbStore(context, SysDefData.dbInfo.db_name, SysDefData.dbInfo.db_verison)
      .then(async (store) => {
        LogUtil.info(TAG, "createRdbStore, store is " + store)
        rdbStore = store
        // create table
        await rdbStore.executeSql(TableSql.FolderTableSQL, null)
        await rdbStore.executeSql(TableSql.NoteTableSQL, null)
        await rdbStore.executeSql(TableSql.AttachmentTableSQL, null)
        await rdbStore.executeSql(TableSql.FormTableSQL, null)
        LogUtil.info(TAG, "create table success")
        // insert system defined folder
        await rdbStore.insert(TableName.FolderTable, SysDefData.sys_def_allNotes)
        LogUtil.info(TAG, "insert sys_def_allNotes success")
        await rdbStore.insert(TableName.FolderTable, SysDefData.sys_def_unClassified)
        LogUtil.info(TAG, "insert sys_def_unClassified success")
        await rdbStore.insert(TableName.FolderTable, SysDefData.sys_def_myFavorites)
        LogUtil.info(TAG, "insert sys_def_myFavorites success")
        await rdbStore.insert(TableName.FolderTable, SysDefData.sys_def_recentDeletes)
        LogUtil.info(TAG, "insert sys_def_recentDeletes success")
        await rdbStore.insert(TableName.FolderTable, SysDefData.sys_def_personal)
        LogUtil.info(TAG, "insert sys_def_personal success")
        await rdbStore.insert(TableName.FolderTable, SysDefData.sys_def_life)
        LogUtil.info(TAG, "insert sys_def_life success")
        await rdbStore.insert(TableName.FolderTable, SysDefData.sys_def_work)
        LogUtil.info(TAG, "insert sys_def_work success")
        // insert system defined note and attachment
        await rdbStore.insert(TableName.NoteTable, SysDefData.sys_def_note1)
        LogUtil.info(TAG, "insert sys_def_note1 success")
        await rdbStore.insert(TableName.NoteTable, SysDefData.sys_def_note2)
        LogUtil.info(TAG, "insert sys_def_note2 success")
        await rdbStore.insert(TableName.NoteTable, SysDefData.sys_def_note3)
        LogUtil.info(TAG, "insert sys_def_note3 success")
        await rdbStore.insert(TableName.NoteTable, SysDefData.sys_def_note4)
        LogUtil.info(TAG, "insert sys_def_note4 success")

        // add sys-def folder and note to AppStorage
        let folderDataArray = []
        let sysDefFolderArray = [SysDefData.sys_def_allNotes, SysDefData.sys_def_unClassified,
        SysDefData.sys_def_myFavorites, SysDefData.sys_def_recentDeletes,
        SysDefData.sys_def_personal, SysDefData.sys_def_life, SysDefData.sys_def_work]
        sysDefFolderArray.forEach((sysDefFolder) => {
          let folderData = new FolderData(sysDefFolder.id, sysDefFolder.name, sysDefFolder.uuid, sysDefFolder.color,
            sysDefFolder.folder_type, sysDefFolder.is_deleted, sysDefFolder.created_time,
            sysDefFolder.modified_time)
          folderDataArray.push(folderData)
        })
        let noteDataArray = []
        let sysDefNoteArray = [SysDefData.sys_def_note1, SysDefData.sys_def_note2,
        SysDefData.sys_def_note3, SysDefData.sys_def_note4]
        sysDefNoteArray.forEach((sysDefNote) => {
          let noteData = new NoteData(sysDefNote.id, sysDefNote.title, sysDefNote.uuid, sysDefNote.folder_uuid, sysDefNote.content_text,
            sysDefNote.content_img, sysDefNote.note_type, sysDefNote.is_top, sysDefNote.is_favorite,
            sysDefNote.is_deleted, sysDefNote.created_time, sysDefNote.modified_time, sysDefNote.deleted_time)
          noteDataArray.push(noteData)
        })
        LogUtil.info(TAG, "folderDataArray[sysdef] : " + folderDataArray.length)
        for (let folderData of folderDataArray) {
          LogUtil.info(TAG, "folderData[sysdef] : " + JSON.stringify(folderData))
        }
        LogUtil.info(TAG, "noteDataArray[sysdef] : " + noteDataArray.length)
        for (let noteData of noteDataArray) {
          LogUtil.info(TAG, "noteData[sysdef] : " + JSON.stringify(noteData))
        }
        AppStorage.SetOrCreate('AllFolderArray', folderDataArray)
        AppStorage.SetOrCreate('AllNoteArray', noteDataArray)

        // 迁移
        let isContinue = AppStorage.Get('IsContinue');
        LogUtil.info(TAG, "createRdbStore, isContinue is " + isContinue)
        if (isContinue != undefined && isContinue == 1) {
          console.info("RdbStoreUtil createRdbStore, IsContinue true")
          let continueFolder: string = AppStorage.Get('ContinueFolder')
          console.log("RdbStoreUtil createRdbStore, continueFolder is " + continueFolder)
          let continueNote: string = AppStorage.Get('ContinueNote')
          console.log("RdbStoreUtil createRdbStore, continueNote is " + continueNote)
          let continueSection = AppStorage.Get('ContinueSection')
          console.log("RdbStoreUtil createRdbStore, continueSection is " + continueSection)

          let folderObj = JSON.parse(continueFolder)
          let folderData = new FolderData(folderObj.uuid, folderObj.name, folderObj.uuid, folderObj.color,
            folderObj.folder_type, folderObj.is_deleted, folderObj.created_time, folderObj.modified_time)

          let noteObj = JSON.parse(continueNote)
          let noteData = new NoteData(noteObj.uuid, noteObj.title, noteObj.uuid, noteObj.folder_uuid,
            noteObj.content_text, noteObj.content_img, noteObj.note_type, noteObj.is_top, noteObj.is_favorite,
            noteObj.is_deleted, noteObj.created_time, noteObj.modified_time, noteObj.deleted_time)

          AppStorage.SetOrCreate('Folder', folderData)
          AppStorage.SetOrCreate('Note', noteData)
          AppStorage.SetOrCreate('Section', continueSection)
        } else {
          console.info("RdbStoreUtil createRdbStore, IsContinue false")
          AppStorage.SetOrCreate('Folder', AppStorage.Get('AllFolderArray')[0])
          AppStorage.SetOrCreate('Note', AppStorage.Get('AllNoteArray')[0])
          AppStorage.SetOrCreate('Section', 3)
        }
        AppStorage.SetOrCreate('DBQueryFinished', 1)
        LogUtil.info(TAG, "createRdbStore, set DBQueryFinished 1")
      })
      .catch((err) => {
        LogUtil.error(TAG, "createRdbStore, error : " + err)
      })
  },

  /**
   * query folders and notes from the database, then save them to the AppStorage.
   */
  initAppStorage(context) {
    let folderDataArray = []
    let noteDataArray = []
    ohosDataRdb.getRdbStore(context, SysDefData.dbInfo.db_name, SysDefData.dbInfo.db_verison)
      .then(async (store) => {
        LogUtil.info(TAG, "initAppStorage, store is " + store)
        rdbStore = store
        // query folder
        let columns_folder = []
        let predicates_folder = new ohosDataRdb.RdbPredicates(TableName.FolderTable)
        let resultSet_folder = await rdbStore.query(predicates_folder, columns_folder)
        while (resultSet_folder.goToNextRow()) {
          let id = resultSet_folder.getLong(resultSet_folder.getColumnIndex(FolderTableColumn.Id))
          let name = resultSet_folder.getString(resultSet_folder.getColumnIndex(FolderTableColumn.Name))
          let uuid = resultSet_folder.getString(resultSet_folder.getColumnIndex(FolderTableColumn.Uuid))
          let color = resultSet_folder.getString(resultSet_folder.getColumnIndex(FolderTableColumn.Color))
          let folder_type = resultSet_folder.getLong(resultSet_folder.getColumnIndex(FolderTableColumn.FolderType))
          let is_deleted = resultSet_folder.getLong(resultSet_folder.getColumnIndex(FolderTableColumn.IsDeleted))
          let created_time = resultSet_folder.getLong(resultSet_folder.getColumnIndex(FolderTableColumn.CreatedTime))
          let modified_time = resultSet_folder.getLong(resultSet_folder.getColumnIndex(FolderTableColumn.ModifiedTime))
          let folderData = new FolderData(id, name, uuid, color, folder_type, is_deleted, created_time, modified_time)
          folderDataArray.push(folderData)
        }
        LogUtil.info(TAG, "query folder table success")
        // query note
        let columns_note = []
        let predicates_note = new ohosDataRdb.RdbPredicates(TableName.NoteTable)
        let resultSet_note = await rdbStore.query(predicates_note, columns_note)
        while (resultSet_note.goToNextRow()) {
          let id = resultSet_note.getLong(resultSet_note.getColumnIndex(NoteTableColumn.Id))
          let title = resultSet_note.getString(resultSet_note.getColumnIndex(NoteTableColumn.Title))
          let uuid = resultSet_note.getString(resultSet_note.getColumnIndex(NoteTableColumn.Uuid))
          let folder_uuid = resultSet_note.getString(resultSet_note.getColumnIndex(NoteTableColumn.FolderUuid))
          let content_text = resultSet_note.getString(resultSet_note.getColumnIndex(NoteTableColumn.ContentText))
          let content_img = resultSet_note.getString(resultSet_note.getColumnIndex(NoteTableColumn.ContentImg))
          let noteType = resultSet_note.getLong(resultSet_note.getColumnIndex(NoteTableColumn.NoteType))
          let is_top = resultSet_note.getLong(resultSet_note.getColumnIndex(NoteTableColumn.IsTop))
          let is_favorite = resultSet_note.getLong(resultSet_note.getColumnIndex(NoteTableColumn.IsFavorite))
          let is_deleted = resultSet_note.getLong(resultSet_note.getColumnIndex(NoteTableColumn.IsDeleted))
          let created_time = resultSet_note.getLong(resultSet_note.getColumnIndex(NoteTableColumn.CreatedTime))
          let modified_time = resultSet_note.getLong(resultSet_note.getColumnIndex(NoteTableColumn.ModifiedTime))
          let deleted_time = resultSet_note.getLong(resultSet_note.getColumnIndex(NoteTableColumn.DeletedTime))
          let noteData = new NoteData(id, title, uuid, folder_uuid, content_text, content_img, noteType, is_top, is_favorite, is_deleted, created_time, modified_time, deleted_time)
          noteDataArray.push(noteData)
        }
        LogUtil.info(TAG, "query note table success")
        LogUtil.info(TAG, "folderDataArray[query] : " + folderDataArray.length)
        for (let folderData of folderDataArray) {
          LogUtil.info(TAG, "folderData[query] : " + JSON.stringify(folderData))
        }
        LogUtil.info(TAG, "noteDataArray[query] : " + noteDataArray.length)
        for (let noteData of noteDataArray) {
          LogUtil.info(TAG, "noteData[query] : " + JSON.stringify(noteData))
        }
        AppStorage.SetOrCreate('AllFolderArray', folderDataArray)
        AppStorage.SetOrCreate('AllNoteArray', noteDataArray)

        // 迁移
        let isContinue = AppStorage.Get('IsContinue');
        LogUtil.info(TAG, "initAppStorage, isContinue is " + isContinue)
        if (isContinue != undefined && isContinue == 1) {
          console.info("RdbStoreUtil initAppStorage, IsContinue true")
          let continueFolder: string = AppStorage.Get('ContinueFolder')
          console.log("RdbStoreUtil initAppStorage, continueFolder is " + continueFolder)
          let continueNote: string = AppStorage.Get('ContinueNote')
          console.log("RdbStoreUtil initAppStorage, continueNote is " + continueNote)
          let continueSection = AppStorage.Get('ContinueSection')
          console.log("RdbStoreUtil initAppStorage, continueSection is " + continueSection)

          let folderObj = JSON.parse(continueFolder)
          let folderData = new FolderData(folderObj.uuid, folderObj.name, folderObj.uuid, folderObj.color,
            folderObj.folder_type, folderObj.is_deleted, folderObj.created_time, folderObj.modified_time)

          let noteObj = JSON.parse(continueNote)
          let noteData = new NoteData(noteObj.uuid, noteObj.title, noteObj.uuid, noteObj.folder_uuid,
            noteObj.content_text, noteObj.content_img, noteObj.note_type, noteObj.is_top, noteObj.is_favorite,
            noteObj.is_deleted, noteObj.created_time, noteObj.modified_time, noteObj.deleted_time)

          AppStorage.SetOrCreate('Folder', folderData)
          AppStorage.SetOrCreate('Note', noteData)
          AppStorage.SetOrCreate('Section', continueSection)
        } else {
          console.info("RdbStoreUtil initAppStorage, IsContinue false")
          AppStorage.SetOrCreate('Folder', AppStorage.Get('AllFolderArray')[0])
          AppStorage.SetOrCreate('Note', AppStorage.Get('AllNoteArray')[0])
          AppStorage.SetOrCreate('Section', 3)
        }
        AppStorage.SetOrCreate('DBQueryFinished', 1)
        LogUtil.info(TAG, "initAppStorage, set DBQueryFinished 1")
      })
      .catch((err) => {
        LogUtil.error(TAG, "initAppStorage, error : " + err)
      })
  },

  /**
   * insert
   * @param tableName
   * @param valueBucket
   * @param callback
   */
  insert(tableName, valueBucket, callback) {
    rdbStore.insert(tableName, valueBucket).then((rowId) => {
      LogUtil.info(TAG, "insert success, rowId is " + rowId)
      if (callback != null) {
        callback(rowId)
      }
    }).catch((err) => {
      LogUtil.error(TAG, "insert error : " + err)
    })
  },

  /**
   * delete
   * @param predicates
   * @param callback
   */
  delete(predicates, callback) {
    rdbStore.delete(predicates).then((affectedRowCount) => {
      LogUtil.info(TAG, "delete success, affectedRowCount is " + affectedRowCount)
      if (callback != null) {
        callback(affectedRowCount)
      }
    }).catch((err) => {
      LogUtil.error(TAG, "delete error : " + err)
    })
  },

  /**
   * update
   * @param valueBucket
   * @param predicates
   * @param callback
   */
  update(valueBucket, predicates, callback) {
    rdbStore.update(valueBucket, predicates).then((affectedRowCount) => {
      LogUtil.info(TAG, "update success, affectedRowCount is " + affectedRowCount)
      if (callback != null) {
        callback(affectedRowCount)
      }
    }).catch((err) => {
      LogUtil.error(TAG, "update error : " + err)
    })
  },

  /**
   * query
   * @param columns
   * @param predicates
   * @param callback
   */
  query(columns, predicates, callback) {
    rdbStore.query(predicates, columns).then((resultSet) => {
      LogUtil.info(TAG, "query success, row count : " + resultSet.rowCount)
      if (callback != null) {
        callback(resultSet)
      }
    }).catch((err) => {
      LogUtil.error(TAG, "query error : " + err)
    })
  },

  /**
   * get RdbPredicates by table name
   * @param tableName
   */
  getRdbPredicates(tableName) {
    return new ohosDataRdb.RdbPredicates(tableName)
  }
}