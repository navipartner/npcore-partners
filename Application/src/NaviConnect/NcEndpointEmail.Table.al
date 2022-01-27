table 6151523 "NPR Nc Endpoint E-mail"
{
    Access = Internal;
    Caption = 'Nc Endpoint E-mail';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Nc Endpoint E-mail List";
    LookupPageID = "NPR Nc Endpoint E-mail List";

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
                UpdateNcEndpoint();
            end;
        }
        field(40; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateNcEndpoint();
            end;
        }
        field(50; "Output Nc Task Entry No."; BigInteger)
        {
            Caption = 'Output Nc Task Entry No.';
            DataClassification = CustomerContent;
        }
        field(110; "Recipient E-Mail Address"; Text[80])
        {
            Caption = 'Recipient E-Mail Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            begin
                UpdateNcEndpoint();
            end;
        }
        field(115; "CC E-Mail Address"; Text[80])
        {
            Caption = 'CC E-Mail Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(116; "BCC E-Mail Address"; Text[80])
        {
            Caption = 'BCC E-Mail Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(120; "Subject Text"; Text[150])
        {
            Caption = 'Subject Text';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateNcEndpoint();
            end;
        }
        field(130; "Body Text"; Text[250])
        {
            Caption = 'Body Text';
            DataClassification = CustomerContent;
        }
        field(140; "Filename Attachment"; Text[250])
        {
            Caption = 'Filename Attachment';
            DataClassification = CustomerContent;
        }
        field(150; "Sender Name"; Text[80])
        {
            Caption = 'Sender Name';
            DataClassification = CustomerContent;
        }
        field(160; "Sender E-Mail Address"; Text[80])
        {
            Caption = 'Sender E-Mail Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
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
        NcTriggerTaskMgt.VerifyNoEndpointTriggerLinksExist(GetEndpointTypeCode(), Code);
    end;

    trigger OnRename()
    begin
        NcTriggerTaskMgt.VerifyNoEndpointTriggerLinksExist(GetEndpointTypeCode(), Code);
    end;

    var
        NcTriggerTaskMgt: Codeunit "NPR Nc Trigger Task Mgt.";

    procedure GetEndpointTypeCode(): Code[20]
    begin
        exit('EMAIL');
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
            NcEndpoint.Validate("Endpoint Type", GetEndpointTypeCode());
            NcEndpoint.Insert();
        end;
        if Description <> NcEndpoint.Description then begin
            NcEndpoint.Description := Description;
            ToBeUpdated := true;
        end;
        SetupSummary := BuildSetupSummary();
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
        TextSetupSummaryLbl: Label 'E-Mail Recipient %1, subject %2.', Comment = '%1="NPR Nc Endpoint E-mail"."Recipient E-Mail Address";%2="NPR Nc Endpoint E-mail"."Subject Text"';
    begin
        exit(StrSubstNo(TextSetupSummaryLbl, "Recipient E-Mail Address", "Subject Text"));
    end;
}

