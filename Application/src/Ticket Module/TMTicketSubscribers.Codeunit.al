codeunit 6248504 "NPR TMTicketSubscribers"
{
    access = Internal;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteRelatedData', '', false, false)]
    local procedure OnAfterDeleteItemRelatedData(Item: Record Item)
    var
        DynamicPriceItemList: Record "NPR TM DynamicPriceItemList";
    begin
        if (Item.IsTemporary()) then
            exit;

        // Delete all dynamic price item list entries related to the deleted item
        DynamicPriceItemList.Reset();
        DynamicPriceItemList.SetFilter(ItemNo, '=%1', Item."No.");
        DynamicPriceItemList.DeleteAll();
    end;

}