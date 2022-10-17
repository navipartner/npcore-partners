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
                    ToolTip = 'Specifies the payment method denominations are defined for.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Denomination Type"; Rec."Denomination Type")
                {
                    ToolTip = 'Specifies the type of currency unit (whether it is a coin, or a banknote).';
                    ApplicationArea = NPRRetail;
                }
                field("Denomination Variant ID"; Rec."Denomination Variant ID")
                {
                    ToolTip = 'Specifies the variant of denomination set. May be used if there are multiple denomination sets circulating at the same time after, for example, a money reform.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(Denomination; Rec.Denomination)
                {
                    ToolTip = 'Specifies the denomination of a currency unit of this type.';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies if the specific denomination is blocked. If it is blocked, it won''t be suggested, while ';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
