page 6151218 "NPR NpCs Open. Hour Calendar"
{
    Caption = 'Collect Store Opening Hour Calendar';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpCs Open. Hour Cal. Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Calendar Date"; Rec."Calendar Date")
                {

                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Time"; Rec."Start Time")
                {

                    ToolTip = 'Specifies the value of the Start Time field';
                    ApplicationArea = NPRRetail;
                }
                field("End Time"; Rec."End Time")
                {

                    ToolTip = 'Specifies the value of the End Time field';
                    ApplicationArea = NPRRetail;
                }
                field(Weekday; Rec.Weekday)
                {

                    ToolTip = 'Specifies the value of the Weekday field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

