page 6184603 NPRPowerBIDimension
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Dimension;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code for the dimension.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the dimension code you enter in the Code field.';
                    ApplicationArea = All;
                }

            }
        }

    }
}