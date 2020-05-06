codeunit 6184532 "EFT NETSCloud Integration"
{
    // NPR5.54/MMV /20200129 CASE 364340 Created object


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

    procedure IntegrationType(): Text
    begin
        exit('NETS_CLOUD');
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
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"EFT NETSCloud Integration";
        tmpEFTIntegrationType.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "EFT Aux Operation" temporary)
    begin
        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := CANCEL_ACTION;
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := BALANCE_ENQUIRY;
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 3;
        tmpEFTAuxOperation.Description := DOWNLOAD_DATASET;
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation.Init;
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 4;
        tmpEFTAuxOperation.Description := DOWNLOAD_SOFTWARE;
        tmpEFTAuxOperation.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "EFT Setup")
    var
        EFTNETSCloudPOSUnitSetupPage: Page "EFT NETS Cloud POS Unit Setup";
        EFTNETSCloudPOSUnitSetup: Record "EFT NETS Cloud POS Unit Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
          exit;

        GetPOSUnitParameters(EFTSetup, EFTNETSCloudPOSUnitSetup);
        Commit;
        EFTNETSCloudPOSUnitSetupPage.SetEFTSetup(EFTSetup);
        EFTNETSCloudPOSUnitSetupPage.SetRecord(EFTNETSCloudPOSUnitSetup);
        EFTNETSCloudPOSUnitSetupPage.RunModal();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "EFT Setup")
    var
        EFTNETSCloudPaymentSetup: Record "EFT NETS Cloud Payment Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
          exit;

        GetPaymentTypeParameters(EFTSetup, EFTNETSCloudPaymentSetup);
        Commit;
        PAGE.RunModal(PAGE::"EFT NETS Cloud Payment Setup", EFTNETSCloudPaymentSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
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

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);

        ErrorIfNotLatestFinancialTransaction(EftTransactionRequest, true);
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

        CreateGenericRequest(EftTransactionRequest);

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest.Insert(true);
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

        ErrorIfNotLatestFinancialTransaction(EftTransactionRequest, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateEndWorkshiftRequest', '', false, false)]
    local procedure OnCreateEndWorkshiftRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
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

        if not GetAutoReconcileOnBalancing(EFTSetup) then
          exit;

        tmpEFTSetup := EFTSetup;
        tmpEFTSetup.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "EFT Transaction Request";var Handled: Boolean)
    var
        EFTNETSCloudProtocol: Codeunit "EFT NETSCloud Protocol";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;
        Handled := true;

        EFTNETSCloudProtocol.SendEftDeviceRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;

        if not CODEUNIT.Run(CODEUNIT::"EFT Try Print Receipt", EftTransactionRequest) then
          Message(GetLastErrorText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterPaymentConfirm', '', false, false)]
    local procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "EFT Transaction Request";var DoNotResume: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
          exit;

        if EftTransactionRequest."Signature Type" = EftTransactionRequest."Signature Type"::"On Receipt" then begin
          if not Confirm(SIGNATURE_APPROVAL) then begin
            VoidTransactionAfterSignatureDecline(EftTransactionRequest);
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnBeforePauseFrontEnd', '', false, false)]
    local procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "EFT Transaction Request";var Skip: Boolean)
    begin
        if not EFTTransactionRequest.IsType(IntegrationType()) then
          exit;

        with EFTTransactionRequest do
          Skip := ("Processing Type" in ["Processing Type"::SETUP, "Processing Type"::VOID, "Processing Type"::LOOK_UP, "Processing Type"::AUXILIARY, "Processing Type"::CLOSE]);
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
          Skip := ("Processing Type" in ["Processing Type"::SETUP, "Processing Type"::VOID, "Processing Type"::LOOK_UP, "Processing Type"::AUXILIARY, "Processing Type"::CLOSE]);
    end;

    procedure HandleProtocolResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    var
        EFTInterface: Codeunit "EFT Interface";
        EFTPaymentMapping: Codeunit "EFT Payment Mapping";
        PaymentTypePOS: Record "Payment Type POS";
    begin
        case EftTransactionRequest."Processing Type" of
          EftTransactionRequest."Processing Type"::PAYMENT,
          EftTransactionRequest."Processing Type"::REFUND,
          EftTransactionRequest."Processing Type"::LOOK_UP :
            HandleTrxResponse(EftTransactionRequest);

          EftTransactionRequest."Processing Type"::VOID :
            HandleVoidResponse(EftTransactionRequest);

          EftTransactionRequest."Processing Type"::CLOSE :
            HandleReconciliation(EftTransactionRequest);

          EftTransactionRequest."Processing Type"::AUXILIARY :
            case EftTransactionRequest."Auxiliary Operation ID" of
              1 : ; //Cancel_action response
              2 : HandleBalanceEnquiryResponse(EftTransactionRequest);
              3 : HandleDownloadDatasetResponse(EftTransactionRequest);
              4 : HandleDownloadSoftwareResponse(EftTransactionRequest);
            end;
        end;

        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    local procedure HandleTrxResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    var
        EFTPaymentMapping: Codeunit "EFT Payment Mapping";
        PaymentTypePOS: Record "Payment Type POS";
    begin
        if not EftTransactionRequest.Successful then
          Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");

        if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, PaymentTypePOS) then begin
          EftTransactionRequest."POS Payment Type Code" := PaymentTypePOS."No.";
          EftTransactionRequest."Card Name" := CopyStr(PaymentTypePOS.Description, 1, MaxStrLen (EftTransactionRequest."Card Name"));
        end;
        EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
        EftTransactionRequest.Modify;
    end;

    local procedure HandleVoidResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    var
        EFTPaymentMapping: Codeunit "EFT Payment Mapping";
        PaymentTypePOS: Record "Payment Type POS";
    begin
        if EftTransactionRequest.Successful then begin
          Message(VOID_SUCCESS, EftTransactionRequest."Entry No.");
          if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, PaymentTypePOS) then begin
            EftTransactionRequest."POS Payment Type Code" := PaymentTypePOS."No.";
            EftTransactionRequest."Card Name" := CopyStr(PaymentTypePOS.Description, 1, MaxStrLen (EftTransactionRequest."Card Name"));
          end;
          EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
          EftTransactionRequest.Modify;
        end else begin
          Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
        end;
    end;

    local procedure HandleReconciliation(var EftTransactionRequest: Record "EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then begin
          Message(RECONCILE_SUCCESS);
          Commit;
          if not CODEUNIT.Run(CODEUNIT::"EFT Try Print Receipt", EftTransactionRequest) then
            Message(GetLastErrorText);
        end else begin
          Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
        end;
    end;

    local procedure HandleBalanceEnquiryResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
          Message(EftTransactionRequest."Result Display Text")
        else
          Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    local procedure HandleDownloadDatasetResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
          Message(OPERATION_SUCCESS, EftTransactionRequest."Integration Type", EftTransactionRequest."Auxiliary Operation Desc.")
        else
          Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    local procedure HandleDownloadSoftwareResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    begin
        if EftTransactionRequest.Successful then
          Message(OPERATION_SUCCESS, EftTransactionRequest."Integration Type", EftTransactionRequest."Auxiliary Operation Desc.")
        else
          Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
    end;

    local procedure "// EFT Parameter Handling"()
    begin
    end;

    procedure GetAPIUsername(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTNETSCloudPaymentSetup: Record "EFT NETS Cloud Payment Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTNETSCloudPaymentSetup);
        exit(EFTNETSCloudPaymentSetup."API Username");
    end;

    procedure GetAPIPassword(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTNETSCloudPaymentSetup: Record "EFT NETS Cloud Payment Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTNETSCloudPaymentSetup);
        exit(EFTNETSCloudPaymentSetup."API Password");
    end;

    procedure GetEnvironment(EFTSetupIn: Record "EFT Setup"): Integer
    var
        EFTNETSCloudPaymentSetup: Record "EFT NETS Cloud Payment Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTNETSCloudPaymentSetup);
        exit(EFTNETSCloudPaymentSetup.Environment);
    end;

    procedure GetLogLevel(EFTSetupIn: Record "EFT Setup"): Integer
    var
        EFTNETSCloudPaymentSetup: Record "EFT NETS Cloud Payment Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTNETSCloudPaymentSetup);
        exit(EFTNETSCloudPaymentSetup."Log Level");
    end;

    procedure GetAutoReconcileOnBalancing(EFTSetupIn: Record "EFT Setup"): Boolean
    var
        EFTNETSCloudPaymentSetup: Record "EFT NETS Cloud Payment Setup";
    begin
        GetPaymentTypeParameters(EFTSetupIn, EFTNETSCloudPaymentSetup);
        exit(EFTNETSCloudPaymentSetup."Auto Reconcile on EOD");
    end;

    local procedure GetPaymentTypeParameters(EFTSetup: Record "EFT Setup";var EFTNETSCloudPaymentSetupOut: Record "EFT NETS Cloud Payment Setup")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not EFTNETSCloudPaymentSetupOut.Get(EFTSetup."Payment Type POS") then begin
          EFTNETSCloudPaymentSetupOut.Init;
          EFTNETSCloudPaymentSetupOut."Payment Type POS" := EFTSetup."Payment Type POS";
          EFTNETSCloudPaymentSetupOut.Insert;
        end;
    end;

    procedure GetTerminalID(EFTSetupIn: Record "EFT Setup"): Text
    var
        EFTNETSCloudPOSUnitSetup: Record "EFT NETS Cloud POS Unit Setup";
    begin
        GetPOSUnitParameters(EFTSetupIn, EFTNETSCloudPOSUnitSetup);
        exit(EFTNETSCloudPOSUnitSetup."Terminal ID");
    end;

    local procedure GetPOSUnitParameters(EFTSetup: Record "EFT Setup";var EFTNETSCloudPOSUnitSetup: Record "EFT NETS Cloud POS Unit Setup")
    begin
        if not EFTNETSCloudPOSUnitSetup.Get(EFTSetup."POS Unit No.") then begin
          EFTNETSCloudPOSUnitSetup.Init;
          EFTNETSCloudPOSUnitSetup."POS Unit No." := EFTSetup."POS Unit No.";
          EFTNETSCloudPOSUnitSetup.Insert;
        end;
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure CreateGenericRequest(var EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTSetup: Record "EFT Setup";
        PaymentTypePOS: Record "Payment Type POS";
        OutStream: OutStream;
        EFTNETSCloudProtocol: Codeunit "EFT NETSCloud Protocol";
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

    procedure VoidTransactionAfterSignatureDecline(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        EFTSetup: Record "EFT Setup";
        VoidEFTTransactionRequest: Record "EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        EFTFrameworkMgt.CreateVoidRequest(VoidEFTTransactionRequest, EFTSetup, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.", EFTTransactionRequest."Entry No.", false);
        Commit;
        EFTFrameworkMgt.SendRequest(VoidEFTTransactionRequest);
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "EFT Transaction Request"): Text
    begin
        if EFTTransactionRequest."Card Name" <> '' then begin
          if (StrLen(EFTTransactionRequest."Card Number") > 8) then
            exit(StrSubstNo ('%1: %2', EFTTransactionRequest."Card Name", CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number")-7)))
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

    procedure AbortTransaction(EFTTransactionRequest: Record "EFT Transaction Request"): Boolean
    var
        EFTFrameworkMgt: Codeunit "EFT Framework Mgt.";
        AbortEFTTransactionRequest: Record "EFT Transaction Request";
        EFTSetup: Record "EFT Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        EFTFrameworkMgt.CreateAuxRequest(AbortEFTTransactionRequest, EFTSetup, 1, EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
        AbortEFTTransactionRequest."Processed Entry No." := EFTTransactionRequest."Entry No.";
        AbortEFTTransactionRequest.Modify;
        Commit;
        EFTFrameworkMgt.SendRequest(AbortEFTTransactionRequest);
        AbortEFTTransactionRequest.Find;
        exit(AbortEFTTransactionRequest.Successful);
    end;

    procedure LookupTerminal(EFTSetup: Record "EFT Setup";var TerminalIDOut: Text): Boolean
    var
        EFTNETSCloudProtocol: Codeunit "EFT NETSCloud Protocol";
        JSON: Text;
        JObject: DotNet npNetJObject;
        JToken: DotNet npNetJToken;
        JArray: DotNet npNetJArray;
        TmpRetailList: Record "Retail List" temporary;
    begin
        JSON := EFTNETSCloudProtocol.TerminalList(EFTSetup);
        JObject := JObject.Parse(JSON);
        JArray := JObject.Item('terminals');

        foreach JToken in JArray do begin
          TmpRetailList.Number += 1;
          TmpRetailList.Choice := JToken.Item('terminalId').ToString();
          TmpRetailList.Insert;
        end;

        if (PAGE.RunModal(0, TmpRetailList) <> ACTION::LookupOK) then
          exit(false);

        TerminalIDOut := TmpRetailList.Choice;
        exit(true);
    end;

    procedure ShowTerminalSettings(EFTSetup: Record "EFT Setup")
    var
        EFTNETSCloudProtocol: Codeunit "EFT NETSCloud Protocol";
        JSON: Text;
        JObject: DotNet npNetJObject;
    begin
        JObject := JObject.Parse(EFTNETSCloudProtocol.TerminalSettings(EFTSetup));
        Message(JObject.ToString());
    end;

    local procedure ErrorIfNotLatestFinancialTransaction(EFTTransactionRequestIn: Record "EFT Transaction Request";IncludeVoids: Boolean)
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
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
        if (EFTTransactionRequest.FindLast) then
          if (EFTTransactionRequest."Entry No." = EFTTransactionRequestIn."Processed Entry No.") then
            exit;

        Error(ERROR_ONLY_LAST, Format(EFTTransactionRequestIn."Processing Type"), EFTTransactionRequestIn."Hardware ID");
    end;
}

