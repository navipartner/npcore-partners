table 6151599 "NPR NpDc Coupon Setup"
{
    Caption = 'Coupon Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Coupon No. Series"; Code[20])
        {
            Caption = 'Coupon No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(20; "Arch. Coupon No. Series"; Code[20])
        {
            Caption = 'Posted Coupon No. Series';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';
            TableRelation = "No. Series";
        }
        field(25; "Reference No. Pattern"; Code[20])
        {
            Caption = 'Reference No. Pattern';
            DataClassification = CustomerContent;
        }
        field(30; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151591));
        }
        field(35; "Print on Issue"; Boolean)
        {
            Caption = 'Print on Issue';
            DataClassification = CustomerContent;
            Description = 'NPR5.42';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

