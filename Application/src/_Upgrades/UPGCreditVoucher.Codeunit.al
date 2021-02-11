codeunit 6150921 "NPR UPG Credit Voucher"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgTagDef: Codeunit "NPR UPG Credit Voucher Tag Def";
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
        CreditVoucher2RetailVoucher();
    end;

    local procedure CreditVoucher2RetailVoucher()
    var
        CreditVoucher: Record "NPR Credit Voucher";
        RetailVoucher: Record "NPR NpRv Voucher";
        RetailVoucherType: Record "NPR NpRv Voucher Type";
        RetailVoucherTypeUpg: Record "NPR NpRv Voucher Type";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        CreditVoucher.SetFilter(Status, '<>%1', CreditVoucher.Status::Cancelled);
        if not CreditVoucher.FindSet() then
            exit;
        RetailVoucherType.Code := 'CREDITVOUCHER';
        if RetailVoucherType.Find() then begin
            RetailVoucherTypeUpg.TransferFields(RetailVoucherType);
            RetailVoucherTypeUpg.Code := 'CREDITVOUCHER_UPG';
            RetailVoucherTypeUpg.Insert(true);
        end;

        repeat
            RetailVoucher."No." := CreditVoucher."No.";
            if not RetailVoucher.Find() then begin
                RetailVoucher.Init();
                RetailVoucher.validate("Voucher Type", RetailVoucherTypeUpg.Code);
                RetailVoucher."Starting Date" := CreateDateTime(CreditVoucher."Issue Date", Time());
                RetailVoucher."Ending Date" := CreateDateTime(CreditVoucher."Expire Date", Time());
                RetailVoucher."Reference No." := CreditVoucher."No.";
                RetailVoucher."Customer No." := CreditVoucher."Customer No";
                RetailVoucher.Address := CopyStr(CreditVoucher.Address, 1, MaxStrLen(RetailVoucher.Address));
                RetailVoucher.Name := CopyStr(CreditVoucher.Name, 1, MaxStrLen(RetailVoucher.Name));
                RetailVoucher."Post Code" := CreditVoucher."Post Code";
                RetailVoucher.City := CopyStr(CreditVoucher.City, 1, MaxStrLen(RetailVoucher.City));
                case CreditVoucher.Status of
                    CreditVoucher.Status::Cashed:
                        begin
                            VoucherMgt.ArchiveRetailVoucher(RetailVoucher, CreditVoucher.Amount);
                        end;
                    CreditVoucher.Status::Open:
                        begin
                            VoucherMgt.OpenRetailVoucher(RetailVoucher, CreditVoucher.Amount);
                            RetailVoucher.Insert(true);
                        end;
                end;
            end;
        until CreditVoucher.Next() = 0;
    end;
}