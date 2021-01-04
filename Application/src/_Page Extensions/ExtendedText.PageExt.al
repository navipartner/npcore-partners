pageextension 6014435 "NPR Extended Text" extends "Extended Text"
{
    // NPR5.49/TJ  /20190218 CASE 345047 New group Jobs and field Event
    layout
    {
        addafter(Service)
        {
            group("NPR Jobs")
            {
                Caption = 'Jobs';
                field("NPR Event"; "NPR Event")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Event field';
                }
            }
        }
    }
}

