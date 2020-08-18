table 6184880 "FTP Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created
    // NPR5.55/ALST/20200709 CASE 408285 added port number

    Caption = 'FTP Setup';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(5; "FTP Host"; Text[250])
        {
            Caption = 'FTP Host URI';
        }
        field(10; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(20; Timeout; Integer)
        {
            Caption = 'Timeout';
            Description = 'Miliseconds';
        }
        field(30; User; Text[50])
        {
            Caption = 'User Name';
        }
        field(40; "Service Password"; Guid)
        {
            Caption = 'Service Password';
        }
        field(45;"Port Number";Integer)
        {
            Caption = 'Port Number';
            Description = 'NPR5.55 only needed for SSH, for all rest it can be included in the URI';
        }
        field(50; "Storage On Server"; Text[250])
        {
            Caption = 'Server files location';

            trigger OnValidate()
            var
                FileManagement: Codeunit "File Management";
                BadDirErr: Label 'Directory "%1" does not exist on the server, please check %2';
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
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        NoPassErr: Label 'No password found';

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

    procedure GetPassword(): Text
    var
        PasswordValue: Text;
    begin
        if not IsolatedStorage.Get("Service Password", DataScope::Company, PasswordValue) then
            Error(NoPassErr);

        exit(PasswordValue);
    end;
}

