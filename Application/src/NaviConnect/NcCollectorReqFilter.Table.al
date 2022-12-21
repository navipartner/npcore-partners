table 6151530 "NPR Nc Collector Req. Filter"
{
    Access = Internal;
    Caption = 'Nc Collector Request Filter';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'NC Collector module removed from NpCore. We switched to Job Queue instead of using Task Queue.';
    ObsoleteTag = 'BC 21 - Task Queue deprecating starting from 28/06/2022';

    fields
    {
        field(10; "Nc Collector Request No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Nc Collector Request No.';
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
    }

    keys
    {
        key(Key1; "Nc Collector Request No.", "Table No.", "Field No.")
        {
        }
    }
}

