codeunit 6184639 "NPR EFT Adyen Integration"
{
    Access = Internal;

    var
        NO_SHOPPER_ON_CARD: Label 'No shopper associated with card';

    procedure CloudIntegrationType(): Code[20]
    var
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
    begin
        exit(EFTAdyenCloudIntegrat.IntegrationType());
    end;

    procedure HWCIntegrationType(): Code[20]
    var
        EFTAdyenHWCIntegrat: Codeunit "NPR EFT Adyen HWC Integrat.";
    begin
        exit(EFTAdyenHWCIntegrat.IntegrationType());
    end;

    procedure MposTapToPayIntegrationType(): Code[20]
    var
        EFTAdyenTTPIntegrat: Codeunit "NPR EFT Adyen TTP Integ.";
    begin
        exit(EFTAdyenTTPIntegrat.IntegrationType());
    end;

    procedure MposLanIntegrationType(): Code[20]
    var
        EFTAdyenMposLanInteg: Codeunit "NPR EFT Adyen Mpos Lan Integ.";
    begin
        exit(EFTAdyenMposLanInteg.IntegrationType());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), HWCIntegrationType(), MposTapToPayIntegrationType(), MposLanIntegrationType()]) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);

        RecurringContractCheckPreTransaction(EftTransactionRequest);

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");
        EftTransactionRequest."Manual Capture" := GetManualCapture(EFTSetup);
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), HWCIntegrationType(), MposTapToPayIntegrationType(), MposLanIntegrationType()]) then
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), HWCIntegrationType(), MposTapToPayIntegrationType(), MposLanIntegrationType()]) then
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), HWCIntegrationType(), MposLanIntegrationType()]) then
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVerifySetupRequest', '', false, false)]
    local procedure OnCreateVerifySetupRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), HWCIntegrationType()]) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), HWCIntegrationType()]) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]
    local procedure OnPrepareRequestSend(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    var
        EFTAdyenUnitSetup: Record "NPR EFT Adyen Unit Setup";
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTAdyenHWCIntegrat: Codeunit "NPR EFT Adyen HWC Integrat.";
    begin
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), HWCIntegrationType(), MposTapToPayIntegrationType(), MposLanIntegrationType()]) then
            exit;

        if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::AUXILIARY)
            and (EftTransactionRequest."Auxiliary Operation ID" = "NPR EFT Adyen Aux Operation"::DISABLE_CONTRACT.AsInteger()) then begin
            RequestMechanism := RequestMechanism::Synchronous;
            exit;
        end;

        RequestMechanism := RequestMechanism::POSWorkflow;
        Request.Add('EntryNo', EFTTransactionRequest."Entry No.");
        if EftTransactionRequest."Amount Input" <> 0 then begin
            Request.Add('formattedAmount', Format(EFTTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));
        end else begin
            Request.Add('formattedAmount', ' ');
        end;
        if EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::AUXILIARY then begin
            Request.Add('TypeCaption', Format(EftTransactionRequest."Auxiliary Operation Desc."));
        end else begin
            Request.Add('TypeCaption', Format(EftTransactionRequest."Processing Type"));
        end;
        Request.Add('unattended', EftTransactionRequest."Self Service");
        Request.Add('PaymentSetupCode', EftTransactionRequest."POS Payment Type Code");
        if (EftTransactionRequest."Integration Type" in [MposLanIntegrationType(), HWCIntegrationType()]) then begin
            GetUnitSetupParameters(EftTransactionRequest."Register No.", EFTAdyenUnitSetup);
            Request.Add('LocalTerminalIpAddress', GetTerminalEndpoint(EFTAdyenUnitSetup));
        end;
        EFTAdyenPaymTypeSetup.Get(EftTransactionRequest."POS Payment Type Code");
        Request.Add('IsLiveEnvironment', EFTAdyenPaymTypeSetup.Environment = EFTAdyenPaymTypeSetup.Environment::PRODUCTION);
        Request.Add('PosUnitNumber', EftTransactionRequest."Register No.");
        case EftTransactionRequest."Integration Type" of
            CloudIntegrationType():
                Workflow := Format(Enum::"NPR POS Workflow"::EFT_ADYEN_CLOUD);
            HWCIntegrationType():
                begin
                    Request.Add('hwcRequest', EFTAdyenHWCIntegrat.BuildTransactionRequest(EftTransactionRequest."Entry No."));
                    Workflow := Format(Enum::"NPR POS Workflow"::EFT_ADYEN_HWC);
                end;
            MposTapToPayIntegrationType():
                Workflow := Format(Enum::"NPR POS Workflow"::EFT_ADYEN_MPOS_TTP);
            MposLanIntegrationType():
                Workflow := Format(Enum::"NPR POS Workflow"::EFT_ADYEN_MPOS_LAN);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnSendRequestSynchronously', '', false, false)]
    local procedure OnSendRequestSynchronously(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTAdyenContractMgmt: Codeunit "NPR EFT Adyen Contract Mgmt.";
    begin
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), HWCIntegrationType()]) then
            exit;
        if EftTransactionRequest."Processing Type" <> EftTransactionRequest."Processing Type"::AUXILIARY then
            exit;
        if EftTransactionRequest."Auxiliary Operation ID" <> "NPR EFT Adyen Aux Operation"::DISABLE_CONTRACT.AsInteger() then
            exit;

        EFTAdyenContractMgmt.DisableRecurringContract(EftTransactionRequest);
        Handled := true;
    end;

    #region EFT Parameter Handling
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

    procedure GetPaymentTypeParameters(EFTSetup: Record "NPR EFT Setup"; var EFTAdyenPaymentTypeSetupOut: Record "NPR EFT Adyen Paym. Type Setup")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not EFTAdyenPaymentTypeSetupOut.Get(EFTSetup."Payment Type POS") then begin
            EFTAdyenPaymentTypeSetupOut.Init();
            EFTAdyenPaymentTypeSetupOut."Payment Type POS" := EFTSetup."Payment Type POS";
            EFTAdyenPaymentTypeSetupOut.Insert();
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

    procedure GetManualCapture(EFTSetupIn: Record "NPR EFT Setup"): Boolean
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Manual Capture");
    end;

    procedure GetEnableTipping(EFTSetupIn: Record "NPR EFT Setup"): Boolean
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Enable Tipping");
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Framework Mgt.", 'OnAfterEftIntegrationResponseReceived', '', false, false)]
    local procedure InsertEFTAdditionalData(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        MMMemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        if (EftTransactionRequest."Auxiliary Operation ID" in [Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_SIGNATURE.AsInteger(),
                                                                Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_PHONE_NO.AsInteger(),
                                                                Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_EMAIL.AsInteger()]) or
        ((EftTransactionRequest."Auxiliary Operation ID" = Enum::"NPR EFT Adyen Aux Operation"::ABORT_TRX.AsInteger()) and EftTransactionRequest."Created From Data Collection") then
            exit;

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        if EFTAdyenIntegration.GetCreateRecurringContract(EFTSetup) = EFTAdyenPaymentTypeSetup."Create Recurring Contract"::NO then
            exit;

        if EFTTransactionRequest."Recurring Detail Reference" = '' then
            exit;
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), HWCIntegrationType()]) then
            exit;
        if EftTransactionRequest."Processing Type" <> EftTransactionRequest."Processing Type"::PAYMENT then
            exit;

        MMMemberInfoCapture.SetRange("Receipt No.", EftTransactionRequest."Sales Ticket No.");
        if not MMMemberInfoCapture.FindSet() then begin
            DeleteMemberPaymentMethods(EftTransactionRequest);
            AddPaymentMethodToExistingMembership(EftTransactionRequest, MemberPaymentMethod);
            exit;
        end;

        repeat
            NewMemberSubscription(EftTransactionRequest, MMMemberInfoCapture);
        until MMMemberInfoCapture.Next() = 0;

    end;
    #endregion

    #region Aux

    local procedure CreateGenericRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        EFTAdyenUnitSetup: Record "NPR EFT Adyen Unit Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");

        EFTTransactionRequest."Integration Version Code" := '3.0'; //Adyen Terminal API Protocol v3.0
        if EFTTransactionRequest."Integration Type" = CloudIntegrationType() then begin
            EFTTransactionRequest."Hardware ID" := EFTAdyenCloudIntegrat.GetPOIID(EFTSetup);
            if EFTAdyenCloudIntegrat.GetEnvironment(EFTSetup) <> 0 then
                EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";
        end;
        if (EFTTransactionRequest."Integration Type" in [MposLanIntegrationType(), HWCIntegrationType()]) then begin
            GetUnitSetupParameters(EFTSetup."POS Unit No.", EFTAdyenUnitSetup);
            EFTTransactionRequest."Hardware ID" := CopyStr(EFTAdyenUnitSetup.POIID, 1, MaxStrLen(EFTTransactionRequest."Hardware ID"));
        end;

        if not GetCashbackAllowed(EFTSetup) then
            EFTTransactionRequest.TestField("Cashback Amount", 0);
    end;

    local procedure GetUnitSetupParameters(POSUnitNo: Code[10]; var EFTAdyenUnitSetup: Record "NPR EFT Adyen Unit Setup")
    begin
        if (not EFTAdyenUnitSetup.Get(POSUnitNo)) then begin
            EFTAdyenUnitSetup.Init();
            EFTAdyenUnitSetup."POS Unit No." := POSUnitNo;
            EFTAdyenUnitSetup.Insert();
        end;
    end;

    procedure GetTerminalEndpoint(EFTAdyenUnitSetup: Record "NPR EFT Adyen Unit Setup"): Text
    begin
        exit(StrSubstNo('https://%1:8443/nexo', EFTAdyenUnitSetup."Terminal LAN IP"));
    end;

    procedure GetTerminalEndpoint(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTAdyenUnitSetup: Record "NPR EFT Adyen Unit Setup";
    begin
        GetUnitSetupParameters(EFTSetup."POS Unit No.", EFTAdyenUnitSetup);
        exit(GetTerminalEndpoint(EFTAdyenUnitSetup));
    end;

    procedure GetLocalKeyIdentifier(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Local Key Identifier");
    end;

    procedure GetLocalKeyPassphrase(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Local Key Passphrase");
    end;

    procedure GetLocalKeyVersion(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Local Key Version");
    end;

    procedure VoidTransactionAfterSignatureDecline(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var VoidEntryNo: Integer)
    var
        EFTSetup: Record "NPR EFT Setup";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        EFTFrameworkMgt.CreateVoidRequest(VoidEFTTransactionRequest, EFTSetup, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.", EFTTransactionRequest."Entry No.", false);
        Commit();
        VoidEntryNo := VoidEFTTransactionRequest."Entry No."
    end;

    procedure AcquireCardBeforeTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var AcquireCardEntryNo: Integer): Boolean
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        AcquireCardEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        if not (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then
            exit(false);

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if GetCreateRecurringContract(EFTSetup) <> 0 then
            exit(false);

        if not GetAcquireCardFirst(EFTSetup) then
            exit(false);

        if not POSSession.IsInitialized() then
            exit(false);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        EFTFrameworkMgt.CreateAuxRequest(AcquireCardEFTTransactionRequest, EFTSetup, 2, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        AcquireCardEFTTransactionRequest."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
        AcquireCardEFTTransactionRequest.Modify();
        EFTTransactionRequest.Recoverable := false; //Not recoverable if we fail on card acquisition, since it never started externally.
        EFTTransactionRequest.Modify();
        Commit();

        AcquireCardEntryNo := AcquireCardEFTTransactionRequest."Entry No.";
        exit(true);
    end;

    procedure RequestShopperSubscriptionConfirmation(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var TerminalConfirmationEntryNo: Integer): Boolean
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        ShopperSubscriptionConfirmationEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        if not (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then
            exit(false);

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        if GetCreateRecurringContract(EFTSetup) = 0 then
            exit(false);

        if not POSSession.IsInitialized() then
            exit(false);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        EFTFrameworkMgt.CreateAuxRequest(ShopperSubscriptionConfirmationEFTTransactionRequest, EFTSetup, 8, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        ShopperSubscriptionConfirmationEFTTransactionRequest."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
        ShopperSubscriptionConfirmationEFTTransactionRequest.Modify();
        EFTTransactionRequest.Recoverable := false;
        EFTTransactionRequest.Modify();
        Commit();

        TerminalConfirmationEntryNo := ShopperSubscriptionConfirmationEFTTransactionRequest."Entry No.";
        exit(true);
    end;

    local procedure RecurringContractCheckPreTransaction(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        SalePOS: Record "NPR POS Sale";
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTSetup: Record "NPR EFT Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        EntityType: Option Customer,Contact,Membership;
        MembershipEntryNo: Integer;
        ShopperReference: Text[50];
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if GetCreateRecurringContract(EFTSetup) = 0 then
            exit;

        POSSession.ErrorIfNotInitialized();
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetRange("Receipt No.", SalePOS."Sales Ticket No.");
        if not MemberInfoCapture.FindSet() then begin
            MembershipEntryNo := MembershipMgtInternal.GetMembershipEntryNoFromCustomer(SalePOS."Customer No.");
            GetCreateEFTShopperRecognition(Format(MembershipEntryNo), EntityType::Membership, EFTTransactionRequest."Integration Type", EFTShopperRecognition);
            ShopperReference := EFTShopperRecognition."Shopper Reference";
        end else
            repeat
                GetCreateEFTShopperRecognition(Format(MemberInfoCapture."Membership Entry No."), EntityType::Membership, EFTTransactionRequest."Integration Type", EFTShopperRecognition);
                if ShopperReference = '' then
                    ShopperReference := EFTShopperRecognition."Shopper Reference";
            until MemberInfoCapture.Next() = 0;

        EFTTransactionRequest."Internal Customer ID" := ShopperReference;
    end;

    internal procedure GetCreateEFTShopperRecognition(EntityKey: Code[20]; EntityType: Option Customer,Contact,Membership; IntegrationType: Code[20]; var EFTShopperRecognition: Record "NPR EFT Shopper Recognition")
    begin
        EFTShopperRecognition.Reset();
        EFTShopperRecognition.SetFilter("Integration Type", '%1|%2', CloudIntegrationType(), HWCIntegrationType());
        EFTShopperRecognition.SetRange("Entity Key", EntityKey);
        EFTShopperRecognition.SetRange("Entity Type", EntityType);

        if not EFTShopperRecognition.FindFirst() then begin
            EFTShopperRecognition.Init();
            EFTShopperRecognition."Integration Type" := IntegrationType;
            EFTShopperRecognition."Shopper Reference" := CopyStr(Format(CreateGuid()), 2, 36);
            EFTShopperRecognition."Entity Key" := EntityKey;
            EFTShopperRecognition."Entity Type" := EntityType;
            EFTShopperRecognition.Insert();
        end;
    end;

    procedure ContinueAfterAcquireCard(TransactionEntryNo: Integer; var ContinueOnTransactionEntryNo: Integer): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTTransactionRequest.Get(TransactionEntryNo) then
            exit(false);

        if EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::AUXILIARY then
            exit(false);

        case EFTTransactionRequest."Auxiliary Operation ID" of
            "NPR EFT Adyen Aux Operation"::ACQUIRE_CARD.AsInteger():
                begin
                    exit(ShouldProceedToPurchaseTransaction(EFTTransactionRequest, ContinueOnTransactionEntryNo));
                end;
            "NPR EFT Adyen Aux Operation"::DETECT_SHOPPER.AsInteger():
                begin
                    DetectShopper(EFTTransactionRequest);
                    exit(false);
                end;
            "NPR EFT Adyen Aux Operation"::CLEAR_SHOPPER.AsInteger():
                begin
                    ClearShopperContract(EFTTransactionRequest);
                    exit(false);
                end;
            else
                EFTTransactionRequest.FieldError("Auxiliary Operation ID");
        end;
    end;

    procedure ContinueAfterSubscriptionConfirmation(TransactionEntryNo: Integer; var ContinueOnTransactionEntryNo: Integer): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTTransactionRequest.Get(TransactionEntryNo) then
            exit(false);

        if EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::AUXILIARY then
            exit(false);

        case EFTTransactionRequest."Auxiliary Operation ID" of
            "NPR EFT Adyen Aux Operation"::SUBSCRIPTION_CONFIRM.AsInteger():
                begin
                    exit(ShouldProceedToPurchaseTransactionAfterSubscriptionConfirmation(EFTTransactionRequest, ContinueOnTransactionEntryNo));
                end;
            else
                EFTTransactionRequest.FieldError("Auxiliary Operation ID");
        end;
    end;

    local procedure ShouldProceedToPurchaseTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var ContinueOnTransactionEntryNo: Integer): Boolean
    var
        EFTPaymentTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTTransactionRequest.Successful then
            exit(false);

        if not ContinueAfterShopperRecognition(EFTTransactionRequest) then
            exit(false);

        if CancelContractCreation(EFTTransactionRequest) then
            exit(false);

        if (EFTTransactionRequest."Initiated from Entry No." = 0) then
            exit(false);

        EFTPaymentTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        EFTPaymentTransactionRequest.Recoverable := true;
        EFTPaymentTransactionRequest.Modify();
        Commit();
        ContinueOnTransactionEntryNo := EFTPaymentTransactionRequest."Entry No.";
        exit(true);
    end;

    local procedure ShouldProceedToPurchaseTransactionAfterSubscriptionConfirmation(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var ContinueOnTransactionEntryNo: Integer): Boolean
    var
        EFTPaymentTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTTransactionRequest.Successful then
            exit(false);

        if not EFTTransactionRequest."Confirmed Flag" then
            exit(false);

        EFTPaymentTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        EFTPaymentTransactionRequest.Recoverable := true;
        EFTPaymentTransactionRequest.Modify();
        Commit();
        ContinueOnTransactionEntryNo := EFTPaymentTransactionRequest."Entry No.";
        exit(true);
    end;

    internal procedure ContinueAfterSignatureVerification(TransactionEntryNo: Integer; var ContinueOnTransactionEntryNo: Integer): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTTransactionRequest.Get(TransactionEntryNo) then
            exit(false);

        if EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::AUXILIARY then
            exit(false);

        case EFTTransactionRequest."Auxiliary Operation ID" of
            "NPR EFT Adyen Aux Operation"::ACQUIRE_SIGNATURE.AsInteger():
                begin
                    exit(ShouldProceedToTransactionAfterSignatureConfirmation(EFTTransactionRequest, ContinueOnTransactionEntryNo));
                end;
            else
                EFTTransactionRequest.FieldError("Auxiliary Operation ID");
        end;
    end;

    internal procedure ContinueAfterPhoneNoVerification(TransactionEntryNo: Integer; var ContinueOnTransactionEntryNo: Integer): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTTransactionRequest.Get(TransactionEntryNo) then
            exit(false);

        if EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::AUXILIARY then
            exit(false);

        case EFTTransactionRequest."Auxiliary Operation ID" of
            "NPR EFT Adyen Aux Operation"::ACQUIRE_PHONE_NO.AsInteger():
                begin
                    exit(ShouldProceedToTransactionAfterPhoneNoConfirmation(EFTTransactionRequest, ContinueOnTransactionEntryNo));
                end;
            else
                EFTTransactionRequest.FieldError("Auxiliary Operation ID");
        end;
    end;

    local procedure ShouldProceedToTransactionAfterSignatureConfirmation(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var ContinueOnTransactionEntryNo: Integer): Boolean
    begin
        if not EFTTransactionRequest.Successful then
            exit(false);

        if not EFTTransactionRequest."Confirmed Flag" then
            exit(false);

        ContinueOnTransactionEntryNo := EFTTransactionRequest."Entry No.";
        exit(true);
    end;

    local procedure ShouldProceedToTransactionAfterPhoneNoConfirmation(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var ContinueOnTransactionEntryNo: Integer): Boolean
    begin
        if not EFTTransactionRequest.Successful then
            exit(false);

        if not EFTTransactionRequest."Confirmed Flag" then
            exit(false);

        ContinueOnTransactionEntryNo := EFTTransactionRequest."Entry No.";
        exit(true);
    end;

    local procedure ClearShopperContract(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        DisableEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        ShopperFound: Boolean;
        DISABLE_SHOPPER_SUCCESS: Label 'Shopper Reference Disabled: %1';
        CLEAR_SHOPPER_PROMPT_MATCH: Label 'Disable contract with shopper?\Reference ID: %1\%2 No.: %3';
        CLEAR_SHOPPER_PROMPT: Label 'Disable contract with shopper?\Reference ID: %1';
    begin
        if not (EFTTransactionRequest.Successful) then
            exit;

        if EFTTransactionRequest."External Customer ID" = '' then begin
            Message(NO_SHOPPER_ON_CARD);
            exit;
        end;

        ShopperFound := EFTShopperRecognition.Get(CloudIntegrationType(), EFTTransactionRequest."External Customer ID");
        if not ShopperFound then
            ShopperFound := EFTShopperRecognition.Get(HWCIntegrationType(), EFTTransactionRequest."External Customer ID");

        if ShopperFound then begin
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
        DisableEFTTransactionRequest.Modify();
        Commit();
        EFTFrameworkMgt.SendSynchronousRequest(DisableEFTTransactionRequest);

        DisableEFTTransactionRequest.Find('=');
        if DisableEFTTransactionRequest.Successful then begin
            Message(StrSubstNo(DISABLE_SHOPPER_SUCCESS, DisableEFTTransactionRequest."External Customer ID"));
        end;

    end;

    local procedure ContinueAfterShopperRecognition(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        BeforeAmount: Decimal;
        AfterAmount: Decimal;
        POSSession: Codeunit "NPR POS Session";
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

    local procedure DetectShopper(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        UNKNOWN_SHOPPER: Label 'Unknown shopper reference ID associated with card: %1';
    begin
        if not (EFTTransactionRequest.Successful) then
            exit;

        if EFTTransactionRequest."External Customer ID" = '' then begin
            Message(NO_SHOPPER_ON_CARD);
            exit;
        end;

        if not EFTShopperRecognition.Get(CloudIntegrationType(), EFTTransactionRequest."External Customer ID") then begin
            if not EFTShopperRecognition.Get(HWCIntegrationType(), EFTTransactionRequest."External Customer ID") then begin
                Message(UNKNOWN_SHOPPER, EFTTransactionRequest."External Customer ID");
                exit;
            end;
        end;

        Commit();
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

        if not EFTShopperRecognition.Get(CloudIntegrationType(), EftTransactionRequest."External Customer ID") then
            if not EFTShopperRecognition.Get(HWCIntegrationType(), EftTransactionRequest."External Customer ID") then
                exit(false);

        POSSale.GetCurrentSale(SalePOS);
        if (SalePOS."Customer No." <> '') then
            exit(false);

        Commit();
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
        PRICE_CHANGED: Label 'Price changed after customer recognition:\Before: %1\After: %2';
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        SilentAllowed := GetSilentDiscountAllowed(EFTSetup);

        EFTPaymentTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        if (0 < BeforeAmount) and (0 < AfterAmount) and (AfterAmount < BeforeAmount) and (EFTPaymentTransactionRequest."Amount Input" = BeforeAmount) and (SilentAllowed) then begin
            EFTPaymentTransactionRequest."Amount Input" := AfterAmount;
            EFTPaymentTransactionRequest.Modify();
            Commit();

            exit(true); //Positive amount before and after, original payment was on full remaining amount, and silent allowed is set.
        end;

        Message(StrSubstNo(PRICE_CHANGED, BeforeAmount, AfterAmount));

        exit(false);
    end;

    local procedure CancelContractCreation(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        CurrentShopperRef: Text;
        CurrentShopperRefLbl: Label ', %1 %2', Locked = true;
        CONTRACT_DUPLICATE: Label 'Card already has contract for %1 %2';
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if GetCreateRecurringContract(EFTSetup) = 0 then
            exit(false);

        if EFTTransactionRequest."External Customer ID" <> '' then begin
            CurrentShopperRef := EFTTransactionRequest."External Customer ID";
            if EFTShopperRecognition.Get(CloudIntegrationType(), EFTTransactionRequest."External Customer ID") then begin
                CurrentShopperRef += StrSubstNo(CurrentShopperRefLbl, Format(EFTShopperRecognition."Entity Type"), EFTShopperRecognition."Entity Key");
            end else
                if EFTShopperRecognition.Get(HWCIntegrationType(), EFTTransactionRequest."External Customer ID") then begin
                    CurrentShopperRef += StrSubstNo(CurrentShopperRefLbl, Format(EFTShopperRecognition."Entity Type"), EFTShopperRecognition."Entity Key");
                end;
            Message(StrSubstNo(CONTRACT_DUPLICATE, EFTShopperRecognition.FieldCaption("Shopper Reference"), CurrentShopperRef));
            exit(true);
        end;

        exit(false);
    end;


    #endregion

    procedure WriteLogEntry(EFTTransactionRequest: Record "NPR EFT Transaction Request"; IsError: Boolean; Description: Text; LogContents: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        WriteLogEntry(EFTSetup, IsError, EFTTransactionRequest."Entry No.", Description, LogContents);
    end;

    internal procedure WriteLogEntry(RegisterNo: Code[10]; OriginalPOSPaymentTypeCode: Code[10]; EntryNo: Integer; IsError: Boolean; Description: Text; LogContents: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(RegisterNo, OriginalPOSPaymentTypeCode);
        WriteLogEntry(EFTSetup, IsError, EntryNo, Description, LogContents);
    end;

    local procedure WriteLogEntry(EFTSetup: Record "NPR EFT Setup"; IsError: Boolean; EntryNo: Integer; Description: Text; LogContents: Text)
    var
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        AdyenCloudPaymentSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        case GetLogLevel(EFTSetup) of
            AdyenCloudPaymentSetup."Log Level"::ERROR:
                if IsError then
                    EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, LogContents)
                else
                    EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, '');

            AdyenCloudPaymentSetup."Log Level"::FULL:
                EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, LogContents);

            AdyenCloudPaymentSetup."Log Level"::NONE:
                EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, '');
        end;
    end;

    internal procedure WriteGenericDataCollectionLogEntry(EntryNo: Integer; Description: Text; Logs: Text)
    var
        EFTTransactionLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
    begin
        EFTTransactionLoggingMgt.WriteLogEntry(EntryNo, Description, '');
    end;

    local procedure GetLogLevel(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Log Level");
    end;

    local procedure NewMemberSubscription(EftTransactionRequest: Record "NPR EFT Transaction Request"; var MMMemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        MMPaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
        UserAccount: Record "NPR UserAccount";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        if not Membership.Get(MMMemberInfoCapture."Membership Entry No.") then
            exit;

        if MemberPaymentMethod.Get(MMMemberInfoCapture."Member Payment Method") then
            MemberPaymentMethod.Delete();

        Member.Get(MMMemberInfoCapture."Member Entry No");

        if (not MembershipMgtInternal.GetUserAccountFromMember(Member, UserAccount)) then
            MembershipMgtInternal.CreateUserAccountFromMember(Member, UserAccount);

        if MMPaymentMethodMgt.FindMemberPaymentMethod(EftTransactionRequest, MemberPaymentMethod) then begin
            MMPaymentMethodMgt.SetMemberPaymentMethodAsDefault(Membership, MemberPaymentMethod);
            MembershipMgtInternal.EnableMembershipInternalAutoRenewal(Membership, true, false);
        end else begin

            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);

            AddPaymentMethodForMemberOrPayer(SalePOS, UserAccount, EftTransactionRequest, MemberPaymentMethod, MembershipMgtInternal, MMPaymentMethodMgt);

            MMPaymentMethodMgt.SetMemberPaymentMethodAsDefault(Membership, MemberPaymentMethod);
            MembershipMgtInternal.EnableMembershipInternalAutoRenewal(Membership, true, false);

            MMMemberInfoCapture."Enable Auto-Renew" := true;
            MMMemberInfoCapture."Member Payment Method" := MemberPaymentMethod."Entry No.";
            MMMemberInfoCapture.Modify();
        end;
    end;

    local procedure AddPaymentMethodToExistingMembership(EftTransactionRequest: Record "NPR EFT Transaction Request"; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        MMPaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
        Membership: Record "NPR MM Membership";
        UserAccount: Record "NPR UserAccount";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Member: Record "NPR MM Member";
        SubscriptionPSP: Enum "NPR MM Subscription PSP";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." = '' then
            exit;

        Membership.SetCurrentKey("Customer No.");
        Membership.SetRange("Customer No.", SalePOS."Customer No.");
        Membership.SetLoadFields("Entry No.");
        if not Membership.FindFirst() then
            exit;

        if (not MembershipMgt.GetFirstAdminMember(Membership."Entry No.", Member)) then
            exit;

        // Check if we need to create a separate payer UserAccount
        if (SalePOS."Membership Payer E-Mail" <> Member."E-Mail Address") and (SalePOS."Membership Payer E-Mail" <> '') then begin
            if not MembershipMgt.PayerAccountExists(SalePOS, UserAccount, Member) then
                MembershipMgt.CreatePaymentUserAccountFromEmail(SalePOS."Membership Payer E-Mail", UserAccount);
        end else
            if (not MembershipMgt.GetUserAccountFromMember(Member, UserAccount)) then
                MembershipMgt.CreateUserAccountFromMember(Member, UserAccount);

        if MMPaymentMethodMgt.GetSubscriptionPSP(EftTransactionRequest."Integration Type", SubscriptionPSP) then begin
            if not MMPaymentMethodMgt.FindPaymentMethod(EftTransactionRequest."Recurring Detail Reference", EftTransactionRequest."Internal Customer ID", SubscriptionPSP, UserAccount, MemberPaymentMethod) then
                MMPaymentMethodMgt.AddMemberPaymentMethod(UserAccount, EftTransactionRequest, MemberPaymentMethod);

            // NOTE: Previously this would not add it as default, but that should be safe to do now.
            MMPaymentMethodMgt.SetMemberPaymentMethodAsDefault(Membership, MemberPaymentMethod);
            MembershipMgt.EnableMembershipInternalAutoRenewal(Membership, true, false);
        end;
    end;

    local procedure AddPaymentMethodForMemberOrPayer(SalePOS: Record "NPR POS Sale"; MemberUserAccount: Record "NPR UserAccount"; EftTransactionRequest: Record "NPR EFT Transaction Request"; var MemberPaymentMethod: Record "NPR MM Member Payment Method"; MembershipMgt: Codeunit "NPR MM MembershipMgtInternal"; MMPaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.")
    var
        PaymentUserAccount: Record "NPR UserAccount";
        UserAccountMgtImpl: Codeunit "NPR UserAccountMgtImpl";
    begin
        // Default: use member's UserAccount
        if SalePOS."Membership Payer E-Mail" = '' then begin
            MMPaymentMethodMgt.AddMemberPaymentMethod(MemberUserAccount, EftTransactionRequest, MemberPaymentMethod);
            exit;
        end;

        // Check if payer email is different from member email
        if SalePOS."Membership Payer E-Mail" = MemberUserAccount.EmailAddress then begin
            MMPaymentMethodMgt.AddMemberPaymentMethod(MemberUserAccount, EftTransactionRequest, MemberPaymentMethod);
            exit;
        end;

        // Create payment method with payer's UserAccount
        if not UserAccountMgtImpl.FindAccountByEmail(SalePOS."Membership Payer E-Mail", PaymentUserAccount) then
            MembershipMgt.CreatePaymentUserAccountFromEmail(SalePOS."Membership Payer E-Mail", PaymentUserAccount);
        MMPaymentMethodMgt.AddMemberPaymentMethod(PaymentUserAccount, EftTransactionRequest, MemberPaymentMethod);

    end;

    local procedure DeleteMemberPaymentMethods(CurrEftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        MMPaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
    begin
        EftTransactionRequest.SetCurrentKey("Sales Ticket No.", "Sales Line No.");
        EftTransactionRequest.SetRange("Sales Ticket No.", CurrEftTransactionRequest."Sales Ticket No.");
        EftTransactionRequest.SetFilter("Sales Line No.", '<>%1', CurrEftTransactionRequest."Sales Line No.");
        EFTTransactionRequest.SetRange(Successful, true);
        EFTTransactionRequest.SetFilter("Recurring Detail Reference", '<>%1', '');
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        EftTransactionRequest.SetLoadFields("Sales Ticket No.", "Sales Line No.", SystemId, Successful, "Recurring Detail Reference", "Processing Type");
        if not EftTransactionRequest.FindSet() then
            exit;

        repeat
            MMPaymentMethodMgt.DeleteMemberPaymentMethod(EftTransactionRequest);
        until EftTransactionRequest.Next() = 0;
    end;

    internal procedure CheckMMPaymentMethodAssignedToPOSSale(EFTSetup: Record "NPR EFT Setup"; SalesTicketNo: Code[20]) PaymentMethodAssigned: Boolean;
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTPaymentParamSetup: Record "NPR EFT Adyen Paym. Type Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
    begin
        EFTPaymentParamSetup.SetLoadFields("Create Recurring Contract");
        EFTPaymentParamSetup.Get(EFTSetup."Payment Type POS");
        if EFTPaymentParamSetup."Create Recurring Contract" = EFTPaymentParamSetup."Create Recurring Contract"::NO then
            exit;

        MemberInfoCapture.SetRange("Receipt No.", SalesTicketNo);
        MemberInfoCapture.SetFilter("Member Payment Method", '<>0');
        PaymentMethodAssigned := not MemberInfoCapture.IsEmpty;
        if PaymentMethodAssigned then
            exit;

        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.", "Sales Line No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalesTicketNo);
        EFTTransactionRequest.SetFilter("Sales Line No.", '<>%1', 0);
        EFTTransactionRequest.SetRange(Successful, true);
        EFTTransactionRequest.SetFilter("Recurring Detail Reference", '<>%1', '');
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        EFTTransactionRequest.SetLoadFields("Sales Ticket No.", SystemId, "Sales Line No.", Successful, "Recurring Detail Reference", "Processing Type");
        if not EFTTransactionRequest.FindSet() then
            exit;

        repeat
            MemberPaymentMethod.Reset();
            MemberPaymentMethod.SetCurrentKey("Created from System Id");
            MemberPaymentMethod.SetRange("Created from System Id", EFTTransactionRequest.SystemId);
            PaymentMethodAssigned := not MemberPaymentMethod.IsEmpty;
        until (EFTTransactionRequest.Next() = 0) or PaymentMethodAssigned;
    end;

    internal procedure RewriteAmountFromStringToNumberWithoutRounding(Json: Text; Element: Text): Text
    var
        ElementStartIndex: Integer;
        ValueStartIndex: Integer;
        ValueEndIndex: Integer;
    begin
        // Adyen built an API that depends on amounts being sent as decimals, but they also have strong opinions on the number of decimals. 3 or 2 depending on the currency.
        // The problem is that if you use the built-in JSON types in AL, a decimal is rounded to remove trailing zeroes. And since formatted decimals in AL are strings which adyen doesn't accept in the JSON,
        // we are removing the string quotes manually around numbers formatted to adyens spec....
        // This situation is why other PSPs use integers to transfers amount :)

        ElementStartIndex := Json.IndexOf('"' + Element + '":');
        if ElementStartIndex = 0 then
            exit(Json);
        ValueStartIndex := Json.IndexOf('"', ElementStartIndex + StrLen(Element) + 3);
        ValueEndIndex := Json.IndexOf('"', ValueStartIndex + 1);

        exit(Json.Remove(ValueStartIndex, 1).Remove(ValueEndIndex - 1, 1));
    end;

    internal procedure AddAcquireCardParametersToDictionary(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Parameters: Dictionary of [Text, Text])
    var
        InitiatedFromEFTTransactionRequest: Record "NPR EFT Transaction Request";
        AmountInput: Decimal;
    begin
        if EFTTransactionRequest."Initiated from Entry No." > 0 then begin
            if InitiatedFromEFTTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.") then
                AmountInput := InitiatedFromEFTTransactionRequest."Amount Input";
        end;

        Parameters.Add('RegisterNo', EFTTransactionRequest."Register No.");
        Parameters.Add('OriginalPOSPaymentTypeCode', EFTTransactionRequest."Original POS Payment Type Code");
        Parameters.Add('ReferenceNumberInput', EFTTransactionRequest."Reference Number Input");
        Parameters.Add('HardwareID', EFTTransactionRequest."Hardware ID");
        Parameters.Add('IntegrationVersionCode', EFTTransactionRequest."Integration Version Code");
        Parameters.Add('SalesTicketNo', EFTTransactionRequest."Sales Ticket No.");
        Parameters.Add('AuxiliaryOperationID', Format(EFTTransactionRequest."Auxiliary Operation ID"));
        Parameters.Add('InitiatedFromEntryNo', Format(EFTTransactionRequest."Initiated from Entry No."));
        Parameters.Add('AmountInput', Format(AmountInput, 0, 9));
        Parameters.Add('Mode', Format(EFTTransactionRequest.Mode));
    end;
}