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
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
            }
        }
    }

    actions
    {
    }
}

