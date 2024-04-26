table 6150799 "NPR HU EInvoice Local. Setup"
{
    Access = Internal;
    Caption = 'HU EInvoice Localisation Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR HU EInvoice Local. Setup";
    LookupPageId = "NPR HU EInvoice Local. Setup";
    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary key';
        }
        field(10; "Enable HU EInvoice Local"; Boolean)
        {
            Caption = 'Enable HU E-Invoice Localisation';
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