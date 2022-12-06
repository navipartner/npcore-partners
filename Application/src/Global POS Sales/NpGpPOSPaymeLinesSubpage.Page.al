page 6150755 "NPR NpGp POSPaymeLines Subpage"
{
    Extensible = False;
    Caption = 'Payment Lines';
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR NpGp POS Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Amount"; Rec."Payment Amount")
                {

                    ToolTip = 'Specifies the value of the Payment Amount field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

