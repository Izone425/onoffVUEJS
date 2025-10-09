# Database Setup Guide

## Prerequisites

- PostgreSQL 12 or higher installed
- PostgreSQL command-line tools (psql)
- Database admin credentials

## Quick Setup

### 1. Create Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE timetec_hrv2;

# Connect to the new database
\c timetec_hrv2

# Exit psql
\q
```

### 2. Run Schema Migration

```bash
# Run the schema file
psql -U postgres -d timetec_hrv2 -f database/schema.sql
```

### 3. Load Seed Data

```bash
# Run the seed file
psql -U postgres -d timetec_hrv2 -f database/seed.sql
```

### 4. Configure Environment

```bash
# Copy the example env file
cp .env.example .env

# Edit .env with your database credentials
# Update DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
```

## Database Structure

### Core Tables

#### Users & Authentication
- `roles` - User roles and permissions
- `users` - System users with role assignments

#### Task Management
- `task_templates` - Reusable task templates
- `task_instances` - Actual tasks assigned to employees
- `task_comments` - Comments on tasks
- `task_attachments` - File attachments for tasks

#### Workflow Management
- `workflows` - Workflow definitions
- `workflow_phases` - Phases within workflows (Pre-Onboarding, First Day, etc.)
- `workflow_tasks` - Tasks configured in workflows
- `employee_workflows` - Workflow instances for employees

#### Employee Processing
- `pre_hires` - Pre-hire employee records
- `employee_workflows` - Employee onboarding/offboarding process tracking

#### System Resources
- `systems` - System access (HRMS, Email, etc.)
- `assets` - Company assets (Laptops, Access Cards, etc.)
- `asset_types` - Asset categories
- `system_access_logs` - Access grant/revoke logs
- `asset_assignments` - Asset issue/return tracking

#### Configuration
- `general_settings` - System-wide settings
- `audit_logs` - Audit trail for all changes

## Default Accounts

After running the seed data, the following users will be available:

| Email | Role | Department |
|-------|------|------------|
| ahmed.f@company.com | HR Admin | HR |
| farah.k@company.com | HR Coordinator | HR |
| nizam.s@company.com | Manager | Engineering |
| azlan.i@company.com | IT/PIC | IT |
| aina.z@company.com | Staff | UX |
| harith.r@company.com | Staff | Engineering |

**Note:** Default passwords should be set up through your authentication system.

## Sample Workflows

The seed data includes 6 pre-configured workflows:

### Onboarding Workflows
1. **Standard (HQ) v1.2** - Standard office-based onboarding
2. **Remote Employee v1.0** - Remote/hybrid worker onboarding
3. **Executive/Senior Leadership v2.0** - Senior hire onboarding

### Offboarding Workflows
4. **Voluntary Exit v1.0** - Standard resignation process
5. **Retirement Exit v1.1** - Retirement scenario
6. **Contract End (No Renewal) v1.0** - Contract worker exit

## Database Maintenance

### Backup Database

```bash
pg_dump -U postgres -d timetec_hrv2 > backup_$(date +%Y%m%d).sql
```

### Restore Database

```bash
psql -U postgres -d timetec_hrv2 < backup_20250101.sql
```

### Reset Database

```bash
# Drop and recreate
psql -U postgres -c "DROP DATABASE IF EXISTS timetec_hrv2;"
psql -U postgres -c "CREATE DATABASE timetec_hrv2;"

# Run migrations
psql -U postgres -d timetec_hrv2 -f database/schema.sql
psql -U postgres -d timetec_hrv2 -f database/seed.sql
```

## Indexes

The schema includes optimized indexes for:
- User lookups by email, role, status
- Task filtering by status, assignee, due date
- Workflow queries by category, status
- Audit log searches by timestamp, entity, actor

## Triggers

Automatic triggers are configured for:
- `updated_at` timestamp updates on all major tables
- Maintains data consistency automatically

## Security Considerations

1. **Never commit `.env` file** - Contains sensitive credentials
2. **Use strong passwords** for database users
3. **Enable SSL** for production database connections
4. **Regular backups** - Schedule automated backups
5. **Restrict access** - Use proper PostgreSQL user permissions

## Troubleshooting

### Connection Issues

```bash
# Test connection
psql -U postgres -h localhost -p 5432 -d timetec_hrv2

# Check PostgreSQL status
sudo systemctl status postgresql  # Linux
brew services list | grep postgresql  # macOS
```

### Permission Issues

```bash
# Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE timetec_hrv2 TO your_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_user;
```

### View Table Structure

```sql
-- List all tables
\dt

-- Describe a table
\d task_templates

-- View indexes
\di

-- View table data
SELECT * FROM users LIMIT 5;
```

## Migration Scripts

For future database updates, create numbered migration files:

```
database/
  migrations/
    001_add_email_verification.sql
    002_add_notification_preferences.sql
```

Apply migrations in order:

```bash
psql -U postgres -d timetec_hrv2 -f database/migrations/001_add_email_verification.sql
```

## Contact

For database-related issues or questions, contact the development team.
