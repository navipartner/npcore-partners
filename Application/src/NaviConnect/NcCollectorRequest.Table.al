table 6151529 "NPR Nc Collector Request"
{
    Access = Internal;
    Caption = 'Nc Collector Request';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'NC Collector module removed from NpCore. We switched to Job Queue instead of using Task Queue.';

    fields
    {
        field(1; "No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; Direction; Option)
        {
            Caption = 'Direction';
            DataClassification = CustomerContent;
            OptionCaption = 'Incoming,Outgoing';
            OptionMembers = Incoming,Outgoing;
        }
        field(5; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; "Collector Code"; Code[20])
        {
            Caption = 'Collector Code';
            DataClassification = CustomerContent;
        }
        field(30; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'New,Processed,Rejected';
            OptionMembers = New,Processed,Rejected;
        }
        field(40; "Creation Date"; DateTime)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(50; "Processed Date"; DateTime)
        {
            Caption = 'Processed Date';
            DataClassification = CustomerContent;
        }
        field(100; "Database Name"; Text[250])
        {
            Caption = 'Database Name';
            DataClassification = CustomerContent;
        }
        field(120; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(130; "User ID"; Text[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(150; "Processing Comment"; Text[250])
        {
            Caption = 'Processing Comment';
            DataClassification = CustomerContent;
        }
        field(160; "External No."; BigInteger)
        {
            Caption = 'External No.';
            DataClassification = CustomerContent;
        }
        field(170; "Only New and Modified Records"; Boolean)
        {
            Caption = 'Only New and Modified Records';
            DataClassification = CustomerContent;
        }
        field(200; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(205; "Table View"; Text[250])
        {
            Caption = 'Table View';
            DataClassification = CustomerContent;
        }
        field(210; "Table Filter"; TableFilter)
        {
            Caption = 'Table Filter';
            DataClassification = CustomerContent;
        }
        field(220; "Table Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }
}

