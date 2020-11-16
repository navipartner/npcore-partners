table 6059957 "NPR MCS Person Groups"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to object

    Caption = 'MCS Person Groups';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(11; PersonGroupId; Text[50])
        {
            Caption = 'Person Group Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; Name; Text[128])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if PersonGroups.FindLast then
            Id := PersonGroups.Id + 10000
        else
            Id := 10000;

        TestField(Name);
    end;

    var
        PersonGroups: Record "NPR MCS Person Groups";
}

