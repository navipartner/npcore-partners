table 6059997 "Scanner Service Log"
{
    // NPR5.29/NPKNAV/20170127  CASE 252352 Transport NPR5.29 - 27 januar 2017
    // NPR5.48/JDH /20181109 CASE 334163 Added Object Caption

    Caption = 'Scanner Service Log';
    DrillDownPageID = "Scanner Service Log List";
    LookupPageID = "Scanner Service Log List";

    fields
    {
        field(1;Id;Guid)
        {
            Caption = 'Id';
            Editable = false;
        }
        field(2;"Request Start";DateTime)
        {
            Caption = 'Request Start';
            Editable = false;
        }
        field(3;"Request End";DateTime)
        {
            Caption = 'Request End';
            Editable = false;
        }
        field(4;"Request Data";BLOB)
        {
            Caption = 'Request Data';
        }
        field(5;"Request Function";Text[30])
        {
            Caption = 'Request Function';
            Editable = false;
        }
        field(6;"Response Data";BLOB)
        {
            Caption = 'Response Data';
        }
        field(7;"Internal Request";Boolean)
        {
            Caption = 'Internal Request';
            Editable = false;
        }
        field(8;"Internal Log No.";Guid)
        {
            Caption = 'Internal Log No.';
            Editable = false;
        }
        field(9;"Debug Request Data";Text[250])
        {
            Caption = 'Debug Request Data';
        }
        field(10;"Current User";Text[250])
        {
            Caption = 'Current User';
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
        key(Key2;"Request Start")
        {
        }
    }

    fieldgroups
    {
    }
}

