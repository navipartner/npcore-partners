codeunit 6150923 "NPR UPG Gift Voucher"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Gift Voucher', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Gift Voucher")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Gift Voucher"));

        LogMessageStopwatch.LogFinish();
    end;

    procedure Upgrade()
    begin
        GiftVoucher2RetailVoucher();
    end;

    local procedure GiftVoucher2RetailVoucher()
    var
        GiftVoucher: Record "NPR Gift Voucher";
        RetailVoucher: Record "NPR NpRv Voucher";
        RetailVoucherType: Record "NPR NpRv Voucher Type";
        Register: Record "NPR Register";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        RetailVoucherTypeCode: Code[20];
        RetailVoucherTypeDescLbl: Label 'Gift Voucher created with upgrade procedure';
        RetailVoucherDescLbl: Label 'Gift Voucher';
    begin
        GiftVoucher.SetFilter(Status, '<>%1', GiftVoucher.Status::Cancelled);
        if not GiftVoucher.FindSet() then
            exit;

        RetailVoucherTypeCode := 'GIFTVOUCHER_0000';
        repeat
            Register.reset();
            Register.setrange("Register No.", GiftVoucher."Register No.");
            if Register.FindSet() then
                repeat
                    RetailVoucherType.SetRange("Account No.", Register."Gift Voucher Account");
                    RetailVoucherType.SetRange("Payment Type", GiftVoucher."Payment Type No.");
                    if not RetailVoucherType.FindFirst() then begin
                        RetailVoucherType.Reset();
                        RetailVoucherTypeCode := IncStr(RetailVoucherTypeCode);
                        RetailVoucherType.Code := RetailVoucherTypeCode;
                        RetailVoucherType.Init();
                        RetailVoucherType."Account No." := Register."Gift Voucher Account";
#pragma warning disable AA0139
                        RetailVoucherType."Payment Type" := GiftVoucher."Payment Type No.";
#pragma warning restore
                        RetailVoucherType.Description := CopyStr(RetailVoucherTypeDescLbl, 1, MaxStrLen(RetailVoucherType.Description));
                        RetailVoucherType.Insert();
                    end;
                    RetailVoucher."No." := GiftVoucher."No.";
                    if not RetailVoucher.Find() then begin
                        RetailVoucher.Init();
                        RetailVoucher.validate("Voucher Type", RetailVoucherType.Code);
                        RetailVoucher.Description := CopyStr(RetailVoucherDescLbl, 1, MaxStrLen(RetailVoucher.Description));
                        if GiftVoucher."Issue Date" <> 0D then
                            RetailVoucher."Starting Date" := CreateDateTime(GiftVoucher."Issue Date", Time());
                        if GiftVoucher."Expire Date" <> 0D then
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
                                end;
                        end;
                        RetailVoucher.Insert();
                    end;
                until Register.Next() = 0;
        until GiftVoucher.Next() = 0;
    end;
}
