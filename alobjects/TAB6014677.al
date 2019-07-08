table 6014677 "Endpoint Request"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created
    // NPR5.25\BR\20160801  CASE 234602 Added Field Query No.
    // NPR5.48/JDH /20181109 CASE 334163 Added Captions, and changed caption "PK" to "Primary Key"

    Caption = 'Endpoint Request';
    DrillDownPageID = "Endpoint Request List";
    LookupPageID = "Endpoint Request List";

    fields
    {
        field(1;"No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'No.';
        }
        field(10;"Endpoint Code";Code[20])
        {
            Caption = 'Endpoint Code';
            TableRelation = Endpoint;
        }
        field(20;"Request Batch No.";BigInteger)
        {
            Caption = 'Request Batch No.';
            TableRelation = "Endpoint Request Batch";
        }
        field(30;"Type of Change";Option)
        {
            Caption = 'Type of Change';
            OptionCaption = 'Insert,Modify,Rename,Delete';
            OptionMembers = Insert,Modify,Rename,Delete;
        }
        field(35;"Record Position";Text[250])
        {
            Caption = 'Record Position';
        }
        field(40;"Record ID";RecordID)
        {
            Caption = 'Record ID';
        }
        field(50;Obsolete;Boolean)
        {
            Caption = 'Obsolete';
        }
        field(60;"Data log Record No.";BigInteger)
        {
            Caption = 'Data log Record No.';
            TableRelation = "Data Log Record";
        }
        field(100;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(110;"PK Code 1";Code[20])
        {
            Caption = 'Primary Key Code 1';
        }
        field(111;"PK Code 2";Code[20])
        {
            Caption = 'Primary Key Code 2';
        }
        field(120;"PK Line 1";Integer)
        {
            Caption = 'Primary Key Line 1';
        }
        field(125;"PK Line 2";Integer)
        {
            Caption = 'Primary Key Line 2';
        }
        field(130;"PK Option 1";Option)
        {
            Caption = 'Primary Key Option 1';
            InitValue = "20";
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20";
        }
        field(140;"Date Created";DateTime)
        {
            Caption = 'Date Created';
        }
        field(200;"Query No.";BigInteger)
        {
            Caption = 'Query No.';
            Description = 'NPR5.25';
            TableRelation = "Endpoint Query";
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Endpoint Code","Request Batch No.","No.")
        {
        }
        key(Key3;"Request Batch No.","No.")
        {
        }
        key(Key4;"Query No.")
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

