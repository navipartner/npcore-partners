/// <summary>
/// Generic BI endpoints. /bi/:tableNo reads the records of any table that the calling API key or
/// Entra ID application has been allowed to read, and /tablemetadata describes what can be read.
/// Nothing here is table specific: the fields come from the table metadata and the records from the
/// shared RecordRef reader on "NPR API Request", so pagination and sync behave exactly as on every
/// other endpoint of the module.
/// </summary>
codeunit 6151563 "NPR API BI" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        // API error texts are machine readable English, like every other message of this module.
        TableNoNotNumericErr: Label 'The table number "%1" is not a number.', Comment = '%1 = the path segment that was received', Locked = true;
        TableResourceLbl: Label 'Table %1', Comment = '%1 = table number', Locked = true;
        PrincipalNotResolvedErr: Label 'The request user %1 is not an Entra ID application registered in Business Central, so no BI API table allowlist can be applied.', Comment = '%1 = user security id', Locked = true;
        TableNotAllowedErr: Label 'Table %1 (%2) is not allowed for this API key or Entra ID application. Add it in the BI API Allowed Tables setup in Business Central.', Comment = '%1 = table number, %2 = table name', Locked = true;
        MissingRowVersionIndexErr: Label 'Table %1 (%2) cannot be read through the BI API yet, because it has no index that starts with SystemRowVersion. Every read is incremental and needs that index to order and resume by. A table extension has to add: key("NPR API Sync"; SystemRowVersion) { }', Comment = '%1 = table number, %2 = table name', Locked = true;
        NotABooleanErr: Label 'The query parameter %1 has to be true or false, but it was "%2".', Comment = '%1 = parameter name, %2 = the value received', Locked = true;
        NotANumberErr: Label 'The query parameter %1 has to be a number, but it was "%2".', Comment = '%1 = parameter name, %2 = the value received', Locked = true;
        SyncCannotBeDisabledErr: Label 'Reads from this endpoint are always incremental, so sync cannot be turned off. Remove the sync parameter.', Locked = true;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        case true of
            Request.Match('GET', '/bi/:tableNo'):
                exit(GetTableData(Request));
            Request.Match('GET', '/tablemetadata'):
                exit(GetTableList(Request));
            Request.Match('GET', '/tablemetadata/:tableNo'):
                exit(GetTableMetadata(Request));
        end;
    end;

    local procedure GetTableData(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        BIAccess: Codeunit "NPR API BI Access";
        BIMetadata: Codeunit "NPR API BI Metadata";
        Sentry: Codeunit "NPR Sentry";
        PrincipalType: Enum "NPR API BI Principal Type";
        PrincipalId: Guid;
        RecRef: RecordRef;
        Fields: Dictionary of [Integer, Text];
        TableIds: List of [Integer];
        TableName: Text;
        TableNo: Integer;
    begin
        if not TryGetTableNo(Request, TableNo, Response) then
            exit(Response);

        Sentry.AddTransactionTag('bc.bi.table', Format(TableNo));

        if not TryValidateQuery(Request, Response) then
            exit(Response);

        // Refreshed before the gate is consulted, not after. The gate reads the allowlist and the
        // Entra applications, so reading those from a stale server cache would keep serving a table
        // an administrator has just revoked, and keep refusing one they have just added.
        TableIds := BIAccess.GateTableIds();
        TableIds.Add(TableNo);
        Request.SkipCacheIfNonStickyRequest(TableIds);

        if not BIAccess.ResolvePrincipal(PrincipalType, PrincipalId) then
            exit(Response.CreateErrorResponse(
                "NPR API Error Code"::bi_principal_not_resolved,
                StrSubstNo(PrincipalNotResolvedErr, UserSecurityId()),
                "NPR API HTTP Status Code"::Forbidden));

        RecRef.Open(TableNo);
        TableName := RecRef.Name();

        if not BIAccess.IsTableAllowed(PrincipalType, PrincipalId, TableNo) then begin
            RecRef.Close();
            exit(Response.CreateErrorResponse(
                "NPR API Error Code"::bi_table_not_allowed,
                StrSubstNo(TableNotAllowedErr, TableNo, TableName),
                "NPR API HTTP Status Code"::Forbidden));
        end;

        // Every read is incremental, so the index is a precondition of the endpoint rather than of a
        // mode within it. Checked up front so a table that was never prepared for it gets a clear 400
        // instead of the shared reader raising a programming bug error and the consumer seeing a 500.
        if not Request.HasRowVersionKey(RecRef) then begin
            RecRef.Close();
            exit(Response.RespondBadRequest(
                "NPR API Error Code"::bi_missing_rowversion_index,
                StrSubstNo(MissingRowVersionIndexErr, TableNo, TableName)));
        end;
        RecRef.Close();

        BIMetadata.BuildFieldMap(TableNo, Fields);
        exit(Response.RespondOK(Request.GetDataInRowVersionOrder(TableNo, Fields, DefaultPageSize())));
    end;

    local procedure GetTableList(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        BIAccess: Codeunit "NPR API BI Access";
        BIMetadata: Codeunit "NPR API BI Metadata";
    begin
        Request.SkipCacheIfNonStickyRequest(BIAccess.GateTableIds());
        exit(Response.RespondOK(BIMetadata.GetTableListJson(Request)));
    end;

    local procedure GetTableMetadata(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        BIAccess: Codeunit "NPR API BI Access";
        BIMetadata: Codeunit "NPR API BI Metadata";
        TableNo: Integer;
    begin
        if not TryGetTableNo(Request, TableNo, Response) then
            exit(Response);

        Request.SkipCacheIfNonStickyRequest(BIAccess.GateTableIds());
        exit(Response.RespondOK(BIMetadata.GetTableJson(Request, TableNo)));
    end;

    /// <summary>
    /// Reads and validates the table number, which is the second path segment of both /bi/:tableNo
    /// and /tablemetadata/:tableNo. On failure the response to return is handed back to the caller.
    /// </summary>
    local procedure TryGetTableNo(var Request: Codeunit "NPR API Request"; var TableNo: Integer; var Response: Codeunit "NPR API Response"): Boolean
    var
        BIAccess: Codeunit "NPR API BI Access";
        Segment: Text;
    begin
        Segment := Request.Paths().Get(2);
        if not Evaluate(TableNo, Segment) then begin
            Response := Response.RespondBadRequest("NPR API Error Code"::invalid_input, StrSubstNo(TableNoNotNumericErr, Segment));
            exit(false);
        end;

        if not BIAccess.IsTableSupported(TableNo) then begin
            Response := Response.RespondResourceNotFound(StrSubstNo(TableResourceLbl, TableNo));
            exit(false);
        end;

        exit(true);
    end;

    /// <summary>
    /// Checks the query values this endpoint hands to the shared reader. The reader parses them with
    /// a bare Evaluate, which raises, so an unparseable value would otherwise leave the consumer with
    /// a 500 and no error code for what is a mistake in their own request.
    /// </summary>
    local procedure TryValidateQuery(var Request: Codeunit "NPR API Request"; var Response: Codeunit "NPR API Response"): Boolean
    var
        QueryParams: Dictionary of [Text, Text];
        Value: Text;
        BooleanValue: Boolean;
        IntegerValue: Integer;
        BigIntegerValue: BigInteger;
    begin
        QueryParams := Request.QueryParams();

        if QueryParams.Get('sync', Value) then begin
            if not Evaluate(BooleanValue, Value) then begin
                Response := Response.RespondBadRequest("NPR API Error Code"::invalid_input, StrSubstNo(NotABooleanErr, 'sync', Value));
                exit(false);
            end;
            // sync=true is accepted as a no-op for anyone who sent it before it became implicit.
            if not BooleanValue then begin
                Response := Response.RespondBadRequest("NPR API Error Code"::invalid_input, SyncCannotBeDisabledErr);
                exit(false);
            end;
        end;

        if QueryParams.Get('pageSize', Value) then
            if not Evaluate(IntegerValue, Value) then begin
                Response := Response.RespondBadRequest("NPR API Error Code"::invalid_input, StrSubstNo(NotANumberErr, 'pageSize', Value));
                exit(false);
            end;

        if QueryParams.Get('lastRowVersion', Value) then
            if not Evaluate(BigIntegerValue, Value) then begin
                Response := Response.RespondBadRequest("NPR API Error Code"::invalid_input, StrSubstNo(NotANumberErr, 'lastRowVersion', Value));
                exit(false);
            end;

        exit(true);
    end;

    /// <summary>
    /// Smaller than the module maximum on purpose: a BI record carries every field of its table, and
    /// wide tables such as Item have several hundred. A consumer that wants bigger pages can still
    /// ask for them with pageSize.
    /// </summary>
    local procedure DefaultPageSize(): Integer
    begin
        exit(1000);
    end;
}
