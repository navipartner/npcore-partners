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


    local procedure PrepareRequest(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale") WorkflowRequest: JsonObject
    var
        EFTSetup: Record "NPR EFT Setup";
        SalePOS: Record "NPR POS Sale";
        OperationType: Option VoidLast,ReprintLast,LookupLast,OpenConn,CloseConn,VerifySetup,ShowTransactions,AuxOperation,LookupSpecific,VoidSpecific,RefundSpecific,LookupList,VoidList,RefundList;
        EftType: Text;
        PaymentType: Text;
        ERROR_MISSING_PARAM: Label 'Parameter %1 is missing';
        EFTInterface: Codeunit "NPR EFT Interface";
        TempEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
    begin
        POSSale.GetCurrentSale(SalePOS);

        OperationType := Context.GetIntegerParameter('OperationType');
        EftType := Context.GetStringParameter('EftType');
        PaymentType := Context.GetStringParameter('PaymentType');

        if PaymentType = '' then
            Error(ERROR_MISSING_PARAM, 'PaymentType');
        EFTSetup.FindSetup(SalePOS."Register No.", CopyStr(PaymentType, 1, MaxStrLen(EFTSetup."Payment Type POS")));

        EFTInterface.OnDiscoverIntegrations(TempEFTIntegrationType);
        TempEFTIntegrationType.SetRange(Code, EFTSetup."EFT Integration Type");
        TempEFTIntegrationType.FindFirst();

        WorkflowRequest.ReadFrom('{}');
        WorkflowRequest.Add('legacy', not TempEFTIntegrationType."Version 2");
        WorkflowRequest.Add('showSpinner', Context.GetBooleanParameter('ShowSpinner'));
        WorkflowRequest.Add('showSuccessMessage', Context.GetBooleanParameter('ShowSuccessMessage'));

        if (not TempEFTIntegrationType."Version 2") then
            exit; // legacy

        case OperationType of
            OperationType::VerifySetup:
                StartVerifySetup(EFTSetup, SalePOS, WorkflowRequest);

            OperationType::OpenConn:
                StartBeginWorkshift(EFTSetup, SalePOS, WorkflowRequest);

            OperationType::CloseConn:
                StartEndWorkshift(EFTSetup, SalePOS, WorkflowRequest);

            OperationType::VoidLast:
                VoidLastTransaction(EFTSetup, SalePOS, WorkflowRequest);

            OperationType::VoidList:
                VoidList(EFTSetup, SalePOS, WorkflowRequest);

            OperationType::ReprintLast:
                ReprintLastTransaction(EFTSetup, SalePOS);

            OperationType::LookupLast:
                LookupLastTransaction(EFTSetup, SalePOS, WorkflowRequest);

            OperationType::LookupList:
                LookupList(EFTSetup, SalePOS, WorkflowRequest);

            OperationType::ShowTransactions:
                ShowTransactions(EFTSetup, SalePOS);

            OperationType::RefundList:
                RefundList(EFTSetup, SalePOS, WorkflowRequest);

            OperationType::AuxOperation:
                AuxOperation(EFTSetup, SalePOS, Context.GetIntegerParameter('AuxId'), WorkflowRequest);

            else
                Error('Operation not implemented yet for Hardware Connector.');
        end;

        exit(WorkflowRequest);
    end;

    [Obsolete('Remove when all workflows are migrated to v3')]
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
    local procedure StartBeginWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        Mechanism: Enum "NPR EFT Request Mechanism";
        IntegrationRequest: JsonObject;
        EntryNo: Integer;
        Workflow: Text;
    begin
        EntryNo := EFTTransactionMgt.PrepareBeginWorkshift(EFTSetup, SalePOS, IntegrationRequest, Mechanism, Workflow);
        IntegrationRequest.Add('EntryNo', EntryNo);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
    end;

    local procedure StartEndWorkshift(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        Mechanism: Enum "NPR EFT Request Mechanism";
        IntegrationRequest: JsonObject;
        EntryNo: Integer;
        Workflow: Text;
    begin
        EntryNo := EFTTransactionMgt.PrepareEndWorkshift(EFTSetup, SalePOS, IntegrationRequest, Mechanism, Workflow);
        IntegrationRequest.Add('EntryNo', EntryNo);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
    end;

    local procedure VoidLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        Mechanism: Enum "NPR EFT Request Mechanism";
        EntryNo: Integer;
        IntegrationRequest: JsonObject;
        Workflow: Text;
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, false);
        if not VoidConfirm(LastEFTTransactionRequest) then
            Error('');

        EntryNo := EFTTransactionMgt.PrepareVoid(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.", true, IntegrationRequest, Mechanism, Workflow);
        IntegrationRequest.Add('EntryNo', EntryNo);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
    end;

    local procedure VoidList(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
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
        IntegrationRequest.Add('EntryNo', EntryNo);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
    end;

    local procedure StartVerifySetup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        EntryNo: Integer;
        Workflow: Text;
    begin
        EntryNo := EFTTransactionMgt.PrepareVerifySetup(EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", IntegrationRequest, Mechanism, Workflow);
        IntegrationRequest.Add('EntryNo', EntryNo);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
    end;

    local procedure RefundList(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
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
        IntegrationRequest.Add('EntryNo', EntryNo);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
    end;

    local procedure AuxOperation(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; AuxId: Integer; var WorkflowRequest: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        EntryNo: Integer;
        Workflow: Text;
    begin
        EntryNo := EFTTransactionMgt.PrepareAuxOperation(EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", AuxId, IntegrationRequest, Mechanism, Workflow);
        IntegrationRequest.Add('EntryNo', EntryNo);
        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
    end;

    local procedure ReprintLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale")
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, true);
        LastEFTTransactionRequest.PrintReceipts(true);
    end;

    local procedure LookupLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, true);
        StartLookup(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.", WorkflowRequest);
    end;

    local procedure LookupList(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; var WorkflowRequest: JsonObject)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if (not SelectTransaction(EFTTransactionRequest)) then
            exit;
        StartLookup(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.", WorkflowRequest);
    end;

    local procedure StartLookup(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale"; EntryNo: Integer; var WorkflowRequest: JsonObject)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
        LookupEntryNo: Integer;
    begin
        LookupEntryNo := EFTTransactionMgt.PrepareLookup(EFTSetup, SalePOS, EntryNo, IntegrationRequest, Mechanism, Workflow);
        IntegrationRequest.Add('EntryNo', LookupEntryNo);
        EFTTransactionMgt.SendRequestIfSynchronous(LookupEntryNo, IntegrationRequest, Mechanism);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnParameterLookup(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        TempEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
        EFTInterface: Codeunit "NPR EFT Interface";
        TempEFTAuxOperation: Record "NPR EFT Aux Operation" temporary;
        POSParameterValue2: Record "NPR POS Parameter Value";
        EFTSetup: Record "NPR EFT Setup";
        PaymentTypeFilter: Text;
        POSPaymentMethod: Record "NPR POS Payment Method";
        PymTypePOSLbl: Label '%1', Locked = true;
    begin
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::EFT_OPERATION_2) then
            exit;

        Handled := true;

        case POSParameterValue.Name of
            'EftType':
                begin
                    EFTInterface.OnDiscoverIntegrations(TempEFTIntegrationType);
                    if PAGE.RunModal(0, TempEFTIntegrationType) = ACTION::LookupOK then
                        POSParameterValue.Value := TempEFTIntegrationType.Code;
                end;
            'PaymentType':
                begin
                    POSParameterValue2 := POSParameterValue;
                    POSParameterValue2.SetRecFilter();
                    POSParameterValue2.SetRange(Name, 'EftType');
                    if not POSParameterValue2.FindFirst() then
                        exit;
                    if POSParameterValue2.Value = '' then
                        exit;

                    EFTSetup.SetRange("EFT Integration Type", POSParameterValue2.Value);
                    if not EFTSetup.FindSet() then
                        exit;
                    repeat
                        if PaymentTypeFilter <> '' then
                            PaymentTypeFilter += '|';
                        PaymentTypeFilter += StrSubstNo(PymTypePOSLbl, EFTSetup."Payment Type POS");
                    until EFTSetup.Next() = 0;
                    POSPaymentMethod.SetFilter(Code, PaymentTypeFilter);
                    if PAGE.RunModal(0, POSPaymentMethod) = ACTION::LookupOK then
                        POSParameterValue.Value := POSPaymentMethod.Code;
                end;
            'AuxId':
                begin
                    POSParameterValue2 := POSParameterValue;
                    POSParameterValue2.SetRecFilter();
                    POSParameterValue2.SetRange(Name, 'EftType');
                    if not POSParameterValue2.FindFirst() then
                        exit;
                    if POSParameterValue2.Value = '' then
                        exit;

                    EFTInterface.OnDiscoverAuxiliaryOperations(TempEFTAuxOperation);
                    TempEFTAuxOperation.SetRange("Integration Type", POSParameterValue2.Value);
                    if PAGE.RunModal(0, TempEFTAuxOperation) = ACTION::LookupOK then
                        POSParameterValue.Value := Format(TempEFTAuxOperation."Auxiliary ID");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnParameterValidate(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        TempEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
        TempEFTAuxOperation: Record "NPR EFT Aux Operation" temporary;
        EFTInterface: Codeunit "NPR EFT Interface";
        POSParameterValue2: Record "NPR POS Parameter Value";
        AuxId: Integer;
        EFTSetup: Record "NPR EFT Setup";
    begin
        if POSParameterValue."Action Code" <> Format(Enum::"NPR POS Workflow"::EFT_OPERATION_2) then
            exit;

        case POSParameterValue.Name of
            'EftType':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    EFTInterface.OnDiscoverIntegrations(TempEFTIntegrationType);
                    TempEFTIntegrationType.SetRange(Code, POSParameterValue.Value);
                    TempEFTIntegrationType.FindFirst();
                end;
            'PaymentType':
                begin
                    POSParameterValue2 := POSParameterValue;
                    POSParameterValue2.SetRecFilter();
                    POSParameterValue2.SetRange(Name, 'EftType');
                    if not POSParameterValue2.FindFirst() then
                        exit;
                    if POSParameterValue2.Value = '' then
                        exit;

                    EFTSetup.SetRange("EFT Integration Type", POSParameterValue2.Value);
                    EFTSetup.SetRange("Payment Type POS", POSParameterValue.Value);
                    EFTSetup.FindFirst();
                end;
            'AuxId':
                begin
                    if POSParameterValue.Value = '0' then
                        exit;

                    POSParameterValue2 := POSParameterValue;
                    POSParameterValue2.SetRecFilter();
                    POSParameterValue2.SetRange(Name, 'EftType');
                    if not POSParameterValue2.FindFirst() then
                        exit;
                    if POSParameterValue2.Value = '' then
                        exit;

                    EFTInterface.OnDiscoverAuxiliaryOperations(TempEFTAuxOperation);
                    TempEFTAuxOperation.SetRange("Integration Type", POSParameterValue2.Value);
                    Evaluate(AuxId, POSParameterValue.Value);
                    TempEFTAuxOperation.SetRange("Auxiliary ID", AuxId);
                    TempEFTAuxOperation.FindFirst();
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTOp2.Codeunit.js###
'let main=async({workflow:e})=>{const s=await e.respond("prepareRequest"),{legacy:n,integrationRequest:t,showSuccessMessage:a,showSpinner:r,synchronousRequest:o}=s;if(!o){if(n){await e.respond("doLegacyPaymentWorkflow");return}await e.run(s.workflowName,{context:{request:t,showSpinner:r,showSuccessMessage:a}})}};'
        );
    end;

}
