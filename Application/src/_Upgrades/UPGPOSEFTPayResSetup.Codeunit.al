codeunit 6185018 "NPR UPG POS EFT Pay Res. Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpdatePOSEFTPayResSetup();
    end;

    local procedure UpdatePOSEFTPayResSetup()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS EFT Pay Res. Setup', 'UpdatePOSEFTPayResSetup');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdatePOSEFTPayResSetup')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        TransferPOSEFTPayResSetup();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdatePOSEFTPayResSetup'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure TransferPOSEFTPayResSetup()
    var
        POSEFTPayReservSetup: Record "NPR POS EFT Pay Reserv Setup";
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        if not POSEFTPayReservSetup.Get() then
            exit;
        if AdyenSetup.Get() then begin
            PopulateAdyenSetup(AdyenSetup, POSEFTPayReservSetup);
            AdyenSetup.Modify();
        end else begin
            AdyenSetup.Init();
            PopulateAdyenSetup(AdyenSetup, POSEFTPayReservSetup);
            AdyenSetup.Insert();
        end;
    end;

    local procedure PopulateAdyenSetup(var AdyenSetup: Record "NPR Adyen Setup"; POSEFTPayReservSetup: Record "NPR POS EFT Pay Reserv Setup")
    begin
        AdyenSetup."EFT Res. Payment Gateway Code" := POSEFTPayReservSetup."Payment Gateway Code";
        AdyenSetup."EFT Res. Account No." := POSEFTPayReservSetup."Account No.";
        AdyenSetup."EFT Res. Account Type" := POSEFTPayReservSetup."Account Type";
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS EFT Pay Res. Setup");
    end;
}
