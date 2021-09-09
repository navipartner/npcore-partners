page 6014555 "NPR TM Notif. Profile Card"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR TM Notification Profile";
    Caption = 'Ticket Notification Profile Card';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Notification Profile';
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
            part(Lines; "NPR TM Notif. Profile Line")
            {
                Caption = 'Notification Lines';
                SubPageLink = "Profile Code" = FIELD("Profile Code");
                SubPageView = sorting("Profile Code", "Line No.");
                ApplicationArea = NPRTicketAdvanced;
            }
        }
    }
}