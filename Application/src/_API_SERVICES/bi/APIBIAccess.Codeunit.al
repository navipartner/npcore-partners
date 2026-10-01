/// <summary>
/// Resolves the identity behind a BI API request and answers whether that identity may read a table.
/// The BI module needs this on top of the normal module permission set, because "NPR API Core" grants
/// table data permission on everything: without the allowlist, one permission set would expose the
/// whole database.
/// </summary>
codeunit 6151565 "NPR API BI Access"
{
    Access = Internal;

    var
        TableNotSupportedErr: Label 'Table %1 cannot be exposed through the BI API. Only normal, non-system tables that are not obsolete can be selected.', Comment = '%1 = table number';

    /// <summary>
    /// Finds the Entra ID application behind the current session user. An application that was created
    /// from a NaviPartner API Key is represented by that key, so all applications of one key share the
    /// same allowlist. Returns false when the session user is not an Entra ID application at all.
    /// </summary>
    procedure ResolvePrincipal(var PrincipalType: Enum "NPR API BI Principal Type"; var PrincipalId: Guid): Boolean
    var
        AADApplication: Record "AAD Application";
        CandidateType: Enum "NPR API BI Principal Type";
        CandidateId: Guid;
        Resolved: Boolean;
        Disagrees: Boolean;
    begin
        AADApplication.ReadIsolation := IsolationLevel::ReadCommitted;
        AADApplication.SetLoadFields("Client Id", "NPR NaviPartner API Key Id");
        AADApplication.SetRange("User ID", UserSecurityId());
        if not AADApplication.FindSet() then
            exit(false);

        // "User ID" has no uniqueness constraint on the Entra application table, so the session user
        // can in principle map to more than one application. Picking one of them arbitrarily would
        // apply an allowlist the caller may not own, so the request is only served while every
        // matching application agrees on the same principal.
        repeat
            if IsNullGuid(AADApplication."NPR NaviPartner API Key Id") then begin
                CandidateType := CandidateType::"Entra App";
                CandidateId := AADApplication."Client Id";
            end else begin
                CandidateType := CandidateType::"NP API Key";
                CandidateId := AADApplication."NPR NaviPartner API Key Id";
            end;

            if not Resolved then begin
                PrincipalType := CandidateType;
                PrincipalId := CandidateId;
                Resolved := true;
            end else begin
                Disagrees := CandidateType <> PrincipalType;
                if not Disagrees then
                    Disagrees := CandidateId <> PrincipalId;
                if Disagrees then
                    exit(false);
            end;
        until AADApplication.Next() = 0;

        exit(Resolved);
    end;

    procedure IsTableAllowed(PrincipalType: Enum "NPR API BI Principal Type"; PrincipalId: Guid; TableNo: Integer): Boolean
    var
        BIAllowedTable: Record "NPR API BI Allowed Table";
    begin
        BIAllowedTable.ReadIsolation := IsolationLevel::ReadCommitted;
        exit(BIAllowedTable.Get(PrincipalType, PrincipalId, TableNo));
    end;

    procedure GetAllowedTables(PrincipalType: Enum "NPR API BI Principal Type"; PrincipalId: Guid) AllowedTables: Dictionary of [Integer, Boolean]
    var
        BIAllowedTable: Record "NPR API BI Allowed Table";
    begin
        BIAllowedTable.ReadIsolation := IsolationLevel::ReadCommitted;
        BIAllowedTable.SetLoadFields("Table No.");
        BIAllowedTable.SetRange("Principal Type", PrincipalType);
        BIAllowedTable.SetRange("Principal Id", PrincipalId);
        if BIAllowedTable.FindSet() then
            repeat
                if not AllowedTables.ContainsKey(BIAllowedTable."Table No.") then
                    AllowedTables.Add(BIAllowedTable."Table No.", true);
            until BIAllowedTable.Next() = 0;
    end;

    /// <summary>
    /// The single rule for which tables the BI API can serve. The setup table applies it when a row
    /// is written and the endpoint applies it again per request, because a table that is supported
    /// today can later be removed or have its extension uninstalled, which leaves a stored row the
    /// endpoint has to refuse.
    /// </summary>
    procedure IsTableSupported(TableNo: Integer): Boolean
    var
        TableMetadata: Record "Table Metadata";
    begin
        if (TableNo <= 0) or (TableNo >= FirstSystemTableNo()) then
            exit(false);

        TableMetadata.ReadIsolation := IsolationLevel::ReadCommitted;
        TableMetadata.SetLoadFields(TableType, ObsoleteState);
        if not TableMetadata.Get(TableNo) then
            exit(false);
        if TableMetadata.TableType <> TableMetadata.TableType::Normal then
            exit(false);

        exit(TableMetadata.ObsoleteState <> TableMetadata.ObsoleteState::Removed);
    end;

    procedure TestTableSupported(TableNo: Integer)
    begin
        if not IsTableSupported(TableNo) then
            Error(TableNotSupportedErr, TableNo);
    end;

    procedure FirstSystemTableNo(): Integer
    begin
        exit(2000000000);
    end;

    /// <summary>
    /// The tables the access gate itself reads. A caller refreshes these before consulting the gate,
    /// otherwise a revoked table can keep answering from a server instance that still has the row
    /// cached, and a table that was just added keeps answering 403.
    /// </summary>
    procedure GateTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"NPR API BI Allowed Table");
        TableIds.Add(Database::"AAD Application");
    end;

    /// <summary>
    /// An allowlist row is a standing permission to bulk export a table. A copy or restore into a
    /// sandbox keeps the Entra ID applications enabled, so rows left behind would hand the sandbox a
    /// working export of the production data it was copied from. The API key metadata is wiped for
    /// the same reason in "NPR NP API Key Mgt.".
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearDatabaseConfig, '', false, false)]
    local procedure ClearAllowedTablesOnCopyToSandbox(SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        BIAllowedTable: Record "NPR API BI Allowed Table";
    begin
        if (DestinationEnv <> DestinationEnv::Sandbox) then
            exit;

        if (not BIAllowedTable.IsEmpty()) then
            BIAllowedTable.DeleteAll(false);
    end;
}
