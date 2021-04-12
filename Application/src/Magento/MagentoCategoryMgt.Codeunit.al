codeunit 6151406 "NPR Magento Category Mgt."
{
    procedure ItemCountDrillDown(MagentoCategory: Record "NPR Magento Category")
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        MagentoCategoryLink: Record "NPR Magento Category Link";
    begin
        MagentoCategoryLink.SetRange("Category Id", MagentoCategory.Id);
        if MagentoCategoryLink.FindSet() then
            repeat
                if Item.Get(MagentoCategoryLink."Item No.") then begin
                    TempItem.Init();
                    TempItem := Item;
                    TempItem.Insert();
                end;
            until MagentoCategoryLink.Next() = 0;

        PAGE.Run(0, TempItem);
    end;
}