#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6150994 "NPR Sentry Scope"
{
    Access = Internal;
    SingleInstance = true;

    var
        _spans: List of [Codeunit "NPR Sentry Span"];
        _errors: List of [Codeunit "NPR Sentry Error"];
        _transaction: Codeunit "NPR Sentry Transaction";
        _activeSpanId: Text;

    procedure InitScopeAndTransaction(Name: Text; Operation: Text; Dsn: Text; AppRelease: Text; SamplingRate: Decimal; ExternalTraceId: Text; ExternalSpanId: Text; ExternalSampled: Boolean)
    begin
        InitScopeAndTransaction(Name, Operation, Dsn, AppRelease, SamplingRate, ExternalTraceId, ExternalSpanId, ExternalSampled, CurrentDateTime());
    end;

    procedure InitScopeAndTransaction(Name: Text; Operation: Text; Dsn: Text; AppRelease: Text; SamplingRate: Decimal; ExternalTraceId: Text; ExternalSpanId: Text; ExternalSampled: Boolean; StartTime: DateTime)
    var
        sample: Boolean;
    begin
        if HasActiveTransaction() then
            FinalizeScope();

        ResetState();

        if ExternalTraceId <> '' then begin
            sample := ExternalSampled;
        end else begin
            if SamplingRate = 1.0 then begin
                sample := true;
            end else if (SamplingRate > 0.0) and (SamplingRate < 1.0) then begin
                if Random(1000) < (SamplingRate * 1000) then begin
                    sample := true;
                end;
            end;
        end;

        _transaction.Create(Name, Operation, Dsn, AppRelease, ExternalTraceId, ExternalSpanId, sample, StartTime);
        _activeSpanId := _transaction.GetRootSpanId();
    end;


    internal procedure InitScopeAndTransaction(Name: Text; Operation: Text; ExternalTraceId: Text; ExternalSpanId: Text; ExternalSampled: Boolean)
    begin
        InitScopeAndTransaction(Name, Operation, ExternalTraceId, ExternalSpanId, ExternalSampled, CurrentDateTime());
    end;

    internal procedure InitScopeAndTransaction(Name: Text; Operation: Text; ExternalTraceId: Text; ExternalSpanId: Text; ExternalSampled: Boolean; StartTime: DateTime)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        DefaultDsn: Text;
        ModuleInfo: ModuleInfo;
        ReleaseVersion: Text;
    begin
        if HasActiveTransaction() then
            FinalizeScope();

        ResetState();

        NavApp.GetCurrentModuleInfo(ModuleInfo);
        if (ModuleInfo.AppVersion.Major < 9999) then begin
            ReleaseVersion := StrSubstNo('npretail@%1', ModuleInfo.AppVersion);
        end else begin
            ReleaseVersion := 'npretail@dev';
        end;

        if AzureKeyVaultMgt.TryGetAzureKeyVaultSecret('SentryIONpCore', DefaultDsn) then;

        InitScopeAndTransaction(Name, Operation, DefaultDsn, ReleaseVersion, 1.0, ExternalTraceId, ExternalSpanId, ExternalSampled, StartTime);
    end;

    local procedure ResetState()
    begin
        ClearAll();
        clear(_spans);
        clear(_errors);
        clear(_transaction);
        clear(_activeSpanId);
    end;

    internal procedure SetActiveSpanId(Id: Text)
    begin
        _activeSpanId := Id;
    end;

    #region Child Span Constructors
    internal procedure StartSpan(Description: Text): Codeunit "NPR Sentry Span"
    var
        Span: Codeunit "NPR Sentry Span";
        Operation: Text;
    begin
        Operation := StrSubstNo('function.bc:%1', Description.ToLower());
        Operation := DelChr(Operation, '=', '\/{}[]()|!@#$%^&*_§±=;');
        Operation := Operation.Replace(' ', '_');

        Span.Create(_activeSpanId, Description, Operation);
        _spans.Add(Span);
        exit(Span);
    end;

    procedure HttpInvoke(var Client: HttpClient; var Request: HttpRequestMessage; var Response: HttpResponseMessage; HandleReturnValue: Boolean; PropagateSentryHeaders: Boolean): Boolean
    var
        Success: Boolean;
        SentryHttpHeader: Codeunit "NPR Sentry Http";
        HttpHeaders: HttpHeaders;
        Span: Codeunit "NPR Sentry Span";
        RequestUri: Text;
    begin
        Span.Create(_activeSpanId, StrSubstNo('HTTP %1 %2', Request.Method, Request.GetRequestUri), 'http.client');
        _spans.Add(Span);

        if PropagateSentryHeaders then begin
            Request.GetHeaders(HttpHeaders);
            SentryHttpHeader.AddSentryTraceHeader(HttpHeaders, _transaction.GetTraceId(), _activeSpanId, _transaction.GetSampled());
        end;
        RequestUri := Request.GetRequestUri;
        if HandleReturnValue then
            Success := Client.Send(Request, Response)
        else begin
            Client.Send(Request, Response);
            Success := true;
        end;
        Request.SetRequestUri(RequestUri);   //Reset Uri to original value. overwrite the change made by client.Send

        Span.SetMetadata(Client, Request, Response, Success);
        Span.Finish();

        exit(Success);
    end;

    procedure ReportRun(ReportId: Integer; RequestWindow: Boolean; Rec: Variant);
    var
        ReportMetadata: Record "Report Metadata";
        Span: Codeunit "NPR Sentry Span";
    begin
        ReportMetadata.Get(ReportId);
        Span.Create(_activeSpanId, StrSubstNo('BC Report: %1', ReportMetadata.Name), StrSubstNo('function.bc.report:%1', ReportId));
        _spans.Add(Span);

        Report.RunModal(ReportId, RequestWindow, false, Rec);

        Span.Finish();
    end;

    procedure ReportRun(ReportId: Integer; RequestWindow: Boolean);
    var
        ReportMetadata: Record "Report Metadata";
        Span: Codeunit "NPR Sentry Span";
    begin
        ReportMetadata.Get(ReportId);
        Span.Create(_activeSpanId, StrSubstNo('BC Report: %1', ReportMetadata.Name), StrSubstNo('function.bc.report:%1', ReportId));
        _spans.Add(Span);

        Report.RunModal(ReportId, RequestWindow);

        Span.Finish();
    end;

    procedure PageRunModal(PageId: Integer; Rec: Variant): Action
    var
        PageAction: Action;
        PageMetadata: Record "Page Metadata";
        TableMetadata: Record "Table Metadata";
        TypeHelper: Codeunit "Type Helper";
        RecRef: RecordRef;
        Span: Codeunit "NPR Sentry Span";
    begin
        if PageId = 0 then begin
            TypeHelper.CopyRecVariantToRecRef(Rec, RecRef);
            TableMetadata.Get(RecRef.Number);
            PageMetadata.Get(TableMetadata.LookupPageID);
        end else begin
            PageMetadata.Get(PageId);
        end;

        Span.Create(_activeSpanId, StrSubstNo('BC Page: %1', PageMetadata.Name), StrSubstNo('ui.bc.page:%1', PageId));
        _spans.Add(Span);

        PageAction := Page.RunModal(PageId, Rec);

        if PageAction in [Action::OK, Action::LookupOK, Action::Yes] then
            Span.SetStatus("NPR Sentry Span Status"::Ok)
        else if PageAction in [Action::Cancel, Action::No, Action::LookupCancel] then
            Span.SetStatus("NPR Sentry Span Status"::Cancelled)
        else
            Span.SetStatus("NPR Sentry Span Status"::Ok);

        Span.Finish();

        exit(PageAction);
    end;

    procedure PageRunModal(PageId: Integer): Action
    var
        PageAction: Action;
        PageMetadata: Record "Page Metadata";
        Span: Codeunit "NPR Sentry Span";
    begin
        if PageId = 0 then
            exit;

        PageMetadata.Get(PageId);

        Span.Create(_activeSpanId, StrSubstNo('BC Page: %1', PageMetadata.Name), StrSubstNo('ui.bc.page:%1', PageId));
        _spans.Add(Span);

        PageAction := Page.RunModal(PageId);

        if PageAction in [Action::OK, Action::LookupOK, Action::Yes] then
            Span.SetStatus("NPR Sentry Span Status"::Ok)
        else if PageAction in [Action::Cancel, Action::No, Action::LookupCancel] then
            Span.SetStatus("NPR Sentry Span Status"::Cancelled)
        else
            Span.SetStatus("NPR Sentry Span Status"::Ok);

        Span.Finish();

        exit(PageAction);
    end;

    procedure RecordFindSet(Record: Variant; ForUpdate: Boolean; HandleReturnValue: Boolean): Boolean
    var
        Result: Boolean;
        DbQuery: Text;
        Span: Codeunit "NPR Sentry Span";
        RowsReadBefore: Integer;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        DbQuery := FormatDbQuery(RecRef, StrSubstNo('FindSet(%1)', Format(ForUpdate, 0, 9)));

        Span.Create(_activeSpanId, DbQuery, StrSubstNo('db.query:%1', RecRef.Number));
        _spans.Add(Span);

        RowsReadBefore := SessionInformation.SqlRowsRead;

        if HandleReturnValue then
            Result := RecRef.FindSet(ForUpdate)
        else begin
            RecRef.FindSet(ForUpdate);
            Result := true;
        end;

        Span.SetMetadata(StrSubstNo('FindSet(%1)', Format(ForUpdate, 0, 9)), RecRef, SessionInformation.SqlRowsRead - rowsReadBefore, Result);
        Span.Finish();

        exit(Result);
    end;

    procedure RecordFind(Record: Variant; Which: Text; HandleReturnValue: Boolean): Boolean
    var
        Result: Boolean;
        DbQuery: Text;
        Span: Codeunit "NPR Sentry Span";
        RowsReadBefore: Integer;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        DbQuery := FormatDbQuery(RecRef, StrSubstNo('Find(%1)', Which));

        Span.Create(_activeSpanId, DbQuery, StrSubstNo('db.query:%1', RecRef.Number));
        _spans.Add(Span);

        RowsReadBefore := SessionInformation.SqlRowsRead;

        if HandleReturnValue then
            Result := RecRef.Find(Which)
        else begin
            RecRef.Find(Which);
            Result := true;
        end;

        Span.SetMetadata(StrSubstNo('Find(%1)', Which), RecRef, SessionInformation.SqlRowsRead - RowsReadBefore, Result);
        Span.Finish();

        exit(Result);
    end;

    procedure RecordDelete(Record: Variant; RunTrigger: Boolean; HandleReturnValue: Boolean): Boolean
    var
        DbQuery: Text;
        Span: Codeunit "NPR Sentry Span";
        Result: Boolean;
        RowsReadBefore: Integer;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        DbQuery := FormatDbQuery(RecRef, StrSubstNo('Delete(%1)', Format(RunTrigger, 0, 9)));

        Span.Create(_activeSpanId, DbQuery, StrSubstNo('db.query:%1', RecRef.Number));
        _spans.Add(Span);

        RowsReadBefore := SessionInformation.SqlRowsRead;

        if HandleReturnValue then
            Result := RecRef.Delete(RunTrigger)
        else begin
            RecRef.Delete(RunTrigger);
            Result := true;
        end;

        Span.SetMetadata(StrSubstNo('Delete(%1)', Format(RunTrigger, 0, 9)), RecRef, SessionInformation.SqlRowsRead - RowsReadBefore, Result);
        Span.Finish();
        exit(Result);
    end;

    procedure RecordIsEmpty(Record: Variant): Boolean
    var
        Result: Boolean;
        DbQuery: Text;
        Span: Codeunit "NPR Sentry Span";
        RowsReadBefore: Integer;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        DbQuery := FormatDbQuery(RecRef, 'IsEmpty');

        Span.Create(_activeSpanId, DbQuery, StrSubstNo('db.query:%1', RecRef.Number));
        _spans.Add(Span);

        RowsReadBefore := SessionInformation.SqlRowsRead;
        Result := RecRef.IsEmpty();

        Span.SetMetadata('IsEmpty', RecRef, SessionInformation.SqlRowsRead - RowsReadBefore, Result);
        Span.Finish();

        exit(Result);
    end;

    procedure RecordNext(Record: Variant; Steps: Integer): Integer
    var
        Result: Integer;
        DbQuery: Text;
        Span: Codeunit "NPR Sentry Span";
        RowsReadBefore: Integer;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        DbQuery := FormatDbQuery(RecRef, StrSubstNo('Next(%1)', Steps));

        Span.Create(_activeSpanId, DbQuery, StrSubstNo('db.query:%1', RecRef.Number));
        _spans.Add(Span);

        RowsReadBefore := SessionInformation.SqlRowsRead;
        Result := RecRef.Next(Steps);

        Span.SetMetadata(StrSubstNo('Next(%1)', Steps), RecRef, SessionInformation.SqlRowsRead - RowsReadBefore, Result <> 0);
        Span.Finish();

        exit(Result);
    end;

    internal procedure DeleteAll(Record: Variant; RunTrigger: Boolean)
    var
        DbQuery: Text;
        Span: Codeunit "NPR Sentry Span";
        RowsReadBefore: Integer;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        DbQuery := FormatDbQuery(RecRef, StrSubstNo('DeleteAll(%1)', Format(RunTrigger, 0, 9)));

        Span.Create(_activeSpanId, DbQuery, StrSubstNo('db.query:%1', RecRef.Number));
        _spans.Add(Span);

        RowsReadBefore := SessionInformation.SqlRowsRead;

        RecRef.DeleteAll(RunTrigger);

        Span.SetMetadata(StrSubstNo('DeleteAll(%1)', Format(RunTrigger, 0, 9)), RecRef, SessionInformation.SqlRowsRead - RowsReadBefore, true);
        Span.Finish();
    end;

    internal procedure CodeunitRun(Id: Integer; var RecVariant: Variant; HandleReturnValue: Boolean): Boolean
    var
        Span: Codeunit "NPR Sentry Span";
        Result: Boolean;
        CodeUnitMetadata: Record "CodeUnit Metadata";
    begin
        if Id = 0 then
            Error('Missing id for codeunit to run');

        CodeUnitMetadata.Get(Id);

        Span.Create(_activeSpanId, StrSubstNo('BC Codeunit: %1', CodeUnitMetadata.Name), StrSubstNo('function.bc.codeunit:%1', Id));
        _spans.Add(Span);

        if HandleReturnValue then
            Result := CodeUnit.Run(Id, RecVariant)
        else begin
            CodeUnit.Run(Id, RecVariant);
            Result := true;
        end;

        Span.SetStatusFromResult(Result);
        Span.Finish();
        exit(Result);
    end;

    internal procedure Confirm(Message: Text; DefaultValue: Boolean): Boolean
    var
        Span: Codeunit "NPR Sentry Span";
        Result: Boolean;
    begin
        Span.Create(_activeSpanId, StrSubstNo('BC Confirm: %1', Message), 'ui.bc.confirm');
        _spans.Add(Span);

        Result := Dialog.Confirm(Message, DefaultValue);

        if Result then
            Span.SetStatus("NPR Sentry Span Status"::Ok)
        else
            Span.SetStatus("NPR Sentry Span Status"::Cancelled);

        Span.Finish();
        exit(Result);
    end;


    internal procedure StrMenu(OptionMembers: Text; DefaultNumber: Integer; Instruction: Text): Integer
    var
        Span: Codeunit "NPR Sentry Span";
        Result: Integer;
    begin
        Span.Create(_activeSpanId, StrSubstNo('BC StrMenu: %1', Instruction), 'ui.bc.strmenu');
        _spans.Add(Span);

        Result := Dialog.StrMenu(OptionMembers, DefaultNumber, Instruction);

        if Result > 0 then
            Span.SetStatus("NPR Sentry Span Status"::Ok)
        else
            Span.SetStatus("NPR Sentry Span Status"::Cancelled);

        Span.Finish();
        exit(Result);
    end;
    #endregion

    internal procedure AddError(ErrorText: Text; ErrorCallstack: Text)
    var
        SentryError: Codeunit "NPR Sentry Error";
    begin
        SentryError.Create(_activeSpanId, ErrorText, ErrorCallstack, _transaction.GetTraceId(), _transaction.GetRelease());
        _errors.Add(SentryError);
        SetActiveSpanStatus("NPR Sentry Span Status"::InternalError);
    end;

    local procedure SetActiveSpanStatus(Status: Enum "NPR Sentry Span Status")
    var
        Span: Codeunit "NPR Sentry Span";
        i: Integer;
    begin
        for i := 1 to _spans.Count do begin
            Span := _spans.Get(i);
            if Span.GetId() = _activeSpanId then begin
                Span.SetStatus(Status);
                _spans.Set(i, Span);
                exit;
            end;
        end;
    end;

    internal procedure AddLastErrorInEnglish()
    var
        PreviousLanguageId: Integer;
        ErrorCallstack: Text;
        ErrorText: Text;
    begin
        PreviousLanguageId := GlobalLanguage();
        GlobalLanguage(1033); //english
        ErrorText := GetLastErrorText();
        ErrorCallstack := GetLastErrorCallStack();
        GlobalLanguage(PreviousLanguageId);

        AddError(ErrorText, ErrorCallstack)
    end;

    local procedure FormatDbQuery(RecRef: RecordRef; Operation: Text): Text
    var
        DbQuery: Text;
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        DbQuery := StrSubstNo('%1, %2, %3', Operation, RecRef.Name, RecRef.ReadIsolation());
#else
        DbQuery := StrSubstNo('%1 %2', Operation, RecRef.Name);
#endif

        Exit(DbQuery);
    end;

    internal procedure FinalizeScope()
    begin
        if _activeSpanId = '' then
            exit;
        if _transaction.GetRootSpanId() = '' then
            exit;

        _transaction.Finish();

        if (not _transaction.GetSampled()) and (_errors.Count = 0) then
            exit;

        _transaction.Log(_spans, _errors);

        ResetState();
    end;

    procedure GetCurrentTraceId(): Text
    begin
        exit(_transaction.GetTraceId())
    end;

    procedure GetCurrentSpanId(): Text
    begin
        exit(_activeSpanId);
    end;

    procedure IsCurrentTransactionSampled(): Boolean
    begin
        exit(_transaction.GetSampled());
    end;

    procedure HasActiveTransaction(): Boolean
    begin
        exit((_activeSpanId <> '') and _transaction.IsActive());
    end;


}
#endif