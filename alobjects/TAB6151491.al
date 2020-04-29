table 6151491 "Raptor Setup"
{
    // NPR5.51/CLVA/20190710 CASE 355871 Object created
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements
    // NPR5.53/ALPO/20191128 CASE 379012 Raptor tracking integration: send info about sold products to Raptor
    // NPR5.54/ALPO/20200227 CASE 355871 Possibility to define Raptor tracking service types

    Caption = 'Raptor Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Enable Raptor Functions";Boolean)
        {
            Caption = 'Enable Raptor Functions';

            trigger OnValidate()
            begin
                if "Enable Raptor Functions" then
                  InitUrls(false)
                else
                  "Send Data to Raptor" := false;
            end;
        }
        field(11;"API Key";Text[50])
        {
            Caption = 'API Key';
        }
        field(12;"Base Url";Text[250])
        {
            Caption = 'Base Url';
        }
        field(13;"Customer Guid";Text[50])
        {
            Caption = 'Customer Guid';
        }
        field(14;"Customer ID";Integer)
        {
            Caption = 'Customer ID';
        }
        field(15;"Tracking Service Url";Text[250])
        {
            Caption = 'Tracking Service Url';
        }
        field(16;"Send Data to Raptor";Boolean)
        {
            Caption = 'Send Data to Raptor';

            trigger OnValidate()
            begin
                if "Send Data to Raptor" then
                  TestField("Enable Raptor Functions",true);
                RaptorMgt.SetupJobQueue("Send Data to Raptor");
            end;
        }
        field(17;"Tracking Service Type";Text[30])
        {
            Caption = 'Tracking Service Type';

            trigger OnLookup()
            begin
                RaptorMgt.SelectTrackingServiceType("Tracking Service Type");  //NPR5.54 [355871]
            end;

            trigger OnValidate()
            begin
                RaptorMgt.ValidateTrackingServiceType("Tracking Service Type");  //NPR5.54 [355871]
            end;
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

