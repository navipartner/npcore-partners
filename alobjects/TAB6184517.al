table 6184517 "EFT NETS Cloud Payment Setup"
{
    // NPR5.54/MMV /20200129 CASE 364340 Created object

    Caption = 'EFT NETS Cloud Payment Setup';

    fields
    {
        field(1;"Payment Type POS";Code[10])
        {
            Caption = 'Payment Type POS';
            TableRelation = "Payment Type POS"."No.";
        }
        field(10;"API Username";Text[250])
        {
            Caption = 'API Username';
        }
        field(20;"API Password";Text[250])
        {
            Caption = 'API Password';
            ExtendedDatatype = Masked;
        }
        field(30;Environment;Option)
        {
            Caption = 'Environment';
            OptionCaption = 'Production,Test';
            OptionMembers = PROD,TEST;
        }
        field(40;"Log Level";Option)
        {
            Caption = 'Log Level';
            OptionCaption = 'Full,Error,None';
            OptionMembers = FULL,ERROR,"NONE";
        }
        field(50;"Auto Reconcile on EOD";Boolean)
        {
            Caption = 'Auto Reconcile on Balancing';
            InitValue = true;
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

