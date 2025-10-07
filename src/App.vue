<template>
  <div id="app">
    <router-view />
    <Toast />
  </div>
</template>

<script setup>
import Toast from 'primevue/toast'
</script>

<style>
#app {
  width: 100%;
  min-height: 100vh;
}
</style>
