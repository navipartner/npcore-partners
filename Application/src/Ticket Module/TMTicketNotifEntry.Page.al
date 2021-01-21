page 6060065 "NPR TM Ticket Notif. Entry"
{
    // TM1.38/TSA/20181025  CASE 332109 Transport TM1.38 - 25 October 2018
    // TM1.39/NPKNAV/20190125  CASE 310057 Transport TM1.39 - 25 January 2019
    // TM1.45/TSA /20191202 CASE 374620 Send Stakeholder Nofification Manually
    // TM1.45/TSA /20191204 CASE 380754 Added field "Waiting List Reference Code"
    // TM90.1.46/TSA /20200129 CASE 387138 Changed caption on action and change name of function
    // TM90.1.46/TSA /20200318 CASE 374620 Added a commit after changing status to pending

    Caption = 'Ticket Notification Entry';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Notif. Entry";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Date To Notify"; "Date To Notify")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Date To Notify field';
                }
                field("Notification Send Status"; "Notification Send Status")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Send Status field';
                }
                field("Notification Sent At"; "Notification Sent At")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Sent At field';
                }
                field("Notification Sent By User"; "Notification Sent By User")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Sent By User field';
                }
                field("Notification Trigger"; "Notification Trigger")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Trigger field';
                }
                field("Ticket Trigger Type"; "Ticket Trigger Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Trigger Type field';
                }
                field("Ticket Type Code"; "Ticket Type Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                }
                field("Ticket No."; "Ticket No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Ticket List Price"; "Ticket List Price")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket List Price field';
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Method field';
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
                field("Relevant Date"; "Relevant Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Relevant Date field';
                }
                field("Relevant Time"; "Relevant Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Relevant Time field';
                }
                field("Relevant Datetime"; "Relevant Datetime")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Relevant Datetime field';
                }
                field("Expire Date"; "Expire Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Expire Date field';
                }
                field("Expire Time"; "Expire Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Expire Time field';
                }
                field("Expire Datetime"; "Expire Datetime")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Expire Datetime field';
                }
                field(Voided; Voided)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Voided field';
                }
                field("External Ticket No."; "External Ticket No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Ticket No. field';
                }
                field("Ticket No. for Printing"; "Ticket No. for Printing")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. for Printing field';
                }
                field(Section; Section)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Section field';
                }
                field(Row; Row)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Row field';
                }
                field(Seat; Seat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Seat field';
                }
                field("Ticket Holder E-Mail"; "Ticket Holder E-Mail")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Holder E-Mail field';
                }
                field("Ticket Holder Name"; "Ticket Holder Name")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Holder Name field';
                }
                field("Ticket BOM Adm. Description"; "Ticket BOM Adm. Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Item Description field';
                }
                field("Adm. Event Description"; "Adm. Event Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Adm. Event Description field';
                }
                field("Adm. Location Description"; "Adm. Location Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Adm. Location Description field';
                }
                field("Ticket BOM Description"; "Ticket BOM Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket BOM Description field';
                }
                field("Event Start Date"; "Event Start Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Start Date field';
                }
                field("Event Start Time"; "Event Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Start Time field';
                }
                field("Quantity To Admit"; "Quantity To Admit")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Quantity To Admit field';
                }
                field("Waiting List Reference Code"; "Waiting List Reference Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Waiting List Reference Code field';
                }
                field("Failed With Message"; "Failed With Message")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Failed With Message field';
                }
                field("eTicket Type Code"; "eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the eTicket Type Code field';
                }
                field("eTicket Pass Id"; "eTicket Pass Id")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wallet Pass Id field';
                }
                field("eTicket Pass Default URL"; "eTicket Pass Default URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wallet Pass Default URL field';
                }
                field("eTicket Pass Andriod URL"; "eTicket Pass Andriod URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wallet Pass Andriod URL field';
                }
                field("eTicket Pass Landing URL"; "eTicket Pass Landing URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wallet Pass Combine URL field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Recreate eTicket")
            {
                ToolTip = 'Recreate wallet notification event.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'Recreate eTicket';
                Image = ElectronicNumber;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;


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
            action("Resend eTicket")
            {
                ToolTip = 'Resend wallet notification event. This will update wallet contents.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'Resend eTicket';
                Image = SendElectronicDocument;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;


                trigger OnAction()
                var
                    ReasonText: Text;
                    TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                begin

                    "Notification Send Status" := "Notification Send Status"::PENDING;
                    Modify();

                    //-TM1.39 [310057]
                    // IF (NOT TicketRequestManager.SendETicketNotification (Rec."Entry No.", ReasonText)) THEN
                    //   ERROR (ReasonText);
                    if (not TicketRequestManager.SendETicketNotification(Rec."Entry No.", false, ReasonText)) then
                        Error(ReasonText);
                    //+TM1.39 [310057]

                    CurrPage.Update(false);
                end;
            }
            action("Show eTicket Template Data")
            {
                ToolTip = 'Display information sent to wallet.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'Show eTicket Template Data';
                Image = ElectronicDoc;

                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                var
                    TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                begin

                    Message('%1', TicketRequestManager.GetETicketPassData(Rec));
                end;
            }
            separator(Separator6014444)
            {
            }
            action("Send Notification")
            {
                ToolTip = 'Send notification to ticket holder.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Send Notification';
                Image = SendElectronicDocument;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;


                trigger OnAction()
                var
                    TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
                    TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
                begin
                    //-+TM90.1.46 [387138] Function name change

                    //-TM1.45 [374620]
                    "Notification Send Status" := "Notification Send Status"::PENDING;
                    Modify();
                    Commit(); //-+TM90.1.46 [374620]

                    CurrPage.SetSelectionFilter(TicketNotificationEntry);
                    TicketNotifyParticipant.SendGeneralNotification(TicketNotificationEntry);

                    CurrPage.Update(false);
                    //+TM1.45 [374620]
                end;
            }
        }
    }
}

