codeunit 6014535 "NPR Salesperson Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        Upgrade();
    end;

    local procedure Upgrade()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagLbl: Label 'NPRSalespersonUpgrade-20210414-01', Locked = true;
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Salesperson Upgrade', 'Upgrade');

        if UpgradeTag.HasUpgradeTag(UpgradeTagLbl) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeSalesperson();

        UpgradeTag.SetUpgradeTag(UpgradeTagLbl);

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeSalesperson()
    var
        Salesperson: Record "Salesperson/Purchaser";
        InS: InStream;
        SalespersonImageTok: Label 'Salesperson image', Locked = true;
    begin
        Salesperson.Reset();
        if Salesperson.FindSet(true) then
            repeat
                if not Salesperson.Image.HasValue() then begin
                    Salesperson.CalcFields("NPR Picture");
                    if Salesperson."NPR Picture".HasValue() then begin
                        Salesperson."NPR Picture".CreateInStream(InS);
                        Salesperson.Image.ImportStream(InS, SalespersonImageTok);
                        Salesperson.Modify();
                    end;
                end;
            until Salesperson.Next() = 0;
    end;
}