table 6151551 "NpXml Template"
{
    // NC1.00 /MHA /20150113  CASE 199932 Refactored object from Web - XML
    // NC1.01 /MHA /20150201  CASE 199932 Removed field 1010 "Transaction Trigger". Template Triggers are used instead
    // NC1.05 /MHA /20150219  CASE 206395 Removed field 7 "Xml Element Name". Obsolete as NpXml Elements defines the Xml Schema
    // NC1.07 /MHA /20150309  CASE 208131 Updated captions
    // NC1.08 /MHA /20150311  CASE 206395 Added manual Renamed of related records and Renamed fields:
    //                                 - Field 5100 "FTP File Transfer" to "FTP Transfer"
    //                                 - Field 5200 "API File Transfer" to "API Transfer"
    // NC1.09 /MHA /20150313  CASE 208758 Added Field 5219 "API Username Type" and function GetAPIUsername()
    // NC1.11 /MHA /20150325  CASE 209616 Replaced ServerInstance Name with Database Name in automatic Username
    // NC1.21 /TTH /20151020  CASE 224528 Adding versioning and possibility to lock the modified versions.
    // NC1.21 /TTH /20151026  CASE 225078 Changed Template Renaming to inserting new records and deleting the old ones.
    // NC1.22 /MHA /20151203  CASE 224528 Deleted function XmlTemplateChanged() and InitTemplateVersion. Created function InitVersion()
    // NC1.22 /MHA /20151211  CASE 229473 Updated Automatic Username functionality
    // NC1.22 /MHA /20160125  CASE 239371 Task Queue Worker Group replaced by NaviConnect Task Processor
    // NC1.22 /MHA /20160429  CASE 237658 NpXml extended with Namespaces
    // NC2.00 /MHA /20160525  CASE 240005 NaviConnect
    // NC2.01 /MHA /20160905  CASE 242551 Length of field 6059906 Task Processor Code increased from 10 to 20 and added field 5254 API Reponse Success Path
    // NC2.01 /MHA /20161212  CASE 260498 Added Api Request Header fields
    // NC2.03 /MHA /20170316  CASE 268788 Field 5285 Renamed from "API SOAP Namespace" to "Root Namespace"
    // NC2.03 /MHA /20170324  CASE 267094 Added fields: 4900 "Before Transfer Codeunit ID",4905 "Before Transfer Codeunit Name",4910 "Before Transfer Function"
    // NC2.05 /MHA /20170615  CASE 265609 Added option to field 5270 "Api Type": REST (Json)
    // NC2.06 /MHA /20170927  CASE 265779 Added Api Headers
    // NC2.08 /THRO/20171124  CASE 297308 Added "JSON Root is Array", removed field 100 "Xml Schema Validation" and 110 "Xml Schema"
    // NC2.08 /MHA /20171206  CASE 265541 Added field 5405 "Use JSON Numbers"
    // NC2.11 /MHA /20180319  CASE 308403 Updated Hardcoded Dates with DMY2DATE to be Culture neutral in UpdateNaviConnectSetup()
    // NC2.17/JDH /20181112 CASE 334163 Added Caption to fields 5310, 5315, 5320, 5400 and 5405

    Caption = 'NpXml Template';
    DrillDownPageID = "NpXml Template List";
    LookupPageID = "NpXml Template List";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;"Xml Root Name";Text[50])
        {
            Caption = 'Xml Root Name';
            Description = 'Root tag in xml file,NC1.07';
        }
        field(10;"Table No.";Integer)
        {
            Caption = 'Table No.';
            Description = 'Table to Export';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(20;"Template Version";Code[20])
        {
            Caption = 'Version';
            Description = 'NC1.21';
        }
        field(30;"Namespaces Enabled";Boolean)
        {
            Caption = 'Namespaces Enabled';
            Description = 'NC1.22';
        }
        field(1000;"Transaction Task";Boolean)
        {
            Caption = 'Transaction Task';
            Description = 'NaviConnect Task';
        }
        field(1010;"Disable Auto Task Setup";Boolean)
        {
            Caption = 'Disable Auto Task Setup';
            Description = 'NC2.00';
        }
        field(2000;"Batch Task";Boolean)
        {
            Caption = 'Batch Task';
            Description = 'Run by NAS';
        }
        field(2010;"Batch Active From";DateTime)
        {
            Caption = 'Batch Active From';
            Description = 'Earliest run - value required before run';
        }
        field(2020;"Batch Interval (Days)";Integer)
        {
            Caption = 'Batch Interval (Days)';
            Description = 'Next run - Days';
        }
        field(2025;"Batch Interval (Minutes)";Integer)
        {
            Caption = 'Batch Interval (Minutes)';
            Description = 'Next run - Minutes';
        }
        field(2030;"Batch Start Time";Time)
        {
            Caption = 'Batch Start Time';
            Description = 'Next run - Specific time (Overwrites "Batch Interval (Minutes)")';
        }
        field(2040;"Batch End Time";Time)
        {
            Caption = 'Batch End Time';
        }
        field(2100;"Batch Last Run";DateTime)
        {
            Caption = 'Batch Last Run';
            Description = 'Last execution datetime';
        }
        field(2110;"Next Batch Run";DateTime)
        {
            Caption = 'Next Batch Run';
            Description = 'Earliest next run';
        }
        field(2200;"Max Records per File";Integer)
        {
            Caption = 'Max qty. records per XML File';
            Description = 'NC1.07';
        }
        field(3000;"Runtime Error";Boolean)
        {
            Caption = 'Runtime Error';
        }
        field(3010;"Last Error Message";Text[250])
        {
            Caption = 'Last Error Message';
        }
        field(4900;"Before Transfer Codeunit ID";Integer)
        {
            BlankZero = true;
            Caption = 'Before Transfer Codeunit ID';
            Description = 'NC2.03';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //+NC2.03 [267094]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpXml Mgt.");
                EventSubscription.SetRange("Published Function",'OnBeforeTransferXml');
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Before Transfer Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Before Transfer Function" := EventSubscription."Subscriber Function";
                //+NC2.03 [267094]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NC2.03 [267094]
                if "Before Transfer Codeunit ID" = 0 then begin
                  "Before Transfer Function" := '';
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpXml Mgt.");
                EventSubscription.SetRange("Published Function",'OnBeforeTransferXml');
                EventSubscription.SetRange("Subscriber Codeunit ID","Before Transfer Codeunit ID");
                if "Before Transfer Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Before Transfer Function");
                EventSubscription.FindFirst;
                //-267094 [267094]
            end;
        }
        field(4905;"Before Transfer Codeunit Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Before Transfer Codeunit ID")));
            Caption = 'Before Transfer Codeunit Name';
            Description = 'NC2.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4910;"Before Transfer Function";Text[80])
        {
            Caption = 'Before Transfer Function';
            Description = 'NC2.03';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NC2.03 [267094]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpXml Mgt.");
                EventSubscription.SetRange("Published Function",'OnBeforeTransferXml');
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Before Transfer Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Before Transfer Function" := EventSubscription."Subscriber Function";
                //+NC2.03 [267094]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NC2.03 [267094]
                if "Before Transfer Function" = '' then begin
                  "Before Transfer Codeunit ID" := 0;
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpXml Mgt.");
                EventSubscription.SetRange("Published Function",'OnBeforeTransferXml');
                EventSubscription.SetRange("Subscriber Codeunit ID","Before Transfer Codeunit ID");
                if "Before Transfer Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Before Transfer Function");
                EventSubscription.FindFirst;
                //+NC2.03 [267094]
            end;
        }
        field(4990;"File Transfer";Boolean)
        {
            Caption = 'File Transfer';
        }
        field(5000;"File Path";Text[250])
        {
            Caption = 'File Path';

            trigger OnValidate()
            var
                Valid: Boolean;
            begin
                if "File Path" <> '' then begin
                  if "File Path"[StrLen("File Path")] = '\' then begin
                    if StrLen("File Path") = 1 then
                      "File Path" := ''
                    else
                      "File Path" := CopyStr("File Path",1,StrLen("File Path") - 1);
                  end;
                end;
            end;
        }
        field(5100;"FTP Transfer";Boolean)
        {
            Caption = 'FTP Transfer';
            Description = 'NC1.08';
        }
        field(5110;"FTP Server";Text[250])
        {
            Caption = 'FTP Server';
        }
        field(5120;"FTP Username";Text[100])
        {
            Caption = 'FTP Username';
            Description = 'NC1.21';
        }
        field(5130;"FTP Password";Text[100])
        {
            Caption = 'FTP Password';
            Description = 'NC1.21';
        }
        field(5140;"FTP Directory";Text[100])
        {
            Caption = 'FTP Directory';
            Description = 'NC1.21';
        }
        field(5150;"FTP Port";Integer)
        {
            Caption = 'FTP Port';
            MinValue = 0;
        }
        field(5160;"FTP Passive";Boolean)
        {
            Caption = 'FTP Passive';
        }
        field(5200;"API Transfer";Boolean)
        {
            Caption = 'API Transfer';
            Description = 'NC1.08';
        }
        field(5210;"API Url";Text[250])
        {
            Caption = 'API Url';
        }
        field(5219;"API Username Type";Option)
        {
            Caption = 'API Username Type';
            Description = 'NC1.09';
            OptionCaption = 'Custom,Automatic';
            OptionMembers = Custom,Automatic;

            trigger OnValidate()
            begin
                //-NC2.00
                UpdateApiUsername();
                //+NC2.00
            end;
        }
        field(5220;"API Username";Text[250])
        {
            Caption = 'API Username';
        }
        field(5230;"API Password";Text[250])
        {
            Caption = 'API Password';
        }
        field(5250;"API Response Path";Text[250])
        {
            Caption = 'API Response Path';
            Description = 'NC2.01';
        }
        field(5254;"API Response Success Path";Text[250])
        {
            Caption = 'API Response Success Path';
            Description = 'NC2.01';
        }
        field(5255;"API Response Success Value";Text[250])
        {
            Caption = 'API Response Success Value';
            Description = 'NC2.01';
        }
        field(5270;"API Type";Option)
        {
            Caption = 'API Type';
            Description = 'NC2.05';
            OptionCaption = 'REST (Xml),SOAP,REST (Json)';
            OptionMembers = "REST (Xml)",SOAP,"REST (Json)";
        }
        field(5275;"API Method";Option)
        {
            Caption = 'API Method';
            Description = 'NC2.03';
            OptionCaption = 'POST,DELETE,GET,PATCH,PUT';
            OptionMembers = POST,DELETE,GET,PATCH,PUT;
        }
        field(5280;"API SOAP Action";Text[250])
        {
            Caption = 'API SOAP Action';
        }
        field(5285;"Xml Root Namespace";Text[50])
        {
            Caption = 'Xml Root Namespace';
            Description = 'NC1.22,NC2.01,NC2.03';
            TableRelation = "NpXml Namespace".Alias WHERE ("Xml Template Code"=FIELD(Code));
        }
        field(5290;Archived;Boolean)
        {
            Caption = 'Archived';
            Description = 'NC1.21';
            Editable = false;
        }
        field(5295;"Version Description";Text[250])
        {
            Caption = 'Version Description';
            Description = 'NC1.21';
        }
        field(5300;"Last Modified by";Code[50])
        {
            Caption = 'Last Modified by';
            Description = 'NC1.21';
        }
        field(5305;"Last Modified at";DateTime)
        {
            Caption = 'Last Modified at';
            Description = 'NC1.21';
        }
        field(5310;"API Content-Type";Text[100])
        {
            Caption = 'API Content-Type';
            Description = 'NC2.01';
        }
        field(5315;"API Authorization";Text[100])
        {
            Caption = 'API Authorization';
            Description = 'NC2.01';
        }
        field(5320;"API Accept";Text[100])
        {
            Caption = 'API Accept';
            Description = 'NC2.01';
        }
        field(5400;"JSON Root is Array";Boolean)
        {
            Caption = 'JSON Root is Array';
            Description = 'NC2.08';
        }
        field(5405;"Use JSON Numbers";Boolean)
        {
            Caption = 'Use JSON Numbers';
            Description = 'NC2.08';
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
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpXmlApiHeader: Record "NpXml Api Header";
        NpXmlElement: Record "NpXml Element";
        NpXmlAttribute: Record "NpXml Attribute";
        NpXmlFilter: Record "NpXml Filter";
        NpXmlNamespace: Record "NpXml Namespace";
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
        NpXmlTemplateMgt: Codeunit "NpXml Template Mgt.";
        Text100: Label 'Template Deleted';
    begin
        //-NC1.21
        //-NC1.22
        //IF NOT Archived THEN BEGIN
        if not VersionArchived() then begin
        //+NC1.22
          if "Version Description" = '' then
            "Version Description" := Text100;
          NpXmlTemplateMgt.Archive(Rec);
        end;
        //+NC1.21

        //-NC1.21
        //NpXmlElement.SETRANGE("Xml Template Code",Code);
        //NpXmlElement.DELETEALL(TRUE);
        //
        //NpXmlTemplateTrigger.SETRANGE("Xml Template Code",Code);
        //NpXmlTemplateTrigger.DELETEALL(TRUE);
        NpXmlElement.SetRange("Xml Template Code",Code);
        NpXmlElement.DeleteAll;

        NpXmlFilter.SetRange("Xml Template Code",Code);
        NpXmlFilter.DeleteAll;

        NpXmlAttribute.SetRange("Xml Template Code",Code);
        NpXmlAttribute.DeleteAll;

        NpXmlTemplateTrigger.SetRange("Xml Template Code",Code);
        NpXmlTemplateTrigger.DeleteAll;

        NpXmlTemplateTriggerLink.SetRange("Xml Template Code",Code);
        NpXmlTemplateTriggerLink.DeleteAll;
        //+NC1.21

        //-NC2.01
        NpXmlNamespace.SetRange("Xml Template Code",Code);
        NpXmlNamespace.DeleteAll;
        //+NC2.01

        //-NC2.06 [265779]
        NpXmlApiHeader.SetRange("Xml Template Code",Code);
        NpXmlApiHeader.DeleteAll;
        //+NC2.06 [265779]
    end;

    trigger OnInsert()
    begin
        //-NC2.00
        //TESTFIELD("Xml Root Name");
        //TESTFIELD("Table No.");
        //+NC2.00

        //-NC1.22
        ////-NC1.21
        //SetNextTemplateVersionNo(Rec);
        ////+NC1.21
        if "Template Version" = '' then
          SetNextTemplateVersionNo(Rec);
        //+NC1.22

        //-NC2.00
        UpdateApiUsername();
        //+NC2.00
        UpdateNaviConnectSetup();
    end;

    trigger OnModify()
    var
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
        NpXmlTemplateArchive: Record "NpXml Template Archive";
        SaveTemplateDescription: Text;
    begin
        //-NC2.00
        //TESTFIELD("Xml Root Name");
        //TESTFIELD("Table No.");
        //+NC2.00

        if "Table No." <> xRec."Table No." then begin
          NpXmlTemplateTrigger.SetRange("Xml Template Code",Code);
          NpXmlTemplateTrigger.SetFilter("Parent Table No.",'<>%1',"Table No.");
          NpXmlTemplateTrigger.ModifyAll("Parent Table No.","Table No.");

          NpXmlTemplateTriggerLink.SetRange("Xml Template Code",Code);
          NpXmlTemplateTriggerLink.SetFilter("Parent Table No.",'<>%1',"Table No.");
          NpXmlTemplateTriggerLink.ModifyAll("Parent Table No.","Table No.");
        end;
        if (xRec."Transaction Task" <> "Transaction Task") or
           (xRec."Table No." <> "Table No.") or
           (xRec."Task Processor Code" <> "Task Processor Code")
          then
          UpdateNaviConnectSetup();

        //-NC1.22
        ////-NC1.21
        //IF Archived THEN
        //  XmlTemplateChanged();
        ////+NC1.21
        //+NC1.22
    end;

    trigger OnRename()
    var
        NewNpXmlApiHeader: Record "NpXml Api Header";
        NewNpXmlXmlFilter: Record "NpXml Filter";
        NewNpXmlNamespace: Record "NpXml Namespace";
        NewNpXmlTemplateTrigger: Record "NpXml Template Trigger";
        NewNpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
        NpXmlApiHeader: Record "NpXml Api Header";
        NpXmlXmlFilter: Record "NpXml Filter";
        NpXmlNamespace: Record "NpXml Namespace";
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
    begin
        NpXmlXmlFilter.SetRange("Xml Template Code",xRec.Code);
        if NpXmlXmlFilter.FindSet then
          repeat
            NewNpXmlXmlFilter := NpXmlXmlFilter;
            NewNpXmlXmlFilter."Xml Template Code" := Code;
            NewNpXmlXmlFilter.Insert;
          until NpXmlXmlFilter.Next = 0;
          NpXmlXmlFilter.DeleteAll;
        NpXmlTemplateTrigger.SetRange("Xml Template Code",xRec.Code);
        if NpXmlTemplateTrigger.FindSet then
          repeat
            NewNpXmlTemplateTrigger := NpXmlTemplateTrigger;
            NewNpXmlTemplateTrigger."Xml Template Code" := Code;
            NewNpXmlTemplateTrigger.Insert;
          until NpXmlTemplateTrigger.Next = 0;
          NpXmlTemplateTrigger.DeleteAll;
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code",xRec.Code);
        if NpXmlTemplateTriggerLink.FindSet then
          repeat
            NewNpXmlTemplateTriggerLink := NpXmlTemplateTriggerLink;
            NewNpXmlTemplateTriggerLink."Xml Template Code" := Code;
            NewNpXmlTemplateTriggerLink.Insert;
          until NpXmlTemplateTriggerLink.Next = 0;
          NpXmlTemplateTriggerLink.DeleteAll;

        //-NC2.01
        NpXmlNamespace.SetRange("Xml Template Code",xRec.Code);
        if NpXmlNamespace.FindSet then
          repeat
            NewNpXmlNamespace := NpXmlNamespace;
            NewNpXmlNamespace."Xml Template Code" := Code;
            NewNpXmlNamespace.Insert;
          until NpXmlNamespace.Next = 0;
          NpXmlNamespace.DeleteAll;
        //+NC2.01

        //-NC2.06 [265779]
        NpXmlApiHeader.SetRange("Xml Template Code",xRec.Code);
        if NpXmlApiHeader.FindSet then
          repeat
            NewNpXmlApiHeader := NpXmlApiHeader;
            NewNpXmlApiHeader."Xml Template Code" := Code;
            NewNpXmlApiHeader.Insert;
          until NpXmlApiHeader.Next = 0;
          NpXmlApiHeader.DeleteAll;
        //+NC2.06 [265779]
    end;

    procedure GetApiUsername(): Text[250]
    var
        NpXmlMgt: Codeunit "NpXml Mgt.";
    begin
        //-NC1.09
        case "API Username Type" of
          "API Username Type"::Automatic:
            begin
              //-NC1.22
              //ActiveSession.GET(SERVICEINSTANCEID,SESSIONID);
              //EXIT(LOWERCASE(ActiveSession."Database Name" + '_' + COMPANYNAME));
              exit(NpXmlMgt.GetAutomaticUsername());
              //+NC1.22
            end;
          else
            exit("API Username");
        end;
        //+NC1.09
    end;

    procedure InitVersion()
    var
        XMLTemplate: Record "NpXml Template";
        NpXmlTemplateHistory: Record "NpXml Template History";
    begin
        //-NC1.22
        if not Archived then
          exit;

        SetNextTemplateVersionNo(Rec);
        "Last Modified by" := UserId;
        "Last Modified at" := CreateDateTime(Today,Time);
        if "Version Description" = xRec."Version Description" then
          "Version Description" := '';
        Archived := false;
        NpXmlTemplateHistory.InsertHistory(Code,"Template Version",NpXmlTemplateHistory."Event Type"::Modification,"Version Description");
        //+NC1.22
    end;

    local procedure SetNextTemplateVersionNo(var NpXmlTemplate: Record "NpXml Template")
    var
        NpXmlSetup: Record "NpXml Setup";
        NpXmlTemplateArchive: Record "NpXml Template Archive";
        DatabaseRecord: RecordRef;
        NewTemplateVersion: Code[10];
        CurrentTemplateTimestamp: DateTime;
        NextTemplateVersionNo: Code[10];
    begin
        //-NC1.21
        NpXmlSetup.Get;

        if NpXmlSetup."Template Version Prefix" = '' then
          NpXmlSetup."Template Version Prefix" := 'NPK';
        if NpXmlSetup."Template Version No." <= 0 then
          NpXmlSetup."Template Version No." := 1;

        //-NC1.22
        //IF NpXmlTemplate."Template Version" <> '' THEN BEGIN
        //  NextTemplateVersionNo := INCSTR(NpXmlTemplate."Template Version");
        //  IF STRPOS(NextTemplateVersionNo,NpXmlSetup."Template Version Prefix" + FORMAT(NpXmlSetup."Template Version No.")) = 1 THEN BEGIN
        //    NpXmlTemplate."Template Version" := NextTemplateVersionNo;
        //    EXIT;
        //  END;
        //END;
        //
        //NpXmlTemplateArchive.SETRANGE(Code,NpXmlTemplate.Code);
        //IF NpXmlTemplateArchive.FINDLAST THEN BEGIN
        //  NextTemplateVersionNo := INCSTR(NpXmlTemplateArchive."Template Version No.");
        //  IF STRPOS(NextTemplateVersionNo,NpXmlSetup."Template Version Prefix" + FORMAT(NpXmlSetup."Template Version No.")) = 1 THEN BEGIN
        //    NpXmlTemplate."Template Version" := NextTemplateVersionNo;
        //    EXIT;
        //  END;
        //END;
        //
        //NpXmlTemplate."Template Version" := NpXmlSetup."Template Version Prefix" + FORMAT(NpXmlSetup."Template Version No.") + '.00';
        //
        //InitTemplateVersion(NpXmlTemplate.Code,NpXmlTemplate."Template Version");
        NextTemplateVersionNo := NpXmlSetup."Template Version Prefix" + Format(NpXmlSetup."Template Version No.");
        NpXmlTemplate."Template Version" := NextTemplateVersionNo + '.00';
        NpXmlTemplateArchive.SetRange(Code,NpXmlTemplate.Code);
        NpXmlTemplateArchive.SetFilter("Template Version No.",'%1',NextTemplateVersionNo + '.??');
        if NpXmlTemplateArchive.FindLast then
          NpXmlTemplate."Template Version" := IncStr(NpXmlTemplateArchive."Template Version No.");
        //+NC1.22
        //+NC1.21
    end;

    local procedure UpdateApiUsername()
    begin
        //-NC2.00
        if "API Username Type" <> "API Username Type"::Automatic then
          exit;

        "API Username" := GetApiUsername();
        //+NC2.00
    end;

    procedure UpdateNaviConnectSetup()
    var
        DataLogSetup: Record "Data Log Setup (Table)";
        DataLogSubscriber: Record "Data Log Subscriber";
        NaviConnectTaskSetup: Record "Nc Task Setup";
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
        SetupChanged: Boolean;
        DurationBuffer: Duration;
    begin
        if not "Transaction Task" then
          exit;
        //-NC2.00
        if "Disable Auto Task Setup" then
          exit;
        //+NC2.00

        NpXmlTemplateTrigger.SetRange("Xml Template Code",Code);
        NpXmlTemplateTrigger.SetFilter("Table No.",'<>%1',0);
        if NpXmlTemplateTrigger.FindSet then
          repeat
            if NpXmlTemplateTrigger."Insert Trigger" or NpXmlTemplateTrigger."Modify Trigger" or NpXmlTemplateTrigger."Delete Trigger" then begin
              NaviConnectTaskSetup.SetRange("Table No.",NpXmlTemplateTrigger."Table No.");
              NaviConnectTaskSetup.SetRange("Codeunit ID",CODEUNIT::"NpXml Task Mgt.");
              NaviConnectTaskSetup.SetRange("Task Processor Code","Task Processor Code");
              if not NaviConnectTaskSetup.FindFirst then begin
                NaviConnectTaskSetup.Init;
                NaviConnectTaskSetup."Entry No." := 0;
                NaviConnectTaskSetup."Table No." := NpXmlTemplateTrigger."Table No.";
                NaviConnectTaskSetup."Codeunit ID" := CODEUNIT::"NpXml Task Mgt.";
                NaviConnectTaskSetup."Task Processor Code" := "Task Processor Code";
                NaviConnectTaskSetup.Insert(true);
              end;

              if not DataLogSetup.Get(NpXmlTemplateTrigger."Table No.") then begin
                DataLogSetup.Init;
                DataLogSetup."Table ID" := NpXmlTemplateTrigger."Table No.";
                if NpXmlTemplateTrigger."Insert Trigger" then
                  DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
                if NpXmlTemplateTrigger."Modify Trigger" then
                  DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Changes;
                if NpXmlTemplateTrigger."Delete Trigger" then
                  DataLogSetup."Log Deletion" := DataLogSetup."Log Deletion"::Detailed;
                //-NC2.11 [308404]
                //DurationBuffer := CREATEDATETIME(310101D,000000T) - CREATEDATETIME(010101D,000000T);
                DurationBuffer := CreateDateTime(DMY2Date(31,1,2001),000000T) - CreateDateTime(DMY2Date(1,1,2001),000000T);
                //+NC2.11 [308404]
                DataLogSetup."Keep Log for" := DurationBuffer;
                DataLogSetup.Insert(true);
              end else begin
                SetupChanged := false;
                if NpXmlTemplateTrigger."Insert Trigger" and (DataLogSetup."Log Insertion" < DataLogSetup."Log Insertion"::Simple) then begin
                  SetupChanged := true;
                  DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
                end;
                if NpXmlTemplateTrigger."Modify Trigger" and (DataLogSetup."Log Modification" < DataLogSetup."Log Modification"::Changes) then begin
                  SetupChanged := true;
                  DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Changes;
                end;
                if NpXmlTemplateTrigger."Delete Trigger" and (DataLogSetup."Log Deletion" < DataLogSetup."Log Deletion"::Detailed) then begin
                  SetupChanged := true;
                  DataLogSetup."Log Deletion" := DataLogSetup."Log Deletion"::Detailed;
                end;
                if SetupChanged then
                  DataLogSetup.Modify(true);
              end;

              if not DataLogSubscriber.Get("Task Processor Code",NpXmlTemplateTrigger."Table No.") then begin
                DataLogSubscriber.Init;
                DataLogSubscriber.Code := "Task Processor Code";
                DataLogSubscriber."Table ID" := NpXmlTemplateTrigger."Table No.";
                DataLogSubscriber.Insert(true);
              end;
            end;
          until NpXmlTemplateTrigger.Next = 0;
    end;

    procedure VersionArchived(): Boolean
    var
        NpXmlTemplateArchive: Record "NpXml Template Archive";
    begin
        //-NC1.22
        NpXmlTemplateArchive.SetRange(Code,Code);
        NpXmlTemplateArchive.SetRange("Template Version No.","Template Version");
        exit(NpXmlTemplateArchive.FindFirst);
        //+NC1.22
    end;
}

