page 6185062 "NPR SG Scanner Categories"
{
    Extensible = false;
    Caption = 'SpeedGate Scanner Categories';
    SourceTable = "NPR SG Scanner Category";
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(CategoryRepeater)
            {
                field(CategoryCode; Rec.CategoryCode)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Category Code field.';
                }
                field(CategoryDescription; Rec.CategoryDescription)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Category Description field.';
                }
            }
        }
    }
}