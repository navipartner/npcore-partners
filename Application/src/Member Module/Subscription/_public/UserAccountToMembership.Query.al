query 6014513 "NPR UserAccountToMembership"
{
    QueryType = Normal;
    Access = Public;

    elements
    {
        dataitem(UserAccount; "NPR UserAccount")
        {
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

            dataitem(PaymentMethod; "NPR MM Member Payment Method")
            {
#if BC17 or BC18 or BC19 or BC20 or BC21
                DataItemTableFilter = "Table No." = const(6151165);
#else
                DataItemTableFilter = "Table No." = const(DATABASE::"NPR UserAccount");
#endif
                DataItemLink = "BC Record System ID" = UserAccount.SystemId;
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

                dataitem(MembershipPmtMethodMap; "NPR MM MembershipPmtMethodMap")
                {
                    DataItemLink = PaymentMethodId = PaymentMethod.SystemId;
                    SqlJoinType = InnerJoin;

                    column(MembershipPmtMethodMap_MembershipId; MembershipId)
                    {
                    }
                    column(MembershipPmtMethodMap_Status; Status)
                    {
                    }
                    column(MembershipPmtMethodMap_Default; Default)
                    {
                    }

                    dataitem(Membership; "NPR MM Membership")
                    {
                        DataItemLink = SystemId = MembershipPmtMethodMap.MembershipId;
                        SqlJoinType = InnerJoin;

                        column(Membership_SystemId; SystemId)
                        {
                        }
                        column(Membership_EntryNo; "Entry No.")
                        {
                        }
                        column(Membership_ExternalMembershipNo; "External Membership No.")
                        {
                        }
                    }
                }
            }
        }
    }
}

