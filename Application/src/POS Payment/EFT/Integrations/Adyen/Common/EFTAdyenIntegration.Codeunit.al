codeunit 6184639 "NPR EFT Adyen Integration"
{
    Access = Internal;

    var
        CONTRACT_DUPLICATE: Label 'Card already has contract for %1 %2';
        NO_SHOPPER_ON_CARD: Label 'No shopper associated with card';
        CLEAR_SHOPPER_PROMPT_MATCH: Label 'Disable contract with shopper?\Reference ID: %1\%2 No.: %3';
        CLEAR_SHOPPER_PROMPT: Label 'Disable contract with shopper?\Reference ID: %1';
        UNKNOWN_SHOPPER: Label 'Unknown shopper reference ID associated with card: %1';

    procedure CloudIntegrationType(): Code[20]
    var
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
    begin
        exit(EFTAdyenCloudIntegrat.IntegrationType());
    end;

    procedure LocalIntegrationType(): Code[20]
    var
        EFTAdyenLocalIntegrat: Codeunit "NPR EFT Adyen Local Integrat.";
    begin
        exit(EFTAdyenLocalIntegrat.IntegrationType());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not IsEnabled() then
            exit;
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), LocalIntegrationType()]) then
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not IsEnabled() then
            exit;
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), LocalIntegrationType()]) then
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
        if not IsEnabled() then
            exit;
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), LocalIntegrationType()]) then
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
        if not IsEnabled() then
            exit;
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), LocalIntegrationType()]) then
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
        if not IsEnabled() then
            exit;
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), LocalIntegrationType()]) then
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
        if not IsEnabled() then
            exit;
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), LocalIntegrationType()]) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]
    local procedure OnPrepareRequestSend(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    begin
        if not IsEnabled() then
            exit;
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), LocalIntegrationType()]) then
            exit;

        if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::AUXILIARY)
            and (EftTransactionRequest."Auxiliary Operation ID" = 6) then begin
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
        Request.Add('TypeCaption', Format(EftTransactionRequest."Processing Type"));
        Request.Add('unattended', EftTransactionRequest."Self Service");

        case EftTransactionRequest."Integration Type" of
            CloudIntegrationType():
                Workflow := Format(Enum::"NPR POS Workflow"::EFT_ADYEN_CLOUD);
            LocalIntegrationType():
                Workflow := Format(Enum::"NPR POS Workflow"::EFT_ADYEN_LOCAL);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnSendRequestSynchronously', '', false, false)]
    local procedure OnSendRequestSynchronously(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTAdyenContractMgmt: Codeunit "NPR EFT Adyen Contract Mgmt.";
    begin
        if not IsEnabled() then
            exit;
        if not (EftTransactionRequest."Integration Type" in [CloudIntegrationType(), LocalIntegrationType()]) then
            exit;
        if EftTransactionRequest."Processing Type" <> EftTransactionRequest."Processing Type"::AUXILIARY then
            exit;
        if EftTransactionRequest."Auxiliary Operation ID" <> 6 then
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

    #endregion

    #region Aux

    local procedure CreateGenericRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        EFTAdyenLocalIntegration: Codeunit "NPR EFT Adyen Local Integrat.";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");

        EFTTransactionRequest."Integration Version Code" := '3.0'; //Adyen Terminal API Protocol v3.0
        if EFTTransactionRequest."Integration Type" = CloudIntegrationType() then begin
            EFTTransactionRequest."Hardware ID" := EFTAdyenCloudIntegrat.GetPOIID(EFTSetup);
            if EFTAdyenCloudIntegrat.GetEnvironment(EFTSetup) <> 0 then
                EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";
        end else begin
            EFTTransactionRequest."Hardware ID" := EFTAdyenLocalIntegration.GetTerminalEndpoint(EFTSetup);
        end;

        if not GetCashbackAllowed(EFTSetup) then
            EFTTransactionRequest.TestField("Cashback Amount", 0);
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

        if not (GetAcquireCardFirst(EFTSetup) or (GetCreateRecurringContract(EFTSetup) <> 0)) then
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



    local procedure RecurringContractCheckPreTransaction(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if GetCreateRecurringContract(EFTSetup) = 0 then
            exit;

        POSSession.ErrorIfNotInitialized();
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No."); //Customer is required to issue recurring contract

        EFTShopperRecognition.SetFilter("Integration Type", '%1|%2', CloudIntegrationType(), LocalIntegrationType());
        EFTShopperRecognition.SetRange("Entity Key", SalePOS."Customer No.");
        EFTShopperRecognition.SetRange("Entity Type", EFTShopperRecognition."Entity Type"::Customer);

        if not EFTShopperRecognition.FindFirst() then begin
            EFTShopperRecognition.Init();
            EFTShopperRecognition."Integration Type" := EFTTransactionRequest."Integration Type";
            EFTShopperRecognition."Shopper Reference" := CopyStr(Format(CreateGuid()), 2, 36);
            EFTShopperRecognition."Entity Key" := SalePOS."Customer No.";
            EFTShopperRecognition."Entity Type" := EFTShopperRecognition."Entity Type"::Customer;
            EFTShopperRecognition.Insert();
        end;

        EFTTransactionRequest."Internal Customer ID" := EFTShopperRecognition."Shopper Reference";
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
            2:
                begin
                    exit(ShouldProceedToPurchaseTransaction(EFTTransactionRequest, ContinueOnTransactionEntryNo));
                end;
            4:
                begin
                    DetectShopper(EFTTransactionRequest);
                    exit(false);
                end;
            5:
                begin
                    ClearShopperContract(EFTTransactionRequest);
                    exit(false);
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

        EFTPaymentTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        EFTPaymentTransactionRequest.Recoverable := true;
        EFTPaymentTransactionRequest.Modify();
        Commit();
        ContinueOnTransactionEntryNo := EFTPaymentTransactionRequest."Entry No.";
        exit(true);
    end;

    local procedure ClearShopperContract(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        DisableEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        ShopperFound: Boolean;
    begin
        if not (EFTTransactionRequest.Successful) then
            exit;

        if EFTTransactionRequest."External Customer ID" = '' then begin
            Message(NO_SHOPPER_ON_CARD);
            exit;
        end;

        ShopperFound := EFTShopperRecognition.Get(CloudIntegrationType(), EFTTransactionRequest."External Customer ID");
        if not ShopperFound then
            ShopperFound := EFTShopperRecognition.Get(LocalIntegrationType(), EFTTransactionRequest."External Customer ID");

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
    begin
        if not (EFTTransactionRequest.Successful) then
            exit;

        if EFTTransactionRequest."External Customer ID" = '' then begin
            Message(NO_SHOPPER_ON_CARD);
            exit;
        end;

        if not EFTShopperRecognition.Get(CloudIntegrationType(), EFTTransactionRequest."External Customer ID") then begin
            if not EFTShopperRecognition.Get(LocalIntegrationType(), EFTTransactionRequest."External Customer ID") then begin
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
            if not EFTShopperRecognition.Get(LocalIntegrationType(), EftTransactionRequest."External Customer ID") then
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
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        if GetCreateRecurringContract(EFTSetup) = 0 then
            exit(false);

        if EFTTransactionRequest."External Customer ID" <> '' then begin
            CurrentShopperRef := EFTTransactionRequest."External Customer ID";
            if EFTShopperRecognition.Get(CloudIntegrationType(), EFTTransactionRequest."External Customer ID") then begin
                CurrentShopperRef += StrSubstNo(CurrentShopperRefLbl, Format(EFTShopperRecognition."Entity Type"), EFTShopperRecognition."Entity Key");
            end else
                if EFTShopperRecognition.Get(LocalIntegrationType(), EFTTransactionRequest."External Customer ID") then begin
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

    local procedure GetLogLevel(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTAdyenPaymentTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTAdyenPaymentTypeSetup);
        exit(EFTAdyenPaymentTypeSetup."Log Level");
    end;

    local procedure IsEnabled(): Boolean
    var
        EFTAdyenFeatureFlag: Codeunit "NPR EFT Adyen Feature Flag";
    begin
        exit(EFTAdyenFeatureFlag.IsEnabled());
    end;
}