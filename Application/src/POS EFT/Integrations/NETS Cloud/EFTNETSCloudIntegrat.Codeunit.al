codeunit 6184532 "NPR EFT NETSCloud Integrat."
{
    // NPR5.54/MMV /20200129 CASE 364340 Created object
    // NPR5.55/MMV /20200525 CASE 405984 Fixed frontend resume behaviour after lookup prompt.


    trigger OnRun()
    begin
    end;

    var
        Description: Label 'NETS Cloud Terminal API';
        CANCEL_ACTION: Label 'Cancel Action';
        BALANCE_ENQUIRY: Label 'Balance Enquiry';
        DOWNLOAD_DATASET: Label 'Download Dataset';
        DOWNLOAD_SOFTWARE: Label 'Download Software';
        SIGNATURE_APPROVAL: Label 'Customer must sign the receipt. Please confirm that signature is valid';
        TRX_ERROR: Label '%1 %2 failed\%3\%4';
        VOID_SUCCESS: Label 'Transaction %1 voided successfully';
        CARD: Label 'Card: %1';
        UNKNOWN: Label 'Unknown Electronic Payment Type';
        ERROR_ONLY_LAST: Label 'Can only perform %1 on last transaction on terminal %2';
        OPERATION_SUCCESS: Label '%1 %2 Success';
        RECONCILE_SUCCESS: Label 'NETS Terminal Reconciliation Success';

    procedure IntegrationType(): Code[20]
    begin
        exit('NETS_CLOUD');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT NETSCloud Integrat.";
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin
        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := CANCEL_ACTION;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := BALANCE_ENQUIRY;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 3;
        tmpEFTAuxOperation.Description := DOWNLOAD_DATASET;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 4;
        tmpEFTAuxOperation.Description := DOWNLOAD_SOFTWARE;
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

        EftTransactionRequest.TestField("Cashback Amount", 0);

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
        end;

        CreateGenericRequest(EftTransactionRequest);

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);

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

        if not GetAutoReconcileOnBalancing(EFTSetup) then
            exit;

        tmpEFTSetup := EFTSetup;
        tmpEFTSetup.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EFTNETSCloudProtocol.SendEftDeviceRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        if not CODEUNIT.Run(CODEUNIT::"NPR EFT Try Print Receipt", EftTransactionRequest) then
            Message(GetLastErrorText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterPaymentConfirm', '', false, false)]
    local procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "NPR EFT Transaction Request"; var DoNotResume: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        if EftTransactionRequest."Signature Type" = EftTransactionRequest."Signature Type"::"On Receipt" then begin
            if not Confirm(SIGNATURE_APPROVAL) then begin
                VoidTransactionAfterSignatureDecline(EftTransactionRequest);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnBeforePauseFrontEnd', '', false, false)]
    local procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin
        if not EFTTransactionRequest.IsType(IntegrationType()) then
            exit;

        Skip := (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::SETUP, EFTTransactionRequest."Processing Type"::VOID, EFTTransactionRequest."Processing Type"::LOOK_UP, EFTTransactionRequest."Processing Type"::AUXILIARY, EFTTransactionRequest."Processing Type"::CLOSE]);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnBeforeResumeFrontEnd', '', false, false)]
    local procedure OnBeforeResumeFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            exit;
        if not EFTTransactionRequest.IsType(IntegrationType()) then
            exit;

        //-NPR5.55 [405984]
        Skip := (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::SETUP, EFTTransactionRequest."Processing Type"::VOID, EFTTransactionRequest."Processing Type"::AUXILIARY, EFTTransactionRequest."Processing Type"::CLOSE])
        //+NPR5.55 [405984]
    end;

    procedure HandleProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT,
          EftTransactionRequest."Processing Type"::REFUND,
          EftTransactionRequest."Processing Type"::LOOK_UP:
                HandleTrxResponse(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::VOID:
                HandleVoidResponse(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::CLOSE:
                HandleReconciliation(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    1:
                        ; //Cancel_action response
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
        if not EftTransactionRequest.Successful then
            Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");

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
    begin
        if EftTransactionRequest.Successful then begin
            Message(VOID_SUCCESS, EftTransactionRequest."Entry No.");
            if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, POSPaymentMethod) then begin
                EftTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
                EftTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftTransactionRequest."Card Name"));
            end;
            EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
            EftTransactionRequest.Modify();
        end else begin
            Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
        end;
    end;

    local procedure HandleReconciliation(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then begin
            Message(RECONCILE_SUCCESS);
            Commit();
            if not CODEUNIT.Run(CODEUNIT::"NPR EFT Try Print Receipt", EftTransactionRequest) then
                Message(GetLastErrorText);
        end else begin
            Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
        end;
    end;

    local procedure HandleBalanceEnquiryResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
            Message(EftTransactionRequest."Result Display Text")
        else
            Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    local procedure HandleDownloadDatasetResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
            Message(OPERATION_SUCCESS, EftTransactionRequest."Integration Type", EftTransactionRequest."Auxiliary Operation Desc.")
        else
            Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    local procedure HandleDownloadSoftwareResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
            Message(OPERATION_SUCCESS, EftTransactionRequest."Integration Type", EftTransactionRequest."Auxiliary Operation Desc.")
        else
            Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
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
        OutStream: OutStream;
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");

        EFTTransactionRequest."Integration Version Code" := '1.0.0'; //Nets Connect@Cloud REST 1.0.0
        EFTTransactionRequest."Hardware ID" := GetTerminalID(EFTSetup);
        if GetEnvironment(EFTSetup) <> 0 then
            EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";

        EFTTransactionRequest.TestField("Hardware ID");

        EFTTransactionRequest."Access Token".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.Write(EFTNETSCloudProtocol.GetToken(EFTSetup));
    end;

    procedure VoidTransactionAfterSignatureDecline(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        EFTFrameworkMgt.CreateVoidRequest(VoidEFTTransactionRequest, EFTSetup, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.", EFTTransactionRequest."Entry No.", false);
        Commit();
        EFTFrameworkMgt.SendRequest(VoidEFTTransactionRequest);
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        CardLbl: Label '%1: %2', Locked = true;
    begin
        if EFTTransactionRequest."Card Name" <> '' then begin
            if (StrLen(EFTTransactionRequest."Card Number") > 8) then
                exit(StrSubstNo(CardLbl, EFTTransactionRequest."Card Name", CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
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

    procedure AbortTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        AbortEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        EFTFrameworkMgt.CreateAuxRequest(AbortEFTTransactionRequest, EFTSetup, 1, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        AbortEFTTransactionRequest."Processed Entry No." := EFTTransactionRequest."Entry No.";
        AbortEFTTransactionRequest.Modify();
        Commit();
        EFTFrameworkMgt.SendRequest(AbortEFTTransactionRequest);
        AbortEFTTransactionRequest.Find();
        exit(AbortEFTTransactionRequest.Successful);
    end;

    procedure LookupTerminal(EFTSetup: Record "NPR EFT Setup"; var TerminalIDOut: Text): Boolean
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        JSON: Text;
        JObject: DotNet NPRNetJObject;
        JToken: DotNet NPRNetJToken;
        JArray: DotNet NPRNetJArray;
        TempRetailList: Record "NPR Retail List" temporary;
    begin
        JSON := EFTNETSCloudProtocol.TerminalList(EFTSetup);
        JObject := JObject.Parse(JSON);
        JArray := JObject.Item('terminals');

        foreach JToken in JArray do begin
            TempRetailList.Number += 1;
            TempRetailList.Choice := JToken.Item('terminalId').ToString();
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
        JObject: DotNet NPRNetJObject;
    begin
        JObject := JObject.Parse(EFTNETSCloudProtocol.TerminalSettings(EFTSetup));
        Message(JObject.ToString());
    end;

    local procedure ErrorIfNotLatestFinancialTransaction(EFTTransactionRequestIn: Record "NPR EFT Transaction Request"; IncludeVoids: Boolean)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
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

        Error(ERROR_ONLY_LAST, Format(EFTTransactionRequestIn."Processing Type"), EFTTransactionRequestIn."Hardware ID");
    end;
}

