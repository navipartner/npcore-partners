table 6014544 "NPR MobilePayV10 Unit Setup"
{
    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
            Caption = 'POS Unit No.';
        }
        field(10; "Store ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Store ID';
        }
        field(20; "Merchant POS ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant POS ID';
        }
        field(30; "Only QR"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Only QR';
        }

        field(40; "Beacon ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Beacon ID (Box/QR)';
        }
        field(50; "MobilePay POS ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'MobilePay POS ID';
        }
    }

    keys
    {
        key(PK; "POS Unit No.")
        {
            Clustered = true;
        }
    }
}
