table 6151555 "NpXml Template Trigger"
{
    // NC1.01/MH/20150201  CASE 199932 Object Created - defines which table changes should trigger NpXml Templates (Transaction Task).
    // NC1.05/MH/20150219  CASE 206395 Changed TestTableRelation and ValidateTableRelation for field 1 "Xml Template Code"
    // NC1.07/MH/20150309  CASE 208131 Updated captions
    // NC1.11/MH/20150330  CASE 210171 Added multi level triggers
    // NC1.19/MH/20150707  CASE 218282 Deleted unused field 1000 "Xml Template Element Name"
    // NC1.21/TTH/20151020 CASE 224528 Adding versioning and possibility to lock the modified versions. Added field 20 Template Version number and 1010 Last Modified. New function XmlTemplateChanged.
    // NC1.22/MHA/20151203 CASE 224528 Function XmlTemplateChanged() deleted and GetVersionNo() created
    // NC1.22/MHA/20151203 CASE 224528 Deleted function XmlTemplateChanged() and credted GetVersionNo()
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20161018 CASE 2425550 Added Generic Table fields for enabling Temporary Table Exports
    // NC2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // NC2.26/MHA /20200501  CASE 402488 Updated UpdateNaviConnectSetup() from Local to Global and changed Keep Log for from 1 minute to 30 days

    Caption = 'NpXml Template Trigger';

    fields
    {
        field(1;"Xml Template Code";Code[20])
        {
            Caption = 'Xml Template Code';
            Description = 'NC1.05,NC1.07';
            TableRelation = "NpXml Template";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(20;"Template Version No.";Code[20])
        {
            Caption = 'Template Version No.';
            Description = 'NC1.21';
        }
        field(90;"Parent Line No.";Integer)
        {
            Caption = 'Parent Line No.';
            Description = 'NC1.11';

            trigger OnValidate()
            var
                NpXmlTemplateTrigger: Record "NpXml Template Trigger";
                XMLTemplate: Record "NpXml Template";
            begin
                if NpXmlTemplateTrigger.Get("Xml Template Code","Parent Line No.") then
                  "Parent Table No." := NpXmlTemplateTrigger."Table No."
                else if XMLTemplate.Get("Xml Template Code") then
                  "Parent Table No." := XMLTemplate."Table No.";
            end;
        }
        field(100;"Parent Table No.";Integer)
        {
            Caption = 'Parent Table No.';
            Description = 'NC1.11';
            Editable = false;
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(120;"Xml Template Table Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Parent Table No.")));
            Caption = 'Xml Template Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(200;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(220;"Table Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(300;"Insert Trigger";Boolean)
        {
            Caption = 'Insert Trigger';
            InitValue = true;
        }
        field(310;"Modify Trigger";Boolean)
        {
            Caption = 'Modify Trigger';
            InitValue = true;
        }
        field(320;"Delete Trigger";Boolean)
        {
            Caption = 'Delete Trigger';
            InitValue = true;
        }
        field(400;Comment;Text[250])
        {
            Caption = 'Comment';
            Description = 'NC1.11';
        }
        field(500;Level;Integer)
        {
            Caption = 'Level';
        }
        field(600;"Generic Parent Codeunit ID";Integer)
        {
            BlankZero = true;
            Caption = 'Generic Parent Codeunit ID';
            Description = 'NC2.01';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NC2.01 [242550]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpXml Trigger Mgt.");
                EventSubscription.SetRange("Published Function",'OnSetupGenericParentTable');
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Generic Parent Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Generic Parent Function" := EventSubscription."Subscriber Function";
                //-NC2.01 [242550]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NC2.01 [242550]
                if "Generic Parent Codeunit ID" = 0 then begin
                  "Generic Parent Function" := '';
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpXml Trigger Mgt.");
                EventSubscription.SetRange("Published Function",'OnSetupGenericParentTable');
                EventSubscription.SetRange("Subscriber Codeunit ID","Generic Parent Codeunit ID");
                if "Generic Parent Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Generic Parent Function");
                EventSubscription.FindFirst;
                //-NC2.01 [242550]
            end;
        }
        field(605;"Generic Parent Codeunit Name";Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Generic Parent Codeunit ID")));
            Caption = 'Generic Parent Codeunit Name';
            Description = 'NC2.01';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610;"Generic Parent Function";Text[250])
        {
            Caption = 'Generic Parent Function';
            Description = 'NC2.01';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NC2.01 [242550]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpXml Trigger Mgt.");
                EventSubscription.SetRange("Published Function",'OnSetupGenericParentTable');
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Generic Parent Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Generic Parent Function" := EventSubscription."Subscriber Function";
                //-NC2.01 [242550]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NC2.01 [242550]
                if "Generic Parent Function" = '' then begin
                  "Generic Parent Codeunit ID" := 0;
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",CODEUNIT::"NpXml Trigger Mgt.");
                EventSubscription.SetRange("Published Function",'OnSetupGenericParentTable');
                EventSubscription.SetRange("Subscriber Codeunit ID","Generic Parent Codeunit ID");
                if "Generic Parent Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Generic Parent Function");
                EventSubscription.FindFirst;
                //-NC2.01 [242550]
            end;
        }
        field(1010;"Last Modified at";DateTime)
        {
            Caption = 'Last Modified at';
            Description = 'NC1.21';
        }
    }

    keys
    {
        key(Key1;"Xml Template Code","Line No.")
        {
        }
        key(Key2;"Table No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
    begin
        NpXmlTemplateTriggerLink.SetRange("Xml Template Code","Xml Template Code");
        NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.","Line No.");
        NpXmlTemplateTriggerLink.DeleteAll(true);
        //-NC1.22
        ////-NC1.21
        //XmlTemplateChanged;
        ////+NC1.21
        //+NC1.22
    end;

    trigger OnInsert()
    begin
        //-NC1.11
        Validate("Parent Line No.");
        //+NC1.11
        TestField("Parent Table No.");
        TestField("Table No.");
        UpdateNaviConnectSetup();
        //-NC1.22
        ////-NC1.21
        //XmlTemplateChanged;
        ////+NC1.21
        "Template Version No." := GetTemplateVersionNo();
        //+NC1.22
    end;

    trigger OnModify()
    var
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
        XMLTemplate: Record "NpXml Template";
        NpXmlTemplateHistory: Record "NpXml Template History";
        RecRef: RecordRef;
        xRecRef: RecordRef;
    begin
        TestField("Parent Table No.");
        TestField("Table No.");
        if xRec."Table No." <> "Table No." then begin
          NpXmlTemplateTriggerLink.SetRange("Xml Template Code","Xml Template Code");
          NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.","Line No.");
          NpXmlTemplateTriggerLink.SetFilter("Table No.",'<>%1',0);
          NpXmlTemplateTriggerLink.ModifyAll("Table No.","Table No.");
        end;

        if (xRec."Table No." <> "Table No.") or
           (xRec."Insert Trigger" <> "Insert Trigger") or
           (xRec."Modify Trigger" <> "Modify Trigger") or
           (xRec."Delete Trigger" <> "Delete Trigger")
          then
            UpdateNaviConnectSetup();

        //-NC1.21
        //-NC1.22
        //XmlTemplateChanged;
        "Template Version No." := GetTemplateVersionNo();
        //+NC1.22
        "Last Modified at" := CreateDateTime(Today,Time);
        //+NC1.21
    end;

    procedure GetParentLineNo() ParentLineNo: Integer
    var
        NpXmlTemplateTrigger: Record "NpXml Template Trigger";
    begin
        Clear(NpXmlTemplateTrigger);
        NpXmlTemplateTrigger.SetRange("Xml Template Code","Xml Template Code");
        NpXmlTemplateTrigger.SetFilter("Line No.",'<%1',"Line No.");
        NpXmlTemplateTrigger.SetFilter(Level,'<%1',Level);
        if NpXmlTemplateTrigger.FindLast then
          exit(NpXmlTemplateTrigger."Line No.");
    end;

    local procedure GetTemplateVersionNo(): Code[20]
    var
        NpXmlTemplate: Record "NpXml Template";
    begin
        //-NC1.22
        NpXmlTemplate.Get("Xml Template Code");
        exit(NpXmlTemplate."Template Version");
        //+NC1.22
    end;

    procedure UpdateNaviConnectSetup()
    var
        DataLogSetup: Record "Data Log Setup (Table)";
        DataLogSubscriber: Record "Data Log Subscriber";
        NaviConnectTaskSetup: Record "Nc Task Setup";
        NpXmlTemplate: Record "NpXml Template";
        SetupChanged: Boolean;
    begin
        if "Table No." = 0 then
          exit;

        NpXmlTemplate.Get("Xml Template Code");
        if not NpXmlTemplate."Transaction Task" then
          exit;

        if "Insert Trigger" or "Modify Trigger" or "Delete Trigger" then begin
          NaviConnectTaskSetup.SetRange("Table No.","Table No.");
          NaviConnectTaskSetup.SetRange("Codeunit ID",CODEUNIT::"NpXml Task Mgt.");
          NaviConnectTaskSetup.SetRange("Task Processor Code",NpXmlTemplate."Task Processor Code");
          if not NaviConnectTaskSetup.FindFirst then begin
            NaviConnectTaskSetup.Init;
            NaviConnectTaskSetup."Entry No." := 0;
            NaviConnectTaskSetup."Table No." := "Table No.";
            NaviConnectTaskSetup."Codeunit ID" := CODEUNIT::"NpXml Task Mgt.";
            NaviConnectTaskSetup."Task Processor Code" := NpXmlTemplate."Task Processor Code";
            NaviConnectTaskSetup.Insert(true);
          end;

          if not DataLogSetup.Get("Table No.") then begin
            DataLogSetup.Init;
            DataLogSetup."Table ID" := "Table No.";
            if "Insert Trigger" then
              DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
            if "Modify Trigger" then
              DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Changes;
            if "Delete Trigger" then
              DataLogSetup."Log Deletion" := DataLogSetup."Log Deletion"::Detailed;
            //-NC2.26 [402488]
            DataLogSetup."Keep Log for" := CreateDateTime(Today,010000T) - CreateDateTime(CalcDate('<-30D>',Today),010000T);
            //+NC2.26 [402488]
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

          //-NC1.22
          //IF NOT DataLogSubscriber.GET(NpXmlTemplate."Task Processor Code","Table No.") THEN BEGIN
          if not DataLogSubscriber.Get(NpXmlTemplate."Task Processor Code","Table No.",'') then begin
          //+NC1.22
            DataLogSubscriber.Init;
            DataLogSubscriber.Code := NpXmlTemplate."Task Processor Code";
            DataLogSubscriber."Table ID" := "Table No.";
            //-NC1.22
            DataLogSubscriber."Company Name" := '';
            //+NC1.22
            DataLogSubscriber.Insert(true);
          end;
        end;
    end;

    procedure UpdateParentInfo()
    var
        NpXmlTemplateTriggerLink: Record "NpXml Template Trigger Link";
    begin
        Validate("Parent Line No.",GetParentLineNo());
        if xRec."Parent Table No." <> "Parent Table No." then begin
          NpXmlTemplateTriggerLink.SetRange("Xml Template Code","Xml Template Code");
          NpXmlTemplateTriggerLink.SetRange("Xml Template Trigger Line No.","Line No.");
          NpXmlTemplateTriggerLink.SetFilter("Parent Table No.",'<>%1',0);
          NpXmlTemplateTriggerLink.ModifyAll("Parent Table No.","Parent Table No.");
        end;
    end;
}

