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

import LogUtil from '../../baseUtil/LogUtil.ets'
import NoteData from '../../model/databaseModel/NoteData.ets'
import ohosDataRdb from '@ohos.data.rdb';
import {TableName, NoteTableColumn} from '../../model/databaseModel/EnumData.ets'
import NoteUtil from '../../baseUtil/NoteUtil.ets'
import RdbStoreUtil from '../../baseUtil/RdbStoreUtil.ets'
import SysDefData from '../../model/databaseModel/SysDefData.ets'

const TAG = "SearchModel"

/**
 * Search service class
 */
export class SearchModel {
  private rdbStore;

  /**
   * Search
   *
   * @param query - query content
   */
  public async search(noteDataArray: NoteData[], query: string): Promise<NoteData[]> {
    LogUtil.info(TAG, "query is " + query)
    if (!query) {
      LogUtil.info(TAG, "query is null")
      return []
    }
    let searchData: NoteData[] = [];
    noteDataArray.forEach((noteData) => {
      if (noteData.content_text.toLowerCase().indexOf(query.toLowerCase()) != -1
        || noteData.title.toLowerCase().indexOf(query.toLowerCase()) != -1) {
        LogUtil.info(TAG, "uuid " + noteData.uuid)
        searchData.push(noteData);
      }
    })
    // 排序
    return searchData;
  }

  splitToHighlightText(text: string, highlightKeyword): any[] {
    let spans: any[] = []
    var lowerSpans: string[] = text.toLowerCase().split(highlightKeyword.toLowerCase())
    var keywordStartIndex = 0
    var keywordLength = highlightKeyword.length

    for (var i = 0; i < lowerSpans.length; i++) {
      var normalText = text.substr(keywordStartIndex, lowerSpans[i].length)
      spans.push({
        type: 0,
        text: normalText
      })
      // if not at last, append highlight keyword
      if (i != lowerSpans.length - 1) {
        keywordStartIndex += lowerSpans[i].length
        var keywordText = text.substr(keywordStartIndex, keywordLength)
        spans.push({
          type: 1,
          text: keywordText
        })
        keywordStartIndex += keywordLength
      }
    }

    return spans
  }
}

let searchModel = new SearchModel()
export default searchModel as SearchModel