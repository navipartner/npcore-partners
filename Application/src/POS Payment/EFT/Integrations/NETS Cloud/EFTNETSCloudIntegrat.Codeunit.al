codeunit 6184532 "NPR EFT NETSCloud Integrat."
{
    Access = Internal;

    var
        TrxErrorLbl: Label '%1 %2 failed\%3\%4';
        OperationSuccessLbl: Label '%1 %2 Success';

    procedure IntegrationType(): Code[20]
    begin
        exit('NETS_CLOUD');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    var
        DescriptionLbl: Label 'NETS Cloud Terminal API';
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := DescriptionLbl;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT NETSCloud Integrat.";
        tmpEFTIntegrationType."Version 2" := true;
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    var
        BalanceEnquiryLbl: Label 'Balance Enquiry';
        DownloadDatasetLbl: Label 'Download Dataset';
        DownloadSoftwareLbl: Label 'Download Software';
    begin
        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := BalanceEnquiryLbl;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 3;
        tmpEFTAuxOperation.Description := DownloadDatasetLbl;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 4;
        tmpEFTAuxOperation.Description := DownloadSoftwareLbl;
        tmpEFTAuxOperation.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTNETSCloudPOSUnitSetupPage: Page "NPR EFT NETSCloud POSUnitSetup";
        EFTNETSCloudPOSUnitSetup: Record "NPR EFT NETSCloud Unit Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetPOSUnitParameters(EFTSetup, EFTNETSCloudPOSUnitSetup);
        Commit();
        EFTNETSCloudPOSUnitSetupPage.SetEFTSetup(EFTSetup);
        EFTNETSCloudPOSUnitSetupPage.SetRecord(EFTNETSCloudPOSUnitSetup);
        EFTNETSCloudPOSUnitSetupPage.RunModal();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetPaymentTypeParameters(EFTSetup, EFTNETSCloudPaymentSetup);
        Commit();
        PAGE.RunModal(PAGE::"NPR EFT NETS Cloud Paym. Setup", EFTNETSCloudPaymentSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);

        EftTransactionRequest.TestField("Amount Input");
        if EftTransactionRequest."Amount Input" = EftTransactionRequest."Cashback Amount" then begin
            EftTransactionRequest.FieldError("Cashback Amount");
        end;

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);

        ErrorIfNotLatestFinancialTransaction(EftTransactionRequest, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
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

            EftTransactionRequest."Tip Amount" := OriginalEftTransactionRequest."Tip Amount"; //Void original
            EftTransactionRequest."Fee Amount" := OriginalEftTransactionRequest."Fee Amount"; //Void original
        end;

        CreateGenericRequest(EftTransactionRequest);

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);

        if EftTransactionRequest."Processed Entry No." <> 0 then begin
            OriginalEftTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
            if OriginalEftTransactionRequest.Recovered then
                OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Recovered by Entry No.");

            EftTransactionRequest."Tip Amount" := OriginalEftTransactionRequest."Tip Amount"; //Void original
            EftTransactionRequest."Fee Amount" := OriginalEftTransactionRequest."Fee Amount"; //Void original
        end;

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest.Insert(true);

        ErrorIfNotLatestFinancialTransaction(EftTransactionRequest, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateEndWorkshiftRequest', '', false, false)]
    local procedure OnCreateEndWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateGiftCardLoadRequest', '', false, false)]
    local procedure OnCreateGiftCardLoadRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnEndOfDayCloseEft', '', false, false)]
    local procedure OnEndOfDayCloseEft(EndOfDayType: Option "X-Report","Z-Report"; var EftWorkflows: Dictionary of [Text, JsonObject])
    var
        EFTSetup: Record "NPR EFT Setup";
        POSSetup: Codeunit "NPR POS Setup";
        POSSession: Codeunit "NPR POS Session";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSale: Record "NPR POS Sale";
        Request: JsonObject;
        POSActionEFTOp2Bus: Codeunit "NPR POS Action: EFT Op 2 Bus.";
    begin
        if EndOfDayType <> EndOfDayType::"Z-Report" then
            exit;

        POSSession.GetSetup(POSSetup);

        EFTSetup.SetFilter("POS Unit No.", POSSetup.GetPOSUnitNo());
        EFTSetup.SetRange("EFT Integration Type", IntegrationType());
        if not EFTSetup.FindFirst() then begin
            EFTSetup.SetRange("POS Unit No.", '');
            if not EFTSetup.FindFirst() then
                exit;
        end;

        if not GetAutoReconcileOnBalancing(EFTSetup) then
            exit;

        POSSession.GetSale(POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);

        POSActionEFTOp2Bus.StartEndWorkshift(EFTSetup, POSSale, Request);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]
    local procedure OnPrepareRequestSend(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        if EftTransactionRequest."Processing Type" in [EftTransactionRequest."Processing Type"::PAYMENT, EftTransactionRequest."Processing Type"::REFUND, EftTransactionRequest."Processing Type"::GIFTCARD_LOAD] then begin
            Request.Add('EntryNo', EFTTransactionRequest."Entry No.");
            Request.Add('formattedAmount', Format(EFTTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));
            RequestMechanism := RequestMechanism::POSWorkflow;
            Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_CLOUD_TRX);
        end else begin
            RequestMechanism := RequestMechanism::Synchronous;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnSendRequestSynchronously', '', false, false)]
    local procedure OnSendRequestSynchronously(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        Handled := true;
        EFTNETSCloudProtocol.ProcessRequestSynchronously(EftTransactionRequest);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        if EftTransactionRequest."Processing Type" in [EftTransactionRequest."Processing Type"::PAYMENT,
                                                       EftTransactionRequest."Processing Type"::REFUND,
                                                       EftTransactionRequest."Processing Type"::GIFTCARD_LOAD] then
            exit; //printed from within workflow to avoid modal page on background task return

        if not Codeunit.Run(Codeunit::"NPR EFT Try Print Receipt", EftTransactionRequest) then
            Message(GetLastErrorText);
    end;

    procedure HandleProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT,
          EftTransactionRequest."Processing Type"::REFUND,
          EftTransactionRequest."Processing Type"::LOOK_UP,
          EftTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                HandleTrxResponse(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::VOID:
                HandleVoidResponse(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::CLOSE:
                HandleReconciliation(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    2:
                        HandleBalanceEnquiryResponse(EftTransactionRequest);
                    3:
                        HandleDownloadDatasetResponse(EftTransactionRequest);
                    4:
                        HandleDownloadSoftwareResponse(EftTransactionRequest);
                end;
        end;

        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    local procedure HandleTrxResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
    begin
        if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, POSPaymentMethod) then begin
            EftTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
            EftTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftTransactionRequest."Card Name"));
        end;
        EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
        EftTransactionRequest.Modify();
    end;

    local procedure HandleVoidResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
        VoidSuccessLbl: Label 'Transaction %1 voided successfully';
    begin
        if EftTransactionRequest.Successful then begin
            Message(VoidSuccessLbl, EftTransactionRequest."Entry No.");
            if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, POSPaymentMethod) then begin
                EftTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
                EftTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftTransactionRequest."Card Name"));
            end;
            EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
            EftTransactionRequest.Modify();
        end else begin
            Message(TrxErrorLbl, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
        end;
    end;

    local procedure HandleReconciliation(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        ReconcileSuccessLbl: Label 'NETS Terminal Reconciliation Success';
    begin
        if EftTransactionRequest.Successful then begin
            Message(ReconcileSuccessLbl);
            Commit();
            if not CODEUNIT.Run(CODEUNIT::"NPR EFT Try Print Receipt", EftTransactionRequest) then
                Message(GetLastErrorText);
        end else begin
            Message(TrxErrorLbl, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
        end;
    end;

    local procedure HandleBalanceEnquiryResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
            Message(EftTransactionRequest."Result Display Text")
        else
            Message(TrxErrorLbl, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    local procedure HandleDownloadDatasetResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
            Message(OperationSuccessLbl, EftTransactionRequest."Integration Type", EftTransactionRequest."Auxiliary Operation Desc.")
        else
            Message(TrxErrorLbl, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    local procedure HandleDownloadSoftwareResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
            Message(OperationSuccessLbl, EftTransactionRequest."Integration Type", EftTransactionRequest."Auxiliary Operation Desc.")
        else
            Message(TrxErrorLbl, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    procedure GetAPIUsername(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTNETSCloudPaymentSetup);
        exit(EFTNETSCloudPaymentSetup."API Username");
    end;

    procedure GetAPIPassword(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTNETSCloudPaymentSetup);
        exit(EFTNETSCloudPaymentSetup."API Password");
    end;

    procedure GetEnvironment(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTNETSCloudPaymentSetup);
        exit(EFTNETSCloudPaymentSetup.Environment);
    end;

    procedure GetLogLevel(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTNETSCloudPaymentSetup);
        exit(EFTNETSCloudPaymentSetup."Log Level");
    end;

    procedure GetAutoReconcileOnBalancing(EFTSetupIn: Record "NPR EFT Setup"): Boolean
    var
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTNETSCloudPaymentSetup);
        exit(EFTNETSCloudPaymentSetup."Auto Reconcile on EOD");
    end;

    local procedure GetPaymentTypeParameters(EFTSetup: Record "NPR EFT Setup"; var EFTNETSCloudPaymentSetupOut: Record "NPR EFT NETS Cloud Paym. Setup")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not EFTNETSCloudPaymentSetupOut.Get(EFTSetup."Payment Type POS") then begin
            EFTNETSCloudPaymentSetupOut.Init();
            EFTNETSCloudPaymentSetupOut."Payment Type POS" := EFTSetup."Payment Type POS";
            EFTNETSCloudPaymentSetupOut.Insert();
        end;
    end;

    procedure GetTerminalID(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTNETSCloudPOSUnitSetup: Record "NPR EFT NETSCloud Unit Setup";
    begin
        GetPOSUnitParameters(EFTSetupIn, EFTNETSCloudPOSUnitSetup);
        exit(EFTNETSCloudPOSUnitSetup."Terminal ID");
    end;

    local procedure GetPOSUnitParameters(EFTSetup: Record "NPR EFT Setup"; var EFTNETSCloudPOSUnitSetup: Record "NPR EFT NETSCloud Unit Setup")
    begin
        if not EFTNETSCloudPOSUnitSetup.Get(EFTSetup."POS Unit No.") then begin
            EFTNETSCloudPOSUnitSetup.Init();
            EFTNETSCloudPOSUnitSetup."POS Unit No." := EFTSetup."POS Unit No.";
            EFTNETSCloudPOSUnitSetup.Insert();
        end;
    end;

    local procedure CreateGenericRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");

        EFTTransactionRequest."Integration Version Code" := '1.2.7'; //Nets Connect@Cloud REST 1.2.7
#pragma warning disable AA0139
        EFTTransactionRequest."Hardware ID" := GetTerminalID(EFTSetup);
#pragma warning restore AA0139
        if GetEnvironment(EFTSetup) <> 0 then
            EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";

        EFTTransactionRequest.TestField("Hardware ID");

        if EFTSetup.UseAccountPostingForServices() then begin
            POSPaymentMethod.Get(EFTSetup."Payment Type POS");
            POSPaymentMethod.TestField("EFT Surcharge Account No.");
            POSPaymentMethod.TestField("EFT Tip Account No.");
        end;

        EFTNETSCloudProtocol.GetToken(EFTSetup); // Trigger token refresh if missing
    end;

    procedure SignaturePrompt(var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not EFTTransactionRequest.Successful then
            exit(false);
        if not (EftTransactionRequest."Signature Type" = EftTransactionRequest."Signature Type"::"On Receipt") then
            exit(false);

        case true of
            EftTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]:
                ;
            EftTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::LOOK_UP]:
                begin
                    OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
                    if not (OriginalEFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then
                        exit(false);
                end;
            else
                exit(false);
        end;

        exit(true);
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        CardNameLbl: Label '%1: %2', Locked = true;
        UnknownLbl: Label 'Unknown Electronic Payment Type';
    begin
        if EFTTransactionRequest."Card Name" <> '' then begin
            if (StrLen(EFTTransactionRequest."Card Number") > 8) then
                exit(StrSubstNo(CardNameLbl, EFTTransactionRequest."Card Name", CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
            else
                exit(StrSubstNo(EFTTransactionRequest."Card Name"));
        end;

        if EFTTransactionRequest."Stored Value Account Type" <> '' then
            exit(EFTTransactionRequest."Stored Value Account Type");

        if EFTTransactionRequest."Payment Instrument Type" <> '' then
            exit(EFTTransactionRequest."Payment Instrument Type");

        if EFTTransactionRequest."Card Number" <> '' then
            exit(EFTTransactionRequest."Card Number");

        exit(UnknownLbl);
    end;

    procedure LookupTerminal(EFTSetup: Record "NPR EFT Setup"; var TerminalIDOut: Text): Boolean
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        JSON: Text;
        JObject: JsonObject;
        JToken: JsonToken;
        JTokenId: JsonToken;
        JArray: JsonArray;
        TempRetailList: Record "NPR Retail List" temporary;
    begin
        JSON := EFTNETSCloudProtocol.TerminalList(EFTSetup);
        JObject.ReadFrom(JSON);
        JObject.SelectToken('terminals', JToken);
        JArray := JToken.AsArray();

        foreach JToken in JArray do begin
            TempRetailList.Number += 1;
            JToken.SelectToken('terminalId', JTokenId);
#pragma warning disable AA0139
            TempRetailList.Choice := JTokenId.AsValue().AsText();
#pragma warning restore AA0139
            TempRetailList.Insert();
        end;

        if (PAGE.RunModal(0, TempRetailList) <> ACTION::LookupOK) then
            exit(false);

        TerminalIDOut := TempRetailList.Choice;
        exit(true);
    end;

    procedure ShowTerminalSettings(EFTSetup: Record "NPR EFT Setup")
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        JObject: JsonObject;
        FormattedSettings: Text;
    begin
        JObject.ReadFrom(EFTNETSCloudProtocol.TerminalSettings(EFTSetup));
        JObject.WriteTo(FormattedSettings);
        Message(FormattedSettings);
    end;

    local procedure ErrorIfNotLatestFinancialTransaction(EFTTransactionRequestIn: Record "NPR EFT Transaction Request"; IncludeVoids: Boolean)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        ErrorOnlyLastLbl: Label 'Can only perform %1 on last transaction on terminal %2';
    begin
        EFTTransactionRequestIn.TestField("Hardware ID");
        EFTTransactionRequestIn.TestField("Processed Entry No.");

        EFTTransactionRequest.SetRange("Hardware ID", EFTTransactionRequestIn."Hardware ID");
        EFTTransactionRequest.SetRange("Integration Type", EFTTransactionRequestIn."Integration Type");
        if IncludeVoids then begin
            EFTTransactionRequest.SetFilter("Processing Type", '%1|%2|%3|%4',
              EFTTransactionRequest."Processing Type"::PAYMENT,
              EFTTransactionRequest."Processing Type"::REFUND,
              EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD,
              EFTTransactionRequest."Processing Type"::VOID);
        end else begin
            EFTTransactionRequest.SetFilter("Processing Type", '%1|%2|%3',
              EFTTransactionRequest."Processing Type"::PAYMENT,
              EFTTransactionRequest."Processing Type"::REFUND,
              EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD);
        end;
        if (EFTTransactionRequest.FindLast()) then
            if (EFTTransactionRequest."Entry No." = EFTTransactionRequestIn."Processed Entry No.") then
                exit;

        Error(ErrorOnlyLastLbl, Format(EFTTransactionRequestIn."Processing Type"), EFTTransactionRequestIn."Hardware ID");
    end;
}
