enum 6151504 "NPR WalletRole"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; Holder)
    {
        Caption = 'Holder';
    }

    value(1; Owner)
    {
        Caption = 'Owner';
    }

    value(2; Agent)
    {
        Caption = 'Agent';
    }

    value(3; Seller)
    {
        Caption = 'Seller';
    }
}