table 6151555 "NPR NpXml Template Trigger"
{
    Caption = 'NpXml Template Trigger';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Xml Template Code"; Code[20])
        {
            Caption = 'Xml Template Code';
            DataClassification = CustomerContent;
            Description = 'NC1.05,NC1.07';
            TableRelation = "NPR NpXml Template";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(20; "Template Version No."; Code[20])
        {
            Caption = 'Template Version No.';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
        field(90; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
            DataClassification = CustomerContent;
            Description = 'NC1.11';

            trigger OnValidate()
            var
                NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
                XMLTemplate: Record "NPR NpXml Template";
            begin
                if NpXmlTemplateTrigger.Get("Xml Template Code", "Parent Line No.") then
                    "Parent Table No." := NpXmlTemplateTrigger."Table No."
                else
                    if XMLTemplate.Get("Xml Template Code") then
                        "Parent Table No." := XMLTemplate."Table No.";
            end;
        }
        field(100; "Parent Table No."; Integer)
        {
            Caption = 'Parent Table No.';
            DataClassification = CustomerContent;
            Description = 'NC1.11';
            Editable = false;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(120; "Xml Template Table Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Parent Table No.")));
            Caption = 'Xml Template Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(200; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(220; "Table Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(300; "Insert Trigger"; Boolean)
        {
            Caption = 'Insert Trigger';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(310; "Modify Trigger"; Boolean)
        {
            Caption = 'Modify Trigger';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(320; "Delete Trigger"; Boolean)
        {
            Caption = 'Delete Trigger';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(400; Comment; Text[250])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
            Description = 'NC1.11';
        }
        field(500; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
        }
        field(600; "Generic Parent Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Generic Parent Codeunit ID';
            DataClassification = CustomerContent;
            Description = 'NC2.01';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Trigger Mgt.");
                EventSubscription.SetRange("Published Function", 'OnSetupGenericParentTable');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Generic Parent Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Generic Parent Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Generic Parent Codeunit ID" = 0 then begin
                    "Generic Parent Function" := '';
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Trigger Mgt.");
                EventSubscription.SetRange("Published Function", 'OnSetupGenericParentTable');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Generic Parent Codeunit ID");
                if "Generic Parent Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Generic Parent Function");
                EventSubscription.FindFirst();
            end;
        }
        field(605; "Generic Parent Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Generic Parent Codeunit ID")));
            Caption = 'Generic Parent Codeunit Name';
            Description = 'NC2.01';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610; "Generic Parent Function"; Text[250])
        {
            Caption = 'Generic Parent Function';
            DataClassification = CustomerContent;
            Description = 'NC2.01';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Trigger Mgt.");
                EventSubscription.SetRange("Published Function", 'OnSetupGenericParentTable');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                "Generic Parent Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Generic Parent Function" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Generic Parent Function" = '' then begin
                    "Generic Parent Codeunit ID" := 0;
                    exit;
                end;

                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR NpXml Trigger Mgt.");
                EventSubscription.SetRange("Published Function", 'OnSetupGenericParentTable');
                EventSubscription.SetRange("Subscriber Codeunit ID", "Generic Parent Codeunit ID");
                if "Generic Parent Function" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Generic Parent Function");
                EventSubscription.FindFirst();
            end;
        }
        field(1010; "Last Modified at"; DateTime)
        {
            Caption = 'Last Modified at';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
    }

    keys
    {
        key(Key1; "Xml Template Code", "Line No.")
        {
        }
        key(Key2; "Table No.")
        {
        }
    }

    trigger OnDelete()
    var
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
    begin
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code", "Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", "Line No.");
        NpXmlTemplateTriggerLink.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        Validate("Parent Line No.");
        TestField("Parent Table No.");
        TestField("Table No.");
        UpdateNaviConnectSetup();
        "Template Version No." := GetTemplateVersionNo();
    end;

    trigger OnModify()
    var
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
    begin
        TestField("Parent Table No.");
        TestField("Table No.");
        if xRec."Table No." <> "Table No." then begin
            NpXmlTemplateTriggerLink.SetRange("Xml Template Code", "Xml Template Code");
            NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", "Line No.");
            NpXmlTemplateTriggerLink.SetFilter("Table No.", '<>%1', 0);
            NpXmlTemplateTriggerLink.ModifyAll("Table No.", "Table No.");
        end;

        if (xRec."Table No." <> "Table No.") or
           (xRec."Insert Trigger" <> "Insert Trigger") or
           (xRec."Modify Trigger" <> "Modify Trigger") or
           (xRec."Delete Trigger" <> "Delete Trigger")
          then
            UpdateNaviConnectSetup();

        "Template Version No." := GetTemplateVersionNo();
        "Last Modified at" := CreateDateTime(Today, Time);
    end;

    procedure GetParentLineNo() ParentLineNo: Integer
    var
        NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger";
    begin
        Clear(NpXmlTemplateTrigger);
        NpXmlTemplateTrigger.SetRange("Xml Template Code", "Xml Template Code");
        NpXmlTemplateTrigger.SetFilter("Line No.", '<%1', "Line No.");
        NpXmlTemplateTrigger.SetFilter(Level, '<%1', Level);
        if NpXmlTemplateTrigger.FindLast() then
            exit(NpXmlTemplateTrigger."Line No.");
    end;

    local procedure GetTemplateVersionNo(): Code[20]
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        NpXmlTemplate.Get("Xml Template Code");
        exit(NpXmlTemplate."Template Version");
    end;

    procedure UpdateNaviConnectSetup()
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        NaviConnectTaskSetup: Record "NPR Nc Task Setup";
        NpXmlTemplate: Record "NPR NpXml Template";
        SetupChanged: Boolean;
    begin
        if "Table No." = 0 then
            exit;

        NpXmlTemplate.Get("Xml Template Code");
        if not NpXmlTemplate."Transaction Task" then
            exit;

        if "Insert Trigger" or "Modify Trigger" or "Delete Trigger" then begin
            NaviConnectTaskSetup.SetRange("Table No.", "Table No.");
            NaviConnectTaskSetup.SetRange("Codeunit ID", CODEUNIT::"NPR NpXml Task Mgt.");
            NaviConnectTaskSetup.SetRange("Task Processor Code", NpXmlTemplate."Task Processor Code");
            if not NaviConnectTaskSetup.FindFirst() then begin
                NaviConnectTaskSetup.Init();
                NaviConnectTaskSetup."Entry No." := 0;
                NaviConnectTaskSetup."Table No." := "Table No.";
                NaviConnectTaskSetup."Codeunit ID" := CODEUNIT::"NPR NpXml Task Mgt.";
                NaviConnectTaskSetup."Task Processor Code" := NpXmlTemplate."Task Processor Code";
                NaviConnectTaskSetup.Insert(true);
            end;

            if not DataLogSetup.Get("Table No.") then begin
                DataLogSetup.Init();
                DataLogSetup."Table ID" := "Table No.";
                if "Insert Trigger" then
                    DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
                if "Modify Trigger" then
                    DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Changes;
                if "Delete Trigger" then
                    DataLogSetup."Log Deletion" := DataLogSetup."Log Deletion"::Detailed;
                DataLogSetup."Keep Log for" := CreateDateTime(Today, 010000T) - CreateDateTime(CalcDate('<-30D>', Today), 010000T);
                DataLogSetup.Insert(true);
            end else begin
                SetupChanged := false;
                if "Insert Trigger" and (DataLogSetup."Log Insertion" < DataLogSetup."Log Insertion"::Simple) then begin
                    SetupChanged := true;
                    DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
                end;
                if "Modify Trigger" and (DataLogSetup."Log Modification" < DataLogSetup."Log Modification"::Changes) then begin
                    SetupChanged := true;
                    DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Changes;
                end;
                if "Delete Trigger" and (DataLogSetup."Log Deletion" < DataLogSetup."Log Deletion"::Detailed) then begin
                    SetupChanged := true;
                    DataLogSetup."Log Deletion" := DataLogSetup."Log Deletion"::Detailed;
                end;
                if SetupChanged then
                    DataLogSetup.Modify(true);
            end;

            if not DataLogSubscriber.Get(NpXmlTemplate."Task Processor Code", "Table No.", '') then begin
                DataLogSubscriber.Init();
                DataLogSubscriber.Code := NpXmlTemplate."Task Processor Code";
                DataLogSubscriber."Table ID" := "Table No.";
                DataLogSubscriber."Company Name" := '';
                DataLogSubscriber.Insert(true);
            end;
        end;
    end;

    procedure UpdateParentInfo()
    var
        NpXmlTemplateTriggerLink: Record "NPR NpXml Templ.Trigger Link";
    begin
        Validate("Parent Line No.", GetParentLineNo());
        if xRec."Parent Table No." <> "Parent Table No." then begin
            NpXmlTemplateTriggerLink.SetRange("Xml Template Code", "Xml Template Code");
            NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.", "Line No.");
            NpXmlTemplateTriggerLink.SetFilter("Parent Table No.", '<>%1', 0);
            NpXmlTemplateTriggerLink.ModifyAll("Parent Table No.", "Parent Table No.");
        end;
    end;
}

