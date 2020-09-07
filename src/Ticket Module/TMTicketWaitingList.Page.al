page 6151138 "NPR TM Ticket Waiting List"
{
    // TM1.45/TSA/20200122  CASE 380754 Transport TM1.45 - 22 January 2020

    Caption = 'Ticket Waiting List';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Wait. List";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("External Schedule Entry No."; "External Schedule Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Schedule Entry Description"; "Schedule Entry Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = All;
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Token; Token)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Notification Count"; "Notification Count")
                {
                    ApplicationArea = All;
                }
                field("Notified At"; "Notified At")
                {
                    ApplicationArea = All;
                }
                field("Notification Expires At"; "Notification Expires At")
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
            action("Notification Entries")
            {
                Caption = 'Notification Entries';
                Ellipsis = true;
                Image = ElectronicNumber;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket Notif. Entry";
                RunPageLink = "Ticket Token" = FIELD(Token);
                ApplicationArea=All;
            }
            action("Notify Now")
            {
                Caption = 'Notify Now';
                Image = Interaction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    TmpTicketNotificationEntry: Record "NPR TM Ticket Notif. Entry" temporary;
                    TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
                    TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
                    TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
                begin

                    TicketWaitingListMgr.CreateWaitingListNotification(Rec, TmpTicketNotificationEntry);
                    Commit;

                    TmpTicketNotificationEntry.FindFirst();
                    TicketNotificationEntry.SetFilter("Entry No.", '=%1', TmpTicketNotificationEntry."Entry No.");
                    TicketNotifyParticipant.SendGeneralNotification(TicketNotificationEntry);
                end;
            }
        }
    }
}

