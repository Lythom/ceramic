package ceramic;

/** A map that uses int as keys and booleans as values. */
abstract IntBoolMap(IntIntMap) {

    public var size(get,never):Int;
    inline public function get_size():Int return this.size;

    public var iterableKeys(get,never):Array<Int>;
    inline function get_iterableKeys():Array<Int> return this.iterableKeys;

    inline public function new(size:Int = 16, fillFactor:Float = 0.5, iterable:Bool = false) {
        this = new IntIntMap(size, fillFactor, iterable);
    }

    inline public function exists(key:Int):Bool {
        return this.exists(key);
    }

    inline public function get(key:Int):Bool {
        return this.get(key) != 0;
    }

    inline public function set(key:Int, value:Bool):Void {
        this.set(key, value ? 1 : 0);
    }

    inline public function remove(key:Int):Bool {
        return this.remove(key) != 0;
    }

} //IntBoolMap