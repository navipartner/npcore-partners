page 6185074 "NPR APIV1 PBI SubsRequest"
{
    Extensible = false;
    PageType = API;
    Editable = false;
    DelayedInsert = true;
    DataAccessIntent = ReadOnly;
    APIPublisher = 'navipartner';
    APIGroup = 'powerBI';
    APIVersion = 'v1.0';
    EntitySetName = 'subscriptionRequests';
    EntityName = 'susbcriptionRequest';
    SourceTable = "NPR MM Subscr. Request";

    layout
    {
        area(Content)
        {
            repeater(SubsRequestRepeater)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status', Locked = true;
                }
                field(processingStatus; Rec."Processing Status")
                {
                    Caption = 'Processing Status', Locked = true;
                }
                field(subscriptionEntryNo; Rec."Subscription Entry No.")
                {
                    Caption = 'Subscription Entry No.', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(newValidFromDate; Rec."New Valid From Date")
                {
                    Caption = 'New Valid From Date', Locked = true;
                }
                field(newValidUntilDate; Rec."New Valid Until Date")
                {
                    Caption = 'New Valid Until Date', Locked = true;
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code', Locked = true;
                }
                field(posted; Rec.Posted)
                {
                    Caption = 'Posted', Locked = true;
                }
                field(postedMembershipEntryEntryNo; Rec."Posted M/ship Ledg. Entry No.")
                {
                    Caption = 'Posted Memebrship Entry Entry No.', Locked = true;
                }
                field(reversed; Rec.Reversed)
                {
                    Caption = 'Reversed', Locked = true;
                }
                field(reversedByEntryNo; Rec."Reversed by Entry No.")
                {
                    Caption = 'Reversed By Entry No.', Locked = true;
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