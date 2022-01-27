table 6151501 "NPR Nc Task Setup"
{
    Caption = 'Nc Task Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(6; "Table Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(11; "Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Codeunit ID")));
            Caption = 'Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059906; "Task Processor Code"; Code[20])
        {
            Caption = 'Task Processor Code';
            DataClassification = CustomerContent;
            Description = 'NC1.22,NC2.01';
            TableRelation = "NPR Nc Task Processor";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Table No.")
        {
            MaintainSIFTIndex = false;
        }
        key(Key3; "Task Processor Code", "Table No.", "Codeunit ID") { }
    }

    var
        TaskSetupAlreadyExistErr: Label 'NC Task Setup with %1: "%2", %3: "%4" and %5: "%6" already exist.', Comment = '%1 = Task Processor Code, %2 = Task Processor Code Value, %3 = Table No., %4 = Table No. Value, %5 = Codeunit ID, %6 = Codeunit ID Value';

    trigger OnInsert()
    begin
        "Entry No." := 0;
        if "Task Processor Code" = '' then
            "Task Processor Code" := 'nC';

        CheckForDuplicates();
        UpdateDataLogSubscriber("Task Processor Code", '', "Table No.");
    end;

    trigger OnModify()
    begin
        TestField("Task Processor Code");
        if (xRec."Table No." <> Rec."Table No.") or (xRec."Codeunit ID" <> Rec."Codeunit ID") or (xRec."Task Processor Code" <> Rec."Task Processor Code") then
            CheckForDuplicates();

        if xRec."Task Processor Code" <> "Task Processor Code" then
            UpdateDataLogSubscriber("Task Processor Code", xRec."Task Processor Code", "Table No.");
    end;

    procedure UpdateDataLogSubscriber(SubscriberCode: Code[30]; xRecSubscriberCode: Code[30]; TableNo: Integer)
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        DataLogSubscriber2: Record "NPR Data Log Subscriber";
        DataLogRecord: Record "NPR Data Log Record";
        LastLogEntryNo: BigInteger;
    begin
        if TableNo <= 0 then
            exit;
        if SubscriberCode = '' then
            exit;
        if DataLogSubscriber.Get(SubscriberCode, TableNo, '') then
            exit;

        if (xRecSubscriberCode <> '') and (xRecSubscriberCode <> SubscriberCode) and
            DataLogSubscriber2.Get(xRecSubscriberCode, TableNo, '') then begin
            LastLogEntryNo := DataLogSubscriber2."Last Log Entry No.";
            DataLogSubscriber2.Delete(true);
        end else begin
            Clear(DataLogRecord);
            DataLogRecord.SetCurrentKey("Table ID");
            DataLogRecord.SetRange("Table ID", TableNo);
            if DataLogRecord.FindLast() then;
            LastLogEntryNo := DataLogRecord."Entry No.";
        end;

        DataLogSubscriber.Init();
        DataLogSubscriber.Code := SubscriberCode;
        DataLogSubscriber."Table ID" := TableNo;
        DataLogSubscriber."Company Name" := '';
        DataLogSubscriber."Last Log Entry No." := LastLogEntryNo;
        DataLogSubscriber.Insert(true);
    end;

    local procedure CheckForDuplicates()
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
    begin
        if (Rec."Table No." = 0) or (Rec."Codeunit ID" = 0) or (Rec."Task Processor Code" = '') then
            exit;

        NcTaskSetup.SetRange("Table No.", Rec."Table No.");
        NcTaskSetup.SetRange("Codeunit ID", Rec."Codeunit ID");
        NcTaskSetup.SetRange("Task Processor Code", Rec."Task Processor Code");
        if not NcTaskSetup.IsEmpty() then
            Error(TaskSetupAlreadyExistErr, Rec.FieldCaption("Task Processor Code"), Rec."Task Processor Code", Rec.FieldCaption("Table No."), Rec."Table No.", Rec.FieldCaption("Codeunit ID"), Rec."Codeunit ID");
    end;
}

