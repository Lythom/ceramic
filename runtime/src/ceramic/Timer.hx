package ceramic;

using ceramic.Extensions;

class Timer {

    static var callbacks:Array<TimerCallback> = [];
    static var next:Float = 999999999;

    /** Current time, relative to app.
        (number of active seconds since app was started) */
    public static var now(default,null):Float = 0;

    /** Current unix time synchronized with ceramic Timer.
        `Timer.now` and `Timer.timestamp` are garanteed to get incremented
        exactly at the same rate.
        (number of seconds since January 1st, 1970) **/
    public static var timestamp(get,null):Float;
    inline static function get_timestamp():Float {
        return startTimestamp + now;
    }

    public static var startTimestamp(default,null):Float = Date.now().getTime() / 1000.0;

    @:allow(ceramic.App)
    static function update(delta:Float):Void {

        now += delta;
        timestamp += delta;

        if (next <= now) {

            next = 999999999;
            var prevCallbacks = callbacks;
            callbacks = [];

            for (i in 0...prevCallbacks.length) {
                var callback = prevCallbacks.unsafeGet(i);

                if (!callback.cleared) {
                    if (callback.time <= now) {
                        if (callback.interval >= 0) {
                            while (callback.time <= now && !callback.cleared) {
                                callback.callback();
                                if (callback.interval == 0) break;
                                callback.time += callback.interval;
                            }
                            if (!callback.cleared) {
                                callbacks.push(callback);
                                next = Math.min(callback.time, next);
                            }
                        }
                        else {
                            callback.callback();
                        }
                    }
                    else {
                        callbacks.push(callback);
                        next = Math.min(callback.time, next);
                    }
                }
            }
        }

    } //update

// Public API

    /** Execute a callback after the given delay in seconds.
        @return a function to cancel this timer delay */
    inline public static function delay(#if ceramic_optional_owner ?owner:Entity #else owner:Entity #end, seconds:Float, callback:Void->Void):Void->Void {

        return schedule(owner, seconds, callback, -1);

    } //delay

    /** Execute a callback periodically at the given interval in seconds.
        @return a function to cancel this timer interval */
    inline public static function interval(#if ceramic_optional_owner ?owner:Entity #else owner:Entity #end, seconds:Float, callback:Void->Void):Void->Void {
        
        return schedule(owner, seconds, callback, seconds);

    } //interval

    private static function schedule(owner:Entity, seconds:Float, callback:Void->Void, interval:Float):Void->Void {

        var time = now + seconds;
        next = Math.min(time, next);

        var timerCallback = new TimerCallback();

        var clearScheduled:Void->Void = null;
        clearScheduled = function() {
            timerCallback.cleared = true;
        };

        var scheduled:Void->Void = null;
        scheduled = function() {
            if (timerCallback.cleared) {
                return;
            }
            if (owner != null && owner.destroyed) {
                timerCallback.cleared = true;
                return;
            }
            callback();
        }

        timerCallback.callback = scheduled;
        timerCallback.time = time;
        timerCallback.interval = interval;

        callbacks.push(timerCallback);

        return clearScheduled;

    } //schedule

} //Timer

class TimerCallback {

    public var callback:Void->Void = null;
    public var time:Float = 0;
    public var interval:Float = -1;
    public var cleared:Bool = false;

    public function new() {}

} //TimerCallback
