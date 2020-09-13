table 6014653 "NPR Tax Free GB I2 Service"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB I2 Service';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tax Free Unit"; Code[10])
        {
            Caption = 'Tax Free Unit';
            TableRelation = "NPR Tax Free POS Unit"."POS Unit No.";
            DataClassification = CustomerContent;
        }
        field(2; "Service ID"; Integer)
        {
            Caption = 'Service ID';
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(4; "Minimum Purchase Amount"; Decimal)
        {
            Caption = 'Minimum Purchase Amount';
            DataClassification = CustomerContent;
        }
        field(5; "Maximum Purchase Amount"; Decimal)
        {
            Caption = 'Maximum Purchase Amount';
            DataClassification = CustomerContent;
        }
        field(6; "Void Limit In Days"; Integer)
        {
            Caption = 'Void Limit In Days';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Tax Free Unit", "Service ID")
        {
        }
    }

    fieldgroups
    {
    }
}

