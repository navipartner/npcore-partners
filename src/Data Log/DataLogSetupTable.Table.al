table 6059897 "NPR Data Log Setup (Table)"
{
    // DL1.00/MHA /20140801  NP-AddOn: Data Log
    //   - This Table contains Setup information of which Record Changes to log.
    // DL1.16/MHA /20191127  Extended length of field 2 "Table Name" from 30 to 250

    Caption = 'Data Log Setup (Table)';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
            DataClassification = CustomerContent;
        }
        field(2; "Table Name"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Description = 'DL1.16';
            Editable = false;
            FieldClass = FlowField;
        }
        field(3; "Log Insertion"; Option)
        {
            Caption = 'Log Insertion';
            OptionCaption = ' ,Simple,Detailed';
            OptionMembers = " ",Simple,Detailed;
            DataClassification = CustomerContent;
        }
        field(4; "Log Modification"; Option)
        {
            Caption = 'Log Modification';
            OptionCaption = ' ,Simple,Detailed,Changes';
            OptionMembers = " ",Simple,Detailed,Changes;
            DataClassification = CustomerContent;
        }
        field(5; "Log Deletion"; Option)
        {
            Caption = 'Log Deletion';
            OptionCaption = ' ,Simple,Detailed';
            OptionMembers = " ",Simple,Detailed;
            DataClassification = CustomerContent;
        }
        field(10; "Keep Log for"; Duration)
        {
            Caption = 'Keep Log For';
            DataClassification = CustomerContent;
        }
        field(110; "User ID"; Code[250])
        {
            Caption = 'User ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(120; "Last Date Modified"; DateTime)
        {
            Caption = 'Last Date Modified';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "User ID" := UserId;
        "Last Date Modified" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "User ID" := UserId;
        "Last Date Modified" := CurrentDateTime;
    end;

    var
        DataLogMgt: Codeunit "NPR Data Log Management";

    procedure InsertNewTable(TableID: Integer; LogInsertion: Option " ",Simple,Detailed; LogModification: Option " ",Simple,Detailed; LogDeletion: Option " ",Simple,Detailed)
    var
        Dec: Decimal;
    begin
        if Get(TableID) then
            exit;

        Init;
        "Table ID" := TableID;
        "Log Insertion" := LogInsertion;
        "Log Modification" := LogModification;
        "Log Deletion" := LogDeletion;
        "Keep Log for" := 1000 * 60 * 60 * 24 * 7;
        Insert(true);
    end;
}

