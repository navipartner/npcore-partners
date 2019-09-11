codeunit 6059920 "IDS Item Buffer 2 Item Wizard"
{
    // Item Syncronization from Multiple databases NPIS1.0,NPK1.00
    //   Work started by Jerome Cader 07-03-2014.
    //   Contributions are most welcomed.
    //   This module supports any Variance type Navision to be synced from multiple databases-companies
    //         to a central database - company which is a Magento Webshop Navision.
    // 
    //  As always, maintain documentation when adding functionality or changing
    //  the behavior of the codeunit.
    // 
    //  Current functions and their purpose are listed below.
    // --------------------------------------------------------
    // "Export2ItemWizardJnl"
    // Export to Item Wizard Journal. This function is called from Form Item Wizard Functions->Import From Buffer
    // NPR5.23/JDH /20160513 CASE 240916 Removed old VariaX Solution
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion


    trigger OnRun()
    begin
    end;
}

