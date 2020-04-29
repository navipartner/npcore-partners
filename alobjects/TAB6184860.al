table 6184860 "Azure Storage API Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Azure Storage API Setup';

    fields
    {
        field(1;"Account Name";Text[24])
        {
            Caption = 'Azure Account Name';
        }
        field(5;"Account Description";Text[250])
        {
            Caption = 'Azure Account Description';
        }
        field(10;"Access Key";Guid)
        {
            Caption = 'Shared Access Key';
            Description = 'Storage account -> Settings section -> Access keys -> key1 or key2';
        }
        field(20;"Admin Key";Guid)
        {
            Caption = 'Search App Admin Key';
            Description = 'Search Service -> Settings section -> Keys -> "Primary admin key" or "Secondary admin key"';
        }
        field(30;Timeout;Integer)
        {
            Caption = 'Timeout';
            Description = 'Miliseconds. Accounts are set up per region, might affect request timeout threshold';
        }
        field(40;"Storage On Server";Text[250])
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
        key(Key1;"Account Name")
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
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.SetRange(Key,"Access Key");
        if Key = '' then begin
          if ServicePassword.FindFirst then
            ServicePassword.Delete;
          exit;
        end;

        if not ServicePassword.FindFirst then begin
          "Access Key" := CreateGuid;
          Modify;
          ServicePassword.Key := "Access Key";
          ServicePassword.Insert;
        end;

        ServicePassword.SavePassword(Key);
        ServicePassword.Modify;
    end;

    procedure GetAccessKey(): Text
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.SetRange(Key,"Access Key");

        if not ServicePassword.FindFirst then
          Error(NoKeyErr);

        exit(ServicePassword.GetPassword());
    end;

    procedure HandleAdminKey("Key": Text): Text
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.SetRange(Key,"Admin Key");
        if Key = '' then begin
          if ServicePassword.FindFirst then
            ServicePassword.Delete;
          exit;
        end;

        if not ServicePassword.FindFirst then begin
          "Admin Key" := CreateGuid;
          Modify;
          ServicePassword.Key := "Admin Key";
          ServicePassword.Insert;
        end;

        ServicePassword.SavePassword(Key);
        ServicePassword.Modify;
    end;

    procedure GetAdminKey(): Text
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.SetRange(Key,"Admin Key");

        if not ServicePassword.FindFirst then
          Error(NoKeyErr);

        exit(ServicePassword.GetPassword());
    end;
}

