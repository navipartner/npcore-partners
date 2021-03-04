table 6151551 "NPR NpXml Template"
{
    Caption = 'NpXml Template';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpXml Template List";
    LookupPageID = "NPR NpXml Template List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Xml Root Name"; Text[50])
        {
            Caption = 'Xml Root Name';
            DataClassification = CustomerContent;
            Description = 'Root tag in xml file,NC1.07';
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            Description = 'Table to Export';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(20; "Template Version"; Code[20])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(30; "Namespaces Enabled"; Boolean)
        {
            Caption = 'Namespaces Enabled';
            DataClassification = CustomerContent;
            Description = 'NC1.22';
        }
        field(1000; "Transaction Task"; Boolean)
        {
            Caption = 'Transaction Task';
            DataClassification = CustomerContent;
            Description = 'NaviConnect Task';
        }
        field(1010; "Disable Auto Task Setup"; Boolean)
        {
            Caption = 'Disable Auto Task Setup';
            DataClassification = CustomerContent;
            Description = 'NC2.00';
        }
        field(2000; "Batch Task"; Boolean)
        {
            Caption = 'Batch Task';
            DataClassification = CustomerContent;
            Description = 'Run by NAS';
        }
        field(2010; "Batch Active From"; DateTime)
        {
            Caption = 'Batch Active From';
            DataClassification = CustomerContent;
            Description = 'Earliest run - value required before run';
        }
        field(2020; "Batch Interval (Days)"; Integer)
        {
            Caption = 'Batch Interval (Days)';
            DataClassification = CustomerContent;
            Description = 'Next run - Days';
        }
        field(2025; "Batch Interval (Minutes)"; Integer)
        {
            Caption = 'Batch Interval (Minutes)';
            DataClassification = CustomerContent;
            Description = 'Next run - Minutes';
        }
        field(2030; "Batch Start Time"; Time)
        {
            Caption = 'Batch Start Time';
            DataClassification = CustomerContent;
            Description = 'Next run - Specific time (Overwrites "Batch Interval (Minutes)")';
        }
        field(2040; "Batch End Time"; Time)
        {
            Caption = 'Batch End Time';
            DataClassification = CustomerContent;
        }
        field(2100; "Batch Last Run"; DateTime)
        {
            Caption = 'Batch Last Run';
            DataClassification = CustomerContent;
            Description = 'Last execution datetime';
        }
        field(2110; "Next Batch Run"; DateTime)
        {
            Caption = 'Next Batch Run';
            DataClassification = CustomerContent;
            Description = 'Earliest next run';
        }
        field(2200; "Max Records per File"; Integer)
        {
            Caption = 'Max qty. records per XML File';
            DataClassification = CustomerContent;
            Description = 'NC1.07';
        }
        field(3000; "Runtime Error"; Boolean)
        {
            Caption = 'Runtime Error';
            DataClassification = CustomerContent;
        }
        field(3010; "Last Error Message"; Text[250])
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
        }
        field(4900; "Before Transfer Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Before Transfer Codeunit ID';
            DataClassification = CustomerContent;
            Description = 'NC2.03';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Mgt.");
                EventSubscription.SetRange("Published Function", 'OnBeforeTransferXml');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Before Transfer Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Before Transfer Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Before Transfer Codeunit ID" = 0 then begin
                    "Before Transfer Function" := '';
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Mgt.");
                EventSubscription.SetRange("Published Function", 'OnBeforeTransferXml');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Before Transfer Codeunit ID");
                if "Before Transfer Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Before Transfer Function");
                EventSubscription.FindFirst;
            end;
        }
        field(4905; "Before Transfer Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Before Transfer Codeunit ID")));
            Caption = 'Before Transfer Codeunit Name';
            Description = 'NC2.03';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4910; "Before Transfer Function"; Text[80])
        {
            Caption = 'Before Transfer Function';
            DataClassification = CustomerContent;
            Description = 'NC2.03';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Mgt.");
                EventSubscription.SetRange("Published Function", 'OnBeforeTransferXml');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Before Transfer Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Before Transfer Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Before Transfer Function" = '' then begin
                    "Before Transfer Codeunit ID" := 0;
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Mgt.");
                EventSubscription.SetRange("Published Function", 'OnBeforeTransferXml');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Before Transfer Codeunit ID");
                if "Before Transfer Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Before Transfer Function");
                EventSubscription.FindFirst;
            end;
        }
        field(4990; "File Transfer"; Boolean)
        {
            Caption = 'File Transfer';
            DataClassification = CustomerContent;
        }
        field(5000; "File Path"; Text[250])
        {
            Caption = 'File Path';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Valid: Boolean;
            begin
                if "File Path" <> '' then begin
                    if "File Path"[StrLen("File Path")] = '\' then begin
                        if StrLen("File Path") = 1 then
                            "File Path" := ''
                        else
                            "File Path" := CopyStr("File Path", 1, StrLen("File Path") - 1);
                    end;
                end;
            end;
        }
        field(5100; "FTP Transfer"; Boolean)
        {
            Caption = 'FTP Transfer';
            DataClassification = CustomerContent;
            Description = 'NC1.08';
        }
        field(5110; "FTP Server"; Text[250])
        {
            Caption = 'FTP Server';
            DataClassification = CustomerContent;
        }
        field(5120; "FTP Username"; Text[100])
        {
            Caption = 'FTP Username';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(5130; "FTP Password"; Text[100])
        {
            Caption = 'FTP Password';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(5140; "FTP Directory"; Text[100])
        {
            Caption = 'FTP Directory';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(5145; "FTP Filename (Fixed)"; Text[100])
        {
            Caption = 'FTP Filename (Fixed)';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(5150; "FTP Port"; Integer)
        {
            Caption = 'FTP Port';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(5160; "FTP Passive"; Boolean)
        {
            Caption = 'FTP Passive';
            DataClassification = CustomerContent;
        }
        field(5200; "API Transfer"; Boolean)
        {
            Caption = 'API Transfer';
            DataClassification = CustomerContent;
            Description = 'NC1.08';
        }
        field(5210; "API Url"; Text[250])
        {
            Caption = 'API Url';
            DataClassification = CustomerContent;
        }
        field(5219; "API Username Type"; Option)
        {
            Caption = 'API Username Type';
            DataClassification = CustomerContent;
            Description = 'NC1.09';
            OptionCaption = 'Custom,Automatic';
            OptionMembers = Custom,Automatic;

            trigger OnValidate()
            begin
                UpdateApiUsername();
            end;
        }
        field(5220; "API Username"; Text[250])
        {
            Caption = 'API Username';
            DataClassification = CustomerContent;
        }
        field(5230; "API Password"; Text[250])
        {
            Caption = 'API Password';
            DataClassification = CustomerContent;
        }
        field(5250; "API Response Path"; Text[250])
        {
            Caption = 'API Response Path';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
        }
        field(5254; "API Response Success Path"; Text[250])
        {
            Caption = 'API Response Success Path';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
        }
        field(5255; "API Response Success Value"; Text[250])
        {
            Caption = 'API Response Success Value';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
        }
        field(5270; "API Type"; Option)
        {
            Caption = 'API Type';
            DataClassification = CustomerContent;
            Description = 'NC2.05';
            OptionCaption = 'REST (Xml),SOAP,REST (Json)';
            OptionMembers = "REST (Xml)",SOAP,"REST (Json)";
        }
        field(5275; "API Method"; Option)
        {
            Caption = 'API Method';
            DataClassification = CustomerContent;
            Description = 'NC2.03';
            OptionCaption = 'POST,DELETE,GET,PATCH,PUT';
            OptionMembers = POST,DELETE,GET,PATCH,PUT;
        }
        field(5280; "API SOAP Action"; Text[250])
        {
            Caption = 'API SOAP Action';
            DataClassification = CustomerContent;
        }
        field(5285; "Xml Root Namespace"; Text[50])
        {
            Caption = 'Xml Root Namespace';
            DataClassification = CustomerContent;
            Description = 'NC1.22,NC2.01,NC2.03';
            TableRelation = "NPR NpXml Namespace".Alias WHERE("Xml Template Code" = FIELD(Code));
        }
        field(5290; Archived; Boolean)
        {
            Caption = 'Archived';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
            Editable = false;
        }
        field(5295; "Version Description"; Text[250])
        {
            Caption = 'Version Description';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(5300; "Last Modified by"; Code[50])
        {
            Caption = 'Last Modified by';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(5305; "Last Modified at"; DateTime)
        {
            Caption = 'Last Modified at';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(5310; "API Content-Type"; Text[100])
        {
            Caption = 'API Content-Type';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
        }
        field(5315; "API Authorization"; Text[100])
        {
            Caption = 'API Authorization';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
        }
        field(5320; "API Accept"; Text[100])
        {
            Caption = 'API Accept';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
        }
        field(5400; "JSON Root is Array"; Boolean)
        {
            Caption = 'JSON Root is Array';
            DataClassification = CustomerContent;
            Description = 'NC2.08';
        }
        field(5405; "Use JSON Numbers"; Boolean)
        {
            Caption = 'Use JSON Numbers';
            DataClassification = CustomerContent;
            Description = 'NC2.08';
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
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    var
        NpXmlApiHeader: Record "NPR NpXml Api Header";
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlAttribute: Record "NPR NpXml Attribute";
        NpXmlFilter: Record "NPR NpXml Filter";
        NpXmlNamespace: Record "NPR NpXml Namespace";
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";
        Text100: Label 'Template Deleted';
    begin
        if not VersionArchived() then begin
            if "Version Description" = '' then
                "Version Description" := Text100;
            NpXmlTemplateMgt.Archive(Rec);
        end;

        NpXmlElement.SetRange("Xml Template Code", Code);
        NpXmlElement.DeleteAll;

        NpXmlFilter.SetRange("Xml Template Code", Code);
        NpXmlFilter.DeleteAll;

        NpXmlAttribute.SetRange("Xml Template Code", Code);
        NpXmlAttribute.DeleteAll;

        NpXmlTemplateTrigger.SetRange("Xml Template Code", Code);
        NpXmlTemplateTrigger.DeleteAll;

        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", Code);
        NpXmlTemplateTriggerLink.DeleteAll;

        NpXmlNamespace.SetRange("Xml Template Code", Code);
        NpXmlNamespace.DeleteAll;

        NpXmlApiHeader.SetRange("Xml Template Code", Code);
        NpXmlApiHeader.DeleteAll;
    end;

    trigger OnInsert()
    begin
        if "Template Version" = '' then
            SetNextTemplateVersionNo(Rec);

        UpdateApiUsername();
        UpdateNaviConnectSetup();
    end;

    trigger OnModify()
    var
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
        NpXmlTemplateArchive: Record "NPR NpXml Template Arch.";
        SaveTemplateDescription: Text;
    begin
        if "Table No." <> xRec."Table No." then begin
            NpXmlTemplateTrigger.SetRange("Xml Template Code", Code);
            NpXmlTemplateTrigger.SetFilter("Parent Table No.", '<>%1', "Table No.");
            NpXmlTemplateTrigger.ModifyAll("Parent Table No.", "Table No.");

            NpXmlTemplateTriggerLink.SetRange("Xml Template Code", Code);
            NpXmlTemplateTriggerLink.SetFilter("Parent Table No.", '<>%1', "Table No.");
            NpXmlTemplateTriggerLink.ModifyAll("Parent Table No.", "Table No.");
        end;
        if (xRec."Transaction Task" <> "Transaction Task") or
           (xRec."Table No." <> "Table No.") or
           (xRec."Task Processor Code" <> "Task Processor Code")
          then
            UpdateNaviConnectSetup();
    end;

    trigger OnRename()
    var
        NewNpXmlApiHeader: Record "NPR NpXml Api Header";
        NewNpXmlXmlFilter: Record "NPR NpXml Filter";
        NewNpXmlNamespace: Record "NPR NpXml Namespace";
        NewNpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        NewNpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
        NpXmlApiHeader: Record "NPR NpXml Api Header";
        NpXmlXmlFilter: Record "NPR NpXml Filter";
        NpXmlNamespace: Record "NPR NpXml Namespace";
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
    begin
        NpXmlXmlFilter.SetRange("Xml Template Code", xRec.Code);
        if NpXmlXmlFilter.FindSet then
            repeat
                NewNpXmlXmlFilter := NpXmlXmlFilter;
                NewNpXmlXmlFilter."Xml Template Code" := Code;
                NewNpXmlXmlFilter.Insert;
            until NpXmlXmlFilter.Next = 0;
        NpXmlXmlFilter.DeleteAll;
        NpXmlTemplateTrigger.SetRange("Xml Template Code", xRec.Code);
        if NpXmlTemplateTrigger.FindSet then
            repeat
                NewNpXmlTemplateTrigger := NpXmlTemplateTrigger;
                NewNpXmlTemplateTrigger."Xml Template Code" := Code;
                NewNpXmlTemplateTrigger.Insert;
            until NpXmlTemplateTrigger.Next = 0;
        NpXmlTemplateTrigger.DeleteAll;
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", xRec.Code);
        if NpXmlTemplateTriggerLink.FindSet then
            repeat
                NewNpXmlTemplateTriggerLink := NpXmlTemplateTriggerLink;
                NewNpXmlTemplateTriggerLink."Xml Template Code" := Code;
                NewNpXmlTemplateTriggerLink.Insert;
            until NpXmlTemplateTriggerLink.Next = 0;
        NpXmlTemplateTriggerLink.DeleteAll;

        NpXmlNamespace.SetRange("Xml Template Code", xRec.Code);
        if NpXmlNamespace.FindSet then
            repeat
                NewNpXmlNamespace := NpXmlNamespace;
                NewNpXmlNamespace."Xml Template Code" := Code;
                NewNpXmlNamespace.Insert;
            until NpXmlNamespace.Next = 0;
        NpXmlNamespace.DeleteAll;

        NpXmlApiHeader.SetRange("Xml Template Code", xRec.Code);
        if NpXmlApiHeader.FindSet then
            repeat
                NewNpXmlApiHeader := NpXmlApiHeader;
                NewNpXmlApiHeader."Xml Template Code" := Code;
                NewNpXmlApiHeader.Insert;
            until NpXmlApiHeader.Next = 0;
        NpXmlApiHeader.DeleteAll;
    end;

    procedure GetApiUsername(): Text[250]
    var
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
    begin
        case "API Username Type" of
            "API Username Type"::Automatic:
                exit(NpXmlMgt.GetAutomaticUsername());
            else
                exit("API Username");
        end;
    end;

    procedure InitVersion()
    var
        XMLTemplate: Record "NPR NpXml Template";
        NpXmlTemplateHistory: Record "NPR NpXml Template History";
    begin
        if not Archived then
            exit;

        SetNextTemplateVersionNo(Rec);
        "Last Modified by" := UserId;
        "Last Modified at" := CreateDateTime(Today, Time);
        if "Version Description" = xRec."Version Description" then
            "Version Description" := '';
        Archived := false;
        NpXmlTemplateHistory.InsertHistory(Code, "Template Version", NpXmlTemplateHistory."Event Type"::Modification, "Version Description");
    end;

    local procedure SetNextTemplateVersionNo(var NpXmlTemplate: Record "NPR NpXml Template")
    var
        NpXmlSetup: Record "NPR NpXml Setup";
        NpXmlTemplateArchive: Record "NPR NpXml Template Arch.";
        DatabaseRecord: RecordRef;
        NewTemplateVersion: Code[10];
        CurrentTemplateTimestamp: DateTime;
        NextTemplateVersionNo: Code[10];
    begin
        NpXmlSetup.Get;

        if NpXmlSetup."Template Version Prefix" = '' then
            NpXmlSetup."Template Version Prefix" := 'NPK';
        if NpXmlSetup."Template Version No." <= 0 then
            NpXmlSetup."Template Version No." := 1;

        NextTemplateVersionNo := NpXmlSetup."Template Version Prefix" + Format(NpXmlSetup."Template Version No.");
        NpXmlTemplate."Template Version" := NextTemplateVersionNo + '.00';
        NpXmlTemplateArchive.SetRange(Code, NpXmlTemplate.Code);
        NpXmlTemplateArchive.SetFilter("Template Version No.", '%1', NextTemplateVersionNo + '.??');
        if NpXmlTemplateArchive.FindLast then
            NpXmlTemplate."Template Version" := IncStr(NpXmlTemplateArchive."Template Version No.");
    end;

    local procedure UpdateApiUsername()
    begin
        if "API Username Type" <> "API Username Type"::Automatic then
            exit;

        "API Username" := GetApiUsername();
    end;

    procedure UpdateNaviConnectSetup()
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        NaviConnectTaskSetup: Record "NPR Nc Task Setup";
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
        SetupChanged: Boolean;
        DurationBuffer: Duration;
    begin
        if not "Transaction Task" then
            exit;
        if "Disable Auto Task Setup" then
            exit;

        NpXmlTemplateTrigger.SetRange("Xml Template Code", Code);
        NpXmlTemplateTrigger.SetFilter("Table No.", '<>%1', 0);
        if NpXmlTemplateTrigger.FindSet then
            repeat
                if NpXmlTemplateTrigger."Insert Trigger" or NpXmlTemplateTrigger."Modify Trigger" or NpXmlTemplateTrigger."Delete Trigger" then begin
                    NaviConnectTaskSetup.SetRange("Table No.", NpXmlTemplateTrigger."Table No.");
                    NaviConnectTaskSetup.SetRange("Codeunit ID", CODEUNIT::"NPR NpXml Task Mgt.");
                    NaviConnectTaskSetup.SetRange("Task Processor Code", "Task Processor Code");
                    if not NaviConnectTaskSetup.FindFirst then begin
                        NaviConnectTaskSetup.Init;
                        NaviConnectTaskSetup."Entry No." := 0;
                        NaviConnectTaskSetup."Table No." := NpXmlTemplateTrigger."Table No.";
                        NaviConnectTaskSetup."Codeunit ID" := CODEUNIT::"NPR NpXml Task Mgt.";
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
                        DurationBuffer := CreateDateTime(DMY2Date(31, 1, 2001), 000000T) - CreateDateTime(DMY2Date(1, 1, 2001), 000000T);
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

                    if not DataLogSubscriber.Get("Task Processor Code", NpXmlTemplateTrigger."Table No.") then begin
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
        NpXmlTemplateArchive: Record "NPR NpXml Template Arch.";
    begin
        NpXmlTemplateArchive.SetRange(Code, Code);
        NpXmlTemplateArchive.SetRange("Template Version No.", "Template Version");
        exit(NpXmlTemplateArchive.FindFirst);
    end;
}

