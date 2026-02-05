table 6059896 "NPR Data Log Subscriber"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Public;
    Caption = 'Data Log Subscriber';
    DrillDownPageID = "NPR Data Log Subscribers";
    LookupPageID = "NPR Data Log Subscribers";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[30])
        {
            Caption = 'Code';
            Description = 'DL1.07';
            DataClassification = CustomerContent;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(3; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            Description = 'DL1.10';
            TableRelation = Company;
            DataClassification = CustomerContent;
        }
        field(5; "Table Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Last Log Entry No."; BigInteger)
        {
            Caption = 'Last Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(100; "Direct Data Processing"; Boolean)
        {
            Caption = 'Direct Data Processing';
            Description = 'DL1.01';
            DataClassification = CustomerContent;
        }
        field(110; "Data Processing Codeunit ID"; Integer)
        {
            Caption = 'Data Processing Codeunit ID';
            Description = 'DL1.01';
            DataClassification = CustomerContent;
        }
        field(115; "Data Processing Codeunit Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Codeunit),
                                                                           "Object ID" = FIELD("Data Processing Codeunit ID")));
            Caption = 'Data Processing Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Last Date Modified"; DateTime)
        {
            Caption = 'Last Date Modified';
            Description = 'DL1.03';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(130; "Delayed Data Processing (sec)"; Integer)
        {
            Caption = 'Delayed Data Processing (sec)';
            Description = '#416503';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(140; "Failure Codeunit ID"; Integer)
        {
            Caption = 'Failure Codeunit ID';
            BlankZero = true;
            DataClassification = CustomerContent;
        }
        field(150; "Failure Codeunit Caption"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Codeunit),
                                                                           "Object ID" = FIELD("Failure Codeunit ID")));
            Caption = 'Failure Codeunit Caption';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code", "Table ID", "Company Name")
        {
        }
        key(Key2; "Last Log Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure AddAsSubscriber(SubscriberCode: Code[30]; TableNo: Integer)
    begin
        if Get(SubscriberCode, TableNo) then
            exit;

        Init();
        Code := SubscriberCode;
        "Table ID" := TableNo;
        "Last Log Entry No." := 0;
        Insert();
    end;

    internal procedure IsEnabled(): Boolean
    var
        DataLogSubMgt: Codeunit "NPR Data Log Sub. Mgt.";
        SubscriberEnabled: Boolean;
    begin
        SubscriberEnabled := true;
        DataLogSubMgt.OnCheckIfDataLogSubscriberIsEnabled(Rec, SubscriberEnabled);
        exit(SubscriberEnabled);
    end;
}
