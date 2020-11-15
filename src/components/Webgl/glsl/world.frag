#pragma glslify: snoise4 = require(glsl-noise/simplex/4d) 

varying vec3 v1;
varying vec3 v2;
varying vec3 vPosition;
varying vec3 vNormal;

uniform float uTime;

void main() {
  vec4 color = vec4(0.78, 0.5, 0.78, 1.0);

  float d = dot(normalize(v1), normalize(v2));
  float dd = 1.0 - smoothstep(0.4, 0.6, d);

  float noiseSize = 6.0 / d;
  float noiseSpeed = uTime / 100.0;

  float n = snoise4(vec4(
    vec3(
      vPosition.x * noiseSize,
      vPosition.y * noiseSize,
      vPosition.z * noiseSize
    ), 
    noiseSpeed
  ));

  // Color gradient
  vec3 color1 = vec3(0.8, 0.5, 0.8);
  vec3 color2 = vec3(0.9, 0.6, 1.0);

  color.rgb = mix(color1, color2, dd);

  // Alpha
  color.a = dd * n + step(0.6, dd * n) * 0.6;

  gl_FragColor = color;

  if (gl_FragColor.a < 0.01) discard;
}
