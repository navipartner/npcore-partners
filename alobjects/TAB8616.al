tableextension 50052 tableextension50052 extends "Config. Package Field" 
{
    // NC2.12/MHA /20180502  CASE 308107 Added fields 6151090 "Field Type", 6151095 "Binary BLOB"
    fields
    {
        field(6151090;"Field Type";Text[30])
        {
            CalcFormula = Lookup(Field."Type Name" WHERE (TableNo=FIELD("Table ID"),
                                                          "No."=FIELD("Field ID")));
            Caption = 'Field Type';
            Description = 'NC2.12';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151095;"Binary BLOB";Boolean)
        {
            Caption = 'Binary BLOB';
            DataClassification = ToBeClassified;
            Description = 'NC2.12';
        }
    }
}

