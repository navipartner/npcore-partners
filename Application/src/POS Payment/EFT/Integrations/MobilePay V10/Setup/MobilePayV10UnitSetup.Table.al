#if not CLOUD
table 6014544 "NPR MobilePayV10 Unit Setup"
{
    Access = Internal;
    Caption = 'MobilePayV10 Unit Setup';
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

            trigger OnValidate()
            begin
                if ("Store ID" <> xRec."Store ID") then begin
                    TestField("MobilePay POS ID", '');
                end;
            end;
        }
        field(20; "Merchant POS ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant POS ID';

            trigger OnValidate()
            begin
                if ("Merchant POS ID" <> xRec."Merchant POS ID") then begin
                    TestField("MobilePay POS ID", '');
                end;
            end;
        }
        field(30; "Only QR"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Only QR';

            trigger OnValidate()
            begin
                if ("Only QR" <> xRec."Only QR") then begin
                    TestField("MobilePay POS ID", '');
                end;
            end;
        }

        field(40; "Beacon ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Beacon ID (Box/QR)';

            trigger OnValidate()
            begin
                if ("Beacon ID" <> xRec."Beacon ID") then begin
                    TestField("MobilePay POS ID", '');
                end;
            end;
        }
        field(50; "MobilePay POS ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'MobilePay POS ID';
            Editable = false;
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
#endif