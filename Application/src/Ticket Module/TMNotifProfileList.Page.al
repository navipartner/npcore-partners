page 6014564 "NPR TM Notif. Profile List"
{
    PageType = List;
    ApplicationArea = NRTTicketAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR TM Notification Profile";
    Caption = 'Ticket Notification Profile List';
    CardPageId = "NPR TM Notif. Profile Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Profile Code"; Rec."Profile Code")
                {
                    ToolTip = 'Specifies the value of the Profile Code field';
                    ApplicationArea = NRTTicketAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NRTTicketAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NRTTicketAdvanced;
                }
            }
        }
    }
}