-- ============================================
-- TIMETEC HRV2 Onboarding/Offboarding System
-- Seed Data for Initial Setup
-- ============================================

-- ============================================
-- ROLES
-- ============================================

INSERT INTO roles (name, description, permissions) VALUES
('HR Admin', 'Full access to Configuration & Operation', '{
    "generalSettings": {"create": true, "read": true, "update": true, "delete": true},
    "roles": {"create": true, "read": true, "update": true, "delete": true},
    "taskTemplates": {"create": true, "read": true, "update": true, "delete": true},
    "workflow": {"create": true, "read": true, "update": true, "delete": true},
    "auditTrail": {"create": false, "read": true, "update": false, "delete": false},
    "preHireEntry": {"create": true, "read": true, "update": true, "delete": true},
    "dashboards": {"create": false, "read": true, "update": false, "delete": false},
    "assignTasks": {"create": true, "read": true, "update": true, "delete": true}
}'::jsonb),
('HR Coordinator', 'Operation + read of Configuration', '{
    "generalSettings": {"create": false, "read": true, "update": false, "delete": false},
    "roles": {"create": false, "read": true, "update": false, "delete": false},
    "taskTemplates": {"create": false, "read": true, "update": false, "delete": false},
    "workflow": {"create": false, "read": true, "update": false, "delete": false},
    "auditTrail": {"create": false, "read": true, "update": false, "delete": false},
    "preHireEntry": {"create": true, "read": true, "update": true, "delete": false},
    "dashboards": {"create": false, "read": true, "update": false, "delete": false},
    "assignTasks": {"create": true, "read": true, "update": true, "delete": false}
}'::jsonb),
('Manager', 'Operation (view/approve tasks assigned to team)', '{
    "generalSettings": {"create": false, "read": false, "update": false, "delete": false},
    "roles": {"create": false, "read": false, "update": false, "delete": false},
    "taskTemplates": {"create": false, "read": false, "update": false, "delete": false},
    "workflow": {"create": false, "read": false, "update": false, "delete": false},
    "auditTrail": {"create": false, "read": false, "update": false, "delete": false},
    "preHireEntry": {"create": false, "read": true, "update": false, "delete": false},
    "dashboards": {"create": false, "read": true, "update": false, "delete": false},
    "assignTasks": {"create": false, "read": true, "update": true, "delete": false}
}'::jsonb),
('IT/PIC', 'Operation (System/Access & Asset tasks)', '{
    "generalSettings": {"create": false, "read": false, "update": false, "delete": false},
    "roles": {"create": false, "read": false, "update": false, "delete": false},
    "taskTemplates": {"create": false, "read": true, "update": false, "delete": false},
    "workflow": {"create": false, "read": false, "update": false, "delete": false},
    "auditTrail": {"create": false, "read": false, "update": false, "delete": false},
    "preHireEntry": {"create": false, "read": true, "update": false, "delete": false},
    "dashboards": {"create": false, "read": true, "update": false, "delete": false},
    "assignTasks": {"create": false, "read": true, "update": true, "delete": false}
}'::jsonb),
('Staff (End User)', 'Operation (assigned tasks only)', '{
    "generalSettings": {"create": false, "read": false, "update": false, "delete": false},
    "roles": {"create": false, "read": false, "update": false, "delete": false},
    "taskTemplates": {"create": false, "read": false, "update": false, "delete": false},
    "workflow": {"create": false, "read": false, "update": false, "delete": false},
    "auditTrail": {"create": false, "read": false, "update": false, "delete": false},
    "preHireEntry": {"create": false, "read": false, "update": false, "delete": false},
    "dashboards": {"create": false, "read": true, "update": false, "delete": false},
    "assignTasks": {"create": false, "read": true, "update": true, "delete": false}
}'::jsonb);

-- ============================================
-- USERS
-- ============================================

INSERT INTO users (name, email, role_id, department, position, status) VALUES
('Ahmed Fauzi', 'ahmed.f@company.com', 1, 'HR', 'HR Manager', 'active'),
('Farah Kassim', 'farah.k@company.com', 2, 'HR', 'HR Coordinator', 'active'),
('Nizam Salleh', 'nizam.s@company.com', 3, 'Engineering', 'Engineering Manager', 'active'),
('Azlan Ibrahim', 'azlan.i@company.com', 4, 'IT', 'IT Administrator', 'active'),
('Aina Zulkifli', 'aina.z@company.com', 5, 'UX', 'Product Designer', 'active'),
('Harith Rahman', 'harith.r@company.com', 5, 'Engineering', 'Backend Engineer', 'active');

-- ============================================
-- SYSTEMS
-- ============================================

INSERT INTO systems (name, description, category, status) VALUES
('HRMS', 'Human Resource Management System', 'internal', 'active'),
('Email (Google Workspace)', 'Company email system', 'internal', 'active'),
('Slack', 'Team communication platform', 'internal', 'active'),
('VPN', 'Virtual Private Network access', 'internal', 'active'),
('GitHub', 'Code repository and version control', 'development', 'active'),
('Jira', 'Project management and issue tracking', 'development', 'active'),
('Finance ERP', 'Financial system', 'internal', 'active'),
('BI Tool', 'Business Intelligence and Analytics', 'internal', 'active');

-- ============================================
-- ASSET TYPES
-- ============================================

INSERT INTO asset_types (name, prefix, description) VALUES
('Laptop', 'MBP', 'MacBook Pro laptops'),
('Access Card', 'AC', 'Office access cards'),
('Phone', 'IP', 'Company mobile phones'),
('Monitor', 'DELL', 'External monitors');

-- ============================================
-- ASSETS
-- ============================================

INSERT INTO assets (type_id, tag, model, status) VALUES
(1, 'MBP-14-2024-072', 'MacBook Pro 14"', 'available'),
(1, 'MBP-14-2024-073', 'MacBook Pro 14"', 'available'),
(1, 'MBP-16-2024-045', 'MacBook Pro 16"', 'available'),
(2, 'AC-6671', NULL, 'issued'),
(2, 'AC-6672', NULL, 'available'),
(2, 'AC-6673', NULL, 'available'),
(3, 'IP13-221', 'iPhone 13', 'available'),
(3, 'IP13-222', 'iPhone 13', 'available'),
(4, 'DELL-27-8841', 'Dell 27"', 'available'),
(4, 'DELL-27-8842', 'Dell 27"', 'available');

-- ============================================
-- TASK TEMPLATES
-- ============================================

INSERT INTO task_templates (name, description, type, indicator, owner_role, sla_days, mandatory, instructions, configuration) VALUES
('Welcome Pack', 'Send welcome pack to new hire', 'general', 'onboarding', 'HR Admin', 1, true, 'Prepare and send welcome pack containing company swag, handbook, and starter guide.', NULL),
('Read Employee Handbook', 'Review and acknowledge employee handbook', 'document', 'onboarding', 'Staff', 3, true, NULL, '{"acknowledgementType": "sign_off", "requireESign": true, "attachments": ["Employee_Handbook_v3.pdf"]}'::jsonb),
('Day 1 Orientation', 'Attend first day orientation session', 'meeting', 'onboarding', 'HR Admin', 0, true, NULL, '{"mode": "in_person", "location": "Meeting Room A", "requireConfirmation": true}'::jsonb),
('Grant Email & HRMS Access', 'Provision system access for new hire', 'system_access', 'onboarding', 'IT/PIC', 2, true, NULL, '{"systems": [1, 2], "accessLevel": "Contributor", "action": "grant"}'::jsonb),
('Issue Laptop & ID Card', 'Provide hardware and access card', 'asset', 'onboarding', 'IT/PIC', 1, true, NULL, '{"assetTypes": ["Laptop", "Access Card"], "action": "issue", "location": "HQ IT Desk"}'::jsonb),
('Security & Compliance Quiz', 'Complete security awareness questionnaire', 'questionnaire', 'onboarding', 'Staff', 5, true, NULL, '{"questions": [{"id": 1, "text": "What should you do if you receive a suspicious email?", "type": "single_choice", "options": ["Click the link", "Reply to sender", "Report to IT", "Delete immediately"], "correctAnswer": 2}]}'::jsonb),
('Exit Interview', 'Conduct exit interview with departing employee', 'meeting', 'offboarding', 'HR Admin', 2, true, NULL, '{"mode": "in_person", "requireConfirmation": true}'::jsonb),
('Revoke Access & Collect Assets', 'Remove system access and collect company assets', 'checklist', 'offboarding', 'IT/PIC', 3, true, NULL, '{"items": [{"id": 1, "text": "Revoke Email Access", "owner": "IT"}, {"id": 2, "text": "Revoke VPN Access", "owner": "IT"}, {"id": 3, "text": "Collect Laptop", "owner": "IT"}, {"id": 4, "text": "Collect Access Card", "owner": "IT"}]}'::jsonb),
('Final Pay & Benefits Briefing', 'Explain final payment and benefits continuation', 'general', 'offboarding', 'HR Admin', 2, true, 'Schedule meeting to discuss final pay, unused leave, benefits continuation, and exit paperwork.', NULL);

-- ============================================
-- WORKFLOWS
-- ============================================

INSERT INTO workflows (name, category, version, status, trigger_type, trigger_offset, escalation_days, created_by) VALUES
('Onboarding — Standard (HQ) v1.2', 'onboarding', '1.2', 'active', 'hire_date', 0, 2, 1),
('Onboarding — Remote Employee v1.0', 'onboarding', '1.0', 'active', 'hire_date', -3, 1, 1),
('Onboarding — Executive/Senior Leadership v2.0', 'onboarding', '2.0', 'active', 'hire_date', -7, 1, 1),
('Offboarding — Voluntary Exit v1.0', 'offboarding', '1.0', 'active', 'resignation_date', 0, 2, 1),
('Offboarding — Retirement Exit v1.1', 'offboarding', '1.1', 'active', 'resignation_date', -30, 3, 1),
('Offboarding — Contract End (No Renewal) v1.0', 'offboarding', '1.0', 'draft', 'termination_date', -14, 2, 1);

-- ============================================
-- WORKFLOW PHASES (Onboarding Workflows)
-- ============================================

INSERT INTO workflow_phases (workflow_id, phase_id, phase_name, phase_description, sequence_order) VALUES
-- Workflow 1: Standard Onboarding
(1, 'pre-onboarding', 'Pre-Onboarding', 'Tasks before the employee starts', 1),
(1, 'first-day-onboarding', 'First-day Onboarding', 'Welcome and orientation tasks', 2),
(1, 'next-day-onboarding', 'Next day Onboarding', 'Follow-up tasks after first day', 3),
-- Workflow 2: Remote Employee
(2, 'pre-onboarding', 'Pre-Onboarding', 'Tasks before the employee starts', 1),
(2, 'first-day-onboarding', 'First-day Onboarding', 'Welcome and orientation tasks', 2),
(2, 'next-day-onboarding', 'Next day Onboarding', 'Follow-up tasks after first day', 3),
-- Workflow 3: Executive
(3, 'pre-onboarding', 'Pre-Onboarding', 'Tasks before the employee starts', 1),
(3, 'first-day-onboarding', 'First-day Onboarding', 'Welcome and orientation tasks', 2),
(3, 'next-day-onboarding', 'Next day Onboarding', 'Follow-up tasks after first day', 3);

-- ============================================
-- WORKFLOW PHASES (Offboarding Workflows)
-- ============================================

INSERT INTO workflow_phases (workflow_id, phase_id, phase_name, phase_description, sequence_order) VALUES
-- Workflow 4: Voluntary Exit
(4, 'pre-offboarding', 'Pre-Offboarding', 'Tasks during notice period and preparation', 1),
(4, 'last-day', 'Last Day', 'Exit formalities and handover', 2),
(4, 'post-offboarding', 'Post Offboarding', 'Follow-up after departure', 3),
-- Workflow 5: Retirement
(5, 'pre-offboarding', 'Pre-Offboarding', 'Tasks during notice period and preparation', 1),
(5, 'last-day', 'Last Day', 'Exit formalities and handover', 2),
(5, 'post-offboarding', 'Post Offboarding', 'Follow-up after departure', 3),
-- Workflow 6: Contract End
(6, 'pre-offboarding', 'Pre-Offboarding', 'Tasks during notice period and preparation', 1),
(6, 'last-day', 'Last Day', 'Exit formalities and handover', 2),
(6, 'post-offboarding', 'Post Offboarding', 'Follow-up after departure', 3);

-- ============================================
-- WORKFLOW TASKS (Sample for Workflow 1: Standard Onboarding)
-- ============================================

INSERT INTO workflow_tasks (workflow_id, phase_id, task_template_id, assignee_role, sequence_order, trigger_type, trigger_config) VALUES
-- Pre-Onboarding phase
(1, 'pre-onboarding', 1, 'HR Admin', 1, 'date_offset', '{"days": 3, "timeUnit": "days", "beforeAfter": "before", "referenceDate": "hire_date"}'::jsonb),
(1, 'pre-onboarding', 4, 'IT/PIC', 2, 'date_offset', '{"days": 1, "timeUnit": "days", "beforeAfter": "before", "referenceDate": "hire_date"}'::jsonb),
-- First-day Onboarding phase
(1, 'first-day-onboarding', 3, 'HR Admin', 3, 'hire_date', NULL),
(1, 'first-day-onboarding', 5, 'IT/PIC', 4, 'hire_date', NULL),
-- Next day Onboarding phase
(1, 'next-day-onboarding', 2, 'Staff', 5, 'date_offset', '{"days": 1, "timeUnit": "days", "beforeAfter": "after", "referenceDate": "hire_date"}'::jsonb),
(1, 'next-day-onboarding', 6, 'Staff', 6, 'previous_task', '{"dependentTaskId": 2}'::jsonb);

-- ============================================
-- GENERAL SETTINGS
-- ============================================

INSERT INTO general_settings (setting_key, setting_value, setting_type, description) VALUES
('onboarding_duration', '45', 'integer', 'Default onboarding duration in days'),
('offboarding_duration', '14', 'integer', 'Default offboarding duration in days'),
('reminder_cadence', 'every_3_days', 'string', 'How often to send reminders'),
('business_days_only', 'true', 'boolean', 'Count business days only'),
('default_appraisal_template', 'Probation Appraisal v2', 'string', 'Default appraisal template'),
('timezone', 'Asia/Kuala_Lumpur', 'string', 'System timezone'),
('locale', 'en-MY', 'string', 'System locale');

-- ============================================
-- SAMPLE PRE-HIRE DATA
-- ============================================

INSERT INTO pre_hires (name, position, department, start_date, personal_email, workflow_id, created_by) VALUES
('Aina Zulkifli', 'Product Designer', 'UX', '2025-09-15', 'aina.personal@gmail.com', NULL, 1),
('Harith Rahman', 'Backend Engineer', 'Engineering', '2025-09-22', 'harith.personal@gmail.com', 1, 1),
('Nur Iman', 'HR Executive', 'HR', '2025-10-01', 'nur.iman@gmail.com', 1, 1);
