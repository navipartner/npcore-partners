page 6060065 "TM Ticket Notification Entry"
{
    // TM1.38/TSA/20181025  CASE 332109 Transport TM1.38 - 25 October 2018
    // TM1.39/NPKNAV/20190125  CASE 310057 Transport TM1.39 - 25 January 2019
    // TM1.45/TSA /20191202 CASE 374620 Send Stakeholder Nofification Manually
    // TM1.45/TSA /20191204 CASE 380754 Added field "Waiting List Reference Code"

    Caption = 'Ticket Notification Entry';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "TM Ticket Notification Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Date To Notify";"Date To Notify")
                {
                }
                field("Notification Send Status";"Notification Send Status")
                {
                }
                field("Notification Sent At";"Notification Sent At")
                {
                }
                field("Notification Sent By User";"Notification Sent By User")
                {
                }
                field("Notification Trigger";"Notification Trigger")
                {
                }
                field("Ticket Trigger Type";"Ticket Trigger Type")
                {
                }
                field("Ticket Type Code";"Ticket Type Code")
                {
                }
                field("Ticket No.";"Ticket No.")
                {
                }
                field("Ticket List Price";"Ticket List Price")
                {
                }
                field("Notification Method";"Notification Method")
                {
                }
                field("Notification Address";"Notification Address")
                {
                }
                field("Relevant Date";"Relevant Date")
                {
                }
                field("Relevant Time";"Relevant Time")
                {
                }
                field("Relevant Datetime";"Relevant Datetime")
                {
                }
                field("Expire Date";"Expire Date")
                {
                }
                field("Expire Time";"Expire Time")
                {
                }
                field("Expire Datetime";"Expire Datetime")
                {
                }
                field(Voided;Voided)
                {
                }
                field("External Ticket No.";"External Ticket No.")
                {
                }
                field("Ticket No. for Printing";"Ticket No. for Printing")
                {
                }
                field(Section;Section)
                {
                }
                field(Row;Row)
                {
                }
                field(Seat;Seat)
                {
                }
                field("Ticket Holder E-Mail";"Ticket Holder E-Mail")
                {
                }
                field("Ticket Holder Name";"Ticket Holder Name")
                {
                }
                field("Ticket BOM Adm. Description";"Ticket BOM Adm. Description")
                {
                }
                field("Adm. Event Description";"Adm. Event Description")
                {
                }
                field("Adm. Location Description";"Adm. Location Description")
                {
                }
                field("Ticket BOM Description";"Ticket BOM Description")
                {
                }
                field("Event Start Date";"Event Start Date")
                {
                }
                field("Event Start Time";"Event Start Time")
                {
                }
                field("Quantity To Admit";"Quantity To Admit")
                {
                }
                field("Waiting List Reference Code";"Waiting List Reference Code")
                {
                }
                field("Failed With Message";"Failed With Message")
                {
                }
                field("eTicket Type Code";"eTicket Type Code")
                {
                }
                field("eTicket Pass Id";"eTicket Pass Id")
                {
                }
                field("eTicket Pass Default URL";"eTicket Pass Default URL")
                {
                }
                field("eTicket Pass Andriod URL";"eTicket Pass Andriod URL")
                {
                }
                field("eTicket Pass Landing URL";"eTicket Pass Landing URL")
                {
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

                trigger OnAction()
                var
                    TicketRequestManager: Codeunit "TM Ticket Request Manager";
                    ReasonText: Text;
                begin

                    if (not TicketRequestManager.CreateAndSendETicket (Rec."Ticket No.", ReasonText)) then
                      Error (ReasonText);

                    CurrPage.Update (false);
                end;
            }
            action("Resend eTicket")
            {
                Caption = 'Resend eTicket';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ReasonText: Text;
                    TicketRequestManager: Codeunit "TM Ticket Request Manager";
                begin

                    "Notification Send Status" := "Notification Send Status"::PENDING;
                    Modify ();

                    //-TM1.39 [310057]
                    // IF (NOT TicketRequestManager.SendETicketNotification (Rec."Entry No.", ReasonText)) THEN
                    //   ERROR (ReasonText);
                    if (not TicketRequestManager.SendETicketNotification (Rec."Entry No.", false, ReasonText)) then
                      Error (ReasonText);
                    //+TM1.39 [310057]

                    CurrPage.Update (false);
                end;
            }
            action("Show eTicket Template Data")
            {
                Caption = 'Show eTicket Template Data';
                Image = ElectronicDoc;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                var
                    TicketRequestManager: Codeunit "TM Ticket Request Manager";
                begin

                    Message ('%1', TicketRequestManager.GetETicketPassData (Rec));
                end;
            }
            separator(Separator6014444)
            {
            }
            action("Send Stakeholder Notification")
            {
                Caption = 'Send Stakeholder Notification';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TicketNotificationEntry: Record "TM Ticket Notification Entry";
                    TicketNotifyParticipant: Codeunit "TM Ticket Notify Participant";
                begin

                    //-TM1.45 [374620]
                    "Notification Send Status" := "Notification Send Status"::PENDING;
                    Modify ();

                    CurrPage.SetSelectionFilter (TicketNotificationEntry);
                    TicketNotifyParticipant.SendGeneralNotification (TicketNotificationEntry);

                    CurrPage.Update (false);
                    //+TM1.45 [374620]
                end;
            }
        }
    }
}

