page 6184890 "NPR Server Overview"
{
    Caption = 'Server Overview';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = File;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Path; Path)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Path field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Size; Size)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Size field';
                }
                field("Date"; Date)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Time"; Time)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time field';
                }
            }
        }
    }

    actions
    {
    }
}

