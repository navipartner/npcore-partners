codeunit 6151460 "M2 Setup Mgt."
{
    // MAG2.08/MHA /20171016  CASE 292926 Object created - M2 Integration
    // MAG2.09/MHA /20171108  CASE 295656 ticket_setup should also be disabled on ItemStore
    // MAG2.14/MHA /20180529  CASE 286677 Added functions SetupMagentoCredentials(), SetupM2Credentials()
    // MAG2.20/MHA /20190426  CASE 320423 Add functionality to Initiate Magento Setup Event Subscriptions
    // MAG2.22/MHA /20190625  CASE 359285 Added Picture Variety Type in SetupNpXmlTemplates()
    // MAG2.22/MHA /20190705  CASE 361164 Updated Exception Message parsing in MagentoApiGet() and MagentoApiPost()
    // MAG2.22/MHA /20190708  CASE 352201 Added SetupTemplateCollectStore() to SetupNpXmlTemplates()
    // MAG2.26/MHA /20200601  CASE 404580 Setup Event Subscription added for Categories and Brands


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Root Categoery is missing for Website %1';

    local procedure CreateStores(var XmlElement: DotNet npNetXmlElement; MagentoWebsite: Record "Magento Website")
    var
        MagentoStore: Record "Magento Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement2: DotNet npNetXmlElement;
        XmlElement3: DotNet npNetXmlElement;
        i: Integer;
        j: Integer;
        RootItemGroupNo: Code[20];
    begin
        if IsNull(XmlElement) then
            exit;

        if NpXmlDomMgt.FindNode(XmlElement, 'stores/store', XmlElement2) then
            repeat
                RootItemGroupNo := NpXmlDomMgt.GetXmlText(XmlElement, 'root_category', MaxStrLen(RootItemGroupNo), true);
                if not NpXmlDomMgt.FindNode(XmlElement, 'root_category', XmlElement3) then
                    Error(Text000, MagentoWebsite.Code);
                RootItemGroupNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement3, 'external_id', true);
                CreateRootItemGroup(RootItemGroupNo, CopyStr(MagentoWebsite.Name, 1, 50));

                if not MagentoStore.Get(UpperCase(XmlElement2.GetAttribute('code'))) then begin
                    MagentoStore.Init;
                    MagentoStore.Code := UpperCase(XmlElement2.GetAttribute('code'));
                    MagentoStore."Website Code" := MagentoWebsite.Code;
                    MagentoStore.Name := XmlElement2.InnerText;
                    MagentoStore."Root Item Group No." := RootItemGroupNo;
                    MagentoStore.Insert(true);
                end else
                    if (MagentoStore."Website Code" <> MagentoWebsite.Code) or (MagentoStore.Name <> XmlElement2.InnerText) or (MagentoStore."Root Item Group No." <> RootItemGroupNo) then begin
                        MagentoStore."Website Code" := MagentoWebsite.Code;
                        MagentoStore.Name := XmlElement2.InnerText;
                        MagentoStore."Root Item Group No." := RootItemGroupNo;
                        MagentoStore.Modify(true);
                    end;
                XmlElement2 := XmlElement2.NextSibling;
            until IsNull(XmlElement2);
    end;

    local procedure CreateRootItemGroup(ItemGroupNo: Code[20]; ItemGroupName: Text[50])
    var
        ItemGroup: Record "Magento Category";
    begin
        if ItemGroup.Get(ItemGroupNo) then begin
          if (ItemGroup.Name <> ItemGroupName) or (not ItemGroup.Root) or (ItemGroup."Root No." <> ItemGroup.Id) then begin
                ItemGroup.Name := ItemGroupName;
                ItemGroup.Root := true;
            ItemGroup."Root No." := ItemGroup.Id;
                ItemGroup.Modify(true);
            end;
            exit;
        end;

        ItemGroup.Init;
        ItemGroup.Id := ItemGroupNo;
        ItemGroup.Name := ItemGroupName;
        ItemGroup.Root := true;
        ItemGroup."Root No." := ItemGroup.Id;
        ItemGroup.Insert(true);
    end;

    local procedure SetDefaultItemGroupRoots()
    var
        ItemGroup: Record "Magento Category";
        MagentoStore: Record "Magento Store";
        MagentoWebsite: Record "Magento Website";
    begin
        MagentoWebsite.SetRange("Default Website", true);
        if not MagentoWebsite.FindFirst then
            exit;

        MagentoStore.SetRange("Website Code", MagentoWebsite.Code);
        MagentoStore.SetFilter("Root Item Group No.", '<>%1', '');
        if not MagentoStore.FindFirst then
            exit;

        ItemGroup.SetFilter("Parent Category Id",'=%1','');
        ItemGroup.SetFilter("Root No.", '=%1', '');
        ItemGroup.SetRange(Root, false);
        if not ItemGroup.FindSet then
            exit;

        repeat
          ItemGroup."Parent Category Id" := MagentoStore."Root Item Group No.";
            ItemGroup."Root No." := MagentoStore."Root Item Group No.";
            ItemGroup.Modify(true);
        until ItemGroup.Next = 0;
    end;

    local procedure SetupNpXmlTemplates()
    var
        MagentoSetup: Record "Magento Setup";
        NpXmlElement: Record "NpXml Element";
        NpXmlElement2: Record "NpXml Element";
        NpXmlFilter: Record "NpXml Filter";
        TempBlob: Codeunit "Temp Blob";
        MagentoGenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
        M2NpXmlSetupMgt: Codeunit "M2 NpXml Setup Mgt.";
        VariaXElementLineNo: Integer;
        ColorDimension: Code[20];
        SizeDimension: Code[20];
    begin
        if not MagentoSetup.Get then
            exit;

        MagentoGenericSetupMgt.InitGenericMagentoSetup(MagentoSetup);
        TempBlob.FromRecord(MagentoSetup, MagentoSetup.FieldNo("Generic Setup"));

        M2NpXmlSetupMgt.SetupTemplateItem(TempBlob, MagentoSetup."Magento Enabled");
        M2NpXmlSetupMgt.SetupTemplatePicture(TempBlob, MagentoSetup."Magento Enabled");
        M2NpXmlSetupMgt.SetupTemplateItemInventory(TempBlob, MagentoSetup."Magento Enabled");
        M2NpXmlSetupMgt.SetupTemplateItemStore(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Multistore Enabled");
        M2NpXmlSetupMgt.SetupTemplateItemGroup(TempBlob, MagentoSetup."Magento Enabled");
        M2NpXmlSetupMgt.SetupTemplateOrderStatus(TempBlob, MagentoSetup."Magento Enabled");
        M2NpXmlSetupMgt.SetupTemplateBrand(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Brands Enabled");
        M2NpXmlSetupMgt.SetupTemplateGiftVoucher(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Gift Voucher Enabled");
        M2NpXmlSetupMgt.SetupTemplateCreditVoucher(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Gift Voucher Enabled");
        M2NpXmlSetupMgt.SetupTemplateAttribute(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Attributes Enabled");
        M2NpXmlSetupMgt.SetupTemplateAttributeSet(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Attributes Enabled");
        M2NpXmlSetupMgt.SetupTemplateCustomer(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled");
        M2NpXmlSetupMgt.SetupTemplateDisplayConfig(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled");
        M2NpXmlSetupMgt.SetupTemplateSalesPrice(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Sales Prices Enabled");
        M2NpXmlSetupMgt.SetupTemplateSalesLineDiscount(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Sales Line Discounts Enabled");
        M2NpXmlSetupMgt.SetupTemplateTicket(TempBlob, true);
        M2NpXmlSetupMgt.SetupTemplateMember(TempBlob, true);
        //-MAG2.22 [352201]
        M2NpXmlSetupMgt.SetupTemplateCollectStore(TempBlob,
          MagentoSetup."Magento Enabled" and MagentoSetup."Collect in Store Enabled" and (MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"2"));
        //+MAG2.22 [352201]
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/manufacturer', '', MagentoSetup."Brands Enabled");
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/product_external_attributes', '', MagentoSetup."Attributes Enabled");
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/related_products', '', MagentoSetup."Product Relations Enabled");
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/special_price', '', MagentoSetup."Special Prices Enabled");
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/special_price_from', '', MagentoSetup."Special Prices Enabled");
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/special_price_to', '', MagentoSetup."Special Prices Enabled");
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/tier_prices', '', MagentoSetup."Tier Prices Enabled");
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/group_prices', '', MagentoSetup."Customer Group Prices Enabled");
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/custom_options', '', MagentoSetup."Custom Options Enabled");
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/bundled_options', '', MagentoSetup."Bundled Products Enabled");
        M2NpXmlSetupMgt.SetSalesPriceEnabled(TempBlob, 'product/unit_codes', '', MagentoSetup."Sales Prices Enabled" or MagentoSetup."Sales Line Discounts Enabled");
        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/ticket_setup', '', MagentoSetup."Tickets Enabled");
        //-MAG2.09 [295656]
        M2NpXmlSetupMgt.SetItemStoreElementEnabled(TempBlob, 'ticket_setup', MagentoSetup."Tickets Enabled");
        M2NpXmlSetupMgt.AddItemDiscGroupCodeElement(TempBlob);
        //+MAG2.09 [295656]

        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer', '', MagentoSetup."Variant System" = MagentoSetup."Variant System"::Variety);
        //-MAG2.22 [359285]
        case MagentoSetup."Variant System" of
            MagentoSetup."Variant System"::Variety:
                begin
                    M2NpXmlSetupMgt.SetItemFilterValue(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery',
                      '', 'fixed_variety_1_buffer', '', 6059970, MagentoSetup."Variant Picture Dimension");
                    M2NpXmlSetupMgt.SetItemFilterValue(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery',
                      '', 'fixed_variety_2_buffer', '', 6059973, MagentoSetup."Variant Picture Dimension");
                    M2NpXmlSetupMgt.SetItemFilterValue(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery',
                      '', 'fixed_variety_3_buffer', '', 6059976, MagentoSetup."Variant Picture Dimension");
                    M2NpXmlSetupMgt.SetItemFilterValue(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery',
                      '', 'fixed_variety_4_buffer', '', 6059979, MagentoSetup."Variant Picture Dimension");

                    M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/fixed_variety_1_buffer',
                      '', MagentoSetup."Picture Variety Type" = MagentoSetup."Picture Variety Type"::Fixed);
                    M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/fixed_variety_2_buffer',
                      '', MagentoSetup."Picture Variety Type" = MagentoSetup."Picture Variety Type"::Fixed);
                    M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/fixed_variety_3_buffer',
                      '', MagentoSetup."Picture Variety Type" = MagentoSetup."Picture Variety Type"::Fixed);
                    M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/fixed_variety_4_buffer',
                      '', MagentoSetup."Picture Variety Type" = MagentoSetup."Picture Variety Type"::Fixed);
                    M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/variety_1_buffer',
                      '', MagentoSetup."Picture Variety Type" in [MagentoSetup."Picture Variety Type"::"Select on Item", MagentoSetup."Picture Variety Type"::"Variety 1"]);
                    M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/variety_2_buffer',
                      '', MagentoSetup."Picture Variety Type" in [MagentoSetup."Picture Variety Type"::"Select on Item", MagentoSetup."Picture Variety Type"::"Variety 2"]);
                    M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/variety_3_buffer',
                      '', MagentoSetup."Picture Variety Type" in [MagentoSetup."Picture Variety Type"::"Select on Item", MagentoSetup."Picture Variety Type"::"Variety 3"]);
                    M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/variety_4_buffer',
                      '', MagentoSetup."Picture Variety Type" in [MagentoSetup."Picture Variety Type"::"Select on Item", MagentoSetup."Picture Variety Type"::"Variety 4"]);
                end;
        end;
        //+MAG2.22 [359285]
    end;

    local procedure SetupPaymentMethodMapping()
    var
        MagentoSetup: Record "Magento Setup";
        PaymentMapping: Record "Magento Payment Mapping";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        XmlNodeList2: DotNet npNetXmlNodeList;
        i: Integer;
        j: Integer;
        PaymentCode: Text[50];
        PaymentType: Text[50];
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoApiGet(MagentoSetup."Api Url", 'payment_methods', XmlDoc);

        NpXmlDomMgt.FindNodes(XmlDoc, 'payment_method', XmlNodeList);
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            PaymentCode := XmlElement.GetAttribute('code');
            PaymentType := XmlElement.GetAttribute('type');

            if not PaymentMapping.Get(PaymentCode, PaymentType) then begin
                PaymentMapping.Init;
                PaymentMapping."External Payment Method Code" := PaymentCode;
                PaymentMapping."External Payment Type" := PaymentType;
                PaymentMapping.Insert(true);
            end;
        end;
    end;

    local procedure SetupShipmentMethodMapping()
    var
        MagentoSetup: Record "Magento Setup";
        ShipmentMapping: Record "Magento Shipment Mapping";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        XmlNodeList2: DotNet npNetXmlNodeList;
        i: Integer;
        j: Integer;
        ShipmentCode: Text[50];
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoApiGet(MagentoSetup."Api Url", 'shipping_methods', XmlDoc);

        NpXmlDomMgt.FindNodes(XmlDoc, 'shipping_method', XmlNodeList);
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            ShipmentCode := XmlElement.GetAttribute('carrier');
            if not ShipmentMapping.Get(ShipmentCode) then begin
                ShipmentMapping.Init;
                ShipmentMapping."External Shipment Method Code" := ShipmentCode;
                ShipmentMapping.Insert(true);
            end;
        end;
    end;

    local procedure SetupMagentoCredentials(): Text
    var
        MagentoSetup: Record "Magento Setup";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        NpXmlMgt: Codeunit "NpXml Mgt.";
        FormsAuthentication: DotNet npNetFormsAuthentication;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        Authentication: Text;
        Hash: Text;
        Username: Text;
        PrevRec: Text;
    begin
        //-MAG2.14 [286677]
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;

        Username := NpXmlMgt.GetAutomaticUsername();
        Hash := LowerCase(FormsAuthentication.HashPasswordForStoringInConfigFile(Username + Username + 'D3W7k5pd7Pn64ctn25ng91ZkSvyDnjo2', 'MD5'));

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<?xml version="1.0" encoding="utf-8"?>' +
                       '<root>' +
                       '  <initSetup>' +
                       '    <username>' + Username + '</username>' +
                       '    <password>' + Username + '</password>' +
                       '    <hash>' + Hash + '</hash><!-- a hash of a combination of username,password and private key -->' +
                       '  </initSetup>' +
                       '</root>');

        MagentoApiPost(MagentoSetup."Api Url", 'initSetup', XmlDoc);
        if not NpXmlDomMgt.FindNode(XmlDoc.DocumentElement, 'success/message', XmlElement) then
            Error(NpXmlDomMgt.PrettyPrintXml(XmlDoc.InnerXml));

        Authentication := NpXmlDomMgt.GetXmlText(XmlElement, 'authentication_type', 0, true) + ' ' + NpXmlDomMgt.GetXmlText(XmlElement, 'access_token', 0, true);

        PrevRec := Format(MagentoSetup);
        MagentoSetup."Api Username Type" := MagentoSetup."Api Username Type"::Custom;
        MagentoSetup."Api Username" := '';
        MagentoSetup."Api Password" := '';
        MagentoSetup."Api Authorization" := Authentication;
        if PrevRec <> Format(MagentoSetup) then
            MagentoSetup.Modify;
        //+MAG2.14 [286677]
    end;

    local procedure SetupTaxClasses()
    var
        MagentoSetup: Record "Magento Setup";
        MagentoTaxClass: Record "Magento Tax Class";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
        ClassName: Text[250];
        ClassType: Integer;
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoApiGet(MagentoSetup."Api Url", 'tax_classes', XmlDoc);

        NpXmlDomMgt.FindNodes(XmlDoc, 'tax_class', XmlNodeList);
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            ClassName := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'class_name', 0, false), 1, MaxStrLen(MagentoTaxClass.Name));
            ClassType := -1;
            case LowerCase(NpXmlDomMgt.GetXmlText(XmlElement, 'class_type', 0, false)) of
                'customer':
                    ClassType := MagentoTaxClass.Type::Customer;
                'product':
                    ClassType := MagentoTaxClass.Type::Item;
            end;
            if (ClassName <> '') and (ClassType >= 0) then
                if not MagentoTaxClass.Get(ClassName, ClassType) then begin
                    MagentoTaxClass.Init;
                    MagentoTaxClass.Name := ClassName;
                    MagentoTaxClass.Type := ClassType;
                    MagentoTaxClass.Insert(true);
                end;
        end;
    end;

    local procedure SetupWebsites()
    var
        MagentoSetup: Record "Magento Setup";
        MagentoWebsite: Record "Magento Website";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoApiGet(MagentoSetup."Api Url", 'websites', XmlDoc);

        NpXmlDomMgt.FindNodes(XmlDoc, 'website', XmlNodeList);
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            if not MagentoWebsite.Get(XmlElement.GetAttribute('code')) then begin
                MagentoWebsite.Init;
                MagentoWebsite.Code := UpperCase(XmlElement.GetAttribute('code'));
                MagentoWebsite.Name := NpXmlDomMgt.GetXmlText(XmlElement, 'name', 0, false);
                MagentoWebsite."Default Website" := NpXmlDomMgt.GetXmlText(XmlElement, 'is_default', 0, false) = '1';
                MagentoWebsite.Insert(true);
            end else begin
                MagentoWebsite.Name := NpXmlDomMgt.GetXmlText(XmlElement, 'name', 0, false);
                MagentoWebsite."Default Website" := NpXmlDomMgt.GetXmlText(XmlElement, 'is_default', 0, false) = '1';
                MagentoWebsite.Modify(true);
            end;

            if NpXmlDomMgt.FindNode(XmlElement, 'store_groups/store_group', XmlElement2) then
                repeat
                    CreateStores(XmlElement2, MagentoWebsite);
                    XmlElement2 := XmlElement2.NextSibling;
                until IsNull(XmlElement2);
        end;

        SetDefaultItemGroupRoots();
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6151401, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertMagentoSetup(var Rec: Record "Magento Setup";RunTrigger: Boolean)
    begin
        //-MAG2.26 [404580]
        if Rec.IsTemporary then
          exit;

        if Rec."Magento Version" = Rec."Magento Version"::"2" then
          InitMagentoSetupEvents();
        //+MAG2.26 [404580]
    end;

    [EventSubscriber(ObjectType::Table, 6151401, 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnAfterModifyMagentoSetup(var Rec: Record "Magento Setup"; var xRec: Record "Magento Setup"; RunTrigger: Boolean)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
    begin
        //-MAG2.20 [320423]
        if Rec.IsTemporary then
            exit;
        if Rec."Magento Version" = xRec."Magento Version" then
            exit;

        case Rec."Magento Version" of
            Rec."Magento Version"::"1":
                begin
                    MagentoSetupEventSub.DeleteAll;
                end;
            Rec."Magento Version"::"2":
                begin
                    InitMagentoSetupEvents();
                end;
        end;
        //+MAG2.20 [320423]
    end;

    local procedure InitMagentoSetupEvents()
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
    begin
        //-MAG2.20 [320423]
        MagentoSetupEventSub.DeleteAll;
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"DragDrop Picture", CODEUNIT::"M2 Picture Mgt.", 'UploadM2Picture');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Magento Picture Url", CODEUNIT::"M2 Picture Mgt.", 'GetM2PictureUrl');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup NpXml Templates", CODEUNIT::"M2 Setup Mgt.", 'SetupM2NpXmlTemplates');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Magento Tax Classes", CODEUNIT::"M2 Setup Mgt.", 'SetupM2TaxClasses');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Magento Api Credentials", CODEUNIT::"M2 Setup Mgt.", 'SetupM2Credentials');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Magento Websites", CODEUNIT::"M2 Setup Mgt.", 'SetupM2Websites');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Payment Method Mapping", CODEUNIT::"M2 Setup Mgt.", 'SetupM2PaymentMethodMapping');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Shipment Method Mapping", CODEUNIT::"M2 Setup Mgt.", 'SetupM2ShipmentMethodMapping');
        //+MAG2.20 [320423]
        //-MAG2.26 [404580]
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Categories",CODEUNIT::"M2 Category Mgt.",'SetupM2Categories');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Brands",CODEUNIT::"M2 Brand Mgt.",'SetupM2Brands');
        //+MAG2.26 [404580]
    end;

    local procedure InitMagentoSetupEvent(Type: Integer; CodeunitId: Integer; FunctionName: Text)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
    begin
        //-MAG2.20 [320423]
        if MagentoSetupEventSub.Get(Type, CodeunitId, FunctionName) then
            exit;

        MagentoSetupEventSub.Init;
        MagentoSetupEventSub.Type := Type;
        MagentoSetupEventSub."Codeunit ID" := CodeunitId;
        MagentoSetupEventSub."Function Name" := FunctionName;
        MagentoSetupEventSub.Enabled := true;
        MagentoSetupEventSub.Insert(true);
        //+MAG2.20 [320423]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupMagentoCredentials', '', true, true)]
    local procedure SetupM2Credentials(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        //-MAG2.14 [286677]
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Api Credentials", CurrCodeunitId(), 'SetupM2Credentials') then
            exit;

        Handled := true;
        SetupMagentoCredentials();
        //+MAG2.14 [286677]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupNpXmlTemplates', '', true, true)]
    local procedure SetupM2NpXmlTemplates(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup NpXml Templates", CurrCodeunitId(), 'SetupM2NpXmlTemplates') then
            exit;

        Handled := true;
        SetupNpXmlTemplates();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupPaymentMethodMapping', '', true, true)]
    local procedure SetupM2PaymentMethodMapping(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Payment Method Mapping", CurrCodeunitId(), 'SetupM2PaymentMethodMapping') then
            exit;

        Handled := true;
        SetupPaymentMethodMapping();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupShipmentMethodMapping', '', true, true)]
    local procedure SetupM2ShipmentMethodMapping(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        //-MAG2.07 [286943]
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Shipment Method Mapping", CurrCodeunitId(), 'SetupM2ShipmentMethodMapping') then
            exit;

        Handled := true;
        SetupShipmentMethodMapping();
        //+MAG2.07 [286943]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupMagentoTaxClasses', '', true, true)]
    local procedure SetupM2TaxClasses(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Tax Classes", CurrCodeunitId(), 'SetupM2TaxClasses') then
            exit;

        Handled := true;
        SetupTaxClasses();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupMagentoWebsites', '', true, true)]
    local procedure SetupM2Websites(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Websites", CurrCodeunitId(), 'SetupM2Websites') then
            exit;

        Handled := true;
        SetupWebsites();
    end;

    procedure "--- Magento Api"()
    begin
    end;

    procedure MagentoApiGet(MagentoApiUrl: Text; Method: Text; var XmlDoc: DotNet npNetXmlDocument) Result: Boolean
    var
        MagentoSetup: Record "Magento Setup";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        MemoryStream: DotNet npNetMemoryStream;
        WebException: DotNet npNetWebException;
        ErrorMessage: Text;
    begin
        if MagentoApiUrl = '' then
            exit(false);

        if not IsNull(HttpWebRequest) then
            Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(MagentoApiUrl + Method);
        HttpWebRequest.Timeout := 1000 * 60 * 5;

        HttpWebRequest.Method := 'GET';
        HttpWebRequest.ContentType := 'naviconnect/xml';
        HttpWebRequest.Accept('naviconnect/xml');

        MagentoSetup.Get;
        //-MAG2.14 [286677]
        if MagentoSetup."Api Authorization" <> '' then
            HttpWebRequest.Headers.Add('Authorization', MagentoSetup."Api Authorization");
        //+MAG2.14 [286677]

        //-MAG2.22 [361164]
        if not TryGetWebResponse(HttpWebRequest, HttpWebResponse) then begin
            WebException := GetLastErrorObject;
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            Error(CopyStr(ErrorMessage, 1, 1000));
        end;
        //+MAG2.22 [361164]
        MemoryStream := HttpWebResponse.GetResponseStream;

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(MemoryStream);

        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        exit(true);
    end;

    procedure MagentoApiPost(MagentoApiUrl: Text; Method: Text; var XmlDoc: DotNet npNetXmlDocument) Result: Boolean
    var
        MagentoSetup: Record "Magento Setup";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        ErrorMessage: Text;
        ResponseText: Text;
    begin
        //-MAG2.14 [286677]
        if MagentoApiUrl = '' then
            exit(false);

        if not IsNull(HttpWebRequest) then
            Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(MagentoApiUrl + Method);
        HttpWebRequest.Timeout := 1000 * 60 * 5;

        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'naviconnect/xml';
        HttpWebRequest.Accept('naviconnect/xml');

        MagentoSetup.Get;
        if MagentoSetup."Api Authorization" <> '' then
            HttpWebRequest.Headers.Add('Authorization', MagentoSetup."Api Authorization");
        if MagentoSetup."Api Authorization" <> '' then begin
            HttpWebRequest.ContentType := 'naviconnect/xml';
            HttpWebRequest.Accept('application/xml');
            HttpWebRequest.Headers.Add('Authorization', MagentoSetup."Api Authorization");
        end;

        if not NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, WebException) then begin
            //-MAG2.22 [361164]
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            Error(CopyStr(ErrorMessage, 1, 1000));
            //+MAG2.22 [361164]
        end;

        ResponseText := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(ResponseText);
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        exit(true);
        //+MAG2.14 [286677]
    end;

    [TryFunction]
    local procedure TryGetWebResponse(HttpWebRequest: DotNet npNetHttpWebRequest; var HttpWebResponse: DotNet npNetHttpWebResponse)
    var
        MemoryStream: DotNet npNetMemoryStream;
    begin
        //-MAG2.22 [361164]
        HttpWebResponse := HttpWebRequest.GetResponse;
        //+MAG2.22 [361164]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"M2 Setup Mgt.");
    end;
}

