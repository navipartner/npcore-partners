page 6150644 "NPR POS Info Audit Roll"
{
    Extensible = False;
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Audit Roll';
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Info Audit Roll";
    UsageCategory = History;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Line No."; Rec."Sales Line No.")
                {

                    ToolTip = 'Specifies the value of the Sales Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Date"; Rec."Sale Date")
                {

                    ToolTip = 'Specifies the value of the Sale Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Type"; Rec."Receipt Type")
                {

                    ToolTip = 'Specifies the value of the Receipt Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Info Code"; Rec."POS Info Code")
                {

                    ToolTip = 'Specifies the value of the POS Info Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Info"; Rec."POS Info")
                {

                    ToolTip = 'Specifies the value of the POS Info field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field(Price; Rec.Price)
                {

                    ToolTip = 'Specifies the value of the Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Net Amount"; Rec."Net Amount")
                {

                    ToolTip = 'Specifies the value of the Net Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Gross Amount"; Rec."Gross Amount")
                {

                    ToolTip = 'Specifies the value of the Gross Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the value of the Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

