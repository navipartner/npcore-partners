codeunit 6184517 "EFT Adyen Cloud Integration"
{
    // NPR5.48/MMV /20190124 CASE 341237 Created object
    // NPR5.49/MMV /20190219 CASE 345188 Added AcquireCard support
    //                                   Moved payment type parameters to adyen specific table to mask API key.
    // NPR5.49/MMV /20190410 CASE 347476 Get log level
    // NPR5.50/MMV /20190430 CASE 352465 Added support for silent price reduction after customer recognition.


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
        PRICE_CHANGED: Label 'Price changed after customer recognition';
        ABORT_ACQUIRED_FAIL: Label 'Could not abort transaction automatically. Please check terminal status before continuing.';

    local procedure IntegrationType(): Text
    begin
        exit('ADYEN_CLOUD');
    end;

    local procedure "// EFT Interface implementation"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init;
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"EFT Adyen Cloud Integration";
        tmpEFTIntegrationType.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "EFT Aux Operation" temporary)
    begin
        //Any non standard EFT operations are registered here:

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := ABORT_TRX;
        tmpEFTAuxOperation.Insert;

        //-NPR5.49 [345188]
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
        //+NPR5.49 [345188]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "EFT Setup")
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
        EFTTypePOSUnitBLOBParam: Record "EFT Type POS Unit BLOB Param.";
        Blob1: Record TempBlob temporary;
        Blob2: Record TempBlob temporary;
        EFTInterface: Codeunit "EFT Interface";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
          exit;

        GetPOIID(EFTSetup);

        EFTSetup.ShowEftPOSUnitParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "EFT Setup")
    var
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
          exit;

        //-NPR5.49 [345188]
        // GetAPIUser(EFTSetup);
        // GetAPIPassword(EFTSetup);
        // GetEnvironment(EFTSetup);
        // GetTransactionCondition(EFTSetup);
        // GetSelfService(EFTSetup);
        // GetCreateRecurringContract(EFTSetup);

        //EFTSetup.ShowEftPaymentParameters();

        GetPaymentTypeParameters(EFTSetup, EFTAdyenPaymentTypeSetup);
        Commit;
        PAGE.RunModal(PAGE::"EFT Adyen Payment Type Setup", EFTAdyenPaymentTypeSetup);
        //+NPR5.49 [345188]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        //-NPR5.49 [345188]
        RecurringContractCheckPreTransaction(EftTransactionRequest);
        //+NPR5.49 [345188]
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    var
        OriginalEftTransactionRequest: Record "EFT Transaction Request";
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
        //-NPR5.49 [345188]
        RecurringContractCheckPreTransaction(EftTransactionRequest);
        //+NPR5.49 [345188]
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVerifySetupRequest', '', false, false)]
    local procedure OnCreateVerifySetupRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
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
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
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
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    var
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        //-NPR5.49 [345188]
        if AcquireCardBeforeTransaction(EftTransactionRequest) then
          exit;
        //+NPR5.49 [345188]

        EFTAdyenCloudProtocol.SendEftDeviceRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;

        //-NPR5.49 [345188]
        //EftTransactionRequest.PrintReceipts(FALSE);
        if not CODEUNIT.Run(CODEUNIT::"EFT Try Print Receipt", EftTransactionRequest) then
          Message(GetLastErrorText);
        //+NPR5.49 [345188]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterPaymentConfirm', '', false, false)]
    local procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "EFT Transaction Request";var DoNotResume: Boolean)
    var
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
        EFTAdyenCloudSignDialog: Codeunit "EFT Adyen Cloud Sign Dialog";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;

        case EftTransactionRequest."Signature Type" of
          EftTransactionRequest."Signature Type"::"On Receipt" :
            if not Confirm(SIGNATURE_APPROVAL) then begin
              VoidTransactionAfterSignatureDecline(EftTransactionRequest);
            end;

          EftTransactionRequest."Signature Type"::"On Terminal" :
            begin
              DoNotResume := true; //Since the approval is async, we postpone resume of front end workflow for now.
              EFTAdyenCloudSignDialog.ApproveSignature(EftTransactionRequest);
            end;

          EftTransactionRequest."Signature Type"::"On POS" :
            Error('Signature written in POS is not supported');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnBeforePauseFrontEnd', '', false, false)]
    local procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "EFT Transaction Request";var Skip: Boolean)
    begin
        if not EFTTransactionRequest.IsType(IntegrationType()) then
          exit;

        with EFTTransactionRequest do
            Skip := ("Processing Type" in ["Processing Type"::Setup, "Processing Type"::Void, "Processing Type"::xLookup]);

        //These requests are synchronous - which crashes the front end if we pause/resume.
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnBeforeResumeFrontEnd', '', false, false)]
    local procedure OnBeforeResumeFrontEnd(EFTTransactionRequest: Record "EFT Transaction Request";var Skip: Boolean)
    var
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
          exit;
        if not EFTTransactionRequest.IsType(IntegrationType()) then
          exit;

        with EFTTransactionRequest do
            Skip := ("Processing Type" in ["Processing Type"::Setup, "Processing Type"::Void, "Processing Type"::xLookup]) and (not POSFrontEnd.IsPaused);

        //These requests are synchronous - which crashes the front end if we pause/resume.
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnBeforeLookupPrompt', '', false, false)]
    local procedure OnBeforeLookupPrompt(EFTTransactionRequest: Record "EFT Transaction Request";var Skip: Boolean)
    begin
        if not EFTTransactionRequest.IsType(IntegrationType()) then
          exit;

        Skip := true; //Remove this when pos front end doesn't crash for synchronous lookups.
    end;

    local procedure "// Protocol Response"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184518, 'OnAfterProtocolResponse', '', false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    var
        EFTInterface: Codeunit "EFT Interface";
        EFTPaymentMapping: Codeunit "EFT Payment Mapping";
        PaymentTypePOS: Record "Payment Type POS";
    begin
        if not EftTransactionRequest.Successful then
          Message(TRX_ERROR, Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Description", EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");

        if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::Void) and (EftTransactionRequest.Successful) then
          Message(VOID_SUCCESS, EftTransactionRequest."Entry No.");

        if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::Setup) and (EftTransactionRequest.Successful) then
          Message(EftTransactionRequest."Result Display Text");

        if EftTransactionRequest."Processing Type" in [EftTransactionRequest."Processing Type"::Payment, EftTransactionRequest."Processing Type"::Refund, EftTransactionRequest."Processing Type"::xLookup] then begin
          if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, PaymentTypePOS) then begin
            EftTransactionRequest."POS Payment Type Code" := PaymentTypePOS."No.";
            EftTransactionRequest."Card Name" := CopyStr(PaymentTypePOS.Description, 1, MaxStrLen (EftTransactionRequest."Card Name"));
          end;
        //-NPR5.49 [345188]
        //  EftTransactionRequest."POS Description" := GetPOSDescription(EftTransactionRequest);
          EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
        //+NPR5.49 [345188]
          EftTransactionRequest.Modify;
        end;

        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    local procedure "// EFT Parameter Handling"()
    begin
    end;

    procedure GetAPIKey(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        //-NPR5.49 [345188]
        //EXIT(EFTTypePaymentGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."Payment Type POS", 'Password', '', TRUE));
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."API Key");
        //+NPR5.49 [345188]
    end;

    procedure GetEnvironment(EFTSetupIn: Record "EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        //-NPR5.49 [345188]
        //EXIT(EFTTypePaymentGenParam.GetOptionParameterValue(IntegrationType(), EFTSetupIn."Payment Type POS", 'Environment', 0, 'PROD,DEMO', TRUE));
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup.Environment);
        //+NPR5.49 [345188]
    end;

    procedure GetPOIID(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTTypePOSUnitGenParam: Record "EFT Type POS Unit Gen. Param.";
    begin
        exit(EFTTypePOSUnitGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."POS Unit No.", 'POI ID', '', true));
    end;

    procedure GetTransactionCondition(EFTSetupIn: Record "EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        //-NPR5.49 [345188]
        //EXIT(EFTTypePaymentGenParam.GetOptionParameterValue(IntegrationType(), EFTSetupIn."Payment Type POS", 'Transaction Condition', 0, ',AliPay,WeChat,GiftCard', TRUE));
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Transaction Condition");
        //+NPR5.49 [345188]
    end;

    procedure GetCreateRecurringContract(EFTSetupIn: Record "EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        //-NPR5.49 [345188]
        //EXIT(EFTTypePaymentGenParam.GetBooleanParameterValue(IntegrationType(), EFTSetupIn."Payment Type POS", 'Create Recurring Contract', FALSE, TRUE));
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Create Recurring Contract");
        //+NPR5.49 [345188]
    end;

    procedure GetAcquireCardFirst(EFTSetupIn: Record "EFT Setup"): Boolean
    var
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        //-NPR5.49 [345188]
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Acquire Card First");
        //+NPR5.49 [345188]
    end;

    procedure GetLogLevel(EFTSetupIn: Record "EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        //-NPR5.49 [347476]
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Log Level");
        //+NPR5.49 [347476]
    end;

    local procedure GetPaymentTypeParameters(EFTSetup: Record "EFT Setup";var EFTAdyenPaymentTypeSetupOut: Record "EFT Adyen Payment Type Setup")
    begin
        //-NPR5.49 [345188]
        EFTSetup.TestField("Payment Type POS");

        if not EFTAdyenPaymentTypeSetupOut.Get(EFTSetup."Payment Type POS") then begin
          EFTAdyenPaymentTypeSetupOut.Init;
          EFTAdyenPaymentTypeSetupOut."Payment Type POS" := EFTSetup."Payment Type POS";
          EFTAdyenPaymentTypeSetupOut.Insert;
        end;
        //+NPR5.49 [345188]
    end;

    local procedure GetSilentDiscountAllowed(EFTSetupIn: Record "EFT Setup"): Boolean
    var
        EFTAdyenPaymentTypeSetup: Record "EFT Adyen Payment Type Setup";
    begin
        //-NPR5.50 [352465]
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Silent Discount Allowed");
        //+NPR5.50 [352465]
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure CreateGenericRequest(var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTSetup: Record "EFT Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");

        EFTTransactionRequest."Integration Version Code" := '3.0'; //Adyen Terminal API Protocol v3.0
        EFTTransactionRequest."Hardware ID" := GetPOIID(EFTSetup);
        //-NPR5.49 [345188]
        //EFTTransactionRequest."Self Service" := GetSelfService(EFTSetup);
        //+NPR5.49 [345188]
        if GetEnvironment(EFTSetup) <> 0 then
          EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";
    end;

    procedure VoidTransactionAfterSignatureDecline(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTSetup: Record "EFT Setup";
        VoidEFTTransactionRequest: Record "EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        EFTFrameworkMgt.CreateVoidRequest(VoidEFTTransactionRequest, EFTSetup, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.", EFTTransactionRequest."Entry No.", false);
        //-NPR5.49 [345188]
        Commit;
        //+NPR5.49 [345188]
        EFTFrameworkMgt.SendRequest(VoidEFTTransactionRequest);
    end;

    local procedure AcquireCardBeforeTransaction(EFTTransactionRequest: Record "EFT Transaction Request"): Boolean
    var
        EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
        AcquireCardEFTTransactionRequest: Record "EFT Transaction Request";
        EFTSetup: Record "EFT Setup";
        POSSession: Codeunit "POS Session";
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.49 [345188]
        if not (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::Payment, EFTTransactionRequest."Processing Type"::Refund]) then
          exit(false);

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if not GetAcquireCardFirst(EFTSetup) then
          exit(false);

        if not POSSession.IsActiveSession(POSFrontEndManagement) then
          exit(false);
        POSFrontEndManagement.GetSession(POSSession);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."Customer No." <> '' then
          exit(false);

        EFTFrameworkMgt.CreateAuxRequest(AcquireCardEFTTransactionRequest, EFTSetup, 2, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        AcquireCardEFTTransactionRequest."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
        AcquireCardEFTTransactionRequest.Modify;
        Commit;
        EFTFrameworkMgt.SendRequest(AcquireCardEFTTransactionRequest);
        exit(true);
        //+NPR5.49 [345188]
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        if EFTTransactionRequest."Card Name" <> '' then begin
          if (StrLen(EFTTransactionRequest."Card Number") > 8) then
        //-NPR5.49 [345188]
        //    EXIT(STRSUBSTNO ('%1: %2', COPYSTR(EFTTransactionRequest."Card Name",1,10), COPYSTR(EFTTransactionRequest."Card Number", STRLEN(EFTTransactionRequest."Card Number")-7)))
            exit(StrSubstNo ('%1: %2', EFTTransactionRequest."Card Name", CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number")-7)))
        //+NPR5.49 [345188]
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

    local procedure RecurringContractCheckPreTransaction(var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        POSSession: Codeunit "POS Session";
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        EFTShopperRecognition: Record "EFT Shopper Recognition";
        EFTSetup: Record "EFT Setup";
    begin
        //-NPR5.49 [345188]
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if GetCreateRecurringContract(EFTSetup) = 0 then
          exit;

        POSSession.GetSession(POSSession, true);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No."); //Customer is required to issue recurring contract

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
        //+NPR5.49 [345188]
    end;

    procedure ContinueAfterAcquireCard(POSSession: Codeunit "POS Session";TransactionEntryNo: Integer;var ContinueOnTransactionEntryNo: Integer): Boolean
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTPaymentTransactionRequest: Record "EFT Transaction Request";
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
        BeforeAmount: Decimal;
        AfterAmount: Decimal;
        POSSale: Codeunit "POS Sale";
    begin
        //-NPR5.49 [345188]
        if not EFTTransactionRequest.Get(TransactionEntryNo) then
          exit(false);

        if EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::Auxiliary then
          exit(false);

        if EFTTransactionRequest."Auxiliary Operation ID" <> 2 then
          exit(false);

        if not EFTTransactionRequest.Successful then
          exit(false);

        if not ContinueAfterShopperRecognition(EFTTransactionRequest, POSSession) then
          exit(false);

        EFTPaymentTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        EFTAdyenCloudProtocol.SendEftDeviceRequest(EFTPaymentTransactionRequest);
        ContinueOnTransactionEntryNo := EFTPaymentTransactionRequest."Entry No.";
        exit(true);
        //+NPR5.49 [345188]
    end;

    local procedure ContinueAfterShopperRecognition(EFTTransactionRequest: Record "EFT Transaction Request";POSSession: Codeunit "POS Session"): Boolean
    var
        POSSale: Codeunit "POS Sale";
        BeforeAmount: Decimal;
        AfterAmount: Decimal;
    begin
        //-NPR5.49 [345188]
        POSSession.GetSale(POSSale);

        BeforeAmount := GetRemainingPaymentSuggestion(EFTTransactionRequest, POSSession);
        if RecognizeShopper(EFTTransactionRequest, POSSale) then begin
          AfterAmount := GetRemainingPaymentSuggestion(EFTTransactionRequest, POSSession);
          if BeforeAmount <> AfterAmount then begin
        //-NPR5.50 [352465]
        //    HandleAcquireCardPriceChange(EFTTransactionRequest);
        //    EXIT(FALSE);
            exit(HandleAcquireCardPriceChange(EFTTransactionRequest, BeforeAmount, AfterAmount));
        //+NPR5.50 [352465]
          end;
        end;

        exit(true);
        //+NPR5.49 [345188]
    end;

    local procedure RecognizeShopper(EftTransactionRequest: Record "EFT Transaction Request";POSSale: Codeunit "POS Sale"): Boolean
    var
        EFTShopperRecognition: Record "EFT Shopper Recognition";
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.49 [345188]
        if EftTransactionRequest."Internal Customer ID" = '' then
          exit(false);

        if not EFTShopperRecognition.Get(IntegrationType(), EftTransactionRequest."Internal Customer ID") then
          exit(false);

        POSSale.GetCurrentSale(SalePOS);
        if (SalePOS."Customer No." <> '') then
          exit(false);

        Commit;
        exit(CODEUNIT.Run(CODEUNIT::"EFT Try Add Shopper", EFTShopperRecognition));
        //+NPR5.49 [345188]
    end;

    local procedure GetRemainingPaymentSuggestion(EFTTransactionRequest: Record "EFT Transaction Request";POSSession: Codeunit "POS Session"): Decimal
    var
        PaymentTypePOS: Record "Payment Type POS";
        POSPaymentLine: Codeunit "POS Payment Line";
    begin
        //-NPR5.49 [345188]
        POSSession.GetPaymentLine(POSPaymentLine);

        if not POSPaymentLine.GetPaymentType(PaymentTypePOS, EFTTransactionRequest."Original POS Payment Type Code", EFTTransactionRequest."Register No.") then
          Error('%1 %2 could not be retrieved. This is a programming bug, not a user error.', PaymentTypePOS.TableCaption, EFTTransactionRequest."Original POS Payment Type Code");

        exit(POSPaymentLine.CalculateRemainingPaymentSuggestionInCurrentSale(PaymentTypePOS));
        //+NPR5.49 [345188]
    end;

    local procedure HandleAcquireCardPriceChange(EFTTransactionRequest: Record "EFT Transaction Request";BeforeAmount: Decimal;AfterAmount: Decimal): Boolean
    var
        EFTSetup: Record "EFT Setup";
        SilentAllowed: Boolean;
        EFTPaymentTransactionRequest: Record "EFT Transaction Request";
    begin
        //-NPR5.50 [352465]
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        SilentAllowed := GetSilentDiscountAllowed(EFTSetup);

        EFTPaymentTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        if (0 < BeforeAmount) and (0 < AfterAmount) and (AfterAmount < BeforeAmount) and (EFTPaymentTransactionRequest."Amount Input" = BeforeAmount) and (SilentAllowed) then begin
          EFTPaymentTransactionRequest."Amount Input" := AfterAmount;
          EFTPaymentTransactionRequest.Modify;
          Commit;

          exit(true); //Positive amount before and after, original payment was on full remaining amount, and silent allowed is set.
        end;

        AbortAcquireCard(EFTTransactionRequest);
        exit(false);
        //+NPR5.50 [352465]
    end;

    local procedure AbortAcquireCard(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        OriginalEFTTransactionRequest: Record "EFT Transaction Request";
        AbortAttempts: Integer;
        Aborted: Boolean;
    begin
        //-NPR5.49 [345188]
        while (not Aborted) and (AbortAttempts < 2) do begin
          Aborted := SendAbortAcquireCardRequest(EFTTransactionRequest);
          AbortAttempts += 1;
          Sleep(500);
        end;

        OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        OriginalEFTTransactionRequest.Recoverable := false; //We know the primary transaction "failed correctly" since we never started it in the first place.
        OriginalEFTTransactionRequest."Result Description" := CopyStr(PRICE_CHANGED, 1, MaxStrLen(OriginalEFTTransactionRequest."Result Description"));
        OriginalEFTTransactionRequest.Modify;

        OnAfterProtocolResponse(OriginalEFTTransactionRequest);

        if not Aborted then
          Message(ABORT_ACQUIRED_FAIL);
        //+NPR5.49 [345188]
    end;

    procedure AbortTransaction(EFTTransactionRequest: Record "EFT Transaction Request"): Boolean
    var
        EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
        AbortEFTTransactionRequest: Record "EFT Transaction Request";
        EFTSetup: Record "EFT Setup";
    begin
        //-NPR5.49 [345188]
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        EFTFrameworkMgt.CreateAuxRequest(AbortEFTTransactionRequest, EFTSetup, 1, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        AbortEFTTransactionRequest."Processed Entry No." := EFTTransactionRequest."Entry No.";
        AbortEFTTransactionRequest.Modify;
        Commit;
        EFTFrameworkMgt.SendRequest(AbortEFTTransactionRequest);
        AbortEFTTransactionRequest.Find;
        exit(AbortEFTTransactionRequest.Successful);
        //+NPR5.49 [345188]
    end;

    local procedure SendAbortAcquireCardRequest(EFTTransactionRequest: Record "EFT Transaction Request"): Boolean
    var
        EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
        AbortEFTTransactionRequest: Record "EFT Transaction Request";
        EFTSetup: Record "EFT Setup";
    begin
        //-NPR5.49 [345188]
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        EFTFrameworkMgt.CreateAuxRequest(AbortEFTTransactionRequest, EFTSetup, 3, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        AbortEFTTransactionRequest."Processed Entry No." := EFTTransactionRequest."Entry No.";
        AbortEFTTransactionRequest.Modify;
        Commit;
        EFTFrameworkMgt.SendRequest(AbortEFTTransactionRequest);
        AbortEFTTransactionRequest.Find;
        exit(AbortEFTTransactionRequest.Successful);
        //+NPR5.49 [345188]
    end;
}

