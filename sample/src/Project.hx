package;

import ceramic.Entity;
import ceramic.Quad;
import ceramic.Color;
import ceramic.Assets;
import ceramic.Blending;

class Project extends Entity {

    var assets:Assets = new Assets();

    function new() {

        app.settings.antialiasing = true;
        app.settings.background = 0x444444;
        app.settings.width = 320;
        app.settings.height = 568;
        app.settings.scaling = FILL;

        app.onceReady(this, ready);

    } //new

    function ready() {

        var quad1 = new Quad();
        quad1.color = Color.RED;
        quad1.depth = 2;
        quad1.size(50, 50);
        quad1.anchor(0.5, 0.5);
        quad1.pos(320 * 0.5, 568 * 0.5);
        quad1.rotation = 30;
        quad1.scale(2.0, 0.5);

        var quad2 = new Quad();
        quad2.depth = 1;
        quad2.color = Color.YELLOW;
        quad2.size(50, 50);
        quad2.anchor(0.5, 0.5);
        quad2.pos(320 * 0.5, 568 * 0.5 + 20);
        quad2.rotation = 30;
        quad2.scale(2.0, 0.5);

        /*
        // Just an idea
        var tween = new Tween(easeInOut, 0.3, 3, 4);
        tween.onUpdate(this, function(v) {
            this.alpha = v;
        });
        */

        screen.onUpdate(this, function(delta) {

            quad1.rotation = (quad1.rotation + delta * 100) % 360;
            quad2.rotation = (quad2.rotation + delta * 100) % 360;

        });

    } //ready

} //Project