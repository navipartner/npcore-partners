table 6014677 "NPR Endpoint Request"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created
    // NPR5.25\BR\20160801  CASE 234602 Added Field Query No.
    // NPR5.48/JDH /20181109 CASE 334163 Added Captions, and changed caption "PK" to "Primary Key"

    Caption = 'Endpoint Request';
    DrillDownPageID = "NPR Endpoint Request List";
    LookupPageID = "NPR Endpoint Request List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(10; "Endpoint Code"; Code[20])
        {
            Caption = 'Endpoint Code';
            TableRelation = "NPR Endpoint";
            DataClassification = CustomerContent;
        }
        field(20; "Request Batch No."; BigInteger)
        {
            Caption = 'Request Batch No.';
            TableRelation = "NPR Endpoint Request Batch";
            DataClassification = CustomerContent;
        }
        field(30; "Type of Change"; Option)
        {
            Caption = 'Type of Change';
            OptionCaption = 'Insert,Modify,Rename,Delete';
            OptionMembers = Insert,Modify,Rename,Delete;
            DataClassification = CustomerContent;
        }
        field(35; "Record Position"; Text[250])
        {
            Caption = 'Record Position';
            DataClassification = CustomerContent;
        }
        field(40; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
        field(50; Obsolete; Boolean)
        {
            Caption = 'Obsolete';
            DataClassification = CustomerContent;
        }
        field(60; "Data log Record No."; BigInteger)
        {
            Caption = 'Data log Record No.';
            TableRelation = "NPR Data Log Record";
            DataClassification = CustomerContent;
        }
        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(110; "PK Code 1"; Code[20])
        {
            Caption = 'Primary Key Code 1';
            DataClassification = CustomerContent;
        }
        field(111; "PK Code 2"; Code[20])
        {
            Caption = 'Primary Key Code 2';
            DataClassification = CustomerContent;
        }
        field(120; "PK Line 1"; Integer)
        {
            Caption = 'Primary Key Line 1';
            DataClassification = CustomerContent;
        }
        field(125; "PK Line 2"; Integer)
        {
            Caption = 'Primary Key Line 2';
            DataClassification = CustomerContent;
        }
        field(130; "PK Option 1"; Option)
        {
            Caption = 'Primary Key Option 1';
            InitValue = "20";
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20";
            DataClassification = CustomerContent;
        }
        field(140; "Date Created"; DateTime)
        {
            Caption = 'Date Created';
            DataClassification = CustomerContent;
        }
        field(200; "Query No."; BigInteger)
        {
            Caption = 'Query No.';
            Description = 'NPR5.25';
            TableRelation = "NPR Endpoint Query";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Endpoint Code", "Request Batch No.", "No.")
        {
        }
        key(Key3; "Request Batch No.", "No.")
        {
        }
        key(Key4; "Query No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Date Created" := CurrentDateTime;
    end;
}

