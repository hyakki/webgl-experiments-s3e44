varying vec3 v1;
varying vec3 v2;
varying vec3 vPosition;
varying vec3 vNormal;

uniform float uDrums;

void main() {
  vec3 pos = position;

  float strength = 0.75;
  float threshold = 0.25;
  float s = step(threshold, uDrums);
  vec3 target = pos + normal * (s * uDrums * strength);

  pos = mix(pos, target, 0.5);

  vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
  vec4 worldPosition = modelMatrix * vec4(pos, 1.0 );

  gl_Position = projectionMatrix * mvPosition;

  v1 = cameraPosition.xyz;
  v2 = vec4(modelMatrix * vec4(pos, 1.0)).xyz;
  vPosition = pos;
  vNormal = normal;
}
