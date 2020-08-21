page 6150647 "POS Info POS Entry"
{
    // NPR5.41/THRO/20180424 CASE 312185 Page created
    // NPR5.53/ALPO/20200204 CASE 387750 Added fields: "Document No.", "Entry Date", "POS Unit No.", "Salesperson Code"

    Caption = 'POS Info POS Entry';
    Editable = false;
    PageType = List;
    SourceTable = "POS Info POS Entry";
    UsageCategory = Lists;

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
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Receipt Type"; "Receipt Type")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
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
            }
        }
    }

    actions
    {
    }
}

