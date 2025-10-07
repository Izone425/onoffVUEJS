<template>
  <nav class="mobile-bottom-nav">
    <router-link
      v-for="item in navItems"
      :key="item.path"
      :to="item.path"
      class="nav-item"
      :class="{ 'active': isActive(item.path) }"
    >
      <span :class="`pi ${item.icon}`" class="nav-icon"></span>
      <span class="nav-label">{{ item.label }}</span>
      <span v-if="item.badge" class="nav-badge">{{ item.badge }}</span>
    </router-link>
  </nav>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

const navItems = [
  {
    label: 'Operation',
    path: '/operation/onboarding/dashboard',
    icon: 'pi-th-large'
  },
  {
    label: 'Configuration',
    path: '/configuration/general-settings',
    icon: 'pi-cog'
  },
  {
    label: 'Notifications',
    path: '/notifications',
    icon: 'pi-bell',
    badge: 3
  },
  {
    label: 'Profile',
    path: '/profile',
    icon: 'pi-user'
  }
]

const isActive = (path) => {
  return route.path === path || route.path.startsWith(path.split('/').slice(0, 3).join('/'))
}
</script>

<style scoped>
.mobile-bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 60px;
  background-color: var(--color-bg);
  border-top: 1px solid var(--color-divider);
  display: flex;
  justify-content: space-around;
  align-items: center;
  padding: 0 var(--spacing-1);
  z-index: 100;
}

.nav-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 8px;
  text-decoration: none;
  color: var(--color-gray-500);
  transition: all 0.2s;
  position: relative;
  min-width: 60px;
}

.nav-item.active {
  color: var(--color-primary-600);
}

.nav-icon {
  font-size: 20px;
  margin-bottom: 4px;
}

.nav-label {
  font-size: 11px;
  font-weight: 500;
  text-align: center;
}

.nav-badge {
  position: absolute;
  top: 4px;
  right: calc(50% - 16px);
  background-color: var(--color-danger);
  color: white;
  font-size: 10px;
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 10px;
  min-width: 18px;
  text-align: center;
}
</style>
