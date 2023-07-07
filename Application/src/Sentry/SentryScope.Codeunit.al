codeunit 6150994 "NPR Sentry Scope"
{
    // New scope with active transaction is automatically created for all inbound POS action events.

    Access = Internal;
    SingleInstance = true;

    var
        _activeTransaction: Codeunit "NPR Sentry Transaction";
        _activeSpan: Codeunit "NPR Sentry Span";
        _initialized: Boolean;
        _spanSet: Boolean;

    procedure InitScopeAndTransaction(Name: Text; Operation: Text; Dsn: Text; ExternalTraceId: Text; ExternalSpanId: Text; var TransactionOut: Codeunit "NPR Sentry Transaction")
    begin
        Clear(_activeTransaction);
        _activeTransaction.Start(Name, Operation, Dsn, ExternalTraceId, ExternalSpanId);
        TransactionOut := _activeTransaction;
        _initialized := true;
    end;


    procedure InitScopeAndTransaction(Name: Text; Operation: Text; ExternalTraceId: Text; ExternalSpanId: Text; var TransactionOut: Codeunit "NPR Sentry Transaction")
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        DefaultDsn: Text;
    begin
        if not AzureKeyVaultMgt.TryGetAzureKeyVaultSecret('SentryIONpCorePointOfSale', DefaultDsn) then
            exit;
        InitScopeAndTransaction(Name, Operation, DefaultDsn, ExternalTraceId, ExternalSpanId, TransactionOut);
    end;

    procedure SetActiveSpan(var SentrySpan: Codeunit "NPR Sentry Span")
    begin
        if not _initialized then
            exit;

        _activeSpan := SentrySpan;
        _spanSet := true;
    end;

    /// <summary>
    /// Use as global storage of a span reference, to avoid carrying it around between function calls manually.
    /// </summary>
    /// <param name="SentrySpanOut"></param>
    /// <returns>whether or not a span was retrieved</returns>
    procedure TryGetActiveSpan(var SentrySpanOut: Codeunit "NPR Sentry Span"): Boolean
    begin
        if not _initialized then
            exit(false);
        if not _spanSet then
            exit(false);

        SentrySpanOut := _activeSpan;
        exit(true);
    end;

    procedure TryGetActiveTransaction(var ActiveTransactionOut: Codeunit "NPR Sentry Transaction"): Boolean
    begin
        if not _initialized then
            exit(false);

        ActiveTransactionOut := _activeTransaction;
        exit(true);
    end;

    procedure ClearScope()
    begin
        Clear(_activeTransaction);
        Clear(_initialized);
    end;
}