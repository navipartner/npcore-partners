codeunit 6014685 "NPR UPG Sales Pr. Maint. Setup"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Sales Pr. Maint. Setup', 'OnUpgradePerCompany');
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Sales Pr. Maint. Setup")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdatePriceListCodes();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Sales Pr. Maint. Setup"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdatePriceListCodes()
    var
        PriceListHeader: Record "Price List Header";
        PriceListHeader2: Record "Price List Header";
        SalesPriceMaintSetup: Record "NPR Sales Price Maint. Setup";
    begin
        if SalesPriceMaintSetup.FindSet(true) then
            repeat
                if SalesPriceMaintSetup."Price List Code" = '' then
                    if PriceListHeader.Get(SalesPriceMaintSetup."Sales Code") then begin
                        if PriceListHeader."Code" = '' then begin
                            if SalesPriceMaintSetup.Id <= 0 then
                                PriceListHeader2."Code" := '001'
                            else
                                PriceListHeader2."Code" := CopyStr(Format(SalesPriceMaintSetup.Id), 1, MaxStrLen(PriceListHeader2."Code"));
                            while PriceListHeader2.Find() do begin
                                if StrLen(IncStr(PriceListHeader2."Code")) > MaxStrLen(PriceListHeader2."Code") then begin
                                    PriceListHeader2."Code" := PriceListHeader."Code";
                                    break;
                                end;
                                PriceListHeader2."Code" := IncStr(PriceListHeader2."Code");
                            end;
                            if PriceListHeader."Code" <> PriceListHeader2."Code" then
                                PriceListHeader.Rename(PriceListHeader2."Code");
                        end;
                        SalesPriceMaintSetup."Price List Code" := PriceListHeader."Code";
                        SalesPriceMaintSetup.Modify();
                    end;
            until SalesPriceMaintSetup.Next() = 0;
    end;
}