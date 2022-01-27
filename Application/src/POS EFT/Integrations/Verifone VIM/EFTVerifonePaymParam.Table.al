table 6184514 "NPR EFT Verifone Paym. Param."
{
    Access = Internal;
    // NPR5.53/MMV /20191204 CASE 349520 Added object

    Caption = 'EFT Verifone Payment Parameter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(10; "Initialize Timeout Seconds"; Integer)
        {
            Caption = 'Initialize Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 10;
        }
        field(20; "Login Timeout Seconds"; Integer)
        {
            Caption = 'Login Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 10;
        }
        field(30; "Logout Timeout Seconds"; Integer)
        {
            Caption = 'Logout Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 10;
        }
        field(40; "Setup Test Timeout Seconds"; Integer)
        {
            Caption = 'GatewayTest Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 10;
        }
        field(50; "Trx Lookup Timeout Seconds"; Integer)
        {
            Caption = 'Trx Lookup Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 10;
        }
        field(60; "Force Abort Min. Delay Seconds"; Integer)
        {
            Caption = 'Force Abort Delay Seconds';
            DataClassification = CustomerContent;
            InitValue = 10;
        }
        field(70; "Terminal Debug Mode"; Boolean)
        {
            Caption = 'Terminal Debug Mode';
            DataClassification = CustomerContent;
        }
        field(80; "Pre Login Delay Seconds"; Integer)
        {
            Caption = 'Pre Login Delay Seconds';
            DataClassification = CustomerContent;
            InitValue = 2;
        }
        field(90; "Post Reconcile Delay Seconds"; Integer)
        {
            Caption = 'Post Reconcile Delay Seconds';
            DataClassification = CustomerContent;
            InitValue = 2;
        }
        field(100; "Reconciliation Timeout Seconds"; Integer)
        {
            Caption = 'Reconciliation Timeout Seconds';
            DataClassification = CustomerContent;
            InitValue = 20;
        }
    }

    keys
    {
        key(Key1; "Payment Type POS")
        {
        }
    }

    fieldgroups
    {
    }
}

