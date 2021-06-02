codeunit 6151460 "NPR M2 Setup Mgt."
{
    var
        Text000: Label 'Root Categoery is missing for Website %1';

    local procedure CreateStores(var XmlElement: XmlElement; MagentoWebsite: Record "NPR Magento Website")
    var
        MagentoStore: Record "NPR Magento Store";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NodeList: XmlNodeList;
        XmlElement2: XmlNode;
        XmlElement3: XmlNode;
        CodeAttribute: XmlAttribute;
        RootItemGroupNo: Code[20];
    begin
        if XmlElement.IsEmpty then
            exit;

        if XmlElement.SelectNodes('//stores/store', NodeList) then
            foreach XmlElement2 in NodeList do begin
                RootItemGroupNo := NpXmlDomMgt.GetXmlText(XmlElement, 'root_category', MaxStrLen(RootItemGroupNo), true);
                if not NpXmlDomMgt.FindNode(XmlElement.AsXmlNode(), 'root_category', XmlElement3) then
                    Error(Text000, MagentoWebsite.Code);
                RootItemGroupNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement3, 'external_id', true);
                CreateRootItemGroup(RootItemGroupNo, CopyStr(MagentoWebsite.Name, 1, 50));
                XmlElement2.AsXmlElement().Attributes().Get('code', CodeAttribute);

                if not MagentoStore.Get(UpperCase(CodeAttribute.Value)) then begin
                    MagentoStore.Init();
                    MagentoStore.Code := CodeAttribute.Value;
                    MagentoStore."Website Code" := MagentoWebsite.Code;
                    MagentoStore.Name := XmlElement2.AsXmlElement().InnerText();
                    MagentoStore."Root Item Group No." := RootItemGroupNo;
                    MagentoStore.Insert(true);
                end else
                    if (MagentoStore."Website Code" <> MagentoWebsite.Code) or (MagentoStore.Name <> XmlElement2.AsXmlElement().InnerText()) or (MagentoStore."Root Item Group No." <> RootItemGroupNo) then begin
                        MagentoStore."Website Code" := MagentoWebsite.Code;
                        MagentoStore.Name := XmlElement2.AsXmlElement().InnerText();
                        MagentoStore."Root Item Group No." := RootItemGroupNo;
                        MagentoStore.Modify(true);
                    end;
            end;
    end;

    local procedure CreateRootItemGroup(ItemGroupNo: Code[20]; ItemGroupName: Text[50])
    var
        ItemGroup: Record "NPR Magento Category";
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

        ItemGroup.Init();
        ItemGroup.Id := ItemGroupNo;
        ItemGroup.Name := ItemGroupName;
        ItemGroup.Root := true;
        ItemGroup."Root No." := ItemGroup.Id;
        ItemGroup.Insert(true);
    end;

    local procedure SetDefaultItemGroupRoots()
    var
        ItemGroup: Record "NPR Magento Category";
        MagentoStore: Record "NPR Magento Store";
        MagentoWebsite: Record "NPR Magento Website";
    begin
        MagentoWebsite.SetRange("Default Website", true);
        if not MagentoWebsite.FindFirst() then
            exit;

        MagentoStore.SetRange("Website Code", MagentoWebsite.Code);
        MagentoStore.SetFilter("Root Item Group No.", '<>%1', '');
        if not MagentoStore.FindFirst() then
            exit;

        ItemGroup.SetFilter("Parent Category Id", '=%1', '');
        ItemGroup.SetFilter("Root No.", '=%1', '');
        ItemGroup.SetRange(Root, false);
        if not ItemGroup.FindSet() then
            exit;

        repeat
            ItemGroup."Parent Category Id" := MagentoStore."Root Item Group No.";
            ItemGroup."Root No." := MagentoStore."Root Item Group No.";
            ItemGroup.Modify(true);
        until ItemGroup.Next() = 0;
    end;

    local procedure SetupNpXmlTemplates()
    var
        MagentoSetup: Record "NPR Magento Setup";
        TempBlob: Codeunit "Temp Blob";
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        M2NpXmlSetupMgt: Codeunit "NPR M2 NpXml Setup Mgt.";
    begin
        if not MagentoSetup.Get() then
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
        M2NpXmlSetupMgt.SetupTemplateCollectStore(TempBlob,
          MagentoSetup."Magento Enabled" and MagentoSetup."Collect in Store Enabled" and (MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"2"));
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
        M2NpXmlSetupMgt.SetItemStoreElementEnabled(TempBlob, 'ticket_setup', MagentoSetup."Tickets Enabled");
        M2NpXmlSetupMgt.AddItemDiscGroupCodeElement(TempBlob);

        M2NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer', '', MagentoSetup."Variant System" = MagentoSetup."Variant System"::Variety);
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
    end;

    local procedure SetupPaymentMethodMapping()
    var
        MagentoSetup: Record "NPR Magento Setup";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        XmlDoc: XmlDocument;
        XmlElement: XmlNode;
        XmlNodeList: XmlNodeList;
        Attribute: XmlAttribute;
        PaymentCode: Text[50];
        PaymentType: Text[50];
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoApiGet(MagentoSetup."Api Url", 'payment_methods', XmlDoc);
        XmlDoc.AsXmlNode().SelectNodes('//payment_method', XmlNodeList);
        foreach XmlElement in XmlNodeList do begin
            XmlElement.AsXmlElement().Attributes().Get('code', Attribute);
            PaymentCode := Attribute.Value;

            // We need to wrap this in an if since AL native methods throws a runtime exception
            // if the specified attribute does not exist. Since this is the "subtype" of the 
            // payment method, we can accept this attribute missing
            if XmlElement.AsXmlElement().Attributes().Get('type', Attribute) then
                PaymentType := Attribute.Value;

            if not PaymentMapping.Get(PaymentCode, PaymentType) then begin
                PaymentMapping.Init();
                PaymentMapping."External Payment Method Code" := PaymentCode;
                PaymentMapping."External Payment Type" := PaymentType;
                PaymentMapping.Insert(true);
            end;
        end;
    end;

    local procedure SetupShipmentMethodMapping()
    var
        MagentoSetup: Record "NPR Magento Setup";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        XmlDoc: XmlDocument;
        XmlElement: XmlNode;
        XmlNodeList: XmlNodeList;
        Attribute: XmlAttribute;
        ShipmentCode: Text[50];
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoApiGet(MagentoSetup."Api Url", 'shipping_methods', XmlDoc);

        XmlDoc.AsXmlNode().SelectNodes('//shipping_method', XmlNodeList);
        foreach XmlElement in XmlNodeList do begin
            XmlElement.AsXmlElement().Attributes().Get('carrier', Attribute);
            ShipmentCode := Attribute.Value;
            if not ShipmentMapping.Get(ShipmentCode) then begin
                ShipmentMapping.Init();
                ShipmentMapping."External Shipment Method Code" := ShipmentCode;
                ShipmentMapping.Insert(true);
            end;
        end;
    end;

    local procedure SetupMagentoCredentials(): Text
    var
        MagentoSetup: Record "NPR Magento Setup";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NpXmlMgt: Codeunit "NPR NpXml Mgt.";
        CryptMgt: Codeunit "Cryptography Management";
        XmlDoc: XmlDocument;
        XmlElement: XmlNode;
        Authentication: Text;
        Hash: Text;
        Username: Text;
        PrevRec: Text;
        XmlTxt: Text;
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;

        Username := NpXmlMgt.GetAutomaticUsername();
        Hash := LowerCase(CryptMgt.GenerateHash(Username + Username + 'D3W7k5pd7Pn64ctn25ng91ZkSvyDnjo2', 0));

        XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?>' +
                       '<root>' +
                       '  <initSetup>' +
                       '    <username>' + Username + '</username>' +
                       '    <password>' + Username + '</password>' +
                       '    <hash>' + Hash + '</hash><!-- a hash of a combination of username,password and private key -->' +
                       '  </initSetup>' +
                       '</root>', XmlDoc);

        MagentoApiPost(MagentoSetup."Api Url", 'initSetup', XmlDoc);
        if not NpXmlDomMgt.FindNode(XmlDoc.AsXmlNode(), '//success/message', XmlElement) then begin
            XmlDoc.WriteTo(XmlTxt);
            Error(XmlTxt);
        end;

        Authentication := NpXmlDomMgt.GetXmlText(XmlElement.AsXmlElement(), '//authentication_type', 0, true) + ' ' + NpXmlDomMgt.GetXmlText(XmlElement.AsXmlElement(), '//access_token', 0, true);

        PrevRec := Format(MagentoSetup);
        MagentoSetup."Api Username Type" := MagentoSetup."Api Username Type"::Custom;
        MagentoSetup."Api Username" := '';
        MagentoSetup.RemoveApiPassword();
        MagentoSetup."Api Authorization" := Authentication;
        if PrevRec <> Format(MagentoSetup) then
            MagentoSetup.Modify();
    end;

    local procedure SetupTaxClasses()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoTaxClass: Record "NPR Magento Tax Class";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: XmlDocument;
        XmlElement: XmlNode;
        XmlNodeList: XmlNodeList;
        ClassName: Text[250];
        ClassType: Integer;
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoApiGet(MagentoSetup."Api Url", 'tax_classes', XmlDoc);

        XmlDoc.AsXmlNode().SelectNodes('//tax_class', XmlNodeList);
        foreach XmlElement in XmlNodeList do begin
            ClassName := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement.AsXmlElement(), 'class_name', 0, false), 1, MaxStrLen(MagentoTaxClass.Name));
            ClassType := -1;
            case LowerCase(NpXmlDomMgt.GetXmlText(XmlElement.AsXmlElement(), 'class_type', 0, false)) of
                'customer':
                    ClassType := MagentoTaxClass.Type::Customer.AsInteger();
                'product':
                    ClassType := MagentoTaxClass.Type::Item.AsInteger();
            end;
            if (ClassName <> '') and (ClassType >= 0) then
                if not MagentoTaxClass.Get(ClassName, ClassType) then begin
                    MagentoTaxClass.Init();
                    MagentoTaxClass.Name := ClassName;
                    MagentoTaxClass.Type := Enum::"NPR Magento Tax Class Type".FromInteger(ClassType);
                    MagentoTaxClass.Insert(true);
                end;
        end;
    end;

    local procedure SetupWebsites()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoWebsite: Record "NPR Magento Website";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: XmlDocument;
        Node: XmlNode;
        Node2: XmlNode;
        XmlNodeList: XmlNodeList;
        XmlNodeList2: XmlNodeList;
        Attribute: XmlAttribute;
        Element: XmlElement;
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoApiGet(MagentoSetup."Api Url", 'websites', XmlDoc);

        XmlDoc.AsXmlNode().SelectNodes('//website', XmlNodeList);
        foreach Node in XmlNodeList do begin
            Node.AsXmlElement().Attributes().Get('code', Attribute);
            if not MagentoWebsite.Get(Attribute.Value) then begin
                MagentoWebsite.Init();
                MagentoWebsite.Code := Attribute.Value;
                MagentoWebsite.Name := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'name', 0, false);
                MagentoWebsite."Default Website" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'is_default', 0, false) = '1';
                MagentoWebsite.Insert(true);
            end else begin
                MagentoWebsite.Name := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'name', 0, false);
                MagentoWebsite."Default Website" := NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'is_default', 0, false) = '1';
                MagentoWebsite.Modify(true);
            end;

            if Node.SelectNodes('store_groups/store_group', XmlNodeList2) then
                foreach Node2 in XmlNodeList2 do begin
                    Element := Node2.AsXmlElement();
                    CreateStores(Element, MagentoWebsite);
                end;
        end;

        SetDefaultItemGroupRoots();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Setup", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertMagentoSetup(var Rec: Record "NPR Magento Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if Rec."Magento Version" = Rec."Magento Version"::"2" then
            InitMagentoSetupEvents();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Setup", 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnAfterModifyMagentoSetup(var Rec: Record "NPR Magento Setup"; var xRec: Record "NPR Magento Setup"; RunTrigger: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Magento Version" = xRec."Magento Version" then
            exit;

        case Rec."Magento Version" of
            Rec."Magento Version"::"1":
                begin
                    MagentoSetupEventSub.DeleteAll();
                end;
            Rec."Magento Version"::"2":
                begin
                    InitMagentoSetupEvents();
                end;
        end;
    end;

    local procedure InitMagentoSetupEvents()
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        MagentoSetupEventSub.DeleteAll();
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"DragDrop Picture", CODEUNIT::"NPR M2 Picture Mgt.", 'UploadM2Picture');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Magento Picture Url", CODEUNIT::"NPR M2 Picture Mgt.", 'GetM2PictureUrl');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup NpXml Templates", CODEUNIT::"NPR M2 Setup Mgt.", 'SetupM2NpXmlTemplates');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Magento Tax Classes", CODEUNIT::"NPR M2 Setup Mgt.", 'SetupM2TaxClasses');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Magento Api Credentials", CODEUNIT::"NPR M2 Setup Mgt.", 'SetupM2Credentials');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Magento Websites", CODEUNIT::"NPR M2 Setup Mgt.", 'SetupM2Websites');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Payment Method Mapping", CODEUNIT::"NPR M2 Setup Mgt.", 'SetupM2PaymentMethodMapping');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Shipment Method Mapping", CODEUNIT::"NPR M2 Setup Mgt.", 'SetupM2ShipmentMethodMapping');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Categories", CODEUNIT::"NPR M2 Category Mgt.", 'SetupM2Categories');
        InitMagentoSetupEvent(MagentoSetupEventSub.Type::"Setup Brands", CODEUNIT::"NPR M2 Brand Mgt.", 'SetupM2Brands');
    end;

    local procedure InitMagentoSetupEvent(Type: Enum "NPR Mag. Setup Event Sub. Type"; CodeunitId: Integer; FunctionName: Text)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        if MagentoSetupEventSub.Get(Type, CodeunitId, FunctionName) then
            exit;

        MagentoSetupEventSub.Init();
        MagentoSetupEventSub.Type := Type;
        MagentoSetupEventSub."Codeunit ID" := CodeunitId;
        MagentoSetupEventSub."Function Name" := FunctionName;
        MagentoSetupEventSub.Enabled := true;
        MagentoSetupEventSub.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupMagentoCredentials', '', true, true)]
    local procedure SetupM2Credentials(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Api Credentials", CurrCodeunitId(), 'SetupM2Credentials') then
            exit;

        Handled := true;
        SetupMagentoCredentials();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupNpXmlTemplates', '', true, true)]
    local procedure SetupM2NpXmlTemplates(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup NpXml Templates", CurrCodeunitId(), 'SetupM2NpXmlTemplates') then
            exit;

        Handled := true;
        SetupNpXmlTemplates();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupPaymentMethodMapping', '', true, true)]
    local procedure SetupM2PaymentMethodMapping(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Payment Method Mapping", CurrCodeunitId(), 'SetupM2PaymentMethodMapping') then
            exit;

        Handled := true;
        SetupPaymentMethodMapping();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupShipmentMethodMapping', '', true, true)]
    local procedure SetupM2ShipmentMethodMapping(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Shipment Method Mapping", CurrCodeunitId(), 'SetupM2ShipmentMethodMapping') then
            exit;

        Handled := true;
        SetupShipmentMethodMapping();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupMagentoTaxClasses', '', true, true)]
    local procedure SetupM2TaxClasses(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Tax Classes", CurrCodeunitId(), 'SetupM2TaxClasses') then
            exit;

        Handled := true;
        SetupTaxClasses();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupMagentoWebsites', '', true, true)]
    local procedure SetupM2Websites(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if not MagentoSetupMgt.IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Websites", CurrCodeunitId(), 'SetupM2Websites') then
            exit;

        Handled := true;
        SetupWebsites();
    end;

    #region Magento Api

    procedure MagentoApiGet(MagentoApiUrl: Text; Method: Text; var XmlDoc: XmlDocument) Result: Boolean
    var
        MagentoSetup: Record "NPR Magento Setup";
        XmlMgt: Codeunit "XML DOM Management";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Headers: HttpHeaders;
        Client: HttpClient;
        Response: Text;
    begin
        if MagentoApiUrl = '' then
            exit(false);

        HttpWebRequest.SetRequestUri(MagentoApiUrl + Method);
        HttpWebRequest.Method('GET');

        HttpWebRequest.GetHeaders(Headers);
        MagentoSetup.Get();
        if MagentoSetup."Api Authorization" <> '' then
            Headers.Add('Authorization', MagentoSetup."Api Authorization");
        Headers.Add('Accept', 'naviconnect/xml');

        Client.Timeout := 300000;
        Client.Send(HttpWebRequest, HttpWebResponse);
        HttpWebResponse.Content.ReadAs(Response);
        if not HttpWebResponse.IsSuccessStatusCode() then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        XmlDocument.ReadFrom(XmlMgt.RemoveNameSpaces(Response), XmlDoc);
        exit(true);
    end;

    procedure MagentoApiPost(MagentoApiUrl: Text; Method: Text; var XmlDoc: XmlDocument) Result: Boolean
    var
        MagentoSetup: Record "NPR Magento Setup";
        XmlMgt: Codeunit "XML DOM Management";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        Client: HttpClient;
        Response: Text;
    begin
        if MagentoApiUrl = '' then
            exit(false);

        HttpWebRequest.SetRequestUri(MagentoApiUrl + Method);
        HttpWebRequest.Method('POST');
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'naviconnect/xml');
        HttpWebRequest.Content(Content);

        HttpWebRequest.GetHeaders(Headers);
        MagentoSetup.Get();
        if MagentoSetup."Api Authorization" <> '' then begin
            Headers.Add('Authorization', MagentoSetup."Api Authorization");
            Headers.Add('Accept', 'naviconnect/xml');
        end
        else begin
            Headers.Add('Authorization', 'Basic ' + MagentoSetup.GetBasicAuthInfo());
            Headers.Add('Accept', 'application/xml');
        end;

        Client.Timeout := 300000;
        Client.Send(HttpWebRequest, HttpWebResponse);
        HttpWebResponse.Content.ReadAs(Response);
        if not HttpWebResponse.IsSuccessStatusCode() then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        XmlDocument.ReadFrom(XmlMgt.RemoveNameSpaces(Response), XmlDoc);
        exit(true);
    end;

    #endregion

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR M2 Setup Mgt.");
    end;
}