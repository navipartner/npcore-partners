codeunit 6150846 "NPR POS Action: EFT Operation"
{
    var
        ActionDescription: Label 'This is a template for POS Action';
        ERROR_MISSING_PARAM: Label 'Parameter %1 is missing';
        CAPTION_VOID_CONFIRM: Label 'Void the following transaction?\\From Sales Ticket No.: %1\Type: %2\Amount: %3 %4\External Ref. No.: %5';

    local procedure ActionCode(): Text
    begin
        exit('EFT_OPERATION');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('SendRequest', 'respond();');
            Sender.RegisterWorkflowStep('EndOfWorkflow', 'respond();'); //Undim & refresh potential new lines.
            Sender.RegisterWorkflow(false);

            Sender.RegisterTextParameter('EftType', '');
            Sender.RegisterTextParameter('PaymentType', '');
            Sender.RegisterOptionParameter('OperationType', 'VoidLast,ReprintLast,LookupLast,OpenConn,CloseConn,VerifySetup,ShowTransactions,AuxOperation,LookupSpecific,VoidSpecific,RefundSpecific,LookupList,VoidList,RefundList', 'ShowTransactions');
            Sender.RegisterIntegerParameter('AuxId', 0);
            Sender.RegisterIntegerParameter('EntryNo', 0);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        OperationType: Option VoidLast,ReprintLast,LookupLast,OpenConn,CloseConn,VerifySetup,ShowTransactions,AuxOperation,LookupSpecific,VoidSpecific,RefundSpecific,LookupList,VoidList,RefundList;
        EftType: Text;
        PaymentType: Text;
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        AuxId: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EntryNo: Integer;
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        if WorkflowStep = 'EndOfWorkflow' then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        JSON.InitializeJObjectParser(Context, FrontEnd);

        OperationType := JSON.GetIntegerParameterOrFail('OperationType', ActionCode());
        EftType := JSON.GetStringParameterOrFail('EftType', ActionCode());
        PaymentType := JSON.GetStringParameterOrFail('PaymentType', ActionCode());

        if PaymentType = '' then
            Error(ERROR_MISSING_PARAM, 'PaymentType');
        EFTSetup.FindSetup(SalePOS."Register No.", PaymentType);

        case OperationType of
            OperationType::VoidLast:
                VoidLastTransaction(EFTSetup, SalePOS);
            OperationType::ReprintLast:
                ReprintLastTransaction(EFTSetup, SalePOS);
            OperationType::LookupLast:
                LookupLastTransaction(EFTSetup, SalePOS);
            OperationType::OpenConn:
                EFTTransactionMgt.StartBeginWorkshift(EFTSetup, SalePOS);
            OperationType::CloseConn:
                EFTTransactionMgt.StartEndWorkshift(EFTSetup, SalePOS);
            OperationType::VerifySetup:
                EFTTransactionMgt.StartVerifySetup(EFTSetup, SalePOS);
            OperationType::ShowTransactions:
                ShowTransactions(EFTSetup, SalePOS);
            OperationType::AuxOperation:
                begin
                    EFTSetup.TestField("EFT Integration Type", EftType);
                    AuxId := JSON.GetIntegerParameterOrFail('AuxId', ActionCode());
                    EFTTransactionMgt.StartAuxOperation(EFTSetup, SalePOS, AuxId);
                end;
            OperationType::LookupSpecific:
                begin
                    EntryNo := JSON.GetIntegerParameterOrFail('EntryNo', ActionCode());
                    EFTTransactionMgt.StartLookup(EFTSetup, SalePOS, EntryNo);
                end;
            OperationType::VoidSpecific:
                begin
                    EntryNo := JSON.GetIntegerParameterOrFail('EntryNo', ActionCode());
                    EFTTransactionMgt.StartVoid(EFTSetup, SalePOS, EntryNo, true);
                end;
            OperationType::RefundSpecific:
                begin
                    EntryNo := JSON.GetIntegerParameterOrFail('EntryNo', ActionCode());
                    EFTTransactionMgt.StartReferencedRefund(EFTSetup, SalePOS, '', 0, EntryNo);
                end;
            OperationType::LookupList:
                begin
                    if not SelectTransaction(EFTTransactionRequest) then
                        exit;
                    EFTTransactionMgt.StartLookup(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.");
                end;
            OperationType::VoidList:
                begin
                    if not SelectTransaction(EFTTransactionRequest) then
                        exit;
                    if not VoidConfirm(EFTTransactionRequest) then
                        exit;
                    EFTTransactionMgt.StartVoid(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.", true);
                end;
            OperationType::RefundList:
                begin
                    ApplyEftRefundListFilters(EFTTransactionRequest);
                    if not SelectTransaction(EFTTransactionRequest) then
                        exit;
                    EFTTransactionMgt.StartReferencedRefund(EFTSetup, SalePOS, '', 0, EFTTransactionRequest."Entry No.");
                end;
        end;
    end;

    local procedure VoidLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale")
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, false);
        if not VoidConfirm(LastEFTTransactionRequest) then
            Error('');
        EFTTransactionMgt.StartVoid(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.", true);
    end;

    local procedure ReprintLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale")
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, true);
        LastEFTTransactionRequest.PrintReceipts(true);
    end;

    local procedure LookupLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR POS Sale")
    var
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, true);
        EFTTransactionMgt.StartLookup(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.");
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
    begin
        if EFTTransactionRequest.Recovered then begin
            RecoveredEFTTransactionRequest.Get(EFTTransactionRequest."Recovered by Entry No.");
            exit(Confirm(CAPTION_VOID_CONFIRM, false, EFTTransactionRequest."Sales Ticket No.", Format(EFTTransactionRequest."Processing Type"), RecoveredEFTTransactionRequest."Result Amount", RecoveredEFTTransactionRequest."Currency Code", RecoveredEFTTransactionRequest."External Transaction ID"));
        end else
            exit(Confirm(CAPTION_VOID_CONFIRM, false, EFTTransactionRequest."Sales Ticket No.", Format(EFTTransactionRequest."Processing Type"), EFTTransactionRequest."Result Amount", EFTTransactionRequest."Currency Code", EFTTransactionRequest."External Transaction ID"));
    end;

    local procedure SelectTransaction(var EftTransactionRequestOut: Record "NPR EFT Transaction Request"): Boolean
    begin
        exit(PAGE.RunModal(0, EftTransactionRequestOut) = ACTION::LookupOK);
    end;

    local procedure ApplyEftRefundListFilters(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        EFTTransactionRequest.SetRange(Reversed, false);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
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
        if POSParameterValue."Action Code" <> ActionCode() then
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

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnParameterValidate(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        TempEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
        TempEFTAuxOperation: Record "NPR EFT Aux Operation" temporary;
        EFTInterface: Codeunit "NPR EFT Interface";
        POSParameterValue2: Record "NPR POS Parameter Value";
        AuxId: Integer;
        EFTSetup: Record "NPR EFT Setup";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
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
}
