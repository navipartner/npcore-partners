page 6150670 "NPR POS Balancing Line"
{
    Caption = 'POS Balancing Line';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Balancing Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date"; "Entry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Date field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Time field';
                }
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("POS Period Register No."; "POS Period Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Period Register No. field';
                }
                field("POS Payment Bin Code"; "POS Payment Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Bin Code field';
                }
                field("POS Payment Method Code"; "POS Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                }
                field("Calculated Amount"; "Calculated Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculated Amount field';
                }
                field("Balanced Amount"; "Balanced Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balanced Amount field';
                }
                field("Balanced Diff. Amount"; "Balanced Diff. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balanced Diff. Amount field';
                }
                field("New Float Amount"; "New Float Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Amount field';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                }
                field("Calculated Quantity"; "Calculated Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Calculated Quantity field';
                }
                field("Balanced Quantity"; "Balanced Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balanced Quantity field';
                }
                field("Balanced Diff. Quantity"; "Balanced Diff. Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balanced Diff. Quantity field';
                }
                field("Deposited Quantity"; "Deposited Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deposited Quantity field';
                }
                field("Closing Quantity"; "Closing Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Quantity field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Deposit-To Bin Amount"; "Deposit-To Bin Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deposited Amount field';
                }
                field("Deposit-To Bin Code"; "Deposit-To Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deposit-To Bin Code field';
                }
                field("Deposit-To Reference"; "Deposit-To Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deposit-To Reference field';
                }
                field("Move-To Bin Amount"; "Move-To Bin Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Move-To Bin Amount field';
                }
                field("Move-To Bin Code"; "Move-To Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer-To POS Bin Code field';
                }
                field("Move-To Reference"; "Move-To Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Move-To Reference field';
                }
                field("Balancing Details"; "Balancing Details")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balancing Details field';
                }
                field("Orig. POS Sale ID"; "Orig. POS Sale ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. POS Sale ID field';
                }
                field("Orig. POS Line No."; "Orig. POS Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. POS Line No. field';
                }
                field("POS Bin Checkpoint Entry No."; "POS Bin Checkpoint Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Bin Checkpoint Entry No. field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Dimension Set ID"; "Dimension Set ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension Set ID field';
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("Line No."; "Line No.")
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

