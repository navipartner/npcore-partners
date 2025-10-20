table 6150838 "NPR ES Fiscalization Setup"
{
    Access = Internal;
    Caption = 'ES Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR ES Fiscalization Setup";
    LookupPageId = "NPR ES Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "ES Fiscal Enabled"; Boolean)
        {
            Caption = 'ES Fiscalization Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ESAuditMgt: Codeunit "NPR ES Audit Mgt.";
            begin
                ESAuditMgt.InitESFiscalJobQueues("ES Fiscal Enabled");
            end;
        }
        field(20; "Test Fiskaly API URL"; Text[250])
        {
            Caption = 'Test Fiskaly API URL';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(30; "Live Fiskaly API URL"; Text[250])
        {
            Caption = 'Live Fiskaly API URL';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(40; Live; Boolean)
        {
            Caption = 'Live';
            DataClassification = CustomerContent;
        }
        field(50; "Simplified Invoice Limit"; Decimal)
        {
            Caption = 'Simplified Invoice Limit';
            DataClassification = CustomerContent;
        }
        field(60; "Invoice Description"; Text[250])
        {
            Caption = 'Invoice Description';
            DataClassification = CustomerContent;
        }
        field(70; "Print Thermal Receipt On Sale"; Boolean)
        {
            Caption = 'Print Thermal Receipt On Sale';
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

    internal procedure GetWithCheck()
    begin
        Get();

        if Live then
            TestField("Live Fiskaly API URL")
        else
            TestField("Test Fiskaly API URL");
    end;
}