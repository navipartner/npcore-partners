table 6151501 "Nc Task Setup"
{
    // NC1.00/MH/20150113  CASE 199932 Refactored object from Web Integration
    // NC1.22/MHA/20160125 CASE 232733 Task Queue Worker Group replaced by NaviConnect Task Processor
    // NC1.22/MHA/20160216 CASE 226995 Removed DeleteDataLogSubscriber() as cleanup should be performed manually if needed
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NC2.01/MHA/20160905 CASE 242551 Length of field 6059906 Task Processor Code increased from 10 to 20
    // NC2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Nc Task Setup';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            Editable = false;
        }
        field(5;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(6;"Table Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10;"Codeunit ID";Integer)
        {
            Caption = 'Codeunit ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(11;"Codeunit Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Codeunit ID")));
            Caption = 'Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059906;"Task Processor Code";Code[20])
        {
            Caption = 'Task Processor Code';
            Description = 'NC1.22,NC2.01';
            TableRelation = "Nc Task Processor";
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Table No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //-NC1.22
        //DeleteDataLogSubscriber("Task Processor Code","Table No.");
        //+NC1.22
    end;

    trigger OnInsert()
    begin
        "Entry No." := 0;
        //-NC1.22
        if "Task Processor Code" = '' then
          "Task Processor Code" := 'nC';
        //+NC1.22
        UpdateDataLogSubscriber("Task Processor Code",'',"Table No.");
    end;

    trigger OnModify()
    begin
        //-NC1.22
        TestField("Task Processor Code");
        //+NC1.22
        if xRec."Task Processor Code" <> "Task Processor Code" then
          UpdateDataLogSubscriber("Task Processor Code",xRec."Task Processor Code","Table No.");
    end;

    procedure DeleteDataLogSubscriber(SubscriberCode: Code[30];TableNo: Integer)
    var
        DataLogSubscriber: Record "Data Log Subscriber";
    begin
        if SubscriberCode = '' then
          exit;
        //-NC1.22
        //IF DataLogSubscriber.GET(SubscriberCode,TableNo) THEN
        if DataLogSubscriber.Get(SubscriberCode,TableNo,'') then
        //+NC1.22
          DataLogSubscriber.Delete(true);
    end;

    procedure UpdateDataLogSubscriber(SubscriberCode: Code[30];xRecSubscriberCode: Code[30];TableNo: Integer)
    var
        DataLogSubscriber: Record "Data Log Subscriber";
        DataLogSubscriber2: Record "Data Log Subscriber";
        DataLogRecord: Record "Data Log Record";
        LastLogEntryNo: BigInteger;
    begin
        if TableNo <= 0 then
          exit;
        if SubscriberCode = '' then
          exit;
        //-NC1.22
        //IF DataLogSubscriber.GET(SubscriberCode,TableNo) THEN
        if DataLogSubscriber.Get(SubscriberCode,TableNo,'') then
        //+NC1.22
          exit;

        if (xRecSubscriberCode <> '') and (xRecSubscriberCode <> SubscriberCode) and
            //-NC1.22
            //DataLogSubscriber2.GET(xRecSubscriberCode,TableNo) THEN BEGIN
            DataLogSubscriber2.Get(xRecSubscriberCode,TableNo,'') then begin
            //+NC1.22
          LastLogEntryNo := DataLogSubscriber2."Last Log Entry No.";
          DataLogSubscriber2.Delete(true);
        end else begin
          Clear(DataLogRecord);
          DataLogRecord.SetRange("Table ID",TableNo);
          if DataLogRecord.FindLast then;
          LastLogEntryNo := DataLogRecord."Entry No.";
        end;

        DataLogSubscriber.Init;
        DataLogSubscriber.Code := SubscriberCode;
        DataLogSubscriber."Table ID" := TableNo;
        //-NC1.22
        DataLogSubscriber."Company Name" := '';
        //+NC1.22
        DataLogSubscriber."Last Log Entry No." := LastLogEntryNo;
        DataLogSubscriber.Insert(true);
    end;
}

