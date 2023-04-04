codeunit 6150943 "NPR POS Action: Item Card-B"
{
    Access = Internal;

    procedure OpenItemPage(POSSession: Codeunit "NPR POS Session"; PageEditable: Boolean; RefreshLine: Boolean)
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        CurrentView: Codeunit "NPR POS View";
        RetailItemCard: Page "Item Card";
    begin
        POSSession.GetCurrentView(CurrentView);
        if (CurrentView.GetType() = CurrentView.GetType() ::Sale) then begin
            POSSession.GetSale(POSSale);  //Ensure the sale still exists (haven't been seized and finished/cancelled by another session)
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(LinePOS);
            if LinePOS."Line Type" = LinePOS."Line Type"::Item then begin
                if Item.Get(LinePOS."No.") then begin
                    Item.SetRecFilter();
                    RetailItemCard.Editable(PageEditable);
                    RetailItemCard.SetRecord(Item);
                    RetailItemCard.RunModal();
                    if RefreshLine then begin
                        LinePOS.Validate("No.");
                        LinePOS.Modify(true);
                    end;
                end;
            end;
        end;
    end;
}
