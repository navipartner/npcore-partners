page 6014488 "NPR POS Count. Denomin. List"
{
    UsageCategory = Lists;
    ApplicationArea = All;
    Caption = 'Credit Card Prefix';
    SourceTable = "NPR POS Counting Denomination";
    PageType = List;
    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Weight field';
                }
            }
        }
    }

}

