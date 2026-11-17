query 6014447 "NPR MM Burndown Valid From"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'Membership Burndown Valid From';

    elements
    {
        dataitem(MembershipEntry; "NPR MM Membership Entry")
        {
            DataItemTableFilter = Blocked = const(false);

            column(Context; Context)
            {
            }
            column(ValidFromDate; "Valid From Date")
            {
            }
            column(EntryCount)
            {
                Method = Count;
            }
        }
    }
}
