package backend;

import phoenix.Texture;

abstract TextureId(phoenix.TextureID) from phoenix.TextureID to phoenix.TextureID {

    #if !debug inline #end public static var DEFAULT:TextureId = (#if snow_web null #else 0 #end : phoenix.TextureID);

} //TextureId
