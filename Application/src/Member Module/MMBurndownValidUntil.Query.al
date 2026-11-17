query 6014448 "NPR MM Burndown Valid Until"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'Membership Burndown Valid Until';

    elements
    {
        dataitem(MembershipEntry; "NPR MM Membership Entry")
        {
            DataItemTableFilter = Blocked = const(false);

            column(Context; Context)
            {
            }
            column(ValidUntilDate; "Valid Until Date")
            {
            }
            column(EntryCount)
            {
                Method = Count;
            }
        }
    }
}
