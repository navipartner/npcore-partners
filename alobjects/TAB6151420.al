table 6151420 "Magento Store Item"
{
    // MAG1.16/MHA /20150401  CASE 210548 Object created
    // MAG1.17/TR  /20150522  CASE 210548 Object modified for use
    // MAG1.21/MHA /20151118  CASE 227354 Additional Item and Enabled fields added
    //                                    Field 20 Root Item Group No. added
    //                                    Field 1020 Webshop: Flowfield to MagentoStore.Name added
    //                                    Deleted field 305 Meta Keywords
    // MAG1.22/MHA /20151202  CASE 227354 Updated caption for field 131 Define Webshop Name
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.07/MHA /20170912  CASE 289369 Increased length of field 300 "Meta Title" from 50 to 70
    // MAG9.00.2.11/TS  /20180301  CASE 305585 Added field Visibility.
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Field 1025
    // MAG2.22/MHA /20190614  CASE 358258 Extended field 300 "Meta Title" from 70 to 100
    // MAG2.25/MHA /20200416  CASE 395915 Added FlowField 1030 "Language Codee"

    Caption = 'Magento Store Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(5; "Store Code"; Code[32])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = "Magento Store";
        }
        field(7; "Website Code"; Code[32])
        {
            Caption = 'Website Code';
            DataClassification = CustomerContent;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(20; "Root Item Group No."; Code[20])
        {
            Caption = 'Root Item Group No.';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(100; "Webshop Name"; Text[250])
        {
            Caption = 'Webshop name';
            DataClassification = CustomerContent;
            Description = 'StoreView';
        }
        field(101; "Webshop Name Enabled"; Boolean)
        {
            Caption = 'Webshop Name Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(105; "Webshop Description"; BLOB)
        {
            Caption = 'Webshop Description';
            DataClassification = CustomerContent;
            Description = 'StoreView';
        }
        field(106; "Webshop Description Enabled"; Boolean)
        {
            Caption = 'Webshop Description Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(110; "Webshop Short Desc."; BLOB)
        {
            Caption = 'Webshop Short Description';
            DataClassification = CustomerContent;
            Description = 'StoreView';

            trigger OnLookup()
            var
                RecRef: RecordRef;
            begin
            end;
        }
        field(111; "Webshop Short Desc. Enabled"; Boolean)
        {
            Caption = 'Webshop Short Description Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(130; "Seo Link"; Text[250])
        {
            Caption = 'Seo Link';
            DataClassification = CustomerContent;
            Description = 'StoreView,MAG1.17';

            trigger OnValidate()
            var
                MagentoFunctions: Codeunit "Magento Functions";
            begin
                "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
            end;
        }
        field(131; "Seo Link Enabled"; Boolean)
        {
            Caption = 'Seo Link Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(145; "Display Only"; Boolean)
        {
            Caption = 'Display Only';
            DataClassification = CustomerContent;
            Description = 'StoreView';
        }
        field(146; "Display Only Enabled"; Boolean)
        {
            Caption = 'Display Only Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(200; "Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            Description = 'Website,MAG1.21';
            MinValue = 0;
        }
        field(201; "Unit Price Enabled"; Boolean)
        {
            Caption = 'Unit Price Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(205; "Product New From"; Date)
        {
            Caption = 'Product New From';
            DataClassification = CustomerContent;
            Description = 'Website,MAG1.21';
        }
        field(206; "Product New From Enabled"; Boolean)
        {
            Caption = 'Product New From Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(210; "Product New To"; Date)
        {
            Caption = 'Product New To';
            DataClassification = CustomerContent;
            Description = 'Website,MAG1.21';
        }
        field(211; "Product New To Enabled"; Boolean)
        {
            Caption = 'Product New To Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(225; "Special Price"; Decimal)
        {
            Caption = 'Special Price';
            DataClassification = CustomerContent;
            Description = 'Website,MAG1.21';
        }
        field(226; "Special Price Enabled"; Boolean)
        {
            Caption = 'Special Price Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(230; "Special Price From"; Date)
        {
            Caption = 'Special Price From';
            DataClassification = CustomerContent;
            Description = 'Website,MAG1.21';
        }
        field(231; "Special Price From Enabled"; Boolean)
        {
            Caption = 'Special Price From Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(240; "Special Price To"; Date)
        {
            Caption = 'Special Price To';
            DataClassification = CustomerContent;
            Description = 'Website,MAG1.21';
        }
        field(241; "Special Price To Enabled"; Boolean)
        {
            Caption = 'Special Price To Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(300; "Meta Title"; Text[100])
        {
            Caption = 'Meta Title';
            DataClassification = CustomerContent;
            Description = 'StoreView,MAG2.07,MAG2.22';
        }
        field(301; "Meta Title Enabled"; Boolean)
        {
            Caption = 'Meta Title Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(310; "Meta Description"; Text[250])
        {
            Caption = 'Meta Description';
            DataClassification = CustomerContent;
            Description = 'StoreView';
        }
        field(311; "Meta Description Enabled"; Boolean)
        {
            Caption = 'Meta Description Enabled';
            DataClassification = CustomerContent;
            Description = 'MAG1.21';
        }
        field(1000; "Internet Item"; Boolean)
        {
            CalcFormula = Lookup (Item."Magento Item" WHERE("No." = FIELD("Item No.")));
            Caption = 'Internet Item';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Website Item"; Boolean)
        {
            CalcFormula = Exist ("Magento Website Link" WHERE("Item No." = FIELD("Item No."),
                                                              "Website Code" = FIELD("Website Code")));
            Caption = 'Website Item';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; Webshop; Text[64])
        {
            CalcFormula = Lookup ("Magento Store".Name WHERE(Code = FIELD("Store Code")));
            Caption = 'Webshop';
            Description = 'MAG1.21';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1025; Visibility; Option)
        {
            Caption = 'Visibility';
            DataClassification = CustomerContent;
            Description = 'MAG9.00.2.11';
            OptionCaption = 'Visible,Hidden';
            OptionMembers = Visible,Hidden;
        }
        field(1030; "Language Code"; Code[10])
        {
            CalcFormula = Lookup ("Magento Store"."Language Code" WHERE(Code = FIELD("Store Code")));
            Caption = 'Language Code';
            Description = 'MAG2.25';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Store Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //-MAG1.21
        UpdateWebsiteLink(true);
        //+MAG1.21
    end;

    trigger OnInsert()
    var
        MagentoStore: Record "Magento Store";
    begin
        if MagentoStore.Get("Store Code") then
            "Website Code" := MagentoStore."Website Code";
        //-MAG1.21
        //TransferFromItem();
        UpdateWebsiteLink(false);
        UpdateWebsiteFields();
        //+MAG1.21
    end;

    trigger OnModify()
    begin
        //-MAG1.21
        UpdateWebsiteLink(false);
        UpdateWebsiteFields();
        //+MAG1.21
    end;

    trigger OnRename()
    var
        MagentoStore: Record "Magento Store";
    begin
        if MagentoStore.Get("Store Code") then
            "Website Code" := MagentoStore."Website Code";
    end;

    procedure GetEnabledFieldsCaption() EnabledFieldsCaption: Text
    begin
        //-MAG1.21
        EnabledFieldsCaption := '';
        if "Unit Price Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Unit Price");

        if "Product New From Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Product New From");

        if "Product New To Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Product New To");

        if "Special Price Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Special Price");

        if "Special Price From Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Special Price From");

        if "Special Price To Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Special Price To");

        if "Webshop Name Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Webshop Name");

        if "Webshop Description Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Webshop Description");

        if "Webshop Short Desc. Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Webshop Short Desc.");

        if "Display Only Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Display Only");

        if "Seo Link Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Seo Link");

        if "Meta Title Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Meta Title");

        if "Meta Description Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Meta Description");

        if EnabledFieldsCaption <> '' then
            EnabledFieldsCaption := CopyStr(EnabledFieldsCaption, 2);

        exit(EnabledFieldsCaption);
        //+MAG1.21
    end;

    local procedure UpdateWebsiteField(FieldRef: FieldRef)
    var
        MagentoStoreItem: Record "Magento Store Item";
        RecRef: RecordRef;
        FieldRef2: FieldRef;
    begin
        //-MAG1.21
        MagentoStoreItem.SetRange("Item No.", "Item No.");
        MagentoStoreItem.SetFilter("Store Code", '<>%1', "Store Code");
        MagentoStoreItem.SetRange("Website Code", "Website Code");
        if MagentoStoreItem.IsEmpty then
            exit;

        RecRef.GetTable(MagentoStoreItem);
        FieldRef2 := RecRef.Field(FieldRef.Number);
        FieldRef2.SetFilter('<>%1', FieldRef.Value);
        if not RecRef.FindSet then
            exit;

        repeat
            FieldRef2 := RecRef.Field(FieldRef.Number);
            FieldRef2.Value := FieldRef.Value;
            RecRef.Modify;
        until RecRef.Next = 0;
        //+MAG1.21
    end;

    local procedure UpdateWebsiteFields()
    var
        MagentoStoreItem: Record "Magento Store Item";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        //-MAG1.21
        MagentoStoreItem.SetRange("Item No.", "Item No.");
        MagentoStoreItem.SetFilter("Store Code", '<>%1', "Store Code");
        MagentoStoreItem.SetRange("Website Code", "Website Code");
        if MagentoStoreItem.IsEmpty then
            exit;

        RecRef.GetTable(Rec);

        FieldRef := RecRef.Field(FieldNo("Unit Price"));
        UpdateWebsiteField(FieldRef);

        FieldRef := RecRef.Field(FieldNo("Product New From"));
        UpdateWebsiteField(FieldRef);

        FieldRef := RecRef.Field(FieldNo("Product New To"));
        UpdateWebsiteField(FieldRef);

        FieldRef := RecRef.Field(FieldNo("Special Price"));
        UpdateWebsiteField(FieldRef);

        FieldRef := RecRef.Field(FieldNo("Special Price From"));
        UpdateWebsiteField(FieldRef);

        FieldRef := RecRef.Field(FieldNo("Special Price To"));
        UpdateWebsiteField(FieldRef);
        //+MAG1.21
    end;

    local procedure UpdateWebsiteLink(DeleteTrigger: Boolean)
    var
        MagentoStoreItem: Record "Magento Store Item";
        MagentoWebsite: Record "Magento Website";
        MagentoWebsiteLink: Record "Magento Website Link";
    begin
        //-MAG1.21
        if not MagentoWebsite.Get("Website Code") then
            exit;

        if DeleteTrigger or (not Enabled) then begin
            MagentoStoreItem.SetRange("Item No.", "Item No.");
            MagentoStoreItem.SetFilter("Store Code", '<>%1', "Store Code");
            MagentoStoreItem.SetRange("Website Code", "Website Code");
            MagentoStoreItem.SetRange(Enabled, true);
            if MagentoStoreItem.FindFirst then
                exit;

            MagentoWebsiteLink.SetRange("Website Code", "Website Code");
            MagentoWebsiteLink.SetRange("Item No.", "Item No.");
            MagentoWebsiteLink.DeleteAll;
            exit;
        end;

        if MagentoWebsiteLink.Get("Website Code", "Item No.", '') then
            exit;

        MagentoWebsiteLink.Init;
        MagentoWebsiteLink."Website Code" := "Website Code";
        MagentoWebsiteLink."Item No." := "Item No.";
        MagentoWebsiteLink."Variant Code" := '';
        MagentoWebsiteLink.Insert;
        //+MAG1.21
    end;
}

