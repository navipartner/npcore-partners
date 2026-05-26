#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6059911 "NPR Ecom Related Document"
{
    Access = Internal;
    Caption = 'Ecommerce Related Document';
    DataClassification = CustomerContent;
    TableType = Temporary;
    LookupPageId = "NPR Ecom Related Documents";
    DrillDownPageId = "NPR Ecom Related Documents";

    fields
    {
        field(1; "Document Type"; Text[50])
        {
            Caption = 'Document Type';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Source Record Id"; RecordId)
        {
            Caption = 'Source Record Id';
        }
    }

    keys
    {
        key(PK; "Source Record Id")
        {
            Clustered = true;
        }
    }
}
#endif
