#version 150

#moj_import <fog.glsl>


in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform float GameTime;
uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
flat out vec4 baseColor;
out vec2 texCoord0;
out vec2 corner;
out vec4 screenPos;
flat out float isGui;
flat out float isShadow;

out vec3 ipos1;
out vec3 ipos2;
out vec3 ipos3;

out vec3 uvpos1;
out vec3 uvpos2;
out vec3 uvpos3;
out vec3 uvpos4;

#moj_import<text_effects.glsl>

bool shouldApplyTextEffects() { 
    uint vertexColorId = colorId(floor(round(textData.color.rgb * 255.0) / 4.0) / 255.0); 
    if(textData.isShadow) { vertexColorId = colorId(textData.color.rgb);} 
    switch(vertexColorId) { 
        case 16777215u:

#moj_import<text_effects_config.glsl>

        return true;
    } 
    return false; 
}


const vec2[] corners = vec2[](
    vec2(-1.0, +1.0), vec2(-1.0, -1.0), vec2(+1.0, -1.0), vec2(+1.0, +1.0)
);

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    corner = corners[gl_VertexID % 4];

    if(	Position.z == 0.0 && // check if the depth is correct (0 for gui texts)
			gl_Position.x >= 0.95 && gl_Position.y >= -0.35 && // check if the position matches the sidebar
			vertexColor.g == 84.0/255.0 && vertexColor.g == 84.0/255.0 && vertexColor.r == 252.0/255.0 && // check if the color is the sidebar red color
			gl_VertexID <= 4 // check if it's the first character of a string
		) gl_Position = ProjMat * ModelViewMat * vec4(ScreenSize + 100.0, 0.0, 0.0); // move the vertices offscreen, idk if this is a good solution for that but vec4(0.0) doesnt do the trick for everyone

    isShadow = fract(Position.z) < 0.01 ? 1.0 : 0.0;
    isGui = 1.0;//ModelViewMat[3][2] < -1500.0 ? 1.0 : 0.0;

    textData.isShadow = isShadow > 0.5;
    textData.color = Color;
    if(!shouldApplyTextEffects()) {
        isShadow = 0.0;
        if(Position.z == 0.0 && textData.isShadow) {
            textData.isShadow = false;
            if(shouldApplyTextEffects()) {
                isShadow = 0.0;
            }else {
                isGui = 0.0;
            }
        }else{
            isGui = 0.0;
        }
    }

    if(isGui > 0.5) {
        uvpos1 = uvpos2 = uvpos3 = uvpos4 = ipos1 = ipos2 = ipos3 = vec3(0.0);
        switch (gl_VertexID % 4) {
            case 0: ipos1 = vec3(gl_Position.xy, 1.0); uvpos1 = vec3(UV0.xy, 1.0); break;
            case 1: ipos2 = vec3(gl_Position.xy, 1.0); uvpos2 = vec3(UV0.xy, 1.0); break;
            case 2: ipos3 = vec3(gl_Position.xy, 1.0); uvpos3 = vec3(UV0.xy, 1.0); break;
            case 3: uvpos4 = vec3(UV0.xy, 1.0); break;
        }

        gl_Position.xy += corner * 0.2;
    }

    screenPos = gl_Position;
    baseColor = Color;

    
}
