table 6151056 "Distribution Group Members"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group Members';

    fields
    {
        field(1;"Distribution Member Id";Integer)
        {
            Caption = 'Distribution Member Id';
        }
        field(2;"Distribution Group";Code[20])
        {
            Caption = 'Distribution Group';
            TableRelation = "Distribution Group".Code;
        }
        field(3;Location;Code[10])
        {
            Caption = 'Location';
            TableRelation = Location;

            trigger OnValidate()
            var
                location: Record Location;
            begin
                location.Get(Rec.Location);
                Description := location.Name;
            end;
        }
        field(4;Store;Code[10])
        {
            Caption = 'Store';
            TableRelation = "POS Store";
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;"Distribution Share Pct.";Decimal)
        {
            Caption = 'Distribution Share Pct.';
        }
    }

    keys
    {
        key(Key1;"Distribution Member Id")
        {
        }
        key(Key2;"Distribution Group",Location)
        {
        }
    }

    fieldgroups
    {
    }
}

