table 6150803 "NPR RS E-Invoice Setup"
{
    Caption = 'RS E-Invoice Setup';
    Access = Internal;
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS E-Invoice Setup";
    LookupPageId = "NPR RS E-Invoice Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable RS E-Invoice"; Boolean)
        {
            Caption = 'Enable RS E-Invoice';
            DataClassification = CustomerContent;
        }
        field(3; "API URL"; Text[100])
        {
            Caption = 'API URL';
            DataClassification = CustomerContent;
        }
        field(4; "API Key"; Text[100])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
            ExtendedDataType = Masked;
        }
        field(5; "Default Unit Of Measure"; Code[10])
        {
            Caption = 'Default Unit Of Measure';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }
        field(10; "Allow Zero Amt. Purchase Doc."; Boolean)
        {
            Caption = 'Allow Zero Amount Purchase Document';
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

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure GetRSEInvoiceSetupWithCheck()
    begin
        Get();
        TestField("API URL");
        TestField("API Key");
    end;
#endif
}