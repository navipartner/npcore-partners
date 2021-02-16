table 6059958 "NPR MCS Person"
{

    Caption = 'MCS Person';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PersonId; Text[50])
        {
            Caption = 'Person Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; Name; Text[150])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (xRec.Name <> '') and (Name <> xRec.Name) then
                    MCSFaceServiceAPI.UpdatePersonInfo(Rec);
            end;
        }
        field(12; UserData; Text[250])
        {
            Caption = 'User Data';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (xRec.UserData <> '') and (UserData <> xRec.UserData) then
                    MCSFaceServiceAPI.UpdatePersonInfo(Rec);
            end;
        }
        field(13; PersonGroupId; Text[50])
        {
            Caption = 'Person Group Id';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "NPR MCS Person Groups";
        }
        field(14; Faces; Integer)
        {
            CalcFormula = Count("NPR MCS Faces" WHERE(PersonId = FIELD(PersonId)));
            Caption = 'Faces';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; PersonId)
        {
        }
    }
    var
        MCSFaceServiceAPI: Codeunit "NPR MCS Face Service API";
}

