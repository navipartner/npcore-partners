page 6060065 "NPR TM Ticket Notif. Entry"
{
    Extensible = False;
    Caption = 'Ticket Notification Entry';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Notif. Entry";
    UsageCategory = None;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Date To Notify"; Rec."Date To Notify")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Date To Notify field';
                }
                field("Time To Notify"; Rec."Time To Notify")
                {
                    ToolTip = 'Specifies the value of the Time To Notify field';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Notification Send Status"; Rec."Notification Send Status")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Send Status field';
                }
                field("Notification Sent At"; Rec."Notification Sent At")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Sent At field';
                }
                field("Notification Sent By User"; Rec."Notification Sent By User")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Sent By User field';
                }
                field("Notification Trigger"; Rec."Notification Trigger")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Trigger field';
                }
                field("Ticket Trigger Type"; Rec."Ticket Trigger Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Trigger Type field';
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                }
                field("Notification Profile Code"; Rec."Notification Profile Code")
                {
                    ToolTip = 'Specifies the value of the Notification Profile Code field.';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Detention Time Seconds"; Rec."Detention Time Seconds")
                {
                    ToolTip = 'Specifies the value of the Detention Time Seconds field.';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Template Code"; Rec."Template Code")
                {
                    ToolTip = 'Specifies the value of the Template Code field';
                    ApplicationArea = NPRTicketEssential;
                }
                field("Notification Process Method"; Rec."Notification Process Method")
                {
                    ToolTip = 'Specifies the value of the Notification Process Method field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Ticket List Price"; Rec."Ticket List Price")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket List Price field';
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Method field';
                }
                field("Notification Address"; Rec."Notification Address")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
                field("Relevant Date"; Rec."Relevant Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Relevant Date field';
                }
                field("Relevant Time"; Rec."Relevant Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Relevant Time field';
                }
                field("Relevant Datetime"; Rec."Relevant Datetime")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Relevant Datetime field';
                }
                field("Expire Date"; Rec."Expire Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Expire Date field';
                }
                field("Expire Time"; Rec."Expire Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Expire Time field';
                }
                field("Expire Datetime"; Rec."Expire Datetime")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Expire Datetime field';
                }
                field(Voided; Rec.Voided)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Voided field';
                }
                field("External Ticket No."; Rec."External Ticket No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Ticket No. field';
                }
                field("Ticket No. for Printing"; Rec."Ticket No. for Printing")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. for Printing field';
                }
                field(Section; Rec.Section)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Section field';
                }
                field(Row; Rec.Row)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Row field';
                }
                field(Seat; Rec.Seat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Seat field';
                }
                field("Ticket Holder E-Mail"; Rec."Ticket Holder E-Mail")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Holder E-Mail field';
                }
                field("Ticket Holder Name"; Rec."Ticket Holder Name")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Holder Name field';
                }
                field("Ticket BOM Adm. Description"; Rec."Ticket BOM Adm. Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Item Description field';
                }
                field("Adm. Event Description"; Rec."Adm. Event Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Adm. Event Description field';
                }
                field("Adm. Location Description"; Rec."Adm. Location Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Adm. Location Description field';
                }
                field("Ticket BOM Description"; Rec."Ticket BOM Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket BOM Description field';
                }
                field("Event Start Date"; Rec."Event Start Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Start Date field';
                }
                field("Event Start Time"; Rec."Event Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Start Time field';
                }
                field("Quantity To Admit"; Rec."Quantity To Admit")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Quantity To Admit field';
                }
                field("Waiting List Reference Code"; Rec."Waiting List Reference Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Waiting List Reference Code field';
                }
                field("Failed With Message"; Rec."Failed With Message")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Failed With Message field';
                }
                field("eTicket Type Code"; Rec."eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the eTicket Type Code field';
                }
                field("eTicket Pass Id"; Rec."eTicket Pass Id")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wallet Pass Id field';
                }
                field("eTicket Pass Default URL"; Rec."eTicket Pass Default URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wallet Pass Default URL field';
                }
                field("eTicket Pass Andriod URL"; Rec."eTicket Pass Andriod URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wallet Pass Andriod URL field';
                }
                field("eTicket Pass Landing URL"; Rec."eTicket Pass Landing URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wallet Pass Combine URL field';
                }
                field("Authorization Code"; Rec."Authorization Code")
                {
                    ToolTip = 'Specifies the value of the Authorization Code field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Schedule Entry No."; Rec."Admission Schedule Entry No.")
                {
                    ToolTip = 'Specifies the value of the Admission Schedule Entry No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Det. Ticket Access Entry No."; Rec."Det. Ticket Access Entry No.")
                {
                    ToolTip = 'Specifies the value of the Det. Ticket Access Entry No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("External Order No."; Rec."External Order No.")
                {
                    ToolTip = 'Specifies the value of the External Order No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Extra Text"; Rec."Extra Text")
                {
                    ToolTip = 'Specifies the value of the Extra Text field';
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Ticket Item No."; Rec."Ticket Item No.")
                {
                    ToolTip = 'Specifies the value of the Ticket Item No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Variant Code"; Rec."Ticket Variant Code")
                {
                    ToolTip = 'Specifies the value of the Ticket Variant Code field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket External Item No."; Rec."Ticket External Item No.")
                {
                    ToolTip = 'Specifies the value of the Ticket External Item No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Token"; Rec."Ticket Token")
                {
                    ToolTip = 'Specifies the value of the Ticket Token field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Notification Group Id"; Rec."Notification Group Id")
                {
                    ToolTip = 'Specifies the value of the Notification Group Id field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Published Ticket URL"; Rec."Published Ticket URL")
                {
                    ToolTip = 'Specifies the value of the Published Ticket URL field';
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            Action("Recreate eTicket")
            {
                ToolTip = 'Recreate wallet notification event.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'Recreate eTicket';
                Image = ElectronicNumber;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;

                trigger OnAction()
                var
                    TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                    ReasonText: Text;
                begin
                    if (not TicketRequestManager.CreateAndSendETicket(Rec."Ticket No.", ReasonText)) then
                        Error(ReasonText);
                    CurrPage.Update(false);
                end;
            }
            Action("Resend eTicket")
            {
                ToolTip = 'Resend wallet notification event. This will update wallet contents.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'Resend eTicket';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;

                trigger OnAction()
                var
                    ReasonText: Text;
                    TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                begin

                    Rec."Notification Send Status" := Rec."Notification Send Status"::PENDING;
                    Rec.Modify();

                    if (not TicketRequestManager.SendETicketNotification(Rec."Entry No.", false, ReasonText)) then
                        Error(ReasonText);

                    CurrPage.Update(false);
                end;
            }
            Action("Show eTicket Template Data")
            {
                ToolTip = 'Display information sent to wallet.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'Show eTicket Template Data';
                Image = ElectronicDoc;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;

                trigger OnAction()
                var
                    TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                begin

                    Message('%1', TicketRequestManager.GetETicketPassData(Rec));
                end;
            }
            Action("Send Notification")
            {
                ToolTip = 'Send notification to ticket holder.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Send Notification';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;

                trigger OnAction()
                var
                    TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
                    TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
                begin

                    Rec."Notification Send Status" := Rec."Notification Send Status"::PENDING;
                    Rec.Modify();
                    Commit();

                    CurrPage.SetSelectionFilter(TicketNotificationEntry);
                    TicketNotifyParticipant.SendGeneralNotification(TicketNotificationEntry);

                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            Action(NotificationDetention)
            {
                ToolTip = 'Navigate to Notification Detention List.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Notification Detention';
                Image = BreakRulesList;
                RunObject = Page "NPR TM Detained Notification";
                RunPageLink = "Notification Address" = field("Notification Address"), "Notification Profile Code" = field("Notification Profile Code");
            }
        }
    }
}

