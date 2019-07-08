page 6151389 "CS Refill Data"
{
    // NPR5.50/JAKUBV/20190603  CASE 332844 Transport NPR5.50 - 3 June 2019

    Caption = 'Approve Counting';
    Editable = false;
    PageType = List;
    SourceTable = "CS Refill Data";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Group Code";"Item Group Code")
                {
                }
                field("Item Group Description";"Item Group Description")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Item Description";"Item Description")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Variant Description";"Variant Description")
                {
                }
                field("Qty. in Stock";"Qty. in Stock")
                {
                }
                field("Qty. in Store";"Qty. in Store")
                {
                }
                field(Refilled;Refilled)
                {
                }
                field("Refilled By";"Refilled By")
                {
                }
                field("Refilled Date";"Refilled Date")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Approve Counting")
            {
                Caption = 'Approve Counting';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    CSStockTakes: Record "CS Stock-Takes";
                begin
                    CSStockTakes.Get("Stock-Take Id");
                    CSStockTakes.ApproveCounting();
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        QtySum := 'Stock ' + Format("Qty. in Stock") + ' : Store ' + Format("Qty. in Store");
    end;

    var
        QtySum: Text;
}

