table 6151522 "NPR Nc Endpoint FTP"
{
    Caption = 'Nc Endpoint FTP';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Nc Endpoint FTP List";
    LookupPageID = "NPR Nc Endpoint FTP List";
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Creating Use "NPR FTP Connection" or "NPR SFTP Connection" ';

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
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';

            trigger OnValidate()
            begin
                UpdateNcEndpoint();
            end;
        }
        field(40; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';

            trigger OnValidate()
            begin
                UpdateNcEndpoint();
            end;
        }
        field(50; "Output Nc Task Entry No."; BigInteger)
        {
            Caption = 'Output Nc Task Entry No.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';
        }
        field(100; Type; Option)
        {
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Option type to be removed. Use new enum field "Protocol Type" instead.';
            Caption = 'Type';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
            OptionCaption = 'DotNet,,,SharpSFTP';
            OptionMembers = DotNet,,,SharpSFTP;
        }
        field(101; "Protocol Type"; Enum "NPR Nc FTP Protocol Type")
        {
            Caption = 'Protocol Type';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';

            trigger OnValidate()
            begin
                if (Rec."Protocol Type" <> xRec."Protocol Type") and (Rec."Protocol Type" = Rec."Protocol Type"::SFTP) then
                    Rec.EncMode := Rec.EncMode::None;
            end;
        }
        field(110; Server; Text[250])
        {
            Caption = 'FTP Server';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';

            trigger OnValidate()
            begin
                UpdateNcEndpoint();
            end;
        }
        field(120; Username; Text[100])
        {
            Caption = 'FTP Username';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';

            trigger OnValidate()
            begin
                UpdateNcEndpoint();
            end;

        }
        field(130; Password; Text[100])
        {
            Caption = 'FTP Password';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';
        }
        field(140; Directory; Text[100])
        {
            Caption = 'FTP Directory';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';

            trigger OnValidate()
            begin
                UpdateNcEndpoint();
            end;
        }
        field(145; Filename; Text[100])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';
        }
        field(150; Port; Integer)
        {
            Caption = 'FTP Port';
            DataClassification = CustomerContent;
            MinValue = 0;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moving connection info to dedicated tables FTP and SFTP Connection.';
        }
        field(160; Passive; Boolean)
        {
            Caption = 'FTP Passive';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moving connection info to dedicated tables FTP and SFTP Connection.';
        }
        field(161; EncMode; Enum "NPR Nc FTP Encryption mode")
        {
            Caption = 'FTP Encryption mode';
            InitValue = "None";
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';
        }
        field(170; "File Encoding"; Option)
        {
            Caption = 'File Encoding';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
            InitValue = ANSI;
            OptionCaption = 'ANSI,Unicode,UTF-8';
            OptionMembers = ANSI,Unicode,UTF8;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';
        }
        field(175; "File Temporary Extension"; Text[4])
        {
            Caption = 'File Temporary Extension';
            DataClassification = CustomerContent;
            CharAllowed = 'az';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaceing Endpoint FTP with FTP and SFTP Connection.';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    internal procedure GetEndpointTypeCode(): Code[20]
    begin
        exit('FTP');
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
        TextSetupSummaryLbl: Label 'FTP Server: %1, Username %2, Directory %3', Comment = '%1=Server;%2=Username;%3=Directory';
    begin
        exit(StrSubstNo(TextSetupSummaryLbl, Server, Username, Directory));
    end;
}

