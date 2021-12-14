codeunit 6014500 "NPR Upgrade Magento Passwords"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade Magento Passwords', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Magento Passwords")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePasswordsInventoryCompanies();
        UpgradePasswordsPaymentGateway();
        UpgradePasswordsMagentoSetup();
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Magento Passwords"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePasswordsInventoryCompanies()
    var
        InventoryCompanies: Record "NPR Magento Inv. Company";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if not InventoryCompanies.FindSet() then
            exit;

        repeat
            if InventoryCompanies."Api Password" <> '' then begin
                WebServiceAuthHelper.SetApiPassword(InventoryCompanies."Api Password", InventoryCompanies."Api Password Key");
                InventoryCompanies."Api Password" := '';
                InventoryCompanies.Modify();
            end;
        until InventoryCompanies.Next() = 0;
    end;

    local procedure UpgradePasswordsPaymentGateway()
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if not PaymentGateway.FindSet() then
            exit;

        repeat
            if PaymentGateway."Api Password" <> '' then begin
                PaymentGateway.SetApiPassword(PaymentGateway."Api Password");
                PaymentGateway."Api Password" := '';
                PaymentGateway.Modify();
            end;
        until PaymentGateway.Next() = 0;
    end;

    local procedure UpgradePasswordsMagentoSetup()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not MagentoSetup.Get() then
            exit;

        if MagentoSetup."Api Password" <> '' then begin
            MagentoSetup.SetApiPassword(MagentoSetup."Api Password");
            MagentoSetup."Api Password" := '';
            MagentoSetup.Modify();
        end;
    end;
}