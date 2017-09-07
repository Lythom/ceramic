package ceramic;

@:enum abstract MeshColorMapping(Int) {
    /** Map a single color to the whole mesh. */
    var MESH = 0;
    /** Map a color to each indice. */
    var INDICES = 1;
    /** Map a color to each vertex. */
    var VERTICES = 2;
}

/** Draw anything composed of triangles/vertices. */
class Mesh extends Visual {

/// Settings

    public var colorMapping:MeshColorMapping = MESH;

/// Vertices

    /** An array of floats where each pair of numbers is treated as a coordinate location (x,y) */
    public var vertices:Array<Float> = [];

    /** An array of integers or indexes, where every three indexes define a triangle. */
    public var indices:Array<Int> = [];

    /** An array of colors for each vertex. */
    public var colors:Array<AlphaColor> = [];

/// Texture

    /** The texture used on the mesh (optional) */
    public var texture(default,set):Texture = null;
    inline function set_texture(texture:Texture):Texture {
        if (this.texture == texture) return texture;

        // Unbind previous texture destroy event
        if (this.texture != null) {
            this.texture.offDestroy(textureDestroyed);
        }

        this.texture = texture;

        // Update frame
        if (texture != null) {
            // Ensure we remove the texture if it gets destroyed
            texture.onDestroy(this, textureDestroyed);
        }

        return texture;
    }

    /** An array of normalized coordinates used to apply texture mapping.
        Required if the texture is set. */
    public var uvs:Array<Float> = [];

/// Texture destroyed

    function textureDestroyed() {

        // Remove texture because it has been destroyed
        this.texture = null;

    } //textureDestroyed

} //Mesh
