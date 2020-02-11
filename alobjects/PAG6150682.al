page 6150682 "NPRE W.Pad Line Pr.Log Entries"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'W. Pad Line Print Log Entries';
    PageType = List;
    SourceTable = "NPRE W.Pad Line Prnt Log Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Waiter Pad No.";"Waiter Pad No.")
                {
                    Visible = false;
                }
                field("Waiter Pad Line No.";"Waiter Pad Line No.")
                {
                    Visible = false;
                }
                field("Print Type";"Print Type")
                {
                }
                field("Flow Status Object";"Flow Status Object")
                {
                    Visible = false;
                }
                field("Flow Status Code";"Flow Status Code")
                {
                }
                field("Print Category Code";"Print Category Code")
                {
                }
                field("Sent Date-Time";"Sent Date-Time")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

