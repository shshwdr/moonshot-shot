shader_type canvas_item;

uniform float changeColorRatio;
uniform bool upsideDown;
uniform float colorTense;

void fragment() {
	bool condition = UV.y<changeColorRatio;
	if (!upsideDown){
		condition = UV.y>changeColorRatio;
	}
	if (condition){
    	COLOR = texture(TEXTURE, UV);
		//COLOR.r = 1.0;
		COLOR.g *= 0.75;
		COLOR.b *=0.75;
	}else{
		COLOR = texture(TEXTURE, UV);
	}
}