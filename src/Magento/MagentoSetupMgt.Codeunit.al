codeunit 6151401 "NPR Magento Setup Mgt."
{
    // MAG1.17/MHA /20150617  CASE 215910 Object created - includes functions to Init, Edit and Read Magento setup
    // MAG1.17/TR  /20150618  CASE 210183 Drawing functions and enumerators GenericSetupMgt.aDDed. Supports generation of Generic Layout (magento setup).
    // MAG1.19/TR  /20150721  CASE 218821 Currency Code added.
    // MAG1.20/TS  /20150811  CASE 218524 Check if SalesPrices or Sales Lines has been enabled in Magento Setup
    // MAG1.21/TS  /20151016  CASE 225180  Implemented parsing of multiple websites
    // MAG1.21/MHA /20151104  CASE 223835 Added Variant Dimension functions:
    //                                    LookupVariantPictureDimension()
    //                                    OpenRecRef()
    //                                    OpenFieldRef()
    //                                    SetupDimensionBuffer()
    //                                    SetupDimensionBufferVariaX()
    //                                    SetupDimensionBufferVariety()
    //                                    ElementName.VariantDimension()
    // MAG1.21/TS  /20151118  CASE 227359 Magento Multistore Version2
    // MAG1.21/MHA /20151120  CASE 227734 WebVariant Deleted
    // MAG1.21/MHA /20151123  CASE 227354 Added MultiStore NpXml Template
    // MAG1.21/TTH /20151119  CASE 227358 Adding function SetupImportTypes
    // MAG1.22/MHA /20151202  CASE 227358 Added ImportType."Webservice Function"
    // MAG1.22/TS  /20151209  CASE 228917 Updated ImportType filter in GetImportTypeCode()
    // MAG1.22/MHA /20160108  CASE 231348 Corrected NpXml setup of Item Discount Group
    // MAG1.22/TS  /20150120  CASE 231762 Added Ticket Enable Npxml Template
    // MAG1.22/TR  /20160414  CASE 238563 Added function InitCustomOptionNos
    // MAG1.22/MHA /20160427  CASE 240212 SetupMagento() function deleted as functionality as been split into individual Actions
    // MAG2.00/MHA /20160513  CASE 240005 Magento module refactored to new object area
    // MAG2.02/TS  /20170208  CASE 265711 Added Template Ticket and Member
    // MAG2.02/TS  /20170213  CASE 266023 Corrected Confirm Dialog
    // MAG2.03/MHA /20170411  CASE 272066 DragDropPicture 1.04 update
    // MAG2.07/MHA /20170830  CASE 286943 Added Publisher Setup functions
    // MAG2.08/TS  /20171013  CASE 288763 Corrected Lookup Codeunit
    // MAG2.08/MHA /20171016  CASE 292926 Added Removed VatBus- and VatProductPostingGroups from Publisher Setup Functions and added SetupNpXmlTemplates
    // MAG2.10/MHA /20180206  CASE 302910 DragDropPicture 1.05 update
    // MAG2.12/MHA /20180425  CASE 309647 Added function SetupImportTypeReturnOrder()
    // MAG2.13/TS  /20180504  CASE 309743 SetupTaxClasses was on Setup Credentials Function
    // MAG2.17/TS  /20181031  CASE 333862 Seo Link should be filled as well
    // MAG2.22/MHA /20190625  CASE 359285 Added Picture Variety Type in SetupNpXmlTemplates()
    // MAG2.23/MHA /20191018  CASE 373610 Bumped version list in MagentoVersionNo()
    // MAG2.24/MHA /20191018  CASE 386235 Bumped version list in MagentoVersionNo()
    // MAG2.25/BHR /20200212  CASE 374800 Add confirmation box to prevent setup overide
    // MAG2.25/MHA /20200214  CASE 390939 Member- and Ticket Template should only be created if Ticket Module is enabled
    // MAG2.25/MHA /20200416  CASE 400486 Bumped version list in MagentoVersionNo()
    // MAG2.26/MHA /20200527  CASE 406591 Added function OnAfterModifyMagentoSetup()
    // MAG2.26/MHA /20200601  CASE 404580 Added functions for setting up Categories and Brands
    // MAG2.26/MHA /20200602  CASE 407764 Bumped version list


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Root Categoery is missing for Website %1';
        Text001: Label 'Magento Custom Options';
        Text10000: Label 'Check Payment Mapping?';
        Text10010: Label 'Check Shipment Mapping?';
        Text10020: Label 'Check VAT Business Posting Groups?';
        Text10030: Label 'Check VAT Product Posting Groups?';
        Text10040: Label '%1 does not exist in the database';
        Text10050: Label 'Do you want Update Existing Order Import Type Setup?';
        Text10060: Label 'Do you want Update Existing  Return Order Import Type Setup?';

    procedure "--- Magento Setup"()
    begin
    end;

    local procedure CreateStores(var XmlElement: DotNet NPRNetXmlElement; MagentoWebsite: Record "NPR Magento Website")
    var
        MagentoStore: Record "NPR Magento Store";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlElement2: DotNet NPRNetXmlElement;
        XmlElement3: DotNet NPRNetXmlElement;
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
        ItemGroup: Record "NPR Magento Category";
    begin
        if ItemGroup.Get(ItemGroupNo) then begin
            if (ItemGroup.Name <> ItemGroupName) or (not ItemGroup.Root) or (ItemGroup."Root No." <> ItemGroup.Id) then begin
                //-MAG2.17 [333862]
                //ItemGroup.Name := ItemGroupName;
                ItemGroup.Validate(Name, ItemGroupName);
                //+MAG2.17 [333862]
                ItemGroup.Root := true;
                ItemGroup."Root No." := ItemGroup.Id;
                ItemGroup.Modify(true);
            end;
            exit;
        end;

        ItemGroup.Init;
        ItemGroup.Id := ItemGroupNo;
        //-MAG2.17 [333862]
        //ItemGroup.Name := ItemGroupName;
        ItemGroup.Validate(Name, ItemGroupName);
        //+MAG2.17 [333862]
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
        if not MagentoWebsite.FindFirst then
            exit;

        MagentoStore.SetRange("Website Code", MagentoWebsite.Code);
        MagentoStore.SetFilter("Root Item Group No.", '<>%1', '');
        if not MagentoStore.FindFirst then
            exit;

        ItemGroup.SetFilter("Parent Category Id", '=%1', '');
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

    procedure SetupClientAddIns()
    var
        ClientAddinName: Text[220];
        Description: Text[250];
        PublicKeyToken: Text[20];
        Version: Text[25];
    begin
        Version := '';
        PublicKeyToken := '867142ff84820aec';

        Description := 'NaviPartner.NaviConnect.PictureViewer';
        //-MAG2.10 [302910]
        //ClientAddinName := 'NaviPartner.NaviConnect.DragDropPicture.1.04';
        ClientAddinName := 'NaviPartner.NaviConnect.DragDropPicture.1.05';
        //+MAG2.10 [302910]
        SetupClientAddIn(ClientAddinName, PublicKeyToken, Version, Description);

        Description := 'NaviPartner.NaviConnect.TextEditor';
        ClientAddinName := 'NaviPartner.NaviConnect.TextEditor.1.01';
        SetupClientAddIn(ClientAddinName, PublicKeyToken, Version, Description);
    end;

    procedure SetupClientAddIn(Name: Text[220]; PublicKeyToken: Text[20]; Version: Text[25]; Description: Text[250])
    var
        ClientAddin: Record "Add-in";
        MemoryStream: DotNet NPRNetMemoryStream;
        WebClient: DotNet NPRNetWebClient;
        OutStream: OutStream;
    begin
        WebClient := WebClient.WebClient;
        MemoryStream := MemoryStream.MemoryStream(WebClient.DownloadData('http://xsd.navipartner.dk/naviconnect/client_addins/' + Name + '.zip'));

        if not ClientAddin.Get(Name, PublicKeyToken) then begin
            ClientAddin.Init;
            ClientAddin."Add-in Name" := Name;
            ClientAddin."Public Key Token" := PublicKeyToken;
            ClientAddin.Version := Version;
            ClientAddin.Description := Description;
            ClientAddin.Insert(true);
        end;

        ClientAddin.Version := Version;
        ClientAddin.Description := Description;
        ClientAddin.Resource.CreateOutStream(OutStream);
        CopyStream(OutStream, MemoryStream);
        ClientAddin.Modify(true);
    end;

    procedure SetupImportTypeOrder()
    var
        NaviConnectImportType: Record "NPR Nc Import Type";
        ServiceName: Text;
        WebService: Record "Web Service";
    begin
        if not (NaviConnectImportType.Get('ORDER')) then begin
            NaviConnectImportType.Init;
            NaviConnectImportType.Code := 'ORDER';
            NaviConnectImportType.Description := 'magento_services';
            NaviConnectImportType."Import Codeunit ID" := CODEUNIT::"NPR Magento Sales Order Mgt.";
            //-MAG2.08 [288763]
            //NaviConnectImportType."Lookup Codeunit ID" := CODEUNIT::"Magento Pmt. Mgt.";
            NaviConnectImportType."Lookup Codeunit ID" := CODEUNIT::"NPR Magento Lookup SalesOrder";
            //+MAG2.08 [288763]
            NaviConnectImportType."Webservice Enabled" := true;
            NaviConnectImportType."Webservice Codeunit ID" := CODEUNIT::"NPR Magento Webservice";
            NaviConnectImportType."Webservice Function" := 'ImportSalesOrders';
            NaviConnectImportType.Insert(true);
        end else begin
            //-MAG2.25 [374800]
            if GuiAllowed then
                if not Confirm(Text10050, true) then
                    exit;
            //+MAG2.25 [374800]
            NaviConnectImportType.Description := 'magento_services';
            NaviConnectImportType."Import Codeunit ID" := CODEUNIT::"NPR Magento Sales Order Mgt.";
            //-MAG2.08 [288763]
            //NaviConnectImportType."Lookup Codeunit ID" := CODEUNIT::"Magento Pmt. Mgt.";
            NaviConnectImportType."Lookup Codeunit ID" := CODEUNIT::"NPR Magento Lookup SalesOrder";
            //+MAG2.08 [288763]
            NaviConnectImportType."Webservice Enabled" := true;
            NaviConnectImportType."Webservice Codeunit ID" := CODEUNIT::"NPR Magento Webservice";
            NaviConnectImportType."Webservice Function" := 'ImportSalesOrders';
            NaviConnectImportType.Modify(true);
        end;
    end;

    procedure SetupImportTypeReturnOrder()
    var
        NcImportType: Record "NPR Nc Import Type";
        ServiceName: Text;
        WebService: Record "Web Service";
        PrevRec: Text;
    begin
        //-MAG2.12 [309647]
        if not (NcImportType.Get('RETURN_ORD')) then begin
            NcImportType.Init;
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
        //-MAG2.25 [374800]
        if GuiAllowed then
            if not Confirm(Text10060, true) then
                exit;
        //+MAG2.25 [374800]
        NcImportType.Description := 'magento_services';
        NcImportType."Import Codeunit ID" := CODEUNIT::"NPR Magento Imp. Ret. Order";
        NcImportType."Lookup Codeunit ID" := CODEUNIT::"NPR Magento Lookup Ret.Order";
        NcImportType."Webservice Enabled" := true;
        NcImportType."Webservice Codeunit ID" := CODEUNIT::"NPR Magento Webservice";
        NcImportType."Webservice Function" := 'ImportSalesReturnOrders';

        if PrevRec <> Format(NcImportType) then
            NcImportType.Modify(true);
        //+MAG2.12 [309647]
    end;

    procedure SetupImportTypes()
    var
        NaviConnectImportType: Record "NPR Nc Import Type";
        ServiceName: Text;
        WebService: Record "Web Service";
    begin
        //-MAG2.00
        SetupImportTypeOrder();
        //+MAG2.00
        //-MAG2.12 [309647]
        SetupImportTypeReturnOrder();
        //+MAG2.12 [309647]
    end;

    local procedure SetupMagentoCredentials(): Text
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        FormsAuthentication: DotNet NPRNetFormsAuthentication;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;

        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'initSetup', XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
            exit;
        if NpXmlDomMgt.GetXmlText(XmlElement, 'status', 0, false) <> Format(false, 0, 9) then
            exit;

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml('<?xml version="1.0" encoding="utf-8"?>' +
                       '<initSetup>' +
                       '  <credential>' +
                       '    <username>' + MagentoSetup.GetApiUsername() + '</username>' +
                       '    <password>' + MagentoSetup."Api Password" + '</password>' +
                       '    <hash>' + MagentoSetup.GetCredentialsHash() + '</hash><!-- a hash of a combination of username,password and private key -->' +
                       '  </credential>' +
                       '</initSetup>');
        MagentoMgt.MagentoApiPost(MagentoSetup."Api Url", 'initSetup', XmlDoc);
    end;

    local procedure SetupMagentoCustomerGroups()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoCustomerGroup: Record "NPR Magento Customer Group";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
        GroupCode: Text[32];
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;
        if not MagentoSetup."Customers Enabled" then
            exit;
        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'customer_groups', XmlDoc);

        NpXmlDomMgt.FindNodes(XmlDoc, 'customer_group', XmlNodeList);
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            GroupCode := CopyStr(XmlElement.GetAttribute('customer_group_code'), 1, MaxStrLen(MagentoCustomerGroup.Code));
            if GroupCode <> '' then
                if not MagentoCustomerGroup.Get(GroupCode) then begin
                    MagentoCustomerGroup.Init;
                    MagentoCustomerGroup.Code := GroupCode;
                    MagentoCustomerGroup."Magento Tax Class" := NpXmlDomMgt.GetXmlText(XmlElement, 'tax_class_code', 0, false);
                    MagentoCustomerGroup.Insert(true);
                end else begin
                    MagentoCustomerGroup."Magento Tax Class" := NpXmlDomMgt.GetXmlText(XmlElement, 'tax_class_code', 0, false);
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
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
        ClassName: Text[250];
        ClassType: Integer;
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'tax_classes', XmlDoc);

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

    local procedure SetupMagentoWebsites()
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoWebsite: Record "NPR Magento Website";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'websites', XmlDoc);

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

    local procedure SetupPaymentMethodMapping()
    var
        MagentoSetup: Record "NPR Magento Setup";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        XmlNodeList2: DotNet NPRNetXmlNodeList;
        i: Integer;
        j: Integer;
        PaymentCode: Text[50];
        PaymentType: Text[50];
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'payment_methods', XmlDoc);

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
        MagentoSetup: Record "NPR Magento Setup";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        XmlNodeList2: DotNet NPRNetXmlNodeList;
        i: Integer;
        j: Integer;
        ShipmentCode: Text[50];
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;
        MagentoMgt.MagentoApiGet(MagentoSetup."Api Url", 'shipping_methods', XmlDoc);

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

    local procedure SetupNpXmlTemplates()
    var
        MagentoSetup: Record "NPR Magento Setup";
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlElement2: Record "NPR NpXml Element";
        NpXmlFilter: Record "NPR NpXml Filter";
        TempBlob: Codeunit "Temp Blob";
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NpXmlSetupMgt: Codeunit "NPR Magento NpXml Setup Mgt";
        VariaXElementLineNo: Integer;
        ColorDimension: Code[20];
        SizeDimension: Code[20];
    begin
        //-MAG2.00
        if not MagentoSetup.Get then
            exit;

        MagentoGenericSetupMgt.InitGenericMagentoSetup(MagentoSetup);
        TempBlob.FromRecord(MagentoSetup, MagentoSetup.FieldNo("Generic Setup"));

        NpXmlSetupMgt.SetupTemplateItem(TempBlob, MagentoSetup."Magento Enabled");
        NpXmlSetupMgt.SetupTemplatePicture(TempBlob, MagentoSetup."Magento Enabled");
        NpXmlSetupMgt.SetupTemplateItemInventory(TempBlob, MagentoSetup."Magento Enabled");
        NpXmlSetupMgt.SetupTemplateItemStore(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Multistore Enabled");
        NpXmlSetupMgt.SetupTemplateItemGroup(TempBlob, MagentoSetup."Magento Enabled");
        NpXmlSetupMgt.SetupTemplateOrderStatus(TempBlob, MagentoSetup."Magento Enabled");
        NpXmlSetupMgt.SetupTemplateBrand(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Brands Enabled");
        NpXmlSetupMgt.SetupTemplateGiftVoucher(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Gift Voucher Enabled");
        NpXmlSetupMgt.SetupTemplateCreditVoucher(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Gift Voucher Enabled");
        NpXmlSetupMgt.SetupTemplateAttribute(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Attributes Enabled");
        NpXmlSetupMgt.SetupTemplateAttributeSet(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Attributes Enabled");
        NpXmlSetupMgt.SetupTemplateCustomer(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled");
        NpXmlSetupMgt.SetupTemplateDisplayConfig(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled");
        NpXmlSetupMgt.SetupTemplateSalesPrice(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Sales Prices Enabled");
        NpXmlSetupMgt.SetupTemplateSalesLineDiscount(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Sales Line Discounts Enabled");
        NpXmlSetupMgt.SetupTemplateItemDiscountGroup(TempBlob, MagentoSetup."Magento Enabled" and MagentoSetup."Item Disc. Group Enabled");
        //-MAG2.25 [390939]
        NpXmlSetupMgt.SetupTemplateTicket(TempBlob, MagentoSetup."Tickets Enabled");
        NpXmlSetupMgt.SetupTemplateMember(TempBlob, MagentoSetup."Tickets Enabled");
        //+MAG2.25 [390939]
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/manufacturer', '', MagentoSetup."Brands Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/product_external_attributes', '', MagentoSetup."Attributes Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/related_products', '', MagentoSetup."Product Relations Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/special_price', '', MagentoSetup."Special Prices Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/special_price_from', '', MagentoSetup."Special Prices Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/special_price_to', '', MagentoSetup."Special Prices Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/tier_prices', '', MagentoSetup."Tier Prices Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/group_prices', '', MagentoSetup."Customer Group Prices Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/custom_options', '', MagentoSetup."Custom Options Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/bundled_options', '', MagentoSetup."Bundled Products Enabled");
        NpXmlSetupMgt.SetSalesPriceEnabled(TempBlob, 'product/unit_codes', '', MagentoSetup."Sales Prices Enabled" or MagentoSetup."Sales Line Discounts Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/ticket_setup', '', MagentoSetup."Tickets Enabled");
        NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer', '', MagentoSetup."Variant System" = MagentoSetup."Variant System"::Variety);
        //-MAG2.22 [359285]
        case MagentoSetup."Variant System" of
            MagentoSetup."Variant System"::Variety:
                begin
                    NpXmlSetupMgt.SetItemFilterValue(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery',
                      '', 'fixed_variety_1_buffer', '', 6059970, MagentoSetup."Variant Picture Dimension");
                    NpXmlSetupMgt.SetItemFilterValue(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery',
                      '', 'fixed_variety_2_buffer', '', 6059973, MagentoSetup."Variant Picture Dimension");
                    NpXmlSetupMgt.SetItemFilterValue(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery',
                      '', 'fixed_variety_3_buffer', '', 6059976, MagentoSetup."Variant Picture Dimension");
                    NpXmlSetupMgt.SetItemFilterValue(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery',
                      '', 'fixed_variety_4_buffer', '', 6059979, MagentoSetup."Variant Picture Dimension");

                    NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/fixed_variety_1_buffer',
                      '', MagentoSetup."Picture Variety Type" = MagentoSetup."Picture Variety Type"::Fixed);
                    NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/fixed_variety_2_buffer',
                      '', MagentoSetup."Picture Variety Type" = MagentoSetup."Picture Variety Type"::Fixed);
                    NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/fixed_variety_3_buffer',
                      '', MagentoSetup."Picture Variety Type" = MagentoSetup."Picture Variety Type"::Fixed);
                    NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/fixed_variety_4_buffer',
                      '', MagentoSetup."Picture Variety Type" = MagentoSetup."Picture Variety Type"::Fixed);
                    NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/variety_1_buffer',
                      '', MagentoSetup."Picture Variety Type" in [MagentoSetup."Picture Variety Type"::"Select on Item", MagentoSetup."Picture Variety Type"::"Variety 1"]);
                    NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/variety_2_buffer',
                      '', MagentoSetup."Picture Variety Type" in [MagentoSetup."Picture Variety Type"::"Select on Item", MagentoSetup."Picture Variety Type"::"Variety 2"]);
                    NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/variety_3_buffer',
                      '', MagentoSetup."Picture Variety Type" in [MagentoSetup."Picture Variety Type"::"Select on Item", MagentoSetup."Picture Variety Type"::"Variety 3"]);
                    NpXmlSetupMgt.SetItemElementEnabled(TempBlob, 'product/variety_buffer/variant_setup/variants/variant/media_gallery/variety_4_buffer',
                      '', MagentoSetup."Picture Variety Type" in [MagentoSetup."Picture Variety Type"::"Select on Item", MagentoSetup."Picture Variety Type"::"Variety 4"]);
                end;
        end;
        //+MAG2.22 [359285]
        //+MAG2.00
    end;

    procedure SetupVATBusinessPostingGroups()
    var
        MagentoVATBusinessGroup: Record "NPR Magento VAT Bus. Group";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        if VATBusinessPostingGroup.FindSet then
            repeat
                if not MagentoVATBusinessGroup.Get(VATBusinessPostingGroup.Code) then begin
                    MagentoVATBusinessGroup.Init;
                    MagentoVATBusinessGroup."VAT Business Posting Group" := VATBusinessPostingGroup.Code;
                    MagentoVATBusinessGroup.Insert(true);
                end;
            until VATBusinessPostingGroup.Next = 0;
    end;

    procedure SetupVATProductPostingGroups()
    var
        MagentoVATProductGroup: Record "NPR Magento VAT Prod. Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        if VATProductPostingGroup.FindSet then
            repeat
                if not MagentoVATProductGroup.Get(VATProductPostingGroup.Code) then begin
                    MagentoVATProductGroup.Init;
                    MagentoVATProductGroup."VAT Product Posting Group" := VATProductPostingGroup.Code;
                    MagentoVATProductGroup.Insert(true);
                end;
            until VATProductPostingGroup.Next = 0;
    end;

    procedure HasSetupCategories(): Boolean
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        //-MAG2.26 [404580]
        MagentoSetupEventSub.SetRange(Type, MagentoSetupEventSub.Type::"Setup Categories");
        MagentoSetupEventSub.SetFilter("Codeunit ID", '>%1', 0);
        MagentoSetupEventSub.SetFilter("Function Name", '<>%1', '');
        MagentoSetupEventSub.SetRange(Enabled, true);
        exit(MagentoSetupEventSub.FindFirst);
        //+MAG2.26 [404580]
    end;

    procedure HasSetupBrands(): Boolean
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        //-MAG2.26 [404580]
        MagentoSetupEventSub.SetRange(Type, MagentoSetupEventSub.Type::"Setup Brands");
        MagentoSetupEventSub.SetFilter("Codeunit ID", '>%1', 0);
        MagentoSetupEventSub.SetFilter("Function Name", '<>%1', '');
        MagentoSetupEventSub.SetRange(Enabled, true);
        exit(MagentoSetupEventSub.FindFirst);
        //+MAG2.26 [404580]
    end;

    procedure "--- Setup Event Triggers"()
    begin
    end;

    procedure TriggerSetupNpXmlTemplates()
    var
        Handled: Boolean;
    begin
        //-MAG2.08 [292926]
        OnSetupNpXmlTemplates(Handled);
        if Handled then
            exit;

        SetupNpXmlTemplates();
        //+MAG2.08 [292926]
    end;

    procedure TriggerSetupMagentoTaxClasses()
    var
        Handled: Boolean;
    begin
        //-MAG2.07 [286943]
        OnSetupMagentoTaxClasses(Handled);
        if Handled then
            exit;

        SetupMagentoTaxClasses();
        //+MAG2.07 [286943]
    end;

    procedure TriggerSetupMagentoCredentials()
    var
        Handled: Boolean;
    begin
        //-MAG2.13 [309743]
        ////-MAG2.07 [286943]
        //OnSetupMagentoTaxClasses(Handled);
        //IF Handled THEN
        //  EXIT;

        //SetupMagentoTaxClasses();
        OnSetupMagentoCredentials(Handled);
        if Handled then
            exit;
        SetupMagentoCredentials();
        //+MAG2.07 [286943]
        //+MAG2.13 [309743]
    end;

    procedure TriggerSetupMagentoWebsites()
    var
        Handled: Boolean;
    begin
        //-MAG2.07 [286943]
        OnSetupMagentoWebsites(Handled);
        if Handled then
            exit;

        SetupMagentoWebsites();
        //+MAG2.07 [286943]
    end;

    procedure TriggerSetupMagentoCustomerGroups()
    var
        Handled: Boolean;
    begin
        //-MAG2.07 [286943]
        OnSetupMagentoCustomerGroups(Handled);
        if Handled then
            exit;

        SetupMagentoCustomerGroups();
        //+MAG2.07 [286943]
    end;

    procedure TriggerSetupPaymentMethodMapping()
    var
        Handled: Boolean;
    begin
        //-MAG2.07 [286943]
        OnSetupPaymentMethodMapping(Handled);
        if Handled then
            exit;

        SetupPaymentMethodMapping();
        //+MAG2.07 [286943]
    end;

    procedure TriggerSetupShipmentMethodMapping()
    var
        Handled: Boolean;
    begin
        //-MAG2.07 [286943]
        OnSetupShipmentMethodMapping(Handled);
        if Handled then
            exit;

        SetupShipmentMethodMapping();
        //+MAG2.07 [286943]
    end;

    procedure TriggerSetupCategories()
    var
        Handled: Boolean;
    begin
        //-MAG2.26 [404580]
        OnSetupCategories(Handled);
        if Handled then
            exit;
        //+MAG2.26 [404580]
    end;

    procedure TriggerSetupBrands()
    var
        Handled: Boolean;
    begin
        //-MAG2.26 [404580]
        OnSetupBrands(Handled);
        if Handled then
            exit;
        //+MAG2.26 [404580]
    end;

    local procedure "--- Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupNpXmlTemplates(var Handled: Boolean)
    begin
        //-MAG2.08 [292926]
        //+MAG2.08 [292926]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupMagentoTaxClasses(var Handled: Boolean)
    begin
        //-MAG2.07 [286943]
        //+MAG2.07 [286943]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupMagentoCredentials(var Handled: Boolean)
    begin
        //-MAG2.07 [286943]
        //+MAG2.07 [286943]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupMagentoWebsites(var Handled: Boolean)
    begin
        //-MAG2.07 [286943]
        //+MAG2.07 [286943]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupMagentoCustomerGroups(var Handled: Boolean)
    begin
        //-MAG2.07 [286943]
        //+MAG2.07 [286943]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupPaymentMethodMapping(var Handled: Boolean)
    begin
        //-MAG2.07 [286943]
        //+MAG2.07 [286943]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupShipmentMethodMapping(var Handled: Boolean)
    begin
        //-MAG2.07 [286943]
        //+MAG2.07 [286943]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupCategories(var Handled: Boolean)
    begin
        //-MAG2.26 [404580]
        //+MAG2.26 [404580]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupBrands(var Handled: Boolean)
    begin
        //-MAG2.26 [404580]
        //+MAG2.26 [404580]
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupNpXmlTemplates', '', true, true)]
    local procedure SetupM1SetupNpXmlTemplates(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        //-MAG2.08 [292926]
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup NpXml Templates", CurrCodeunitId(), 'SetupM1SetupNpXmlTemplates') then
            exit;

        Handled := true;
        SetupNpXmlTemplates();
        //+MAG2.08 [292926]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupMagentoTaxClasses', '', true, true)]
    local procedure SetupM1MagentoTaxClasses(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        //-MAG2.07 [286943]
        //-MAG2.08 [292926]
        //IF NOT IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Api Credentials",CurrCodeunitId(),'SetupM1MagentoTaxClasses') THEN
        //  EXIT;
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Tax Classes", CurrCodeunitId(), 'SetupM1MagentoTaxClasses') then
            exit;
        //+MAG2.08 [292926]

        Handled := true;
        SetupMagentoTaxClasses();
        //+MAG2.07 [286943]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupMagentoCredentials', '', true, true)]
    local procedure SetupM1Credentials(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        //-MAG2.07 [286943]
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Api Credentials", CurrCodeunitId(), 'SetupM1Credentials') then
            exit;

        Handled := true;
        SetupMagentoCredentials();
        //+MAG2.07 [286943]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupMagentoWebsites', '', true, true)]
    local procedure SetupM1Websites(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        //-MAG2.07 [286943]
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Websites", CurrCodeunitId(), 'SetupM1Websites') then
            exit;

        Handled := true;
        SetupMagentoWebsites();
        //+MAG2.07 [286943]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupMagentoCustomerGroups', '', true, true)]
    local procedure SetupM1CustomerGroups(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        //-MAG2.07 [286943]
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Magento Customer Groups", CurrCodeunitId(), 'SetupM1CustomerGroups') then
            exit;

        Handled := true;
        SetupMagentoCustomerGroups();
        //+MAG2.07 [286943]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupPaymentMethodMapping', '', true, true)]
    local procedure SetupM1PaymentMethodMapping(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        //-MAG2.07 [286943]
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Payment Method Mapping", CurrCodeunitId(), 'SetupM1PaymentMethodMapping') then
            exit;

        Handled := true;
        SetupPaymentMethodMapping();
        //+MAG2.07 [286943]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151401, 'OnSetupShipmentMethodMapping', '', true, true)]
    local procedure SetupM1ShipmentMethodMapping(var Handled: Boolean)
    var
        MagentoSetupEventSub: Record "NPR Magento Setup Event Sub.";
    begin
        //-MAG2.07 [286943]
        if not IsMagentoSetupEventSubscriber(MagentoSetupEventSub.Type::"Setup Shipment Method Mapping", CurrCodeunitId(), 'SetupM1ShipmentMethodMapping') then
            exit;

        Handled := true;
        SetupShipmentMethodMapping();
        //+MAG2.07 [286943]
    end;

    [EventSubscriber(ObjectType::Table, 6151401, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyMagentoSetup(var Rec: Record "NPR Magento Setup"; var xRec: Record "NPR Magento Setup"; RunTrigger: Boolean)
    var
        NpCsStore: Record "NPR NpCs Store";
        DataLogMgt: Codeunit "NPR Data Log Management";
        RecRef: RecordRef;
    begin
        //-MAG2.26 [406591]
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;

        if xRec."NpCs From Store Code" <> Rec."NpCs From Store Code" then begin
            if (xRec."NpCs From Store Code" <> '') and NpCsStore.Get(xRec."NpCs From Store Code") then begin
                RecRef.GetTable(NpCsStore);
                DataLogMgt.OnDatabaseModify(RecRef);
            end;

            if (Rec."NpCs From Store Code" <> '') and NpCsStore.Get(Rec."NpCs From Store Code") then begin
                RecRef.GetTable(NpCsStore);
                DataLogMgt.OnDatabaseModify(RecRef);
            end;
        end;
        //+MAG2.26 [406591]
    end;

    procedure "--- No. Mgt."()
    begin
    end;

    procedure InitCustomOptionNos(var MagentoSetup: Record "NPR Magento Setup")
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesCode: Code[10];
    begin
        if (not MagentoSetup."Custom Options Enabled") or (MagentoSetup."Custom Options No. Series" <> '') then
            exit;

        NoSeriesCode := 'NC_CUSTOM';
        if NoSeries.Get(NoSeriesCode) then begin
            MagentoSetup."Custom Options No. Series" := NoSeriesCode;
            exit;
        end;

        NoSeries.Init;
        NoSeries.Code := NoSeriesCode;
        NoSeries.Description := Text001;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert(true);

        NoSeriesLine.Init;
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting Date" := Today;
        NoSeriesLine."Starting No." := '00001';
        NoSeriesLine.Insert(true);

        MagentoSetup."Custom Options No. Series" := NoSeriesCode;
    end;

    procedure "--- UI Mapping"()
    begin
    end;

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
        MagentoSetup.Get;
        if not MagentoSetup."Magento Enabled" then
            exit;
        if Confirm(Text10000, false) then
            //-MAG2.08 [292926]
            //PAGE.RUNMODAL(PAGE::"Magento Payment Mapping");
            PAGE.Run(PAGE::"NPR Magento Payment Mapping");
        //+MAG2.08 [292926]
    end;

    procedure CheckNaviConnectShipmentMethods()
    begin
        if not GuiAllowed then
            exit;
        if Confirm(Text10010, false) then
            //-MAG2.08 [292926]
            //PAGE.RUNMODAL(PAGE::"Magento Shipment Mapping");
            PAGE.Run(PAGE::"NPR Magento Shipment Mapping");
        //+MAG2.08 [292926]
    end;

    procedure CheckVATBusinessPostingGroups()
    begin
        if not GuiAllowed then
            exit;
        if Confirm(Text10020, false) then
            //-MAG2.08 [292926]
            //PAGE.RUNMODAL(PAGE::"Magento VAT Business Groups");
            PAGE.Run(PAGE::"NPR Magento VAT Bus. Groups");
        //+MAG2.08 [292926]
    end;

    procedure CheckVATProductPostingGroups()
    begin
        if not GuiAllowed then
            exit;
        if Confirm(Text10030, false) then
            //-MAG2.08 [292926]
            //PAGE.RUNMODAL(PAGE::"Magento VAT Product Groups");
            PAGE.Run(PAGE::"NPR Magento VAT Prod. Groups");
        //+MAG2.08 [292926]
    end;

    procedure "--- Managed Nav Modules"()
    begin
    end;

    procedure ShowMissingObjects(var MagentoSetup: Record "NPR Magento Setup")
    var
        NcManagedNavModulesMgt: Codeunit "NPR Nc Man. Nav Modules Mgt.";
        TempObject: Record "Object" temporary;
    begin
        NcManagedNavModulesMgt.FindMissingObjects(MagentoVersionId(), MagentoSetup."Version No.",
          MagentoSetup."Managed Nav Api Url", MagentoSetup."Managed Nav Api Username", MagentoSetup."Managed Nav Api Password", TempObject);

        PAGE.Run(PAGE::"Code Coverage Object", TempObject);
    end;

    procedure MagentoVersionId(): Text
    begin
        exit('MAG');
    end;

    procedure MagentoVersionNo(): Code[20]
    begin
        //-MAG2.26 [407764]
        exit('2.26');
        //+MAG2.26 [407764]
    end;

    procedure UpdateVersionNo(var MagentoSetup: Record "NPR Magento Setup")
    begin
        //-MAG2.22 [359285]
        MagentoSetup."Version No." := MagentoVersionId() + MagentoVersionNo();
        //+MAG2.22 [359285]
    end;

    local procedure "--- Aux"()
    begin
    end;

    procedure IsMagentoSetupEventSubscriber(SetupSubscriptionType: Integer; CodeunitId: Integer; FunctionName: Text): Boolean
    var
        MagentoSetupSubscription: Record "NPR Magento Setup Event Sub.";
    begin
        //-MAG2.07 [286943]
        if not MagentoSetupSubscription.Get(SetupSubscriptionType, CodeunitId, FunctionName) then
            exit(false);

        exit(MagentoSetupSubscription.Enabled);
        //+MAG2.07 [286943]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-MAG2.07 [286943]
        exit(CODEUNIT::"NPR Magento Setup Mgt.");
        //+MAG2.07 [286943]
    end;
}

