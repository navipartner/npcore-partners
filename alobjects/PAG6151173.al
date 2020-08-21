page 6151173 "NpGp POS Info POS Entry"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Global POS Info Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NpGp POS Info POS Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Info Code"; "POS Info Code")
                {
                    ApplicationArea = All;
                }
                field("POS Info"; "POS Info")
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field(Price; Price)
                {
                    ApplicationArea = All;
                }
                field("Net Amount"; "Net Amount")
                {
                    ApplicationArea = All;
                }
                field("Gross Amount"; "Gross Amount")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

