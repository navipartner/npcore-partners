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

    trigger OnInsert()
    begin
        "Entry No." := 0;
        if "Task Processor Code" = '' then
            "Task Processor Code" := 'nC';
        UpdateDataLogSubscriber("Task Processor Code", '', "Table No.");
    end;

    trigger OnModify()
    begin
        TestField("Task Processor Code");
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
}

