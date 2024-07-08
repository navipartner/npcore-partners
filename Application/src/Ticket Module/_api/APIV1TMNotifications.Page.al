page 6014593 "NPR APIV1 - TM Notifications"
{
    PageType = API;
    Caption = 'externalNotification';
    APIPublisher = 'navipartner';
    APIGroup = 'ticket';
    APIVersion = 'v1.0';
    EntityName = 'externalNotification';
    EntitySetName = 'externalNotification';
    SourceTable = "NPR TM Ticket Notif. Entry";
    DelayedInsert = true;
    Extensible = false;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }

                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field(dateToNotify; Rec."Date To Notify")
                {
                    Caption = 'Date To Notify';
                }
                field(timeToNotify; Rec."Time To Notify")
                {
                    Caption = 'Time To Notify';
                }
                field(admissionCode; Rec."Admission Code")
                {
                    Caption = 'Admission Code';
                }

                field(admEventDescription; Rec."Adm. Event Description")
                {
                    Caption = 'Adm. Event Description';
                }
                field(admLocationDescription; Rec."Adm. Location Description")
                {
                    Caption = 'Adm. Location Description';
                }
                field(admissionScheduleEntryNo; Rec."Admission Schedule Entry No.")
                {
                    Caption = 'Admission Schedule Entry No.';
                }
                field(authorizationCode; Rec."Authorization Code")
                {
                    Caption = 'Authorization Code';
                }
                field(detTicketAccessEntryNo; Rec."Det. Ticket Access Entry No.")
                {
                    Caption = 'Det. Ticket Access Entry No.';
                }
                field(eventStartDate; Rec."Event Start Date")
                {
                    Caption = 'Event Start Date';
                }
                field(eventStartTime; Rec."Event Start Time")
                {
                    Caption = 'Event Start Time';
                }
                field(expireDate; Rec."Expire Date")
                {
                    Caption = 'Expire Date';
                }
                field(expireDatetime; Rec."Expire Datetime")
                {
                    Caption = 'Expire Datetime';
                }
                field(expireTime; Rec."Expire Time")
                {
                    Caption = 'Expire Time';
                }
                field(externalOrderNo; Rec."External Order No.")
                {
                    Caption = 'External Order No.';
                }
                field(externalTicketNo; Rec."External Ticket No.")
                {
                    Caption = 'External Ticket No.';
                }
                field(extraText; Rec."Extra Text")
                {
                    Caption = 'Extra Text';
                }
                field(failedWithMessage; Rec."Failed With Message")
                {
                    Caption = 'Failed With Message';
                }
                field(notificationAddress; Rec."Notification Address")
                {
                    Caption = 'Notification Address';
                }
                field(notificationGroupId; Rec."Notification Group Id")
                {
                    Caption = 'Notification Group Id';
                }
                field(notificationMethod; Rec."Notification Method")
                {
                    Caption = 'Notification Method';
                }
                field(notificationProcessMethod; Rec."Notification Process Method")
                {
                    Caption = 'Notification Process Method';
                }
                field(notificationSendStatus; Rec."Notification Send Status")
                {
                    Caption = 'Notification Send Status';
                }
                field(notificationSentAt; Rec."Notification Sent At")
                {
                    Caption = 'Notification Sent At';
                }
                field(notificationSentByUser; Rec."Notification Sent By User")
                {
                    Caption = 'Notification Sent By User';
                }
                field(notificationTrigger; Rec."Notification Trigger")
                {
                    Caption = 'Notification Trigger';
                }
                field(publishedTicketURL; Rec."Published Ticket URL")
                {
                    Caption = 'Published Ticket URL';
                }
                field(quantityToAdmit; Rec."Quantity To Admit")
                {
                    Caption = 'Quantity To Admit';
                }
                field(relevantDate; Rec."Relevant Date")
                {
                    Caption = 'Relevant Date';
                }
                field(relevantDatetime; Rec."Relevant Datetime")
                {
                    Caption = 'Relevant Datetime';
                }
                field(relevantTime; Rec."Relevant Time")
                {
                    Caption = 'Relevant Time';
                }
                field(row; Rec.Row)
                {
                    Caption = 'Row';
                }
                field(seat; Rec.Seat)
                {
                    Caption = 'Seat';
                }
                field(section; Rec.Section)
                {
                    Caption = 'Section';
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt';
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'SystemCreatedBy';
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt';
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy';
                }
                field(templateCode; Rec."Template Code")
                {
                    Caption = 'Template Code';
                }
                field(ticketBOMAdmDescription; Rec."Ticket BOM Adm. Description")
                {
                    Caption = 'Ticket Item Description';
                }
                field(ticketBOMDescription; Rec."Ticket BOM Description")
                {
                    Caption = 'Ticket BOM Description';
                }
                field(ticketExternalItemNo; Rec."Ticket External Item No.")
                {
                    Caption = 'Ticket External Item No.';
                }
                field(ticketHolderEMail; Rec."Ticket Holder E-Mail")
                {
                    Caption = 'Ticket Holder E-Mail';
                }
                field(ticketHolderName; Rec."Ticket Holder Name")
                {
                    Caption = 'Ticket Holder Name';
                }
                field(ticketItemNo; Rec."Ticket Item No.")
                {
                    Caption = 'Ticket Item No.';
                }
                field(ticketListPrice; Rec."Ticket List Price")
                {
                    Caption = 'Ticket List Price';
                }
                field(ticketNo; Rec."Ticket No.")
                {
                    Caption = 'Ticket No.';
                }
                field(ticketNoForPrinting; Rec."Ticket No. for Printing")
                {
                    Caption = 'Ticket No. for Printing';
                }
                field(ticketToken; Rec."Ticket Token")
                {
                    Caption = 'Ticket Token';
                }
                field(ticketTriggerType; Rec."Ticket Trigger Type")
                {
                    Caption = 'Ticket Trigger Type';
                }
                field(ticketTypeCode; Rec."Ticket Type Code")
                {
                    Caption = 'Ticket Type Code';
                }
                field(ticketVariantCode; Rec."Ticket Variant Code")
                {
                    Caption = 'Ticket Variant Code';
                }
                field(voided; Rec.Voided)
                {
                    Caption = 'Voided';
                }
                field(waitingListReferenceCode; Rec."Waiting List Reference Code")
                {
                    Caption = 'Waiting List Reference Code';
                }
                field(eTicketPassAndriodURL; Rec."eTicket Pass Andriod URL")
                {
                    Caption = 'Wallet Pass Andriod URL';
                }
                field(eTicketPassDefaultURL; Rec."eTicket Pass Default URL")
                {
                    Caption = 'Wallet Pass Default URL';
                }
                field(eTicketPassId; Rec."eTicket Pass Id")
                {
                    Caption = 'Wallet Pass Id';
                }
                field(eTicketPassLandingURL; Rec."eTicket Pass Landing URL")
                {
                    Caption = 'Wallet Pass Combine URL';
                }
                field(eTicketTypeCode; Rec."eTicket Type Code")
                {
                    Caption = 'eTicket Type Code';
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
        Rec.SetFilter("Notification Process Method", '=%1', Rec."Notification Process Method"::EXTERNAL);
    end;
}