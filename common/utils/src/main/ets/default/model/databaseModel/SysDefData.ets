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

import {SysDefFolder, SysDefFolderUuid, FolderType, NoteType, Favorite, Top, Delete} from './EnumData.ets'

export default {
  /**
   * db info
   */
  dbInfo: {
    db_name: {
      name: "note.db" // 数据库名称
    },
    db_verison: 1 // 数据库版本
  },

  /**
   * system defined folder
   */
  sys_def_allNotes: {
    "id": 1,
    "name": SysDefFolder.AllNotes,
    "uuid": SysDefFolderUuid.AllNotes,
    "color": "#ffffff",
    "folder_type": FolderType.SysDef,
    "is_deleted": Delete.No,
    "created_time": 1641863695000,
    "modified_time": 1641863695000
  },

  sys_def_unClassified: {
    "id": 2,
    "name": SysDefFolder.UnClassified,
    "uuid": SysDefFolderUuid.UnClassified,
    "color": "#ffffff",
    "folder_type": FolderType.SysDef,
    "is_deleted": Delete.No,
    "created_time": 1641860095000,
    "modified_time": 1641860095000
  },

  sys_def_myFavorites: {
    "id": 3,
    "name": SysDefFolder.MyFavorites,
    "uuid": SysDefFolderUuid.MyFavorites,
    "color": "#ffffff",
    "folder_type": FolderType.FeatureDef,
    "is_deleted": Delete.No,
    "created_time": 1641856088000,
    "modified_time": 1641856088000
  },

  sys_def_recentDeletes: {
    "id": 4,
    "name": SysDefFolder.RecentDeletes,
    "uuid": SysDefFolderUuid.RecentDeletes,
    "color": "#ffffff",
    "folder_type": FolderType.FeatureDef,
    "is_deleted": Delete.No,
    "created_time": 1641848898000,
    "modified_time": 1641848898000
  },

  sys_def_personal: {
    "id": 5,
    "name": "个人",
    "uuid": SysDefFolderUuid.Personal,
    "color": "#41ba41",
    "folder_type": FolderType.CusDef,
    "is_deleted": Delete.No,
    "created_time": 1641677288000,
    "modified_time": 1641677288000
  },

  sys_def_life: {
    "id": 6,
    "name": "生活",
    "uuid": SysDefFolderUuid.Life,
    "color": "#00aaee",
    "folder_type": FolderType.CusDef,
    "is_deleted": Delete.No,
    "created_time": 1641676108000,
    "modified_time": 1641676108000
  },

  sys_def_work: {
    "id": 7,
    "name": "工作",
    "uuid": SysDefFolderUuid.Work,
    "color": "#e84026",
    "folder_type": FolderType.CusDef,
    "is_deleted": Delete.No,
    "created_time": 1641636508000,
    "modified_time": 1641636508000
  },

  /**
   * system defined note
   */
  sys_def_note1: {
    "id": 1,
    "title": "数学公式",
    "uuid": "note1_uuid",
    "folder_uuid": SysDefFolderUuid.UnClassified,
    "content_text": '好好学习，天天向上<div style="text-align:center;"><img src="./shuxue.png"  height="700"/></div><br><br>',
    "content_img": "/res/shuxue.png",
    "note_type": NoteType.SysDef,
    "is_top": Top.Yes,
    "is_favorite": Favorite.Yes,
    "is_deleted": Delete.No,
    "created_time": 1641869573000,
    "modified_time": 1641869573000,
    "deleted_time": 0
  },

  sys_def_note2: {
    "id": 2,
    "title": "UX会议纪要",
    "uuid": "note2_uuid",
    "folder_uuid": SysDefFolderUuid.Work,
    "content_text": "UX会议纪要",
    "content_img": "",
    "note_type": NoteType.SysDef,
    "is_top": Top.Yes,
    "is_favorite": Favorite.No,
    "is_deleted": Delete.No,
    "created_time": 1640999288000,
    "modified_time": 1640999288000,
    "deleted_time": 0
  },

  sys_def_note3: {
    "id": 3,
    "title": "旅游心得",
    "uuid": "note3_uuid",
    "folder_uuid": SysDefFolderUuid.Work,
    "content_text": '旅游心得<div style="text-align:center;"><img src="./lvyou.png"  height="700"/></div><br><br>',
    "content_img": "/res/lvyou.png",
    "note_type": NoteType.SysDef,
    "is_top": Top.No,
    "is_favorite": Favorite.No,
    "is_deleted": Delete.No,
    "created_time": 1641385708000,
    "modified_time": 1641385708000,
    "deleted_time": 0
  },

  sys_def_note4: {
    "id": 4,
    "title": "蛋糕做法",
    "uuid": "note4_uuid",
    "folder_uuid": SysDefFolderUuid.Life,
    "content_text": '蛋糕做法<div style="text-align:center;"><img src="./cake.png"  height="700"/></div><br><br>',
    "content_img": "/res/cake.png",
    "note_type": NoteType.CusDef,
    "is_top": Top.No,
    "is_favorite": Favorite.Yes,
    "is_deleted": Delete.No,
    "created_time": 1640909288000,
    "modified_time": 1640909288000,
    "deleted_time": 0
  }
}