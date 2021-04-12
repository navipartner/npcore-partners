codeunit 6151450 "NPR Magento NpXml Setup Mgt"
{
    var
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";

    local procedure AddNpXmlTemplate(var XmlDoc: XmlDocument; NodePath: Text; UpdateCode: Code[20]; DeleteCode: Code[20])
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
    begin
        MagentoGenericSetupMgt.AddFieldText(XmlDoc, NodePath, "ElementName.Update"(), UpdateCode);
        MagentoGenericSetupMgt.AddFieldText(XmlDoc, NodePath, "ElementName.Delete"(), DeleteCode);
    end;

    procedure InitNpXmlTemplateSetup(var TempBlob: Codeunit "Temp Blob")
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        XmlDoc: XmlDocument;
        OutStream: OutStream;
        NodePath: Text;
    begin
        MagentoGenericSetupMgt.LoadGenericSetup(TempBlob, XmlDoc);

        NodePath := '';
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.TemplateSetup"());

        NodePath := "ElementName.TemplateSetup"();
        MagentoGenericSetupMgt.AddFieldText(XmlDoc, NodePath, "ElementName.TemplateUrl", 'http://xsd.navipartner.dk/naviconnect/npxml_templates/navishop2dev90/');
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.B2C");

        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C";
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.Item");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.ItemGroup");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.ItemInventory");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.ItemStore");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.Brand");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.ItemAttribute");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.ItemAttributeSet");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.Picture");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.GiftVoucher");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.CreditVoucher");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.OrderStatus");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.Ticket");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.Membership");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.CollectStore");

        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/ ' + "ElementName.Item";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ITEM', 'DEL_ITEM');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.ItemGroup";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ITEM_GROUP', 'DEL_ITEM_GROUP');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.ItemInventory";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ITEM__STOCK', '');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.ItemStore";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ITEM__STORE', '');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Brand";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_MANUFACTURER', 'DEL_MANUFACTURER');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.ItemAttribute";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_PROD_ATTR', 'DEL_PROD_ATTR');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.ItemAttributeSet";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_PROD_ATTR_SET', 'DEL_PROD_ATTR_SET');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Picture";
        AddNpXmlTemplate(XmlDoc, NodePath, '', 'DEL_MAG_PICTURE');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.GiftVoucher";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_GIFT_VOUCHER', '');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.CreditVoucher";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_CREDIT_VOUCHER', '');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.OrderStatus";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ORDER_STATUS', '');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Ticket";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_TICKET_ADMISSION', '');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Membership";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_MEMBERSHIP', '');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.CollectStore";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_COLLECT_STORE', 'DEL_COLLECT_STORE');
        NodePath := "ElementName.TemplateSetup"();
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.B2B");

        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B";
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.Customer");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.DisplayConfig");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.SalesPrice");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.SalesLineDiscount");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.ItemDiscountGroup");

        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B"() + '/' + "ElementName.Customer";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_CONT_RELATION', 'DEL_CONTACT');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B"() + '/' + "ElementName.DisplayConfig";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_DISPLAY_CONFIG', 'DEL_DISPLAY_CONFIG');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B"() + '/' + "ElementName.SalesPrice";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_SALES_PRICE', 'DEL_SALES_PRICE');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B"() + '/' + "ElementName.SalesLineDiscount";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_SALES_LINE_DISC', 'DEL_SALES_LINE_DISC');
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B"() + '/' + "ElementName.ItemDiscountGroup";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ITEM_DISC_GROUP', 'DEL_ITEM_DISC_GROUP');

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        XmlDoc.WriteTo(OutStream);
    end;

    local procedure SetupTemplate(var TempBlob: Codeunit "Temp Blob"; TemplateCode: Code[20]; Enabled: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
        NcSetup: Record "NPR Nc Setup";
        NpXmlTemplate: Record "NPR NpXml Template";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        TemplateUrl: Text;
        NewTemplate: Boolean;
    begin
        if (TemplateCode = '') or (not MagentoSetup.Get) then
            exit;

        MagentoSetupMgt.UpdateVersionNo(MagentoSetup);
        if NpXmlTemplate.Get(TemplateCode) and (CopyStr(NpXmlTemplate."Template Version", 1, StrLen(MagentoSetupMgt.MagentoVersionId())) = MagentoSetupMgt.MagentoVersionId()) then
            NpXmlTemplate.Delete(true);

        if not Enabled then begin
            if NpXmlTemplate.Get(TemplateCode) then
                NpXmlTemplate.Delete(true);
            exit;
        end;

        if NcSetup.Get() then;

        NewTemplate := false;
        if not NpXmlTemplate.Get(TemplateCode) then begin
            NewTemplate := true;
            TemplateUrl := MagentoGenericSetupMgt.GetValueText(TempBlob, "ElementName.TemplateSetup"() + '/' + "ElementName.TemplateUrl") + LowerCase(MagentoSetup."Version No.") + '/';
            if not NpXmlTemplateMgt.ImportNpXmlTemplateUrl(TemplateCode, TemplateUrl) then
                exit;
            NpXmlTemplate.Get(TemplateCode);
        end;

        NpXmlTemplate."File Transfer" := false;
        NpXmlTemplate."FTP Transfer" := false;
        NpXmlTemplate."API Transfer" := true;
        NpXmlTemplate."API Url" := MagentoSetup."Api Url" + NpXmlTemplate."Xml Root Name";
        case MagentoSetup."Api Username Type" of
            MagentoSetup."Api Username Type"::Automatic:
                NpXmlTemplate."API Username Type" := NpXmlTemplate."API Username Type"::Automatic;
            MagentoSetup."Api Username Type"::Custom:
                NpXmlTemplate."API Username Type" := NpXmlTemplate."API Username Type"::Custom;
        end;
        NpXmlTemplate."API Username" := MagentoSetup."Api Username";
        NpXmlTemplate."API Password" := MagentoSetup.GetApiPassword();
        NpXmlTemplate."API Authorization" := MagentoSetup."Api Authorization";
        NpXmlTemplate."API Content-Type" := 'navision/xml';
        NpXmlTemplate."API Accept" := 'application/xml';
        NpXmlTemplate."API Response Path" := '';
        NpXmlTemplate."API Response Success Value" := '';
        NpXmlTemplate."API Type" := NpXmlTemplate."API Type"::"REST (Xml)";
        NpXmlTemplate."Batch Task" := false;
        NpXmlTemplate."Transaction Task" := MagentoSetup."Magento Enabled";
        NpXmlTemplate."Task Processor Code" := NcSetup."Task Worker Group";
        NpXmlTemplate."Last Modified by" := UserId;
        NpXmlTemplate."Last Modified at" := CreateDateTime(Today, Time);
        NpXmlTemplate.Modify();
        if NewTemplate and not NpXmlTemplate.VersionArchived() then begin
            if NpXmlTemplate."Version Description" = '' then begin
                NpXmlTemplate."Version Description" := 'Magento Standard';
                NpXmlTemplate.Modify();
            end;
            NpXmlTemplateMgt.Archive(NpXmlTemplate);
        end;
    end;

    procedure SetupTemplateAttribute(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.ItemAttribute" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateCreditVoucher(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.CreditVoucher" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateAttributeSet(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.ItemAttributeSet" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateCustomer(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B"() + '/' + "ElementName.Customer" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateDisplayConfig(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B"() + '/' + "ElementName.DisplayConfig" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateGiftVoucher(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.GiftVoucher" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateItem(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Item" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateItemStore(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.ItemStore" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateItemDiscountGroup(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B"() + '/' + "ElementName.ItemDiscountGroup" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateItemGroup(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.ItemGroup" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateItemInventory(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
        NodePath: Text;
        TemplateCode: Code[20];
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.ItemInventory" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);

        TemplateCode := MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"());
        MagentoSetup.Get();
        if TemplateCode <> MagentoSetup."Stock NpXml Template" then begin
            MagentoSetup.Validate("Stock NpXml Template", TemplateCode);
            MagentoSetup.Modify(true);
        end;
        MagentoItemMgt.UpsertStockTriggers();
    end;

    procedure SetupTemplateBrand(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Brand" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateOrderStatus(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.OrderStatus" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplatePicture(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Picture" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateSalesLineDiscount(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B"() + '/' + "ElementName.SalesLineDiscount" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateSalesPrice(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2B"() + '/' + "ElementName.SalesPrice" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"()), Enabled);
    end;

    procedure SetupTemplateTicket(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Ticket" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
    end;

    procedure SetupTemplateMember(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Membership" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"()), Enabled);
    end;

    procedure "--- Template Element Setup"()
    begin
    end;

    procedure SetItemElementEnabled(var TempBlob: Codeunit "Temp Blob"; NodePath: Text; CommentFilter: Text; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        TemplateCode: Code[20];
    begin
        TemplateCode := MagentoGenericSetupMgt.GetValueText(TempBlob, "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Item" + '/' + "ElementName.Update"());
        if TemplateCode = '' then
            exit;

        if not Enabled then begin
            NpXmlTemplateMgt.DeleteNpXmlElements(TemplateCode, NodePath, CommentFilter);
            exit;
        end;

        NpXmlTemplateMgt.SetNpXmlElementActive(TemplateCode, NodePath, CommentFilter, Enabled);
    end;

    procedure SetItemFilterValue(var TempBlob: Codeunit "Temp Blob"; ParentNodePath: Text; ParentCommentFilter: Text; NodePath: Text; CommentFilter: Text; FilterFieldNo: Integer; FilterValue: Text)
    var
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlElement2: Record "NPR NpXml Element";
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        TemplateCode: Code[20];
    begin
        TemplateCode := MagentoGenericSetupMgt.GetValueText(TempBlob, "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Item" + '/' + "ElementName.Update"());
        if TemplateCode = '' then
            exit;

        NpXmlTemplateMgt.GetNpXmlElement(TemplateCode, ParentNodePath, ParentCommentFilter, NpXmlElement);
        if NpXmlTemplateMgt.GetChildNpXmlElement(NpXmlElement, NodePath, CommentFilter, NpXmlElement2) then
            NpXmlTemplateMgt.SetNpXmlFilterValue(NpXmlElement2."Xml Template Code", NpXmlElement2."Line No.", FilterFieldNo, FilterValue);
    end;

    procedure SetSalesPriceEnabled(var TempBlob: Codeunit "Temp Blob"; NodePath: Text; CommentFilter: Text; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        TemplateCode: Code[20];
    begin
        TemplateCode := MagentoGenericSetupMgt.GetValueText(TempBlob, "ElementName.TemplateSetup"() + '/' + "ElementName.B2C"() + '/' + "ElementName.Item" + '/' + "ElementName.Update"());
        if TemplateCode = '' then
            exit;
        NpXmlTemplateMgt.SetNpXmlElementActive(TemplateCode, NodePath, CommentFilter, Enabled);
    end;

    local procedure "ElementName.B2B"(): Text
    begin
        exit('b2b');
    end;

    local procedure "ElementName.B2C"(): Text
    begin
        exit('b2c');
    end;

    local procedure "ElementName.CreditVoucher"(): Text
    begin
        exit('credit_voucher');
    end;

    local procedure "ElementName.Customer"(): Text
    begin
        exit('customer');
    end;

    local procedure "ElementName.Delete"(): Text
    begin
        exit('delete');
    end;

    local procedure "ElementName.DisplayConfig"(): Text
    begin
        exit('display_config');
    end;

    local procedure "ElementName.GiftVoucher"(): Text
    begin
        exit('gift_voucher');
    end;

    local procedure "ElementName.Item"(): Text
    begin
        exit('item');
    end;

    local procedure "ElementName.ItemAttribute"(): Text
    begin
        exit('item_attribute');
    end;

    local procedure "ElementName.ItemAttributeSet"(): Text
    begin
        exit('item_attribute_set');
    end;

    local procedure "ElementName.ItemDiscountGroup"(): Text
    begin
        exit('item_discount_group');
    end;

    local procedure "ElementName.ItemGroup"(): Text
    begin
        exit('item_group');
    end;

    local procedure "ElementName.ItemInventory"(): Text
    begin
        exit('item_inventory');
    end;

    local procedure "ElementName.ItemStore"(): Text
    begin
        exit('item_store');
    end;

    local procedure "ElementName.Brand"(): Text
    begin
        exit('manufacturer');
    end;

    local procedure "ElementName.OrderStatus"(): Text
    begin
        exit('order_status');
    end;

    local procedure "ElementName.Picture"(): Text
    begin
        exit('picture');
    end;

    local procedure "ElementName.SalesLineDiscount"(): Text
    begin
        exit('sales_line_discount');
    end;

    local procedure "ElementName.SalesPrice"(): Text
    begin
        exit('sales_price');
    end;

    procedure "ElementName.TemplateSetup"(): Text
    begin
        exit('template_setup');
    end;

    procedure "ElementName.TemplateUrl"(): Text
    begin
        exit('template_url');
    end;

    local procedure "ElementName.Update"(): Text
    begin
        exit('update');
    end;

    procedure "ElementName.Ticket"(): Text
    begin
        exit('ticket');
    end;

    procedure "ElementName.Membership"(): Text
    begin
        exit('membership');
    end;

    procedure "ElementName.CollectStore"(): Text
    begin
        exit('collect_store');
    end;
}