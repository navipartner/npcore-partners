table 6059886 "NPR DE Data Export"
{
    Access = Internal;
    Caption = 'DE Data Export';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR DE Data Exports";
    LookupPageId = "NPR DE Data Export Card";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "TSS Code"; Code[10])
        {
            Caption = 'TSS Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR DE TSS";
            trigger OnValidate()
            var
                DETSS: Record "NPR DE TSS";
            begin
                if DETSS.Get("TSS Code") then
                    "TSS ID" := DETSS.SystemId
                else
                    Clear("TSS ID");
            end;
        }
        field(15; "TSS ID"; Guid)
        {
            Caption = 'TSS ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR DE TSS".SystemId;
            Editable = false;
            trigger OnValidate()
            var
                DETSS: Record "NPR DE TSS";
            begin
                if DETSS.GetBySystemId("TSS ID") then
                    "TSS Code" := DETSS."Code";
            end;
        }
        field(20; State; Enum "NPR DE Export State")
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(25; Exception; Enum "NPR DE Export Exception")
        {
            Caption = 'Exception';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "Time Request"; BigInteger)
        {
            Caption = 'Time Request';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(35; "Time Start"; BigInteger)
        {
            Caption = 'Time Start';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "Time End"; BigInteger)
        {
            Caption = 'Time End';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(45; "Time Expiration"; BigInteger)
        {
            Caption = 'Time Expiration';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Time Error"; BigInteger)
        {
            Caption = 'Time Error';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(55; "Estimated Time Of Completion"; BigInteger)
        {
            Caption = 'Estimated Time Of Completion';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Client ID"; Text[250])
        {
            Caption = 'Client ID';
            DataClassification = CustomerContent;
            ValidateTableRelation = false;
            TableRelation = "NPR DE POS Unit Aux. Info".SystemId where("TSS Code" = field("TSS Code"));
        }
        field(65; "Transaction Number"; Text[50])
        {
            Caption = 'Transaction Number';
            DataClassification = CustomerContent;
        }
        field(70; "Start Transaction Number"; Text[50])
        {
            Caption = 'Start Transaction Number';
            DataClassification = CustomerContent;
        }
        field(75; "End Transaction Number"; Text[50])
        {
            Caption = 'End Transaction Number';
            DataClassification = CustomerContent;
        }
        field(80; "Start Date"; BigInteger)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }
        field(85; "End Date"; BigInteger)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
        }
        field(90; "Maximum Number Records"; Integer)
        {
            Caption = 'Maximum Number Records';
            DataClassification = CustomerContent;
        }
        field(95; "Start Signature Counter"; Text[50])
        {
            Caption = 'Start Signature Counter';
            DataClassification = CustomerContent;
        }
        field(100; "End Signature Counter"; Text[50])
        {
            Caption = 'End Signature Counter';
            DataClassification = CustomerContent;
        }
        field(120; Environment; Text[20])
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
        }
        field(125; Version; Text[20])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TSS; "TSS Code", "TSS ID")
        {
        }
        key(State; State)
        {
        }
    }

    trigger OnInsert()
    begin
        "Entry No." := GetLastEntryNo() + 1;
        SystemId := CreateGuid();
    end;

    internal procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    internal procedure GetTimeRequestAsDateTime(): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if "Time Request" = 0 then
            exit(0DT);
        exit(TypeHelper.EvaluateUnixTimestamp("Time Request"));
    end;

    internal procedure GetTimeStartAsDateTime(): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if "Time Start" = 0 then
            exit(0DT);
        exit(TypeHelper.EvaluateUnixTimestamp("Time Start"));
    end;

    internal procedure GetTimeEndAsDateTime(): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if "Time End" = 0 then
            exit(0DT);
        exit(TypeHelper.EvaluateUnixTimestamp("Time End"));
    end;

    internal procedure GetTimeExpirationAsDateTime(): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if "Time Expiration" = 0 then
            exit(0DT);
        exit(TypeHelper.EvaluateUnixTimestamp("Time Expiration"));
    end;

    internal procedure GetTimeErrorAsDateTime(): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if "Time Error" = 0 then
            exit(0DT);
        exit(TypeHelper.EvaluateUnixTimestamp("Time Error"));
    end;

    internal procedure GetEstimatedTimeOfCompletionAsDateTime(): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if "Estimated Time Of Completion" = 0 then
            exit(0DT);
        exit(TypeHelper.EvaluateUnixTimestamp("Estimated Time Of Completion"));
    end;
}