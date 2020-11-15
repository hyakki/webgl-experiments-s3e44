#pragma glslify: snoise4 = require(glsl-noise/simplex/4d) 

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;

uniform float uTime;
uniform float uSpread;
uniform float uPads;

void main() {
  vUv = uv; 
  vNormal = normal;

  vec3 pos = position;

  vec3 target = pos + pos * uSpread * 0.2;

  pos = target;

  float noiseSize = 1.0;
  float noiseSpeed = uTime / 1000.0;
  float n = snoise4(vec4(
    vec3(
      pos.x * noiseSize,
      pos.y * noiseSize,
      pos.z * noiseSize
    ), 
    noiseSpeed * uPads
  ));

  pos.y = pos.y - (n / 3.0);

  vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);

  gl_PointSize = 2.0 - (1.0 / - mvPosition.z);
  gl_Position = projectionMatrix * mvPosition;

  vPosition = pos;
}
