codeunit 6184540 "NPR EFT NETS BAXI Integration"
{
    Access = Internal;
    // NPR5.54/MMV /20200129 CASE 364340 Created object


    trigger OnRun()
    begin
    end;

    var
        Description: Label 'NETS BAXI .NET';
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
        RECONCILIATION: Label 'Reconciliation';

    procedure IntegrationType(): Code[20]
    begin
        exit('NETS_BAXI_NET');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin
        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationType();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT NETS BAXI Integration";
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin
        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := BALANCE_ENQUIRY;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := DOWNLOAD_DATASET;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 3;
        tmpEFTAuxOperation.Description := DOWNLOAD_SOFTWARE;
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 4;
        tmpEFTAuxOperation.Description := RECONCILIATION;
        tmpEFTAuxOperation.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Commit();
        PAGE.RunModal(PAGE::"NPR EFT NETS BAXI Paym. Setup", EFTNETSBAXIPaymentSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
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

        CreateGenericRequest(EftTransactionRequest);

        if EftTransactionRequest."Processed Entry No." <> 0 then begin
            OriginalEftTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
            if OriginalEftTransactionRequest.Recovered then
                OriginalEftTransactionRequest.Get(OriginalEftTransactionRequest."Recovered by Entry No.");

            EftTransactionRequest."Tip Amount" := OriginalEftTransactionRequest."Tip Amount"; //Refund original
            EftTransactionRequest."Fee Amount" := OriginalEftTransactionRequest."Fee Amount"; //Refund original
        end;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateBeginWorkshiftRequest', '', false, false)]
    local procedure OnCreateBeginWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        CreateGenericRequest(EftTransactionRequest);
        EftTransactionRequest.Insert(true);
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
        EftTransactionRequest."Manual Voidable" := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnQueueCloseBeforeRegisterBalance', '', false, false)]
    local procedure OnQueueCloseBeforeRegisterBalance(POSSession: Codeunit "NPR POS Session"; var tmpEFTSetup: Record "NPR EFT Setup" temporary)
    var
        EFTSetup: Record "NPR EFT Setup";
        POSSetup: Codeunit "NPR POS Setup";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
    begin
        POSSession.GetSetup(POSSetup);

        EFTSetup.SetFilter("POS Unit No.", POSSetup.GetPOSUnitNo());
        EFTSetup.SetRange("EFT Integration Type", IntegrationType());
        if not EFTSetup.FindFirst() then begin
            EFTSetup.SetRange("POS Unit No.", '');
            if not EFTSetup.FindFirst() then
                exit;
        end;

        GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        if not EFTNETSBAXIPaymentSetup."Auto Reconcile On EOD" then
            exit;

        tmpEFTSetup := EFTSetup;
        tmpEFTSetup.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTNETSBAXIProtocol: Codeunit "NPR EFT NETS BAXI Protocol";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EFTNETSBAXIProtocol.SendEftDeviceRequest(EftTransactionRequest);
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
                DoNotResume := true;
                VoidTransactionAfterSignatureDecline(EftTransactionRequest);
            end;
        end;
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

            EftTransactionRequest."Processing Type"::OPEN,
          EftTransactionRequest."Processing Type"::CLOSE:
                HandleOpenCloseResponse(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    1:
                        HandleBalanceEnquiryResponse(EftTransactionRequest);
                    2:
                        HandleDownloadDatasetResponse(EftTransactionRequest);
                    3:
                        HandleDownloadSoftwareResponse(EftTransactionRequest);
                    4:
                        HandleReconciliation(EftTransactionRequest);
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
        TODO: Cleanup workaround to BC17 message bug

        if not EftTransactionRequest.Successful then
            Message(TRX_ERROR, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
        */

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

    local procedure HandleOpenCloseResponse(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if EFTTransactionRequest.Successful then
            Message(OPERATION_SUCCESS, EFTTransactionRequest."Integration Type", Format(EFTTransactionRequest."Processing Type"))
        else
            Message(TRX_ERROR, EFTTransactionRequest."Integration Type", Format(EFTTransactionRequest."Processing Type"), EFTTransactionRequest."Result Display Text", EFTTransactionRequest."NST Error");

        if EFTTransactionRequest.Successful then begin
            Commit();
            if not CODEUNIT.Run(CODEUNIT::"NPR EFT Try Print Receipt", EFTTransactionRequest) then
                Message(GetLastErrorText);
        end
    end;

    procedure GetPaymentTypeParameters(EFTSetup: Record "NPR EFT Setup"; var EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup")
    begin
        EFTSetup.TestField("Payment Type POS");

        if not EFTNETSBAXIPaymentSetup.Get(EFTSetup."Payment Type POS") then begin
            EFTNETSBAXIPaymentSetup.Init();
            EFTNETSBAXIPaymentSetup."Payment Type POS" := EFTSetup."Payment Type POS";
            EFTNETSBAXIPaymentSetup.Insert();
        end;
    end;

    local procedure CreateGenericRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");

        EFTTransactionRequest."Integration Version Code" := '1.9.0.821';
        GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        if EFTNETSBAXIPaymentSetup."Host Environment" <> EFTNETSBAXIPaymentSetup."Host Environment"::Production then
            EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";
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
        POSDescriptionLbl: Label '%1: %2', Locked = true;
    begin
        if EFTTransactionRequest."Card Name" <> '' then begin
            if (StrLen(EFTTransactionRequest."Card Number") > 8) then
                exit(StrSubstNo(POSDescriptionLbl, EFTTransactionRequest."Card Name", CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
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

    local procedure ErrorIfNotLatestFinancialTransaction(EFTTransactionRequestIn: Record "NPR EFT Transaction Request"; IncludeVoids: Boolean)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequestIn.TestField("Register No.");
        EFTTransactionRequestIn.TestField("Processed Entry No.");

        EFTTransactionRequest.SetRange("Register No.", EFTTransactionRequestIn."Register No.");
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

