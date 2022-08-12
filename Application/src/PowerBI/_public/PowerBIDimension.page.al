page 6184603 NPRPowerBIDimension
{
    PageType = List;
    Caption = 'PowerBI Dimensions';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Dimension;
    Editable = false;
    ObsoleteState = pending;
    ObsoleteReason = 'Page type changed to API';

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