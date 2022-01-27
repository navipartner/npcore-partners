page 6150682 "NPR NPRE W.Pad Pr.Log Entries"
{
    Extensible = False;
    Caption = 'W. Pad Line Send Log Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE W.Pad Prnt LogEntry";
    UsageCategory = History;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Waiter Pad No."; Rec."Waiter Pad No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Waiter Pad No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Waiter Pad Line No."; Rec."Waiter Pad Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Waiter Pad Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Type"; Rec."Print Type")
                {

                    ToolTip = 'Specifies the value of the Request Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Flow Status Object"; Rec."Flow Status Object")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Flow Status Object field';
                    ApplicationArea = NPRRetail;
                }
                field("Flow Status Code"; Rec."Flow Status Code")
                {

                    ToolTip = 'Specifies the value of the Serving Step Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Category Code"; Rec."Print Category Code")
                {

                    ToolTip = 'Specifies the value of the Print Category Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Sent Date-Time"; Rec."Sent Date-Time")
                {

                    ToolTip = 'Specifies the value of the Sent Date-Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Sent Quanity (Base)"; Rec."Sent Quanity (Base)")
                {

                    ToolTip = 'Specifies the value of the Sent Quanity (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field("Output Type"; Rec."Output Type")
                {

                    ToolTip = 'Specifies the value of the Output Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
