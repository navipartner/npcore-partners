enum 6151505 "NPR WalletReferenceType"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    // Asset related references (1:1 with a wallet line)
    value(100; TICKET_NUMBER)
    {
        Caption = 'Ticket Number';
    }

    value(110; COUPON_NUMBER)
    {
        Caption = 'Coupon Number';
    }

    value(120; VOUCHER_NUMBER)
    {
        Caption = 'Voucher Number';
    }

    // Holder related references (1:n with wallet line, spanning multiple transactions id's)
    value(200; CONTACT_NUMBER)
    {
        Caption = 'Contact Number';
    }

    value(210; WALLET_ID)
    {
        Caption = 'Wallet ID';
    }

    value(220; MEMBER_NUMBER)
    {
        Caption = 'Member Number';
    }


    // Owner related references (1:1 with a wallet header transaction id)
    value(300; CUSTOMER_NUMBER)
    {
        Caption = 'Customer No.';
    }

    value(310; POS_ENTRY_SYSTEM_ID)
    {
        Caption = 'POS System ID';
    }

    value(320; WEB_ORDER_REFERENCE)
    {
        Caption = 'Web Order Reference';
    }

    value(330; MEMBERSHIP_NUMBER)
    {
        Caption = 'Membership Number';
    }

    value(340; CREDIT_CARD_TOKEN)
    {
        Caption = 'Credit Card Token';
    }

    // Agent related references (1:1 with a wallet header transaction id)
    value(400; EXTERNAL_DOCUMENT_NUMBER)
    {
        Caption = 'External Document No.';
    }

}