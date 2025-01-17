package ceramic;

import ceramic.Assets;
import ceramic.ConvertField;

import ceramic.SpinePlugin;
using ceramic.SpinePlugin;

class ConvertSpineData implements ConvertField<String,SpineData> {

    public function new() {}

    public function basicToField(assets:Assets, basic:String, done:SpineData->Void):Void {

        if (basic != null) {
            assets.ensureSpine(basic, null, function(asset:SpineAsset) {
                done(asset != null ? asset.spineData : null);
            });
        }
        else {
            done(null);
        }

    } //basicToField

    public function fieldToBasic(value:SpineData):String {

        return (value == null || value.asset == null) ? null : value.asset.name;

    } //fieldToBasic

} //ConvertSpineData
