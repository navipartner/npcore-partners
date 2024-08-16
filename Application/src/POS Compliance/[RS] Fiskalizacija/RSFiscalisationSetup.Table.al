table 6059861 "NPR RS Fiscalisation Setup"
{
    Access = Internal;
    Caption = 'RS Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS Fiscalisation Setup";
    LookupPageId = "NPR RS Fiscalisation Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(3; "Enable RS Fiscal"; Boolean)
        {
            Caption = 'Enable RS Fiscalization';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
            begin
                Modify();
                RSAuditMgt.AddRSAuditBackgroundJobQueue("Enable RS Fiscal", false)
            end;
        }
        field(6; "Fiscal Proforma on Sales Doc."; Boolean)
        {
            Caption = 'Fiscal Proforma on Sales Documents';
            DataClassification = CustomerContent;
        }
        field(10; "Sandbox URL"; Text[100])
        {
            Caption = 'Sandbox URL';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "Sandbox URL".EndsWith('/') then
                    "Sandbox URL" := CopyStr("Sandbox URL".TrimEnd('/'), 1, MaxStrLen("Sandbox URL"));
            end;
        }
        field(11; "Exclude Token from URL"; Boolean)
        {
            Caption = 'Exclude Token from URL';
            DataClassification = CustomerContent;
        }
        field(20; "Allow Offline Use"; Boolean)
        {
            Caption = 'Allow Offline Use';
            DataClassification = CustomerContent;
        }
        field(21; Training; Boolean)
        {
            Caption = 'Training';
            DataClassification = CustomerContent;
        }
        field(50; "Configuration URL"; Text[250])
        {
            Caption = 'Configuration URL';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(51; "Organization Name"; Text[250])
        {
            Caption = 'Organization Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(52; "Server Time Zone"; Text[250])
        {
            Caption = 'Server Time Zone';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(53; Country; Text[250])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(54; City; Text[250])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(55; Street; Text[250])
        {
            Caption = 'Street';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(56; "TaxPayer Admin Portal URL"; Text[250])
        {
            Caption = 'TaxPayer Admin Portal URL';
            DataClassification = CustomerContent;
            Editable = false;
            ExtendedDatatype = URL;
        }
        field(57; "TaxCore API URL"; Text[250])
        {
            Caption = 'TaxCore API URL';
            DataClassification = CustomerContent;
            Editable = false;
            ExtendedDatatype = URL;
        }
        field(58; "VSDC URL"; Text[250])
        {
            Caption = 'VSDC URL';
            DataClassification = CustomerContent;
            Editable = false;
            ExtendedDatatype = URL;
        }
        field(59; "Root URL"; Text[250])
        {
            Caption = 'Root URL';
            DataClassification = CustomerContent;
            Editable = false;
            ExtendedDatatype = URL;
        }
        field(60; "Environment Name"; Text[250])
        {
            Caption = 'Environment Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(61; "NPT Server URL"; Text[250])
        {
            Caption = 'NPT Server URL';
            DataClassification = CustomerContent;
            Editable = false;
            ExtendedDatatype = URL;
        }
        field(62; "Report E-Mail Selection"; Enum "NPR RS Report E-Mail Selection")
        {
            Caption = 'Report Mail Selection';
            DataClassification = CustomerContent;
        }
        field(63; "E-Mail Subject"; Text[250])
        {
            Caption = 'E-Mail Subject';
            DataClassification = CustomerContent;
        }
        field(70; "Print Item No. on Receipt"; Boolean)
        {
            Caption = 'Print Item No. on Receipt';
            DataClassification = CustomerContent;
        }
        field(71; "Print Item Desc. 2 on Receipt"; Boolean)
        {
            Caption = 'Print Item Description 2 on Receipt';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}