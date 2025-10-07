# Quick Start Guide

## Getting Started in 5 Minutes

### 1. Access the Application

The development server is running at: **http://localhost:5179**

### 2. Navigate the System

The application automatically redirects to the **Onboarding Dashboard** on startup.

#### Navigation Menu

**Operation Section** (Left Sidebar):
- 📥 **Pre-Hire Entry** - Create new user accounts for pre-hires
- 📊 **Onboarding Dashboard** - Monitor onboarding progress
- 📤 **Offboarding Dashboard** - Track offboarding processes

**Configuration Section** (Left Sidebar):
- ⚙️ **General Settings** - System-wide configuration
- 🛡️ **User Roles** - Role-based access control
- 📋 **Task Templates** - Manage task template library
- 🔄 **Workflow Builder** - Create and manage workflows
- 📜 **Audit Trail** - View system change history

### 3. Key Features to Try

#### A. Create a New User Account
1. Navigate to **Operation → Pre-Hire Entry**
2. Find a candidate with "Not Issued" email status
3. Click **"Create User"** button
4. Fill in the user details:
   - Full Name
   - Personal Email
   - Hire Date
   - Manager
   - Location
   - Work Type
5. Click **"Create & Start Onboarding"**
6. Success! User account created and onboarding workflow initiated

#### B. View Onboarding Progress
1. Navigate to **Operation → Onboarding Dashboard**
2. View KPI Cards:
   - Overall Progress: 62%
   - Pending Documents: 7
   - Overdue Tasks: 3
   - New Hires This Month: 5
3. Check progress by new hire in the table
4. Filter tasks: "Assigned to Me", "Team", or "All"
5. Click **"View"** or **"Complete"** on any task

#### C. Configure System Settings
1. Navigate to **Configuration → General Settings**
2. Adjust settings:
   - Onboarding Duration: 45 days
   - Offboarding Duration: 14 days
   - Reminder Cadence: Every 3 days
   - Business Days Only: ON
3. Click **"Save Changes"**
4. See success toast notification

#### D. Browse Task Templates
1. Navigate to **Configuration → Task Templates**
2. Filter by Type or Indicator (Onboarding/Offboarding)
3. View the 9 predefined templates:
   - Welcome Pack (General Task)
   - Read Employee Handbook (Document Task)
   - Day 1 Orientation (Meeting Task)
   - Grant Email & HRMS Access (System Access Task)
   - Issue Laptop & ID Card (Asset Task)
   - Security Quiz (Questionnaire Task)
   - Exit Interview (Meeting Task)
   - Revoke Access & Collect Assets (Checklist Task)
   - Final Pay Briefing (General Task)

#### E. View Workflow Configurations
1. Navigate to **Configuration → Workflow**
2. See 2 active workflows:
   - **Onboarding — Standard (HQ) v1.2** (12 tasks)
   - **Offboarding — Voluntary Exit v1.0** (8 tasks)
3. Click actions to Edit, Duplicate, or View

#### F. Check Audit Trail
1. Navigate to **Configuration → Audit Trail**
2. Filter by:
   - Date Range
   - Actor (user)
   - Entity Type (Workflow, Task, etc.)
   - Action (Create, Update, Delete, etc.)
3. View detailed change history with before/after values

### 4. Mobile View

To test the mobile responsive layout:
1. Open DevTools (F12)
2. Toggle Device Toolbar (Ctrl+Shift+M)
3. Select a mobile device (e.g., iPhone 12)
4. Notice the bottom navigation bar
5. Tap icons to navigate between sections

### 5. UI Components Demo

The system showcases several custom UI components:

**StatCard** (KPI Cards):
```vue
<StatCard
  label="Overall Progress"
  value="62%"
  icon="pi-chart-line"
  color="#16A34A"
/>
```

**StatusChip** (Status Badges):
```vue
<StatusChip status="in_progress" />
<StatusChip status="completed" />
<StatusChip status="overdue" />
```

**ProgressBar**:
```vue
<ProgressBar :percentage="67" label="Progress" />
```

### 6. Sample Data

The application is pre-populated with realistic mock data:

**Users:**
- Aina Zulkifli (Product Designer)
- Harith Rahman (Backend Engineer)
- Farah Kassim (Manager)
- Nizam Salleh (Engineering Manager)
- Ahmed Fauzi (HR Manager - Current User)

**Pre-Hires:**
- Aina Zulkifli (Start: 2025-09-15, Status: Not Issued)
- Harith Rahman (Start: 2025-09-22, Status: Pending Activation)
- Nur Iman (Start: 2025-10-01, Status: Activated)

**New Hires:**
- Aina: 67% complete (8/12 tasks)
- Harith: 25% complete (3/12 tasks)
- Nur Iman: 8% complete (1/12 tasks)

**Leavers:**
- Zulkifli Hassan (Last Day: 2025-09-12, 56% complete)
- Siti Rahmah (Last Day: 2025-09-20, 25% complete)

### 7. Testing Features

#### Notifications
- Click the bell icon (🔔) in the top right
- View 3 sample notifications:
  - Task Overdue (unread)
  - Task Completed (unread)
  - New Pre-Hire (read)

#### User Menu
- Click your avatar in the top right
- View dropdown with:
  - Profile
  - Settings
  - Logout

#### Sidebar Toggle
- Click the collapse button (◀) at the bottom of the sidebar
- Sidebar collapses to icon-only mode
- Click again (▶) to expand

### 8. Design System Reference

**Colors:**
- Primary Blue: `#155EEF`
- Success Green: `#16A34A`
- Warning Orange: `#F59E0B`
- Danger Red: `#DC2626`
- Info Blue: `#0EA5E9`

**Spacing:**
- Base unit: 8px
- Small: 12px
- Medium: 16px
- Large: 24px

**Typography:**
- Display: 28px, Semibold
- H1: 24px, Semibold
- H2: 20px, Semibold
- Body: 14px, Regular

### 9. Development Commands

```bash
# Start dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### 10. Next Steps

To extend the application:

1. **Add Backend Integration:**
   - Create API client in `src/api/`
   - Update Pinia stores to fetch from API
   - Replace mock data with real API calls

2. **Implement Task Detail Modal:**
   - Create modal component for task details
   - Support all 7 task types
   - Add task completion forms

3. **Build Workflow Visual Builder:**
   - Drag & drop canvas
   - Task node components
   - Dependency connections

4. **Add Authentication:**
   - Login/logout functionality
   - JWT token management
   - Route guards based on roles

5. **Enhance Mobile App:**
   - Optimize for mobile
   - Add swipe gestures
   - Implement offline mode

## Tips & Tricks

- **Keyboard Shortcuts:** Use Tab for navigation, Enter to submit forms
- **Search:** Use the search bar in the sidebar to find modules quickly
- **Status Colors:**
  - 🟢 Green = Completed
  - 🔵 Blue = In Progress
  - 🟡 Yellow = Pending
  - 🔴 Red = Overdue
- **Responsive Design:** Test at different screen sizes (mobile, tablet, desktop)
- **Data Tables:** Click column headers to sort data

## Troubleshooting

**Issue:** Port already in use
**Solution:** Vite will automatically try the next available port (5174, 5175, etc.)

**Issue:** Components not rendering
**Solution:** Check browser console for errors, ensure all dependencies are installed

**Issue:** Styles not loading
**Solution:** Clear browser cache and restart dev server

## Support

For questions or issues:
1. Check the [README.md](README.md) for detailed documentation
2. Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
3. Inspect browser DevTools console for errors

---

**Enjoy exploring the TimeTec HR Onboarding & Offboarding System!** 🚀
