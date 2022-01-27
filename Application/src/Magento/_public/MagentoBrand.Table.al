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
                PictureName := MagentoFunctions.LookupPicture(Enum::"NPR Magento Picture Type"::Brand, Picture);
                if PictureName <> '' then
                    Picture := CopyStr(PictureName, 1, MaxStrLen(Picture));
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
                "Seo Link" := CopyStr(MagentoFunctions.SeoFormat("Seo Link"), 1, MaxStrLen("Seo Link"));
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

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                PictureName := MagentoFunctions.LookupPicture(Enum::"NPR Magento Picture Type"::Brand, "Logo Picture");
                if PictureName <> '' then
                    "Logo Picture" := CopyStr(PictureName, 1, MaxStrLen("Logo Picture"));
            end;
        }
        field(105; "Sorting"; Integer)
        {
            Caption = 'Sorting';
            DataClassification = CustomerContent;
        }
        field(110; "Meta Title"; Text[100])
        {
            Caption = 'Meta Title';
            DataClassification = CustomerContent;
        }
        field(115; "Meta Description"; Text[250])
        {
            Caption = 'Meta Description';
            DataClassification = CustomerContent;
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
        "Seo Link" := CopyStr(MagentoFunctions.SeoFormat("Seo Link"), 1, MaxStrLen("Seo Link"));
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
        "Seo Link" := CopyStr(MagentoFunctions.SeoFormat("Seo Link"), 1, MaxStrLen("Seo Link"));
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
