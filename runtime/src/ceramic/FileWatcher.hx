package ceramic;

#if (sys || hxnodejs || nodejs || node)
import sys.io.File;
import sys.FileSystem;
#end

/** A file watcher for ceramic compatible with `interpret.Watcher`. */
class FileWatcher extends Entity #if interpret implements interpret.Watcher #end {

    public static var UPDATE_INTERVAL:Float = 1.0;

    #if web
    static var testedElectronAvailability:Bool = false;
    static var electron:Dynamic = null;
    #end

    var watched:Map<String,WatchedFile> = new Map();

    var timeSinceLastCheck:Float = 0.0;

    public function new() {

        #if web
        if (!testedElectronAvailability) {
            testedElectronAvailability = true;
            try {
                electron = untyped __js__("require('electron')");
            }
            catch (e:Dynamic) {}
        }
        #end

        ceramic.App.app.onUpdate(this, tick);

    } //new

    public function canWatch():Bool {

        #if (!sys && !hxnodejs && !nodejs && !node)

        #if web
        if (electron == null) {
        #end
            return false;
        #if web
        }
        else {
            return true;
        }
        #end

        #else
        return true;
        #end

    } //canWatch

    public function watch(path:String, onUpdate:String->Void):Void->Void {

        if (!canWatch()) {
            trace('[warning] Cannot watch file at path $path with StandardWatcher on this target');
            return function() {};
        }

        var watchedFile = watched.get(path);
        if (watchedFile == null) {
            watchedFile = new WatchedFile();
            watched.set(path, watchedFile);
        }
        watchedFile.updateCallbacks.push(onUpdate);

        var stopped = false;
        var stopWatching = function() {
            if (stopped) return;
            stopped = true;
            var watchedFile = watched.get(path);
            watchedFile.updateCallbacks.remove(onUpdate);
            if (watchedFile.updateCallbacks.length == 0) {
                watched.remove(path);
            }
        };

        return stopWatching;

    } //watch

    override public function destroy() {

        ceramic.App.app.offUpdate(tick);

    } //destroy

/// Internal

    function tick(delta:Float) {

        if (destroyed) return;

        timeSinceLastCheck += delta;
        if (timeSinceLastCheck < UPDATE_INTERVAL) return;
        timeSinceLastCheck = 0.0;

        if (!canWatch()) return;

        for (path in watched.keys()) {
            if (isFile(path)) {
                var mtime = lastModified(path);
                var watchedFile = watched.get(path);
                if (watchedFile.mtime != -1 && mtime > watchedFile.mtime) {
                    // File modification time has changed
                    watchedFile.mtime = mtime;
                    var content = getContent(path);

                    if (content != watchedFile.content) {
                        watchedFile.content = content;
                        
                        // File content has changed, notify
                        for (i in 0...watchedFile.updateCallbacks.length) {
                            watchedFile.updateCallbacks[i](watchedFile.content);
                        }
                    }

                }
                else if (watchedFile.mtime == -1) {
                    // Fetch modification time and content to compare it later
                    watchedFile.mtime = mtime;
                    watchedFile.content = getContent(path);
                }
            }
            #if interpret_debug_watch
            else {
                trace('[warning] Cannot watch file because it does not exist or is not a file: $path');
            }
            #end
        }

    } //tick

    function isFile(path:String):Bool {

        #if (sys || hxnodejs || nodejs || node)
        return FileSystem.exists(path) && !FileSystem.isDirectory(path);
        #elseif web
        if (electron != null) {
            var fs = untyped __js__("{0}.remote.require('fs')", electron);
            return fs.existsSync(path);
        }
        else {
            return false;
        }
        #else
        return false;
        #end

    } //isFile

    function lastModified(path:String):Float {

        #if (sys || hxnodejs || nodejs || node)
        var stat = FileSystem.stat(path);
        if (stat == null) return -1;
        return stat.mtime.getTime();
        #elseif web
        if (electron != null) {
            var fs = untyped __js__("{0}.remote.require('fs')", electron);
            var stat = fs.statSync(path);
            if (stat == null) return -1;
            return stat.mtime.getTime();
        }
        else {
            return -1;
        }
        #else
        return -1;
        #end

    } //lastModified

    function getContent(path:String):String {

        #if (sys || hxnodejs || nodejs || node)
        return File.getContent(path);
        #elseif web
        if (electron != null) {
            var fs = untyped __js__("{0}.remote.require('fs')", electron);
            return fs.readFileSync(path, 'utf8');
        }
        else {
            return null;
        }
        #else
        return null;
        #end

    } //getContent

} //FileWatcher

@:allow(ceramic.FileWatcher)
private class WatchedFile {

    public var updateCallbacks:Array<String->Void> = [];

    public var mtime:Float = -1;

    public var content:String = null;

    public function new() {}

} //WatchedFile
