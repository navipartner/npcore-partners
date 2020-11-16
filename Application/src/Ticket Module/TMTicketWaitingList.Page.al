page 6151138 "NPR TM Ticket Waiting List"
{
    // TM1.45/TSA/20200122  CASE 380754 Transport TM1.45 - 22 January 2020

    Caption = 'Ticket Waiting List';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Wait. List";
    UsageCategory = Lists;
    ApplicationArea = NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    Visible = false;
                }
                field("External Schedule Entry No."; "External Schedule Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    Visible = false;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                }
                field("Schedule Entry Description"; "Schedule Entry Description")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                }
                field(Token; Token)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Notification Count"; "Notification Count")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Notified At"; "Notified At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Notification Expires At"; "Notification Expires At")
                {
                    ApplicationArea = NPRTicketAdvanced;
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
                ToolTip = 'Navigate to notification entries.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Notification Entries';
                Ellipsis = true;
                Image = ElectronicNumber;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket Notif. Entry";
                RunPageLink = "Ticket Token" = FIELD(Token);

            }
            action("Notify Now")
            {
                ToolTip = 'Send waitinglist notification now.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Notify Now';
                Image = Interaction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;


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

