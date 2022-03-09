/**
 * Copyright (C) 2017 Wasabeef
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

var RE = {};
var isInit = false
RE.currentSelection = {
    "startContainer": 0,
    "startOffset": 0,
    "endContainer": 0,
    "endOffset": 0
};

RE.editor = document.getElementById('editor');

function load() {
    addSelectionChange();
}

function addSelectionChange() {
    window.document.addEventListener("selectstart", onSelectionChanged, false);
    window.document.addEventListener("selectionchange", onSelectionChanged, false);
}

document.addEventListener("selectionchange", function() {
    if(!isInit&&(document.innerHTML == "undefined" || document.innerHTML == null || document.innerHTML == "")){
        isInit = true
        //初始化 java代码直接设置不行 必须在此时选中后
        console.log("初始化-默认style")
        document.execCommand("fontSize", false, 3);
        RE.fixFontSize()
    }else{
        RE.backuprange();
    }

  }
 );

// Initializations
RE.callback = function() {
    RE.setLiVal();
    if (window.inputCallBack && window.inputCallBack.call) {
        inputCallBack.call("callback://" + encodeURI(RE.getHtml()));
    }
}

RE.setHtml = function(contents) {
     RE.editor.innerHTML = decodeURIComponent(contents.replace(/\+/g, '%20'));
}


RE.getHtml = function() {
    return RE.editor.innerHTML;
}

RE.getText = function() {
    console.log(RE.editor.innerText);
    return RE.editor.innerText;
}

RE.setBaseTextColor = function(color) {
    RE.editor.style.color  = color;
}

RE.setBaseFontSize = function(size) {
    RE.editor.style.fontSize = size;
}

RE.setPadding = function(left, top, right, bottom) {
  RE.editor.style.paddingLeft = left;
  RE.editor.style.paddingTop = top;
  RE.editor.style.paddingRight = right;
  RE.editor.style.paddingBottom = bottom;
}

RE.setBackgroundColor = function(color) {
    document.body.style.backgroundColor = color;
}

RE.setBackgroundImage = function(image) {
    RE.editor.style.backgroundImage = image;
}

RE.setWidth = function(size) {
    RE.editor.style.minWidth = size;
}

RE.setHeight = function(size) {
    RE.editor.style.height = size;
}

RE.setTextAlign = function(align) {
    RE.editor.style.textAlign = align;
}

RE.setVerticalAlign = function(align) {
    RE.editor.style.verticalAlign = align;
}

RE.setPlaceholder = function(placeholder) {
    RE.editor.setAttribute("placeholder", placeholder);
}

RE.setInputEnabled = function(inputEnabled) {
    RE.editor.contentEditable = String(inputEnabled);
}

RE.undo = function() {
    document.execCommand('undo', false, null);
}

RE.redo = function() {
    document.execCommand('redo', false, null);
}

RE.setBold = function() {
    document.execCommand('bold');
}

RE.setItalic = function() {
    document.execCommand('italic', false, null);
}

RE.setSubscript = function() {
    document.execCommand('subscript', false, null);
}

RE.setSuperscript = function() {
    document.execCommand('superscript', false, null);
}

RE.setStrikeThrough = function() {
    document.execCommand('strikeThrough', false, null);
}

RE.setUnderline = function() {
    document.execCommand('underline', false, null);
}

RE.setNumbers = function () {
    document.execCommand('insertOrderedList', false, null);
    var selection, type;
    if (window.getSelection) {
        selection = getSelection();
    }
    if (selection) {
        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        try {
            var child = range.commonAncestorContainer.parentNode;
            for (var i = 0; i < 10; i++) {
                if (child.nodeName == "OL") {
                    child.style["list-style"] = "decimal";
                    break;
                }
                if (child.parentNode) {
                    child = child.parentNode
                }
            }
        } catch (err) {

        }
    }
}

RE.setABC = function () {
    document.execCommand('insertOrderedList', false, null);
    var selection, type;
    if (window.getSelection) {
        selection = getSelection();
    }
    if (selection) {
        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        try {
            var child = range.commonAncestorContainer.parentNode;
            for (var i = 0; i < 10; i++) {
                if (child.nodeName == "OL") {
                    child.style["list-style"] = "lower-alpha";
                    break;
                }
                if (child.parentNode) {
                    child = child.parentNode
                }
            }
        } catch (err) {

        }
    }
}

RE.setBullets = function () {
    document.execCommand('insertUnorderedList', false, null);
    var selection, type;
    if (window.getSelection) {
        selection = getSelection();
    }
    if (selection) {
        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        try {
            var child = range.commonAncestorContainer.parentNode;
            for (var i = 0; i < 10; i++) {
                if (child.nodeName == "UL") {
                    child.style["list-style"] = "disc";
                    break;
                }
                if (child.parentNode) {
                    child = child.parentNode
                }
            }
        } catch (err) {

        }
    }
}

RE.setSquare = function () {
    document.execCommand('insertUnorderedList', false, null);
    var selection, type;
    if (window.getSelection) {
        selection = getSelection();
    }
    if (selection) {
        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        try {
            var child = range.commonAncestorContainer.parentNode;
            for (var i = 0; i < 10; i++) {
                if (child.nodeName == "UL") {
                    child.style["list-style"] = "square";
                    break;
                }
                if (child.parentNode) {
                    child = child.parentNode
                }
            }
        } catch (err) {

        }
    }
}

RE.setTextColor = function (color) {
    document.execCommand('foreColor', false, color);
}

RE.setTextBackgroundColor = function(color) {
    RE.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand("styleWithCSS", null, false);
}

RE.setFontSize = function(fontSize){
    document.execCommand("fontSize", false, fontSize);
}

RE.execFontSize = function (size, unit) {
    document.execCommand("fontSize", false, "7");
    var fontElements = window.getSelection().anchorNode.parentNode
    fontElements.removeAttribute("size");
    fontElements.style.fontSize = size + 'px'
};


RE.setHeading = function(heading) {
    document.execCommand('formatBlock', false, '<h'+heading+'>');
}

RE.setIndent = function() {
    document.execCommand('indent', false, null);
}

RE.setOutdent = function() {
    document.execCommand('outdent', false, null);
}

RE.setJustifyLeft = function() {
    document.execCommand('justifyLeft', false, null);
}

RE.setJustifyCenter = function() {
    document.execCommand('justifyCenter', false, null);
}

RE.setJustifyRight = function() {
    document.execCommand('justifyRight', false, null);
}

RE.setBlockquote = function() {
    document.execCommand('formatBlock', false, '<blockquote>');
}

//RE.insertImage = function(url) {
//    var html = '<br></br><img src="' + url + '" alt="picvision" style="margin:0px auto;width:90%;display:table-cell;vertical-align:middle;border-radius:10px;max-width:90%" /><br></br>';
//    RE.insertHTML(html);
//    RE.editor.scrollIntoView(false)
//}

RE.insertImage = function() {
    var url = './baidu.png';
    var html = '<br></br><img src="' + url + '" alt="picvision" style="margin:0px auto;width:90%;display:table-cell;vertical-align:middle;border-radius:10px;max-width:90%" /><br></br>';
    RE.insertHTML(html);
    RE.editor.scrollIntoView(false)
}
//&nbsp; 让其可以继续进去编辑模式
RE.insertVideo = function(url,custom,posterUrl) {
     var html = '&nbsp;<video controls="controls" poster="' +posterUrl+ '" src="' + url + '" ' + custom +'></video>&nbsp;<br></br>';
     RE.insertHTML(html);
     RE.editor.scrollIntoView(false)
 }

RE.insertAudio = function(url,custom) {
    var html = '&nbsp;<audio src="' + url + '" ' + custom +'></audio>&nbsp;<br></br>';
    RE.insertHTML(html);
    RE.editor.scrollIntoView(false)
}

RE.insertHTML = function(html) {
    RE.restorerange();
    document.execCommand('insertHTML', false, html);
}

RE.insertLink = function(url, title) {
    RE.restorerange();
    var sel = document.getSelection();
    if (sel.toString().length == 0) {
        document.execCommand("insertHTML",false,"<a href='"+url+"'>"+title+"</a>");
    } else if (sel.rangeCount) {
       var el = document.createElement("a");
       el.setAttribute("href", url);
       el.setAttribute("title", title);

       var range = sel.getRangeAt(0).cloneRange();
       range.surroundContents(el);
       sel.removeAllRanges();
       sel.addRange(range);
   }
    RE.callback();
}

RE.setDone = function() {
    var html = '<input type="checkbox" checked="checked"/> &nbsp;';
    document.execCommand('insertHTML', false, html);
}

RE.addTodo=function(e){
    KEY_ENTER=13;
    if(e.which == KEY_ENTER){
        var node=RE.getSelectedAnchorNode();
        if(node&&node.nodeName=="#text"){
            node=node.parentElement;
        }
        if(node&&node.nodeName=="SPAN"&&node.previousElementSibling&&node.previousElementSibling.className=='note-checkbox'){
            RE.setTodo();
            e.preventDefault();
        }
    }
}

RE.setTodo = function () {
    var parent = document.getElementById('editor')
    var isContentEmpty = parent.innerHTML.trim().length == 0 || parent.innerHTML == '<br>';
    var html = (isContentEmpty ? '' : '<br/>') + '<input name="checkbox" type="checkbox" onclick="onCheckChange(this)" class="note-checkbox"><span class="note-checkbox-txt">&nbsp;</span>';
    document.execCommand('insertHTML', false, html);
}

function onCheckChange(checkbox) {
    if (checkbox.checked == true) {
        checkbox.setAttribute("checked", "checked");
    } else {
        checkbox.removeAttribute("checked");
    }
}

RE.prepareInsert = function() {
    RE.backuprange();
}

RE.backuprange = function(){
    console.log("backuprange");
    var selection = window.getSelection();
    if (selection.rangeCount > 0) {
      var range = selection.getRangeAt(0);
      RE.currentSelection = {
          "startContainer": range.startContainer,
          "startOffset": range.startOffset,
          "endContainer": range.endContainer,
          "endOffset": range.endOffset};
    }
}

RE.restorerange = function(){
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(RE.currentSelection.startContainer, RE.currentSelection.startOffset);
    range.setEnd(RE.currentSelection.endContainer, RE.currentSelection.endOffset);
    selection.addRange(range);
}

RE.enabledEditingItems = function(e) {

    var items = [];
    if (document.queryCommandState('bold')) {
        items.push('bold');
    }
    if (document.queryCommandState('italic')) {
        items.push('italic');
    }
    if (document.queryCommandState('subscript')) {
        items.push('subscript');
    }
    if (document.queryCommandState('superscript')) {
        items.push('superscript');
    }
    if (document.queryCommandState('strikeThrough')) {
        items.push('strikeThrough');
    }
    if (document.queryCommandState('underline')) {
        items.push('underline');
    }
    if (document.queryCommandState('insertOrderedList')) {
        items.push('orderedList');
    }
    if (document.queryCommandState('insertUnorderedList')) {
        items.push('unorderedList');
    }
    if (document.queryCommandState('justifyCenter')) {
        items.push('justifyCenter');
    }
    if (document.queryCommandState('justifyFull')) {
        items.push('justifyFull');
    }
    if (document.queryCommandState('justifyLeft')) {
        items.push('justifyLeft');
    }
    if (document.queryCommandState('justifyRight')) {
        items.push('justifyRight');
    }
    if (document.queryCommandState('insertHorizontalRule')) {
        items.push('horizontalRule');
    }
    var formatBlock = document.queryCommandValue('formatBlock');
    if (formatBlock.length > 0) {
        items.push(formatBlock);
    }
    console.log("HwNotePad items:" + items)
    window.location.href = "re-state://" + encodeURI(items.join(','));
}

RE.focus = function() {
    var range = document.createRange();
    range.selectNodeContents(RE.editor);
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    RE.editor.focus();
}

RE.blurFocus = function() {
    RE.editor.blur();
}

RE.removeFormat = function() {
    document.execCommand('removeFormat', false, null);
}

// Event Listeners
RE.editor.addEventListener("input", RE.callback);




RE.editor.addEventListener("keydown", function(e) {
    RE.addTodo(e);
});
RE.editor.addEventListener("keyup", function(e) {
    var KEY_LEFT = 37, KEY_RIGHT = 39;
    if (e.which == KEY_LEFT || e.which == KEY_RIGHT) {
        RE.enabledEditingItems(e);
    }
});
//RE.editor.addEventListener("click", RE.enabledEditingItems);

RE.fixFontSize = function(){
    var font = document.querySelectorAll('font')
    if(!font){
    return
    }
 font.forEach(function(item) {

 if (item.getAttribute('size') == '1') {
     item.style.fontSize='12px';
     console.log("fixFontSize 12px");
 } else if (item.getAttribute('size') == '2') {
     item.style.fontSize='14px';
    console.log("fixFontSize 14px");
 } else  if (item.getAttribute('size') == '3') {
      item.style.fontSize='16px';
      console.log("fixFontSize 16px");
 } else if (item.getAttribute('size') == '4') {
      item.style.fontSize='18px';
      console.log("fixFontSize 18px");
 } else if (item.getAttribute('size') == '5') {
     item.style.fontSize='20px';
     console.log("fixFontSize 20px");
 } else if (item.getAttribute('size') == '6') {
     item.style.fontSize='22px';
     console.log("fixFontSize 22px");
 }  else {
    console.log("fixFontSize null");
 }
 item.removeAttribute("size")
 console.log("fixFontSize End");

});
}

RE.removeFormat = function() {
    document.execCommand('removeFormat', false, null);
}


//获取当前光标所在内包含的所有样式
RE.getSelectedNode = function() {
    var node,selection;
    if (window.getSelection) {
        selection = getSelection();
        node = selection.anchorNode;
    }
    if (!node && document.selection) {
        selection = document.selection
        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        node = range.commonAncestorContainer ? range.commonAncestorContainer :
        range.parentElement ? range.parentElement() : range.item(0);
    }
    if (node) {
        var item =  (node.nodeName == "#text" ? node.parentNode : node);
         console.log("innerHTML:"+item.innerHTML);
         console.log("font-size:"+item.style["font-size"]);
         console.log("color:"+item.getAttribute("color"));
         console.log("queryCommandState1 bold:"+document.queryCommandState('bold'));

         console.log("src:"+item.getAttribute("src"));
         console.log(item.style["font-size"]+"|"+item.getAttribute("color")+"|"+document.queryCommandState('bold'))

    }
}

//获取光标开始位置归属节点
RE.getSelectedAnchorNode=function(){
    var node,selection;
    if (window.getSelection) {
        selection = getSelection();
        node = selection.anchorNode;
    }
    if (!node && document.selection) {
        selection = document.selection
        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        node = range.commonAncestorContainer ? range.commonAncestorContainer :
                range.parentElement ? range.parentElement() : range.item(0);
    }
    return node;
}

function getHtmlCallToApp() {
    if (window.getHtmlByJs && window.getHtmlByJs.call) {
        getHtmlByJs.call("callback://" + encodeURI(RE.getHtml()));
    }
}

RE.setLiVal=function(){
    var liArr=RE.editor.getElementsByTagName("li");
    var type="1";
    var val=1;
    var len=liArr.length;
    for(var i=0;i<len;i++){
        if(liArr[i].previousElementSibling&&type==liArr[i].getAttribute("type")&&i>0){
            val=val+1;
        }
        else{
            type=liArr[i].getAttribute("type");
            val=1;
        }
        liArr[i].setAttribute("value",val);
    }
}

RE.insertLine = function() {
    var html = '<hr style="color:#F2F2F2"><p class="add"><br></p>';
    RE.insertHTML(html);
 }

function show_alert() {
    alert('this is alert dialog!');
}


function change_test1() {
    var test = document.getElementById('test');
    //alert(test.innerText);
    test.innerText = '新的测试'
    // test.style.fontSize = '30px'
    RE.setBold()
}

function change_test2() {
    RE.setItalic()
}
function change_test3() {
    RE.setBullets()
}
function change_test4() {
    RE.setJustifyCenter()
}

function get_html_content() {
    console.log('hhh Ark WebComponent');
    //str=objName.test("from Html", "6cxfd", 123);
    var htmlString =  encodeURI(RE.getHtml())
    var str = callBackToApp.callbackhtml(htmlString)
    console.log('hhh objName.test result:' + str);
}


