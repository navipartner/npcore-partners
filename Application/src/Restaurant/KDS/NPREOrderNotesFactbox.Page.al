page 6150993 "NPR NPRE Order Notes Factbox"
{
    Extensible = false;
    Caption = 'Order Notes';
    PageType = ListPart;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Notes)
            {
                field(Note; Rec.Value)
                {
                    Caption = 'Note';
                    ToolTip = 'Specifies an order note of the kitchen order of the selected request.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure SetOrderId(OrderId: BigInteger)
    var
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        OrderNotes: List of [Text];
        OrderNote: Text;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        OrderNotesMgt.GetOrderNotes(OrderId, OrderNotes);
        foreach OrderNote in OrderNotes do begin
            Rec.ID += 1;
            Rec.Value := CopyStr(OrderNote, 1, MaxStrLen(Rec.Value));
            Rec.Insert();
        end;
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;
}
