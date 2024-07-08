page 6151246 "NPR POS Bin Entries"
{
    Caption = 'POS Bin Entries';
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR POS Bin Entry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Bin Checkpoint Entry No."; Rec."Bin Checkpoint Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bin Checkpoint Entry No. field.';
                }
                field(Type; Rec."Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("Payment Bin No."; Rec."Payment Bin No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Bin No. field.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Method Code field.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Entry No. field.';
                }
                field("POS Payment Line No."; Rec."POS Payment Line No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Payment Line No. field.';
                }
                field("Transaction Currency Code"; Rec."Transaction Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Currency Code field.';
                }
                field("Transaction Amount"; Rec."Transaction Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Amount field.';
                }
                field("Transaction Amount (LCY)"; Rec."Transaction Amount (LCY)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Amount (LCY) field.';
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Date field.';
                }
                field("Transaction Time"; Rec."Transaction Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Transaction Time field.';
                }
                field("Counted Amount"; Rec."Counted Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Counted Amount field.';
                }
                field("Counted Qty"; Rec."Counted Qty")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Counted Qty field.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Store Code field.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                }
                field("External Transaction No."; Rec."External Transaction No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External Transaction No. field.';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Created At field.';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Comment field.';
                }
                field("Accounting Period Code"; Rec."Accounting Period Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Accounting Period Code field.';
                }

            }
        }
        area(Factboxes)
        {

        }
    }

}