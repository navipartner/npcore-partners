table 6151522 "Nc Endpoint FTP"
{
    // NC2.01/BR   /20160818  CASE 248630 NaviConnect
    // NC2.01/BR  /20161220  CASE 261431 Added Option SharpSFTP in field type,Added field 170 File Encoding and Removed Chilkat options from field 100 Type

    Caption = 'Nc Endpoint FTP';
    DrillDownPageID = "Nc Endpoint FTP List";
    LookupPageID = "Nc Endpoint FTP List";

    fields
    {
        field(10;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(40;Enabled;Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(50;"Output Nc Task Entry No.";BigInteger)
        {
            Caption = 'Output Nc Task Entry No.';
        }
        field(100;Type;Option)
        {
            Caption = 'Type';
            Description = 'NC2.01';
            OptionCaption = 'DotNet,,,SharpSFTP';
            OptionMembers = DotNet,,,SharpSFTP;
        }
        field(110;Server;Text[250])
        {
            Caption = 'FTP Server';

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(120;Username;Text[100])
        {
            Caption = 'FTP Username';

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(130;Password;Text[100])
        {
            Caption = 'FTP Password';
        }
        field(140;Directory;Text[100])
        {
            Caption = 'FTP Directory';

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(145;Filename;Text[100])
        {
            Caption = 'Filename';
        }
        field(150;Port;Integer)
        {
            Caption = 'FTP Port';
            MinValue = 0;
        }
        field(160;Passive;Boolean)
        {
            Caption = 'FTP Passive';
        }
        field(170;"File Encoding";Option)
        {
            Caption = 'File Encoding';
            Description = 'NC2.01';
            InitValue = ANSI;
            OptionCaption = 'ANSI,Unicode,UTF-8';
            OptionMembers = ANSI,Unicode,UTF8;
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

    trigger OnDelete()
    var
        NcEndpointTriggerLink: Record "Nc Endpoint Trigger Link";
    begin
        NcTriggerTaskMgt.VerifyNoEndpointTriggerLinksExist(GetEndpointTypeCode,Code);
    end;

    trigger OnRename()
    begin
        NcTriggerTaskMgt.VerifyNoEndpointTriggerLinksExist(GetEndpointTypeCode,Code);
    end;

    var
        NcTriggerTaskMgt: Codeunit "Nc Trigger Task Mgt.";

    procedure GetEndpointTypeCode(): Code[20]
    begin
        exit('FTP');
    end;

    procedure ShowEndpointTriggerLinks()
    var
        NcEndpointTriggerLink: Record "Nc Endpoint Trigger Link";
        NcEndpointTriggerLinks: Page "Nc Endpoint Trigger Links";
    begin
        Clear(NcEndpointTriggerLinks);
        NcEndpointTriggerLink.Reset;
        //NcEndpointTriggerLink.SETRANGE("Endpoint Type Code",GetEndpointTypeCode);
        NcEndpointTriggerLink.SetRange("Endpoint Code",Code);
        NcEndpointTriggerLinks.SetTableView(NcEndpointTriggerLink);
        NcEndpointTriggerLinks.RunModal;
    end;

    local procedure UpdateNcEndpoint()
    var
        NcEndpoint: Record "Nc Endpoint";
        ToBeUpdated: Boolean;
        SetupSummary: Text;
    begin
        ToBeUpdated := false;
        if not NcEndpoint.Get(Code) then begin
          NcEndpoint.Init;
          NcEndpoint.Validate(Code,Code);
          NcEndpoint.Validate("Endpoint Type",GetEndpointTypeCode);
          NcEndpoint.Insert;
        end;
        if Description <> NcEndpoint.Description then begin
          NcEndpoint.Description := Description;
          ToBeUpdated := true;
        end;
        SetupSummary := BuildSetupSummary;
        if SetupSummary <> NcEndpoint."Setup Summary" then begin
          NcEndpoint."Setup Summary" := CopyStr(SetupSummary,1,MaxStrLen(NcEndpoint."Setup Summary"));
          ToBeUpdated := true;
        end;
        if Enabled <> NcEndpoint.Enabled then begin
          NcEndpoint.Enabled := Enabled;
          ToBeUpdated := true;
        end;
        if ToBeUpdated then
          NcEndpoint.Modify(true);
    end;

    local procedure BuildSetupSummary(): Text
    var
        TextSetupSummary: Label 'FTP Server: %1, Username %2, Directory %3';
    begin
        exit(StrSubstNo(TextSetupSummary,Server,Username,Directory));
    end;
}

