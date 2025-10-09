-- ============================================
-- TIMETEC HRV2 Onboarding/Offboarding System
-- PostgreSQL Database Schema
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS & ROLES
-- ============================================

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    permissions JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    personal_email VARCHAR(255),
    password_hash VARCHAR(255),
    role_id INTEGER REFERENCES roles(id),
    department VARCHAR(100),
    position VARCHAR(100),
    avatar_url TEXT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- SYSTEMS & ASSETS
-- ============================================

CREATE TABLE systems (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE asset_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    prefix VARCHAR(20),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE assets (
    id SERIAL PRIMARY KEY,
    type_id INTEGER REFERENCES asset_types(id),
    tag VARCHAR(100) NOT NULL UNIQUE,
    model VARCHAR(255),
    serial_number VARCHAR(255),
    status VARCHAR(50) DEFAULT 'available',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TASK TEMPLATES
-- ============================================

CREATE TABLE task_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL, -- general, document, questionnaire, meeting, system_access, asset, checklist
    indicator VARCHAR(50) NOT NULL, -- onboarding, offboarding
    owner_role VARCHAR(100),
    default_assignee_id INTEGER REFERENCES users(id),
    sla_days INTEGER DEFAULT 0,
    mandatory BOOLEAN DEFAULT false,
    instructions TEXT,
    configuration JSONB, -- stores type-specific config (systems, assets, questions, etc.)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- WORKFLOWS
-- ============================================

CREATE TABLE workflows (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL, -- onboarding, offboarding
    version VARCHAR(20) DEFAULT '1.0',
    status VARCHAR(50) DEFAULT 'draft', -- draft, active, archived
    trigger_type VARCHAR(50),
    trigger_offset INTEGER DEFAULT 0,
    escalation_days INTEGER DEFAULT 2,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE workflow_phases (
    id SERIAL PRIMARY KEY,
    workflow_id INTEGER REFERENCES workflows(id) ON DELETE CASCADE,
    phase_id VARCHAR(50) NOT NULL,
    phase_name VARCHAR(100) NOT NULL,
    phase_description TEXT,
    sequence_order INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE workflow_tasks (
    id SERIAL PRIMARY KEY,
    workflow_id INTEGER REFERENCES workflows(id) ON DELETE CASCADE,
    phase_id VARCHAR(50) NOT NULL,
    task_template_id INTEGER REFERENCES task_templates(id),
    assignee_id INTEGER REFERENCES users(id),
    assignee_role VARCHAR(100),
    sequence_order INTEGER NOT NULL,
    trigger_type VARCHAR(50), -- hire_date, date_offset, previous_task, etc.
    trigger_config JSONB, -- stores trigger-specific configuration
    completion_config JSONB, -- stores completion deadline configuration
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- PRE-HIRE & EMPLOYEE PROCESSING
-- ============================================

CREATE TABLE pre_hires (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    position VARCHAR(100),
    department VARCHAR(100),
    start_date DATE,
    personal_email VARCHAR(255),
    phone_number VARCHAR(50),
    email_status VARCHAR(50) DEFAULT 'not_issued', -- not_issued, pending_activation, activated
    workflow_id INTEGER REFERENCES workflows(id),
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE employee_workflows (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    pre_hire_id INTEGER REFERENCES pre_hires(id),
    workflow_id INTEGER REFERENCES workflows(id),
    workflow_type VARCHAR(50) NOT NULL, -- onboarding, offboarding
    status VARCHAR(50) DEFAULT 'pending', -- pending, in_progress, completed, cancelled
    start_date DATE,
    end_date DATE,
    resignation_date DATE,
    termination_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TASK INSTANCES
-- ============================================

CREATE TABLE task_instances (
    id SERIAL PRIMARY KEY,
    employee_workflow_id INTEGER REFERENCES employee_workflows(id) ON DELETE CASCADE,
    task_template_id INTEGER REFERENCES task_templates(id),
    phase_id VARCHAR(50),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    assignee_id INTEGER REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending', -- pending, in_progress, completed, overdue, cancelled
    priority VARCHAR(50) DEFAULT 'normal',
    due_date DATE,
    trigger_date DATE,
    completed_at TIMESTAMP,
    completed_by INTEGER REFERENCES users(id),
    notes TEXT,
    configuration JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE task_comments (
    id SERIAL PRIMARY KEY,
    task_instance_id INTEGER REFERENCES task_instances(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id),
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE task_attachments (
    id SERIAL PRIMARY KEY,
    task_instance_id INTEGER REFERENCES task_instances(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),
    uploaded_by INTEGER REFERENCES users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- SYSTEM ACCESS & ASSET TRACKING
-- ============================================

CREATE TABLE system_access_logs (
    id SERIAL PRIMARY KEY,
    task_instance_id INTEGER REFERENCES task_instances(id),
    user_id INTEGER REFERENCES users(id),
    system_id INTEGER REFERENCES systems(id),
    action VARCHAR(50) NOT NULL, -- grant, revoke
    access_level VARCHAR(100),
    performed_by INTEGER REFERENCES users(id),
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE asset_assignments (
    id SERIAL PRIMARY KEY,
    task_instance_id INTEGER REFERENCES task_instances(id),
    asset_id INTEGER REFERENCES assets(id),
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(50) NOT NULL, -- issue, collect
    assigned_at TIMESTAMP,
    returned_at TIMESTAMP,
    condition_notes TEXT,
    performed_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- AUDIT TRAIL
-- ============================================

CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actor_id INTEGER REFERENCES users(id),
    actor_name VARCHAR(255),
    entity_type VARCHAR(100) NOT NULL,
    entity_id INTEGER,
    entity_name VARCHAR(255),
    action VARCHAR(100) NOT NULL,
    before_value TEXT,
    after_value TEXT,
    source_ip VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- GENERAL SETTINGS
-- ============================================

CREATE TABLE general_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type VARCHAR(50) DEFAULT 'string',
    description TEXT,
    updated_by INTEGER REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_status ON users(status);

CREATE INDEX idx_task_templates_type ON task_templates(type);
CREATE INDEX idx_task_templates_indicator ON task_templates(indicator);

CREATE INDEX idx_workflows_category ON workflows(category);
CREATE INDEX idx_workflows_status ON workflows(status);

CREATE INDEX idx_workflow_tasks_workflow ON workflow_tasks(workflow_id);
CREATE INDEX idx_workflow_tasks_template ON workflow_tasks(task_template_id);

CREATE INDEX idx_employee_workflows_user ON employee_workflows(user_id);
CREATE INDEX idx_employee_workflows_workflow ON employee_workflows(workflow_id);
CREATE INDEX idx_employee_workflows_status ON employee_workflows(status);

CREATE INDEX idx_task_instances_employee_workflow ON task_instances(employee_workflow_id);
CREATE INDEX idx_task_instances_assignee ON task_instances(assignee_id);
CREATE INDEX idx_task_instances_status ON task_instances(status);
CREATE INDEX idx_task_instances_due_date ON task_instances(due_date);

CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_id);

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_task_templates_updated_at BEFORE UPDATE ON task_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflows_updated_at BEFORE UPDATE ON workflows
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pre_hires_updated_at BEFORE UPDATE ON pre_hires
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employee_workflows_updated_at BEFORE UPDATE ON employee_workflows
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_task_instances_updated_at BEFORE UPDATE ON task_instances
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
