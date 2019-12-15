table 6059897 "Data Log Setup (Table)"
{
    // DL1.00/MH/20140801  NP-AddOn: Data Log
    //   - This Table contains Setup information of which Record Changes to log.

    Caption = 'Data Log Setup (Table)';

    fields
    {
        field(1;"Table ID";Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(2;"Table Name";Text[30])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Table),
                                                                           "Object ID"=FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(3;"Log Insertion";Option)
        {
            Caption = 'Log Insertion';
            OptionCaption = ' ,Simple,Detailed';
            OptionMembers = " ",Simple,Detailed;
        }
        field(4;"Log Modification";Option)
        {
            Caption = 'Log Modification';
            OptionCaption = ' ,Simple,Detailed,Changes';
            OptionMembers = " ",Simple,Detailed,Changes;
        }
        field(5;"Log Deletion";Option)
        {
            Caption = 'Log Deletion';
            OptionCaption = ' ,Simple,Detailed';
            OptionMembers = " ",Simple,Detailed;
        }
        field(10;"Keep Log for";Duration)
        {
            Caption = 'Keep Log For';
        }
        field(110;"User ID";Code[250])
        {
            Caption = 'User ID';
            Editable = false;
        }
        field(120;"Last Date Modified";DateTime)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"Table ID")
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
        DataLogMgt: Codeunit "Data Log Management";

    procedure InsertNewTable(TableID: Integer;LogInsertion: Option " ",Simple,Detailed;LogModification: Option " ",Simple,Detailed;LogDeletion: Option " ",Simple,Detailed)
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

