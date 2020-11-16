codeunit 6151461 "NPR M2 NpXml Setup Mgt."
{
    // MAG2.08/MHA /20171016  CASE 292926 Object created - M2 Integration
    // MAG2.09/MHA /20171108  CASE 295656 Api Method changed to REST (Json)
    // MAG2.22/MHA /20190625  CASE 359285 Adjusted SetupTemplate() to delete existing Template if Version Id belongs to Magento
    // MAG2.22/MHA /20190708  CASE 352201 Added function SetupTemplateCollectStore
    // MAG2.25/MHA /20200416  CASE 400486 Cleared Api Credentials in SetupTemplate() because Bearer Auth is used instead
    // MAG2.26/MHA /20200501  CASE 402488 Stock NpXml Template is set on Magento Setup SetupTemplateItemInventory()
    // MAG2.26/MHA /20200601  CASE 404580 Magento Categories and -Brands can now be managed externally


    trigger OnRun()
    begin
    end;

    var
        NpXmlTemplateMgt: Codeunit "NPR NpXml Template Mgt.";

    procedure "--- Generic Setup"()
    begin
    end;

    local procedure AddNpXmlTemplate(var XmlDoc: DotNet "NPRNetXmlDocument"; NodePath: Text; UpdateCode: Code[20]; DeleteCode: Code[20])
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
    begin
        MagentoGenericSetupMgt.AddFieldText(XmlDoc, NodePath, "ElementName.Update", UpdateCode);
        MagentoGenericSetupMgt.AddFieldText(XmlDoc, NodePath, "ElementName.Delete", DeleteCode);
    end;

    local procedure RemoveNpXmlTemplate(TemplateCode: Code[20])
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        //-MAG2.26 [404580]
        if NpXmlTemplate.Get(TemplateCode) then
            NpXmlTemplate.Delete(true);
        //+MAG2.26 [404580]
    end;

    procedure InitNpXmlTemplateSetup(var TempBlob: Codeunit "Temp Blob")
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        XmlDoc: DotNet "NPRNetXmlDocument";
        OutStream: OutStream;
        NodePath: Text;
    begin
        MagentoGenericSetupMgt.LoadGenericSetup(TempBlob, XmlDoc);

        NodePath := '';
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.TemplateSetup");

        NodePath := "ElementName.TemplateSetup";
        MagentoGenericSetupMgt.AddFieldText(XmlDoc, NodePath, "ElementName.TemplateUrl", 'http://xsd.navipartner.dk/naviconnect/npxml_templates/navishop2dev90/');
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.B2C");

        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C";
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

        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/ ' + "ElementName.Item";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ITEM', 'DEL_ITEM');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemGroup";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ITEM_GROUP', 'DEL_ITEM_GROUP');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemInventory";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ITEM__STOCK', '');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemStore";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ITEM__STORE', '');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Brand";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_MANUFACTURER', 'DEL_MANUFACTURER');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemAttribute";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_PROD_ATTR', 'DEL_PROD_ATTR');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemAttributeSet";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_PROD_ATTR_SET', 'DEL_PROD_ATTR_SET');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Picture";
        AddNpXmlTemplate(XmlDoc, NodePath, '', 'DEL_MAG_PICTURE');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.GiftVoucher";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_GIFT_VOUCHER', '');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.CreditVoucher";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_CREDIT_VOUCHER', '');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.OrderStatus";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_ORDER_STATUS', '');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Ticket";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_TICKET_ADMISSION', '');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Membership";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_MEMBERSHIP', '');
        NodePath := "ElementName.TemplateSetup";
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.B2B");

        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2B";
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.Customer");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.DisplayConfig");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.SalesPrice");
        MagentoGenericSetupMgt.AddContainer(XmlDoc, NodePath, "ElementName.SalesLineDiscount");
        //-MAG2.09 [295656]
        //MagentoGenericSetupMgt.AddContainer(XmlDoc,NodePath,"ElementName.ItemDiscountGroup");
        //+MAG2.09 [295656]

        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2B" + '/' + "ElementName.Customer";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_CONT_RELATION', 'DEL_CONTACT');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2B" + '/' + "ElementName.DisplayConfig";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_DISPLAY_CONFIG', 'DEL_DISPLAY_CONFIG');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2B" + '/' + "ElementName.SalesPrice";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_SALES_PRICE', 'DEL_SALES_PRICE');
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2B" + '/' + "ElementName.SalesLineDiscount";
        AddNpXmlTemplate(XmlDoc, NodePath, 'UPD_SALES_LINE_DISC', 'DEL_SALES_LINE_DISC');
        //-MAG2.09 [295656]
        //NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2B" + '/' + "ElementName.ItemDiscountGroup";
        //AddNpXmlTemplate(XmlDoc,NodePath,'UPD_ITEM_DISC_GROUP','DEL_ITEM_DISC_GROUP');
        //+MAG2.09 [295656]

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        XmlDoc.Save(OutStream);
    end;

    procedure "--- Magento Template Setup"()
    begin
    end;

    local procedure SetupTemplate(var TempBlob: Codeunit "Temp Blob"; TemplateCode: Code[20]; Enabled: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
        NcSetup: Record "NPR Nc Setup";
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlTemplate: Record "NPR NpXml Template";
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
        TemplateUrl: Text;
        NewTemplate: Boolean;
    begin
        if (TemplateCode = '') or (not MagentoSetup.Get) then
            exit;

        //-MAG2.22 [359285]
        MagentoSetupMgt.UpdateVersionNo(MagentoSetup);
        if NpXmlTemplate.Get(TemplateCode) and (CopyStr(NpXmlTemplate."Template Version", 1, StrLen(MagentoSetupMgt.MagentoVersionId())) = MagentoSetupMgt.MagentoVersionId()) then
            NpXmlTemplate.Delete(true);
        //+MAG2.22 [359285]

        if not Enabled then begin
            if NpXmlTemplate.Get(TemplateCode) then
                NpXmlTemplate.Delete(true);
            exit;
        end;

        if NcSetup.Get then;

        NewTemplate := false;
        if not NpXmlTemplate.Get(TemplateCode) then begin
            NewTemplate := true;
            TemplateUrl := MagentoGenericSetupMgt.GetValueText(TempBlob, "ElementName.TemplateSetup" + '/' + "ElementName.TemplateUrl") + LowerCase(MagentoSetup."Version No.") + '/';
            if not NpXmlTemplateMgt.ImportNpXmlTemplateUrl(TemplateCode, TemplateUrl) then
                exit;
            NpXmlTemplate.Get(TemplateCode);
        end;

        NpXmlTemplate."File Transfer" := false;
        NpXmlTemplate."FTP Transfer" := false;
        NpXmlTemplate."API Transfer" := true;
        NpXmlTemplate."API Url" := MagentoSetup."Api Url" + NpXmlTemplate."Xml Root Name";
        NpXmlTemplate."API Authorization" := MagentoSetup."Api Authorization";
        //-MAG2.25 [400486]
        NpXmlTemplate."API Username Type" := NpXmlTemplate."API Username Type"::Custom;
        NpXmlTemplate."API Username" := '';
        NpXmlTemplate."API Password" := '';
        //+MAG2.25 [400486]
        //-MAG2.09 [295656]
        //NpXmlTemplate."API Content-Type" := 'naviconnect/xml';
        NpXmlTemplate."API Content-Type" := 'naviconnect/json';
        //+MAG2.09 [295656]
        NpXmlTemplate."API Accept" := 'naviconnect/xml';
        NpXmlTemplate."API Response Path" := '';
        NpXmlTemplate."API Response Success Value" := '';
        //-MAG2.09 [295656]
        //NpXmlTemplate."API Type" := NpXmlTemplate."API Type"::"REST (Xml)";
        NpXmlTemplate."API Type" := NpXmlTemplate."API Type"::"REST (Json)";
        //+MAG2.09 [295656]
        NpXmlTemplate."Batch Task" := false;
        NpXmlTemplate."Transaction Task" := MagentoSetup."Magento Enabled";
        NpXmlTemplate."Task Processor Code" := NcSetup."Task Worker Group";
        NpXmlTemplate."Last Modified by" := UserId;
        NpXmlTemplate."Last Modified at" := CreateDateTime(Today, Time);
        NpXmlTemplate.Modify;
        if NewTemplate and not NpXmlTemplate.VersionArchived() then begin
            if NpXmlTemplate."Version Description" = '' then begin
                NpXmlTemplate."Version Description" := 'Magento Standard';
                NpXmlTemplate.Modify;
            end;
            NpXmlTemplateMgt.Archive(NpXmlTemplate);
        end;

        //-MAG2.09 [295656]
        NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate.Code);
        NpXmlElement.SetRange(CDATA, true);
        NpXmlElement.ModifyAll(CDATA, false);
        //+MAG2.09 [295656]
    end;

    procedure SetupTemplateAttribute(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemAttribute" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateAttributeSet(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemAttributeSet" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateCreditVoucher(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.CreditVoucher" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateCustomer(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2B" + '/' + "ElementName.Customer" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateDisplayConfig(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2B" + '/' + "ElementName.DisplayConfig" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateGiftVoucher(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.GiftVoucher" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateItem(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Item" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateItemStore(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        //-MAG1.21
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemStore" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
        //+MAG1.21
    end;

    procedure SetupTemplateItemGroup(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemGroup" + '/';
        //-MAG2.26 [404580]
        if MagentoSetupMgt.HasSetupBrands() then begin
            RemoveNpXmlTemplate(MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"));
            RemoveNpXmlTemplate(MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"));
            exit;
        end;
        //+MAG2.26 [404580]
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateItemInventory(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        NpXmlTemplate: Record "NPR NpXml Template";
        MagentoSetup: Record "NPR Magento Setup";
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
        String: DotNet NPRNetString;
        NodePath: Text;
        TemplateCode: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemInventory" + '/';
        TemplateCode := MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update");
        SetupTemplate(TempBlob, TemplateCode, Enabled);
        NpXmlTemplate.Get(TemplateCode);
        String := NpXmlTemplate."API Url";
        NpXmlTemplate."API Url" := String.Replace('stock_updates', 'stock');
        NpXmlTemplate.Modify;

        //-MAG2.26 [402488]
        MagentoSetup.Get;
        if TemplateCode <> MagentoSetup."Stock NpXml Template" then begin
            MagentoSetup.Validate("Stock NpXml Template", TemplateCode);
            MagentoSetup.Modify(true);
        end;
        MagentoItemMgt.UpsertStockTriggers();
        //+MAG2.26 [402488]
    end;

    procedure SetupTemplateBrand(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Brand" + '/';
        //-MAG2.26 [404580]
        if MagentoSetupMgt.HasSetupBrands() then begin
            RemoveNpXmlTemplate(MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"));
            RemoveNpXmlTemplate(MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"));
            exit;
        end;
        //+MAG2.26 [404580]
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateOrderStatus(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.OrderStatus" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplatePicture(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Picture" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateSalesLineDiscount(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2B" + '/' + "ElementName.SalesLineDiscount" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateSalesPrice(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2B" + '/' + "ElementName.SalesPrice" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
    end;

    procedure SetupTemplateTicket(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        //-MAG2.02
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Ticket" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        //+MAG2.02
    end;

    procedure SetupTemplateMember(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        //-MAG2.02
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Membership" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        //+MAG2.02
    end;

    procedure SetupTemplateCollectStore(var TempBlob: Codeunit "Temp Blob"; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        NodePath: Text;
    begin
        //-MAG2.22 [352201]
        NodePath := "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.CollectStore" + '/';
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Update"), Enabled);
        SetupTemplate(TempBlob, MagentoGenericSetupMgt.GetValueText(TempBlob, NodePath + "ElementName.Delete"), Enabled);
        //+MAG2.22 [352201]
    end;

    procedure "--- Template Element Setup"()
    begin
    end;

    procedure AddItemDiscGroupCodeElement(var TempBlob: Codeunit "Temp Blob")
    var
        Item: Record Item;
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlElement2: Record "NPR NpXml Element";
        NpXmlTemplate: Record "NPR NpXml Template";
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        TemplateCode: Code[20];
        LineNo: Integer;
    begin
        //-MAG2.09 [295656]
        TemplateCode := MagentoGenericSetupMgt.GetValueText(TempBlob, "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Item" + '/' + "ElementName.Update");
        if TemplateCode = '' then
            exit;

        if not NpXmlTemplate.Get(TemplateCode) then
            exit;

        NpXmlElement.SetRange("Xml Template Code", NpXmlTemplate.Code);
        NpXmlElement.SetRange("Table No.", DATABASE::Item);
        NpXmlElement.SetRange("Element Name", 'item_disc_group');
        if NpXmlElement.FindFirst then
            exit;
        NpXmlElement.SetRange("Element Name", 'price');
        if not NpXmlElement.FindFirst then
            exit;

        LineNo := NpXmlElement."Line No.";
        NpXmlElement2.Copy(NpXmlElement);
        NpXmlElement2.SetRange("Table No.");
        NpXmlElement2.SetRange("Element Name");
        if NpXmlElement2.Next <> 0 then
            LineNo += Round((NpXmlElement2."Line No." - NpXmlElement."Line No.") / 2, 1)
        else
            LineNo += 10000;

        if NpXmlElement2.Get(NpXmlElement."Xml Template Code", LineNo) then begin
            NpXmlTemplateMgt.NormalizeNpXmlElementLineNo(NpXmlElement."Xml Template Code", NpXmlElement);
            LineNo := NpXmlElement."Line No." + 5000;
        end;

        NpXmlElement2.Init;
        NpXmlElement2 := NpXmlElement;
        NpXmlElement2."Line No." := LineNo;
        NpXmlElement2."Element Name" := 'item_disc_group';
        NpXmlElement2."Field No." := Item.FieldNo("Item Disc. Group");
        NpXmlElement2.Insert;
        //+MAG2.09 [295656]
    end;

    local procedure DeleteNpXmlElement(NpXmlElement: Record "NPR NpXml Element")
    var
        NpXmlElement2: Record "NPR NpXml Element";
    begin
        //-MAG2.09 [295656]
        NpXmlElement2.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlElement2.SetRange("Parent Line No.", NpXmlElement."Line No.");
        if NpXmlElement2.FindSet then
            repeat
                DeleteNpXmlElement(NpXmlElement2);
            until NpXmlElement2.Next = 0;

        NpXmlElement.Delete(true);
        //+MAG2.09 [295656]
    end;

    procedure SetItemElementEnabled(var TempBlob: Codeunit "Temp Blob"; NodePath: Text; CommentFilter: Text; Enabled: Boolean)
    var
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        TemplateCode: Code[20];
    begin
        TemplateCode := MagentoGenericSetupMgt.GetValueText(TempBlob, "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Item" + '/' + "ElementName.Update");
        if TemplateCode = '' then
            exit;

        if not Enabled then begin
            NpXmlTemplateMgt.DeleteNpXmlElements(TemplateCode, NodePath, CommentFilter);
            exit;
        end;

        NpXmlTemplateMgt.SetNpXmlElementActive(TemplateCode, NodePath, CommentFilter, Enabled);
    end;

    procedure SetItemStoreElementEnabled(var TempBlob: Codeunit "Temp Blob"; ElementName: Text; Enabled: Boolean)
    var
        NpXmlElement: Record "NPR NpXml Element";
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        TemplateCode: Code[20];
    begin
        //-MAG2.09 [295656]
        TemplateCode := MagentoGenericSetupMgt.GetValueText(TempBlob, "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.ItemStore" + '/' + "ElementName.Update");
        if TemplateCode = '' then
            exit;

        if not Enabled then begin
            NpXmlElement.SetRange("Xml Template Code", TemplateCode);
            NpXmlElement.SetRange("Element Name", ElementName);
            while NpXmlElement.FindFirst do
                DeleteNpXmlElement(NpXmlElement);

            exit;
        end;

        NpXmlElement.SetRange("Xml Template Code", TemplateCode);
        NpXmlElement.SetRange("Element Name", ElementName);
        if not NpXmlElement.FindSet then
            exit;

        repeat
            if not NpXmlElement.Active then begin
                NpXmlElement.Active := true;
                NpXmlElement.Modify;
            end;
            NpXmlTemplateMgt.SetChildNpXmlElementsActive(NpXmlElement, Enabled);
        until NpXmlElement.Next = 0;
        //+MAG2.09 [295656]
    end;

    procedure SetItemFilterValue(var TempBlob: Codeunit "Temp Blob"; ParentNodePath: Text; ParentCommentFilter: Text; NodePath: Text; CommentFilter: Text; FilterFieldNo: Integer; FilterValue: Text)
    var
        NpXmlElement: Record "NPR NpXml Element";
        NpXmlElement2: Record "NPR NpXml Element";
        MagentoGenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
        TemplateCode: Code[20];
    begin
        TemplateCode := MagentoGenericSetupMgt.GetValueText(TempBlob, "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Item" + '/' + "ElementName.Update");
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
        TemplateCode := MagentoGenericSetupMgt.GetValueText(TempBlob, "ElementName.TemplateSetup" + '/' + "ElementName.B2C" + '/' + "ElementName.Item" + '/' + "ElementName.Update");
        if TemplateCode = '' then
            exit;
        NpXmlTemplateMgt.SetNpXmlElementActive(TemplateCode, NodePath, CommentFilter, Enabled);
    end;

    procedure "--- Enum"()
    begin
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
        //-MAG2.02
        exit('ticket');
        //+MAG2.02
    end;

    procedure "ElementName.Membership"(): Text
    begin
        //-MAG2.02
        exit('membership');
        //+MAG2.02
    end;

    procedure "ElementName.CollectStore"(): Text
    begin
        //-MAG2.22 [352201]
        exit('collect_store');
        //+MAG2.22 [352201]
    end;
}

