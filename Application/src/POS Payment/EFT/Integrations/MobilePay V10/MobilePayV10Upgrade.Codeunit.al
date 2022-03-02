#if not CLOUD
codeunit 6014565 "NPR MobilePayV10 Upgrade"
{
    Access = Internal;
    // Subtype = Upgrade;

    // trigger OnUpgradePerCompany()
    // begin
    //     // TODO:
    //     // Find any EFTSetup records pointing to old mobilepay, and for each:
    //     // Create new mobilepay type instead and fill out values as below:
    //     // CompanyInformation."VAT Registration No." -> Merchant VAT No. !!! We have VAT Registration No. also on POS Store.
    //     // MerchantId + LocationId -> Try GET /v10/stores -> Store ID (https://mobilepaydev.github.io/MobilePay-PoS-v10/pos_management#existing-solution)
    //     // PosId -> Merchant PosId + Try GET /v10/pointofsale with filter -> MobilePay PosID
    //     // PosUnitId -> BeaconId        
    // end;

    trigger OnRun()
    begin
        StartMobilePayUpgradeProcedure();
        if not confirm('Commit?', false) then
            Error('Stop!');
    end;

    local procedure StartMobilePayUpgradeProcedure()
    begin
        if (not FindAndSetDefaultMobilePayV10IntegrationType()) then
            exit;

        TempOldEftSetupTemp.Reset();
        TempOldEftSetupTemp.DeleteAll(false);

        TempEftSetupToRegisterInMobilePay.Reset();
        TempEftSetupToRegisterInMobilePay.DeleteAll(false);

        TempOldEFTTypePOSUnitGenParam.Reset();
        TempOldEFTTypePOSUnitGenParam.DeleteAll(false);

        TempOldEFTTypePaymentGenParam.Reset();
        TempOldEFTTypePaymentGenParam.DeleteAll(false);

        TempOldEFTTypePOSUnitBLOBParam.Reset();
        TempOldEFTTypePOSUnitBLOBParam.DeleteAll(false);

        // Buffer old EFT setup data and delete the old records.
        ProcessAllOldMobilePayEftIntegrationTypes();

        // Flush buffer to real tables and do some additional post-processing.
        ProcessEftSetupBuffer();

        // Send POS units to MobilePay (includes Commits).
        ProcessPOSMobilePayBuffer();

        // Delete all old data.
        DeleteOldData();
    end;

    local procedure FindAndSetDefaultMobilePayV10IntegrationType(): Boolean
    var
        mobilePayV10Integration: Codeunit "NPR MobilePayV10 Integration";
    begin
        exit(mobilePayV10Integration.FindAndSetDefaultMobilePayV10IntegrationType(TempDefaultMobilePayEftIntType));
    end;

    local procedure ProcessAllOldMobilePayEftIntegrationTypes()
    var
        tempEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
        tempEFTIntegrationType2: Record "NPR EFT Integration Type" temporary;
    begin
        FindAndSetDefaultMobilePayV10IntegrationType();
        tempEFTIntegrationType.Copy(TempDefaultMobilePayEftIntType, true);
        tempEFTIntegrationType2.Copy(TempDefaultMobilePayEftIntType, true);

        tempEFTIntegrationType.Reset();
        tempEFTIntegrationType.SetRange("Codeunit ID", Codeunit::"NPR EFT MobilePay Integ.");
        IF tempEFTIntegrationType.FindSet() then begin
            repeat
                tempEFTIntegrationType2 := tempEFTIntegrationType;
                ProcessAllOldMobilePayEftSetupRecords(tempEFTIntegrationType2);

            // TODO: Do we want to delete the old MobilePay integration type or not?
            //EFTIntegrationType2.Delete(false);
            until tempEFTIntegrationType.Next() = 0;
        end;
    end;

    local procedure ProcessAllOldMobilePayEftSetupRecords(var EFTIntegrationType: Record "NPR EFT Integration Type")
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTSetup2: Record "NPR EFT Setup";
    begin
        EFTSetup.SetRange("EFT Integration Type", EFTIntegrationType.Code);
        if EFTSetup.FindSet() then begin
            repeat

                EFTSetup2 := EFTSetup;

                CreateOldEftSetupTempRecords(EFTSetup2);
                CreateOldEftTypePosUnitGenParamsTempRecords(EFTSetup2);
                CreateOldEftTypePaymentGenParamsTempRecords(EftSetup2);
                CreateOldEftTypePosUnitBlobParamsTempRecords(EFTSetup2);

            until EFTSetup.Next() = 0;
        end;
    end;

    local procedure CreateOldEftTypePosUnitGenParamsTempRecords(var OldEftSetup: Record "NPR EFT Setup")
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
    begin
        EFTTypePOSUnitGenParam.SetRange("Integration Type", OldEftSetup."EFT Integration Type");
        EFTTypePOSUnitGenParam.SetRange("POS Unit No.", OldEftSetup."POS Unit No.");
        if EFTTypePOSUnitGenParam.FindSet() then begin
            repeat
                TempOldEFTTypePOSUnitGenParam.Init();
                TempOldEFTTypePOSUnitGenParam.TransferFields(EFTTypePOSUnitGenParam, true);
                TempOldEFTTypePOSUnitGenParam.Insert(false);
            until EFTTypePOSUnitGenParam.next() = 0;
        end;
    end;

    local procedure CreateOldEftTypePaymentGenParamsTempRecords(var OldEftSetup: Record "NPR EFT Setup")
    var
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
    begin
        EFTTypePaymentGenParam.SetRange("Integration Type", OldEftSetup."EFT Integration Type");
        EFTTypePaymentGenParam.SetRange("Payment Type POS", OldEftSetup."Payment Type POS");
        if EFTTypePaymentGenParam.FindSet() then begin
            repeat
                TempOldEFTTypePaymentGenParam.Init();
                TempOldEFTTypePaymentGenParam.TransferFields(EFTTypePaymentGenParam, TRUE);
                if not TempOldEFTTypePaymentGenParam.Insert(FALSE) then;
            until EFTTypePaymentGenParam.Next() = 0;
        end;
    end;

    local procedure CreateOldEftTypePosUnitBlobParamsTempRecords(var OldEftSetup: Record "NPR EFT Setup")
    var
        EFTTypePOSUnitBLOBParam: Record "NPR EFTType POSUnit BLOBParam.";
    begin
        EFTTypePOSUnitBLOBParam.SetRange("Integration Type", OldEftSetup."EFT Integration Type");
        EFTTypePOSUnitBLOBParam.SetRange("POS Unit No.", OldEftSetup."POS Unit No.");
        if EFTTypePOSUnitBLOBParam.FindSet() then begin
            repeat
                TempOldEFTTypePOSUnitBLOBParam.Init();
                if TempOldEFTTypePOSUnitBLOBParam.Value.HasValue then
                    TempOldEFTTypePOSUnitBLOBParam.CalcFields(Value);
                TempOldEFTTypePOSUnitBLOBParam.TransferFields(EFTTypePOSUnitBLOBParam, true);
                TempOldEFTTypePOSUnitBLOBParam.Insert(false);
            until EFTTypePOSUnitBLOBParam.next() = 0;
        end;
    end;

    local procedure CreateOldEftSetupTempRecords(var OldEftSetup: Record "NPR EFT Setup")
    begin
        OldEftSetup.TestField("Payment Type POS");
        OldEftSetup.TestField("POS Unit No.");

        TempOldEftSetupTemp.init();
        TempOldEftSetupTemp.TransferFields(OldEftSetup, true);
        TempOldEftSetupTemp.Insert(false);
    end;

    local procedure ProcessEftSetupBuffer()
    var
        EftSetup: Record "NPR EFT Setup";
    begin
        TempOldEftSetupTemp.reset();
        if TempOldEftSetupTemp.FindSet() then begin

            // Let's create entry only when MobilePay is active (exist EFT Setup for old MobilePay).
            CreateJobQueueEntry();

            repeat
                EftSetup.Init();
                EftSetup."Payment Type POS" := TempOldEftSetupTemp."Payment Type POS";
                EftSetup."POS Unit No." := TempOldEftSetupTemp."POS Unit No.";
                EftSetup.Validate("EFT Integration Type", TempDefaultMobilePayEftIntType.Code);
                if not EftSetup.Insert() then
                    EftSetup.Modify();

                FillMobilePayV10PaymentSetup(EftSetup);
                Authenticate(EftSetup);
                FillMobilePayV10UnitSetup(EftSetup);

            until TempOldEftSetupTemp.Next() = 0;
        end;
    end;

    local procedure FillMobilePayV10PaymentSetup(var EftSetup: Record "NPR EFT Setup")
    var
        MobilePayPaymentSetup: Record "NPR MobilePayV10 Payment Setup";
        EftTypePayGenParam: Record "NPR EFT Type Pay. Gen. Param.";
        CompanyInfo: Record "Company Information";
        PosUnit: Record "NPR POS Unit";
        PosStore: Record "NPR POS Store";
    begin
        if (not MobilePayPaymentSetup.Get(EftSetup."Payment Type POS")) then begin
            MobilePayPaymentSetup.Init();
            MobilePayPaymentSetup."Payment Type POS" := EftSetup."Payment Type POS";
            MobilePayPaymentSetup.Insert();
        end;

        if (MobilePayPaymentSetup."Merchant VAT Number" = '') then begin

            // I would go to POS Store first to try to find VAT Reg. No. but the old MobilePay
            // was using another approach - reading from Company Info.
            CompanyInfo.Get();
            CompanyInfo.TestField("Country/Region Code");
            if (not (CompanyInfo."Country/Region Code" in ['DK', 'FI'])) then
                Error(UNSUPPORTED_COUNTRY_Err, CompanyInfo."Country/Region Code");

            MobilePayPaymentSetup."Merchant VAT Number" := CompanyInfo."VAT Registration No.";

            if (MobilePayPaymentSetup."Merchant VAT Number" = '') then begin
                PosUnit.GET(EftSetup."POS Unit No.");
                if (PosUnit."POS Store Code" <> '') then begin
                    PosStore.Get(PosUnit."POS Store Code");
                    MobilePayPaymentSetup."Merchant VAT Number" := PosStore."VAT Registration No.";
                end;
            end;

            if (MobilePayPaymentSetup."Merchant VAT Number" <> '') then begin
                if STRPOS(MobilePayPaymentSetup."Merchant VAT Number", CompanyInfo."Country/Region Code") = 0 then begin
                    MobilePayPaymentSetup."Merchant VAT Number" :=
                        StrSubstNo(MerchantVatNoEvalFormulaTok, CompanyInfo."Country/Region Code", MobilePayPaymentSetup."Merchant VAT Number");
                end;
            end;

            // Environment
            EftTypePayGenParam.GET(TempOldEftSetupTemp."EFT Integration Type", TempOldEftSetupTemp."Payment Type POS", 'Environment');
            // 0 = 'PROD', 1 = 'DEMO'
            case EftTypePayGenParam.Value of
                '0', 'PROD':
                    MobilePayPaymentSetup.Environment := MobilePayPaymentSetup.Environment::Production;
                '1', 'DEMO':
                    MobilePayPaymentSetup.Environment := MobilePayPaymentSetup.Environment::Sandbox;
                else
                    EftTypePayGenParam.FieldError(Value, USUPPORTED_PARAM_VALUE_Err);
            end;

            MobilePayPaymentSetup.Modify();

        end;
    end;

    local procedure FillMobilePayV10UnitSetup(var EftSetup: Record "NPR EFT Setup")
    var
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        tempMobilePayStores: Record "NPR MobilePayV10 Store" temporary;
        locationId: Text;
        merchantId: Text;
        posUnitId: Text;
    begin
        if (not mobilePayUnitSetup.Get(EftSetup."POS Unit No.")) then begin
            mobilePayUnitSetup."POS Unit No." := EftSetup."POS Unit No.";
            mobilePayUnitSetup.Insert();
        end else begin
            // Don't update an existing pos unit setup but check if it was created in the backend and if not, then try to register it.
            if mobilePayUnitSetup."MobilePay POS ID" = '' then begin
                RegisterPOSInMobilePayBuffer(EftSetup);
            end;

            exit;
        end;

        tempMobilePayStores.Reset();
        tempMobilePayStores.DeleteAll(FALSE);
        GetMobilePayStores(EftSetup, tempMobilePayStores);

        TempOldEftSetupTemp.Get(EftSetup."Payment Type POS", EftSetup."POS Unit No.");

        // Location ID
        if not TempOldEFTTypePOSUnitGenParam.Get(TempOldEftSetupTemp."EFT Integration Type", EftSetup."POS Unit No.", 'Location ID') then
            exit;
        locationId := TempOldEFTTypePOSUnitGenParam.Value;

        // PoS Unit ID
        if not TempOldEFTTypePOSUnitGenParam.Get(TempOldEftSetupTemp."EFT Integration Type", EftSetup."POS Unit No.", 'PoS Unit ID') then
            exit;
        posUnitId := TempOldEFTTypePOSUnitGenParam.Value;

        // Merchant ID
        if not TempOldEFTTypePaymentGenParam.Get(TempOldEftSetupTemp."EFT Integration Type", TempOldEftSetupTemp."Payment Type POS", 'Merchant ID') then
            exit;
        merchantId := TempOldEFTTypePaymentGenParam.Value;

        if (locationId = '') OR (merchantId = '') then begin
            // Not a complete MobilePay setup!!!
            exit;
        end;

        tempMobilePayStores.Reset();
        tempMobilePayStores.SetRange("Merchant Brand Id", merchantId);
        tempMobilePayStores.SetRange("Merchant Location Id", locationId);
        if not (tempMobilePayStores.FindFirst()) then
            exit;

        tempMobilePayStores.TestField("Store ID");

        mobilePayUnitSetup."Store ID" := tempMobilePayStores."Store ID";
        mobilePayUnitSetup."Merchant POS ID" := EftSetup."POS Unit No.";
        mobilePayUnitSetup."Beacon ID" := posUnitId;
        mobilePayUnitSetup."Only QR" := IsQROnlyPosUnit(posUnitId);
        if (mobilePayUnitSetup."Only QR") then begin
            Clear(mobilePayUnitSetup."Beacon ID");
        end else begin
            // TO-DO: How do we know what is the beacon id if there is a static one (white boxes)?
        end;
        mobilePayUnitSetup.Modify();

        // Call MobilePay backend to register POS. The following includes COMMIT!!!
        RegisterPOSInMobilePayBuffer(EftSetup);
    end;

    local procedure GetMobilePayStores(var EftSetup: Record "NPR EFT Setup"; var TempMobilePayStores: Record "NPR MobilePayV10 Store" temporary)
    var
        MobilePayV10Integration: Codeunit "NPR MobilePayV10 Integration";
    begin
        MobilePayV10Integration.GetMobilePayStores(EftSetup, TempMobilePayStores);
    end;

    local procedure IsQROnlyPosUnit(PosUnitId: Text): Boolean
    begin
        // TO-DO: How do we know what is the beacon id if there is a static one (white boxes)?
        Exit(PosUnitId = '');
    end;

    local procedure RegisterPOSInMobilePayBuffer(var EftSetup: Record "NPR EFT Setup")
    begin
        TempEftSetupToRegisterInMobilePay.Init();
        TempEftSetupToRegisterInMobilePay.TransferFields(EftSetup, true);
        if TempEftSetupToRegisterInMobilePay.Insert() then;
    end;

    local procedure ProcessPOSMobilePayBuffer()
    var
        eftSetup: Record "NPR EFT Setup";
        mobilePayIntegration: Codeunit "NPR MobilePayV10 Integration";
    begin
        TempEftSetupToRegisterInMobilePay.Reset();
        if not TempEftSetupToRegisterInMobilePay.FindSet() then begin
            exit;
        end;

        repeat
            eftSetup.Get(TempEftSetupToRegisterInMobilePay."Payment Type POS", TempEftSetupToRegisterInMobilePay."POS Unit No.");
            // Carefully, the following includes COMMITs:
            mobilePayIntegration.CreatePOS(eftSetup);
        until TempEftSetupToRegisterInMobilePay.Next() = 0;
    end;

    local procedure Authenticate(var EftSetup: Record "NPR EFT Setup"): Text
    var
        mobilePayToken: Codeunit "NPR MobilePayV10 Token";
        mobilePayAuthRequest: Codeunit "NPR MobilePayV10 Auth";
        TempEftTrxRequest: Record "NPR EFT Transaction Request" temporary;
        token: Text;
    begin
        if mobilePayToken.TryGetToken(token) then
            exit(token);

        TempEftTrxRequest.Init();
        TempEftTrxRequest."Original POS Payment Type Code" := EftSetup."Payment Type POS";
        TempEftTrxRequest.Insert();
        mobilePayAuthRequest.SetGlobalEFTSetup(EftSetup);
        mobilePayAuthRequest.Run(TempEftTrxRequest);

        IF mobilePayToken.TryGetToken(token) THEN
            EXIT(token);

        Error(CANT_AUTH_Err);
    end;

    local procedure CreateJobQueueEntry()
    var
        MobilePayV10Protocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        if (not MobilePayV10Protocol.ExistCancelDeadTransactionsTask()) then begin
            MobilePayV10Protocol.CreateCancelDeadTransactionsTask(false);
        end;
    end;

    local procedure DeleteOldData()
    var
        EFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param.";
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
        EFTTypePOSUnitBLOBParam: Record "NPR EFTType POSUnit BLOBParam.";
    begin
        TempOldEFTTypePOSUnitGenParam.Reset();
        if TempOldEFTTypePOSUnitGenParam.FindSet() then begin
            repeat
                EFTTypePOSUnitGenParam.Get(
                  TempOldEFTTypePOSUnitGenParam."Integration Type",
                  TempOldEFTTypePOSUnitGenParam."POS Unit No.",
                  TempOldEFTTypePOSUnitGenParam.Name);

                EFTTypePOSUnitGenParam.Delete();
            until TempOldEFTTypePOSUnitGenParam.Next() = 0;
        end;

        TempOldEFTTypePaymentGenParam.Reset();
        if TempOldEFTTypePaymentGenParam.FindSet() then begin
            repeat
                EFTTypePaymentGenParam.Get(
                  TempOldEFTTypePaymentGenParam."Integration Type",
                  TempOldEFTTypePaymentGenParam."Payment Type POS",
                  TempOldEFTTypePaymentGenParam.Name);

                EFTTypePaymentGenParam.Delete();
            until TempOldEFTTypePaymentGenParam.Next() = 0;
        end;

        TempOldEFTTypePOSUnitBLOBParam.Reset();
        if TempOldEFTTypePOSUnitBLOBParam.FindSet() then begin
            repeat
                EFTTypePOSUnitBLOBParam.Get(
                  TempOldEFTTypePOSUnitBLOBParam."Integration Type",
                  TempOldEFTTypePOSUnitBLOBParam."POS Unit No.",
                  TempOldEFTTypePOSUnitBLOBParam.Name);

                EFTTypePOSUnitBLOBParam.Delete();
            until TempOldEFTTypePOSUnitBLOBParam.Next() = 0;
        end;
    end;

    var
        TempDefaultMobilePayEftIntType: Record "NPR EFT Integration Type" temporary;
        TempOldEftSetupTemp: Record "NPR EFT Setup" temporary;
        TempEftSetupToRegisterInMobilePay: Record "NPR EFT Setup" temporary;
        TempOldEFTTypePOSUnitGenParam: Record "NPR EFTType POSUnit Gen.Param." temporary;
        TempOldEFTTypePOSUnitBLOBParam: Record "NPR EFTType POSUnit BLOBParam." temporary;
        USUPPORTED_PARAM_VALUE_Err: Label 'Unsupported value for the parameter.';
        UNSUPPORTED_COUNTRY_Err: Label 'MobilePay isn''t supported in %1 (country).';
        CANT_AUTH_Err: Label 'Can''t authenticate!';
        TempOldEFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param." temporary;
        MerchantVatNoEvalFormulaTok: Label '%1%2', Locked = true;
}
#endif