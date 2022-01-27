page 6151601 "NPR NpDc Arch.Coupon Entries"
{
    Extensible = False;
    Caption = 'Archived Coupon Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    PopulateAllFields = true;
    SourceTable = "NPR NpDc Arch.Coupon Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {

                    ToolTip = 'Specifies the value of the Remaining Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount per Qty."; Rec."Amount per Qty.")
                {

                    ToolTip = 'Specifies the value of the Amount per Qty. field';
                    ApplicationArea = NPRRetail;
                }
                field(Open; Rec.Open)
                {

                    ToolTip = 'Specifies the value of the Open field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Type"; Rec."Document Type")
                {

                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the Register No. field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {

                    ToolTip = 'Specifies the value of the Closed by Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

