#if not BC17
table 6150938 "NPR Spfy Metafield Definition"
{
    Access = Internal;
    Caption = 'Shopify Metafield Definition';
    DataClassification = CustomerContent;
    TableType = Temporary;
    LookupPageId = "NPR Spfy Metafields";
    DrillDownPageId = "NPR Spfy Metafields";

    fields
    {
        field(1; ID; Text[30])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(2; "Key"; Text[80])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; Namespace; Text[255])
        {
            Caption = 'Namespace';
            DataClassification = CustomerContent;
        }
        field(6; "Owner Type"; Enum "NPR Spfy Metafield Owner Type")
        {
            Caption = 'Owner Type';
            DataClassification = CustomerContent;
        }
        field(7; Type; Text[50])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(9; "Validation Definition GID"; Text[80])
        {
            Caption = 'Validation Definition GID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}
#endif