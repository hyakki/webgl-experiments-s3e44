varying vec2 vUv;
uniform sampler2D city;
uniform float uTime;

void main() {
  vec4 color = texture2D(city, vUv);

  // color.rgba = vec4(vUv.x, vUv.y, 0.0, 1.0);

  gl_FragColor = color;
}
