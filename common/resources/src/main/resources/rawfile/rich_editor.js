/* @file
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

let RICH_EDITOR = {};
let storage = window.localStorage;
RICH_EDITOR.editor = document.getElementById('editorjs_box');

RICH_EDITOR.setHtml = function (contents) {
  let paddingLeft = storage.getItem('paddingLeft');
  if (contents) {
    RICH_EDITOR.editor.style.paddingLeft = paddingLeft + 'px';
  }
  let base64regex = /^([0-9a-zA-Z+/]{4})*(([0-9a-zA-Z+/]{2}==)|([0-9a-zA-Z+/]{3}=))?$/;
  if (base64regex.test(contents)) {
    RICH_EDITOR.editor.innerHTML = decodeURIComponent(escape(atob(contents)));
  } else {
    RICH_EDITOR.editor.innerHTML = contents;
  }
};

RICH_EDITOR.getHtml = function () {
  return document.getElementById('editorjs_box').innerHTML;
};

RICH_EDITOR.undo = function () {
  document.execCommand('undo', false, null);
};

RICH_EDITOR.redo = function () {
  document.execCommand('redo', false, null);
};

RICH_EDITOR.setBold = function () {
  document.execCommand('bold');
};

RICH_EDITOR.setItalic = function () {
  document.execCommand('italic', false, null);
};

RICH_EDITOR.setSubscript = function () {
  document.execCommand('subscript', false, null);
};

RICH_EDITOR.setSuperscript = function () {
  document.execCommand('superscript', false, null);
};

RICH_EDITOR.setStrikeThrough = function () {
  document.execCommand('strikeThrough', false, null);
};

RICH_EDITOR.setUnderline = function () {
  document.execCommand('underline', false, null);
};

RICH_EDITOR.getListStyle = function () {
  let selection;
  let type;
  if (window.getSelection) {
    selection = getSelection();
  }
  if (!selection) {
    return;
  }
  let range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
  try {
    let child = range.commonAncestorContainer;
    for (let i = 0; i < 10; i++) {
      if (child.nodeName === 'OL') {
        console.info('insertOrderedList');
        document.execCommand('insertOrderedList', false, null);
        return child.style['list-style'];
      }
      if (child.nodeName === 'UL') {
        console.info('insertUnorderedList');
        document.execCommand('insertUnorderedList', false, null);
        return child.style['list-style'];
      }
      if (child.parentNode) {
        child = child.parentNode;
      }
    }
  } catch (err) {
    console.error(err);
  }

};

RICH_EDITOR.setNumbers = function () {
  let listStyle = RICH_EDITOR.getListStyle();
  if (listStyle === 'decimal') {
    return;
  }
  let fontSize = document.queryCommandValue('fontSize');
  document.execCommand('insertOrderedList', false, null);
  document.execCommand('fontSize', false, fontSize);
  let selection;
  let type;
  if (window.getSelection) {
    selection = getSelection();
  }
  if (!selection) {
    return;
  }
  let range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
  try {
    let child = range.commonAncestorContainer;
    for (let i = 0; i < 10; i++) {
      if (child.nodeName === 'OL') {
        child.style['list-style'] = 'decimal';
        break;
      }
      if (child.parentNode) {
        child = child.parentNode;
      }
    }
  } catch (err) {
    console.error(err);
  }
};

RICH_EDITOR.setABC = function () {
  let listStyle = RICH_EDITOR.getListStyle();
  if (listStyle === 'lower-alpha') {
    return;
  }
  let fontSize = document.queryCommandValue('fontSize');
  document.execCommand('insertOrderedList', false, null);
  document.execCommand('fontSize', false, fontSize);
  let selection;
  let type;
  if (window.getSelection) {
    selection = getSelection();
  }
  if (!selection) {
    return;
  }
  let range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
  try {
    let child = range.commonAncestorContainer;
    for (let i = 0; i < 10; i++) {
      if (child.nodeName === 'OL') {
        child.style['list-style'] = 'lower-alpha';
        break;
      }
      if (child.parentNode) {
        child = child.parentNode;
      }
    }
  } catch (err) {
    console.error(err);
  }
};

RICH_EDITOR.setBullets = function () {
  let listStyle = RICH_EDITOR.getListStyle();
  if (listStyle === 'disc') {
    return;
  }
  let fontSize = document.queryCommandValue('fontSize');
  document.execCommand('insertUnorderedList', false, null);
  document.execCommand('fontSize', false, fontSize);
  let selection;
  let type;
  if (window.getSelection) {
    selection = getSelection();
  }
  if (!selection) {
    return;
  }
  let range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
  try {
    let child = range.commonAncestorContainer;
    for (let i = 0; i < 10; i++) {
      if (child.nodeName === 'UL') {
        child.style['list-style'] = 'disc';
        break;
      }
      if (child.parentNode) {
        child = child.parentNode;
      }
    }
  } catch (err) {
    console.error(err);
  }
};

RICH_EDITOR.setSquare = function () {
  let listStyle = RICH_EDITOR.getListStyle();
  if (listStyle === 'square') {
    return;
  }
  let fontSize = document.queryCommandValue('fontSize');
  document.execCommand('insertUnorderedList', false, null);
  document.execCommand('fontSize', false, fontSize);
  let selection;
  let type;
  if (window.getSelection) {
    selection = getSelection();
  }
  if (!selection) {
    return;
  }
  let range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
  try {
    let child = range.commonAncestorContainer;
    for (let i = 0; i < 10; i++) {
      if (child.nodeName === 'UL') {
        child.style['list-style'] = 'square';
        break;
      }
      if (child.parentNode) {
        child = child.parentNode;
      }
    }
  } catch (err) {
    console.error(err);
  }
};

RICH_EDITOR.setTextColor = function (color) {
  document.execCommand('foreColor', false, color);
};

RICH_EDITOR.setFontSize = function (fontSize) {
  document.execCommand('fontSize', false, fontSize);
};

RICH_EDITOR.execFontSize = function (size, unit) {
  if (size === '12') {
    document.execCommand('fontSize', false, 3);
  } else if (size === '16') {
    document.execCommand('fontSize', false, 4);
  } else if (size === '20') {
    document.execCommand('fontSize', false, 5);
  } else if (size === '24') {
    document.execCommand('fontSize', false, 6);
  } else if (size === '28') {
    document.execCommand('fontSize', false, 7);
  }
};

let pad = 24;
RICH_EDITOR.setIndent = function () {
  let parents = document.getElementById('editorjs_box');
  parents.removeAttribute('padding-left');
  if (pad >= 408) {
    return;
  }
  pad = pad + 24;
  parents.style.paddingLeft = pad + 'px';
  if (!storage) {
    return;
  }
  storage.setItem('paddingLeft', pad);
};

RICH_EDITOR.setOutdent = function () {
  let parents = document.getElementById('editorjs_box');
  parents.removeAttribute('padding-left');
  if (pad === 24) {
    parents.style.paddingLeft = 24 + 'px';
    if (!storage) {
      return;
    }
    storage.setItem('paddingLeft', pad);
  } else {
    pad = pad - 24;
    parents.style.paddingLeft = pad + 'px';
    if (!storage) {
      return;
    }
    storage.setItem('paddingLeft', pad);
  }
};

RICH_EDITOR.setJustifyLeft = function () {
  document.execCommand('justifyLeft', false, null);
};

RICH_EDITOR.setJustifyCenter = function () {
  document.execCommand('justifyCenter', false, null);
};

RICH_EDITOR.setJustifyRight = function () {
  document.execCommand('justifyRight', false, null);
};

RICH_EDITOR.insertImage = function (url) {
  let html = '<br></br><img src="' + url +
    '" alt="picvision" style="margin:0px auto;width:90%;display:table-cell;' +
    'vertical-align:middle;border-radius:10px;max-width:90%" /><br></br>';
  document.getElementById('editorjs_box').innerHTML += html;
  document.getElementById('editorjs_box').scrollIntoView(false);
};

RICH_EDITOR.insertHTML = function (html) {
  document.execCommand('insertHTML', false, html);
};

RICH_EDITOR.setDone = function () {
  let html = '<input type="checkbox" checked="checked"/> &nbsp;';
  document.execCommand('insertHTML', false, html);
};

RICH_EDITOR.addTodo = function (e) {
  let KEY_ENTER;
  KEY_ENTER = 13;
  if (e.which === KEY_ENTER) {
    let node = RICH_EDITOR.getSelectedAnchorNode();
    if (node && node.nodeName === '#text') {
      node = node.parentElement;
    }
    if (node && node.nodeName === 'SPAN' && node.previousElementSibling &&
      node.previousElementSibling.className === 'note-checkbox') {
      RICH_EDITOR.setTodo();
      e.preventDefault();
    }
  }
};

RICH_EDITOR.setTodo = function () {
  let parent = document.getElementById('editorjs_box');
  let isContentEmpty = parent.innerHTML.trim().length === 0 || parent.innerHTML === '<br>';
  let html = (isContentEmpty ? '' : '<br/>') +
    '<span>&nbsp;</span>' +
    '<input name="checkbox" type="checkbox" onclick="onCheckChange(this)" class="note-checkbox">' +
    '<span class="note-checkbox-txt">&nbsp;</span>';
  document.execCommand('insertHTML', false, html);
};

function onCheckChange(checkbox) {
  if (checkbox.checked === true) {
    checkbox.setAttribute('checked', 'checked');
  } else {
    checkbox.removeAttribute('checked');
  }
}

RICH_EDITOR.restorerange = function () {
  let selection = window.getSelection();
  selection.removeAllRanges();
  let range = document.createRange();
  range.setStart(RICH_EDITOR.currentSelection.startContainer, RICH_EDITOR.currentSelection.startOffset);
  range.setEnd(RICH_EDITOR.currentSelection.endContainer, RICH_EDITOR.currentSelection.endOffset);
  selection.addRange(range);
};

// 获取光标开始位置归属节点

RICH_EDITOR.getSelectedAnchorNode = function () {
  let node;
  let selection;
  if (window.getSelection) {
    selection = getSelection();
    node = selection.anchorNode;
  }
  if (!node && document.selection) {
    selection = document.selection;
    let range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
    node = range.commonAncestorContainer ? range.commonAncestorContainer : range.parentElement
                                                                             ? range.parentElement() : range.item(0);
  }
  return node;
};

RICH_EDITOR.cancelSelection = function () {
  let selection = window.getSelection();
  selection.removeAllRanges();
};

let callBackToApp = window.callBackToApp;

function getHtmlContent() {
  console.log('getHtmlContent');
  let htmlString = RICH_EDITOR.getHtml();
  let imgName = getImagePathFromContent(htmlString);
  htmlString = window.btoa(unescape(encodeURIComponent(htmlString)));
  callBackToApp.callbackImagePath(imgName);
  let str = callBackToApp.callbackhtml(htmlString);
  console.log('getHtmlContent end');
}

function saveHtmlContent() {
  console.log('saveHtmlContent');
  let htmlString = RICH_EDITOR.getHtml();
  let imgName = getImagePathFromContent(htmlString);
  htmlString = window.btoa(unescape(encodeURIComponent(htmlString)));

  callBackToApp.callbackImagePath(imgName);
  let str = callBackToApp.callbackhtmlSave(htmlString);
  console.log('saveHtmlContent end');
}

function getImagePathFromContent(contentInfo) {
  let imgReg = /<img[^>]+>/g;
  let imgName = '';
  let srcReg = /src=[\'\"]?([^\'\"]*)[\'\"]?/i;
  let imgArray = contentInfo.match(imgReg);
  // 取第一张图片做为标题栏后的缩略图
  if (imgArray && imgArray.length > 0) {
    let src = imgArray[0].match(srcReg);
    if (src != null && src.length > 1) {
      imgName = src[1];
      if (imgName.indexOf('shuxue.png') >= 0 || imgName.indexOf('cake.png') >= 0) {
        imgName = '/res/' + imgName;
      }
    }
  }
  return imgName;
}

function scheduledSaveContent() {
  if (callBackToApp !== undefined) {
    console.info('scheduledSaveContent');
    let htmlString = RICH_EDITOR.getHtml();
    let imgName = getImagePathFromContent(htmlString);
    htmlString = window.btoa(unescape(encodeURIComponent(htmlString)));
    callBackToApp.callbackImagePath(imgName);
    let str = callBackToApp.callbackScheduledSave(htmlString);
    console.info('scheduledSaveContent end');
  }
}

document.body.addEventListener('paste', (event) => {
  let length = event.clipboardData.items.length;
  if (length > 0) {
    let file = event.clipboardData.items[0].getAsFile();
    const reader = new FileReader();
    reader.onloadend = () => {
      callBackToApp.callbackPasteImage(reader.result);
    };
    reader.readAsDataURL(file);
    event.preventDefault();
  }
});

RICH_EDITOR.getFontSizes = function () {
  document.execCommand('fontSize', false, null);
  let fontElements = window.getSelection().anchorNode.parentNode;
  let getSize = parseInt(window.getComputedStyle(fontElements, null).fontSize);
  let str = callBackToApp.callbackGetSize(getSize);
};

RICH_EDITOR.insertImageHtml = function (contents) {
  let selection = window.getSelection();
  if (!selection.rangeCount) {
    return false;
  }
  selection.deleteFromDocument();
  let img = document.createElement('img');
  img.src = contents;
  selection.getRangeAt(0).insertNode(img);
  return true;
};

document.addEventListener('click', (e) => {
  console.info(`lsq: e is ${JSON.stringify(e)}`);
  let parent = document.getElementById('editorjs_box');
  if (parent.id !== 'editorjs_box') {
    e.preventDefault();
  }
});

document.getElementById('addToDo').addEventListener('click', () => {
  callBackToApp.addToDo();
});

document.getElementById('chooseStyle').addEventListener('click', () => {
  callBackToApp.chooseStyle();
});

document.getElementById('openAlbum').addEventListener('click', () => {
  callBackToApp.openAlbum();
});

function changeSizeToRk() {
  document.getElementById('img1').style.width = '40px';
  document.getElementById('img1').style.height = '40px';
  document.getElementById('img2').style.width = '40px';
  document.getElementById('img2').style.height = '40px';
  document.getElementById('img3').style.width = '40px';
  document.getElementById('img3').style.height = '40px';
  document.getElementById('lable1').style.fontSize = '20px';
  document.getElementById('lable2').style.fontSize = '20px';
  document.getElementById('lable3').style.fontSize = '20px';
}

function changeSizeToPhone() {
  document.getElementById('img1').style.width = '24px';
  document.getElementById('img1').style.height = '24px';
  document.getElementById('img2').style.width = '24px';
  document.getElementById('img2').style.height = '24px';
  document.getElementById('img3').style.width = '24px';
  document.getElementById('img3').style.height = '24px';
  document.getElementById('lable1').style.fontSize = '12px';
  document.getElementById('lable2').style.fontSize = '12px';
  document.getElementById('lable3').style.fontSize = '12px';
}

function changeSizeToTablet() {
  document.getElementById('img1').style.width = '28px';
  document.getElementById('img1').style.height = '28px';
  document.getElementById('img2').style.width = '28px';
  document.getElementById('img2').style.height = '28px';
  document.getElementById('img3').style.width = '28px';
  document.getElementById('img3').style.height = '28px';
  document.getElementById('lable1').style.fontSize = '12px';
  document.getElementById('lable2').style.fontSize = '12px';
  document.getElementById('lable3').style.fontSize = '12px';
}

function hiddenButton() {
  document.getElementById('buttonBox').style.display = 'none';
}

RICH_EDITOR.getFocus = function () {
  return document.getElementById('editorjs_box').focus();
};

RICH_EDITOR.getBlur = function () {
  return document.getElementById('editorjs_box').blur();
};

document.getElementById('editorjs_box').addEventListener('click', () => {
  document.getElementById('buttonBox').style.display = 'flex';
});