codeunit 6059924 "IDS Item Replication"
{
    // IDS1.20/JDH/20160224 CASE 234022 checking that all setup requirement is present, to avoid an unhandeled get
    // NPR5.29/TJ/20161223 CASE 249720 Replaced calling of standard codeunit 7000 Sales Price Calc. Mgt. with our own codeunit 6014453 POS Sales Price Calc. Mgt.
    // NPR5.45/MHA /20180803 CASE 323705 Changed FindPriceStdItem() and FindPriceVarietyItem() to use Retail Price function
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion


    trigger OnRun()
    begin
    end;
}

