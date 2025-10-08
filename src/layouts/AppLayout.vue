<template>
  <div class="app-layout">
    <!-- Desktop Layout -->
    <div class="desktop-layout" v-if="!isMobile">
      <AppSidebar :collapsed="sidebarCollapsed" @toggle="toggleSidebar" />
      <div class="main-content" :class="{ 'sidebar-collapsed': sidebarCollapsed }">
        <AppTopbar />
        <div class="content-area">
          <router-view />
        </div>
      </div>
    </div>

    <!-- Mobile Layout -->
    <div class="mobile-layout" v-else>
      <div class="mobile-topbar">
        <AppTopbar :mobile="true" />
      </div>
      <div class="mobile-content">
        <router-view />
      </div>
      <MobileBottomNav />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import AppSidebar from '../components/layout/AppSidebar.vue'
import AppTopbar from '../components/layout/AppTopbar.vue'
import MobileBottomNav from '../components/layout/MobileBottomNav.vue'

const sidebarCollapsed = ref(false)
const isMobile = ref(false)

const checkMobile = () => {
  isMobile.value = window.innerWidth < 768
}

const toggleSidebar = () => {
  sidebarCollapsed.value = !sidebarCollapsed.value
}

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})
</script>

<style scoped>
.app-layout {
  width: 100%;
  min-height: 100vh;
  background-color: var(--color-bg);
}

/* Desktop Layout */
.desktop-layout {
  display: flex;
  width: 100%;
  height: 100vh;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin-left: 220px;
  transition: margin-left 0.3s ease;
  overflow: hidden;
}

.main-content.sidebar-collapsed {
  margin-left: 64px;
}

.content-area {
  flex: 1;
  overflow-y: auto;
  padding: var(--spacing-3);
  background-color: var(--color-surface);
}

/* Mobile Layout */
.mobile-layout {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.mobile-topbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  background-color: var(--color-bg);
  box-shadow: var(--shadow-sm);
}

.mobile-content {
  flex: 1;
  overflow-y: auto;
  padding: var(--spacing-3);
  margin-top: 56px;
  margin-bottom: 60px;
}
</style>
