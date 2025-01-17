package ceramic;

import haxe.rtti.Meta;
import ceramic.Assert.*;
import ceramic.Shortcuts.*;

using StringTools;

/** Utility to track a tree of entity objects and perform specific actions when some entities get untracked */
class TrackEntities extends Component {

/// Properties

    var entity:Entity;

    public var entityMap(default,null):Map<Entity,Bool> = new Map();

/// Lifecycle

    function init() {

        // Perform first scan to get initial data
        scan();

    } //init

/// Public API

    /** Compute the whole object tree to see which entities are in it.
        It will then be possible to compare the result with a previous scan and detect new and unused entities. */
    public function scan():Void {

        var prevEntityMap = entityMap;
        entityMap = new Map();

        scanValue(entity);

        cleanTrackingFromPrevEntityMap(prevEntityMap);

    } //scan

    function scanValue(value:Dynamic):Void {

        if (value == null) return;

        if (Std.is(value, Entity)) {
            var entity:Entity = cast value;
            if (entity.destroyed) return;

            if (entityMap.exists(entity)) {
                return; // Already tracked
            }

            // Add entity to map
            entityMap.set(entity, true);

            var clazz = Type.getClass(value);
            var fieldsMeta = Meta.getFields(clazz);

            // TODO scan entity fields in an efficient way

            return;

        }
        else if (Std.is(value, Array)) {

            var array:Array<Dynamic> = value;
            for (i in 0...array.length) {
                scanValue(array[i]);
            }

            return;

        }
        else if (Std.is(value, String) || Std.is(value, Int) || Std.is(value, Float) || Std.is(value, Bool)) {

            return;

        }
        else {

            // TODO handle maps and object literals?

        }

    } //scanEntity

    function cleanTrackingFromPrevEntityMap(prevEntityMap:Map<Entity,Bool>) {

        // TODO

    } //cleanTrackingFromPrevEntityMap

} //TrackEntities
