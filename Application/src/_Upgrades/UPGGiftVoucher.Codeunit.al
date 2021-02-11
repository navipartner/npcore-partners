codeunit 6150923 "NPR UPG Gift Voucher"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgTagDef: Codeunit "NPR UPG Gift Voucher Tag Def";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag()) then
            exit;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag());
    end;

    local procedure Upgrade()
    begin
        GiftVoucher2RetailVoucher();
    end;

    local procedure GiftVoucher2RetailVoucher()
    var
        GiftVoucher: Record "NPR Gift Voucher";
        RetailVoucher: Record "NPR NpRv Voucher";
        RetailVoucherType: Record "NPR NpRv Voucher Type";
        RetailVoucherTypeUpg: Record "NPR NpRv Voucher Type";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        GiftVoucher.SetFilter(Status, '<>%1', GiftVoucher.Status::Cancelled);
        if not GiftVoucher.FindSet() then
            exit;
        RetailVoucherType.Code := 'GIFTVOUCHER';
        if RetailVoucherType.Find() then begin
            RetailVoucherTypeUpg.TransferFields(RetailVoucherType);
            RetailVoucherTypeUpg.Code := 'GIFTVOUCHER_UPG';
            RetailVoucherTypeUpg.Insert(true);
        end;

        repeat
            RetailVoucher."No." := GiftVoucher."No.";
            if not RetailVoucher.Find() then begin
                RetailVoucher.Init();
                RetailVoucher.validate("Voucher Type", RetailVoucherTypeUpg.Code);
                RetailVoucher."Starting Date" := CreateDateTime(GiftVoucher."Issue Date", Time());
                RetailVoucher."Ending Date" := CreateDateTime(GiftVoucher."Expire Date", Time());
                RetailVoucher."Reference No." := GiftVoucher."No.";
                RetailVoucher."Customer No." := GiftVoucher."Customer No.";
                RetailVoucher.Address := CopyStr(GiftVoucher.Address, 1, MaxStrLen(RetailVoucher.Address));
                RetailVoucher.Name := CopyStr(GiftVoucher.Name, 1, MaxStrLen(RetailVoucher.Name));
                RetailVoucher."Post Code" := GiftVoucher."ZIP Code";
                RetailVoucher.City := CopyStr(GiftVoucher.City, 1, MaxStrLen(RetailVoucher.City));
                case GiftVoucher.Status of
                    GiftVoucher.Status::Cashed:
                        begin
                            VoucherMgt.ArchiveRetailVoucher(RetailVoucher, GiftVoucher.Amount);
                        end;
                    GiftVoucher.Status::Open:
                        begin
                            VoucherMgt.OpenRetailVoucher(RetailVoucher, GiftVoucher.Amount);
                            RetailVoucher.Insert(true);
                        end;
                end;
            end;
        until GiftVoucher.Next() = 0;
    end;
}