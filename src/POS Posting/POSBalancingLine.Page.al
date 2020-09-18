page 6150670 "NPR POS Balancing Line"
{
    // NPR5.39/NPKNAV/20180223  CASE 302690-01 Transport NPR5.39 - 23 February 2018
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object
    // NPR5.53/SARA/20191024 CASE 373672 Addde Action button POS Entry Card

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
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                }
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("POS Period Register No."; "POS Period Register No.")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Bin Code"; "POS Payment Bin Code")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Method Code"; "POS Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Calculated Amount"; "Calculated Amount")
                {
                    ApplicationArea = All;
                }
                field("Balanced Amount"; "Balanced Amount")
                {
                    ApplicationArea = All;
                }
                field("Balanced Diff. Amount"; "Balanced Diff. Amount")
                {
                    ApplicationArea = All;
                }
                field("New Float Amount"; "New Float Amount")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Calculated Quantity"; "Calculated Quantity")
                {
                    ApplicationArea = All;
                }
                field("Balanced Quantity"; "Balanced Quantity")
                {
                    ApplicationArea = All;
                }
                field("Balanced Diff. Quantity"; "Balanced Diff. Quantity")
                {
                    ApplicationArea = All;
                }
                field("Deposited Quantity"; "Deposited Quantity")
                {
                    ApplicationArea = All;
                }
                field("Closing Quantity"; "Closing Quantity")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Deposit-To Bin Amount"; "Deposit-To Bin Amount")
                {
                    ApplicationArea = All;
                }
                field("Deposit-To Bin Code"; "Deposit-To Bin Code")
                {
                    ApplicationArea = All;
                }
                field("Deposit-To Reference"; "Deposit-To Reference")
                {
                    ApplicationArea = All;
                }
                field("Move-To Bin Amount"; "Move-To Bin Amount")
                {
                    ApplicationArea = All;
                }
                field("Move-To Bin Code"; "Move-To Bin Code")
                {
                    ApplicationArea = All;
                }
                field("Move-To Reference"; "Move-To Reference")
                {
                    ApplicationArea = All;
                }
                field("Balancing Details"; "Balancing Details")
                {
                    ApplicationArea = All;
                }
                field("Orig. POS Sale ID"; "Orig. POS Sale ID")
                {
                    ApplicationArea = All;
                }
                field("Orig. POS Line No."; "Orig. POS Line No.")
                {
                    ApplicationArea = All;
                }
                field("POS Bin Checkpoint Entry No."; "POS Bin Checkpoint Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Dimension Set ID"; "Dimension Set ID")
                {
                    ApplicationArea = All;
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
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
                }
            }
        }
    }
}

