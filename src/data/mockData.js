// Mock Data for HRMS Onboarding & Offboarding System

export const users = [
  {
    id: 1,
    name: 'Aina Zulkifli',
    email: 'aina.z@company.com',
    role: 'Product Designer',
    department: 'UX',
    status: 'active',
    avatar: null
  },
  {
    id: 2,
    name: 'Harith Rahman',
    email: 'harith.r@company.com',
    role: 'Backend Engineer',
    department: 'Engineering',
    status: 'active',
    avatar: null
  },
  {
    id: 3,
    name: 'Farah Kassim',
    email: 'farah.k@company.com',
    role: 'Manager',
    department: 'UX',
    status: 'active',
    avatar: null
  },
  {
    id: 4,
    name: 'Nizam Salleh',
    email: 'nizam.s@company.com',
    role: 'Engineering Manager',
    department: 'Engineering',
    status: 'active',
    avatar: null
  },
  {
    id: 5,
    name: 'Ahmed Fauzi',
    email: 'ahmed.f@company.com',
    role: 'HR Manager',
    department: 'HR',
    status: 'active',
    avatar: null
  }
]

export const preHires = [
  {
    id: 1,
    name: 'Aina Zulkifli',
    position: 'Product Designer',
    department: 'UX',
    startDate: '2025-09-15',
    personalEmail: 'aina.personal@gmail.com',
    emailStatus: 'not_issued',
    workflowId: null,
    appraisalTemplateId: null
  },
  {
    id: 2,
    name: 'Harith Rahman',
    position: 'Backend Engineer',
    department: 'Engineering',
    startDate: '2025-09-22',
    personalEmail: 'harith.personal@gmail.com',
    emailStatus: 'pending_activation',
    workflowId: 1,
    appraisalTemplateId: 1
  },
  {
    id: 3,
    name: 'Nur Iman',
    position: 'HR Executive',
    department: 'HR',
    startDate: '2025-10-01',
    personalEmail: 'nur.iman@gmail.com',
    emailStatus: 'activated',
    workflowId: 1,
    appraisalTemplateId: 1
  }
]

export const systems = [
  { id: 1, name: 'HRMS', description: 'Human Resource Management System' },
  { id: 2, name: 'Email (Google Workspace)', description: 'Email system' },
  { id: 3, name: 'Slack', description: 'Communication platform' },
  { id: 4, name: 'VPN', description: 'Virtual Private Network' },
  { id: 5, name: 'GitHub', description: 'Code repository' },
  { id: 6, name: 'Jira', description: 'Project management' },
  { id: 7, name: 'Finance ERP', description: 'Financial system' },
  { id: 8, name: 'BI Tool', description: 'Business Intelligence' }
]

export const accessLevels = ['Viewer', 'Contributor', 'Admin']

export const assetTypes = [
  { id: 1, name: 'Laptop', prefix: 'MBP' },
  { id: 2, name: 'Access Card', prefix: 'AC' },
  { id: 3, name: 'Phone', prefix: 'IP' },
  { id: 4, name: 'Monitor', prefix: 'DELL' }
]

export const assets = [
  {
    id: 1,
    type: 'Laptop',
    model: 'MacBook Pro 14',
    tag: 'MBP-14-2024-072',
    status: 'available'
  },
  {
    id: 2,
    type: 'Access Card',
    tag: 'AC-6671',
    status: 'issued'
  },
  {
    id: 3,
    type: 'Phone',
    model: 'iPhone 13',
    tag: 'IP13-221',
    status: 'available'
  },
  {
    id: 4,
    type: 'Monitor',
    model: 'Dell 27"',
    tag: 'DELL-27-8841',
    status: 'available'
  }
]

export const taskTypes = [
  { value: 'general', label: 'General Task — Free Text' },
  { value: 'document', label: 'Information/Document Form Task' },
  { value: 'questionnaire', label: 'Questionnaire Task' },
  { value: 'meeting', label: 'Meeting/Event Task' },
  { value: 'system_access', label: 'System / Access Task' },
  { value: 'asset', label: 'Asset Task' },
  { value: 'checklist', label: 'Checklist / Multi-step Task' }
]

export const taskTemplates = [
  {
    id: 1,
    name: 'Welcome Pack',
    description: 'Send welcome pack to new hire',
    type: 'general',
    indicator: 'onboarding',
    ownerRole: 'HR Admin',
    defaultAssignee: null,
    sla: 1,
    mandatory: true,
    dependencies: [],
    instructions: 'Prepare and send welcome pack containing company swag, handbook, and starter guide.',
    createdAt: '2025-08-15',
    updatedAt: '2025-08-20'
  },
  {
    id: 2,
    name: 'Read Employee Handbook',
    description: 'Review and acknowledge employee handbook',
    type: 'document',
    indicator: 'onboarding',
    ownerRole: 'Staff',
    defaultAssignee: null,
    sla: 3,
    mandatory: true,
    dependencies: [],
    acknowledgementType: 'sign_off',
    requireESign: true,
    attachments: ['Employee_Handbook_v3.pdf'],
    createdAt: '2025-08-15',
    updatedAt: '2025-08-20'
  },
  {
    id: 3,
    name: 'Day 1 Orientation',
    description: 'Attend first day orientation session',
    type: 'meeting',
    indicator: 'onboarding',
    ownerRole: 'HR Admin',
    defaultAssignee: null,
    sla: 0,
    mandatory: true,
    dependencies: [],
    mode: 'in_person',
    location: 'Meeting Room A',
    requireConfirmation: true,
    createdAt: '2025-08-15',
    updatedAt: '2025-08-20'
  },
  {
    id: 4,
    name: 'Grant Email & HRMS Access',
    description: 'Provision system access for new hire',
    type: 'system_access',
    indicator: 'onboarding',
    ownerRole: 'IT/PIC',
    defaultAssignee: null,
    sla: 2,
    mandatory: true,
    dependencies: [],
    systems: [2, 1],
    accessLevel: 'Contributor',
    action: 'grant',
    createdAt: '2025-08-15',
    updatedAt: '2025-08-20'
  },
  {
    id: 5,
    name: 'Issue Laptop & ID Card',
    description: 'Provide hardware and access card',
    type: 'asset',
    indicator: 'onboarding',
    ownerRole: 'IT/PIC',
    defaultAssignee: null,
    sla: 1,
    mandatory: true,
    dependencies: [],
    assetTypes: ['Laptop', 'Access Card'],
    action: 'issue',
    location: 'HQ IT Desk',
    createdAt: '2025-08-15',
    updatedAt: '2025-08-20'
  },
  {
    id: 6,
    name: 'Security & Compliance Quiz',
    description: 'Complete security awareness questionnaire',
    type: 'questionnaire',
    indicator: 'onboarding',
    ownerRole: 'Staff',
    defaultAssignee: null,
    sla: 5,
    mandatory: true,
    dependencies: [2],
    questions: [
      {
        id: 1,
        text: 'What should you do if you receive a suspicious email?',
        type: 'single_choice',
        options: ['Click the link', 'Reply to sender', 'Report to IT', 'Delete immediately'],
        correctAnswer: 2
      },
      {
        id: 2,
        text: 'Select all acceptable password practices:',
        type: 'multiple_choice',
        options: ['Use complex passwords', 'Share with team', 'Change regularly', 'Write on sticky note']
      }
    ],
    createdAt: '2025-08-15',
    updatedAt: '2025-08-20'
  },
  {
    id: 7,
    name: 'Exit Interview',
    description: 'Conduct exit interview with departing employee',
    type: 'meeting',
    indicator: 'offboarding',
    ownerRole: 'HR Admin',
    defaultAssignee: null,
    sla: 2,
    mandatory: true,
    dependencies: [],
    mode: 'in_person',
    requireConfirmation: true,
    createdAt: '2025-08-15',
    updatedAt: '2025-08-20'
  },
  {
    id: 8,
    name: 'Revoke Access & Collect Assets',
    description: 'Remove system access and collect company assets',
    type: 'checklist',
    indicator: 'offboarding',
    ownerRole: 'IT/PIC',
    defaultAssignee: null,
    sla: 3,
    mandatory: true,
    dependencies: [],
    items: [
      { id: 1, text: 'Revoke Email Access', owner: 'IT' },
      { id: 2, text: 'Revoke VPN Access', owner: 'IT' },
      { id: 3, text: 'Revoke GitHub Access', owner: 'IT' },
      { id: 4, text: 'Collect Laptop', owner: 'IT' },
      { id: 5, text: 'Collect Access Card', owner: 'IT' }
    ],
    createdAt: '2025-08-15',
    updatedAt: '2025-08-20'
  },
  {
    id: 9,
    name: 'Final Pay & Benefits Briefing',
    description: 'Explain final payment and benefits continuation',
    type: 'general',
    indicator: 'offboarding',
    ownerRole: 'HR Admin',
    defaultAssignee: null,
    sla: 2,
    mandatory: true,
    dependencies: [],
    instructions: 'Schedule meeting to discuss final pay, unused leave, benefits continuation, and exit paperwork.',
    createdAt: '2025-08-15',
    updatedAt: '2025-08-20'
  }
]

export const workflows = [
  {
    id: 1,
    name: 'Onboarding — Standard (HQ) v1.2',
    category: 'onboarding',
    version: '1.2',
    status: 'active',
    tasks: [1, 2, 3, 4, 5, 6],
    taskCount: 12,
    triggerType: 'hire_date',
    triggerOffset: 0,
    escalationDays: 2,
    updatedAt: '2025-08-20'
  },
  {
    id: 2,
    name: 'Offboarding — Voluntary Exit v1.0',
    category: 'offboarding',
    version: '1.0',
    status: 'active',
    tasks: [7, 8, 9],
    taskCount: 8,
    triggerType: 'resignation_date',
    triggerOffset: 0,
    escalationDays: 2,
    updatedAt: '2025-08-10'
  }
]

export const roles = [
  {
    id: 1,
    name: 'HR Admin',
    description: 'Full access to Configuration & Operation',
    permissions: {
      generalSettings: { create: true, read: true, update: true, delete: true },
      roles: { create: true, read: true, update: true, delete: true },
      taskTemplates: { create: true, read: true, update: true, delete: true },
      workflow: { create: true, read: true, update: true, delete: true },
      auditTrail: { create: false, read: true, update: false, delete: false },
      preHireEntry: { create: true, read: true, update: true, delete: true },
      dashboards: { create: false, read: true, update: false, delete: false },
      assignTasks: { create: true, read: true, update: true, delete: true }
    },
    updatedAt: '2025-08-15'
  },
  {
    id: 2,
    name: 'HR Coordinator',
    description: 'Operation + read of Configuration',
    permissions: {
      generalSettings: { create: false, read: true, update: false, delete: false },
      roles: { create: false, read: true, update: false, delete: false },
      taskTemplates: { create: false, read: true, update: false, delete: false },
      workflow: { create: false, read: true, update: false, delete: false },
      auditTrail: { create: false, read: true, update: false, delete: false },
      preHireEntry: { create: true, read: true, update: true, delete: false },
      dashboards: { create: false, read: true, update: false, delete: false },
      assignTasks: { create: true, read: true, update: true, delete: false }
    },
    updatedAt: '2025-08-15'
  },
  {
    id: 3,
    name: 'Manager',
    description: 'Operation (view/approve tasks assigned to team)',
    permissions: {
      generalSettings: { create: false, read: false, update: false, delete: false },
      roles: { create: false, read: false, update: false, delete: false },
      taskTemplates: { create: false, read: false, update: false, delete: false },
      workflow: { create: false, read: false, update: false, delete: false },
      auditTrail: { create: false, read: false, update: false, delete: false },
      preHireEntry: { create: false, read: true, update: false, delete: false },
      dashboards: { create: false, read: true, update: false, delete: false },
      assignTasks: { create: false, read: true, update: true, delete: false }
    },
    updatedAt: '2025-08-15'
  },
  {
    id: 4,
    name: 'IT/PIC',
    description: 'Operation (System/Access & Asset tasks)',
    permissions: {
      generalSettings: { create: false, read: false, update: false, delete: false },
      roles: { create: false, read: false, update: false, delete: false },
      taskTemplates: { create: false, read: true, update: false, delete: false },
      workflow: { create: false, read: false, update: false, delete: false },
      auditTrail: { create: false, read: false, update: false, delete: false },
      preHireEntry: { create: false, read: true, update: false, delete: false },
      dashboards: { create: false, read: true, update: false, delete: false },
      assignTasks: { create: false, read: true, update: true, delete: false }
    },
    updatedAt: '2025-08-15'
  },
  {
    id: 5,
    name: 'Staff (End User)',
    description: 'Operation (assigned tasks only)',
    permissions: {
      generalSettings: { create: false, read: false, update: false, delete: false },
      roles: { create: false, read: false, update: false, delete: false },
      taskTemplates: { create: false, read: false, update: false, delete: false },
      workflow: { create: false, read: false, update: false, delete: false },
      auditTrail: { create: false, read: false, update: false, delete: false },
      preHireEntry: { create: false, read: false, update: false, delete: false },
      dashboards: { create: false, read: true, update: false, delete: false },
      assignTasks: { create: false, read: true, update: true, delete: false }
    },
    updatedAt: '2025-08-15'
  }
]

export const auditTrail = [
  {
    id: 1,
    timestamp: '2025-08-20 10:12:34',
    actor: 'HR Admin',
    entity: 'Workflow',
    entityName: 'Onboarding — Standard',
    action: 'Update',
    before: 'v1.1',
    after: 'v1.2',
    sourceIp: '203.0.113.10'
  },
  {
    id: 2,
    timestamp: '2025-08-22 09:03:15',
    actor: 'IT Admin',
    entity: 'Task',
    entityName: 'Grant Email',
    action: 'Assign',
    before: null,
    after: 'azlan@company.com',
    sourceIp: '203.0.113.11'
  },
  {
    id: 3,
    timestamp: '2025-08-25 14:22:10',
    actor: 'HR Admin',
    entity: 'Task Template',
    entityName: 'Security Quiz',
    action: 'Create',
    before: null,
    after: 'New template',
    sourceIp: '203.0.113.10'
  }
]

export const generalSettings = {
  onboardingDuration: 45,
  offboardingDuration: 14,
  reminderCadence: 'every_3_days',
  businessDaysOnly: true,
  defaultAppraisalTemplate: 'Probation Appraisal v2',
  timezone: 'Asia/Kuala_Lumpur',
  locale: 'en-MY'
}

export const appraisalTemplates = [
  { id: 1, name: 'Probation Appraisal v2' },
  { id: 2, name: 'Annual Performance Review' },
  { id: 3, name: '90-Day Check-in' }
]
