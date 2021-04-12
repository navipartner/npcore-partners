codeunit 6184517 "NPR EFT Adyen Cloud Integ."
{

    trigger OnRun()
    begin
    end;

    var
        Description: Label 'Adyen Cloud Terminal API';
        CARD: Label 'Card: %1';
        UNKNOWN: Label 'Unknown Electronic Payment Type';
        TRX_ERROR: Label '%1 failed\%2\%3\%4';
        VOID_SUCCESS: Label 'Transaction %1 voided successfully';
        ABORT_TRX: Label 'Abort Transaction';
        SIGNATURE_APPROVAL: Label 'Customer must sign the receipt. Please confirm that signature is valid';
        ACQUIRE_CARD: Label 'Acquire Card';
        ABORT_ACQUIRED: Label 'Abort Acquired Card';
        PRICE_CHANGED: Label 'Price changed after customer recognition:\Before: %1\After: %2';
        ABORT_ACQUIRED_FAIL: Label 'Could not abort transaction automatically. Please check terminal status before continuing.';
        CONTRACT_DUPLICATE: Label 'Card already has contract for %1 %2';
        DETECT_SHOPPER: Label 'Detect Shopper from Card';
        CLEAR_SHOPPER: Label 'Clear Shopper from Card';
        NO_SHOPPER_ON_CARD: Label 'No shopper associated with card';
        CLEAR_SHOPPER_PROMPT_MATCH: Label 'Disable contract with shopper?\Reference ID: %1\%2 No.: %3';
        CLEAR_SHOPPER_PROMPT: Label 'Disable contract with shopper?\Reference ID: %1';
        UNKNOWN_SHOPPER: Label 'Unknown shopper reference ID associated with card: %1';
        DISABLE_CONTRACT: Label 'Disable Shopper Recurring Contract';
        DISABLE_SHOPPER_SUCCESS: Label 'Shopper Reference Disabled: %1';

    procedure IntegrationType(): Text
    begin
        exit('ADYEN_CLOUD');
    end;

    local procedure "// EFT Interface implementation"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init;
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT Adyen Cloud Integ.";
        tmpEFTIntegrationType.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin
        //Any non standard EFT operations are registered here:

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := ABORT_TRX;
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := ACQUIRE_CARD;
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 3;
        tmpEFTAuxOperation.Description := ABORT_ACQUIRED;
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 4;
        tmpEFTAuxOperation.Description := DETECT_SHOPPER;
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 5;
        tmpEFTAuxOperation.Description := CLEAR_SHOPPER;
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 6;
        tmpEFTAuxOperation.Description := DISABLE_CONTRACT;
        tmpEFTAuxOperation.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
        EFTTypePOSUnitBLOBParam: Record "NPR EFTType POSUnit BLOBParam.";
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetPOIID(EFTSetup);

        EFTSetup.ShowEftPOSUnitParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetPaymentTypeParameters(EFTSetup, EFTAdyenPaymentTypeSetup);
        Commit;
        PAGE.RunModal(PAGE::"NPR EFT Adyen Paym. Type Setup", EFTAdyenPaymentTypeSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);

        RecurringContractCheckPreTransaction(EftTransactionRequest);

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        OriginalEftTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        if OriginalEftTransactionRequest."Processing Type" = OriginalEftTransactionRequest."Processing Type"::VOID then begin
            //Integration does not provide these values in void response so we copy manually
            EftTransactionRequest."Card Number" := OriginalEftTransactionRequest."Card Number";
            EftTransactionRequest."Card Name" := OriginalEftTransactionRequest."Card Name";
            EftTransactionRequest."Card Application ID" := OriginalEftTransactionRequest."Card Application ID";
            EftTransactionRequest."Card Issuer ID" := OriginalEftTransactionRequest."Card Issuer ID";
        end;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        if EftTransactionRequest."Processed Entry No." <> 0 then begin
            OriginalEftTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
            if OriginalEftTransactionRequest.Recovered then
                OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Recovered by Entry No.");
        end;

        EftTransactionRequest."Amount Input" := Abs(EftTransactionRequest."Amount Input");

        CreateGenericRequest(EftTransactionRequest);

        RecurringContractCheckPreTransaction(EftTransactionRequest);

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        OriginalEftTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        if OriginalEftTransactionRequest.Recovered then
            OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Recovered by Entry No.");

        //Integration does not provide these values in void response so we copy manually
        EftTransactionRequest."Card Number" := OriginalEftTransactionRequest."Card Number";
        EftTransactionRequest."Card Name" := OriginalEftTransactionRequest."Card Name";
        EftTransactionRequest."Card Application ID" := OriginalEftTransactionRequest."Card Application ID";
        EftTransactionRequest."Card Issuer ID" := OriginalEftTransactionRequest."Card Issuer ID";

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVerifySetupRequest', '', false, false)]
    local procedure OnCreateVerifySetupRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot.";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        if AcquireCardBeforeTransaction(EftTransactionRequest) then
            exit;

        EFTAdyenCloudProtocol.SendEftDeviceRequest(EftTransactionRequest, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        if not CODEUNIT.Run(CODEUNIT::"NPR EFT Try Print Receipt", EftTransactionRequest) then
            Message(GetLastErrorText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterPaymentConfirm', '', false, false)]
    local procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "NPR EFT Transaction Request"; var DoNotResume: Boolean)
    var
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot.";
        EFTAdyenCloudSignDialog: Codeunit "NPR EFT Adyen Cloud Sign Dia.";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        case EftTransactionRequest."Signature Type" of
            EftTransactionRequest."Signature Type"::"On Receipt":
                if not Confirm(SIGNATURE_APPROVAL) then begin
                    VoidTransactionAfterSignatureDecline(EftTransactionRequest);
                end;

            EftTransactionRequest."Signature Type"::"On Terminal":
                begin
                    DoNotResume := true; //Since the approval is async, we postpone resume of front end workflow for now.
                    EFTAdyenCloudSignDialog.ApproveSignature(EftTransactionRequest);
                end;

            EftTransactionRequest."Signature Type"::"On POS":
                Error('Signature written in POS is not supported');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnBeforePauseFrontEnd', '', false, false)]
    local procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin
        if not EFTTransactionRequest.IsType(IntegrationType()) then
            exit;

        with EFTTransactionRequest do
            Skip :=
          ("Processing Type" in ["Processing Type"::SETUP, "Processing Type"::VOID, "Processing Type"::LOOK_UP]);

        //POS is not robust against Pause & Resume without client ping-pong so we skip both for SETUP,VOID,LOOKUP operations as they are all server-side synchronous API requests in Adyen
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnBeforeResumeFrontEnd', '', false, false)]
    local procedure OnBeforeResumeFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            exit;
        if not EFTTransactionRequest.IsType(IntegrationType()) then
            exit;

        with EFTTransactionRequest do
            Skip := (("Processing Type" = EFTTransactionRequest."Processing Type"::AUXILIARY) and ("Auxiliary Operation ID" in [1, 2, 3, 6]))
                    or (("Processing Type" in ["Processing Type"::SETUP, "Processing Type"::VOID, "Processing Type"::LOOK_UP]) and (not POSFrontEnd.IsPaused));

        //POS is not robust against Pause & Resume without client ping-pong so we skip both for SETUP,VOID,LOOKUP operations as they are all server-side synchronous API requests in Adyen
    end;

    procedure HandleProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
    begin
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT,
          EftTransactionRequest."Processing Type"::REFUND,
          EftTransactionRequest."Processing Type"::LOOK_UP:
                HandleTrxResponse(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::VOID:
                HandleVoidResponse(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::SETUP:
                HandleSetupResponse(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    1, 2, 3:
                        ;
                    4, 5:
                        HandleDetectShopperResponse(EftTransactionRequest);
                    6:
                        HandleClearShopperContractResponse(EftTransactionRequest);
                end;
        end;

        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    local procedure HandleTrxResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
    begin
        /*
        TODO: Cleanup workaround to BC17 message bug.

        if (not EftTransactionRequest.Successful) and
          ((not EftTransactionRequest."Self Service") or (not EftTransactionRequest."External Result Known")) then begin
            Message(TRX_ERROR, Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Description", EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
        end;
        */

        if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, POSPaymentMethod) then begin
            EftTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
            EftTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftTransactionRequest."Card Name"));
        end;
        EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
        EftTransactionRequest.Modify;
    end;

    local procedure HandleVoidResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        VoidedTrx: Record "NPR EFT Transaction Request";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
    begin
        if EftTransactionRequest.Successful then begin
            if (not EftTransactionRequest."Self Service") then
                Message(VOID_SUCCESS, EftTransactionRequest."Entry No.");

            if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, POSPaymentMethod) then begin
                EftTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
                EftTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftTransactionRequest."Card Name"));
            end;
            EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
            EftTransactionRequest.Modify;

        end else begin
            if (not EftTransactionRequest."Self Service") or (not EftTransactionRequest."External Result Known") then
                Message(TRX_ERROR, Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Description", EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
        end;
    end;

    local procedure HandleSetupResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
            Message(EftTransactionRequest."Result Display Text")
        else
            Message(TRX_ERROR, Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Description", EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    local procedure HandleDetectShopperResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if not EftTransactionRequest.Successful then
            Message(TRX_ERROR, Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Description", EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    local procedure HandleClearShopperContractResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
            Message(DISABLE_SHOPPER_SUCCESS, EftTransactionRequest."External Customer ID")
        else
            Message(TRX_ERROR, Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Description", EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    #region EFT Parameter Handling

    procedure GetAPIKey(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."API Key");
    end;

    procedure GetEnvironment(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup.Environment);
    end;

    procedure GetPOIID(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."POS Unit No.", 'POI ID', '', true));
    end;

    procedure GetTransactionCondition(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Transaction Condition");
    end;

    procedure GetCreateRecurringContract(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Create Recurring Contract");
    end;

    procedure GetAcquireCardFirst(EFTSetupIn: Record "NPR EFT Setup"): Boolean
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Acquire Card First");
    end;

    procedure GetLogLevel(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Log Level");
    end;

    local procedure GetPaymentTypeParameters(EFTSetup: Record "NPR EFT Setup"; var EFTAdyenPaymentTypeSetupOut: Record "NPR EFT Adyen Paym. Type Setup")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not EFTAdyenPaymentTypeSetupOut.Get(EFTSetup."Payment Type POS") then begin
            EFTAdyenPaymentTypeSetupOut.Init;
            EFTAdyenPaymentTypeSetupOut."Payment Type POS" := EFTSetup."Payment Type POS";
            EFTAdyenPaymentTypeSetupOut.Insert;
        end;
    end;

    local procedure GetSilentDiscountAllowed(EFTSetupIn: Record "NPR EFT Setup"): Boolean
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Silent Discount Allowed");
    end;

    procedure GetCaptureDelayHours(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Capture Delay Hours");
    end;

    local procedure GetCashbackAllowed(EFTSetupIn: Record "NPR EFT Setup"): Boolean
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Cashback Allowed");
    end;

    procedure GetMerchantAccount(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Merchant Account");
    end;

    procedure GetRecurringURLPrefix(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        EFTAdyenPaymentTypeSetup.TestField("Recurring API URL Prefix");
        exit(EFTAdyenPaymentTypeSetup."Recurring API URL Prefix");
    end;

    procedure GetUnattended(EFTSetupIn: Record "NPR EFT Setup"): Boolean
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup.Unattended);
    end;

    #endregion

    #region Aux

    local procedure CreateGenericRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");

        EFTTransactionRequest."Integration Version Code" := '3.0'; //Adyen Terminal API Protocol v3.0
        EFTTransactionRequest."Hardware ID" := GetPOIID(EFTSetup);
        if GetEnvironment(EFTSetup) <> 0 then
            EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";

        if not GetCashbackAllowed(EFTSetup) then
            EFTTransactionRequest.TestField("Cashback Amount", 0);

        EFTTransactionRequest."Self Service" := GetUnattended(EFTSetup);
    end;

    procedure VoidTransactionAfterSignatureDecline(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        EFTFrameworkMgt.CreateVoidRequest(VoidEFTTransactionRequest, EFTSetup, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.", EFTTransactionRequest."Entry No.", false);
        Commit;
        EFTFrameworkMgt.SendRequest(VoidEFTTransactionRequest);
    end;

    local procedure AcquireCardBeforeTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        AcquireCardEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        if not (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then
            exit(false);

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if not (GetAcquireCardFirst(EFTSetup) or (GetCreateRecurringContract(EFTSetup) <> 0)) then
            exit(false);

        if not POSSession.IsActiveSession(POSFrontEndManagement) then
            exit(false);
        POSFrontEndManagement.GetSession(POSSession);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        EFTFrameworkMgt.CreateAuxRequest(AcquireCardEFTTransactionRequest, EFTSetup, 2, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        AcquireCardEFTTransactionRequest."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
        AcquireCardEFTTransactionRequest.Modify;
        EFTTransactionRequest.Recoverable := false; //Not recoverable if we fail on card acquisition, since it never started externally.
        EFTTransactionRequest.Modify;
        Commit;
        EFTFrameworkMgt.SendRequest(AcquireCardEFTTransactionRequest);
        exit(true);
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        if EFTTransactionRequest."Card Name" <> '' then begin
            if (StrLen(EFTTransactionRequest."Card Number") > 8) then
                exit(StrSubstNo('%1: %2', EFTTransactionRequest."Card Name", CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
            else
                exit(StrSubstNo(EFTTransactionRequest."Card Name"));
        end;

        if EFTTransactionRequest."Stored Value Account Type" <> '' then
            exit(EFTTransactionRequest."Stored Value Account Type");

        if EFTTransactionRequest."Payment Instrument Type" <> '' then
            exit(EFTTransactionRequest."Payment Instrument Type");

        if EFTTransactionRequest."Card Number" <> '' then
            exit(StrSubstNo(CARD, EFTTransactionRequest."Card Number"));

        exit(UNKNOWN);
    end;

    local procedure RecurringContractCheckPreTransaction(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if GetCreateRecurringContract(EFTSetup) = 0 then
            exit;

        POSSession.GetSession(POSSession, true);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No."); //Customer is required to issue recurring contract

        EFTShopperRecognition.SetRange("Integration Type", IntegrationType());
        EFTShopperRecognition.SetRange("Entity Key", SalePOS."Customer No.");
        if SalePOS."Customer Type" = SalePOS."Customer Type"::Cash then
            EFTShopperRecognition.SetRange("Entity Type", EFTShopperRecognition."Entity Type"::Contact)
        else
            EFTShopperRecognition.SetRange("Entity Type", EFTShopperRecognition."Entity Type"::Customer);

        if not EFTShopperRecognition.FindFirst then begin
            EFTShopperRecognition.Init;
            EFTShopperRecognition."Integration Type" := IntegrationType();
            EFTShopperRecognition."Shopper Reference" := CopyStr(Format(CreateGuid), 2, 36);
            EFTShopperRecognition."Entity Key" := SalePOS."Customer No.";
            if SalePOS."Customer Type" = SalePOS."Customer Type"::Cash then
                EFTShopperRecognition."Entity Type" := EFTShopperRecognition."Entity Type"::Contact
            else
                EFTShopperRecognition."Entity Type" := EFTShopperRecognition."Entity Type"::Customer;
            EFTShopperRecognition.Insert;
        end;

        EFTTransactionRequest."Internal Customer ID" := EFTShopperRecognition."Shopper Reference";
    end;

    procedure ContinueAfterAcquireCard(POSSession: Codeunit "NPR POS Session"; TransactionEntryNo: Integer; var ContinueOnTransactionEntryNo: Integer): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        BeforeAmount: Decimal;
        AfterAmount: Decimal;
        POSSale: Codeunit "NPR POS Sale";
    begin
        if not EFTTransactionRequest.Get(TransactionEntryNo) then
            exit(false);

        if EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::AUXILIARY then
            exit(false);

        case EFTTransactionRequest."Auxiliary Operation ID" of
            2:
                begin
                    exit(ShouldProceedToPurchaseTransaction(POSSession, EFTTransactionRequest, ContinueOnTransactionEntryNo));
                end;
            4:
                begin
                    DetectShopper(POSSession, EFTTransactionRequest);
                    exit(false);
                end;
            5:
                begin
                    ClearShopperContract(POSSession, EFTTransactionRequest);
                    exit(false);
                end;
            else
                EFTTransactionRequest.FieldError("Auxiliary Operation ID");
        end;
    end;

    local procedure ShouldProceedToPurchaseTransaction(POSSession: Codeunit "NPR POS Session"; EFTTransactionRequest: Record "NPR EFT Transaction Request"; var ContinueOnTransactionEntryNo: Integer): Boolean
    var
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot.";
        EFTPaymentTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTTransactionRequest.Successful then
            exit(false);

        if not ContinueAfterShopperRecognition(EFTTransactionRequest, POSSession) then
            exit(false);

        if CancelContractCreation(EFTTransactionRequest, POSSession) then
            exit(false);

        EFTPaymentTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        EFTPaymentTransactionRequest.Recoverable := true;
        EFTPaymentTransactionRequest.Modify;
        Commit;
        EFTAdyenCloudProtocol.SendEftDeviceRequest(EFTPaymentTransactionRequest, true);
        ContinueOnTransactionEntryNo := EFTPaymentTransactionRequest."Entry No.";
        exit(true);
    end;

    local procedure ClearShopperContract(POSSession: Codeunit "NPR POS Session"; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot.";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        DisableEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
    begin
        if not (EFTTransactionRequest.Successful) then
            exit;

        AbortAcquireCard(EFTTransactionRequest, '');

        if EFTTransactionRequest."External Customer ID" = '' then begin
            Message(NO_SHOPPER_ON_CARD);
            exit;
        end;

        if EFTShopperRecognition.Get(IntegrationType(), EFTTransactionRequest."External Customer ID") then begin
            if not Confirm(CLEAR_SHOPPER_PROMPT_MATCH, false, EFTTransactionRequest."External Customer ID", EFTShopperRecognition."Entity Type", EFTShopperRecognition."Entity Key") then
                exit;
        end else begin
            if not Confirm(CLEAR_SHOPPER_PROMPT, false, EFTTransactionRequest."External Customer ID") then
                exit;
        end;

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        EFTFrameworkMgt.CreateAuxRequest(DisableEFTTransactionRequest, EFTSetup, 6, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        DisableEFTTransactionRequest."External Customer ID" := EFTTransactionRequest."External Customer ID";
        DisableEFTTransactionRequest."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
        DisableEFTTransactionRequest.Modify;
        Commit;
        EFTFrameworkMgt.SendRequest(DisableEFTTransactionRequest);
    end;

    local procedure ContinueAfterShopperRecognition(EFTTransactionRequest: Record "NPR EFT Transaction Request"; POSSession: Codeunit "NPR POS Session"): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        BeforeAmount: Decimal;
        AfterAmount: Decimal;
    begin
        POSSession.GetSale(POSSale);

        BeforeAmount := GetRemainingPaymentSuggestion(EFTTransactionRequest, POSSession);
        if DetectShopperSilent(EFTTransactionRequest, POSSale) then begin
            AfterAmount := GetRemainingPaymentSuggestion(EFTTransactionRequest, POSSession);
            if BeforeAmount <> AfterAmount then begin
                exit(HandleAcquireCardPriceChange(EFTTransactionRequest, BeforeAmount, AfterAmount));
            end;
        end;

        exit(true);
    end;

    local procedure DetectShopper(POSSession: Codeunit "NPR POS Session"; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
    begin
        if not (EFTTransactionRequest.Successful) then
            exit;

        AbortAcquireCard(EFTTransactionRequest, '');

        if EFTTransactionRequest."External Customer ID" = '' then begin
            Message(NO_SHOPPER_ON_CARD);
            exit;
        end;

        if not EFTShopperRecognition.Get(IntegrationType(), EFTTransactionRequest."External Customer ID") then begin
            Message(UNKNOWN_SHOPPER, EFTTransactionRequest."External Customer ID");
            exit;
        end;

        Commit;
        if not CODEUNIT.Run(CODEUNIT::"NPR EFT Try Add Shopper", EFTShopperRecognition) then
            Message(GetLastErrorText);
    end;

    local procedure DetectShopperSilent(EftTransactionRequest: Record "NPR EFT Transaction Request"; POSSale: Codeunit "NPR POS Sale"): Boolean
    var
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        SalePOS: Record "NPR POS Sale";
    begin
        if EftTransactionRequest."External Customer ID" = '' then
            exit(false);

        if not EFTShopperRecognition.Get(IntegrationType(), EftTransactionRequest."External Customer ID") then
            exit(false);

        POSSale.GetCurrentSale(SalePOS);
        if (SalePOS."Customer No." <> '') then
            exit(false);

        Commit;
        exit(CODEUNIT.Run(CODEUNIT::"NPR EFT Try Add Shopper", EFTShopperRecognition));
    end;

    local procedure GetRemainingPaymentSuggestion(EFTTransactionRequest: Record "NPR EFT Transaction Request"; POSSession: Codeunit "NPR POS Session"): Decimal
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);

        if not POSPaymentMethod.Get(EFTTransactionRequest."Original POS Payment Type Code") then
            Error('%1 %2 could not be retrieved. This is a programming bug, not a user error.', POSPaymentMethod.TableCaption, EFTTransactionRequest."Original POS Payment Type Code");

        exit(POSPaymentLine.CalculateRemainingPaymentSuggestionInCurrentSale(POSPaymentMethod));
    end;

    local procedure HandleAcquireCardPriceChange(EFTTransactionRequest: Record "NPR EFT Transaction Request"; BeforeAmount: Decimal; AfterAmount: Decimal): Boolean
    var
        EFTSetup: Record "NPR EFT Setup";
        SilentAllowed: Boolean;
        EFTPaymentTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        SilentAllowed := GetSilentDiscountAllowed(EFTSetup);

        EFTPaymentTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        if (0 < BeforeAmount) and (0 < AfterAmount) and (AfterAmount < BeforeAmount) and (EFTPaymentTransactionRequest."Amount Input" = BeforeAmount) and (SilentAllowed) then begin
            EFTPaymentTransactionRequest."Amount Input" := AfterAmount;
            EFTPaymentTransactionRequest.Modify;
            Commit;

            exit(true); //Positive amount before and after, original payment was on full remaining amount, and silent allowed is set.
        end;

        AbortAcquireCard(EFTTransactionRequest, StrSubstNo(PRICE_CHANGED, BeforeAmount, AfterAmount));
        exit(false);
    end;

    local procedure AbortAcquireCard(EFTTransactionRequest: Record "NPR EFT Transaction Request"; Reason: Text)
    var
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        AbortAttempts: Integer;
        Aborted: Boolean;
    begin
        while (not Aborted) and (AbortAttempts < 2) do begin
            Aborted := SendAbortAcquireCardRequest(EFTTransactionRequest);
            AbortAttempts += 1;
            Sleep(500);
        end;

        if Reason <> '' then
            Message(Reason);

        ProcessOriginalTrxAfterAcquireCardFailure(EFTTransactionRequest);

        if not Aborted then
            Message(ABORT_ACQUIRED_FAIL);
    end;

    procedure AbortTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request"; RegisterNo: Text; SalesTicketNo: Text): Boolean
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        AbortEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(RegisterNo, EFTTransactionRequest."Original POS Payment Type Code");

        EFTFrameworkMgt.CreateAuxRequest(AbortEFTTransactionRequest, EFTSetup, 1, RegisterNo, SalesTicketNo);
        AbortEFTTransactionRequest."Processed Entry No." := EFTTransactionRequest."Entry No.";
        AbortEFTTransactionRequest.Modify;
        Commit;
        EFTFrameworkMgt.SendRequest(AbortEFTTransactionRequest);
        AbortEFTTransactionRequest.Find;
        exit(AbortEFTTransactionRequest.Successful);
    end;

    local procedure SendAbortAcquireCardRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        AbortEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        EFTFrameworkMgt.CreateAuxRequest(AbortEFTTransactionRequest, EFTSetup, 3, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        AbortEFTTransactionRequest."Processed Entry No." := EFTTransactionRequest."Entry No.";
        AbortEFTTransactionRequest.Modify;
        Commit;
        EFTFrameworkMgt.SendRequest(AbortEFTTransactionRequest);
        AbortEFTTransactionRequest.Find;
        exit(AbortEFTTransactionRequest.Successful);
    end;

    local procedure CancelContractCreation(EFTTransactionRequest: Record "NPR EFT Transaction Request"; POSSession: Codeunit "NPR POS Session"): Boolean
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        CurrentShopperRef: Text;
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if GetCreateRecurringContract(EFTSetup) = 0 then
            exit(false);

        if EFTTransactionRequest."External Customer ID" <> '' then begin
            CurrentShopperRef := EFTTransactionRequest."External Customer ID";
            if EFTShopperRecognition.Get(IntegrationType(), EFTTransactionRequest."External Customer ID") then
                CurrentShopperRef += StrSubstNo(', %1 %2', Format(EFTShopperRecognition."Entity Type"), EFTShopperRecognition."Entity Key");
            AbortAcquireCard(EFTTransactionRequest, StrSubstNo(CONTRACT_DUPLICATE, EFTShopperRecognition.FieldCaption("Shopper Reference"), CurrentShopperRef));
            exit(true);
        end;

        exit(false);
    end;

    procedure ProcessOriginalTrxAfterAcquireCardFailure(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if (EFTTransactionRequest."Initiated from Entry No." = 0) then
            exit;
        if (EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::AUXILIARY) then
            exit;
        if (EFTTransactionRequest."Auxiliary Operation ID" <> 2) then
            exit;

        OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        OriginalEFTTransactionRequest."External Result Known" := true; //We know the primary transaction "failed correctly" since we never started it in the first place.
        OriginalEFTTransactionRequest.Recoverable := false; //Not recoverable since we never started it in the first place.
        OriginalEFTTransactionRequest."NST Error" := EFTTransactionRequest."NST Error";
        OriginalEFTTransactionRequest."Result Description" := EFTTransactionRequest."Result Description";
        OriginalEFTTransactionRequest."Result Display Text" := EFTTransactionRequest."Result Display Text";
        OriginalEFTTransactionRequest.Modify;
        HandleProtocolResponse(OriginalEFTTransactionRequest);
    end;
    #endregion
}

