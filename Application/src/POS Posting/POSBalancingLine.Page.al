page 6150670 "NPR POS Balancing Line"
{
    Caption = 'POS Balancing Line';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Balancing Line";

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
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Time field';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("POS Period Register No."; Rec."POS Period Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Period Register No. field';
                }
                field("POS Payment Bin Code"; Rec."POS Payment Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Bin Code field';
                }
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                }
                field("Calculated Amount"; Rec."Calculated Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculated Amount field';
                }
                field("Balanced Amount"; Rec."Balanced Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balanced Amount field';
                }
                field("Balanced Diff. Amount"; Rec."Balanced Diff. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balanced Diff. Amount field';
                }
                field("New Float Amount"; Rec."New Float Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Amount field';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                }
                field("Calculated Quantity"; Rec."Calculated Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculated Quantity field';
                }
                field("Balanced Quantity"; Rec."Balanced Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balanced Quantity field';
                }
                field("Balanced Diff. Quantity"; Rec."Balanced Diff. Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balanced Diff. Quantity field';
                }
                field("Deposited Quantity"; Rec."Deposited Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deposited Quantity field';
                }
                field("Closing Quantity"; Rec."Closing Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Quantity field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Deposit-To Bin Amount"; Rec."Deposit-To Bin Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deposited Amount field';
                }
                field("Deposit-To Bin Code"; Rec."Deposit-To Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deposit-To Bin Code field';
                }
                field("Deposit-To Reference"; Rec."Deposit-To Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deposit-To Reference field';
                }
                field("Move-To Bin Amount"; Rec."Move-To Bin Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Move-To Bin Amount field';
                }
                field("Move-To Bin Code"; Rec."Move-To Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer-To POS Bin Code field';
                }
                field("Move-To Reference"; Rec."Move-To Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Move-To Reference field';
                }
                field("Balancing Details"; Rec."Balancing Details")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balancing Details field';
                }
                field("Orig. POS Sale ID"; Rec."Orig. POS Sale ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. POS Sale ID field';
                }
                field("Orig. POS Line No."; Rec."Orig. POS Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. POS Line No. field';
                }
                field("POS Bin Checkpoint Entry No."; Rec."POS Bin Checkpoint Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Bin Checkpoint Entry No. field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Set ID field';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Entry Card action';
                }
            }
        }
    }
}

