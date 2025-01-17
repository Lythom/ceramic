package ceramic;

import ceramic.App;
import ceramic.Entity;
import ceramic.Assets;
import ceramic.AssetOptions;
import ceramic.AssetId;
import ceramic.Asset;
import ceramic.Either;

import ceramic.SpineAsset;
import ceramic.SpineData;
import ceramic.Spines;
import ceramic.ConvertSpineData;

import spine.Bone;

import ceramic.Shortcuts.*;

using StringTools;

@:access(ceramic.App)
class SpinePlugin {

/// Init plugin

    static function __init__():Void {

        // Calling a static method inside __init__ makes this snippet
        // compatible with haxe-modular or similar bundling tools
        SpinePlugin.pluginInit();

    } //__init__
    
    static function pluginInit() {

        App.oncePreInit(function() {

            log.info('Init spine plugin');

            // Generate spine asset ids
            var clazz = Type.resolveClass('ceramic.Spines');
            for (key in @:privateAccess Spines._ids.keys()) {
                var id = @:privateAccess Spines._ids.get(key);
                var info:Dynamic = Reflect.field(clazz, key);
                Reflect.setField(info, '_id', id);
            }

            // Extend assets with `spine` kind
            Assets.addAssetKind('spine', addSpine, ['spine'], true, ['ceramic.SpineData']);

            // Extend converters
            var convertSpineData = new ConvertSpineData();
            ceramic.App.app.converters.set('ceramic.SpineData', convertSpineData);

            // Load additional shaders required by spine
            ceramic.App.app.onceDefaultAssetsLoad(null, function(assets) {
                assets.add(ceramic.Shaders.TINT_BLACK, {
                    customAttributes: [
                        { size: 4, name: 'vertexDarkColor' }
                    ]
                });
            });
            
        });

    } //pluginInit

/// Asset extensions

    public static function addSpine(assets:Assets, name:String, ?options:AssetOptions):Void {

        if (name.startsWith('spine:')) name = name.substr(6);

        assets.addAsset(new SpineAsset(name, options));

    } //addSpine

    public static function ensureSpine(assets:Assets, name:Either<String,AssetId<Dynamic>>, ?options:AssetOptions, done:SpineAsset->Void):Void {

        var realName:String = Std.is(name, String) ? cast name : cast Reflect.field(name, '_id');
        if (!realName.startsWith('spine:')) realName = 'spine:' + realName;

        assets.ensure(cast realName, options, function(asset) {
            done(Std.is(asset, SpineAsset) ? cast asset : null);
        });

    } //ensureSpine

    @:access(ceramic.Assets)
    public static function spine(assets:Assets, name:Either<String,AssetId<Dynamic>>):SpineData {

        var realName:String = Std.is(name, String) ? cast name : cast Reflect.field(name, '_id');
        if (realName.startsWith('spine:')) realName = realName.substr(6);
        
        if (!assets.assetsByKindAndName.exists('spine')) return null;
        var asset:SpineAsset = cast assets.assetsByKindAndName.get('spine').get(realName);
        if (asset == null) return null;

        return asset.spineData;

    } //spine

    inline public static function toSkeletonName(name:AssetId<Dynamic>):String {

        return Reflect.field(name, '_id');

    } //spineSkeletonName

} //SpinePlugin
