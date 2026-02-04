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
                    Caption = 'External Member Card No.', Locked = true;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;
                }
                field(blockedDate; Rec."Blocked Date")
                {
                    Caption = 'Blocked Date', Locked = true;
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code', Locked = true;
                }
                field(salesReceiptNo; Rec."Sales Receipt No.")
                {
                    Caption = 'POS Reciept No.', Locked = true;
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.', Locked = true;
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date', Locked = true;
                }
                field(externalTicketNo; Rec."External Ticket No.")
                {
                    Caption = 'External Ticket No.', Locked = true;
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.', Locked = true;
                }
                field(validFromDate; Rec."Valid From Date")
                {
                    Caption = 'Valid From Date', Locked = true;
                }
                field(validFromTime; Rec."Valid From Time")
                {
                    Caption = 'Valid From Time', Locked = true;
                }
                field(validToDate; Rec."Valid To Date")
                {
                    Caption = 'Valid To Date', Locked = true;
                }
                field(validToTime; Rec."Valid To Time")
                {
                    Caption = 'Valid To Time', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code', Locked = true;
                }
                field(ticketReservationEntryNo; Rec."Ticket Reservation Entry No.")
                {
                    Caption = 'Ticket Reservation Entry No.', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time', Locked = true;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'System Created At', Locked = true;
                }
                field(amountExclVat; Rec.AmountExclVat)
                {
                    Caption = 'Amount Excl. VAT', Locked = true;
                }
                field(amountInclVat; Rec.AmountInclVat)
                {
                    Caption = 'Amount Incl. VAT', Locked = true;
                }
                field(listPriceExclVat; Rec.ListPriceExclVat)
                {
                    Caption = 'List Price Excl. VAT', Locked = true;
                }
                field(listPriceInclVat; Rec.ListPriceInclVat)
                {
                    Caption = 'List Price Incl. VAT', Locked = true;
                }
                field(printCount; Rec.PrintCount)
                {
                    Caption = 'Print Count', Locked = true;
                }
                field(printedDate; Rec."Printed Date")
                {
                    Caption = 'Printed Date', Locked = true;
                }
                field(printedDateTime; Rec.PrintedDateTime)
                {
                    Caption = 'Printed Date Time', Locked = true;
                }
                field(salesHeaderNo; Rec."Sales Header No.")
                {
                    Caption = 'Sales Header No.', Locked = true;
                }
                field(salesHeaderType; Rec."Sales Header Type")
                {
                    Caption = 'Sales Header Type', Locked = true;
                }

#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
}