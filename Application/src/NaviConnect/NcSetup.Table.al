table 6151500 "NPR Nc Setup"
{
    Caption = 'Nc Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Keep Tasks for"; Duration)
        {
            Caption = 'Keep Tasks for';
            DataClassification = CustomerContent;
        }
        field(300; "Task Queue Enabled"; Boolean)
        {
            Caption = 'Task Queue Enabled';
            DataClassification = CustomerContent;
            Description = 'NC1.11,NC1.12,NC1.16,NC1.17';
            TableRelation = "NPR Task Worker Group";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(305; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            DataClassification = CustomerContent;
            Description = 'NC1.09,NC1.11,NC1.12,NC1.17';
            TableRelation = "NPR Task Worker Group";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(310; "Max Task Count per Batch"; Integer)
        {
            Caption = 'Max Task Count per batch';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        //-NC1.22
        //NaviConnectMgt.SetupNaviConnect();v
        //+NC1.22
    end;

    trigger OnModify()
    begin
        //-NC1.21
        //IF xRec."Task Queue Enabled" <> "Task Queue Enabled" THEN
        //  NaviConnectMgt.SetupNaviConnect();
        //+NC1.21
    end;

    var
        NaviConnectMgt: Codeunit "NPR Nc Setup Mgt.";

    procedure InsertNaviconnectTaskSetup(TableNo: Integer)
    var
        NaviConnectTaskSetup: Record "NPR Nc Task Setup";
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        //-NPR5.48 [340446]
        /*
        NaviConnectTaskSetup.SETRANGE("Table No.",TableNo);
        NaviConnectTaskSetup.SETRANGE("Codeunit ID",CODEUNIT::"NaviDocs Management");
        NaviConnectTaskSetup.SETRANGE("Task Processor Code",'NC');
        IF NOT NaviConnectTaskSetup.FINDFIRST THEN BEGIN
          NaviConnectTaskSetup.INIT;
          NaviConnectTaskSetup."Entry No." := 0;
          NaviConnectTaskSetup."Table No." := TableNo;
          NaviConnectTaskSetup."Codeunit ID" := CODEUNIT::"NaviDocs Management";
          NaviConnectTaskSetup."Task Processor Code" := 'NC';
          NaviConnectTaskSetup.INSERT(TRUE);
        END;
        
        IF NOT DataLogSetup.GET(TableNo) THEN BEGIN
          DataLogSetup.INIT;
          DataLogSetup."Table ID" := TableNo;
          DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
          DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Changes;
          DataLogSetup."Log Deletion" := DataLogSetup."Log Deletion"::Detailed;
          DataLogSetup."Keep Log for" := 1000 * 60;
          DataLogSetup.INSERT(TRUE);
        END;
        
        IF NOT DataLogSubscriber.GET('NC',TableNo) THEN BEGIN
          DataLogSubscriber.INIT;
          DataLogSubscriber.Code := 'NC';
          DataLogSubscriber."Table ID" := TableNo;
          DataLogSubscriber.INSERT(TRUE);
        END;
        */
        //+NPR5.48 [340446]

    end;
}

