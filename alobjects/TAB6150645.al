table 6150645 "POS Info Lookup Setup"
{
    Caption = 'POS Info Lookup Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Info Code"; Code[20])
        {
            Caption = 'POS Info Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Info";
        }
        field(2; "Table No"; Integer)
        {
            Caption = 'Table No';
            DataClassification = CustomerContent;
        }
        field(3; "Map To"; Option)
        {
            Caption = 'Map To';
            DataClassification = CustomerContent;
            OptionCaption = 'Field 1,Field 2,Field 3,Field 4,Field 5,Field 6';
            OptionMembers = "Field 1","Field 2","Field 3","Field 4","Field 5","Field 6";
        }
        field(10; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No"));
        }
        field(11; "Field Name"; Text[30])
        {
            CalcFormula = Lookup (Field."Field Caption" WHERE(TableNo = FIELD("Table No"),
                                                              "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "POS Info Code", "Table No", "Map To")
        {
        }
    }

    fieldgroups
    {
    }
}

