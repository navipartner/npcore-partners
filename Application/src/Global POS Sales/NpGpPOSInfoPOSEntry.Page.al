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
                field("Sales Line No."; Rec."Sales Line No.")
                {

                    ToolTip = 'Specifies the value of the Sales Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {

                    ToolTip = 'Specifies the value of the POS Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
