table 6151170 "NPR NpGp POS Sales Setup"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales
    // NPR5.51/ALST/20190904  CASE 337539 obscured password
    // NPR5.52/ALST/20191009  CASE 372010 added permissions to service password

    Caption = 'Global POS Sales Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpGp Global POSSalesSetups";
    LookupPageID = "NPR NpGp Global POSSalesSetups";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Company Name"; Text[100])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            TableRelation = Company;

            trigger OnValidate()
            var
                Company: Record Company;
                NpGpPOSSalesSyncMgt: Codeunit "NPR NpGp POS Sales Sync Mgt.";
                Url: Text;
            begin
                if StrLen("Company Name") > MaxStrLen(Company.Name) then
                    exit;
                if not Company.Get("Company Name") then
                    exit;

                NpGpPOSSalesSyncMgt.InitGlobalPosSalesService();
                Url := GetUrl(CLIENTTYPE::SOAP, Company.Name, OBJECTTYPE::Codeunit, CODEUNIT::"NPR NpGp POS Sales WS");
                "Service Url" := CopyStr(Url, 1, MaxStrLen("Service Url"));
            end;
        }
        field(10; "Service Url"; Text[250])
        {
            Caption = 'Service Url';
            DataClassification = CustomerContent;
        }
        field(15; "Service Username"; Text[250])
        {
            Caption = 'Service Username';
            DataClassification = CustomerContent;
        }
        field(20; "Service Password"; Guid)
        {
            Caption = 'Service Password';
            DataClassification = CustomerContent;
        }
        field(25; "Sync POS Sales Immediately"; Boolean)
        {
            Caption = 'Sync POS Sales Immediately';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure HandlePassword(Password: Text): Text
    begin
        if Password = '' then begin
            if IsolatedStorage.Contains("Service Password", DataScope::Company) then
                IsolatedStorage.Delete("Service Password", DataScope::Company);
            exit;
        end;

        if not IsolatedStorage.Contains("Service Password", DataScope::Company) then begin
            "Service Password" := CreateGuid();
            Modify;
        end;
        IsolatedStorage.Set("Service Password", Password, DataScope::Company);

    end;
}

