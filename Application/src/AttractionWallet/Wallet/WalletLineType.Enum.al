enum 6151503 "NPR WalletLineType"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; WALLET)
    {
        Caption = 'Wallet';
    }

    value(10; TICKET)
    {
        Caption = 'Ticket';
    }

    value(11; COUPON)
    {
        Caption = 'Coupon';
    }

    value(12; MEMBERSHIP)
    {
        Caption = 'Membership';
    }

    value(13; VOUCHER)
    {
        Caption = 'Voucher';
    }
}