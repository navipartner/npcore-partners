codeunit 85058 "NPR Magento Sales Order Tests"
{
    Subtype = Test;

    var
        _MagentoLibrary: Codeunit "NPR Library - Magento";
        _LastOrderNo: Text;
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CanImportMagentoSalesOrder()
    var
        MagentoSalesOrderMgt: Codeunit "NPR Magento Sales Order Mgt.";
        ImportEntry: Record "NPR Nc Import Entry";
    begin
        Initialize();
        CreateImportEntry(ImportEntry);
        MagentoSalesOrderMgt.Run(ImportEntry);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommitIsNotAllowed()
    var
        MagentoSalesOrderMgt: Codeunit "NPR Magento Sales Order Mgt.";
        ImportEntry: Record "NPR Nc Import Entry";
        SubsriberWithCommit: Codeunit "NPR Sales Header Commit Subs.";
        Assert: Codeunit Assert;
    begin
        Initialize();
        CreateImportEntry(ImportEntry);
        BindSubscription(SubsriberWithCommit);
        asserterror MagentoSalesOrderMgt.RunProcessImportEntry(ImportEntry);
        UnbindSubscription(SubsriberWithCommit);

        Assert.IsTrue(
            GetLastErrorText().Contains('Commit'),
            StrSubstNo('Error message should relate to commit behavior, but did not contain the keyword "Commit"!\\Message: %1', GetLastErrorText()));
    end;

    local procedure CreateImportEntry(var ImportEntry: Record "NPR Nc Import Entry")
    var
        LibraryNaviConnect: Codeunit "NPR Library - NaviConnect";
        OStr: OutStream;
    begin
        _LastOrderNo := IncStr(_LastOrderNo);

        Clear(ImportEntry);

        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Document Name" := 'Test-Xml.xml';
        ImportEntry."Import Type" := LibraryNaviConnect.CreateImportType();
        ImportEntry.Date := CurrentDateTime();

        ImportEntry."Document Source".CreateOutStream(OStr);
        OStr.WriteText(GetValidXmlDocument(_LastOrderNo));

        ImportEntry.Insert();
    end;

    local procedure GetValidXmlDocument(OrderNo: Text) Doc: Text
    begin
        Doc :=
            '<sales_orders>' +
                '<sales_order xmlns="urn:microsoft-dynamics-nav/xmlports/sales_order" order_no="' + OrderNo + '" website_code="base">' +
                    '<order_date>2020-08-18 19:39:20</order_date>' +
                    '<sell_to_customer customer_no="" tax_class="Retail Customer">' +
                        '<name><![CDATA[Automated Test]]></name>' +
                        '<name_2/>' +
                        '<address><![CDATA[Titangade 16]]></address>' +
                        '<address_2/>' +
                        '<post_code><![CDATA[2200]]></post_code>' +
                        '<city><![CDATA[Copenhagen N]]></city>' +
                        '<country_code>DK</country_code>' +
                        '<contact/>' +
                        '<email><![CDATA[test@navipartner.dk]]></email>' +
                        '<phone><![CDATA[88912346]]></phone>' +
                    '</sell_to_customer>' +
                    '<payments>' +
                        '<payment_method type="payment_gateway" code="funny_money">' +
                            '<payment_type/>' +
                            '<transaction_id/>' +
                            '<payment_amount>36.0000</payment_amount>' +
                            '<payment_fee>0.0000</payment_fee>' +
                        '</payment_method>' +
                    '</payments>' +
                    '<shipment>' +
                        '<shipment_method>test_method</shipment_method>' +
                        '<shipment_service />' +
                        '<shipment_fee>0.0000</shipment_fee>' +
                        '<shipment_date/>' +
                    '</shipment>' +
                    '<comments>' +
                        '<comment_line>' +
                            '<comment/>' +
                        '</comment_line>' +
                    '</comments>' +
                    '<sales_order_lines>' +
                        '<sales_order_line type="item" external_no="1000">' +
                            '<description><![CDATA[Proteus Fitness Jackshirt]]></description>' +
                            '<unit_price_incl_vat>36.0000</unit_price_incl_vat>' +
                            '<quantity>1.0000</quantity>' +
                            '<discount_pct>0.0000</discount_pct>' +
                            '<discount_amount>0.0000</discount_amount>' +
                            '<vat_percent>0.0000</vat_percent>' +
                            '<line_amount_incl_vat>36.0000</line_amount_incl_vat>' +
                        '</sales_order_line>' +
                    '</sales_order_lines>' +
                '</sales_order>' +
            '</sales_orders>';
    end;

    local procedure Initialize()
    var
        MagentoSetup: Record "NPR Magento Setup";
        CustomerTempl: Record "Customer Templ.";
        Salesperson: Record "Salesperson/Purchaser";
        Item: Record Item;
        LibrarySales: Codeunit "Library - Sales";
        LibraryERM: Codeunit "Library - ERM";
        LibraryTemplates: Codeunit "Library - Templates";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if (not _Initialized) then begin
            LibraryTemplates.CreateCustomerTemplateWithData(CustomerTempl);

            Item."No." := '1000';
            if (Item.Find()) then
                Item.Delete();
            _MagentoLibrary.CreateMagentoItem(Item);

            if (not VATPostingSetup.Get(CustomerTempl."VAT Bus. Posting Group", Item."VAT Prod. Posting Group")) then
                LibraryERM.CreateVATPostingSetup(VATPostingSetup, CustomerTempl."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");

            LibrarySales.CreateSalesperson(Salesperson);

            _MagentoLibrary.CreateMagentoSetup(MagentoSetup);
            MagentoSetup."Customer Update Mode" := MagentoSetup."Customer Update Mode"::"Create and Update";
            MagentoSetup."Customer Template Code" := CustomerTempl.Code;
            MagentoSetup."Salesperson Code" := Salesperson.Code;
            MagentoSetup.Modify();

            _MagentoLibrary.CreatePaymentMapping('funny_money', '');
            _MagentoLibrary.CreateShipmentMapping('test_method');
            _MagentoLibrary.CreateMagentoStore('base', 'default');
            _MagentoLibrary.CreateVATBusinessGroupMapping(CustomerTempl."VAT Bus. Posting Group", 'Retail Customer');

            _LastOrderNo := '1';

            _Initialized := true;
        end;

        Commit();
    end;
}