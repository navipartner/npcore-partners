table 6184503 "NPR CleanCash Register"
{

    Caption = 'CleanCash Cash Register';
    DataClassification = CustomerContent;
    ObsoleteReason = 'This table is not used anymore';
    ObsoleteState = Removed;
    ObsoleteTag = 'CleanCash To AL';
    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register"."Register No.";
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

