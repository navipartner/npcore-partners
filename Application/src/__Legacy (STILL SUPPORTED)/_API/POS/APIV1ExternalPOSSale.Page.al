page 6059775 "NPR APIV1 - External POS Sale"
{
    Extensible = False;

    APIGroup = 'pos';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'External POS Sale';
    DelayedInsert = true;
    EntityName = 'externalPosSale';
    EntitySetName = 'externalPosSales';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR External POS Sale";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(startTime; Rec."Start Time")
                {
                    Caption = 'Start Time', Locked = true;
                }
                field("date"; Rec."Date")
                {
                    Caption = 'Date', Locked = true;
                }
                field(registerNo; Rec."Register No.")
                {
                    Caption = 'POS Unit No.', Locked = true;
                }

                field(salesTicketNo; Rec."Sales Ticket No.")
                {
                    Caption = 'Sales Ticket No.', Locked = true;
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code', Locked = true;
                }
                field(posStoreCode; Rec."POS Store Code")
                {
                    Caption = 'POS Store Code', Locked = true;
                }

                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.', Locked = true;
                }

                field(pricesIncludingVAT; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Including VAT', Locked = true;
                }
                field(eventNo; Rec."Event No.")
                {
                    Caption = 'Event No.', Locked = true;
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.', Locked = true;
                }
                field(reference; Rec.Reference)
                {
                    Caption = 'Reference', Locked = true;
                }
                field(posEntrySystemId; Rec."POS Entry System Id")
                {
                    Caption = 'POS Entry System Id', Locked = true;
                }

                field(smsTemplateCode; Rec."SMS Template")
                {
                    Caption = 'SMS Template', Locked = true;
                }
                field(emailTemplateCode; Rec."Email Template")
                {
                    Caption = 'E-mail Template', Locked = true;
                }
                field(externalPosSaleId; Rec."External Pos Sale Id")
                {
                    Caption = 'External Pos Sale Id', Locked = true;
                }
                field(externalPosId; Rec."External Pos Id")
                {
                    Caption = 'External Pos Id', Locked = true;
                }
                field(sendReceiptToEmail; Rec."Send Receipt: Email")
                {
                    Caption = 'Send Receipt: Email', Locked = true;
                }
                field(sendReceiptToSms; Rec."Send Receipt: SMS")
                {
                    Caption = 'Send Receipt: SMS', Locked = true;
                }
                field(email; Rec."E-mail")
                {
                    Caption = 'E-mail', Locked = true;
                }
                field(phoneNumber; Rec."Phone Number")
                {
                    Caption = 'Phone Number', Locked = true;
                }

                part(externalPosSaleLines; "NPR APIV1 - Ext. POS Sale Line")
                {
                    Caption = 'External Pos Sale Lines', Locked = true;
                    EntityName = 'externalPosSaleLine';
                    EntitySetName = 'externalPosSaleLines';
                    SubPageLink = "External POS Sale Entry No." = field("Entry No.");
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ExtPOSSaleProcessing: Codeunit "NPR Ext. POS Sale Processing";
    begin
        Rec.Insert(true);
        ExtPOSSaleProcessing.TryAutoFillExternalPOSSale(Rec);
        exit(false);
    end;
}
