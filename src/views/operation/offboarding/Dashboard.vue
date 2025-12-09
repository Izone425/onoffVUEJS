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

              <!-- Staff User: File Upload Section -->
              <div v-if="isStaffUser" class="staff-upload-section">
                <!-- Already uploaded file - Staff can view and replace -->
                <div v-if="item.uploadedFile" class="uploaded-file-preview">
                  <div class="file-preview">
                    <div class="file-icon-wrapper uploaded">
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
                        icon="pi pi-trash"
                        severity="danger"
                        text
                        size="small"
                        title="Remove"
                        @click="removeUploadedFile(item, index)"
                      />
                    </div>
                  </div>
                  <div class="replace-file-hint">
                    <i class="pi pi-info-circle"></i>
                    <span>Click below to replace this file</span>
                  </div>
                </div>

                <!-- File Upload Area for Staff -->
                <div class="file-upload-area" :class="{ 'has-file': item.tempFile }">
                  <input
                    type="file"
                    :id="`staff-upload-${index}`"
                    accept=".pdf,.doc,.docx,.jpg,.jpeg,.png"
                    @change="(e) => handleStaffFileUpload(e, item, index)"
                    style="display: none"
                  />
                  <label :for="`staff-upload-${index}`" class="upload-label">
                    <div v-if="!item.tempFile" class="upload-placeholder">
                      <i class="pi pi-cloud-upload"></i>
                      <span class="upload-text">{{ item.uploadedFile ? 'Click to replace file' : 'Click to upload file' }}</span>
                      <span class="upload-hint">PDF, DOC, DOCX, JPG, PNG (Max 10MB)</span>
                    </div>
                    <div v-else class="upload-selected">
                      <i class="pi pi-file"></i>
                      <div class="selected-file-info">
                        <span class="selected-file-name">{{ item.tempFile.name }}</span>
                        <span class="selected-file-size">{{ formatFileSize(item.tempFile.size) }}</span>
                      </div>
                      <i class="pi pi-times remove-temp" @click.prevent="removeTempFile(item, index)"></i>
                    </div>
                  </label>
                </div>

                <!-- Upload Button -->
                <div v-if="item.tempFile" class="upload-actions">
                  <Button
                    label="Upload Document"
                    icon="pi pi-upload"
                    severity="success"
                    size="small"
                    @click="confirmStaffUpload(item, index)"
                  />
                  <Button
                    label="Cancel"
                    icon="pi pi-times"
                    severity="secondary"
                    size="small"
                    outlined
                    @click="removeTempFile(item, index)"
                  />
                </div>
              </div>

              <!-- HR Admin/Other Roles: View Only Section -->
              <div v-else>
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
        </div>

        <!-- Questionnaire Section (for Questionnaire type tasks) -->
        <div v-if="selectedTaskForDetails.questionnaire && selectedTaskForDetails.questionnaire.length > 0" class="questionnaire-section" :class="{ 'staff-mode': isStaffUser }">
          <div class="questionnaire-header">
            <i class="pi pi-question-circle"></i>
            <span>{{ isStaffUser ? 'Complete Questionnaire' : 'Questionnaire Responses' }}</span>
            <Tag
              :value="`${getAnsweredQuestionsCount(selectedTaskForDetails)}/${selectedTaskForDetails.questionnaire.length}`"
              :severity="getAnsweredQuestionsCount(selectedTaskForDetails) === selectedTaskForDetails.questionnaire.length ? 'success' : 'warning'"
            />
          </div>

          <!-- Staff User Editable Form -->
          <div v-if="isStaffUser" class="staff-questionnaire-form">
            <div class="staff-form-instructions">
              <i class="pi pi-info-circle"></i>
              <span>Please answer all required questions marked with <strong>*</strong> before submitting.</span>
            </div>
            <div class="questionnaire-list">
              <div
                v-for="(question, index) in selectedTaskForDetails.questionnaire"
                :key="index"
                class="question-card staff-editable"
                :class="{ 'question-answered': question.answer, 'question-required': question.required && !question.answer }"
              >
                <div class="question-card-header">
                  <div class="question-info">
                    <span class="question-number">Q{{ index + 1 }}</span>
                    <span class="question-text">
                      {{ question.question }}
                      <span v-if="question.required" class="required-asterisk">*</span>
                    </span>
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

                <!-- Staff Input Section -->
                <div class="staff-input-section">
                  <!-- Show input fields ONLY when: no answer exists OR editing mode is active -->
                  <template v-if="!question.answer || question.isEditing">
                    <!-- Picklist (Single) - Dropdown -->
                    <div v-if="question.type === 'Picklist (Single)'" class="input-wrapper">
                      <Dropdown
                        v-model="question.tempAnswer"
                        :options="question.options || getDefaultSingleOptions(question.question)"
                        placeholder="Select an option..."
                        class="staff-dropdown"
                        :class="{ 'has-value': question.tempAnswer }"
                        @change="handleQuestionAnswerChange(question, index)"
                      />
                    </div>

                    <!-- Picklist (Multiple) - Checkbox Group -->
                    <div v-else-if="question.type === 'Picklist (Multiple)'" class="input-wrapper checkbox-group">
                      <div class="checkbox-options">
                        <div
                          v-for="(option, optIdx) in (question.options || getDefaultMultiOptions(question.question))"
                          :key="optIdx"
                          class="checkbox-option"
                        >
                          <Checkbox
                            v-model="question.tempMultiAnswer"
                            :inputId="`q${index}-opt${optIdx}`"
                            :value="option"
                            @change="handleMultiAnswerChange(question, index)"
                          />
                          <label :for="`q${index}-opt${optIdx}`">{{ option }}</label>
                        </div>
                      </div>
                    </div>

                    <!-- Text (Multiple Lines) - Textarea -->
                    <div v-else-if="question.type === 'Text (Multiple Lines)'" class="input-wrapper">
                      <Textarea
                        v-model="question.tempAnswer"
                        placeholder="Type your answer here..."
                        rows="3"
                        class="staff-textarea"
                        :class="{ 'has-value': question.tempAnswer }"
                        @input="handleQuestionAnswerChange(question, index)"
                      />
                    </div>

                    <!-- Cancel Edit Button (when editing existing answer) -->
                    <div v-if="question.isEditing" class="edit-actions">
                      <Button
                        icon="pi pi-times"
                        label="Cancel"
                        text
                        severity="secondary"
                        size="small"
                        @click="cancelEditAnswer(question, index)"
                      />
                      <Button
                        icon="pi pi-check"
                        label="Save Changes"
                        size="small"
                        @click="saveEditedAnswer(question, index)"
                      />
                    </div>
                  </template>

                  <!-- Current Answer Display (if already answered AND not editing) -->
                  <div v-if="question.answer && !question.isEditing" class="current-answer-display">
                    <div class="current-answer-label">
                      <i class="pi pi-check-circle"></i>
                      <span>Your answer:</span>
                    </div>
                    <div class="current-answer-value">{{ question.answer }}</div>
                    <Button
                      icon="pi pi-pencil"
                      label="Edit Answer"
                      text
                      size="small"
                      class="edit-answer-btn"
                      @click="enableEditAnswer(question, index)"
                    />
                  </div>
                </div>
              </div>
            </div>

            <!-- Submit Actions -->
            <div class="staff-questionnaire-actions">
              <div class="action-info">
                <span class="answered-count">{{ getAnsweredQuestionsCount(selectedTaskForDetails) }} of {{ selectedTaskForDetails.questionnaire.length }} answered</span>
                <span v-if="getRequiredUnansweredCount(selectedTaskForDetails) > 0" class="required-warning">
                  <i class="pi pi-exclamation-triangle"></i>
                  {{ getRequiredUnansweredCount(selectedTaskForDetails) }} required question(s) remaining
                </span>
              </div>
              <div class="action-buttons">
                <Button
                  icon="pi pi-save"
                  label="Save Draft"
                  severity="secondary"
                  outlined
                  @click="saveQuestionnaireDraft(selectedTaskForDetails)"
                />
                <Button
                  icon="pi pi-check"
                  label="Submit Questionnaire"
                  :disabled="getRequiredUnansweredCount(selectedTaskForDetails) > 0"
                  @click="submitQuestionnaire(selectedTaskForDetails)"
                />
              </div>
            </div>
          </div>

          <!-- Read-only View for HR Admin / Other Users -->
          <div v-else class="questionnaire-list">
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

        <!-- System Access Section (for System/Access type tasks - Offboarding) -->
        <div v-if="selectedTaskForDetails.systemAccess && selectedTaskForDetails.systemAccess.length > 0" class="system-access-section offboarding">
          <div class="system-access-header">
            <i class="pi pi-lock"></i>
            <span>System Access Revocation</span>
            <Tag
              :value="`${getRevokedSystemsCount(selectedTaskForDetails)}/${selectedTaskForDetails.systemAccess.length}`"
              :severity="getRevokedSystemsCount(selectedTaskForDetails) === selectedTaskForDetails.systemAccess.length ? 'success' : 'warning'"
            />
          </div>
          <div class="system-access-list">
            <div
              v-for="(system, index) in selectedTaskForDetails.systemAccess"
              :key="index"
              class="system-access-card"
              :class="{ 'system-revoked': system.revoked }"
            >
              <div class="system-card-header">
                <div class="system-info">
                  <span class="system-number">#{{ index + 1 }}</span>
                  <span class="system-name">{{ system.name }}</span>
                </div>
                <div class="system-status-badge">
                  <Tag
                    :value="system.revoked ? 'Revoked' : 'Pending'"
                    :severity="system.revoked ? 'success' : 'warning'"
                    class="status-tag"
                  />
                </div>
              </div>
              <div v-if="system.description" class="system-description">
                {{ system.description }}
              </div>

              <!-- Granted Credentials Section - Shows original access granted during onboarding -->
              <div v-if="system.grantedUser" class="granted-credentials-section">
                <div class="credentials-header">
                  <i class="pi pi-key"></i>
                  <span>Access Credentials (Granted)</span>
                </div>
                <div class="credentials-content">
                  <div class="credential-item">
                    <span class="credential-label">User/Email:</span>
                    <span class="credential-value">{{ system.grantedUser }}</span>
                  </div>
                  <div v-if="system.grantedAt" class="credential-item">
                    <span class="credential-label">Granted:</span>
                    <span class="credential-value">{{ system.grantedAt }}</span>
                  </div>
                  <div v-if="system.grantedBy" class="credential-item">
                    <span class="credential-label">Granted by:</span>
                    <span class="credential-value">{{ system.grantedBy }}</span>
                  </div>
                </div>
              </div>

              <div class="system-details">
                <div class="system-detail-item">
                  <i class="pi pi-user"></i>
                  <span>PIC: <strong>{{ system.pic }}</strong></span>
                </div>
                <div v-if="system.revokedAt" class="system-detail-item">
                  <i class="pi pi-calendar"></i>
                  <span>Revoked: {{ system.revokedAt }}</span>
                </div>
                <div v-if="system.revokedBy" class="system-detail-item">
                  <i class="pi pi-user-edit"></i>
                  <span>Revoked by: <strong>{{ system.revokedBy }}</strong></span>
                </div>
              </div>

              <!-- IT/PIC Action Section - Only show for IT/PIC users when not revoked -->
              <div v-if="isITPICUser && !system.revoked" class="itpic-action-section revoke-action">
                <div class="action-section-header">
                  <i class="pi pi-ban"></i>
                  <span>Revoke System Access</span>
                </div>
                <div class="revoke-form">
                  <div class="form-row">
                    <div class="form-field">
                      <label>Revocation Notes (Optional)</label>
                      <Textarea
                        v-model="system.tempRevocationNotes"
                        placeholder="Add any notes about the revocation..."
                        :rows="2"
                        class="w-full"
                      />
                    </div>
                  </div>
                  <div class="action-buttons">
                    <Button
                      label="Confirm Revocation"
                      icon="pi pi-lock"
                      severity="danger"
                      size="small"
                      @click="confirmSystemRevocation(system, index)"
                    />
                  </div>
                </div>
              </div>

              <!-- IT/PIC Undo Action - Show for IT/PIC users when already revoked -->
              <div v-if="isITPICUser && system.revoked" class="itpic-undo-section">
                <Button
                  label="Undo Revocation"
                  icon="pi pi-undo"
                  severity="secondary"
                  size="small"
                  outlined
                  @click="undoSystemRevocation(system, index)"
                />
              </div>

              <!-- Revocation status indicator (only show for non-IT/PIC users) -->
              <div v-if="!isITPICUser && system.revoked" class="revocation-confirmed">
                <i class="pi pi-check-circle"></i>
                <span>Access successfully revoked</span>
              </div>
              <div v-if="!isITPICUser && !system.revoked" class="revocation-pending">
                <i class="pi pi-clock"></i>
                <span>Awaiting revocation</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Asset Collection Section (for Asset type tasks - Offboarding) -->
        <div v-if="selectedTaskForDetails.assetCollection && selectedTaskForDetails.assetCollection.length > 0" class="asset-collection-section">
          <div class="asset-collection-header">
            <i class="pi pi-box"></i>
            <span>Asset Collection</span>
            <Tag
              :value="`${getCollectedAssetsCount(selectedTaskForDetails)}/${selectedTaskForDetails.assetCollection.length}`"
              :severity="getCollectedAssetsCount(selectedTaskForDetails) === selectedTaskForDetails.assetCollection.length ? 'success' : 'warning'"
            />
          </div>
          <div class="asset-collection-list">
            <div
              v-for="(asset, index) in selectedTaskForDetails.assetCollection"
              :key="index"
              class="asset-collection-card"
              :class="{ 'asset-collected': asset.collected, 'asset-compulsory': asset.isCompulsory }"
            >
              <div class="asset-card-header">
                <div class="asset-info">
                  <span class="asset-number">#{{ index + 1 }}</span>
                  <span class="asset-name">{{ asset.name }}</span>
                </div>
                <div class="asset-badges">
                  <Tag
                    :value="asset.isCompulsory ? 'Compulsory' : 'Optional'"
                    :severity="asset.isCompulsory ? 'danger' : 'secondary'"
                    class="compulsory-tag"
                  />
                  <Tag
                    :value="asset.collected ? 'Collected' : 'Pending'"
                    :severity="asset.collected ? 'success' : 'warning'"
                    class="status-tag"
                  />
                </div>
              </div>
              <div v-if="asset.serialNumber" class="asset-serial">
                <i class="pi pi-hashtag"></i>
                <span>Serial: <strong>{{ asset.serialNumber }}</strong></span>
              </div>
              <div v-if="asset.description" class="asset-description">
                {{ asset.description }}
              </div>
              <div class="asset-details">
                <div v-if="asset.collectedAt" class="asset-detail-item">
                  <i class="pi pi-calendar"></i>
                  <span>Collected: {{ asset.collectedAt }}</span>
                </div>
                <div v-if="asset.collectedBy" class="asset-detail-item">
                  <i class="pi pi-user"></i>
                  <span>Collected by: <strong>{{ asset.collectedBy }}</strong></span>
                </div>
                <div v-if="asset.condition" class="asset-detail-item">
                  <i class="pi pi-info-circle"></i>
                  <span>Condition: <strong>{{ asset.condition }}</strong></span>
                </div>
              </div>

              <!-- IT/PIC Action Section - Only show for IT/PIC users when not collected -->
              <div v-if="isITPICUser && !asset.collected" class="itpic-action-section collect-action">
                <div class="action-section-header">
                  <i class="pi pi-box"></i>
                  <span>Collect Asset from Staff</span>
                </div>
                <div class="collect-form">
                  <div class="form-row">
                    <div class="form-field">
                      <label>Asset Condition</label>
                      <Dropdown
                        v-model="asset.tempCondition"
                        :options="assetConditionOptions"
                        optionLabel="label"
                        optionValue="value"
                        placeholder="Select condition"
                        class="w-full"
                      />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-field">
                      <label>Collection Notes (Optional)</label>
                      <Textarea
                        v-model="asset.tempCollectionNotes"
                        placeholder="Add any notes about the asset condition or collection..."
                        :rows="2"
                        class="w-full"
                      />
                    </div>
                  </div>
                  <div class="action-buttons">
                    <Button
                      label="Confirm Collection"
                      icon="pi pi-check"
                      severity="success"
                      size="small"
                      @click="confirmAssetCollection(asset, index)"
                    />
                  </div>
                </div>
              </div>

              <!-- IT/PIC Undo Action - Show for IT/PIC users when already collected -->
              <div v-if="isITPICUser && asset.collected" class="itpic-undo-section">
                <Button
                  label="Undo Collection"
                  icon="pi pi-undo"
                  severity="secondary"
                  size="small"
                  outlined
                  @click="undoAssetCollection(asset, index)"
                />
              </div>

              <!-- Collection status indicator (only show for non-IT/PIC users) -->
              <div v-if="!isITPICUser && asset.collected" class="collection-confirmed">
                <i class="pi pi-check-circle"></i>
                <span>Asset successfully collected</span>
              </div>
              <div v-if="!isITPICUser && !asset.collected" class="collection-pending">
                <i class="pi pi-clock"></i>
                <span>Awaiting collection from staff</span>
              </div>
            </div>
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
import Textarea from 'primevue/textarea'
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
  { id: 4, name: 'Nurul Aina', manager: 'Farah Kassim', lastWorkingDay: '2025-10-15', currentStage: 'Post-Offboarding', completedTasks: 8, totalTasks: 8, progress: 100, status: 'completed', company: 'fingertech' },
  { id: 5, name: 'Aina Zulkifli', manager: 'Ahmed Fauzi', lastWorkingDay: '2025-10-15', currentStage: 'Last Day-Offboarding', completedTasks: 6, totalTasks: 15, progress: 40, status: 'in-progress', company: 'timetec-cloud' }
])

// Tasks data
const allTasks = ref([
  { id: 1, task: 'Exit Interview', assignee: 'Zulkifli Hassan', due: '2025-09-10', type: 'Meeting/Event', indicator: 'Offboarding', status: 'completed', assignedTo: 'HR Admin', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Conduct exit interview to gather feedback and understand reasons for leaving.' },
  { id: 2, task: 'Revoke System Access', assignee: 'Zulkifli Hassan', due: '2025-09-12', type: 'System/Access', indicator: 'Offboarding', status: 'in-progress', assignedTo: 'IT/PIC', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Revoke all system access including email, network, and applications.', systemAccess: [
    { name: 'Corporate Email (Outlook)', description: 'Disable email account and remove from distribution lists', pic: 'IT Admin', grantedUser: 'zulkifli.hassan@timetec.com', grantedAt: '2022-03-15', grantedBy: 'David Kim', revoked: true, revokedAt: '2025-09-11', revokedBy: 'David Kim' },
    { name: 'HRMS Portal', description: 'Revoke access to HR Management System', pic: 'HR Admin', grantedUser: 'zulkifli.hassan', grantedAt: '2022-03-15', grantedBy: 'Sarah Lee', revoked: true, revokedAt: '2025-09-11', revokedBy: 'David Kim' },
    { name: 'SharePoint & OneDrive', description: 'Remove cloud storage access and transfer files to manager', pic: 'IT Admin', grantedUser: 'zulkifli.hassan@timetec.com', grantedAt: '2022-03-16', grantedBy: 'David Kim', revoked: true, revokedAt: '2025-09-12', revokedBy: 'David Kim' },
    { name: 'VPN Access', description: 'Disable remote network access', pic: 'IT Admin', grantedUser: 'zh-vpn-2022', grantedAt: '2022-03-20', grantedBy: 'David Kim', revoked: false },
    { name: 'Jira & Confluence', description: 'Remove from project boards and revoke documentation access', pic: 'IT Admin', grantedUser: 'zulkifli.hassan@timetec.com', grantedAt: '2022-03-18', grantedBy: 'David Kim', revoked: false }
  ] },
  { id: 3, task: 'Collect Company Assets', assignee: 'Zulkifli Hassan', due: '2025-09-12', type: 'Asset', indicator: 'Offboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Collect all company assets including laptop, phone, access card, and other equipment.', assetCollection: [
    { name: 'Laptop (MacBook Pro 14")', serialNumber: 'MBP-2023-ZH-001', description: 'Company issued laptop with charger and accessories', isCompulsory: true, collected: true, collectedAt: '2025-09-11', collectedBy: 'David Kim', condition: 'Good' },
    { name: 'Mobile Phone (iPhone 14)', serialNumber: 'IPH-2023-ZH-002', description: 'Company mobile phone with SIM card', isCompulsory: true, collected: true, collectedAt: '2025-09-11', collectedBy: 'David Kim', condition: 'Good' },
    { name: 'Access Card', serialNumber: 'ACC-ZH-1234', description: 'Building access card and parking card', isCompulsory: true, collected: false },
    { name: 'Company Credit Card', serialNumber: 'CC-CORP-5678', description: 'Corporate credit card for business expenses', isCompulsory: true, collected: false },
    { name: 'External Hard Drive', serialNumber: 'HDD-2022-ZH-003', description: '1TB external hard drive for backup', isCompulsory: false, collected: true, collectedAt: '2025-09-12', collectedBy: 'David Kim', condition: 'Fair' },
    { name: 'Office Keys', serialNumber: 'KEY-ZH-456', description: 'Office cabinet and drawer keys', isCompulsory: false, collected: false }
  ] },
  { id: 4, task: 'Final Pay Calculation', assignee: 'Siti Rahmah', due: '2025-09-18', type: 'General', indicator: 'Offboarding', status: 'pending', assignedTo: 'HR Admin', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Calculate final pay including prorated salary, unused leave, and any deductions.' },
  { id: 5, task: 'Knowledge Transfer', assignee: 'Zulkifli Hassan', due: '2025-09-08', type: 'Checklist', indicator: 'Offboarding', status: 'overdue', assignedTo: 'Manager', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Complete knowledge transfer documentation and handover to replacement.' },
  { id: 6, task: 'Benefits Termination', assignee: 'Ahmad Razak', due: '2025-10-01', type: 'General', indicator: 'Offboarding', status: 'in-progress', assignedTo: 'HR Admin', stage: 'Last Day-Offboarding', company: 'timetec-computing', description: 'Process termination of all employee benefits.' },
  { id: 7, task: 'Resignation Letter Filing', assignee: 'Siti Rahmah', due: '2025-09-15', type: 'Document', indicator: 'Offboarding', status: 'completed', assignedTo: 'HR Admin', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'File resignation letter and related documentation.' },
  { id: 8, task: 'Exit Survey', assignee: 'Zulkifli Hassan', due: '2025-09-11', type: 'Questionnaire', indicator: 'Offboarding', status: 'completed', assignedTo: 'Staff', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Complete the exit survey questionnaire.', questionnaire: [
    { question: 'What is your primary reason for leaving?', type: 'Picklist (Single)', required: true, answer: 'Career advancement' },
    { question: 'How would you rate your overall experience working here?', type: 'Picklist (Single)', required: true, answer: 'Good' },
    { question: 'Which aspects of your job did you enjoy the most?', type: 'Picklist (Multiple)', required: false, answer: 'Team collaboration, Learning opportunities, Work environment' },
    { question: 'Would you recommend this company as a good place to work?', type: 'Picklist (Single)', required: true, answer: 'Probably yes' },
    { question: 'What suggestions do you have for improving the workplace?', type: 'Text (Multiple Lines)', required: false, answer: 'I think the company could benefit from more flexible work arrangements and better career development programs. Overall, it has been a great experience working here and I appreciate all the support from my team.' }
  ] },
  { id: 13, task: 'Resignation Letter', assignee: 'Zulkifli Hassan', due: '2025-09-05', type: 'Document', indicator: 'Offboarding', status: 'completed', assignedTo: 'Staff', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Submit resignation letter as compulsory document for offboarding process.', requiredItems: [{ name: 'Resignation Letter', isCompulsory: true, completed: true, uploadedFile: { name: 'Resignation_Letter_Zulkifli_Hassan.pdf', type: 'pdf', size: '245 KB', uploadedAt: '2025-09-03' } }] },
  { id: 9, task: 'Clearance Form', assignee: 'Ahmad Razak', due: '2025-10-01', type: 'Information', indicator: 'Offboarding', status: 'pending', assignedTo: 'Staff', stage: 'Last Day-Offboarding', company: 'timetec-computing', description: 'Complete the clearance form with all required signatures.' },
  { id: 10, task: 'Reference Letter Request', assignee: 'Nurul Aina', due: '2025-10-15', type: 'Document', indicator: 'Offboarding', status: 'completed', assignedTo: 'HR Admin', stage: 'Post-Offboarding', company: 'fingertech', description: 'Process reference letter request.' },
  { id: 11, task: 'Revoke Building Access', assignee: 'Zulkifli Hassan', due: '2025-09-12', type: 'System/Access', indicator: 'Offboarding', status: 'pending', assignedTo: 'IT/PIC', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Revoke building access card and parking access.' },
  { id: 12, task: 'Archive Employee Records', assignee: 'Nurul Aina', due: '2025-10-20', type: 'Document', indicator: 'Offboarding', status: 'completed', assignedTo: 'HR Admin', stage: 'Post-Offboarding', company: 'fingertech', description: 'Archive all employee records as per retention policy.' },

  // ============ AINA ZULKIFLI (STAFF) OFFBOARDING TASKS ============
  // Pre-Offboarding Stage Tasks
  { id: 100, task: 'Submit Resignation Letter', assignee: 'Aina Zulkifli', due: '2025-10-01', type: 'Document', indicator: 'Offboarding', status: 'completed', assignedTo: 'Staff', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Submit your official resignation letter to HR department.', requiredItems: [
    { name: 'Resignation Letter', isCompulsory: true, completed: true, uploadedFile: { name: 'Resignation_Letter_Aina_Zulkifli.pdf', type: 'pdf', size: '189 KB', uploadedAt: '2025-09-28' } }
  ] },
  { id: 101, task: 'Complete Exit Survey', assignee: 'Aina Zulkifli', due: '2025-10-05', type: 'Questionnaire', indicator: 'Offboarding', status: 'completed', assignedTo: 'Staff', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Complete the exit survey to provide feedback on your employment experience.', questionnaire: [
    { question: 'What is your primary reason for leaving?', type: 'Picklist (Single)', required: true, answer: 'Better career opportunity', options: ['Better career opportunity', 'Higher salary/compensation', 'Relocation', 'Personal/family reasons', 'Health reasons', 'Further education', 'Work-life balance', 'Management issues', 'Company culture', 'Other'] },
    { question: 'How would you rate your overall experience working here?', type: 'Picklist (Single)', required: true, answer: 'Excellent', options: ['Excellent', 'Very Good', 'Good', 'Average', 'Poor'] },
    { question: 'Which aspects of your job did you enjoy the most?', type: 'Picklist (Multiple)', required: false, answer: 'Work environment, Team collaboration, Management support', options: ['Work environment', 'Team collaboration', 'Management support', 'Learning opportunities', 'Career growth', 'Compensation & benefits', 'Work-life balance', 'Company culture', 'Job responsibilities'] },
    { question: 'Would you recommend this company as a good place to work?', type: 'Picklist (Single)', required: true, answer: 'Definitely yes', options: ['Definitely yes', 'Probably yes', 'Not sure', 'Probably not', 'Definitely not'] },
    { question: 'What suggestions do you have for improving the workplace?', type: 'Text (Multiple Lines)', required: false, answer: 'The company has been a great place to work. I would suggest more focus on employee wellness programs and flexible working arrangements.' }
  ] },
  { id: 102, task: 'Knowledge Transfer Documentation', assignee: 'Aina Zulkifli', due: '2025-10-08', type: 'Document', indicator: 'Offboarding', status: 'in-progress', assignedTo: 'Staff', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Prepare and submit knowledge transfer documentation for your role and responsibilities.', requiredItems: [
    { name: 'Project Handover Document', isCompulsory: true, completed: true, uploadedFile: { name: 'Project_Handover_AZ.docx', type: 'doc', size: '1.2 MB', uploadedAt: '2025-10-02' } },
    { name: 'Process Documentation', isCompulsory: true, completed: false },
    { name: 'Contact List & Stakeholders', isCompulsory: false, completed: true, uploadedFile: { name: 'Stakeholder_Contacts.xlsx', type: 'xlsx', size: '45 KB', uploadedAt: '2025-10-03' } }
  ] },
  { id: 103, task: 'Update Personal Information', assignee: 'Aina Zulkifli', due: '2025-10-03', type: 'Information', indicator: 'Offboarding', status: 'completed', assignedTo: 'Staff', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Update your personal contact information for post-employment communication.', filledInfo: [
    { label: 'Personal Email', value: 'aina.zulkifli@gmail.com', required: true },
    { label: 'Personal Phone Number', value: '+60 12-345 6789', required: true },
    { label: 'Forwarding Address', value: '123 Jalan Harmoni, Taman Bahagia, 47301 Petaling Jaya, Selangor', required: true },
    { label: 'Emergency Contact', value: 'Ahmad Zulkifli (Father) - +60 13-987 6543', required: false }
  ] },
  { id: 104, task: 'Acknowledge Company Policy on Confidentiality', assignee: 'Aina Zulkifli', due: '2025-10-02', type: 'Document', indicator: 'Offboarding', status: 'completed', assignedTo: 'Staff', stage: 'Pre-Offboarding', company: 'timetec-cloud', description: 'Review and acknowledge the company confidentiality and non-disclosure agreement upon exit.', requiredItems: [
    { name: 'Signed Confidentiality Acknowledgment', isCompulsory: true, completed: true, uploadedFile: { name: 'Confidentiality_Ack_Signed.pdf', type: 'pdf', size: '156 KB', uploadedAt: '2025-10-01' } }
  ] },

  // Last Day-Offboarding Stage Tasks
  { id: 105, task: 'Return Company Assets', assignee: 'Aina Zulkifli', due: '2025-10-15', type: 'Checklist', indicator: 'Offboarding', status: 'pending', assignedTo: 'Staff', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Return all company-issued assets to IT department on your last working day.', checklistItems: [
    { name: 'Laptop & Charger', completed: false, notes: 'MacBook Pro 14" with power adapter' },
    { name: 'Mobile Phone', completed: false, notes: 'iPhone 13 with SIM card' },
    { name: 'Access Card', completed: false, notes: 'Building and parking access card' },
    { name: 'Office Keys', completed: false, notes: 'Cabinet and drawer keys' },
    { name: 'Company Credit Card', completed: false, notes: 'Corporate card (if applicable)' }
  ] },
  { id: 106, task: 'Complete Clearance Form', assignee: 'Aina Zulkifli', due: '2025-10-15', type: 'Information', indicator: 'Offboarding', status: 'pending', assignedTo: 'Staff', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Complete the departmental clearance form with all required signatures.', filledInfo: [
    { label: 'Department Head Clearance', value: '', required: true },
    { label: 'IT Department Clearance', value: '', required: true },
    { label: 'Finance Department Clearance', value: '', required: true },
    { label: 'HR Department Clearance', value: '', required: true },
    { label: 'Library/Resource Center Clearance', value: '', required: false }
  ] },
  { id: 107, task: 'Backup Personal Files', assignee: 'Aina Zulkifli', due: '2025-10-14', type: 'General', indicator: 'Offboarding', status: 'in-progress', assignedTo: 'Staff', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Backup any personal files from company devices before returning them. Ensure no company confidential data is copied.' },
  { id: 108, task: 'Final Timesheet Submission', assignee: 'Aina Zulkifli', due: '2025-10-15', type: 'Document', indicator: 'Offboarding', status: 'not-started', assignedTo: 'Staff', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Submit your final timesheet including all worked hours up to your last day.', requiredItems: [
    { name: 'Final Timesheet', isCompulsory: true, completed: false }
  ] },
  { id: 109, task: 'Update Out-of-Office & Email Forwarding', assignee: 'Aina Zulkifli', due: '2025-10-15', type: 'General', indicator: 'Offboarding', status: 'not-started', assignedTo: 'Staff', stage: 'Last Day-Offboarding', company: 'timetec-cloud', description: 'Set up out-of-office reply and configure email forwarding to your replacement or manager.' },

  // Post-Offboarding Stage Tasks
  { id: 110, task: 'Collect Final Payslip', assignee: 'Aina Zulkifli', due: '2025-10-25', type: 'Document', indicator: 'Offboarding', status: 'pending', assignedTo: 'Staff', stage: 'Post-Offboarding', company: 'timetec-cloud', description: 'Collect your final payslip and payment confirmation from HR department.', requiredItems: [
    { name: 'Final Payslip Acknowledgment', isCompulsory: true, completed: false }
  ] },
  { id: 111, task: 'Collect Employment Certificate', assignee: 'Aina Zulkifli', due: '2025-10-30', type: 'Document', indicator: 'Offboarding', status: 'pending', assignedTo: 'Staff', stage: 'Post-Offboarding', company: 'timetec-cloud', description: 'Collect your employment certificate and reference letter from HR department.' },
  { id: 112, task: 'Exit Interview Feedback Review', assignee: 'Aina Zulkifli', due: '2025-10-20', type: 'Meeting/Event', indicator: 'Offboarding', status: 'not-started', assignedTo: 'Staff', stage: 'Post-Offboarding', company: 'timetec-cloud', description: 'Optional meeting to review and discuss your exit interview feedback with HR.' },
  { id: 115, task: 'Offboarding Feedback Survey', assignee: 'Aina Zulkifli', due: '2025-10-18', type: 'Questionnaire', indicator: 'Offboarding', status: 'in-progress', assignedTo: 'Staff', stage: 'Post-Offboarding', company: 'timetec-cloud', description: 'Complete this feedback survey about your offboarding experience to help us improve our processes.', questionnaire: [
    { question: 'How would you rate the overall offboarding process?', type: 'Picklist (Single)', required: true, answer: '', options: ['Excellent', 'Good', 'Average', 'Poor', 'Very Poor'] },
    { question: 'Was the offboarding timeline communicated clearly?', type: 'Picklist (Single)', required: true, answer: '', options: ['Yes, very clear', 'Somewhat clear', 'Not very clear', 'Not communicated at all'] },
    { question: 'Which departments handled your offboarding well?', type: 'Picklist (Multiple)', required: false, answer: '', options: ['HR Department', 'IT Department', 'Finance Department', 'Direct Manager', 'Admin Team'] },
    { question: 'What challenges did you face during the offboarding process?', type: 'Text (Multiple Lines)', required: false, answer: '' },
    { question: 'Would you recommend this company to others as a good place to work?', type: 'Picklist (Single)', required: true, answer: '', options: ['Definitely yes', 'Probably yes', 'Not sure', 'Probably not', 'Definitely not'] },
    { question: 'Any additional suggestions to improve the offboarding experience?', type: 'Text (Multiple Lines)', required: false, answer: '' }
  ] },
  { id: 113, task: 'SOCSO & EPF Transfer Confirmation', assignee: 'Aina Zulkifli', due: '2025-11-15', type: 'Information', indicator: 'Offboarding', status: 'pending', assignedTo: 'Staff', stage: 'Post-Offboarding', company: 'timetec-cloud', description: 'Confirm the transfer of your SOCSO and EPF contributions to your new employer or personal account.', filledInfo: [
    { label: 'New Employer Name (if applicable)', value: '', required: false },
    { label: 'EPF Account Number', value: '', required: true },
    { label: 'SOCSO Reference Number', value: '', required: true },
    { label: 'Preferred Transfer Method', value: '', required: true }
  ] },
  { id: 114, task: 'Alumni Network Registration', assignee: 'Aina Zulkifli', due: '2025-11-01', type: 'Information', indicator: 'Offboarding', status: 'not-started', assignedTo: 'Staff', stage: 'Post-Offboarding', company: 'timetec-cloud', description: 'Optional registration for company alumni network to stay connected with former colleagues.', filledInfo: [
    { label: 'Personal LinkedIn Profile', value: '', required: false },
    { label: 'Preferred Contact Email', value: '', required: false },
    { label: 'Consent to Alumni Communications', value: '', required: true }
  ] }
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

// Get completed items count for document tasks
const getCompletedItemsCount = (task) => {
  if (!task.requiredItems) return 0
  return task.requiredItems.filter(item => item.completed).length
}

// Get file icon based on type
const getFileIcon = (type) => {
  switch (type) {
    case 'pdf': return 'pi-file-pdf'
    case 'image': return 'pi-image'
    case 'doc':
    case 'docx': return 'pi-file-word'
    case 'xls':
    case 'xlsx': return 'pi-file-excel'
    default: return 'pi-file'
  }
}

// Preview file
const previewFile = (file) => {
  toast.add({
    severity: 'info',
    summary: 'Opening Preview',
    detail: `Opening ${file.name} in preview mode`,
    life: 3000
  })
  // In a real application, this would open a preview modal
}

// Download file
const downloadFile = (file) => {
  toast.add({
    severity: 'success',
    summary: 'Download Started',
    detail: `Downloading ${file.name}`,
    life: 3000
  })
  // In a real application, this would trigger the file download
}

// Format file size for display
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

// Staff Document Upload Functions
const handleStaffFileUpload = (event, item, index) => {
  const file = event.target.files[0]
  if (file) {
    // Validate file size (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      toast.add({
        severity: 'error',
        summary: 'File Too Large',
        detail: 'Please select a file smaller than 10MB',
        life: 3000
      })
      return
    }

    // Store temp file in the item
    item.tempFile = file

    toast.add({
      severity: 'info',
      summary: 'File Selected',
      detail: `${file.name} ready to upload`,
      life: 2000
    })
  }
}

const removeTempFile = (item, index) => {
  item.tempFile = null
  // Reset the file input
  const input = document.getElementById(`staff-upload-${index}`)
  if (input) input.value = ''
}

const removeUploadedFile = (item, index) => {
  item.uploadedFile = null
  item.completed = false

  toast.add({
    severity: 'info',
    summary: 'File Removed',
    detail: 'The uploaded file has been removed',
    life: 3000
  })
}

const confirmStaffUpload = (item, index) => {
  if (!item.tempFile) return

  // Simulate file upload
  const file = item.tempFile
  const fileExtension = file.name.split('.').pop().toLowerCase()

  // Set uploaded file data
  item.uploadedFile = {
    name: file.name,
    type: fileExtension,
    size: formatFileSize(file.size),
    uploadedAt: new Date().toISOString().split('T')[0]
  }

  // Mark as completed
  item.completed = true

  // Clear temp file
  item.tempFile = null

  // Reset the file input
  const input = document.getElementById(`staff-upload-${index}`)
  if (input) input.value = ''

  toast.add({
    severity: 'success',
    summary: 'Upload Successful',
    detail: `${file.name} has been uploaded successfully`,
    life: 3000
  })
}

// Get answered questions count for questionnaire tasks
const getAnsweredQuestionsCount = (task) => {
  if (!task.questionnaire || task.questionnaire.length === 0) return 0
  return task.questionnaire.filter(q => q.answer).length
}

// Get count of required questions that are not yet answered
const getRequiredUnansweredCount = (task) => {
  if (!task.questionnaire || task.questionnaire.length === 0) return 0
  return task.questionnaire.filter(q => q.required && !q.answer).length
}

// Get default options for single-choice questions based on question context
const getDefaultSingleOptions = (questionText) => {
  const lowerQuestion = questionText.toLowerCase()

  // Rating questions
  if (lowerQuestion.includes('rate') || lowerQuestion.includes('rating')) {
    return ['Excellent', 'Very Good', 'Good', 'Average', 'Poor']
  }
  // Yes/No or recommendation questions
  if (lowerQuestion.includes('recommend') || lowerQuestion.includes('would you')) {
    return ['Definitely yes', 'Probably yes', 'Not sure', 'Probably not', 'Definitely not']
  }
  // Satisfaction questions
  if (lowerQuestion.includes('satisfied') || lowerQuestion.includes('satisfaction')) {
    return ['Very Satisfied', 'Satisfied', 'Neutral', 'Dissatisfied', 'Very Dissatisfied']
  }
  // Agreement questions
  if (lowerQuestion.includes('agree')) {
    return ['Strongly Agree', 'Agree', 'Neutral', 'Disagree', 'Strongly Disagree']
  }
  // Reason for leaving
  if (lowerQuestion.includes('reason') && lowerQuestion.includes('leaving')) {
    return ['Better career opportunity', 'Higher salary/compensation', 'Relocation', 'Personal/family reasons', 'Work-life balance', 'Management issues', 'Other']
  }
  // Communication clarity
  if (lowerQuestion.includes('clear') || lowerQuestion.includes('communicated')) {
    return ['Yes, very clear', 'Somewhat clear', 'Not very clear', 'Not communicated at all']
  }
  // Default fallback
  return ['Excellent', 'Good', 'Average', 'Poor', 'Very Poor']
}

// Get default options for multiple-choice questions based on question context
const getDefaultMultiOptions = (questionText) => {
  const lowerQuestion = questionText.toLowerCase()

  // Aspects/features enjoyed
  if (lowerQuestion.includes('aspects') || lowerQuestion.includes('enjoy')) {
    return ['Work environment', 'Team collaboration', 'Management support', 'Learning opportunities', 'Career growth', 'Compensation & benefits', 'Work-life balance', 'Company culture']
  }
  // Department handling
  if (lowerQuestion.includes('department')) {
    return ['HR Department', 'IT Department', 'Finance Department', 'Direct Manager', 'Admin Team', 'Facilities']
  }
  // Improvement areas
  if (lowerQuestion.includes('improve') || lowerQuestion.includes('better')) {
    return ['Communication', 'Training & Development', 'Work-life balance', 'Compensation', 'Management', 'Team collaboration', 'Tools & Resources']
  }
  // Default fallback
  return ['Option A', 'Option B', 'Option C', 'Option D', 'Option E']
}

// Handle single/text answer change
const handleQuestionAnswerChange = (question, index) => {
  // tempAnswer is already updated via v-model, no additional action needed here
  // This can be used for real-time validation or auto-save in the future
}

// Handle multiple choice answer change
const handleMultiAnswerChange = (question, index) => {
  // Initialize tempMultiAnswer if not exists
  if (!question.tempMultiAnswer) {
    question.tempMultiAnswer = []
  }
}

// Enable editing of an already answered question
const enableEditAnswer = (question, index) => {
  question.isEditing = true
  // Pre-populate tempAnswer with current answer
  if (question.type === 'Picklist (Multiple)') {
    question.tempMultiAnswer = question.answer ? question.answer.split(', ') : []
  } else {
    question.tempAnswer = question.answer || ''
  }
}

// Cancel editing and revert to original answer
const cancelEditAnswer = (question, index) => {
  question.isEditing = false
  question.tempAnswer = null
  question.tempMultiAnswer = null
}

// Save edited answer
const saveEditedAnswer = (question, index) => {
  if (question.type === 'Picklist (Multiple)') {
    if (question.tempMultiAnswer && question.tempMultiAnswer.length > 0) {
      question.answer = question.tempMultiAnswer.join(', ')
    }
  } else {
    if (question.tempAnswer) {
      question.answer = question.tempAnswer
    }
  }
  question.isEditing = false
  question.tempAnswer = null
  question.tempMultiAnswer = null

  toast.add({
    severity: 'success',
    summary: 'Answer Updated',
    detail: 'Your answer has been saved successfully.',
    life: 2000
  })
}

// Save questionnaire draft (save answers without completing the task)
const saveQuestionnaireDraft = (task) => {
  let savedCount = 0

  task.questionnaire.forEach((question) => {
    if (question.type === 'Picklist (Multiple)') {
      if (question.tempMultiAnswer && question.tempMultiAnswer.length > 0) {
        question.answer = question.tempMultiAnswer.join(', ')
        savedCount++
      }
    } else {
      if (question.tempAnswer) {
        question.answer = question.tempAnswer
        savedCount++
      }
    }
    question.isEditing = false
  })

  toast.add({
    severity: 'info',
    summary: 'Draft Saved',
    detail: `${savedCount} answer(s) saved as draft. You can continue later.`,
    life: 3000
  })
}

// Submit questionnaire (mark task as completed)
const submitQuestionnaire = (task) => {
  // First save all answers
  task.questionnaire.forEach((question) => {
    if (question.type === 'Picklist (Multiple)') {
      if (question.tempMultiAnswer && question.tempMultiAnswer.length > 0) {
        question.answer = question.tempMultiAnswer.join(', ')
      }
    } else {
      if (question.tempAnswer) {
        question.answer = question.tempAnswer
      }
    }
    question.isEditing = false
  })

  // Check if all required questions are answered
  const unansweredRequired = task.questionnaire.filter(q => q.required && !q.answer)
  if (unansweredRequired.length > 0) {
    toast.add({
      severity: 'warn',
      summary: 'Incomplete Questionnaire',
      detail: `Please answer all ${unansweredRequired.length} required question(s) before submitting.`,
      life: 4000
    })
    return
  }

  // Mark task as completed
  task.status = 'completed'

  toast.add({
    severity: 'success',
    summary: 'Questionnaire Submitted',
    detail: 'Thank you! Your questionnaire has been submitted successfully.',
    life: 3000
  })

  // Close the drawer after a short delay
  setTimeout(() => {
    isTaskDetailsDrawerOpen.value = false
  }, 1500)
}

// Get revoked systems count for offboarding system access tasks
const getRevokedSystemsCount = (task) => {
  if (!task.systemAccess || task.systemAccess.length === 0) return 0
  return task.systemAccess.filter(system => system.revoked).length
}

// Get collected assets count for offboarding asset collection tasks
const getCollectedAssetsCount = (task) => {
  if (!task.assetCollection || task.assetCollection.length === 0) return 0
  return task.assetCollection.filter(asset => asset.collected).length
}

// Asset condition options for collection form
const assetConditionOptions = ref([
  { label: 'Excellent', value: 'Excellent' },
  { label: 'Good', value: 'Good' },
  { label: 'Fair', value: 'Fair' },
  { label: 'Poor', value: 'Poor' },
  { label: 'Damaged', value: 'Damaged' }
])

// IT/PIC Action Functions - System Access Revocation (Offboarding)
const confirmSystemRevocation = (system, index) => {
  // Get current user name from store
  const currentUserName = userStore.currentRole?.name === 'IT/PIC' ? 'David Kim' : 'IT Admin'

  // Update the system access
  system.revoked = true
  system.revokedAt = new Date().toISOString().split('T')[0]
  system.revokedBy = currentUserName
  if (system.tempRevocationNotes) {
    system.revocationNotes = system.tempRevocationNotes
  }

  toast.add({
    severity: 'success',
    summary: 'Access Revoked',
    detail: `Access to ${system.name} has been successfully revoked`,
    life: 3000
  })
}

const undoSystemRevocation = (system, index) => {
  system.revoked = false
  system.revokedAt = null
  system.revokedBy = null
  system.revocationNotes = null

  toast.add({
    severity: 'info',
    summary: 'Revocation Undone',
    detail: `Revocation of ${system.name} has been undone`,
    life: 3000
  })
}

// IT/PIC Action Functions - Asset Collection (Offboarding)
const confirmAssetCollection = (asset, index) => {
  // Get current user name from store
  const currentUserName = userStore.currentRole?.name === 'IT/PIC' ? 'David Kim' : 'IT Admin'

  // Validate condition selection
  if (!asset.tempCondition) {
    toast.add({
      severity: 'warn',
      summary: 'Missing Information',
      detail: 'Please select the asset condition before confirming collection',
      life: 3000
    })
    return
  }

  // Update the asset
  asset.collected = true
  asset.collectedAt = new Date().toISOString().split('T')[0]
  asset.collectedBy = currentUserName
  asset.condition = asset.tempCondition
  if (asset.tempCollectionNotes) {
    asset.collectionNotes = asset.tempCollectionNotes
  }

  toast.add({
    severity: 'success',
    summary: 'Asset Collected',
    detail: `${asset.name} has been successfully collected`,
    life: 3000
  })
}

const undoAssetCollection = (asset, index) => {
  asset.collected = false
  asset.collectedAt = null
  asset.collectedBy = null
  asset.condition = null
  asset.collectionNotes = null

  toast.add({
    severity: 'info',
    summary: 'Collection Undone',
    detail: `Collection of ${asset.name} has been undone`,
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

/* Uploaded Document Section */
.uploaded-document-section {
  margin-bottom: 1rem;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 13px;
  color: var(--color-gray-700);
  margin-bottom: 0.5rem;
}

.section-header .pi-file-pdf {
  color: #dc2626;
}

.document-card {
  background: linear-gradient(135deg, #fef2f2, #fff);
  border: 1px solid #fecaca;
  border-radius: var(--radius-md);
  padding: 1rem;
}

.document-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

.document-icon {
  width: 48px;
  height: 48px;
  background: #fee2e2;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
}

.document-icon .pi {
  font-size: 24px;
  color: #dc2626;
}

.document-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.document-name {
  font-weight: 600;
  font-size: 14px;
  color: var(--color-gray-900);
}

.document-meta {
  font-size: 12px;
  color: var(--color-gray-500);
}

.document-actions {
  display: flex;
  gap: 0.5rem;
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

/* Stage Task Items (Staff View - matching Onboarding layout) */
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

.stage-task-item .task-item-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.375rem;
  margin-bottom: 0.375rem;
}

.task-item-title {
  font-weight: 500;
  font-size: 13px;
  color: var(--color-gray-900);
  line-height: 1.3;
}

.stage-task-item .task-item-meta {
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

.stage-task-item .task-item-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.25rem;
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

/* Staff Upload Section */
.staff-upload-section {
  padding: 0.75rem;
}

.uploaded-file-preview {
  margin-bottom: 0.75rem;
}

.uploaded-file-preview .file-preview {
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border: 1px solid #86efac;
}

.uploaded-file-preview .file-icon-wrapper.uploaded {
  background: #bbf7d0;
  color: var(--color-success-700);
}

.replace-file-hint {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  margin-top: 0.5rem;
  padding: 0.375rem 0.5rem;
  background: #fef9c3;
  border-radius: var(--radius-sm);
  font-size: 11px;
  color: #a16207;
}

.replace-file-hint i {
  font-size: 12px;
}

.file-upload-area {
  border: 2px dashed var(--color-gray-300);
  border-radius: var(--radius-md);
  background: var(--color-gray-50);
  transition: all 0.2s ease;
  cursor: pointer;
}

.file-upload-area:hover {
  border-color: var(--color-primary-400);
  background: var(--color-primary-50);
}

.file-upload-area.has-file {
  border-color: var(--color-success-400);
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
}

.upload-label {
  display: block;
  cursor: pointer;
  padding: 1rem;
}

.upload-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  text-align: center;
}

.upload-placeholder i {
  font-size: 2rem;
  color: var(--color-gray-400);
}

.file-upload-area:hover .upload-placeholder i {
  color: var(--color-primary-500);
}

.upload-text {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-600);
}

.file-upload-area:hover .upload-text {
  color: var(--color-primary-600);
}

.upload-hint {
  font-size: 11px;
  color: var(--color-gray-400);
}

.upload-selected {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.upload-selected > i.pi-file {
  font-size: 1.5rem;
  color: var(--color-success-600);
}

.selected-file-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.selected-file-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-gray-800);
}

.selected-file-size {
  font-size: 11px;
  color: var(--color-gray-500);
}

.remove-temp {
  padding: 0.375rem;
  color: var(--color-gray-400);
  cursor: pointer;
  transition: color 0.2s ease;
}

.remove-temp:hover {
  color: var(--color-danger-600);
}

.upload-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-top: 0.75rem;
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

/* Staff Questionnaire Form Styles */
.questionnaire-section.staff-mode {
  background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%);
  border: 1px solid #a5b4fc;
}

.questionnaire-section.staff-mode .questionnaire-header {
  color: #4338ca;
  border-bottom-color: #a5b4fc;
}

.staff-questionnaire-form {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.staff-form-instructions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 0.75rem;
  background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
  border: 1px solid #fcd34d;
  border-radius: var(--radius-md);
  font-size: 12px;
  color: #92400e;
}

.staff-form-instructions i {
  color: #d97706;
  font-size: 14px;
}

.question-card.staff-editable {
  border: 1px solid #c7d2fe;
  transition: all 0.2s ease;
}

.question-card.staff-editable:hover {
  border-color: #818cf8;
  box-shadow: 0 2px 12px rgba(99, 102, 241, 0.15);
}

.question-card.staff-editable.question-required {
  border-left: 3px solid #f59e0b;
}

.question-card.staff-editable.question-answered {
  border-left: 3px solid var(--color-success-500);
}

.required-asterisk {
  color: #dc2626;
  font-weight: 600;
  margin-left: 2px;
}

.staff-input-section {
  padding: 0.75rem;
  background: var(--color-bg);
}

.input-wrapper {
  margin-bottom: 0.5rem;
}

.staff-dropdown {
  width: 100%;
}

.staff-dropdown :deep(.p-dropdown) {
  width: 100%;
}

.staff-textarea {
  width: 100%;
}

.staff-textarea :deep(.p-textarea) {
  width: 100%;
  resize: vertical;
}

.checkbox-group {
  padding: 0.25rem 0;
}

.checkbox-options {
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
}

.checkbox-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.checkbox-option label {
  font-size: 13px;
  color: var(--color-gray-700);
  cursor: pointer;
}

.checkbox-option:hover label {
  color: var(--color-primary-600);
}

.current-answer-display {
  margin-top: 0.75rem;
  padding: 0.75rem;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border: 1px solid #86efac;
  border-radius: var(--radius-md);
}

.current-answer-label {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 11px;
  font-weight: 600;
  color: var(--color-success-700);
  margin-bottom: 0.5rem;
}

.current-answer-label i {
  color: var(--color-success-600);
  font-size: 12px;
}

.current-answer-value {
  font-size: 13px;
  color: var(--color-success-900);
  padding: 0.5rem 0.625rem;
  background: var(--color-bg);
  border: 1px solid #bbf7d0;
  border-radius: var(--radius-sm);
  margin-bottom: 0.5rem;
  line-height: 1.5;
}

.edit-answer-btn {
  font-size: 11px;
}

.edit-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px dashed var(--color-divider);
}

.edit-actions :deep(.p-button) {
  font-size: 12px;
}

.staff-questionnaire-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  background: var(--color-bg);
  border: 1px solid #c7d2fe;
  border-radius: var(--radius-md);
  margin-top: 0.5rem;
}

.action-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.answered-count {
  font-size: 12px;
  font-weight: 500;
  color: var(--color-gray-700);
}

.required-warning {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 11px;
  color: #d97706;
}

.required-warning i {
  font-size: 12px;
}

.staff-questionnaire-actions .action-buttons {
  display: flex;
  gap: 0.5rem;
}

.staff-questionnaire-actions .action-buttons :deep(.p-button) {
  white-space: nowrap;
  min-width: fit-content;
}

/* System Access Section - Offboarding */
.system-access-section {
  background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
  border: 1px solid #fecaca;
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.system-access-section.offboarding {
  background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
  border: 1px solid #fecaca;
}

.system-access-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 13px;
  color: #dc2626;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #fecaca;
}

.system-access-header i {
  color: #dc2626;
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
  border-color: #fca5a5;
  box-shadow: 0 2px 8px rgba(220, 38, 38, 0.1);
}

.system-access-card.system-revoked {
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
  background: #dc2626;
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
  color: #dc2626;
  font-size: 12px;
}

.revocation-confirmed {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 0.75rem;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border-top: 1px solid #bbf7d0;
  font-size: 12px;
  color: var(--color-success-700);
}

.revocation-confirmed i {
  color: var(--color-success-600);
}

.revocation-pending {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 0.75rem;
  background: linear-gradient(135deg, #fefce8 0%, #fef9c3 100%);
  border-top: 1px solid #fde047;
  font-size: 12px;
  color: #a16207;
  font-style: italic;
}

.revocation-pending i {
  color: #ca8a04;
}

/* Asset Collection Section - Offboarding */
.asset-collection-section {
  background: linear-gradient(135deg, #fef7ed 0%, #fed7aa 100%);
  border: 1px solid #fdba74;
  border-radius: var(--radius-md);
  padding: 0.75rem;
  margin-bottom: 1rem;
}

.asset-collection-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 13px;
  color: #c2410c;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #fdba74;
}

.asset-collection-header i {
  color: #c2410c;
}

.asset-collection-header span {
  flex: 1;
}

.asset-collection-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.asset-collection-card {
  background: var(--color-bg);
  border: 1px solid var(--color-divider);
  border-radius: var(--radius-md);
  overflow: hidden;
  transition: all 0.2s ease;
}

.asset-collection-card:hover {
  border-color: #fb923c;
  box-shadow: 0 2px 8px rgba(194, 65, 12, 0.1);
}

.asset-collection-card.asset-collected {
  border-left: 3px solid var(--color-success-500);
}

.asset-collection-card.asset-compulsory:not(.asset-collected) {
  border-left: 3px solid #dc2626;
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
  background: #c2410c;
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

.asset-badges {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.asset-serial {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: var(--color-gray-50);
  border-bottom: 1px solid var(--color-divider);
  font-size: 12px;
  color: var(--color-gray-600);
}

.asset-serial i {
  color: #c2410c;
  font-size: 11px;
}

.asset-description {
  padding: 0.625rem 0.75rem;
  font-size: 12px;
  color: var(--color-gray-600);
  background: var(--color-bg);
  border-bottom: 1px solid var(--color-divider);
}

.asset-details {
  padding: 0.75rem;
}

.asset-detail-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 12px;
  color: var(--color-gray-600);
  margin-bottom: 0.5rem;
}

.asset-detail-item:last-child {
  margin-bottom: 0;
}

.asset-detail-item i {
  color: #c2410c;
  font-size: 12px;
}

.collection-confirmed {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 0.75rem;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border-top: 1px solid #bbf7d0;
  font-size: 12px;
  color: var(--color-success-700);
}

.collection-confirmed i {
  color: var(--color-success-600);
}

.collection-pending {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 0.75rem;
  background: linear-gradient(135deg, #fefce8 0%, #fef9c3 100%);
  border-top: 1px solid #fde047;
  font-size: 12px;
  color: #a16207;
  font-style: italic;
}

.collection-pending i {
  color: #ca8a04;
}

/* IT/PIC Action Section Styles */
.itpic-action-section {
  margin-top: 0.75rem;
  padding: 0.75rem;
  background: var(--color-gray-50);
  border-radius: var(--radius-md);
  border: 1px dashed var(--color-divider);
}

.itpic-action-section.revoke-action {
  background: linear-gradient(135deg, #fef2f2 0%, #fecaca 100%);
  border-color: #fca5a5;
}

.itpic-action-section.collect-action {
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border-color: #86efac;
}

.action-section-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 12px;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--color-divider);
}

.revoke-action .action-section-header {
  color: #dc2626;
  border-bottom-color: #fca5a5;
}

.revoke-action .action-section-header i {
  color: #dc2626;
}

.collect-action .action-section-header {
  color: var(--color-success-700);
  border-bottom-color: #86efac;
}

.collect-action .action-section-header i {
  color: var(--color-success-600);
}

.revoke-form,
.collect-form {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.form-row {
  display: flex;
  gap: 0.75rem;
}

.form-field {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.form-field label {
  font-size: 11px;
  font-weight: 600;
  color: var(--color-gray-600);
  text-transform: uppercase;
  letter-spacing: 0.025em;
}

.action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.action-buttons :deep(.p-button) {
  white-space: nowrap;
  min-width: fit-content;
}

.itpic-undo-section {
  display: flex;
  justify-content: flex-end;
  padding: 0.75rem;
  background: var(--color-gray-50);
  border-top: 1px solid var(--color-divider);
}

/* Granted Credentials Section - Offboarding */
.granted-credentials-section {
  margin: 0.5rem 0.75rem;
  padding: 0.625rem;
  background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
  border: 1px solid #93c5fd;
  border-radius: var(--radius-md);
}

.granted-credentials-section .credentials-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 11px;
  color: #1d4ed8;
  margin-bottom: 0.5rem;
  padding-bottom: 0.375rem;
  border-bottom: 1px solid #93c5fd;
  text-transform: uppercase;
  letter-spacing: 0.025em;
}

.granted-credentials-section .credentials-header i {
  color: #1d4ed8;
  font-size: 12px;
}

.granted-credentials-section .credentials-content {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.granted-credentials-section .credential-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 12px;
}

.granted-credentials-section .credential-label {
  color: var(--color-gray-500);
  min-width: 80px;
}

.granted-credentials-section .credential-value {
  color: var(--color-gray-800);
  font-weight: 500;
  font-family: 'SF Mono', 'Monaco', 'Consolas', monospace;
  background: rgba(255, 255, 255, 0.6);
  padding: 0.125rem 0.375rem;
  border-radius: var(--radius-sm);
}
</style>
