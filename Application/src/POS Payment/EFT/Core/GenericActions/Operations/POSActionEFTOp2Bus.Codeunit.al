codeunit 6059894 "NPR POS Action: EFT Op 2 Bus."
{
    Access = Internal;

    procedure StartBeginWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        Mechanism: Enum "NPR EFT Request Mechanism";
        IntegrationRequest: JsonObject;
        EntryNo: Integer;
        Workflow: Text;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EntryNo := EFTTransactionMgt.PrepareBeginWorkshift(EFTSetup, SalePOS, IntegrationRequest, Mechanism, Workflow);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        if Mechanism = Mechanism::Synchronous then begin
            WorkflowRequest.Add('synchronousRequest', true);
            EFTTransactionRequest.Get(EntryNo);
            WorkflowRequest.Add('synchronousSuccess', EFTTransactionRequest.Successful);
        end;
    end;

    procedure StartEndWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        Mechanism: Enum "NPR EFT Request Mechanism";
        IntegrationRequest: JsonObject;
        EntryNo: Integer;
        Workflow: Text;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EntryNo := EFTTransactionMgt.PrepareEndWorkshift(EFTSetup, SalePOS, IntegrationRequest, Mechanism, Workflow);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        if Mechanism = Mechanism::Synchronous then begin
            WorkflowRequest.Add('synchronousRequest', true);
            EFTTransactionRequest.Get(EntryNo);
            WorkflowRequest.Add('synchronousSuccess', EFTTransactionRequest.Successful);
        end;
    end;

    procedure VoidLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        Mechanism: Enum "NPR EFT Request Mechanism";
        EntryNo: Integer;
        IntegrationRequest: JsonObject;
        Workflow: Text;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, false);
        if not VoidConfirm(LastEFTTransactionRequest) then
            Error('');

        EntryNo := EFTTransactionMgt.PrepareVoid(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.", true, IntegrationRequest, Mechanism, Workflow);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        if Mechanism = Mechanism::Synchronous then begin
            WorkflowRequest.Add('synchronousRequest', true);
            EFTTransactionRequest.Get(EntryNo);
            WorkflowRequest.Add('synchronousSuccess', EFTTransactionRequest.Successful);
        end;
    end;

    procedure VoidList(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        EntryNo: Integer;
        Workflow: Text;
    begin
        if (not SelectTransaction(EFTTransactionRequest)) then
            exit;
        if not VoidConfirm(EFTTransactionRequest) then
            Error('');

        EntryNo := EFTTransactionMgt.PrepareVoid(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.", true, IntegrationRequest, Mechanism, Workflow);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        if Mechanism = Mechanism::Synchronous then begin
            WorkflowRequest.Add('synchronousRequest', true);
            EFTTransactionRequest.Get(EntryNo);
            WorkflowRequest.Add('synchronousSuccess', EFTTransactionRequest.Successful);
        end;
    end;

    procedure StartVerifySetup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        EntryNo: Integer;
        Workflow: Text;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EntryNo := EFTTransactionMgt.PrepareVerifySetup(EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", IntegrationRequest, Mechanism, Workflow);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        if Mechanism = Mechanism::Synchronous then begin
            WorkflowRequest.Add('synchronousRequest', true);
            EFTTransactionRequest.Get(EntryNo);
            WorkflowRequest.Add('synchronousSuccess', EFTTransactionRequest.Successful);
        end;
    end;

    procedure RefundList(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        IntegrationRequest: JsonObject;
        EntryNo: Integer;
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
    begin
        ApplyEftRefundListFilters(EFTTransactionRequest);
        if not SelectTransaction(EFTTransactionRequest) then
            exit;

        EntryNo := EFTTransactionMgt.PrepareReferencedRefund(EFTSetup, SalePOS, '', 0, EFTTransactionRequest."Entry No.", IntegrationRequest, Mechanism, Workflow);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        if Mechanism = Mechanism::Synchronous then begin
            WorkflowRequest.Add('synchronousRequest', true);
            EFTTransactionRequest.Get(EntryNo);
            WorkflowRequest.Add('synchronousSuccess', EFTTransactionRequest.Successful);
        end;
    end;

    procedure AuxOperation(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; AuxId: Integer; var WorkflowRequest: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        EntryNo: Integer;
        Workflow: Text;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EntryNo := EFTTransactionMgt.PrepareAuxOperation(EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", AuxId, IntegrationRequest, Mechanism, Workflow);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        if Mechanism = Mechanism::Synchronous then begin
            WorkflowRequest.Add('synchronousRequest', true);
            EFTTransactionRequest.Get(EntryNo);
            WorkflowRequest.Add('synchronousSuccess', EFTTransactionRequest.Successful);
        end;
    end;

    procedure ReprintLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale")
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, true);
        LastEFTTransactionRequest.PrintReceipts(true);
    end;

    procedure LookupLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, true);
        StartLookup(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.", WorkflowRequest);
    end;

    procedure LookupList(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if (not SelectTransaction(EFTTransactionRequest)) then
            exit;
        StartLookup(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.", WorkflowRequest);
    end;

    procedure StartLookup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; EntryNo: Integer; var WorkflowRequest: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
        LookupEntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        LookupEntryNo := EFTTransactionMgt.PrepareLookup(EFTSetup, SalePOS, EntryNo, IntegrationRequest, Mechanism, Workflow);
        EFTTransactionMgt.SendRequestIfSynchronous(LookupEntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        if Mechanism = Mechanism::Synchronous then begin
            WorkflowRequest.Add('synchronousRequest', true);
            EFTTransactionRequest.Get(EntryNo);
            WorkflowRequest.Add('synchronousSuccess', EFTTransactionRequest.Successful);
        end;
    end;

    procedure SelectTransaction(var EftTransactionRequestOut: Record "NPR EFT Transaction Request"): Boolean
    begin
        exit(PAGE.RunModal(0, EftTransactionRequestOut) = ACTION::LookupOK);
    end;

    procedure ShowTransactions(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetRange("Register No.", SalePOS."Register No.");
        EFTTransactionRequest.SetRange("Integration Type", EFTSetup."EFT Integration Type");
        EFTTransactionRequest.SetAscending("Entry No.", false);
        PAGE.Run(PAGE::"NPR EFT Transaction Requests", EFTTransactionRequest);
    end;

    procedure ApplyEftRefundListFilters(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        EFTTransactionRequest.SetRange(Reversed, false);
    end;

    procedure GetLastFinancialTransaction(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; IncludeVoidRequests: Boolean)
    begin
        EFTTransactionRequest.SetRange("Register No.", SalePOS."Register No.");
        EFTTransactionRequest.SetRange("Integration Type", EFTSetup."EFT Integration Type");
        if IncludeVoidRequests then begin
            EFTTransactionRequest.SetFilter("Processing Type", '%1|%2|%3|%4',
                EFTTransactionRequest."Processing Type"::PAYMENT,
                EFTTransactionRequest."Processing Type"::REFUND,
                EFTTransactionRequest."Processing Type"::VOID,
                EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD);
        end else begin
            EFTTransactionRequest.SetFilter("Processing Type", '%1|%2|%3',
                EFTTransactionRequest."Processing Type"::PAYMENT,
                EFTTransactionRequest."Processing Type"::REFUND,
                EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD);
        end;
        EFTTransactionRequest.FindLast();
    end;

    procedure VoidConfirm(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        RecoveredEFTTransactionRequest: Record "NPR EFT Transaction Request";
        CAPTION_VOID_CONFIRM: Label 'Void the following transaction?\\From Sales Ticket No.: %1\Type: %2\Amount: %3 %4\External Ref. No.: %5';
    begin
        if EFTTransactionRequest.Recovered then begin
            RecoveredEFTTransactionRequest.Get(EFTTransactionRequest."Recovered by Entry No.");
            exit(Confirm(CAPTION_VOID_CONFIRM, false, EFTTransactionRequest."Sales Ticket No.", Format(EFTTransactionRequest."Processing Type"), RecoveredEFTTransactionRequest."Result Amount", RecoveredEFTTransactionRequest."Currency Code", RecoveredEFTTransactionRequest."External Transaction ID"));
        end else
            exit(Confirm(CAPTION_VOID_CONFIRM, false, EFTTransactionRequest."Sales Ticket No.", Format(EFTTransactionRequest."Processing Type"), EFTTransactionRequest."Result Amount", EFTTransactionRequest."Currency Code", EFTTransactionRequest."External Transaction ID"));
    end;
}