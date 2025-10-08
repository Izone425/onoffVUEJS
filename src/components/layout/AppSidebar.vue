<template>
  <aside class="sidebar" :class="{ 'collapsed': collapsed }">
    <div class="sidebar-header">
      <div class="logo">
        <div class="logo-icon">
          <span class="pi pi-users"></span>
        </div>
        <div class="logo-text" v-if="!collapsed">
          <div class="logo-title">TimeTec HR</div>
          <div class="logo-subtitle">Human Resources</div>
        </div>
      </div>
    </div>

    <div class="sidebar-search" v-if="!collapsed">
      <input
        type="text"
        placeholder="Search modules..."
        class="search-input"
      />
      <span class="pi pi-search search-icon"></span>
    </div>

    <nav class="sidebar-nav">
      <div class="nav-section">
        <div class="nav-section-title" v-if="!collapsed">Operation</div>
        <div class="nav-items">
          <router-link
            v-for="item in operationItems"
            :key="item.path"
            :to="item.path"
            class="nav-item"
            :class="{ 'active': isActive(item.path) }"
            :title="collapsed ? item.label : ''"
          >
            <span :class="`pi ${item.icon}`" class="nav-icon"></span>
            <span class="nav-label" v-if="!collapsed">{{ item.label }}</span>
          </router-link>
        </div>
      </div>

      <div class="nav-section">
        <div class="nav-section-title" v-if="!collapsed">Configuration</div>
        <div class="nav-items">
          <router-link
            v-for="item in configItems"
            :key="item.path"
            :to="item.path"
            class="nav-item"
            :class="{ 'active': isActive(item.path) }"
            :title="collapsed ? item.label : ''"
          >
            <span :class="`pi ${item.icon}`" class="nav-icon"></span>
            <span class="nav-label" v-if="!collapsed">{{ item.label }}</span>
          </router-link>
        </div>
      </div>
    </nav>

    <div class="sidebar-footer">
      <button @click="$emit('toggle')" class="collapse-btn">
        <span :class="collapsed ? 'pi pi-angle-right' : 'pi pi-angle-left'"></span>
      </button>
    </div>
  </aside>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

defineProps({
  collapsed: {
    type: Boolean,
    default: false
  }
})

defineEmits(['toggle'])

const route = useRoute()

const operationItems = [
  {
    label: 'Pre-Hire Entry',
    path: '/operation/onboarding/pre-hire',
    icon: 'pi-user-plus'
  },
  {
    label: 'Onboarding Dashboard',
    path: '/operation/onboarding/dashboard',
    icon: 'pi-sign-in'
  },
  {
    label: 'Offboarding Dashboard',
    path: '/operation/offboarding/dashboard',
    icon: 'pi-sign-out'
  }
]

const configItems = [
  {
    label: 'General Settings',
    path: '/configuration/general-settings',
    icon: 'pi-cog'
  },
  {
    label: 'User Roles',
    path: '/configuration/user-roles',
    icon: 'pi-shield'
  },
  {
    label: 'Task Templates',
    path: '/configuration/task-templates',
    icon: 'pi-file'
  },
  {
    label: 'Workflow Builder',
    path: '/configuration/workflow',
    icon: 'pi-sitemap'
  },
  {
    label: 'Audit Trail',
    path: '/configuration/audit-trail',
    icon: 'pi-history'
  }
]

const isActive = (path) => {
  return route.path === path || route.path.startsWith(path + '/')
}
</script>

<style scoped>
.sidebar {
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  width: 220px;
  background-color: var(--color-bg);
  border-right: 1px solid var(--color-divider);
  display: flex;
  flex-direction: column;
  transition: width 0.3s ease;
  z-index: 100;
}

.sidebar.collapsed {
  width: 64px;
}

.sidebar-header {
  padding: var(--spacing-3);
  border-bottom: 1px solid var(--color-divider);
}

.logo {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.logo-icon {
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #155EEF, #0B4EDD);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.logo-icon .pi {
  color: white;
  font-size: 16px;
}

.logo-text {
  flex: 1;
  min-width: 0;
}

.logo-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-gray-900);
  line-height: 1.2;
}

.logo-subtitle {
  font-size: 11px;
  color: var(--color-gray-500);
  line-height: 1.2;
}

.sidebar-search {
  padding: var(--spacing-3);
  position: relative;
}

.search-input {
  width: 100%;
  padding: 6px 10px 6px 30px;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  font-size: 12px;
  background-color: var(--color-surface);
  transition: border-color 0.2s;
}

.search-input:focus {
  outline: none;
  border-color: var(--color-primary-600);
}

.search-icon {
  position: absolute;
  left: calc(var(--spacing-3) + 10px);
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-gray-500);
  font-size: 12px;
}

.sidebar-nav {
  flex: 1;
  overflow-y: auto;
  padding: var(--spacing-3) 0;
}

.nav-section {
  margin-bottom: var(--spacing-4);
}

.nav-section-title {
  padding: var(--spacing-1) var(--spacing-3);
  font-size: 10px;
  font-weight: 600;
  color: var(--color-gray-500);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.nav-items {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 0 var(--spacing-2);
}

.nav-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  padding: 8px 10px;
  border-radius: var(--radius-md);
  color: var(--color-gray-700);
  text-decoration: none;
  transition: all 0.2s;
  cursor: pointer;
}

.nav-item:hover {
  background-color: var(--color-gray-100);
  color: var(--color-gray-900);
}

.nav-item.active {
  background-color: var(--color-primary-600);
  color: white;
}

.nav-icon {
  font-size: 16px;
  flex-shrink: 0;
  width: 18px;
  text-align: center;
}

.nav-label {
  font-size: 13px;
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.sidebar-footer {
  padding: var(--spacing-3);
  border-top: 1px solid var(--color-divider);
}

.collapse-btn {
  width: 100%;
  padding: 10px;
  background-color: transparent;
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  color: var(--color-gray-700);
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.collapse-btn:hover {
  background-color: var(--color-gray-100);
  border-color: var(--color-gray-300);
}

.collapsed .nav-item {
  justify-content: center;
}

.collapsed .sidebar-footer {
  padding: var(--spacing-2);
}
</style>
