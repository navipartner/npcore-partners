table 6150670 "Upgrade NPRE Restaurant Setup"
{
    // [VLOBJUPG] Object may be deleted after upgrade
    // NPR5.52/ALPO/20190813 CASE 360258 Created object
    //                                   Upgrade table to handle schema change (field 'Auto print kintchen order' type changed from boolean to option)

    Caption = 'Restaurant Setup';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(10;"Waiter Pad No. Serie";Code[10])
        {
            Caption = 'Waiter Pad No. Serie';
        }
        field(11;"Kitchen Order Template";Code[20])
        {
            Caption = 'Kitchen Order Template';
        }
        field(12;"Pre Receipt Template";Code[20])
        {
            Caption = 'Pre Receipt Template';
        }
        field(13;"Auto Print Kitchen Order";Boolean)
        {
            Caption = 'Auto Print Kitchen Order';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

