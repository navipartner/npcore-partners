table 6151528 "NPR Nc Collection Line"
{
    Access = Internal;
    Caption = 'Nc Collection Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Nc Collection Lines";
    LookupPageID = "NPR Nc Collection Lines";

    fields
    {
        field(1; "No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(10; "Collector Code"; Code[20])
        {
            Caption = 'Collector Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Collector";
        }
        field(20; "Collection No."; BigInteger)
        {
            Caption = 'Collection No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Collection";
        }
        field(30; "Type of Change"; Option)
        {
            Caption = 'Type of Change';
            DataClassification = CustomerContent;
            OptionCaption = 'Insert,Modify,Rename,Delete';
            OptionMembers = Insert,Modify,Rename,Delete;
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
            DataClassification = CustomerContent;
            TableRelation = "NPR Data Log Record";
        }
        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(110; "PK Code 1"; Code[20])
        {
            Caption = 'PK Code 1';
            DataClassification = CustomerContent;
        }
        field(111; "PK Code 2"; Code[20])
        {
            Caption = 'PK Code 2';
            DataClassification = CustomerContent;
        }
        field(120; "PK Line 1"; Integer)
        {
            Caption = 'PK Line 1';
            DataClassification = CustomerContent;
        }
        field(125; "PK Line 2"; Integer)
        {
            Caption = 'PK Line 2';
            DataClassification = CustomerContent;
        }
        field(130; "PK Option 1"; Option)
        {
            Caption = 'PK Option 1';
            DataClassification = CustomerContent;
            InitValue = "20";
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20";
        }
        field(140; "Date Created"; DateTime)
        {
            Caption = 'Date Created';
            DataClassification = CustomerContent;
        }
        field(200; "Request No."; BigInteger)
        {
            Caption = 'Request No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Collector Request";
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Collector Code", "Collection No.", "No.")
        {
        }
        key(Key3; "Collection No.", "No.")
        {
        }
    }

    trigger OnInsert()
    begin
        "Date Created" := CurrentDateTime();
    end;
}

