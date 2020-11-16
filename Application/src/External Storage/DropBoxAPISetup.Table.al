table 6184870 "NPR DropBox API Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'DropBox API Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Account Code"; Code[10])
        {
            Caption = 'DropBox Account Code';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; Token; Guid)
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
            Description = 'https://www.dropbox.com/developers/apps -> select your app -> OAuth 2 section -> Generate Access token';
        }
        field(20; Timeout; Integer)
        {
            Caption = 'Timeout';
            DataClassification = CustomerContent;
            Description = 'Miliseconds';
        }
        field(30; "Storage On Server"; Text[250])
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
        key(Key1; "Account Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        NoTokenErr: Label 'No token found';
        BadDirErr: Label 'Directory "%1" does not exist on the server, please check %2';

    procedure HandleToken(DropBoxToken: Text): Text
    begin
        if DropBoxToken = '' then begin
            if IsolatedStorage.Contains(Token, DataScope::Company) then
                IsolatedStorage.Delete(Token, DataScope::Company);
            exit;
        end;

        if not IsolatedStorage.Contains(Token, DataScope::Company) then begin
            Token := CreateGuid();
            Modify;
        end;
        IsolatedStorage.Set(Token, DropBoxToken, DataScope::Company);
    end;

    procedure GetToken(): Text
    var
        TokenValue: Text;
    begin
        if not IsolatedStorage.Get(Token, DataScope::Company, TokenValue) then
            Error(NoTokenErr);

        exit(TokenValue);
    end;
}

