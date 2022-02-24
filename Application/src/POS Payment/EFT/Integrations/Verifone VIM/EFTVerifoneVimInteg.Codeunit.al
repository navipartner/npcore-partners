codeunit 6184526 "NPR EFT Verifone Vim Integ."
{
    Access = Internal;
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

    local procedure IntegrationType(): Code[20]
    begin
        exit('VERIFONE_VIM');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := INTEGRATION_DESC;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Verifone Vim Integ.";
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin
        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := BALANCE_CHECK_DEC;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := RECONCILIATION;
        tmpEFTAuxOperation.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        Commit();
        PAGE.RunModal(PAGE::"NPR EFT Verifone Unit Param.", EFTVerifoneUnitParameter);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        Commit();
        PAGE.RunModal(PAGE::"NPR EFT Verifone Paym. Param.", EFTVerifonePaymentParameter);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateBeginWorkshiftRequest', '', false, false)]
    local procedure OnCreateBeginWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateEndWorkshiftRequest', '', false, false)]
    local procedure OnCreateEndWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateGiftCardLoadRequest', '', false, false)]
    local procedure OnCreateGiftCardLoadRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTrxRequest: Record "NPR EFT Transaction Request";
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        case EftTransactionRequest."Auxiliary Operation ID" of
            1:
                OnCreateBalanceEnquiryRequest(EftTransactionRequest, Handled);
            2:
                OnCreateReconciliationRequest(EftTransactionRequest, Handled);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTrxRequest: Record "NPR EFT Transaction Request";
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnQueueCloseBeforeRegisterBalance', '', false, false)]
    local procedure OnQueueCloseBeforeRegisterBalance(POSSession: Codeunit "NPR POS Session"; var tmpEFTSetup: Record "NPR EFT Setup" temporary)
    var
        EFTSetup: Record "NPR EFT Setup";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);

        EFTSetup.SetFilter("POS Unit No.", POSSetup.GetPOSUnitNo());
        EFTSetup.SetRange("EFT Integration Type", IntegrationType());
        if not EFTSetup.FindFirst() then begin
            EFTSetup.SetRange("POS Unit No.", '');
            if not EFTSetup.FindFirst() then
                exit;
        end;

        if not GetAutoCloseOnBalancing(EFTSetup) then
            exit;

        tmpEFTSetup := EFTSetup;
        tmpEFTSetup.Insert();
    end;

    local procedure OnCreateBalanceEnquiryRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        Handled := true;

        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    local procedure OnCreateReconciliationRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        Handled := true;

        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTVerifoneVimProtocol: Codeunit "NPR EFT Verifone Vim Prot.";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EFTVerifoneVimProtocol.SendEftDeviceRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrintReceipt', '', false, false)]
    local procedure OnPrintReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
    begin
        if not EFTTransactionRequest.IsType(IntegrationType()) then
            exit;

        if (EFTTransactionRequest."Authentication Method" = EFTTransactionRequest."Authentication Method"::Signature)
          and (EFTTransactionRequest."Signature Type" = EFTTransactionRequest."Signature Type"::"On Receipt")
          and (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT)
          and (EFTTransactionRequest.Finished <> 0DT) then begin

            Handled := true; //We have already printed the merchant receipt (1) during the purchase transaction. So we manually print only customer receipt at end of trx.

            CreditCardTransaction.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
            CreditCardTransaction.FindFirst();
            CreditCardTransaction.SetRange("Receipt No.", CreditCardTransaction."Receipt No." + 1);
            CreditCardTransaction.FindSet();
            CreditCardTransaction.PrintTerminalReceipt();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        if not CODEUNIT.Run(CODEUNIT::"NPR EFT Try Print Receipt", EftTransactionRequest) then
            Message(GetLastErrorText);
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        CardNumberLbl: Label '%1: %2', Locked = true;
    begin
        if EFTTransactionRequest."Card Name" <> '' then begin
            if (StrLen(EFTTransactionRequest."Card Number") > 8) then
                exit(StrSubstNo(CardNumberLbl, EFTTransactionRequest."Card Name", CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
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

    local procedure GetPOSUnitParameters(EFTSetup: Record "NPR EFT Setup"; var EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.")
    begin
        if not EFTVerifoneUnitParameter.Get(EFTSetup."POS Unit No.") then begin
            EFTVerifoneUnitParameter.Init();
            EFTVerifoneUnitParameter."POS Unit" := EFTSetup."POS Unit No.";
            EFTVerifoneUnitParameter.Insert();
        end;
    end;

    procedure GetLogLocation(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Log Location");
    end;

    procedure GetLogLevel(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Log Level");
    end;

    procedure GetListeningPort(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Listening Port");
    end;

    procedure GetConnectionMode(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Connection Mode");
    end;

    procedure GetConnectionType(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Connection Type");
    end;

    procedure GetDefautlLanguage(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Default Language");
    end;

    procedure GetTerminalSerialNumber(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal Serial Number");
    end;

    procedure GetTerminalLANAddress(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal LAN Address");
    end;

    procedure GetTerminalLANPort(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Terminal LAN Port");
    end;

    procedure GetAutoCloseOnBalancing(EFTSetup: Record "NPR EFT Setup"): Boolean
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Auto Close Terminal on EOD");
    end;

    procedure GetAutoOpenOnTransaction(EFTSetup: Record "NPR EFT Setup"): Boolean
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Auto Open on Transaction");
    end;

    procedure GetAutoReconciliationOnClose(EFTSetup: Record "NPR EFT Setup"): Boolean
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Auto Reconcile on Close");
    end;

    procedure GetAutoLoginAfterReconnect(EFTSetup: Record "NPR EFT Setup"): Boolean
    var
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        GetPOSUnitParameters(EFTSetup, EFTVerifoneUnitParameter);
        exit(EFTVerifoneUnitParameter."Auto Login After Reconnect");
    end;

    procedure GetPaymentTypeParameters(EFTSetup: Record "NPR EFT Setup"; var EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not EFTVerifonePaymentParameter.Get(EFTSetup."Payment Type POS") then begin
            EFTVerifonePaymentParameter.Init();
            EFTVerifonePaymentParameter."Payment Type POS" := EFTSetup."Payment Type POS";
            EFTVerifonePaymentParameter.Insert();
        end;
    end;

    procedure GetInitTimeout(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Initialize Timeout Seconds");
    end;

    procedure GetLoginTimeout(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Login Timeout Seconds");
    end;

    procedure GetLogoutTimeout(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Logout Timeout Seconds");
    end;

    procedure GetSetupTestTimeout(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Setup Test Timeout Seconds");
    end;

    procedure GetTransactionStatusTimeout(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Trx Lookup Timeout Seconds");
    end;

    procedure GetForceAbortMinimumDelay(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Force Abort Min. Delay Seconds");
    end;

    procedure GetDebugMode(EFTSetup: Record "NPR EFT Setup"): Boolean
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Terminal Debug Mode");
    end;

    procedure GetReconciliationTimeout(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Reconciliation Timeout Seconds");
    end;

    procedure GetPreLoginDelay(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Pre Login Delay Seconds");
    end;

    procedure GetPostReconcileDelay(EFTSetup: Record "NPR EFT Setup"): Integer
    var
        EFTVerifonePaymentParameter: Record "NPR EFT Verifone Paym. Param.";
    begin
        GetPaymentTypeParameters(EFTSetup, EFTVerifonePaymentParameter);
        exit(EFTVerifonePaymentParameter."Post Reconcile Delay Seconds");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Verifone Vim Prot.", 'OnAfterProtocolResponse', '', false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTInterface: Codeunit "NPR EFT Interface";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
    begin
        if not EftTransactionRequest.Successful then begin
            if EftTransactionRequest."Processing Type" <> EftTransactionRequest."Processing Type"::AUXILIARY then begin
                //TODO: Clean up workaround to BC17 message bug
                if not (EftTransactionRequest."Processing Type" in [EftTransactionRequest."Processing Type"::PAYMENT, EftTransactionRequest."Processing Type"::REFUND, EftTransactionRequest."Processing Type"::LOOK_UP]) then
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

        if EftTransactionRequest."Processing Type" in [EftTransactionRequest."Processing Type"::PAYMENT,
                                                       EftTransactionRequest."Processing Type"::REFUND,
                                                       EftTransactionRequest."Processing Type"::LOOK_UP,
                                                       EftTransactionRequest."Processing Type"::VOID] then begin
            if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, POSPaymentMethod) then begin
                EftTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
                EftTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftTransactionRequest."Card Name"));
            end;
            EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
            EftTransactionRequest.Modify();
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

