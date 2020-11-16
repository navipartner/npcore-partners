table 6151372 "NPR CS Comm. Log"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.50/CLVA/20180206 CASE 344466 Added field "Device Id"

    Caption = 'CS Communication Log';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR CS Comm. Log List";
    LookupPageID = "NPR CS Comm. Log List";

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Request Start"; DateTime)
        {
            Caption = 'Request Start';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Request End"; DateTime)
        {
            Caption = 'Request End';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Request Data"; BLOB)
        {
            Caption = 'Request Data';
            DataClassification = CustomerContent;
        }
        field(14; "Request Function"; Text[30])
        {
            Caption = 'Request Function';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "Response Data"; BLOB)
        {
            Caption = 'Response Data';
            DataClassification = CustomerContent;
        }
        field(16; "Internal Request"; Boolean)
        {
            Caption = 'Internal Request';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Internal Log No."; Guid)
        {
            Caption = 'Internal Log No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18; User; Code[20])
        {
            Caption = 'User';
            DataClassification = CustomerContent;
        }
        field(19; "Device Id"; Code[10])
        {
            Caption = 'Device Id';
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

