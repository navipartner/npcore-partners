page 6014437 "NPR Sale POS: Saved Sale Line"
{
    Caption = 'Saved Sales Lines';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Sale Line POS";

    layout
    {
        area(content)
        {
            repeater("Saved Sales Lines")
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
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

