<template>
  <div class="offboarding-dashboard">
    <!-- Progress by Leaver Page View -->
    <template v-if="showProgressByLeaver">
      <div class="page-header">
        <div class="header-left">
          <Button
            icon="pi pi-arrow-left"
            label="Back to Dashboard"
            severity="secondary"
            outlined
            size="small"
            @click="showProgressByLeaver = false; resetProgressFilters()"
          />
          <div class="header-text">
            <h1 class="page-title">Offboarding Progress</h1>
            <p class="page-subtitle">Comprehensive view of all leavers and their offboarding progress</p>
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
          <DataTable :value="progressFilteredLeavers" stripedRows tableStyle="width: 100%" class="progress-table-fit">
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
              <div class="empty-state">No leavers match the selected filters</div>
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
                @click="resetProgressFilters"
              />
            </div>
            <div class="filter-controls">
              <InputText v-model="progressSearchQuery" placeholder="Search by task name..." class="search-input" />
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

          <!-- Tasks Table -->
          <DataTable :value="progressFilteredTasks" stripedRows tableStyle="width: 100%">
            <Column field="task" header="Task" sortable style="width: 25%">
              <template #body="{ data }">
                <span class="font-medium">{{ data.task }}</span>
              </template>
            </Column>
            <Column field="assignee" header="Employee" sortable style="width: 15%" />
            <Column field="assignedTo" header="Assigned To" sortable style="width: 12%">
              <template #body="{ data }">
                <Tag :value="data.assignedTo" severity="info" />
              </template>
            </Column>
            <Column field="due" header="Due" sortable style="width: 10%">
              <template #body="{ data }">
                <span :class="{ 'text-danger': isOverdue(data.due) }">{{ data.due }}</span>
              </template>
            </Column>
            <Column field="stage" header="Stage" sortable style="width: 14%">
              <template #body="{ data }">
                <Tag :value="data.stage" :severity="getStageSeverity(data.stage)" />
              </template>
            </Column>
            <Column header="Status" style="width: 12%">
              <template #body="{ data }">
                <StatusChip :status="normalizeStatus(data.status)" />
              </template>
            </Column>
            <Column header="Action" style="width: 12%">
              <template #body="{ data }">
                <Button
                  icon="pi pi-eye"
                  label="View"
                  text
                  size="small"
                  @click="openTaskDetailsDrawer(data)"
                />
              </template>
            </Column>
            <template #empty>
              <div class="empty-state">No tasks match the selected filters</div>
            </template>
          </DataTable>
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
            <p class="page-subtitle">View and manage all offboarding tasks assigned to this employee</p>
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
          <span class="summary-label">Last Working Day</span>
          <span class="summary-value">{{ selectedEmployee.lastWorkingDay }}</span>
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
        <div v-for="stage in offboardingStages" :key="stage" class="stage-column">
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
              </div>
            </div>
            <div v-if="getEmployeeTasksByStage(stage).length === 0" class="empty-tasks">
              No tasks in this stage
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
          <h1 class="dashboard-title">Offboarding Dashboard</h1>
          <p class="dashboard-subtitle">Track leaver progress and manage offboarding tasks</p>
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
          <Button icon="pi pi-users" label="Assign Offboarding Workflow" class="offboarding-btn" @click="isAssignDrawerOpen = true" />
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
            <!-- Pre-Offboarding -->
            <div
              class="progress-stage-item"
              :class="{ active: selectedStageFilter === 'Pre-Offboarding' }"
              @click="handleStageClick('Pre-Offboarding')"
            >
              <div class="stage-info">
                <div class="stage-label">
                  <i class="pi pi-clipboard" style="color: #9333ea;"></i>
                  <span>Pre-Offboarding</span>
                  <Tag v-if="selectedStageFilter === 'Pre-Offboarding'" value="Filtered" severity="secondary" class="filter-tag" />
                </div>
                <div class="stage-stats">
                  <span class="stats-text">{{ stageProgress.preOffboarding.completed }} of {{ stageProgress.preOffboarding.total }} {{ currentUserRole === 'Staff (End User)' ? 'tasks' : 'employees' }}</span>
                  <span class="stats-percentage">{{ stageProgress.preOffboarding.percentage }}%</span>
                </div>
              </div>
              <ProgressBar :value="stageProgress.preOffboarding.percentage" :showValue="false" style="height: 8px;" />
            </div>

            <!-- Last Day-Offboarding -->
            <div
              class="progress-stage-item"
              :class="{ active: selectedStageFilter === 'Last Day-Offboarding' }"
              @click="handleStageClick('Last Day-Offboarding')"
            >
              <div class="stage-info">
                <div class="stage-label">
                  <i class="pi pi-calendar" style="color: #3b82f6;"></i>
                  <span>Last Day-Offboarding</span>
                  <Tag v-if="selectedStageFilter === 'Last Day-Offboarding'" value="Filtered" severity="secondary" class="filter-tag" />
                </div>
                <div class="stage-stats">
                  <span class="stats-text">{{ stageProgress.lastDay.completed }} of {{ stageProgress.lastDay.total }} {{ currentUserRole === 'Staff (End User)' ? 'tasks' : 'employees' }}</span>
                  <span class="stats-percentage">{{ stageProgress.lastDay.percentage }}%</span>
                </div>
              </div>
              <ProgressBar :value="stageProgress.lastDay.percentage" :showValue="false" style="height: 8px;" />
            </div>

            <!-- Post-Offboarding -->
            <div
              class="progress-stage-item"
              :class="{ active: selectedStageFilter === 'Post-Offboarding' }"
              @click="handleStageClick('Post-Offboarding')"
            >
              <div class="stage-info">
                <div class="stage-label">
                  <i class="pi pi-check-circle" style="color: #16a34a;"></i>
                  <span>Post-Offboarding</span>
                  <Tag v-if="selectedStageFilter === 'Post-Offboarding'" value="Filtered" severity="secondary" class="filter-tag" />
                </div>
                <div class="stage-stats">
                  <span class="stats-text">{{ stageProgress.postOffboarding.completed }} of {{ stageProgress.postOffboarding.total }} {{ currentUserRole === 'Staff (End User)' ? 'tasks' : 'employees' }}</span>
                  <span class="stats-percentage">{{ stageProgress.postOffboarding.percentage }}%</span>
                </div>
              </div>
              <ProgressBar :value="stageProgress.postOffboarding.percentage" :showValue="false" style="height: 8px;" />
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
                  <span class="overdue-task-meta">Assignee: {{ task.assignee }} - Due: {{ task.due }}</span>
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
                  <span class="staff-task-meta">{{ task.type }} - {{ task.stage }}</span>
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
                  <span class="staff-task-meta">{{ task.type }} - Due: {{ task.due }}</span>
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

      <!-- Offboarding Progress Table -->
      <div class="content-card" v-if="currentUserRole !== 'Staff (End User)'">
        <div class="card-header">
          <div class="card-title-section" @click="showProgressByLeaver = true">
            <h2 class="card-title">Offboarding Progress</h2>
            <i class="pi pi-external-link"></i>
          </div>
          <Button
            v-if="selectedStageFilter"
            icon="pi pi-times"
            :label="`Clear Stage Filter: ${selectedStageFilter}`"
            severity="secondary"
            text
            size="small"
            @click="clearStageFilter"
          />
        </div>
        <DataTable
          :value="filteredLeavers"
          stripedRows
          responsiveLayout="scroll"
          class="progress-table clickable-rows"
          @row-click="(e) => openEmployeeTasksDrawer(e.data)"
        >
          <Column field="name" header="Employee" sortable style="width: 18%">
            <template #body="{ data }">
              <span class="font-medium">{{ data.name }}</span>
            </template>
          </Column>
          <Column field="manager" header="Manager" sortable style="width: 15%" />
          <Column field="lastWorkingDay" header="Last Working Day" sortable style="width: 12%" />
          <Column field="currentStage" header="Stage" sortable style="width: 15%">
            <template #body="{ data }">
              <Tag :value="data.currentStage" :severity="getStageSeverity(data.currentStage)" class="stage-badge" />
            </template>
          </Column>
          <Column header="Progress" style="width: 18%">
            <template #body="{ data }">
              <div class="progress-cell">
                <ProgressBar :value="data.progress" :showValue="false" style="height: 6px; flex: 1;" />
                <span class="progress-percentage">{{ data.progress }}%</span>
              </div>
            </template>
          </Column>
          <Column header="Tasks" style="width: 8%">
            <template #body="{ data }">
              <span class="tasks-count">{{ data.completedTasks }}/{{ data.totalTasks }}</span>
            </template>
          </Column>
          <Column header="Status" style="width: 10%">
            <template #body="{ data }">
              <StatusChip :status="normalizeStatus(data.status)" />
            </template>
          </Column>
          <template #empty>
            <div class="empty-state">No leavers match the selected filters</div>
          </template>
        </DataTable>
      </div>

      <!-- Tasks Section -->
      <div class="content-card">
        <div class="card-header">
          <h2 class="card-title">Tasks</h2>
          <p v-if="currentUserRole === 'Staff (End User)'" class="card-subtitle">Tasks assigned specifically to you</p>
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
                    <span :class="{ 'text-danger': isOverdue(data.due) }">{{ data.due }}</span>
                  </div>
                </template>
              </Column>
              <Column field="type" header="Type" sortable style="width: 12%">
                <template #body="{ data }">
                  <Tag :value="data.type" severity="secondary" />
                </template>
              </Column>
              <Column field="stage" header="Stage" sortable style="width: 13%">
                <template #body="{ data }">
                  <Tag :value="data.stage" :severity="getStageSeverity(data.stage)" class="stage-badge" />
                </template>
              </Column>
              <Column header="Status" style="width: 10%">
                <template #body="{ data }">
                  <StatusChip :status="normalizeStatus(data.status)" />
                </template>
              </Column>
              <Column header="Actions" style="width: 16%">
                <template #body="{ data }">
                  <div class="action-buttons">
                    <Button
                      icon="pi pi-eye"
                      severity="info"
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
                    <span :class="{ 'text-danger': isOverdue(data.due) }">{{ data.due }}</span>
                  </div>
                </template>
              </Column>
              <Column field="stage" header="Stage" sortable style="width: 13%">
                <template #body="{ data }">
                  <Tag :value="data.stage" :severity="getStageSeverity(data.stage)" class="stage-badge" />
                </template>
              </Column>
              <Column header="Status" style="width: 10%">
                <template #body="{ data }">
                  <StatusChip :status="normalizeStatus(data.status)" />
                </template>
              </Column>
              <Column header="Actions" style="width: 12%">
                <template #body="{ data }">
                  <div class="action-buttons">
                    <Button
                      icon="pi pi-eye"
                      severity="info"
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
                <div class="empty-state">No team tasks</div>
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
                    <span :class="{ 'text-danger': isOverdue(data.due) }">{{ data.due }}</span>
                  </div>
                </template>
              </Column>
              <Column field="stage" header="Stage" sortable style="width: 15%">
                <template #body="{ data }">
                  <Tag :value="data.stage" :severity="getStageSeverity(data.stage)" class="stage-badge" />
                </template>
              </Column>
              <Column header="Status" style="width: 12%">
                <template #body="{ data }">
                  <StatusChip :status="normalizeStatus(data.status)" />
                </template>
              </Column>
              <Column header="Actions" style="width: 24%">
                <template #body="{ data }">
                  <div class="action-buttons">
                    <Button
                      icon="pi pi-eye"
                      severity="info"
                      text
                      rounded
                      size="small"
                      title="View Details"
                      @click="openTaskDetailsDrawer(data)"
                    />
                    <Button
                      icon="pi pi-user-plus"
                      label="Assign"
                      size="small"
                      outlined
                      @click="openAssignPanel($event, data)"
                    />
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
        <template v-else>
          <div class="staff-tasks-grid">
            <div v-for="stage in offboardingStages" :key="stage" class="stage-column">
              <div class="stage-header">
                <div class="stage-title">
                  <i :class="getStageIcon(stage)" :style="{ color: getStageColor(stage) }"></i>
                  <span>{{ stage }}</span>
                </div>
                <Tag :value="getMyTasksByStage(stage).length" severity="secondary" />
              </div>
              <div class="stage-tasks">
                <div
                  v-for="task in getMyTasksByStage(stage)"
                  :key="task.id"
                  class="task-item"
                  @click="openTaskDetailsDrawer(task)"
                >
                  <div class="task-item-header">
                    <i :class="getTaskStatusIcon(task.status)" :style="{ color: getTaskStatusColor(task.status) }"></i>
                    <span class="task-name">{{ task.task }}</span>
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
        </template>
      </div>
    </template>

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
            <!-- Hide Employee and Assigned To for Staff users -->
            <div v-if="!isStaffUser" class="info-item">
              <span class="info-label">Employee</span>
              <span class="info-value">{{ selectedTaskForDetails.assignee }}</span>
            </div>
            <div v-if="!isStaffUser" class="info-item">
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

        <!-- Action Buttons -->
        <div class="task-actions-section" v-if="!isStaffUser">
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

    <!-- Employee Tasks Drawer -->
    <Sidebar v-model:visible="isEmployeeTasksDrawerOpen" position="right" style="width: 700px;">
      <template #header>
        <span class="drawer-title">Tasks for {{ selectedEmployee?.name }}</span>
      </template>
      <div class="drawer-content" v-if="selectedEmployee">
        <p class="drawer-subtitle">Viewing all assigned tasks across all offboarding stages</p>

        <!-- Employee Info Card -->
        <div class="employee-info-card">
          <div class="info-row">
            <div class="info-item">
              <span class="info-label">Manager</span>
              <span class="info-value">{{ selectedEmployee.manager }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Last Working Day</span>
              <span class="info-value">{{ selectedEmployee.lastWorkingDay }}</span>
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
        <div v-for="stage in offboardingStages" :key="stage" class="stage-tasks-section">
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
                icon="pi pi-eye"
                severity="secondary"
                text
                rounded
                size="small"
                title="View Details"
                @click="openTaskDetailsDrawer(task); isEmployeeTasksDrawerOpen = false"
              />
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
                icon="pi pi-check-circle"
                severity="success"
                text
                rounded
                size="small"
                title="Mark Complete"
                @click="completeTask(task)"
              />
            </div>
          </div>
          <div v-if="getEmployeeTasksByStage(stage).length === 0" class="empty-stage">
            No tasks in this stage
          </div>
        </div>
      </div>
    </Sidebar>

    <!-- Assign Workflow Drawer -->
    <Sidebar v-model:visible="isAssignDrawerOpen" position="right" style="width: 500px;">
      <template #header>
        <span class="drawer-title">Assign Offboarding Workflow</span>
      </template>
      <div class="drawer-content">
        <p class="drawer-subtitle">Assign an offboarding workflow to a leaver</p>

        <div class="assign-form">
          <div class="form-field">
            <label>Select Leaver</label>
            <Dropdown
              v-model="assignFormData.employeeId"
              :options="leaverOptions"
              optionLabel="label"
              optionValue="value"
              placeholder="Select a leaver"
              class="w-full"
            />
          </div>
          <div class="form-field">
            <label>Last Working Day</label>
            <Calendar v-model="assignFormData.lastWorkingDay" dateFormat="yy-mm-dd" class="w-full" />
          </div>
          <div class="form-field">
            <label>Select Workflow</label>
            <Dropdown
              v-model="assignFormData.workflowId"
              :options="offboardingWorkflows"
              optionLabel="name"
              optionValue="id"
              placeholder="Select a workflow"
              class="w-full"
            />
          </div>
        </div>
      </div>
      <div class="drawer-footer">
        <Button label="Cancel" severity="secondary" outlined @click="isAssignDrawerOpen = false" />
        <Button label="Assign Workflow" @click="handleAssignWorkflow" />
      </div>
    </Sidebar>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useToast } from 'primevue/usetoast'
import { useUserStore } from '../../../stores/userStore'
import StatusChip from '../../../components/ui/StatusChip.vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import Tag from 'primevue/tag'
import ProgressBar from 'primevue/progressbar'
import Sidebar from 'primevue/sidebar'
import TabView from 'primevue/tabview'
import TabPanel from 'primevue/tabpanel'
import Dropdown from 'primevue/dropdown'
import InputText from 'primevue/inputtext'
import Calendar from 'primevue/calendar'
import Checkbox from 'primevue/checkbox'
import Popover from 'primevue/popover'

const toast = useToast()
const userStore = useUserStore()

// Current user role
const currentUserRole = computed(() => userStore.currentRole?.name || 'HR Admin')
const currentUserName = computed(() => userStore.currentUser?.name || 'Ahmed Fauzi')
const isStaffUser = computed(() => currentUserRole.value === 'Staff (End User)')
const isITPICUser = computed(() => currentUserRole.value === 'IT/PIC')

// Companies
const companies = ref([
  { id: 'timetec-cloud', name: 'TimeTec Cloud' },
  { id: 'timetec-computing', name: 'TimeTec Computing' },
  { id: 'fingertech', name: 'FingerTec' }
])
const selectedCompanies = ref(['timetec-cloud', 'timetec-computing', 'fingertech'])

// Offboarding stages
const offboardingStages = ['Pre-Offboarding', 'Last Day-Offboarding', 'Post-Offboarding']

// View states
const showProgressByLeaver = ref(false)
const showEmployeeTasksPage = ref(false)
const selectedEmployee = ref(null)
const progressViewTab = ref(0)
const tasksViewTab = ref(0)
const selectedStageFilter = ref(null)

// Progress filters
const progressSearchQuery = ref('')
const progressStageFilter = ref('all')
const progressStatusFilter = ref('all')

// Drawers
const isTaskDetailsDrawerOpen = ref(false)
const isAssignDrawerOpen = ref(false)
const isAddTaskDrawerOpen = ref(false)
const isEmployeeTasksDrawerOpen = ref(false)
const selectedTaskForDetails = ref(null)

// Popover ref
const companyFilterPopover = ref(null)

// Filter options
const stageFilterOptions = [
  { label: 'All Stages', value: 'all' },
  { label: 'Pre-Offboarding', value: 'Pre-Offboarding' },
  { label: 'Last Day-Offboarding', value: 'Last Day-Offboarding' },
  { label: 'Post-Offboarding', value: 'Post-Offboarding' }
]

const statusFilterOptions = [
  { label: 'All Statuses', value: 'all' },
  { label: 'Completed', value: 'completed' },
  { label: 'In Progress', value: 'in-progress' },
  { label: 'Pending', value: 'pending' },
  { label: 'Not Started', value: 'not-started' }
]

// Assign form data
const assignFormData = ref({
  employeeId: null,
  lastWorkingDay: null,
  workflowId: null
})

// Leavers data
const allLeavers = ref([
  { id: 1, name: 'Zulkifli Hassan', manager: 'Farah Kassim', lastWorkingDay: '2025-09-12', currentStage: 'Pre-Offboarding', completedTasks: 5, totalTasks: 9, progress: 56, status: 'in-progress', company: 'timetec-cloud' },
  { id: 2, name: 'Siti Rahmah', manager: 'Nizam Salleh', lastWorkingDay: '2025-09-20', currentStage: 'Pre-Offboarding', completedTasks: 2, totalTasks: 8, progress: 25, status: 'not-started', company: 'timetec-cloud' },
  { id: 3, name: 'Ahmad Razak', manager: 'Ahmed Fauzi', lastWorkingDay: '2025-10-01', currentStage: 'Last Day-Offboarding', completedTasks: 6, totalTasks: 10, progress: 60, status: 'in-progress', company: 'timetec-computing' },
  { id: 4, name: 'Nurul Aina', manager: 'Farah Kassim', lastWorkingDay: '2025-10-15', currentStage: 'Post-Offboarding', completedTasks: 8, totalTasks: 8, progress: 100, status: 'completed', company: 'fingertech' }
])

// Tasks data
const allTasks = ref([
  { id: 1, task: 'Exit Interview', assignee: 'Zulkifli Hassan', due: '2025-09-10', type: 'Meeting/Event', indicator: 'Offboarding', status: 'completed', assignedTo: 'HR Admin', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Conduct exit interview to gather feedback and understand reasons for leaving.' },
  { id: 2, task: 'Revoke System Access', assignee: 'Zulkifli Hassan', due: '2025-09-12', type: 'System/Access', indicator: 'Offboarding', status: 'in-progress', assignedTo: 'IT/PIC', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Revoke all system access including email, network, and applications.' },
  { id: 3, task: 'Collect Company Assets', assignee: 'Zulkifli Hassan', due: '2025-09-12', type: 'Asset', indicator: 'Offboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Collect all company assets including laptop, phone, access card, and other equipment.' },
  { id: 4, task: 'Final Pay Calculation', assignee: 'Siti Rahmah', due: '2025-09-18', type: 'General', indicator: 'Offboarding', status: 'pending', assignedTo: 'HR Admin', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Calculate final pay including prorated salary, unused leave, and any deductions.' },
  { id: 5, task: 'Knowledge Transfer', assignee: 'Zulkifli Hassan', due: '2025-09-08', type: 'Checklist', indicator: 'Offboarding', status: 'overdue', assignedTo: 'Manager', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Complete knowledge transfer documentation and handover to replacement.' },
  { id: 6, task: 'Benefits Termination', assignee: 'Ahmad Razak', due: '2025-10-01', type: 'General', indicator: 'Offboarding', status: 'in-progress', assignedTo: 'HR Admin', stage: 'Last Day-Offboarding', company: 'timetec-computing', description: 'Process termination of all employee benefits.' },
  { id: 7, task: 'Resignation Letter Filing', assignee: 'Siti Rahmah', due: '2025-09-15', type: 'Document', indicator: 'Offboarding', status: 'completed', assignedTo: 'HR Admin', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'File resignation letter and related documentation.' },
  { id: 8, task: 'Exit Survey', assignee: 'Zulkifli Hassan', due: '2025-09-11', type: 'Questionnaire', indicator: 'Offboarding', status: 'pending', assignedTo: 'Staff', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Complete the exit survey questionnaire.' },
  { id: 9, task: 'Clearance Form', assignee: 'Ahmad Razak', due: '2025-10-01', type: 'Information', indicator: 'Offboarding', status: 'pending', assignedTo: 'Staff', stage: 'Last Day-Offboarding', company: 'timetec-computing', description: 'Complete the clearance form with all required signatures.' },
  { id: 10, task: 'Reference Letter Request', assignee: 'Nurul Aina', due: '2025-10-15', type: 'Document', indicator: 'Offboarding', status: 'completed', assignedTo: 'HR Admin', stage: 'Post-Offboarding', company: 'fingertech', description: 'Process reference letter request.' },
  { id: 11, task: 'Revoke Building Access', assignee: 'Zulkifli Hassan', due: '2025-09-12', type: 'System/Access', indicator: 'Offboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Revoke building access card and parking access.' },
  { id: 12, task: 'Archive Employee Records', assignee: 'Nurul Aina', due: '2025-10-20', type: 'Document', indicator: 'Offboarding', status: 'completed', assignedTo: 'HR Admin', stage: 'Post-Offboarding', company: 'fingertech', description: 'Archive all employee records as per retention policy.' }
])

// Alerts data
const allAlerts = ref([
  { id: 1, message: 'Zulkifli Hassan - Knowledge Transfer overdue by 3 days', type: 'warning', time: '2 hours ago', company: 'timetec-cloud' },
  { id: 2, message: 'Siti Rahmah exit interview scheduled for tomorrow', type: 'info', time: '4 hours ago', company: 'timetec-cloud' },
  { id: 3, message: 'Ahmad Razak last working day approaching', type: 'warning', time: '1 day ago', company: 'timetec-computing' }
])

// Offboarding workflows
const offboardingWorkflows = ref([
  { id: 1, name: 'Standard Offboarding', tasks: 8 },
  { id: 2, name: 'Executive Offboarding', tasks: 12 },
  { id: 3, name: 'Contractor Offboarding', tasks: 5 }
])

// Leaver options for dropdown
const leaverOptions = computed(() => {
  return allLeavers.value.map(l => ({ label: l.name, value: l.id }))
})

// Filtered data
const filteredTasks = computed(() => {
  let tasks = allTasks.value.filter(task => selectedCompanies.value.includes(task.company))

  if (currentUserRole.value === 'Staff (End User)') {
    tasks = tasks.filter(task => task.assignee === currentUserName.value)
  }

  return tasks
})

const filteredLeavers = computed(() => {
  let leavers = allLeavers.value.filter(l => selectedCompanies.value.includes(l.company))

  if (selectedStageFilter.value) {
    leavers = leavers.filter(l => l.currentStage === selectedStageFilter.value)
  }

  return leavers
})

const filteredAlerts = computed(() => {
  let alerts = allAlerts.value.filter(alert => selectedCompanies.value.includes(alert.company))

  if (currentUserRole.value === 'Staff (End User)') {
    alerts = alerts.filter(alert => alert.message.toLowerCase().includes(currentUserName.value.toLowerCase()))
  }

  return alerts
})

// Progress filtered data
const progressFilteredLeavers = computed(() => {
  let leavers = allLeavers.value.filter(l => selectedCompanies.value.includes(l.company))

  if (progressSearchQuery.value) {
    const query = progressSearchQuery.value.toLowerCase()
    leavers = leavers.filter(l =>
      l.name.toLowerCase().includes(query) ||
      l.manager.toLowerCase().includes(query)
    )
  }

  if (progressStageFilter.value !== 'all') {
    leavers = leavers.filter(l => l.currentStage === progressStageFilter.value)
  }

  if (progressStatusFilter.value !== 'all') {
    leavers = leavers.filter(l => normalizeStatus(l.status) === progressStatusFilter.value)
  }

  return leavers
})

const progressFilteredTasks = computed(() => {
  let tasks = filteredTasks.value

  if (progressSearchQuery.value) {
    const query = progressSearchQuery.value.toLowerCase()
    tasks = tasks.filter(t => t.task.toLowerCase().includes(query))
  }

  if (progressStatusFilter.value !== 'all') {
    tasks = tasks.filter(t => normalizeStatus(t.status) === progressStatusFilter.value)
  }

  return tasks
})

// Stage progress
const stageProgress = computed(() => {
  const calculateStageProgress = (stage) => {
    const stageTasks = filteredTasks.value.filter(task => task.stage === stage)

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
    preOffboarding: calculateStageProgress('Pre-Offboarding'),
    lastDay: calculateStageProgress('Last Day-Offboarding'),
    postOffboarding: calculateStageProgress('Post-Offboarding')
  }
})

// Overdue tasks
const overdueTasks = computed(() => {
  const overdue = filteredTasks.value.filter(task => task.status === 'overdue')
  return { total: overdue.length, tasks: overdue }
})

// Staff tasks
const staffCompletedTasks = computed(() => {
  return filteredTasks.value.filter(task => task.status === 'completed')
})

const staffNotStartedTasks = computed(() => {
  return filteredTasks.value.filter(task => task.status === 'not-started')
})

// Task tabs computed
const getTasksAssignedToMe = computed(() => {
  const role = currentUserRole.value
  if (role === 'HR Admin') {
    return filteredTasks.value.filter(task => task.assignedTo === 'HR Admin')
  } else if (role === 'IT/PIC') {
    return filteredTasks.value.filter(task => task.assignedTo === 'IT/PIC')
  } else if (role === 'Manager') {
    return filteredTasks.value.filter(task => task.assignedTo === 'Manager')
  }
  return filteredTasks.value.filter(task => task.assignee === currentUserName.value)
})

const getTeamTasks = computed(() => {
  return filteredTasks.value.filter(task => task.assignedTo !== 'Unassigned')
})

const getUnassignedTasks = computed(() => {
  return filteredTasks.value.filter(task => task.assignedTo === 'Unassigned' || !task.assignedTo)
})

// Helper functions
const getCompanyName = (companyId) => {
  return companies.value.find(c => c.id === companyId)?.name || companyId
}

const normalizeStatus = (status) => {
  if (!status) return 'pending'
  const normalized = status.toLowerCase().replace(/_/g, '-')
  if (normalized === 'in-progress') return 'in-progress'
  return normalized
}

const getStageSeverity = (stage) => {
  switch (stage) {
    case 'Pre-Offboarding': return 'warning'
    case 'Last Day-Offboarding': return 'info'
    case 'Post-Offboarding': return 'success'
    default: return 'secondary'
  }
}

const getStageIcon = (stage) => {
  switch (stage) {
    case 'Pre-Offboarding': return 'pi pi-clipboard'
    case 'Last Day-Offboarding': return 'pi pi-calendar'
    case 'Post-Offboarding': return 'pi pi-check-circle'
    default: return 'pi pi-circle'
  }
}

const getStageColor = (stage) => {
  switch (stage) {
    case 'Pre-Offboarding': return '#9333ea'
    case 'Last Day-Offboarding': return '#3b82f6'
    case 'Post-Offboarding': return '#16a34a'
    default: return '#64748b'
  }
}

const getTaskStatusIcon = (status) => {
  switch (status) {
    case 'completed': return 'pi pi-check-circle'
    case 'in-progress': return 'pi pi-spin pi-spinner'
    case 'pending': return 'pi pi-clock'
    case 'overdue': return 'pi pi-exclamation-triangle'
    default: return 'pi pi-circle'
  }
}

const getTaskStatusColor = (status) => {
  switch (status) {
    case 'completed': return '#16a34a'
    case 'in-progress': return '#3b82f6'
    case 'pending': return '#f59e0b'
    case 'overdue': return '#dc2626'
    default: return '#64748b'
  }
}

const getAlertIcon = (type) => {
  switch (type) {
    case 'warning': return 'pi pi-exclamation-triangle'
    case 'info': return 'pi pi-info-circle'
    case 'error': return 'pi pi-times-circle'
    default: return 'pi pi-bell'
  }
}

const getAlertColor = (type) => {
  switch (type) {
    case 'warning': return '#f59e0b'
    case 'info': return '#3b82f6'
    case 'error': return '#dc2626'
    default: return '#64748b'
  }
}

const isOverdue = (dueDate) => {
  return new Date(dueDate) < new Date()
}

// Computed properties for Employee Tasks Drawer
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

const getEmployeeTasksByStage = (stage) => {
  if (!selectedEmployee.value) return []
  return filteredTasks.value.filter(task =>
    task.assignee === selectedEmployee.value.name && task.stage === stage
  )
}

const getMyTasksByStage = (stage) => {
  return filteredTasks.value.filter(task =>
    task.stage === stage && task.assignee === currentUserName.value
  )
}

// Actions
const toggleCompanyFilter = (event) => {
  companyFilterPopover.value?.toggle(event)
}

const handleStageClick = (stage) => {
  if (selectedStageFilter.value === stage) {
    selectedStageFilter.value = null
  } else {
    selectedStageFilter.value = stage
  }
}

const clearStageFilter = () => {
  selectedStageFilter.value = null
}

const resetProgressFilters = () => {
  progressSearchQuery.value = ''
  progressStageFilter.value = 'all'
  progressStatusFilter.value = 'all'
}

const viewEmployeeTasks = (employee) => {
  selectedEmployee.value = employee
  showEmployeeTasksPage.value = true
  showProgressByLeaver.value = false
}

const openEmployeeTasksDrawer = (employee) => {
  selectedEmployee.value = employee
  isEmployeeTasksDrawerOpen.value = true
}

const openTaskDetailsDrawer = (task) => {
  selectedTaskForDetails.value = task
  isTaskDetailsDrawerOpen.value = true
}

const openAssignPanel = (event, task) => {
  console.log('Assign task:', task)
}

const completeTask = (task) => {
  task.status = 'completed'
  toast.add({
    severity: 'success',
    summary: 'Task Completed',
    detail: `${task.task} has been marked as completed`,
    life: 3000
  })
}

const resetTask = (task) => {
  task.status = 'pending'
  toast.add({
    severity: 'info',
    summary: 'Task Reset',
    detail: `${task.task} has been reset to pending`,
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
      detail: `${task.task} has been deleted`,
      life: 3000
    })
  }
}

const sendReminder = (task) => {
  toast.add({
    severity: 'info',
    summary: 'Reminder Sent',
    detail: `Reminder sent for ${task.task}`,
    life: 3000
  })
}

const handleAssignWorkflow = () => {
  toast.add({
    severity: 'success',
    summary: 'Workflow Assigned',
    detail: 'Offboarding workflow has been assigned successfully',
    life: 3000
  })
  isAssignDrawerOpen.value = false
}
</script>

<style scoped>
.offboarding-dashboard {
  max-width: 1600px;
  margin: 0 auto;
}

/* Header Styles */
.page-header, .dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
  gap: 1rem;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.header-text {
  display: flex;
  flex-direction: column;
}

.page-title, .dashboard-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-gray-900);
  margin: 0;
}

.page-subtitle, .dashboard-subtitle {
  font-size: 0.875rem;
  color: var(--color-gray-500);
  margin: 0.25rem 0 0 0;
}

.header-actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
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
  gap: 0.5rem;
  font-weight: 600;
  font-size: 14px;
  color: var(--color-gray-700);
  margin-bottom: 0.75rem;
}

.kpi-card-content {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

/* Progress Stage Item */
.progress-stage-item {
  padding: 0.625rem;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid transparent;
}

.progress-stage-item:hover {
  background: var(--color-gray-50);
}

.progress-stage-item.active {
  background: var(--color-primary-50);
  border-color: var(--color-primary-200);
}

.stage-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.375rem;
}

.stage-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 13px;
  font-weight: 500;
}

.stage-stats {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.stats-text {
  font-size: 12px;
  color: var(--color-gray-500);
}

.stats-percentage {
  font-size: 13px;
  font-weight: 600;
  color: var(--color-gray-700);
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
  align-items: center;
  justify-content: space-between;
  padding: 0.5rem;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: var(--radius-sm);
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
}

.card-title-section:hover {
  color: var(--color-primary-600);
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  color: var(--color-gray-900);
  margin: 0;
}

.card-subtitle {
  font-size: 12px;
  color: var(--color-gray-500);
  margin: 0.25rem 0 0 0;
}

/* Progress Cell */
.progress-cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.progress-percentage {
  font-size: 12px;
  font-weight: 600;
  color: var(--color-gray-700);
  min-width: 35px;
}

.tasks-count, .tasks-count-cell {
  font-size: 12px;
  font-weight: 500;
  color: var(--color-gray-600);
}

/* Tables */
.progress-table :deep(.p-datatable-tbody > tr > td) {
  padding: 0.625rem 0.75rem;
}

.tasks-table :deep(.p-datatable-tbody > tr > td) {
  padding: 0.5rem 0.75rem;
}

.due-cell {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  white-space: nowrap;
}

.text-danger {
  color: #dc2626 !important;
}

.action-buttons {
  display: flex;
  gap: 0.25rem;
}

.stage-badge {
  white-space: nowrap;
}

/* Tabs */
.tasks-tabs :deep(.p-tabview-nav) {
  background: var(--color-gray-100);
  border-radius: var(--radius-md);
  padding: 0.25rem;
  gap: 0.25rem;
}

.tasks-tabs :deep(.p-tabview-nav-link) {
  border-radius: var(--radius-sm);
  padding: 0.5rem 1rem;
  font-size: 13px;
  font-weight: 500;
}

.tasks-tabs :deep(.p-tabview-nav-link:not(.p-disabled):focus) {
  box-shadow: none;
}

.tasks-tabs :deep(.p-highlight .p-tabview-nav-link) {
  background: var(--color-bg);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}

/* Filter Section */
.filter-section {
  padding: 0.75rem;
  background: var(--color-gray-50);
  border-radius: var(--radius-md);
  margin-bottom: 1rem;
}

.filter-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.filter-label {
  font-size: 12px;
  font-weight: 600;
  color: var(--color-gray-600);
  text-transform: uppercase;
}

.filter-controls {
  display: flex;
  gap: 0.5rem;
}

.search-input {
  flex: 1;
  min-width: 200px;
}

.filter-dropdown {
  min-width: 150px;
}

/* Empty State */
.empty-state {
  padding: 2rem;
  text-align: center;
  color: var(--color-gray-500);
  font-size: 14px;
}

/* Drawer Styles */
.drawer-title-with-icon {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 16px;
  font-weight: 600;
}

.drawer-title {
  font-size: 16px;
  font-weight: 600;
}

.drawer-content {
  padding: 0;
}

.drawer-subtitle {
  font-size: 13px;
  color: var(--color-gray-500);
  margin-bottom: 1rem;
}

.drawer-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  padding: 1rem;
  border-top: 1px solid var(--color-divider);
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

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-label {
  font-size: 11px;
  color: var(--color-gray-500);
  text-transform: uppercase;
}

.info-value {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
}

/* Task Description */
.task-description-section {
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
}

.description-content {
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.75rem;
}

.description-content p {
  font-size: 13px;
  color: var(--color-gray-700);
  line-height: 1.5;
  margin: 0;
}

.no-description {
  font-style: italic;
  color: var(--color-gray-400);
}

/* Task Actions */
.task-actions-section {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.action-buttons-row {
  display: flex;
  gap: 0.5rem;
}

.flex-1 {
  flex: 1;
}

.w-full {
  width: 100%;
}

/* Assign Form */
.assign-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.form-field label {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-700);
}

/* Company Filter */
.company-filter-content {
  padding: 0.5rem;
  min-width: 200px;
}

.filter-title {
  font-size: 13px;
  font-weight: 600;
  color: var(--color-gray-700);
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

/* Employee Summary Card */
.employee-summary-card {
  display: flex;
  gap: 2rem;
  padding: 1rem;
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  margin-bottom: 1rem;
}

.summary-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.summary-label {
  font-size: 11px;
  color: var(--color-gray-500);
  text-transform: uppercase;
}

.summary-value {
  font-size: 14px;
  font-weight: 500;
  color: var(--color-gray-900);
}

/* Tasks Stage Grid */
.tasks-stage-grid, .staff-tasks-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}

.stage-column {
  background: var(--color-gray-50);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  padding: 0.75rem;
}

.stage-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--color-divider);
}

.stage-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 13px;
  font-weight: 600;
}

.stage-tasks {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.task-card, .task-item {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-sm);
  padding: 0.625rem;
  cursor: pointer;
  transition: all 0.2s;
}

.task-card:hover, .task-item:hover {
  border-color: var(--color-primary-300);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.task-card-header, .task-item-header {
  display: flex;
  align-items: flex-start;
  gap: 0.375rem;
  margin-bottom: 0.375rem;
}

.task-title, .task-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-900);
  line-height: 1.3;
}

.task-card-details {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  margin-bottom: 0.375rem;
}

.task-card-meta, .task-item-meta {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.5rem;
  font-size: 11px;
  color: var(--color-gray-500);
}

.task-card-actions, .task-item-actions {
  display: flex;
  gap: 0.25rem;
  margin-top: 0.375rem;
  padding-top: 0.375rem;
  border-top: 1px solid var(--color-divider);
}

.empty-tasks, .empty-stage-tasks {
  padding: 1rem;
  text-align: center;
  color: var(--color-gray-400);
  font-size: 12px;
  font-style: italic;
}

.font-medium {
  font-weight: 500;
}

/* Clickable Rows */
.clickable-rows :deep(.p-datatable-tbody > tr) {
  cursor: pointer;
  transition: background-color 0.2s;
}

.clickable-rows :deep(.p-datatable-tbody > tr:hover) {
  background-color: var(--color-gray-50) !important;
}

/* Employee Tasks Drawer Styles */
.employee-info-card {
  background: var(--color-gray-50);
  border-radius: var(--radius-lg);
  padding: 1rem;
  margin-bottom: 1.5rem;
}

.employee-info-card .info-row {
  display: flex;
  gap: 2rem;
  margin-bottom: 0.75rem;
}

.employee-info-card .info-row:last-child {
  margin-bottom: 0;
}

.employee-info-card .info-item {
  flex: 1;
}

.employee-info-card .info-label {
  display: block;
  font-size: 0.75rem;
  color: var(--color-gray-500);
  margin-bottom: 0.25rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.employee-info-card .info-value {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--color-gray-900);
}

.employee-info-card .tasks-count {
  display: block;
  font-size: 0.75rem;
  color: var(--color-gray-500);
  margin-top: 0.25rem;
}

/* Stage Tasks Section */
.stage-tasks-section {
  margin-bottom: 1.5rem;
}

.stage-section-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--color-divider);
}

.stage-task-count {
  font-size: 0.75rem;
  color: var(--color-gray-500);
}

/* Drawer Task Card */
.drawer-task-card {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.75rem;
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  margin-bottom: 0.5rem;
  transition: box-shadow 0.2s;
}

.drawer-task-card:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.task-card-main {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  flex: 1;
}

.task-card-main > i {
  font-size: 1rem;
  margin-top: 0.125rem;
}

.task-card-content {
  flex: 1;
}

.task-card-title-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.375rem;
}

.task-card-title {
  font-weight: 500;
  color: var(--color-gray-900);
  font-size: 0.875rem;
}

.task-card-meta-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.task-card-meta-row .meta-item {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.75rem;
  color: var(--color-gray-500);
}

.task-card-meta-row .meta-item i {
  font-size: 0.75rem;
}

.task-card-actions {
  display: flex;
  gap: 0.25rem;
  flex-shrink: 0;
}

.empty-stage {
  padding: 1rem;
  text-align: center;
  color: var(--color-gray-400);
  font-size: 0.875rem;
  font-style: italic;
  background: var(--color-gray-50);
  border-radius: var(--radius-md);
}

/* Offboarding Button Style */
.offboarding-btn {
  background-color: #dc2626 !important;
  border-color: #dc2626 !important;
}

.offboarding-btn:hover {
  background-color: #b91c1c !important;
  border-color: #b91c1c !important;
}

.offboarding-btn:focus {
  box-shadow: 0 0 0 2px #ffffff, 0 0 0 4px #fca5a5 !important;
}
</style>
