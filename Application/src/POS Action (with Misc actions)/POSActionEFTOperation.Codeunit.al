codeunit 6150846 "NPR POS Action: EFT Operation"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/MMV /20181221 CASE 340754 Added new list operation types for refund, void, lookup.
    // NPR5.48/MMV /20190123 CASE 341237 Added support for new pause/resume skip events.
    // NPR5.51/MMV /20190603 CASE 355433 Moved UnpauseWorkflowAfterResponse away from this codeunit
    // NPR5.51/MMV /20190628 CASE 359385 Added support for giftcard load
    // NPR5.54/MMV /20200226 CASE 364340 Consolidated pause/skip behaviour & all request types.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a template for POS Action';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved for EFT Operation';
        ERROR_MISSING_PARAM: Label 'Parameter %1 is missing';
        CAPTION_VOID_CONFIRM: Label 'Void the following transaction?\\From Sales Ticket No.: %1\Type: %2\Amount: %3 %4\External Ref. No.: %5';

    local procedure ActionCode(): Text
    begin
        exit('EFT_OPERATION');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1'); //-+NPR5.48
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
        SalePOS: Record "NPR Sale POS";
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

        OperationType := JSON.GetIntegerParameter('OperationType', true);
        EftType := JSON.GetStringParameter('EftType', true);
        PaymentType := JSON.GetStringParameter('PaymentType', true);

        if PaymentType = '' then
            Error(ERROR_MISSING_PARAM, 'PaymentType');
        EFTSetup.FindSetup(SalePOS."Register No.", PaymentType);

        case OperationType of
            OperationType::VoidLast:
                VoidLastTransaction(EFTSetup, SalePOS, FrontEnd);
            OperationType::ReprintLast:
                ReprintLastTransaction(EFTSetup, SalePOS);
            OperationType::LookupLast:
                LookupLastTransaction(EFTSetup, SalePOS, FrontEnd);
            //-NPR5.54 [364340]
            OperationType::OpenConn:
                EFTTransactionMgt.StartBeginWorkshift(EFTSetup, SalePOS);
            OperationType::CloseConn:
                EFTTransactionMgt.StartEndWorkshift(EFTSetup, SalePOS);
            OperationType::VerifySetup:
                EFTTransactionMgt.StartVerifySetup(EFTSetup, SalePOS);
            //+NPR5.54 [364340]
            OperationType::ShowTransactions:
                ShowTransactions(EFTSetup, SalePOS);
            OperationType::AuxOperation:
                begin
                    EFTSetup.TestField("EFT Integration Type", EftType);
                    AuxId := JSON.GetIntegerParameter('AuxId', true);
                    //-NPR5.54 [364340]
                    EFTTransactionMgt.StartAuxOperation(EFTSetup, SalePOS, AuxId);
                    //+NPR5.54 [364340]
                end;
            OperationType::LookupSpecific:
                begin
                    EntryNo := JSON.GetIntegerParameter('EntryNo', true);
                    //-NPR5.54 [364340]
                    EFTTransactionMgt.StartLookup(EFTSetup, SalePOS, EntryNo);
                    //+NPR5.54 [364340]
                end;
            OperationType::VoidSpecific:
                begin
                    EntryNo := JSON.GetIntegerParameter('EntryNo', true);
                    //-NPR5.54 [364340]
                    EFTTransactionMgt.StartVoid(EFTSetup, SalePOS, EntryNo, true);
                    //+NPR5.54 [364340]
                end;
            OperationType::RefundSpecific:
                begin
                    EntryNo := JSON.GetIntegerParameter('EntryNo', true);
                    //-NPR5.54 [364340]
                    EFTTransactionMgt.StartReferencedRefund(EFTSetup, SalePOS, '', 0, EntryNo);
                    //+NPR5.54 [364340]
                end;
            OperationType::LookupList:
                begin
                    if not SelectTransaction(EFTTransactionRequest) then
                        exit;
                    //-NPR5.54 [364340]
                    EFTTransactionMgt.StartLookup(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.");
                    //+NPR5.54 [364340]
                end;
            OperationType::VoidList:
                begin
                    if not SelectTransaction(EFTTransactionRequest) then
                        exit;
                    if not VoidConfirm(EFTTransactionRequest) then
                        exit;
                    //-NPR5.54 [364340]
                    EFTTransactionMgt.StartVoid(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.", true);
                    //+NPR5.54 [364340]
                end;
            OperationType::RefundList:
                begin
                    if not SelectTransaction(EFTTransactionRequest) then
                        exit;
                    //-NPR5.54 [364340]
                    EFTTransactionMgt.StartReferencedRefund(EFTSetup, SalePOS, '', 0, EFTTransactionRequest."Entry No.");
                    //+NPR5.54 [364340]
                end;
        end;
    end;

    local procedure "--"()
    begin
    end;

    local procedure VoidLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        RecoveredEFTTransactionRequest: Record "NPR EFT Transaction Request";
        Continue: Boolean;
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        //-NPR5.54 [364340]
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, false);
        //+NPR5.54 [364340]
        if not VoidConfirm(LastEFTTransactionRequest) then
            Error('');
        //-NPR5.54 [364340]
        EFTTransactionMgt.StartVoid(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.", true);
        //+NPR5.54 [364340]
    end;

    local procedure ReprintLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS")
    var
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        //-NPR5.54 [364340]
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, true);
        //+NPR5.54 [364340]
        LastEFTTransactionRequest.PrintReceipts(true);
    end;

    local procedure LookupLastTransaction(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTIntegration: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        LastEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        //-NPR5.54 [364340]
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS, true);
        EFTTransactionMgt.StartLookup(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.");
        //+NPR5.54 [364340]
    end;

    local procedure ShowTransactions(EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetRange("Register No.", SalePOS."Register No.");
        EFTTransactionRequest.SetRange("Integration Type", EFTSetup."EFT Integration Type");
        EFTTransactionRequest.SetAscending("Entry No.", false);
        PAGE.Run(PAGE::"NPR EFT Transaction Requests", EFTTransactionRequest);
    end;

    local procedure GetLastFinancialTransaction(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; SalePOS: Record "NPR Sale POS"; IncludeVoidRequests: Boolean)
    begin
        EFTTransactionRequest.SetRange("Register No.", SalePOS."Register No.");
        EFTTransactionRequest.SetRange("Integration Type", EFTSetup."EFT Integration Type");
        //-NPR5.54 [364340]
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
        //+NPR5.54 [364340]
        EFTTransactionRequest.FindLast;
    end;

    local procedure VoidConfirm(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        RecoveredEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if EFTTransactionRequest.Recovered then begin
            RecoveredEFTTransactionRequest.Get(EFTTransactionRequest."Recovered by Entry No.");
            with RecoveredEFTTransactionRequest do
                exit(Confirm(CAPTION_VOID_CONFIRM, false, EFTTransactionRequest."Sales Ticket No.", Format(EFTTransactionRequest."Processing Type"), "Result Amount", "Currency Code", "External Transaction ID"));
        end else
            with EFTTransactionRequest do
                exit(Confirm(CAPTION_VOID_CONFIRM, false, "Sales Ticket No.", Format("Processing Type"), "Result Amount", "Currency Code", "External Transaction ID"));
    end;

    local procedure SelectTransaction(var EftTransactionRequestOut: Record "NPR EFT Transaction Request"): Boolean
    begin
        exit(PAGE.RunModal(0, EftTransactionRequestOut) = ACTION::LookupOK);
    end;

    local procedure "// Parameter Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnParameterLookup(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
        EFTInterface: Codeunit "NPR EFT Interface";
        tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary;
        POSParameterValue2: Record "NPR POS Parameter Value";
        EFTSetup: Record "NPR EFT Setup";
        PaymentTypeFilter: Text;
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        Handled := true;

        case POSParameterValue.Name of
            'EftType':
                begin
                    EFTInterface.OnDiscoverIntegrations(tmpEFTIntegrationType);
                    if PAGE.RunModal(0, tmpEFTIntegrationType) = ACTION::LookupOK then
                        POSParameterValue.Value := tmpEFTIntegrationType.Code;
                end;
            'PaymentType':
                begin
                    POSParameterValue2 := POSParameterValue;
                    POSParameterValue2.SetRecFilter;
                    POSParameterValue2.SetRange(Name, 'EftType');
                    if not POSParameterValue2.FindFirst then
                        exit;
                    if POSParameterValue2.Value = '' then
                        exit;

                    EFTSetup.SetRange("EFT Integration Type", POSParameterValue2.Value);
                    if not EFTSetup.FindSet then
                        exit;
                    repeat
                        if PaymentTypeFilter <> '' then
                            PaymentTypeFilter += '|';
                        PaymentTypeFilter += StrSubstNo('%1', EFTSetup."Payment Type POS");
                    until EFTSetup.Next = 0;
                    PaymentTypePOS.SetFilter("No.", PaymentTypeFilter);
                    if PAGE.RunModal(0, PaymentTypePOS) = ACTION::LookupOK then
                        POSParameterValue.Value := PaymentTypePOS."No.";
                end;
            'AuxId':
                begin
                    POSParameterValue2 := POSParameterValue;
                    POSParameterValue2.SetRecFilter;
                    POSParameterValue2.SetRange(Name, 'EftType');
                    if not POSParameterValue2.FindFirst then
                        exit;
                    if POSParameterValue2.Value = '' then
                        exit;

                    EFTInterface.OnDiscoverAuxiliaryOperations(tmpEFTAuxOperation);
                    tmpEFTAuxOperation.SetRange("Integration Type", POSParameterValue2.Value);
                    if PAGE.RunModal(0, tmpEFTAuxOperation) = ACTION::LookupOK then
                        POSParameterValue.Value := Format(tmpEFTAuxOperation."Auxiliary ID");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnParameterValidate(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
        tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary;
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
                    EFTInterface.OnDiscoverIntegrations(tmpEFTIntegrationType);
                    tmpEFTIntegrationType.SetRange(Code, POSParameterValue.Value);
                    tmpEFTIntegrationType.FindFirst;
                end;
            'PaymentType':
                begin
                    POSParameterValue2 := POSParameterValue;
                    POSParameterValue2.SetRecFilter;
                    POSParameterValue2.SetRange(Name, 'EftType');
                    if not POSParameterValue2.FindFirst then
                        exit;
                    if POSParameterValue2.Value = '' then
                        exit;

                    EFTSetup.SetRange("EFT Integration Type", POSParameterValue2.Value);
                    EFTSetup.SetRange("Payment Type POS", POSParameterValue.Value);
                    EFTSetup.FindFirst;
                end;
            'AuxId':
                begin
                    if POSParameterValue.Value = '0' then
                        exit;

                    POSParameterValue2 := POSParameterValue;
                    POSParameterValue2.SetRecFilter;
                    POSParameterValue2.SetRange(Name, 'EftType');
                    if not POSParameterValue2.FindFirst then
                        exit;
                    if POSParameterValue2.Value = '' then
                        exit;

                    EFTInterface.OnDiscoverAuxiliaryOperations(tmpEFTAuxOperation);
                    tmpEFTAuxOperation.SetRange("Integration Type", POSParameterValue2.Value);
                    Evaluate(AuxId, POSParameterValue.Value);
                    tmpEFTAuxOperation.SetRange("Auxiliary ID", AuxId);
                    tmpEFTAuxOperation.FindFirst;
                end;
        end;
    end;
}

