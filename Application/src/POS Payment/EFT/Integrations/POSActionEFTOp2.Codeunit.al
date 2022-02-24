codeunit 6059799 "NPR POS Action: EFT Op 2" implements "NPR IPOS Workflow"
{

    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action is the starting point for EFT aux operations.';
        EftTypeName: Label 'EFT Type';
        EftTypeDesc: Label 'The EFT integration performing the operation';
        PaymentTypeName: Label 'Payment Method';
        PaymentTypeDesc: Label 'The payment method that links to EFT integration in EFT setup';
        OperationTypeOptions: Label 'VoidLast,ReprintLast,LookupLast,OpenConn,CloseConn,VerifySetup,ShowTransactions,AuxOperation,LookupSpecific,VoidSpecific,RefundSpecific,LookupList,VoidList,RefundList', Locked = true;
        OperationTypeOptionNames: Label 'Void Last,Reprint Last,Lookup Last,Open Terminal,Close Terminal,Verify Setup,Show Transactions,Auxiliary Operation,Lookup Specific,Void Specific,Refund Specific,Lookup List,Void List,Refund List';
        OperationTypeName: Label 'Operation Type';
        OperationTypeDesc: Label 'Determines which EFT operation to perform.';
        AuxIdName: Label 'Auxiliary Id';
        AuxIdDesc: Label 'Determines which auxiliary operation to perform. All terminals do not support all operations.';
        ShowSpinnerName: Label 'Show Spinner';
        ShowSpinnerDesc: Label 'Determines whether there is a UI shown while operation is performed.';
        ShowSuccessMessageName: Label 'Show Success Message';
        ShowSuccessMessageDesc: Label 'Determines whether there is message to confirm when the operation is deemed successful.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('EftType', '', EftTypeName, EftTypeDesc);
        WorkflowConfig.AddTextParameter('PaymentType', '', PaymentTypeName, PaymentTypeDesc);
        WorkflowConfig.AddOptionParameter('OperationType', OperationTypeOptions, 'ShowTransactions', OperationTypeName, OperationTypeDesc, OperationTypeOptionNames);
        WorkflowConfig.AddIntegerParameter('AuxId', 0, AuxIdName, AuxIdDesc);
        WorkflowConfig.AddBooleanParameter('ShowSpinner', false, ShowSpinnerName, ShowSpinnerDesc);
        WorkflowConfig.AddBooleanParameter('ShowSuccessMessage', true, ShowSuccessMessageName, ShowSuccessMessageDesc);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'prepareRequest':
                Frontend.WorkflowResponse(PrepareRequest(Context, Sale));
            'doLegacyPaymentWorkflow':
                Frontend.WorkflowResponse(DoLegacyEftOperation(Context, FrontEnd));
        end;
    end;


    local procedure PrepareRequest(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale") EftRequest: JsonObject
    var
        EFTSetup: Record "NPR EFT Setup";
        SalePOS: Record "NPR POS Sale";
        OperationType: Option VoidLast,ReprintLast,LookupLast,OpenConn,CloseConn,VerifySetup,ShowTransactions,AuxOperation,LookupSpecific,VoidSpecific,RefundSpecific,LookupList,VoidList,RefundList;
        EftType: Text;
        PaymentType: Text;
        ERROR_MISSING_PARAM: Label 'Parameter %1 is missing';
    begin
        POSSale.GetCurrentSale(SalePOS);

        OperationType := Context.GetIntegerParameter('OperationType');
        EftType := Context.GetStringParameter('EftType');
        PaymentType := Context.GetStringParameter('PaymentType');

        if PaymentType = '' then
            Error(ERROR_MISSING_PARAM, 'PaymentType');
        EFTSetup.FindSetup(SalePOS."Register No.", CopyStr(PaymentType, 1, MaxStrLen(EFTSetup."Payment Type POS")));

        EftRequest.ReadFrom('{}');
        EftRequest.Add('version', Format(EFTSetup.Integration + 1, 0, 9)); // options are zero based
        EftRequest.Add('showSpinner', Context.GetBooleanParameter('ShowSpinner'));
        EftRequest.Add('showSuccessMessage', Context.GetBooleanParameter('ShowSuccessMessage'));

        if (EFTSetup.Integration = EFTSetup.Integration::SG) then
            exit; // legacy

        case OperationType of
            OperationType::VerifySetup:
                StartVerifySetup(EFTSetup, SalePOS, EftRequest);

            OperationType::OpenConn:
                StartBeginWorkshift(EFTSetup, SalePOS, EftRequest);
            OperationType::CloseConn:
                StartEndWorkshift(EFTSetup, SalePOS, EftRequest);

            OperationType::VoidLast:
                VoidLastTransaction(EFTSetup, SalePOS, EftRequest);
            OperationType::VoidList:
                VoidList(EFTSetup, SalePOS, EftRequest);

            OperationType::ReprintLast:
                ReprintLastTransaction(EFTSetup, SalePOS);

            OperationType::LookupLast:
                LookupLastTransaction(EFTSetup, SalePOS, EftRequest);
            OperationType::LookupList:
                LookupList(EFTSetup, SalePOS, EftRequest);

            OperationType::ShowTransactions:
                ShowTransactions(EFTSetup, SalePOS);

            OperationType::RefundList:
                RefundList(EFTSetup, SalePOS, EftRequest);

            OperationType::AuxOperation:
                AuxOperation(EFTSetup, SalePOS, Context.GetIntegerParameter('AuxId'), EftRequest);

            else
                Error('Operation not implemented yet for Hardware Connector.');
        end;

        exit(EftRequest);
    end;

    local procedure DoLegacyEftOperation(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management") Response: JsonObject
    var
        POSAction: Record "NPR POS Action";
    begin
        POSAction.Get('EFT_OPERATION');
        POSAction.SetWorkflowInvocationParameterUnsafe('OperationType', Context.GetStringParameter('OperationType'));
        POSAction.SetWorkflowInvocationParameterUnsafe('EftType', Context.GetStringParameter('EftType'));
        POSAction.SetWorkflowInvocationParameterUnsafe('PaymentType', Context.GetStringParameter('PaymentType'));
        FrontEnd.InvokeWorkflow(POSAction);

        Response.ReadFrom('{}');
    end;

    #region operations
    local procedure StartBeginWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; WorkflowContext: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        HwcRequest: JsonObject;
    begin

        EFTTransactionMgt.StartBeginWorkshift(EFTSetup, SalePOS, HwcRequest);
        WorkflowContext.Add('hwcRequest', HwcRequest);
    end;

    local procedure StartEndWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowContext: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        HwcRequest: JsonObject;
    begin

        EFTTransactionMgt.StartEndWorkshift(EFTSetup, SalePOS, HwcRequest);
        WorkflowContext.Add('hwcRequest', HwcRequest);
    end;

    local procedure VoidLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowContext: JsonObject)
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        HwcRequest: JsonObject;
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, false);
        if not VoidConfirm(LastEFTTransactionRequest) then
            Error('');

        EFTTransactionMgt.StartVoid(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.", true, HwcRequest);
        WorkflowContext.Add('hwcRequest', HwcRequest);
    end;

    local procedure VoidList(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowContext: JsonObject)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        HwcRequest: JsonObject;
    begin
        if (not SelectTransaction(EFTTransactionRequest)) then
            exit;
        if not VoidConfirm(EFTTransactionRequest) then
            Error('');

        EFTTransactionMgt.StartVoid(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.", true, HwcRequest);
        WorkflowContext.Add('hwcRequest', HwcRequest);
    end;

    local procedure StartVerifySetup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowContext: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        HwcRequest: JsonObject;
    begin
        EFTTransactionMgt.StartVerifySetup(EFTSetup, SalePOS, HwcRequest);
        WorkflowContext.Add('hwcRequest', HwcRequest);
    end;

    local procedure RefundList(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowContext: JsonObject)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        HwcRequest: JsonObject;
    begin
        ApplyEftRefundListFilters(EFTTransactionRequest);
        if not SelectTransaction(EFTTransactionRequest) then
            exit;

        EFTTransactionMgt.StartReferencedRefund(EFTSetup, SalePOS, '', 0, EFTTransactionRequest."Entry No.", HwcRequest);
        WorkflowContext.Add('hwcRequest', HwcRequest);
    end;

    local procedure AuxOperation(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; AuxId: Integer; var WorkflowContext: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        HwcRequest: JsonObject;
    begin
        EFTTransactionMgt.StartAuxOperation(EFTSetup, SalePOS, AuxId, HwcRequest);
        WorkflowContext.Add('hwcRequest', HwcRequest);
    end;

    local procedure ReprintLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale")
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, true);
        LastEFTTransactionRequest.PrintReceipts(true);
    end;

    local procedure LookupLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowContext: JsonObject)
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, true);
        StartLookup(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.", WorkflowContext);
    end;

    local procedure LookupList(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowContext: JsonObject)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if (not SelectTransaction(EFTTransactionRequest)) then
            exit;
        StartLookup(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.", WorkflowContext);
    end;

    local procedure StartLookup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; EntryNo: Integer; var WorkflowContext: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        HwcRequest: JsonObject;
    begin
        EFTTransactionMgt.StartLookup(EFTSetup, SalePOS, EntryNo, HwcRequest);
        WorkflowContext.Add('hwcRequest', HwcRequest);
    end;

    local procedure SelectTransaction(var EftTransactionRequestOut: Record "NPR EFT Transaction Request"): Boolean
    begin
        exit(PAGE.RunModal(0, EftTransactionRequestOut) = ACTION::LookupOK);
    end;

    local procedure ShowTransactions(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetRange("Register No.", SalePOS."Register No.");
        EFTTransactionRequest.SetRange("Integration Type", EFTSetup."EFT Integration Type");
        EFTTransactionRequest.SetAscending("Entry No.", false);
        PAGE.Run(PAGE::"NPR EFT Transaction Requests", EFTTransactionRequest);
    end;

    local procedure ApplyEftRefundListFilters(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        EFTTransactionRequest.SetRange(Reversed, false);
    end;

    local procedure GetLastFinancialTransaction(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; IncludeVoidRequests: Boolean)
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

    local procedure VoidConfirm(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
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

    #endregion

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTOp2.Codeunit.js###
'let main=async({workflow:s})=>{const{version:n,hwcRequest:e,showSuccessMessage:o,showSpinner:a}=await s.respond("prepareRequest");if(typeof n=="undefined"||n==1){await s.respond("doLegacyPaymentWorkflow");return}typeof e!="undefined"&&e.hasOwnProperty("WorkflowName")&&s.queue(e.WorkflowName,{context:{hwcRequest:e,showSpinner:a,showSuccessMessage:o}})};'
        );
    end;

}
