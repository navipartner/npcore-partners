table 6059957 "MCS Person Groups"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to object

    Caption = 'MCS Person Groups';

    fields
    {
        field(1;Id;Integer)
        {
            Caption = 'Id';
        }
        field(11;PersonGroupId;Text[50])
        {
            Caption = 'Person Group Id';
            Editable = false;
        }
        field(12;Name;Text[128])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1;Id)
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
        PersonGroups: Record "MCS Person Groups";
}

