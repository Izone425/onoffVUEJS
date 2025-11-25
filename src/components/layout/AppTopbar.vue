<template>
  <header class="topbar" :class="{ 'mobile': mobile }">
    <div class="topbar-left">
      <!-- Page title removed -->
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
            <span class="user-initials">{{ userStore.userInitials }}</span>
          </div>
          <div class="user-info" v-if="!mobile">
            <div class="user-name">{{ userStore.currentUser.name }}</div>
            <div class="user-role">{{ userStore.currentRole.name }}</div>
          </div>
          <span class="pi pi-angle-down" v-if="!mobile"></span>
        </button>

        <div class="user-dropdown" v-show="showUserMenu" ref="userDropdownRef">
          <!-- User Header -->
          <div class="dropdown-header">
            <div class="user-avatar large">
              <span class="user-initials">{{ userStore.userInitials }}</span>
            </div>
            <div class="user-details">
              <div class="user-name">{{ userStore.currentUser.name }}</div>
              <div class="user-email">{{ userStore.currentUser.email }}</div>
            </div>
          </div>

          <!-- Current Role Badge -->
          <div class="current-role-section">
            <div class="current-role-badge">
              <span class="pi pi-shield"></span>
              <span>{{ userStore.currentRole.name }}</span>
            </div>
            <p class="role-description">{{ userStore.currentRole.description }}</p>
          </div>

          <div class="dropdown-divider"></div>

          <!-- Role Switcher Section -->
          <div class="role-switcher-section">
            <div class="section-header">
              <span class="pi pi-sync"></span>
              <span>Switch View As</span>
            </div>
            <div class="role-list">
              <button
                v-for="role in userStore.roles"
                :key="role.id"
                class="role-item"
                :class="{ 'active': role.id === userStore.currentRoleId }"
                @click="handleRoleSwitch(role.id)"
              >
                <div class="role-item-left">
                  <div class="role-icon" :class="getRoleColorClass(role.id)">
                    <span class="pi pi-user"></span>
                  </div>
                  <div class="role-info">
                    <div class="role-name">{{ role.name }}</div>
                    <div class="role-desc">{{ role.description }}</div>
                  </div>
                </div>
                <span v-if="role.id === userStore.currentRoleId" class="pi pi-check active-check"></span>
              </button>
            </div>
          </div>

          <div class="dropdown-divider"></div>

          <!-- Menu Items -->
          <a href="#" class="dropdown-item">
            <span class="pi pi-user"></span>
            <span>Profile</span>
          </a>
          <a href="#" class="dropdown-item">
            <span class="pi pi-cog"></span>
            <span>Settings</span>
          </a>
          <div class="dropdown-divider"></div>
          <a href="#" class="dropdown-item logout">
            <span class="pi pi-sign-out"></span>
            <span>Logout</span>
          </a>
        </div>
      </div>
    </div>

    <!-- Notifications Panel -->
    <div class="notifications-panel" v-show="showNotifications" ref="notificationsPanelRef">
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
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../../stores/userStore'

defineProps({
  mobile: {
    type: Boolean,
    default: false
  }
})

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const showUserMenu = ref(false)
const showNotifications = ref(false)
const userDropdownRef = ref(null)
const notificationsPanelRef = ref(null)

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

const notificationCount = computed(() => {
  return notifications.value.filter(n => !n.read).length
})

const getRoleColorClass = (roleId) => {
  const colors = {
    'hr-admin': 'color-blue',
    'hr-coordinator': 'color-green',
    'manager': 'color-purple',
    'it-pic': 'color-orange',
    'staff': 'color-gray'
  }
  return colors[roleId] || 'color-blue'
}

const handleRoleSwitch = (roleId) => {
  userStore.switchRole(roleId)
  showUserMenu.value = false

  // Navigate to the first available page for this role
  const role = userStore.roles.find(r => r.id === roleId)
  if (role) {
    // Check current route access
    const currentPath = route.path

    // Determine if user still has access to current page
    let hasAccess = false

    if (currentPath.includes('/configuration/')) {
      if (currentPath.includes('general-settings')) hasAccess = role.permissions.generalSettings?.read
      else if (currentPath.includes('user-roles')) hasAccess = role.permissions.roles?.read
      else if (currentPath.includes('task-templates')) hasAccess = role.permissions.taskTemplates?.read
      else if (currentPath.includes('workflow')) hasAccess = role.permissions.workflow?.read
      else if (currentPath.includes('audit-trail')) hasAccess = role.permissions.auditTrail?.read
    } else if (currentPath.includes('/operation/')) {
      if (currentPath.includes('pre-hire')) hasAccess = role.permissions.preHireEntry?.read
      else if (currentPath.includes('dashboard')) hasAccess = role.permissions.dashboards?.read
    }

    // If no access, redirect to first available page
    if (!hasAccess) {
      if (role.permissions.dashboards?.read) {
        router.push('/operation/onboarding/dashboard')
      } else if (role.permissions.preHireEntry?.read) {
        router.push('/operation/onboarding/pre-hire')
      } else if (role.permissions.generalSettings?.read) {
        router.push('/configuration/general-settings')
      }
    }
  }
}

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

// Click outside handler
const handleClickOutside = (event) => {
  // Handle user dropdown
  if (showUserMenu.value && userDropdownRef.value) {
    const userBtn = document.querySelector('.user-btn')
    if (!userDropdownRef.value.contains(event.target) && !userBtn?.contains(event.target)) {
      showUserMenu.value = false
    }
  }

  // Handle notifications panel
  if (showNotifications.value && notificationsPanelRef.value) {
    const notifBtn = document.querySelector('.notification-btn')
    if (!notificationsPanelRef.value.contains(event.target) && !notifBtn?.contains(event.target)) {
      showNotifications.value = false
    }
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.topbar {
  height: 52px;
  background-color: var(--color-bg);
  border-bottom: 1px solid var(--color-divider);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 var(--spacing-3);
  position: relative;
}

.topbar.mobile {
  height: 48px;
  padding: 0 var(--spacing-3);
}

.topbar-left {
  flex: 1;
}

.page-title {
  font-size: 16px;
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
  width: 32px;
  height: 32px;
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
  font-size: 16px;
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
  padding: 4px 10px 4px 4px;
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
  width: 28px;
  height: 28px;
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
  font-size: 12px;
  font-weight: 600;
}

.user-avatar.large .user-initials {
  font-size: 16px;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.user-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
  line-height: 1.2;
}

.user-role {
  font-size: 11px;
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
  width: 360px;
  background-color: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  z-index: 1000;
  animation: slideDown 0.2s ease;
  max-height: 80vh;
  overflow-y: auto;
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

/* Current Role Section */
.current-role-section {
  padding: 0 var(--spacing-3) var(--spacing-3);
}

.current-role-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: linear-gradient(135deg, #155EEF, #0B4EDD);
  color: white;
  border-radius: var(--radius-md);
  font-size: 12px;
  font-weight: 600;
}

.current-role-badge .pi {
  font-size: 12px;
}

.role-description {
  font-size: 11px;
  color: var(--color-gray-500);
  margin: 8px 0 0 0;
}

/* Role Switcher Section */
.role-switcher-section {
  padding: var(--spacing-2) var(--spacing-3);
}

.section-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
  font-size: 11px;
  font-weight: 600;
  color: var(--color-gray-500);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: var(--spacing-2);
}

.section-header .pi {
  font-size: 12px;
}

.role-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.role-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 12px;
  border: 1px solid transparent;
  background-color: transparent;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s;
  width: 100%;
  text-align: left;
}

.role-item:hover {
  background-color: var(--color-gray-50);
  border-color: var(--color-divider);
}

.role-item.active {
  background-color: #eff6ff;
  border-color: #bfdbfe;
}

.role-item-left {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
}

.role-icon {
  width: 32px;
  height: 32px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.role-icon .pi {
  font-size: 14px;
}

.role-icon.color-blue {
  background-color: #dbeafe;
  color: #1d4ed8;
}

.role-icon.color-green {
  background-color: #dcfce7;
  color: #16a34a;
}

.role-icon.color-purple {
  background-color: #f3e8ff;
  color: #9333ea;
}

.role-icon.color-orange {
  background-color: #ffedd5;
  color: #ea580c;
}

.role-icon.color-gray {
  background-color: #f3f4f6;
  color: #4b5563;
}

.role-info {
  flex: 1;
  min-width: 0;
}

.role-info .role-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
  line-height: 1.3;
}

.role-info .role-desc {
  font-size: 11px;
  color: var(--color-gray-500);
  line-height: 1.3;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.active-check {
  color: #155EEF;
  font-size: 14px;
  font-weight: bold;
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

.dropdown-item.logout {
  color: #dc2626;
}

.dropdown-item.logout:hover {
  background-color: #fef2f2;
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
