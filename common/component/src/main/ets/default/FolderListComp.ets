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

import FolderData from '../../../../../../common/utils/src/main/ets/default/model/databaseModel/FolderData.ets'
import NoteData from '../../../../../../common/utils/src/main/ets/default/model/databaseModel/NoteData.ets'
import {SysDefFolderUuid, TableName, FolderType, FolderTableColumn, NoteTableColumn, Delete, DeleteFileType} from '../../../../../../common/utils/src/main/ets/default/model/databaseModel/EnumData.ets'
import {NewOrEditFolderDialog, DeleteDialog} from './CusDialogComp.ets'
import StyleConstants from '../../../../../../common/utils/src/main/ets/default/constants/StyleConstants.ets'
import RdbStoreUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/RdbStoreUtil.ets'
import FolderUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/FolderUtil.ets'
import NoteUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/NoteUtil.ets'
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets'

// Folder list component
@Component
export struct FolderListComp {
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = AppStorage.Link('AllFolderArray')
  @Consume('SectionStatus') sectionStatus: number
  @Consume('ExpandStatus') expandStatus: boolean // 笔记本折叠展开状态
  controllerShow: WebController
  TAG = "FolderListComp"

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Column() {
        Column() {
          Image($r("app.media.suojin"))
            .height(24)
            .width(24)
            .onClick(() => {
              if (this.sectionStatus == 1) {
                this.expandStatus = !this.expandStatus
              } else {
                this.sectionStatus = (this.sectionStatus == 3 ? 2 : 3)
                // 迁移
                console.log("FolderListComp, set continue section")
                AppStorage.SetOrCreate<number>('ContinueSection', this.sectionStatus)
                console.log("FolderListComp, set continue section success")
              }
            })
        }.alignItems(HorizontalAlign.Start)
        .width("100%")
        .margin({ top: 28 })
        .padding({ left: 24 })

        NoteAndCreateComp()
        // center
        Column() {
          List() {
            ForEach(this.AllFolderArray, (folderItem: FolderData) => {
              ListItem() {
                if (!FolderUtil.isBottomFixedFolder(folderItem)) {
                  FolderItemComp({ folderItem: folderItem, controllerShow: this.controllerShow })
                }
              }
            }, folderItem => folderItem.name.toString())
          }
        }.width('100%')
        .padding({ left: 12, right: 12 })
        .height(7 * 56) // 列表最多显示7个 每个的高度为56
      }

      Column() {
        FolderItemComp({
          folderItem: FolderUtil.getFolderData(AppStorage.Get('AllFolderArray'), SysDefFolderUuid.MyFavorites),
          controllerShow: this.controllerShow
        })
        FolderItemComp({
          folderItem: FolderUtil.getFolderData(AppStorage.Get('AllFolderArray'), SysDefFolderUuid.RecentDeletes),
          controllerShow: this.controllerShow
        })
      }.margin({ bottom: 48 })
      .width("100%")
      .padding({ left: 12, right: 12 })
    }
  }

  aboutToAppear(): void{
    LogUtil.info(this.TAG, "aboutToAppear")
  }

  aboutToDisappear(): void{
    LogUtil.info(this.TAG, "aboutToDisappear")
  }

}

@Component
export struct NoteAndCreateComp {
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = AppStorage.Link('AllFolderArray')
  @Consume('SelectedColor') selectedColor: string
  @Consume('PortraitModel') portraitModel: boolean
  folderCreateDialogCtl: CustomDialogController = new CustomDialogController({
    builder: NewOrEditFolderDialog({ confirm: this.onCreateConfirm.bind(this), dialogType: 0 }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true,
  })
  folderCreateDialogCtlBottom: CustomDialogController = new CustomDialogController({
    builder: NewOrEditFolderDialog({ confirm: this.onCreateConfirm.bind(this), dialogType: 0 }),
    alignment: DialogAlignment.Bottom,
    autoCancel: false,
    customStyle: true,
  })

  onCreateConfirm(color:string, name:string) {
    let folderData = new FolderData(0, name, new Date().getTime() + "", color, FolderType.CusDef, Delete.No, new Date().getTime(), new Date().getTime()) // 新的的笔记本都是自定义类型 type为1
    this.AllFolderArray.push(folderData)
    // insert folder to db
    RdbStoreUtil.insert(TableName.FolderTable, folderData.toFolderObject(), null)
  }

  build() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Row() {
        Text($r("app.string.note"))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }.width(102)

      Row() {
        Text($r("app.string.create"))
          .fontSize(14)
          .fontColor($r("app.color.text_color_f86d05"))
          .onClick(() => {
            this.selectedColor = "#e84026" // 新建的时候选中第一个颜色
            if (this.portraitModel) {
              this.folderCreateDialogCtlBottom.open()
            } else {
              this.folderCreateDialogCtl.open()
            }
          }).padding({ right: 0 })
      }.width(50)
    }.width("100%")
    .margin({ top: 8 })
    .padding({ left: 24 })
    .height(56)
  }
}

@Component
struct FolderItemComp {
  @State folderItem: FolderData = undefined
  @StorageLink('AllNoteArray') AllNoteArray: NoteData[]  = []
  @StorageLink('AllFolderArray') AllFolderArray: FolderData[]  = []
  @StorageLink('CheckedNoteArray') CheckedNoteArray: NoteData[]  = []
  @Consume('SelectedFolderData') selectedFolderData: FolderData
  @Consume('SelectedNoteData') selectedNoteData: NoteData
  @Consume('RefreshFlag') refreshFlag: number
  @Consume('Longpress') longpress: boolean
  @Consume('SelectedColor') selectedColor: string
  @Consume('PortraitModel') portraitModel: boolean
  controllerShow: WebController
  private isLongPress: boolean = false
  TAG = "FolderListComp"
// Folder Edit Dialog
  folderEditDialogCtl: CustomDialogController = new CustomDialogController({
    builder: NewOrEditFolderDialog({
      editFolderUuid: this.folderItem.uuid,
      confirm: this.onEditConfirm.bind(this),
      dialogType: 1
    }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true,
  })
// Folder Edit Dialog for portrait model
  folderEditDialogCtlBottom: CustomDialogController = new CustomDialogController({
    builder: NewOrEditFolderDialog({
      editFolderUuid: this.folderItem.uuid,
      confirm: this.onEditConfirm.bind(this),
      dialogType: 1
    }),
    alignment: DialogAlignment.Bottom,
    autoCancel: false,
    customStyle: true,
  })
// Folder Edit Callback
  onEditConfirm(color:string, name:string) {
    this.folderItem.color = color
    this.folderItem.name = name
    this.folderItem.folder_type = FolderType.CusDef
    // update folder to db
    let predicates_folder = RdbStoreUtil.getRdbPredicates(TableName.FolderTable)
    predicates_folder.equalTo(FolderTableColumn.Uuid, this.folderItem.uuid)
    RdbStoreUtil.update(this.folderItem.toFolderObject(), predicates_folder, null)
  }
// Folder Delete Dialog
  folderDeleteDialogCtl: CustomDialogController = new CustomDialogController({
    builder: DeleteDialog({ onConfirm: this.onDeleteConfirm.bind(this), deleteFileType: DeleteFileType.FolderData }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true,
  })
// Folder Delete Dialog for portrait model
  folderDeleteDialogCtlBottom: CustomDialogController = new CustomDialogController({
    builder: DeleteDialog({ onConfirm: this.onDeleteConfirm.bind(this), deleteFileType: DeleteFileType.FolderData }),
    alignment: DialogAlignment.Bottom,
    autoCancel: false,
    customStyle: true,
  })
// Folder Delete Callback
  onDeleteConfirm() {
    let currentFolder = FolderUtil.getFolderData(this.AllFolderArray, this.folderItem.uuid)
    let index = this.AllFolderArray.indexOf(currentFolder)
    let currentNoteDataArray = NoteUtil.getNoteDataArray(AppStorage.Get('AllNoteArray'), this.folderItem.uuid)
    if (index > -1) {
      this.AllFolderArray.splice(index, 1)
      currentNoteDataArray.forEach((noteItem: NoteData) => {
        noteItem.is_deleted = Delete.Yes
        noteItem.folder_uuid = SysDefFolderUuid.UnClassified
        noteItem.deleted_time = new Date().getTime()
        // update note to db
        let predicates_note = RdbStoreUtil.getRdbPredicates(TableName.NoteTable)
        predicates_note.equalTo(NoteTableColumn.Uuid, noteItem.uuid)
        RdbStoreUtil.update(noteItem.toNoteObject(), predicates_note, null)
      })
      // delete folder from db
      let predicates_folder = RdbStoreUtil.getRdbPredicates(TableName.FolderTable)
      predicates_folder.equalTo(FolderTableColumn.Uuid, this.folderItem.uuid)
      RdbStoreUtil.delete(predicates_folder, null)
      // update selectedFolderData and selectedNoteData
      this.selectedFolderData = FolderUtil.getFolderData(this.AllFolderArray, SysDefFolderUuid.AllNotes)
      this.selectedNoteData = NoteUtil.getFirstNoteData(this.AllNoteArray, SysDefFolderUuid.AllNotes)
      // save continue data
      let continueFolder: string = JSON.stringify(this.selectedFolderData.toFolderObject())
      let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
      AppStorage.SetOrCreate<string>('ContinueFolder', continueFolder)
      AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
      console.log("onDeleteConfirm, set continue folder and note success")
    }
  }
// Folder Create Dialog
  folderCreateDialogCtl: CustomDialogController = new CustomDialogController({
    builder: NewOrEditFolderDialog({ confirm: this.onCreateConfirm.bind(this), dialogType: 0 }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true,
  })
// Folder Create Dialog for portrait model
  folderCreateDialogCtlBottom: CustomDialogController = new CustomDialogController({
    builder: NewOrEditFolderDialog({ confirm: this.onCreateConfirm.bind(this), dialogType: 0 }),
    alignment: DialogAlignment.Bottom,
    autoCancel: false,
    customStyle: true,
  })
// Folder Create Callback
  onCreateConfirm(color:string, name:string) {
    let folderData = new FolderData(0, name, new Date().getTime() + "", color, FolderType.CusDef, Delete.No, new Date().getTime(), new Date().getTime()) // 新的的笔记本都是自定义类型 type为1
    this.AllFolderArray.push(folderData)
    // insert folder to db
    RdbStoreUtil.insert(TableName.FolderTable, folderData.toFolderObject(), null)
  }

  @Builder menuBuilder() {
    Column({ space: 1 }) {
      Text($r("app.string.editFolder"))
        .width(124)
        .height(48)
        .padding({ top: 13, bottom: 13 })
        .fontSize(16)
        .fontColor($r("app.color.folder_color_182431"))
        .onClick(() => {
          this.selectedColor = this.folderItem.color
          if (this.portraitModel) {
            this.folderEditDialogCtlBottom.open()
          } else {
            this.folderEditDialogCtl.open()
          }
          ContextMenu.close()
        })
      Divider()
        .color($r("app.color.divider_color_e4e4e4"))
        .strokeWidth(1)
      Text($r("app.string.deleteFolder"))
        .width(124)
        .height(48)
        .padding({ top: 13, bottom: 14 })
        .fontSize(16)
        .fontColor($r("app.color.folder_color_182431"))
        .onClick(() => {
          if (this.portraitModel) {
            this.folderDeleteDialogCtlBottom.open()
          } else {
            this.folderDeleteDialogCtl.open()
          }
          ContextMenu.close()
        })
      Divider()
        .color($r("app.color.divider_color_e4e4e4"))
        .strokeWidth(1)
      Text($r("app.string.createFolder"))
        .width(124)
        .height(48)
        .padding({ top: 13, bottom: 15 })
        .fontSize(16)
        .fontColor($r("app.color.folder_color_182431"))
        .onClick(() => {
          this.selectedColor = "#e84026" // 新建的时候选中第一个颜色
          if (this.portraitModel) {
            this.folderCreateDialogCtlBottom.open()
          } else {
            this.folderCreateDialogCtl.open()
          }
          ContextMenu.close()
        })
    }
    .width(156)
    .height(154)
    .padding({ top: 4, bottom: 4, left: 16, right: 16 })
    .borderRadius(16)
    .backgroundColor(Color.White)
    .visibility(this.folderItem.folder_type == FolderType.CusDef ? Visibility.Visible : Visibility.None)
  }

  build() {
    Flex() {
      Flex({ alignItems: ItemAlign.Center, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween }) {
        Row() {
          Image(FolderUtil.getFolderIcon(this.folderItem.uuid))
            .objectFit(ImageFit.ScaleDown)
            .width(24)
            .height(24)
            .fillColor(FolderUtil.getFolderIconColor(this.AllFolderArray, this.folderItem.uuid, this.selectedFolderData.uuid == this.folderItem.uuid))
            .margin({ right: 16 })
          Text(FolderUtil.getFolderText(this.folderItem))
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .flexShrink(1)
            .fontColor(FolderUtil.getFolderTextColor(this.selectedFolderData.uuid == this.folderItem.uuid))
          Text(this.refreshFlag.toString())
            .visibility(Visibility.None) // 用于强制刷新使用
        }.width(118)

        Text(FolderUtil.getNoteCount(AppStorage.Get('AllNoteArray'), this.folderItem.uuid).toString())
          .fontSize(14)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .borderRadius(12)
      .height(56)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.isLongPress ? $r("app.color.folder_color_19182431") : this.selectedFolderData.uuid == this.folderItem.uuid
                                                                                    ? $r("app.color.folder_color_ffffff") : $r("app.color.folder_color_19ffffff"))
      .bindContextMenu(this.menuBuilder, ResponseType.LongPress)
      .bindContextMenu(this.menuBuilder, ResponseType.RightClick)
      .onClick(() => {
        if (this.longpress) {
          this.longpress = false
          NoteUtil.unsetAllNotesChecked(this.CheckedNoteArray)
        } else {
          this.selectedFolderData = this.folderItem
          this.selectedNoteData = NoteUtil.getFirstNoteData(AppStorage.Get('AllNoteArray'), this.folderItem.uuid)
          // 刷新web界面
          this.controllerShow.runJavaScript({ script: "RICH_EDITOR.setHtml('" + this.selectedNoteData.content_text + "')" })
          // save continue data
          let continueFolder: string = JSON.stringify(this.selectedFolderData.toFolderObject())
          let continueNote: string = JSON.stringify(this.selectedNoteData.toNoteObject())
          AppStorage.SetOrCreate<string>('ContinueFolder', continueFolder)
          AppStorage.SetOrCreate<string>('ContinueNote', continueNote)
          AppStorage.SetOrCreate('ContinueSection', 3)
          console.log("FolderItemComp, set continue folder and note success")
        }
      })
    }
    .width('100%')
    .height(56)
    .parallelGesture(
    GestureGroup(GestureMode.Exclusive,
    LongPressGesture()
      .onAction(() => {
        this.isLongPress = true
        this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
      })
      .onActionEnd(() => {
        this.isLongPress = false
        this.refreshFlag = (this.refreshFlag == 0 ? 1 : 0)
      })
    )
    )
  }
}