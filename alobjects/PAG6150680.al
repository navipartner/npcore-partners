page 6150680 "NPRE W.Pad L. Print Categories"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'W. Pad Line Print Categories';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "NPRE W.Pad Line Print Category";

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
                field("Print Category Code";"Print Category Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

