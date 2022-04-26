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

/**
 * Log Util
 */

export class LogUtil {
  private static readonly IS_DEBUG_ON: boolean = false;
  private static readonly CONTACTS_DOMAIN: string = "00902";
  private static readonly SLASH: string = "/";
  private static readonly COLON: string = ": ";
  constructor() {
  }

  private static prefix(tag: string) {
    return this.CONTACTS_DOMAIN + this.SLASH + tag + this.COLON;
  }

  static debug(tag: string, msg: string, ...args: any[]) {
    if (this.IS_DEBUG_ON) {
      console.info(this.prefix(tag) + msg, args);
    } else {
      console.debug(this.prefix(tag) + msg, args);
    }
  }

  static info(tag: string, msg: string, ...args: any[]) {
    console.info(this.prefix(tag) + msg, args);
  }

  static warn(tag: string, msg: string, ...args: any[]) {
    console.warn(this.prefix(tag) + msg, args);
  }

  static error(tag: string, msg: string, ...args: any[]) {
    console.error(this.prefix(tag) + msg, args);
  }
}