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
        <div class="header-actions" v-if="currentUserRole !== 'Staff (End User)'">
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
                  <span class="stats-text">{{ stageProgress.preOnboarding.completed }} of {{ stageProgress.preOnboarding.total }} {{ currentUserRole === 'Staff (End User)' ? 'tasks' : 'employees' }}</span>
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
                  <span class="stats-text">{{ stageProgress.firstDay.completed }} of {{ stageProgress.firstDay.total }} {{ currentUserRole === 'Staff (End User)' ? 'tasks' : 'employees' }}</span>
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
                  <span class="stats-text">{{ stageProgress.nextDay.completed }} of {{ stageProgress.nextDay.total }} {{ currentUserRole === 'Staff (End User)' ? 'tasks' : 'employees' }}</span>
                  <span class="stats-percentage">{{ stageProgress.nextDay.percentage }}%</span>
                </div>
              </div>
              <ProgressBar :value="stageProgress.nextDay.percentage" :showValue="false" style="height: 8px;" />
            </div>
          </div>
        </div>

        <!-- For Non-Staff Users: Overdue Tasks Card -->
        <div v-if="currentUserRole !== 'Staff (End User)'" class="kpi-card">
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

        <!-- For Staff Users: Completed Tasks Card -->
        <div v-if="currentUserRole === 'Staff (End User)'" class="kpi-card">
          <div class="kpi-card-header">
            <i class="pi pi-check-circle" style="color: #16a34a;"></i>
            <span>Completed Tasks</span>
          </div>
          <div class="kpi-card-content">
            <div class="staff-stat-content">
              <div class="staff-stat-info">
                <div class="staff-stat-value">{{ staffCompletedTasks.length }}</div>
                <div class="staff-stat-label">Tasks completed</div>
              </div>
            </div>
            <div v-if="staffCompletedTasks.length > 0" class="staff-tasks-list">
              <div
                v-for="task in staffCompletedTasks.slice(0, 3)"
                :key="task.id"
                class="staff-task-item completed"
                @click="openTaskDetailsDrawer(task)"
              >
                <div class="staff-task-content">
                  <span class="staff-task-name">{{ task.task }}</span>
                  <span class="staff-task-meta">{{ task.type }} • {{ task.stage }}</span>
                </div>
                <i class="pi pi-eye"></i>
              </div>
              <p v-if="staffCompletedTasks.length > 3" class="staff-tasks-more">
                +{{ staffCompletedTasks.length - 3 }} more completed
              </p>
            </div>
            <div v-else class="no-staff-tasks">
              <i class="pi pi-info-circle"></i>
              <span>No completed tasks yet</span>
            </div>
          </div>
        </div>

        <!-- For Non-Staff Users: Alerts Card -->
        <div v-if="currentUserRole !== 'Staff (End User)'" class="kpi-card">
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

        <!-- For Staff Users: Not Started Card -->
        <div v-if="currentUserRole === 'Staff (End User)'" class="kpi-card">
          <div class="kpi-card-header">
            <i class="pi pi-clock" style="color: #6366f1;"></i>
            <span>Not Started</span>
          </div>
          <div class="kpi-card-content">
            <div class="staff-stat-content">
              <div class="staff-stat-info">
                <div class="staff-stat-value">{{ staffNotStartedTasks.length }}</div>
                <div class="staff-stat-label">Tasks not started</div>
              </div>
            </div>
            <div v-if="staffNotStartedTasks.length > 0" class="staff-tasks-list">
              <div
                v-for="task in staffNotStartedTasks.slice(0, 3)"
                :key="task.id"
                class="staff-task-item not-started"
                @click="openTaskDetailsDrawer(task)"
              >
                <div class="staff-task-content">
                  <span class="staff-task-name">{{ task.task }}</span>
                  <span class="staff-task-meta">{{ task.type }} • Due: {{ task.due }}</span>
                </div>
                <i class="pi pi-eye"></i>
              </div>
              <p v-if="staffNotStartedTasks.length > 3" class="staff-tasks-more">
                +{{ staffNotStartedTasks.length - 3 }} more to start
              </p>
            </div>
            <div v-else class="no-staff-tasks success">
              <i class="pi pi-check-circle"></i>
              <span>All tasks have been started!</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Onboarding Progress Table -->
      <div class="content-card" v-if="currentUserRole !== 'Staff (End User)'">
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

      <!-- Tasks Section -->
      <div class="content-card">
        <div class="card-header">
          <div>
            <h2 class="card-title">Tasks</h2>
            <p v-if="currentUserRole === 'Staff (End User)'" class="card-subtitle">Tasks assigned specifically to you</p>
          </div>
          <Button
            icon="pi pi-filter"
            label="Filter"
            severity="secondary"
            outlined
            size="small"
          />
        </div>

        <!-- Tabbed View for HR Admin -->
        <TabView v-if="currentUserRole !== 'Staff (End User)'" v-model:activeIndex="tasksViewTab" class="tasks-tabs">
          <!-- Assigned to Me Tab -->
          <TabPanel header="Assigned to Me">
            <DataTable :value="getTasksAssignedToMe" stripedRows responsiveLayout="scroll" class="tasks-table">
              <Column field="task" header="Task" sortable style="width: 22%">
                <template #body="{ data }">
                  <span class="font-medium">{{ data.task }}</span>
                </template>
              </Column>
              <Column field="assignee" header="Employee" sortable style="width: 15%" />
              <Column field="due" header="Due" sortable style="width: 12%">
                <template #body="{ data }">
                  <div class="due-cell">
                    <i class="pi pi-calendar"></i>
                    <span>{{ data.due }}</span>
                  </div>
                </template>
              </Column>
              <Column field="type" header="Type" sortable style="width: 13%">
                <template #body="{ data }">
                  <Tag :value="data.type" severity="secondary" />
                </template>
              </Column>
              <Column field="stage" header="Stage" sortable style="width: 14%">
                <template #body="{ data }">
                  <Tag :value="data.stage" :severity="getStageSeverity(data.stage)" :class="getStageClass(data.stage)" />
                </template>
              </Column>
              <Column field="status" header="Status" sortable style="width: 10%">
                <template #body="{ data }">
                  <StatusChip :status="normalizeStatus(data.status)" />
                </template>
              </Column>
              <Column header="Actions" style="width: 14%">
                <template #body="{ data }">
                  <div class="task-table-actions">
                    <Button
                      icon="pi pi-eye"
                      severity="secondary"
                      text
                      rounded
                      size="small"
                      title="View Details"
                      @click="openTaskDetailsDrawer(data)"
                    />
                    <Button
                      v-if="data.status !== 'completed'"
                      icon="pi pi-check-circle"
                      severity="success"
                      text
                      rounded
                      size="small"
                      title="Mark Complete"
                      @click="completeTask(data)"
                    />
                  </div>
                </template>
              </Column>
              <template #empty>
                <div class="empty-state">No tasks assigned to you</div>
              </template>
            </DataTable>
          </TabPanel>

          <!-- Team Tab -->
          <TabPanel header="Team">
            <DataTable :value="getTeamTasks" stripedRows responsiveLayout="scroll" class="tasks-table">
              <Column field="task" header="Task" sortable style="width: 20%">
                <template #body="{ data }">
                  <span class="font-medium">{{ data.task }}</span>
                </template>
              </Column>
              <Column field="assignee" header="Employee" sortable style="width: 13%" />
              <Column field="assignedTo" header="Assigned To" sortable style="width: 12%">
                <template #body="{ data }">
                  <Tag :value="data.assignedTo" severity="info" />
                </template>
              </Column>
              <Column field="due" header="Due" sortable style="width: 10%">
                <template #body="{ data }">
                  <div class="due-cell">
                    <i class="pi pi-calendar"></i>
                    <span>{{ data.due }}</span>
                  </div>
                </template>
              </Column>
              <Column field="type" header="Type" sortable style="width: 11%">
                <template #body="{ data }">
                  <Tag :value="data.type" severity="secondary" />
                </template>
              </Column>
              <Column field="stage" header="Stage" sortable style="width: 12%">
                <template #body="{ data }">
                  <Tag :value="data.stage" :severity="getStageSeverity(data.stage)" :class="getStageClass(data.stage)" />
                </template>
              </Column>
              <Column field="status" header="Status" sortable style="width: 10%">
                <template #body="{ data }">
                  <StatusChip :status="normalizeStatus(data.status)" />
                </template>
              </Column>
              <Column header="Actions" style="width: 12%">
                <template #body="{ data }">
                  <div class="task-table-actions">
                    <Button
                      icon="pi pi-eye"
                      severity="secondary"
                      text
                      rounded
                      size="small"
                      title="View Details"
                      @click="openTaskDetailsDrawer(data)"
                    />
                    <Button
                      v-if="data.status !== 'completed'"
                      icon="pi pi-check-circle"
                      severity="success"
                      text
                      rounded
                      size="small"
                      title="Mark Complete"
                      @click="completeTask(data)"
                    />
                  </div>
                </template>
              </Column>
              <template #empty>
                <div class="empty-state">No team tasks found</div>
              </template>
            </DataTable>
          </TabPanel>

          <!-- Unassigned Tab -->
          <TabPanel header="Unassigned">
            <DataTable :value="getUnassignedTasks" stripedRows responsiveLayout="scroll" class="tasks-table">
              <Column field="task" header="Task" sortable style="width: 22%">
                <template #body="{ data }">
                  <span class="font-medium">{{ data.task }}</span>
                </template>
              </Column>
              <Column field="assignee" header="Employee" sortable style="width: 15%" />
              <Column field="due" header="Due" sortable style="width: 12%">
                <template #body="{ data }">
                  <div class="due-cell">
                    <i class="pi pi-calendar"></i>
                    <span>{{ data.due }}</span>
                  </div>
                </template>
              </Column>
              <Column field="type" header="Type" sortable style="width: 13%">
                <template #body="{ data }">
                  <Tag :value="data.type" severity="secondary" />
                </template>
              </Column>
              <Column field="stage" header="Stage" sortable style="width: 14%">
                <template #body="{ data }">
                  <Tag :value="data.stage" :severity="getStageSeverity(data.stage)" :class="getStageClass(data.stage)" />
                </template>
              </Column>
              <Column field="status" header="Status" sortable style="width: 10%">
                <template #body="{ data }">
                  <StatusChip :status="normalizeStatus(data.status)" />
                </template>
              </Column>
              <Column header="Actions" style="width: 18%">
                <template #body="{ data }">
                  <div class="task-table-actions">
                    <Button
                      icon="pi pi-eye"
                      severity="secondary"
                      text
                      rounded
                      size="small"
                      title="View Details"
                      @click="openTaskDetailsDrawer(data)"
                    />
                    <Button
                      icon="pi pi-user-plus"
                      label="Assign"
                      severity="info"
                      outlined
                      size="small"
                      class="assign-dropdown-btn"
                      @click="(event) => toggleAssignPanel(event, data)"
                    />
                    <OverlayPanel
                      :ref="(el) => setAssignPanelRef(el, data.id)"
                      class="assign-panel"
                      :dismissable="true"
                    >
                      <div class="assign-panel-content">
                        <!-- Sticky Header: Search + Assign to Me -->
                        <div class="assign-panel-header">
                          <!-- Search Input -->
                          <div class="assign-search">
                            <i class="pi pi-search"></i>
                            <InputText
                              v-model="assignSearchQuery"
                              placeholder="Search..."
                              class="assign-search-input"
                              @input="filterAssignOptions"
                            />
                          </div>

                          <!-- Assign to Me Option -->
                          <div
                            class="assign-option assign-to-me"
                            @click="assignTask(data, 'me', currentUserName); closeAssignPanel(data.id)"
                          >
                            <i class="pi pi-user"></i>
                            <span>Assign to Me</span>
                          </div>
                        </div>

                        <!-- Scrollable Body: Departments + Employees -->
                        <div class="assign-panel-body">
                          <!-- Departments Section -->
                          <div class="assign-section" v-if="filteredDepartments.length > 0">
                            <div class="assign-section-header">
                              <i class="pi pi-building"></i>
                              <span>Departments</span>
                            </div>
                            <div class="assign-options-list">
                              <div
                                v-for="dept in filteredDepartments"
                                :key="dept.id"
                                class="assign-option"
                                @click="assignTask(data, 'department', dept.code); closeAssignPanel(data.id)"
                              >
                                <i class="pi pi-users"></i>
                                <span>{{ dept.name }}</span>
                              </div>
                            </div>
                          </div>

                          <!-- Employees Section -->
                          <div class="assign-section" v-if="filteredEmployees.length > 0">
                            <div class="assign-section-header">
                              <i class="pi pi-user-plus"></i>
                              <span>Employees</span>
                            </div>
                            <div class="assign-options-list">
                              <div
                                v-for="emp in filteredEmployees"
                                :key="emp.id"
                                class="assign-option"
                                @click="assignTask(data, 'employee', emp.name); closeAssignPanel(data.id)"
                              >
                                <i class="pi pi-user"></i>
                                <div class="employee-option-info">
                                  <span class="employee-name">{{ emp.name }}</span>
                                  <span class="employee-role">{{ emp.role }}</span>
                                </div>
                              </div>
                            </div>
                          </div>

                          <!-- No Results -->
                          <div v-if="assignSearchQuery && filteredDepartments.length === 0 && filteredEmployees.length === 0" class="assign-no-results">
                            <i class="pi pi-info-circle"></i>
                            <span>No results found</span>
                          </div>
                        </div>
                      </div>
                    </OverlayPanel>
                  </div>
                </template>
              </Column>
              <template #empty>
                <div class="empty-state">No unassigned tasks</div>
              </template>
            </DataTable>
          </TabPanel>
        </TabView>

        <!-- Staff View - Tasks by Stage Grid -->
        <div v-else class="tasks-by-stage-grid">
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
                <div v-if="!isStaffUser" class="task-item-actions" @click.stop>
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
              :value="`${getCompletedItemsCount(selectedTaskForDetails)}/${selectedTaskForDetails.requiredItems.length}`"
              :severity="getCompletedItemsCount(selectedTaskForDetails) === selectedTaskForDetails.requiredItems.length ? 'success' : 'warning'"
            />
          </div>
          <div class="required-items-list">
            <div
              v-for="(item, index) in selectedTaskForDetails.requiredItems"
              :key="index"
              class="required-item-card"
              :class="{ 'item-completed': item.completed, 'item-compulsory': item.isCompulsory }"
            >
              <div class="item-header">
                <span class="item-label">{{ item.name }}</span>
                <div class="item-badges">
                  <Tag
                    :value="item.isCompulsory ? 'Compulsory' : 'Optional'"
                    :severity="item.isCompulsory ? 'danger' : 'secondary'"
                    class="compulsory-tag"
                  />
                  <i v-if="item.completed" class="pi pi-check-circle item-check-icon"></i>
                </div>
              </div>
              <!-- Uploaded File Section (visible for HR Admin) -->
              <div v-if="item.uploadedFile" class="uploaded-file-section">
                <div class="file-preview">
                  <div class="file-icon-wrapper">
                    <i :class="['pi', getFileIcon(item.uploadedFile.type)]"></i>
                  </div>
                  <div class="file-info">
                    <span class="file-name">{{ item.uploadedFile.name }}</span>
                    <span class="file-meta">
                      {{ item.uploadedFile.size }} • Uploaded {{ item.uploadedFile.uploadedAt }}
                    </span>
                  </div>
                  <div class="file-actions">
                    <Button
                      icon="pi pi-eye"
                      severity="secondary"
                      text
                      size="small"
                      title="Preview"
                      @click="previewFile(item.uploadedFile)"
                    />
                    <Button
                      icon="pi pi-download"
                      severity="secondary"
                      text
                      size="small"
                      title="Download"
                      @click="downloadFile(item.uploadedFile)"
                    />
                  </div>
                </div>
              </div>
              <!-- No File Uploaded -->
              <div v-else class="no-file-section">
                <i class="pi pi-inbox"></i>
                <span>No file uploaded yet</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Filled Information Section (for Information type tasks) -->
        <div v-if="selectedTaskForDetails.filledInfo && selectedTaskForDetails.filledInfo.length > 0" class="filled-info-section">
          <div class="filled-info-header">
            <i class="pi pi-list"></i>
            <span>Filled Information</span>
            <Tag
              :value="`${getFilledInfoCount(selectedTaskForDetails)}/${selectedTaskForDetails.filledInfo.length}`"
              :severity="getFilledInfoCount(selectedTaskForDetails) === selectedTaskForDetails.filledInfo.length ? 'success' : 'warning'"
            />
          </div>
          <div class="filled-info-list">
            <div
              v-for="(info, index) in selectedTaskForDetails.filledInfo"
              :key="index"
              class="filled-info-item"
              :class="{ 'info-filled': info.value }"
            >
              <div class="info-field-label">{{ info.label }}</div>
              <div v-if="info.value" class="info-field-value">{{ info.value }}</div>
              <div v-else class="info-field-empty">Not provided</div>
            </div>
          </div>
        </div>

        <!-- System Access Section (for System type tasks) -->
        <div v-if="selectedTaskForDetails.systemAccess && selectedTaskForDetails.systemAccess.length > 0" class="system-access-section">
          <div class="system-access-header">
            <i class="pi pi-cog"></i>
            <span>System & Application Access</span>
            <Tag
              :value="`${getGrantedSystemsCount(selectedTaskForDetails)}/${selectedTaskForDetails.systemAccess.length}`"
              :severity="getGrantedSystemsCount(selectedTaskForDetails) === selectedTaskForDetails.systemAccess.length ? 'success' : 'warning'"
            />
          </div>
          <div class="system-access-list">
            <div
              v-for="(system, index) in selectedTaskForDetails.systemAccess"
              :key="index"
              class="system-access-card"
              :class="{ 'system-granted': system.granted }"
            >
              <div class="system-card-header">
                <div class="system-info">
                  <span class="system-number">#{{ index + 1 }}</span>
                  <span class="system-name">{{ system.name }}</span>
                </div>
                <div class="system-status-badge">
                  <Tag
                    :value="system.granted ? 'Granted' : 'Pending'"
                    :severity="system.granted ? 'success' : 'warning'"
                    class="status-tag"
                  />
                </div>
              </div>
              <div v-if="system.description" class="system-description">
                {{ system.description }}
              </div>
              <div class="system-details">
                <div class="system-detail-item">
                  <i class="pi pi-user"></i>
                  <span>PIC: <strong>{{ system.pic }}</strong></span>
                </div>
                <div v-if="system.grantedAt" class="system-detail-item">
                  <i class="pi pi-calendar"></i>
                  <span>Granted: {{ system.grantedAt }}</span>
                </div>

                <!-- IT/PIC Action Section - Only show for IT/PIC users when not granted -->
                <div v-if="isITPICUser && !system.granted" class="itpic-action-section">
                  <div class="action-section-header">
                    <i class="pi pi-key"></i>
                    <span>Configure Access Credentials</span>
                  </div>
                  <div class="credentials-form">
                    <div class="form-row">
                      <div class="form-field">
                        <label>Username/Email</label>
                        <InputText
                          v-model="system.tempCredentials.username"
                          placeholder="Enter username or email"
                          class="w-full"
                        />
                      </div>
                    </div>
                    <div class="form-row">
                      <div class="form-field">
                        <label>Initial Password</label>
                        <InputText
                          v-model="system.tempCredentials.password"
                          placeholder="Enter initial password"
                          class="w-full"
                        />
                      </div>
                    </div>
                    <div class="form-row">
                      <div class="form-field">
                        <label>Remarks (Optional)</label>
                        <Textarea
                          v-model="system.tempCredentials.remarks"
                          placeholder="Add any additional notes..."
                          :rows="2"
                          class="w-full"
                        />
                      </div>
                    </div>
                    <div class="action-buttons">
                      <Button
                        label="Grant Access"
                        icon="pi pi-check"
                        severity="success"
                        size="small"
                        @click="grantSystemAccess(system, index)"
                      />
                    </div>
                  </div>
                </div>

                <!-- Show credentials if granted (for all users) -->
                <div v-if="system.credentials" class="system-credentials">
                  <div class="credentials-header">
                    <i class="pi pi-key"></i>
                    <span>Access Credentials</span>
                  </div>
                  <div class="credentials-content">
                    <div v-if="system.credentials.username" class="credential-item">
                      <span class="credential-label">Username:</span>
                      <span class="credential-value">{{ system.credentials.username }}</span>
                    </div>
                    <div v-if="system.credentials.email" class="credential-item">
                      <span class="credential-label">Email:</span>
                      <span class="credential-value">{{ system.credentials.email }}</span>
                    </div>
                    <div v-if="system.credentials.password" class="credential-item">
                      <span class="credential-label">Password:</span>
                      <span class="credential-value">{{ system.credentials.password }}</span>
                    </div>
                  </div>
                </div>

                <!-- IT/PIC can revoke access if already granted -->
                <div v-if="isITPICUser && system.granted" class="itpic-revoke-section">
                  <Button
                    label="Revoke Access"
                    icon="pi pi-times"
                    severity="danger"
                    size="small"
                    outlined
                    @click="revokeSystemAccess(system, index)"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Asset Details Section (for Asset type tasks) -->
        <div v-if="selectedTaskForDetails.assetItems && selectedTaskForDetails.assetItems.length > 0" class="asset-details-section">
          <div class="asset-details-header">
            <i class="pi pi-box"></i>
            <span>Asset Details</span>
            <Tag
              :value="`${getIssuedAssetsCount(selectedTaskForDetails)}/${selectedTaskForDetails.assetItems.length}`"
              :severity="getIssuedAssetsCount(selectedTaskForDetails) === selectedTaskForDetails.assetItems.length ? 'success' : 'warning'"
            />
          </div>
          <div class="asset-details-list">
            <div
              v-for="(asset, index) in selectedTaskForDetails.assetItems"
              :key="index"
              class="asset-item-card"
              :class="{ 'asset-issued': asset.issued }"
            >
              <div class="asset-card-header">
                <div class="asset-info">
                  <span class="asset-number">#{{ index + 1 }}</span>
                  <span class="asset-name">{{ asset.name }}</span>
                </div>
                <div class="asset-status-badge">
                  <Tag
                    :value="asset.issued ? 'Issued' : 'Pending'"
                    :severity="asset.issued ? 'success' : 'warning'"
                    class="status-tag"
                  />
                </div>
              </div>
              <div v-if="asset.description" class="asset-description">
                {{ asset.description }}
              </div>
              <div class="asset-details-content">
                <div class="asset-detail-row">
                  <div class="asset-detail-item">
                    <i class="pi pi-user"></i>
                    <span>PIC: <strong>{{ asset.pic }}</strong></span>
                  </div>
                  <div v-if="asset.issuedAt" class="asset-detail-item">
                    <i class="pi pi-calendar"></i>
                    <span>Issued: {{ asset.issuedAt }}</span>
                  </div>
                </div>

                <!-- IT/PIC Action Section - Only show for IT/PIC users when not issued -->
                <div v-if="isITPICUser && !asset.issued" class="itpic-action-section orange">
                  <div class="action-section-header">
                    <i class="pi pi-box"></i>
                    <span>Issue Asset</span>
                  </div>
                  <div class="asset-issue-form">
                    <div class="form-row">
                      <div class="form-field">
                        <label>Serial Number <span class="required">*</span></label>
                        <InputText
                          v-model="asset.tempData.serialNumber"
                          placeholder="Enter asset serial number"
                          class="w-full"
                        />
                      </div>
                    </div>
                    <div class="form-row">
                      <div class="form-field">
                        <label>Remarks (Optional)</label>
                        <Textarea
                          v-model="asset.tempData.remarks"
                          placeholder="Add any notes about this asset..."
                          :rows="2"
                          class="w-full"
                        />
                      </div>
                    </div>
                    <div class="form-row">
                      <div class="form-field">
                        <label>Hand-over Letter</label>
                        <div class="file-upload-area">
                          <input
                            type="file"
                            :id="`handover-file-${index}`"
                            accept=".pdf,.doc,.docx"
                            @change="(e) => handleHandoverFileUpload(e, asset)"
                            style="display: none"
                          />
                          <label :for="`handover-file-${index}`" class="upload-label">
                            <i class="pi pi-upload"></i>
                            <span v-if="!asset.tempData.handoverFile">Click to upload hand-over letter</span>
                            <span v-else>{{ asset.tempData.handoverFile.name }}</span>
                          </label>
                        </div>
                      </div>
                    </div>
                    <div class="action-buttons">
                      <Button
                        label="Issue Asset"
                        icon="pi pi-check"
                        severity="warning"
                        size="small"
                        @click="issueAsset(asset, index)"
                      />
                    </div>
                  </div>
                </div>

                <!-- Show issued details (for all users when issued) -->
                <div v-if="asset.serialNumber" class="asset-serial-section">
                  <div class="serial-header">
                    <i class="pi pi-tag"></i>
                    <span>Serial Number</span>
                  </div>
                  <div class="serial-value">{{ asset.serialNumber }}</div>
                </div>
                <div v-if="asset.handoverLetter" class="asset-handover-section">
                  <div class="handover-header">
                    <i class="pi pi-file"></i>
                    <span>Hand-over Letter</span>
                    <Tag
                      :value="asset.handoverLetter.signed ? 'Signed' : 'Uploaded'"
                      :severity="asset.handoverLetter.signed ? 'success' : 'info'"
                      class="handover-tag"
                    />
                  </div>
                  <div class="handover-file">
                    <div class="file-icon-wrapper orange">
                      <i class="pi pi-file-pdf"></i>
                    </div>
                    <div class="file-info">
                      <span class="file-name">{{ asset.handoverLetter.fileName }}</span>
                      <span class="file-meta">{{ asset.handoverLetter.uploadedAt }}</span>
                    </div>
                    <div class="file-actions">
                      <Button
                        icon="pi pi-eye"
                        severity="secondary"
                        text
                        size="small"
                        title="Preview"
                        @click="previewFile({ name: asset.handoverLetter.fileName })"
                      />
                      <Button
                        icon="pi pi-download"
                        severity="secondary"
                        text
                        size="small"
                        title="Download"
                        @click="downloadFile({ name: asset.handoverLetter.fileName })"
                      />
                    </div>
                  </div>
                </div>
                <div v-if="asset.remarks" class="asset-remarks-section">
                  <div class="remarks-header">
                    <i class="pi pi-comment"></i>
                    <span>Remarks</span>
                  </div>
                  <div class="remarks-content">{{ asset.remarks }}</div>
                </div>

                <!-- IT/PIC can revoke/recall asset if already issued -->
                <div v-if="isITPICUser && asset.issued" class="itpic-revoke-section">
                  <Button
                    label="Recall Asset"
                    icon="pi pi-undo"
                    severity="danger"
                    size="small"
                    outlined
                    @click="recallAsset(asset, index)"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Questionnaire Section (for Questionnaire type tasks) -->
        <div v-if="selectedTaskForDetails.questionnaire && selectedTaskForDetails.questionnaire.length > 0" class="questionnaire-section">
          <div class="questionnaire-header">
            <i class="pi pi-question-circle"></i>
            <span>Questionnaire</span>
            <Tag
              :value="`${getAnsweredQuestionsCount(selectedTaskForDetails)}/${selectedTaskForDetails.questionnaire.length}`"
              :severity="getAnsweredQuestionsCount(selectedTaskForDetails) === selectedTaskForDetails.questionnaire.length ? 'success' : 'warning'"
            />
          </div>
          <div class="questionnaire-list">
            <div
              v-for="(question, index) in selectedTaskForDetails.questionnaire"
              :key="index"
              class="question-card"
              :class="{ 'question-answered': question.answer }"
            >
              <div class="question-card-header">
                <div class="question-info">
                  <span class="question-number">Q{{ index + 1 }}</span>
                  <span class="question-text">{{ question.question }}</span>
                </div>
              </div>
              <div class="question-meta">
                <Tag :value="question.type" severity="secondary" class="type-tag" />
                <Tag
                  :value="question.required ? 'Required' : 'Optional'"
                  :severity="question.required ? 'info' : 'secondary'"
                  class="required-tag"
                />
              </div>
              <div v-if="question.answer" class="question-answer-section">
                <div class="answer-header">
                  <span>Answer</span>
                </div>
                <div class="answer-content">{{ question.answer }}</div>
              </div>
              <div v-else class="question-no-answer">
                <i class="pi pi-clock"></i>
                <span>Awaiting response</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="task-actions-section">
          <!-- Unassigned Task Actions -->
          <template v-if="isTaskUnassigned(selectedTaskForDetails)">
            <Button
              icon="pi pi-user-plus"
              label="Assign"
              class="w-full"
              @click="(event) => toggleTaskDrawerAssignPanel(event)"
            />
            <OverlayPanel
              ref="taskDrawerAssignPanelRef"
              class="assign-panel"
              :dismissable="true"
            >
              <div class="assign-panel-content">
                <!-- Sticky Header: Search + Assign to Me -->
                <div class="assign-panel-header">
                  <!-- Search Input -->
                  <div class="assign-search">
                    <i class="pi pi-search"></i>
                    <InputText
                      v-model="assignSearchQuery"
                      placeholder="Search..."
                      class="assign-search-input"
                    />
                  </div>

                  <!-- Assign to Me Option -->
                  <div
                    class="assign-option assign-to-me"
                    @click="assignTaskFromDrawer('me', currentUserName)"
                  >
                    <i class="pi pi-user"></i>
                    <span>Assign to Me</span>
                  </div>
                </div>

                <!-- Scrollable Body: Departments + Employees -->
                <div class="assign-panel-body">
                  <!-- Departments Section -->
                  <div class="assign-section" v-if="filteredDepartments.length > 0">
                    <div class="assign-section-header">
                      <i class="pi pi-building"></i>
                      <span>Departments</span>
                    </div>
                    <div class="assign-options-list">
                      <div
                        v-for="dept in filteredDepartments"
                        :key="dept.id"
                        class="assign-option"
                        @click="assignTaskFromDrawer('department', dept.code)"
                      >
                        <i class="pi pi-users"></i>
                        <span>{{ dept.name }}</span>
                      </div>
                    </div>
                  </div>

                  <!-- Employees Section -->
                  <div class="assign-section" v-if="filteredEmployees.length > 0">
                    <div class="assign-section-header">
                      <i class="pi pi-user-plus"></i>
                      <span>Employees</span>
                    </div>
                    <div class="assign-options-list">
                      <div
                        v-for="emp in filteredEmployees"
                        :key="emp.id"
                        class="assign-option"
                        @click="assignTaskFromDrawer('employee', emp.name)"
                      >
                        <i class="pi pi-user"></i>
                        <div class="employee-option-info">
                          <span class="employee-name">{{ emp.name }}</span>
                          <span class="employee-role">{{ emp.role }}</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- No Results -->
                  <div v-if="assignSearchQuery && filteredDepartments.length === 0 && filteredEmployees.length === 0" class="assign-no-results">
                    <i class="pi pi-info-circle"></i>
                    <span>No results found</span>
                  </div>
                </div>
              </div>
            </OverlayPanel>
            <Button
              icon="pi pi-trash"
              label="Delete"
              severity="danger"
              outlined
              class="w-full mt-2"
              @click="deleteTask(selectedTaskForDetails); isTaskDetailsDrawerOpen = false"
            />
          </template>

          <!-- Assigned Task Actions (hidden for Staff users - PIC handles completion) -->
          <template v-else-if="!isStaffUser">
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
                  v-if="!(isITPICUser && (selectedTaskForDetails.type === 'System/Access' || selectedTaskForDetails.type === 'System' || selectedTaskForDetails.type === 'Asset'))"
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
import { useUserStore } from '../../../stores/userStore'
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
import Menu from 'primevue/menu'
import OverlayPanel from 'primevue/overlaypanel'
import StatusChip from '../../../components/ui/StatusChip.vue'

const toast = useToast()
const router = useRouter()
const userStore = useUserStore()

// Current user role from store
const currentUserRole = computed(() => userStore.currentRole?.name || 'HR Admin')
const currentUserName = computed(() => userStore.currentUser?.name || 'Ahmed Fauzi')

// Check if current user is IT/PIC
const isITPICUser = computed(() => currentUserRole.value === 'IT/PIC')
const isStaffUser = computed(() => currentUserRole.value === 'Staff (End User)')

// Companies
const companies = ref([
  { id: 'timetec-cloud', name: 'TimeTec Cloud' },
  { id: 'timetec-computing', name: 'TimeTec Computing' },
  { id: 'fingertech', name: 'FingerTec' }
])

// Departments for task assignment
const departments = ref([
  { id: 'hr', name: 'Human Resources', code: 'HR' },
  { id: 'it', name: 'Information Technology', code: 'IT' },
  { id: 'finance', name: 'Finance & Accounting', code: 'Finance' },
  { id: 'operations', name: 'Operations', code: 'Operations' },
  { id: 'marketing', name: 'Marketing', code: 'Marketing' },
  { id: 'sales', name: 'Sales', code: 'Sales' }
])

// Employees for task assignment
const employees = ref([
  { id: 'emp-1', name: 'Ahmed Fauzi', department: 'hr', role: 'HR Admin' },
  { id: 'emp-2', name: 'Farah Kassim', department: 'hr', role: 'HR Coordinator' },
  { id: 'emp-3', name: 'Nizam Salleh', department: 'it', role: 'IT Manager' },
  { id: 'emp-4', name: 'Lina Wong', department: 'it', role: 'IT Support' },
  { id: 'emp-5', name: 'Razak Hassan', department: 'operations', role: 'Operations Manager' },
  { id: 'emp-6', name: 'Jason Tan', department: 'finance', role: 'Finance Manager' },
  { id: 'emp-7', name: 'Kamala Devi', department: 'marketing', role: 'Marketing Lead' },
  { id: 'emp-8', name: 'David Kim', department: 'sales', role: 'Sales Manager' }
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
const tasksViewTab = ref(0)
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

// Assign panel refs and state
const assignPanelRefs = ref({})
const currentAssignTask = ref(null)
const assignSearchQuery = ref('')
const taskDrawerAssignPanelRef = ref(null)

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
    { name: 'IC (Identity Card)', completed: true, isCompulsory: true, uploadedFile: { name: 'IC_Aina_Zulkifli.pdf', type: 'pdf', size: '1.2 MB', uploadedAt: '2025-09-15', uploadedBy: 'Aina Zulkifli' } },
    { name: 'Passport', completed: true, isCompulsory: false, uploadedFile: { name: 'Passport_Aina_Zulkifli.pdf', type: 'pdf', size: '2.4 MB', uploadedAt: '2025-09-15', uploadedBy: 'Aina Zulkifli' } }
  ] },
  { id: 6, task: 'Payroll & Banking Information Setup', assignee: 'Aina Zulkifli', due: '2025-09-18', type: 'Information', indicator: 'Onboarding', status: 'pending', assignedTo: 'Staff', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Complete payroll setup for the new employee. Ensure all information is accurate before the first pay cycle.', filledInfo: [
    { label: 'Bank Name', value: 'Maybank' },
    { label: 'Bank Account Number', value: '1234-5678-9012' },
    { label: 'Account Holder Name', value: 'Aina Zulkifli' },
    { label: 'Tax Identification Number (TIN)', value: 'TIN-12345678' },
    { label: 'EPF Number', value: '' },
    { label: 'SOCSO Number', value: '' }
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
  { id: 9, task: 'Employee Feedback Survey', assignee: 'Aina Zulkifli', due: '2025-09-23', type: 'Questionnaire', indicator: 'Onboarding', status: 'pending', assignedTo: 'HR', stage: 'Next Day-Onboarding', company: 'timetec-cloud', description: 'Send and collect the 7-day onboarding feedback survey. Analyze responses and share insights with the onboarding team.', questionnaire: [
    { question: 'How would you rate your overall onboarding experience?', type: 'Picklist (Single)', required: true, answer: 'Excellent' },
    { question: 'Which aspects of onboarding were most helpful?', type: 'Picklist (Multiple)', required: true, answer: 'Welcome orientation, Team introduction, Equipment setup' },
    { question: 'How satisfied are you with your workstation and equipment?', type: 'Picklist (Single)', required: true, answer: 'Very Satisfied' },
    { question: 'How well did your team help you integrate into the workplace?', type: 'Picklist (Single)', required: true, answer: 'Excellent' },
    { question: 'What suggestions do you have for improving the onboarding process?', type: 'Text (Multiple Lines)', required: false, answer: 'The onboarding process was smooth overall. I appreciated the detailed orientation session and the warm welcome from the team. One suggestion would be to provide a digital checklist that employees can access on their phones.' }
  ] },
  { id: 10, task: 'Office Tour & Badge Photo', assignee: 'Aina Zulkifli', due: '2025-09-16', type: 'General Task', indicator: 'Onboarding', status: 'pending', assignedTo: 'Staff', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Conduct office tour and take badge photo:\n\n• Tour all office areas and facilities\n• Introduce to key personnel\n• Show emergency exits and assembly points\n• Take professional photo for ID badge\n• Explain office etiquette and rules\n\nDuration: Approximately 45 minutes.' },
  { id: 11, task: 'Day 1 Orientation', assignee: 'Aina Zulkifli', due: '2025-09-16', type: 'Meeting/Event', indicator: 'Onboarding', status: 'pending', assignedTo: 'HR', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Conduct comprehensive Day 1 orientation:\n\n• Welcome and introductions\n• Company overview presentation\n• HR policies and procedures\n• Benefits explanation\n• IT systems overview\n• Safety briefing\n\nProvide orientation materials and answer any questions.' },
  { id: 12, task: 'Grant Email & HRMS Access', assignee: 'Aina Zulkifli', due: '2025-09-16', type: 'System', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Set up and verify all system access on Day 1:\n\n• Activate email account\n• Verify HRMS login\n• Grant access to shared drives\n• Set up VPN if required\n• Configure software licenses\n\nProvide login credentials and basic training on system usage.', systemAccess: [
    { name: 'Corporate Email (Outlook)', description: 'Set up company email account with standard mailbox size and distribution lists', pic: 'IT Admin', granted: true, grantedAt: '2025-09-16', credentials: { email: 'aina.zulkifli@timetec.com', password: 'T1m3T3c@2025' } },
    { name: 'HRMS Portal', description: 'Grant access to HR Management System for leave, claims, and employee self-service', pic: 'HR Admin', granted: true, grantedAt: '2025-09-16', credentials: { username: 'aina.zulkifli', password: 'Hr$P0rt@l2025' } },
    { name: 'SharePoint & OneDrive', description: 'Configure cloud storage and document collaboration access', pic: 'IT Admin', granted: false, credentials: null }
  ] },
  { id: 13, task: 'Issue Laptop & ID Card', assignee: 'Aina Zulkifli', due: '2025-09-16', type: 'Asset', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Issue company assets to the new employee:\n\n• Laptop with all required software installed\n• Power adapter and accessories\n• ID card with access permissions\n• Asset acknowledgment form\n\nRecord all serial numbers and have employee sign asset receipt form.', assetItems: [
    { name: 'Laptop Computer', description: 'Business laptop with Windows 11, Microsoft Office suite, and essential software pre-installed', pic: 'IT Admin', issued: true, issuedAt: '2025-09-16', serialNumber: 'DELL-XPS15-2025-001234', handoverLetter: { fileName: 'Laptop_Handover_Aina.pdf', uploadedAt: '2025-09-16', signed: true }, remarks: 'Laptop in excellent condition. All software installed and tested.' },
    { name: 'Employee ID Card', description: 'Photo ID card with building access permissions and employee identification number', pic: 'HR Admin', issued: true, issuedAt: '2025-09-16', serialNumber: 'EMP-2025-001234', handoverLetter: { fileName: 'IDCard_Handover_Aina.pdf', uploadedAt: '2025-09-16', signed: true }, remarks: null }
  ] },
  { id: 20, task: 'Issue Laptop & ID Card', assignee: 'Jessica Wong', due: '2025-09-28', type: 'Asset', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Prepare and configure laptop for new employee:\n\n• Install standard software suite\n• Configure email client\n• Set up security software\n• Prepare ID card with photo\n• Test all equipment\n\nHave assets ready for collection before start date.', assetItems: [
    { name: 'Laptop Computer', description: 'Dell XPS 15 with Windows 11 Pro and Office 365 pre-installed', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: 'Laptop being prepared in IT staging area' },
    { name: 'Employee ID Card', description: 'Photo ID card with building access and attendance functionality', pic: 'HR Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: 'Pending photo submission' }
  ] },
  // TimeTec Computing tasks
  { id: 14, task: 'Welcome Pack', assignee: 'Siti Aminah', due: '2025-09-19', type: 'General Task', indicator: 'Onboarding', status: 'completed', assignedTo: 'HR Coordinator', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Prepare welcome pack with company materials, handbook, and office supplies for the new team member.' },
  { id: 15, task: 'Setup Company Email', assignee: 'Siti Aminah', due: '2025-09-20', type: 'System/Access', indicator: 'Onboarding', status: 'completed', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Create company email account and configure all necessary access permissions for internal systems.', systemAccess: [
    { name: 'Microsoft Outlook', description: 'Company email account with standard mailbox and calendar access', pic: 'IT Admin', granted: true, grantedAt: '2025-09-19', credentials: { email: 'siti.aminah@timetec.com', password: 'Welcome@2025!' } },
    { name: 'Microsoft Teams', description: 'Team collaboration and communication platform access', pic: 'IT Admin', granted: true, grantedAt: '2025-09-19', credentials: null }
  ] },
  { id: 16, task: 'Hardware Setup', assignee: 'Amir Hamzah', due: '2025-09-26', type: 'Asset', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Set up workstation with all required hardware including computer, monitors, keyboard, mouse, and any specialized equipment needed for the role.', assetItems: [
    { name: 'Desktop Computer', description: 'HP ProDesk 400 G7 with Intel i7, 16GB RAM, 512GB SSD', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: 'Unit being configured' },
    { name: 'Monitor', description: 'Dell 24" Full HD monitor with adjustable stand', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: null },
    { name: 'Keyboard & Mouse', description: 'Wireless keyboard and mouse combo set', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: null }
  ] },
  { id: 17, task: 'Team Introduction Meeting', assignee: 'Siti Aminah', due: '2025-09-19', type: 'Meeting/Event', indicator: 'Onboarding', status: 'completed', assignedTo: 'Manager', stage: '1st Day-Onboarding', company: 'timetec-computing', description: 'Organize team meeting to introduce the new employee. Include brief presentations from team members about their roles and current projects.' },
  { id: 18, task: 'Complete Training Modules', assignee: 'Siti Aminah', due: '2025-09-22', type: 'General Task', indicator: 'Onboarding', status: 'pending', assignedTo: 'Staff', stage: 'Next Day-Onboarding', company: 'timetec-computing', description: 'Complete all mandatory training modules:\n\n• Company compliance training\n• Security awareness\n• Product knowledge basics\n• System usage tutorials\n\nTrack completion in the learning management system.' },
  // FingerTec tasks
  { id: 19, task: 'Onboarding Checklist Review', assignee: 'Daniel Lee', due: '2025-09-21', type: 'General Task', indicator: 'Onboarding', status: 'completed', assignedTo: 'HR Coordinator', stage: 'Pre-Onboarding', company: 'fingertech', description: 'Review and verify completion of all pre-onboarding checklist items before the employee\'s start date.' },
  { id: 21, task: 'Security Access Setup', assignee: 'Daniel Lee', due: '2025-09-22', type: 'System/Access', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'fingertech', description: 'Configure security access including building access card, system login credentials, and appropriate permission levels based on role requirements.', systemAccess: [
    { name: 'Active Directory', description: 'Windows domain account with group policy access', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'Building Access Control', description: 'Access card registration for main entrance and department areas', pic: 'Security Admin', granted: false, credentials: null },
    { name: 'VPN Access', description: 'Remote access VPN for work from home capability', pic: 'IT Admin', granted: false, credentials: null }
  ] },
  { id: 22, task: 'Department Tour', assignee: 'Daniel Lee', due: '2025-09-21', type: 'Meeting/Event', indicator: 'Onboarding', status: 'completed', assignedTo: 'Manager', stage: '1st Day-Onboarding', company: 'fingertech', description: 'Conduct a comprehensive tour of the department, introducing the new employee to team members and explaining workflows and collaboration points.' },
  { id: 23, task: 'Company Policy Briefing', assignee: 'Sarah Ibrahim', due: '2025-10-06', type: 'Meeting/Event', indicator: 'Onboarding', status: 'not-started', assignedTo: 'HR Coordinator', stage: 'Pre-Onboarding', company: 'fingertech', description: 'Conduct briefing session covering all company policies:\n\n• Code of conduct\n• Leave policies\n• Performance review process\n• Communication guidelines\n• Dress code\n\nProvide policy handbook and answer questions.' },
  // Unassigned Tasks - TimeTec Cloud
  { id: 24, task: 'Configure VPN Access', assignee: 'Jessica Wong', due: '2025-09-28', type: 'System/Access', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Unassigned', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Configure VPN access for remote work capability:\n\n• Set up VPN client on employee device\n• Generate VPN credentials\n• Configure access permissions\n• Test connectivity to internal resources\n• Provide VPN usage guidelines' },
  { id: 25, task: 'Setup Development Environment', assignee: 'Jessica Wong', due: '2025-09-29', type: 'System/Access', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Unassigned', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Set up complete development environment:\n\n• Install IDE and required plugins\n• Configure version control (Git)\n• Set up local development server\n• Install project dependencies\n• Configure code formatting and linting tools' },
  { id: 26, task: 'Team Introduction Meeting', assignee: 'Jessica Wong', due: '2025-10-01', type: 'Meeting/Event', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Unassigned', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Organize team introduction meeting:\n\n• Schedule meeting with all team members\n• Prepare introduction presentation\n• Plan team bonding activities\n• Share team structure and roles\n• Discuss current projects and priorities' },
  { id: 27, task: 'Security Badge Activation', assignee: 'Harith Rahman', due: '2025-09-25', type: 'Asset', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Unassigned', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Activate security badge for building access:\n\n• Encode access card with appropriate permissions\n• Set up floor and room access levels\n• Register fingerprint for biometric access\n• Test all access points\n• Provide access guidelines and emergency procedures' },
  // Unassigned Tasks - TimeTec Computing
  { id: 28, task: 'Assign Workspace', assignee: 'Amir Hamzah', due: '2025-09-27', type: 'Asset', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Unassigned', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Assign and prepare workspace for new employee:\n\n• Allocate desk/cubicle location\n• Set up ergonomic chair and equipment\n• Install desk phone with extension\n• Provide office supplies kit\n• Add name plate and department signage' },
  { id: 29, task: 'Parking Pass Issuance', assignee: 'Amir Hamzah', due: '2025-09-27', type: 'General Task', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Unassigned', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Issue parking pass to new employee:\n\n• Register vehicle details in system\n• Generate parking access card\n• Assign parking bay if applicable\n• Explain parking rules and designated areas\n• Provide contact for parking issues' },
  { id: 30, task: 'Software License Allocation', assignee: 'Siti Aminah', due: '2025-09-20', type: 'System/Access', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Unassigned', stage: 'Next Day-Onboarding', company: 'timetec-computing', description: 'Allocate required software licenses:\n\n• Assign Microsoft Office 365 license\n• Allocate project management tool access\n• Set up design software licenses (if applicable)\n• Configure collaboration tool access\n• Document all allocated licenses' },
  // Unassigned Tasks - FingerTec
  { id: 31, task: 'Biometric Enrollment', assignee: 'Daniel Lee', due: '2025-09-22', type: 'System/Access', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Unassigned', stage: '1st Day-Onboarding', company: 'fingertech', description: 'Enroll employee in biometric attendance system:\n\n• Register fingerprint templates\n• Set up facial recognition profile\n• Configure attendance schedule\n• Link to payroll system\n• Test clock-in/clock-out functionality' },
  { id: 32, task: 'Department Budget Briefing', assignee: 'Sarah Ibrahim', due: '2025-10-07', type: 'Meeting/Event', indicator: 'Onboarding', status: 'not-started', assignedTo: 'Unassigned', stage: 'Next Day-Onboarding', company: 'fingertech', description: 'Conduct department budget briefing:\n\n• Explain budget allocation process\n• Review expense approval workflow\n• Demonstrate expense reporting system\n• Discuss procurement procedures\n• Provide budget policy documentation' },
  // IT/PIC Assigned Tasks - System/Access & Asset Types (for David Kim)
  // TimeTec Cloud - IT/PIC Tasks
  { id: 33, task: 'Configure Project Management Tool Access', assignee: 'Harith Rahman', due: '2025-09-26', type: 'System/Access', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Grant access to project management tools:\n\n• Create Jira/Asana account\n• Add to relevant project boards\n• Set up notification preferences\n• Configure dashboard views\n• Assign to initial projects', systemAccess: [
    { name: 'Jira Software', description: 'Project tracking and issue management system', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'Confluence', description: 'Team collaboration and documentation platform', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'Slack Workspace', description: 'Team communication and messaging platform', pic: 'IT Admin', granted: true, grantedAt: '2025-09-20', credentials: { email: 'harith.rahman@timetec.com', workspace: 'TimeTec Cloud' } }
  ] },
  { id: 34, task: 'Setup Cloud Development Access', assignee: 'Jessica Wong', due: '2025-09-28', type: 'System/Access', indicator: 'Onboarding', status: 'not-started', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Configure cloud platform access:\n\n• Create AWS/Azure account\n• Set up IAM roles and permissions\n• Configure CLI access\n• Set up SSH keys\n• Enable MFA authentication', systemAccess: [
    { name: 'AWS Console', description: 'Amazon Web Services cloud platform access', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'Azure Portal', description: 'Microsoft Azure cloud services access', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'GitHub Enterprise', description: 'Source code repository and version control', pic: 'IT Admin', granted: false, credentials: null }
  ] },
  { id: 35, task: 'Issue Monitor & Peripherals', assignee: 'Harith Rahman', due: '2025-09-24', type: 'Asset', indicator: 'Onboarding', status: 'in_progress', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Issue additional workstation equipment:\n\n• External monitor (24" or larger)\n• Wireless keyboard and mouse\n• USB hub/docking station\n• Webcam for video calls\n• Headset with microphone', assetItems: [
    { name: 'External Monitor', description: 'Dell 27" UltraSharp Monitor for dual-screen setup', pic: 'IT Admin', issued: true, issuedAt: '2025-09-22', serialNumber: 'DELL-U2722D-2025-005678', handoverLetter: null, remarks: 'Monitor delivered to workstation' },
    { name: 'Docking Station', description: 'USB-C docking station with multiple ports', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: 'Pending inventory check' },
    { name: 'Wireless Keyboard & Mouse', description: 'Logitech MX Keys and MX Master 3 combo', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: null }
  ] },
  { id: 36, task: 'Configure Database Access', assignee: 'Nur Iman', due: '2025-10-02', type: 'System/Access', indicator: 'Onboarding', status: 'not-started', assignedTo: 'IT/PIC', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Set up database access permissions:\n\n• Create database user accounts\n• Assign read/write permissions\n• Configure connection strings\n• Set up database client tools\n• Document access credentials securely', systemAccess: [
    { name: 'MySQL Database', description: 'Production and staging database access', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'MongoDB Atlas', description: 'NoSQL database cluster access', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'Redis Cache', description: 'In-memory data store access', pic: 'IT Admin', granted: false, credentials: null }
  ] },
  // TimeTec Computing - IT/PIC Tasks
  { id: 37, task: 'Grant ERP System Access', assignee: 'Siti Aminah', due: '2025-09-21', type: 'System/Access', indicator: 'Onboarding', status: 'completed', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Configure ERP system access:\n\n• Create SAP user account\n• Assign appropriate roles\n• Set up authorization profiles\n• Configure transaction access\n• Provide system training materials', systemAccess: [
    { name: 'SAP ERP', description: 'Enterprise Resource Planning system for finance and operations', pic: 'IT Admin', granted: true, grantedAt: '2025-09-20', credentials: { username: 'SITI.AMINAH', password: 'S@P2025!Init' } },
    { name: 'SAP Business Warehouse', description: 'Business intelligence and reporting system', pic: 'IT Admin', granted: true, grantedAt: '2025-09-20', credentials: { username: 'SITI.AMINAH', password: 'BW@2025!Init' } }
  ] },
  { id: 38, task: 'Issue Desktop Computer', assignee: 'Amir Hamzah', due: '2025-09-27', type: 'Asset', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Issue and configure desktop workstation:\n\n• Prepare desktop PC with required specs\n• Install Windows 11 Pro\n• Install Microsoft Office suite\n• Configure network settings\n• Install department-specific software', assetItems: [
    { name: 'Desktop Computer', description: 'HP ProDesk 400 G7 with Intel i7, 16GB RAM, 512GB SSD', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: 'Unit being prepared in IT staging area' },
    { name: 'Monitor Set', description: 'Dual HP 24" monitors with adjustable stands', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: null }
  ] },
  { id: 39, task: 'Setup Network Printer Access', assignee: 'Siti Aminah', due: '2025-09-22', type: 'System/Access', indicator: 'Onboarding', status: 'completed', assignedTo: 'IT/PIC', stage: 'Next Day-Onboarding', company: 'timetec-computing', description: 'Configure network printer access:\n\n• Install printer drivers\n• Add to department print queue\n• Set default printing preferences\n• Configure print quota if applicable\n• Test print functionality', systemAccess: [
    { name: 'Network Printer - Floor 3', description: 'HP LaserJet Pro MFP for printing, scanning, and copying', pic: 'IT Admin', granted: true, grantedAt: '2025-09-21', credentials: { username: 'PRINTER\\siti.aminah', password: null } },
    { name: 'Print Management Portal', description: 'Web portal for print job management and quota monitoring', pic: 'IT Admin', granted: true, grantedAt: '2025-09-21', credentials: null }
  ] },
  // FingerTec - IT/PIC Tasks
  { id: 40, task: 'Setup Time Attendance Terminal Access', assignee: 'Daniel Lee', due: '2025-09-23', type: 'System/Access', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'fingertech', description: 'Configure time attendance system:\n\n• Enroll fingerprint in FingerTec terminal\n• Register face recognition profile\n• Set up employee ID in TCMSv3\n• Configure shift schedule\n• Test attendance recording', systemAccess: [
    { name: 'TCMSv3 Software', description: 'TimeTec Management System for attendance management', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'FingerTec Terminal', description: 'Biometric terminal enrollment and access', pic: 'IT Admin', granted: false, credentials: null }
  ] },
  { id: 41, task: 'Issue Access Control Card', assignee: 'Daniel Lee', due: '2025-09-22', type: 'Asset', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: '1st Day-Onboarding', company: 'fingertech', description: 'Issue and configure access control card:\n\n• Program RFID card with employee ID\n• Configure door access permissions\n• Set up floor access levels\n• Register card in access control system\n• Test at all required access points', assetItems: [
    { name: 'RFID Access Card', description: 'Proximity card for door access control system', pic: 'Security Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: 'Card pending programming' },
    { name: 'Building Key', description: 'Physical key for designated storage and office areas', pic: 'Facilities', issued: false, serialNumber: null, handoverLetter: null, remarks: null }
  ] },
  { id: 42, task: 'Configure CRM System Access', assignee: 'Sarah Ibrahim', due: '2025-10-08', type: 'System/Access', indicator: 'Onboarding', status: 'not-started', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'fingertech', description: 'Set up CRM system access:\n\n• Create Salesforce/HubSpot account\n• Assign user license and role\n• Configure dashboard and reports\n• Set up email integration\n• Import relevant contact lists', systemAccess: [
    { name: 'Salesforce CRM', description: 'Customer relationship management platform', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'HubSpot Marketing', description: 'Marketing automation and analytics platform', pic: 'Marketing Admin', granted: false, credentials: null }
  ] },
  { id: 43, task: 'Issue Mobile Device', assignee: 'Sarah Ibrahim', due: '2025-10-09', type: 'Asset', indicator: 'Onboarding', status: 'not-started', assignedTo: 'IT/PIC', stage: '1st Day-Onboarding', company: 'fingertech', description: 'Issue and configure company mobile device:\n\n• Prepare smartphone with MDM enrolled\n• Install required business apps\n• Configure email and calendar\n• Set up VPN and security policies\n• Provide device usage guidelines', assetItems: [
    { name: 'Company Smartphone', description: 'iPhone 15 with corporate MDM profile installed', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: 'Device pending procurement approval' },
    { name: 'SIM Card', description: 'Corporate mobile plan SIM card', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: null }
  ] },
  // Additional IT/PIC Tasks - More variety in status and types
  // TimeTec Cloud - Additional IT/PIC Tasks
  { id: 44, task: 'Setup Microsoft 365 Account', assignee: 'Harith Rahman', due: '2025-09-22', type: 'System/Access', indicator: 'Onboarding', status: 'completed', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Create and configure Microsoft 365 account:\n\n• Create user account in Azure AD\n• Assign appropriate licenses (E3/E5)\n• Configure email and Teams access\n• Set up OneDrive storage\n• Enable MFA authentication', systemAccess: [
    { name: 'Microsoft 365', description: 'Office 365 E3 license with full productivity suite', pic: 'IT Admin', granted: true, grantedAt: '2025-09-21', credentials: { email: 'harith.rahman@timetec.com', password: 'M365@Init2025!' } },
    { name: 'Microsoft Teams', description: 'Team collaboration and video conferencing', pic: 'IT Admin', granted: true, grantedAt: '2025-09-21', credentials: null },
    { name: 'SharePoint Online', description: 'Document management and intranet access', pic: 'IT Admin', granted: true, grantedAt: '2025-09-21', credentials: null }
  ] },
  { id: 45, task: 'Configure VPN Client', assignee: 'Jessica Wong', due: '2025-09-30', type: 'System/Access', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Install and configure VPN for secure remote access:\n\n• Install FortiClient VPN software\n• Configure connection profiles\n• Set up certificate-based authentication\n• Test connectivity to internal resources\n• Provide VPN usage documentation', systemAccess: [
    { name: 'FortiClient VPN', description: 'Secure VPN client for remote access to corporate network', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'Remote Desktop Gateway', description: 'Access to internal servers and applications', pic: 'IT Admin', granted: false, credentials: null }
  ] },
  { id: 46, task: 'Issue Wireless Headset', assignee: 'Nur Iman', due: '2025-10-01', type: 'Asset', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: '1st Day-Onboarding', company: 'timetec-cloud', description: 'Issue wireless headset for video calls:\n\n• Prepare Jabra/Poly wireless headset\n• Pair with laptop via Bluetooth/USB\n• Configure audio settings\n• Test with Teams/Zoom\n• Provide user manual', assetItems: [
    { name: 'Wireless Headset', description: 'Jabra Evolve2 75 wireless headset with ANC', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: 'Unit available in inventory' },
    { name: 'USB Dongle', description: 'Jabra Link 380 USB adapter for connectivity', pic: 'IT Admin', issued: false, serialNumber: null, handoverLetter: null, remarks: null }
  ] },
  { id: 47, task: 'Setup Source Code Repository Access', assignee: 'Jessica Wong', due: '2025-09-29', type: 'System/Access', indicator: 'Onboarding', status: 'overdue', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-cloud', description: 'Grant access to source code repositories:\n\n• Create GitLab/GitHub account\n• Add to relevant project repositories\n• Configure SSH keys\n• Set up code review permissions\n• Provide Git workflow documentation', systemAccess: [
    { name: 'GitLab Enterprise', description: 'Source code repository and CI/CD platform', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'Jenkins CI', description: 'Continuous integration and deployment server', pic: 'IT Admin', granted: false, credentials: null },
    { name: 'SonarQube', description: 'Code quality and security analysis platform', pic: 'IT Admin', granted: false, credentials: null }
  ] },
  // TimeTec Computing - Additional IT/PIC Tasks
  { id: 48, task: 'Setup Accounting Software Access', assignee: 'Amir Hamzah', due: '2025-09-28', type: 'System/Access', indicator: 'Onboarding', status: 'in_progress', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'timetec-computing', description: 'Configure access to accounting systems:\n\n• Create user in QuickBooks/Sage\n• Assign role-based permissions\n• Set up report access\n• Configure approval workflows\n• Provide system training', systemAccess: [
    { name: 'QuickBooks Enterprise', description: 'Accounting and financial management software', pic: 'Finance Admin', granted: true, grantedAt: '2025-09-26', credentials: { username: 'amir.hamzah', password: 'QB@2025Init' } },
    { name: 'Sage Payroll', description: 'Payroll processing and tax management', pic: 'HR Admin', granted: false, credentials: null }
  ] },
  { id: 49, task: 'Issue Backup Hard Drive', assignee: 'Siti Aminah', due: '2025-09-23', type: 'Asset', indicator: 'Onboarding', status: 'completed', assignedTo: 'IT/PIC', stage: 'Next Day-Onboarding', company: 'timetec-computing', description: 'Issue encrypted backup drive for data protection:\n\n• Prepare encrypted external SSD\n• Configure automatic backup schedule\n• Set up BitLocker encryption\n• Test backup and restore\n• Document backup procedures', assetItems: [
    { name: 'External SSD', description: 'Samsung T7 1TB encrypted portable SSD', pic: 'IT Admin', issued: true, issuedAt: '2025-09-22', serialNumber: 'SAM-T7-2025-008765', handoverLetter: { fileName: 'SSD_Handover_Siti.pdf', uploadedAt: '2025-09-22', signed: true }, remarks: 'BitLocker enabled with recovery key stored in AD' }
  ] },
  // FingerTec - Additional IT/PIC Tasks
  { id: 50, task: 'Configure Door Access Permissions', assignee: 'Daniel Lee', due: '2025-09-24', type: 'System/Access', indicator: 'Onboarding', status: 'in_progress', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'fingertech', description: 'Set up door access control permissions:\n\n• Register user in i-Neighbour system\n• Configure access zones and schedules\n• Set up visitor management profile\n• Enable mobile credentialing\n• Test access at all entry points', systemAccess: [
    { name: 'i-Neighbour Access Control', description: 'Smart door access management system', pic: 'Security Admin', granted: true, grantedAt: '2025-09-23', credentials: { cardNumber: 'AC-2025-001234', pin: '4521' } },
    { name: 'Visitor Management System', description: 'Guest registration and pre-approval system', pic: 'Reception', granted: false, credentials: null }
  ] },
  { id: 51, task: 'Issue Security Token', assignee: 'Sarah Ibrahim', due: '2025-10-10', type: 'Asset', indicator: 'Onboarding', status: 'not-started', assignedTo: 'IT/PIC', stage: 'Pre-Onboarding', company: 'fingertech', description: 'Issue hardware security token for 2FA:\n\n• Prepare YubiKey security key\n• Register with Azure AD/Okta\n• Configure for critical systems\n• Test authentication flow\n• Provide backup codes', assetItems: [
    { name: 'YubiKey 5 NFC', description: 'Hardware security key for multi-factor authentication', pic: 'IT Security', issued: false, serialNumber: null, handoverLetter: null, remarks: 'Keys ordered, expected delivery in 3 days' }
  ] },
  { id: 52, task: 'Setup Inventory Management System', assignee: 'Daniel Lee', due: '2025-09-25', type: 'System/Access', indicator: 'Onboarding', status: 'pending', assignedTo: 'IT/PIC', stage: '1st Day-Onboarding', company: 'fingertech', description: 'Grant access to inventory tracking system:\n\n• Create user account in Fishbowl\n• Assign warehouse permissions\n• Configure barcode scanner\n• Set up inventory alerts\n• Provide training materials', systemAccess: [
    { name: 'Fishbowl Inventory', description: 'Warehouse and inventory management system', pic: 'Warehouse Admin', granted: false, credentials: null },
    { name: 'Barcode Scanner App', description: 'Mobile app for inventory scanning', pic: 'IT Admin', granted: false, credentials: null }
  ] }
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
  let tasks = allTasks.value.filter(task => selectedCompanies.value.includes(task.company))

  // For Staff users, only show their own tasks
  if (currentUserRole.value === 'Staff (End User)') {
    tasks = tasks.filter(task => task.assignee === currentUserName.value)
  }

  return tasks
})

const filteredAlerts = computed(() => {
  let alerts = allAlerts.value.filter(alert => selectedCompanies.value.includes(alert.company))

  // For Staff users, only show alerts related to them
  if (currentUserRole.value === 'Staff (End User)') {
    alerts = alerts.filter(alert =>
      alert.message.toLowerCase().includes(currentUserName.value.toLowerCase())
    )
  }

  return alerts
})

const stageProgress = computed(() => {
  const calculateStageProgress = (stage) => {
    const stageTasks = filteredTasks.value.filter(task => task.stage === stage)

    // For Staff users, show task-based progress (completed tasks / total tasks)
    if (currentUserRole.value === 'Staff (End User)') {
      if (stageTasks.length === 0) {
        return { completed: 0, total: 0, percentage: 0 }
      }

      const completedTasks = stageTasks.filter(task => task.status === 'completed').length
      return {
        completed: completedTasks,
        total: stageTasks.length,
        percentage: Math.round((completedTasks / stageTasks.length) * 100)
      }
    }

    // For other roles, show employee-based progress
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

// Staff-specific computed properties for KPI cards
const staffCompletedTasks = computed(() => {
  return filteredTasks.value.filter(task => task.status === 'completed')
})

const staffNotStartedTasks = computed(() => {
  return filteredTasks.value.filter(task => task.status === 'not-started')
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

// Computed properties for Tasks tabs
const getTasksAssignedToMe = computed(() => {
  const role = currentUserRole.value

  // Filter tasks based on current user's role
  if (role === 'IT/PIC') {
    // IT/PIC sees System/Access and Asset type tasks assigned to IT/PIC or IT
    return filteredTasks.value.filter(task =>
      task.assignedTo === 'IT/PIC' ||
      task.assignedTo === 'IT' ||
      task.assignedTo === 'IT Admin'
    )
  } else if (role === 'HR Admin' || role === 'HR Coordinator') {
    // HR roles see HR-related tasks
    return filteredTasks.value.filter(task =>
      task.assignedTo === 'HR' ||
      task.assignedTo === 'HR Admin' ||
      task.assignedTo === 'HR Coordinator'
    )
  } else if (role === 'Manager') {
    return filteredTasks.value.filter(task => task.assignedTo === 'Manager')
  } else if (role === 'Staff (End User)') {
    return filteredTasks.value.filter(task => task.assignedTo === 'Staff')
  }

  // Default: show all non-unassigned tasks
  return filteredTasks.value.filter(task => task.assignedTo && task.assignedTo !== 'Unassigned')
})

const getTeamTasks = computed(() => {
  // All tasks assigned to team members (not unassigned)
  return filteredTasks.value.filter(task => task.assignedTo && task.assignedTo !== 'Unassigned')
})

const getUnassignedTasks = computed(() => {
  return filteredTasks.value.filter(task => !task.assignedTo || task.assignedTo === 'Unassigned')
})

// Filtered lists for assign panel search
const filteredDepartments = computed(() => {
  if (!assignSearchQuery.value.trim()) {
    return departments.value
  }
  const query = assignSearchQuery.value.toLowerCase()
  return departments.value.filter(dept =>
    dept.name.toLowerCase().includes(query) ||
    dept.code.toLowerCase().includes(query)
  )
})

const filteredEmployees = computed(() => {
  if (!assignSearchQuery.value.trim()) {
    return employees.value
  }
  const query = assignSearchQuery.value.toLowerCase()
  return employees.value.filter(emp =>
    emp.name.toLowerCase().includes(query) ||
    emp.role.toLowerCase().includes(query)
  )
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

const getStageClass = (stage) => {
  switch (stage) {
    case 'Pre-Onboarding': return 'stage-pre'
    case '1st Day-Onboarding': return 'stage-first'
    case 'Next Day-Onboarding': return 'stage-next'
    default: return ''
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
  // For Staff users, only show tasks assigned to them
  return filteredTasks.value.filter(task =>
    task.stage === stage && task.assignee === currentUserName.value
  )
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
  // Initialize temp objects for IT/PIC actions if needed
  if (task.systemAccess) {
    task.systemAccess.forEach(system => {
      if (!system.tempCredentials) {
        system.tempCredentials = { username: '', password: '', remarks: '' }
      }
    })
  }
  if (task.assetItems) {
    task.assetItems.forEach(asset => {
      if (!asset.tempData) {
        asset.tempData = { serialNumber: '', remarks: '', handoverFile: null }
      }
    })
  }

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

const assignTaskToMe = (task) => {
  task.assignedTo = currentUserName.value
  toast.add({
    severity: 'success',
    summary: 'Task Assigned',
    detail: `Task "${task.task}" has been assigned to you`,
    life: 3000
  })
}

// Assign Panel Functions
const setAssignPanelRef = (el, taskId) => {
  if (el) {
    assignPanelRefs.value[taskId] = el
  }
}

const toggleAssignPanel = (event, task) => {
  currentAssignTask.value = task
  assignSearchQuery.value = '' // Reset search when opening
  const panel = assignPanelRefs.value[task.id]
  if (panel) {
    panel.toggle(event)
  }
}

const closeAssignPanel = (taskId) => {
  const panel = assignPanelRefs.value[taskId]
  if (panel) {
    panel.hide()
  }
  assignSearchQuery.value = ''
}

const filterAssignOptions = () => {
  // Filtering is handled by computed properties
  // This function can be used for additional logic if needed
}

const assignTask = (task, type, assignee) => {
  task.assignedTo = assignee

  let detail = ''
  switch (type) {
    case 'me':
      detail = `Task "${task.task}" has been assigned to you`
      break
    case 'department':
      detail = `Task "${task.task}" has been assigned to ${assignee} department`
      break
    case 'employee':
      detail = `Task "${task.task}" has been assigned to ${assignee}`
      break
  }

  toast.add({
    severity: 'success',
    summary: 'Task Assigned',
    detail,
    life: 3000
  })
}

// Task Drawer Assign Panel Functions
const isTaskUnassigned = (task) => {
  return !task.assignedTo || task.assignedTo === 'Unassigned'
}

const toggleTaskDrawerAssignPanel = (event) => {
  assignSearchQuery.value = ''
  if (taskDrawerAssignPanelRef.value) {
    taskDrawerAssignPanelRef.value.toggle(event)
  }
}

const assignTaskFromDrawer = (type, assignee) => {
  if (selectedTaskForDetails.value) {
    assignTask(selectedTaskForDetails.value, type, assignee)
    if (taskDrawerAssignPanelRef.value) {
      taskDrawerAssignPanelRef.value.hide()
    }
    assignSearchQuery.value = ''
    isTaskDetailsDrawerOpen.value = false
  }
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

// File helper functions
const getFileIcon = (fileType) => {
  const iconMap = {
    'pdf': 'pi-file-pdf',
    'image': 'pi-image',
    'doc': 'pi-file-word',
    'docx': 'pi-file-word',
    'xls': 'pi-file-excel',
    'xlsx': 'pi-file-excel',
    'jpg': 'pi-image',
    'jpeg': 'pi-image',
    'png': 'pi-image',
    'default': 'pi-file'
  }
  return iconMap[fileType] || iconMap['default']
}

const previewFile = (file) => {
  toast.add({
    severity: 'info',
    summary: 'Preview File',
    detail: `Opening preview for ${file.name}`,
    life: 3000
  })
  // In real implementation, this would open a file preview modal
}

const downloadFile = (file) => {
  toast.add({
    severity: 'success',
    summary: 'Download Started',
    detail: `Downloading ${file.name}`,
    life: 3000
  })
  // In real implementation, this would trigger file download
}

// Filled Information helper functions
const getFilledInfoCount = (task) => {
  if (!task.filledInfo || task.filledInfo.length === 0) return 0
  return task.filledInfo.filter(info => info.value).length
}

// System Access helper functions
const getGrantedSystemsCount = (task) => {
  if (!task.systemAccess || task.systemAccess.length === 0) return 0
  return task.systemAccess.filter(system => system.granted).length
}

// Asset helper functions
const getIssuedAssetsCount = (task) => {
  if (!task.assetItems || task.assetItems.length === 0) return 0
  return task.assetItems.filter(asset => asset.issued).length
}

// IT/PIC Action Functions - System Access
const grantSystemAccess = (system, index) => {
  const credentials = system.tempCredentials || {}
  if (!credentials.username) {
    toast.add({
      severity: 'warn',
      summary: 'Missing Information',
      detail: 'Please enter username/email for the access credentials',
      life: 3000
    })
    return
  }

  // Update the system access
  system.granted = true
  system.grantedAt = new Date().toISOString().split('T')[0]
  system.credentials = {
    username: credentials.username,
    email: credentials.username.includes('@') ? credentials.username : null,
    password: credentials.password || 'TempPass123!'
  }

  toast.add({
    severity: 'success',
    summary: 'Access Granted',
    detail: `Access to ${system.name} has been granted successfully`,
    life: 3000
  })
}

const revokeSystemAccess = (system, index) => {
  system.granted = false
  system.grantedAt = null
  system.credentials = null

  toast.add({
    severity: 'info',
    summary: 'Access Revoked',
    detail: `Access to ${system.name} has been revoked`,
    life: 3000
  })
}

// IT/PIC Action Functions - Asset Management
const handleHandoverFileUpload = (event, asset) => {
  const file = event.target.files[0]
  if (file) {
    if (!asset.tempData) {
      asset.tempData = {}
    }
    asset.tempData.handoverFile = file

    toast.add({
      severity: 'info',
      summary: 'File Selected',
      detail: `${file.name} selected for upload`,
      life: 2000
    })
  }
}

const issueAsset = (asset, index) => {
  const tempData = asset.tempData || {}
  if (!tempData.serialNumber) {
    toast.add({
      severity: 'warn',
      summary: 'Missing Information',
      detail: 'Please enter the serial number for the asset',
      life: 3000
    })
    return
  }

  // Update the asset
  asset.issued = true
  asset.issuedAt = new Date().toISOString().split('T')[0]
  asset.serialNumber = tempData.serialNumber
  asset.remarks = tempData.remarks || null

  if (tempData.handoverFile) {
    asset.handoverLetter = {
      fileName: tempData.handoverFile.name,
      uploadedAt: new Date().toISOString().split('T')[0],
      signed: false
    }
  }

  toast.add({
    severity: 'success',
    summary: 'Asset Issued',
    detail: `${asset.name} has been issued successfully`,
    life: 3000
  })
}

const recallAsset = (asset, index) => {
  asset.issued = false
  asset.issuedAt = null
  asset.serialNumber = null
  asset.handoverLetter = null
  asset.remarks = null

  toast.add({
    severity: 'info',
    summary: 'Asset Recalled',
    detail: `${asset.name} has been marked for recall`,
    life: 3000
  })
}

// Questionnaire helper functions
const getAnsweredQuestionsCount = (task) => {
  if (!task.questionnaire || task.questionnaire.length === 0) return 0
  return task.questionnaire.filter(q => q.answer).length
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

/* Staff KPI Cards */
.staff-stat-content {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 0.75rem;
}

.staff-stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.staff-stat-info {
  flex: 1;
}

.staff-stat-value {
  font-size: 1.875rem;
  font-weight: 700;
  color: var(--color-gray-900);
}

.staff-stat-label {
  font-size: 0.875rem;
  color: var(--color-gray-500);
}

.staff-tasks-list {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.staff-task-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem 0.75rem;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.staff-task-item.completed {
  background: #f0fdf4;
  border: 1px solid #bbf7d0;
}

.staff-task-item.completed:hover {
  background: #dcfce7;
}

.staff-task-item.not-started {
  background: #eef2ff;
  border: 1px solid #c7d2fe;
}

.staff-task-item.not-started:hover {
  background: #e0e7ff;
}

.staff-task-item i {
  color: var(--color-gray-400);
  font-size: 0.875rem;
}

.staff-task-content {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.staff-task-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
}

.staff-task-item.completed .staff-task-name {
  color: #166534;
}

.staff-task-item.not-started .staff-task-name {
  color: #4338ca;
}

.staff-task-meta {
  font-size: 11px;
  color: var(--color-gray-500);
}

.staff-task-item.completed .staff-task-meta {
  color: #15803d;
}

.staff-task-item.not-started .staff-task-meta {
  color: #6366f1;
}

.staff-tasks-more {
  font-size: 11px;
  color: var(--color-gray-500);
  text-align: center;
  margin-top: 0.5rem;
}

.no-staff-tasks {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  text-align: center;
  color: var(--color-gray-500);
  font-size: 12px;
}

.no-staff-tasks i {
  font-size: 2rem;
  color: var(--color-gray-400);
  margin-bottom: 0.375rem;
}

.no-staff-tasks.success i {
  color: #16a34a;
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
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

/* Required Item Card - New Design */
.required-item-card {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
  transition: all 0.2s ease;
}

.required-item-card:hover {
  border-color: var(--color-primary-300);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.required-item-card.item-completed {
  border-color: var(--color-success-300);
}

.required-item-card.item-compulsory {
  border-left: 3px solid var(--color-danger-500);
}

.required-item-card.item-compulsory.item-completed {
  border-left-color: var(--color-success-500);
}

.item-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem;
  background: var(--color-bg);
}

.item-badges {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.compulsory-tag {
  font-size: 11px;
}

.item-label {
  flex: 1;
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-700);
}

.required-item-card.item-completed .item-label {
  color: var(--color-gray-500);
}

.item-check-icon {
  color: var(--color-success-600);
  font-size: 16px;
}

/* Uploaded File Section */
.uploaded-file-section {
  padding: 0.75rem;
}

.file-preview {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem 0.75rem;
  background: var(--color-primary-50);
  border: 1px solid var(--color-primary-200);
  border-radius: var(--radius-sm);
}

.file-icon-wrapper {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-primary-100);
  border-radius: var(--radius-sm);
  color: var(--color-primary-600);
  font-size: 18px;
}

.file-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
  min-width: 0;
}

.file-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-800);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-meta {
  font-size: 11px;
  color: var(--color-gray-500);
}

.file-actions {
  display: flex;
  gap: 0.25rem;
}

/* No File Uploaded */
.no-file-section {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 1rem;
  color: var(--color-gray-400);
  font-size: 12px;
  font-style: italic;
}

.no-file-section i {
  font-size: 16px;
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

/* Filled Information Section */
.filled-info-section {
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.filled-info-header {
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

.filled-info-header i {
  color: var(--color-primary-600);
}

.filled-info-header span {
  flex: 1;
}

.filled-info-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filled-info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.625rem 0.75rem;
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-sm);
  transition: all 0.2s ease;
}

.filled-info-item:hover {
  border-color: var(--color-primary-300);
}

.filled-info-item.info-filled {
  border-left: 3px solid var(--color-success-500);
}

.info-field-label {
  font-size: 12px;
  font-weight: 400;
  color: var(--color-gray-500);
}

.info-field-value {
  font-size: 13px;
  font-weight: 600;
  color: var(--color-primary-700);
  text-align: right;
  background: var(--color-primary-50);
  padding: 0.25rem 0.5rem;
  border-radius: var(--radius-sm);
}

.info-field-empty {
  font-size: 12px;
  color: var(--color-gray-400);
  font-style: italic;
}

/* System Access Section */
.system-access-section {
  background: linear-gradient(135deg, #faf5ff 0%, #f3e8ff 100%);
  border: 1px solid #e9d5ff;
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.system-access-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 13px;
  color: #7c3aed;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #e9d5ff;
}

.system-access-header i {
  color: #7c3aed;
}

.system-access-header span {
  flex: 1;
}

.system-access-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.system-access-card {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
  transition: all 0.2s ease;
}

.system-access-card:hover {
  border-color: #c4b5fd;
  box-shadow: 0 2px 8px rgba(124, 58, 237, 0.1);
}

.system-access-card.system-granted {
  border-left: 3px solid var(--color-success-500);
}

.system-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem;
  background: var(--color-gray-50);
  border-bottom: 1px solid var(--color-divider);
}

.system-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.system-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  background: #7c3aed;
  color: white;
  font-size: 11px;
  font-weight: 600;
  border-radius: 50%;
}

.system-name {
  font-size: 13px;
  font-weight: 600;
  color: var(--color-gray-800);
}

.status-tag {
  font-size: 11px;
}

.system-description {
  padding: 0.625rem 0.75rem;
  font-size: 12px;
  color: var(--color-gray-600);
  background: var(--color-gray-50);
  border-bottom: 1px solid var(--color-divider);
}

.system-details {
  padding: 0.75rem;
}

.system-detail-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 12px;
  color: var(--color-gray-600);
  margin-bottom: 0.5rem;
}

.system-detail-item:last-child {
  margin-bottom: 0;
}

.system-detail-item i {
  color: #7c3aed;
  font-size: 12px;
}

.system-credentials {
  margin-top: 0.75rem;
  padding: 0.75rem;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border: 1px solid #bbf7d0;
  border-radius: var(--radius-sm);
}

.credentials-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 12px;
  font-weight: 600;
  color: var(--color-success-700);
  margin-bottom: 0.5rem;
}

.credentials-header i {
  color: var(--color-success-600);
}

.credentials-content {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.credential-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
}

.credential-label {
  color: var(--color-gray-500);
}

.credential-value {
  font-weight: 500;
  color: var(--color-gray-800);
  background: var(--color-bg);
  padding: 0.125rem 0.5rem;
  border-radius: var(--radius-sm);
}

/* IT/PIC Action Sections */
.itpic-action-section {
  margin-top: 0.75rem;
  padding: 0.75rem;
  background: linear-gradient(135deg, #ede9fe 0%, #ddd6fe 100%);
  border: 1px solid #c4b5fd;
  border-radius: var(--radius-sm);
}

.itpic-action-section.orange {
  background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%);
  border: 1px solid #fdba74;
}

.action-section-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 12px;
  font-weight: 600;
  color: #7c3aed;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px dashed #c4b5fd;
}

.itpic-action-section.orange .action-section-header {
  color: #c2410c;
  border-bottom-color: #fdba74;
}

.action-section-header i {
  font-size: 14px;
}

.credentials-form,
.asset-issue-form {
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
}

.form-row {
  display: flex;
  gap: 0.5rem;
}

.form-field {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.form-field label {
  font-size: 11px;
  font-weight: 500;
  color: var(--color-gray-600);
}

.form-field label .required {
  color: var(--color-danger);
}

.form-field :deep(.p-inputtext),
.form-field :deep(.p-textarea) {
  font-size: 12px;
  padding: 0.5rem 0.625rem;
}

.action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.file-upload-area {
  border: 1px dashed var(--color-gray-300);
  border-radius: var(--radius-sm);
  background: var(--color-bg);
  transition: all 0.2s ease;
}

.file-upload-area:hover {
  border-color: var(--color-primary);
  background: var(--color-primary-50);
}

.upload-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  cursor: pointer;
  font-size: 12px;
  color: var(--color-gray-600);
}

.upload-label i {
  color: var(--color-primary);
}

.itpic-revoke-section {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px dashed var(--color-gray-300);
  display: flex;
  justify-content: flex-end;
}

/* Asset Details Section */
.asset-details-section {
  background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%);
  border: 1px solid #fed7aa;
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.asset-details-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 13px;
  color: #c2410c;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #fed7aa;
}

.asset-details-header i {
  color: #ea580c;
}

.asset-details-header span {
  flex: 1;
}

.asset-details-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.asset-item-card {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
  transition: all 0.2s ease;
}

.asset-item-card:hover {
  border-color: #fdba74;
  box-shadow: 0 2px 8px rgba(234, 88, 12, 0.1);
}

.asset-item-card.asset-issued {
  border-left: 3px solid var(--color-success-500);
}

.asset-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.75rem;
  background: var(--color-gray-50);
  border-bottom: 1px solid var(--color-divider);
}

.asset-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.asset-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  background: #ea580c;
  color: white;
  font-size: 11px;
  font-weight: 600;
  border-radius: 50%;
}

.asset-name {
  font-size: 13px;
  font-weight: 600;
  color: var(--color-gray-800);
}

.asset-description {
  padding: 0.625rem 0.75rem;
  font-size: 12px;
  color: var(--color-gray-600);
  background: var(--color-gray-50);
  border-bottom: 1px solid var(--color-divider);
}

.asset-details-content {
  padding: 0.75rem;
}

.asset-detail-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 0.75rem;
}

.asset-detail-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 12px;
  color: var(--color-gray-600);
}

.asset-detail-item i {
  color: #ea580c;
  font-size: 12px;
}

.asset-serial-section {
  margin-bottom: 0.75rem;
  padding: 0.625rem 0.75rem;
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-sm);
}

.serial-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 11px;
  color: var(--color-gray-500);
  margin-bottom: 0.375rem;
}

.serial-header i {
  color: #ea580c;
}

.serial-value {
  font-size: 13px;
  font-weight: 600;
  font-family: monospace;
  color: var(--color-gray-800);
  background: var(--color-bg);
  padding: 0.25rem 0.5rem;
  border-radius: var(--radius-sm);
  display: inline-block;
}

.asset-handover-section {
  margin-bottom: 0.75rem;
  padding: 0.75rem;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border: 1px solid #bbf7d0;
  border-radius: var(--radius-sm);
}

.handover-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 12px;
  font-weight: 600;
  color: var(--color-success-700);
  margin-bottom: 0.5rem;
}

.handover-header i {
  color: var(--color-success-600);
}

.handover-header span {
  flex: 1;
}

.handover-tag {
  font-size: 10px;
}

.handover-file {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem 0.75rem;
  background: var(--color-bg);
  border: 1px solid #bbf7d0;
  border-radius: var(--radius-sm);
}

.file-icon-wrapper.orange {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #ffedd5;
  border-radius: var(--radius-sm);
  color: #ea580c;
  font-size: 16px;
}

.asset-remarks-section {
  padding: 0.625rem 0.75rem;
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: var(--radius-sm);
}

.remarks-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 11px;
  font-weight: 600;
  color: #1d4ed8;
  margin-bottom: 0.375rem;
}

.remarks-header i {
  color: #3b82f6;
}

.remarks-content {
  font-size: 12px;
  color: var(--color-gray-700);
  line-height: 1.5;
}

/* Questionnaire Section */
.questionnaire-section {
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border: 1px solid #cbd5e1;
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.questionnaire-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 13px;
  color: #475569;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #cbd5e1;
}

.questionnaire-header i {
  color: #6366f1;
}

.questionnaire-header span {
  flex: 1;
}

.questionnaire-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.question-card {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
  transition: all 0.2s ease;
}

.question-card:hover {
  border-color: #a5b4fc;
  box-shadow: 0 2px 8px rgba(99, 102, 241, 0.1);
}

.question-card.question-answered {
  border-left: 3px solid var(--color-success-500);
}

.question-card-header {
  padding: 0.75rem;
  background: var(--color-gray-50);
  border-bottom: 1px solid var(--color-divider);
}

.question-info {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
}

.question-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 28px;
  height: 20px;
  background: #6366f1;
  color: white;
  font-size: 11px;
  font-weight: 600;
  border-radius: 4px;
  flex-shrink: 0;
}

.question-text {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-800);
  line-height: 1.4;
}

.question-meta {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid var(--color-divider);
}

.type-tag {
  font-size: 10px;
}

.required-tag {
  font-size: 10px;
}

.question-answer-section {
  padding: 0.75rem;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border-top: 1px solid #bbf7d0;
}

.answer-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 11px;
  font-weight: 600;
  color: var(--color-success-700);
  margin-bottom: 0.5rem;
}

.answer-header i {
  color: var(--color-success-600);
}

.answer-content {
  font-size: 13px;
  color: var(--color-success-900);
  line-height: 1.5;
  background: var(--color-bg);
  padding: 0.5rem 0.75rem;
  border-radius: var(--radius-sm);
  border: 1px solid #bbf7d0;
}

.question-no-answer {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem;
  color: var(--color-gray-400);
  font-size: 12px;
  font-style: italic;
}

.question-no-answer i {
  font-size: 14px;
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

/* Tasks Tabs Styles */
.tasks-tabs {
  margin-top: 0.5rem;
}

.tasks-tabs :deep(.p-tabview-nav) {
  background: var(--color-gray-100);
  border: none;
  gap: 0.25rem;
  padding: 4px;
  border-radius: 8px;
  display: inline-flex;
  width: auto;
}

.tasks-tabs :deep(.p-tabview-nav-container) {
  display: inline-block;
}

.tasks-tabs :deep(.p-tabview-nav-link) {
  background: transparent;
  border: none;
  padding: 0.5rem 1rem;
  font-size: 13px;
  color: var(--color-gray-600);
  border-radius: 6px;
  transition: all 0.2s ease;
}

.tasks-tabs :deep(.p-tabview-nav-link:hover) {
  background: var(--color-gray-200);
  color: var(--color-gray-700);
}

.tasks-tabs :deep(.p-tabview-header.p-highlight .p-tabview-nav-link) {
  background: white;
  color: var(--color-primary-600);
  font-weight: 600;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.tasks-tabs :deep(.p-tabview-panels) {
  background: transparent;
  padding: 1rem 0 0 0;
}

.tasks-tabs :deep(.p-tabview-ink-bar) {
  display: none;
}

/* Tasks Table */
.tasks-table {
  font-size: 13px;
}

.tasks-table :deep(.p-datatable-header) {
  background: transparent;
  border: none;
  padding: 0;
}

.tasks-table :deep(.p-datatable-thead > tr > th) {
  background: var(--color-gray-50);
  border-bottom: 1px solid var(--color-gray-200);
  padding: 0.75rem 1rem;
  font-size: 12px;
  font-weight: 600;
  color: var(--color-gray-600);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.tasks-table :deep(.p-datatable-tbody > tr > td) {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid var(--color-gray-100);
  vertical-align: middle;
}

.tasks-table :deep(.p-datatable-tbody > tr:hover) {
  background: var(--color-gray-50);
}

.task-table-actions {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.due-cell {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  color: var(--color-gray-600);
  font-size: 12px;
  white-space: nowrap;
}

.due-cell i {
  font-size: 12px;
  color: var(--color-gray-400);
}

/* Stage Badge Colors */
.stage-pre,
.stage-first,
.stage-next {
  white-space: nowrap !important;
}

.stage-pre {
  background-color: rgba(147, 51, 234, 0.1) !important;
  color: #9333ea !important;
  border: none !important;
}

.stage-first {
  background-color: rgba(59, 130, 246, 0.1) !important;
  color: #3b82f6 !important;
  border: none !important;
}

.stage-next {
  background-color: rgba(22, 163, 74, 0.1) !important;
  color: #16a34a !important;
  border: none !important;
}

/* Assign Dropdown Button */
.assign-dropdown-btn {
  font-size: 12px;
  padding: 0.375rem 0.75rem;
}

.assign-dropdown-btn :deep(.p-button-icon) {
  font-size: 12px;
}

/* Assign Panel Styles */
.assign-panel {
  min-width: 280px;
  max-width: 320px;
}

.assign-panel :deep(.p-overlaypanel-content) {
  padding: 0;
}

.assign-panel-content {
  display: flex;
  flex-direction: column;
  max-height: 400px;
}

/* Sticky Header: Search + Assign to Me */
.assign-panel-header {
  flex-shrink: 0;
  background: white;
  border-bottom: 1px solid var(--color-gray-200);
}

/* Scrollable Body: Departments + Employees */
.assign-panel-body {
  flex: 1;
  overflow-y: auto;
  max-height: 280px;
}

/* Search Input */
.assign-search {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem;
  border-bottom: 1px solid var(--color-gray-100);
  background: var(--color-gray-50);
}

.assign-search i {
  color: var(--color-gray-400);
  font-size: 14px;
}

.assign-search-input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 13px;
  padding: 0.25rem;
  outline: none;
}

.assign-search-input:focus {
  box-shadow: none;
}

.assign-search-input::placeholder {
  color: var(--color-gray-400);
}

/* Assign Sections */
.assign-section {
  padding: 0.5rem 0;
}

.assign-section:not(:last-child) {
  border-bottom: 1px solid var(--color-gray-100);
}

.assign-section-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  font-size: 11px;
  font-weight: 600;
  color: var(--color-gray-500);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.assign-section-header i {
  font-size: 12px;
}

/* Assign Options */
.assign-options-list {
  /* No individual scroll - single scroll on parent container */
}

.assign-option {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  padding: 0.625rem 0.75rem;
  cursor: pointer;
  transition: background-color 0.15s;
  font-size: 13px;
  color: var(--color-gray-700);
}

.assign-option:hover {
  background: var(--color-gray-100);
}

.assign-option i {
  font-size: 14px;
  color: var(--color-gray-500);
  width: 18px;
  text-align: center;
}

.assign-to-me {
  background: var(--color-primary-50);
  color: var(--color-primary-700);
  font-weight: 500;
}

.assign-to-me:hover {
  background: var(--color-primary-100);
}

.assign-to-me i {
  color: var(--color-primary-600);
}

/* Employee Option Info */
.employee-option-info {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.employee-option-info .employee-name {
  font-weight: 500;
  color: var(--color-gray-800);
}

.employee-option-info .employee-role {
  font-size: 11px;
  color: var(--color-gray-500);
}

/* No Results */
.assign-no-results {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 1.5rem;
  color: var(--color-gray-500);
  font-size: 13px;
}

.assign-no-results i {
  font-size: 16px;
}

/* Utility Classes */
.mt-2 {
  margin-top: 0.5rem;
}

/* Task Table Tags - prevent wrapping */
:deep(.p-datatable .p-tag) {
  white-space: nowrap;
}
</style>
