table 6151491 "Raptor Setup"
{
    // NPR5.51/CLVA/20190710 CASE 355871 Object created
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements
    // NPR5.53/ALPO/20191128 CASE 379012 Raptor tracking integration: send info about sold products to Raptor
    // NPR5.54/ALPO/20200227 CASE 355871 Possibility to define Raptor tracking service types
    // NPR5.55/ALPO/20200422 CASE 400925 Exclude webshop sales from data sent to Raptor

    Caption = 'Raptor Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Enable Raptor Functions"; Boolean)
        {
            Caption = 'Enable Raptor Functions';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Enable Raptor Functions" then
                    InitUrls(false)
                else
                    "Send Data to Raptor" := false;
            end;
        }
        field(11; "API Key"; Text[50])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
        }
        field(12; "Base Url"; Text[250])
        {
            Caption = 'Base Url';
            DataClassification = CustomerContent;
        }
        field(13; "Customer Guid"; Text[50])
        {
            Caption = 'Customer Guid';
            DataClassification = CustomerContent;
        }
        field(14; "Customer ID"; Integer)
        {
            Caption = 'Customer ID';
            DataClassification = CustomerContent;
        }
        field(15; "Tracking Service Url"; Text[250])
        {
            Caption = 'Tracking Service Url';
            DataClassification = CustomerContent;
        }
        field(16; "Send Data to Raptor"; Boolean)
        {
            Caption = 'Send Data to Raptor';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Send Data to Raptor" then
                    TestField("Enable Raptor Functions", true);
                RaptorMgt.SetupJobQueue("Send Data to Raptor");
            end;
        }
        field(17; "Tracking Service Type"; Text[30])
        {
            Caption = 'Tracking Service Type';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                RaptorMgt.SelectTrackingServiceType("Tracking Service Type");  //NPR5.54 [355871]
            end;

            trigger OnValidate()
            begin
                RaptorMgt.ValidateTrackingServiceType("Tracking Service Type");  //NPR5.54 [355871]
            end;
        }
        field(18; "Exclude Webshop Sales"; Boolean)
        {
            Caption = 'Exclude Webshop Sales';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(19; "Webshop Salesperson Filter"; Text[250])
        {
            Caption = 'Webshop Salesperson Filter';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
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
        InitUrls(false);
    end;

    var
        RaptorMgt: Codeunit "Raptor Management";

    procedure InitUrls(Force: Boolean)
    begin
        if ("Base Url" = '') or Force then
            "Base Url" := 'https://api.raptorsmartadvisor.com';
        if ("Tracking Service Url" = '') or Force then
            "Tracking Service Url" := 'https://t.raptorsmartadvisor.com';
        //-NPR5.54 [355871]
        if ("Tracking Service Type" = '') or Force then
            RaptorMgt.GetDefaultTrackingServiceType("Tracking Service Type");
        //+NPR5.54 [355871]
    end;
}

