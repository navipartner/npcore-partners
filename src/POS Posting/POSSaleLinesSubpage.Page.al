page 6150748 "NPR POS Sale Lines Subpage"
{
    Caption = 'POS Sale Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NPR Sale Line POS";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sale Type"; "Sale Type")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
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
            action(ShowDocument)
            {
                Caption = 'Show Document';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    SalePOS: Record "NPR Sale POS";
                begin
                    SalePOS.Get("Register No.", "Sales Ticket No.");
                    PAGE.Run(PAGE::"NPR Unfinished POS Sale Trx", SalePOS);
                end;
            }
        }
    }
}