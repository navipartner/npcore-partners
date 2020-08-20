table 6184503 "CleanCash Register"
{
    // NPR4.21/JHL/20160302 CASE 222417 Table created to handle registration of register using CleanCash
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields/table with word Register in their name

    Caption = 'CleanCash Cash Register';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = Register."Register No.";
        }
        field(2; "CleanCash No. Series"; Code[10])
        {
            Caption = 'CleanCash No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(3; "CleanCash Integration"; Boolean)
        {
            Caption = 'CleanCash Integration';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.")
        {
        }
    }

    fieldgroups
    {
    }
}

