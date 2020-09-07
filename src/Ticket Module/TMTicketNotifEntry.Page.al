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

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Date To Notify"; "Date To Notify")
                {
                    ApplicationArea = All;
                }
                field("Notification Send Status"; "Notification Send Status")
                {
                    ApplicationArea = All;
                }
                field("Notification Sent At"; "Notification Sent At")
                {
                    ApplicationArea = All;
                }
                field("Notification Sent By User"; "Notification Sent By User")
                {
                    ApplicationArea = All;
                }
                field("Notification Trigger"; "Notification Trigger")
                {
                    ApplicationArea = All;
                }
                field("Ticket Trigger Type"; "Ticket Trigger Type")
                {
                    ApplicationArea = All;
                }
                field("Ticket Type Code"; "Ticket Type Code")
                {
                    ApplicationArea = All;
                }
                field("Ticket No."; "Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Ticket List Price"; "Ticket List Price")
                {
                    ApplicationArea = All;
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = All;
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = All;
                }
                field("Relevant Date"; "Relevant Date")
                {
                    ApplicationArea = All;
                }
                field("Relevant Time"; "Relevant Time")
                {
                    ApplicationArea = All;
                }
                field("Relevant Datetime"; "Relevant Datetime")
                {
                    ApplicationArea = All;
                }
                field("Expire Date"; "Expire Date")
                {
                    ApplicationArea = All;
                }
                field("Expire Time"; "Expire Time")
                {
                    ApplicationArea = All;
                }
                field("Expire Datetime"; "Expire Datetime")
                {
                    ApplicationArea = All;
                }
                field(Voided; Voided)
                {
                    ApplicationArea = All;
                }
                field("External Ticket No."; "External Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Ticket No. for Printing"; "Ticket No. for Printing")
                {
                    ApplicationArea = All;
                }
                field(Section; Section)
                {
                    ApplicationArea = All;
                }
                field(Row; Row)
                {
                    ApplicationArea = All;
                }
                field(Seat; Seat)
                {
                    ApplicationArea = All;
                }
                field("Ticket Holder E-Mail"; "Ticket Holder E-Mail")
                {
                    ApplicationArea = All;
                }
                field("Ticket Holder Name"; "Ticket Holder Name")
                {
                    ApplicationArea = All;
                }
                field("Ticket BOM Adm. Description"; "Ticket BOM Adm. Description")
                {
                    ApplicationArea = All;
                }
                field("Adm. Event Description"; "Adm. Event Description")
                {
                    ApplicationArea = All;
                }
                field("Adm. Location Description"; "Adm. Location Description")
                {
                    ApplicationArea = All;
                }
                field("Ticket BOM Description"; "Ticket BOM Description")
                {
                    ApplicationArea = All;
                }
                field("Event Start Date"; "Event Start Date")
                {
                    ApplicationArea = All;
                }
                field("Event Start Time"; "Event Start Time")
                {
                    ApplicationArea = All;
                }
                field("Quantity To Admit"; "Quantity To Admit")
                {
                    ApplicationArea = All;
                }
                field("Waiting List Reference Code"; "Waiting List Reference Code")
                {
                    ApplicationArea = All;
                }
                field("Failed With Message"; "Failed With Message")
                {
                    ApplicationArea = All;
                }
                field("eTicket Type Code"; "eTicket Type Code")
                {
                    ApplicationArea = All;
                }
                field("eTicket Pass Id"; "eTicket Pass Id")
                {
                    ApplicationArea = All;
                }
                field("eTicket Pass Default URL"; "eTicket Pass Default URL")
                {
                    ApplicationArea = All;
                }
                field("eTicket Pass Andriod URL"; "eTicket Pass Andriod URL")
                {
                    ApplicationArea = All;
                }
                field("eTicket Pass Landing URL"; "eTicket Pass Landing URL")
                {
                    ApplicationArea = All;
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
                Caption = 'Recreate eTicket';
                Image = ElectronicNumber;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

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
                Caption = 'Resend eTicket';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea=All;

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
                Caption = 'Show eTicket Template Data';
                Image = ElectronicDoc;
                ApplicationArea=All;
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
                Caption = 'Send Notification';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea=All;

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

