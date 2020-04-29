table 6151057 "Distribution Headers"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group Setup';

    fields
    {
        field(1;"Distribution Id";Integer)
        {
            Caption = 'Distribution Id';
        }
        field(10;"Distribution Group";Code[20])
        {
            Caption = 'Distribution Group';
            TableRelation = "Distribution Group";
        }
        field(11;"Item Hiearachy";Code[20])
        {
            Caption = 'Item Hiearachy';
            TableRelation = "Item Hierarchy";
        }
        field(20;"Distribution Type";Option)
        {
            Caption = 'Distribution Type';
            OptionCaption = 'Automatic,Manual,Blocked';
            OptionMembers = Automatic,Manual,Blocked;
        }
        field(30;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(50;"Required Date";Date)
        {
            Caption = 'Required Date';
        }
    }

    keys
    {
        key(Key1;"Distribution Id")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DistributionLines: Record "Distribution Lines";
    begin
        DistributionLines.SetRange("Distribution Id","Distribution Id");
        DistributionLines.DeleteAll(true);
    end;
}

