table 6059958 "MCS Person"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to object

    Caption = 'MCS Person';

    fields
    {
        field(1;PersonId;Text[50])
        {
            Caption = 'Person Id';
            Editable = false;
        }
        field(11;Name;Text[50])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                if  (xRec.Name <> '') and (Name <> xRec.Name) then
                  MCSFaceServiceAPI.UpdatePersonInfo(Rec);
            end;
        }
        field(12;UserData;Text[250])
        {
            Caption = 'User Data';

            trigger OnValidate()
            begin
                if (xRec.UserData <> '') and (UserData <> xRec.UserData) then
                  MCSFaceServiceAPI.UpdatePersonInfo(Rec);
            end;
        }
        field(13;PersonGroupId;Text[50])
        {
            Caption = 'Person Group Id';
            Editable = false;
            TableRelation = "MCS Person Groups";
        }
        field(14;Faces;Integer)
        {
            CalcFormula = Count("MCS Faces" WHERE (PersonId=FIELD(PersonId)));
            Caption = 'Faces';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;PersonId)
        {
        }
    }

    fieldgroups
    {
    }

    var
        MCSFaceServiceAPI: Codeunit "MCS Face Service API";
}

