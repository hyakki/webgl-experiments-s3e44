<template>
  <div class="app">
    <Webgl class="app__webgl" />
  </div>
</template>

<script lang="ts">
import Webgl from '@/components/Webgl/Webgl.vue'

export default {
  name: 'App',
  components: {
    Webgl,
  },
}
</script>

<style lang="scss">
[class*='app--'],
body {
  overscroll-behavior: none;
}

.app {
  @include get-all-space;

  color: $c-black;
}

.app__webgl {
  @include get-all-space;

  overflow: hidden;
}
</style>
