table 6151524 "Nc Endpoint File"
{
    // NC2.01/BR  /20160829  CASE 248630 NaviConnect
    // NC2.12/MHA /20180502  CASE 313362 Added field 105 "Client Path"

    Caption = 'Nc Endpoint File';
    DrillDownPageID = "Nc Endpoint File List";
    LookupPageID = "Nc Endpoint File List";

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
        field(100;Path;Text[250])
        {
            Caption = 'Path';

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(105;"Client Path";Boolean)
        {
            Caption = 'Client Path';
            Description = 'NC2.12';
        }
        field(110;Filename;Text[250])
        {
            Caption = 'Filename';

            trigger OnValidate()
            begin
                UpdateNcEndpoint;
            end;
        }
        field(120;"Handle Exiting File";Option)
        {
            Caption = 'Handle Exiting File';
            OptionCaption = 'Keep Existing File,Replace Existing File,Add Timestamp Suffix to New File';
            OptionMembers = KeepExisting,Replace,AddSuffix;
        }
        field(130;"File Encoding";Option)
        {
            Caption = 'File Encoding';
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
        exit('FILE');
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
        TextSetupSummary: Label 'File Export Path %1, Namename %2.';
    begin
        exit(StrSubstNo(TextSetupSummary,Path,Filename));
    end;
}

