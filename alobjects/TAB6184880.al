table 6184880 "FTP Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'FTP Setup';
    Permissions = TableData "Service Password"=rimd;

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(5;"FTP Host";Text[250])
        {
            Caption = 'FTP Host URI';
        }
        field(10;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(20;Timeout;Integer)
        {
            Caption = 'Timeout';
            Description = 'Miliseconds';
        }
        field(30;User;Text[50])
        {
            Caption = 'User Name';
        }
        field(40;"Service Password";Guid)
        {
            Caption = 'Service Password';
        }
        field(50;"Storage On Server";Text[250])
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
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        NoPassErr: Label 'No password found';

    procedure HandlePassword(Password: Text): Text
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.SetRange(Key,"Service Password");
        if Password = '' then begin
          if ServicePassword.FindFirst then
            ServicePassword.Delete;
          exit;
        end;

        if not ServicePassword.FindFirst then begin
          "Service Password" := CreateGuid;
          Modify;
          ServicePassword.Key := "Service Password";
          ServicePassword.Insert;
        end;

        ServicePassword.SavePassword(Password);
        ServicePassword.Modify;
    end;

    procedure GetPassword(): Text
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.SetRange(Key,"Service Password");

        if not ServicePassword.FindFirst then
          Error(NoPassErr);

        exit(ServicePassword.GetPassword());
    end;
}

