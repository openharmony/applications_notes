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

var mNeedToUpdateToolbarState = false;

function command(name) {
    document.execCommand(name);
}

function setFontSize(value) {
    console.log("setFontSize() value : " + value);
    document.execCommand("fontSize", false, value);
}

/** Font size change feature */
function getFontSize() {
    var fontSize = document.queryCommandValue('fontSize');
    console.log("get current fontSize : " + fontSize);
    fontSize = getSupportedFontSize(fontSize);
    return fontSize;
}

function getSupportedFontSize(fontSize) {
    var result = 16;
    switch (parseInt(fontSize)) {
        case 1:
            result = 12;
            break;
        case 2:
            result = 14;
            break;
        case 3:
            result = 16;
            break;
        case 4:
            result = 18;
            break;
        case 5:
            result = 20;
            break;
        case 6:
            result = 22;
            break;
        default:
            break;
    }
    console.log("get supported fontSize : " + result);
    return result;
}

function setForeColor(value) {
    console.log("setForeColor() value : " + value);
    document.execCommand("foreColor", false, value);
}

function getFontColor() {
    var fontColor = document.queryCommandValue('foreColor');
    console.log("get current fontColor : " + fontColor);
    return fontColor;
}

function updateRichTextState() {
    var result = 0x0;
    var boldState = getCurrentBoldState();
    result |= boldState;

    var italicState = getCurrentItalicState();
    result |= italicState;

    var underlineState = getCurrentUnderlineState();
    result |= underlineState;

    var orderedListState = getCurrentOrderedListState();
    result |= orderedListState;

    var unorderedListState = getCurrentUnorderedListState();
    result |= unorderedListState;

    var alignLeftState = getCurrentAlignLeftState();
    result |= alignLeftState;

    var alignCenterState = getCurrentAlignCenterState();
    result |= alignCenterState;

    var alignRightState = getCurrentAlignRightState();
    result |= alignRightState;

    // font size
    var fontSize = getFontSize();

    // font color
    var foreColor = getFontColor();

    var undoState = getCurrentUndoState();
    result |= undoState;

    var redoState = getCurrentRedoState();
    result |= redoState;

    if (window.updateRichEditStateFinished && window.updateRichEditStateFinished.call) {
        updateRichEditStateFinished.call(result + "&" + fontSize + "&" + foreColor);
    }
}

function getCurrentUndoState() {
    var undoState = 0x0;
    var canUndo = document.queryCommandEnabled("undo");
    if (canUndo == true) {
        undoState |= 0x400;
    }
    return undoState;
}

function getCurrentRedoState() {
    var redoState = 0x0;
    var canRedo = document.queryCommandEnabled("redo");
    if (canRedo == true) {
        redoState |= 0x800;
    }
    return redoState;
}

function getCurrentAlignLeftState() {
    var alignLeftState = 0x0;
    var state = document.queryCommandState("justifyLeft");
    var indeterm = document.queryCommandIndeterm("justifyLeft");
    if (state == true) {
        alignLeftState |= 0x1000;
    } else if (state == false) {
        if (indeterm == true) {
            alignLeftState |= 0x2000;
        } else {
            alignLeftState |= 0x0;
        }
    } else if (state == null) {
        alignLeftState |= 0x0;
    }
    return alignLeftState;
}

function getCurrentAlignCenterState() {
    var alignCenterState = 0x0;
    var state = document.queryCommandState("justifyCenter");
    var indeterm = document.queryCommandIndeterm("justifyCenter");
    if (state == true) {
        alignCenterState |= 0x4000;
    } else if (state == false) {
        if (indeterm == true) {
            alignCenterState |= 0x8000;
        } else {
            alignCenterState |= 0x0;
        }
    } else if (state == null) {
        alignCenterState |= 0x0;
    }
    return alignCenterState;
}

function getCurrentAlignRightState() {
    var alignRightState = 0x0;
    var state = document.queryCommandState("justifyRight");
    var indeterm = document.queryCommandIndeterm("justifyRight");
    if (state == true) {
        alignRightState |= 0x10000;
    } else if (state == false) {
        if (indeterm == true) {
            alignRightState |= 0x20000;
        } else {
            alignRightState |= 0x0;
        }
    } else if (state == null) {
        alignRightState |= 0x0;
    }
    return alignRightState;
}

function getCurrentOrderedListState() {
    var orderedListState = 0x0;
    var state = document.queryCommandState("insertOrderedList");
    var indeterm = document.queryCommandIndeterm("insertOrderedList");

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
                    type = child.style["list-style"];
                    break;
                }
                if (child.parentNode) {
                    child = child.parentNode
                }
            }
        } catch (err) {

        }
    }
    if (state == true) {
        if (type == "lower-alpha") {
            orderedListState |= 0x40000;
        } else {
            orderedListState |= 0x40;
        }
    } else if (state == false) {
        if (indeterm == true) {
            orderedListState |= 0x80;
        } else {
            orderedListState |= 0x0;
        }
    } else if (state == null) {
        orderedListState |= 0x0;
    }
    return orderedListState;
}

function getCurrentUnorderedListState() {
    var unorderedListState = 0x0;
    var state = document.queryCommandState("insertUnorderedList");
    var indeterm = document.queryCommandIndeterm("insertUnorderedList");

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
                    type = child.style["list-style"];
                    break;
                }
                if (child.parentNode) {
                    child = child.parentNode
                }
            }
        } catch (err) {

        }
    }
    if (state == true) {
        if (type == "square") {
            unorderedListState |= 0x100000;
        } else {
            unorderedListState |= 0x100;
        }
    } else if (state == false) {
        if (indeterm == true) {
            unorderedListState |= 0x200;
        } else {
            unorderedListState |= 0x0;
        }
    } else if (state == null) {
        unorderedListState |= 0x0;
    }
    return unorderedListState;
}

function getCurrentUnderlineState() {
    var underlineState = 0x0;
    var state = document.queryCommandState("underline");
    var indeterm = document.queryCommandIndeterm("underline");
    if (state == true) {
        underlineState |= 0x10;
    } else if (state == false) {
        if (indeterm == true) {
            underlineState |= 0x20;
        } else {
            underlineState |= 0x0;
        }
    } else if (state == null) {
        underlineState |= 0x0;
    }
    return underlineState;
}

function getCurrentItalicState() {
    var italicState = 0x0;
    var state = document.queryCommandState("italic");
    var indeterm = document.queryCommandIndeterm("italic");
    if (state == true) {
        italicState |= 0x4;
    } else if (state == false) {
        if (indeterm == true) {
            italicState |= 0x8;
        } else {
            italicState |= 0x0;
        }
    } else if (state == null) {
        italicState |= 0x0;
    }
    return italicState;
}

function getCurrentBoldState() {
    var boldState = 0x0;
    var state = document.queryCommandState("bold");
    var indeterm = document.queryCommandIndeterm("bold");
    if (state == true) {
        boldState |= 0x1;
    } else if (state == false) {
        if (indeterm == true) {
            boldState |= 0x2;
        } else {
            boldState |= 0x0;
        }
    } else if (state == null) {
        boldState |= 0x0;
    }
    return boldState;
}

function onSelectionChanged(event) {
    switch (event.type) {
        case "selectstart":
            mNeedToUpdateToolbarState = true;
            break;
        case "selectionchange":
            {
                if (mNeedToUpdateToolbarState) {
                    updateRichTextState();
                }
            }
            break;
    }
}