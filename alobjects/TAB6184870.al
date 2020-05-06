table 6184870 "DropBox API Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'DropBox API Setup';
    Permissions = TableData "Service Password"=rimd;

    fields
    {
        field(1;"Account Code";Code[10])
        {
            Caption = 'DropBox Account Code';
        }
        field(5;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(10;Token;Guid)
        {
            Caption = 'Token';
            Description = 'https://www.dropbox.com/developers/apps -> select your app -> OAuth 2 section -> Generate Access token';
        }
        field(20;Timeout;Integer)
        {
            Caption = 'Timeout';
            Description = 'Miliseconds';
        }
        field(30;"Storage On Server";Text[250])
        {
            Caption = 'Server files location';

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
        key(Key1;"Account Code")
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
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.SetRange(Key,Token);
        if DropBoxToken = '' then begin
          if ServicePassword.FindFirst then
            ServicePassword.Delete;
          exit;
        end;

        if not ServicePassword.FindFirst then begin
          Token := CreateGuid;
          Modify;
          ServicePassword.Key := Token;
          ServicePassword.Insert;
        end;

        ServicePassword.SavePassword(DropBoxToken);
        ServicePassword.Modify;
    end;

    procedure GetToken(): Text
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.SetRange(Key,Token);

        if not ServicePassword.FindFirst then
          Error(NoTokenErr);

        exit(ServicePassword.GetPassword());
    end;
}

