package backend;

@:allow(Main)
@:allow(backend.Textures)
class Backend implements ceramic.Events #if !completion implements spec.Backend #end {

/// Public API

    public var info(default,null) = new backend.Info();

    public var audio(default,null) = new backend.Audio();

    public var draw(default,null) = new backend.Draw();

    public var texts(default,null) = new backend.Texts();

    public var textures(default,null) = new backend.Textures();

    public var shaders(default,null) = new backend.Shaders();

    public var screen(default,null) = new backend.Screen();

    public function new() {}

    public function init(app:ceramic.App) {

    } //init

/// Events

    @event function ready();

    @event function update(delta:Float);

    @event function keyDown(key:ceramic.Key);
    @event function keyUp(key:ceramic.Key);

/// Internal update logic

    inline function willEmitUpdate(delta:Float) {

        //

    } //willEmitUpdate

    inline function didEmitUpdate(delta:Float) {

        //

    } //didEmitUpdate

} //Backend