page 6014464 "NPR Register Period List"
{
    Caption = 'Register Period List';
    CardPageID = "NPR Periods";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Period";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Date Closed"; "Date Closed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Closed field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Balancing Time"; "Balancing Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balancing Time field';
                }
                field("Last Date Active"; "Last Date Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Date Active field';
                }
            }
        }
    }

    actions
    {
    }
}

