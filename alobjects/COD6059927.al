codeunit 6059927 "IDS Item Buffer 2 Item Wrksht"
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
    // 
    // IDS1.21/JDH/20160329 CASE 234022 Handling of same item numbers across companies
    // NPR5.23/BR/20160509 CASE  241030 Deactivated Stock synch
    // NPR5.23/JDH /20160516 CASE 240916 Deactivated Variant Lookup from Item Wizard - is discontinued
    // NPR5.25/BR/20130726 CASE  247522 Fix overflow error when text is too long
    // NPR5.51/MHA /20190820  CASE 365377 IDS is deprecated [VLOBJDEL] Object marked for deletion


    trigger OnRun()
    begin
    end;
}

