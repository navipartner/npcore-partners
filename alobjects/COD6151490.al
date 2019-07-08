codeunit 6151490 UPG_CodeunitMAG
{
    // MAG2.21/BHR /20190509 CASE 338087 Update "Prices Includes VAT"

    Subtype = Upgrade;

    trigger OnRun()
    var
        UPGCustomOption: Integer;
    begin
    end;

    [UpgradePerCompany]
    procedure UPGCustomOption()
    var
        MagentoCustomOption: Record "Magento Custom Option";
        MagentoCustomOptionValue: Record "Magento Custom Option Value";
    begin
        if MagentoCustomOption.FindSet then
          MagentoCustomOption.ModifyAll("Price Includes VAT",true);

        if MagentoCustomOptionValue.FindSet then
          MagentoCustomOptionValue.ModifyAll("Price Includes VAT",true);
    end;
}

