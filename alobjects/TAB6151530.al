table 6151530 "Nc Collector Request Filter"
{
    // NC2.01\BR\20160909  CASE 250447 NaviConnect: Object created

    Caption = 'Nc Collector Request Filter';

    fields
    {
        field(10; "Nc Collector Request No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Nc Collector Request No.';
            TableRelation = "Nc Collector Request";
        }
        field(20; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(30; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, "Table No.");
                if PAGE.RunModal(PAGE::"Field Lookup", Field) = ACTION::LookupOK then
                    "Field No." := Field."No.";
            end;

            trigger OnValidate()
            begin
                CalcFields("Field Name");
            end;
        }
        field(35; "Field Name"; Text[30])
        {
            CalcFormula = Lookup (Field.FieldName WHERE(TableNo = FIELD("Table No."),
                                                        "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Filter Text"; Text[250])
        {
            Caption = 'Filter Text';
        }
    }

    keys
    {
        key(Key1; "Nc Collector Request No.", "Table No.", "Field No.")
        {
        }
    }

    fieldgroups
    {
    }
}

