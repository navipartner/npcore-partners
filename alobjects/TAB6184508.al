table 6184508 "EFT Adyen Payment Type Setup"
{
    // NPR5.49/MMV /20190401 CASE 345188 Created object
    // NPR5.49/MMV /20190410 CASE 347476 Added field 7
    // NPR5.50/MMV /20190430 CASE 352465 Added field 8
    // NPR5.51/MMV /20190520 CASE 355433 Added field 9, 10
    // NPR5.53/MMV /20191211 CASE 377533 Added fields 11, 12

    Caption = 'EFT Adyen Payment Type Setup';

    fields
    {
        field(1;"Payment Type POS";Code[10])
        {
            Caption = 'Payment Type POS';
            TableRelation = "Payment Type POS"."No.";
        }
        field(2;"API Key";Text[250])
        {
            Caption = 'API Key';
            ExtendedDatatype = Masked;
        }
        field(3;Environment;Option)
        {
            Caption = 'Environment';
            OptionCaption = 'Production,Test';
            OptionMembers = PRODUCTION,TEST;
        }
        field(4;"Transaction Condition";Option)
        {
            Caption = 'Transaction Condition';
            OptionCaption = 'None,Alipay,WeChat,Gift Card';
            OptionMembers = "NONE",ALIPAY,WECHAT,GIFTCARD;
        }
        field(5;"Create Recurring Contract";Option)
        {
            Caption = 'Create Recurring Contract';
            OptionCaption = 'No,Recurring,One Click,Recurring & One Click';
            OptionMembers = NO,RECURRING,ONECLICK,RECURRING_ONECLICK;
        }
        field(6;"Acquire Card First";Boolean)
        {
            Caption = 'Acquire Card First';
        }
        field(7;"Log Level";Option)
        {
            Caption = 'Log Level';
            OptionCaption = 'Errors,Full,None';
            OptionMembers = ERROR,FULL,"NONE";
        }
        field(8;"Silent Discount Allowed";Boolean)
        {
            Caption = 'Silent Discount Allowed';
        }
        field(9;"Capture Delay Hours";Integer)
        {
            BlankZero = true;
            Caption = 'Capture Delay Hours';
        }
        field(10;"Cashback Allowed";Boolean)
        {
            Caption = 'Cashback Allowed';
        }
        field(11;"Merchant Account";Text[250])
        {
            Caption = 'Merchant Account';
        }
        field(12;"Recurring API URL Prefix";Text[250])
        {
            Caption = 'Recurring API URL Prefix';
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

