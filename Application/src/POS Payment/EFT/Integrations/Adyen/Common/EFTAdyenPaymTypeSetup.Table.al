table 6184508 "NPR EFT Adyen Paym. Type Setup"
{
    Access = Internal;
    Caption = 'EFT Adyen Payment Type Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(2; "API Key"; Text[250])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(3; Environment; Option)
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
            OptionCaption = 'Live,Test';
            OptionMembers = PRODUCTION,TEST;
        }
        field(4; "Transaction Condition"; Option)
        {
            Caption = 'Transaction Condition';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Alipay,WeChat,Gift Card';
            OptionMembers = "NONE",ALIPAY,WECHAT,GIFTCARD;
        }
        field(5; "Create Recurring Contract"; Option)
        {
            Caption = 'Create Recurring Contract';
            DataClassification = CustomerContent;
            OptionCaption = 'No,Recurring,One Click,Recurring & One Click';
            OptionMembers = NO,RECURRING,ONECLICK,RECURRING_ONECLICK;
        }
        field(6; "Acquire Card First"; Boolean)
        {
            Caption = 'Acquire Card First';
            DataClassification = CustomerContent;
        }
        field(7; "Log Level"; Option)
        {
            Caption = 'Log Level';
            DataClassification = CustomerContent;
            OptionCaption = 'Errors,Full,None';
            OptionMembers = ERROR,FULL,"NONE";
        }
        field(8; "Silent Discount Allowed"; Boolean)
        {
            Caption = 'Silent Discount Allowed';
            DataClassification = CustomerContent;
        }
        field(9; "Capture Delay Hours"; Integer)
        {
            BlankZero = true;
            Caption = 'Capture Delay Hours';
            DataClassification = CustomerContent;
        }
        field(10; "Cashback Allowed"; Boolean)
        {
            Caption = 'Cashback Allowed';
            DataClassification = CustomerContent;
        }
        field(11; "Merchant Account"; Text[250])
        {
            Caption = 'Merchant Account';
            DataClassification = CustomerContent;
        }
        field(12; "Recurring API URL Prefix"; Text[250])
        {
            Caption = 'Recurring API URL Prefix';
            DataClassification = CustomerContent;
        }
        field(13; Unattended; Boolean)
        {
            Caption = 'Unattended';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-11-28';
            ObsoleteReason = 'The EFT module now correctly set "Self Service" field';
        }
        field(14; "Local Key Identifier"; Text[250])
        {
            Caption = 'Local Key Identifier';
            DataClassification = CustomerContent;
        }
        field(15; "Local Key Passphrase"; Text[250])
        {
            Caption = 'Local Key Passphrase';
            DataClassification = CustomerContent;
        }
        field(16; "Local Key Version"; Integer)
        {
            BlankZero = true;
            Caption = 'Local Key Version';
            DataClassification = CustomerContent;
        }

        field(17; "Manual Capture"; Boolean)
        {
            Caption = 'Manual Capture';
            DataClassification = CustomerContent;
        }
        field(18; "In Person Store Id"; Text[250])
        {
            Caption = 'Store Id';
            DataClassification = CustomerContent;
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

    procedure GetEncryptionKeyMaterialJson(): Text
    var
        KeyMaterial: Codeunit "Json Text Reader/Writer";
    begin
        KeyMaterial.SetDoNotFormat();
        KeyMaterial.WriteStartObject('');
        KeyMaterial.WriteStringProperty('KeyIdentifier', Rec."Local Key Identifier");
        KeyMaterial.WriteStringProperty('Password', Rec."Local Key Passphrase");
        //Do not use Number value since it will output decimal
        KeyMaterial.WriteProperty('KeyVersion');
        KeyMaterial.WriteValue(Rec."Local Key Version");
        KeyMaterial.WriteEndObject(); //root
        exit(KeyMaterial.GetJSonAsText());
    end;
}