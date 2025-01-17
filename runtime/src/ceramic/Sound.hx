package ceramic;

import ceramic.Assets;
import ceramic.Shortcuts.*;

class Sound extends Entity {

    public var backendItem:backend.AudioResource;

    public var asset:SoundAsset;

/// Lifecycle

    public function new(backendItem:backend.AudioResource) {

        super();

        this.backendItem = backendItem;

    } //new

    override function destroy() {

        super.destroy();

        if (asset != null) asset.destroy();

        app.backend.audio.destroy(backendItem);
        backendItem = null;

    } //destroy

/// Public API

    /** Default volume when playing this sound. */
    public var volume:Float = 0.5;

    /** Default pan when playing this sound. */
    public var pan:Float = 0;

    /** Default pitch when playing this sound. */
    public var pitch:Float = 1;

    /** Play the sound at requested position. If volume/pan/pitch are not provided,
        sound instance properties will be used instead. */
    public function play(position:Float = 0, loop:Bool = false, ?volume:Float, ?pan:Float, ?pitch:Float):SoundPlayer {

        if (volume == null) volume = this.volume;
        if (pan == null) pan = this.pan;
        if (pitch == null) pitch = this.pitch;

        return cast app.backend.audio.play(backendItem, volume, pan, pitch, position, loop);

    } //play

} //Sound
