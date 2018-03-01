package ceramic;

import ceramic.Shortcuts.*;

class Autorun extends Entity {

/// Current autorun

    public static var current:Autorun = null;

/// Events

    @event function reset();

/// Properties

    var onRun:Void->Void;

    var invalidated = false;

/// Lifecycle

    public function new(onRun:Void->Void) {

        this.onRun = onRun;

        // Run once to create initial binding and execute callback
        run();

    } //new

    public function run():Void {

        // Nothing to do if destroyed
        if (destroyed) return;

        // We are not invalidated anymore as we are resetting state
        invalidated = false;

        // Set current autorun to self
        var prevCurrent = current;
        current = this;

        // Unbind everything
        emitReset();

        // Run (and bind) again
        onRun();

        // Restore previous current autorun
        current = prevCurrent;

    } //run

    inline public function invalidate():Void {

        if (invalidated) return;
        invalidated = true;

        app.onceImmediate(run);

    } //invalidate

} //Autorun