table 6184514 "EFT Verifone Payment Parameter"
{
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Payment Parameter';

    fields
    {
        field(1;"Payment Type POS";Code[10])
        {
            Caption = 'Payment Type POS';
            TableRelation = "Payment Type POS"."No.";
        }
        field(10;"Initialize Timeout Seconds";Integer)
        {
            Caption = 'Initialize Timeout Seconds';
            InitValue = 10;
        }
        field(20;"Login Timeout Seconds";Integer)
        {
            Caption = 'Login Timeout Seconds';
            InitValue = 10;
        }
        field(30;"Logout Timeout Seconds";Integer)
        {
            Caption = 'Logout Timeout Seconds';
            InitValue = 10;
        }
        field(40;"Setup Test Timeout Seconds";Integer)
        {
            Caption = 'GatewayTest Timeout Seconds';
            InitValue = 10;
        }
        field(50;"Trx Lookup Timeout Seconds";Integer)
        {
            Caption = 'Trx Lookup Timeout Seconds';
            InitValue = 10;
        }
        field(60;"Force Abort Min. Delay Seconds";Integer)
        {
            Caption = 'Force Abort Delay Seconds';
            InitValue = 10;
        }
        field(70;"Terminal Debug Mode";Boolean)
        {
            Caption = 'Terminal Debug Mode';
        }
        field(80;"Pre Login Delay Seconds";Integer)
        {
            Caption = 'Pre Login Delay Seconds';
            InitValue = 2;
        }
        field(90;"Post Reconcile Delay Seconds";Integer)
        {
            Caption = 'Post Reconcile Delay Seconds';
            InitValue = 2;
        }
        field(100;"Reconciliation Timeout Seconds";Integer)
        {
            Caption = 'Reconciliation Timeout Seconds';
            InitValue = 20;
        }
    }

    keys
    {
        key(Key1;"Payment Type POS")
        {
        }
    }

    fieldgroups
    {
    }
}

