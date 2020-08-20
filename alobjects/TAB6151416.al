table 6151416 "Magento Brand"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150201  CASE 199932 Added Field 100 "Logo Picture"
    // MAG1.02/MH/20150204  CASE 199932 Change Seo Link Update
    // MAG1.04/MH/20150209  CASE 199932 Corrected MAXSTRLEN on Logo
    // MAG1.14/MH/20150429  CASE 212526 Changed parameters for LookupPicture() to PictureType, PictureName
    // MAG1.20/TS/20151005 CASE 224193  Added field 105 Sorting
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // MAG2.22/MHA /20190614  CASE 358258 Extended field 110 "Meta Title" from 50 to 100
    // MAG2.23/BHR /20190730  CASE 362728 Created New Field 15 Short Description
    // MAG2.26/MHA /20200601  CASE 404580 Renamed Field 1 from "Code" to "Id"

    Caption = 'Magento Brand';
    DataClassification = CustomerContent;
    DrillDownPageID = "Magento Brands";
    LookupPageID = "Magento Brands";

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
                //-MAG1.02
                if "Seo Link" = '' then
                    Validate("Seo Link", Name);
                //+MAG1.02
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
                //-MAG1.14
                ///PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Manufacturer",MAXSTRLEN(Picture));
                PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Brand", Picture);
                //+MAG1.14
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
                //-MAG1.02
                "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
                //+MAG1.02
            end;
        }
        field(15; "Short Description"; BLOB)
        {
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
                //-MAG1.14
                ////-MAG1.04
                //PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Manufacturer",MAXSTRLEN("Logo Picture"));
                ////+MAG1.04
                PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Brand", "Logo Picture");
                //+MAG1.14
                if PictureName <> '' then
                    "Logo Picture" := PictureName;
            end;
        }
        field(105; Sorting; Integer)
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
    }

    trigger OnDelete()
    var
        Item: Record Item;
    begin
        //-MAG2.00
        // //-MAG1.04
        // Item.SETRANGE("Webshop Manufacturer",Code);
        // Item.MODIFYALL("Webshop Manufacturer",'',FALSE);
        // //+MAG1.04
        Item.SetRange("Magento Brand", Id);
        Item.ModifyAll("Magento Brand", '', false);
        //+MAG2.00
    end;

    trigger OnInsert()
    var
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        //-MAG2.26 [404580]
        if MagentoSetupMgt.HasSetupBrands() then
            exit;
        //+MAG2.26 [404580]

        TestField(Name);

        //-MAG1.02
        if "Seo Link" = '' then
            "Seo Link" := Name;
        "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
        //+MAG1.02
    end;

    trigger OnModify()
    var
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        //-MAG2.26 [404580]
        if MagentoSetupMgt.HasSetupBrands() then
            exit;
        //+MAG2.26 [404580]

        TestField(Name);

        //-MAG1.02
        if "Seo Link" = '' then
            "Seo Link" := Name;
        "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
        //+MAG1.02
    end;

    trigger OnRename()
    var
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        //-MAG2.26 [404580]
        if MagentoSetupMgt.HasSetupBrands() then
            exit;
        //+MAG2.26 [404580]

        TestField(Name);
    end;

    var
        MagentoFunctions: Codeunit "Magento Functions";
}

