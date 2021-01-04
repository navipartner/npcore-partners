page 6151173 "NPR NpGp POS Info POS Entry"
{
    Caption = 'Global POS Info Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpGp POS Info POS Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Info Code"; "POS Info Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Info Code field';
                }
                field("POS Info"; "POS Info")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Info field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(Price; Price)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price field';
                }
                field("Net Amount"; "Net Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Net Amount field';
                }
                field("Gross Amount"; "Gross Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gross Amount field';
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Amount field';
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line No. field';
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }

    actions
    {
    }
}

