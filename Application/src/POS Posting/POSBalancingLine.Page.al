page 6150670 "NPR POS Balancing Line"
{
    Extensible = False;
    Caption = 'POS Balancing Line';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Balancing Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date"; Rec."Entry Date")
                {

                    ToolTip = 'Specifies the value of the Entry Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."Ending Time")
                {

                    ToolTip = 'Specifies the value of the Ending Time field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Period Register No."; Rec."POS Period Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Period Register No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin Code"; Rec."POS Payment Bin Code")
                {

                    ToolTip = 'Specifies the value of the POS Payment Bin Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Calculated Amount"; Rec."Calculated Amount")
                {

                    ToolTip = 'Specifies the value of the Calculated Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Balanced Amount"; Rec."Balanced Amount")
                {

                    ToolTip = 'Specifies the value of the Balanced Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Balanced Diff. Amount"; Rec."Balanced Diff. Amount")
                {

                    ToolTip = 'Specifies the value of the Balanced Diff. Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("New Float Amount"; Rec."New Float Amount")
                {

                    ToolTip = 'Specifies the value of the Closing Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Calculated Quantity"; Rec."Calculated Quantity")
                {

                    ToolTip = 'Specifies the value of the Calculated Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Balanced Quantity"; Rec."Balanced Quantity")
                {

                    ToolTip = 'Specifies the value of the Balanced Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Balanced Diff. Quantity"; Rec."Balanced Diff. Quantity")
                {

                    ToolTip = 'Specifies the value of the Balanced Diff. Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Deposited Quantity"; Rec."Deposited Quantity")
                {

                    ToolTip = 'Specifies the value of the Deposited Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Closing Quantity"; Rec."Closing Quantity")
                {

                    ToolTip = 'Specifies the value of the Closing Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Deposit-To Bin Amount"; Rec."Deposit-To Bin Amount")
                {

                    ToolTip = 'Specifies the value of the Deposited Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Deposit-To Bin Code"; Rec."Deposit-To Bin Code")
                {

                    ToolTip = 'Specifies the value of the Deposit-To Bin Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Deposit-To Reference"; Rec."Deposit-To Reference")
                {

                    ToolTip = 'Specifies the value of the Deposit-To Reference field';
                    ApplicationArea = NPRRetail;
                }
                field("Move-To Bin Amount"; Rec."Move-To Bin Amount")
                {

                    ToolTip = 'Specifies the value of the Move-To Bin Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Move-To Bin Code"; Rec."Move-To Bin Code")
                {

                    ToolTip = 'Specifies the value of the Transfer-To POS Bin Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Move-To Reference"; Rec."Move-To Reference")
                {

                    ToolTip = 'Specifies the value of the Move-To Reference field';
                    ApplicationArea = NPRRetail;
                }
                field("Balancing Details"; Rec."Balancing Details")
                {

                    ToolTip = 'Specifies the value of the Balancing Details field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Bin Checkpoint Entry No."; Rec."POS Bin Checkpoint Entry No.")
                {

                    ToolTip = 'Specifies the value of the POS Bin Checkpoint Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {

                    ToolTip = 'Specifies the value of the Dimension Set ID field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {

                    ToolTip = 'Specifies the value of the POS Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("POS Entry")
            {
                Caption = 'POS Entry';
                action("POS Entry Card")
                {
                    Caption = 'POS Entry Card';
                    Image = List;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "NPR POS Entry Card";
                    RunPageLink = "Entry No." = FIELD("POS Entry No.");
                    RunPageView = SORTING("Entry No.");

                    ToolTip = 'Executes the POS Entry Card action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

