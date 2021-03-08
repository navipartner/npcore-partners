codeunit 85008 "NPR E-Commerce Tests"
{
    // // [Feature] E-Commerce import sales and purchase documents
    Subtype = Test;

    trigger OnRun()
    begin
        Initialized := false;
    end;

    var
        Initialized: Boolean;
        ItemNo, ItemNo2, SalesOrderNo, StoreCode, PostCode, GLAccountNo, PurchInvoiceNo, VendorNo : Code[20];
        MagentoPaymentCode, MagentoPaymentCode2, TransactionId, TransactionId2 : Code[50];
        ItemDesc, ItemDesc2, EMail, City, ExternalShipmentMethodCode, GLAccName, Comment : Text;
        VendorInvoiceNo: Code[35];
        Qty, Qty2, UnitPrice, UnitPrice2, UnitPrice3, UnitPrice4, PymAmount1, PymAmount2 : Decimal;
        XmlSales, XmlPurch : TextBuilder;

    [Test]
    procedure CreateSalesOrderWithoutSellToCustomerXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when sell_to_customer is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without sell_to_customer tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/sell_to_customer', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutSellToCustomerNameXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when sell_to_customer name is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../sell_to_customer/name tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/sell_to_customer/name', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutSellToCustomerAddressXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when sell_to_customer address is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../sell_to_customer/address tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/sell_to_customer/address', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutSellToCustomerPostCodeXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when sell_to_customer post code is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../sell_to_customer/post_code tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/sell_to_customer/post_code', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutSellToCustomerCityXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when sell_to_customer city is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../sell_to_customer/city tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/sell_to_customer/city', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutSellToCustomerEMailXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when sell_to_customer email is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../sell_to_customer/email tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/sell_to_customer/email', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutPricesInclVATXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when prices including vat is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../prices_incl_vat tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/prices_incl_vat', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutCurrencyCodeXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when currency code is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../currency_code tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/currency_code', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutShipToCustomerNameXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when ship_to_customer name is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../ship_to_customer/name tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/ship_to_customer/name', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutShipToCustomerAddressXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when ship_to_customer address is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../ship_to_customer/address tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/ship_to_customer/address', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutShipToCustomerPostCodeXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when ship_to_customer post code is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../ship_to_customer/post_code tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/ship_to_customer/post_code', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutShipToCustomerCityXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when ship_to_customer city is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../ship_to_customer/city tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/ship_to_customer/city', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutOrderDateXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when order date is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../order_date tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/order_date', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutPaymentMethodCodeXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when payment found in xml but without payment method code

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../payments/payment/@code tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/payments/payment[last()]/@code', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;


    [Test]
    procedure CreateSalesOrderWithoutPaymentTransactionIdXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when payment found in xml but without transaction id

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../payments/payment/transaction_id tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/payments/payment[last()]/transaction_id', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutPaymentAmountXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when payment found in xml but without payment amount

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../payments/payment/amount tag
        LoadXmlAndRemoveElement('/sales_orders/sales_order/payments/payment[last()]/amount', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutItemReferenceNoXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when reference is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../@reference_no in item
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''item'']//@reference_no', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutItemUnitPriceXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when unit price is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../unit_price in item
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''item'']//unit_price', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutItemQtyXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when quantity is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../quantity in item
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''item'']//quantity', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutItemLineAmountXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when line amount is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../line_amount in item
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''item'']//line_amount', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutItemDescriptionXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when description is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../description in item
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''item'']//description', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutItemDescription2XmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when description 2 is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../description_2 in item
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''item'']//description_2', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutItemVATPctXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when vat percent is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../vat_percent in item
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''item'']//vat_percent', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutGLAccReferenceNoXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when reference is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../@reference_no in g/l account
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''gl_account'']//@reference_no', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutGLAccUnitPriceXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when unit price is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../unit_price in gl_account
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''gl_account'']//unit_price', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutGLAccQtyXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when quantity is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../quantity in g/l account
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''gl_account'']//quantity', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutGLAccLineAmountXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when line amount is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../line_amount in g/l account
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''gl_account'']//line_amount', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutGLAccDescriptionXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when description is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../description in g/l account
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''gl_account'']//description', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutGLAccDescription2XmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when description 2 is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../description_2 in g/l account
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''gl_account'']//description_2', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutCommentDescriptionXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when description is not found in loaded document for comment type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../description in comment
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''comment'']//description', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrderWithoutCommentDescription2XmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when description 2 is not found in loaded document for comment type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);

        // [When] Load xml without ../description_2 in comment
        LoadXmlAndRemoveElements('/sales_orders/sales_order/sales_order_lines/sales_order_line[@type=''comment'']//description_2', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreateSalesOrder()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        GLAcc: Record "G/L Account";
        Customer: Record Customer;
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        EcStore: Record "NPR NpEc Store";
        EcDocument: Record "NPR NpEc Document";
        PaymentLine: Record "NPR Magento Payment Line";
        RecordLink: Record "Record Link";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
        Assert: Codeunit Assert;
        ShipmentFeeAccNo: Code[20];
    begin
        // [Scenario] Load sales order

        // [Given] Xml document
        Initialize();

        // [Given] Remove sales order with external document no.
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Document No.", SalesOrderNo);
        if not SalesHeader.IsEmpty() then
            SalesHeader.DeleteAll(true);

        // [Given] Remove E-Commerce Order
        EcDocument.SetRange("Store Code", StoreCode);
        EcDocument.SetRange("Reference No.", SalesOrderNo);
        EcDocument.SetRange("Document Type", EcDocument."Document Type"::"Sales Order");
        if not EcDocument.IsEmpty() then
            EcDocument.DeleteAll(true);

        // [Given] Remove Magento Payment Lines
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesOrderNo);
        if not PaymentLine.IsEmpty() then
            PaymentLine.DeleteAll(true);

        // [Given] Remove Note
        RecordLink.SetRange("Record ID", SalesHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        if not RecordLink.IsEmpty() then
            RecordLink.DeleteAll(true);

        // [Given] Load xml with NaviConnect
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);
        LoadXml(ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [When] Create sales order
        EcWebService.ProcessImportEntry(ImportEntry);
        Commit();

        // [Then] Verify Sales Order created
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Document No.", SalesOrderNo);
        Assert.IsTrue(SalesHeader.FindFirst(), StrSubstNo('Sales order not created with %1: %2', Salesheader.FieldCaption("External Document No."), SalesOrderNo));

        // Verify imported customer is assigned to sales order
        Customer.SetRange("E-Mail", EMail);
        Assert.IsTrue(Customer.FindFirst(), StrSubstNo('Customer with %1: %2, not found', Customer.FieldCaption("E-Mail"), EMail));
        Assert.AreEqual(SalesHeader."Sell-to Customer No.", Customer."No.", 'Wrong customer assigned to order.');

        // Verify number of items imported to sales order
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        Assert.AreEqual(2, SalesLine.Count(), 'Expected item lines on sales document');

        // Verfiy sales order line details imported to sales order for first item
        EcStore.Code := StoreCode;
        EcStore.Find();

        SalesLine.SetRange("No.", ItemNo);
        Assert.IsTrue(SalesLine.FindFirst(), StrSubstNo('Expected %1:%2', Item.Tablecaption(), ItemNo));
        Assert.AreEqual(Qty, SalesLine.Quantity, 'Wrong quantity');
        Assert.AreEqual(UnitPrice, SalesLine."Unit Price", 'Wrong unit price');
        Assert.AreEqual(Round(Qty * UnitPrice), SalesLine."Line Amount", 'Wrong line amount');
        Assert.AreEqual(EcStore."Location Code", SalesLine."Location Code", 'Wrong location');

        // Verify imported description is assigned to sales order line for first item
        Item.Get(ItemNo);
        Assert.AreNotEqual(Item.Description, SalesLine.Description, 'Wrong description');

        // Verfiy sales order line details imported to sales order for second item
        SalesLine.SetRange("No.", ItemNo2);
        Assert.IsTrue(SalesLine.FindFirst(), StrSubstNo('Expected %1:%2', Item.Tablecaption(), ItemNo2));
        Assert.AreEqual(Qty2, SalesLine.Quantity, 'Wrong quantity');
        Assert.AreEqual(UnitPrice2, SalesLine."Unit Price", 'Wrong unit price');
        Assert.AreEqual(Round(Qty2 * UnitPrice2), SalesLine."Line Amount", 'Wrong line amount');
        Assert.AreEqual(EcStore."Location Code", SalesLine."Location Code", 'Wrong location');

        // Verify imported description is assigned to sales order line for second item
        Item.Get(ItemNo2);
        Assert.AreNotEqual(Item.Description, SalesLine.Description, 'Wrong description');

        // Verify number of g/l accounts imported to sales order
        SalesLine.SetRange(Type);
        SalesLine.SetRange("No.");
        SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
        Assert.AreEqual(2, SalesLine.Count(), 'Expected g/l accounts on sales document');

        // Verfiy sales order line details imported to sales order for g/l account
        SalesLine.SetRange("No.", GLAccountNo);
        Assert.IsTrue(SalesLine.FindFirst(), StrSubstNo('Expected %1:%2', GLAcc.Tablecaption(), GLAccountNo));
        Assert.AreEqual(1, SalesLine.Quantity, 'Wrong quantity');
        Assert.AreEqual(UnitPrice3, SalesLine."Unit Price", 'Wrong unit price');
        Assert.AreEqual(Round(UnitPrice3 * SalesLine.Quantity), SalesLine."Line Amount", 'Wrong line amount');

        // Verify imported description is assigned to sales order line for g/l account
        GLAcc.Get(GLAccountNo);
        Assert.AreNotEqual(GLAcc.Name, SalesLine.Description, 'Wrong description');

        ShipmentMapping.SetRange("External Shipment Method Code", ExternalShipmentMethodCode);
        ShipmentMapping.FindFirst();
        ShipmentFeeAccNo := ShipmentMapping."Shipment Fee No.";

        // Verfiy sales order line details imported to sales order for shipment fee g/l account no.
        SalesLine.SetRange("No.", ShipmentFeeAccNo);
        Assert.IsTrue(SalesLine.FindFirst(), StrSubstNo('Expected %1:%2', GLAcc.Tablecaption(), ShipmentFeeAccNo));
        Assert.AreEqual(1, SalesLine.Quantity, 'Wrong quantity');
        Assert.AreEqual(UnitPrice4, SalesLine."Unit Price", 'Wrong unit price');
        Assert.AreEqual(Round(UnitPrice4 * SalesLine.Quantity), SalesLine."Line Amount", 'Wrong line amount');

        // Verify number of comments imported to sales order
        SalesLine.SetRange(Type);
        SalesLine.SetRange("No.");
        SalesLine.SetRange(Type, SalesLine.Type::" ");
        Assert.AreEqual(1, SalesLine.Count(), 'Expected comment on sales document line');

        // Verify comment is imported to sales order line
        SalesLine.SetRange(Description, Comment);
        Assert.IsTrue(not SalesLine.IsEmpty(), StrSubstNo('Expected comment %1', Comment));

        // Verify number of payment lines imported and attached to sales order
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        Assert.AreEqual(2, PaymentLine.Count(), 'Expected payment lines attached to sales order');

        // Verfiy payment line details for first payment
        PaymentLine.SetRange("No.", TransactionId);
        Assert.IsTrue(PaymentLine.FindFirst(), StrSubstNo('Expected %1 with transaction id %2', PaymentLine.Tablecaption(), TransactionId));
        Assert.AreEqual(Round(PymAmount1), Round(PaymentLine.Amount), 'Wrong payment line amount');

        // Verfiy payment line details for second payment
        PaymentLine.SetRange("No.", TransactionId2);
        Assert.IsTrue(PaymentLine.FindFirst(), StrSubstNo('Expected %1 with transaction id %2', PaymentLine.Tablecaption(), TransactionId2));
        Assert.AreEqual(Round(PymAmount2), Round(PaymentLine.Amount), 'Wrong payment line amount');

        // Verify note imported and attached to sales order
        RecordLink.SetRange("Record ID", SalesHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        Assert.IsTrue(not RecordLink.IsEmpty(), 'Expected note attached to sales order');
    end;

    [Test]
    procedure DeleteSalesOrder()
    var
        ImportEntryCreateDoc: Record "NPR NC Import Entry";
        ImportEntryDeleteDoc: Record "NPR NC Import Entry";
        ImportTypeCreateDoc: Record "NPR Nc Import Type";
        ImportTypeDeleteDoc: Record "NPR Nc Import Type";
        SalesHeader: Record "Sales Header";
        EcDocument: Record "NPR NpEc Document";
        PaymentLine: Record "NPR Magento Payment Line";
        RecordLink: Record "Record Link";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
        Assert: Codeunit Assert;
    begin
        // [Scenario] Delete sales order

        // [Given] Xml document
        Initialize();

        // [Given] Remove sales order with external document no.
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Document No.", SalesOrderNo);
        if not SalesHeader.IsEmpty() then
            SalesHeader.DeleteAll(true);

        // [Given] Remove E-Commerce Order
        EcDocument.SetRange("Store Code", StoreCode);
        EcDocument.SetRange("Reference No.", SalesOrderNo);
        EcDocument.SetRange("Document Type", EcDocument."Document Type"::"Sales Order");
        if not EcDocument.IsEmpty() then
            EcDocument.DeleteAll(true);

        // [Given] Remove Magento Payment Lines
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesOrderNo);
        if not PaymentLine.IsEmpty() then
            PaymentLine.DeleteAll(true);

        // [Given] Remove Note
        RecordLink.SetRange("Record ID", SalesHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        if not RecordLink.IsEmpty() then
            RecordLink.DeleteAll(true);

        // [Given] Load xml with NaviConnect for creating order
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportTypeCreateDoc);
        LoadXml(ImportTypeCreateDoc, ImportEntryCreateDoc, SalesOrderNo + '.xml', XmlSales);

        // [Given] Create sales order
        EcWebService.ProcessImportEntry(ImportEntryCreateDoc);
        Commit();

        // [Given] Load xml with NaviConnect for deleting
        LibraryECommerce.InitImportTypeDeleteSalesOrder(ImportTypeDeleteDoc);
        LoadXml(ImportTypeDeleteDoc, ImportEntryDeleteDoc, SalesOrderNo + '.xml', XmlSales);

        // [When] Import and create sales order 
        EcWebService.ProcessImportEntry(ImportEntryDeleteDoc);
        Commit();

        // [Then] Verify Sales Order deleted
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Document No.", SalesOrderNo);
        Assert.IsTrue(SalesHeader.IsEmpty(), StrSubstNo('Sales order not deleted for %1: %2', Salesheader.FieldCaption("External Document No."), SalesOrderNo));

        // Verify Ec Document not found
        EcDocument.SetRange("Store Code", StoreCode);
        EcDocument.SetRange("Reference No.", SalesOrderNo);
        EcDocument.SetRange("Document Type", EcDocument."Document Type"::"Sales Order");
        Assert.IsTrue(EcDocument.IsEmpty(), StrSubstNo('Ec document not deleted for %1: %2', EcDocument.FieldCaption("Reference No."), SalesOrderNo));

        // Verify Payment Line not found
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        Assert.IsTrue(PaymentLine.IsEmpty(), StrSubstNo('Payment Lines not deleted for %1: %2', PaymentLine.FieldCaption("Document No."), SalesOrderNo));

        // Verify Note not found
        RecordLink.SetRange("Record ID", SalesHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        Assert.IsTrue(EcDocument.IsEmpty(), StrSubstNo('Ec document not deleted for %1: %2', RecordLink.FieldCaption("Record ID"), SalesHeader.RecordId()));
    end;

    [Test]
    procedure UpdateAndPostSalesOrder()
    var
        ImportEntryCreateDoc: Record "NPR NC Import Entry";
        ImportEntryPostDoc: Record "NPR NC Import Entry";
        ImportTypeCreateDoc: Record "NPR Nc Import Type";
        ImportTypePostDoc: Record "NPR Nc Import Type";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesSetup: Record "Sales & Receivables Setup";
        EcDocument: Record "NPR NpEc Document";
        PaymentLine: Record "NPR Magento Payment Line";
        RecordLink: Record "Record Link";
        EcStore: Record "NPR NpEc Store";
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
        Assert: Codeunit Assert;
        FM: Codeunit "File Management";
    begin
        // [Scenario] Create, update and post sales order

        // [Given] Xml document
        Initialize();

        // [Given] Remove sales order with external document no.
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Document No.", SalesOrderNo);
        if not SalesHeader.IsEmpty() then
            SalesHeader.DeleteAll(true);

        // [Given] Remove Magento Payment Lines
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesOrderNo);
        if not PaymentLine.IsEmpty() then
            PaymentLine.DeleteAll(true);

        // [Given] Remove Note
        RecordLink.SetRange("Record ID", SalesHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        if not RecordLink.IsEmpty() then
            RecordLink.DeleteAll(true);

        // [Given] Remove E-Commerce Order
        EcDocument.SetRange("Store Code", StoreCode);
        EcDocument.SetRange("Reference No.", SalesOrderNo);
        EcDocument.SetRange("Document Type", EcDocument."Document Type"::"Sales Order");
        if not EcDocument.IsEmpty() then
            EcDocument.DeleteAll(true);

        EcDocument.SetRange("Document Type", EcDocument."Document Type"::"Posted Sales Invoice");
        if not EcDocument.IsEmpty() then
            EcDocument.DeleteAll(true);

        // [Given] Remove All Posted Sales Invoice
        SalesInvHeader.SetRange("External Document No.", SalesOrderNo);
        if SalesInvHeader.FindSet() then begin
            SalesSetup.Get();
            SalesSetup."Allow Document Deletion Before" := WorkDate() + 1;
            SalesSetup.Modify();
            repeat
                SalesInvHeader."No. Printed" := 1;
                SalesInvHeader.Delete(true);
            until SalesInvHeader.Next() = 0;
        end;

        // [Given] Remove all E-Mail Template Headers to silently prevent sending e-mail
        EmailTemplateHeader.DeleteAll();

        // [Given] Increase inventory for imported items
        EcStore.Code := StoreCode;
        EcStore.Find();
        LibraryECommerce.IncreaseItemInventoryOnLocation(ItemNo, Qty, EcStore."Location Code");
        LibraryECommerce.IncreaseItemInventoryOnLocation(ItemNo2, Qty2, EcStore."Location Code");

        // [Given] Load xml with NaviConnect for creating order
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportTypeCreateDoc);
        LoadXml(ImportTypeCreateDoc, ImportEntryCreateDoc, SalesOrderNo + '.xml', XmlSales);

        // [Given] Create sales order
        EcWebService.ProcessImportEntry(ImportEntryCreateDoc);
        Commit();

        // [Given] Load xml with NaviConnect for posting
        LibraryECommerce.InitImportTypePostSalesOrder(ImportTypePostDoc);
        LoadXml(ImportTypePostDoc, ImportEntryPostDoc, SalesOrderNo + '.xml', XmlSales);

        // [When] Import and post sales order 
        EcWebService.ProcessImportEntry(ImportEntryPostDoc);
        Commit();

        // [Then] Verify Sales Order posted
        SalesInvHeader.Reset();
        SalesInvHeader.SetRange("External Document No.", SalesOrderNo);
        Assert.IsTrue(SalesInvHeader.FindFirst(), StrSubstNo('Sales Order not posted with %1:%2', SalesInvHeader.FieldCaption("External Document No."), SalesOrderNo));
    end;

    [Test]
    procedure CreateAndPostSalesOrder()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        EcDocument: Record "NPR NpEc Document";
        PaymentLine: Record "NPR Magento Payment Line";
        RecordLink: Record "Record Link";
        EcStore: Record "NPR NpEc Store";
        SalesSetup: Record "Sales & Receivables Setup";
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
        Assert: Codeunit Assert;
    begin
        // [Scenario] Create and post sales order in one transaction

        // [Given] Xml document
        Initialize();

        // [Given] Remove sales order with external document no.
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Document No.", SalesOrderNo);
        if not SalesHeader.IsEmpty() then
            SalesHeader.DeleteAll(true);

        // [Given] Remove Magento Payment Lines
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesOrderNo);
        if not PaymentLine.IsEmpty() then
            PaymentLine.DeleteAll(true);

        // [Given] Remove Note
        RecordLink.SetRange("Record ID", SalesHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        if not RecordLink.IsEmpty() then
            RecordLink.DeleteAll(true);

        // [Given] Remove E-Commerce Order
        EcDocument.SetRange("Store Code", StoreCode);
        EcDocument.SetRange("Reference No.", SalesOrderNo);
        EcDocument.SetRange("Document Type", EcDocument."Document Type"::"Sales Order");
        if not EcDocument.IsEmpty() then
            EcDocument.DeleteAll(true);

        EcDocument.SetRange("Document Type", EcDocument."Document Type"::"Posted Sales Invoice");
        if not EcDocument.IsEmpty() then
            EcDocument.DeleteAll(true);

        // [Given] Remove Posted Sales Invoice 
        SalesInvHeader.SetRange("Order No.", SalesOrderNo);
        if SalesInvHeader.FindSet() then begin
            SalesSetup.Get();
            SalesSetup."Allow Document Deletion Before" := WorkDate() + 1;
            SalesSetup.Modify();
            repeat
                SalesInvHeader."No. Printed" := 1;
                SalesInvHeader.Delete(true);
            until SalesInvHeader.Next() = 0;
        end;

        // [Given] Remove all E-Mail Template Headers to silently prevent sending e-mail
        EmailTemplateHeader.DeleteAll();

        // [Given] Increase inventory for imported items
        EcStore.Code := StoreCode;
        EcStore.Find();
        LibraryECommerce.IncreaseItemInventoryOnLocation(ItemNo, Qty, EcStore."Location Code");
        LibraryECommerce.IncreaseItemInventoryOnLocation(ItemNo2, Qty2, EcStore."Location Code");

        // [Given] Load xml with NaviConnect for creating and posting
        LibraryECommerce.InitImportTypePostSalesOrder(ImportType);
        LoadXml(ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [When] Import and post sales order 
        EcWebService.ProcessImportEntry(ImportEntry);
        Commit();

        // [Then] Verify Sales Order posted
        SalesInvHeader.Reset();
        SalesInvHeader.SetRange("External Document No.", SalesOrderNo);
        Assert.IsTrue(SalesInvHeader.FindFirst(), StrSubstNo('Sales Order not posted with %1:%2', SalesInvHeader.FieldCaption("External Document No."), SalesOrderNo));
    end;

    [Test]
    [HandlerFunctions('OpenSalesOrder')]
    procedure LookupSalesOrder()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        SalesHeader: Record "Sales Header";
        EcDocument: Record "NPR NpEc Document";
        PaymentLine: Record "NPR Magento Payment Line";
        RecordLink: Record "Record Link";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
        Assert: Codeunit Assert;
    begin
        // [Scenario] Lookup sales order

        // [Given] Xml document
        Initialize();

        // [Given] Remove sales order with external document no.
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Document No.", SalesOrderNo);
        if not SalesHeader.IsEmpty() then
            SalesHeader.DeleteAll(true);

        // [Given] Remove E-Commerce Order
        EcDocument.SetRange("Store Code", StoreCode);
        EcDocument.SetRange("Reference No.", SalesOrderNo);
        EcDocument.SetRange("Document Type", EcDocument."Document Type"::"Sales Order");
        if not EcDocument.IsEmpty() then
            EcDocument.DeleteAll(true);

        // [Given] Remove Magento Payment Lines
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesOrderNo);
        if not PaymentLine.IsEmpty() then
            PaymentLine.DeleteAll(true);

        // [Given] Remove Note
        RecordLink.SetRange("Record ID", SalesHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        if not RecordLink.IsEmpty() then
            RecordLink.DeleteAll(true);

        // [Given] Load xml with NaviConnect
        LibraryECommerce.InitImportTypeCreateSalesOrder(ImportType);
        LoadXml(ImportType, ImportEntry, SalesOrderNo + '.xml', XmlSales);

        // [Given] Create sales order
        EcWebService.ProcessImportEntry(ImportEntry);
        Commit();

        // [When] Lookup sales order
        Codeunit.Run(ImportType."Lookup Codeunit ID", ImportEntry);

        // [Then] Handle sales order page
    end;

    [Test]
    procedure CreatePurchInvWithoutBuyFromVendorXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when buy_from_vendor is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without buy_from_vendor tag
        LoadXmlAndRemoveElement('/purchase_invoices/purchase_invoice/buy_from_vendor', ImportType, ImportEntry, PurchInvoiceNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutPostingDateXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when posting_date is not found in loaded xml document

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../posting_date tag
        LoadXmlAndRemoveElement('/purchase_invoices/purchase_invoice/posting_date', ImportType, ImportEntry, PurchInvoiceNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutItemReferenceNoXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when reference is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../@reference_no in item
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''item'']//@reference_no', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutItemDirectUnitCostXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when direct unit cost is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../direct_unit_cost in item
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''item'']//direct_unit_cost', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutItemQtyXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when quantity is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../quantity in item
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''item'']//quantity', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutItemLineAmountXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when line amount is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../line_amount in item
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''item'']//line_amount', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutItemVATPctXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when vat percent is not found in loaded document for item type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../vat_percent in item
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''item'']//vat_percent', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutGLAccReferenceNoXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when reference is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../@reference_no in g/l account
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''gl_account'']//@reference_no', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutGLAccDirectUnitCostXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when unit price is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../direct_unit_cost in gl_account
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''gl_account'']//direct_unit_cost', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutGLAccQtyXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when quantity is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../quantity in g/l account
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''gl_account'']//quantity', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutGLAccLineAmountXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when line amount is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../line_amount in g/l account
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''gl_account'']//line_amount', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvWithoutGLAccDescriptionXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when description is not found in loaded document for g/l account type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../description in g/l account
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''gl_account'']//description', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;


    [Test]
    procedure CreatePurchInvWithoutCommentDescriptionXmlTagErr()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        // [Scenario] Handle error when description is not found in loaded document for comment type 

        // [Given] Xml document
        Initialize();

        // [Given] Nc Import Type
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);

        // [When] Load xml without ../description in comment
        LoadXmlAndRemoveElements('/purchase_invoices/purchase_invoice/purchase_invoice_lines/purchase_invoice_line[@type=''comment'']//description', ImportType, ImportEntry, SalesOrderNo + '.xml', XmlPurch);

        // [Then] Expected error
        asserterror EcWebService.ProcessImportEntry(ImportEntry);
    end;

    [Test]
    procedure CreatePurchInvoice()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        GLAcc: Record "G/L Account";
        Vendor: Record Vendor;
        EcStore: Record "NPR NpEc Store";
        EcDocument: Record "NPR NpEc Document";
        RecordLink: Record "Record Link";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
        Assert: Codeunit Assert;
    begin
        // [Scenario] Load purchase invoice

        // [Given] Xml document
        Initialize();

        // [Given] Remove purchase invoice with vendor invoice no.
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SetRange("Vendor Invoice No.", VendorInvoiceNo);
        if not PurchaseHeader.IsEmpty() then
            PurchaseHeader.DeleteAll(true);

        // [Given] Remove E-Commerce Invoice
        EcDocument.SetRange("Store Code", StoreCode);
        EcDocument.SetRange("Reference No.", PurchInvoiceNo);
        EcDocument.SetRange("Document Type", EcDocument."Document Type"::"Purchase Invoice");
        if not EcDocument.IsEmpty() then
            EcDocument.DeleteAll(true);

        // [Given] Remove Note
        RecordLink.SetRange("Record ID", PurchaseHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        if not RecordLink.IsEmpty() then
            RecordLink.DeleteAll(true);

        // [Given] Load xml with NaviConnect
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);
        LoadXml(ImportType, ImportEntry, PurchInvoiceNo + '.xml', XmlPurch);

        // [When] Create sales order
        EcWebService.ProcessImportEntry(ImportEntry);
        Commit();

        // [Then] Verify Sales Order created
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SetRange("Vendor Invoice No.", VendorInvoiceNo);
        Assert.IsTrue(PurchaseHeader.FindFirst(), StrSubstNo('Purchase invoice not created with %1: %2', PurchaseHeader.FieldCaption("Vendor Invoice No."), VendorInvoiceNo));

        // Verify imported vendor is assigned to purchase invoice
        Vendor."No." := VendorNo;
        Assert.IsTrue(Vendor.Find(), StrSubstNo('Vendor with %1: %2, not found', Vendor.FieldCaption("No."), VendorNo));
        Assert.AreEqual(PurchaseHeader."Buy-from Vendor No.", Vendor."No.", 'Wrong vendor assigned to invoice.');

        // Verify number of items imported to purchase invoice
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        Assert.AreEqual(2, PurchaseLine.Count(), 'Expected item lines on purchase document');

        // Verfiy purchase invoice line details imported to purchase invoice for first item
        EcStore.Code := StoreCode;
        EcStore.Find();

        PurchaseLine.SetRange("No.", ItemNo);
        Assert.IsTrue(PurchaseLine.FindFirst(), StrSubstNo('Expected %1:%2', Item.Tablecaption(), ItemNo));
        Assert.AreEqual(Qty, PurchaseLine.Quantity, 'Wrong quantity');
        Assert.AreEqual(UnitPrice, PurchaseLine."Direct Unit Cost", 'Wrong direct unit cose');
        Assert.AreEqual(Round(Qty * UnitPrice), PurchaseLine."Line Amount", 'Wrong line amount');
        Assert.AreEqual(EcStore."Location Code", PurchaseLine."Location Code", 'Wrong location');

        // Verfiy purchase invoice line details imported to purchase invoice for second item
        PurchaseLine.SetRange("No.", ItemNo2);
        Assert.IsTrue(PurchaseLine.FindFirst(), StrSubstNo('Expected %1:%2', Item.Tablecaption(), ItemNo2));
        Assert.AreEqual(Qty2, PurchaseLine.Quantity, 'Wrong quantity');
        Assert.AreEqual(UnitPrice2, PurchaseLine."Direct Unit Cost", 'Wrong direct unit cost');
        Assert.AreEqual(Round(Qty2 * UnitPrice2), PurchaseLine."Line Amount", 'Wrong line amount');
        Assert.AreEqual(EcStore."Location Code", PurchaseLine."Location Code", 'Wrong location');

        // Verify number of g/l accounts imported to sales order
        PurchaseLine.SetRange(Type);
        PurchaseLine.SetRange("No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::"G/L Account");
        Assert.AreEqual(1, PurchaseLine.Count(), 'Expected g/l accounts on purchase document');

        // Verfiy purchase invoice line details imported to purchase invoice for g/l account
        PurchaseLine.SetRange("No.", GLAccountNo);
        Assert.IsTrue(PurchaseLine.FindFirst(), StrSubstNo('Expected %1:%2', GLAcc.Tablecaption(), GLAccountNo));
        Assert.AreEqual(1, PurchaseLine.Quantity, 'Wrong quantity');
        Assert.AreEqual(UnitPrice3, PurchaseLine."Direct Unit Cost", 'Wrong direct unit cost');
        Assert.AreEqual(Round(UnitPrice3 * PurchaseLine.Quantity), PurchaseLine."Line Amount", 'Wrong line amount');

        // Verify imported description is assigned to sales order line for g/l account
        GLAcc.Get(GLAccountNo);
        Assert.AreNotEqual(GLAcc.Name, PurchaseLine.Description, 'Wrong description');

        // Verify number of comments imported to purchase invoice
        PurchaseLine.SetRange(Type);
        PurchaseLine.SetRange("No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::" ");
        Assert.AreEqual(1, PurchaseLine.Count(), 'Expected comment on purchase document line');

        // Verify comment is imported to purchase invoice line
        PurchaseLine.SetRange(Description, Comment);
        Assert.IsTrue(not PurchaseLine.IsEmpty(), StrSubstNo('Expected comment %1', Comment));

        // Verify note imported and attached to purchase invoice
        RecordLink.SetRange("Record ID", PurchaseHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        Assert.IsTrue(not RecordLink.IsEmpty(), 'Expected note attached to purchase invoice');
    end;

    [Test]
    [HandlerFunctions('OpenPurchaseInvoice')]
    procedure LookupPurchInvoice()
    var
        ImportEntry: Record "NPR NC Import Entry";
        ImportType: Record "NPR Nc Import Type";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        GLAcc: Record "G/L Account";
        Vendor: Record Vendor;
        EcStore: Record "NPR NpEc Store";
        EcDocument: Record "NPR NpEc Document";
        RecordLink: Record "Record Link";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        EcWebService: codeunit "NPR NpEc Webservice";
        Assert: Codeunit Assert;
    begin
        // [Scenario] Load purchase invoice

        // [Given] Xml document
        Initialize();

        // [Given] Remove purchase invoice with vendor invoice no.
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SetRange("Vendor Invoice No.", VendorInvoiceNo);
        if not PurchaseHeader.IsEmpty() then
            PurchaseHeader.DeleteAll(true);

        // [Given] Remove E-Commerce Invoice
        EcDocument.SetRange("Store Code", StoreCode);
        EcDocument.SetRange("Reference No.", PurchInvoiceNo);
        EcDocument.SetRange("Document Type", EcDocument."Document Type"::"Purchase Invoice");
        if not EcDocument.IsEmpty() then
            EcDocument.DeleteAll(true);

        // [Given] Remove Note
        RecordLink.SetRange("Record ID", PurchaseHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        if not RecordLink.IsEmpty() then
            RecordLink.DeleteAll(true);

        // [Given] Load xml with NaviConnect
        LibraryECommerce.InitImportTypeCreatePurchInv(ImportType);
        LoadXml(ImportType, ImportEntry, PurchInvoiceNo + '.xml', XmlPurch);

        // [Given] Create sales order
        EcWebService.ProcessImportEntry(ImportEntry);
        Commit();

        // [When] Lookup purchase invoice
        Codeunit.Run(ImportType."Lookup Codeunit ID", ImportEntry);

        // [Then] Handle purchase invoice page        
    end;

    local procedure Initialize()
    var
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
    begin
        if not Initialized then begin
            PrepareDataForXml();
            SetSalesDocumentAsXml();
            SetPurchDocumentAsXml();
            InitializeRelatedRecords();
            Initialized := true;
        end;
        Commit();
    end;

    local procedure PrepareDataForXml()
    var
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
    begin
        LibraryECommerce.GetSalesOrderNo(SalesOrderNo);
        LibraryECommerce.GetPurchInvNo(PurchInvoiceNo);
        LibraryECommerce.GetVendorInvoiceNo(VendorInvoiceNo);
        LibraryECommerce.GetEcStoreCode(StoreCode);
        LibraryECommerce.GetPostCodeAndCity(PostCode, City);
        LibraryECommerce.GetCustomerEMailAddress(EMail);
        LibraryECommerce.GetMagentoPaymentCode(MagentoPaymentCode);
        LibraryECommerce.GetMagentoPaymentTransactionId(TransactionId);
        LibraryECommerce.GetMagentoPaymentCode(MagentoPaymentCode2);
        LibraryECommerce.GetMagentoPaymentTransactionId(TransactionId2);
        LibraryECommerce.GetMagentoShipmentMethodCode(ExternalShipmentMethodCode);
        LibraryECommerce.CreateItem(ItemNo);
        LibraryECommerce.CreateItem(ItemNo2);
        LibraryECommerce.GetItemQuantitiesAndPrices(Qty, Qty2, UnitPrice, UnitPrice2);
        LibraryECommerce.CreateGLAccount(GLAccountNo);
        LibraryECommerce.GetGlAccUnitPrices(UnitPrice3, UnitPrice4);
        LibraryECommerce.GetLineDesc(Comment, "Sales Line Type"::" ");
        LibraryECommerce.GetLineDesc(ItemDesc, "Sales Line Type"::Item);
        LibraryECommerce.GetLineDesc(ItemDesc2, "Sales Line Type"::Item);
        LibraryECommerce.GetLineDesc(GLAccName, "Sales Line Type"::"G/L Account");
        LibraryECommerce.GetPaymentAmounts(PymAmount1, PymAmount2);
        LibraryECommerce.CreateVendor(EMail, '', VendorNo);
    end;

    local procedure SetSalesDocumentAsXml(): Text
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LineAmt, LineAmt2 : Decimal;
    begin
        XmlSales.Append('<?xml version="1.0" encoding="UTF-8"?>');
        XmlSales.Append('<sales_orders xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:microsoft-dynamics-nav/xmlports/sales_order">');
        XmlSales.Append(StrSubstNo('<sales_order order_no="%1" xsi:store_code="%2">', SalesOrderNo, StoreCode));
        XmlSales.Append(StrSubstNo('<xsi:order_date>%1</xsi:order_date>', Format(LibraryRandom.RandDate(0), 0, 9)));
        XmlSales.Append('<!-- <posting_date>Zero or Once</posting_date> -->');
        XmlSales.Append('<prices_incl_vat>true</prices_incl_vat>');
        XmlSales.Append('<currency_code/>');
        XmlSales.Append('<!-- XML Element is not mandatory for creating order but it''s mandatory for creating/updating customer -->');
        XmlSales.Append('<!-- <external_document_no>Zero or Once</external_document_no>-->');
        XmlSales.Append('<xsi:sell_to_customer customer_no="">');
        XmlSales.Append('<!-- Try without customer number and set email and/or phone in customer mapping -->');
        XmlSales.Append(StrSubstNo('<name>%1</name>', LibraryRandom.RandText(MaxStrLen(Customer.Name))));
        XmlSales.Append('<!-- <name_2>Zero or Once</name_2> -->');
        XmlSales.Append(StrSubstNo('<address>%1</address>', LibraryRandom.RandText(MaxStrLen(Customer.Address))));
        XmlSales.Append('<!-- <address_2>Zero or Once</address_2> -->');
        XmlSales.Append(StrSubstNo('<post_code>%1</post_code>', PostCode));
        XmlSales.Append(StrSubstNo('<city>%1</city>', City));
        XmlSales.Append('<!-- <country_code>Zero or Once</country_code> -->');
        XmlSales.Append('<!-- <contact>Zero or Once</contact> -->');
        XmlSales.Append(StrSubstNo('<xsi:email>%1</xsi:email>', EMail));
        XmlSales.Append('<!-- <phone>Zero or Once</phone> -->');
        XmlSales.Append('<!-- <ean>Zero or Once</ean> -->');
        XmlSales.Append('<!-- <vat_registration_no>Zero or Once</vat_registration_no> -->');
        XmlSales.Append('</xsi:sell_to_customer>');
        XmlSales.Append('<ship_to_customer>');
        XmlSales.Append(StrSubstNo('<name>%1</name>', LibraryRandom.RandText(MaxStrLen(Customer.Name))));
        XmlSales.Append('<!-- <name_2>Zero or Once</name_2> -->');
        XmlSales.Append(StrSubstNo('<address>%1</address>', LibraryRandom.RandText(MaxStrLen(Customer.Address))));
        XmlSales.Append('<!-- <address_2>Zero or Once</address_2> -->');
        XmlSales.Append(StrSubstNo('<post_code>%1</post_code>', PostCode));
        XmlSales.Append(StrSubstNo('<city>%1</city>', City));
        XmlSales.Append('<!-- <country_code>Zero or Once</country_code> -->');
        XmlSales.Append('<!-- <contact>Zero or Once</contact> -->');
        XmlSales.Append('</ship_to_customer>');
        XmlSales.Append('<payments>');
        XmlSales.Append(StrSubstNo('<payment code="%1">', MagentoPaymentCode));
        XmlSales.Append('<!-- <card_type>Zero or Once</card_type> -->');
        XmlSales.Append(StrSubstNo('<transaction_id>%1</transaction_id>', TransactionId));
        XmlSales.Append(StrSubstNo('<amount>%1</amount>', Format(PymAmount1, 0, 9)));
        XmlSales.Append('</payment>');
        XmlSales.Append(StrSubstNo('<payment code="%1">', MagentoPaymentCode2));
        XmlSales.Append('<!-- <card_type>Zero or Once</card_type> -->');
        XmlSales.Append(StrSubstNo('<transaction_id>%1</transaction_id>', TransactionId2));
        XmlSales.Append(StrSubstNo('<amount>%1</amount>', Format(PymAmount2, 0, 9)));
        XmlSales.Append('</payment>');
        XmlSales.Append('</payments>');
        XmlSales.Append(StrSubstNo('<shipment_method code="%1">', ExternalShipmentMethodCode));
        XmlSales.Append(StrSubstNo('<shipment_fee>%1</shipment_fee>', Format(UnitPrice4, 0, 9)));
        XmlSales.Append('</shipment_method>');
        XmlSales.Append(StrSubstNo('<note>%1</note>', LibraryRandom.RandText(2048)));
        XmlSales.Append('<sales_order_lines>');
        XmlSales.Append(StrSubstNo('<sales_order_line reference_no="%1" type="item">', ItemNo));
        XmlSales.Append(StrSubstNo('<description>%1</description>', ItemDesc));
        XmlSales.Append('<description_2/>');
        XmlSales.Append(StrSubstNo('<unit_price>%1</unit_price>', Format(UnitPrice, 0, 9)));
        XmlSales.Append(StrSubstNo('<quantity>%1</quantity>', Format(Qty, 0, 9)));
        XmlSales.Append('<!-- <discount_pct>Zero or Once</discount_pct> -->');
        XmlSales.Append('<!-- <discount_amount>Zero or Once</discount_amount> -->');

        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        XmlSales.Append(StrSubstNo('<vat_percent>%1</vat_percent>', VATPostingSetup."VAT %"));

        XmlSales.Append(StrSubstNo('<line_amount>%1</line_amount>', Qty * UnitPrice));
        XmlSales.Append('</sales_order_line>');
        XmlSales.Append(StrSubstNo('<sales_order_line reference_no="%1" type="item">', ItemNo2));
        XmlSales.Append(StrSubstNo('<description>%1</description>', ItemDesc2));
        XmlSales.Append('<description_2/>');
        XmlSales.Append(StrSubstNo('<unit_price>%1</unit_price>', Format(UnitPrice2, 0, 9)));
        XmlSales.Append(StrSubstNo('<quantity>%1</quantity>', Format(Qty2, 0, 9)));
        XmlSales.Append('<!-- <discount_pct>Zero or Once</discount_pct> -->');
        XmlSales.Append('<!-- <discount_amount>Zero or Once</discount_amount> -->');
        XmlSales.Append(StrSubstNo('<vat_percent>%1</vat_percent>', VATPostingSetup."VAT %"));
        XmlSales.Append(StrSubstNo('<line_amount>%1</line_amount>', Qty2 * UnitPrice2));
        XmlSales.Append('</sales_order_line>');
        XmlSales.Append(StrSubstNo('<sales_order_line reference_no="%1" type="gl_account">', GLAccountNo));
        XmlSales.Append(StrSubstNo('<description>%1</description>', GLAccName));
        XmlSales.Append('<description_2/>');
        XmlSales.Append(StrSubstNo('<unit_price>%1</unit_price>', Format(UnitPrice3, 0, 9)));
        XmlSales.Append('<quantity>1</quantity>');
        XmlSales.Append(StrSubstNo('<line_amount>%1</line_amount>', UnitPrice3 * 1));
        XmlSales.Append('</sales_order_line>');
        XmlSales.Append('<sales_order_line type="comment">');
        XmlSales.Append(StrSubstNo('<description>%1</description>', Comment));
        XmlSales.Append('<description_2/>');
        XmlSales.Append('</sales_order_line>');
        XmlSales.Append('</sales_order_lines>');
        XmlSales.Append('</sales_order>');
        XmlSales.Append('</sales_orders>');
    end;

    local procedure SetPurchDocumentAsXml(): Text
    var
        Vendor: Record Vendor;
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LineAmt, LineAmt2 : Decimal;
    begin
        XmlPurch.Append('<?xml version="1.0" encoding="UTF-8"?>');
        XmlPurch.Append('<purchase_invoices xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> xmlns="urn:microsoft-dynamics-nav/xmlports/purchase_invoices">');
        XmlPurch.Append(StrSubstNo('<purchase_invoice xsi:store_code="%1" invoice_no="%2">', StoreCode, PurchInvoiceNo));
        XmlPurch.Append('<!-- <document_date>Zero or Once</document_date> -->');
        XmlPurch.Append(StrSubstNo('<xsi:posting_date>%1</xsi:posting_date>', Format(LibraryRandom.RandDate(0), 0, 9)));
        XmlPurch.Append('<prices_incl_vat>true</prices_incl_vat>');
        XmlPurch.Append('<!-- <currency_code>Zero or Once</currency_code> -->');
        XmlPurch.Append(StrSubstNo('<vendor_invoice_no>%1</vendor_invoice_no>', VendorInvoiceNo));
        XmlPurch.Append(StrSubstNo('<xsi:buy_from_vendor vendor_no="%1">', VendorNo));
        XmlPurch.Append(StrSubstNo('<name>%1</name>', LibraryRandom.RandText(MaxStrLen(Vendor.Name))));
        XmlPurch.Append('<!-- <name_2>Zero or Once</name_2> -->');
        XmlPurch.Append(StrSubstNo('<address>%1</address>', LibraryRandom.RandText(MaxStrLen(Vendor.Address))));
        XmlPurch.Append('<!-- <address_2>Zero or Once</address_2> -->');
        XmlPurch.Append(StrSubstNo('<post_code>%1</post_code>', PostCode));
        XmlPurch.Append(StrSubstNo('<city>%1</city>', City));
        XmlPurch.Append('<!-- <country_code>Zero or Once</country_code> -->');
        XmlPurch.Append('<!-- <contact>Zero or Once</contact> -->');
        XmlPurch.Append(StrSubstNo('<xsi:email>%1</xsi:email>', EMail));
        XmlPurch.Append('<!-- <phone>Zero or Once</phone> -->');
        XmlPurch.Append('</xsi:buy_from_vendor>');
        XmlPurch.Append(StrSubstNo('<note>%1</note>', LibraryRandom.RandText(2048)));

        XmlPurch.Append('<purchase_invoice_lines>');
        XmlPurch.Append(StrSubstNo('<purchase_invoice_line type="item" reference_no="%1">', ItemNo));
        XmlPurch.Append('<!-- <description>Zero or Once</description> -->');
        XmlPurch.Append('<!-- <description_2>Zero or Once</description_2> -->');
        XmlPurch.Append(StrSubstNo('<direct_unit_cost>%1</direct_unit_cost>', Format(UnitPrice, 0, 9)));
        XmlPurch.Append(StrSubstNo('<quantity>%1</quantity>', Format(Qty, 0, 9)));
        XmlPurch.Append('<!-- <discount_pct>Zero or Once</discount_pct> -->');
        XmlPurch.Append('<!-- <discount_amount>Zero or Once</discount_amount> -->');
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        XmlPurch.Append(StrSubstNo('<vat_percent>%1</vat_percent>', VATPostingSetup."VAT %"));
        XmlPurch.Append(StrSubstNo('<line_amount>%1</line_amount>', Qty * UnitPrice));
        XmlPurch.Append('</purchase_invoice_line>');

        XmlPurch.Append(StrSubstNo('<purchase_invoice_line type="item" reference_no="%1">', ItemNo2));
        XmlPurch.Append('<!-- <description>Zero or Once</description> -->');
        XmlPurch.Append('<!-- <description_2>Zero or Once</description_2> -->');
        XmlPurch.Append(StrSubstNo('<direct_unit_cost>%1</direct_unit_cost>', Format(UnitPrice2, 0, 9)));
        XmlPurch.Append(StrSubstNo('<quantity>%1</quantity>', Format(Qty2, 0, 9)));
        XmlPurch.Append('<!-- <discount_pct>Zero or Once</discount_pct> -->');
        XmlPurch.Append('<!-- <discount_amount>Zero or Once</discount_amount> -->');
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        XmlPurch.Append(StrSubstNo('<vat_percent>%1</vat_percent>', VATPostingSetup."VAT %"));
        XmlPurch.Append(StrSubstNo('<line_amount>%1</line_amount>', Qty2 * UnitPrice2));
        XmlPurch.Append('</purchase_invoice_line>');

        XmlPurch.Append(StrSubstNo('<purchase_invoice_line type="gl_account" reference_no="%1">', GLAccountNo));
        XmlPurch.Append(StrSubstNo('<description>%1</description>', GLAccName));
        XmlPurch.Append('<!-- <description_2>Zero or Once</description_2> -->');
        XmlPurch.Append(StrSubstNo('<direct_unit_cost>%1</direct_unit_cost>', Format(UnitPrice3, 0, 9)));
        XmlPurch.Append('<quantity>1</quantity>');
        XmlPurch.Append(StrSubstNo('<line_amount>%1</line_amount>', 1 * UnitPrice3));
        XmlPurch.Append('</purchase_invoice_line>');

        XmlPurch.Append('<purchase_invoice_line type="comment">');
        XmlPurch.Append(StrSubstNo('<description>%1</description>', Comment));
        XmlPurch.Append('<description_2/>');
        XmlPurch.Append('</purchase_invoice_line>');

        XmlPurch.Append('</purchase_invoice_lines>');
        XmlPurch.Append('</purchase_invoice>');
        XmlPurch.Append('</purchase_invoices>');
    end;

    local procedure InitializeRelatedRecords()
    var
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
    begin
        LibraryECommerce.CreateCustomer(EMail, '');
        LibraryECommerce.CreateEcStore(StoreCode);
        LibraryECommerce.CreateEcCustomerMapping(StoreCode, '');
        LibraryECommerce.CreateMagentoPaymentMapping(MagentoPaymentCode, '');
        LibraryECommerce.CreateMagentoPaymentMapping(MagentoPaymentCode2, '');
        LibraryECommerce.CreateMagentoShipmentMapping(ExternalShipmentMethodCode);
    end;

    local procedure LoadXmlAndRemoveElement(XPath: Text; ImportType: Record "NPR Nc Import Type"; var ImportEntry: Record "NPR NC Import Entry"; DocName: Text; Xml: TextBuilder)
    var
        Node: XmlNode;
        Document: XmlDocument;
        XmlDomMgt: Codeunit "XML DOM Management";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        OutStr: OutStream;
        XmlDoc: Text;
    begin
        LibraryECommerce.InsertImportEntry(ImportType, ImportEntry);
        ImportEntry."Document Name" := DocName;
        ImportEntry."Document Source".CreateOutStream(OutStr);

        XmlDoc := Xml.ToText();
        XmlDoc := XmlDomMgt.RemoveNamespaces(XmlDoc);
        XmlDocument.ReadFrom(XmlDoc, Document);
        Document.SelectSingleNode(XPath, Node);
        Node.Remove();
        Document.WriteTo(OutStr);

        ImportEntry.Modify();
    end;

    local procedure LoadXmlAndRemoveElements(XPath: Text; ImportType: Record "NPR Nc Import Type"; var ImportEntry: Record "NPR NC Import Entry"; DocName: Text; Xml: TextBuilder)
    var
        ImportEntry2: Record "NPR NC Import Entry";
        Node: XmlNode;
        NodeList: XmlNodeList;
        Document: XmlDocument;
        XmlDomMgt: Codeunit "XML DOM Management";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        OutStr: OutStream;
        XmlDoc: Text;
    begin
        ImportEntry2.SetRange("Import Type", ImportType.Code);
        if not ImportEntry2.IsEmpty() then
            ImportEntry2.DeleteAll();

        LibraryECommerce.InsertImportEntry(ImportType, ImportEntry);
        ImportEntry."Document Name" := DocName;
        ImportEntry."Document Source".CreateOutStream(OutStr);

        XmlDoc := Xml.ToText();
        XmlDoc := XmlDomMgt.RemoveNamespaces(XmlDoc);
        XmlDocument.ReadFrom(XmlDoc, Document);
        Document.SelectNodes(XPath, NodeList);
        foreach Node in NodeList do
            Node.Remove();
        Document.WriteTo(OutStr);

        ImportEntry.Modify();
    end;

    local procedure LoadXml(ImportType: Record "NPR Nc Import Type"; var ImportEntry: Record "NPR NC Import Entry"; DocName: Text; Xml: TextBuilder)
    var
        Node: XmlNode;
        Document: XmlDocument;
        XmlDomMgt: Codeunit "XML DOM Management";
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
        OutStr: OutStream;
        XmlDoc: Text;
    begin
        LibraryECommerce.InsertImportEntry(ImportType, ImportEntry);
        ImportEntry."Document Name" := DocName;
        ImportEntry."Document Source".CreateOutStream(OutStr);

        XmlDoc := Xml.ToText();
        XmlDoc := XmlDomMgt.RemoveNamespaces(XmlDoc);
        XmlDocument.ReadFrom(XmlDoc, Document);
        Document.WriteTo(OutStr);

        ImportEntry.Modify();
    end;

    [PageHandler]
    procedure OpenSalesOrder(var SalesOrder: TestPage "Sales Order")
    var
        MyNotifications: Record "My Notifications";
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        MyNotifications.Disable(InstructionMgt.GetClosingUnpostedDocumentNotificationId());
        SalesOrder.Close();
    end;

    [PageHandler]
    procedure OpenPurchaseInvoice(var PurchaseInvoice: TestPage "Purchase Invoice")
    var
        MyNotifications: Record "My Notifications";
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        MyNotifications.Disable(InstructionMgt.GetClosingUnpostedDocumentNotificationId());
        PurchaseInvoice.Close();
    end;
}
