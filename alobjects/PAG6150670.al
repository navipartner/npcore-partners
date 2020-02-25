page 6150670 "POS Balancing Line"
{
    // NPR5.39/NPKNAV/20180223  CASE 302690-01 Transport NPR5.39 - 23 February 2018
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object
    // NPR5.53/SARA/20191024 CASE 373672 Addde Action button POS Entry Card

    Caption = 'POS Balancing Line';
    Editable = false;
    PageType = List;
    SourceTable = "POS Balancing Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date";"Entry Date")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Ending Time";"Ending Time")
                {
                }
                field("POS Store Code";"POS Store Code")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("POS Period Register No.";"POS Period Register No.")
                {
                }
                field("POS Payment Bin Code";"POS Payment Bin Code")
                {
                }
                field("POS Payment Method Code";"POS Payment Method Code")
                {
                }
                field("Calculated Amount";"Calculated Amount")
                {
                }
                field("Balanced Amount";"Balanced Amount")
                {
                }
                field("Balanced Diff. Amount";"Balanced Diff. Amount")
                {
                }
                field("New Float Amount";"New Float Amount")
                {
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                }
                field("Calculated Quantity";"Calculated Quantity")
                {
                }
                field("Balanced Quantity";"Balanced Quantity")
                {
                }
                field("Balanced Diff. Quantity";"Balanced Diff. Quantity")
                {
                }
                field("Deposited Quantity";"Deposited Quantity")
                {
                }
                field("Closing Quantity";"Closing Quantity")
                {
                }
                field(Description;Description)
                {
                }
                field("Deposit-To Bin Amount";"Deposit-To Bin Amount")
                {
                }
                field("Deposit-To Bin Code";"Deposit-To Bin Code")
                {
                }
                field("Deposit-To Reference";"Deposit-To Reference")
                {
                }
                field("Move-To Bin Amount";"Move-To Bin Amount")
                {
                }
                field("Move-To Bin Code";"Move-To Bin Code")
                {
                }
                field("Move-To Reference";"Move-To Reference")
                {
                }
                field("Balancing Details";"Balancing Details")
                {
                }
                field("Orig. POS Sale ID";"Orig. POS Sale ID")
                {
                }
                field("Orig. POS Line No.";"Orig. POS Line No.")
                {
                }
                field("POS Bin Checkpoint Entry No.";"POS Bin Checkpoint Entry No.")
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Dimension Set ID";"Dimension Set ID")
                {
                }
                field("POS Entry No.";"POS Entry No.")
                {
                }
                field("Line No.";"Line No.")
                {
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
                    RunObject = Page "POS Entry Card";
                    RunPageLink = "Entry No."=FIELD("POS Entry No.");
                    RunPageView = SORTING("Entry No.");
                }
            }
        }
    }
}

