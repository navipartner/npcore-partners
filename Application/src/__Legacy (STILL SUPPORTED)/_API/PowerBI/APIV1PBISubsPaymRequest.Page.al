page 6185075 "NPR APIV1 PBI SubsPaymRequest"
{
    Extensible = false;
    Editable = false;
    DelayedInsert = true;
    PageType = API;
    APIPublisher = 'navipartner';
    APIGroup = 'powerBI';
    APIVersion = 'v1.0';
    EntitySetName = 'subscriptionPaymentRequests';
    EntityName = 'subscriptionPaymentRequest';
    SourceTable = "NPR MM Subscr. Payment Request";
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(SubsPaymRequestRepeater)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status', Locked = true;
                }
                field(subscriptionRequestEntryNo; Rec."Subscr. Request Entry No.")
                {
                    Caption = 'Subscription Request Entry No.', Locked = true;
                }
                field(psp; Rec.PSP)
                {
                    Caption = 'PSP', Locked = true;
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code', Locked = true;
                }
                field(externalTransactionId; Rec."External Transaction ID")
                {
                    Caption = 'External Transaction Id', Locked = true;
                }
                field(resultCode; Rec."Result Code")
                {
                    Caption = 'Result Code', Locked = true;
                }
                field(rejectedReasonCode; Rec."Rejected Reason Code")
                {
                    Caption = 'Rejected Reason Code', Locked = true;
                }
                field(rejectedReasonDescription; Rec."Rejected Reason Description")
                {
                    Caption = 'Rejected Reason Description', Locked = true;
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