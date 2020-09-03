table 6059997 "NPR Scanner Service Log"
{
    // NPR5.29/NPKNAV/20170127  CASE 252352 Transport NPR5.29 - 27 januar 2017
    // NPR5.48/JDH /20181109 CASE 334163 Added Object Caption

    Caption = 'Scanner Service Log';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Scanner Service Log List";
    LookupPageID = "NPR Scanner Service Log List";

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Request Start"; DateTime)
        {
            Caption = 'Request Start';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Request End"; DateTime)
        {
            Caption = 'Request End';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Request Data"; BLOB)
        {
            Caption = 'Request Data';
            DataClassification = CustomerContent;
        }
        field(5; "Request Function"; Text[30])
        {
            Caption = 'Request Function';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Response Data"; BLOB)
        {
            Caption = 'Response Data';
            DataClassification = CustomerContent;
        }
        field(7; "Internal Request"; Boolean)
        {
            Caption = 'Internal Request';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Internal Log No."; Guid)
        {
            Caption = 'Internal Log No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Debug Request Data"; Text[250])
        {
            Caption = 'Debug Request Data';
            DataClassification = CustomerContent;
        }
        field(10; "Current User"; Text[250])
        {
            Caption = 'Current User';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
        key(Key2; "Request Start")
        {
        }
    }

    fieldgroups
    {
    }
}

