page 6150682 "NPR NPRE W.Pad Pr.Log Entries"
{
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
                field("Waiter Pad No."; Rec."Waiter Pad No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Waiter Pad No. field';
                }
                field("Waiter Pad Line No."; Rec."Waiter Pad Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Waiter Pad Line No. field';
                }
                field("Print Type"; Rec."Print Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Type field';
                }
                field("Flow Status Object"; Rec."Flow Status Object")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Flow Status Object field';
                }
                field("Flow Status Code"; Rec."Flow Status Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Step Code field';
                }
                field("Print Category Code"; Rec."Print Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Category Code field';
                }
                field("Sent Date-Time"; Rec."Sent Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent Date-Time field';
                }
                field("Sent Quanity (Base)"; Rec."Sent Quanity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent Quanity (Base) field';
                }
                field("Output Type"; Rec."Output Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Output Type field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }
}