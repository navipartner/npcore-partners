table 6151200 "NpCs Store Workflow Relation"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190822  CASE 364557 Added field 300 "Processing Print Template"
    // NPR5.54/MHA /20200130  CASE 378956 Added Store Notification Fields

    Caption = 'Collect Workflow Relation';

    fields
    {
        field(1;"Store Code";Code[20])
        {
            Caption = 'Store Code';
            NotBlank = true;
            TableRelation = "NpCs Store";
        }
        field(5;"Workflow Code";Code[20])
        {
            Caption = 'Workflow Code';
            NotBlank = true;
            TableRelation = "NpCs Workflow";

            trigger OnValidate()
            var
                NpCsWorkflow: Record "NpCs Workflow";
            begin
                if "Workflow Code" = '' then
                  exit;

                NpCsWorkflow.Get("Workflow Code");
                "Send Notification from Store" := NpCsWorkflow."Send Notification from Store";
                "Notify Customer via E-mail" := NpCsWorkflow."Notify Customer via E-mail";
                "E-mail Template (Pending)" := NpCsWorkflow."E-mail Template (Pending)";
                "E-mail Template (Confirmed)" := NpCsWorkflow."E-mail Template (Confirmed)";
                "E-mail Template (Rejected)" := NpCsWorkflow."E-mail Template (Rejected)";
                "E-mail Template (Expired)" := NpCsWorkflow."E-mail Template (Expired)";
                "Notify Customer via Sms" := NpCsWorkflow."Notify Customer via Sms";
                "Sms Template (Pending)" := NpCsWorkflow."Sms Template (Pending)";
                "Sms Template (Confirmed)" := NpCsWorkflow."Sms Template (Confirmed)";
                "Sms Template (Rejected)" := NpCsWorkflow."Sms Template (Rejected)";
                "Sms Template (Expired)" := NpCsWorkflow."Sms Template (Expired)";
                //-NPR5.54 [378956]
                "Notify Store via E-mail" := NpCsWorkflow."Notify Store via E-mail";
                "Store E-mail Temp. (Pending)" := NpCsWorkflow."Store E-mail Temp. (Pending)";
                "Store E-mail Temp. (Expired)" := NpCsWorkflow."Store E-mail Temp. (Expired)";
                "Notify Store via Sms" := NpCsWorkflow."Notify Store via Sms";
                "Store Sms Template (Pending)" := NpCsWorkflow."Store Sms Template (Pending)";
                "Store Sms Template (Expired)" := NpCsWorkflow."Store Sms Template (Expired)";
                //+NPR5.54 [378956]
            end;
        }
        field(10;"Workflow Description";Text[50])
        {
            CalcFormula = Lookup("NpCs Workflow".Description WHERE (Code=FIELD("Workflow Code")));
            Caption = 'Workflow Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(125;"Send Notification from Store";Boolean)
        {
            Caption = 'Send Notification from Store';
        }
        field(130;"Notify Customer via E-mail";Boolean)
        {
            Caption = 'Notify Customer via E-mail';
        }
        field(135;"E-mail Template (Pending)";Code[20])
        {
            Caption = 'E-mail Template (Pending)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                EmailTemplateHeader: Record "E-mail Template Header";
                NpCsStore: Record "NpCs Store";
            begin
                NpCsStore.Get("Store Code");
                if EmailTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if EmailTemplateHeader.Get("E-mail Template (Pending)") then;
                EmailTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,EmailTemplateHeader) = ACTION::LookupOK then
                  Validate("E-mail Template (Pending)",EmailTemplateHeader.Code);
            end;
        }
        field(140;"E-mail Template (Confirmed)";Code[20])
        {
            Caption = 'E-mail Template (Confirmed)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                EmailTemplateHeader: Record "E-mail Template Header";
                NpCsStore: Record "NpCs Store";
            begin
                NpCsStore.Get("Store Code");
                if EmailTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if EmailTemplateHeader.Get("E-mail Template (Confirmed)") then;
                EmailTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,EmailTemplateHeader) = ACTION::LookupOK then
                  Validate("E-mail Template (Confirmed)",EmailTemplateHeader.Code);
            end;
        }
        field(145;"E-mail Template (Rejected)";Code[20])
        {
            Caption = 'E-mail Template (Rejected)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                EmailTemplateHeader: Record "E-mail Template Header";
                NpCsStore: Record "NpCs Store";
            begin
                NpCsStore.Get("Store Code");
                if EmailTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if EmailTemplateHeader.Get("E-mail Template (Rejected)") then;
                EmailTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,EmailTemplateHeader) = ACTION::LookupOK then
                  Validate("E-mail Template (Rejected)",EmailTemplateHeader.Code);
            end;
        }
        field(150;"E-mail Template (Expired)";Code[20])
        {
            Caption = 'E-mail Template (Expired)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                EmailTemplateHeader: Record "E-mail Template Header";
                NpCsStore: Record "NpCs Store";
            begin
                NpCsStore.Get("Store Code");
                if EmailTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if EmailTemplateHeader.Get("E-mail Template (Expired)") then;
                EmailTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,EmailTemplateHeader) = ACTION::LookupOK then
                  Validate("E-mail Template (Expired)",EmailTemplateHeader.Code);
            end;
        }
        field(155;"Notify Customer via Sms";Boolean)
        {
            Caption = 'Notify Customer via Sms';
        }
        field(160;"Sms Template (Pending)";Code[10])
        {
            Caption = 'Sms Template (Pending)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsStore: Record "NpCs Store";
                SMSTemplateHeader: Record "SMS Template Header";
            begin
                NpCsStore.Get("Store Code");
                if SMSTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if SMSTemplateHeader.Get("Sms Template (Pending)") then;
                SMSTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,SMSTemplateHeader) = ACTION::LookupOK then
                  Validate("Sms Template (Pending)",SMSTemplateHeader.Code);
            end;
        }
        field(165;"Sms Template (Confirmed)";Code[10])
        {
            Caption = 'Sms Template (Confirmed)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsStore: Record "NpCs Store";
                SMSTemplateHeader: Record "SMS Template Header";
            begin
                NpCsStore.Get("Store Code");
                if SMSTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if SMSTemplateHeader.Get("Sms Template (Confirmed)") then;
                SMSTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,SMSTemplateHeader) = ACTION::LookupOK then
                  Validate("Sms Template (Confirmed)",SMSTemplateHeader.Code);
            end;
        }
        field(170;"Sms Template (Rejected)";Code[10])
        {
            Caption = 'Sms Template (Rejected)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsStore: Record "NpCs Store";
                SMSTemplateHeader: Record "SMS Template Header";
            begin
                NpCsStore.Get("Store Code");
                if SMSTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if SMSTemplateHeader.Get("Sms Template (Rejected)") then;
                SMSTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,SMSTemplateHeader) = ACTION::LookupOK then
                  Validate("Sms Template (Rejected)",SMSTemplateHeader.Code);
            end;
        }
        field(175;"Sms Template (Expired)";Code[10])
        {
            Caption = 'Sms Template (Expired)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsStore: Record "NpCs Store";
                SMSTemplateHeader: Record "SMS Template Header";
            begin
                NpCsStore.Get("Store Code");
                if SMSTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if SMSTemplateHeader.Get("Sms Template (Expired)") then;
                SMSTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,SMSTemplateHeader) = ACTION::LookupOK then
                  Validate("Sms Template (Expired)",SMSTemplateHeader.Code);
            end;
        }
        field(300;"Processing Print Template";Code[20])
        {
            Caption = 'Processing Print Template';
            Description = 'NPR5.51';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsStore: Record "NpCs Store";
                RPTemplateHeader: Record "RP Template Header";
            begin
                //-NPR5.51 [364557]
                NpCsStore.Get("Store Code");
                if RPTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if RPTemplateHeader.Get("Processing Print Template") then;
                RPTemplateHeader.SetRange("Table ID",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,RPTemplateHeader) = ACTION::LookupOK then
                  Validate("Processing Print Template",RPTemplateHeader.Code);
                //+NPR5.51 [364557]
            end;
        }
        field(305;"Delivery Print Template (POS)";Code[20])
        {
            Caption = 'Delivery Print Template (POS)';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsStore: Record "NpCs Store";
                RPTemplateHeader: Record "RP Template Header";
            begin
                NpCsStore.Get("Store Code");
                if RPTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if RPTemplateHeader.Get("Delivery Print Template (POS)") then;
                RPTemplateHeader.SetRange("Table ID",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,RPTemplateHeader) = ACTION::LookupOK then
                  Validate("Delivery Print Template (POS)",RPTemplateHeader.Code);
            end;
        }
        field(310;"Delivery Print Template (S.)";Code[20])
        {
            Caption = 'Delivery Template (Sales Document)';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsStore: Record "NpCs Store";
                RPTemplateHeader: Record "RP Template Header";
            begin
                NpCsStore.Get("Store Code");
                if RPTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if RPTemplateHeader.Get("Delivery Print Template (S.)") then;
                RPTemplateHeader.SetRange("Table ID",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,RPTemplateHeader) = ACTION::LookupOK then
                  Validate("Delivery Print Template (S.)",RPTemplateHeader.Code);
            end;
        }
        field(400;"Notify Store via E-mail";Boolean)
        {
            Caption = 'Notify Store via E-mail';
            Description = 'NPR5.54';
        }
        field(410;"Store E-mail Temp. (Pending)";Code[20])
        {
            Caption = 'Store E-mail Template (Pending)';
            Description = 'NPR5.54';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                EmailTemplateHeader: Record "E-mail Template Header";
                NpCsStore: Record "NpCs Store";
            begin
                //-NPR5.54 [378956]
                NpCsStore.Get("Store Code");
                if EmailTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if EmailTemplateHeader.Get("Store E-mail Temp. (Pending)") then;
                EmailTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,EmailTemplateHeader) = ACTION::LookupOK then
                  Validate("Store E-mail Temp. (Pending)",EmailTemplateHeader.Code);
                //+NPR5.54 [378956]
            end;
        }
        field(420;"Store E-mail Temp. (Expired)";Code[20])
        {
            Caption = 'Store E-mail Template (Expired)';
            Description = 'NPR5.54';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                EmailTemplateHeader: Record "E-mail Template Header";
                NpCsStore: Record "NpCs Store";
            begin
                //-NPR5.54 [378956]
                NpCsStore.Get("Store Code");
                if EmailTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if EmailTemplateHeader.Get("Store E-mail Temp. (Expired)") then;
                EmailTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,EmailTemplateHeader) = ACTION::LookupOK then
                  Validate("Store E-mail Temp. (Expired)",EmailTemplateHeader.Code);
                //+NPR5.54 [378956]
            end;
        }
        field(430;"Notify Store via Sms";Boolean)
        {
            Caption = 'Notify Store via Sms';
            Description = 'NPR5.54';
        }
        field(440;"Store Sms Template (Pending)";Code[10])
        {
            Caption = 'Store Sms Template (Pending)';
            Description = 'NPR5.54';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsStore: Record "NpCs Store";
                SMSTemplateHeader: Record "SMS Template Header";
            begin
                //-NPR5.54 [378956]
                NpCsStore.Get("Store Code");
                if SMSTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if SMSTemplateHeader.Get("Store Sms Template (Pending)") then;
                SMSTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,SMSTemplateHeader) = ACTION::LookupOK then
                  Validate("Store Sms Template (Pending)",SMSTemplateHeader.Code);
                //+NPR5.54 [378956]
            end;
        }
        field(450;"Store Sms Template (Expired)";Code[10])
        {
            Caption = 'Store Sms Template (Expired)';
            Description = 'NPR5.54';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                NpCsStore: Record "NpCs Store";
                SMSTemplateHeader: Record "SMS Template Header";
            begin
                //-NPR5.54 [378956]
                NpCsStore.Get("Store Code");
                if SMSTemplateHeader.ChangeCompany(NpCsStore."Company Name") then;

                if SMSTemplateHeader.Get("Store Sms Template (Expired)") then;
                SMSTemplateHeader.SetRange("Table No.",DATABASE::"NpCs Document");
                if PAGE.RunModal(0,SMSTemplateHeader) = ACTION::LookupOK then
                  Validate("Store Sms Template (Expired)",SMSTemplateHeader.Code);
                //+NPR5.54 [378956]
            end;
        }
    }

    keys
    {
        key(Key1;"Store Code","Workflow Code")
        {
        }
    }

    fieldgroups
    {
    }
}

