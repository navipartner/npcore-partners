table 6060085 "NPR BG Fiscalization Setup"
{
    Access = Internal;
    Caption = 'BG Fiscalization Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR BG Fiscalization Setup";
    LookupPageId = "NPR BG Fiscalization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable BG Fiscal"; Boolean)
        {
            Caption = 'Enable BG Fiscalization';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-11-28';
            ObsoleteReason = 'SIS Integration specific field is introduced.';
        }
        field(10; "BG SIS Fiscal Enabled"; Boolean)
        {
            Caption = 'BG SIS Fiscalization Enabled';
            DataClassification = CustomerContent;
        }
        field(15; "BG SIS Print EFT Information"; Boolean)
        {
            Caption = 'BG SIS Print EFT Information';
            DataClassification = CustomerContent;
        }
        field(20; "BG SIS on PDF"; Boolean)
        {
            Caption = 'BG SIS on PDF';
            DataClassification = CustomerContent;
        }
        field(30; "BG SIS Auto Set Cashier"; Boolean)
        {
            Caption = 'BG SIS Auto Set Cashier';
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