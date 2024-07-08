codeunit 6150952 "NPR POS Action: RunPageItem-B"
{
    Access = Internal;

    procedure RunPageItem(POSSession: Codeunit "NPR POS Session"; PageId: Integer)
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.TestField("Line Type", SaleLinePOS."Line Type"::Item);
        Item.Get(SaleLinePOS."No.");
        Item.SetFilter("Variant Filter", Item."Variant Filter");

        RunPage(Item, PageId);
    end;

    local procedure RunPage(var Item: Record Item; PageId: Integer)
    begin
        if PageId = 0 then
            exit;

        PAGE.RunModal(PageId, Item);
    end;
}
