table 6151522 "NPR Nc Endpoint FTP"
{
    Caption = 'Nc Endpoint FTP';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Nc Endpoint FTP List";
    LookupPageID = "NPR Nc Endpoint FTP List";

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(40; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(50; "Output Nc Task Entry No."; BigInteger)
        {
            Caption = 'Output Nc Task Entry No.';
            DataClassification = CustomerContent;
        }
        field(100; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
            OptionCaption = 'DotNet,,,SharpSFTP';
            OptionMembers = DotNet,,,SharpSFTP;
        }
        field(110; Server; Text[250])
        {
            Caption = 'FTP Server';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(120; Username; Text[100])
        {
            Caption = 'FTP Username';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(130; Password; Text[100])
        {
            Caption = 'FTP Password';
            DataClassification = CustomerContent;
        }
        field(140; Directory; Text[100])
        {
            Caption = 'FTP Directory';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(145; Filename; Text[100])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;
        }
        field(150; Port; Integer)
        {
            Caption = 'FTP Port';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(160; Passive; Boolean)
        {
            Caption = 'FTP Passive';
            DataClassification = CustomerContent;
        }
        field(170; "File Encoding"; Option)
        {
            Caption = 'File Encoding';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
            InitValue = ANSI;
            OptionCaption = 'ANSI,Unicode,UTF-8';
            OptionMembers = ANSI,Unicode,UTF8;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    begin
        NcTriggerTaskMgt.VerifyNoEndpointTriggerLinksExist(GetEndpointTypeCode, Code);
    end;

    trigger OnRename()
    begin
        NcTriggerTaskMgt.VerifyNoEndpointTriggerLinksExist(GetEndpointTypeCode, Code);
    end;

    var
        NcTriggerTaskMgt: Codeunit "NPR Nc Trigger Task Mgt.";

    procedure GetEndpointTypeCode(): Code[20]
    begin
        exit('FTP');
    end;

    procedure ShowEndpointTriggerLinks()
    var
        NcEndpointTriggerLink: Record "NPR Nc Endpoint Trigger Link";
        NcEndpointTriggerLinks: Page "NPR Nc Endpoint Trigger Links";
    begin
        Clear(NcEndpointTriggerLinks);
        NcEndpointTriggerLink.Reset();
        NcEndpointTriggerLink.SetRange("Endpoint Code", Code);
        NcEndpointTriggerLinks.SetTableView(NcEndpointTriggerLink);
        NcEndpointTriggerLinks.RunModal();
    end;

    local procedure UpdateNcEndpoint()
    var
        NcEndpoint: Record "NPR Nc Endpoint";
        ToBeUpdated: Boolean;
        SetupSummary: Text;
    begin
        ToBeUpdated := false;
        if not NcEndpoint.Get(Code) then begin
            NcEndpoint.Init();
            NcEndpoint.Validate(Code, Code);
            NcEndpoint.Validate("Endpoint Type", GetEndpointTypeCode);
            NcEndpoint.Insert();
        end;
        if Description <> NcEndpoint.Description then begin
            NcEndpoint.Description := Description;
            ToBeUpdated := true;
        end;
        SetupSummary := BuildSetupSummary;
        if SetupSummary <> NcEndpoint."Setup Summary" then begin
            NcEndpoint."Setup Summary" := CopyStr(SetupSummary, 1, MaxStrLen(NcEndpoint."Setup Summary"));
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
        exit(StrSubstNo(TextSetupSummary, Server, Username, Directory));
    end;
}

