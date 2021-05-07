table 6151402 "NPR Magento Website"
{
    Caption = 'Magento Website';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Website List";
    LookupPageID = "NPR Magento Website List";

    fields
    {
        field(1; "Code"; Code[32])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Name; Text[64])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(20; "Default Website"; Boolean)
        {
            Caption = 'Std. Website';
            DataClassification = CustomerContent;
        }
        field(25; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(30; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(35; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(40; "Sales Order No. Series"; Code[20])
        {
            Caption = 'Sales Order No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(45; "Customer No. Series"; Code[20])
        {
            Caption = 'Customer No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    var
        MagentoStore: Record "NPR Magento Store";
    begin
        MagentoStore.SetRange("Website Code", Code);
        MagentoStore.DeleteAll();
    end;
}
