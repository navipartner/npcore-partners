codeunit 6014636 "Payment Type POS Upg"
{
    // NPR5.51/TJ  /20190628 CASE 357069 New object

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [UpgradePerCompany]
    procedure UpdateOpenDrawer()
    var
        PaymentTypePOS: Record "Payment Type POS";
    begin
        PaymentTypePOS.SetFilter("Processing Type",'%1|%2',PaymentTypePOS."Processing Type"::Cash,PaymentTypePOS."Processing Type"::"Foreign Currency");
        PaymentTypePOS.ModifyAll("Open Drawer",true);
    end;
}

