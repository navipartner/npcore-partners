codeunit 6014414 "NPR POS Tax Free Data Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR POS Tax Free Data Upgrade', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR POS Tax Free Data Upgrade")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        TaxFreePosUnitTableUpgrade();
        TaxFreeRequestUpgrade();
        TaxFreeVoucherUpgrade();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR POS Tax Free Data Upgrade"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure TaxFreePosUnitTableUpgrade()
    var
        NPRTaxFreePOSUnit: Record "NPR Tax Free POS Unit";
    begin
        if not NPRTaxFreePOSUnit.FindSet() then
            exit;

        repeat
            if NPRTaxFreePOSUnit."Handler ID" <> '' then
                case NPRTaxFreePOSUnit."Handler ID" of
                    'GLOBALBLUE_I2':
                        begin
                            NPRTaxFreePOSUnit."Handler ID Enum" := NPRTaxFreePOSUnit."Handler ID Enum"::GLOBALBLUE_I2;
                            NPRTaxFreePOSUnit.Modify();
                        end;
                    'PREMIER_PI':
                        begin
                            NPRTaxFreePOSUnit."Handler ID Enum" := NPRTaxFreePOSUnit."Handler ID Enum"::PREMIER_PI;
                            NPRTaxFreePOSUnit.Modify();
                        end;
                end;
        until NPRTaxFreePOSUnit.Next() = 0;
    end;

    local procedure TaxFreeRequestUpgrade()
    var
        NPRTaxFreeRequest: Record "NPR Tax Free Request";
    begin
        if not NPRTaxFreeRequest.FindSet() then
            exit;

        repeat
            if NPRTaxFreeRequest."Handler ID" <> '' then
                case NPRTaxFreeRequest."Handler ID" of
                    'GLOBALBLUE_I2':
                        begin
                            NPRTaxFreeRequest."Handler ID Enum" := NPRTaxFreeRequest."Handler ID Enum"::GLOBALBLUE_I2;
                            NPRTaxFreeRequest.Modify();
                        end;
                    'PREMIER_PI':
                        begin
                            NPRTaxFreeRequest."Handler ID Enum" := NPRTaxFreeRequest."Handler ID Enum"::PREMIER_PI;
                            NPRTaxFreeRequest.Modify();
                        end;
                end;
        until NPRTaxFreeRequest.Next() = 0;
    end;

    local procedure TaxFreeVoucherUpgrade()
    var
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
    begin
        if not TaxFreeVoucher.FindSet() then
            exit;

        repeat
            if TaxFreeVoucher."Handler ID" <> '' then
                case TaxFreeVoucher."Handler ID" of
                    'GLOBALBLUE_I2':
                        begin
                            TaxFreeVoucher."Handler ID Enum" := TaxFreeVoucher."Handler ID Enum"::GLOBALBLUE_I2;
                            TaxFreeVoucher.Modify();
                        end;
                    'PREMIER_PI':
                        begin
                            TaxFreeVoucher."Handler ID Enum" := TaxFreeVoucher."Handler ID Enum"::PREMIER_PI;
                            TaxFreeVoucher.Modify();
                        end;
                end;
        until TaxFreeVoucher.Next() = 0;
    end;
}
