codeunit 6060096 "NPR UPG BG Vision"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpdateBGVisionVatSubject();
    end;

    local procedure UpdateBGVisionVatSubject()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG BG Vision', 'UpdateBGVisionVatSubject');
        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateBGVisionVatSubject')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        UpdateBGVisionVatSubjectSales();
        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateBGVisionVatSubject'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateBGVisionVatSubjectSales()
    var
        VATEntry: Record "VAT Entry";
        BGVISIONLocalMgt: Codeunit "NPR BG VISION Local. Mgt.";
    begin
        VATEntry.Reset();
        VATEntry.SetRange("Posting Date", CalcDate('<-CM>', Today()), Today());
        BGVISIONLocalMgt.ModifyVATSubjectTVB(VATEntry);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG BG Vision");
    end;
}
