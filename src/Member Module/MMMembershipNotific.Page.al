page 6060143 "NPR MM Membership Notific."
{
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.26/NPKNAV/20180222  CASE 300681 Transport MM1.26 - 22 February 2018
    // MM1.29/TSA /20180506 CASE 314131 Added field for wallet services

    Caption = 'Membership Notification';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Membership Notific.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                }
                field("Notification Code"; "Notification Code")
                {
                    ApplicationArea = All;
                }
                field("Date To Notify"; "Date To Notify")
                {
                    ApplicationArea = All;
                }
                field("Notification Status"; "Notification Status")
                {
                    ApplicationArea = All;
                }
                field("Notification Processed At"; "Notification Processed At")
                {
                    ApplicationArea = All;
                }
                field("Notification Processed By User"; "Notification Processed By User")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                }
                field("Blocked By User"; "Blocked By User")
                {
                    ApplicationArea = All;
                }
                field("Notification Trigger"; "Notification Trigger")
                {
                    ApplicationArea = All;
                }
                field("Template Filter Value"; "Template Filter Value")
                {
                    ApplicationArea = All;
                }
                field("Target Member Role"; "Target Member Role")
                {
                    ApplicationArea = All;
                }
                field("Include NP Pass"; "Include NP Pass")
                {
                    ApplicationArea = All;
                }
                field("Processing Method"; "Processing Method")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR MM Member Notific. Entry";
                RunPageLink = "Notification Entry No." = FIELD("Entry No.");
                ApplicationArea=All;
            }
        }
        area(processing)
        {
            action("Send Notifications")
            {
                Caption = 'Send Notifications';
                Image = SendTo;
                Promoted = true;
                ApplicationArea=All;

                trigger OnAction()
                begin

                    SendNotification(Rec);
                end;
            }
        }
    }

    local procedure SendNotification(MembershipNotification: Record "NPR MM Membership Notific.")
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
    begin

        MemberNotification.HandleMembershipNotification(MembershipNotification);
        CurrPage.Update(false);
    end;
}

