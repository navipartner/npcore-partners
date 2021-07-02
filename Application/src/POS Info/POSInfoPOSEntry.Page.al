page 6150647 "NPR POS Info POS Entry"
{
    Caption = 'POS Info POS Entry';
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Info POS Entry";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Date field';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Sales Line No."; Rec."Sales Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line No. field';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Receipt Type"; Rec."Receipt Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Type field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("POS Info Code"; Rec."POS Info Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Info Code field';
                }
                field("POS Info"; Rec."POS Info")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Info field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price field';
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Amount field';
                }
                field("Gross Amount"; Rec."Gross Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gross Amount field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Amount field';
                }
            }
        }
    }
}
