table 6151410 "NPR Magento Inv. Company"
{
    Caption = 'Magento Inventory Company';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Company;
        }
        field(5; "Location Filter"; Text[100])
        {
            Caption = 'Location Filter';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                Location: Record Location;
            begin
                if "Company Name" <> CompanyName then
                    if not Location.ChangeCompany("Company Name") then
                        exit;

                if PAGE.RunModal(PAGE::"Location List", Location) <> ACTION::LookupOK then
                    exit;

                "Location Filter" := Location.Code;
            end;

            trigger OnValidate()
            begin
                "Location Filter" := UpperCase("Location Filter");
            end;
        }
        field(10; "Api Url"; Text[250])
        {
            Caption = 'Api Url';
            DataClassification = CustomerContent;
        }
        field(15; "Api Username"; Text[100])
        {
            Caption = 'Api Username';
            DataClassification = CustomerContent;
        }
        field(20; "Api Password"; Text[100])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'IsolatedStorage is in use.';
            Caption = 'Api Password';
            DataClassification = CustomerContent;
        }
        field(21; "Api Password Key"; Guid)
        {
            Caption = 'Api Password Key';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(25; "Api Domain"; Text[100])
        {
            Caption = 'Api Domain';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Company Name")
        {
        }
    }

    trigger OnInsert()
    begin
        SetApiUrl();
    end;

    trigger OnModify()
    begin
        SetApiUrl();
    end;

    procedure SetApiUrl()
    var
        Position: Integer;
    begin
        if "Api Url" = '' then begin
            "Api Url" := CopyStr(GetUrl(CLIENTTYPE::SOAP, "Company Name", OBJECTTYPE::Codeunit, CODEUNIT::"NPR Magento Webservice"), 1, MaxStrLen("Api Url"));
            if StrPos(LowerCase("Api Url"), 'https://') = 1 then begin
                Position := StrPos(CopyStr("Api Url", StrLen('https://')), ':');
                "Api Url" := 'https://localhost.dynamics-retail.com:' + CopyStr("Api Url", StrLen('https://') + Position);
            end;
        end;
    end;

    [NonDebuggable]
    procedure SetApiPassword(NewPassword: Text)
    begin
        if IsNullGuid("Api Password Key") then
            "Api Password Key" := CreateGuid();

        if not EncryptionEnabled() then
            IsolatedStorage.Set("Api Password Key", NewPassword, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted("Api Password Key", NewPassword, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetApiPassword() PasswordValue: Text
    begin
        IsolatedStorage.Get("Api Password Key", DataScope::Company, PasswordValue);
    end;

    [NonDebuggable]
    procedure HasApiPassword(): Boolean
    begin
        exit(GetApiPassword() <> '');
    end;

    procedure RemoveApiPassword()
    begin
        IsolatedStorage.Delete("Api Password Key", DataScope::Company);
        Clear("Api Password Key");
    end;
}