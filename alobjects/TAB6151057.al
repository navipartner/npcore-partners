table 6151057 "Distribution Headers"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Group Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Distribution Id"; Integer)
        {
            Caption = 'Distribution Id';
            DataClassification = CustomerContent;
        }
        field(10; "Distribution Group"; Code[20])
        {
            Caption = 'Distribution Group';
            DataClassification = CustomerContent;
            TableRelation = "Distribution Group";
        }
        field(11; "Item Hiearachy"; Code[20])
        {
            Caption = 'Item Hiearachy';
            DataClassification = CustomerContent;
            TableRelation = "Item Hierarchy";
        }
        field(20; "Distribution Type"; Option)
        {
            Caption = 'Distribution Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Automatic,Manual,Blocked';
            OptionMembers = Automatic,Manual,Blocked;
        }
        field(30; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; "Required Date"; Date)
        {
            Caption = 'Required Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Distribution Id")
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
        DistributionLines.SetRange("Distribution Id", "Distribution Id");
        DistributionLines.DeleteAll(true);
    end;
}

