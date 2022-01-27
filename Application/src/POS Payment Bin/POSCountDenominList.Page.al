page 6014488 "NPR POS Count. Denomin. List"
{
    Extensible = False;
    UsageCategory = Lists;

    Caption = 'Credit Card Prefix';
    SourceTable = "NPR POS Counting Denomination";
    PageType = List;
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Weight; Rec.Weight)
                {

                    ToolTip = 'Specifies the value of the Weight field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

