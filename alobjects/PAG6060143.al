page 6060143 "MM Membership Notification"
{
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.26/NPKNAV/20180222  CASE 300681 Transport MM1.26 - 22 February 2018
    // MM1.29/TSA /20180506 CASE 314131 Added field for wallet services

    Caption = 'Membership Notification';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "MM Membership Notification";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
                field("Membership Entry No.";"Membership Entry No.")
                {
                    Visible = false;
                }
                field("External Membership No.";"External Membership No.")
                {
                }
                field("Notification Code";"Notification Code")
                {
                }
                field("Date To Notify";"Date To Notify")
                {
                }
                field("Notification Status";"Notification Status")
                {
                }
                field("Notification Processed At";"Notification Processed At")
                {
                }
                field("Notification Processed By User";"Notification Processed By User")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                }
                field("Blocked By User";"Blocked By User")
                {
                }
                field("Notification Trigger";"Notification Trigger")
                {
                }
                field("Template Filter Value";"Template Filter Value")
                {
                }
                field("Target Member Role";"Target Member Role")
                {
                }
                field("Include NP Pass";"Include NP Pass")
                {
                }
                field("Processing Method";"Processing Method")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("View Members Notified")
            {
                Caption = 'View Members Notified';
                Image = InteractionLog;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "MM Member Notification Entry";
                RunPageLink = "Notification Entry No."=FIELD("Entry No.");
            }
        }
        area(processing)
        {
            action("Send Notifications")
            {
                Caption = 'Send Notifications';
                Image = SendTo;
                Promoted = true;

                trigger OnAction()
                begin

                    SendNotification (Rec);
                end;
            }
        }
    }

    local procedure SendNotification(MembershipNotification: Record "MM Membership Notification")
    var
        MemberNotification: Codeunit "MM Member Notification";
    begin

        MemberNotification.HandleMembershipNotification (MembershipNotification);
        CurrPage.Update (false);
    end;
}

