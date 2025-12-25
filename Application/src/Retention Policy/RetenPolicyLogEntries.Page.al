#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
page 6248218 "NPR Reten. Policy Log Entries"
{
    ApplicationArea = NPRRetail;
    Caption = 'NPR Retention Policy Log Entries';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR Retention Policy Log Entry";
    SourceTableView = order(descending);
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the entry number assigned to the entry.';
                }
                field("Date/time"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time the entry was created.';
                }
                field("Message"; Rec.Message)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the content of the message in the log entry.';
                }
                field("Message Type"; Rec."Message Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the message is informational, a warning, or an error.';
                }
                field("User Id"; Rec."User Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the ID of the user who ran the process that created the log entry.';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(PromotedDisplayMessage; "Display Message")
            {
            }
            actionref(PromotedCallStack; "Call Stack")
            {
            }
        }
        area(Processing)
        {
            action("Display Message")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Message';
                Image = Text;
                ToolTip = 'Displays the full entry message.';

                trigger OnAction()
                begin
                    Message(Rec.Message);
                end;
            }
            action("Call Stack")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Call Stack';
                Image = DesignCodeBehind;
                Enabled = Rec."Message Type" = Rec."Message Type"::Error;
                ToolTip = 'Displays the Error Call Stack';

                trigger OnAction()
                begin
                    if Rec."Error Call Stack".HasValue() then
                        Message(Rec.GetErrorCallStack());
                end;
            }
        }
    }
}
#endif