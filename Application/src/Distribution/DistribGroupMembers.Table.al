table 6151056 "NPR Distrib. Group Members"
{
    Access = Internal;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group Members';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Distribution Member Id"; Integer)
        {
            Caption = 'Distribution Member Id';
            DataClassification = CustomerContent;
        }
        field(2; "Distribution Group"; Code[20])
        {
            Caption = 'Distribution Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR Distrib. Group".Code;
        }
        field(3; Location; Code[10])
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
            TableRelation = Location;

            trigger OnValidate()
            var
                location: Record Location;
            begin
                location.Get(Rec.Location);
                Description := location.Name;
            end;
        }
        field(4; Store; Code[10])
        {
            Caption = 'Store';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Distribution Share Pct."; Decimal)
        {
            Caption = 'Distribution Share Pct.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Distribution Member Id")
        {
        }
        key(Key2; "Distribution Group", Location)
        {
        }
    }

    fieldgroups
    {
    }
}

