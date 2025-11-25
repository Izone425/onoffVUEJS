import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

// Define all available roles with their permissions
const roleDefinitions = [
  {
    id: 'hr-admin',
    name: 'HR Admin',
    description: 'Full access to Configuration & Operation',
    userCount: 3,
    lastUpdated: '2025-08-20',
    permissions: {
      generalSettings: { read: true, write: true },
      roles: { read: true, write: true },
      taskTemplates: { read: true, write: true },
      workflow: { read: true, write: true },
      auditTrail: { read: true, write: true },
      preHireEntry: { read: true, write: true },
      dashboards: { read: true, write: true },
      assignTasks: { read: true, write: true }
    }
  },
  {
    id: 'hr-coordinator',
    name: 'HR Coordinator',
    description: 'Operation + read of Configuration',
    userCount: 5,
    lastUpdated: '2025-08-15',
    permissions: {
      generalSettings: { read: true, write: false },
      roles: { read: true, write: false },
      taskTemplates: { read: true, write: false },
      workflow: { read: true, write: false },
      auditTrail: { read: true, write: false },
      preHireEntry: { read: true, write: true },
      dashboards: { read: true, write: true },
      assignTasks: { read: true, write: true }
    }
  },
  {
    id: 'manager',
    name: 'Manager',
    description: 'Operation (view/approve tasks assigned to team)',
    userCount: 12,
    lastUpdated: '2025-08-10',
    permissions: {
      generalSettings: { read: false, write: false },
      roles: { read: false, write: false },
      taskTemplates: { read: false, write: false },
      workflow: { read: false, write: false },
      auditTrail: { read: false, write: false },
      preHireEntry: { read: false, write: false },
      dashboards: { read: true, write: false },
      assignTasks: { read: true, write: true }
    }
  },
  {
    id: 'it-pic',
    name: 'IT/PIC',
    description: 'Operation (System/Access & Asset tasks)',
    userCount: 4,
    lastUpdated: '2025-08-18',
    permissions: {
      generalSettings: { read: true, write: true },
      roles: { read: true, write: false },
      taskTemplates: { read: true, write: true },
      workflow: { read: true, write: true },
      auditTrail: { read: true, write: false },
      preHireEntry: { read: false, write: false },
      dashboards: { read: true, write: true },
      assignTasks: { read: true, write: true }
    }
  },
  {
    id: 'staff',
    name: 'Staff (End User)',
    description: 'Operation (assigned tasks only)',
    userCount: 86,
    lastUpdated: '2025-08-12',
    permissions: {
      generalSettings: { read: false, write: false },
      roles: { read: false, write: false },
      taskTemplates: { read: false, write: false },
      workflow: { read: false, write: false },
      auditTrail: { read: false, write: false },
      preHireEntry: { read: false, write: false },
      dashboards: { read: true, write: false },
      assignTasks: { read: false, write: false }
    }
  }
]

// User profiles for each role (for demo/switching purposes)
const userProfiles = {
  'hr-admin': {
    name: 'Ahmed Fauzi',
    email: 'ahmed.f@company.com',
    avatar: null
  },
  'hr-coordinator': {
    name: 'Sarah Ahmad',
    email: 'sarah.a@company.com',
    avatar: null
  },
  'manager': {
    name: 'Farah Kassim',
    email: 'farah.k@company.com',
    avatar: null
  },
  'it-pic': {
    name: 'David Kim',
    email: 'david.k@company.com',
    avatar: null
  },
  'staff': {
    name: 'Aina Zulkifli',
    email: 'aina.z@company.com',
    avatar: null
  }
}

// Permission module definitions for the sidebar
const permissionModules = [
  { key: 'generalSettings', label: 'General Settings', icon: 'pi-cog' },
  { key: 'roles', label: 'Roles', icon: 'pi-shield' },
  { key: 'taskTemplates', label: 'Task Templates', icon: 'pi-file' },
  { key: 'workflow', label: 'Workflow', icon: 'pi-sitemap' },
  { key: 'auditTrail', label: 'Audit Trail', icon: 'pi-history' },
  { key: 'preHireEntry', label: 'Pre-Hire Entry', icon: 'pi-user-plus' },
  { key: 'dashboards', label: 'Dashboards', icon: 'pi-chart-bar' },
  { key: 'assignTasks', label: 'Assign Tasks', icon: 'pi-users' }
]

export const useUserStore = defineStore('user', () => {
  // State
  const currentRoleId = ref('hr-admin')
  const roles = ref(roleDefinitions)

  // Getters
  const currentRole = computed(() => {
    return roles.value.find(r => r.id === currentRoleId.value) || roles.value[0]
  })

  const currentUser = computed(() => {
    return userProfiles[currentRoleId.value] || userProfiles['hr-admin']
  })

  const currentPermissions = computed(() => {
    return currentRole.value?.permissions || {}
  })

  const userInitials = computed(() => {
    const names = currentUser.value.name.split(' ')
    return names.map(n => n[0]).join('').toUpperCase()
  })

  // Check if user has read access to a module
  const canRead = (module) => {
    return currentPermissions.value[module]?.read || false
  }

  // Check if user has write access to a module
  const canWrite = (module) => {
    return currentPermissions.value[module]?.write || false
  }

  // Get available navigation items based on current role
  const availableOperationItems = computed(() => {
    const items = []

    if (canRead('preHireEntry')) {
      items.push({
        label: 'Pre-Hire Entry',
        path: '/operation/onboarding/pre-hire',
        icon: 'pi-user-plus',
        permission: 'preHireEntry'
      })
    }

    if (canRead('dashboards')) {
      items.push({
        label: 'Onboarding Dashboard',
        path: '/operation/onboarding/dashboard',
        icon: 'pi-sign-in',
        permission: 'dashboards'
      })
      items.push({
        label: 'Offboarding Dashboard',
        path: '/operation/offboarding/dashboard',
        icon: 'pi-sign-out',
        permission: 'dashboards'
      })
    }

    return items
  })

  const availableConfigItems = computed(() => {
    const items = []

    if (canRead('generalSettings')) {
      items.push({
        label: 'General Settings',
        path: '/configuration/general-settings',
        icon: 'pi-cog',
        permission: 'generalSettings'
      })
    }

    if (canRead('roles')) {
      items.push({
        label: 'User Roles',
        path: '/configuration/user-roles',
        icon: 'pi-shield',
        permission: 'roles'
      })
    }

    if (canRead('taskTemplates')) {
      items.push({
        label: 'Task Templates',
        path: '/configuration/task-templates',
        icon: 'pi-file',
        permission: 'taskTemplates'
      })
    }

    if (canRead('workflow')) {
      items.push({
        label: 'Workflow Builder',
        path: '/configuration/workflow',
        icon: 'pi-sitemap',
        permission: 'workflow'
      })
    }

    if (canRead('auditTrail')) {
      items.push({
        label: 'Audit Trail',
        path: '/configuration/audit-trail',
        icon: 'pi-history',
        permission: 'auditTrail'
      })
    }

    return items
  })

  // Check if configuration section should be visible
  const showConfigSection = computed(() => {
    return availableConfigItems.value.length > 0
  })

  // Actions
  const switchRole = (roleId) => {
    const role = roles.value.find(r => r.id === roleId)
    if (role) {
      currentRoleId.value = roleId
    }
  }

  const updateRolePermissions = (roleId, permissions) => {
    const roleIndex = roles.value.findIndex(r => r.id === roleId)
    if (roleIndex !== -1) {
      roles.value[roleIndex].permissions = permissions
    }
  }

  return {
    // State
    currentRoleId,
    roles,
    permissionModules,

    // Getters
    currentRole,
    currentUser,
    currentPermissions,
    userInitials,
    availableOperationItems,
    availableConfigItems,
    showConfigSection,

    // Methods
    canRead,
    canWrite,
    switchRole,
    updateRolePermissions
  }
})
