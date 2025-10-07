# TimeTec HR - Onboarding & Offboarding System

A comprehensive Human Resource Management System (HRMS) for managing employee onboarding and offboarding processes. Built with Vue.js 3, PrimeVue, and Composition API.

## 🚀 Features

### Operation Module

#### Onboarding
- **Pre-Hire Entry**: Manage pre-hires, create user accounts, assign workflows and appraisal templates
- **Onboarding Dashboard**:
  - KPI cards (Overall Progress, Pending Documents, Overdue Tasks, New Hires)
  - Progress tracking by new hire
  - Task management with filtering
  - Document tracking

#### Offboarding
- **Offboarding Dashboard**:
  - Progress tracking by leaver
  - Task management
  - Asset collection tracking
  - Access revocation management

### Configuration Module

1. **General Settings**: Configure global onboarding/offboarding behavior
   - Duration settings (onboarding/offboarding days)
   - Reminder cadence
   - Business days only toggle
   - Default appraisal templates
   - Timezone & locale settings

2. **User Roles**: Role-based access control
   - HR Admin (Full access)
   - HR Coordinator (Operation + read Configuration)
   - Manager (Team task approval)
   - IT/PIC (System/Access & Asset tasks)
   - Staff (Assigned tasks only)

3. **Task Templates**: 7 types of reusable task templates
   - General Task (Free Text)
   - Information/Document Form Task
   - Questionnaire Task
   - Meeting/Event Task
   - System/Access Task
   - Asset Task
   - Checklist/Multi-step Task

4. **Workflow Builder**: Compose workflows from task templates
   - Drag & drop interface
   - Task dependencies
   - PIC assignment
   - Trigger configuration
   - Version control

5. **Audit Trail**: Track all system changes
   - Configuration changes
   - Operational changes
   - User actions
   - Source IP tracking

## 🎨 Design System

### Colors
- **Primary**: #155EEF (Blue)
- **Success**: #16A34A (Green)
- **Warning**: #F59E0B (Orange)
- **Danger**: #DC2626 (Red)
- **Info**: #0EA5E9 (Light Blue)

### Typography
- **Display**: 28px/36px, Semibold
- **H1**: 24px/32px, Semibold
- **H2**: 20px/28px, Semibold
- **Body**: 14px/20px, Regular
- **Caption**: 12px/16px, Regular

### Spacing
- 8px base spacing system
- Tokens: 8px, 12px, 16px, 24px, 32px, 48px

## 🛠️ Technology Stack

- **Framework**: Vue.js 3 (Composition API)
- **UI Library**: PrimeVue 4
- **State Management**: Pinia
- **Routing**: Vue Router
- **Icons**: PrimeIcons
- **Build Tool**: Vite

## 📦 Installation

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## 📁 Project Structure

```
src/
├── components/
│   ├── layout/           # Layout components (Sidebar, Topbar, etc.)
│   └── ui/               # Reusable UI components (StatCard, StatusChip, etc.)
├── data/
│   └── mockData.js       # Mock data for prototyping
├── layouts/
│   └── AppLayout.vue     # Main application layout
├── router/
│   └── index.js          # Route configuration
├── stores/               # Pinia stores (if needed)
├── styles/
│   └── main.css          # Global styles & design tokens
├── views/
│   ├── configuration/    # Configuration module views
│   └── operation/        # Operation module views
│       ├── onboarding/
│       └── offboarding/
├── App.vue               # Root component
└── main.js               # Application entry point
```

## 🎯 Key Components

### Layout Components
- **AppLayout**: Main application wrapper with sidebar and topbar
- **AppSidebar**: Navigation sidebar with collapsible feature
- **AppTopbar**: Top navigation bar with search, notifications, and user menu
- **MobileBottomNav**: Mobile bottom navigation bar

### UI Components
- **StatCard**: KPI card with icon, value, and trend
- **StatusChip**: Status badge with predefined variants
- **ProgressBar**: Progress indicator with percentage

### Views

#### Configuration
- GeneralSettings.vue
- UserRoles.vue
- TaskTemplates.vue
- Workflow.vue
- AuditTrail.vue

#### Operation - Onboarding
- PreHireEntry.vue
- Dashboard.vue

#### Operation - Offboarding
- Dashboard.vue

## 🌐 Routing

All routes are nested under the AppLayout component:

```
/                                       → Redirect to /operation/onboarding/dashboard
/operation/onboarding/pre-hire          → Pre-Hire Entry
/operation/onboarding/dashboard         → Onboarding Dashboard
/operation/offboarding/dashboard        → Offboarding Dashboard
/configuration/general-settings         → General Settings
/configuration/user-roles               → User Roles
/configuration/task-templates           → Task Templates
/configuration/workflow                 → Workflow Builder
/configuration/audit-trail              → Audit Trail
```

## 📊 Mock Data

The application includes comprehensive mock data:
- **Users**: 5 sample users with different roles
- **Pre-Hires**: 3 candidates with different email statuses
- **Systems**: 8 systems for access management
- **Assets**: 4 asset types for tracking
- **Task Templates**: 9 predefined templates (6 onboarding, 3 offboarding)
- **Workflows**: 2 workflows (1 onboarding, 1 offboarding)
- **Roles**: 5 role configurations with permissions
- **Audit Trail**: Sample audit entries

## 🎨 Design Highlights

### Desktop-First Approach
- Responsive 12-column grid system
- Sidebar navigation (collapsible)
- Top navigation bar with search and notifications
- Content area with max-width containers

### Mobile Responsive
- Bottom tab navigation
- Simplified layouts
- Touch-optimized controls
- Minimum 44px touch targets

### Accessibility Features
- Keyboard navigation support
- Focus indicators
- ARIA labels
- High contrast colors (WCAG AA compliant)
- Semantic HTML

## 🔐 User Roles & Permissions

| Role | Configuration Access | Operation Access | Special Permissions |
|------|---------------------|------------------|---------------------|
| HR Admin | Full CRUD | Full | All permissions |
| HR Coordinator | Read only | Full | Can assign tasks |
| Manager | None | View/Approve team tasks | Team oversight |
| IT/PIC | View templates | System/Asset tasks | Technical tasks |
| Staff | None | Own tasks only | Task completion |

## 🎯 Task Template Types

1. **General Task**: Free-form task with instructions
2. **Document Task**: Upload/acknowledge documents with optional e-signature
3. **Questionnaire**: Custom forms with multiple question types
4. **Meeting/Event**: Schedule meetings with confirmation
5. **System Access**: Grant/revoke system access
6. **Asset**: Issue/return company assets
7. **Checklist**: Multi-step tasks with sub-items

## 📈 KPIs Tracked

### Onboarding
- Overall Progress (%)
- Pending Documents
- Overdue Tasks
- New Hires This Month

### Offboarding
- Overall Progress (%)
- Pending Documents
- Overdue Tasks
- Exits This Month

## 🚧 Future Enhancements

- [ ] Task detail modal with all 7 task types
- [ ] Workflow visual builder (drag & drop)
- [ ] Real-time notifications
- [ ] Email/SMS integration
- [ ] Document e-signature
- [ ] Mobile app (native)
- [ ] Analytics & reporting
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Export/import functionality
- [ ] Integration with ATS systems

## 📝 Development Notes

### Component Conventions
- Use Composition API with `<script setup>`
- Props validation for all components
- Emit events for parent-child communication
- Use PrimeVue components where possible

### Styling Conventions
- Use CSS variables from design system
- Scoped styles in components
- BEM naming for custom classes
- Mobile-first media queries

### State Management
- Router for navigation state
- Pinia for complex state (when needed)
- Local state for component-specific data

## 🤝 Contributing

1. Follow Vue.js style guide
2. Use meaningful commit messages
3. Test on both desktop and mobile
4. Ensure accessibility compliance
5. Document new components

## 📄 License

Proprietary - TimeTec HR System

---

**Built with ❤️ using Vue.js 3, PrimeVue, and modern web technologies**
