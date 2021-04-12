table 6151092 "NPR Nc RapidConn. Endpoint"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect

    Caption = 'Nc RapidConnect Endpoint';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Nc RapidConnect Setup";
        }
        field(5; "Endpoint Code"; Code[20])
        {
            Caption = 'Endpoint Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Nc Endpoint";
        }
        field(1000; "Endpoint Type"; Code[20])
        {
            CalcFormula = Lookup("NPR Nc Endpoint"."Endpoint Type" WHERE(Code = FIELD("Endpoint Code")));
            Caption = 'Endpoint Type';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "NPR Nc Endpoint Type";
            ValidateTableRelation = false;
        }
        field(1005; Description; Text[50])
        {
            CalcFormula = Lookup("NPR Nc Endpoint".Description WHERE(Code = FIELD("Endpoint Code")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Setup Summary"; Text[100])
        {
            CalcFormula = Lookup("NPR Nc Endpoint"."Setup Summary" WHERE(Code = FIELD("Endpoint Code")));
            Caption = 'Setup Summary';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Setup Code", "Endpoint Code")
        {
        }
    }

    fieldgroups
    {
    }
}

