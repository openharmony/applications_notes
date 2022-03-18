/*
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
import {LogUtil} from './LogUtil.ets'
import {MediaLibraryAccess} from '../access/MediaLibraryAccess.ets';
import fileio from '@ohos.fileio';

const TAG = "OperationUtils"
export class OperationUtils {


    async copy(uri: string):Promise<string> {
        try {
            let numId = this.getIdByUri(uri)
            var context = globalThis.noteContext
            let fileAsset = await this.getFileAssetById(numId,context);
            if (fileAsset == null || fileAsset == undefined) {
                LogUtil.warn(TAG, "Failed to get fileAsset")
                return;
            }

            let fd = await MediaLibraryAccess.openAsset('RW', fileAsset);
            if (fd <= 0) {
                LogUtil.warn(TAG, "fd is invaild")
                return;
            }
            LogUtil.info(TAG, 'copyAsset read end!')

            // 通过Uri拷贝图片到指定指定的包路径下
            // 1、获取本地路径
            var dir = context.filesDir
            // 2、生成本地文件名
            var time = new Date().getTime()
            var imagePath = dir + "/" + time.toString().substr(10) + "_note"+ numId + ".jpg"
            // 3、拷贝
            fileio.copyFile(fd, imagePath).then(() => {
                LogUtil.info(TAG, "[save]copyFile successfully")
            }).catch((err) => {
                LogUtil.info(TAG, "[save]copyFile failed : " + err)
            });
            // 4、关闭安fd,Asset
            fileAsset.close(fd);
            await MediaLibraryAccess.closeAsset(fd, fileAsset);
        } catch (error) {
            LogUtil.info(TAG, "create error: " + error);
            return;
        }
        LogUtil.debug(TAG, 'copy end');

        return imagePath.toString()
    }

    getIdByUri(uri:string): number {
        let srcIndex = uri.lastIndexOf('/');
        let srcEnd = uri.length;
        let srcId = uri.substring(srcIndex + 1, srcEnd);
        let numId = new Number(srcId);
        LogUtil.debug(TAG, `getIdByUri numId: ${numId}`);
        return numId.valueOf();
    }

    async getFileAssetById(id,context){
        LogUtil.info(TAG, 'getFileAssetById');
        let fetchOpt = {
            selections : 'file_id =?',
            selectionArgs : [`${id}`],
        }

        try {
            let result = await MediaLibraryAccess.getFirstObject(fetchOpt,context);
            if (result == null) {
                LogUtil.info(TAG, 'getFileAssetByUri fail');
                return null;
            }
            return result.obj;
        } catch (error) {
            LogUtil.info(TAG, 'getFileAssetById error');
            return null;
        }
    }
}

let mOperationUtils = new OperationUtils();
export default mOperationUtils as OperationUtils;
