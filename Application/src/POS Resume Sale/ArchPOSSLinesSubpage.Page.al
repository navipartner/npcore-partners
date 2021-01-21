page 6150745 "NPR Arch. POS S. Lines Subpage"
{
    Caption = 'Archive POS Sale Lines';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Archive Sale Line POS";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sale Type"; "Sale Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Type field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Document action';

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
