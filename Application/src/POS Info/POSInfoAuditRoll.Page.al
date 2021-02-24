page 6150644 "NPR POS Info Audit Roll"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Audit Roll';
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Info Audit Roll";
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line No. field';
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Date field';
                }
                field("Receipt Type"; "Receipt Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Type field';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
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
            }
        }
    }

    actions
    {
    }
}

