package ceramic;

/** A bunch of static extensions to make life easier. */
class Extensions {

/// Array extensions

    inline public static function unsafeGet<T>(array:Array<T>, index:Int):T {
#if cpp
        return cpp.NativeArray.unsafeGet(array, index);
#else
        return array[index];
#end
    } //unsafeGet

    inline public static function unsafeSet<T>(array:Array<T>, index:Int, value:T):Void {
#if cpp
        cpp.NativeArray.unsafeSet(array, index, value);
#else
        array[index] = value;
#end
    } //unsafeSet

} //Extensions