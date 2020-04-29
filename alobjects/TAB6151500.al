table 6151500 "Nc Setup"
{
    // NC1.01/MH/20150201  CASE 199932 Object Created
    // NC1.03/TS/20150202  CASE 201682 Added fields related to Gift Voucher
    // NC1.04/TS/20150206  CASE 201682 Added more fields related to Gift Voucher
    // NC1.04/MH/20150206  CASE 199932 Added field 20020 Variant System
    // NC1.05/MH/20150223  CASE 206395 Added B2B Fields and Renumbered field 22061 "Gift Voucher Activated"
    // NC1.05/TS/20150223  CASE 201682 Added Credit Voucher field
    // NC1.06/TS/20150224  CASE 201682 Added Credit Voucher Bitmap
    // NC1.07/TS/20150309  CASE 208236 Removed  Gift Voucher No.Series Management
    // NC1.09/MH/20150313  CASE 208758 Added function GetNpXmlAPIUsername() and fields NpXml Setup Fields
    // NC1.10/TS/20150317  CASE 208237 Added Field Customer Template Code
    // NC1.11/MH/20150325  CASE 209616 Replaced ServerInstance Name with Database Name in automatic Username
    //                                 Added field 30000 Task Worker Enabled
    //                                 Moved field 10010 NpXml Task Worker Group to 30010 Task Worker Group
    // NC1.12/MH/20150407  CASE 210712 Updated captions and field names
    // NC1.12/TS/20150407  CASE 210753 Added Credit Voucher Language Code
    // NC1.13/MH/20150409  CASE 211043 Added field 140 Salesperson Code
    // NC1.16/TS/20150423  CASE 212103 Added fields - 200 Order Import Codeunit Id
    //                                              - 205 Return Order Codeunit Id
    //                                              - 210 Contact Import Codeunit Id
    // NC1.16/TR/20150424  CASE 210960 Added Variety to field option on field 20020
    // NC1.16/TS/20150429  CASE 195494 Added fields related to Navidocs
    // NC1.17/MH/20150622  CASE 216851 Magento and NpXml related fields moved to new setup tables and renumbered the following fields:
    //                                 - 22070 Customer Template Code --> 115
    //                                 - 30000 Task Queue Enabled --> 300
    //                                 - 30010 Task Worker Group --> 305
    // NC1.21/TS/20151014  CASE 225075 Added field 310 Max Task Count per Batch
    // NC1.21/TTH/20151118 CASE 227358 Changed the naming of fields 200 and 205, removed field 210 and 400-425
    // NC1.22/MHA/20151202  CASE 227358 Removed Automatic SetupNaviConnect() in OnInsert()
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NPR5.48/TJ/20190128 CASE 340446 Function not used

    Caption = 'Nc Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Keep Tasks for";Duration)
        {
            Caption = 'Keep Tasks for';
        }
        field(300;"Task Queue Enabled";Boolean)
        {
            Caption = 'Task Queue Enabled';
            Description = 'NC1.11,NC1.12,NC1.16,NC1.17';
            TableRelation = "Task Worker Group";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(305;"Task Worker Group";Code[10])
        {
            Caption = 'Task Worker Group';
            Description = 'NC1.09,NC1.11,NC1.12,NC1.17';
            TableRelation = "Task Worker Group";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(310;"Max Task Count per Batch";Integer)
        {
            Caption = 'Max Task Count per batch';
            Description = 'NC1.21';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
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
        NaviConnectMgt: Codeunit "Nc Setup Mgt.";

    procedure InsertNaviconnectTaskSetup(TableNo: Integer)
    var
        NaviConnectTaskSetup: Record "Nc Task Setup";
        DataLogSetup: Record "Data Log Setup (Table)";
        DataLogSubscriber: Record "Data Log Subscriber";
        NpXmlTemplate: Record "NpXml Template";
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

