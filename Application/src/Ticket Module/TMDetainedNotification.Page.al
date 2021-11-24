page 6059841 "NPR TM Detained Notification"
{
    PageType = List;
    ApplicationArea = NPRTicketAdvanced;
    UsageCategory = Lists;
    SourceTable = "NPR TM Detained Notification";
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Notification Address"; Rec."Notification Address")
                {
                    ToolTip = 'Specifies the value of the Notification Address field.';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Detain Until"; Rec."Detain Until")
                {
                    ToolTip = 'Specifies the value of the Detain Until field.';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Notification Profile Code"; Rec."Notification Profile Code")
                {
                    ToolTip = 'Specifies the value of the Notification Profile Code field.';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Notification Trigger Type"; Rec."Notification Trigger Type")
                {
                    ToolTip = 'Specifies the value of the Ticket Trigger Type field.';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                    ApplicationArea = NPRTicketAdvanced;
                }

            }
        }

    }
}