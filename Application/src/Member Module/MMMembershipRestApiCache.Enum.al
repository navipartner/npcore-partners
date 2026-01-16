enum 6014563 "NPR MMMembershipRestApiCache"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; NoCache)
    {
        Caption = 'NoCache';
    }
    value(1; MemberCardNumber)
    {
        Caption = 'MemberCardNumber';
    }
    value(2; MemberCardNumberDetails)
    {
        Caption = 'MemberCardNumberDetails';
    }
    value(3; LoyaltyPoints)
    {
        Caption = 'LoyaltyPoints';
    }
}
