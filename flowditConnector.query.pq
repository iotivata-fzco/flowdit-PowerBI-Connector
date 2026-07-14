section flowditConnectorUnitTests;

shared flowditConnector.UnitTest = [
    RootTable = flowditConnector.Contents("api-dev.flowdit.com", "testing.flowdit.com"),

    // ── Entity data ───────────────────────────────────────────────────────────
    Issues           = RootTable{[Name = "issues"]}[Data],
    IssueCategories  = RootTable{[Name = "issue-categories"]}[Data],
    IssueAssignees   = RootTable{[Name = "issue-assignees"]}[Data],
    IssueLabels      = RootTable{[Name = "issue-labels"]}[Data],
    Inspections      = RootTable{[Name = "inspections"]}[Data],
    Responses        = RootTable{[Name = "responses"]}[Data],
    Templates        = RootTable{[Name = "templates"]}[Data],
    Assignments      = RootTable{[Name = "assignments"]}[Data],
    AssignmentAssignees = RootTable{[Name = "assignment-assignees"]}[Data],
    AssignmentManagers = RootTable{[Name = "assignment-managers"]}[Data],
    Assets           = RootTable{[Name = "assets"]}[Data],
    AssetTypes       = RootTable{[Name = "asset-types"]}[Data],
    Users            = RootTable{[Name = "users"]}[Data],
    Groups           = RootTable{[Name = "groups"]}[Data],
    UserGroups       = RootTable{[Name = "user-groups"]}[Data],

    // Helper
    colNames = (t) => Table.ColumnNames(t),
    hasCol   = (t, col) => List.Contains(Table.ColumnNames(t), col),

    // Fact(<Name of the Test>, <Expected Value>, <Actual Value>)
    facts = {
        // ── Navigation table ──────────────────────────────────────────────────
        Fact("Nav table has 15 entries", 15, Table.RowCount(RootTable)),

        // ── Issues (10 columns) ──────────────────────────────────────────────
        Fact("Issues data loads", true, not Table.IsEmpty(Issues)),
        Fact("Issues has 10 columns", 10, List.Count(colNames(Issues))),
        Fact("Issues has 'id'",            true, hasCol(Issues, "id")),
        Fact("Issues has 'title'",         true, hasCol(Issues, "title")),
        Fact("Issues has 'status'",        true, hasCol(Issues, "status")),
        Fact("Issues has 'priority'",      true, hasCol(Issues, "priority")),
        Fact("Issues has 'risk_code'",     true, hasCol(Issues, "risk_code")),
        Fact("Issues has 'asset_id'",      true, hasCol(Issues, "asset_id")),
        Fact("Issues has 'category_id'",   true, hasCol(Issues, "category_id")),
        Fact("Issues has 'due_at'",        true, hasCol(Issues, "due_at")),
        Fact("Issues has 'created_at'",    true, hasCol(Issues, "created_at")),
        Fact("Issues has 'updated_at'",    true, hasCol(Issues, "updated_at")),

        // ── Issue Categories (7 columns) ─────────────────────────────────────
        Fact("IssueCategories has 7 columns", 7, List.Count(colNames(IssueCategories))),
        Fact("IssueCategories has 'id'",         true, hasCol(IssueCategories, "id")),
        Fact("IssueCategories has 'name'",       true, hasCol(IssueCategories, "name")),
        Fact("IssueCategories has 'risk_code'",  true, hasCol(IssueCategories, "risk_code")),
        Fact("IssueCategories has 'parent_id'",  true, hasCol(IssueCategories, "parent_id")),
        Fact("IssueCategories has 'created_at'", true, hasCol(IssueCategories, "created_at")),
        Fact("IssueCategories has 'updated_at'", true, hasCol(IssueCategories, "updated_at")),
        Fact("IssueCategories has 'is_deleted'", true, hasCol(IssueCategories, "is_deleted")),

        // ── Issue Assignees (6 columns) ──────────────────────────────────────
        Fact("IssueAssignees has 6 columns", 6, List.Count(colNames(IssueAssignees))),
        Fact("IssueAssignees has 'id'",            true, hasCol(IssueAssignees, "id")),
        Fact("IssueAssignees has 'issue_id'",      true, hasCol(IssueAssignees, "issue_id")),
        Fact("IssueAssignees has 'assignee_id'",   true, hasCol(IssueAssignees, "assignee_id")),
        Fact("IssueAssignees has 'type'",          true, hasCol(IssueAssignees, "type")),
        Fact("IssueAssignees has 'assigned_by_id'", true, hasCol(IssueAssignees, "assigned_by_id")),
        Fact("IssueAssignees has 'updated_at'",    true, hasCol(IssueAssignees, "updated_at")),

        // ── Issue Labels (6 columns) ─────────────────────────────────────────
        Fact("IssueLabels has 6 columns", 6, List.Count(colNames(IssueLabels))),
        Fact("IssueLabels has 'id'",          true, hasCol(IssueLabels, "id")),
        Fact("IssueLabels has 'issue_id'",     true, hasCol(IssueLabels, "issue_id")),
        Fact("IssueLabels has 'label_id'",     true, hasCol(IssueLabels, "label_id")),
        Fact("IssueLabels has 'label'",        true, hasCol(IssueLabels, "label")),
        Fact("IssueLabels has 'added_by_id'",  true, hasCol(IssueLabels, "added_by_id")),
        Fact("IssueLabels has 'updated_at'",   true, hasCol(IssueLabels, "updated_at")),

        // ── Inspections (20 columns) ─────────────────────────────────────────
        Fact("Inspections has 20 columns", 20, List.Count(colNames(Inspections))),
        Fact("Inspections has 'id'",                true, hasCol(Inspections, "id")),
        Fact("Inspections has 'title'",             true, hasCol(Inspections, "title")),
        Fact("Inspections has 'status_code'",       true, hasCol(Inspections, "status_code")),
        Fact("Inspections has 'is_collaborative'",  true, hasCol(Inspections, "is_collaborative")),
        Fact("Inspections has 'score'",             true, hasCol(Inspections, "score")),
        Fact("Inspections has 'count_failed'",      true, hasCol(Inspections, "count_failed")),
        Fact("Inspections has 'count_issues'",      true, hasCol(Inspections, "count_issues")),
        Fact("Inspections has 'sequence_number'",   true, hasCol(Inspections, "sequence_number")),
        Fact("Inspections has 'document_id'",       true, hasCol(Inspections, "document_id")),
        Fact("Inspections has 'assignment_id'",     true, hasCol(Inspections, "assignment_id")),
        Fact("Inspections has 'template_id'",       true, hasCol(Inspections, "template_id")),
        Fact("Inspections has 'asset_id'",          true, hasCol(Inspections, "asset_id")),
        Fact("Inspections has 'assigned_by_id'",    true, hasCol(Inspections, "assigned_by_id")),
        Fact("Inspections has 'started_by_id'",     true, hasCol(Inspections, "started_by_id")),
        Fact("Inspections has 'current_user_id'",   true, hasCol(Inspections, "current_user_id")),
        Fact("Inspections has 'started_at'",        true, hasCol(Inspections, "started_at")),
        Fact("Inspections has 'due_at'",            true, hasCol(Inspections, "due_at")),
        Fact("Inspections has 'end_date'",          true, hasCol(Inspections, "end_date")),
        Fact("Inspections has 'created_at'",        true, hasCol(Inspections, "created_at")),
        Fact("Inspections has 'updated_at'",        true, hasCol(Inspections, "updated_at")),

        // ── Responses (10 columns) ───────────────────────────────────────────
        Fact("Responses has 10 columns", 10, List.Count(colNames(Responses))),
        Fact("Responses has 'id'",              true, hasCol(Responses, "id")),
        Fact("Responses has 'item_base_uuid'",  true, hasCol(Responses, "item_base_uuid")),
        Fact("Responses has 'item_uuid'",       true, hasCol(Responses, "item_uuid")),
        Fact("Responses has 'item_type'",       true, hasCol(Responses, "item_type")),
        Fact("Responses has 'answer'",          true, hasCol(Responses, "answer")),
        Fact("Responses has 'question_title'",  true, hasCol(Responses, "question_title")),
        Fact("Responses has 'template_id'",     true, hasCol(Responses, "template_id")),
        Fact("Responses has 'inspection_id'",   true, hasCol(Responses, "inspection_id")),
        Fact("Responses has 'response_at'",     true, hasCol(Responses, "response_at")),
        Fact("Responses has 'is_dynamic'",      true, hasCol(Responses, "is_dynamic")),

        // ── Templates (6 columns) ────────────────────────────────────────────
        Fact("Templates has 6 columns", 6, List.Count(colNames(Templates))),
        Fact("Templates has 'id'",           true, hasCol(Templates, "id")),
        Fact("Templates has 'title'",        true, hasCol(Templates, "title")),
        Fact("Templates has 'created_by_id'", true, hasCol(Templates, "created_by_id")),
        Fact("Templates has 'created_at'",   true, hasCol(Templates, "created_at")),
        Fact("Templates has 'updated_at'",   true, hasCol(Templates, "updated_at")),
        Fact("Templates has 'is_deleted'",   true, hasCol(Templates, "is_deleted")),

        // ── Assignments (13 columns) ─────────────────────────────────────────
        Fact("Assignments has 13 columns", 13, List.Count(colNames(Assignments))),
        Fact("Assignments has 'id'",                  true, hasCol(Assignments, "id")),
        Fact("Assignments has 'title'",               true, hasCol(Assignments, "title")),
        Fact("Assignments has 'assigned_by_id'",      true, hasCol(Assignments, "assigned_by_id")),
        Fact("Assignments has 'is_restricted'",       true, hasCol(Assignments, "is_restricted")),
        Fact("Assignments has 'is_collaborative'",    true, hasCol(Assignments, "is_collaborative")),
        Fact("Assignments has 'type'",                true, hasCol(Assignments, "type")),
        Fact("Assignments has 'status'",              true, hasCol(Assignments, "status")),
        Fact("Assignments has 'submitted_after_due'", true, hasCol(Assignments, "submitted_after_due")),
        Fact("Assignments has 'started_at'",          true, hasCol(Assignments, "started_at")),
        Fact("Assignments has 'ended_at'",            true, hasCol(Assignments, "ended_at")),
        Fact("Assignments has 'created_at'",          true, hasCol(Assignments, "created_at")),
        Fact("Assignments has 'updated_at'",          true, hasCol(Assignments, "updated_at")),
        Fact("Assignments has 'is_deleted'",         true, hasCol(Assignments, "is_deleted")),

        // ── Assignment Assignees (6 columns) ─────────────────────────────────
        Fact("AssignmentAssignees has 6 columns", 6, List.Count(colNames(AssignmentAssignees))),
        Fact("AssignmentAssignees has 'id'",             true, hasCol(AssignmentAssignees, "id")),
        Fact("AssignmentAssignees has 'assignment_id'",  true, hasCol(AssignmentAssignees, "assignment_id")),
        Fact("AssignmentAssignees has 'assignee_id'",    true, hasCol(AssignmentAssignees, "assignee_id")),
        Fact("AssignmentAssignees has 'type'",           true, hasCol(AssignmentAssignees, "type")),
        Fact("AssignmentAssignees has 'assigned_by_id'", true, hasCol(AssignmentAssignees, "assigned_by_id")),
        Fact("AssignmentAssignees has 'updated_at'",     true, hasCol(AssignmentAssignees, "updated_at")),

        // ── Assignment Managers (6 columns) ─────────────────────────────────
        Fact("AssignmentManagers has 6 columns", 6, List.Count(colNames(AssignmentManagers))),
        Fact("AssignmentManagers has 'id'",             true, hasCol(AssignmentManagers, "id")),
        Fact("AssignmentManagers has 'assignment_id'",  true, hasCol(AssignmentManagers, "assignment_id")),
        Fact("AssignmentManagers has 'manager_id'",     true, hasCol(AssignmentManagers, "manager_id")),
        Fact("AssignmentManagers has 'type'",           true, hasCol(AssignmentManagers, "type")),
        Fact("AssignmentManagers has 'assigned_by_id'", true, hasCol(AssignmentManagers, "assigned_by_id")),
        Fact("AssignmentManagers has 'updated_at'",     true, hasCol(AssignmentManagers, "updated_at")),

        // ── Assets (7 columns) ───────────────────────────────────────────────
        Fact("Assets has 7 columns", 7, List.Count(colNames(Assets))),
        Fact("Assets has 'id'",           true, hasCol(Assets, "id")),
        Fact("Assets has 'asset_id'",     true, hasCol(Assets, "asset_id")),
        Fact("Assets has 'display_name'", true, hasCol(Assets, "display_name")),
        Fact("Assets has 'type_id'",      true, hasCol(Assets, "type_id")),
        Fact("Assets has 'created_by_id'", true, hasCol(Assets, "created_by_id")),
        Fact("Assets has 'created_at'",   true, hasCol(Assets, "created_at")),
        Fact("Assets has 'updated_at'",   true, hasCol(Assets, "updated_at")),

        // ── Asset Types (4 columns) ──────────────────────────────────────────
        Fact("AssetTypes has 4 columns", 4, List.Count(colNames(AssetTypes))),
        Fact("AssetTypes has 'id'",         true, hasCol(AssetTypes, "id")),
        Fact("AssetTypes has 'name'",       true, hasCol(AssetTypes, "name")),
        Fact("AssetTypes has 'created_at'", true, hasCol(AssetTypes, "created_at")),
        Fact("AssetTypes has 'updated_at'", true, hasCol(AssetTypes, "updated_at")),

        // ── Users (9 columns) ────────────────────────────────────────────────
        Fact("Users has 9 columns", 9, List.Count(colNames(Users))),
        Fact("Users has 'id'",         true, hasCol(Users, "id")),
        Fact("Users has 'first_name'", true, hasCol(Users, "first_name")),
        Fact("Users has 'last_name'",  true, hasCol(Users, "last_name")),
        Fact("Users has 'nick_name'",  true, hasCol(Users, "nick_name")),
        Fact("Users has 'email'",      true, hasCol(Users, "email")),
        Fact("Users has 'status'",     true, hasCol(Users, "status")),
        Fact("Users has 'created_at'", true, hasCol(Users, "created_at")),
        Fact("Users has 'updated_at'", true, hasCol(Users, "updated_at")),
        Fact("Users has 'is_deleted'", true, hasCol(Users, "is_deleted")),

        // ── Groups (4 columns) ───────────────────────────────────────────────
        Fact("Groups has 4 columns", 4, List.Count(colNames(Groups))),
        Fact("Groups has 'id'",         true, hasCol(Groups, "id")),
        Fact("Groups has 'name'",       true, hasCol(Groups, "name")),
        Fact("Groups has 'created_at'", true, hasCol(Groups, "created_at")),
        Fact("Groups has 'updated_at'", true, hasCol(Groups, "updated_at")),

        // ── User Groups (5 columns) ──────────────────────────────────────────
        Fact("UserGroups has 5 columns", 5, List.Count(colNames(UserGroups))),
        Fact("UserGroups has 'id'",         true, hasCol(UserGroups, "id")),
        Fact("UserGroups has 'user_id'",    true, hasCol(UserGroups, "user_id")),
        Fact("UserGroups has 'group_id'",   true, hasCol(UserGroups, "group_id")),
        Fact("UserGroups has 'created_at'", true, hasCol(UserGroups, "created_at")),
        Fact("UserGroups has 'updated_at'", true, hasCol(UserGroups, "updated_at"))
    }
];
