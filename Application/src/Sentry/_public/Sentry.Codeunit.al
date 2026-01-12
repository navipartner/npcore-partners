codeunit 6248497 "NPR Sentry"
{
    /// <summary>
    /// A sentry transaction can be initialized at the start of each callstack and finished at the end.
    /// For example:
    /// - At the start/end of an API codeunit/page/query
    /// - At the start/end of a page action trigger
    /// - At the start/end a JQ codeunit.
    /// - At the start/end of a POS action
    /// - At the start/end of a background session
    /// - At the start/end of a page background task
    ///
    /// Each transaction consists of a tree of spans - each span represents a time interval in which an interesting event worth measuring happened..
    ///
    /// Each transaction can be linked to a parent session or outside system that triggered it in BC. (This will visualize the entire trace together in one view inside sentry.)
    /// </summary>

    Access = Public;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        SentryScope: Codeunit "NPR Sentry Scope"; // Is SingleInstance
#endif

    /// <summary>
    /// For PTE use, requires a customer specific DSN
    /// </summary>
    procedure InitScopeAndTransaction(Name: Text; Operation: Text; Dsn: Text; AppRelease: Text; ExternalTraceId: Text; ExternalSpanId: Text; ExternalSampled: Boolean)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.InitScopeAndTransaction(Name, Operation, Dsn, AppRelease, 0.0, ExternalTraceId, ExternalSpanId, ExternalSampled);
#endif
    end;

    /// <summary>
    /// For PTE use, requires a customer specific DSN
    /// </summary>
    procedure InitScopeAndTransaction(Name: Text; Operation: Text; Dsn: Text; AppRelease: Text; SamplingRate: Decimal)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.InitScopeAndTransaction(Name, Operation, Dsn, AppRelease, SamplingRate, '', '', false);
#endif
    end;

    /// <summary>
    /// For PTE use in APIs that receive a sentry-trace header. requires a customer specific DSN
    /// </summary>
    procedure InitScopeAndTransaction(Name: Text; Operation: Text; Dsn: Text; AppRelease: Text; SentryTraceHeader: Text)
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        ExternalId: Text;
        ExternalSpanId: Text;
        ExternalSampled: Boolean;
        SentryHttp: Codeunit "NPR Sentry Http";
    begin
        SentryHttp.TryParseSentryTraceHeader(SentryTraceHeader, ExternalId, ExternalSpanId, ExternalSampled);
        SentryScope.InitScopeAndTransaction(Name, Operation, Dsn, AppRelease, 0.0, ExternalId, ExternalSpanId, ExternalSampled);
    end;
#else
    begin
    end;
#endif

    /// <summary>
    /// For core use, goes to our core project in sentry with a centralized sample rate.
    /// </summary>
    internal procedure InitScopeAndTransaction(Name: Text; Operation: Text; ExternalTraceId: Text; ExternalSpanId: Text; ExternalSampled: Boolean)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.InitScopeAndTransaction(Name, Operation, ExternalTraceId, ExternalSpanId, ExternalSampled);
#endif
    end;

    /// <summary>
    /// For core use, goes to our core project in sentry with a centralized sample rate. With StartTime parameter to capture earlier processing.
    /// </summary>
    internal procedure InitScopeAndTransaction(Name: Text; Operation: Text; ExternalTraceId: Text; ExternalSpanId: Text; ExternalSampled: Boolean; StartTime: DateTime)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.InitScopeAndTransaction(Name, Operation, ExternalTraceId, ExternalSpanId, ExternalSampled, StartTime);
#endif
    end;

    /// <summary>
    /// For core use, goes to our core project in sentry with a centralized sample rate.
    /// </summary>
    internal procedure InitScopeAndTransaction(Name: Text; Operation: Text)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.InitScopeAndTransaction(Name, Operation, '', '', false);
#endif
    end;

    /// <summary>
    /// For core use, goes to our core project in sentry with a centralized sample rate. With StartTime parameter to capture earlier processing.
    /// </summary>
    internal procedure InitScopeAndTransaction(Name: Text; Operation: Text; StartTime: DateTime)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.InitScopeAndTransaction(Name, Operation, '', '', false, StartTime);
#endif
    end;

    /// <summary>
    /// For core use, goes to our core project in sentry with a centralized sample rate. With sentry-trace header.
    /// </summary>
    internal procedure InitScopeAndTransaction(Name: Text; Operation: Text; SentryTraceHeader: Text)
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        ExternalId: Text;
        ExternalSpanId: Text;
        ExternalSampled: Boolean;
        SentryHttp: Codeunit "NPR Sentry Http";
    begin
        SentryHttp.TryParseSentryTraceHeader(SentryTraceHeader, ExternalId, ExternalSpanId, ExternalSampled);
        SentryScope.InitScopeAndTransaction(Name, Operation, ExternalId, ExternalSpanId, ExternalSampled);
    end;
#else
    begin
    end;
#endif

    /// <summary>
    /// For core use, goes to our core project in sentry with a centralized sample rate. With sentry-trace header and StartTime parameter.
    /// </summary>
    internal procedure InitScopeAndTransaction(Name: Text; Operation: Text; SentryTraceHeader: Text; StartTime: DateTime)
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        ExternalId: Text;
        ExternalSpanId: Text;
        ExternalSampled: Boolean;
        SentryHttp: Codeunit "NPR Sentry Http";
    begin
        SentryHttp.TryParseSentryTraceHeader(SentryTraceHeader, ExternalId, ExternalSpanId, ExternalSampled);
        SentryScope.InitScopeAndTransaction(Name, Operation, ExternalId, ExternalSpanId, ExternalSampled, StartTime);
    end;
#else
    begin
    end;
#endif

    procedure FinalizeScope()
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.FinalizeScope();
#endif
    end;

    procedure StartSpan(var Span: Codeunit "NPR Sentry Span"; Description: Text)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        Span := SentryScope.StartSpan(Description);
#endif
    end;

    procedure AddLastErrorInEnglish()
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.AddLastErrorInEnglish();
#endif
    end;

    procedure AddLastErrorIfProgrammingBug()
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        SentryErrorHandling: Codeunit "NPR Sentry Error Handling";
    begin
        if SentryErrorHandling.IsLastErrorAProgrammingBug() then
            SentryScope.AddLastErrorInEnglish();
    end;
#else
    begin
    end;
#endif

    procedure AddError(ErrorText: Text)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.AddError(ErrorText, '');
#endif
    end;

    procedure AddError(ErrorText: Text; ErrorCallstack: Text)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.AddError(ErrorText, ErrorCallstack);
#endif
    end;


    procedure HttpInvoke(var Client: HttpClient; var Request: HttpRequestMessage; var Response: HttpResponseMessage)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.HttpInvoke(Client, Request, Response, false, false);
#else
        Client.Send(Request, Response);
#endif
    end;

    procedure HttpInvoke(var Client: HttpClient; var Request: HttpRequestMessage; var Response: HttpResponseMessage; HandleReturnValue: Boolean): Boolean
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.HttpInvoke(Client, Request, Response, HandleReturnValue, false));
#else
        if HandleReturnValue then
            exit(Client.Send(Request, Response))
        else begin
            Client.Send(Request, Response);
            exit(true);
        end;
#endif
    end;

    procedure HttpInvoke(var Client: HttpClient; var Request: HttpRequestMessage; var Response: HttpResponseMessage; HandleReturnValue: Boolean; PropagateSentryHeaders: Boolean): Boolean
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.HttpInvoke(Client, Request, Response, HandleReturnValue, PropagateSentryHeaders));
#else
        if HandleReturnValue then
            exit(Client.Send(Request, Response))
        else begin
            Client.Send(Request, Response);
            exit(true);
        end;
#endif
    end;

    procedure PageRunModal(PageId: Integer; Record: Variant): Action
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.PageRunModal(PageId, Record));
#else
        exit(Page.RunModal(PageId, Record));
#endif
    end;

    procedure PageRunModal(PageId: Integer): Action
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.PageRunModal(PageId));
#else
        exit(Page.RunModal(PageId));
#endif
    end;

    procedure Confirm(Message: Text; DefaultValue: Boolean): Boolean
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.Confirm(Message, DefaultValue));
#else
        exit(Dialog.Confirm(Message, DefaultValue));
#endif
    end;

    procedure StrMenu(OptionMembers: Text; DefaultNumber: Integer; Instruction: Text): Integer
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.StrMenu(OptionMembers, DefaultNumber, Instruction));
#else
        exit(Dialog.StrMenu(OptionMembers, DefaultNumber, Instruction));
#endif
    end;

    procedure FindSet(Record: Variant; ForUpdate: Boolean; HandleReturnValue: Boolean): Boolean
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    begin
        exit(SentryScope.RecordFindSet(Record, ForUpdate, HandleReturnValue));
    end;
#else
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        if HandleReturnValue then
            exit(RecRef.FindSet(ForUpdate))
        else begin
            RecRef.FindSet(ForUpdate);
            exit(true);
        end;
    end;
#endif

    procedure FindSet(Record: Variant)
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    begin
        SentryScope.RecordFindSet(Record, false, false);
    end;
#else
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        RecRef.FindSet(false);
    end;
#endif

    procedure Find(Record: Variant; Which: Text)
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    begin
        SentryScope.RecordFind(Record, Which, false);
    end;
#else
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        RecRef.Find(Which);
    end;
#endif

    procedure Find(Record: Variant; Which: Text; ForUpdate: Boolean; HandleReturnValue: Boolean): Boolean
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    begin
        exit(SentryScope.RecordFind(Record, Which, HandleReturnValue));

    end;
#else
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        if HandleReturnValue then
            exit(RecRef.Find(Which))
        else begin
            RecRef.Find(Which);
            exit(true);
        end;
    end;
#endif

    procedure Delete(Record: Variant; RunTrigger: Boolean)
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    begin
        SentryScope.RecordDelete(Record, RunTrigger, false);
    end;
#else
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        RecRef.Delete(RunTrigger);
    end;
#endif

    procedure Delete(Record: Variant; RunTrigger: Boolean; HandleReturnValue: Boolean) ReturnValue: Boolean
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    begin
        exit(SentryScope.RecordDelete(Record, RunTrigger, HandleReturnValue))
    end;
#else
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        if HandleReturnValue then
            exit(RecRef.Delete(RunTrigger))
        else begin
            RecRef.Delete(RunTrigger);
            exit(true);
        end;
    end;
#endif

    procedure DeleteAll(Record: Variant; RunTrigger: Boolean)
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    begin
        SentryScope.DeleteAll(Record, RunTrigger);
    end;
#else
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        RecRef.DeleteAll(RunTrigger);
    end;
#endif

    procedure Next(Record: Variant; Steps: Integer): Integer
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    begin
        exit(SentryScope.RecordNext(Record, Steps));
    end;
#else
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        exit(RecRef.Next(Steps));
    end;
#endif

    procedure Next(Record: Variant): Integer
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    begin
        exit(SentryScope.RecordNext(Record, 1));
    end;
#else
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        exit(RecRef.Next(1));
    end;
#endif

    procedure IsEmpty(Record: Variant): Boolean
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    begin
        exit(SentryScope.RecordIsEmpty(Record));
    end;
#else
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        exit(RecRef.IsEmpty());
    end;
#endif

    procedure CodeunitRun(Id: Integer; Record: Variant)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.CodeunitRun(Id, Record, false);
#else
        Codeunit.Run(Id, Record);
#endif
    end;

    procedure CodeunitRun(Id: Integer; Record: Variant; HandleReturnValue: Boolean): Boolean
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.CodeunitRun(Id, Record, HandleReturnValue));
#else
        if HandleReturnValue then
            exit(Codeunit.Run(Id, Record))
        else begin
            Codeunit.Run(Id, Record);
            exit(true);
        end;
#endif
    end;

    procedure ReportRun(ReportId: Integer; RequestWindow: Boolean; Record: Variant)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.ReportRun(ReportId, RequestWindow, Record);
#else
        Report.RunModal(ReportId, RequestWindow, false, Record);
#endif
    end;

    procedure ReportRun(ReportId: Integer)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SentryScope.ReportRun(ReportId, false);
#else
        Report.RunModal(ReportId, false);
#endif
    end;

    procedure GetCurrentTraceId(): Text
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.GetCurrentTraceId());
#else
        exit('');
#endif
    end;

    procedure GetCurrentSpanId(): Text
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.GetCurrentSpanId());
#else
        exit('');
#endif
    end;

    procedure IsCurrentTransactionSampled(): Boolean
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.IsCurrentTransactionSampled());
#else
        exit(false);
#endif
    end;

    procedure HasActiveTransaction(): Boolean
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(SentryScope.HasActiveTransaction());
#else
        exit(false);
#endif
    end;
}
