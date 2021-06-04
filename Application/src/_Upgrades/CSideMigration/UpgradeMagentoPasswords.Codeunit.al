codeunit 6014500 "NPR Upgrade Magento Passwords"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade Magento Passwords', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(GetMagentoPassUpgradeTag()) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePasswordsInventoryCompanies();
        UpgradePasswordsPaymentGateway();
        UpgradePasswordsMagentoSetup();
        UpgradeTagMgt.SetUpgradeTag(GetMagentoPassUpgradeTag());

        LogMessageStopwatch.LogFinish();
    end;

    local procedure GetMagentoPassUpgradeTag(): Text
    begin
        exit('Magento_Password_IsolatedStorage_20210129');
    end;

    local procedure UpgradePasswordsInventoryCompanies()
    var
        InventoryCompanies: Record "NPR Magento Inv. Company";
    begin
        if not InventoryCompanies.FindSet() then
            exit;

        repeat
            if InventoryCompanies."Api Password" <> '' then begin
                InventoryCompanies.SetApiPassword(InventoryCompanies."Api Password");
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

        if MagentoSetup."Managed Nav Api Password" <> '' then begin
            MagentoSetup.SetNavApiPassword(MagentoSetup."Managed Nav Api Password");
            MagentoSetup."Managed Nav Api Password" := '';
            MagentoSetup.Modify();
        end;
    end;
}