codeunit 6151399 "Upg. Magento Customer Mapping"
{
    // MAG2.21/MHA /20190522  CASE 355271 Upgrade codeunit for rework of MagentoSetup."Customer Mapping" [VLOBJUPG] Object may be deleted after upgrade

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [UpgradePerCompany]
    procedure UpdateCustomerMapping()
    var
        MagentoSetup: Record "Magento Setup";
    begin
        if not MagentoSetup.Get then
          exit;

        if MagentoSetup."Customer Mapping" = MagentoSetup."Customer Mapping"::"E-mail" then
          exit;

        MagentoSetup."Customer Mapping" := MagentoSetup."Customer Mapping"::"E-mail";
        MagentoSetup.Modify;
    end;
}

