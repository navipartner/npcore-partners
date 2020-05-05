page 6150745 "Archive POS Sale Lines Subpage"
{
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale

    Caption = 'Archive POS Sale Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Archive Sale Line POS";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sale Type";"Sale Type")
                {
                }
                field("Line No.";"Line No.")
                {
                }
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field(Amount;Amount)
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowDocument)
            {
                Caption = 'Show Document';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SalePOS: Record "Sale POS";
                begin
                    SalePOS.Get("Register No.","Sales Ticket No.");
                    PAGE.Run(PAGE::"Unfinished POS Sale Transact.",SalePOS);
                end;
            }
        }
    }
}

