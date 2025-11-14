query 6014516 "NPR MMSubPayRequestToAccount"
{
    QueryType = Normal;

    elements
    {
        dataitem(SubscriptionPaymentRequest; "NPR MM Subscr. Payment Request")
        {

            column(SubscriptionPaymentRequest_EntryNo; "Entry No.")
            {
            }
            column(SubscriptionPaymentRequest_SystemId; SystemId)
            {
            }
            column(SubscriptionPaymentRequest_SubscriptionRequestEntryNo; "Subscr. Request Entry No.")
            {
            }
            column(SubscriptionPaymentRequest_Type; Type)
            {
            }
            column(SubscriptionPaymentRequest_Status; Status)
            {
            }
            column(SubscriptionPaymentRequest_ResultCode; "Result Code")
            {
            }
            column(SubscriptionPaymentRequest_RejectedReasonCode; "Rejected Reason Code")
            {
            }
            column(SubscriptionPaymentRequest_RejectedReasonDescription; "Rejected Reason Description")
            {
            }

            dataitem(PaymentMethod; "NPR MM Member Payment Method")
            {
                DataItemLink = "Entry No." = SubscriptionPaymentRequest."Payment Method Entry No.";
                SqlJoinType = InnerJoin;
                column(PaymentMethod_SystemId; SystemId)
                {
                }
                column(PaymentMethod_EntryNo; "Entry No.")
                {
                }
                column(PaymentMethod_PSP; PSP)
                {
                }
                column(PaymentMethod_Status; Status)
                {
                }
                column(PaymentMethod_PaymentInstrumentType; "Payment Instrument Type")
                {
                }
                column(PaymentMethod_PaymentBrand; "Payment Brand")
                {
                }
                column(PaymentMethod_MaskedPan; "Masked Pan")
                {
                }
                column(PaymentMethod_ExpiryDate; "Expiry Date")
                {
                }
                column(PaymentMethod_PANLast4Digits; "PAN Last 4 Digits")
                {
                }
                column(PaymentMethod_Alias; "Payment Method Alias")
                {
                }
                dataitem(UserAccount; "NPR UserAccount")
                {
                    DataItemLink = SystemId = PaymentMethod."BC Record System ID";
                    SqlJoinType = InnerJoin;
                    column(UserAccount_SystemId; SystemId)
                    {
                    }
                    column(UserAccount_AccountNo; AccountNo)
                    {
                    }
                    column(UserAccount_FirstName; FirstName)
                    {
                    }
                    column(UserAccount_LastName; LastName)
                    {
                    }
                    column(UserAccount_DisplayName; DisplayName)
                    {
                    }
                    column(UserAccount_EmailAddress; EmailAddress)
                    {
                    }
                    column(UserAccount_PhoneNo; PhoneNo)
                    {
                    }
                }
            }
        }

    }
}