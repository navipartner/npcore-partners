table 6184517 "NPR EFT NETS Cloud Paym. Setup"
{
    Access = Internal;
    // NPR5.54/MMV /20200129 CASE 364340 Created object

    Caption = 'EFT NETS Cloud Payment Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(10; "API Username"; Text[250])
        {
            Caption = 'API Username';
            DataClassification = CustomerContent;
        }
        field(20; "API Password"; Text[250])
        {
            Caption = 'API Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(30; Environment; Option)
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
            OptionCaption = 'Production,Test';
            OptionMembers = PROD,TEST;
        }
        field(40; "Log Level"; Option)
        {
            Caption = 'Log Level';
            DataClassification = CustomerContent;
            OptionCaption = 'Full,Error,None';
            OptionMembers = FULL,ERROR,"NONE";
        }
        field(50; "Auto Reconcile on EOD"; Boolean)
        {
            Caption = 'Auto Reconcile on Balancing';
            DataClassification = CustomerContent;
            InitValue = true;
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

