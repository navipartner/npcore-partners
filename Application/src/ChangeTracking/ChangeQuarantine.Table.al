table 6059991 "NPR Change Quarantine"
{
    Access = Internal;
    Caption = 'Change Quarantine';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Integration Type"; Enum "NPR Integration Type")
        {
            Caption = 'Integration Type';
        }
        field(20; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(21; "Table Name"; Text[249])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
        }
        field(30; "Row Version"; BigInteger)
        {
            Caption = 'Row Version';
        }
        field(40; "Record ID"; RecordId)
        {
            Caption = 'Record ID';
        }
        field(50; "Entity System Id"; Guid)
        {
            Caption = 'Entity System Id';
        }
        field(60; "Error Text"; Text[2048])
        {
            Caption = 'Error Text';
        }
        field(70; "Quarantined At"; DateTime)
        {
            Caption = 'Quarantined At';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
