table 6184851 "FR Audit No. Series"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object
    // NPR5.51/MMV /20190614 CASE 356076 Added field 6

    Caption = 'FR Audit No. Series';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Unit";
        }
        field(2; "Reprint No. Series"; Code[10])
        {
            Caption = 'Reprint No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(3; "JET No. Series"; Code[10])
        {
            Caption = 'JET No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(4; "Period No. Series"; Code[10])
        {
            Caption = 'Period No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(5; "Grand Period No. Series"; Code[10])
        {
            Caption = 'Grand Period No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(6; "Yearly Period No. Series"; Code[10])
        {
            Caption = 'Yearly Period No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "POS Unit No.")
        {
        }
    }

    fieldgroups
    {
    }
}

