section flowditConnector;

// ── Schema Types ──────────────────────────────────────────────────────────────

IssueType = type table [
    id = number,
    title = nullable text,
    status = nullable text,
    priority = nullable text,
    risk_code = nullable text,
    asset_id = nullable text,
    category_id = nullable text,
    due_at = nullable datetimezone,
    created_at = nullable datetimezone,
    updated_at = nullable datetimezone
];

InspectionType = type table [
    id = number,
    title = nullable text,
    status_code = nullable text,
    is_collaborative = nullable logical,
    score = nullable number,
    count_failed = nullable number,
    count_issues = nullable number,
    sequence_number = nullable number,
    document_id = nullable text,
    assignment_id = nullable text,
    template_id = nullable text,
    asset_id = nullable text,
    assigned_by_id = nullable text,
    started_by_id = nullable text,
    current_user_id = nullable text,
    started_at = nullable datetimezone,
    due_at = nullable datetimezone,
    end_date = nullable datetimezone,
    created_at = nullable datetimezone,
    updated_at = nullable datetimezone
];

UserType = type table [
    id = number,
    first_name = nullable text,
    last_name = nullable text,
    nick_name = nullable text,
    email = nullable text,
    status = nullable text,
    created_at = nullable datetimezone,
    updated_at = nullable datetimezone,
    is_deleted = nullable logical
];

GroupType = type table [
    id = number,
    name = nullable text,
    created_at = nullable datetimezone,
    updated_at = nullable datetimezone
];

UserGroupType = type table [
    id = number,
    user_id = nullable text,
    group_id = nullable text,
    created_at = nullable datetimezone,
    updated_at = nullable datetimezone
];

AssignmentType = type table [
    id = number,
    title = nullable text,
    assigned_by_id = nullable text,
    is_restricted = nullable logical,
    is_collaborative = nullable logical,
    type = nullable text,
    status = nullable text,
    submitted_after_due = nullable logical,
    started_at = nullable datetimezone,
    ended_at = nullable datetimezone,
    created_at = nullable datetimezone,
    updated_at = nullable datetimezone,
    is_deleted = nullable logical
];

TemplateType = type table [
    id = number,
    title = nullable text,
    created_by_id = nullable text,
    created_at = nullable datetimezone,
    updated_at = nullable datetimezone,
    is_deleted = nullable logical
];

ResponsesType = type table [
    id = number,
    item_base_uuid = nullable text,
    item_uuid = nullable text,
    item_type = nullable text,
    answer = nullable text,
    question_title = nullable text,
    template_id = nullable text,
    inspection_id = nullable text,
    response_at = nullable datetimezone,
    is_dynamic = nullable logical
];

AssetType = type table [
    id = number,
    asset_id = nullable text,
    display_name = nullable text,
    type_id = nullable text,
    created_by_id = nullable text,
    created_at = nullable datetimezone,
    updated_at = nullable datetimezone
];

AssetTypeType = type table [
    id = number,
    name = nullable text,
    created_at = nullable datetimezone,
    updated_at = nullable datetimezone
];

IssueCategoryType = type table [
    id = number,
    name = nullable text,
    risk_code = nullable text,
    parent_id = nullable text,
    created_at = nullable datetimezone,
    updated_at = nullable datetimezone,
    is_deleted = nullable logical
];

IssueAssigneeType = type table [
    id = text,
    issue_id = nullable text,
    assignee_id = nullable text,
    type = nullable text,
    assigned_by_id = nullable text,
    updated_at = nullable datetimezone
];

// Maps entity names to their schema types and navigation groups.
SchemaTable = #table(
    {"Entity", "Type", "Group"},
    {
        {"issues", IssueType, ""},
        {"inspections", InspectionType, ""},
        {"assignments", AssignmentType, ""},
        {"templates", TemplateType, ""},
        {"responses", ResponsesType, ""},
        {"assets", AssetType, ""},
        {"asset-types", AssetTypeType, ""},
        {"users", UserType, ""},
        {"groups", GroupType, ""},
        {"user-groups", UserGroupType, ""},
        {"issue-categories", IssueCategoryType, ""},
        {"issue-assignees", IssueAssigneeType, ""}
    }
);

GetSchemaForEntity = (entity as text) as type =>
    try SchemaTable{[Entity = entity]}[Type]
    otherwise error "Couldn't find entity: '" & entity & "'";

// ── Data Source Definition ────────────────────────────────────────────────────

flowditConnector = [
    TestConnection = (apiDomain, workspaceDomain) =>
        let
            testUrl = "https://" & apiDomain & "/api/" & workspaceDomain & "/integrations/powerbi/v1/ping",
            currentCredential = Extension.CurrentCredential(),
            token = currentCredential[Key],
            headers = [
                Accept = "application/json",
                Authorization = "Bearer " & token
            ],
            testResult = try Web.Contents(
                testUrl,
                [
                    Headers = headers,
                    ManualCredentials = true,
                    ManualStatusHandling = {400, 401, 403, 404, 500},
                    Timeout = #duration(0, 0, 0, 10)
                ]
            ),
            args =
                if testResult[HasError] then
                    error Error.Record(
                        "DataSource.Error",
                        "Could not connect to the API. " & testResult[Error][Message],
                        "Check the API Domain and Workspace Domain for typos."
                    )
                else
                    let
                        response = testResult[Value],
                        status = Value.Metadata(response)[Response.Status]?,
                        body = try Json.Document(response) otherwise null,
                        bodyMsg = if body <> null and Record.HasFields(body, {"error"}) then body[error]
                                  else if body <> null and Record.HasFields(body, {"message"}) then body[message]
                                  else null
                    in
                        if status = 401 then
                            error Error.Record(
                                "DataSource.Error",
                                "Invalid credentials. The API Token was rejected by the server.",
                                if bodyMsg <> null then bodyMsg else "Verify the API Token is correct and has not expired."
                            )
                        else if status = 403 then
                            error Error.Record(
                                "DataSource.Error",
                                "Access forbidden (403).",
                                if bodyMsg <> null then bodyMsg else "Check that the token has the correct permissions."
                            )
                        else if status = 404 then
                            error Error.Record(
                                "DataSource.Error",
                                "Endpoint not found (404). Check the API Domain and Workspace Domain.",
                                "Verify the domain and workspace number (e.g. 0) are correct."
                            )
                        else if status = null or status < 200 or status >= 300 then
                            error Error.Record(
                                "DataSource.Error",
                                "Connection test failed with status " & (if status <> null then Text.From(status) else "unknown") & ".",
                                if bodyMsg <> null then bodyMsg else "Verify your API Domain, Workspace Domain, and API Token."
                            )
                        else
                            { "flowditConnector.Contents", apiDomain, workspaceDomain }
        in
            args,
    Authentication = [
        Key = [ KeyLabel = "API Token" ]
    ],
    Label = "Flowdit Connector"
];

flowditConnector.Publish = [
    Beta       = false,
    ButtonText = { "Flowdit Connector", "Connect to your Flowdit tenant" },
    SourceImage = flowditConnector.Icons,
    SourceTypeImage = flowditConnector.Icons
];

flowditConnector.Icons = [
    Icon16 = { Extension.Contents("icon16.png") },
    Icon32 = { Extension.Contents("icon32.png") }
];

// ── Connector Entry Point ─────────────────────────────────────────────────────

[DataSource.Kind = "flowditConnector", Publish = "flowditConnector.Publish"]
shared flowditConnector.Contents = Value.ReplaceType(flowditConnectorImpl, flowditConnectorType);

flowditConnectorType = type function (
    apiDomain as (
        type text meta [
            Documentation.FieldCaption = "API Domain",
            Documentation.FieldDescription = "API domain for your Flowdit instance (e.g. api.flowdit.com)",
            Documentation.SampleValues = {"api.flowdit.com"}
        ]
    ),
    workspaceDomain as (
        type text meta [
            Documentation.FieldCaption = "Workspace Domain",
            Documentation.FieldDescription = "Workspace domain for your Flowdit tenant (e.g. testing.flowdit.com)",
            Documentation.SampleValues = {"{workspaceId}.flowdit.com"}
        ]
    )
) as table meta [ Documentation.Name = "Flowdit Connector" ];

flowditConnectorImpl = (apiDomain as text, workspaceDomain as text) as table =>
    let
        baseUrl = "https://" & apiDomain & "/api/" & workspaceDomain & "/integrations/powerbi/v1",
        navTable = flowditNavTable(baseUrl)
    in
        navTable;

// ── Incremental Refresh Entry Point ───────────────────────────────────────────
// Use this function in Power BI Desktop to enable Incremental Refresh.
// The date-range args map 1:1 to the API `updated_at_from` / `updated_at_to`
// filters (handled with full datetime precision on the backend), so each Power BI
// refresh partition only pulls rows whose updated_at falls inside its window
// instead of reloading the whole table.
//
// Recommended Power BI Desktop setup:
//   1. Create DateTime parameters `RangeStart` and `RangeEnd` (set values in UTC).
//   2. Get Data > flowditConnector.IncrementalRefresh, fill:
//        apiDomain       = e.g. "api.flowdit.com"
//        workspaceDomain = e.g. "testing.flowdit.com"
//        entity          = e.g. "inspections"
//        updatedAfter    = RangeStart
//        updatedBefore   = RangeEnd
//   3. Mark as date table on `updated_at` (Table tools > Mark as date table).
//   4. Configure Incremental Refresh policy (e.g. incremental: 1 day / historical: 5 years).
//
// Power BI partitions by date window and expands RangeStart/RangeEnd per
// partition at refresh time, so only the updated_at slice for each partition
// is fetched from the API — the remaining partitions stay cached.

// NOTE 1: No `Publish` attribute here. Power BI only lists functions with a
// `Publish` record in the "Get Data" gallery. Both Contents and IncrementalRefresh
// were pointing at the SAME `flowditConnector.Publish` record, so Power BI showed
// duplicate "Flowdit Connector" entries, and picking the IncrementalRefresh one
// presented its entity / updated_from / updated_to fields. By leaving only
// `DataSource.Kind`, IncrementalRefresh stays usable in M (and discoverable via
// Get Data search by name), but Contents is the sole gallery entry — the user
// always lands on apiDomain / workspaceDomain when they pick the connector.
//
// NOTE 2: entity, updatedAfter, updatedBefore are declared `optional` so that the
// required-parameter signature (apiDomain, workspaceDomain) matches
// flowditConnector.Contents. Per Microsoft's connector rules:
//   "when you associate a function with a specific DataSource.Kind, each function
//    must have the same set of required parameters, with the same name and type."
// Optional params are excluded from the credential lookup key. Violating this
// rule causes Power BI to silently refuse to load the extension.
[DataSource.Kind = "flowditConnector"]
shared flowditConnector.IncrementalRefresh = Value.ReplaceType(flowditConnectorIncrementalImpl, flowditConnectorIncrementalType);
flowditConnectorIncrementalType = type function (
    apiDomain as (
        type text meta [
            Documentation.FieldCaption = "API Domain",
            Documentation.FieldDescription = "API domain for your Flowdit instance (e.g. api.flowdit.com)",
            Documentation.SampleValues = {"api.flowdit.com"}
        ]
    ),
    workspaceDomain as (
        type text meta [
            Documentation.FieldCaption = "Workspace Domain",
            Documentation.FieldDescription = "Workspace domain for your Flowdit tenant (e.g. testing.flowdit.com)",
            Documentation.SampleValues = {"{workspaceId}.flowdit.com"}
        ]
    ),
    optional entity as (
        type nullable text meta [
            Documentation.FieldCaption = "Entity",
            Documentation.FieldDescription = "One of: issues, inspections, assignments, templates, responses, assets, asset-types, users, groups, user-groups, issue-categories, issue-assignees",
            Documentation.SampleValues = {"inspections"}
        ]
    ),
    optional updatedAfter as (
        type nullable datetime meta [
            Documentation.FieldCaption = "Updated After (UTC)",
            Documentation.FieldDescription = "Inclusive lower bound on updated_at. Bind this to the RangeStart datetime parameter."
        ]
    ),
    optional updatedBefore as (
        type nullable datetime meta [
            Documentation.FieldCaption = "Updated Before (UTC)",
            Documentation.FieldDescription = "Inclusive upper bound on updated_at. Bind this to the RangeEnd datetime parameter."
        ]
    )
) as table meta [ Documentation.Name = "Flowdit Incremental Refresh" ];

flowditConnectorIncrementalImpl = (
    apiDomain as text,
    workspaceDomain as text,
    optional entity as nullable text,
    optional updatedAfter as nullable datetime,
    optional updatedBefore as nullable datetime
) as table =>
    let
        baseUrl = "https://" & apiDomain & "/api/" & workspaceDomain & "/integrations/powerbi/v1",
        fullUrl = baseUrl & "/" & entity,
        schema = GetSchemaForEntity(entity),
        // Format as ISO-8601 local: "yyyy-MM-ddTHH:mm:ss". The backend compares via
        // `->where('updated_at', '>=', ...)` (NOT whereDate), so the full datetime
        // (including seconds) is honored — required for correct incremental refresh.
        // Only include the params that are actually set — Web.Contents would
        // otherwise emit them as empty strings and filter everything out.
        updatedAtFrom = if updatedAfter <> null then DateTime.ToText(updatedAfter, "yyyy-MM-ddTHH:mm:ss") else null,
        updatedAtTo   = if updatedBefore <> null then DateTime.ToText(updatedBefore, "yyyy-MM-ddTHH:mm:ss") else null,
        queryParams =
            (if updatedAfter <> null then [updated_at_from = updatedAtFrom] else [])
            &
            (if updatedBefore <> null then [updated_at_to = updatedAtTo] else []),
        result = GetAllPagesByNextLink(fullUrl, schema, queryParams),
        appliedSchema = Table.ChangeType(result, schema)
    in
        appliedSchema;

// ── Navigation Table ──────────────────────────────────────────────────────────

flowditNavTable = (url as text) as table =>
    let
        entities = Table.SelectRows(SchemaTable, each [Group] = ""),
        entityNames = Table.SelectColumns(entities, {"Entity"}),
        rename = Table.RenameColumns(entityNames, {{"Entity", "Name"}}),
        withData = Table.AddColumn(rename, "Data", each GetEntity(url, [Name]), type table),
        withItemKind = Table.AddColumn(withData, "ItemKind", each "Table", type text),
        withItemName = Table.AddColumn(withItemKind, "ItemName", each "Table", type text),
        withIsLeaf = Table.AddColumn(withItemName, "IsLeaf", each true, type logical),
        navTable = Table.ToNavigationTable(withIsLeaf, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;

// ── Data Loading (Pagination with Query Folding Support) ──────────────────────

GetEntity = (url as text, entity as text) as table =>
    let
        fullUrl = url & "/" & entity,
        schema = GetSchemaForEntity(entity),
        result = GetAllPagesByNextLink(fullUrl, schema, []),
        appliedSchema = Table.ChangeType(result, schema)
    in
        appliedSchema;

// Reads all pages by following the next_page_url links from each response.
// Laravel's next_page_url already retains all original filter params + page number,
// so queryParams (filters) is only attached to the FIRST request. Subsequent
// requests follow nextLink verbatim — duplicating queryParams would make
// Web.Contents emit `?p=2&updated_at_from=...&updated_at_from=...` (duplicate keys,
// undefined behavior).
GetAllPagesByNextLink = (url as text, optional schema as type, optional queryParams as record) as table =>
    let
        // Acquire the credential token ONCE for the entire pagination chain.
        credential = Extension.CurrentCredential(),
        token = credential[Key],
        // ── CRITICAL: Parse the ORIGINAL request URL once ──
        // All subsequent pagination pages reuse this EXACT scheme + host + path
        // so Power BI treats every page as the SAME data source.
        //
        // ROOT CAUSE: Laravel's next_page_url may differ from the original URL
        // in scheme (http vs https) or host when the server is behind a reverse
        // proxy, load balancer, or Docker network. Power BI treats ANY scheme
        // or host change as a BRAND-NEW data source and prompts for credentials
        // — even though the token is valid. Page 1 works (same URL as the
        // connector sent), page 2+ fails (follows next_page_url verbatim).
        //
        // FIX: For page 2+, rebuild the URL using the ORIGINAL scheme + host +
        // path, extracting ONLY the query string (page=N + filters) from
        // next_page_url.
        baseParts = Uri.Parts(url),
        scheme = baseParts[Scheme],
        host = baseParts[Host],
        path = baseParts[Path]
    in
        Table.GenerateByPage(
            (previous) =>
                let
                    isFirstPage = (previous = null),
                    nextLink = if isFirstPage then url else Value.Metadata(previous)[NextLink]?,
                    // Page 1: original URL with caller-supplied queryParams.
                    // Page 2+: same scheme + host + path, only the query string
                    //          comes from next_page_url (contains page=N + all
                    //          original filters echoed by Laravel).
                    requestUrl =
                        if isFirstPage then
                            url
                        else if nextLink <> null then
                            let
                                nextParts = Uri.Parts(nextLink),
                                nextQuery = nextParts[Query],
                                qString = if Record.FieldCount(nextQuery) > 0 then "?" & Uri.BuildQueryString(nextQuery) else ""
                            in
                                scheme & "://" & host & path & qString
                        else
                            null,
                    pageParams = if isFirstPage then queryParams else null,
                    page = if (requestUrl <> null) then GetPage(requestUrl, schema, pageParams, token) else null
                in
                    page
        );

// Fetches a single page and attaches the NextLink metadata.
// `token` is provided by GetAllPagesByNextLink — never read here.
GetPage = (url as text, optional schema as type, optional queryParams as record, optional token as text) as table =>
    let
        body = MakeRequest(url, queryParams, token),
        nextLink = Record.FieldOrDefault(body, "next_page_url"),
        bodyData = if Record.HasFields(body, "data") and body[data] <> null then body[data] else {},
        data =
            if List.IsEmpty(bodyData) then
                // Empty page — schema is applied later via Table.ChangeType in GetEntity
                #table({}, {})
            else if (schema = null) then
                Table.FromRecords(bodyData)
            else
                let
                    // Validate that all items are records
                    validatedData = List.Select(bodyData, each _ is record),
                    asTable = Table.FromList(validatedData, Splitter.SplitByNothing(), {"Column1"}),
                    fields = Record.FieldNames(Type.RecordFields(Type.TableRow(schema))),
                    expanded = Table.ExpandRecordColumn(asTable, "Column1", fields)
                in
                    expanded
    in
        data meta [NextLink = nextLink];

// ── HTTP Requests (with retry and error handling) ─────────────────────────────

// `token` is threaded in from GetAllPagesByNextLink. This function must NOT
// call Extension.CurrentCredential() — doing so per request drops the token
// under Power BI parallel refresh.
MakeRequest = (url as text, optional queryParams as record, optional token as text) =>
    let
        // ── CRITICAL: Decompose URL into BaseUrl + RelativePath + Query ──
        // When a full absolute URL with query string baked in (e.g. Laravel's
        // next_page_url = https://host/api/.../inspections?page=2) is passed
        // directly to Web.Contents, Power BI treats each unique URL as a DISTINCT
        // data source and re-validates credentials. The 1st page succeeds, but
        // page 2+ triggers the re-authentication modal — even though the token
        // is valid. By always passing the SAME base URL and splitting path/query
        // via RelativePath + Query, Power BI routes all pagination requests
        // through one consistent credential scope.
        parts = Uri.Parts(url),
        baseUri = parts[Scheme] & "://" & parts[Host],
        relativePath = parts[Path],
        urlQuery = parts[Query],
        // Merge URL query params (e.g. ?page=2 from next_page_url) with any
        // caller-supplied filters (only present on the first page).
        mergedQuery = if queryParams <> null then Record.Combine({urlQuery, queryParams}) else urlQuery,
        headers = [
            Accept = "application/json",
            Authorization = "Bearer " & token
        ],
        failStatusCodes = {500, 502, 503, 504, 429},
        waitForResult = Value.WaitFor(
            (iteration) =>
                let
                    _url = Diagnostics.LogValue("Accessing URL", url),
                    result = Web.Contents(
                        baseUri,
                        [
                            RelativePath = relativePath,
                            Headers = headers,
                            Query = mergedQuery,
                            ManualCredentials = true,
                            ManualStatusHandling = failStatusCodes,
                            Timeout = #duration(0, 0, 2, 0)
                        ]
                    ),
                    buffered = Binary.Buffer(result),
                    status = Value.Metadata(result)[Response.Status]?,
                    _status = Diagnostics.LogValue("Request finished with status", status),
                    actualResult =
                        if (status <> null and status = 401) then
                            error Error.Record(
                                "DataSource.Error",
                                "The API rejected the token (401 Unauthorized). Please re-enter your API Token credentials.",
                                "Verify that your API token is valid and has not expired."
                            )
                        else if (status <> null and status = 404) then
                            error Error.Record(
                                "DataSource.Error",
                                "The requested resource was not found (404).",
                                "Please verify the entity name and URL structure."
                            )
                        else if (status <> null and List.Contains(failStatusCodes, status)) then
                            null // Retry
                        else if (status <> null and (status < 200 or status >= 300)) then
                            error Error.Record(
                                "DataSource.Error",
                                "API request failed with status: " & Text.From(status),
                                "An unexpected error occurred while fetching data."
                            )
                        else
                            buffered
                in
                    actualResult,
            (iteration) => #duration(0, 0, 0, Number.Power(2, iteration) * 2),
            6
        ),
        // Safe JSON parsing with error handling
        jsonResult =
            try Json.Document(waitForResult)
            otherwise
                let
                    rawText = try Text.FromBinary(waitForResult) otherwise "[Unable to read response]",
                    errorMsg = "The API returned an invalid JSON response. " &
                               "This may indicate a server error or maintenance mode."
                in
                    error Error.Record(
                        "InvalidJsonResponse",
                        errorMsg,
                        "Raw response (first 500 chars): " & Text.Start(rawText, 500)
                    )
    in
        jsonResult;

// ── Load Library Functions ────────────────────────────────────────────────────

Extension.LoadFunction = (name as text) =>
    let
        binary = Extension.Contents(name),
        asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

Table.ChangeType = Extension.LoadFunction("Table.ChangeType.pqm");
Table.GenerateByPage = Extension.LoadFunction("Table.GenerateByPage.pqm");
Table.ToNavigationTable = Extension.LoadFunction("Table.ToNavigationTable.pqm");
Value.WaitFor = Extension.LoadFunction("Value.WaitFor.pqm");

Diagnostics = Extension.LoadFunction("Diagnostics.pqm");
Diagnostics.LogValue = Diagnostics[LogValue];
Diagnostics.LogFailure = Diagnostics[LogFailure];
