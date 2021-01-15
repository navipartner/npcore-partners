table 6151416 "NPR Magento Brand"
{
    Caption = 'Magento Brand';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Brands";
    LookupPageID = "NPR Magento Brands";

    fields
    {
        field(1; Id; Code[20])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Description = 'MAG2.26';
            NotBlank = true;
        }
        field(2; Name; Text[32])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Seo Link" = '' then
                    Validate("Seo Link", Name);
            end;
        }
        field(3; Picture; Text[250])
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Brand", Picture);
                if PictureName <> '' then
                    Picture := PictureName;
            end;
        }
        field(9; Description; BLOB)
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Seo Link"; Text[200])
        {
            Caption = 'Seo Link';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
            end;
        }
        field(15; "Short Description"; BLOB)
        {
            DataClassification = CustomerContent;
        }
        field(100; "Logo Picture"; Text[250])
        {
            Caption = 'Logo';
            DataClassification = CustomerContent;
            Description = 'MAG1.01';

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Brand", "Logo Picture");
                if PictureName <> '' then
                    "Logo Picture" := PictureName;
            end;
        }
        field(105; "Sorting"; Integer)
        {
            Caption = 'Sorting';
            DataClassification = CustomerContent;
            Description = 'MAG1.20';
        }
        field(110; "Meta Title"; Text[100])
        {
            Caption = 'Meta Title';
            DataClassification = CustomerContent;
            Description = 'MAG2.00,MAG2.22';
        }
        field(115; "Meta Description"; Text[250])
        {
            Caption = 'Meta Description';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
        key(Key2; Name)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Id, Name)
        {
        }
    }

    trigger OnDelete()
    var
        Item: Record Item;
    begin
        Item.SetRange("NPR Magento Brand", Id);
        Item.ModifyAll("NPR Magento Brand", '', false);
    end;

    trigger OnInsert()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if MagentoSetupMgt.HasSetupBrands() then
            exit;

        TestField(Name);

        if "Seo Link" = '' then
            "Seo Link" := Name;
        "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
    end;

    trigger OnModify()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if MagentoSetupMgt.HasSetupBrands() then
            exit;

        TestField(Name);

        if "Seo Link" = '' then
            "Seo Link" := Name;
        "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
    end;

    trigger OnRename()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if MagentoSetupMgt.HasSetupBrands() then
            exit;

        TestField(Name);
    end;

    var
        MagentoFunctions: Codeunit "NPR Magento Functions";
}