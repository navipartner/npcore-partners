page 6014464 "NPR Register Period List"
{
    Caption = 'Register Period List';
    CardPageID = "NPR Periods";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
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
                }
                field("Date Closed"; "Date Closed")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Balancing Time"; "Balancing Time")
                {
                    ApplicationArea = All;
                }
                field("Last Date Active"; "Last Date Active")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

