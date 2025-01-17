package ceramic;

import ceramic.Shortcuts.*;

using StringTools;

#if (haxe_ver < 4)
using unifill.Unifill;
#end

@:allow(ceramic.App)
class TextInput implements Events {

/// Events

    @event function _update(text:String);

    @event function _enter();

    @event function _escape();

    @event function _selection(selectionStart:Int, selectionEnd:Int);

    @event function _stop();

/// Properties

    var inputActive:Bool = false;

    var explicitPosInLine:Int = 0;

    var explicitPosLine:Int = 0;

    var shiftPressed:Bool = false;

    var invertedSelection:Bool = false;

    public var allowMovingCursor(default,null):Bool = false;

    public var multiline(default,null):Bool = false;

    public var text(default,set):String = '';

    public var selectionStart(default,null):Int = -1;

    public var selectionEnd(default,null):Int = -1;

    public var delegate(default,null):TextInputDelegate = null;

/// Lifecycle

    private function new() {

        //

    } //new

/// Public API

    public function start(
        text:String,
        x:Float, y:Float, w:Float, h:Float,
        multiline:Bool = false,
        selectionStart:Int = -1, selectionEnd:Int = -1,
        allowMovingCursor:Bool = false,
        delegate:TextInputDelegate = null
    ):Void {

        if (inputActive) stop();
        inputActive = true;

        this.text = text;
        this.multiline = multiline;
        this.allowMovingCursor = allowMovingCursor;
        this.delegate = delegate;

        explicitPosInLine = 0;
        explicitPosLine = 0;
        invertedSelection = false;
        
        #if (haxe_ver >= 4)
        if (selectionStart < 0) selectionStart = text.length;
        #else
        if (selectionStart < 0) selectionStart = text.uLength();
        #end
        if (selectionEnd < selectionStart) selectionEnd = selectionStart;
        this.selectionStart = selectionStart;
        this.selectionEnd = selectionEnd;

        app.backend.textInput.start(text, x, y, w, h);
        emitUpdate(text);
        emitSelection(selectionStart, selectionEnd);

    } //start

    public function stop():Void {

        if (!inputActive) return;
        inputActive = false;

        selectionStart = -1;
        selectionEnd = -1;
        invertedSelection = false;
        delegate = null;

        app.backend.textInput.stop();
        emitStop();

    } //stop

    public function updateSelection(selectionStart:Int, selectionEnd:Int, ?inverted:Bool):Void {

        if (this.selectionStart != selectionStart || this.selectionEnd != selectionEnd) {
            this.selectionStart = selectionStart;
            this.selectionEnd = selectionEnd;
            if (inverted != null) invertedSelection = inverted;
            emitSelection(selectionStart, selectionEnd);
        }

    } //updateSelection

    public function appendText(text:String):Void {

        // Clear selection and add text in place

        var newText = '';
        if (selectionStart > 0) {
            #if (haxe_ver >= 4)
            newText += this.text.substring(0, selectionStart);
            #else
            newText += this.text.uSubstring(0, selectionStart);
            #end
        }
        newText += text;
        #if (haxe_ver >= 4)
        newText += this.text.substring(selectionEnd);
        #else
        newText += this.text.uSubstring(selectionEnd);
        #end

        #if (haxe_ver >= 4)
        selectionStart += text.length;
        #else
        selectionStart += text.uLength();
        #end
        selectionEnd = selectionStart;
        invertedSelection = false;
        this.text = newText;

        emitUpdate(this.text);
        emitSelection(selectionStart, selectionEnd);
        
        explicitPosInLine = posInCurrentLine(selectionStart);
        explicitPosLine = lineForPos(selectionStart);

    } //appendText

    public function backspace():Void {

        // Clear selection and erase text in place

        var eraseSelection = selectionEnd > selectionStart;

        var newText = '';
        if (selectionStart > 1) {
            #if (haxe_ver >= 4)
            newText += this.text.substring(0, eraseSelection ? selectionStart : selectionStart - 1);
            #else
            newText += this.text.uSubstring(0, eraseSelection ? selectionStart : selectionStart - 1);
            #end
        }
        #if (haxe_ver >= 4)
        newText += this.text.substring(selectionEnd);
        #else
        newText += this.text.uSubstring(selectionEnd);
        #end

        if (selectionStart > 0 && !eraseSelection) selectionStart--;
        selectionEnd = selectionStart;
        this.text = newText;

        emitUpdate(text);
        emitSelection(selectionStart, selectionEnd);
        
        explicitPosInLine = posInCurrentLine(selectionStart);
        explicitPosLine = lineForPos(selectionStart);

    } //backspace

    public function moveLeft():Void {

        if (!allowMovingCursor) return;

        if (shiftPressed) {
            if (invertedSelection) {
                if (selectionStart > 0) {
                    selectionStart--;
                    emitSelection(selectionStart, selectionEnd);
                }

                explicitPosInLine = posInCurrentLine(selectionStart);
                explicitPosLine = lineForPos(selectionStart);
            }
            else if (selectionEnd > selectionStart) {
                selectionEnd--;
                emitSelection(selectionStart, selectionEnd);

                explicitPosInLine = posInCurrentLine(selectionEnd);
                explicitPosLine = lineForPos(selectionEnd);
            }
            else {
                if (selectionStart > 0) {
                    invertedSelection = true;
                    selectionStart--;
                    emitSelection(selectionStart, selectionEnd);
                }

                explicitPosInLine = posInCurrentLine(selectionStart);
                explicitPosLine = lineForPos(selectionStart);
            }
        }
        else {
            invertedSelection = false;

            if (selectionEnd > selectionStart) {
                // Some text is selected, just deselect and
                // put the cursor at the start of previous selection
                selectionEnd = selectionStart;
                emitSelection(selectionStart, selectionEnd);
            }
            else if (selectionStart > 0) {
                // Move the cursor by one character to the left
                selectionStart--;
                selectionEnd = selectionStart;
                emitSelection(selectionStart, selectionEnd);
            }

            explicitPosInLine = posInCurrentLine(selectionStart);
            explicitPosLine = lineForPos(selectionStart);
        }

    } //moveLeft

    public function moveRight():Void {

        if (!allowMovingCursor) return;

        if (shiftPressed) {
            #if (haxe_ver >= 4)
            var textLength = text.length;
            #else
            var textLength = text.uLength();
            #end

            if (selectionStart == selectionEnd) {
                invertedSelection = false;
                
                if (selectionEnd < textLength) {
                    selectionEnd++;
                    emitSelection(selectionStart, selectionEnd);
                }

                explicitPosInLine = posInCurrentLine(selectionEnd);
                explicitPosLine = lineForPos(selectionEnd);
            }
            else if (invertedSelection) {
                selectionStart++;
                emitSelection(selectionStart, selectionEnd);
                explicitPosInLine = posInCurrentLine(selectionStart);
                explicitPosLine = lineForPos(selectionStart);
            }
            else {
                if (selectionEnd < textLength) {
                    selectionEnd++;
                    emitSelection(selectionStart, selectionEnd);
                }

                explicitPosInLine = posInCurrentLine(selectionEnd);
                explicitPosLine = lineForPos(selectionEnd);
            }

        }
        else {
            invertedSelection = false;

            if (selectionEnd > selectionStart) {
                // Some text is selected, just deselect and
                // put the cursor at the end of previous selection
                selectionStart = selectionEnd;
                emitSelection(selectionStart, selectionEnd);
            }
            else if (selectionStart < #if (haxe_ver >= 4) text.length #else text.uLength() #end) {
                // Move the cursor by one character to the right
                selectionStart++;
                selectionEnd = selectionStart;
                emitSelection(selectionStart, selectionEnd);
            }

            explicitPosInLine = posInCurrentLine(selectionStart);
            explicitPosLine = lineForPos(selectionStart);
        }

    } //moveRight

    public function moveUp():Void {

        if (!allowMovingCursor) return;

        if (shiftPressed) {
            var startLine = lineForPos(selectionStart);
            var endLine = lineForPos(selectionEnd);
            if (!invertedSelection && endLine > startLine) {
                // Move the cursor by one line to the top
                var offset = explicitPosInLine;
                var currentLine = endLine;
                if (delegate != null) offset = delegate.textInputClosestPositionInLine(explicitPosInLine, explicitPosLine, currentLine - 1);
                var newPos = globalPosForLine(currentLine - 1, offset);
                selectionEnd = Std.int(Math.max(selectionStart, newPos));
                emitSelection(selectionStart, selectionEnd);
            }
            else if (selectionStart > 0) {
                invertedSelection = true;
                if (startLine > 0) {
                    // Move the cursor by one line to the top
                    var offset = explicitPosInLine;
                    var currentLine = startLine;
                    if (delegate != null) offset = delegate.textInputClosestPositionInLine(explicitPosInLine, explicitPosLine, currentLine - 1);
                    selectionStart = globalPosForLine(currentLine - 1, offset);
                }
                else {
                    selectionStart = 0;
                }
                emitSelection(selectionStart, selectionEnd);
            }
        }
        else {
            invertedSelection = false;

            if (selectionStart > 0) {
                var currentLine = lineForPos(selectionStart);
                if (currentLine > 0) {
                    // Move the cursor by one line to the top
                    var offset = explicitPosInLine;
                    if (delegate != null) offset = delegate.textInputClosestPositionInLine(explicitPosInLine, explicitPosLine, currentLine - 1);
                    selectionStart = globalPosForLine(currentLine - 1, offset);
                    selectionEnd = selectionStart;
                    emitSelection(selectionStart, selectionEnd);
                }
                else {
                    // Move the cursor to the beginning of the text
                    selectionStart = 0;
                    selectionEnd = 0;
                    emitSelection(selectionStart, selectionEnd);
                }
            }
            else {
                selectionStart = 0;
                selectionEnd = 0;
                emitSelection(selectionStart, selectionEnd);
            }
        }

    } //moveUp

    public function moveDown():Void {

        if (!allowMovingCursor) return;

        #if (haxe_ver >= 4)
        var textLength = text.length;
        #else
        var textLength = text.uLength();
        #end

        if (shiftPressed) {
            var startLine = lineForPos(selectionStart);
            var endLine = lineForPos(selectionEnd);
            if (!invertedSelection) {
                if (selectionEnd < textLength - 1) {
                    var offset = explicitPosInLine;
                    var currentLine = endLine;
                    var numLines = numLines();
                    if (currentLine < numLines - 1) {
                        // Move the cursor by one line to the bottom
                        if (delegate != null) offset = delegate.textInputClosestPositionInLine(explicitPosInLine, explicitPosLine, currentLine + 1);
                        selectionEnd = globalPosForLine(currentLine + 1, offset);
                    }
                    else {
                        selectionEnd = textLength;
                    }
                    emitSelection(selectionStart, selectionEnd);
                }
                else if (selectionEnd < textLength) {
                    selectionEnd = textLength;
                    emitSelection(selectionStart, selectionEnd);
                }
            }
            else if (invertedSelection) {
                if (endLine > startLine) {
                    var offset = explicitPosInLine;
                    var currentLine = startLine;
                    // Move the cursor by one line to the bottom
                    if (delegate != null) offset = delegate.textInputClosestPositionInLine(explicitPosInLine, explicitPosLine, currentLine + 1);
                    var newPos = globalPosForLine(currentLine + 1, offset);
                    selectionStart = Std.int(Math.min(selectionEnd, newPos));
                    emitSelection(selectionStart, selectionEnd);
                }
                else if (selectionEnd < textLength - 1) {
                    invertedSelection = false;
                    var currentLine = startLine;
                    var numLines = numLines();
                    var offset = explicitPosInLine;
                    if (currentLine < numLines - 1) {
                        // Move the cursor by one line to the bottom
                        if (delegate != null) offset = delegate.textInputClosestPositionInLine(explicitPosInLine, explicitPosLine, currentLine + 1);
                        selectionEnd = globalPosForLine(currentLine + 1, offset);
                    }
                    else {
                        selectionEnd = textLength;
                    }
                    emitSelection(selectionStart, selectionEnd);
                }
                else if (selectionEnd < textLength) {
                    invertedSelection = false;
                    selectionEnd = textLength;
                    emitSelection(selectionStart, selectionEnd);
                }
            }
        }
        else {
            invertedSelection = false;

            if (selectionEnd < textLength - 1) {
                var currentLine = lineForPos(selectionEnd);
                var numLines = numLines();
                if (currentLine < numLines - 1) {
                    // Move the cursor by one line to the bottom
                    var offset = explicitPosInLine;
                    if (delegate != null) offset = delegate.textInputClosestPositionInLine(explicitPosInLine, explicitPosLine, currentLine + 1);
                    selectionStart = globalPosForLine(currentLine + 1, offset);
                    selectionEnd = selectionStart;
                    emitSelection(selectionStart, selectionEnd);
                }
                else {
                    // Move the cursor to the end of the text
                    selectionStart = textLength;
                    selectionEnd = selectionStart;
                    emitSelection(selectionStart, selectionEnd);
                }
            }
            else {
                selectionStart = textLength;
                selectionEnd = selectionStart;
                emitSelection(selectionStart, selectionEnd);
            }
        }

    } //moveDown

    public function enter():Void {

        emitEnter();

        // In case input was stopped at `enter` event
        if (!inputActive) return;
        
        if (multiline) {
            appendText("\n");
        }

    } //enter

    public function escape():Void {

        emitEscape();
        stop();

    } //escape

    public function shiftDown():Void {

        shiftPressed = true;

    } //shiftDown

    public function shiftUp():Void {

        shiftPressed = false;

    } //shiftUp

/// Helpers

    /** Get the position in the current line, from the given global position in text */
    function posInCurrentLine(globalPos:Int):Int {

        if (delegate != null) return delegate.textInputPosInLineForIndex(globalPos);

        var text = this.text;

        var posInLine = 0;
        while (globalPos > 0) {
            #if (haxe_ver >= 4)
            var char = text.charAt(globalPos);
            #else
            var char = text.uCharAt(globalPos);
            #end
            if (char == "\n" && posInLine > 0) {
                posInLine--;
                break;
            }
            globalPos--;
            posInLine++;
        }

        return posInLine;

    } //posInLine

    /** Get the current line (starts from 0) from the given global position in text */
    function lineForPos(globalPos:Int):Int {

        if (delegate != null) return delegate.textInputLineForIndex(globalPos);

        var text = this.text;

        var lineNumber = 0;
        var i = 0;
        while (i < globalPos) {
            #if (haxe_ver >= 4)
            var char = text.charAt(i);
            #else
            var char = text.uCharAt(i);
            #end
            if (char == "\n") lineNumber++;
            i++;
        }

        return lineNumber;

    } //lineForPos

    function numLines():Int {

        if (delegate != null) return delegate.textInputNumberOfLines();

        return text.split("\n").length;

    } //numLines

    function globalPosForLine(lineNumber:Int, lineOffset:Int):Int {

        if (delegate != null) return delegate.textInputIndexForPosInLine(lineNumber, lineOffset);

        var text = this.text;
        var i = 0;
        #if (haxe_ver >= 4)
        var numChars = text.length;
        #else
        var numChars = text.uLength();
        #end
        var currentLine = 0;
        while (i < numChars) {
            #if (haxe_ver >= 4)
            var c = text.charAt(i);
            #else
            var c = text.uCharAt(i);
            #end
            if (currentLine == lineNumber) {
                if (lineOffset > 0) {
                    if (c == "\n") break;
                    lineOffset--;
                }
                else {
                    break;
                }
            }
            else if (c == "\n") {
                currentLine++;
            }
            i++;
        }

        return i;

    } //globalPosForLine

    function set_text(text:String):String {

        if (this.text == text) return text;
        this.text = text;

        #if (haxe_ver >= 4)
        var len = text.length;
        #else
        var len = text.uLength();
        #end

        var selectionStart = this.selectionStart;
        var selectionEnd = this.selectionEnd;

        if (selectionEnd > len) selectionEnd = len;
        if (selectionStart > selectionEnd) selectionStart = selectionEnd;
        updateSelection(selectionStart, selectionEnd);

        return text;

    } //set_text

} //TextInput
