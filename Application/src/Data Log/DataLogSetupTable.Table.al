table 6059897 "NPR Data Log Setup (Table)"
{
    //This Table contains Setup information of which Record Changes to log.

    Caption = 'Data Log Setup (Table)';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(2; "Table Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table), "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
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
        field(20; "Ignored Fields"; Integer)
        {
            Caption = 'Ignored Fields';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR Data Log Setup (Field)" where("Table ID" = field("Table ID")));
        }
        field(110; "User ID"; Code[250])
        {
            Caption = 'User ID';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
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
        "User ID" := CopyStr(UserId, 1, MaxStrLen("User ID"));
        "Last Date Modified" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "User ID" := CopyStr(UserId, 1, MaxStrLen("User ID"));
        "Last Date Modified" := CurrentDateTime;
    end;

    trigger OnDelete()
    var
        DataLogSetupField: Record "NPR Data Log Setup (Field)";
    begin
        DataLogSetupField.SetRange("Table ID", "Table ID");
        if not DataLogSetupField.IsEmpty then
            DataLogSetupField.DeleteAll();
    end;


    procedure InsertNewTable(TableID: Integer; LogInsertion: Option " ",Simple,Detailed; LogModification: Option " ",Simple,Detailed; LogDeletion: Option " ",Simple,Detailed)
    begin
        if Get(TableID) then
            exit;

        Init();
        "Table ID" := TableID;
        "Log Insertion" := LogInsertion;
        "Log Modification" := LogModification;
        "Log Deletion" := LogDeletion;
        "Keep Log for" := 1000 * 60 * 60 * 24 * 7;
        Insert(true);
    end;
}
