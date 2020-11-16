codeunit 6151406 "NPR Magento Category Mgt."
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.04/MH/20150217  CASE 199932 Deleted unused functions for Setup of Item Group Structure
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.26/MHA /20200601  CASE 404580 Magento "Item Group" renamed to "Category"


    trigger OnRun()
    begin
    end;

    procedure ItemCountDrillDown(MagentoCategory: Record "NPR Magento Category")
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        MagentoCategoryLink: Record "NPR Magento Category Link";
    begin
        //-MAG2.26 [404580]
        MagentoCategoryLink.SetRange("Category Id", MagentoCategory.Id);
        if MagentoCategoryLink.FindSet then
            repeat
                if Item.Get(MagentoCategoryLink."Item No.") then begin
                    TempItem.Init;
                    TempItem := Item;
                    TempItem.Insert;
                end;
            until MagentoCategoryLink.Next = 0;

        PAGE.Run(0, TempItem);
        //+MAG2.26 [404580]
    end;
}

