table 6184860 "NPR Azure Storage API Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Azure Storage API Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Account Name"; Text[24])
        {
            Caption = 'Azure Account Name';
            DataClassification = CustomerContent;
        }
        field(5; "Account Description"; Text[250])
        {
            Caption = 'Azure Account Description';
            DataClassification = CustomerContent;
        }
        field(10; "Access Key"; Guid)
        {
            Caption = 'Shared Access Key';
            DataClassification = CustomerContent;
            Description = 'Storage account -> Settings section -> Access keys -> key1 or key2';
        }
        field(20; "Admin Key"; Guid)
        {
            Caption = 'Search App Admin Key';
            DataClassification = CustomerContent;
            Description = 'Search Service -> Settings section -> Keys -> "Primary admin key" or "Secondary admin key"';
        }
        field(30; Timeout; Integer)
        {
            Caption = 'Timeout';
            DataClassification = CustomerContent;
            Description = 'Miliseconds. Accounts are set up per region, might affect request timeout threshold';
        }
        field(40; "Storage On Server"; Text[250])
        {
            Caption = 'Server files location';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                FileManagement: Codeunit "File Management";
            begin
                if not FileManagement.ServerDirectoryExists("Storage On Server") then
                    Error(BadDirErr, "Storage On Server", TableCaption);

                if CopyStr("Storage On Server", StrLen("Storage On Server")) <> '\' then
                    "Storage On Server" += '\';
            end;
        }
    }

    keys
    {
        key(Key1; "Account Name")
        {
        }
    }

    fieldgroups
    {
    }

    var
        NoKeyErr: Label 'No key found';
        BadDirErr: Label 'Directory "%1" does not exist on the server, please check %2';

    procedure HandleAccessKey("Key": Text): Text
    begin
        if "Key" = '' then begin
            if IsolatedStorage.Contains("Access Key", DataScope::Company) then
                IsolatedStorage.Delete("Access Key", DataScope::Company);
            exit;
        end;

        if not IsolatedStorage.Contains("Access Key", DataScope::Company) then begin
            "Access Key" := CreateGuid();
            Modify;
        end;
        IsolatedStorage.Set("Access Key", "Key", DataScope::Company);
    end;

    procedure GetAccessKey(): Text
    var
        TokenValue: Text;
    begin
        if not IsolatedStorage.Get("Access Key", DataScope::Company, TokenValue) then
            Error(NoKeyErr);

        exit(TokenValue);
    end;

    procedure HandleAdminKey("Key": Text): Text
    begin
        if "Key" = '' then begin
            if IsolatedStorage.Contains("Admin Key", DataScope::Company) then
                IsolatedStorage.Delete("Admin Key", DataScope::Company);
            exit;
        end;

        if not IsolatedStorage.Contains("Admin Key", DataScope::Company) then begin
            "Admin Key" := CreateGuid();
            Modify;
        end;
        IsolatedStorage.Set("Admin Key", "Key", DataScope::Company);
    end;

    procedure GetAdminKey(): Text
    var
        TokenValue: Text;
    begin
        if not IsolatedStorage.Get("Admin Key", DataScope::Company, TokenValue) then
            Error(NoKeyErr);

        exit(TokenValue);
    end;
}