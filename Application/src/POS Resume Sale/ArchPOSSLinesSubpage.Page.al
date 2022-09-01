﻿page 6150745 "NPR Arch. POS S. Lines Subpage"
{
    Extensible = False;
    Caption = 'Archive POS Sale Lines';
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Archive Sale Line POS";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sale Type"; Rec."Sale Type")
                {

                    ToolTip = 'Specifies the value of the Sale Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;
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
                ToolTip = 'Executes the Show Document action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    SalePOS: Record "NPR POS Sale";
                begin
                    SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.");
                    PAGE.Run(PAGE::"NPR Unfinished POS Sale Trx", SalePOS);
                end;
            }
        }
    }
}
