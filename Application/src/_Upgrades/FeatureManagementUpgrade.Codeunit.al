codeunit 6151470 "NPR Feature Management Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        FeatureManagementInstall: Codeunit "NPR Feature Management Install";
        NewVoucherReservation: Codeunit "NPR New Voucher Reservation";
    begin
        FeatureManagementInstall.AddFeatures();
        NewVoucherReservation.HandleOnUpgrade();
    end;
}
