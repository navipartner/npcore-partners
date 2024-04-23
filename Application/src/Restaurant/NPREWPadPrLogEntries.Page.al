page 6150682 "NPR NPRE W.Pad Pr.Log Entries"
{
    Extensible = False;
    Caption = 'W. Pad Line Send Log Entries';
    ContextSensitiveHelpPage = 'docs/restaurant/intro/';
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
                    ToolTip = 'Specifies the waiter pad number the reqiest was created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Waiter Pad Line No."; Rec."Waiter Pad Line No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the waiter pad line number the reqiest was created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Print Type"; Rec."Print Type")
                {
                    ToolTip = 'Specifies the request type this log entry was created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Flow Status Object"; Rec."Flow Status Object")
                {
                    Visible = false;
                    ToolTip = 'Specifies the status object the reqiest was created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Flow Status Code"; Rec."Flow Status Code")
                {
                    ToolTip = 'Specifies the serving step the reqiest was created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Print Category Code"; Rec."Print Category Code")
                {
                    ToolTip = 'Specifies the item print/production category the reqiest was created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Sent Date-Time"; Rec."Sent Date-Time")
                {
                    ToolTip = 'Specifies the date-time the reqiest was created at.';
                    ApplicationArea = NPRRetail;
                }
                field("Sent Quanity (Base)"; Rec."Sent Quanity (Base)")
                {
                    ToolTip = 'Specifies quanity (base) included in the request.';
                    ApplicationArea = NPRRetail;
                }
                field("Output Type"; Rec."Output Type")
                {
                    ToolTip = 'Specifies if the request output type is KDS or printer.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the unique number of the log entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
