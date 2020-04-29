codeunit 6184526 "EFT Verifone Vim Integration"
{
    // NPR5.53/MMV /20191203 CASE 349520 Created object
    // NPR5.54/MMV /20200414 CASE 364340 Added card data for voids


    trigger OnRun()
    begin
    end;

    var
        INTEGRATION_DESC: Label 'Verifone VIM via stargate';
        BALANCE_CHECK_DEC: Label 'Balance Enquiry';
        TRX_ERROR: Label '%1 %2 failed\%3\%4';
        VOID_SUCCESS: Label 'Transaction %1 voided successfully';
        CARD: Label 'Card: %1';
        UNKNOWN: Label 'Unknown Electronic Payment Type';
        OPERATION_SUCCESS: Label '%1 %2 Success';
        RECONCILIATION: Label 'Acquirer Reconciliation';
        BALANCE_PROMPT: Label 'Balance: %1 %2\Expiry Date: %3';

    local procedure IntegrationType(): Text
    begin
        exit('VERIFONE_VIM');
    end;

    local procedure "// Interface implementation"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init;
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := INTEGRATION_DESC;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"EFT Verifone Vim Integration";
        tmpEFTIntegrationType.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "EFT Aux Operation" temporary)
    begin
        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := BALANCE_CHECK_DEC;
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := RECONCILIATION;
        tmpEFTAuxOperation.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "EFT Setup")
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
          exit;

        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        Commit;
        PAGE.RunModal(PAGE::"EFT Verifone Unit Parameters", EFTVerifoneUnitParameter);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "EFT Setup")
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
          exit;

        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        Commit;
        PAGE.RunModal(PAGE::"EFT Verifone Payment Parameter", EFTVerifonePaymentParameter);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateBeginWorkshiftRequest', '', false, false)]
    local procedure OnCreateBeginWorkshiftRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateEndWorkshiftRequest', '', false, false)]
    local procedure OnCreateEndWorkshiftRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateGiftCardLoadRequest', '', false, false)]
    local procedure OnCreateGiftCardLoadRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    var
        OriginalEftTrxRequest: Record "EFT Transaction Request";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        OriginalEftTrxRequest.Get(EftTransactionRequest."Processed Entry No.");
        //-NPR5.54 [364340]
        if OriginalEftTrxRequest.Recovered then
          OriginalEftTrxRequest.Get(OriginalEftTrxRequest."Recovered by Entry No.");

        //Integration does not provide these values in void response so we copy manually
        EftTransactionRequest."Card Number" := OriginalEftTrxRequest."Card Number";
        EftTransactionRequest."Card Name" := OriginalEftTrxRequest."Card Name";
        EftTransactionRequest."Card Application ID" := OriginalEftTrxRequest."Card Application ID";
        EftTransactionRequest."Card Issuer ID" := OriginalEftTrxRequest."Card Issuer ID";
        //+NPR5.54 [364340]
        OriginalEftTrxRequest.TestField("External Transaction ID");

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;

        case EftTransactionRequest."Auxiliary Operation ID" of
          1 : OnCreateBalanceEnquiryRequest(EftTransactionRequest, Handled);
          2 : OnCreateReconciliationRequest(EftTransactionRequest, Handled);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    var
        OriginalEftTrxRequest: Record "EFT Transaction Request";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        OriginalEftTrxRequest.Get(EftTransactionRequest."Processed Entry No.");
        OriginalEftTrxRequest.TestField("Reference Number Output");
        //-NPR5.54 [364340]
        if OriginalEftTrxRequest."Processing Type" = OriginalEftTrxRequest."Processing Type"::VOID then begin
          //Integration does not provide these values in void response so we copy manually
          EftTransactionRequest."Card Number" := OriginalEftTrxRequest."Card Number";
          EftTransactionRequest."Card Name" := OriginalEftTrxRequest."Card Name";
          EftTransactionRequest."Card Application ID" := OriginalEftTrxRequest."Card Application ID";
          EftTransactionRequest."Card Issuer ID" := OriginalEftTrxRequest."Card Issuer ID";
        end;
        //+NPR5.54 [364340]

        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnQueueCloseBeforeRegisterBalance', '', false, false)]
    local procedure OnQueueCloseBeforeRegisterBalance(POSSession: Codeunit "POS Session";var tmpEFTSetup: Record "EFT Setup" temporary)
    var
        EFTSetup: Record "EFT Setup";
        POSSetup: Codeunit "POS Setup";
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        POSSession.GetSetup(POSSetup);

        EFTSetup.SetFilter("POS Unit No.", POSSetup.Register());
        EFTSetup.SetRange("EFT Integration Type", IntegrationType());
        if not EFTSetup.FindFirst then begin
          EFTSetup.SetRange("POS Unit No.", '');
          if not EFTSetup.FindFirst then
            exit;
        end;

        if not GetAutoCloseOnBalancing(EFTSetup) then
          exit;

        tmpEFTSetup := EFTSetup;
        tmpEFTSetup.Insert;
    end;

    local procedure OnCreateBalanceEnquiryRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        Handled := true;

        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    local procedure OnCreateReconciliationRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        Handled := true;

        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    var
        EFTVerifoneVimProtocol: Codeunit "EFT Verifone Vim Protocol";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        EFTVerifoneVimProtocol.SendEftDeviceRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnPrintReceipt', '', false, false)]
    local procedure OnPrintReceipt(EFTTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    var
        CreditCardTransaction: Record "EFT Receipt";
    begin
        if not EFTTransactionRequest.IsType(IntegrationType()) then
          exit;

        if (EFTTransactionRequest."Authentication Method" = EFTTransactionRequest."Authentication Method"::Signature)
          and (EFTTransactionRequest."Signature Type" = EFTTransactionRequest."Signature Type"::"On Receipt")
          and (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT)
          and (EFTTransactionRequest.Finished <> 0DT) then begin

          Handled := true; //We have already printed the merchant receipt (1) during the purchase transaction. So we manually print only customer receipt at end of trx.

          CreditCardTransaction.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
          CreditCardTransaction.FindFirst;
          CreditCardTransaction.SetRange("Receipt No.", CreditCardTransaction."Receipt No." + 1);
          CreditCardTransaction.FindSet;
          CreditCardTransaction.PrintTerminalReceipt();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;

        if not CODEUNIT.Run(CODEUNIT::"EFT Try Print Receipt", EftTransactionRequest) then
          Message(GetLastErrorText);
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        if EFTTransactionRequest."Card Name" <> '' then begin
          if (StrLen(EFTTransactionRequest."Card Number") > 8) then
            exit(StrSubstNo ('%1: %2', EFTTransactionRequest."Card Name", CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number")-7)))
          else
            exit(StrSubstNo(EFTTransactionRequest."Card Name"));
        end;

        if EFTTransactionRequest."Card Number" <> '' then
          exit(StrSubstNo(CARD, EFTTransactionRequest."Card Number"));

        if EFTTransactionRequest."Stored Value Account Type" <> '' then
          exit(EFTTransactionRequest."Stored Value Account Type");

        if EFTTransactionRequest."Payment Instrument Type" <> '' then
          exit(EFTTransactionRequest."Payment Instrument Type");

        exit(UNKNOWN);
    end;

    local procedure "// POS Unit specific parameters"()
    begin
    end;

    local procedure GetPOSUnitParameters(EFTSetup: Record "EFT Setup";var EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter")
    begin
        if not EFTVerifoneUnitParameter.Get(EFTSetup."POS Unit No.") then begin
          EFTVerifoneUnitParameter.Init;
          EFTVerifoneUnitParameter."POS Unit" := EFTSetup."POS Unit No.";
          EFTVerifoneUnitParameter.Insert;
        end;
    end;

    procedure GetLogLocation(EFTSetup: Record "EFT Setup"): Text
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Log Location");
    end;

    procedure GetLogLevel(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Log Level");
    end;

    procedure GetListeningPort(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Listening Port");
    end;

    procedure GetConnectionMode(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Connection Mode");
    end;

    procedure GetConnectionType(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Connection Type");
    end;

    procedure GetDefautlLanguage(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Default Language");
    end;

    procedure GetTerminalSerialNumber(EFTSetup: Record "EFT Setup"): Text
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Serial Number");
    end;

    procedure GetTerminalLANAddress(EFTSetup: Record "EFT Setup"): Text
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal LAN Address");
    end;

    procedure GetTerminalLANPort(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal LAN Port");
    end;

    procedure GetAutoCloseOnBalancing(EFTSetup: Record "EFT Setup"): Boolean
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Auto Close Terminal on EOD");
    end;

    procedure GetAutoOpenOnTransaction(EFTSetup: Record "EFT Setup"): Boolean
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Auto Open on Transaction");
    end;

    procedure GetAutoReconciliationOnClose(EFTSetup: Record "EFT Setup"): Boolean
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Auto Reconcile on Close");
    end;

    procedure GetAutoLoginAfterReconnect(EFTSetup: Record "EFT Setup"): Boolean
    var
        EFTVerifoneUnitParameter: Record "EFT Verifone Unit Parameter";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Auto Login After Reconnect");
    end;

    local procedure "// Payment Type specific parameters"()
    begin
    end;

    procedure GetPaymentTypeParameters(EFTSetup: Record "EFT Setup";var EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not EFTVerifonePaymentParameter.Get(EFTSetup."Payment Type POS") then begin
          EFTVerifonePaymentParameter.Init;
          EFTVerifonePaymentParameter."Payment Type POS" := EFTSetup."Payment Type POS";
          EFTVerifonePaymentParameter.Insert;
        end;
    end;

    procedure GetInitTimeout(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Initialize Timeout Seconds");
    end;

    procedure GetLoginTimeout(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Login Timeout Seconds");
    end;

    procedure GetLogoutTimeout(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Logout Timeout Seconds");
    end;

    procedure GetSetupTestTimeout(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Setup Test Timeout Seconds");
    end;

    procedure GetTransactionStatusTimeout(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Trx Lookup Timeout Seconds");
    end;

    procedure GetForceAbortMinimumDelay(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Force Abort Min. Delay Seconds");
    end;

    procedure GetDebugMode(EFTSetup: Record "EFT Setup"): Boolean
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Terminal Debug Mode");
    end;

    procedure GetReconciliationTimeout(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Reconciliation Timeout Seconds");
    end;

    procedure GetPreLoginDelay(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Pre Login Delay Seconds");
    end;

    procedure GetPostReconcileDelay(EFTSetup: Record "EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "EFT Verifone Payment Parameter";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Post Reconcile Delay Seconds");
    end;

    local procedure "// Protocol Response"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184527, 'OnAfterProtocolResponse', '', false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    var
        EFTInterface: Codeunit "EFT Interface";
        EFTPaymentMapping: Codeunit "EFT Payment Mapping";
        PaymentTypePOS: Record "Payment Type POS";
    begin
        if not EftTransactionRequest.Successful then begin
          if EftTransactionRequest."Processing Type" <> EftTransactionRequest."Processing Type"::AUXILIARY then begin
            Message(TRX_ERROR, IntegrationType(), Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Description", EftTransactionRequest."NST Error");
          end else begin
            Message(TRX_ERROR, IntegrationType(), Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Description", EftTransactionRequest."NST Error");
          end;
        end;

        if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::VOID) and (EftTransactionRequest.Successful) then
          Message(VOID_SUCCESS, EftTransactionRequest."Entry No.");


        if (EftTransactionRequest."Processing Type" in [EftTransactionRequest."Processing Type"::OPEN, EftTransactionRequest."Processing Type"::CLOSE]) and (EftTransactionRequest.Successful) then
          Message(OPERATION_SUCCESS, IntegrationType(), Format(EftTransactionRequest."Processing Type"));

        if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::SETUP) and (EftTransactionRequest.Successful) then
          Message(EftTransactionRequest."Result Display Text");

        //-NPR5.54 [364340]
        if EftTransactionRequest."Processing Type" in [EftTransactionRequest."Processing Type"::PAYMENT,
                                                       EftTransactionRequest."Processing Type"::REFUND,
                                                       EftTransactionRequest."Processing Type"::LOOK_UP,
                                                       EftTransactionRequest."Processing Type"::VOID] then begin
        //+NPR5.54 [364340]
          if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, PaymentTypePOS) then begin
            EftTransactionRequest."POS Payment Type Code" := PaymentTypePOS."No.";
            EftTransactionRequest."Card Name" := CopyStr(PaymentTypePOS.Description, 1, MaxStrLen (EftTransactionRequest."Card Name"));
          end;
          EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
          EftTransactionRequest.Modify;
        end;

        if (EftTransactionRequest.Successful)
          and (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::AUXILIARY)
          and (EftTransactionRequest."Auxiliary Operation ID" = 1) then begin
            Message(BALANCE_PROMPT, EftTransactionRequest."Result Amount", EftTransactionRequest."Currency Code", EftTransactionRequest."Card Expiry Date");
        end;

        if (EftTransactionRequest.Successful)
          and (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::AUXILIARY)
          and (EftTransactionRequest."Auxiliary Operation ID" = 2) then begin
            Message(OPERATION_SUCCESS, IntegrationType(), Format(EftTransactionRequest."Auxiliary Operation Desc."));
        end;

        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;
}

