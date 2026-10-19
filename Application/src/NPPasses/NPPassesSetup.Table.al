table 6248729 "NPR NP Passes Setup"
{
    Access = Internal;
    Caption = 'NP Passes Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NP Passes Setup";
    LookupPageID = "NPR NP Passes Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SecretRequiredErr: Label '%1 must be entered before %2 can be enabled.', Comment = '%1 = Signing Secret field caption, %2 = NP Passes Setup table caption';
            begin
                if (not Enabled) then
                    exit;
                TestField("Base URL");
                if (not HasSigningSecret()) then
                    Error(SecretRequiredErr, FieldCaption("Signing Secret Key"), TableCaption());
            end;
        }
        field(20; "Base URL"; Text[250])
        {
            Caption = 'Base URL';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Base URL" = '') then
                    exit;
                while "Base URL".EndsWith('/') do
                    "Base URL" := CopyStr(CopyStr("Base URL", 1, StrLen("Base URL") - 1), 1, MaxStrLen("Base URL"));
            end;
        }
        field(40; "Signing Secret Key"; Guid)
        {
            Caption = 'Signing Secret';
            DataClassification = SystemMetadata;
        }
        field(50; "Design List URL"; Text[250])
        {
            Caption = 'Design List URL';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                InvalidUrlErr: Label '%1 must be either %2 or %3.', Comment = '%1 = Design List URL field caption, %2 = production URL, %3 = prelive URL';
            begin
                if ("Design List URL" = '') then
                    exit;
                while "Design List URL".EndsWith('/') do
                    "Design List URL" := CopyStr(CopyStr("Design List URL", 1, StrLen("Design List URL") - 1), 1, MaxStrLen("Design List URL"));
                if ("Design List URL" <> ProdDesignListUrl()) and
                   ("Design List URL" <> PreliveDesignListUrl()) then
                    Error(InvalidUrlErr, FieldCaption("Design List URL"), ProdDesignListUrl(), PreliveDesignListUrl());
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    internal procedure SetSigningSecret(NewSecret: SecretText)
    begin
        if (IsNullGuid("Signing Secret Key")) then
            "Signing Secret Key" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted("Signing Secret Key", NewSecret, DataScope::Company)
        else
            IsolatedStorage.Set("Signing Secret Key", NewSecret, DataScope::Company);
    end;

    internal procedure DeleteSigningSecret()
    var
        DisableFirstErr: Label 'Disable %1 before removing %2; wallet links cannot be issued without it.', Comment = '%1 = NP Passes Setup table caption, %2 = Signing Secret field caption';
    begin
        if (Enabled) then
            Error(DisableFirstErr, TableCaption(), FieldCaption("Signing Secret Key"));
        if (IsNullGuid("Signing Secret Key")) then
            exit;
        if (IsolatedStorage.Contains("Signing Secret Key", DataScope::Company)) then
            IsolatedStorage.Delete("Signing Secret Key", DataScope::Company);
    end;

    internal procedure HasSigningSecret(): Boolean
    begin
        if (IsNullGuid("Signing Secret Key")) then
            exit(false);
        exit(IsolatedStorage.Contains("Signing Secret Key", DataScope::Company));
    end;

    internal procedure GetSigningSecret() Secret: SecretText
    begin
        if (IsNullGuid("Signing Secret Key")) then
            exit;
        if (not IsolatedStorage.Get("Signing Secret Key", DataScope::Company, Secret)) then
            Clear(Secret);
    end;

    internal procedure GetDesignListUrl(): Text[250]
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if ("Design List URL" <> '') and
           EnvironmentInformation.IsSaaS() and EnvironmentInformation.IsSandbox() then
            if ("Design List URL" = ProdDesignListUrl()) or ("Design List URL" = PreliveDesignListUrl()) then
                exit("Design List URL");
        if EnvironmentInformation.IsSaaS() and EnvironmentInformation.IsSandbox() then
            exit(PreliveDesignListUrl());
        exit(ProdDesignListUrl());
    end;

    local procedure ProdDesignListUrl(): Text[250]
    begin
        exit('https://bc-designer-api.npretail.app');
    end;

    local procedure PreliveDesignListUrl(): Text[250]
    begin
        exit('https://bc-designer-api.npretail-prelive.app');
    end;
}
