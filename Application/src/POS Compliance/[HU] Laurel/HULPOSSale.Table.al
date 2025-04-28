table 6151098 "NPR HU L POS Sale"
{
    Access = Internal;
    Caption = 'HU Laurel POS Sale';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Sale SystemId"; Guid)
        {
            Caption = 'POS Sale SystemId';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Sale".SystemId;
        }
        field(10; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(11; "Customer Post Code"; Text[20])
        {
            Caption = 'Customer Post Code';
            DataClassification = CustomerContent;
        }
        field(12; "Customer City"; Text[30])
        {
            Caption = 'Customer City';
            DataClassification = CustomerContent;
        }
        field(13; "Customer Address"; Text[100])
        {
            Caption = 'Customer Address';
            DataClassification = CustomerContent;
        }
        field(14; "Customer VAT Number"; Text[20])
        {
            Caption = 'Customer VAT Number';
            DataClassification = CustomerContent;
        }
        field(20; "Original Date"; Date)
        {
            Caption = 'Original Date';
            DataClassification = CustomerContent;
        }
        field(21; "Original Type"; Text[2])
        {
            Caption = 'Original Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                InvalidOrigTypeInputErr: Label 'Invalid input for Original Type. Allowed values are: %1', Comment = '%1 = Allowed Values';
                AllowedValuesLbl: Label 'NY, SZ', Locked = true;
            begin
                if not ("Original Type" in ['NY', 'SZ']) then
                    Error(InvalidOrigTypeInputErr, AllowedValuesLbl);
            end;
        }
        field(22; "Original BBOX ID"; Text[9])
        {
            Caption = 'Original BBOX ID';
            DataClassification = CustomerContent;
        }
        field(23; "Original No."; Integer)
        {
            Caption = 'Original No.';
            DataClassification = CustomerContent;
        }
        field(24; "Original Closure No."; Integer)
        {
            Caption = 'Original Closure No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "POS Sale SystemId")
        {
            Clustered = true;
        }
    }
}