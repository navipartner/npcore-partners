table 6151402 "NPR Magento Website"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150113  CASE 199932 Changed Table Structure
    // MAG1.21/TS/20151016  CASE 225180  Added Website Code Filter to Page Part
    // MAG1.22/MHA/20151202  CASE 225180 Added missing MagentoStore.DELETEALL
    // MAG1.22/TS/20150107  CASE 228446 Added Global Dimension 1 Code and Global Dimension 2 Code
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.01/TS/20161014  CASE 254886 Added Location Code
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // MAG2.26/MHA /20200505  CASE 402828 Added field 40 "Sales Order No. Series"

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
            Description = 'MAG1.22';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(30; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            Description = 'MAG1.22';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(35; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            Description = 'MAG2.01';
            TableRelation = Location.Code;
        }
        field(40; "Sales Order No. Series"; Code[20])
        {
            Caption = 'Sales Order No. Series';
            DataClassification = CustomerContent;
            Description = 'MAG2.26';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        MagentoStore: Record "NPR Magento Store";
    begin
        //-MAG1.21
        MagentoStore.SetRange("Website Code", Code);
        //+MAG1.21
        //-MAG1.22
        MagentoStore.DeleteAll;
        //+MAG1.22
    end;
}

