codeunit 6150977 "NPR UPG ItemRef. Disc Barcodes"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeDiscBarcodes();
    end;

    local procedure UpgradeDiscBarcodes()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG ItemRef. Disc Barcodes', 'OnUpgradePerCompany');
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG ItemRef. Disc Barcodes", 'UpgradeDiscBarcodes')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeDiscontiuedBarcodes();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG ItemRef. Disc Barcodes", 'UpgradeDiscBarcodes'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeDiscontiuedBarcodes()
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.SetRange("Discontinue Bar Code", true);
        if ItemReference.FindSet(true) then
            repeat
                ItemReference."NPR Discontinued Barcode" := true;
                ItemReference."NPR Discontinued Reason" := ItemReference."NPR Discontinued Reason"::Upgrade;
                ItemReference.Modify(true);
            until ItemReference.Next() = 0;
    end;
}