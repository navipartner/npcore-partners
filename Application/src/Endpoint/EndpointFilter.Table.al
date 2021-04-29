table 6014675 "NPR Endpoint Filter"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Endpoint Code"; Code[20])
        {
            Caption = 'Endpoint Code';
            TableRelation = "NPR Endpoint";
            DataClassification = CustomerContent;
        }
        field(20; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
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
        field(35; "Field Name"; Text[50])
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
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Endpoint Code", "Table No.", "Field No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        Endpoint: Record "NPR Endpoint";
    begin
        if ("Table No." = 0) and ("Endpoint Code" <> '') then begin
            Endpoint.Get("Endpoint Code");
            "Table No." := Endpoint."Table No.";
        end;
        if "Table No." = 0 then
            Error(TxtSpecifyTableInEndPoint);
    end;

    var
        TxtSpecifyTableInEndPoint: Label 'Please specifiy the table in the Endpoint before adding filters.';
}

