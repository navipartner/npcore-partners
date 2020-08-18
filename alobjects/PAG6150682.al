page 6150682 "NPRE W.Pad Line Pr.Log Entries"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'W. Pad Line Send Log Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NPRE W.Pad Line Prnt Log Entry";
    UsageCategory = History;

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
                field("Sent Quanity (Base)";"Sent Quanity (Base)")
                {
                }
                field("Output Type";"Output Type")
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

