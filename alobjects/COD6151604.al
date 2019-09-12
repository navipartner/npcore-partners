codeunit 6151604 "NpDc Coupon Entry upg."
{
    // NPR5.51/MHA /20190724  CASE 343352 Upgrade codeunit for "Document Type" on Coupon Entries [VLOBJUPG] Object may be deleted after upgrade

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [UpgradePerCompany]
    procedure UpgCouponEntryDocType()
    var
        NpDcCouponEntry: Record "NpDc Coupon Entry";
        NpDcArchCouponEntry: Record "NpDc Arch. Coupon Entry";
    begin
        NpDcCouponEntry.SetFilter("Document No.",'<>%1','');
        if NpDcCouponEntry.FindFirst then
          NpDcCouponEntry.ModifyAll("Document Type",NpDcCouponEntry."Document Type"::"POS Entry");

        NpDcArchCouponEntry.SetFilter("Document No.",'<>%1','');
        if NpDcArchCouponEntry.FindFirst then
          NpDcArchCouponEntry.ModifyAll("Document Type",NpDcArchCouponEntry."Document Type"::"POS Entry");
    end;
}

