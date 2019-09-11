codeunit 6150846 "POS Action - EFT Operation"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/MMV /20181221 CASE 340754 Added new list operation types for refund, void, lookup.
    // NPR5.48/MMV /20190123 CASE 341237 Added support for new pause/resume skip events.
    // NPR5.51/MMV /20190603 CASE 355433 Moved UnpauseWorkflowAfterResponse away from this codeunit
    // NPR5.51/MMV /20190628 CASE 359385 Added support for giftcard load


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
        exit ('EFT_OPERATION');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1'); //-+NPR5.48
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
          Sender.RegisterWorkflowStep ('SendRequest', 'respond();');
          Sender.RegisterWorkflowStep ('EndOfWorkflow', 'respond();'); //Undim & refresh potential new lines.
          Sender.RegisterWorkflow (false);

          Sender.RegisterTextParameter('EftType','');
          Sender.RegisterTextParameter('PaymentType','');
          Sender.RegisterOptionParameter('OperationType', 'VoidLast,ReprintLast,LookupLast,OpenConn,CloseConn,VerifySetup,ShowTransactions,AuxOperation,LookupSpecific,VoidSpecific,RefundSpecific,LookupList,VoidList,RefundList', 'ShowTransactions');
          Sender.RegisterIntegerParameter('AuxId', 0);
          Sender.RegisterIntegerParameter('EntryNo', 0);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        OperationType: Option VoidLast,ReprintLast,LookupLast,OpenConn,CloseConn,VerifySetup,ShowTransactions,AuxOperation,LookupSpecific,VoidSpecific,RefundSpecific,LookupList,VoidList,RefundList;
        EftType: Text;
        PaymentType: Text;
        JSON: Codeunit "POS JSON Management";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        AuxId: Integer;
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTSetup: Record "EFT Setup";
        EntryNo: Integer;
    begin
        if not Action.IsThisAction(ActionCode()) then
          exit;

        Handled := true;

        if WorkflowStep = 'EndOfWorkflow' then
          exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        JSON.InitializeJObjectParser(Context,FrontEnd);

        OperationType := JSON.GetIntegerParameter('OperationType', true);
        EftType := JSON.GetStringParameter('EftType', true);
        PaymentType := JSON.GetStringParameter('PaymentType', true);

        if PaymentType = '' then
          Error(ERROR_MISSING_PARAM, 'PaymentType');
        EFTSetup.FindSetup(SalePOS."Register No.", PaymentType);

        case OperationType of
          OperationType::VoidLast : VoidLastTransaction(EFTSetup, SalePOS, FrontEnd);
          OperationType::ReprintLast : ReprintLastTransaction(EFTSetup, SalePOS);
          OperationType::LookupLast : LookupLastTransaction(EFTSetup, SalePOS, FrontEnd);
          OperationType::OpenConn : OpenConnection(EFTSetup, SalePOS, FrontEnd);
          OperationType::CloseConn : CloseConnection(EFTSetup, SalePOS, FrontEnd);
          OperationType::VerifySetup : VerifySetup(EFTSetup, SalePOS, FrontEnd);
          OperationType::ShowTransactions : ShowTransactions(EFTSetup, SalePOS);
          OperationType::AuxOperation :
            begin
              EFTSetup.TestField("EFT Integration Type", EftType);
              AuxId := JSON.GetIntegerParameter('AuxId', true);
              AuxOperation(EFTSetup, SalePOS, AuxId, FrontEnd);
            end;
          OperationType::LookupSpecific :
            begin
              EntryNo := JSON.GetIntegerParameter('EntryNo', true);
              LookupTransaction(EFTSetup, SalePOS, EntryNo, FrontEnd);
            end;
          OperationType::VoidSpecific :
            begin
              EntryNo := JSON.GetIntegerParameter('EntryNo', true);
              VoidTransaction(EFTSetup, SalePOS, EntryNo, FrontEnd);
           end;
          OperationType::RefundSpecific :
            begin
              EntryNo := JSON.GetIntegerParameter('EntryNo', true);
              RefundTransaction(EFTSetup, SalePOS, EntryNo, FrontEnd);
            end;
          OperationType::LookupList :
            begin
              if not SelectTransaction(EFTTransactionRequest) then
                exit;
              LookupTransaction(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.", FrontEnd);
            end;
          OperationType::VoidList :
            begin
              if not SelectTransaction(EFTTransactionRequest) then
                exit;
              if not VoidConfirm(EFTTransactionRequest) then
                exit;
              VoidTransaction(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.", FrontEnd);
            end;
          OperationType::RefundList :
            begin
              if not SelectTransaction(EFTTransactionRequest) then
                exit;
              RefundTransaction(EFTSetup, SalePOS, EFTTransactionRequest."Entry No.", FrontEnd);
            end;
        end;
    end;

    local procedure "--"()
    begin
    end;

    local procedure VoidLastTransaction(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS";FrontEnd: Codeunit "POS Front End Management")
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequest: Record "EFT Transaction Request";
        LastEFTTransactionRequest: Record "EFT Transaction Request";
        RecoveredEFTTransactionRequest: Record "EFT Transaction Request";
        Continue: Boolean;
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS);
        if not VoidConfirm(LastEFTTransactionRequest) then
          Error('');
        VoidTransaction(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.", FrontEnd);
    end;

    local procedure VoidTransaction(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS";EntryNo: Integer;FrontEnd: Codeunit "POS Front End Management")
    var
        EFTFramework: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequestToVoid: Record "EFT Transaction Request";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        EFTTransactionRequestToVoid.Get(EntryNo);
        EFTFramework.CreateVoidRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EntryNo, true);
        Commit;
        PauseWorkflow(EFTTransactionRequest, FrontEnd);
        EFTFramework.SendRequest(EFTTransactionRequest);
    end;

    local procedure RefundTransaction(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS";EntryNo: Integer;FrontEnd: Codeunit "POS Front End Management")
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequestToRefund: Record "EFT Transaction Request";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        EFTTransactionRequestToRefund.Get(EntryNo);
        EFTIntegration.CreateRefundRequest(EFTTransactionRequest,
                                           EFTSetup,
                                           SalePOS."Register No.",
                                           SalePOS."Sales Ticket No.",
                                           EFTTransactionRequestToRefund."Currency Code",
                                           EFTTransactionRequestToRefund."Result Amount",
                                           EFTTransactionRequestToRefund."Entry No.");
        Commit;
        PauseWorkflow(EFTTransactionRequest, FrontEnd);
        EFTIntegration.SendRequest(EFTTransactionRequest);
    end;

    local procedure ReprintLastTransaction(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS")
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequest: Record "EFT Transaction Request";
        LastEFTTransactionRequest: Record "EFT Transaction Request";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS);
        LastEFTTransactionRequest.PrintReceipts(true);
    end;

    local procedure LookupLastTransaction(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS";FrontEnd: Codeunit "POS Front End Management")
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequest: Record "EFT Transaction Request";
        LastEFTTransactionRequest: Record "EFT Transaction Request";
    begin
        GetLastFinancialTransaction(LastEFTTransactionRequest, EFTSetup, SalePOS);
        LookupTransaction(EFTSetup, SalePOS, LastEFTTransactionRequest."Entry No.", FrontEnd);
    end;

    local procedure LookupTransaction(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS";EntryNo: Integer;FrontEnd: Codeunit "POS Front End Management")
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequestToLookup: Record "EFT Transaction Request";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        EFTTransactionRequestToLookup.Get(EntryNo);
        EFTIntegration.CreateLookupTransactionRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.", EntryNo);
        Commit;
        PauseWorkflow(EFTTransactionRequest, FrontEnd);
        EFTIntegration.SendRequest(EFTTransactionRequest);
    end;

    local procedure OpenConnection(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS";FrontEnd: Codeunit "POS Front End Management")
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        EFTIntegration.CreateBeginWorkshiftRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit;
        PauseWorkflow(EFTTransactionRequest, FrontEnd);
        EFTIntegration.SendRequest(EFTTransactionRequest);
    end;

    local procedure CloseConnection(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS";FrontEnd: Codeunit "POS Front End Management")
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        EFTIntegration.CreateEndWorkshiftRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit;
        PauseWorkflow(EFTTransactionRequest, FrontEnd);
        EFTIntegration.SendRequest(EFTTransactionRequest);
    end;

    local procedure VerifySetup(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS";FrontEnd: Codeunit "POS Front End Management")
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        EFTIntegration.CreateVerifySetupRequest(EFTTransactionRequest, EFTSetup, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit;
        PauseWorkflow(EFTTransactionRequest, FrontEnd);
        EFTIntegration.SendRequest(EFTTransactionRequest);
    end;

    local procedure ShowTransactions(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        EFTTransactionRequest.SetRange("Register No.", SalePOS."Register No.");
        EFTTransactionRequest.SetRange("Integration Type", EFTSetup."EFT Integration Type");
        EFTTransactionRequest.SetAscending("Entry No.", false);
        PAGE.Run(PAGE::"EFT Transaction Requests", EFTTransactionRequest);
    end;

    local procedure AuxOperation(EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS";AuxID: Integer;FrontEnd: Codeunit "POS Front End Management")
    var
        EFTIntegration: Codeunit "EFT Framework Mgt.";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        EFTIntegration.CreateAuxRequest(EFTTransactionRequest, EFTSetup, AuxID, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        Commit;
        PauseWorkflow(EFTTransactionRequest, FrontEnd);
        EFTIntegration.SendRequest(EFTTransactionRequest);
    end;

    local procedure GetLastFinancialTransaction(var EFTTransactionRequest: Record "EFT Transaction Request";EFTSetup: Record "EFT Setup";SalePOS: Record "Sale POS")
    begin
        EFTTransactionRequest.SetRange("Register No.", SalePOS."Register No.");
        EFTTransactionRequest.SetRange("Integration Type", EFTSetup."EFT Integration Type");
        //-NPR5.51 [359385]
        //EFTTransactionRequest.SETFILTER("Processing Type", '%1|%2|%3', EFTTransactionRequest."Processing Type"::Payment, EFTTransactionRequest."Processing Type"::Refund, EFTTransactionRequest."Processing Type"::Void);
        EFTTransactionRequest.SetFilter("Processing Type", '%1|%2|%3|%4',
            EFTTransactionRequest."Processing Type"::PAYMENT,
            EFTTransactionRequest."Processing Type"::REFUND,
            EFTTransactionRequest."Processing Type"::VOID,
            EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD);
        //+NPR5.51 [359385]
        EFTTransactionRequest.FindLast;
    end;

    local procedure PauseWorkflow(EFTTransactionRequest: Record "EFT Transaction Request";FrontEnd: Codeunit "POS Front End Management")
    var
        EFTInterface: Codeunit "EFT Interface";
        Skip: Boolean;
    begin
        EFTInterface.OnBeforePauseFrontEnd(EFTTransactionRequest, Skip);
        if not Skip then
          FrontEnd.PauseWorkflow();
    end;

    local procedure VoidConfirm(EFTTransactionRequest: Record "EFT Transaction Request"): Boolean
    var
        RecoveredEFTTransactionRequest: Record "EFT Transaction Request";
    begin
        if EFTTransactionRequest.Recovered then begin
          RecoveredEFTTransactionRequest.Get(EFTTransactionRequest."Recovered by Entry No.");
          with RecoveredEFTTransactionRequest do
            exit(Confirm(CAPTION_VOID_CONFIRM, false, EFTTransactionRequest."Sales Ticket No.", Format(EFTTransactionRequest."Processing Type"), "Result Amount", "Currency Code", "External Transaction ID"));
        end else
          with EFTTransactionRequest do
            exit(Confirm(CAPTION_VOID_CONFIRM, false, "Sales Ticket No.", Format("Processing Type"), "Result Amount", "Currency Code", "External Transaction ID"));
    end;

    local procedure SelectTransaction(var EftTransactionRequestOut: Record "EFT Transaction Request"): Boolean
    begin
        exit(PAGE.RunModal(0, EftTransactionRequestOut) = ACTION::LookupOK);
    end;

    local procedure "// Parameter Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnParameterLookup(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        tmpEFTIntegrationType: Record "EFT Integration Type" temporary;
        EFTInterface: Codeunit "EFT Interface";
        tmpEFTAuxOperation: Record "EFT Aux Operation" temporary;
        POSParameterValue2: Record "POS Parameter Value";
        EFTSetup: Record "EFT Setup";
        PaymentTypeFilter: Text;
        PaymentTypePOS: Record "Payment Type POS";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;

        Handled := true;

        case POSParameterValue.Name of
          'EftType' :
            begin
              EFTInterface.OnDiscoverIntegrations(tmpEFTIntegrationType);
              if PAGE.RunModal(0, tmpEFTIntegrationType) = ACTION::LookupOK then
                POSParameterValue.Value := tmpEFTIntegrationType.Code;
            end;
          'PaymentType' :
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
    local procedure OnParameterValidate(var POSParameterValue: Record "POS Parameter Value")
    var
        tmpEFTIntegrationType: Record "EFT Integration Type" temporary;
        tmpEFTAuxOperation: Record "EFT Aux Operation" temporary;
        EFTInterface: Codeunit "EFT Interface";
        POSParameterValue2: Record "POS Parameter Value";
        AuxId: Integer;
        EFTSetup: Record "EFT Setup";
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

