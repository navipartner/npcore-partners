table 6014486 "NPR Exchange Label Setup"
{
    Caption = 'Exchange Label Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "EAN Prefix Exhange Label"; Code[2])
        {
            Caption = 'EAN Prefix Exhange Label';
            DataClassification = CustomerContent;
        }
        field(30; "Exchange Label  No. Series"; Code[20])
        {
            Caption = 'Exchange Label Nos.';
            DataClassification = CustomerContent;
            Description = 'Nummerserie Til Bytte Mærker';
            TableRelation = "No. Series";
        }
        field(40; "Purchace Price Code"; Text[10])
        {
            Caption = 'Purchase Price Code';
            DataClassification = CustomerContent;
            Description = 'Angiver det ord k¢bsprisen skal kodes efter på prislabel';
        }
        field(50; "Exchange Label Exchange Period"; DateFormula)
        {
            Caption = 'Exchange Label Exchange Period';
            DataClassification = CustomerContent;
            Description = 'Bytteperiode for Byttemærker';
        }
        field(60; "Exchange Label Default Date"; Code[10])
        {
            Caption = 'Exchange Label Default Date';
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
