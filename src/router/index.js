import { createRouter, createWebHistory } from 'vue-router'
import AppLayout from '../layouts/AppLayout.vue'

const routes = [
  {
    path: '/',
    component: AppLayout,
    redirect: '/operation/onboarding/dashboard',
    children: [
      // Operation Routes
      {
        path: 'operation/onboarding/pre-hire',
        name: 'PreHireEntry',
        component: () => import('../views/operation/onboarding/PreHireEntry.vue'),
        meta: { title: 'Pre-Hire Entry', roles: ['HR Admin', 'HR Coordinator'] }
      },
      {
        path: 'operation/onboarding/dashboard',
        name: 'OnboardingDashboard',
        component: () => import('../views/operation/onboarding/Dashboard.vue'),
        meta: { title: 'Onboarding Dashboard' }
      },
      {
        path: 'operation/offboarding/dashboard',
        name: 'OffboardingDashboard',
        component: () => import('../views/operation/offboarding/Dashboard.vue'),
        meta: { title: 'Offboarding Dashboard' }
      },
      // Configuration Routes
      {
        path: 'configuration/general-settings',
        name: 'GeneralSettings',
        component: () => import('../views/configuration/GeneralSettings.vue'),
        meta: { title: 'General Settings', roles: ['HR Admin'] }
      },
      {
        path: 'configuration/user-roles',
        name: 'UserRoles',
        component: () => import('../views/configuration/UserRoles.vue'),
        meta: { title: 'User Roles', roles: ['HR Admin'] }
      },
      {
        path: 'configuration/task-templates',
        name: 'TaskTemplates',
        component: () => import('../views/configuration/TaskTemplates.vue'),
        meta: { title: 'Task Templates', roles: ['HR Admin'] }
      },
      {
        path: 'configuration/workflow',
        name: 'Workflow',
        component: () => import('../views/configuration/Workflow.vue'),
        meta: { title: 'Workflow Builder', roles: ['HR Admin'] }
      },
      {
        path: 'configuration/audit-trail',
        name: 'AuditTrail',
        component: () => import('../views/configuration/AuditTrail.vue'),
        meta: { title: 'Audit Trail', roles: ['HR Admin'] }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  document.title = to.meta.title ? `${to.meta.title} - TimeTec HR` : 'TimeTec HR'
  next()
})

export default router
