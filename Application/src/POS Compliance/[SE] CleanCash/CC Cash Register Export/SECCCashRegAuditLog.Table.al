table 6059857 "NPR SE CC Cash Reg. Audit Log"
{
    Access = Internal;
    Caption = 'CleanCash Cash Register Audit Log';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR SE CC Cash Reg. Audit Log";
    LookupPageId = "NPR SE CC Cash Reg. Audit Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Entry Type"; Enum "NPR SE CC Audit Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Table Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "External Description"; Text[250])
        {
            Caption = 'External Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Additional Information"; Text[250])
        {
            Caption = 'Additional Information';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}