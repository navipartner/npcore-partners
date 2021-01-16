page 6150682 "NPR NPRE W.Pad Pr.Log Entries"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'W. Pad Line Send Log Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE W.Pad Prnt LogEntry";
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Waiter Pad No."; "Waiter Pad No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Waiter Pad No. field';
                }
                field("Waiter Pad Line No."; "Waiter Pad Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Waiter Pad Line No. field';
                }
                field("Print Type"; "Print Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Type field';
                }
                field("Flow Status Object"; "Flow Status Object")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Flow Status Object field';
                }
                field("Flow Status Code"; "Flow Status Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Step Code field';
                }
                field("Print Category Code"; "Print Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Category Code field';
                }
                field("Sent Date-Time"; "Sent Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent Date-Time field';
                }
                field("Sent Quanity (Base)"; "Sent Quanity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent Quanity (Base) field';
                }
                field("Output Type"; "Output Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Type field';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }

    actions
    {
    }
}

