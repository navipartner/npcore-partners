table 6151093 "Nc RapidConnect Trigger Field"
{
    // NC2.14/MHA /20180716  CASE 322308 Object created - Partial Trigger functionality

    Caption = 'Nc RapidConnect Trigger Field';
    DataClassification = CustomerContent;
    DrillDownPageID = "Nc RapidConnect Trigger Fields";
    LookupPageID = "Nc RapidConnect Trigger Fields";

    fields
    {
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Nc RapidConnect Setup";
        }
        field(5; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(10; "Field No."; Integer)
        {
            BlankZero = true;
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table ID"));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, "Table ID");
                if PAGE.RunModal(PAGE::"Field Lookup", Field) = ACTION::LookupOK then
                    "Field No." := Field."No.";

                CalcFields("Field Name");
            end;

            trigger OnValidate()
            begin
                CalcFields("Field Name");
            end;
        }
        field(15; "Field Name"; Text[50])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Table ID"),
                                                        "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
            end;
        }
    }

    keys
    {
        key(Key1; "Setup Code", "Table ID", "Field No.")
        {
        }
    }

    fieldgroups
    {
    }
}

