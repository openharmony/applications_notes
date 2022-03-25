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
    "content_text": '<p>好好学习，天天向上</p><div style="text-align:center;"><img src="./shuxue.png"  height="700" style="border-radius:24px"/></div><br><br>',
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
    "content_text": "",
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
    "content_text": '<div style="line-height:1.4;"><p>出门在外首要是安全问题，不然命都没有了还谈什么?其次是身上的财物，要知道，你一到某地，身上的行李很容易被狼盯上。' +
                    '背着旅行袋的人到那里都是任人宰割的对象，所以不要完成全相信陌生人的话，也不要走行人稀少的小道，方便的话最好是将包裹就近寄存，免去这道危险。' +
                    '同时在身上相对安全的地方保留贴身的救命钱，狡兔三窟，千万不要将开心的旅游变成伤心的流浪!</p>' +
                    '<p>出门在外要想整个旅程无遗憾，关键是心态。首先要对即将到的目的地有一个正确的认识和恰当的期望。</p>' +
                    '<p>一般每个自然风景区旅游区都有着自己的特色，带著一种游九寨沟桂林山水的心情和期望去陕西的人肯定会失望而归。' +
                    '同样带着游西部的心情和期望去海南.桂林你也会觉得那里也没有什么，只不过山和水比别的地方特别一点。</p></div>',
    "content_img": "",
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
    "content_text": '<div style="line-height:1.4;">' +
                    '<input name="checkbox" type="checkbox" onclick="onCheckChange(this)" class="note-checkbox" checked="checked">' +
                    '<span class="note-checkbox-txt">&nbsp;&nbsp;糖60g</span><br>' +
                    '<input name="checkbox" type="checkbox" onclick="onCheckChange(this)" class="note-checkbox">' +
                    '<span class="note-checkbox-txt">&nbsp;&nbsp;玉米油40g</span><br><div>' +
                    '<div style="margin-top:14px; margin-top:14px;"><text>&nbsp;&nbsp;&nbsp;&nbsp;1. 准备小盆打入三个鸡蛋，加盐加糖，蛋糕粉分两次加入蛋糊内。<br>' +
                    '&nbsp;&nbsp;&nbsp;&nbsp;2. 玉米油倒入碗里，再加入牛奶，用打蛋器打到完全融为一体，烤箱预热15分钟。<br>' +
                    '&nbsp;&nbsp;&nbsp;&nbsp;3. 再加入葡萄干、核桃仁，把蛋糕放进烤箱，定时40分钟，取出即可食用。<br><br></text><div>' +
                    '<div style="text-align:center;"><img src="./cake.png"  height="600" style="border-radius:24px"/></div><br><br>',
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