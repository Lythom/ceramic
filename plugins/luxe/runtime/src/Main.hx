package;

import luxe.Input;

class Main extends luxe.Game {

    static var lastDevicePixelRatio:Float = -1;
    static var lastWidth:Float = -1;
    static var lastHeight:Float = -1;

    static var touches:Map<Int,Int> = new Map();
    static var touchIndexes:Map<Int,Int> = new Map();

    static var mouseDownButtons:Map<Int,Bool> = new Map();
    static var mouseX:Float = 0;
    static var mouseY:Float = 0;

    static var instance:Main;

    override function config(config:luxe.GameConfig) {

#if (!completion && !display)

        instance = this;
        var app = @:privateAccess new ceramic.App();

        // Configure luxe
        config.render.antialiasing = app.settings.antialiasing ? 4 : 0;
        config.window.borderless = false;
        if (app.settings.targetWidth > 0) config.window.width = cast app.settings.targetWidth;
        if (app.settings.targetHeight > 0) config.window.height = cast app.settings.targetHeight;
        config.window.resizable = app.settings.resizable;
        config.window.title = cast app.settings.title;

#if web
        if (app.settings.backend.webParent != null) {
            config.runtime.window_parent = app.settings.backend.webParent;
        }
        config.runtime.browser_window_mousemove = true;
        config.runtime.browser_window_mouseup = true;
        if (app.settings.backend.allowDefaultKeys) {
            config.runtime.prevent_default_keys = [];
        }
#end

#end

        return config;

    } //config

    override function ready():Void {

#if (!completion && !display)

        // Keep screen size and density value to trigger
        // resize events that might be skipped by the engine
        lastDevicePixelRatio = Luxe.screen.device_pixel_ratio;
        lastWidth = Luxe.screen.width;
        lastHeight = Luxe.screen.height;

        // Background color
        Luxe.renderer.clear_color.rgb(ceramic.App.app.settings.background);

        // Camera size
        Luxe.camera.size = new luxe.Vector(Luxe.screen.width * Luxe.screen.device_pixel_ratio, Luxe.screen.height * Luxe.screen.device_pixel_ratio);

        // Emit ready event
        ceramic.App.app.backend.emitReady();

#end

    } //ready

    override function update(delta:Float):Void {

#if (!completion && !display)

        // We may need to trigger resize explicitly as luxe/snow
        // doesn't seem to always detect it automatically.
        triggerResizeIfNeeded();

        // Update
        ceramic.App.app.backend.emitUpdate(delta);

#end

    } //update

    override function onwindowresized(event:luxe.Screen.WindowEvent) {
        
#if (!completion && !display)

        triggerResizeIfNeeded();

#end

    } //onwindowresized

#if (!completion && !display)

    override function onmousedown(event:MouseEvent) {

        if (mouseDownButtons.exists(event.button)) {
            onmouseup(event);
        }

        mouseX = event.x;
        mouseY = event.y;

        mouseDownButtons.set(event.button, true);
        ceramic.App.app.backend.screen.emitMouseDown(
            event.button,
            event.x,
            event.y
        );

    } //onmousedown

    override function onmouseup(event:MouseEvent) {

        if (!mouseDownButtons.exists(event.button)) {
            return;
        }

        mouseX = event.x;
        mouseY = event.y;

        mouseDownButtons.remove(event.button);
        ceramic.App.app.backend.screen.emitMouseUp(
            event.button,
            event.x,
            event.y
        );

    } //onmouseup

    override function onmousewheel(event:MouseEvent) {

        ceramic.App.app.backend.screen.emitMouseWheel(
            event.x,
            event.y
        );

    } //onmousewheel

    override function onmousemove(event:MouseEvent) {

        mouseX = event.x;
        mouseY = event.y;

        ceramic.App.app.backend.screen.emitMouseMove(
            event.x,
            event.y
        );

    } //onmousemove

    override function onkeydown(event:KeyEvent) {

        ceramic.App.app.backend.emitKeyDown({
            keyCode: event.keycode,
            scanCode: event.scancode
        });

    } //onkeydown

    override function onkeyup(event:KeyEvent) {

        ceramic.App.app.backend.emitKeyUp({
            keyCode: event.keycode,
            scanCode: event.scancode
        });

    } //onkeyup

// Don't handle touch on desktop, for now
#if !(mac || windows || linux)

    override function ontouchdown(event:TouchEvent) {

        var index = 0;
        while (touchIndexes.exists(index)) {
            index++;
        }
        touches.set(event.touch_id, index);
        touchIndexes.set(index, event.touch_id);

        ceramic.App.app.backend.screen.emitTouchDown(
            index,
            event.x,
            event.y
        );

    } //ontouchdown

    override function ontouchup(event:TouchEvent) {

        if (!touches.exists(event.touch_id)) {
            ontouchdown(event);
        }
        var index = touches.get(event.touch_id);

        ceramic.App.app.backend.screen.emitTouchUp(
            index,
            event.x,
            event.y
        );

        touches.remove(event.touch_id);
        touchIndexes.remove(index);

    } //ontouchup

    override function ontouchmove(event:TouchEvent) {

        if (!touches.exists(event.touch_id)) {
            ontouchdown(event);
        }
        var index = touches.get(event.touch_id);

        ceramic.App.app.backend.screen.emitTouchMove(
            index,
            event.x,
            event.y
        );

    } //ontouchmove

#end

#end

/// Internal

    function triggerResizeIfNeeded():Void {
        
#if (!completion && !display)

        // Ensure screen data has changed since last time we emit event
        if (   Luxe.screen.device_pixel_ratio == lastDevicePixelRatio
            && Luxe.screen.width == lastWidth
            && Luxe.screen.height == lastHeight) return;

        // Update values for next compare
        lastDevicePixelRatio = Luxe.screen.device_pixel_ratio;
        lastWidth = Luxe.screen.width;
        lastHeight = Luxe.screen.height;

        // Emit resize
        ceramic.App.app.backend.screen.emitResize();

        // Update camera size
        Luxe.camera.size = new luxe.Vector(Luxe.screen.width * Luxe.screen.device_pixel_ratio, Luxe.screen.height * Luxe.screen.device_pixel_ratio);

#end

    }

}