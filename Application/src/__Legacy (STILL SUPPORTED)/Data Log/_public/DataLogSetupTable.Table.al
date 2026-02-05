table 6059897 "NPR Data Log Setup (Table)"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Public;
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

            trigger OnValidate()
            var
                JobQueueManagement: Codeunit "NPR Job Queue Management";
                MustNotBeNegativeErr: Label 'must be equal to or greater than 0';
                MustNotExceed90DErr: Label 'cannot exceed 90 days';
            begin
                if "Keep Log for" < 0 then
                    FieldError("Keep Log for", MustNotBeNegativeErr);
                if "Keep Log for" = 0 then
                    exit;
                if "Keep Log for" > JobQueueManagement.DaysToDuration(90) then
                    FieldError("Keep Log for", MustNotExceed90DErr);
            end;
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

        HandleDataLogSetupIgnoreFields();
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

    local procedure HandleDataLogSetupIgnoreFields()
    var
        Item: Record Item;
        ILE: Record "Item Ledger Entry";
        Contact: Record Contact;
    begin
        case Rec."Table ID" of
            Database::Item:
                begin
                    InsertDataLogSetupIgnoreField(Database::Item, Item.FieldNo("Cost is Adjusted"));
                    InsertDataLogSetupIgnoreField(Database::Item, Item.FieldNo("Allow Online Adjustment"));
                    InsertDataLogSetupIgnoreField(Database::Item, Item.FieldNo("Last DateTime Modified"));
                    InsertDataLogSetupIgnoreField(Database::Item, Item.FieldNo("Last Date Modified"));
                    InsertDataLogSetupIgnoreField(Database::Item, Item.FieldNo("Last Time Modified"));
                end;
            Database::"Item Ledger Entry":
                InsertDataLogSetupIgnoreField(Database::"Item Ledger Entry", Ile.FieldNo("Applied Entry to Adjust"));
            Database::Contact:
                InsertDataLogSetupIgnoreField(Database::Contact, Contact.FieldNo("Last Time Modified"));
        end;
    end;

    local procedure InsertDataLogSetupIgnoreField(TableId: Integer; FieldNo: Integer)
    var
        DataLogSetupField: Record "NPR Data Log Setup (Field)";
    begin
        DataLogSetupField.SetRange("Table ID", TableId);
        DataLogSetupField.SetRange("Field No.", FieldNo);
        if not DataLogSetupField.IsEmpty() then
            exit;

        DataLogSetupField.Init();
        DataLogSetupField."Table ID" := TableId;
        DataLogSetupField."Ignore Modification" := true;
        DataLogSetupField."Field No." := FieldNo;
        DataLogSetupField.Insert();
    end;
}
