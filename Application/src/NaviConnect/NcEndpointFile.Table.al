table 6151524 "NPR Nc Endpoint File"
{
    Caption = 'Nc Endpoint File';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Nc Endpoint File List";
    LookupPageID = "NPR Nc Endpoint File List";

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
        field(100; Path; Text[250])
        {
            Caption = 'Path';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(105; "Client Path"; Boolean)
        {
            Caption = 'Client Path';
            DataClassification = CustomerContent;
            Description = 'NC2.12';
        }
        field(110; Filename; Text[250])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(120; "Handle Exiting File"; Option)
        {
            Caption = 'Handle Exiting File';
            DataClassification = CustomerContent;
            OptionCaption = 'Keep Existing File,Replace Existing File,Add Timestamp Suffix to New File';
            OptionMembers = KeepExisting,Replace,AddSuffix;
        }
        field(130; "File Encoding"; Option)
        {
            Caption = 'File Encoding';
            DataClassification = CustomerContent;
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
        exit('FILE');
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
        TextSetupSummary: Label 'File Export Path %1, Namename %2.';
    begin
        exit(StrSubstNo(TextSetupSummary, Path, Filename));
    end;
}

