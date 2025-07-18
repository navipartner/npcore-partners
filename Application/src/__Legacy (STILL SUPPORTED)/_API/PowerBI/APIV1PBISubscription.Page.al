page 6185073 "NPR APIV1 PBI Subscription"
{
    Extensible = false;
    PageType = API;
    Editable = false;
    DelayedInsert = true;
    SourceTable = "NPR MM Subscription";
    APIPublisher = 'navipartner';
    APIGroup = 'powerBI';
    APIVersion = 'v1.0';
    EntitySetName = 'mmSubscriptions';
    EntityName = 'mmSubscription';
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            repeater(SubscriptionRepeater)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(autoRenew; Rec."Auto-Renew")
                {
                    Caption = 'Auto-Renew', Locked = true;
                }
                field(membershipEntryNo; Rec."Membership Entry No.")
                {
                    Caption = 'Membership Entry No.', Locked = true;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;
                }
                field(startedAt; Rec."Started At")
                {
                    Caption = 'Started At', Locked = true;
                }
                field(validFromDate; Rec."Valid From Date")
                {
                    Caption = 'Valid From Date', Locked = true;
                }
                field(validUntilDate; Rec."Valid Until Date")
                {
                    Caption = 'Valid Until Date', Locked = true;
                }
                field(committedUntil; Rec."Committed Until")
                {
                    Caption = 'Committed Until', Locked = true;
                }
                field(terminateAt; Rec."Terminate At")
                {
                    Caption = 'Terminate At', Locked = true;
                }
                field(terminationRequestedAt; Rec."Termination Requested At")
                {
                    Caption = 'Termination Requested At', Locked = true;
                }
                field(terminationReason; Rec."Termination Reason")
                {
                    Caption = 'Termination Reason', Locked = true;
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