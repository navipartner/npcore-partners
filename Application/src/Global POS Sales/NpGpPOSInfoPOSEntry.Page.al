page 6151173 "NPR NpGp POS Info POS Entry"
{
    Caption = 'Global POS Info Entries';
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR NpGp POS Info POS Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Sales Line No."; Rec."Sales Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line No. field';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }
}
