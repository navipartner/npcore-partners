codeunit 6184523 "NPR EFT ISMP Baxi Integ."
{
    // NPR5.51/CLVA/20190805 CASE 364011 Created object


    trigger OnRun()
    begin
    end;

    var
        EFTSetup: Record "NPR EFT Setup";
        Description: Label 'ISMP Baxi by Nets ';
        MerchantID: Text;
        PaymentTypePOS: Record "NPR Payment Type POS";
        Register: Record "NPR Register";
        InvalidParameter: Label '%1 setup for %2 %3 has invalid %4 configuration.';

    procedure IntegrationType(): Text
    begin
        exit('ISMPBAXI');
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
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR EFT ISMP Baxi Integ.";
        tmpEFTIntegrationType.Insert;
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

        EFTSetup.ShowEftPOSUnitParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationPaymentSetup', '', false, false)]
    local procedure OnConfigureIntegrationPaymentSetup(EFTSetup: Record "NPR EFT Setup")
    var
        EFTTypePaymentBLOBParam: Record "NPR EFTType Paym. BLOB Param.";
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
    begin
        if EFTSetup."EFT Integration Type" <> IntegrationType() then
            exit;

        GetMerchantID(EFTSetup);
        GetEnvironment(EFTSetup);

        EFTSetup.ShowEftPaymentParameters();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        Handled := true;

        InitializeGlobals(EftTransactionRequest."POS Payment Type Code", EftTransactionRequest."Register No.");

        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        //TODO: Implement API request looking up transaction results so lost results can be recovered later in case of error.
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalEftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        Handled := true;

        InitializeGlobals(EftTransactionRequest."POS Payment Type Code", EftTransactionRequest."Register No.");

        EftTransactionRequest.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        EFTISMPBaxiProtocol: Codeunit "NPR EFT ISMP Baxi Prot.";
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EFTISMPBaxiProtocol.SendEftDeviceRequest(EftTransactionRequest);
    end;

    local procedure "// Protocol Response"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184524, 'OnAfterProtocolResponse', '', false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    local procedure "// API Operations"()
    begin
    end;

    procedure InitializeGlobals(PaymentType: Code[10]; RegisterNo: Code[10])
    var
        EFTSetupIn: Record "NPR EFT Setup";
    begin
        EFTSetupIn.FindSetup(RegisterNo, PaymentType);
        if Format(EFTSetupIn.RecordId) = Format(EFTSetup.RecordId) then
            exit;
        EFTSetupIn.TestField("EFT Integration Type", IntegrationType());

        EFTSetup := EFTSetupIn;
        PaymentTypePOS.Get(EFTSetup."Payment Type POS");
        Register.Get(EFTSetup."POS Unit No.");

        MerchantID := GetMerchantID(EFTSetup);

        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');
    end;

    procedure PaymentStart(var EftTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin
        ClearLastError();
        InitializeGlobals(EftTransactionRequest."POS Payment Type Code", EftTransactionRequest."Register No.");

        EftTransactionRequest."Reference Number Input" := StrSubstNo('%1-%2-%3', EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.", EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify;

        if MerchantID = '' then
            Error(InvalidParameter, IntegrationType(), PaymentTypePOS.TableCaption, PaymentTypePOS."No.", 'Merchant ID');

        exit(true);
    end;

    procedure GetPaymentStatus(var EFTTransReq: Record "NPR EFT Transaction Request"; TransactionNo: Integer): Boolean
    var
        PaymentStatus: Integer;
        CustomerID: Text;
        MPOSNetsTransactions: Record "NPR MPOS Nets Transactions";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        PaymentTypePOS: Record "NPR Payment Type POS";
        SalePOS: Record "NPR Sale POS";
    begin
        if MPOSNetsTransactions.Get(TransactionNo) then begin
            if (MPOSNetsTransactions."Callback Result" <> EFTTransReq."Result Code") or ((MPOSNetsTransactions."Callback ResponseCode" <> '') and (MPOSNetsTransactions."Callback RejectionSource" = 0)) then begin
                //Baxi result code if succes(GODKENDT) is = 0
                if ((MPOSNetsTransactions."Callback ResponseCode" <> '') and (MPOSNetsTransactions."Callback RejectionSource" = 0)) then
                    EFTTransReq."Result Code" := 1
                else
                    EFTTransReq."Result Code" := MPOSNetsTransactions."Callback Result";
                if (StrLen(MPOSNetsTransactions."Callback StatusDescription") > MaxStrLen(EFTTransReq."Result Description")) then
                    EFTTransReq."Result Description" := 'NO ISMP CONNECTION'
                else
                    EFTTransReq."Result Description" := CopyStr(MPOSNetsTransactions."Callback StatusDescription", 1, MaxStrLen(EFTTransReq."Result Description"));
            end;

            //IF NOT (MPOSNetsTransactions."Callback CardIssuerName" IN ['', 'null']) THEN
            //  EFTTransReq."External Customer ID" := MPOSNetsTransactions."Callback CardIssuerName";

            //  IF MPOSNetsTransactions."Callback SessionNumber" <> '' THEN BEGIN
            //    EFTTransReq."External Transaction ID" := MPOSNetsTransactions."Callback SessionNumber";
            //    EFTTransReq."Reference Number Output" := MPOSNetsTransactions."Callback SessionNumber";
            //  END;

            if EFTTransReq."Result Code" = 1 then begin //Success
                EFTTransReq.Successful := true;
                EFTTransReq."Amount Output" := EFTTransReq."Amount Input";
                EFTTransReq."Result Amount" := EFTTransReq."Amount Input";
                EFTTransReq."Tip Amount" := MPOSNetsTransactions."Callback TipAmount";
                EFTTransReq."Card Issuer ID" := MPOSNetsTransactions."Callback CardIssuerName";

                if EFTTransReq."Card Number" <> MPOSNetsTransactions."Callback TruncatedPan" then begin
                    SalePOS.Get(EFTTransReq."Register No.", EFTTransReq."Sales Ticket No.");
                    if CreditCardHelper.FindPaymentType(MPOSNetsTransactions."Callback TruncatedPan", PaymentTypePOS, SalePOS."Location Code") then begin
                        EFTTransReq."POS Payment Type Code" := PaymentTypePOS."No.";
                        EFTTransReq."Card Name" := CopyStr(PaymentTypePOS.Description, 1, MaxStrLen(EFTTransReq."Card Name"));
                    end;
                    EFTTransReq."Card Number" := MPOSNetsTransactions."Callback TruncatedPan";
                end;
            end;

            MPOSNetsTransactions.CalcFields("Callback Receipt 1");
            if MPOSNetsTransactions."Callback Receipt 1".HasValue then begin
                EFTTransReq."Receipt 1" := MPOSNetsTransactions."Callback Receipt 1";
            end;
            MPOSNetsTransactions.CalcFields("Callback Receipt 2");
            if MPOSNetsTransactions."Callback Receipt 2".HasValue then begin
                EFTTransReq."Receipt 2" := MPOSNetsTransactions."Callback Receipt 2";
            end;

            EFTTransReq.Modify; //Persist changes across multiple status checks.

            exit(true);
        end;

        exit(false);
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure GetMerchantID(EFTSetupIn: Record "NPR EFT Setup"): Text
    var
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetTextParameterValue(IntegrationType(), EFTSetupIn."Payment Type POS", 'Merchant ID', '', true));
    end;

    local procedure GetEnvironment(EFTSetupIn: Record "NPR EFT Setup"): Integer
    var
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
    begin
        exit(EFTTypePaymentGenParam.GetOptionParameterValue(IntegrationType(), EFTSetupIn."Payment Type POS", 'Environment', 0, 'PROD,DEMO', true));
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
        AbortEFTTransactionRequest.Modify;
        Commit;
        EFTFrameworkMgt.SendRequest(AbortEFTTransactionRequest);
        AbortEFTTransactionRequest.Find;
        exit(AbortEFTTransactionRequest.Successful);
    end;
}

