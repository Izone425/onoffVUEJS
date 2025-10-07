# System Architecture

## Overview

The TimeTec HR Onboarding & Offboarding system is built using a modern Vue.js 3 architecture with a component-based approach. The system follows a modular design with clear separation of concerns.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Browser                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    Vue.js App                         │  │
│  │  ┌──────────────────────────────────────────────┐    │  │
│  │  │           Router (Vue Router)                │    │  │
│  │  └──────────────────────────────────────────────┘    │  │
│  │  ┌──────────────────────────────────────────────┐    │  │
│  │  │         App Layout (AppLayout.vue)           │    │  │
│  │  │  ┌────────────┐  ┌──────────────────────┐   │    │  │
│  │  │  │  Sidebar   │  │   Main Content       │   │    │  │
│  │  │  │            │  │   ┌──────────────┐   │   │    │  │
│  │  │  │ Navigation │  │   │   Topbar     │   │   │    │  │
│  │  │  │            │  │   └──────────────┘   │   │    │  │
│  │  │  │            │  │   ┌──────────────┐   │   │    │  │
│  │  │  │            │  │   │  Router View │   │   │    │  │
│  │  │  │            │  │   │  (Views)     │   │   │    │  │
│  │  │  │            │  │   └──────────────┘   │   │    │  │
│  │  │  └────────────┘  └──────────────────────┘   │    │  │
│  │  └──────────────────────────────────────────────┘    │  │
│  │  ┌──────────────────────────────────────────────┐    │  │
│  │  │      State Management (Pinia)                │    │  │
│  │  └──────────────────────────────────────────────┘    │  │
│  │  ┌──────────────────────────────────────────────┐    │  │
│  │  │      UI Components (PrimeVue)                │    │  │
│  │  └──────────────────────────────────────────────┘    │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Layer Architecture

### 1. Presentation Layer

#### Layout Components (`src/layouts/`)
- **AppLayout.vue**: Main application wrapper
  - Manages desktop/mobile layout switching
  - Handles sidebar collapse state
  - Integrates sidebar, topbar, and mobile navigation

#### Layout Sub-Components (`src/components/layout/`)
- **AppSidebar.vue**: Side navigation
  - Collapsible sidebar
  - Operation & Configuration sections
  - Active route highlighting

- **AppTopbar.vue**: Top navigation bar
  - Page title display
  - Search functionality
  - Notifications dropdown
  - User menu

- **MobileBottomNav.vue**: Mobile bottom navigation
  - Tab-based navigation
  - Badge support for notifications

### 2. View Layer (`src/views/`)

Views are organized by module:

```
views/
├── configuration/
│   ├── GeneralSettings.vue      # System-wide settings
│   ├── UserRoles.vue             # Role management
│   ├── TaskTemplates.vue         # Task template library
│   ├── Workflow.vue              # Workflow builder
│   └── AuditTrail.vue            # System audit log
└── operation/
    ├── onboarding/
    │   ├── PreHireEntry.vue      # Pre-hire management
    │   └── Dashboard.vue         # Onboarding overview
    └── offboarding/
        └── Dashboard.vue         # Offboarding overview
```

### 3. Component Layer

#### UI Components (`src/components/ui/`)
Reusable, presentational components:

- **StatCard.vue**: KPI display card
  - Props: label, value, icon, color, change
  - Used in dashboards for metrics

- **StatusChip.vue**: Status badge
  - Props: status, label
  - Variants: success, warning, danger, info, secondary

- **ProgressBar.vue**: Progress indicator
  - Props: percentage, label, showLabel, color
  - Used for task completion tracking

#### Feature Components (`src/components/features/`)
Domain-specific components (future expansion):
- Task detail modals
- Workflow canvas
- Permission matrix

### 4. Data Layer

#### Mock Data (`src/data/mockData.js`)
Centralized mock data for prototyping:
```javascript
export const users = [...]
export const preHires = [...]
export const systems = [...]
export const assets = [...]
export const taskTemplates = [...]
export const workflows = [...]
export const roles = [...]
export const auditTrail = [...]
```

#### State Management (`src/stores/`)
Pinia stores for reactive state (expandable):
```
stores/
├── user.js          # User authentication & profile
├── tasks.js         # Task management
├── workflows.js     # Workflow state
└── config.js        # Configuration state
```

### 5. Routing Layer (`src/router/`)

Nested routing structure:
```javascript
{
  path: '/',
  component: AppLayout,
  children: [
    { path: 'operation/...', component: ... },
    { path: 'configuration/...', component: ... }
  ]
}
```

Benefits:
- Shared layout across all routes
- Lazy loading for views
- Meta data for permissions & titles

### 6. Style Layer (`src/styles/`)

Design system implementation:
```css
:root {
  /* Design tokens */
  --color-primary-600: #155EEF;
  --spacing-1: 0.5rem;
  --radius-md: 0.5rem;
  /* ... */
}
```

## Data Flow

### User Interaction Flow

```
User Action
    ↓
Component Event Handler
    ↓
State Update (Pinia Store)
    ↓
Component Re-render
    ↓
UI Update
```

### Example: Completing a Task

```
1. User clicks "Complete" button
   ↓
2. @click="completeTask(data)" in Dashboard.vue
   ↓
3. Task store: tasks.complete(taskId)
   ↓
4. API call (future): POST /api/tasks/:id/complete
   ↓
5. Store updates reactive state
   ↓
6. Component re-renders with updated data
   ↓
7. Toast notification displays success
```

## Component Communication

### Parent → Child: Props
```vue
<StatCard
  label="Overall Progress"
  :value="62"
  icon="pi-chart-line"
/>
```

### Child → Parent: Events
```vue
<!-- Child -->
<button @click="$emit('toggle')">Toggle</button>

<!-- Parent -->
<AppSidebar @toggle="handleToggle" />
```

### Sibling Communication: Pinia Store
```javascript
// Component A
const taskStore = useTaskStore()
taskStore.updateTask(task)

// Component B (reactive)
const taskStore = useTaskStore()
const task = taskStore.getTaskById(id)
```

## Responsive Design Strategy

### Breakpoints
```css
/* Mobile: < 768px */
/* Tablet: 768px - 1024px */
/* Desktop: > 1024px */
```

### Layout Switching
```javascript
const isMobile = ref(window.innerWidth < 768)

onMounted(() => {
  window.addEventListener('resize', () => {
    isMobile.value = window.innerWidth < 768
  })
})
```

### Desktop Layout
- Fixed sidebar (260px)
- Collapsible to 80px
- Top navigation bar
- Main content area

### Mobile Layout
- Hidden sidebar
- Bottom tab navigation
- Simplified topbar
- Full-width content

## Performance Considerations

### Code Splitting
- Route-based lazy loading
- Component-level code splitting for large features

```javascript
component: () => import('../views/Dashboard.vue')
```

### Optimizations
- Virtual scrolling for large lists (future)
- Image lazy loading
- Debounced search/filter inputs
- Memoized computed properties

## Security Architecture

### Role-Based Access Control (RBAC)

```javascript
// Route meta
meta: {
  title: 'General Settings',
  roles: ['HR Admin']
}

// Route guard (future)
router.beforeEach((to, from, next) => {
  const userRole = store.getters.currentUserRole
  if (to.meta.roles && !to.meta.roles.includes(userRole)) {
    next('/unauthorized')
  } else {
    next()
  }
})
```

### Permission Checking
```javascript
// In components
const hasPermission = (action, entity) => {
  const userPermissions = store.getters.currentUserPermissions
  return userPermissions[entity]?.[action] === true
}
```

## Extensibility Points

### Adding New Task Types
1. Add task type to `mockData.js`
2. Create task template component
3. Add to task detail modal
4. Update task form validation

### Adding New Modules
1. Create view in `src/views/[module]/`
2. Add route in `src/router/index.js`
3. Add navigation item in sidebar
4. Create module-specific stores if needed

### Integrating with Backend API
```javascript
// Create API client
// src/api/client.js
export const api = {
  tasks: {
    list: () => axios.get('/api/tasks'),
    get: (id) => axios.get(`/api/tasks/${id}`),
    create: (data) => axios.post('/api/tasks', data),
    update: (id, data) => axios.put(`/api/tasks/${id}`, data),
    delete: (id) => axios.delete(`/api/tasks/${id}`)
  }
}

// Update stores to use API
// src/stores/tasks.js
export const useTaskStore = defineStore('tasks', {
  actions: {
    async fetchTasks() {
      this.tasks = await api.tasks.list()
    }
  }
})
```

## Testing Strategy (Future)

### Unit Tests
- Component logic
- Store actions/getters
- Utility functions

### Integration Tests
- Component interactions
- Router navigation
- Store mutations

### E2E Tests
- User workflows
- Critical paths
- Cross-browser testing

## Deployment Architecture

```
Development → Staging → Production
     ↓           ↓          ↓
  Vite Dev   Vite Build  CDN/Nginx
```

### Build Process
```bash
npm run build
# Outputs to dist/
# - index.html
# - assets/
#   - [hash].js
#   - [hash].css
```

## Monitoring & Logging (Future)

- Error tracking (e.g., Sentry)
- Analytics (e.g., Google Analytics)
- Performance monitoring
- User behavior tracking

---

This architecture provides:
- **Scalability**: Easy to add new features
- **Maintainability**: Clear structure and separation
- **Performance**: Optimized loading and rendering
- **Security**: Role-based access control
- **Testability**: Modular, testable components
