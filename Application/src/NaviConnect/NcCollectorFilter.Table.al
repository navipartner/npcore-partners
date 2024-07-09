table 6151526 "NPR Nc Collector Filter"
{
    Access = Internal;
    Caption = 'Nc Collector Filter';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'NC Collector module removed from NpCore. We switched to Job Queue instead of using Task Queue.';

    fields
    {
        field(10; "Collector Code"; Code[20])
        {
            Caption = 'Collector Code';
            DataClassification = CustomerContent;
        }
        field(20; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(30; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
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
        }
    }

    keys
    {
        key(Key1; "Collector Code", "Table No.", "Field No.")
        {
        }
    }
}

