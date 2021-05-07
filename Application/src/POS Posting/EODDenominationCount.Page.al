page 6014443 "NPR EOD Denomination Count"
{

    Caption = 'NPR EOD Denomination Count';
    PageType = Worksheet;
    SourceTable = "NPR EOD Denomination";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ToolTip = 'Specifies the value of the POS Payment Method Code field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Denomination Type"; Rec."Denomination Type")
                {
                    ToolTip = 'Specifies the value of the Denomination Type field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Denomination; Rec.Denomination)
                {
                    ToolTip = 'Specifies the value of the Denomination field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
