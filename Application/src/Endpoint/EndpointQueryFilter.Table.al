table 6014679 "NPR Endpoint Query Filter"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created
    // NPR5.48/JDH /20181109 CASE 334163 Added Captions

    Caption = 'Endpoint Query Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Endpoint Query No."; BigInteger)
        {
            Caption = 'Endpoint Query No.';
            TableRelation = "NPR Endpoint Query";
            DataClassification = CustomerContent;
        }
        field(20; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
            DataClassification = CustomerContent;
        }
        field(30; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Field": Record "Field";
            begin
                Field.SetRange(TableNo, "Table No.");
                if PAGE.RunModal(PAGE::"NPR Field Lookup", Field) = ACTION::LookupOK then
                    "Field No." := Field."No.";
            end;

            trigger OnValidate()
            begin
                CalcFields("Field Name");
            end;
        }
        field(35; "Field Name"; Text[30])
        {
            CalcFormula = Lookup(Field.FieldName WHERE(TableNo = FIELD("Table No."),
                                                        "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Filter Text"; Text[250])
        {
            Caption = 'Filter Text';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Endpoint Query No.", "Table No.", "Field No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
    end;

}

