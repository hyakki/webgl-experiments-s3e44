varying vec2 vUv;

void main() {
  vec3 pos = position;

  vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
  vec4 worldPosition = modelMatrix * vec4(pos, 1.0 );

  gl_Position = projectionMatrix * mvPosition;

  vUv = uv;
}
