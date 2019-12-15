table 6151528 "Nc Collection Line"
{
    // NC2.01\BR\20160909  CASE 250447 NaviConnect: Object created

    Caption = 'Nc Collection Line';
    DrillDownPageID = "Nc Collection Lines";
    LookupPageID = "Nc Collection Lines";

    fields
    {
        field(1;"No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'No.';
        }
        field(10;"Collector Code";Code[20])
        {
            Caption = 'Collector Code';
            TableRelation = "Nc Collector";
        }
        field(20;"Collection No.";BigInteger)
        {
            Caption = 'Collection No.';
            TableRelation = "Nc Collection";
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
            Caption = 'PK Code 1';
        }
        field(111;"PK Code 2";Code[20])
        {
            Caption = 'PK Code 2';
        }
        field(120;"PK Line 1";Integer)
        {
            Caption = 'PK Line 1';
        }
        field(125;"PK Line 2";Integer)
        {
            Caption = 'PK Line 2';
        }
        field(130;"PK Option 1";Option)
        {
            Caption = 'PK Option 1';
            InitValue = "20";
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20";
        }
        field(140;"Date Created";DateTime)
        {
            Caption = 'Date Created';
        }
        field(200;"Request No.";BigInteger)
        {
            Caption = 'Request No.';
            TableRelation = "Nc Collector Request";
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Collector Code","Collection No.","No.")
        {
        }
        key(Key3;"Collection No.","No.")
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

