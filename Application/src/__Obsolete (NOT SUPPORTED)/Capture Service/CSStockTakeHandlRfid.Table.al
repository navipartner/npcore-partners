﻿table 6151390 "NPR CS Stock-Take Handl. Rfid"
{
    Access = Internal;

    Caption = 'CS Stock-Take Handling Rfid';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Object moved to NP Warehouse App.';
    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(10; "Stock-Take Id"; Guid)
        {
            Caption = 'Stock-Take Id';
            DataClassification = CustomerContent;
        }
        field(11; "Batch Id"; Guid)
        {
            Caption = 'Batch Id';
            DataClassification = CustomerContent;
        }
        field(12; "Request Data"; BLOB)
        {
            Caption = 'Request Data';
            DataClassification = CustomerContent;
        }
        field(13; "Request Function"; Text[30])
        {
            Caption = 'Request Function';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Response Data"; BLOB)
        {
            Caption = 'Response Data';
            DataClassification = CustomerContent;
        }
        field(15; "Batch No."; Integer)
        {
            Caption = 'Batch No.';
            DataClassification = CustomerContent;
        }
        field(16; "Device Id"; Code[10])
        {
            Caption = 'Device Id';
            DataClassification = CustomerContent;
        }
        field(17; "Stock-Take Config Code"; Code[10])
        {
            Caption = 'Stock-Take Conf. Code';
            DataClassification = CustomerContent;
        }
        field(18; "Worksheet Name"; Code[10])
        {
            Caption = 'Worksheet Name';
            DataClassification = CustomerContent;
        }
        field(19; Tags; Integer)
        {
            Caption = 'Tags';
            DataClassification = CustomerContent;
        }
        field(20; Handled; Boolean)
        {
            Caption = 'Handled';
            DataClassification = CustomerContent;
        }
        field(21; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(22; "Created By"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }
        field(23; "Batch Posting"; Boolean)
        {
            Caption = 'Batch Posting';
            DataClassification = CustomerContent;
        }
        field(24; "Posting Started"; DateTime)
        {
            Caption = 'Posting Started';
            DataClassification = CustomerContent;
        }
        field(25; "Posting Ended"; DateTime)
        {
            Caption = 'Posting Ended';
            DataClassification = CustomerContent;
        }
        field(26; "Posting Error"; Text[100])
        {
            Caption = 'Posting Error';
            DataClassification = CustomerContent;
        }
        field(27; "Posting Error Detail"; Text[250])
        {
            Caption = 'Posting Error Detail';
            DataClassification = CustomerContent;
        }
        field(28; "Area"; Option)
        {
            Caption = 'Area';
            DataClassification = CustomerContent;
            OptionCaption = 'Warehouse,Salesfloor,Stockroom';
            OptionMembers = Warehouse,Salesfloor,Stockroom;
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
        key(Key2; Created)
        {
        }
    }

    fieldgroups
    {
    }
}

