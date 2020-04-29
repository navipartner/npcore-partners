table 6059820 "Transactional Email Setup"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created

    Caption = 'Transactional Email Setup';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(10;"Client ID";Text[100])
        {
            Caption = 'Client ID';
        }
        field(20;"API Key";Text[100])
        {
            Caption = 'API Key';
        }
        field(30;"API URL";Text[250])
        {
            Caption = 'API URL';
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

    trigger OnInsert()
    var
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
    begin
        if "API URL" = '' then
          "API URL" := CampaignMonitorMgt.DefaultAPIURL;
    end;
}

