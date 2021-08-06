table 6151550 "NPR NpXml Setup"
{
    Caption = 'NpXml Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "NpXml Enabled"; Boolean)
        {
            Caption = 'NpXml Enabled';
            DataClassification = CustomerContent;
        }
        field(60; "Template Version Prefix"; Code[5])
        {
            Caption = 'Template Version Prefix';
            DataClassification = CustomerContent;
            Description = 'NC1.21';

            trigger OnValidate()
            var
                NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
                InvalidVersionTagErr: Label 'Invalid version tag';
            begin
                if (StrPos("Template Version Prefix", NcSetupMgt.NaviConnectDefaultTaskProcessorCode()) = 1) then
                    Error(InvalidVersionTagErr);
            end;
        }
        field(65; "Template Version No."; Integer)
        {
            Caption = 'Template Version No.';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
            InitValue = 1;
            MinValue = 1;
            NotBlank = true;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}
