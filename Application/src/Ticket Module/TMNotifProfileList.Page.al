﻿page 6014564 "NPR TM Notif. Profile List"
{
    Extensible = False;
    PageType = List;
    ApplicationArea = NPRTicketAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR TM Notification Profile";
    Caption = 'Ticket Notification Profile List';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/how-to/create_ticket_notif/';
    CardPageId = "NPR TM Notif. Profile Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Profile Code"; Rec."Profile Code")
                {
                    ToolTip = 'Specifies the value of the Profile Code field';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRTicketAdvanced;
                }
            }
        }
    }
}
