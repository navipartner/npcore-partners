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

    Caption = 'Magento Brand';
    DrillDownPageID = "Magento Brands";
    LookupPageID = "Magento Brands";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Name;Text[32])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                //-MAG1.02
                if "Seo Link" = '' then
                  Validate("Seo Link",Name);
                //+MAG1.02
            end;
        }
        field(3;Picture;Text[250])
        {
            Caption = 'Picture';

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                //-MAG1.14
                ///PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Manufacturer",MAXSTRLEN(Picture));
                PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Brand",Picture);
                //+MAG1.14
                if PictureName <> '' then
                  Picture := PictureName;
            end;
        }
        field(9;Description;BLOB)
        {
            Caption = 'Description';
        }
        field(10;"Seo Link";Text[200])
        {
            Caption = 'Seo Link';

            trigger OnValidate()
            begin
                //-MAG1.02
                "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
                //+MAG1.02
            end;
        }
        field(100;"Logo Picture";Text[250])
        {
            Caption = 'Logo';
            Description = 'MAG1.01';

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                //-MAG1.14
                ////-MAG1.04
                //PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Manufacturer",MAXSTRLEN("Logo Picture"));
                ////+MAG1.04
                PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Brand","Logo Picture");
                //+MAG1.14
                if PictureName <> '' then
                  "Logo Picture" := PictureName;
            end;
        }
        field(105;Sorting;Integer)
        {
            Caption = 'Sorting';
            Description = 'MAG1.20';
        }
        field(110;"Meta Title";Text[100])
        {
            Caption = 'Meta Title';
            Description = 'MAG2.00,MAG2.22';
        }
        field(115;"Meta Description";Text[250])
        {
            Caption = 'Meta Description';
            Description = 'MAG2.00';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;Name)
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
        Item.SetRange("Magento Brand",Code);
        Item.ModifyAll("Magento Brand",'',false);
        //+MAG2.00
    end;

    trigger OnInsert()
    begin
        TestField(Name);

        //-MAG1.02
        if "Seo Link" = '' then
          "Seo Link" := Name;
        "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
        //+MAG1.02
    end;

    trigger OnModify()
    begin
        TestField(Name);

        //-MAG1.02
        if "Seo Link" = '' then
          "Seo Link" := Name;
        "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
        //+MAG1.02
    end;

    trigger OnRename()
    begin
        TestField(Name);
    end;

    var
        MagentoFunctions: Codeunit "Magento Functions";
}

