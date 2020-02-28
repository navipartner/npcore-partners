page 6151138 "TM Ticket Waiting List"
{
    // TM1.45/TSA/20200122  CASE 380754 Transport TM1.45 - 22 January 2020

    Caption = 'Ticket Waiting List';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "TM Ticket Waiting List";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("External Schedule Entry No.";"External Schedule Entry No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Admission Code";"Admission Code")
                {
                    Editable = false;
                }
                field("Schedule Entry Description";"Schedule Entry Description")
                {
                    Editable = false;
                }
                field("Notification Address";"Notification Address")
                {
                }
                field("Created At";"Created At")
                {
                    Editable = false;
                }
                field(Token;Token)
                {
                    Editable = false;
                }
                field("Item No.";"Item No.")
                {
                    Editable = false;
                }
                field("Variant Code";"Variant Code")
                {
                    Editable = false;
                }
                field(Status;Status)
                {
                }
                field("Notification Count";"Notification Count")
                {
                }
                field("Notified At";"Notified At")
                {
                }
                field("Notification Expires At";"Notification Expires At")
                {
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
                RunObject = Page "TM Ticket Notification Entry";
                RunPageLink = "Ticket Token"=FIELD(Token);
            }
            action("Notify Now")
            {
                Caption = 'Notify Now';
                Image = Interaction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TmpTicketNotificationEntry: Record "TM Ticket Notification Entry" temporary;
                    TicketNotificationEntry: Record "TM Ticket Notification Entry";
                    TicketWaitingListMgr: Codeunit "TM Ticket Waiting List Mgr.";
                    TicketNotifyParticipant: Codeunit "TM Ticket Notify Participant";
                begin

                    TicketWaitingListMgr.CreateWaitingListNotification (Rec, TmpTicketNotificationEntry);
                    Commit;

                    TmpTicketNotificationEntry.FindFirst ();
                    TicketNotificationEntry.SetFilter ("Entry No.", '=%1', TmpTicketNotificationEntry."Entry No.");
                    TicketNotifyParticipant.SendGeneralNotification (TicketNotificationEntry);
                end;
            }
        }
    }
}

