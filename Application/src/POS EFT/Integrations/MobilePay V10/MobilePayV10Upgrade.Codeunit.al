codeunit 6014565 "NPR MobilePayV10 Upgrade"
{
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

        OldEftSetupTempBuff.reset;
        OldEftSetupTempBuff.DeleteAll(false);

        OldEFTTypePOSUnitGenParamTempBuff.Reset();
        OldEFTTypePOSUnitGenParamTempBuff.DeleteAll(false);

        OldEFTTypePOSUnitBLOBParamTempBuff.Reset();
        OldEFTTypePOSUnitBLOBParamTempBuff.DeleteAll(false);

        // Buffer old EFT setup data and delete the old records.
        ProcessAllOldMobilePayEftIntegrationTypes();

        // Flush buffer to real tables and do some additional post-processing.
        ProcessEftSetupBuffer();
    end;

    local procedure FindAndSetDefaultMobilePayV10IntegrationType(): Boolean
    var
        mobilePayV10Integration: Codeunit "NPR MobilePayV10 Integration";
    begin
        exit(mobilePayV10Integration.FindAndSetDefaultMobilePayV10IntegrationType(DefaultMobilePayEftIntType));
    end;

    local procedure ProcessAllOldMobilePayEftIntegrationTypes()
    var
        EFTIntegrationTypeBuff: Record "NPR EFT Integration Type" temporary;
        EFTIntegrationTypeBuff2: Record "NPR EFT Integration Type" temporary;
    begin
        FindAndSetDefaultMobilePayV10IntegrationType();
        EFTIntegrationTypeBuff.Copy(DefaultMobilePayEftIntType, true);
        EFTIntegrationTypeBuff2.Copy(DefaultMobilePayEftIntType, true);

        EFTIntegrationTypeBuff.Reset();
        EFTIntegrationTypeBuff.SetRange("Codeunit ID", Codeunit::"NPR EFT MobilePay Integ.");
        IF EFTIntegrationTypeBuff.FindSet() then begin
            repeat
                EFTIntegrationTypeBuff2 := EFTIntegrationTypeBuff;
                ProcessAllOldMobilePayEftSetupRecords(EFTIntegrationTypeBuff2);

            // TODO: Do we want to delete the old MobilePay integration type or not?
            //EFTIntegrationType2.Delete(false);
            until EFTIntegrationTypeBuff.Next() = 0;
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
                CreateOldEftTypePosUnitBlobParamsTempRecords(EFTSetup2);

                EFTSetup2.Delete(true);

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
                OldEFTTypePOSUnitGenParamTempBuff.Init();
                OldEFTTypePOSUnitGenParamTempBuff.TransferFields(EFTTypePOSUnitGenParam, true);
                OldEFTTypePOSUnitGenParamTempBuff.Insert(false);
            until EFTTypePOSUnitGenParam.next() = 0;
        end;

        EFTTypePOSUnitGenParam.DeleteAll;
    end;

    local procedure CreateOldEftTypePosUnitBlobParamsTempRecords(var OldEftSetup: Record "NPR EFT Setup")
    var
        EFTTypePOSUnitBLOBParam: Record "NPR EFTType POSUnit BLOBParam.";
    begin
        EFTTypePOSUnitBLOBParam.SetRange("Integration Type", OldEftSetup."EFT Integration Type");
        EFTTypePOSUnitBLOBParam.SetRange("POS Unit No.", OldEftSetup."POS Unit No.");
        if EFTTypePOSUnitBLOBParam.FindSet() then begin
            repeat
                OldEFTTypePOSUnitBLOBParamTempBuff.Init();
                OldEFTTypePOSUnitBLOBParamTempBuff.TransferFields(EFTTypePOSUnitBLOBParam, true);
                OldEFTTypePOSUnitBLOBParamTempBuff.Insert(false);
            until EFTTypePOSUnitBLOBParam.next() = 0;
        end;

        EFTTypePOSUnitBLOBParam.DeleteAll(false);
    end;

    local procedure CreateOldEftSetupTempRecords(var OldEftSetup: Record "NPR EFT Setup")
    var
        NewEftSetup: Record "NPR EFT Setup";
    begin
        OldEftSetup.TestField("Payment Type POS");
        OldEftSetup.TestField("POS Unit No.");

        OldEftSetupTempBuff.init();
        OldEftSetupTempBuff.TransferFields(OldEftSetup, true);
        OldEftSetupTempBuff.Insert(false);
    end;

    local procedure ProcessEftSetupBuffer()
    var
        EftSetup: Record "NPR EFT Setup";
    begin
        OldEftSetupTempBuff.reset();
        if OldEftSetupTempBuff.FindSet() then begin
            repeat
                EftSetup.Init();
                EftSetup."Payment Type POS" := OldEftSetupTempBuff."Payment Type POS";
                EftSetup."POS Unit No." := OldEftSetupTempBuff."POS Unit No.";
                EftSetup.Insert();
                EftSetup.Validate("EFT Integration Type", DefaultMobilePayEftIntType.Code);
                EftSetup.Modify();

                FillMobilePayV10PaymentSetup(EftSetup);

            until OldEftSetupTempBuff.Next() = 0;
        end;
    end;

    local procedure FillMobilePayV10PaymentSetup(var EftSetup: Record "NPR EFT Setup")
    var
        MobilePayPaymentSetup: Record "NPR MobilePayV10 Payment Setup";
        EftTypePayGenParam: Record "NPR EFT Type Pay. Gen. Param.";
        CompanyInfo: Record "Company Information";
    begin
        if (not MobilePayPaymentSetup.Get(EftSetup."Payment Type POS")) then begin
            MobilePayPaymentSetup.Init();
            MobilePayPaymentSetup."Payment Type POS" := EftSetup."Payment Type POS";
            MobilePayPaymentSetup.Insert();
        end;

        if (MobilePayPaymentSetup."Merchant VAT Number" = '') then begin
            CompanyInfo.Get();
            CompanyInfo.TestField("VAT Registration No.");

            MobilePayPaymentSetup."Merchant VAT Number" := CompanyInfo."VAT Registration No.";

            // Environment
            EftTypePayGenParam.GET(OldEftSetupTempBuff."EFT Integration Type", OldEftSetupTempBuff."Payment Type POS", 'Environment');
            // 0 = 'PROD', 1 = 'DEMO'
            case EftTypePayGenParam.Value of
                '0', 'PROD':
                    MobilePayPaymentSetup.Environment := MobilePayPaymentSetup.Environment::Production;
                '1', 'DEMO':
                    MobilePayPaymentSetup.Environment := MobilePayPaymentSetup.Environment::Sandbox;
                else
                    EftTypePayGenParam.FieldError(Value, USUPPORTED_PARAM_VALUE);
            end;

            MobilePayPaymentSetup.Modify();

        end;
    end;

    var
        DefaultMobilePayEftIntType: Record "NPR EFT Integration Type" temporary;
        OldEftSetupTempBuff: Record "NPR EFT Setup" temporary;
        OldEFTTypePOSUnitGenParamTempBuff: Record "NPR EFTType POSUnit Gen.Param." temporary;
        OldEFTTypePOSUnitBLOBParamTempBuff: Record "NPR EFTType POSUnit BLOBParam." temporary;
        USUPPORTED_PARAM_VALUE: Label 'Unsupported value for the parameter.';
}