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
        Register: Record "NPR Register";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        RetailVoucherTypeCode: Code[20];
        RetailVoucherTypeDescLbl: Label 'Credit Voucher created with upgrade procedure';
        RetailVoucherDescLbl: Label 'Credit Voucher';
    begin
        CreditVoucher.SetFilter(Status, '<>%1', CreditVoucher.Status::Cancelled);
        if not CreditVoucher.FindSet() then
            exit;

        RetailVoucherTypeCode := 'CREDITVOUCHER_0000';
        repeat
            Register.reset();
            Register.setrange("Register No.", CreditVoucher."Register No.");
            if Register.FindSet() then
                repeat
                    RetailVoucherType.SetRange("Account No.", Register."Credit Voucher Account");
                    RetailVoucherType.SetRange("Payment Type", CreditVoucher."Payment Type No.");
                    if not RetailVoucherType.FindFirst() then begin
                        RetailVoucherType.Reset();
                        RetailVoucherTypeCode := IncStr(RetailVoucherTypeCode);
                        RetailVoucherType.Code := RetailVoucherTypeCode;
                        RetailVoucherType.Init();
                        RetailVoucherType."Account No." := Register."Credit Voucher Account";
                        RetailVoucherType."Payment Type" := CreditVoucher."Payment Type No.";
                        RetailVoucherType.Description := CopyStr(RetailVoucherTypeDescLbl, 1, MaxStrLen(RetailVoucherType.Description));
                        RetailVoucherType.Insert();
                    end;
                    RetailVoucher."No." := CreditVoucher."No.";
                    if not RetailVoucher.Find() then begin
                        RetailVoucher.Init();
                        RetailVoucher.validate("Voucher Type", RetailVoucherType.Code);
                        RetailVoucher.Description := CopyStr(RetailVoucherDescLbl, 1, MaxStrLen(RetailVoucher.Description));
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
                                end;
                        end;
                        RetailVoucher.Insert();
                    end;
                until Register.Next() = 0;
        until CreditVoucher.Next() = 0;
    end;
}