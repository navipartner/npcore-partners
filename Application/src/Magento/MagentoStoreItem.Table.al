table 6151420 "NPR Magento Store Item"
{
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
            TableRelation = "NPR Magento Store";
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
        }
        field(20; "Root Item Group No."; Code[20])
        {
            Caption = 'Root Item Group No.';
            DataClassification = CustomerContent;
        }
        field(100; "Webshop Name"; Text[250])
        {
            Caption = 'Webshop name';
            DataClassification = CustomerContent;
        }
        field(101; "Webshop Name Enabled"; Boolean)
        {
            Caption = 'Webshop Name Enabled';
            DataClassification = CustomerContent;
        }
        field(105; "Webshop Description"; BLOB)
        {
            Caption = 'Webshop Description';
            DataClassification = CustomerContent;
        }
        field(106; "Webshop Description Enabled"; Boolean)
        {
            Caption = 'Webshop Description Enabled';
            DataClassification = CustomerContent;
        }
        field(110; "Webshop Short Desc."; BLOB)
        {
            Caption = 'Webshop Short Description';
            DataClassification = CustomerContent;
        }
        field(111; "Webshop Short Desc. Enabled"; Boolean)
        {
            Caption = 'Webshop Short Description Enabled';
            DataClassification = CustomerContent;
        }
        field(130; "Seo Link"; Text[250])
        {
            Caption = 'Seo Link';
            DataClassification = CustomerContent;
            Description = 'StoreView,MAG1.17';

            trigger OnValidate()
            var
                MagentoFunctions: Codeunit "NPR Magento Functions";
            begin
                "Seo Link" := MagentoFunctions.SeoFormat("Seo Link");
            end;
        }
        field(131; "Seo Link Enabled"; Boolean)
        {
            Caption = 'Seo Link Enabled';
            DataClassification = CustomerContent;
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
        }
        field(150; "Display Only Text"; Text[250])
        {
            Caption = 'Display Only Text';
            DataClassification = CustomerContent;
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
        }
        field(1000; "Internet Item"; Boolean)
        {
            CalcFormula = Lookup(Item."NPR Magento Item" WHERE("No." = FIELD("Item No.")));
            Caption = 'Internet Item';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Website Item"; Boolean)
        {
            CalcFormula = Exist("NPR Magento Website Link" WHERE("Item No." = FIELD("Item No."),
                                                              "Website Code" = FIELD("Website Code")));
            Caption = 'Website Item';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; Webshop; Text[64])
        {
            CalcFormula = Lookup("NPR Magento Store".Name WHERE(Code = FIELD("Store Code")));
            Caption = 'Webshop';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1025; Visibility; Enum "NPR Mag. Store Item Visibility")
        {
            Caption = 'Visibility';
            DataClassification = CustomerContent;
        }
        field(1030; "Language Code"; Code[10])
        {
            CalcFormula = Lookup("NPR Magento Store"."Language Code" WHERE(Code = FIELD("Store Code")));
            Caption = 'Language Code';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Store Code")
        {
        }
    }

    trigger OnDelete()
    begin
        UpdateWebsiteLink(true);
    end;

    trigger OnInsert()
    var
        MagentoStore: Record "NPR Magento Store";
    begin
        if MagentoStore.Get("Store Code") then
            "Website Code" := MagentoStore."Website Code";
        UpdateWebsiteLink(false);
        UpdateWebsiteFields();
    end;

    trigger OnModify()
    begin
        UpdateWebsiteLink(false);
        UpdateWebsiteFields();
    end;

    trigger OnRename()
    var
        MagentoStore: Record "NPR Magento Store";
    begin
        if MagentoStore.Get("Store Code") then
            "Website Code" := MagentoStore."Website Code";
    end;

    procedure GetEnabledFieldsCaption() EnabledFieldsCaption: Text
    begin
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

        if "Display Only Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Display Only Text");

        if "Seo Link Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Seo Link");

        if "Meta Title Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Meta Title");

        if "Meta Description Enabled" then
            EnabledFieldsCaption += ',' + FieldCaption("Meta Description");

        if EnabledFieldsCaption <> '' then
            EnabledFieldsCaption := CopyStr(EnabledFieldsCaption, 2);

        exit(EnabledFieldsCaption);
    end;

    local procedure UpdateWebsiteField(FieldRef: FieldRef)
    var
        MagentoStoreItem: Record "NPR Magento Store Item";
        RecRef: RecordRef;
        FieldRef2: FieldRef;
    begin
        MagentoStoreItem.SetRange("Item No.", "Item No.");
        MagentoStoreItem.SetFilter("Store Code", '<>%1', "Store Code");
        MagentoStoreItem.SetRange("Website Code", "Website Code");
        if MagentoStoreItem.IsEmpty then
            exit;

        RecRef.GetTable(MagentoStoreItem);
        FieldRef2 := RecRef.Field(FieldRef.Number);
        FieldRef2.SetFilter('<>%1', FieldRef.Value);
        if not RecRef.FindSet() then
            exit;

        repeat
            FieldRef2 := RecRef.Field(FieldRef.Number);
            FieldRef2.Value := FieldRef.Value;
            RecRef.Modify();
        until RecRef.Next() = 0;
    end;

    local procedure UpdateWebsiteFields()
    var
        MagentoStoreItem: Record "NPR Magento Store Item";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
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
    end;

    local procedure UpdateWebsiteLink(DeleteTrigger: Boolean)
    var
        MagentoStoreItem: Record "NPR Magento Store Item";
        MagentoWebsite: Record "NPR Magento Website";
        MagentoWebsiteLink: Record "NPR Magento Website Link";
    begin
        if not MagentoWebsite.Get("Website Code") then
            exit;

        if DeleteTrigger or (not Enabled) then begin
            MagentoStoreItem.SetRange("Item No.", "Item No.");
            MagentoStoreItem.SetFilter("Store Code", '<>%1', "Store Code");
            MagentoStoreItem.SetRange("Website Code", "Website Code");
            MagentoStoreItem.SetRange(Enabled, true);
            if MagentoStoreItem.FindFirst() then
                exit;

            MagentoWebsiteLink.SetRange("Website Code", "Website Code");
            MagentoWebsiteLink.SetRange("Item No.", "Item No.");
            MagentoWebsiteLink.DeleteAll();
            exit;
        end;

        if MagentoWebsiteLink.Get("Website Code", "Item No.", '') then
            exit;

        MagentoWebsiteLink.Init();
        MagentoWebsiteLink."Website Code" := "Website Code";
        MagentoWebsiteLink."Item No." := "Item No.";
        MagentoWebsiteLink."Variant Code" := '';
        MagentoWebsiteLink.Insert();
    end;
}
