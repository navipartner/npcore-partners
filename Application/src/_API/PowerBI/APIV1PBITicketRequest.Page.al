page 6151541 "NPR APIV1 PBITicketRequest"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'ticketRequest';
    EntitySetName = 'ticketRequests';
    Caption = 'PowerBI Ticket Request';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Ticket Reservation Req.";
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
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(sessionTokenID; Rec."Session Token ID")
                {
                    Caption = 'Session Token ID', Locked = true;
                }
                field(createdDateTime; Rec."Created Date Time")
                {
                    Caption = 'Created Date Time', Locked = true;
                }
                field(requestStatus; Rec."Request Status")
                {
                    Caption = 'Request Status', Locked = true;
                }
                field(requestStatusDateTime; Rec."Request Status Date Time")
                {
                    Caption = 'Request Status Date Time', Locked = true;
                }
                field(revokeTicketRequest; Rec."Revoke Ticket Request")
                {
                    Caption = 'Revoke Ticket Request', Locked = true;
                }
                field(revokeAccessEntryNo; Rec."Revoke Access Entry No.")
                {
                    Caption = 'Revoke Access Entry No.', Locked = true;
                }
                field(externalItemCode; Rec."External Item Code")
                {
                    Caption = 'External Item Code', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(externalAdmSchEntryNo; Rec."External Adm. Sch. Entry No.")
                {
                    Caption = 'External Adm. Sch. Entry No.', Locked = true;
                }
                field(extLineReferenceNo; Rec."Ext. Line Reference No.")
                {
                    Caption = 'Ext. Line Reference No.', Locked = true;
                }
                field(externalMemberNo; Rec."External Member No.")
                {
                    Caption = 'External Member No.', Locked = true;
                }
                field(admissionCode; Rec."Admission Code")
                {
                    Caption = 'Admission Code', Locked = true;
                }
                field(admissionInclusion; Rec."Admission Inclusion")
                {
                    Caption = 'Admission Inclusion', Locked = true;
                }
                field(admissionInclusionStatus; Rec."Admission Inclusion Status")
                {
                    Caption = 'Admission Inclusion Status', Locked = true;
                }
                field(expiresDateTime; Rec."Expires Date Time")
                {
                    Caption = 'Expires Date Time', Locked = true;
                }
                field(externalTicketNumber; Rec."External Ticket Number")
                {
                    Caption = 'External Ticket Number', Locked = true;
                }
                field(preAssignedTicketNumber; Rec.PreAssignedTicketNumber)
                {
                    Caption = 'Pre-Assigned Ticket Number', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code', Locked = true;
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(amountInclVat; Rec.AmountInclVat)
                {
                    Caption = 'Amount Incl. VAT', Locked = true;
                }
                field(unitAmount; Rec.UnitAmount)
                {
                    Caption = 'Unit Amount', Locked = true;
                }
                field(unitAmountInclVat; Rec.UnitAmountInclVat)
                {
                    Caption = 'Unit Amount Incl. VAT', Locked = true;
                }
                field(admissionDescription; Rec."Admission Description")
                {
                    Caption = 'Admission Description', Locked = true;
                }
                field(scheduledTimeDescription; Rec."Scheduled Time Description")
                {
                    Caption = 'Scheduled Time Description', Locked = true;
                }
                field(waitingListReferenceCode; Rec."Waiting List Reference Code")
                {
                    Caption = 'Waiting List Reference Code', Locked = true;
                }
                field(notificationMethod; Rec."Notification Method")
                {
                    Caption = 'Notification Method', Locked = true;
                }
                field(notificationAddress; Rec."Notification Address")
                {
                    Caption = 'Notification Address', Locked = true;
                }
                field(notificationFormat; Rec."Notification Format")
                {
                    Caption = 'Notification Format', Locked = true;
                }
                field(ticketHolderName; Rec.TicketHolderName)
                {
                    Caption = 'Ticket Holder Name', Locked = true;
                }
                field(diyPrintOrderRequested; Rec."DIY Print Order Requested")
                {
                    Caption = 'DIY Print Order Requested', Locked = true;
                }
                field(diyPrintOrderAt; Rec."DIY Print Order At")
                {
                    Caption = 'DIY Print Order At', Locked = true;
                }
                field(externalOrderNo; Rec."External Order No.")
                {
                    Caption = 'External Order No.', Locked = true;
                }
                field(primaryRequestLine; Rec."Primary Request Line")
                {
                    Caption = 'Primary Request Line', Locked = true;
                }
                field(admissionCreated; Rec."Admission Created")
                {
                    Caption = 'Admission Created', Locked = true;
                }
                field(paymentOption; Rec."Payment Option")
                {
                    Caption = 'Payment Option', Locked = true;
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.', Locked = true;
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'Entry Type', Locked = true;
                }
                field(superseedsEntryNo; Rec."Superseeds Entry No.")
                {
                    Caption = 'Superseeds Entry No.', Locked = true;
                }
                field(isSuperseeded; Rec."Is Superseeded")
                {
                    Caption = 'Is Superseeded', Locked = true;
                }
                field(authorizationCode; Rec."Authorization Code")
                {
                    Caption = 'Authorization Code', Locked = true;
                }
                field(default; Rec.Default)
                {
                    Caption = 'Default', Locked = true;
                }
                field(receiptNo; Rec."Receipt No.")
                {
                    Caption = 'Receipt No.', Locked = true;
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified DateTime Filter', Locked = true;
                }
            }
        }
    }
}
