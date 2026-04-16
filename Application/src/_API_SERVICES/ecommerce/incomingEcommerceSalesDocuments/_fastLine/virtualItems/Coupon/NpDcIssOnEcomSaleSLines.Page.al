#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150900 "NPR NpDc Iss.OnEcomSale SLines"
{
    Extensible = False;
    PageType = List;
    SourceTable = "NPR NpDc Iss.OnEcomSale S.Line";
    Caption = 'Ecom Sales Coupon Issue Setup Lines';
    DataCaptionExpression = PageCaptionText();
    AutoSplitKey = true;
    DelayedInsert = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Type; Rec."Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }
    local procedure PageCaptionText(): Text
    begin
        exit(Rec."Coupon Type");
    end;
}
#endif