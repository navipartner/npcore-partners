table 6151530 "NPR Nc Collector Req. Filter"
{
    Access = Internal;
    Caption = 'Nc Collector Request Filter';
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteReason = 'Task Queue module is about to be removed from NpCore so NC Collector is also going to be removed.';
    ObsoleteTag = 'BC 20 - Task Queue deprecating starting from 28/06/2022';

    fields
    {
        field(10; "Nc Collector Request No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Nc Collector Request No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Collector Request";
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
        key(Key1; "Nc Collector Request No.", "Table No.", "Field No.")
        {
        }
    }
}

