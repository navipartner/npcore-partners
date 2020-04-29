page 6014464 "Register Period List"
{
    Caption = 'Register Period List';
    CardPageID = Periods;
    Editable = false;
    PageType = List;
    SourceTable = Period;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description;Description)
                {
                }
                field("Date Closed";"Date Closed")
                {
                }
                field(Status;Status)
                {
                }
                field("Balancing Time";"Balancing Time")
                {
                }
                field("Last Date Active";"Last Date Active")
                {
                }
            }
        }
    }

    actions
    {
    }
}

