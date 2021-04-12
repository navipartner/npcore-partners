table 6151526 "NPR Nc Collector Filter"
{
    // NC2.01/BR  /20160909  CASE 250447 NaviConnect: Object created
    // NC2.08/BR  /20171220  CASE 300634 Added field Collect When Modified

    Caption = 'Nc Collector Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Collector Code"; Code[20])
        {
            Caption = 'Collector Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Collector";
        }
        field(20; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(30; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));

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
        field(50; "Collect When Modified"; Boolean)
        {
            Caption = 'Collect When Modified';
            DataClassification = CustomerContent;
            Description = 'NC2.08';
        }
    }

    keys
    {
        key(Key1; "Collector Code", "Table No.", "Field No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        NcCollector: Record "NPR Nc Collector";
    begin
        if ("Table No." = 0) and ("Collector Code" <> '') then begin
            NcCollector.Get("Collector Code");
            "Table No." := NcCollector."Table No.";
        end;
        if "Table No." = 0 then
            Error(TxtSpecifyTableInCollector);
    end;

    var
        TxtSpecifyTableInCollector: Label 'Please specifiy the table in the Collector before adding filters.';
}

