page 6059939 "NPR APIV1 PBITicket"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'ticket';
    EntitySetName = 'tickets';
    Caption = 'PowerBI Ticket';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Ticket";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(ticketTypeCode; Rec."Ticket Type Code")
                {
                    Caption = 'Ticket Type Code', Locked = true;
                }
                field(externalMemberCardNo; Rec."External Member Card No.")
                {
                    Caption = 'External Member Card No.';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(blockedDate; Rec."Blocked Date")
                {
                    Caption = 'Blocked Date';
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';
                }
                field(salesReceiptNo; Rec."Sales Receipt No.")
                {
                    Caption = 'POS Reciept No.';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';
                }
                field(externalTicketNo; Rec."External Ticket No.")
                {
                    Caption = 'External Ticket No.';
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(validFromDate; Rec."Valid From Date")
                {
                    Caption = 'Valid From Date';
                }
                field(validFromTime; Rec."Valid From Time")
                {
                    Caption = 'Valid From Time';
                }
                field(validToDate; Rec."Valid To Date")
                {
                    Caption = 'Valid To Date';
                }
                field(validToTime; Rec."Valid To Time")
                {
                    Caption = 'Valid To Time';
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                }
                field(ticketReservationEntryNo; Rec."Ticket Reservation Entry No.")
                {
                    Caption = 'Ticket Reservation Entry No.';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time', Locked = true;
                }
            }
        }
    }
}