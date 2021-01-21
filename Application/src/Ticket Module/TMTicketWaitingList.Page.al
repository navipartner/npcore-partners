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
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("External Schedule Entry No."; "External Schedule Entry No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the External Schedule Entry No. field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Schedule Entry Description"; "Schedule Entry Description")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Schedule Entry Description field';
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field(Token; Token)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Token field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Status; Status)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Notification Count"; "Notification Count")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Count field';
                }
                field("Notified At"; "Notified At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notified At field';
                }
                field("Notification Expires At"; "Notification Expires At")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Expires At field';
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
				PromotedOnly = true;
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
				PromotedOnly = true;
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

