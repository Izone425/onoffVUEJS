<template>
  <header class="topbar" :class="{ 'mobile': mobile }">
    <div class="topbar-left">
      <h1 class="page-title">{{ pageTitle }}</h1>
    </div>

    <div class="topbar-right">
      <button class="topbar-btn" title="Search">
        <span class="pi pi-search"></span>
      </button>

      <button class="topbar-btn notification-btn" @click="toggleNotifications" title="Notifications">
        <span class="pi pi-bell"></span>
        <span class="badge" v-if="notificationCount > 0">{{ notificationCount }}</span>
      </button>

      <button class="topbar-btn" title="Help">
        <span class="pi pi-question-circle"></span>
      </button>

      <div class="user-menu">
        <button class="user-btn" @click="toggleUserMenu">
          <div class="user-avatar">
            <span class="user-initials">{{ userInitials }}</span>
          </div>
          <div class="user-info" v-if="!mobile">
            <div class="user-name">{{ currentUser.name }}</div>
            <div class="user-role">{{ currentUser.role }}</div>
          </div>
          <span class="pi pi-angle-down" v-if="!mobile"></span>
        </button>

        <div class="user-dropdown" v-if="showUserMenu" v-click-outside="closeUserMenu">
          <div class="dropdown-header">
            <div class="user-avatar large">
              <span class="user-initials">{{ userInitials }}</span>
            </div>
            <div class="user-details">
              <div class="user-name">{{ currentUser.name }}</div>
              <div class="user-email">{{ currentUser.email }}</div>
            </div>
          </div>
          <div class="dropdown-divider"></div>
          <a href="#" class="dropdown-item">
            <span class="pi pi-user"></span>
            <span>Profile</span>
          </a>
          <a href="#" class="dropdown-item">
            <span class="pi pi-cog"></span>
            <span>Settings</span>
          </a>
          <div class="dropdown-divider"></div>
          <a href="#" class="dropdown-item">
            <span class="pi pi-sign-out"></span>
            <span>Logout</span>
          </a>
        </div>
      </div>
    </div>

    <!-- Notifications Panel -->
    <div class="notifications-panel" v-if="showNotifications" v-click-outside="closeNotifications">
      <div class="panel-header">
        <h3>Notifications</h3>
        <button class="mark-all-read">Mark all as read</button>
      </div>
      <div class="notifications-list">
        <div v-for="notification in notifications" :key="notification.id" class="notification-item" :class="{ 'unread': !notification.read }">
          <div class="notification-icon">
            <span :class="`pi ${notification.icon}`"></span>
          </div>
          <div class="notification-content">
            <div class="notification-title">{{ notification.title }}</div>
            <div class="notification-message">{{ notification.message }}</div>
            <div class="notification-time">{{ notification.time }}</div>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'

defineProps({
  mobile: {
    type: Boolean,
    default: false
  }
})

const route = useRoute()
const showUserMenu = ref(false)
const showNotifications = ref(false)

const currentUser = {
  name: 'Ahmed Fauzi',
  email: 'ahmed.f@company.com',
  role: 'HR Admin'
}

const notifications = ref([
  {
    id: 1,
    icon: 'pi-exclamation-circle',
    title: 'Task Overdue',
    message: 'Grant Email & HRMS Access is overdue for Harith Rahman',
    time: '5 minutes ago',
    read: false
  },
  {
    id: 2,
    icon: 'pi-check-circle',
    title: 'Task Completed',
    message: 'Welcome Pack completed for Aina Zulkifli',
    time: '1 hour ago',
    read: false
  },
  {
    id: 3,
    icon: 'pi-info-circle',
    title: 'New Pre-Hire',
    message: 'New candidate added: Nur Iman',
    time: '2 hours ago',
    read: true
  }
])

const pageTitle = computed(() => route.meta.title || 'Dashboard')

const userInitials = computed(() => {
  const names = currentUser.name.split(' ')
  return names.map(n => n[0]).join('').toUpperCase()
})

const notificationCount = computed(() => {
  return notifications.value.filter(n => !n.read).length
})

const toggleUserMenu = () => {
  showUserMenu.value = !showUserMenu.value
  showNotifications.value = false
}

const toggleNotifications = () => {
  showNotifications.value = !showNotifications.value
  showUserMenu.value = false
}

const closeUserMenu = () => {
  showUserMenu.value = false
}

const closeNotifications = () => {
  showNotifications.value = false
}

// Click outside directive
const vClickOutside = {
  mounted(el, binding) {
    el.clickOutsideEvent = (event) => {
      if (!(el === event.target || el.contains(event.target))) {
        binding.value()
      }
    }
    document.addEventListener('click', el.clickOutsideEvent)
  },
  unmounted(el) {
    document.removeEventListener('click', el.clickOutsideEvent)
  }
}
</script>

<style scoped>
.topbar {
  height: 64px;
  background-color: var(--color-bg);
  border-bottom: 1px solid var(--color-divider);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 var(--spacing-4);
  position: relative;
}

.topbar.mobile {
  height: 56px;
  padding: 0 var(--spacing-3);
}

.topbar-left {
  flex: 1;
}

.page-title {
  font-size: 20px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
}

.topbar-right {
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
}

.topbar-btn {
  width: 40px;
  height: 40px;
  border: none;
  background-color: transparent;
  border-radius: var(--radius-md);
  color: var(--color-gray-700);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  transition: all 0.2s;
}

.topbar-btn:hover {
  background-color: var(--color-gray-100);
}

.topbar-btn .pi {
  font-size: 18px;
}

.notification-btn .badge {
  position: absolute;
  top: 8px;
  right: 8px;
  background-color: var(--color-danger);
  color: white;
  font-size: 10px;
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 10px;
  min-width: 18px;
  text-align: center;
}

.user-menu {
  position: relative;
  margin-left: var(--spacing-1);
}

.user-btn {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  padding: 6px 12px 6px 6px;
  border: 1px solid var(--color-divider);
  background-color: transparent;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s;
}

.user-btn:hover {
  background-color: var(--color-gray-100);
  border-color: var(--color-gray-300);
}

.user-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, #155EEF, #0B4EDD);
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-avatar.large {
  width: 48px;
  height: 48px;
}

.user-initials {
  color: white;
  font-size: 14px;
  font-weight: 600;
}

.user-avatar.large .user-initials {
  font-size: 18px;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-900);
  line-height: 1.2;
}

.user-role {
  font-size: 12px;
  color: var(--color-gray-500);
  line-height: 1.2;
}

.user-email {
  font-size: 12px;
  color: var(--color-gray-500);
  margin-top: 2px;
}

.user-dropdown,
.notifications-panel {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  width: 320px;
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  z-index: 1000;
  animation: slideDown 0.2s ease;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.dropdown-header {
  padding: var(--spacing-3);
  display: flex;
  gap: var(--spacing-2);
}

.user-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.dropdown-divider {
  height: 1px;
  background-color: var(--color-divider);
  margin: 0;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  padding: 12px var(--spacing-3);
  color: var(--color-gray-700);
  text-decoration: none;
  transition: all 0.2s;
}

.dropdown-item:hover {
  background-color: var(--color-gray-100);
}

.dropdown-item .pi {
  font-size: 16px;
}

.notifications-panel {
  width: 380px;
}

.panel-header {
  padding: var(--spacing-3);
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid var(--color-divider);
}

.panel-header h3 {
  font-size: 16px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
}

.mark-all-read {
  background: none;
  border: none;
  color: var(--color-primary-600);
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
}

.mark-all-read:hover {
  text-decoration: underline;
}

.notifications-list {
  max-height: 400px;
  overflow-y: auto;
}

.notification-item {
  display: flex;
  gap: var(--spacing-2);
  padding: var(--spacing-3);
  border-bottom: 1px solid var(--color-divider);
  cursor: pointer;
  transition: all 0.2s;
}

.notification-item:hover {
  background-color: var(--color-gray-100);
}

.notification-item.unread {
  background-color: rgba(21, 94, 239, 0.05);
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-icon {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background-color: var(--color-gray-100);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.notification-icon .pi {
  font-size: 16px;
  color: var(--color-gray-700);
}

.notification-content {
  flex: 1;
}

.notification-title {
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-900);
  margin-bottom: 2px;
}

.notification-message {
  font-size: 13px;
  color: var(--color-gray-700);
  margin-bottom: 4px;
}

.notification-time {
  font-size: 12px;
  color: var(--color-gray-500);
}
</style>
