# flowdit Power Query Connector

The flowdit Power Query Connector provides a data connection for [flowdit](https://flowdit.com) in Power BI.

## Getting started

1. Build the connector (see [Build](#build) below).
2. Copy the resulting `flowditConnector.mez` file into your `[My Documents]\Power BI Desktop\Custom Connectors` folder.
3. Make sure **Allow any extension to load without validation or warning** is enabled under `File > Options and settings > Options > Security > Data Extensions`. The connector is not currently signed, so this setting is required for it to load.
4. Select `Get Data > More`, search for **Flowdit Connector**, and connect.
5. Enter your **API Domain** (for example `api.flowdit.com`) and **Workspace Domain** (for example `yourworkspace.flowdit.com`).
6. When prompted for credentials, choose **API Token** and paste in your flowdit Power BI API token.

After connecting, the navigator shows all available entities - inspections, issues, assignments, templates, responses, assets, and more - ready to load into Power BI.

### Getting an API token

An API token can be generated from your flowdit workspace settings. Contact your flowdit workspace administrator if you do not have access to generate one.

## Incremental refresh

The connector ships a second entry point, `flowditConnector.IncrementalRefresh`, that lets a single table be filtered by an `updated_at` date range. This is the setup Power BI's Incremental Refresh feature requires.

To configure it in Power BI Desktop:

1. Create two `DateTime` parameters named `RangeStart` and `RangeEnd` with values in UTC.
2. Use `Get Data > flowditConnector.IncrementalRefresh` and fill in:
   - **API Domain** - for example `api.flowdit.com`
   - **Workspace Domain** - for example `yourworkspace.flowdit.com`
   - **Entity** - the name of the table you want to filter, for example `inspections`
   - **Updated After** - bind to `RangeStart`
   - **Updated Before** - bind to `RangeEnd`
3. Mark the query as a date table on `updated_at` (`Table tools > Mark as date table`).
4. Configure the Incremental Refresh policy on the table, for example refresh the last 1 day and keep 5 years of history.

Each refresh partition then only pulls the rows whose `updated_at` falls inside its date window instead of reloading the whole table.

## Frequently Asked Questions (FAQ)

### What's the purpose of the "Workspace Domain"?

The Workspace Domain identifies which flowdit tenant to connect to, for example `yourworkspace.flowdit.com`. It is stored locally as part of the connection and is not shared with flowdit servers beyond what is needed to route the request.

### Why is a table empty?

An empty table usually means either the workspace has no records of that type yet, or the API token used does not have permission to access that data. Check with your flowdit workspace administrator if you expect data and see none.

### Can I filter which rows are loaded?

Yes. Use `flowditConnector.IncrementalRefresh` with the `Entity`, `Updated After`, and `Updated Before` parameters to load only rows updated within a specific date range. The default `flowditConnector.Contents` navigation table always loads the full table.

## Build

Requires Bash or PowerShell.

### macOS / Linux

```bash
bash build.sh
```

### Windows

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

The build creates `build/flowditConnector.mez`. See [Getting started](#getting-started) to load it into Power BI Desktop.

## Resources

- [Power Query documentation](https://docs.microsoft.com/en-us/power-query/)
- [TripPin Tutorial](https://docs.microsoft.com/en-us/power-query/samples/trippin/readme) - a good starting point for understanding Power Query data source extensions.
