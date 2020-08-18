codeunit 6151413 "Magento Sales Order Mgt."
{
    // MAG1.16/TS  /20150423  CASE 212103 Object created
    // MAG1.16/TS  /20150515  CASE 212432 Added Code to allow import when unit price = 0 during import of bundled items
    // MAG1.17/MHA /20150619  CASE 216853 VariantCode should only be validated if not blank as it would otherwise delete SalesLine.Description
    // MAG1.17/MHA /20150622  CASE 215533 Setup fields moved from NaviConnect to Magento
    // MAG1.18/MHA /20150709  CASE 218282 Added ContactCustomer functionality and applied localization neutrality
    // MAG1.19/TS  /20150727  CASE 212568 Added GiftWrap
    // MAG1.20/TS  /20150811  CASE 218524 Added unit of measure to sales line
    // MAG1.20/TR  /20150813  CASE 218819 Added function ActivateAndMailGiftVouchers created.
    // MAG1.20/TR  /20150828  CASE 219645 References to Paymentline."Payment Gateway Code" updated
    // MAG1.21/TS  /20151016  CASE 225217 Set Required to FAlSE for external_document_no
    // MAG1.21/MHA /20151022  CASE 225667 Changed FIND to GET as field values within the filter have been changed during import
    // MAG1.21/TTH /20151120  CASE 227358 Modified codeunit to import Sales Documents only to be used with NaviConnect Import Entry Type
    // MAG1.22/TS  /20151007  CASE 228446 Added Code to Import Global Dimension 1 Code and Global Dimension 2 Code
    // MAG1.22/TS  /20151022  CASE 232426 Added Function to Look for ItemNo in ItemCrossReferenceTable
    // MAG1.22/TS  /20160105  CASE 230767 Look for Currency code on Sales Order
    // MAG1.22/TR  /20160127  CASE 232815 Added validation of the field SalesHeader."Payment Method Code" in InsertSalesHeader
    // MAG1.22/TS  /20160129  CASE 233104 Added Payment Terms if Customer already Exist instead of MagentoSetup."Payment Terms Code"
    // MAG1.22/MHA /20160209  CASE 233765 Removed parsing of unused variable cert_id
    // MAG1.22/TS  /20160407  CASE 233892 Change comment_Line code to comment_Line type and added sales header as VAR
    // MAG1.22/MHA /20160422  CASE 239810 Xml Element Name changed from payment to payment_method during payment fee insert
    // MAG1.22/MHA /20162604  CASE 232815 Changed validation of SalesHeader."Payment Method Code" to take account for Blank Payment Method Code
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/TS  /20160912  CASE 250884 Removed ExternalNo = Bundle
    // MAG2.01/TS  /20161014  CASE 254886 Added Location Code
    // MAG2.01/TS  /20160705  CASE 246247 Hotfix for Customer Import
    // MAG2.02/MHA /20170207  CASE 265269 Buffering VATAmountLineTemp moved from InsertSalesLineShipmentFee() to the end of InsertSalesLines()
    // MAG2.02/MHA /20170221  CASE 266871 Added Customer Config. Template
    // MAG2.03/MHA /20170321  CASE 266871 Implemented Differentiated Customer Config. Template
    // MAG2.03/MHA /20170403  CASE 271324 Line Amount may be validated as long as Unit Price <> 0
    // MAG2.04/TS  /20170421  CASE 269100 Added Extra information about Gift Voucher
    // MAG2.04/MHA /20170519  CASE 276533 Payment Lines with Amount = 0 should not be imported in InsertPaymentLinePaymentMethod()
    // MAG2.05/MHA /20170712  CASE 283588 Added "Allow Adjust Payment Amount" in InsertPaymentLinePaymentMethod()
    // MAG2.06/MHA /20170717  CASE 284036 Customer is updated InsertCustomer()
    // MAG2.08/TS  /20171310  CASE 293324 Removed Length on Variable TransactionId in InsertPaymentLinePaymentMethod()
    // MAG2.09/TS  /20170412  CASE 298459 Corrected Import of Multiple Gift Vouchers
    // MAG2.09/MHA /20171218  CASE 299976 Added import of vat_registration_no
    // MAG2.09/MHA /20180111  CASE 301960 CreditVoucher."No." should be #Blank when issuing new in InsertPaymentLineVoucher()
    // MAG2.11/TS  /20180323  CASE 288763 Increased ExternalReferenceNo to 50
    // MAG2.13/MHA /20180521  CASE 314625 Fixed Contact sync
    // MAG2.13/MHA /20180522  CASE 315841 ShipmentFee 0 should be ignored in InsertSalesLineShipmentFee()
    // MAG2.15/TS  /20180828  CASE 324335 Vat % was not being applied.
    // MAG2.17/MHA /20180918  CASE 302179 Added Retail Voucher as Payment Method
    // MAG2.17/TS  /20181011  CASE 324190 Added Type Custom Options,Cleared Unused Variables(OMA) and removed old commented codes
    // MAG2.18/MHA /20190314  CASE 348660 Increased VATBusPostingGroup in InsertCustomer() from 10 to 20 as standard field is increased from NAV2018
    // MAG2.19/MHA /20190306  CASE 347974 Added option to Release Order on Import
    // MAG2.19/MMV /20190314  CASE 347687 Added handling of shopper reference
    // MAG2.20/MHA /20190411  CASE 349994 Added import of <use_customer_salesperson> in InsertSalesHeader()
    // MAG2.20/MHA /20190417  CASE 352201 Added Collect in Store functionality
    // MAG2.21/MHA /20190522  CASE 355271 Reworked Customer Mapping in GetCustomer()
    // MAG2.22/BHR /20190604  CASE 350006 Added import of requested_delivery_date
    // MAG2.22/MHA /20190610  CASE 357763 Added Shipment Fee Type to Shipment Mapping
    // MAG2.22/MHA /20190611  CASE 357662 Added "Customer Update Mode" in InsertCustomer()
    // MAG2.22/MHA /20190621  CASE 359146 Added option to use Blank Code for LCY
    // MAG2.22/MHA /20190625  CASE 359754 Added "Customer No." to "Customer Mapping" in GetCustomer()
    // MAG2.22/MHA /20190628  CASE 359332 "Sell-to Contact" is mandatory for Ean Orders
    // MAG2.22/ZESO/20190701  CASE 358761 Populate "Description 2" with Description from Item Variants when Variant Code is used.
    // MAG2.22/MHA /20190711  CASE 360098 Added Customer Template Mapping in InsertCustomer() and Vat % should be set after validation of "VAT Prod. Posting Group"
    // MAG2.22/MHA /20190711  CASE 361705 Corrected case for "E-mail OR Phone No." in GetCustomer()
    // MAG2.22/BHR /20190711  CASE 360098 Correction to filter on customer template Mapping
    // MAG2.22/MHA /20190724  CASE 343352 Added function UpdateExtCouponReservations()
    // MAG2.23/BHR /20190807  CASE 360098 Re-Correction to filter on customer template Mapping
    // MAG2.23/MHA /20190826  CASE 363864 Added Retail Voucher functions
    // MAG2.23/ALPO/20191004  CASE 367219 Auto set capture date for payments captured externally
    // MAG2.23/MHA /20191017  CASE 371791 Added Ticket- and Membership posting
    // MAG2.23/MHA /20191017  CASE 373262 Added Post on Import Setup
    // MAG2.24/MHA /20191024  CASE 371807 Added "Phone No. to Customer No." GetCustomer()
    // MAG2.24/MHA /20191118  CASE 372315 Adjusted InsertSalesLineRetailVoucher() to support Top-up
    // MAG2.24/MHA /20191122  CASE 378597 Only Customer No., E-mail and Phone No. should be touched in UpdateRetailVoucherCustomerInfo()
    // MAG2.25/ZESO/20200131  CASE 386010 Populate Issue Date and Salesperson Code on Credit Voucher
    // MAG2.25/MHA /20200204  CASE 387936 Added function SendOrderConfirmation()
    // MAG2.25/MHA /20200306  CASE 384262 Added import of <vat_percent> in InsertSalesLineRetailVoucher()
    // MAG2.25/MHA /20200323  CASE 372135 Retail Voucher Description is now used on Sales Line
    // MAG2.26/MHA /20200428  CASE 402247 Added Option "Fixed" to field "Customer Update Mode"
    // MAG2.26/MHA /20200505  CASE 402828 Added Website Sales Order No. Series in InsertSalesHeader()
    // MAG2.26/MHA /20200515  CASE 401788 Added Publisher Events for extensibility purposes
    // MAG2.26/MHA /20200526  CASE 406591 Reworked InsertCollectDocument() to use new element <sales_order/shipment/collect_in_store>
    // MAG2.26/MHA /20200427  CASE 402013 Added issue of Return Retail Voucher in InsertRetailVoucherPayment()
    // MAG2.26/MHA /20200427  CASE 402015 Voucher table updated
    // NPR5.55/MHA /20200626  CASE 401059 Custom Option Type is now used to determine if Custom Option Lines are required
    // NPR5.55/MHA /20200701  CASE 411513 Default Collect in Store Customer Notification is E-mail
    // NPR5.55/MHA /20200729  CASE 416534 Skip Customer Posting fields when Config Template is defined in InsertCustomer()
    // NPR5.55/MHA /20200730  CASE 412507 Support for prices excluding vat

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet npNetXmlDocument;
    begin
        //-MAG2.26 [401788]
        CurrImportEntry := Rec;
        Clear(CurrImportType);
        if CurrImportType.Get(CurrImportEntry."Import Type") then;
        //+MAG2.26 [401788]

        if LoadXmlDoc(XmlDoc) then
          ImportSalesOrders(XmlDoc);
    end;

    var
        MagentoSetup: Record "Magento Setup";
        VATAmountLineTemp: Record "VAT Amount Line" temporary;
        MagentoMgt: Codeunit "Magento Mgt.";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        SalesPost: Codeunit "Sales-Post";
        Initialized: Boolean;
        Error001: Label 'Xml Element sell_to_customer is missing';
        Error002: Label 'Item %1 does not exist in %2';
        Error003: Label 'Error during E-mail Confirmation: %1';
        Text000: Label 'Invalid Voucher Reference No. %1';
        Text001: Label 'Voucher %1 is already in use';
        Text002: Label 'Customer Create is not allowed when Customer Update Mode is %1';
        CurrImportEntry: Record "Nc Import Entry";
        CurrImportType: Record "Nc Import Type";
        Text003: Label 'Voucher Payment Amount %1 exceeds Voucher Amount %2';

    local procedure ImportSalesOrders(XmlDoc: DotNet npNetXmlDocument)
    var
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
    begin
        Initialize;
        if IsNull(XmlDoc) then
          exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;
        if not NpXmlDomMgt.FindNodes(XmlElement,'sales_order',XmlNodeList) then
          exit;
        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          ImportSalesOrder(XmlElement);
        end;
    end;

    local procedure ImportSalesOrder(XmlElement: DotNet npNetXmlElement) Imported: Boolean
    var
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        MailErrorMessage: Text;
    begin
        if IsNull(XmlElement) then
          exit(false);
        if OrderExists(XmlElement) then
          exit(false);

        InsertSalesHeader(XmlElement,SalesHeader);
        InsertSalesLines(XmlElement,SalesHeader);
        InsertPaymentLines(XmlElement,SalesHeader);
        InsertComments(XmlElement,SalesHeader);
        //-MAG2.22 [343352]
        UpdateExtCouponReservations(SalesHeader);
        //-MAG2.22 [343352]
        //-MAG2.26 [401788]
        OnBeforeRelease(CurrImportType,CurrImportEntry,XmlElement,SalesHeader);
        //+MAG2.26 [401788]
        //-MAG2.19 [347974]
        if MagentoSetup."Release Order on Import" then
          ReleaseSalesDoc.PerformManualRelease(SalesHeader);
        //+MAG2.19 [347974]
        //-MAG2.20 [352201]
        InsertCollectDocument(XmlElement,SalesHeader);
        //+MAG2.20 [352201]
        //-MAG2.23 [363864]
        UpdateRetailVoucherCustomerInfo(SalesHeader);
        //+MAG2.23 [363864]
        //-MAG2.26 [401788]
        OnBeforeCommit(CurrImportType,CurrImportEntry,XmlElement,SalesHeader);
        //+MAG2.26 [401788]
        //-MAG2.25 [387936]
        Commit;
        if MagentoSetup."Send Order Confirmation" then
          MailErrorMessage := SendOrderConfirmation(XmlElement,SalesHeader);
        //+MAG2.25 [387936]
        Commit;
        ActivateAndMailGiftVouchers(SalesHeader);

        //-MAG2.23 [371791]
        Commit;
        PostOnImport(SalesHeader);
        //+MAG2.23 [371791]

        //-MAG2.25 [387936]
        Commit;
        if MailErrorMessage <> '' then
          Error(Error003,CopyStr(MailErrorMessage,1,900));
        //+MAG2.25 [387936]
        exit(true);
    end;

    local procedure "--- Database"()
    begin
    end;

    local procedure InsertCollectDocument(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        NpCsWorkflow: Record "NpCs Workflow";
        NpCsDocument: Record "NpCs Document";
        NpCsStoreFrom: Record "NpCs Store";
        NpCsStoreTo: Record "NpCs Store";
        NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        XmlElementCollect: DotNet npNetXmlElement;
        StoreCode: Code[20];
    begin
        //-MAG2.26 [406591]
        if not NpXmlDomMgt.FindElement(XmlElement,'shipment/collect_in_store',false,XmlElementCollect) then
          exit;

        MagentoSetup.TestField("Collect in Store Enabled");
        MagentoSetup.TestField("NpCs From Store Code");
        MagentoSetup.TestField("NpCs Workflow Code");

        StoreCode := NpXmlDomMgt.GetAttributeCode(XmlElementCollect,'','store_code',MaxStrLen(NpCsStoreTo.Code),true);
        if StoreCode = '' then
          exit;

        NpCsStoreTo.Get(StoreCode);

        NpCsWorkflow.Get(MagentoSetup."NpCs Workflow Code");
        NpCsCollectMgt.InitSendToStoreDocument(SalesHeader,NpCsStoreTo,NpCsWorkflow,NpCsDocument);

        NpCsStoreFrom.Get(MagentoSetup."NpCs From Store Code");
        NpCsDocument."From Store Code" := NpCsStoreFrom.Code;
        NpCsDocument."To Document Type" := NpCsDocument."To Document Type"::Order;

        NpCsDocument."Allow Partial Delivery" := NpXmlDomMgt.GetElementBoolean(XmlElementCollect,'allow_partial_delivery',false);

        NpCsDocument."Notify Customer via E-mail" := NpXmlDomMgt.GetElementBoolean(XmlElementCollect,'notify_customer_via_email',false);
        NpCsDocument."Customer E-mail" :=
          NpXmlDomMgt.GetElementText(XmlElementCollect,'customer_email',MaxStrLen(NpCsDocument."Customer E-mail"),false);
        if NpCsDocument."Customer E-mail" = '' then
          NpCsDocument."Customer E-mail" := NpXmlDomMgt.GetXmlText(XmlElement,'sell_to_customer/email',MaxStrLen(NpCsDocument."Customer E-mail"),true);

        NpCsDocument."Notify Customer via Sms" := NpXmlDomMgt.GetElementBoolean(XmlElementCollect,'notify_customer_via_sms',false);
        NpCsDocument."Customer Phone No." :=
          NpXmlDomMgt.GetElementText(XmlElementCollect,'customer_phone',MaxStrLen(NpCsDocument."Customer Phone No."),false);
        if NpCsDocument."Customer Phone No." = '' then
          NpCsDocument."Customer Phone No." := NpXmlDomMgt.GetXmlText(XmlElement,'sell_to_customer/phone',MaxStrLen(NpCsDocument."Customer Phone No."),false);

        //-NPR5.55 [411513]
        if not NpCsDocument."Notify Customer via Sms" then
          NpCsDocument."Notify Customer via E-mail" := true;
        //+NPR5.55 [411513]

        NpCsDocument.Modify(true);

        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
        //+MAG2.26 [406591]
    end;

    local procedure InsertCommentLine(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        RecordLink: Record "Record Link";
        CommentLine: Text;
        CommentType: Text;
        OutStream: OutStream;
        LinkID: Integer;
        BinaryWriter: DotNet npNetBinaryWriter;
        Encoding: DotNet npNetEncoding;
    begin
        CommentType := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'type',false);
        CommentLine := NpXmlDomMgt.GetXmlText(XmlElement,'comment',0,true);
        if CommentLine <> '' then begin
          if CommentType <> '' then
            LinkID := SalesHeader.AddLink('',SalesHeader."No." + '-' + CommentType)
          else
            LinkID := SalesHeader.AddLink('',SalesHeader."No.");
          RecordLink.Get(LinkID);
          RecordLink.Type := RecordLink.Type::Note;
          RecordLink.Note.CreateOutStream(OutStream);
          RecordLink."User ID" := '';
          Encoding := Encoding.UTF8;
          BinaryWriter := BinaryWriter.BinaryWriter(OutStream,Encoding);
          if CommentType <> '' then
            BinaryWriter.Write(CommentType + ': ' + CommentLine)
          else
            BinaryWriter.Write(CommentLine);
          RecordLink.Modify(true);
          //-MAG2.26 [401788]
          OnAfterInsertCommentLine(CurrImportType,CurrImportEntry,XmlElement,SalesHeader,RecordLink);
          //+MAG2.26 [401788]
        end;
    end;

    local procedure InsertComments(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
    begin
        NpXmlDomMgt.FindNodes(XmlElement,'comment_line',XmlNodeList);
        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement2 := XmlNodeList.ItemOf(i);
          InsertCommentLine(XmlElement2,SalesHeader);
        end;
    end;

    local procedure InsertCustomer(XmlElement: DotNet npNetXmlElement;IsContactCustomer: Boolean;var Customer: Record Customer): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        CustTemplate: Record "Customer Template";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        UpdateContFromCust: Codeunit "CustCont-Update";
        RecRef: RecordRef;
        ExternalCustomerNo: Text;
        TaxClass: Text;
        ConfigTemplateCode: Code[10];
        VATBusPostingGroup: Code[20];
        NewCust: Boolean;
        PrevCust: Text;
        EanNo: Text;
        CustTemplateCode: Code[10];
        CustNo: Code[20];
    begin
        Initialize;
        ExternalCustomerNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'customer_no',false);
        if IsContactCustomer then begin
          if GetContactCustomer(ExternalCustomerNo,Customer)then
            exit;
        end;

        TaxClass := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'tax_class',true);
        NewCust := not GetCustomer(ExternalCustomerNo,XmlElement,Customer);

        //-MAG2.26 [402247]
        if NewCust and (MagentoSetup."Customer Update Mode" = MagentoSetup."Customer Update Mode"::Fixed) then begin
          Customer."Post Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'post_code',MaxStrLen(Customer."Post Code"),true));
          Customer."Country/Region Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'country_code',MaxStrLen(Customer."Country/Region Code"),false));
          CustNo := MagentoMgt.GetFixedCustomerNo(Customer);
          Customer.Get(CustNo);
          NewCust := false;
        end;
        //+MAG2.26 [402247]

        if NewCust then begin
          //-MAG2.22 [357662]
          if not (MagentoSetup."Customer Update Mode" in [MagentoSetup."Customer Update Mode"::"Create and Update",MagentoSetup."Customer Update Mode"::Create]) then
            Error(Text002,MagentoSetup."Customer Update Mode");
          //+MAG2.22 [357662]
          VATBusPostingGroup := MagentoMgt.GetVATBusPostingGroup(TaxClass);

          //-MAG2.24 [371807]
          InitCustomer(XmlElement,Customer);
          //+MAG2.24 [371807]
          Customer."External Customer No." := ExternalCustomerNo;
          Customer.Insert(true);
          //-MAG2.22 [360098]
          //-MAG2.22 [360098]
          Customer."Post Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'post_code',MaxStrLen(Customer."Post Code"),true));
          Customer."Country/Region Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'country_code',MaxStrLen(Customer."Country/Region Code"),false));
          //+MAG2.22 [360098]
          CustTemplateCode := MagentoMgt.GetCustTemplate(Customer);
          if CustTemplateCode <> '' then begin
            CustTemplate.Get(CustTemplateCode);
          //+MAG2.22 [360098]
            Customer."Gen. Bus. Posting Group" := CustTemplate."Gen. Bus. Posting Group";
            Customer."VAT Bus. Posting Group" := CustTemplate."VAT Bus. Posting Group";
            Customer."Customer Posting Group" := CustTemplate."Customer Posting Group";
            //-MAG2.22 [359146]
            Customer."Currency Code" := GetCurrencyCode(CustTemplate."Currency Code");
            //+MAG2.22 [359146]
            Customer."Customer Price Group" := CustTemplate."Customer Price Group";
            Customer."Invoice Disc. Code" := CustTemplate."Invoice Disc. Code";
            Customer."Customer Disc. Group" := CustTemplate."Customer Disc. Group";
            Customer."Allow Line Disc." := CustTemplate."Allow Line Disc.";
            Customer."Payment Terms Code" := CustTemplate."Payment Terms Code";
            Customer."Payment Method Code" := CustTemplate."Payment Method Code";
            Customer."Shipment Method Code" := CustTemplate."Shipment Method Code";
          //-NPR5.55 [416534]
          end else if ConfigTemplateCode = '' then begin
          //+NPR5.55 [416534]
            Customer.Validate("Gen. Bus. Posting Group",VATBusPostingGroup);
            Customer.Validate("VAT Bus. Posting Group",VATBusPostingGroup);
            Customer.Validate("Customer Posting Group",MagentoSetup."Customer Posting Group");
            Customer.Validate("Payment Terms Code",MagentoSetup."Payment Terms Code");
          end;
        end;
        //-MAG2.22 [357662]
        case MagentoSetup."Customer Update Mode" of
          MagentoSetup."Customer Update Mode"::Create:
            begin
              if not NewCust then
                exit;
            end;
          MagentoSetup."Customer Update Mode"::None:
            begin
              exit;
            end;
          //-MAG2.26 [402247]
          MagentoSetup."Customer Update Mode"::Fixed:
            begin
              exit;
            end;
          //+MAG2.26 [402247]
        end;

        //+MAG2.22 [357662]
        PrevCust := Format(Customer);
        //-MAG2.22 [360098]
          //-MAG2.23 [360098]
          Customer."Post Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'post_code',MaxStrLen(Customer."Post Code"),true));
          Customer."Country/Region Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'country_code',MaxStrLen(Customer."Country/Region Code"),false));
          //+MAG2.23 [360098]
        ConfigTemplateCode := MagentoMgt.GetCustConfigTemplate(TaxClass,Customer);
        //+MAG2.22 [360098]
        if (ConfigTemplateCode <> '') and ConfigTemplateHeader.Get(ConfigTemplateCode) then begin
          RecRef.GetTable(Customer);
          ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
          RecRef.SetTable(Customer);
        end;

        Customer.Name := NpXmlDomMgt.GetXmlText(XmlElement,'name',MaxStrLen(Customer.Name),true);
        Customer."Name 2" := NpXmlDomMgt.GetXmlText(XmlElement,'name_2',MaxStrLen(Customer."Name 2"),false);
        Customer.Address := NpXmlDomMgt.GetXmlText(XmlElement,'address',MaxStrLen(Customer.Address),true);
        Customer."Address 2" := NpXmlDomMgt.GetXmlText(XmlElement,'address_2',MaxStrLen(Customer.Address),false);
        Customer."Post Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'post_code',MaxStrLen(Customer."Post Code"),true));
        Customer.City := NpXmlDomMgt.GetXmlText(XmlElement,'city',MaxStrLen(Customer.City),true);
        Customer."Country/Region Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'country_code',MaxStrLen(Customer."Country/Region Code"),false));
        Customer.Contact := NpXmlDomMgt.GetXmlText(XmlElement,'contact',MaxStrLen(Customer.Contact),false);
        Customer."E-Mail" := NpXmlDomMgt.GetXmlText(XmlElement,'email',MaxStrLen(Customer."E-Mail"),true);
        Customer."Phone No." := NpXmlDomMgt.GetXmlText(XmlElement,'phone',MaxStrLen(Customer."Phone No."),false);
        //-MAG2.22 [359332]
        Customer.GLN := NpXmlDomMgt.GetXmlText(XmlElement,'ean',MaxStrLen(Customer.GLN),false);
        if Customer.GLN <> '' then begin
          RecRef.GetTable(Customer);
          SetFieldText(RecRef,13600,Customer.GLN);
          RecRef.SetTable(Customer);

          if Customer.Contact = '' then
            Customer.Contact := 'X';
          Customer."Document Processing" := Customer."Document Processing"::OIO;
        end;
        //+MAG2.22 [359332]

        //-MAG2.09 [299976]
        Customer."VAT Registration No." := NpXmlDomMgt.GetXmlText(XmlElement,'vat_registration_no',MaxStrLen(Customer."VAT Registration No."),false);
        //+MAG2.09 [299976]
        Customer."Prices Including VAT" := true;
        //-NPR5.55 [412507]
        if NpXmlDomMgt.GetElementBoolean(XmlElement,'../prices_excluding_vat',false) then
          Customer."Prices Including VAT" := false;
        //+NPR5.55 [412507]
        //-MAG2.26 [401788]
        OnBeforeModifyCustomer(CurrImportType,CurrImportEntry,XmlElement,Customer);
        //+MAG2.26 [401788]
        if PrevCust = Format(Customer) then
          exit;
        Customer.Modify(true);
        //-MAG2.13 [314625]
        UpdateContFromCust.OnModify(Customer);
        //+MAG2.13 [314625]
    end;

    local procedure InsertPaymentLinePaymentMethod(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        PaymentLine: Record "Magento Payment Line";
        PaymentMapping: Record "Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        TransactionId: Text;
        PaymentAmount: Decimal;
        ShopperReference: Text;
    begin
        TransactionId := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'transaction_id',MaxStrLen(PaymentLine."No."),true));
        Evaluate(PaymentAmount,NpXmlDomMgt.GetXmlText(XmlElement,'payment_amount',0,true),9);
        if PaymentAmount = 0 then
          exit;

        //-MAG2.19 [347687]
        ShopperReference := NpXmlDomMgt.GetXmlText(XmlElement,'shopper_reference',MaxStrLen(PaymentLine."No."),false);
        //+MAG2.19 [347687]

        PaymentMapping.SetRange("External Payment Method Code",CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement,'code',true),1,MaxStrLen(PaymentMapping."External Payment Method Code")));

        PaymentMapping.SetRange("External Payment Type",NpXmlDomMgt.GetXmlText(XmlElement,'payment_type',MaxStrLen(PaymentMapping."External Payment Type"),false));
        if not PaymentMapping.FindFirst then begin
          PaymentMapping.SetRange("External Payment Type");
          PaymentMapping.FindFirst;
        end;
        PaymentMapping.TestField("Payment Method Code");
        PaymentMethod.Get(PaymentMapping."Payment Method Code");

        LineNo += 10000;
        PaymentLine."Document Table No." := DATABASE::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := LineNo;
        PaymentLine.Description := CopyStr(PaymentMethod.Description + ' ' + SalesHeader."External Order No.",1,MaxStrLen(PaymentLine.Description));
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine."Account Type" := PaymentMethod."Bal. Account Type";
        PaymentLine."Account No." := PaymentMethod."Bal. Account No.";
        PaymentLine."No." := TransactionId;
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine."Source Table No." := DATABASE::"Payment Method";
        PaymentLine."Source No." := PaymentMethod.Code;
        PaymentLine.Amount := PaymentAmount;
        PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
        PaymentLine."Payment Gateway Code" := PaymentMapping."Payment Gateway Code";
        //-MAG2.19 [347687]
        PaymentLine."Payment Gateway Shopper Ref." := ShopperReference;
        //+MAG2.19 [347687]
        //-MAG2.23 [367219]
        if PaymentMapping."Captured Externally" then
          PaymentLine."Date Captured" := GetDate(SalesHeader."Order Date",SalesHeader."Posting Date");
        //+MAG2.23 [367219]
        PaymentLine.Insert(true);
    end;

    local procedure InsertPaymentLineVoucher(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        CreditVoucher: Record "Credit Voucher";
        GiftVoucher: Record "Gift Voucher";
        NaviConnectPaymentLine: Record "Magento Payment Line";
        ExternalReferenceNo: Code[50];
        PaymentAccountNo: Code[20];
        PaymentSourceNo: Code[20];
        PaymentDescription: Text[50];
        Amount: Decimal;
        PaymentAmount: Decimal;
        PaymentLineNo: Integer;
        PaymentSourceTableNo: Integer;
        Err001: Label 'Invalid Web Code %1';
        Txt001: Label 'Giftvoucher %1';
        Txt002: Label 'Credit Voucher %1';
        NaviConnectPaymentLine2: Record "Magento Payment Line";
    begin
        Initialize;
        ExternalReferenceNo := NpXmlDomMgt.GetXmlText(XmlElement,'transaction_id',MaxStrLen(ExternalReferenceNo),true);
        Evaluate(Amount,NpXmlDomMgt.GetXmlText(XmlElement,'payment_amount',0,true),9);

        if Amount <> 0 then begin
          GiftVoucher.SetRange("External Reference No.",ExternalReferenceNo);
          CreditVoucher.SetRange("External Reference No.",ExternalReferenceNo);
          if GiftVoucher.FindFirst then begin
            PaymentDescription := StrSubstNo(Txt001,GiftVoucher."No.");
            PaymentAccountNo := MagentoSetup."Gift Voucher Account No.";
            PaymentSourceTableNo := DATABASE::"Gift Voucher";
            PaymentSourceNo := GiftVoucher."No.";
            PaymentAmount := GiftVoucher.Amount;
          end else
            if CreditVoucher.FindFirst then begin
              PaymentDescription := StrSubstNo(Txt002,CreditVoucher."No.");
              PaymentAccountNo := MagentoSetup."Credit Voucher Account No.";
              PaymentSourceTableNo := DATABASE::"Credit Voucher";
              PaymentSourceNo := CreditVoucher."No.";
              PaymentAmount := CreditVoucher.Amount;
            end else
              Error(StrSubstNo(Err001,ExternalReferenceNo));

          NaviConnectPaymentLine.Reset;
          NaviConnectPaymentLine.LockTable;
          NaviConnectPaymentLine.SetRange("Document Table No.",DATABASE::"Sales Header");
          NaviConnectPaymentLine.SetRange("Document Type",SalesHeader."Document Type");
          NaviConnectPaymentLine.SetRange("Document No.",SalesHeader."No.");
          if NaviConnectPaymentLine.FindLast then;
          PaymentLineNo := NaviConnectPaymentLine."Line No." + 10000;
          NaviConnectPaymentLine.Init;
          NaviConnectPaymentLine."Document Table No." := DATABASE::"Sales Header";
          NaviConnectPaymentLine."Document Type" := SalesHeader."Document Type";
          NaviConnectPaymentLine."Document No." := SalesHeader."No.";
          NaviConnectPaymentLine."Line No." := PaymentLineNo;
          NaviConnectPaymentLine."Payment Type" := NaviConnectPaymentLine."Payment Type"::Voucher;
          NaviConnectPaymentLine.Description := PaymentDescription;
          NaviConnectPaymentLine."Account No." := PaymentAccountNo;
          NaviConnectPaymentLine."No." := ExternalReferenceNo;
          NaviConnectPaymentLine.Amount := PaymentAmount;
          NaviConnectPaymentLine."Posting Date" := SalesHeader."Posting Date";
          NaviConnectPaymentLine."Source Table No." := PaymentSourceTableNo;
          NaviConnectPaymentLine."Source No." := PaymentSourceNo;
          NaviConnectPaymentLine.Insert;
        end;

        NaviConnectPaymentLine2.SetRange("Document Table No.",DATABASE::"Sales Header");
        NaviConnectPaymentLine2.SetRange("Document Type",SalesHeader."Document Type");
        NaviConnectPaymentLine2.SetRange("Document No.",SalesHeader."No.");
        if NaviConnectPaymentLine2.FindLast then ;
        PaymentLineNo := NaviConnectPaymentLine2."Line No." ;

        SalesHeader.CalcFields("Magento Payment Amount");
        if VATAmountLineTemp.GetTotalAmountInclVAT < SalesHeader."Magento Payment Amount" then begin
          CreditVoucher.Init;
          //-MAG2.09 [301960]
          CreditVoucher."No." := '';
          //+MAG2.09 [301960]
          CreditVoucher.Status := CreditVoucher.Status::Cancelled;
          CreditVoucher.Amount := SalesHeader."Magento Payment Amount" - VATAmountLineTemp.GetTotalAmountInclVAT;
          CreditVoucher."Customer No" := SalesHeader."Bill-to Customer No.";
          CreditVoucher.Name := CopyStr(SalesHeader."Bill-to Name",1,MaxStrLen(CreditVoucher.Name));
          CreditVoucher.Address := SalesHeader."Bill-to Address";
          CreditVoucher."Post Code" := SalesHeader."Bill-to Post Code";
          CreditVoucher.City := SalesHeader."Bill-to City";
          CreditVoucher."Location Code" := SalesHeader."Location Code";
          CreditVoucher."Shortcut Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
          CreditVoucher."Shortcut Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
          CreditVoucher."Sales Order No." := SalesHeader."No.";
          CreditVoucher."Currency Code" := SalesHeader."Currency Code";
          //-MAG2.25 [386010]
          CreditVoucher."Issue Date" := Today;
          CreditVoucher.Salesperson := SalesHeader."Salesperson Code";
          //+MAG2.25 [386010]
          CreditVoucher.Insert(true);

          NaviConnectPaymentLine2.Init;
          NaviConnectPaymentLine2."Document Table No." := DATABASE::"Sales Header";
          NaviConnectPaymentLine2."Document Type" := SalesHeader."Document Type";
          NaviConnectPaymentLine2."Document No." := SalesHeader."No.";
          PaymentLineNo += 10000;
          NaviConnectPaymentLine2."Line No." := PaymentLineNo;
          NaviConnectPaymentLine2."Payment Type" := NaviConnectPaymentLine2."Payment Type"::Voucher;
          NaviConnectPaymentLine2.Description := StrSubstNo(Txt002,CreditVoucher."No.");
          NaviConnectPaymentLine2."Account No." := MagentoSetup."Credit Voucher Account No.";
          NaviConnectPaymentLine2."No." := CopyStr(CreditVoucher."External Reference No.",1,MaxStrLen(NaviConnectPaymentLine2."No."));
          NaviConnectPaymentLine2."Posting Date" := SalesHeader."Posting Date";
          NaviConnectPaymentLine2."Source Table No." := DATABASE::"Credit Voucher";
          NaviConnectPaymentLine2."Source No." := CreditVoucher."No.";
          NaviConnectPaymentLine2.Amount := -CreditVoucher.Amount;
          NaviConnectPaymentLine2.Insert;
        end;
    end;

    local procedure InsertRetailVoucherPayment(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header";var LineNo: Integer): Boolean
    var
        NpRvSalesLine: Record "NpRv Sales Line";
        NpRvVoucher: Record "NpRv Voucher";
        NpRvGlobalVoucherWebservice: Codeunit "NpRv Global Voucher Webservice";
        PaymentLine: Record "Magento Payment Line";
        NpRvSalesDocMgt: Codeunit "NpRv Sales Doc. Mgt.";
        ExternalReferenceNo: Text;
        Amount: Decimal;
    begin
        //-MAG2.17 [302179]
        ExternalReferenceNo := NpXmlDomMgt.GetXmlText(XmlElement,'transaction_id',MaxStrLen(NpRvVoucher."Reference No."),true);
        Evaluate(Amount,NpXmlDomMgt.GetXmlText(XmlElement,'payment_amount',0,true),9);

        if not NpRvGlobalVoucherWebservice.FindVoucher('',ExternalReferenceNo,NpRvVoucher) then
          Error(Text000,ExternalReferenceNo);

        //-MAG2.26 [402013]
        NpRvVoucher.CalcFields(Amount);
        if NpRvVoucher.Amount < Amount then
          Error(Text003,Amount,NpRvVoucher.Amount);
        //+MAG2.26 [402013]

        NpRvSalesLine.SetRange("Document Source",NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("External Document No.",SalesHeader."External Order No.");
        NpRvSalesLine.SetRange("Voucher Type",NpRvVoucher."Voucher Type");
        NpRvSalesLine.SetRange("Voucher No.",NpRvVoucher."No.");
        NpRvSalesLine.SetRange(Type,NpRvSalesLine.Type::Payment);
        if not NpRvSalesLine.FindFirst then begin
          if NpRvVoucher.CalcInUseQty() > 0 then
            Error(Text001,NpRvVoucher."Reference No.");

          //-MAG2.26 [402015]
          NpRvSalesLine.Init;
          NpRvSalesLine.Id := CreateGuid;
          NpRvSalesLine."External Document No." := SalesHeader."External Order No.";
          NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
          NpRvSalesLine."Document Type" := SalesHeader."Document Type";
          NpRvSalesLine."Document No." := SalesHeader."No.";
          NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
          NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
          NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
          NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
          NpRvSalesLine.Description := NpRvVoucher.Description;
          NpRvSalesLine.Insert(true);
          //+MAG2.26 [402015]
        end;

        LineNo += 10000;
        PaymentLine.Init;
        PaymentLine."Document Table No." := DATABASE::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := LineNo;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::Voucher;
        PaymentLine.Description := NpRvVoucher.Description;
        PaymentLine."Account No." := NpRvVoucher."Account No.";
        PaymentLine."No." := NpRvVoucher."Reference No.";
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine."Source Table No." := DATABASE::"NpRv Voucher";
        PaymentLine."Source No." := NpRvVoucher."No.";
        PaymentLine."External Reference No." := SalesHeader."External Order No.";
        PaymentLine.Amount := Amount;
        PaymentLine.Insert;
        //+MAG2.17 [302179]

        //-MAG2.26 [402013]
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
        NpRvSalesLine."Document Type" := SalesHeader."Document Type"::Order;
        NpRvSalesLine."Document No." := SalesHeader."No.";
        NpRvSalesLine."Document Line No." := PaymentLine."Line No.";
        NpRvSalesLine.Modify(true);

        NpRvSalesDocMgt.ApplyPayment(SalesHeader,NpRvSalesLine);
        //+MAG2.26 [402013]
    end;

    local procedure InsertPaymentLines(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        XmlElement2: DotNet npNetXmlElement;
        XmlElementLines: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        LineNo: Integer;
        i: Integer;
    begin
        XmlElementLines := XmlElement.SelectSingleNode('payments');
        if not IsNull(XmlElementLines) then begin
          NpXmlDomMgt.FindNodes(XmlElementLines,'payment_method',XmlNodeList);
          LineNo := 0;
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement2 := XmlNodeList.ItemOf(i);
            case LowerCase(NpXmlDomMgt.GetXmlAttributeText(XmlElement2,'type',true)) of
              'payment_gateway','': InsertPaymentLinePaymentMethod(XmlElement2,SalesHeader,LineNo);
              'voucher': InsertPaymentLineVoucher(XmlElement2,SalesHeader,LineNo);
              //-MAG2.17 [302179]
              'retail_voucher': InsertRetailVoucherPayment(XmlElement2,SalesHeader,LineNo);
              //+MAG2.17 [302179]
            end;
          end;
        end;
    end;

    local procedure InsertSalesHeader(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        MagentoWebsite: Record "Magento Website";
        ShipmentMapping: Record "Magento Shipment Mapping";
        PaymentMapping: Record "Magento Payment Mapping";
        MagentoMgt: Codeunit "Magento Mgt.";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        XmlElement2: DotNet npNetXmlElement;
        RecRef: RecordRef;
        OrderNo: Code[20];
    begin
        Initialize;
        Clear(SalesHeader);
        OrderNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'order_no',true);
        //-MAG2.26 [402828]
        if MagentoWebsite.Get(NpXmlDomMgt.GetAttributeCode(XmlElement,'','website_code',MaxStrLen(MagentoWebsite.Code),true)) then;
        //+MAG2.26 [402828]

        if not NpXmlDomMgt.FindNode(XmlElement,'sell_to_customer',XmlElement2) then
          Error(Error001);
        InsertCustomer(XmlElement2,MagentoSetup."Customers Enabled",Customer);
        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';
        //-MAG2.26 [402828]
        if MagentoWebsite."Sales Order No. Series" <> '' then
          NoSeriesMgt.InitSeries(MagentoWebsite."Sales Order No. Series",SalesHeader."No. Series",Today,SalesHeader."No.",SalesHeader."No. Series");
        //+MAG2.26 [402828]
        SalesHeader."External Order No." := CopyStr(OrderNo,1,MaxStrLen(SalesHeader."External Order No."));
        SalesHeader."External Document No." := NpXmlDomMgt.GetXmlText(XmlElement,'external_document_no',MaxStrLen(SalesHeader."External Document No."),false);
        if SalesHeader."External Document No." = '' then
          SalesHeader."External Document No." := SalesHeader."External Order No.";
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.",Customer."No.");
        //-MAG2.22 [357662]
        SalesHeader."Sell-to Customer Name" := NpXmlDomMgt.GetElementText(XmlElement2,'name',MaxStrLen(SalesHeader."Sell-to Customer Name"),true);
        SalesHeader."Sell-to Customer Name 2" := NpXmlDomMgt.GetElementText(XmlElement2,'name_2',MaxStrLen(SalesHeader."Sell-to Customer Name 2"),false);
        SalesHeader."Sell-to Address"  := NpXmlDomMgt.GetElementText(XmlElement2,'address',MaxStrLen(SalesHeader."Sell-to Address"),true);
        SalesHeader."Sell-to Address 2" := NpXmlDomMgt.GetElementText(XmlElement2,'address_2',MaxStrLen(SalesHeader."Sell-to Address 2"),false);
        SalesHeader."Sell-to Post Code" := UpperCase(NpXmlDomMgt.GetElementCode(XmlElement2,'post_code',MaxStrLen(SalesHeader."Sell-to Post Code"),true));
        SalesHeader."Sell-to City" := NpXmlDomMgt.GetElementText(XmlElement2,'city',MaxStrLen(SalesHeader."Sell-to City"),true);
        SalesHeader."Sell-to Country/Region Code" := NpXmlDomMgt.GetElementCode(XmlElement2,'country_code',MaxStrLen(SalesHeader."Sell-to Country/Region Code"),false);
        SalesHeader."Sell-to Contact" := NpXmlDomMgt.GetElementText(XmlElement2,'contact',MaxStrLen(SalesHeader."Sell-to Contact"),false);
        //+MAG2.22 [357662]
        //-MAG2.26 [402247]
        RecRef.GetTable(SalesHeader);
        SetFieldText(RecRef,171,NpXmlDomMgt.GetXmlText(XmlElement2,'phone',MaxStrLen(Customer."Phone No."),false));
        SetFieldText(RecRef,13605,NpXmlDomMgt.GetXmlText(XmlElement2,'phone',MaxStrLen(Customer."Phone No."),false));
        SetFieldText(RecRef,13635,NpXmlDomMgt.GetXmlText(XmlElement2,'phone',MaxStrLen(Customer."Phone No."),false));
        SetFieldText(RecRef,172,NpXmlDomMgt.GetXmlText(XmlElement2,'email',MaxStrLen(Customer."E-Mail"),false));
        SetFieldText(RecRef,13607,NpXmlDomMgt.GetXmlText(XmlElement2,'email',MaxStrLen(Customer."E-Mail"),false));
        SetFieldText(RecRef,13637,NpXmlDomMgt.GetXmlText(XmlElement2,'email',MaxStrLen(Customer."E-Mail"),false));
        SetFieldText(RecRef,13630,NpXmlDomMgt.GetXmlText(XmlElement2,'ean',MaxStrLen(Customer.GLN),false));
        RecRef.SetTable(SalesHeader);
        case MagentoSetup."Customer Update Mode" of
          MagentoSetup."Customer Update Mode"::Fixed:
            begin
              TempCustomer."Post Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2,'post_code',MaxStrLen(Customer."Post Code"),true));
              TempCustomer."Country/Region Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2,'country_code',MaxStrLen(Customer."Country/Region Code"),false));
              if SalesHeader."Sell-to Customer No." = MagentoMgt.GetFixedCustomerNo(TempCustomer) then begin
                SalesHeader."Bill-to Name" := SalesHeader."Sell-to Customer Name";
                SalesHeader."Bill-to Name 2" := SalesHeader."Sell-to Customer Name 2";
                SalesHeader."Bill-to Address" := SalesHeader."Sell-to Address";
                SalesHeader."Bill-to Address 2" := SalesHeader."Sell-to Address 2";
                SalesHeader."Bill-to Post Code" := SalesHeader."Sell-to Post Code";
                SalesHeader."Bill-to City" := SalesHeader."Sell-to City";
                SalesHeader."Bill-to Company" := '';
                SalesHeader."Bill-to Contact" := SalesHeader."Sell-to Contact";
                SalesHeader."Bill-to Contact No." := SalesHeader."Sell-to Contact No.";
                SalesHeader."Bill-to Country/Region Code" := SalesHeader."Sell-to Country/Region Code";
                SalesHeader."Bill-to County" := SalesHeader."Sell-to County";
                SalesHeader."Bill-to E-mail" := NpXmlDomMgt.GetXmlText(XmlElement2,'email',MaxStrLen(SalesHeader."Bill-to E-mail"),false);

                SalesHeader."Ship-to Name" := SalesHeader."Sell-to Customer Name";
                SalesHeader."Ship-to Name 2" := SalesHeader."Sell-to Customer Name 2";
                SalesHeader."Ship-to Address" := SalesHeader."Sell-to Address";
                SalesHeader."Ship-to Address 2" := SalesHeader."Sell-to Address 2";
                SalesHeader."Ship-to Post Code" := SalesHeader."Sell-to Post Code";
                SalesHeader."Ship-to City" := SalesHeader."Sell-to City";
                SalesHeader."Ship-to Country/Region Code" := SalesHeader."Sell-to Country/Region Code";
                SalesHeader."Ship-to Contact" := SalesHeader."Sell-to Contact";
              end;
            end;
        end;
        //+MAG2.26 [402247]
        SalesHeader."Prices Including VAT" := true;
        //-NPR5.55 [412507]
        if NpXmlDomMgt.GetElementBoolean(XmlElement,'prices_excluding_vat',false) then
          SalesHeader."Prices Including VAT" := false;
        //+NPR5.55 [412507]

        if NpXmlDomMgt.FindNode(XmlElement,'ship_to_customer',XmlElement2) then begin
          SalesHeader."Ship-to Name" := NpXmlDomMgt.GetXmlText(XmlElement2,'name',MaxStrLen(SalesHeader."Ship-to Name"),true);
          SalesHeader."Ship-to Name 2" := NpXmlDomMgt.GetXmlText(XmlElement2,'name_2',MaxStrLen(SalesHeader."Ship-to Name 2"),false);
          SalesHeader."Ship-to Address" := NpXmlDomMgt.GetXmlText(XmlElement2,'address',MaxStrLen(SalesHeader."Ship-to Address"),true);
          SalesHeader."Ship-to Address 2" := NpXmlDomMgt.GetXmlText(XmlElement2,'address_2',MaxStrLen(SalesHeader."Ship-to Address 2"),false);
          SalesHeader."Ship-to Post Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2,'post_code',MaxStrLen(SalesHeader."Ship-to Post Code"),true));
          SalesHeader."Ship-to City" := NpXmlDomMgt.GetXmlText(XmlElement2,'city',MaxStrLen(SalesHeader."Ship-to City"),true);
          SalesHeader."Ship-to Country/Region Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2,'country_code',MaxStrLen(SalesHeader."Ship-to Country/Region Code"),false));
          SalesHeader."Ship-to Contact" := NpXmlDomMgt.GetXmlText(XmlElement2,'contact',MaxStrLen(SalesHeader."Ship-to Contact"),false);
        end;

        //-MAG2.22 [359332]
        if Customer.GLN <> '' then
          SalesHeader."Document Processing" := SalesHeader."Document Processing"::OIO;
        //+MAG2.22 [359332]
        SalesHeader.Validate("Salesperson Code",MagentoSetup."Salesperson Code");
        //-MAG2.20 [349994]
        if NpXmlDomMgt.GetElementBoolean(XmlElement,'use_customer_salesperson',false) and (Customer."Salesperson Code" <> '') then
          SalesHeader.Validate("Salesperson Code",Customer."Salesperson Code");
        //+MAG2.20 [349994]

        if NpXmlDomMgt.FindNode(XmlElement,'shipment',XmlElement2) then begin
          ShipmentMapping.SetRange("External Shipment Method Code",NpXmlDomMgt.GetXmlText(XmlElement2,'shipment_method',MaxStrLen(ShipmentMapping."External Shipment Method Code"),true));
          ShipmentMapping.FindFirst;
          SalesHeader.Validate("Shipment Method Code",ShipmentMapping."Shipment Method Code");
          SalesHeader.Validate("Shipping Agent Code",ShipmentMapping."Shipping Agent Code");
          SalesHeader.Validate("Shipping Agent Service Code",ShipmentMapping."Shipping Agent Service Code");
          RecRef.GetTable(SalesHeader);
          SetFieldText(RecRef,6014420,NpXmlDomMgt.GetXmlText(XmlElement2,'shipment_service',10,false));
          RecRef.SetTable(SalesHeader);
        end;

        if NpXmlDomMgt.FindNode(XmlElement,'payments/payment_method',XmlElement2) then
          repeat
            if LowerCase(NpXmlDomMgt.GetXmlAttributeText(XmlElement2,'type',true)) = 'payment_gateway' then begin
              PaymentMapping.SetRange("External Payment Method Code",
                CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement2,'code',true),1,MaxStrLen(PaymentMapping."External Payment Method Code")));
              PaymentMapping.SetRange("External Payment Type",
                NpXmlDomMgt.GetXmlText(XmlElement2,'payment_type',MaxStrLen(PaymentMapping."External Payment Type"),false));
              if not PaymentMapping.FindFirst then begin
                PaymentMapping.SetRange("External Payment Type");
                PaymentMapping.FindFirst;
              end;
              if (SalesHeader."Payment Method Code" = '') and (PaymentMapping."Payment Method Code" <> '') then
                SalesHeader.Validate("Payment Method Code",PaymentMapping."Payment Method Code");
            end;
            XmlElement2 := XmlElement2.NextSibling;
            if not IsNull(XmlElement2) then
              if LowerCase(XmlElement2.Name) <> 'payment_method' then
                Clear(XmlElement2);
          until IsNull(XmlElement2) or (SalesHeader."Payment Method Code" <> '');

        //-MAG2.26 [402828]
        if (MagentoWebsite.Code <> '') and (MagentoWebsite."Global Dimension 1 Code" <> '') then begin
        //+MAG2.26 [402828]
          SalesHeader.Validate(SalesHeader."Shortcut Dimension 1 Code",MagentoWebsite."Global Dimension 1 Code");
          SalesHeader.Validate("Shortcut Dimension 2 Code",MagentoWebsite."Global Dimension 2 Code");
        end;
        SalesHeader.Validate("Location Code",MagentoWebsite."Location Code");
        //-MAG2.22 [359146]
        SalesHeader.Validate("Currency Code",GetCurrencyCode(NpXmlDomMgt.GetElementCode(XmlElement,'currency_code',MaxStrLen(SalesHeader."Currency Code"),false)));
        //+MAG2.22 [359146]
        SalesHeader.Modify(true);

        //-MAG2.26 [401788]
        OnAfterInsertSalesHeader(CurrImportType,CurrImportEntry,XmlElement,SalesHeader);
        //+MAG2.26 [401788]
    end;

    local procedure InsertSalesLines(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header")
    var
        SalesLineTemp: Record "Sales Line" temporary;
        XmlElementLine: DotNet npNetXmlElement;
        XmlElementLines: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        LineNo: Integer;
        i: Integer;
    begin
        LineNo := 0;

        XmlElementLines := XmlElement.SelectSingleNode('sales_order_lines');
        if not IsNull(XmlElementLines) then begin
          NpXmlDomMgt.FindNodes(XmlElementLines,'sales_order_line',XmlNodeList);
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElementLine := XmlNodeList.ItemOf(i);
            InsertSalesLine(XmlElementLine,SalesHeader,LineNo);
          end;
        end;

        XmlElementLines := XmlElement.SelectSingleNode('payments');
        if not IsNull(XmlElementLines) then begin
          NpXmlDomMgt.FindNodes(XmlElementLines,'payment_method',XmlNodeList);
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElementLine := XmlNodeList.ItemOf(i);
            InsertSalesLinePaymentFee(XmlElementLine,SalesHeader,LineNo);
          end;
        end;

        if NpXmlDomMgt.FindNode(XmlElement,'shipment',XmlElementLine) then
          InsertSalesLineShipmentFee(XmlElementLine,SalesHeader,LineNo);

        SalesPost.GetSalesLines(SalesHeader,SalesLineTemp,0);
        SalesLineTemp.CalcVATAmountLines(0,SalesHeader,SalesLineTemp,VATAmountLineTemp);
        SalesLineTemp.UpdateVATOnLines(0,SalesHeader,SalesLineTemp,VATAmountLineTemp);
    end;

    local procedure InsertSalesLine(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        Initialize;
        //-MAG2.17 [302179]
        case LowerCase(NpXmlDomMgt.GetXmlAttributeText(XmlElement,'type',true)) of
          'comment' :
            begin
              InsertSalesLineComment(XmlElement,SalesHeader,LineNo);
            end;
          'item' :
            begin
              InsertSalesLineItem(XmlElement,SalesHeader,LineNo);
            end;
          'gift_voucher' :
            begin
              InsertSalesLineGiftVoucher(XmlElement,SalesHeader,LineNo);
            end;
          'fee' :
            begin
              InsertSalesLineFee(XmlElement,SalesHeader,LineNo);
            end;
          'retail_voucher':
            begin
              InsertSalesLineRetailVoucher(XmlElement,SalesHeader,LineNo);
            end;
          //-MAG2.17 [324190]
          'custom_option':
            begin
              InsertSalesLineCustomOption(XmlElement,SalesHeader,LineNo);
            end;
          //+MAG2.17 [324190]
        end;
        //+MAG2.17 [302179]

        //-MAG2.26 [401788]
        if SalesLine.Get(SalesHeader."Document Type",LineNo) then
          OnAfterInsertSalesLine(CurrImportType,CurrImportEntry,XmlElement,SalesHeader,SalesLine);
        //+MAG2.26 [401788]
    end;

    local procedure InsertSalesLineComment(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        //-MAG2.17 [302179]
        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);
        SalesLine.Validate(Type,SalesLine.Type::" ");
        SalesLine.Description := NpXmlDomMgt.GetXmlText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
        SalesLine.Modify(true);
        //+MAG2.17 [302179]
    end;

    local procedure InsertSalesLineItem(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
        Position: Integer;
        TableId: Integer;
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        VatPct: Decimal;
        ExternalItemNo: Text;
        ItemNo: Code[20];
        UnitofMeasure: Code[10];
        VariantCode: Code[10];
        RequestedDeliveryDate: Date;
    begin
        //-MAG2.17 [302179]
        ExternalItemNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'external_no',true);
        Position := StrPos(ExternalItemNo,'_');
        if Position = 0 then begin
          ItemNo := CopyStr(ExternalItemNo,1,MaxStrLen(SalesHeader."No."));
          VariantCode := '';
        end else begin
          ItemNo := CopyStr(CopyStr(ExternalItemNo,1,Position - 1),1,MaxStrLen(SalesHeader."No."));
          VariantCode := CopyStr(CopyStr(ExternalItemNo,Position + 1),1,MaxStrLen(SalesHeader."No."));
        end;
        if not Item.Get(ItemNo) then
          if not (TranslateBarcodeToItemVariant(ExternalItemNo,ItemNo,VariantCode,TableId)) then
            //-MAG2.17 [302179]
            //ERROR(STRSUBSTNO(Error002,ItemNo,TableId));
            Error(StrSubstNo(Error002,ExternalItemNo,XmlElement.Name));
            //+MAG2.17 [302179]

        if VariantCode <> '' then
          ItemVariant.Get(ItemNo,VariantCode);
        //-NPR5.55 [412507]
        UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price_incl_vat',true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount_incl_vat',true);
        if not SalesHeader."Prices Including VAT" then begin
          UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price_excl_vat',true);
          LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount_excl_vat',true);
        end;
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement,'quantity',true);
        VatPct := NpXmlDomMgt.GetElementDec(XmlElement,'vat_percent',true);
        UnitofMeasure := NpXmlDomMgt.GetElementCode(XmlElement,'unit_of_measure',MaxStrLen(SalesLine."Unit of Measure Code"),false);
        //+NPR5.55 [412507]
        //-MAG2.22 [350006]
        RequestedDeliveryDate:=NpXmlDomMgt.GetElementDate(XmlElement,'requested_delivery_date',false);
        //+MAG2.22 [350006]
        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type,SalesLine.Type::Item);
        SalesLine.Validate("No.",ItemNo);
        SalesLine."Variant Code" := VariantCode;
        //-MAG2.22 [358761]
        if VariantCode <> '' then
          SalesLine."Description 2" := ItemVariant.Description;
        //+MAG2.22 [358761]
        SalesLine.Validate(Quantity,Quantity);
        //-MAG2.22 [350006]
        if RequestedDeliveryDate <> 0D then
          SalesLine.Validate("Requested Delivery Date",RequestedDeliveryDate);
        //+MAG2.22 [350006]
        if not (UnitofMeasure in ['','_BLANK_']) then
          SalesLine.Validate("Unit of Measure Code",UnitofMeasure);
        if UnitPrice > 0 then
          SalesLine.Validate("Unit Price",UnitPrice)
        else
          SalesLine."Unit Price" := UnitPrice;
        SalesLine.Validate("VAT Prod. Posting Group");
        //-MAG2.22 [360098]
        SalesLine.Validate("VAT %",VatPct);
        //+MAG2.22 [360098]

        if SalesLine."Unit Price" <> 0 then
          SalesLine.Validate("Line Amount",LineAmount)
        else
          SalesLine."Line Amount" := LineAmount;
        SalesLine.Modify(true);
        //+MAG2.17 [302179]
    end;

    local procedure InsertSalesLineGiftVoucher(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        XmlElementGiftVoucher: DotNet npNetXmlElement;
        SalesLine: Record "Sales Line";
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        VatPct: Decimal;
    begin
        //-MAG2.17 [302179]
        //-NPR5.55 [412507]
        UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price_incl_vat',true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount_incl_vat',true);
        if not SalesHeader."Prices Including VAT" then begin
          UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price_excl_vat',true);
          LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount_excl_vat',true);
        end;
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement,'quantity',true);
        VatPct := NpXmlDomMgt.GetElementDec(XmlElement,'vat_percent',true);
        //+NPR5.55 [412507]

        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.",MagentoSetup."Gift Voucher Account No.");
        SalesLine.Description := NpXmlDomMgt.GetXmlText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
        SalesLine.Validate("Unit Price",UnitPrice);
        SalesLine.Validate(Quantity,Quantity);
        SalesLine.Validate("VAT %",VatPct);
        SalesLine.Validate("Line Amount",LineAmount);
        SalesLine.Modify(true);

        XmlElementGiftVoucher := XmlElement.SelectSingleNode('gift_vouchers/gift_voucher');
        while not IsNull(XmlElementGiftVoucher) do begin
          InsertGiftVoucher(XmlElementGiftVoucher,SalesHeader);
          XmlElementGiftVoucher:= XmlElementGiftVoucher.NextSibling;
        end;
        //+MAG2.17 [302179]
    end;

    local procedure InsertSalesLineFee(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesCommentLine: Record "Sales Comment Line";
        SalesLine: Record "Sales Line";
        ShipmentMapping: Record "Magento Shipment Mapping";
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        VatPct: Decimal;
    begin
        //-MAG2.17 [302179]
        Evaluate(Quantity,NpXmlDomMgt.GetXmlText(XmlElement,'quantity',0,true),9);
        Evaluate(LineAmount,NpXmlDomMgt.GetXmlText(XmlElement,'line_amount_incl_vat',0,true),9);
        if (Quantity = 0) and (LineAmount = 0) then begin
          LineNo += 10000;
          SalesCommentLine.Init;
          SalesCommentLine."Document Type" := SalesHeader."Document Type";
          SalesCommentLine."No." := SalesHeader."No.";
          SalesCommentLine."Document Line No." := 0;
          SalesCommentLine."Line No." := LineNo;
          SalesCommentLine.Date := Today;
          SalesCommentLine.Comment := NpXmlDomMgt.GetXmlText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
          SalesCommentLine.Insert(true);
        end else begin
          //-NPR5.55 [412507]
          UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price_incl_vat',true);
          VatPct := NpXmlDomMgt.GetElementDec(XmlElement,'vat_percent',true);
          if not SalesHeader."Prices Including VAT" then
            UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price_excl_vat',true);
          //+NPR5.55 [412507]

          LineNo += 10000;
          SalesLine.Init;
          SalesLine."Document Type" := SalesHeader."Document Type";
          SalesLine."Document No." := SalesHeader."No.";
          SalesLine."Line No." := LineNo;
          SalesLine.Insert(true);
          ShipmentMapping.SetRange("External Shipment Method Code",NpXmlDomMgt.GetXmlAttributeText(XmlElement,'external_no',false));
          ShipmentMapping.FindFirst;
          //-MAG2.22 [357763]
          //SalesLine.VALIDATE(Type,SalesLine.Type::"G/L Account");
          case ShipmentMapping."Shipment Fee Type" of
            ShipmentMapping."Shipment Fee Type"::"G/L Account":
              begin
                SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
              end;
            ShipmentMapping."Shipment Fee Type"::Item:
              begin
                SalesLine.Validate(Type,SalesLine.Type::Item);
              end;
            ShipmentMapping."Shipment Fee Type"::Resource:
              begin
                SalesLine.Validate(Type,SalesLine.Type::Resource);
              end;
            ShipmentMapping."Shipment Fee Type"::"Fixed Asset":
              begin
                SalesLine.Validate(Type,SalesLine.Type::"Fixed Asset");
              end;
            ShipmentMapping."Shipment Fee Type"::"Charge (Item)":
              begin
                SalesLine.Validate(Type,SalesLine.Type::"Charge (Item)");
              end;
          end;
          //+MAG2.22 [357763]
          SalesLine.Validate("No.",ShipmentMapping."Shipment Fee No.");
          if Quantity <> 0 then
            SalesLine.Validate(Quantity,Quantity);
          //-NPR5.55 [412507]
          SalesLine.Validate("VAT %",VatPct);
          //+NPR5.55 [412507]

          SalesLine.Validate("Unit Price",UnitPrice);
          SalesLine.Description := NpXmlDomMgt.GetXmlText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
          SalesLine.Modify(true);
        end;
        //-MAG2.17 [302179]
    end;

    local procedure InsertSalesLineRetailVoucher(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        NpRvSalesLine: Record "NpRv Sales Line";
        NpRvVoucher: Record "NpRv Voucher";
        NpRvVoucherType: Record "NpRv Voucher Type";
        SalesLine: Record "Sales Line";
        NpRvGlobalVoucherWebservice: Codeunit "NpRv Global Voucher Webservice";
        ReferenceNo: Text;
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        VatPct: Decimal;
        PrevRec: Text;
    begin
        //-MAG2.26 [402015]
        ReferenceNo := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement,'external_no',true),1,MaxStrLen(NpRvVoucher."Reference No."));

        NpRvSalesLine.SetRange("Document Source",NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("External Document No.",SalesHeader."External Order No.");
        NpRvSalesLine.SetRange("Reference No.",ReferenceNo);
        NpRvSalesLine.SetFilter(Type,'%1|%2',NpRvSalesLine.Type::"New Voucher",NpRvSalesLine.Type::"Top-up");
        if not NpRvSalesLine.FindFirst then begin
          if NpRvGlobalVoucherWebservice.FindVoucher('',ReferenceNo,NpRvVoucher) then begin
            NpRvSalesLine.Init;
            NpRvSalesLine.Id := CreateGuid;
            NpRvSalesLine."External Document No." := SalesHeader."External Order No.";
            NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
            NpRvSalesLine."Document Type" := SalesHeader."Document Type";
            NpRvSalesLine."Document No." := SalesHeader."No.";
            NpRvSalesLine.Type := NpRvSalesLine.Type::"Top-up";
            NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
            NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
            NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
            NpRvSalesLine.Description := NpRvVoucher.Description;
            NpRvSalesLine.Insert(true);
          end;
        end;
        NpRvSalesLine.FindFirst;
        NpRvVoucherType.Get(NpRvSalesLine."Voucher Type");
        NpRvVoucherType.TestField("Account No.");
        if (NpRvSalesLine."Voucher No." <> '') and NpRvVoucher.Get(NpRvSalesLine."Voucher No.") then begin
          NpRvVoucher.CalcFields("Issue Date");
          if (NpRvVoucher."Issue Date" <> 0D) then
            NpRvVoucher.TestField("Allow Top-up");

          if NpRvVoucher."Account No." <> '' then
            NpRvVoucherType."Account No." := NpRvVoucher."Account No.";
        end;

        //-NPR5.55 [412507]
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement,'quantity',true);
        UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price_incl_vat',true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount_incl_vat',true);
        if not SalesHeader."Prices Including VAT" then begin
          UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price_excl_vat',true);
          LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount_excl_vat',true);
        end;
        VatPct := NpXmlDomMgt.GetElementDec(XmlElement,'vat_percent',true);
        //+NPR5.55 [412507]

        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.",NpRvVoucherType."Account No.");
        //-MAG2.25 [372135]
        SalesLine.Description := NpRvSalesLine.Description;
        //+MAG2.25 [372135]
        SalesLine.Validate(Quantity,Quantity);
        SalesLine.Validate("VAT %",VatPct);
        SalesLine.Validate("Unit Price",UnitPrice);
        if SalesLine."Unit Price" <> 0 then
          SalesLine.Validate("Line Amount",LineAmount);
        SalesLine.Modify(true);

        PrevRec := Format(NpRvSalesLine);

        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Document Type" := SalesLine."Document Type";
        NpRvSalesLine."Document No." := SalesLine."Document No.";
        NpRvSalesLine."Document Line No." := SalesLine."Line No.";

        if PrevRec <> Format(NpRvSalesLine) then
          NpRvSalesLine.Modify(true);
        //+MAG2.26 [402015]
    end;

    local procedure InsertSalesLinePaymentFee(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        PaymentFee: Decimal;
    begin
        if not Evaluate(PaymentFee,NpXmlDomMgt.GetXmlText(XmlElement,'payment_fee',0,false),9) then
          exit;
        //-MAG2.00
        if PaymentFee = 0 then
          exit;
        //+MAG2.00
        Initialize;
        MagentoSetup.TestField("Payment Fee Account No.");

        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.",MagentoSetup."Payment Fee Account No.");
        SalesLine.Validate("Unit Price",PaymentFee);
        SalesLine.Validate(Quantity,1);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineShipmentFee(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        ShipmentMapping: Record "Magento Shipment Mapping";
        ShipmentFee: Decimal;
    begin
        if not Evaluate(ShipmentFee,NpXmlDomMgt.GetXmlText(XmlElement,'shipment_fee',0,false),9) then
          exit;
        //-MAG2.13 [315841]
        if ShipmentFee = 0 then
          exit;
        //+MAG2.13 [315841]

        ShipmentMapping.SetRange("External Shipment Method Code",NpXmlDomMgt.GetXmlText(XmlElement,'shipment_method',MaxStrLen(ShipmentMapping."External Shipment Method Code"),true));
        ShipmentMapping.FindFirst;
        ShipmentMapping.TestField("Shipment Fee No.");

        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        //-MAG2.22 [357763]
        //SalesLine.VALIDATE(Type,SalesLine.Type::"G/L Account");
        case ShipmentMapping."Shipment Fee Type" of
          ShipmentMapping."Shipment Fee Type"::"G/L Account":
            begin
              SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
            end;
          ShipmentMapping."Shipment Fee Type"::Item:
            begin
              SalesLine.Validate(Type,SalesLine.Type::Item);
            end;
          ShipmentMapping."Shipment Fee Type"::Resource:
            begin
              SalesLine.Validate(Type,SalesLine.Type::Resource);
            end;
          ShipmentMapping."Shipment Fee Type"::"Fixed Asset":
            begin
              SalesLine.Validate(Type,SalesLine.Type::"Fixed Asset");
            end;
          ShipmentMapping."Shipment Fee Type"::"Charge (Item)":
            begin
              SalesLine.Validate(Type,SalesLine.Type::"Charge (Item)");
            end;
        end;
        //+MAG2.22 [357763]
        SalesLine.Validate("No.",ShipmentMapping."Shipment Fee No.");
        SalesLine.Validate("Unit Price",ShipmentFee);
        SalesLine.Validate(Quantity,1);
        SalesLine.Modify(true);
    end;

    local procedure InsertGiftVoucher(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header")
    var
        GiftVoucher: Record "Gift Voucher";
        Ostream: OutStream;
    begin
        GiftVoucher.Init;
        Evaluate(GiftVoucher.Amount,NpXmlDomMgt.GetXmlText(XmlElement,'amount',0,true),9);
        GiftVoucher.Name := NpXmlDomMgt.GetXmlText(XmlElement,'name',MaxStrLen(GiftVoucher.Name),true);
        GiftVoucher."External Gift Voucher No." := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'external_no',true);
        GiftVoucher."External Reference No." := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'certificate_number',true);
        GiftVoucher.Status := GiftVoucher.Status::Cancelled;
        GiftVoucher."Sales Order No." := SalesHeader."No." ;
        GiftVoucher."Gift Voucher Message".CreateOutStream(Ostream);
        Ostream.Write(NpXmlDomMgt.GetXmlText(XmlElement,'message',0,true));
        GiftVoucher."Issue Date" := Today;
        GiftVoucher.Salesperson := SalesHeader."Salesperson Code";
        GiftVoucher."External No." := SalesHeader."External Document No.";
        GiftVoucher."Customer No." := SalesHeader."Sell-to Customer No.";
        GiftVoucher.Insert(true);
    end;

    local procedure InsertSalesLineCustomOption(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        MagentoCustomOption: Record "Magento Custom Option";
        MagentoCustomOptionValue: Record "Magento Custom Option Value";
        SalesLine: Record "Sales Line";
        Position: Integer;
        Position2: Integer;
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        VatPct: Decimal;
        CustomOptionLineNo: Integer;
        SalesType: Integer;
        CustomOptionNo: Code[20];
        SalesNo: Code[20];
        UnitofMeasure: Code[10];
        ExternalItemNo: Text;
    begin
        //-MAG2.17 [324190]
        ExternalItemNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'external_no',true);
        Position := StrPos(ExternalItemNo,'#');
        CustomOptionLineNo := 0;
        if Position = 0 then
          CustomOptionNo := CopyStr(ExternalItemNo,1,MaxStrLen(MagentoCustomOption."No."))
        else
          CustomOptionNo := CopyStr(ExternalItemNo,Position + 1,MaxStrLen(MagentoCustomOption."No."));

        Position2 := StrPos(ExternalItemNo,'_');
        if Position2 <> 0 then begin
          CustomOptionNo := CopyStr(CustomOptionNo,1,StrPos(CustomOptionNo,'_') - 1);
          Evaluate(CustomOptionLineNo,CopyStr(ExternalItemNo,Position2 + 1,10),9);
        end;
        MagentoCustomOption.Get(CustomOptionNo);
        //-NPR5.55 [401059]
        case MagentoCustomOption.Type of
          MagentoCustomOption.Type::SelectCheckbox,MagentoCustomOption.Type::SelectDropDown,
          MagentoCustomOption.Type::SelectMultiple,MagentoCustomOption.Type::SelectRadioButtons:
            begin
              MagentoCustomOptionValue.Get(CustomOptionNo,CustomOptionLineNo);
              MagentoCustomOptionValue.TestField("Sales No.");
              SalesType := MagentoCustomOptionValue."Sales Type";
              SalesNo := MagentoCustomOptionValue."Sales No.";
            end
          else begin
            MagentoCustomOption.TestField("Sales No.");
            SalesType := MagentoCustomOption."Sales Type";
            SalesNo := MagentoCustomOption."Sales No.";
          end;
        end;
        //+NPR5.55 [401059]

        //-NPR5.55 [412507]
        UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price_incl_vat',true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount_incl_vat',true);
        if not SalesHeader."Prices Including VAT" then begin
          UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price_excl_vat',true);
          LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount_excl_vat',true);
        end;
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement,'quantity',true);
        VatPct := NpXmlDomMgt.GetElementDec(XmlElement,'vat_percent',true);
        UnitofMeasure := NpXmlDomMgt.GetElementCode(XmlElement,'unit_of_measure',MaxStrLen(SalesLine."Unit of Measure Code"),false);
        //+NPR5.55 [412507]
        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type,SalesType);
        SalesLine.Validate("No.",SalesNo);
        SalesLine.Description := NpXmlDomMgt.GetXmlText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
        SalesLine."Description 2" :=NpXmlDomMgt.GetXmlText(XmlElement,'description_2',MaxStrLen(SalesLine.Description),false);
        SalesLine.Validate(Quantity,Quantity);
        if not (UnitofMeasure in ['','_BLANK_']) then
          SalesLine.Validate("Unit of Measure Code",UnitofMeasure);
        if UnitPrice > 0 then
          SalesLine.Validate("Unit Price",UnitPrice)
        else
          SalesLine."Unit Price" := UnitPrice;
        SalesLine.Validate("VAT Prod. Posting Group");
        //-MAG2.22 [360098]
        SalesLine.Validate("VAT %",VatPct);
        //+MAG2.22 [360098]

        if SalesLine."Unit Price" <> 0 then
          SalesLine.Validate("Line Amount",LineAmount)
        else
          SalesLine."Line Amount" := LineAmount;
        SalesLine.Modify(true);
        //+MAG2.17 [324190]
    end;

    local procedure UpdateExtCouponReservations(SalesHeader: Record "Sales Header")
    var
        NpDcExtCouponReservation: Record "NpDc Ext. Coupon Reservation";
    begin
        //-MAG2.22 [343352]
        NpDcExtCouponReservation.SetRange("External Document No.",SalesHeader."External Order No.");
        NpDcExtCouponReservation.SetFilter("Document No.",'=%1','');
        if NpDcExtCouponReservation.FindFirst then begin
          NpDcExtCouponReservation.ModifyAll("Document Type",SalesHeader."Document Type");
          NpDcExtCouponReservation.ModifyAll("Document No.",SalesHeader."No.");
        end;
        //+MAG2.22 [343352]
    end;

    local procedure UpdateRetailVoucherCustomerInfo(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        NpRvSalesLine: Record "NpRv Sales Line";
        NpRvSalesLinePrev: Record "NpRv Sales Line";
    begin
        //-MAG2.26 [402015]
        NpRvSalesLine.SetRange("External Document No.",SalesHeader."External Order No.");
        NpRvSalesLine.SetRange("Document Type",SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.",SalesHeader."No.");
        if not NpRvSalesLine.FindSet then
          exit;

        repeat
          NpRvSalesLinePrev := NpRvSalesLine;

          NpRvSalesLine."Customer No." := SalesHeader."Sell-to Customer No.";
          case MagentoSetup."E-mail Retail Vouchers to" of
            MagentoSetup."E-mail Retail Vouchers to"::" ":
              begin
                NpRvSalesLine."E-mail" := NpRvSalesLinePrev."E-mail";
                NpRvSalesLine."Phone No." := NpRvSalesLinePrev."Phone No.";
              end;
            MagentoSetup."E-mail Retail Vouchers to"::"Bill-to Customer":
              begin
                Customer.Get(SalesHeader."Bill-to Customer No.");
                NpRvSalesLine."E-mail" := Customer."E-Mail";
                NpRvSalesLine."Phone No." := Customer."Phone No.";;
              end;
          end;

          if Format(NpRvSalesLinePrev) <> Format(NpRvSalesLine) then
            NpRvSalesLine.Modify(true);
        until NpRvSalesLine.Next = 0;
        //+MAG2.26 [402015]
    end;

    local procedure "--- Post On Import"()
    begin
    end;

    local procedure SendOrderConfirmation(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header") MailErrorMessage: Text
    var
        Customer: Record Customer;
        EmailTemplateHeader: Record "E-mail Template Header";
        ReportSelections: Record "Report Selections";
        EmailMgt: Codeunit "E-mail Management";
        RecRef: RecordRef;
        RecipientEmail: Text;
    begin
        //-MAG2.25 [387936]
        RecipientEmail := NpXmlDomMgt.GetXmlText(XmlElement,'sell_to_customer/email',0,true);
        MagentoSetup.TestField("E-mail Template (Order Conf.)");
        EmailTemplateHeader.Get(MagentoSetup."E-mail Template (Order Conf.)");
        RecRef.GetTable(SalesHeader);
        RecRef.SetRecFilter;
        if EmailTemplateHeader."Report ID" <= 0 then begin
          ReportSelections.SetRange(Usage,ReportSelections.Usage::"S.Order");
          ReportSelections.SetFilter("Report ID",'>%1',0);
          ReportSelections.FindFirst;
          EmailTemplateHeader."Report ID" := ReportSelections."Report ID";
        end;
        MailErrorMessage := EmailMgt.SendReportTemplate(EmailTemplateHeader."Report ID",RecRef,EmailTemplateHeader,RecipientEmail,true);
        exit(MailErrorMessage);
        //+MAG2.25 [387936]
    end;

    local procedure PostOnImport(SalesHeader: Record "Sales Header")
    var
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        PrevRec: Text;
    begin
        //-MAG2.23 [371791]
        if not HasLinesToPostOnImport(SalesHeader) then
          exit;

        if SalesHeader.Status <> SalesHeader.Status::Open then
          ReleaseSalesDoc.PerformManualReopen(SalesHeader);

        ResetSalesLines(SalesHeader);

        MarkLinesForPosting(SalesHeader);

        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);
        //+MAG2.23 [371791]
    end;

    local procedure HasLinesToPostOnImport(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        //-MAG2.23 [371791]
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetFilter(Quantity,'<>%1',0);
        if SalesLine.FindSet then
          repeat
            if IsLineToPost(SalesLine) then
              exit(true);
          until SalesLine.Next = 0;

        exit(false);
        //+MAG2.23 [371791]
    end;

    local procedure IsLineToPost(SalesLine: Record "Sales Line"): Boolean
    begin
        //-MAG2.23 [363864]
        if MagentoSetup."Post Retail Vouchers on Import" then begin
          if IsRetailVoucherLine(SalesLine) then
            exit(true);
        end;
        //+MAG2.23 [363864]

        //-MAG2.23 [371791]
        if MagentoSetup."Post Tickets on Import" then begin
          if IsTicketLine(SalesLine) then
            exit(true);
        end;

        if MagentoSetup."Post Memberships on Import" then begin
          if IsMembershipLine(SalesLine) then
            exit(true);
        end;
        //+MAG2.23 [371791]

        //-MAG2.23 [373262]
        if HasPostOnImportSetup(SalesLine) then
          exit(true);

        exit(false);
        //-MAG2.23 [373262]
    end;

    local procedure IsRetailVoucherLine(SalesLine: Record "Sales Line"): Boolean
    var
        NpRvSalesLine: Record "NpRv Sales Line";
    begin
        //-MAG2.26 [402015]
        //-MAG2.23 [363864]
        NpRvSalesLine.SetRange("Document Source",NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("Document Type",SalesLine."Document Type");
        NpRvSalesLine.SetRange("Document No.",SalesLine."Document No.");
        NpRvSalesLine.SetRange("Document Line No.",SalesLine."Line No.");
        exit(NpRvSalesLine.FindFirst);
        //+MAG2.23 [363864]
        //+MAG2.26 [402015]
    end;

    local procedure IsTicketLine(SalesLine: Record "Sales Line"): Boolean
    var
        Item: Record Item;
    begin
        //-MAG2.23 [371791]
        if SalesLine.Type <> SalesLine.Type::Item then
          exit(false);

        if not Item.Get(SalesLine."No.") then
          exit(false);

        exit(Item."Ticket Type" <> '');
        //+MAG2.23 [371791]
    end;

    local procedure IsMembershipLine(SalesLine: Record "Sales Line"): Boolean
    var
        MMMembershipAlterationSetup: Record "MM Membership Alteration Setup";
        MMMembershipSalesSetup: Record "MM Membership Sales Setup";
    begin
        //-MAG2.23 [371791]
        case SalesLine.Type of
          SalesLine.Type::"G/L Account":
            begin
              if MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ACCOUNT,SalesLine."No.") then
                exit(true);
            end;
          SalesLine.Type::Item:
            begin
              if MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ITEM,SalesLine."No.") then
                exit(true);

              MMMembershipAlterationSetup.SetRange("Sales Item No.",SalesLine."No.");
              if MMMembershipAlterationSetup.FindFirst then
                exit(true);
            end;
        end;

        exit(false)
        //+MAG2.23 [371791]
    end;

    local procedure HasPostOnImportSetup(SalesLine: Record "Sales Line"): Boolean
    var
        MagentoPostonImportSetup: Record "Magento Post on Import Setup";
    begin
        //-MAG2.23 [373262]
        if SalesLine.Type = SalesLine.Type::" " then
          exit;

        exit(MagentoPostonImportSetup.Get(SalesLine.Type,SalesLine."No."));
        //+MAG2.23 [373262]
    end;

    local procedure ResetSalesLines(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        PrevRec: Text;
    begin
        //0MAG2.23 [371791]
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetFilter(Quantity,'<>%1',0);
        if SalesLine.FindSet then
          repeat
            PrevRec := Format(SalesLine);

            SalesLine.Validate("Qty. to Ship",0);
            SalesLine.Validate("Qty. to Invoice",0);

            if PrevRec <> Format(SalesLine) then
              SalesLine.Modify(true);
          until SalesLine.Next = 0;
        //+MAG2.23 [371791]
    end;

    local procedure MarkLinesForPosting(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        PrevRec: Text;
    begin
        //-MAG2.23 [371791]
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetFilter(Quantity,'<>%1',0);
        if SalesLine.FindSet then
          repeat
            if IsLineToPost(SalesLine) then begin
              PrevRec := Format(SalesLine);

              SalesLine.Validate("Qty. to Ship",SalesLine."Outstanding Quantity");

              if PrevRec <> Format(SalesLine) then
                SalesLine.Modify(true);
            end;
          until SalesLine.Next = 0;

        exit(false);
        //+MAG2.23 [371791]
    end;

    local procedure "--- Get/Check"()
    begin
    end;

    local procedure GetContactCustomer(ContactNo: Code[20];var Customer: Record Customer): Boolean
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        Initialize;
        Clear(Contact);

        if not Contact.Get(ContactNo) then
          exit(false);

        ContBusRel.SetRange("Contact No.",Contact."Company No.");
        ContBusRel.SetRange("Link to Table",ContBusRel."Link to Table"::Customer);
        ContBusRel.SetFilter("No.",'<>%1','');
        if not ContBusRel.FindFirst then
          exit(false);

        exit(Customer.Get(ContBusRel."No."));
    end;

    local procedure GetCustomer(ExternalCustomerNo: Code[20];XmlElement: DotNet npNetXmlElement;var Customer: Record Customer) Found: Boolean
    var
        CustNo: Code[20];
    begin
        //-MAG2.26 [401788]
        Clear(Customer);
        OnBeforeGetCustomer(CurrImportType,CurrImportEntry,ExternalCustomerNo,XmlElement,Customer,Found);
        if Found then
          exit(Customer.Find);
        //+MAG2.26 [401788]
        Initialize;
        Clear(Customer);
        //-MAG2.21 [355271]
        // Customer.SETRANGE("E-Mail",NpXmlDomMgt.GetXmlText(XmlElement,'email',MAXSTRLEN(Customer."E-Mail"),FALSE));
        // EXIT(Customer.FINDFIRST AND (Customer."E-Mail" <> ''));
        case MagentoSetup."Customer Mapping" of
          MagentoSetup."Customer Mapping"::"E-mail":
            begin
              Customer.SetRange("E-Mail",NpXmlDomMgt.GetXmlText(XmlElement,'email',MaxStrLen(Customer."E-Mail"),false));
              exit(Customer.FindFirst and (Customer."E-Mail" <> ''));
            end;
          MagentoSetup."Customer Mapping"::"Phone No.":
            begin
              Customer.SetRange("Phone No.",NpXmlDomMgt.GetXmlText(XmlElement,'phone',MaxStrLen(Customer."Phone No."),false));
              exit(Customer.FindFirst and (Customer."Phone No." <> ''));
            end;
          MagentoSetup."Customer Mapping"::"E-mail AND Phone No.":
            begin
              Customer.SetRange("E-Mail",NpXmlDomMgt.GetXmlText(XmlElement,'email',MaxStrLen(Customer."E-Mail"),false));
              Customer.SetRange("Phone No.",NpXmlDomMgt.GetXmlText(XmlElement,'phone',MaxStrLen(Customer."Phone No."),false));
              exit(Customer.FindFirst and (Customer."E-Mail" <> '') and (Customer."Phone No." <> ''));
            end;
          //-MAG2.22 [361705]
          MagentoSetup."Customer Mapping"::"E-mail OR Phone No.":
          //+MAG2.22 [361705]
            begin
              Customer.SetRange("E-Mail",NpXmlDomMgt.GetXmlText(XmlElement,'email',MaxStrLen(Customer."E-Mail"),false));
              if Customer.FindFirst and (Customer."E-Mail" <> '') then
                exit(true);

              Clear(Customer);
              Customer.SetRange("Phone No.",NpXmlDomMgt.GetXmlText(XmlElement,'phone',MaxStrLen(Customer."Phone No."),false));
              exit(Customer.FindFirst and (Customer."Phone No." <> ''));
            end;
          //-MAG2.22 [359754]
          MagentoSetup."Customer Mapping"::"Customer No.":
            begin
              CustNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'','customer_no',MaxStrLen(Customer."No."),false);
              if CustNo = '' then
                  exit(false);
              exit(Customer.Get(CustNo));
            end;
          //+MAG2.22 [359754]
          //-MAG2.24 [371807]
          MagentoSetup."Customer Mapping"::"Phone No. to Customer No.":
            begin
              CustNo := NpXmlDomMgt.GetXmlText(XmlElement,'phone',MaxStrLen(Customer."No."),false);
              if CustNo = '' then
                exit(false);

              exit(Customer.Get(CustNo));
            end;
          //+MAG2.24 [371807]
        end;

        exit(false);
        //+MAG2.21 [355271]
    end;

    local procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        //-MAG2.22 [359146]
        Initialize();

        if not MagentoSetup."Use Blank Code for LCY" then
            exit(CurrencyCode);

        GLSetup.Get;
        if GLSetup."LCY Code" = CurrencyCode then
          exit('');

        exit(CurrencyCode);
        //+MAG2.22 [359146]
    end;

    local procedure OrderExists(XmlElement: DotNet npNetXmlElement): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        OrderNo: Code[20];
    begin
        OrderNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'order_no',true);
        if OrderNo = '' then
          exit(true);

        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Order No.",CopyStr(OrderNo,1,MaxStrLen(SalesHeader."External Order No.")));
        if SalesHeader.FindFirst then
          exit(true);

        SalesInvHeader.SetRange("External Order No.",CopyStr(OrderNo,1,MaxStrLen(SalesInvHeader."External Order No.")));
        if SalesInvHeader.FindFirst then
          exit(true);

        exit(false);
    end;

    local procedure "--- Set"()
    begin
    end;

    local procedure InitCustomer(XmlElement: DotNet npNetXmlElement;var Cust: Record Customer)
    begin
        //-MAG2.24 [371807]
        Initialize();

        Cust.Init;
        Cust."No." := '';
        case MagentoSetup."Customer Mapping" of
          MagentoSetup."Customer Mapping"::"Customer No.":
            begin
              Cust."No." := NpXmlDomMgt.GetAttributeCode(XmlElement,'','customer_no',MaxStrLen(Cust."No."),false);
            end;
          MagentoSetup."Customer Mapping"::"Phone No. to Customer No.":
            begin
              Cust."No." := NpXmlDomMgt.GetXmlText(XmlElement,'phone',MaxStrLen(Cust."No."),false);
            end;
        end;
        //+MAG2.24 [371807]
    end;

    local procedure SetFieldText(var RecRef: RecordRef;FieldNo: Integer;Value: Text)
    var
        "Field": Record "Field";
        FieldObsolete: Record "Field";
        RecRefObsolete: RecordRef;
        FieldRef: FieldRef;
        FieldRefObsolete: FieldRef;
    begin
        if not Field.Get(RecRef.Number,FieldNo) then
          exit;

        //-MAG2.26 [402247]
        RecRefObsolete.GetTable(Field);
        if FieldObsolete.Get(RecRefObsolete.Number,25) then begin
          FieldRefObsolete := RecRefObsolete.Field(25);
          if Format(FieldRefObsolete.Value,0,2) <> '0' then
            exit;
        end;
        //+MAG2.26 [402247]
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Value := Value;
    end;

    local procedure "--- Misc"()
    begin
    end;

    procedure Initialize()
    begin
        if not Initialized then begin
          MagentoSetup.Get;
          Initialized := true;
        end;
    end;

    local procedure LoadXmlDoc(NaviConnectImportEntry: Record "Nc Import Entry";var XmlDoc: DotNet npNetXmlDocument): Boolean
    var
        InStr: InStream;
    begin
        NaviConnectImportEntry.CalcFields("Document Source");
        if not NaviConnectImportEntry."Document Source".HasValue then
          exit(false);

        NaviConnectImportEntry."Document Source".CreateInStream(InStr);
        if not IsNull(XmlDoc) then
          Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStr);
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        Clear(InStr);
        exit(true);
    end;

    local procedure ActivateAndMailGiftVouchers(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        MagentoGiftVoucherMgt: Codeunit "Magento Gift Voucher Mgt.";
    begin
        if not (MagentoSetup."Gift Voucher Activation" = MagentoSetup."Gift Voucher Activation"::OnInsert) then
          exit;
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
          exit;
        MagentoGiftVoucherMgt.ActivateAndMailGiftVouchers(SalesHeader."External Order No.",Customer."E-Mail");
    end;

    local procedure TranslateBarcodeToItemVariant(Barcode: Text[50];var ItemNo: Code[20];var VariantCode: Code[10];var ResolvingTable: Integer) Found: Boolean
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemVariant: Record "Item Variant";
        GenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        ResolvingTable := 0;
        ItemNo := '';
        VariantCode := '';
        if (Barcode = '') then exit (false);

        // Try Item Table
        if (StrLen (Barcode) <= MaxStrLen (Item."No.")) then begin
          if (Item.Get (UpperCase(Barcode))) then begin
            ResolvingTable := DATABASE::Item;
            ItemNo := Item."No.";
            exit (true);
          end;
        end;

        // Try Item Cross Reference
        with ItemCrossReference do begin
          if (StrLen (Barcode) <= MaxStrLen ("Cross-Reference No.")) then begin
            SetCurrentKey ("Cross-Reference Type", "Cross-Reference No.");
            SetFilter ("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
            SetFilter ("Cross-Reference No.", '=%1', UpperCase (Barcode));
            SetFilter ("Discontinue Bar Code", '=%1', false);
            if (FindFirst ()) then begin
              ResolvingTable := DATABASE::"Item Cross Reference";
              ItemNo := "Item No.";
              VariantCode := "Variant Code";
              exit (true);
            end;
          end;
        end;

        // Try Alternative No
        if not GenericSetupMgt.OpenRecRef(6014416,RecRef) then
          exit(false);

        if not GenericSetupMgt.OpenFieldRef(RecRef,2,FieldRef) then
          exit(false);
        if StrLen(Barcode) > FieldRef.Length then
          exit(false);
        FieldRef.SetFilter('=%1', UpperCase (Barcode));

        if not GenericSetupMgt.OpenFieldRef(RecRef,4,FieldRef) then
          exit(false);
        FieldRef.SetFilter('=%1',0);

        if not RecRef.FindFirst then
          exit(false);

        if not GenericSetupMgt.OpenFieldRef(RecRef,1,FieldRef) then
          exit(false);

        if not Item.Get(CopyStr(UpperCase(Format(FieldRef.Value)),1,MaxStrLen(Item."No."))) then
          exit (false);

        if GenericSetupMgt.OpenFieldRef(RecRef,6,FieldRef) then begin
          if (Format(FieldRef.Value) <> '') and (not ItemVariant.Get(Item."No.",CopyStr(UpperCase(Format(FieldRef.Value)),1,MaxStrLen(ItemVariant.Code)))) then
              exit(false);
        end;

        ResolvingTable := DATABASE::"Alternative No.";
        ItemNo := Item."No.";
        VariantCode := ItemVariant.Code;
        exit(true);
    end;

    local procedure GetDate(Date1: Date;Date2: Date): Date
    begin
        //-MAG2.23 [367219]
        if Date1 <> 0D then
          exit(Date1);
        if Date2 <> 0D then
          exit(Date2);
        exit(WorkDate);
        //+MAG2.23 [367219]
    end;

    local procedure "--- OnAfterEvents"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCustomer(ImportType: Record "Nc Import Type";ImportEntry: Record "Nc Import Entry";ExternalCustomerNo: Code[20];Element: DotNet npNetXmlElement;var Customer: Record Customer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyCustomer(ImportType: Record "Nc Import Type";ImportEntry: Record "Nc Import Entry";Element: DotNet npNetXmlElement;var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesHeader(ImportType: Record "Nc Import Type";ImportEntry: Record "Nc Import Entry";Element: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesLine(ImportType: Record "Nc Import Type";ImportEntry: Record "Nc Import Entry";Element: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header";var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertCommentLine(ImportType: Record "Nc Import Type";ImportEntry: Record "Nc Import Entry";Element: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header";var RecordLink: Record "Record Link")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRelease(ImportType: Record "Nc Import Type";ImportEntry: Record "Nc Import Entry";Element: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCommit(ImportType: Record "Nc Import Type";ImportEntry: Record "Nc Import Entry";Element: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    begin
    end;
}

