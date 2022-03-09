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

/**
 * Log Util
 */
export class LogUtil {
  getLogFirstStr(tag: string, ...msg) {
    let firstStr: string = tag + ", " + msg[0] + "  "
    try {
      throw new Error();
    } catch (e) {
      firstStr += e.stack.split('at ')[3].split(' ')[0]
    }
    return firstStr
  }

  debug(tag: string, ...msg) {
    if (msg.length == 0) {
      console.debug(tag)
      return
    }
    let firstStr = this.getLogFirstStr(tag, ...msg)
    msg.shift()
    console.debug(firstStr, ...msg)
  }

  info(tag: string, ...msg) {
    if (msg.length == 0) {
      console.debug(tag)
      return
    }
    let firstStr = this.getLogFirstStr(tag, ...msg)
    msg.shift()
    console.info(firstStr, ...msg)
  }

  warn(tag: string, ...msg) {
    if (msg.length == 0) {
      console.debug(tag)
      return
    }
    let firstStr = this.getLogFirstStr(tag, ...msg)
    msg.shift()
    console.warn(firstStr, ...msg)
  }

  error(tag: string, ...msg) {
    if (msg.length == 0) {
      console.debug(tag)
      return
    }
    let firstStr = this.getLogFirstStr(tag, ...msg)
    msg.shift()
    console.error(firstStr, ...msg)
  }
}

let mLogUtil = new LogUtil();
export default mLogUtil as LogUtil