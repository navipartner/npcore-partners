codeunit 6151406 "Magento Item Group Mgt."
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.04/MH/20150217  CASE 199932 Deleted unused functions for Setup of Item Group Structure
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration


    trigger OnRun()
    begin
    end;

    procedure ItemCountDrillDown(ItemGroupNo: Code[20])
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        WebLinkToItemGroup: Record "Magento Item Group Link";
    begin
        TempItem.DeleteAll;
        WebLinkToItemGroup.Reset;
        WebLinkToItemGroup.SetRange("Item Group",ItemGroupNo);
        if WebLinkToItemGroup.FindSet then repeat
          if Item.Get(WebLinkToItemGroup."Item No.") then begin
            TempItem.Init;
            TempItem := Item;
            TempItem.Insert;
          end;
        until WebLinkToItemGroup.Next = 0;

        PAGE.RunModal(PAGE::"Item List",TempItem);
    end;
}

