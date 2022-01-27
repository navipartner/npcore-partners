page 6014445 "NPR Payment Method Denom"
{
    Extensible = False;
    Caption = 'NPR Payment Method Denom';
    PageType = List;
    SourceTable = "NPR Payment Method Denom";
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

                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Denomination Type"; Rec."Denomination Type")
                {
                    ToolTip = 'Specifies the value of the Denomination Type field.';
                    ApplicationArea = NPRRetail;

                }
                field(Denomination; Rec.Denomination)
                {
                    ToolTip = 'Specifies the value of the Denomination field.';
                    ApplicationArea = NPRRetail;

                }
            }
        }
    }

}
