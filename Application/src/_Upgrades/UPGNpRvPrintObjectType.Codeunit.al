codeunit 6014689 "NPR UPG NpRv Print Object Type"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG NpRv Print Object Type', 'OnUpgradePerCompany');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitID())) then begin
            InitializePrintObjectTypeFields();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitID()));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR UPG NpRv Print Object Type");
    end;

    local procedure InitializePrintObjectTypeFields()
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        Voucher: Record "NPR NpRv Voucher";
        VourcherType: Record "NPR NpRv Voucher Type";
    begin
        if not ArchVoucher.IsEmpty() then
            ArchVoucher.ModifyAll("Print Object Type", ArchVoucher."Print Object Type"::Template);

        if not Voucher.IsEmpty() then
            Voucher.ModifyAll("Print Object Type", ArchVoucher."Print Object Type"::Template);

        if not VourcherType.IsEmpty() then
            VourcherType.ModifyAll("Print Object Type", ArchVoucher."Print Object Type"::Template);
    end;
}
