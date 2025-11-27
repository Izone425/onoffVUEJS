<template>
  <div class="onboarding-dashboard">
    <!-- Progress by New Hire Page View -->
    <template v-if="showProgressByNewHire">
      <div class="page-header">
        <div class="header-left">
          <Button
            icon="pi pi-arrow-left"
            label="Back to Dashboard"
            severity="secondary"
            outlined
            size="small"
            @click="showProgressByNewHire = false; resetProgressFilters()"
          />
          <div class="header-text">
            <h1 class="page-title">Onboarding Progress</h1>
            <p class="page-subtitle">Comprehensive view of all new hires and their onboarding progress</p>
          </div>
        </div>
        <div class="header-actions">
          <Button
            icon="pi pi-building"
            :label="`Companies (${selectedCompanies.length})`"
            severity="secondary"
            outlined
            @click="toggleCompanyFilter"
          />
          <Popover ref="companyFilterPopover">
            <div class="company-filter-content">
              <div class="filter-title">Select Companies</div>
              <div v-for="company in companies" :key="company.id" class="filter-item">
                <Checkbox v-model="selectedCompanies" :inputId="company.id" :value="company.id" />
                <label :for="company.id">{{ company.name }}</label>
              </div>
            </div>
          </Popover>
        </div>
      </div>

      <!-- Progress View Card -->
      <div class="content-card">
        <div class="card-header">
          <div class="tabs-container">
            <TabView v-model:activeIndex="progressViewTab">
              <TabPanel header="By Employee" />
              <TabPanel header="By Task" />
            </TabView>
          </div>
        </div>

        <!-- By Employee Tab Content -->
        <div v-if="progressViewTab === 0" class="tab-content">
          <!-- Filters -->
          <div class="filter-section">
            <div class="filter-header">
              <span class="filter-label">Filter & Search</span>
              <Button
                v-if="progressSearchQuery || progressStageFilter !== 'all' || progressStatusFilter !== 'all'"
                icon="pi pi-times"
                label="Clear Filters"
                text
                size="small"
                @click="resetProgressFilters"
              />
            </div>
            <div class="filter-controls">
              <InputText v-model="progressSearchQuery" placeholder="Search by employee name or manager..." class="search-input" />
              <Dropdown
                v-model="progressStageFilter"
                :options="stageFilterOptions"
                optionLabel="label"
                optionValue="value"
                placeholder="All Stages"
                class="filter-dropdown"
              />
              <Dropdown
                v-model="progressStatusFilter"
                :options="statusFilterOptions"
                optionLabel="label"
                optionValue="value"
                placeholder="All Statuses"
                class="filter-dropdown"
              />
            </div>
          </div>

          <!-- Employee Progress Table -->
          <DataTable :value="progressFilteredNewHires" stripedRows tableStyle="width: 100%" class="progress-table-fit">
            <Column field="name" header="Employee" sortable style="width: 15%">
              <template #body="{ data }">
                <span class="font-medium">{{ data.name }}</span>
              </template>
            </Column>
            <Column field="company" header="Company" sortable style="width: 12%">
              <template #body="{ data }">
                <Tag :value="getCompanyName(data.company)" severity="secondary" />
              </template>
            </Column>
            <Column field="manager" header="Manager" sortable style="width: 13%" />
            <Column field="currentStage" header="Stage" sortable style="width: 14%">
              <template #body="{ data }">
                <Tag :value="data.currentStage" :severity="getStageSeverity(data.currentStage)" />
              </template>
            </Column>
            <Column header="Progress" style="width: 14%">
              <template #body="{ data }">
                <div class="progress-cell">
                  <ProgressBar :value="data.progress" :showValue="false" style="height: 6px; flex: 1; min-width: 50px;" />
                  <span class="progress-percentage">{{ data.progress }}%</span>
                </div>
              </template>
            </Column>
            <Column header="Tasks" style="width: 8%">
              <template #body="{ data }">
                <span class="tasks-count-cell">{{ data.completedTasks }}/{{ data.totalTasks }}</span>
              </template>
            </Column>
            <Column header="Status" style="width: 10%">
              <template #body="{ data }">
                <StatusChip :status="normalizeStatus(data.status)" />
              </template>
            </Column>
            <Column header="Action" style="width: 14%">
              <template #body="{ data }">
                <Button
                  icon="pi pi-eye"
                  label="View Tasks"
                  text
                  size="small"
                  @click="viewEmployeeTasks(data)"
                />
              </template>
            </Column>
            <template #empty>
              <div class="empty-state">No new hires match the selected filters</div>
            </template>
          </DataTable>
        </div>

        <!-- By Task Tab Content -->
        <div v-if="progressViewTab === 1" class="tab-content">
          <!-- Filters -->
          <div class="filter-section">
            <div class="filter-header">
              <span class="filter-label">Filter & Search</span>
              <Button
                v-if="progressSearchQuery || progressStatusFilter !== 'all'"
                icon="pi pi-times"
                label="Clear Filters"
                text
                size="small"
                @click="progressSearchQuery = ''; progressStatusFilter = 'all'"
              />
            </div>
            <div class="filter-controls">
              <InputText v-model="progressSearchQuery" placeholder="Search by task name..." class="search-input" />
              <Dropdown
                v-model="progressStatusFilter"
                :options="taskStatusFilterOptions"
                optionLabel="label"
                optionValue="value"
                placeholder="All Statuses"
                class="filter-dropdown"
              />
            </div>
          </div>

          <!-- Task Stage Tabs -->
          <TabView v-model:activeIndex="taskStageTab" class="task-stage-tabs">
            <TabPanel header="Pre-Onboarding">
              <DataTable :value="getTasksByStage('Pre-Onboarding')" stripedRows responsiveLayout="scroll">
                <Column field="task" header="Task Name" sortable style="min-width: 200px">
                  <template #body="{ data }">
                    <span class="font-medium">{{ data.task }}</span>
                  </template>
                </Column>
                <Column field="type" header="Type" sortable style="min-width: 140px">
                  <template #body="{ data }">
                    <Tag :value="data.type" severity="secondary" />
                  </template>
                </Column>
                <Column field="company" header="Company" sortable style="min-width: 140px">
                  <template #body="{ data }">
                    <Tag :value="getCompanyName(data.company)" severity="secondary" />
                  </template>
                </Column>
                <Column header="Actions" style="min-width: 120px">
                  <template #body="{ data }">
                    <Button
                      icon="pi pi-eye"
                      label="View Details"
                      text
                      size="small"
                      @click="openTaskEmployeesDrawer(data)"
                    />
                  </template>
                </Column>
                <template #empty>
                  <div class="empty-state">No Pre-Onboarding tasks found</div>
                </template>
              </DataTable>
            </TabPanel>
            <TabPanel header="1st Day-Onboarding">
              <DataTable :value="getTasksByStage('1st Day-Onboarding')" stripedRows responsiveLayout="scroll">
                <Column field="task" header="Task Name" sortable style="min-width: 200px">
                  <template #body="{ data }">
                    <span class="font-medium">{{ data.task }}</span>
                  </template>
                </Column>
                <Column field="type" header="Type" sortable style="min-width: 140px">
                  <template #body="{ data }">
                    <Tag :value="data.type" severity="secondary" />
                  </template>
                </Column>
                <Column field="company" header="Company" sortable style="min-width: 140px">
                  <template #body="{ data }">
                    <Tag :value="getCompanyName(data.company)" severity="secondary" />
                  </template>
                </Column>
                <Column header="Actions" style="min-width: 120px">
                  <template #body="{ data }">
                    <Button
                      icon="pi pi-eye"
                      label="View Details"
                      text
                      size="small"
                      @click="openTaskEmployeesDrawer(data)"
                    />
                  </template>
                </Column>
                <template #empty>
                  <div class="empty-state">No 1st Day-Onboarding tasks found</div>
                </template>
              </DataTable>
            </TabPanel>
            <TabPanel header="Next Day-Onboarding">
              <DataTable :value="getTasksByStage('Next Day-Onboarding')" stripedRows responsiveLayout="scroll">
                <Column field="task" header="Task Name" sortable style="min-width: 200px">
                  <template #body="{ data }">
                    <span class="font-medium">{{ data.task }}</span>
                  </template>
                </Column>
                <Column field="type" header="Type" sortable style="min-width: 140px">
                  <template #body="{ data }">
                    <Tag :value="data.type" severity="secondary" />
                  </template>
                </Column>
                <Column field="company" header="Company" sortable style="min-width: 140px">
                  <template #body="{ data }">
                    <Tag :value="getCompanyName(data.company)" severity="secondary" />
                  </template>
                </Column>
                <Column header="Actions" style="min-width: 120px">
                  <template #body="{ data }">
                    <Button
                      icon="pi pi-eye"
                      label="View Details"
                      text
                      size="small"
                      @click="openTaskEmployeesDrawer(data)"
                    />
                  </template>
                </Column>
                <template #empty>
                  <div class="empty-state">No Next Day-Onboarding tasks found</div>
                </template>
              </DataTable>
            </TabPanel>
          </TabView>
        </div>
      </div>
    </template>

    <!-- Employee Tasks Page View -->
    <template v-else-if="showEmployeeTasksPage && selectedEmployee">
      <div class="page-header">
        <div class="header-left">
          <Button
            icon="pi pi-arrow-left"
            label="Back to Progress"
            severity="secondary"
            outlined
            size="small"
            @click="showEmployeeTasksPage = false; selectedEmployee = null"
          />
          <div class="header-text">
            <h1 class="page-title">Tasks for {{ selectedEmployee.name }}</h1>
            <p class="page-subtitle">View and manage all onboarding tasks assigned to this employee</p>
          </div>
        </div>
        <Button icon="pi pi-plus" label="Add Task" @click="isAddTaskDrawerOpen = true" />
      </div>

      <!-- Employee Summary Card -->
      <div class="employee-summary-card">
        <div class="summary-item">
          <span class="summary-label">Reporting Manager</span>
          <span class="summary-value">{{ selectedEmployee.manager }}</span>
        </div>
        <div class="summary-item">
          <span class="summary-label">Current Stage</span>
          <Tag :value="selectedEmployee.currentStage" severity="info" />
        </div>
        <div class="summary-item">
          <span class="summary-label">Overall Progress</span>
          <div class="progress-cell">
            <ProgressBar :value="selectedEmployee.progress" :showValue="false" style="height: 8px; width: 100px;" />
            <span class="progress-percentage">{{ selectedEmployee.progress }}%</span>
          </div>
        </div>
      </div>

      <!-- Tasks Grid by Stage -->
      <div class="tasks-stage-grid">
        <div v-for="stage in onboardingStages" :key="stage" class="stage-column">
          <div class="stage-header">
            <div class="stage-title">
              <i :class="getStageIcon(stage)" :style="{ color: getStageColor(stage) }"></i>
              <span>{{ stage }}</span>
            </div>
            <Tag :value="getEmployeeTasksByStage(stage).length" severity="secondary" />
          </div>
          <div class="stage-tasks">
            <div
              v-for="task in getEmployeeTasksByStage(stage)"
              :key="task.id"
              class="task-card"
              @click="openTaskDetailsDrawer(task)"
            >
              <div class="task-card-header">
                <i :class="getTaskStatusIcon(task.status)" :style="{ color: getTaskStatusColor(task.status) }"></i>
                <span class="task-title">{{ task.task }}</span>
              </div>
              <div class="task-card-details">
                <Tag :value="task.type" severity="secondary" class="task-type-tag" />
                <StatusChip :status="normalizeStatus(task.status)" />
              </div>
              <div class="task-card-meta">
                <span><i class="pi pi-user"></i> {{ task.assignedTo }}</span>
                <span><i class="pi pi-calendar"></i> {{ task.due }}</span>
              </div>
              <div class="task-card-actions" @click.stop>
                <Button
                  v-if="task.status !== 'completed'"
                  icon="pi pi-bell"
                  severity="info"
                  text
                  rounded
                  size="small"
                  @click="sendReminder(task)"
                />
                <Button
                  v-if="task.status !== 'completed'"
                  icon="pi pi-check-circle"
                  severity="success"
                  text
                  rounded
                  size="small"
                  @click="completeTask(task)"
                />
                <Button
                  v-if="task.status !== 'completed'"
                  icon="pi pi-trash"
                  severity="danger"
                  text
                  rounded
                  size="small"
                  @click="deleteTask(task)"
                />
                <Button
                  v-if="task.status === 'completed'"
                  icon="pi pi-refresh"
                  severity="warning"
                  text
                  rounded
                  size="small"
                  @click="resetTask(task)"
                />
              </div>
            </div>
            <div v-if="getEmployeeTasksByStage(stage).length === 0" class="empty-tasks">
              No tasks
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- Main Dashboard View -->
    <template v-else>
      <!-- Dashboard Header -->
      <div class="dashboard-header">
        <div>
          <h1 class="dashboard-title">Onboarding Dashboard</h1>
          <p class="dashboard-subtitle">Track new hire progress and manage onboarding tasks</p>
        </div>
        <div class="header-actions" v-if="currentUserRole !== 'Staff'">
          <Button
            icon="pi pi-building"
            :label="`Companies (${selectedCompanies.length})`"
            severity="secondary"
            outlined
            @click="toggleCompanyFilter"
          />
          <Popover ref="companyFilterPopover">
            <div class="company-filter-content">
              <div class="filter-title">Select Companies</div>
              <div v-for="company in companies" :key="company.id" class="filter-item">
                <Checkbox v-model="selectedCompanies" :inputId="company.id" :value="company.id" />
                <label :for="company.id">{{ company.name }}</label>
              </div>
            </div>
          </Popover>
          <Button icon="pi pi-users" label="Assign Onboarding Workflow" @click="isAssignDrawerOpen = true" />
        </div>
      </div>

      <!-- KPI Cards Grid -->
      <div class="kpi-grid">
        <!-- Overall Progress Card -->
        <div class="kpi-card kpi-card-large">
          <div class="kpi-card-header">
            <i class="pi pi-chart-line"></i>
            <span>Overall Progress</span>
          </div>
          <div class="kpi-card-content">
            <!-- Pre-Onboarding -->
            <div
              class="progress-stage-item"
              :class="{ active: selectedStageFilter === 'Pre-Onboarding' }"
              @click="handleStageClick('Pre-Onboarding')"
            >
              <div class="stage-info">
                <div class="stage-label">
                  <i class="pi pi-clipboard" style="color: #9333ea;"></i>
                  <span>Pre-Onboarding</span>
                  <Tag v-if="selectedStageFilter === 'Pre-Onboarding'" value="Filtered" severity="secondary" class="filter-tag" />
                </div>
                <div class="stage-stats">
                  <span class="stats-text">{{ stageProgress.preOnboarding.completed }} of {{ stageProgress.preOnboarding.total }} employees</span>
                  <span class="stats-percentage">{{ stageProgress.preOnboarding.percentage }}%</span>
                </div>
              </div>
              <ProgressBar :value="stageProgress.preOnboarding.percentage" :showValue="false" style="height: 8px;" />
            </div>

            <!-- 1st Day-Onboarding -->
            <div
              class="progress-stage-item"
              :class="{ active: selectedStageFilter === '1st Day-Onboarding' }"
              @click="handleStageClick('1st Day-Onboarding')"
            >
              <div class="stage-info">
                <div class="stage-label">
                  <i class="pi pi-calendar" style="color: #3b82f6;"></i>
                  <span>1st Day-Onboarding</span>
                  <Tag v-if="selectedStageFilter === '1st Day-Onboarding'" value="Filtered" severity="secondary" class="filter-tag" />
                </div>
                <div class="stage-stats">
                  <span class="stats-text">{{ stageProgress.firstDay.completed }} of {{ stageProgress.firstDay.total }} employees</span>
                  <span class="stats-percentage">{{ stageProgress.firstDay.percentage }}%</span>
                </div>
              </div>
              <ProgressBar :value="stageProgress.firstDay.percentage" :showValue="false" style="height: 8px;" />
            </div>

            <!-- Next Day-Onboarding -->
            <div
              class="progress-stage-item"
              :class="{ active: selectedStageFilter === 'Next Day-Onboarding' }"
              @click="handleStageClick('Next Day-Onboarding')"
            >
              <div class="stage-info">
                <div class="stage-label">
                  <i class="pi pi-check-circle" style="color: #16a34a;"></i>
                  <span>Next Day-Onboarding</span>
                  <Tag v-if="selectedStageFilter === 'Next Day-Onboarding'" value="Filtered" severity="secondary" class="filter-tag" />
                </div>
                <div class="stage-stats">
                  <span class="stats-text">{{ stageProgress.nextDay.completed }} of {{ stageProgress.nextDay.total }} employees</span>
                  <span class="stats-percentage">{{ stageProgress.nextDay.percentage }}%</span>
                </div>
              </div>
              <ProgressBar :value="stageProgress.nextDay.percentage" :showValue="false" style="height: 8px;" />
            </div>
          </div>
        </div>

        <!-- Overdue Tasks Card -->
        <div class="kpi-card">
          <div class="kpi-card-header">
            <i class="pi pi-exclamation-triangle" style="color: #dc2626;"></i>
            <span>Overdue Tasks</span>
          </div>
          <div class="kpi-card-content">
            <div class="overdue-stats">
              <span class="overdue-count">{{ overdueTasks.total }}</span>
              <span class="overdue-label">Tasks overdue</span>
            </div>
            <div v-if="overdueTasks.total > 0" class="overdue-list">
              <div
                v-for="task in overdueTasks.tasks.slice(0, 3)"
                :key="task.id"
                class="overdue-item"
                @click="openTaskDetailsDrawer(task)"
              >
                <div class="overdue-item-content">
                  <span class="overdue-task-name">{{ task.task }}</span>
                  <span class="overdue-task-meta">Assignee: {{ task.assignee }} • Due: {{ task.due }}</span>
                </div>
                <i class="pi pi-eye"></i>
              </div>
              <p v-if="overdueTasks.total > 3" class="overdue-more">
                +{{ overdueTasks.total - 3 }} more overdue tasks
              </p>
            </div>
            <div v-else class="no-overdue">
              <i class="pi pi-check-circle"></i>
              <span>No overdue tasks!</span>
            </div>
          </div>
        </div>

        <!-- Alerts Card -->
        <div class="kpi-card">
          <div class="kpi-card-header">
            <i class="pi pi-bell" style="color: #f59e0b;"></i>
            <span>Alerts</span>
          </div>
          <div class="kpi-card-content">
            <div v-if="filteredAlerts.length > 0" class="alerts-list">
              <div v-for="alert in filteredAlerts.slice(0, 3)" :key="alert.id" class="alert-item">
                <i :class="getAlertIcon(alert.type)" :style="{ color: getAlertColor(alert.type) }"></i>
                <div class="alert-content">
                  <span class="alert-message">{{ alert.message }}</span>
                  <span class="alert-time">{{ alert.time }}</span>
                </div>
              </div>
              <p v-if="filteredAlerts.length > 3" class="alerts-more">
                +{{ filteredAlerts.length - 3 }} more alerts
              </p>
            </div>
            <div v-else class="no-alerts">
              <i class="pi pi-check-circle"></i>
              <span>No alerts for selected companies</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Onboarding Progress Table -->
      <div class="content-card" v-if="currentUserRole !== 'Staff'">
        <div class="card-header">
          <div class="card-title-section" @click="showProgressByNewHire = true">
            <h2 class="card-title">Onboarding Progress</h2>
            <i class="pi pi-external-link"></i>
          </div>
          <Button
            v-if="selectedStageFilter"
            label="Clear Filter"
            severity="secondary"
            outlined
            size="small"
            @click="selectedStageFilter = null"
          />
        </div>
        <p v-if="selectedStageFilter" class="filter-indicator">
          Showing employees in
          <Tag :value="selectedStageFilter" :severity="getStageSeverity(selectedStageFilter)" />
        </p>

        <DataTable
          :value="displayedNewHires"
          stripedRows
          responsiveLayout="scroll"
          class="progress-table"
          @row-click="(e) => openEmployeeTasksDrawer(e.data)"
        >
          <Column field="name" header="Name" sortable style="min-width: 180px">
            <template #body="{ data }">
              <span class="font-medium">{{ data.name }}</span>
            </template>
          </Column>
          <Column field="manager" header="Reporting Manager" sortable style="min-width: 150px" />
          <Column field="currentStage" header="Stage" sortable style="min-width: 160px">
            <template #body="{ data }">
              <Tag :value="data.currentStage" :severity="getStageSeverity(data.currentStage)" />
            </template>
          </Column>
          <Column header="Progress" style="min-width: 180px">
            <template #body="{ data }">
              <div class="progress-cell" :title="`${data.completedTasks} of ${data.totalTasks} tasks completed`">
                <ProgressBar :value="data.progress" :showValue="false" style="height: 8px; width: 80px;" />
                <span class="progress-percentage">{{ data.progress }}%</span>
              </div>
            </template>
          </Column>
          <Column header="Status" style="min-width: 120px">
            <template #body="{ data }">
              <StatusChip :status="normalizeStatus(data.status)" />
            </template>
          </Column>
          <template #empty>
            <div class="empty-state">
              No employees found{{ selectedStageFilter ? ` in ${selectedStageFilter}` : '' }}
            </div>
          </template>
        </DataTable>
      </div>

      <!-- My Tasks Section -->
      <div class="content-card">
        <div class="card-header">
          <div>
            <h2 class="card-title">{{ currentUserRole === 'Staff' ? 'My Tasks' : 'Tasks' }}</h2>
            <p v-if="currentUserRole === 'Staff'" class="card-subtitle">Tasks assigned specifically to you</p>
          </div>
          <Button
            icon="pi pi-filter"
            label="Filter"
            severity="secondary"
            outlined
            size="small"
          />
        </div>

        <!-- Tasks by Stage Grid -->
        <div class="tasks-by-stage-grid">
          <div v-for="stage in onboardingStages" :key="stage" class="stage-section">
            <div class="stage-section-header">
              <div class="stage-section-title">
                <i :class="getStageIcon(stage)" :style="{ color: getStageColor(stage) }"></i>
                <span>{{ stage }}</span>
              </div>
              <Tag :value="getMyTasksByStage(stage).length" severity="secondary" />
            </div>
            <div class="stage-tasks-list">
              <div
                v-for="task in getMyTasksByStage(stage)"
                :key="task.id"
                class="stage-task-item"
                :class="{ completed: task.status === 'completed' }"
                @click="openTaskDetailsDrawer(task)"
              >
                <div class="task-item-header">
                  <span class="task-item-title">{{ task.task }}</span>
                  <StatusChip :status="normalizeStatus(task.status)" />
                </div>
                <div class="task-item-meta">
                  <Tag :value="task.type" severity="secondary" />
                  <span class="task-assignee"><i class="pi pi-user"></i> {{ task.assignedTo }}</span>
                  <span class="task-due"><i class="pi pi-calendar"></i> {{ task.due }}</span>
                </div>
                <div class="task-item-actions" @click.stop>
                  <Button
                    v-if="task.status !== 'completed'"
                    icon="pi pi-bell"
                    severity="info"
                    text
                    rounded
                    size="small"
                    title="Send Reminder"
                    @click="sendReminder(task)"
                  />
                  <Button
                    v-if="task.status !== 'completed'"
                    icon="pi pi-check"
                    severity="success"
                    text
                    rounded
                    size="small"
                    title="Mark Complete"
                    @click="completeTask(task)"
                  />
                  <Button
                    v-if="task.status !== 'completed'"
                    icon="pi pi-trash"
                    severity="danger"
                    text
                    rounded
                    size="small"
                    title="Delete"
                    @click="deleteTask(task)"
                  />
                  <Button
                    v-if="task.status === 'completed'"
                    icon="pi pi-refresh"
                    severity="warning"
                    text
                    rounded
                    size="small"
                    title="Reset Status"
                    @click="resetTask(task)"
                  />
                </div>
              </div>
              <div v-if="getMyTasksByStage(stage).length === 0" class="empty-stage-tasks">
                No tasks in this stage
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- Assign Workflow Drawer -->
    <Sidebar v-model:visible="isAssignDrawerOpen" position="right" style="width: 500px;">
      <template #header>
        <span class="drawer-title">Assign Onboarding Workflow</span>
      </template>
      <div class="drawer-content">
        <div class="form-group">
          <label for="employee">Select Employee</label>
          <Dropdown
            v-model="assignFormData.employeeId"
            :options="filteredNewHires"
            optionLabel="name"
            optionValue="id"
            placeholder="Select an employee"
            class="w-full"
          />
        </div>
        <div class="form-group">
          <label for="workflow">Select Workflow</label>
          <Dropdown
            v-model="assignFormData.workflowId"
            :options="onboardingWorkflows"
            optionLabel="name"
            optionValue="id"
            placeholder="Select a workflow"
            class="w-full"
          />
        </div>

        <!-- Workflow Preview -->
        <div v-if="selectedWorkflow" class="workflow-preview">
          <h4>Workflow Tasks Preview</h4>
          <div class="workflow-tasks-list">
            <div v-for="(task, index) in selectedWorkflow.tasks" :key="index" class="workflow-task-item">
              <span class="task-number">{{ index + 1 }}</span>
              <div class="task-info">
                <span class="task-name">{{ task.name }}</span>
                <span class="task-details">{{ task.ownerRole }} • {{ task.sla }} days SLA</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="drawer-footer">
        <Button label="Cancel" severity="secondary" outlined @click="isAssignDrawerOpen = false" />
        <Button label="Assign Workflow" @click="handleAssignWorkflow" />
      </div>
    </Sidebar>

    <!-- Employee Tasks Drawer -->
    <Sidebar v-model:visible="isEmployeeTasksDrawerOpen" position="right" style="width: 700px;">
      <template #header>
        <span class="drawer-title">Tasks for {{ selectedEmployee?.name }}</span>
      </template>
      <div class="drawer-content" v-if="selectedEmployee">
        <p class="drawer-subtitle">Viewing all assigned tasks across all onboarding stages</p>

        <!-- Employee Info Card -->
        <div class="employee-info-card">
          <div class="info-row">
            <div class="info-item">
              <span class="info-label">Manager</span>
              <span class="info-value">{{ selectedEmployee.manager }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Start Date</span>
              <span class="info-value">{{ selectedEmployee.startDate }}</span>
            </div>
          </div>
          <div class="info-row">
            <div class="info-item">
              <span class="info-label">Current Stage</span>
              <Tag :value="selectedEmployee.currentStage" :severity="getStageSeverity(selectedEmployee.currentStage)" />
            </div>
            <div class="info-item">
              <span class="info-label">Progress</span>
              <div class="progress-cell">
                <ProgressBar :value="employeeActualProgress" :showValue="false" style="height: 8px; width: 80px;" />
                <span class="progress-percentage">{{ employeeActualProgress }}%</span>
              </div>
              <span class="tasks-count">{{ employeeCompletedTasks }} of {{ employeeTotalTasks }} tasks completed</span>
            </div>
          </div>
        </div>

        <!-- Tasks by Stage -->
        <div v-for="stage in onboardingStages" :key="stage" class="stage-tasks-section">
          <div class="stage-section-header">
            <Tag :value="stage" :severity="getStageSeverity(stage)" />
            <span class="stage-task-count">({{ getEmployeeTasksByStage(stage).length }} tasks)</span>
          </div>
          <div v-for="task in getEmployeeTasksByStage(stage)" :key="task.id" class="drawer-task-card">
            <div class="task-card-main">
              <i :class="getTaskStatusIcon(task.status)" :style="{ color: getTaskStatusColor(task.status) }"></i>
              <div class="task-card-content">
                <div class="task-card-title-row">
                  <span class="task-card-title">{{ task.task }}</span>
                  <StatusChip :status="normalizeStatus(task.status)" />
                </div>
                <div class="task-card-meta-row">
                  <Tag :value="task.type" severity="secondary" />
                  <span class="meta-item"><i class="pi pi-user"></i> {{ task.assignedTo }}</span>
                  <span class="meta-item"><i class="pi pi-calendar"></i> {{ task.due }}</span>
                </div>
              </div>
            </div>
            <div class="task-card-actions">
              <Button
                v-if="task.status !== 'completed'"
                icon="pi pi-bell"
                severity="info"
                text
                rounded
                size="small"
                @click="sendReminder(task)"
              />
              <Button
                v-if="task.status !== 'completed'"
                icon="pi pi-check-circle"
                severity="success"
                text
                rounded
                size="small"
                @click="completeTask(task)"
              />
              <Button
                v-if="task.status !== 'completed'"
                icon="pi pi-trash"
                severity="danger"
                text
                rounded
                size="small"
                @click="deleteTask(task)"
              />
              <Button
                v-if="task.status === 'completed'"
                icon="pi pi-refresh"
                severity="warning"
                text
                rounded
                size="small"
                @click="resetTask(task)"
              />
            </div>
          </div>
          <div v-if="getEmployeeTasksByStage(stage).length === 0" class="empty-stage">
            No tasks in this stage
          </div>
        </div>
      </div>
    </Sidebar>

    <!-- Task Details Drawer -->
    <Sidebar v-model:visible="isTaskDetailsDrawerOpen" position="right" style="width: 600px;">
      <template #header>
        <div class="drawer-title-with-icon">
          <i class="pi pi-file-check"></i>
          <span>{{ selectedTaskForDetails?.task }}</span>
        </div>
      </template>
      <div class="drawer-content" v-if="selectedTaskForDetails">
        <p class="drawer-subtitle">Task details and information</p>

        <!-- Task Information Card -->
        <div class="task-info-card">
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">Employee</span>
              <span class="info-value">{{ selectedTaskForDetails.assignee }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Assigned To</span>
              <span class="info-value">{{ selectedTaskForDetails.assignedTo }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Due Date</span>
              <span class="info-value">{{ selectedTaskForDetails.due }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Task Type</span>
              <Tag :value="selectedTaskForDetails.type" severity="secondary" />
            </div>
            <div class="info-item">
              <span class="info-label">Status</span>
              <StatusChip :status="normalizeStatus(selectedTaskForDetails.status)" />
            </div>
            <div class="info-item">
              <span class="info-label">Stage</span>
              <Tag :value="selectedTaskForDetails.stage" :severity="getStageSeverity(selectedTaskForDetails.stage)" />
            </div>
          </div>
        </div>

        <!-- Task Description -->
        <div class="task-description-section">
          <div class="description-header">
            <i class="pi pi-align-left"></i>
            <span>Description</span>
          </div>
          <div class="description-content">
            <p v-if="selectedTaskForDetails.description">{{ selectedTaskForDetails.description }}</p>
            <p v-else class="no-description">No description provided for this task.</p>
          </div>
        </div>

        <!-- Required Items Section (for Document type tasks) -->
        <div v-if="selectedTaskForDetails.requiredItems && selectedTaskForDetails.requiredItems.length > 0" class="required-items-section">
          <div class="required-items-header">
            <i class="pi pi-file-check"></i>
            <span>Required Items</span>
            <Tag
              :value="`${getCompletedItemsCount(selectedTaskForDetails)  }/${selectedTaskForDetails.requiredItems.length}`"
              :severity="getCompletedItemsCount(selectedTaskForDetails) === selectedTaskForDetails.requiredItems.length ? 'success' : 'warning'"
            />
          </div>
          <div class="required-items-list">
            <div
              v-for="(item, index) in selectedTaskForDetails.requiredItems"
              :key="index"
              class="required-item"
              :class="{ 'item-completed': item.completed }"
            >
              <Checkbox
                v-model="item.completed"
                :inputId="`item-${selectedTaskForDetails.id}-${index}`"
                :binary="true"
                @change="updateTaskProgress(selectedTaskForDetails)"
              />
              <label :for="`item-${selectedTaskForDetails.id}-${index}`" class="item-label">
                {{ item.name }}
              </label>
              <i v-if="item.completed" class="pi pi-check-circle item-check-icon"></i>
            </div>
          </div>
          <div class="required-items-progress">
            <ProgressBar
              :value="getItemsProgressPercentage(selectedTaskForDetails)"
              :showValue="false"
              style="height: 6px;"
            />
            <span class="progress-text">{{ getItemsProgressPercentage(selectedTaskForDetails) }}% completed</span>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="task-actions-section">
          <Button
            v-if="selectedTaskForDetails.status === 'completed'"
            icon="pi pi-refresh"
            label="Revert Mark as Completed"
            severity="secondary"
            outlined
            class="w-full"
            @click="resetTask(selectedTaskForDetails); isTaskDetailsDrawerOpen = false"
          />
          <template v-else>
            <Button
              icon="pi pi-check-circle"
              label="Mark as Complete"
              class="w-full"
              @click="completeTask(selectedTaskForDetails); isTaskDetailsDrawerOpen = false"
            />
            <div class="action-buttons-row">
              <Button
                icon="pi pi-bell"
                label="Nudge"
                severity="secondary"
                outlined
                class="flex-1"
                @click="sendReminder(selectedTaskForDetails)"
              />
              <Button
                icon="pi pi-trash"
                label="Delete"
                severity="danger"
                outlined
                class="flex-1"
                @click="deleteTask(selectedTaskForDetails); isTaskDetailsDrawerOpen = false"
              />
            </div>
          </template>
        </div>
      </div>
    </Sidebar>

    <!-- Add Task Drawer -->
    <Sidebar v-model:visible="isAddTaskDrawerOpen" position="right" style="width: 500px;">
      <template #header>
        <span class="drawer-title">Add Task to {{ selectedEmployee?.name }}</span>
      </template>
      <div class="drawer-content">
        <p class="drawer-subtitle">Select a task template from the configuration and assign it to a specific stage.</p>

        <div class="form-group">
          <label>Task Template</label>
          <Dropdown
            v-model="addTaskFormData.templateId"
            :options="onboardingTaskTemplates"
            optionLabel="name"
            optionValue="id"
            placeholder="Select a task template"
            class="w-full"
          >
            <template #option="{ option }">
              <div class="template-option">
                <Tag :value="option.type" severity="secondary" />
                <span>{{ option.name }}</span>
              </div>
            </template>
          </Dropdown>
        </div>
        <div class="form-group">
          <label>Onboarding Stage</label>
          <Dropdown
            v-model="addTaskFormData.stage"
            :options="onboardingStages"
            placeholder="Select a stage"
            class="w-full"
          />
        </div>
        <div class="form-group">
          <label>Trigger</label>
          <Dropdown
            v-model="addTaskFormData.trigger"
            :options="triggerOptions"
            optionLabel="label"
            optionValue="value"
            placeholder="Select a trigger"
            class="w-full"
          >
            <template #option="{ option }">
              <div class="trigger-option">
                <span class="trigger-label">{{ option.label }}</span>
                <span class="trigger-desc">{{ option.description }}</span>
              </div>
            </template>
          </Dropdown>
        </div>
      </div>
      <div class="drawer-footer">
        <Button label="Cancel" severity="secondary" outlined @click="isAddTaskDrawerOpen = false" />
        <Button label="Add Task" @click="handleAddTask" />
      </div>
    </Sidebar>

    <!-- Task Employees Drawer -->
    <Sidebar v-model:visible="isTaskEmployeesDrawerOpen" position="right" style="width: 700px;">
      <template #header>
        <div class="drawer-title-with-icon">
          <i class="pi pi-list-check"></i>
          <span>{{ selectedTaskForEmployees?.task }}</span>
        </div>
      </template>
      <div class="drawer-content" v-if="selectedTaskForEmployees">
        <p class="drawer-subtitle">Employees assigned to this task</p>

        <!-- Task Information -->
        <div class="task-meta-card">
          <div class="meta-row">
            <i class="pi pi-tag"></i>
            <span class="meta-label">Task Type:</span>
            <Tag :value="selectedTaskForEmployees.type" severity="secondary" />
          </div>
          <div class="meta-row">
            <i class="pi pi-building"></i>
            <span class="meta-label">Company:</span>
            <Tag :value="getCompanyName(selectedTaskForEmployees.company)" severity="secondary" />
          </div>
          <div class="meta-row">
            <i class="pi pi-sitemap"></i>
            <span class="meta-label">Stage:</span>
            <Tag :value="selectedTaskForEmployees.stage" :severity="getStageSeverity(selectedTaskForEmployees.stage)" />
          </div>
        </div>

        <!-- Assigned Employees List -->
        <h4 class="section-title">Assigned Employees</h4>
        <div class="assigned-employees-list">
          <div
            v-for="employee in getTaskAssignedEmployees(selectedTaskForEmployees)"
            :key="employee.id"
            class="assigned-employee-card"
          >
            <div class="employee-card-main">
              <div class="employee-avatar">
                <i class="pi pi-user"></i>
              </div>
              <div class="employee-details">
                <span class="employee-name">{{ employee.name }}</span>
                <span class="employee-meta">Manager: {{ employee.manager }} • Start: {{ employee.startDate }}</span>
              </div>
              <div class="employee-status">
                <StatusChip :status="normalizeStatus(employee.taskStatus)" />
                <span class="due-date"><i class="pi pi-calendar"></i> Due: {{ employee.taskDue }}</span>
              </div>
            </div>
            <div class="employee-progress">
              <div class="progress-header">
                <span>Overall Progress</span>
                <span>{{ employee.completedTasks }}/{{ employee.totalTasks }} tasks</span>
              </div>
              <ProgressBar :value="(employee.completedTasks / employee.totalTasks) * 100" :showValue="false" style="height: 8px;" />
            </div>
            <Button
              icon="pi pi-eye"
              label="View Employee Details"
              severity="secondary"
              outlined
              class="w-full"
              @click="viewEmployeeFromTask(employee)"
            />
          </div>
          <div v-if="getTaskAssignedEmployees(selectedTaskForEmployees).length === 0" class="empty-state">
            No employees assigned to this task
          </div>
        </div>
      </div>
    </Sidebar>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useToast } from 'primevue/usetoast'
import { useRouter } from 'vue-router'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import TabView from 'primevue/tabview'
import TabPanel from 'primevue/tabpanel'
import Tag from 'primevue/tag'
import ProgressBar from 'primevue/progressbar'
import Sidebar from 'primevue/sidebar'
import Dropdown from 'primevue/dropdown'
import Calendar from 'primevue/calendar'
import InputText from 'primevue/inputtext'
import Checkbox from 'primevue/checkbox'
import Popover from 'primevue/popover'
import StatusChip from '../../../components/ui/StatusChip.vue'

const toast = useToast()
const router = useRouter()

// Current user role (would come from store in real app)
const currentUserRole = ref('HR Admin')

// Companies
const companies = ref([
  { id: 'timetec-cloud', name: 'TimeTec Cloud' },
  { id: 'timetec-computing', name: 'TimeTec Computing' },
  { id: 'fingertech', name: 'FingerTec' }
])

// Onboarding stages
const onboardingStages = ['Pre-Onboarding', '1st Day-Onboarding', 'Next Day-Onboarding']

// Trigger options
const triggerOptions = [
  { value: 'hire_date', label: 'On Hire Date', description: 'Starts on the employee\'s hire date' },
  { value: 'confirmed_status', label: 'On Confirmed Staff Status', description: 'Starts when employee status is confirmed' },
  { value: 'previous_task', label: 'After Previous Task Completed', description: 'Starts after the previous task is completed' },
  { value: 'date_offset', label: 'Date Offset', description: 'Starts on a specific date offset' }
]

// Filter options
const stageFilterOptions = [
  { label: 'All Stages', value: 'all' },
  { label: 'Pre-Onboarding', value: 'pre-onboarding' },
  { label: '1st Day-Onboarding', value: 'first-day' },
  { label: 'Next Day-Onboarding', value: 'next-day' }
]

const statusFilterOptions = [
  { label: 'All Statuses', value: 'all' },
  { label: 'In Progress', value: 'in-progress' },
  { label: 'Not Started', value: 'not-started' }
]

const taskStatusFilterOptions = [
  { label: 'All Statuses', value: 'all' },
  { label: 'In Progress', value: 'in-progress' },
  { label: 'Pending', value: 'pending' },
  { label: 'Completed', value: 'completed' },
  { label: 'Overdue', value: 'overdue' }
]

// State
const selectedCompanies = ref(['timetec-cloud'])
const selectedStageFilter = ref(null)
const showProgressByNewHire = ref(false)
const showEmployeeTasksPage = ref(false)
const progressViewTab = ref(0)
const taskStageTab = ref(0)
const progressSearchQuery = ref('')
const progressStageFilter = ref('all')
const progressStatusFilter = ref('all')

// Drawer states
const isAssignDrawerOpen = ref(false)
const isEmployeeTasksDrawerOpen = ref(false)
const isTaskDetailsDrawerOpen = ref(false)
const isAddTaskDrawerOpen = ref(false)
const isTaskEmployeesDrawerOpen = ref(false)

// Selected items
const selectedEmployee = ref(null)
const selectedTaskForDetails = ref(null)
const selectedTaskForEmployees = ref(null)

// Form data
const assignFormData = ref({
  employeeId: '',
  workflowId: ''
})

const addTaskFormData = ref({
  templateId: '',
  stage: '',
  trigger: ''
})

// Company filter popover ref
const companyFilterPopover = ref(null)

// Sample data - New Hires
const allNewHires = ref([
  // TimeTec Cloud employees
  { id: 1, name: 'Aina Zulkifli', manager: 'Farah Kassim', startDate: '2025-09-15', completedTasks: 8, totalTasks: 12, progress: 67, status: 'in-progress', currentStage: '1st Day-Onboarding', company: 'timetec-cloud' },
  { id: 2, name: 'Harith Rahman', manager: 'Nizam Salleh', startDate: '2025-09-22', completedTasks: 3, totalTasks: 12, progress: 25, status: 'not-started', currentStage: 'Pre-Onboarding', company: 'timetec-cloud' },
  { id: 3, name: 'Nur Iman', manager: 'Ahmed Fauzi', startDate: '2025-10-01', completedTasks: 1, totalTasks: 12, progress: 8, status: 'not-started', currentStage: 'Pre-Onboarding', company: 'timetec-cloud' },
  { id: 8, name: 'Jessica Wong', manager: 'David Kim', startDate: '2025-09-28', completedTasks: 4, totalTasks: 12, progress: 33, status: 'in-progress', currentStage: '1st Day-Onboarding', company: 'timetec-cloud' },
  // TimeTec Computing employees
  { id: 4, name: 'Siti Aminah', manager: 'Razak Hassan', startDate: '2025-09-18', completedTasks: 10, totalTasks: 12, progress: 83, status: 'in-progress', currentStage: 'Next Day-Onboarding', company: 'timetec-computing' },
  { id: 5, name: 'Amir Hamzah', manager: 'Lina Wong', startDate: '2025-09-25', completedTasks: 5, totalTasks: 12, progress: 42, status: 'in-progress', currentStage: 'Pre-Onboarding', company: 'timetec-computing' },
  // FingerTec employees
  { id: 6, name: 'Daniel Lee', manager: 'Jason Tan', startDate: '2025-09-20', completedTasks: 6, totalTasks: 12, progress: 50, status: 'in-progress', currentStage: '1st Day-Onboarding', company: 'fingertech' },
  { id: 7, name: 'Sarah Ibrahim', manager: 'Kamala Devi', startDate: '2025-10-05', completedTasks: 2, totalTasks: 12, progress: 17, status: 'not-started', currentStage: 'Pre-Onboarding', company: 'fingertech' }
])

// Sample data - Tasks
const allTasks = ref([
  // TimeTec Cloud tasks
  { id: 1, task: 'Welcome Pack', assignee: 'Aina Zulkifli', due: '2025-09-16', type: 'General Task', indicator: 'Onboarding', status: 'pending', assignedTo: 'HR Coordinator', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Prepare and deliver the welcome pack to the new employee. This includes:\n\n• Company branded merchandise (t-shirt, mug, notebook)\n• Employee handbook\n• Office supplies starter kit\n• Building access card\n• Parking information\n\nEnsure all items are neatly packaged and ready for the employee\'s first day.' },
  { id: 2, task: 'Grant Email & HRMS Access', assignee: 'Harith Rahman', due: '2025-09-24', type: 'System/Access', indicator: 'Onboarding', status: 'overdue', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Create corporate email account and grant access to HRMS system.\n\nSteps:\n1. Create email account following naming convention\n2. Set up email signature template\n3. Add to relevant distribution lists\n4. Create HRMS account with appropriate role permissions\n5. Send credentials via secure channel to employee' },
  { id: 3, task: 'Day 1 Orientation', assignee: 'Nur Iman', due: '2025-10-01', type: 'Meeting/Event', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Manager', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Conduct the Day 1 orientation session covering:\n\n• Company history and culture\n• Organizational structure\n• Team introductions\n• Office tour\n• Safety and emergency procedures\n• Q&A session\n\nDuration: 2-3 hours. Location: Conference Room A.' },
  { id: 4, task: 'Setup Workstation', assignee: 'Harith Rahman', due: '2025-09-23', type: 'Asset', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Prepare the employee workstation before their first day:\n\n• Assign desk location\n• Setup computer with required software\n• Configure network access\n• Install necessary development tools\n• Test all equipment functionality\n• Place welcome note on desk' },
  { id: 5, task: 'Compulsory Document', assignee: 'Aina Zulkifli', due: '2025-09-17', type: 'Document', indicator: 'Onboarding', status: 'completed', assignedTo: 'Staff', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Review and acknowledge compulsory documents.', requiredItems: [
    { name: 'IC (Identity Card)', completed: true, isCompulsory: true },
    { name: 'Passport', completed: true, isCompulsory: false }
  ] },
  { id: 6, task: 'Payroll & Banking Information Setup', assignee: 'Aina Zulkifli', due: '2025-09-18', type: 'Information', indicator: 'Onboarding', status: 'pending', assignedTo: 'Staff', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Complete payroll setup for the new employee. Ensure all information is accurate before the first pay cycle.', requiredItems: [
    { name: 'Verify bank account details', completed: true },
    { name: 'Set up in payroll system', completed: true },
    { name: 'Configure tax deductions (PCB)', completed: false },
    { name: 'Set up EPF and SOCSO contributions', completed: false },
    { name: 'Process any allowances or benefits', completed: false }
  ] },
  { id: 7, task: 'Verify Identity Documents', assignee: 'Harith Rahman', due: '2025-09-25', type: 'Information/Document', indicator: 'Onboarding', status: 'pending', assignedTo: 'Staff', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Verify all submitted identity documents for authenticity. Flag any discrepancies to HR immediately.', requiredItems: [
    { name: 'Check IC/Passport validity', completed: true },
    { name: 'Verify educational qualifications', completed: false },
    { name: 'Cross-reference employment history', completed: false },
    { name: 'Complete background verification checklist', completed: false }
  ] },
  { id: 8, task: 'Process Employment Forms', assignee: 'Nur Iman', due: '2025-10-02', type: 'Information/Document', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Staff', stage: 'Next Day-Onboarding', company: 'timetec-cloud', description: 'Process all employment-related forms. Ensure all forms are completed, signed, and filed properly.', requiredItems: [
    { name: 'Employment contract (signed copy)', completed: false },
    { name: 'NDA and confidentiality agreement', completed: false },
    { name: 'Company policy acknowledgment', completed: false },
    { name: 'Benefits enrollment forms', completed: false },
    { name: 'Emergency contact form', completed: false }
  ] },
  { id: 9, task: 'Employee Feedback Survey', assignee: 'Aina Zulkifli', due: '2025-09-23', type: 'Questionnaire', indicator: 'Onboarding', status: 'pending', assignedTo: 'HR', stage: 'Next Day-Onboarding', company: 'timetec-cloud', description: 'Send and collect the 7-day onboarding feedback survey. Analyze responses and share insights with the onboarding team.', requiredItems: [
    { name: 'Overall onboarding experience rating', completed: false },
    { name: 'Quality of orientation sessions', completed: false },
    { name: 'Workstation and equipment satisfaction', completed: false },
    { name: 'Team integration feedback', completed: false },
    { name: 'Suggestions for improvement', completed: false }
  ] },
  { id: 10, task: 'Office Tour & Badge Photo', assignee: 'Aina Zulkifli', due: '2025-09-16', type: 'General Task', indicator: 'Onboarding', status: 'pending', assignedTo: 'Staff', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Conduct office tour and take badge photo:\n\n• Tour all office areas and facilities\n• Introduce to key personnel\n• Show emergency exits and assembly points\n• Take professional photo for ID badge\n• Explain office etiquette and rules\n\nDuration: Approximately 45 minutes.' },
  { id: 11, task: 'Day 1 Orientation', assignee: 'Aina Zulkifli', due: '2025-09-16', type: 'Meeting/Event', indicator: 'Onboarding', status: 'pending', assignedTo: 'HR', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Conduct comprehensive Day 1 orientation:\n\n• Welcome and introductions\n• Company overview presentation\n• HR policies and procedures\n• Benefits explanation\n• IT systems overview\n• Safety briefing\n\nProvide orientation materials and answer any questions.' },
  { id: 12, task: 'Grant Email & HRMS Access', assignee: 'Aina Zulkifli', due: '2025-09-16', type: 'System', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Set up and verify all system access on Day 1:\n\n• Activate email account\n• Verify HRMS login\n• Grant access to shared drives\n• Set up VPN if required\n• Configure software licenses\n\nProvide login credentials and basic training on system usage.' },
  { id: 13, task: 'Issue Laptop & ID Card', assignee: 'Aina Zulkifli', due: '2025-09-16', type: 'Asset', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Issue company assets to the new employee:\n\n• Laptop with all required software installed\n• Power adapter and accessories\n• ID card with access permissions\n• Asset acknowledgment form\n\nRecord all serial numbers and have employee sign asset receipt form.' },
  { id: 20, task: 'Issue Laptop & ID Card', assignee: 'Jessica Wong', due: '2025-09-28', type: 'Asset', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Prepare and configure laptop for new employee:\n\n• Install standard software suite\n• Configure email client\n• Set up security software\n• Prepare ID card with photo\n• Test all equipment\n\nHave assets ready for collection before start date.' },
  // TimeTec Computing tasks
  { id: 14, task: 'Welcome Pack', assignee: 'Siti Aminah', due: '2025-09-19', type: 'General Task', indicator: 'Onboarding', status: 'completed', assignedTo: 'HR Coordinator', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Prepare welcome pack with company materials, handbook, and office supplies for the new team member.' },
  { id: 15, task: 'Setup Company Email', assignee: 'Siti Aminah', due: '2025-09-20', type: 'System/Access', indicator: 'Onboarding', status: 'completed', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Create company email account and configure all necessary access permissions for internal systems.' },
  { id: 16, task: 'Hardware Setup', assignee: 'Amir Hamzah', due: '2025-09-26', type: 'Asset', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Set up workstation with all required hardware including computer, monitors, keyboard, mouse, and any specialized equipment needed for the role.' },
  { id: 17, task: 'Team Introduction Meeting', assignee: 'Siti Aminah', due: '2025-09-19', type: 'Meeting/Event', indicator: 'Onboarding', status: 'completed', assignedTo: 'Manager', stage: '1st Day-Onboarding', company: 'timetec-computing', description: 'Organize team meeting to introduce the new employee. Include brief presentations from team members about their roles and current projects.' },
  { id: 18, task: 'Complete Training Modules', assignee: 'Siti Aminah', due: '2025-09-22', type: 'General Task', indicator: 'Onboarding', status: 'pending', assignedTo: 'Staff', stage: 'Next Day-Onboarding', company: 'timetec-computing', description: 'Complete all mandatory training modules:\n\n• Company compliance training\n• Security awareness\n• Product knowledge basics\n• System usage tutorials\n\nTrack completion in the learning management system.' },
  // FingerTec tasks
  { id: 19, task: 'Onboarding Checklist Review', assignee: 'Daniel Lee', due: '2025-09-21', type: 'General Task', indicator: 'Onboarding', status: 'completed', assignedTo: 'HR Coordinator', stage: 'Pre-Onboarding', company: 'fingertech', description: 'Review and verify completion of all pre-onboarding checklist items before the employee\'s start date.' },
  { id: 21, task: 'Security Access Setup', assignee: 'Daniel Lee', due: '2025-09-22', type: 'System/Access', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'fingertech', description: 'Configure security access including building access card, system login credentials, and appropriate permission levels based on role requirements.' },
  { id: 22, task: 'Department Tour', assignee: 'Daniel Lee', due: '2025-09-21', type: 'Meeting/Event', indicator: 'Onboarding', status: 'completed', assignedTo: 'Manager', stage: '1st Day-Onboarding', company: 'fingertech', description: 'Conduct a comprehensive tour of the department, introducing the new employee to team members and explaining workflows and collaboration points.' },
  { id: 23, task: 'Company Policy Briefing', assignee: 'Sarah Ibrahim', due: '2025-10-06', type: 'Meeting/Event', indicator: 'Onboarding', status: 'not-started', assignedTo: 'HR Coordinator', stage: 'Pre-Onboarding', company: 'fingertech', description: 'Conduct briefing session covering all company policies:\n\n• Code of conduct\n• Leave policies\n• Performance review process\n• Communication guidelines\n• Dress code\n\nProvide policy handbook and answer questions.' }
])

// Sample data - Alerts
const allAlerts = ref([
  { id: 1, message: '2 tasks overdue for Harith Rahman - requires manager escalation', type: 'error', time: '2 hours ago', company: 'timetec-cloud' },
  { id: 2, message: 'Aina Zulkifli pending laptop pickup - asset location confirmed', type: 'warning', time: '4 hours ago', company: 'timetec-cloud' },
  { id: 3, message: 'Amir Hamzah workstation setup delayed - IT team notified', type: 'warning', time: '1 hour ago', company: 'timetec-computing' },
  { id: 4, message: 'Siti Aminah training completion due tomorrow', type: 'info', time: '3 hours ago', company: 'timetec-computing' },
  { id: 5, message: 'Daniel Lee security access pending approval', type: 'warning', time: '5 hours ago', company: 'fingertech' },
  { id: 6, message: 'Sarah Ibrahim onboarding scheduled for next week', type: 'info', time: '1 day ago', company: 'fingertech' }
])

// Sample workflows
const onboardingWorkflows = ref([
  { id: 'wf-1', name: 'Onboarding — Standard (HQ)', tasks: [
    { name: 'Welcome Pack', ownerRole: 'HR', sla: 1 },
    { name: 'Grant Email Access', ownerRole: 'IT', sla: 2 },
    { name: 'Day 1 Orientation', ownerRole: 'HR', sla: 0 },
    { name: 'Issue Laptop & ID', ownerRole: 'IT', sla: 1 }
  ]},
  { id: 'wf-2', name: 'Onboarding — Remote Employee', tasks: [
    { name: 'Welcome Pack (Digital)', ownerRole: 'HR', sla: 1 },
    { name: 'Grant Remote Access', ownerRole: 'IT', sla: 2 },
    { name: 'Virtual Orientation', ownerRole: 'HR', sla: 0 }
  ]},
  { id: 'wf-3', name: 'Onboarding — Executive Level', tasks: [
    { name: 'Executive Welcome Pack', ownerRole: 'HR', sla: 1 },
    { name: 'Executive Briefing', ownerRole: 'CEO', sla: 3 }
  ]}
])

// Sample task templates
const onboardingTaskTemplates = ref([
  { id: 'tt-1', name: 'Welcome Pack', type: 'General' },
  { id: 'tt-2', name: 'Compulsory Document', type: 'Document' },
  { id: 'tt-3', name: 'Day 1 Orientation', type: 'Meeting' },
  { id: 'tt-4', name: 'Grant Email & HRMS Access', type: 'System' },
  { id: 'tt-5', name: 'Issue Laptop & ID Card', type: 'Asset' },
  { id: 'tt-6', name: 'Security & Compliance Quiz', type: 'Questionnaire' }
])

// Computed properties
const filteredNewHires = computed(() => {
  return allNewHires.value.filter(hire => selectedCompanies.value.includes(hire.company))
})

const displayedNewHires = computed(() => {
  if (!selectedStageFilter.value) {
    return filteredNewHires.value
  }
  return filteredNewHires.value.filter(hire => hire.currentStage === selectedStageFilter.value)
})

const progressFilteredNewHires = computed(() => {
  let result = filteredNewHires.value

  // Apply search query
  if (progressSearchQuery.value.trim()) {
    const query = progressSearchQuery.value.toLowerCase()
    result = result.filter(hire =>
      hire.name.toLowerCase().includes(query) ||
      hire.manager.toLowerCase().includes(query)
    )
  }

  // Apply stage filter
  if (progressStageFilter.value !== 'all') {
    const stageMap = {
      'pre-onboarding': 'Pre-Onboarding',
      'first-day': '1st Day-Onboarding',
      'next-day': 'Next Day-Onboarding'
    }
    const mappedStage = stageMap[progressStageFilter.value]
    if (mappedStage) {
      result = result.filter(hire => hire.currentStage === mappedStage)
    }
  }

  // Apply status filter
  if (progressStatusFilter.value !== 'all') {
    result = result.filter(hire => hire.status === progressStatusFilter.value)
  }

  return result
})

const filteredTasks = computed(() => {
  return allTasks.value.filter(task => selectedCompanies.value.includes(task.company))
})

const filteredAlerts = computed(() => {
  return allAlerts.value.filter(alert => selectedCompanies.value.includes(alert.company))
})

const stageProgress = computed(() => {
  const calculateStageProgress = (stage) => {
    const stageTasks = filteredTasks.value.filter(task => task.stage === stage)
    const employeesInStage = [...new Set(stageTasks.map(task => task.assignee))]

    if (employeesInStage.length === 0) {
      return { completed: 0, total: 0, percentage: 0 }
    }

    let employeesCompleted = 0
    employeesInStage.forEach(employee => {
      const employeeTasks = stageTasks.filter(task => task.assignee === employee)
      const allTasksCompleted = employeeTasks.every(task => task.status === 'completed')
      if (allTasksCompleted) {
        employeesCompleted++
      }
    })

    return {
      completed: employeesCompleted,
      total: employeesInStage.length,
      percentage: Math.round((employeesCompleted / employeesInStage.length) * 100)
    }
  }

  return {
    preOnboarding: calculateStageProgress('Pre-Onboarding'),
    firstDay: calculateStageProgress('1st Day-Onboarding'),
    nextDay: calculateStageProgress('Next Day-Onboarding')
  }
})

const overdueTasks = computed(() => {
  const overdue = filteredTasks.value.filter(task => task.status === 'overdue')
  return {
    total: overdue.length,
    tasks: overdue
  }
})

const selectedWorkflow = computed(() => {
  if (!assignFormData.value.workflowId) return null
  return onboardingWorkflows.value.find(w => w.id === assignFormData.value.workflowId)
})

const employeeTasks = computed(() => {
  if (!selectedEmployee.value) return []
  return filteredTasks.value.filter(task => task.assignee === selectedEmployee.value.name)
})

const employeeCompletedTasks = computed(() => {
  return employeeTasks.value.filter(task => task.status === 'completed').length
})

const employeeTotalTasks = computed(() => {
  return employeeTasks.value.length
})

const employeeActualProgress = computed(() => {
  if (employeeTotalTasks.value === 0) return 0
  return Math.round((employeeCompletedTasks.value / employeeTotalTasks.value) * 100)
})

// Helper functions
const getCompanyName = (companyId) => {
  const company = companies.value.find(c => c.id === companyId)
  return company ? company.name : companyId
}

const normalizeStatus = (status) => {
  // Convert hyphenated status to underscore format for StatusChip
  return status.replace(/-/g, '_')
}

const getStageSeverity = (stage) => {
  switch (stage) {
    case 'Pre-Onboarding': return 'secondary'
    case '1st Day-Onboarding': return 'info'
    case 'Next Day-Onboarding': return 'success'
    default: return 'secondary'
  }
}

const getStageIcon = (stage) => {
  switch (stage) {
    case 'Pre-Onboarding': return 'pi pi-clipboard'
    case '1st Day-Onboarding': return 'pi pi-calendar'
    case 'Next Day-Onboarding': return 'pi pi-check-circle'
    default: return 'pi pi-list'
  }
}

const getStageColor = (stage) => {
  switch (stage) {
    case 'Pre-Onboarding': return '#9333ea'
    case '1st Day-Onboarding': return '#3b82f6'
    case 'Next Day-Onboarding': return '#16a34a'
    default: return '#6b7280'
  }
}

const getTaskStatusIcon = (status) => {
  switch (status) {
    case 'completed': return 'pi pi-check-circle'
    case 'overdue': return 'pi pi-exclamation-triangle'
    default: return 'pi pi-clock'
  }
}

const getTaskStatusColor = (status) => {
  switch (status) {
    case 'completed': return '#16a34a'
    case 'overdue': return '#dc2626'
    default: return '#9ca3af'
  }
}

const getAlertIcon = (type) => {
  return 'pi pi-exclamation-triangle'
}

const getAlertColor = (type) => {
  switch (type) {
    case 'error': return '#dc2626'
    case 'warning': return '#f59e0b'
    case 'info': return '#3b82f6'
    default: return '#6b7280'
  }
}

const getTasksByStage = (stage) => {
  return filteredTasks.value.filter(task => task.stage === stage)
}

const getMyTasksByStage = (stage) => {
  return filteredTasks.value.filter(task => task.stage === stage)
}

const getEmployeeTasksByStage = (stage) => {
  if (!selectedEmployee.value) return []
  return filteredTasks.value.filter(task =>
    task.assignee === selectedEmployee.value.name && task.stage === stage
  )
}

const getTaskAssignedEmployees = (task) => {
  if (!task) return []

  const assignedTasks = allTasks.value.filter(t =>
    t.task === task.task && t.company === task.company
  )

  return assignedTasks.map(t => {
    const employee = allNewHires.value.find(h => h.name === t.assignee)
    if (employee) {
      return {
        ...employee,
        taskStatus: t.status,
        taskDue: t.due
      }
    }
    return null
  }).filter(e => e !== null)
}

// Event handlers
const toggleCompanyFilter = (event) => {
  companyFilterPopover.value?.toggle(event)
}

const handleStageClick = (stage) => {
  selectedStageFilter.value = selectedStageFilter.value === stage ? null : stage
}

const resetProgressFilters = () => {
  progressSearchQuery.value = ''
  progressStageFilter.value = 'all'
  progressStatusFilter.value = 'all'
}

const viewEmployeeTasks = (employee) => {
  selectedEmployee.value = employee
  showEmployeeTasksPage.value = true
  showProgressByNewHire.value = false
}

const openEmployeeTasksDrawer = (employee) => {
  selectedEmployee.value = employee
  isEmployeeTasksDrawerOpen.value = true
}

const openTaskDetailsDrawer = (task) => {
  selectedTaskForDetails.value = task
  isTaskDetailsDrawerOpen.value = true
}

const openTaskEmployeesDrawer = (task) => {
  selectedTaskForEmployees.value = task
  isTaskEmployeesDrawerOpen.value = true
}

const viewEmployeeFromTask = (employee) => {
  selectedEmployee.value = employee
  isTaskEmployeesDrawerOpen.value = false
  showProgressByNewHire.value = false
  showEmployeeTasksPage.value = true
}

const handleAssignWorkflow = () => {
  if (!assignFormData.value.employeeId || !assignFormData.value.workflowId) {
    toast.add({
      severity: 'error',
      summary: 'Validation Error',
      detail: 'Please select an employee and workflow',
      life: 3000
    })
    return
  }

  const employee = filteredNewHires.value.find(e => e.id === assignFormData.value.employeeId)
  const workflow = onboardingWorkflows.value.find(w => w.id === assignFormData.value.workflowId)

  toast.add({
    severity: 'success',
    summary: 'Workflow Assigned',
    detail: `"${workflow.name}" has been assigned to ${employee.name}`,
    life: 3000
  })

  isAssignDrawerOpen.value = false
  assignFormData.value = { employeeId: '', workflowId: '' }
}

const handleAddTask = () => {
  if (!addTaskFormData.value.templateId || !addTaskFormData.value.stage || !addTaskFormData.value.trigger) {
    toast.add({
      severity: 'error',
      summary: 'Validation Error',
      detail: 'Please select task template, stage, and trigger',
      life: 3000
    })
    return
  }

  const template = onboardingTaskTemplates.value.find(t => t.id === addTaskFormData.value.templateId)
  const trigger = triggerOptions.find(t => t.value === addTaskFormData.value.trigger)

  toast.add({
    severity: 'success',
    summary: 'Task Added',
    detail: `"${template.name}" has been added to ${addTaskFormData.value.stage} with trigger "${trigger.label}"`,
    life: 3000
  })

  isAddTaskDrawerOpen.value = false
  addTaskFormData.value = { templateId: '', stage: '', trigger: '' }
}

const sendReminder = (task) => {
  toast.add({
    severity: 'success',
    summary: 'Reminder Sent',
    detail: `A notification has been sent to ${task.assignedTo} about the task: "${task.task}"`,
    life: 5000
  })
}

const completeTask = (task) => {
  task.status = 'completed'
  toast.add({
    severity: 'success',
    summary: 'Task Completed',
    detail: `Task "${task.task}" has been marked as completed`,
    life: 3000
  })
}

const deleteTask = (task) => {
  const index = allTasks.value.findIndex(t => t.id === task.id)
  if (index !== -1) {
    allTasks.value.splice(index, 1)
    toast.add({
      severity: 'success',
      summary: 'Task Deleted',
      detail: `Task "${task.task}" has been deleted`,
      life: 3000
    })
  }
}

const resetTask = (task) => {
  task.status = 'pending'
  toast.add({
    severity: 'success',
    summary: 'Task Status Reset',
    detail: `Task "${task.task}" has been reset to pending status`,
    life: 3000
  })
}

// Required Items helper functions
const getCompletedItemsCount = (task) => {
  if (!task.requiredItems || task.requiredItems.length === 0) return 0
  return task.requiredItems.filter(item => item.completed).length
}

const getItemsProgressPercentage = (task) => {
  if (!task.requiredItems || task.requiredItems.length === 0) return 0
  const completed = getCompletedItemsCount(task)
  return Math.round((completed / task.requiredItems.length) * 100)
}

const updateTaskProgress = (task) => {
  // Auto-complete task if all required items are checked
  if (task.requiredItems && task.requiredItems.length > 0) {
    const allCompleted = task.requiredItems.every(item => item.completed)
    if (allCompleted && task.status !== 'completed') {
      toast.add({
        severity: 'info',
        summary: 'All Items Completed',
        detail: 'All required items have been checked. You can now mark this task as complete.',
        life: 4000
      })
    }
  }
}
</script>

<style scoped>
.onboarding-dashboard {
  max-width: 1600px;
  margin: 0 auto;
  font-size: 13px;
}

/* Page Header */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.header-left {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
}

.header-text {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
}

.page-subtitle {
  font-size: 12px;
  color: var(--color-gray-500);
  margin: 0;
}

/* Dashboard Header */
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.dashboard-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0 0 0.125rem 0;
}

.dashboard-subtitle {
  font-size: 12px;
  color: var(--color-gray-500);
  margin: 0;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

/* Company Filter */
.company-filter-content {
  padding: 0.5rem;
  min-width: 180px;
}

.filter-title {
  font-weight: 600;
  font-size: 13px;
  margin-bottom: 0.5rem;
}

.filter-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.375rem 0;
}

.filter-item label {
  font-size: 13px;
  cursor: pointer;
}

/* KPI Grid */
.kpi-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1rem;
}

.kpi-card {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  padding: 1rem;
}

.kpi-card-large {
  grid-column: span 1;
}

.kpi-card-header {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  margin-bottom: 0.75rem;
  font-weight: 600;
  font-size: 14px;
}

.kpi-card-content {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

/* Progress Stage Items */
.progress-stage-item {
  padding: 0.5rem;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s;
}

.progress-stage-item:hover {
  background: var(--color-gray-50);
}

.progress-stage-item.active {
  background: var(--color-primary-50);
  border: 2px solid var(--color-primary-200);
}

.stage-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  margin-bottom: 0.25rem;
}

.stage-label {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 13px;
  font-weight: 500;
}

.filter-tag {
  font-size: 10px;
}

.stage-stats {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.stats-text {
  font-size: 12px;
  color: var(--color-gray-500);
}

.stats-percentage {
  font-size: 13px;
  font-weight: 600;
}

/* Overdue Section */
.overdue-stats {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.75rem;
}

.overdue-count {
  font-size: 1.5rem;
  font-weight: 700;
  color: #dc2626;
}

.overdue-label {
  font-size: 12px;
  color: var(--color-gray-500);
}

.overdue-list {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.overdue-item {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  padding: 0.5rem;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background 0.2s;
}

.overdue-item:hover {
  background: #fee2e2;
}

.overdue-item-content {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.overdue-task-name {
  font-size: 13px;
  font-weight: 500;
  color: #991b1b;
}

.overdue-task-meta {
  font-size: 11px;
  color: #b91c1c;
}

.overdue-more {
  font-size: 11px;
  color: var(--color-gray-500);
  text-align: center;
  margin-top: 0.5rem;
}

.no-overdue, .no-alerts {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  text-align: center;
  color: var(--color-gray-500);
  font-size: 12px;
}

.no-overdue i, .no-alerts i {
  font-size: 2rem;
  color: #16a34a;
  margin-bottom: 0.375rem;
}

/* Alerts Section */
.alerts-list {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.alert-item {
  display: flex;
  align-items: flex-start;
  gap: 0.375rem;
  padding: 0.5rem;
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
}

.alert-content {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.alert-message {
  font-size: 12px;
}

.alert-time {
  font-size: 11px;
  color: var(--color-gray-500);
}

.alerts-more {
  font-size: 11px;
  color: var(--color-gray-500);
  text-align: center;
  margin-top: 0.375rem;
}

/* Content Card */
.content-card {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  padding: 1rem;
  margin-bottom: 1rem;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.card-title-section {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  cursor: pointer;
  transition: color 0.2s;
}

.card-title-section:hover {
  color: var(--color-primary-600);
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  margin: 0;
}

.card-subtitle {
  font-size: 12px;
  color: var(--color-gray-500);
  margin: 0.125rem 0 0 0;
}

.filter-indicator {
  font-size: 12px;
  color: var(--color-gray-500);
  margin-bottom: 0.75rem;
}

/* Progress Cell */
.progress-cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 0;
}

.progress-cell :deep(.p-progressbar) {
  flex: 1;
  min-width: 40px;
}

.progress-percentage {
  font-size: 12px;
  font-weight: 500;
  color: var(--color-gray-600);
  flex-shrink: 0;
}

/* Filter Section */
.filter-section {
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 0.75rem;
}

.filter-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.filter-label {
  font-size: 13px;
  font-weight: 500;
}

.filter-controls {
  display: flex;
  gap: 0.75rem;
}

.search-input {
  flex: 1;
}

.filter-dropdown {
  width: 160px;
}

/* Tasks by Stage Grid */
.tasks-by-stage-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0.75rem;
}

.stage-section {
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.75rem;
}

.stage-section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem;
  background: var(--color-bg);
  border-radius: var(--radius-sm);
  margin-bottom: 0.5rem;
}

.stage-section-title {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-weight: 600;
  font-size: 13px;
}

.stage-tasks-list {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.stage-task-item {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-left: 3px solid #f59e0b;
  border-radius: var(--radius-sm);
  padding: 0.5rem;
  cursor: pointer;
  transition: box-shadow 0.2s;
}

.stage-task-item:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.stage-task-item.completed {
  border-left-color: #16a34a;
}

.task-item-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.375rem;
  margin-bottom: 0.375rem;
}

.task-item-title {
  font-weight: 500;
  font-size: 13px;
}

.task-item-meta {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  flex-wrap: wrap;
  margin-bottom: 0.375rem;
}

.task-assignee, .task-due {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 11px;
  color: var(--color-gray-500);
}

.task-item-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.25rem;
}

.empty-stage-tasks {
  text-align: center;
  padding: 1.5rem;
  color: var(--color-gray-400);
  font-size: 12px;
}

/* Employee Summary Card */
.employee-summary-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  padding: 0.75rem 1rem;
  margin-bottom: 1rem;
}

.summary-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.summary-label {
  font-size: 11px;
  color: var(--color-gray-500);
}

.summary-value {
  font-size: 13px;
  font-weight: 500;
}

/* Tasks Stage Grid */
.tasks-stage-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0.75rem;
}

.stage-column {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.stage-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0.75rem;
  background: var(--color-gray-50);
  border-bottom: 1px solid var(--color-divider);
}

.stage-title {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-weight: 600;
  font-size: 13px;
}

.stage-tasks {
  padding: 0.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.task-card {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.5rem;
  cursor: pointer;
  transition: box-shadow 0.2s, background 0.2s;
}

.task-card:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  background: var(--color-gray-50);
}

.task-card-header {
  display: flex;
  align-items: flex-start;
  gap: 0.375rem;
  margin-bottom: 0.375rem;
}

.task-title {
  font-weight: 500;
  font-size: 13px;
  flex: 1;
}

.task-card-details {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.375rem;
}

.task-type-tag {
  font-size: 10px;
}

.task-card-meta {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
  font-size: 11px;
  color: var(--color-gray-500);
  margin-bottom: 0.375rem;
}

.task-card-meta span {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.task-card-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.25rem;
  border-top: 1px solid var(--color-divider);
  padding-top: 0.375rem;
  margin-top: 0.25rem;
}

.empty-tasks {
  text-align: center;
  padding: 1.5rem;
  color: var(--color-gray-400);
  font-size: 12px;
}

/* Drawer Styles */
.drawer-title {
  font-size: 16px;
  font-weight: 600;
}

.drawer-title-with-icon {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 16px;
  font-weight: 600;
}

.drawer-content {
  padding: 0.75rem 0;
}

.drawer-subtitle {
  font-size: 12px;
  color: var(--color-gray-500);
  margin: 0 0 1rem 0;
}

.drawer-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  padding: 0.75rem 0;
  border-top: 1px solid var(--color-divider);
  margin-top: auto;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  font-size: 13px;
  font-weight: 500;
  margin-bottom: 0.375rem;
}

/* Workflow Preview */
.workflow-preview {
  margin-top: 1rem;
  padding: 0.75rem;
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
}

.workflow-preview h4 {
  font-size: 13px;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
}

.workflow-tasks-list {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.workflow-task-item {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  padding: 0.375rem;
  background: var(--color-bg);
  border-radius: var(--radius-sm);
}

.task-number {
  width: 20px;
  height: 20px;
  background: var(--color-primary-100);
  color: var(--color-primary-600);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 600;
  flex-shrink: 0;
}

.task-info {
  display: flex;
  flex-direction: column;
}

.task-name {
  font-size: 13px;
  font-weight: 500;
}

.task-details {
  font-size: 11px;
  color: var(--color-gray-500);
}

/* Employee Info Card */
.employee-info-card {
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.info-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.info-label {
  font-size: 11px;
  color: var(--color-gray-500);
}

.info-value {
  font-size: 13px;
  font-weight: 500;
}

.tasks-count {
  font-size: 11px;
  color: var(--color-gray-500);
  margin-top: 0.125rem;
}

/* Stage Tasks Section */
.stage-tasks-section {
  margin-bottom: 1rem;
}

.stage-task-count {
  font-size: 12px;
  color: var(--color-gray-500);
  margin-left: 0.375rem;
}

.drawer-task-card {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.5rem;
  margin-top: 0.375rem;
}

.task-card-main {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
}

.task-card-content {
  flex: 1;
}

.task-card-title-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.375rem;
  margin-bottom: 0.5rem;
}

.task-card-title {
  font-weight: 500;
  font-size: 13px;
}

.task-card-meta-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 12px;
  color: var(--color-gray-500);
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.empty-stage {
  text-align: center;
  padding: 0.75rem;
  color: var(--color-gray-400);
  font-size: 12px;
}

/* Task Info Card */
.task-info-card {
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
}

/* Task Description Section */
.task-description-section {
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.description-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 13px;
  color: var(--color-gray-700);
  margin-bottom: 0.5rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--color-divider);
}

.description-header i {
  color: var(--color-primary-600);
}

.description-content {
  font-size: 13px;
  line-height: 1.6;
  color: var(--color-gray-700);
}

.description-content p {
  margin: 0;
  white-space: pre-wrap;
}

.description-content .no-description {
  color: var(--color-gray-400);
  font-style: italic;
}

/* Required Items Section */
.required-items-section {
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.required-items-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 13px;
  color: var(--color-gray-700);
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--color-divider);
}

.required-items-header i {
  color: var(--color-primary-600);
}

.required-items-header span {
  flex: 1;
}

.required-items-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.required-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.required-item:hover {
  border-color: var(--color-primary-300);
  background: var(--color-primary-50);
}

.required-item.item-completed {
  background: var(--color-success-50);
  border-color: var(--color-success-200);
}

.required-item.item-completed .item-label {
  text-decoration: line-through;
  color: var(--color-gray-500);
}

.item-label {
  flex: 1;
  font-size: 13px;
  color: var(--color-gray-700);
  cursor: pointer;
}

.item-check-icon {
  color: var(--color-success-600);
  font-size: 14px;
}

.required-items-progress {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding-top: 0.5rem;
  border-top: 1px solid var(--color-divider);
}

.required-items-progress .progress-text {
  font-size: 12px;
  color: var(--color-gray-500);
  white-space: nowrap;
}

.required-items-progress :deep(.p-progressbar) {
  flex: 1;
}

/* Task Actions Section */
.task-actions-section {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding-top: 0.75rem;
  border-top: 1px solid var(--color-divider);
}

.action-buttons-row {
  display: flex;
  gap: 0.5rem;
}

/* Template/Trigger Options */
.template-option {
  display: flex;
  align-items: center;
  gap: 0.375rem;
}

.trigger-option {
  display: flex;
  flex-direction: column;
}

.trigger-label {
  font-weight: 500;
  font-size: 13px;
}

.trigger-desc {
  font-size: 11px;
  color: var(--color-gray-500);
}

/* Task Meta Card */
.task-meta-card {
  background: var(--color-gray-50);
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.meta-row {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  margin-bottom: 0.375rem;
}

.meta-row:last-child {
  margin-bottom: 0;
}

.meta-label {
  font-size: 13px;
  font-weight: 500;
}

.section-title {
  font-size: 13px;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
}

/* Assigned Employees List */
.assigned-employees-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.assigned-employee-card {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.75rem;
  transition: box-shadow 0.2s;
}

.assigned-employee-card:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.employee-card-main {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.employee-avatar {
  width: 32px;
  height: 32px;
  background: var(--color-primary-100);
  color: var(--color-primary-600);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}

.employee-details {
  flex: 1;
}

.employee-name {
  font-weight: 500;
  font-size: 13px;
}

.employee-meta {
  font-size: 11px;
  color: var(--color-gray-500);
}

.employee-status {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.125rem;
}

.due-date {
  font-size: 11px;
  color: var(--color-gray-500);
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.employee-progress {
  margin-bottom: 0.5rem;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: var(--color-gray-600);
  margin-bottom: 0.125rem;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 2rem;
  color: var(--color-gray-500);
  font-size: 12px;
}

/* Progress Table */
.progress-table :deep(.p-datatable-tbody > tr) {
  cursor: pointer;
}

.progress-table :deep(.p-datatable-tbody > tr:hover) {
  background: var(--color-gray-50) !important;
}

/* Progress Table Fit - No horizontal scroll */
.progress-table-fit {
  width: 100%;
}

.progress-table-fit :deep(.p-datatable-table) {
  table-layout: fixed;
  width: 100%;
}

.progress-table-fit :deep(.p-datatable-thead > tr > th),
.progress-table-fit :deep(.p-datatable-tbody > tr > td) {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  padding: 0.5rem 0.75rem;
}

.progress-table-fit :deep(.p-datatable-tbody > tr) {
  cursor: pointer;
}

.progress-table-fit :deep(.p-datatable-tbody > tr:hover) {
  background: var(--color-gray-50) !important;
}

.tasks-count-cell {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-700);
}

/* Tab Content */
.tab-content {
  padding-top: 0.75rem;
}

.task-stage-tabs {
  margin-top: 0.75rem;
}

/* Utility Classes */
.font-medium {
  font-weight: 500;
}

.w-full {
  width: 100%;
}

.flex-1 {
  flex: 1;
}

/* Responsive adjustments */
@media (max-width: 1200px) {
  .kpi-grid {
    grid-template-columns: 1fr 1fr;
  }

  .tasks-by-stage-grid,
  .tasks-stage-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .kpi-grid {
    grid-template-columns: 1fr;
  }

  .dashboard-header {
    flex-direction: column;
    gap: 0.75rem;
    align-items: flex-start;
  }

  .header-actions {
    width: 100%;
    flex-wrap: wrap;
  }

  .filter-controls {
    flex-direction: column;
  }

  .filter-dropdown {
    width: 100%;
  }
}
</style>
