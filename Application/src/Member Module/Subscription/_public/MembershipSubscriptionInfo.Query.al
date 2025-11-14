query 6014515 "NPR MembershipSubscriptionInfo"
{
    QueryType = Normal;

    elements
    {
        dataitem(Membership; "NPR MM Membership")
        {
            column(Membership_SystemId; SystemId)
            {
            }
            column(Membership_EntryNo; "Entry No.")
            {
            }
            column(Membership_ExternalMembershipNo; "External Membership No.")
            {
            }
            dataitem(MembershipEntry; "NPR MM Membership Entry")
            {
                DataItemLink = "Membership Entry No." = Membership."Entry No.";
                SqlJoinType = InnerJoin;
                column(MembershipEntry_EntryNo; "Entry No.")
                {
                }
                column(MembershipEntry_ItemNo; "Item No.")
                {
                }
                column(MembershipEntry_Description; Description)
                {
                }
                column(MembershipEntry_Context; Context)
                {
                }

                dataitem(Subscription; "NPR MM Subscription")
                {
                    DataItemLink = "Membership Entry No." = Membership."Entry No.", "Membership Ledger Entry No." = MembershipEntry."Entry No.";
                    SqlJoinType = LeftOuterJoin;
                    column(Subscription_SystemId; SystemId)
                    {
                    }
                    column(Subscription_EntryNo; "Entry No.")
                    {
                    }
                    column(Subscription_Blocked; Blocked)
                    {
                    }
                    column(Subscription_ValidFromDate; "Valid From Date")
                    {
                    }
                    column(Subscription_ValidUntilDate; "Valid Until Date")
                    {
                    }
                    column(Subscription_CommittedUntil; "Committed Until")
                    {
                    }
                    column(Subscription_PostponeRenewalAttemptUntil; "Postpone Renewal Attempt Until")
                    {
                    }
                    column(Subscription_Auto_Renew; "Auto-Renew")
                    {
                    }

                    dataitem(SubscriptionRequest; "NPR MM Subscr. Request")
                    {
                        DataItemLink = "Subscription Entry No." = Subscription."Entry No.";
                        SqlJoinType = LeftOuterJoin;
                        column(SubscriptionRequest_EntryNo; "Entry No.")
                        {
                        }
                        column(SubscriptionRequest_Type; Type)
                        {
                        }
                        column(SubscriptionRequest_Status; Status)
                        {
                        }
                        column(SubscriptionRequest_ProcessingStatus; "Processing Status")
                        {
                        }
                        column(SubscriptionRequest_Description; Description)
                        {
                        }
                        column(SubscriptionRequest_NewValidFromDate; "New Valid From Date")
                        {
                        }
                        column(SubscriptionRequest_NewValidUntilDate; "New Valid Until Date")
                        {
                        }
                        column(SubscriptionRequest_TerminateAt; "Terminate At")
                        {
                        }
                        column(SubscriptionRequest_Amount; Amount)
                        {
                        }
                        column(SubscriptionRequest_CurrencyCode; "Currency Code")
                        {
                        }
                        column(SubscriptionRequest_ItemNo; "Item No.")
                        {
                        }
                        column(SubscriptionRequest_Posted; Posted)
                        {
                        }
                        column(SubscriptionRequest_PostedMshipLedgEntryNo; "Posted M/ship Ledg. Entry No.")
                        {
                        }
                        column(SubscriptionRequest_MembershipEntryToCancel; "Membership Entry To Cancel")
                        {
                        }
                        column(SubscriptionRequest_GL_EntryNo; "G/L Entry No.")
                        {
                        }
                        column(SubscriptionRequest_PostingDocumentType; "Posting Document Type")
                        {
                        }
                        column(SubscriptionRequest_PostingDocumentNo; "Posting Document No.")
                        {
                        }
                        column(SubscriptionRequest_PostingDate; "Posting Date")
                        {
                        }
                        column(SubscriptionRequest_CustLedgerEntryNo; "Cust. Ledger Entry No.")
                        {
                        }
                        column(SubscriptionRequest_ProcessTryCount; "Process Try Count")
                        {
                        }
                        column(SubscriptionRequest_Reversed; Reversed)
                        {
                        }
                        column(SubscriptionRequest_ReversedByEntryNo; "Reversed by Entry No.")
                        {
                        }
                        column(SubscriptionRequest_ProcessingStatusChangeDate; "Processing Status Change Date")
                        {
                        }
                        column(SubscriptionRequest_RenewScheduleDateFormula; "Renew Schedule Date Formula")
                        {
                        }
                        column(SubscriptionRequest_RenewScheduleDate; "Renew Schedule Date")
                        {
                        }
                        column(SubscriptionRequest_TerminationReason; "Termination Reason")
                        {
                        }
                        column(SubscriptionRequest_TerminationRequestedAt; "Termination Requested At")
                        {
                        }
                    }
                }
            }
        }
    }
}