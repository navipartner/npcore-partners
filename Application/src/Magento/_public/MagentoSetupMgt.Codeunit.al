codeunit 6151401 "NPR Magento Setup Mgt."
{
    var
        Text000: Label 'Root Categoery is missing for Website %1';
        Text001: Label 'Magento Custom Options';
        Text10000: Label 'Check Payment Mapping?';
        Text10010: Label 'Check Shipment Mapping?';
        Text10020: Label 'Check VAT Business Posting Groups?';
        Text10030: Label 'Check VAT Product Posting Groups?';
        Text10050: Label 'Do you want Update Existing Order Import Type Setup?';
        Text10060: Label 'Do you want Update Existing  Return Order Import Type Setup?';

    #region Magento Setup

    local procedure CreateStores(XmlElement: XmlElement; MagentoWebsite: Record "NPR Magento Website")
    var
        MagentoStore: Record "NPR Magento Store";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XNodeSibling: XmlNode;
        XNodeChild: XmlNode;
        XNodeList: XmlNodeList;
        XAttribute: XmlAttribute;
        RootItemGroupNo: Code[20];
    begin
        if XmlElement.IsEmpty then
            exit;

        if XmlElement.SelectNodes('stores/store', XNodeList) then begin
            foreach XNodeChild in XNodeList do begin
                RootItemGroupNo := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'root_category', MaxStrLen(RootItemGroupNo), true), 1, MaxStrLen(RootItemGroupNo));
                if not XmlElement.SelectSingleNode('root_category', XNodeSibling) then
                    Error(Text000, MagentoWebsite.Code);
                RootItemGroupNo := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XNodeSibling, 'external_id', true), 1, MaxStrLen(RootItemGroupNo));
                CreateRootItemGroup(RootItemGroupNo, CopyStr(MagentoWebsite.Name, 1, 50));

                XNodeChild.AsXmlElement().Attributes().Get('code', XAttribute);

                if not MagentoStore.Get(UpperCase(XAttribute.Value)) then begin
                    MagentoStore.Init();
                    MagentoStore.Code := CopyStr(UpperCase(XAttribute.Value), 1, MaxStrLen(MagentoStore.Code));
                    MagentoStore."Website Code" := MagentoWebsite.Code;
                    MagentoStore.Name := CopyStr(XNodeChild.AsXmlElement().InnerText, 1, MaxStrLen(MagentoStore.Name));
                    MagentoStore."Root Item Group No." := RootItemGroupNo;
                    MagentoStore.Insert(true);
                end else
                    if (MagentoStore."Website Code" <> MagentoWebsite.Code) or (MagentoStore.Name <> XNodeChild.AsXmlElement().InnerText) or (MagentoStore."Root Item Group No." <> RootItemGroupNo) then begin
                        MagentoStore."Website Code" := MagentoWebsite.Code;
                        MagentoStore.Name := CopyStr(XNodeChild.AsXmlElement().InnerText, 1, MaxStrLen(MagentoStore.Name));
                        MagentoStore."Root Item Group No." := RootItemGroupNo;
                        MagentoStore.Modify(true);
                    end;
            end;
        end;
    end;

    local procedure CreateRootItemGroup(ItemGroupNo: Code[20]; ItemGroupName: Text[50])
    var
        ItemGroup: Record "NPR Magento Category";
    begin
        if ItemGroup.Get(ItemGroupNo) then begin
            if (ItemGroup.Name <> ItemGroupName) or (not ItemGroup.Root) or (ItemGroup."Root No." <> ItemGroup.Id) then begin
                ItemGroup.Validate(Name, ItemGroupName);
                ItemGroup.Root := true;
                ItemGroup."Root No." := ItemGroup.Id;
                ItemGroup.Modify(true);
            end;
            exit;
        end;

        ItemGroup.Init();
        ItemGroup.Id := ItemGroupNo;
        ItemGroup.Validate(Name, ItemGroupName);
        ItemGroup.Root := true;
        ItemGroup."Root No." := ItemGroup.Id;
        ItemGroup.Insert(true);
    end;

    procedure SetDefaultItemGroupRoots()
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

    procedure SetupImportTypeOrder()
    var
        NaviConnectImportType: Record "NPR Nc Import Type";
    begin
        if not (NaviConnectImportType.Get('ORDER')) then begin
            NaviConnectImportType.Init();
            NaviConnectImportType.Code := 'ORDER';
            NaviConnectImportType.Description := 'magento_services';
            NaviConnectImportType."Import Codeunit ID" := CODEUNIT::"NPR Magento Sales Order Mgt.";
            NaviConnectImportType."Lookup Codeunit ID" := CODEUNIT::"NPR Magento Lookup SalesOrder";
            NaviConnectImportType."Webservice Enabled" := true;
            NaviConnectImportType."Webservice Codeunit ID" := CODEUNIT::"NPR Magento Webservice";
            NaviConnectImportType."Webservice Function" := 'ImportSalesOrders';
            NaviConnectImportType.Insert(true);
        end else begin
            if GuiAllowed then
                if not Confirm(Text10050, true) then
                    exit;
            NaviConnectImportType.Description := 'magento_services';
            NaviConnectImportType."Import Codeunit ID" := CODEUNIT::"NPR Magento Sales Order Mgt.";
            NaviConnectImportType."Lookup Codeunit ID" := CODEUNIT::"NPR Magento Lookup SalesOrder";
            NaviConnectImportType."Webservice Enabled" := true;
            NaviConnectImportType."Webservice Codeunit ID" := CODEUNIT::"NPR Magento Webservice";
            NaviConnectImportType."Webservice Function" := 'ImportSalesOrders';
            NaviConnectImportType.Modify(true);
        end;
    end;

    procedure SetupImportTypeReturnOrder()
    var
        NcImportType: Record "NPR Nc Import Type";
        PrevRec: Text;
    begin
        if not (NcImportType.Get('RETURN_ORD')) then begin
            NcImportType.Init();
            NcImportType.Code := 'RETURN_ORD';
            NcImportType.Description := 'magento_services';
            NcImportType."Import Codeunit ID" := CODEUNIT::"NPR Magento Imp. Ret. Order";
            NcImportType."Lookup Codeunit ID" := CODEUNIT::"NPR Magento Lookup Ret.Order";
            NcImportType."Webservice Enabled" := true;
            NcImportType."Webservice Codeunit ID" := CODEUNIT::"NPR Magento Webservice";
            NcImportType."Webservice Function" := 'ImportSalesReturnOrders';
            NcImportType.Insert(true);
        end;

        PrevRec := Format(NcImportType);
        if GuiAllowed then
            if not Confirm(Text10060, true) then
                exit;
        NcImportType.Description := 'magento_services';
        NcImportType."Import Codeunit ID" := CODEUNIT::"NPR Magento Imp. Ret. Order";
        NcImportType."Lookup Codeunit ID" := CODEUNIT::"NPR Magento Lookup Ret.Order";
        NcImportType."Webservice Enabled" := true;
        NcImportType."Webservice Codeunit ID" := CODEUNIT::"NPR Magento Webservice";
        NcImportType."Webservice Function" := 'ImportSalesReturnOrders';

        if PrevRec <> Format(NcImportType) then
            NcImportType.Modify(true);
    end;

    procedure SetupImportTypes()
    begin
        SetupImportTypeOrder();
        SetupImportTypeReturnOrder();
    end;

    local procedure SetupMagentoCredentials(): Text
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: XmlDocument;
        XElement: XmlElement;
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;

        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'initSetup', XmlDoc);
        XmlDoc.GetRoot(XElement);
        if XElement.IsEmpty then
            exit;
        if NpXmlDomMgt.GetXmlText(XElement, '//status', 0, false) <> Format(false, 0, 9) then
            exit;

        Clear(XmlDoc);
        XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?>' +
                       '<initSetup>' +
                       '  <credential>' +
                       '    <username>' + MagentoSetup.GetApiUsername() + '</username>' +
                       '    <password>' + MagentoSetup.GetApiPassword() + '</password>' +
                       '    <hash>' + MagentoSetup.GetCredentialsHash() + '</hash><!-- a hash of a combination of username,password and private key -->' +
                       '  </credential>' +
                       '</initSetup>', XmlDoc);
        MagentoMgt.MagentoApiPost(MagentoSetup."Api Url", 'initSetup', XmlDoc);
    end;

    local procedure SetupMagentoCustomerGroups()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoCustomerGroup: Record "NPR Magento Customer Group";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: XmlDocument;
        XNode: XmlNode;
        XAttribute: XmlAttribute;
        XNodeList: XmlNodeList;
        GroupCode: Text[32];
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;
        if not MagentoSetup."Customers Enabled" then
            exit;
        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'customer_groups', XmlDoc);

        XmlDoc.SelectNodes('//customer_group', XNodeList);
        foreach XNode in XNodeList do begin
            XNode.AsXmlElement().Attributes().Get('customer_group_code', XAttribute);
            GroupCode := CopyStr(XAttribute.Value, 1, MaxStrLen(MagentoCustomerGroup.Code));
            if GroupCode <> '' then
                if not MagentoCustomerGroup.Get(GroupCode) then begin
                    MagentoCustomerGroup.Init();
                    MagentoCustomerGroup.Code := CopyStr(GroupCode, 1, MaxStrLen(MagentoCustomerGroup.Code));
                    MagentoCustomerGroup."Magento Tax Class" := CopyStr(NpXmlDomMgt.GetXmlText(XNode.AsXmlElement(), 'tax_class_code', 0, false), 1, MaxStrLen(MagentoCustomerGroup."Magento Tax Class"));
                    MagentoCustomerGroup.Insert(true);
                end else begin
                    MagentoCustomerGroup."Magento Tax Class" := CopyStr(NpXmlDomMgt.GetXmlText(XNode.AsXmlElement(), 'tax_class_code', 0, false), 1, MaxStrLen(MagentoCustomerGroup."Magento Tax Class"));
                    MagentoCustomerGroup.Modify(true);
                end;
        end;
    end;

    local procedure SetupMagentoTaxClasses()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoTaxClass: Record "NPR Magento Tax Class";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: XmlDocument;
        XNode: XmlNode;
        XNodeList: XmlNodeList;
        ClassName: Text[250];
        ClassType: Integer;
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'tax_classes', XmlDoc);

        XmlDoc.SelectNodes('//tax_class', XNodeList);
        foreach XNode in XNodeList do begin
            ClassName := CopyStr(NpXmlDomMgt.GetXmlText(XNode.AsXmlElement(), 'class_name', 0, false), 1, MaxStrLen(MagentoTaxClass.Name));
            ClassType := -1;
            case LowerCase(NpXmlDomMgt.GetXmlText(XNode.AsXmlElement(), 'class_type', 0, false)) of
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

    local procedure SetupMagentoWebsites()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoWebsite: Record "NPR Magento Website";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: XmlDocument;
        XNode: XmlNode;
        XNodeList: XmlNodeList;
        XAttribute: XmlAttribute;
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'websites', XmlDoc);

        XmlDoc.SelectNodes('//website', XNodeList);
        foreach XNode in XNodeList do begin
            XNode.AsXmlElement().Attributes().Get('code', XAttribute);
            if not MagentoWebsite.Get(XAttribute.Value) then begin
                MagentoWebsite.Init();
                MagentoWebsite.Code := CopyStr(UpperCase(XAttribute.Value), 1, MaxStrLen(MagentoWebsite.Code));
                MagentoWebsite.Name := CopyStr(NpXmlDomMgt.GetXmlText(XNode.AsXmlElement(), 'name', 0, false), 1, MaxStrLen(MagentoWebsite.Name));
                MagentoWebsite."Default Website" := NpXmlDomMgt.GetXmlText(XNode.AsXmlElement(), 'is_default', 0, false) = '1';
                MagentoWebsite.Insert(true);
            end else begin
                MagentoWebsite.Name := CopyStr(NpXmlDomMgt.GetXmlText(XNode.AsXmlElement(), 'name', 0, false), 1, MaxStrLen(MagentoWebsite.Name));
                MagentoWebsite."Default Website" := NpXmlDomMgt.GetXmlText(XNode.AsXmlElement(), 'is_default', 0, false) = '1';
                MagentoWebsite.Modify(true);
            end;

            if XNode.SelectNodes('store_groups/store_group', XNodeList) then
                foreach XNode in XNodeList do
                    CreateStores(XNode.AsXmlElement(), MagentoWebsite);

            SetDefaultItemGroupRoots();
        end;
    end;

    local procedure SetupPaymentMethodMapping()
    var
        MagentoSetup: Record "NPR Magento Setup";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        XmlDoc: XmlDocument;
        XNode: XmlNode;
        XNodeList: XmlNodeList;
        XAttribute: XmlAttribute;
        PaymentCode: Text[50];
        PaymentType: Text[50];
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'payment_methods', XmlDoc);

        XmlDoc.SelectNodes('//payment_method', XNodeList);
        foreach XNode in XNodeList do begin
            XNode.AsXmlElement().Attributes().Get('code', XAttribute);
            PaymentCode := CopyStr(XAttribute.Value, 1, MaxStrLen(PaymentCode));
            XNode.AsXmlElement().Attributes().Get('type', XAttribute);
            PaymentType := CopyStr(XAttribute.Value, 1, MaxStrLen(PaymentCode));

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
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        XmlDoc: XmlDocument;
        XNode: XmlNode;
        XNodeList: XmlNodeList;
        XAttribute: XmlAttribute;
        ShipmentCode: Text[50];
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'shipping_methods', XmlDoc);

        XmlDoc.SelectNodes('//shipping_method', XNodeList);
        foreach XNode in XNodeList do begin
            XNode.AsXmlElement().Attributes().Get('carrier', XAttribute);
            ShipmentCode := CopyStr(XAttribute.Value, 1, MaxStrLen(ShipmentCode));
            if not ShipmentMapping.Get(ShipmentCode) then begin
                ShipmentMapping.Init();
                ShipmentMapping."External Shipment Method Code" := ShipmentCode;
                ShipmentMapping.Insert(true);
            end;
        end;
    end;

    local procedure SetupNpXmlTemplates()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not MagentoSetup.Get() then
            exit;

        MagentoSetup.Validate("Products XmlTemplates Enabled", true);
        MagentoSetup.Validate("Stock Updat. XmlTempl. Enabled", true);
        MagentoSetup.Validate("Product Att. XmlTempl. Enabled", true);
        MagentoSetup.Validate("Prod. Attr. Sets XmlTem. Enab.", true);
        MagentoSetup.Validate("Order Updat. XmlTempl. Enabled", true);
        MagentoSetup.Validate("Multi Store XmlTempl. Enabled", true);
        MagentoSetup.Validate("Ticket Adm. XmlTempl. Enabled", true);
        MagentoSetup.Validate("Coll. Stores XmlTempl. Enabled", true);
        MagentoSetup.Validate("Delete Cust. XmlTempl. Enabled", true);
        MagentoSetup.Modify();
    end;

    procedure SetupVATBusinessPostingGroups()
    var
        MagentoVATBusinessGroup: Record "NPR Magento VAT Bus. Group";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        if VATBusinessPostingGroup.FindSet() then
            repeat
                if not MagentoVATBusinessGroup.Get(VATBusinessPostingGroup.Code) then begin
                    MagentoVATBusinessGroup.Init();
                    MagentoVATBusinessGroup."VAT Business Posting Group" := VATBusinessPostingGroup.Code;
                    MagentoVATBusinessGroup.Insert(true);
                end;
            until VATBusinessPostingGroup.Next() = 0;
    end;

    procedure SetupVATProductPostingGroups()
    var
        MagentoVATProductGroup: Record "NPR Magento VAT Prod. Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        if VATProductPostingGroup.FindSet() then
            repeat
                if not MagentoVATProductGroup.Get(VATProductPostingGroup.Code) then begin
                    MagentoVATProductGroup.Init();
                    MagentoVATProductGroup."VAT Product Posting Group" := VATProductPostingGroup.Code;
                    MagentoVATProductGroup.Insert(true);
                end;
            until VATProductPostingGroup.Next() = 0;
    end;

    procedure HasSetupCategories(): Boolean
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        MagentoSetupEventSub.SetRange(Type, MagentoSetupEventSub.Type::"Setup Categories");
        MagentoSetupEventSub.SetFilter("Codeunit ID", '>%1', 0);
        MagentoSetupEventSub.SetFilter("Function Name", '<>%1', '');
        MagentoSetupEventSub.SetRange(Enabled, true);
        exit(MagentoSetupEventSub.FindFirst());
    end;

    procedure HasSetupBrands(): Boolean
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        MagentoSetupEventSub.SetRange(Type, MagentoSetupEventSub.Type::"Setup Brands");
        MagentoSetupEventSub.SetFilter("Codeunit ID", '>%1', 0);
        MagentoSetupEventSub.SetFilter("Function Name", '<>%1', '');
        MagentoSetupEventSub.SetRange(Enabled, true);
        exit(MagentoSetupEventSub.FindFirst());
    end;

    #endregion

    procedure TriggerSetupNpXmlTemplates()
    var
        Handled: Boolean;
    begin
        OnSetupNpXmlTemplates(Handled);
        if Handled then
            exit;

        SetupNpXmlTemplates();
    end;

    procedure TriggerSetupMagentoTaxClasses()
    var
        Handled: Boolean;
    begin
        OnSetupMagentoTaxClasses(Handled);
        if Handled then
            exit;

        SetupMagentoTaxClasses();
    end;

    procedure TriggerSetupMagentoCredentials()
    var
        Handled: Boolean;
    begin
        OnSetupMagentoCredentials(Handled);
        if Handled then
            exit;
        SetupMagentoCredentials();
    end;

    procedure TriggerSetupMagentoWebsites()
    var
        Handled: Boolean;
    begin
        OnSetupMagentoWebsites(Handled);
        if Handled then
            exit;

        SetupMagentoWebsites();
    end;

    procedure TriggerSetupMagentoCustomerGroups()
    var
        Handled: Boolean;
    begin
        OnSetupMagentoCustomerGroups(Handled);
        if Handled then
            exit;

        SetupMagentoCustomerGroups();
    end;

    procedure TriggerSetupPaymentMethodMapping()
    var
        Handled: Boolean;
    begin
        OnSetupPaymentMethodMapping(Handled);
        if Handled then
            exit;

        SetupPaymentMethodMapping();
    end;

    procedure TriggerSetupShipmentMethodMapping()
    var
        Handled: Boolean;
    begin
        OnSetupShipmentMethodMapping(Handled);
        if Handled then
            exit;

        SetupShipmentMethodMapping();
    end;

    procedure TriggerSetupCategories(InActiveSession: Boolean)
    var
        Handled: Boolean;
    begin
        OnSetupCategories(Handled, InActiveSession);
        if Handled then
            exit;
    end;

    procedure TriggerSetupBrands(InActiveSession: Boolean)
    var
        Handled: Boolean;
    begin
        OnSetupBrands(Handled, InActiveSession);
        if Handled then
            exit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupNpXmlTemplates(var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupMagentoTaxClasses(var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupMagentoCredentials(var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupMagentoWebsites(var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupMagentoCustomerGroups(var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupPaymentMethodMapping(var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupShipmentMethodMapping(var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupCategories(var Handled: Boolean; InActiveSession: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupBrands(var Handled: Boolean; InActiveSession: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupNpXmlTemplates', '', true, true)]
    local procedure SetupM1SetupNpXmlTemplates(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup NpXml Templates", CurrCodeunitId(), 'SetupM1SetupNpXmlTemplates') then
            exit;

        Handled := true;
        SetupNpXmlTemplates();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupMagentoTaxClasses', '', true, true)]
    local procedure SetupM1MagentoTaxClasses(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Tax Classes", CurrCodeunitId(), 'SetupM1MagentoTaxClasses') then
            exit;

        Handled := true;
        SetupMagentoTaxClasses();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupMagentoCredentials', '', true, true)]
    local procedure SetupM1Credentials(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Api Credentials", CurrCodeunitId(), 'SetupM1Credentials') then
            exit;

        Handled := true;
        SetupMagentoCredentials();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupMagentoWebsites', '', true, true)]
    local procedure SetupM1Websites(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Websites", CurrCodeunitId(), 'SetupM1Websites') then
            exit;

        Handled := true;
        SetupMagentoWebsites();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupMagentoCustomerGroups', '', true, true)]
    local procedure SetupM1CustomerGroups(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Customer Groups", CurrCodeunitId(), 'SetupM1CustomerGroups') then
            exit;

        Handled := true;
        SetupMagentoCustomerGroups();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupPaymentMethodMapping', '', true, true)]
    local procedure SetupM1PaymentMethodMapping(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Payment Method Mapping", CurrCodeunitId(), 'SetupM1PaymentMethodMapping') then
            exit;

        Handled := true;
        SetupPaymentMethodMapping();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Setup Mgt.", 'OnSetupShipmentMethodMapping', '', true, true)]
    local procedure SetupM1ShipmentMethodMapping(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Shipment Method Mapping", CurrCodeunitId(), 'SetupM1ShipmentMethodMapping') then
            exit;

        Handled := true;
        SetupShipmentMethodMapping();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Setup", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyMagentoSetup(var Rec: Record "NPR Magento Setup"; var xRec: Record "NPR Magento Setup"; RunTrigger: Boolean)
    var
        NpCsStore: Record "NPR NpCs Store";
        DataLogMgt: Codeunit "NPR Data Log Management";
        RecRef: RecordRef;
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;

        if xRec."NpCs From Store Code" <> Rec."NpCs From Store Code" then begin
            if (xRec."NpCs From Store Code" <> '') and NpCsStore.Get(xRec."NpCs From Store Code") then begin
                RecRef.GetTable(NpCsStore);
                DataLogMgt.LogDatabaseModify(RecRef);
            end;

            if (Rec."NpCs From Store Code" <> '') and NpCsStore.Get(Rec."NpCs From Store Code") then begin
                RecRef.GetTable(NpCsStore);
                DataLogMgt.LogDatabaseModify(RecRef);
            end;
        end;
    end;

    procedure InitCustomOptionNos(var MagentoSetup: Record "NPR Magento Setup")
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesCode: Code[20];
    begin
        if (not MagentoSetup."Custom Options Enabled") or (MagentoSetup."Custom Options No. Series" <> '') then
            exit;

        NoSeriesCode := 'NC_CUSTOM';
        if NoSeries.Get(NoSeriesCode) then begin
            MagentoSetup."Custom Options No. Series" := NoSeriesCode;
            exit;
        end;

        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries.Description := Text001;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting Date" := Today();
        NoSeriesLine."Starting No." := '00001';
        NoSeriesLine.Insert(true);

        MagentoSetup."Custom Options No. Series" := NoSeriesCode;
    end;

    #region UI Mapping"()

    procedure CheckMappings()
    begin
        CheckVATProductPostingGroups();
        CheckVATBusinessPostingGroups();
        CheckNaviConnectPaymentMethods();
        CheckNaviConnectShipmentMethods();
    end;

    procedure CheckNaviConnectPaymentMethods()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not GuiAllowed then
            exit;
        MagentoSetup.Get();
        if not MagentoSetup."Magento Enabled" then
            exit;
        if Confirm(Text10000, false) then
            PAGE.Run(PAGE::"NPR Magento Payment Mapping");
    end;

    procedure CheckNaviConnectShipmentMethods()
    begin
        if not GuiAllowed then
            exit;
        if Confirm(Text10010, false) then
            PAGE.Run(PAGE::"NPR Magento Shipment Mapping");
    end;

    procedure CheckVATBusinessPostingGroups()
    begin
        if not GuiAllowed then
            exit;
        if Confirm(Text10020, false) then
            PAGE.Run(PAGE::"NPR Magento VAT Bus. Groups");
    end;

    procedure CheckVATProductPostingGroups()
    begin
        if not GuiAllowed then
            exit;
        if Confirm(Text10030, false) then
            PAGE.Run(PAGE::"NPR Magento VAT Prod. Groups");
    end;

    #endregion

    #region Managed Nav Modules
    procedure MagentoVersionId(): Text
    begin
        exit('MAG');
    end;

    procedure MagentoVersionNo(): Code[20]
    begin
        exit('2.26');
    end;

    procedure UpdateVersionNo(var MagentoSetup: Record "NPR Magento Setup")
    begin
        MagentoSetup."Version No." := MagentoVersionId() + MagentoVersionNo();
    end;

    #endregion

    #region Aux

    procedure IsMagentoSetupEventSubscriber(SetupSubscriptionType: Enum "NPR Mag. Setup Event Sub. Type"; CodeunitId: Integer;
                                                                       FunctionName: Text): Boolean
    var
        MagentoSetupSubscription: Record "NPR Magento Setup Event Sub.";
    begin
        if not MagentoSetupSubscription.Get(SetupSubscriptionType, CodeunitId, FunctionName) then
            exit(false);

        exit(MagentoSetupSubscription.Enabled);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento Setup Mgt.");
    end;

    #endregion
}
