page 6151389 "NPR CS Refill Data"
{
    // NPR5.50/JAKUBV/20190603  CASE 332844 Transport NPR5.50 - 3 June 2019

    Caption = 'Approve Counting';
    Editable = false;
    PageType = List;
    SourceTable = "NPR CS Refill Data";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item Group Code"; "Item Group Code")
                {
                    ApplicationArea = All;
                }
                field("Item Group Description"; "Item Group Description")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Variant Description"; "Variant Description")
                {
                    ApplicationArea = All;
                }
                field("Qty. in Stock"; "Qty. in Stock")
                {
                    ApplicationArea = All;
                }
                field("Qty. in Store"; "Qty. in Store")
                {
                    ApplicationArea = All;
                }
                field(Refilled; Refilled)
                {
                    ApplicationArea = All;
                }
                field("Refilled By"; "Refilled By")
                {
                    ApplicationArea = All;
                }
                field("Refilled Date"; "Refilled Date")
                {
                    ApplicationArea = All;
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
                    CSStockTakes: Record "NPR CS Stock-Takes";
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

