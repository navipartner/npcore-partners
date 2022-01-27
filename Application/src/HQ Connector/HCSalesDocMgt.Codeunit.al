codeunit 6150906 "NPR HC Sales Doc. Mgt."
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        Document: XmlDocument;
    begin
        if Rec.LoadXmlDoc(Document) then
            UpdateSales(Document);
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

    local procedure UpdateSales(Document: XmlDocument)
    var
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        Document.GetRoot(Element);
        if Element.IsEmpty then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'salesdocumentimport', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'salesdocument', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'insertsalesdocument', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'salesheader', NodeList) then
            exit;

        foreach Node in NodeList do
            UpdateSalesHeader(Node.AsXmlElement());

    end;

    local procedure UpdateSalesHeader(ItemXmlElement: XmlElement): Boolean
    var
        SalesHeader: Record "Sales Header";
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        if ItemXmlElement.IsEmpty then
            exit(false);

        InsertSalesHeader(ItemXmlElement, SalesHeader);

        NpXmlDomMgt.FindNodes(ItemXmlElement.AsXmlNode(), 'salesline', NodeList);
        foreach Node in NodeList do
            UpdateSalesLine(Node.AsXmlElement(), SalesHeader);

        Commit();

        OnAfterUpdateSalesHeader(SalesHeader);

        exit(true);
    end;

    local procedure UpdateSalesLine(ItemXmlElement: XmlElement; SalesHeader: Record "Sales Header"): Boolean
    var
        TempSalesLine: Record "Sales Line" temporary;
        SalesLine: Record "Sales Line";
        NodeList: XmlNodeList;
        Node: XmlNode;
        XPath: Text[250];
        XPathReservationEntryLbl: Label 'reservationentry[@sourcetype="37" and @sourcesubtype="%1" and @sourceid="%2" and @sourcebatchname="" and @sourceprodorderline="0" and @sourcerefno="%3" and @positive="false"]', Locked = true;
    begin
        if ItemXmlElement.IsEmpty then
            exit(false);

        InsertSalesLine(ItemXmlElement, SalesHeader, SalesLine, TempSalesLine);
        XPath := StrSubstNo(XPathReservationEntryLbl,
                            Format(TempSalesLine."Document Type", 0, 2), TempSalesLine."Document No.", Format(TempSalesLine."Line No."));
        NpXmlDomMgt.FindNodes(ItemXmlElement.AsXmlNode(), XPath, NodeList);
        foreach Node in NodeList do
            UpdateReservationEntry(Node.AsXmlElement(), SalesLine);

        exit(true);
    end;

    local procedure UpdateReservationEntry(ItemXmlElement: XmlElement; SalesLine: Record "Sales Line"): Boolean
    begin
        if ItemXmlElement.IsEmpty then
            exit(false);

        InsertReservationEntry(ItemXmlElement, SalesLine);

        exit(true);
    end;

    local procedure InsertSalesHeader(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        TempSalesHeader: Record "Sales Header" temporary;
        Handeld: Boolean;
    begin
        Evaluate(TempSalesHeader."Document Type", NpXmlDomMgt.GetXmlAttributeText(Element, 'documenttype', false), 9);
        TempSalesHeader."No." := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'documentno', false), 1, 20);
        Evaluate(TempSalesHeader."Sell-to Customer No.", NpXmlDomMgt.GetXmlText(Element, 'selltocustomerno', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Customer No.", NpXmlDomMgt.GetXmlText(Element, 'billtocustomerno', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Name", NpXmlDomMgt.GetXmlText(Element, 'billtoname', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Name 2", NpXmlDomMgt.GetXmlText(Element, 'billtoname2', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Address", NpXmlDomMgt.GetXmlText(Element, 'billtoaddress', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Address 2", NpXmlDomMgt.GetXmlText(Element, 'billtoaddress2', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to City", NpXmlDomMgt.GetXmlText(Element, 'billtocity', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Contact", NpXmlDomMgt.GetXmlText(Element, 'billtocontact', 0, false), 9);
        Evaluate(TempSalesHeader."Your Reference", NpXmlDomMgt.GetXmlText(Element, 'yourreference', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Code", NpXmlDomMgt.GetXmlText(Element, 'shiptocode', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Name", NpXmlDomMgt.GetXmlText(Element, 'shiptoname', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Name 2", NpXmlDomMgt.GetXmlText(Element, 'shiptoname2', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Address", NpXmlDomMgt.GetXmlText(Element, 'shiptoaddress', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Address 2", NpXmlDomMgt.GetXmlText(Element, 'shiptoaddress2', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to City", NpXmlDomMgt.GetXmlText(Element, 'shiptocity', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Contact", NpXmlDomMgt.GetXmlText(Element, 'shiptocontact', 0, false), 9);
        Evaluate(TempSalesHeader."Order Date", NpXmlDomMgt.GetXmlText(Element, 'orderdate', 0, false), 9);
        Evaluate(TempSalesHeader."Posting Date", NpXmlDomMgt.GetXmlText(Element, 'postingdate', 0, false), 9);
        Evaluate(TempSalesHeader."Shipment Date", NpXmlDomMgt.GetXmlText(Element, 'shipmentdate', 0, false), 9);
        Evaluate(TempSalesHeader."Posting Description", NpXmlDomMgt.GetXmlText(Element, 'postingdescription', 0, false), 9);
        Evaluate(TempSalesHeader."Payment Terms Code", NpXmlDomMgt.GetXmlText(Element, 'paymenttermscode', 0, false), 9);
        Evaluate(TempSalesHeader."Due Date", NpXmlDomMgt.GetXmlText(Element, 'duedate', 0, false), 9);
        Evaluate(TempSalesHeader."Payment Discount %", NpXmlDomMgt.GetXmlText(Element, 'paymentdiscount', 0, false), 9);
        Evaluate(TempSalesHeader."Pmt. Discount Date", NpXmlDomMgt.GetXmlText(Element, 'pmtdiscountdate', 0, false), 9);
        Evaluate(TempSalesHeader."Shipment Method Code", NpXmlDomMgt.GetXmlText(Element, 'shipmentmethod', 0, false), 9);
        Evaluate(TempSalesHeader."Location Code", NpXmlDomMgt.GetXmlText(Element, 'locationcode', 0, false), 9);
        Evaluate(TempSalesHeader."Shortcut Dimension 1 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension1', 0, false), 9);
        Evaluate(TempSalesHeader."Shortcut Dimension 2 Code", NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension2', 0, false), 9);
        Evaluate(TempSalesHeader."Customer Posting Group", NpXmlDomMgt.GetXmlText(Element, 'customerpostinggroup', 0, false), 9);
        Evaluate(TempSalesHeader."Currency Code", NpXmlDomMgt.GetXmlText(Element, 'currencycode', 0, false), 9);
        Evaluate(TempSalesHeader."Currency Factor", NpXmlDomMgt.GetXmlText(Element, 'currencyfactor', 0, false), 9);
        Evaluate(TempSalesHeader."Customer Price Group", NpXmlDomMgt.GetXmlText(Element, 'customerpricegroup', 0, false), 9);
        Evaluate(TempSalesHeader."Prices Including VAT", NpXmlDomMgt.GetXmlText(Element, 'pricesincludingvat', 0, false), 9);
        Evaluate(TempSalesHeader."Invoice Disc. Code", NpXmlDomMgt.GetXmlText(Element, 'invoicedisccode', 0, false), 9);
        Evaluate(TempSalesHeader."Customer Disc. Group", NpXmlDomMgt.GetXmlText(Element, 'customerdisccode', 0, false), 9);
        Evaluate(TempSalesHeader."Language Code", NpXmlDomMgt.GetXmlText(Element, 'languagecode', 0, false), 9);
        Evaluate(TempSalesHeader."Salesperson Code", NpXmlDomMgt.GetXmlText(Element, 'salespersoncode', 0, false), 9);
        Evaluate(TempSalesHeader."Order Class", NpXmlDomMgt.GetXmlText(Element, 'orderclass', 0, false), 9);
        Evaluate(TempSalesHeader."On Hold", NpXmlDomMgt.GetXmlText(Element, 'onhold', 0, false), 9);
        Evaluate(TempSalesHeader."Bal. Account No.", NpXmlDomMgt.GetXmlText(Element, 'balaccountno', 0, false), 9);
        Evaluate(TempSalesHeader."VAT Registration No.", NpXmlDomMgt.GetXmlText(Element, 'vatregistrationno', 0, false), 9);
        Evaluate(TempSalesHeader."Combine Shipments", NpXmlDomMgt.GetXmlText(Element, 'combineshipments', 0, false), 9);
        Evaluate(TempSalesHeader."Reason Code", NpXmlDomMgt.GetXmlText(Element, 'reasoncode', 0, false), 9);
        Evaluate(TempSalesHeader."Gen. Bus. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'genbuspostinggroup', 0, false), 9);
        Evaluate(TempSalesHeader."EU 3-Party Trade", NpXmlDomMgt.GetXmlText(Element, 'eu3partytrade', 0, false), 9);
        Evaluate(TempSalesHeader."Transaction Type", NpXmlDomMgt.GetXmlText(Element, 'transactiontype', 0, false), 9);
        Evaluate(TempSalesHeader."Transport Method", NpXmlDomMgt.GetXmlText(Element, 'transportmethod', 0, false), 9);
        Evaluate(TempSalesHeader."VAT Country/Region Code", NpXmlDomMgt.GetXmlText(Element, 'vatcountryregioncode', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Customer Name", NpXmlDomMgt.GetXmlText(Element, 'selltocustomername', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Customer Name 2", NpXmlDomMgt.GetXmlText(Element, 'selltocustomername2', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Address", NpXmlDomMgt.GetXmlText(Element, 'selltoaddress', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Address 2", NpXmlDomMgt.GetXmlText(Element, 'selltoaddress2', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to City", NpXmlDomMgt.GetXmlText(Element, 'selltocity', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Contact", NpXmlDomMgt.GetXmlText(Element, 'selltocontact', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Post Code", NpXmlDomMgt.GetXmlText(Element, 'billtopostcode', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to County", NpXmlDomMgt.GetXmlText(Element, 'billtocounty', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Country/Region Code", NpXmlDomMgt.GetXmlText(Element, 'billtocountryregioncode', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Post Code", NpXmlDomMgt.GetXmlText(Element, 'selltopostcode', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to County", NpXmlDomMgt.GetXmlText(Element, 'selltocounty', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Country/Region Code", NpXmlDomMgt.GetXmlText(Element, 'selltocountryregioncode', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Post Code", NpXmlDomMgt.GetXmlText(Element, 'shiptopostcode', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to County", NpXmlDomMgt.GetXmlText(Element, 'shiptocounty', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Country/Region Code", NpXmlDomMgt.GetXmlText(Element, 'shiptocountryregioncode', 0, false), 9);
        Evaluate(TempSalesHeader."Bal. Account Type", NpXmlDomMgt.GetXmlText(Element, 'balaccounttype', 0, false), 9);
        Evaluate(TempSalesHeader."Exit Point", NpXmlDomMgt.GetXmlText(Element, 'exitpoint', 0, false), 9);
        Evaluate(TempSalesHeader."Document Date", NpXmlDomMgt.GetXmlText(Element, 'documentdate', 0, false), 9);
        Evaluate(TempSalesHeader."External Document No.", NpXmlDomMgt.GetXmlText(Element, 'externaldocumentno', 0, false), 9);
        Evaluate(TempSalesHeader.Area, NpXmlDomMgt.GetXmlText(Element, 'area', 0, false), 9);
        Evaluate(TempSalesHeader."Transaction Specification", NpXmlDomMgt.GetXmlText(Element, 'transactionspecification', 0, false), 9);
        Evaluate(TempSalesHeader."Payment Method Code", NpXmlDomMgt.GetXmlText(Element, 'paymentmethodcode', 0, false), 9);
        Evaluate(TempSalesHeader."Shipping Agent Code", NpXmlDomMgt.GetXmlText(Element, 'shippingagentcode', 0, false), 9);
        Evaluate(TempSalesHeader."Package Tracking No.", NpXmlDomMgt.GetXmlText(Element, 'packagetrackingno', 0, false), 9);
        Evaluate(TempSalesHeader."No. Series", NpXmlDomMgt.GetXmlText(Element, 'noseries', 0, false), 9);
        Evaluate(TempSalesHeader."Posting No. Series", NpXmlDomMgt.GetXmlText(Element, 'postingnoseries', 0, false), 9);
        Evaluate(TempSalesHeader."Shipping No. Series", NpXmlDomMgt.GetXmlText(Element, 'shippingnoseries', 0, false), 9);
        Evaluate(TempSalesHeader."Tax Area Code", NpXmlDomMgt.GetXmlText(Element, 'taxareacode', 0, false), 9);
        Evaluate(TempSalesHeader."Tax Liable", NpXmlDomMgt.GetXmlText(Element, 'taxliable', 0, false), 9);
        Evaluate(TempSalesHeader."VAT Bus. Posting Group", NpXmlDomMgt.GetXmlText(Element, 'vatbuspostinggroup', 0, false), 9);
        Evaluate(TempSalesHeader.Reserve, NpXmlDomMgt.GetXmlText(Element, 'reserve', 0, false), 9);
        Evaluate(TempSalesHeader."Applies-to ID", NpXmlDomMgt.GetXmlText(Element, 'appliestoid', 0, false), 9);
        Evaluate(TempSalesHeader."VAT Base Discount %", NpXmlDomMgt.GetXmlText(Element, 'vatbasediscountperc', 0, false), 9);
        Evaluate(TempSalesHeader.Status, NpXmlDomMgt.GetXmlText(Element, 'status', 0, false), 9);
        Evaluate(TempSalesHeader."Invoice Discount Calculation", NpXmlDomMgt.GetXmlText(Element, 'invoicediscountcalculation', 0, false), 9);
        Evaluate(TempSalesHeader."Invoice Discount Value", NpXmlDomMgt.GetXmlText(Element, 'invoicediscountvalue', 0, false), 9);
        Evaluate(TempSalesHeader."Quote No.", NpXmlDomMgt.GetXmlText(Element, 'quoteno', 0, false), 9);
#if BC17
        Evaluate(TempSalesHeader."Sell-to Customer Template Code", NpXmlDomMgt.GetXmlText(Element, 'selltocustomertemplatecode', 0, false), 9);
#else
        Evaluate(TempSalesHeader."Sell-to Customer Templ. Code", NpXmlDomMgt.GetXmlText(Element, 'selltocustomertemplatecode', 0, false), 9);
#endif
        Evaluate(TempSalesHeader."Sell-to Contact No.", NpXmlDomMgt.GetXmlText(Element, 'selltocontactno', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Contact No.", NpXmlDomMgt.GetXmlText(Element, 'billtocontactno', 0, false), 9);
#if BC17
        Evaluate(TempSalesHeader."Bill-to Customer Template Code", NpXmlDomMgt.GetXmlText(Element, 'selltocustomertemplatecode', 0, false), 9);
#else
        Evaluate(TempSalesHeader."Bill-to Customer Templ. Code", NpXmlDomMgt.GetXmlText(Element, 'billtocustomertemplatecode', 0, false), 9);
#endif
        Evaluate(TempSalesHeader."Opportunity No.", NpXmlDomMgt.GetXmlText(Element, 'opportunityno', 0, false), 9);
        Evaluate(TempSalesHeader."Responsibility Center", NpXmlDomMgt.GetXmlText(Element, 'responisbilitycenter', 0, false), 9);
        Evaluate(TempSalesHeader."Shipping Advice", NpXmlDomMgt.GetXmlText(Element, 'shippingadvice', 0, false), 9);
        Evaluate(TempSalesHeader."Requested Delivery Date", NpXmlDomMgt.GetXmlText(Element, 'requesteddeliverydate', 0, false), 9);
        Evaluate(TempSalesHeader."Promised Delivery Date", NpXmlDomMgt.GetXmlText(Element, 'promiseddeliverydate', 0, false), 9);
        Evaluate(TempSalesHeader."Shipping Time", NpXmlDomMgt.GetXmlText(Element, 'shippingtime', 0, false), 9);
        Evaluate(TempSalesHeader."Outbound Whse. Handling Time", NpXmlDomMgt.GetXmlText(Element, 'outboundwhsehandlingtime', 0, false), 9);
        Evaluate(TempSalesHeader."Shipping Agent Service Code", NpXmlDomMgt.GetXmlText(Element, 'shippingagenetservicecode', 0, false), 9);
        Evaluate(TempSalesHeader."Allow Line Disc.", NpXmlDomMgt.GetXmlText(Element, 'allowlinedisc', 0, false), 9);

        OnBeforeInsertSalesHeader(TempSalesHeader, SalesHeader, Handeld);
        //Record insert
        if not Handeld then begin
            SalesHeader.SetRange("External Document No.", TempSalesHeader."External Document No.");
            if not SalesHeader.FindFirst() then begin
                SalesHeader.Init();
                SalesHeader.Validate("Document Type", TempSalesHeader."Document Type");
                SalesHeader."No." := '';
                SalesHeader.Insert(true);
                SalesHeader.Validate("Sell-to Customer No.", TempSalesHeader."Sell-to Customer No.");
                SalesHeader.Validate("Posting Date", TempSalesHeader."Posting Date");
                SalesHeader.Validate("Document Date", TempSalesHeader."Document Date");
                SalesHeader.Validate("External Document No.", TempSalesHeader."External Document No.");
                SalesHeader.Validate("Your Reference", TempSalesHeader."Your Reference");
                SalesHeader.Validate("Bill-to Customer No.", TempSalesHeader."Bill-to Customer No.");
                SalesHeader.Validate("Bill-to Contact", TempSalesHeader."Bill-to Contact");
                if SalesHeader."Sell-to Contact" = '' then
                    SalesHeader.Validate("Sell-to Contact", TempSalesHeader."Sell-to Contact");
                SalesHeader.Validate("Ship-to Name", TempSalesHeader."Ship-to Name");
                SalesHeader.Validate("Ship-to Address", TempSalesHeader."Ship-to Address");
                SalesHeader.Validate("Ship-to Address 2", TempSalesHeader."Ship-to Address 2");
                SalesHeader.Ship := TempSalesHeader.Ship;
                SalesHeader.Invoice := TempSalesHeader.Invoice;
                SalesHeader.Receive := TempSalesHeader.Receive;
                SalesHeader.Modify(true);
            end else begin
                SalesHeader.SetHideValidationDialog(true);
                if SalesHeader."Sell-to Customer No." <> TempSalesHeader."Sell-to Customer No." then
                    SalesHeader.Validate("Sell-to Customer No.", TempSalesHeader."Sell-to Customer No.");
                if SalesHeader."Posting Date" <> TempSalesHeader."Posting Date" then
                    SalesHeader.Validate("Posting Date", TempSalesHeader."Posting Date");
                if SalesHeader."Document Date" <> TempSalesHeader."Document Date" then
                    SalesHeader.Validate("Document Date", TempSalesHeader."Document Date");
                if SalesHeader."External Document No." <> TempSalesHeader."External Document No." then
                    SalesHeader.Validate("External Document No.", TempSalesHeader."External Document No.");
                if SalesHeader."Your Reference" <> TempSalesHeader."Your Reference" then
                    SalesHeader.Validate("Your Reference", TempSalesHeader."Your Reference");
                if SalesHeader."Bill-to Customer No." <> TempSalesHeader."Bill-to Customer No." then
                    SalesHeader.Validate("Bill-to Customer No.", TempSalesHeader."Bill-to Customer No.");
                if SalesHeader."Bill-to Contact" <> TempSalesHeader."Bill-to Contact" then
                    SalesHeader.Validate("Bill-to Contact", TempSalesHeader."Bill-to Contact");
                if SalesHeader."Sell-to Contact" <> TempSalesHeader."Sell-to Contact" then
                    SalesHeader.Validate("Sell-to Contact", TempSalesHeader."Sell-to Contact");
                if SalesHeader."Ship-to Name" <> TempSalesHeader."Ship-to Name" then
                    SalesHeader.Validate("Ship-to Name", TempSalesHeader."Ship-to Name");
                if SalesHeader."Ship-to Address" <> TempSalesHeader."Ship-to Address" then
                    SalesHeader.Validate("Ship-to Address", TempSalesHeader."Ship-to Address");
                if SalesHeader."Ship-to Address 2" <> TempSalesHeader."Ship-to Address 2" then
                    SalesHeader.Validate("Ship-to Address 2", TempSalesHeader."Ship-to Address 2");
                SalesHeader.Modify(true);
            end;
            SalesHeader.Reset();
        end;

        OnAfterInsertSalesHeader(TempSalesHeader, SalesHeader);
    end;

    local procedure InsertSalesLine(Element: XmlElement; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line")
    var
        Handeld: Boolean;
    begin
        Evaluate(TempSalesLine."Document Type", NpXmlDomMgt.GetXmlAttributeText(Element, 'documenttype', false), 9);
        TempSalesLine."Document No." := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'documentno', false), 1, 20);
        Evaluate(TempSalesLine."Line No.", NpXmlDomMgt.GetXmlAttributeText(Element, 'lineno', false), 9);
        Evaluate(TempSalesLine.Type, NpXmlDomMgt.GetXmlText(Element, 'type', 0, false), 9);
        TempSalesLine."No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'no', 0, false), 1, 20);
        TempSalesLine."Location Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'locationcode', 0, false), 1, 10);
        TempSalesLine."Posting Group" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'postinggroup', 0, false), 1, 20);
        Evaluate(TempSalesLine."Shipment Date", NpXmlDomMgt.GetXmlText(Element, 'shipmentdate', 0, false), 9);
        TempSalesLine.Description := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'description', 0, false), 1, 100);
        TempSalesLine."Description 2" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'description2', 0, false), 1, 50);
        TempSalesLine."Unit of Measure" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'unitofmeasure', 0, false), 1, 50);
        Evaluate(TempSalesLine.Quantity, NpXmlDomMgt.GetXmlText(Element, 'quantity', 0, false), 9);
        Evaluate(TempSalesLine."Outstanding Quantity", NpXmlDomMgt.GetXmlText(Element, 'outstandingquantity', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Invoice", NpXmlDomMgt.GetXmlText(Element, 'qtytoinvoice', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Ship", NpXmlDomMgt.GetXmlText(Element, 'qtytoship', 0, false), 9);
        Evaluate(TempSalesLine."Unit Price", NpXmlDomMgt.GetXmlText(Element, 'unitprice', 0, false), 9);
        Evaluate(TempSalesLine."Unit Cost (LCY)", NpXmlDomMgt.GetXmlText(Element, 'unitcostlcy', 0, false), 9);
        Evaluate(TempSalesLine."VAT %", NpXmlDomMgt.GetXmlText(Element, 'vatpercent', 0, false), 9);
        Evaluate(TempSalesLine."Line Discount %", NpXmlDomMgt.GetXmlText(Element, 'linediscountpercent', 0, false), 9);
        Evaluate(TempSalesLine."Line Discount Amount", NpXmlDomMgt.GetXmlText(Element, 'linediscountamount', 0, false), 9);
        Evaluate(TempSalesLine.Amount, NpXmlDomMgt.GetXmlText(Element, 'amount', 0, false), 9);
        Evaluate(TempSalesLine."Amount Including VAT", NpXmlDomMgt.GetXmlText(Element, 'amountincludingvat', 0, false), 9);
        Evaluate(TempSalesLine."Allow Invoice Disc.", NpXmlDomMgt.GetXmlText(Element, 'allowinvoicedisc', 0, false), 9);
        Evaluate(TempSalesLine."Gross Weight", NpXmlDomMgt.GetXmlText(Element, 'grossweight', 0, false), 9);
        Evaluate(TempSalesLine."Net Weight", NpXmlDomMgt.GetXmlText(Element, 'netweight', 0, false), 9);
        Evaluate(TempSalesLine."Units per Parcel", NpXmlDomMgt.GetXmlText(Element, 'unitsperparcel', 0, false), 9);
        Evaluate(TempSalesLine."Unit Volume", NpXmlDomMgt.GetXmlText(Element, 'unitvolume', 0, false), 9);
        TempSalesLine."Shortcut Dimension 1 Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension1code', 0, false), 1, 20);
        TempSalesLine."Shortcut Dimension 2 Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'shortcutdimension2code', 0, false), 1, 20);
        TempSalesLine."Customer Price Group" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'customerpricegroup', 0, false), 1, 10);
        TempSalesLine."Job No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'jobno', 0, false), 1, 20);
        TempSalesLine."Work Type Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'worktypecode', 0, false), 1, 10);
        Evaluate(TempSalesLine."Recalculate Invoice Disc.", NpXmlDomMgt.GetXmlText(Element, 'recalculateinvoicedisc', 0, false), 9);
        Evaluate(TempSalesLine."Outstanding Amount", NpXmlDomMgt.GetXmlText(Element, 'outstandingamount', 0, false), 9);
        Evaluate(TempSalesLine."Qty. Shipped Not Invoiced", NpXmlDomMgt.GetXmlText(Element, 'qtyshippednotinvoiced', 0, false), 9);
        Evaluate(TempSalesLine."Shipped Not Invoiced", NpXmlDomMgt.GetXmlText(Element, 'shippednotinvoiced', 0, false), 9);
        Evaluate(TempSalesLine."Quantity Shipped", NpXmlDomMgt.GetXmlText(Element, 'quantityshipped', 0, false), 9);
        Evaluate(TempSalesLine."Quantity Invoiced", NpXmlDomMgt.GetXmlText(Element, 'quantityinvoiced', 0, false), 9);
        Evaluate(TempSalesLine."Profit %", NpXmlDomMgt.GetXmlText(Element, 'profitpercent', 0, false), 9);
        TempSalesLine."Bill-to Customer No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'billtocustomerno', 0, false), 1, 20);
        Evaluate(TempSalesLine."Inv. Discount Amount", NpXmlDomMgt.GetXmlText(Element, 'invdiscountamount', 0, false), 9);
        Evaluate(TempSalesLine."Drop Shipment", NpXmlDomMgt.GetXmlText(Element, 'dropshipment', 0, false), 9);
        TempSalesLine."Gen. Bus. Posting Group" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'genbuspostinggroup', 0, false), 1, 20);
        TempSalesLine."Gen. Prod. Posting Group" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'genprodpostinggroup', 0, false), 1, 20);
        Evaluate(TempSalesLine."VAT Calculation Type", NpXmlDomMgt.GetXmlText(Element, 'vatcalculationtype', 0, false), 9);
        TempSalesLine."Transaction Type" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'transactiontype', 0, false), 1, 10);
        TempSalesLine."Transport Method" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'transportmethod', 0, false), 1, 10);
        Evaluate(TempSalesLine."Attached to Line No.", NpXmlDomMgt.GetXmlText(Element, 'attachedtolineno', 0, false), 9);
        TempSalesLine."Exit Point" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'exitpoint', 0, false), 1, 10);
        TempSalesLine.Area := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'area', 0, false), 1, 10);
        TempSalesLine."Transaction Specification" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'transactionspecification', 0, false), 1, 10);
        TempSalesLine."Tax Category" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'taxcategory', 0, false), 1, 10);
        TempSalesLine."Tax Area Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'taxareacode', 0, false), 1, 20);
        Evaluate(TempSalesLine."Tax Liable", NpXmlDomMgt.GetXmlText(Element, 'taxliable', 0, false), 9);
        TempSalesLine."Tax Group Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'taxgroupcode', 0, false), 1, 20);
        TempSalesLine."VAT Clause Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'vatclausecode', 0, false), 1, 20);
        TempSalesLine."VAT Bus. Posting Group" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'vatbuspostinggroup', 0, false), 1, 20);
        TempSalesLine."VAT Prod. Posting Group" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'vatprodpostinggroup', 0, false), 1, 20);
        TempSalesLine."Currency Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'currencycode', 0, false), 1, 10);
        Evaluate(TempSalesLine."Outstanding Amount (LCY)", NpXmlDomMgt.GetXmlText(Element, 'outstandingamountlcy', 0, false), 9);
        Evaluate(TempSalesLine."Shipped Not Invoiced (LCY)", NpXmlDomMgt.GetXmlText(Element, 'shippednotinvoicedlcy', 0, false), 9);
        Evaluate(TempSalesLine.Reserve, NpXmlDomMgt.GetXmlText(Element, 'reserve', 0, false), 9);
        Evaluate(TempSalesLine."VAT Base Amount", NpXmlDomMgt.GetXmlText(Element, 'vatbaseamount', 0, false), 9);
        Evaluate(TempSalesLine."Unit Cost", NpXmlDomMgt.GetXmlText(Element, 'unitcost', 0, false), 9);
        Evaluate(TempSalesLine."System-Created Entry", NpXmlDomMgt.GetXmlText(Element, 'systemcreatedentry', 0, false), 9);
        Evaluate(TempSalesLine."Line Amount", NpXmlDomMgt.GetXmlText(Element, 'lineamount', 0, false), 9);
        Evaluate(TempSalesLine."VAT Difference", NpXmlDomMgt.GetXmlText(Element, 'vatdifference', 0, false), 9);
        Evaluate(TempSalesLine."Inv. Disc. Amount to Invoice", NpXmlDomMgt.GetXmlText(Element, 'invdiscamounttoinvoice', 0, false), 9);
        TempSalesLine."VAT Identifier" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'vatidentifier', 0, false), 1, 20);
        Evaluate(TempSalesLine."IC Partner Ref. Type", NpXmlDomMgt.GetXmlText(Element, 'icpartnerreftype', 0, false), 9);
        TempSalesLine."IC Item Reference No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'icpartnerreference', 0, false), 1, 50);
        Evaluate(TempSalesLine."Prepayment %", NpXmlDomMgt.GetXmlText(Element, 'prepaymentpercent', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. Line Amount", NpXmlDomMgt.GetXmlText(Element, 'prepmtlineamount', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. Amt. Inv.", NpXmlDomMgt.GetXmlText(Element, 'prepmtamtinv', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. Amt. Incl. VAT", NpXmlDomMgt.GetXmlText(Element, 'prepmtamtinclvat', 0, false), 9);
        Evaluate(TempSalesLine."Prepayment Amount", NpXmlDomMgt.GetXmlText(Element, 'prepaymentamount', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. VAT Base Amt.", NpXmlDomMgt.GetXmlText(Element, 'prepmtvatbaseamt', 0, false), 9);
        Evaluate(TempSalesLine."Prepayment VAT %", NpXmlDomMgt.GetXmlText(Element, 'prepaymentvatpercent', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. VAT Calc. Type", NpXmlDomMgt.GetXmlText(Element, 'prepmtvatcalctype', 0, false), 9);
        TempSalesLine."Prepayment VAT Identifier" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'prepaymentvatidentifier', 0, false), 1, 20);
        TempSalesLine."Prepayment Tax Area Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'prepaymenttaxareacode', 0, false), 1, 20);
        Evaluate(TempSalesLine."Prepayment Tax Liable", NpXmlDomMgt.GetXmlText(Element, 'prepaymenttaxliable', 0, false), 9);
        TempSalesLine."Prepayment Tax Group Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'prepaymenttaxgroupcode', 0, false), 1, 20);
        Evaluate(TempSalesLine."Prepmt Amt to Deduct", NpXmlDomMgt.GetXmlText(Element, 'prepmtamttodeduct', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt Amt Deducted", NpXmlDomMgt.GetXmlText(Element, 'prepmtamtdeducted', 0, false), 9);
        Evaluate(TempSalesLine."Prepayment Line", NpXmlDomMgt.GetXmlText(Element, 'prepaymentline', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. Amount Inv. Incl. VAT", NpXmlDomMgt.GetXmlText(Element, 'prepmtamountinvinclvat', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. Amount Inv. (LCY)", NpXmlDomMgt.GetXmlText(Element, 'prepmtamountinvlcy', 0, false), 9);
        TempSalesLine."IC Partner Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'icpartnercode', 0, false), 1, 20);
        Evaluate(TempSalesLine."Prepmt. VAT Amount Inv. (LCY)", NpXmlDomMgt.GetXmlText(Element, 'prepmtvatamountinvlcy', 0, false), 9);
        Evaluate(TempSalesLine."Prepayment VAT Difference", NpXmlDomMgt.GetXmlText(Element, 'prepaymentvatdifference', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt VAT Diff. to Deduct", NpXmlDomMgt.GetXmlText(Element, 'prepmtvatdifftodeduct', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt VAT Diff. Deducted", NpXmlDomMgt.GetXmlText(Element, 'prepmtvatdiffdeducted', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Assemble to Order", NpXmlDomMgt.GetXmlText(Element, 'qtytoassembletoorder', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Asm. to Order (Base)", NpXmlDomMgt.GetXmlText(Element, 'qtytoasmtoorderbase', 0, false), 9);
        TempSalesLine."Job Task No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'jobtaskno', 0, false), 1, 20);
        Evaluate(TempSalesLine."Job Contract Entry No.", NpXmlDomMgt.GetXmlText(Element, 'jobcontractentryno', 0, false), 9);
        TempSalesLine."Deferral Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'deferralcode', 0, false), 1, 10);
        Evaluate(TempSalesLine."Returns Deferral Start Date", NpXmlDomMgt.GetXmlText(Element, 'returnsdeferralstartdate', 0, false), 9);
        TempSalesLine."Variant Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'variantcode', 0, false), 1, 10);
        TempSalesLine."Bin Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'bincode', 0, false), 1, 20);
        Evaluate(TempSalesLine."Qty. per Unit of Measure", NpXmlDomMgt.GetXmlText(Element, 'qtyperunitofmeasure', 0, false), 9);
        Evaluate(TempSalesLine.Planned, NpXmlDomMgt.GetXmlText(Element, 'planned', 0, false), 9);
        TempSalesLine."Unit of Measure Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'unitofmeasurecode', 0, false), 1, 10);
        Evaluate(TempSalesLine."Quantity (Base)", NpXmlDomMgt.GetXmlText(Element, 'quantitybase', 0, false), 9);
        Evaluate(TempSalesLine."Outstanding Qty. (Base)", NpXmlDomMgt.GetXmlText(Element, 'outstandingqtybase', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Invoice (Base)", NpXmlDomMgt.GetXmlText(Element, 'qtytoinvoicebase', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Ship (Base)", NpXmlDomMgt.GetXmlText(Element, 'qtytoshipbase', 0, false), 9);
        Evaluate(TempSalesLine."Qty. Shipped Not Invd. (Base)", NpXmlDomMgt.GetXmlText(Element, 'qtyshippednotinvdbase', 0, false), 9);
        Evaluate(TempSalesLine."Qty. Shipped (Base)", NpXmlDomMgt.GetXmlText(Element, 'qtyshippedbase', 0, false), 9);
        Evaluate(TempSalesLine."Qty. Invoiced (Base)", NpXmlDomMgt.GetXmlText(Element, 'qtyinvoicedbase', 0, false), 9);
        Evaluate(TempSalesLine."FA Posting Date", NpXmlDomMgt.GetXmlText(Element, 'fapostingdate', 0, false), 9);
        TempSalesLine."Depreciation Book Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'depreciationbookcode', 0, false), 1, 10);
        Evaluate(TempSalesLine."Depr. until FA Posting Date", NpXmlDomMgt.GetXmlText(Element, 'depruntilfapostingdate', 0, false), 9);
        TempSalesLine."Duplicate in Depreciation Book" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'duplicateindepreciationbook', 0, false), 1, 10);
        Evaluate(TempSalesLine."Use Duplication List", NpXmlDomMgt.GetXmlText(Element, 'useduplicationlist', 0, false), 9);
        TempSalesLine."Responsibility Center" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'responsibilitycenter', 0, false), 1, 10);
        Evaluate(TempSalesLine."Out-of-Stock Substitution", NpXmlDomMgt.GetXmlText(Element, 'outofstocksubstitution', 0, false), 9);
        TempSalesLine."Originally Ordered No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'originallyorderedno', 0, false), 1, 20);
        TempSalesLine."Originally Ordered Var. Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'originallyorderedvarcode', 0, false), 1, 10);
        TempSalesLine."Item Reference No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'crossreferenceno', 0, false), 1, 50);
        TempSalesLine."Item Reference Unit of Measure" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'unitofmeasurecrossref', 0, false), 1, 10);
        Evaluate(TempSalesLine."Item Reference Type", NpXmlDomMgt.GetXmlText(Element, 'crossreferencetype', 0, false), 9);
        TempSalesLine."Item Reference Type No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'crossreferencetypeno', 0, false), 1, 30);
        TempSalesLine."Item Category Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'itemcategorycode', 0, false), 1, 20);
        Evaluate(TempSalesLine.Nonstock, NpXmlDomMgt.GetXmlText(Element, 'nonstock', 0, false), 9);
        TempSalesLine."Purchasing Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'purchasingcode', 0, false), 1, 10);
        Evaluate(TempSalesLine."Special Order", NpXmlDomMgt.GetXmlText(Element, 'specialorder', 0, false), 9);
        Evaluate(TempSalesLine."Completely Shipped", NpXmlDomMgt.GetXmlText(Element, 'completelyshipped', 0, false), 9);
        Evaluate(TempSalesLine."Requested Delivery Date", NpXmlDomMgt.GetXmlText(Element, 'requesteddeliverydate', 0, false), 9);
        Evaluate(TempSalesLine."Promised Delivery Date", NpXmlDomMgt.GetXmlText(Element, 'promiseddeliverydate', 0, false), 9);
        Evaluate(TempSalesLine."Shipping Time", NpXmlDomMgt.GetXmlText(Element, 'shippingtime', 0, false), 9);
        Evaluate(TempSalesLine."Outbound Whse. Handling Time", NpXmlDomMgt.GetXmlText(Element, 'outboundwhsehandlingtime', 0, false), 9);
        Evaluate(TempSalesLine."Planned Delivery Date", NpXmlDomMgt.GetXmlText(Element, 'planneddeliverydate', 0, false), 9);
        Evaluate(TempSalesLine."Planned Shipment Date", NpXmlDomMgt.GetXmlText(Element, 'plannedshipmentdate', 0, false), 9);
        TempSalesLine."Shipping Agent Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'shippingagentcode', 0, false), 1, 10);
        TempSalesLine."Shipping Agent Service Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'shippingagentservicecode', 0, false), 1, 10);
        Evaluate(TempSalesLine."Allow Item Charge Assignment", NpXmlDomMgt.GetXmlText(Element, 'allowitemchargeassignment', 0, false), 9);
        Evaluate(TempSalesLine."Return Qty. to Receive", NpXmlDomMgt.GetXmlText(Element, 'returnqtytoreceive', 0, false), 9);
        Evaluate(TempSalesLine."Return Qty. to Receive (Base)", NpXmlDomMgt.GetXmlText(Element, 'returnqtytoreceivebase', 0, false), 9);
        Evaluate(TempSalesLine."Return Qty. Rcd. Not Invd.", NpXmlDomMgt.GetXmlText(Element, 'returnqtyrcdnotinvd', 0, false), 9);
        Evaluate(TempSalesLine."Ret. Qty. Rcd. Not Invd.(Base)", NpXmlDomMgt.GetXmlText(Element, 'retqtyrcdnotinvdbase', 0, false), 9);
        Evaluate(TempSalesLine."Return Rcd. Not Invd.", NpXmlDomMgt.GetXmlText(Element, 'returnrcdnotinvd', 0, false), 9);
        Evaluate(TempSalesLine."Return Rcd. Not Invd. (LCY)", NpXmlDomMgt.GetXmlText(Element, 'returnrcdnotinvdlcy', 0, false), 9);
        Evaluate(TempSalesLine."Return Qty. Received", NpXmlDomMgt.GetXmlText(Element, 'returnqtyreceived', 0, false), 9);
        Evaluate(TempSalesLine."Return Qty. Received (Base)", NpXmlDomMgt.GetXmlText(Element, 'returnqtyreceivedbase', 0, false), 9);
        TempSalesLine."BOM Item No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'bomitemno', 0, false), 1, 20);
        TempSalesLine."Return Reason Code" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'returnreasoncode', 0, false), 1, 10);
        Evaluate(TempSalesLine."Allow Line Disc.", NpXmlDomMgt.GetXmlText(Element, 'allowlinedisc', 0, false), 9);
        TempSalesLine."Customer Disc. Group" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'customerdiscgroup', 0, false), 1, 20);

        OnBeforeInsertSalesLine(TempSalesLine, SalesHeader, SalesLine, Handeld);

        if not Handeld then begin
            if not SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", TempSalesLine."Line No.") then begin
                SalesLine.Init();
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := TempSalesLine."Line No.";
                SalesLine.Insert(true);
                SalesLine.Validate(Type, TempSalesLine.Type);
                SalesLine.Validate("No.", TempSalesLine."No.");
                SalesLine.Validate("Unit of Measure Code", TempSalesLine."Unit of Measure Code");
                SalesLine.Validate(Quantity, TempSalesLine.Quantity);
                SalesLine.Description := TempSalesLine.Description;
                SalesLine."Description 2" := TempSalesLine."Description 2";
                SalesLine.Validate("Unit Price", TempSalesLine."Unit Price");
                if TempSalesLine."Line Discount %" <> 0 then
                    SalesLine.Validate("Line Discount %", TempSalesLine."Line Discount %");
                SalesLine.Modify(true);
            end else begin
                SalesLine.SetHideValidationDialog(true);
                if SalesLine.Type <> TempSalesLine.Type then
                    SalesLine.Validate(Type, TempSalesLine.Type);
                if SalesLine."No." <> TempSalesLine."No." then
                    SalesLine.Validate("No.", TempSalesLine."No.");
                if SalesLine."Unit of Measure Code" <> TempSalesLine."Unit of Measure Code" then
                    SalesLine.Validate("Unit of Measure Code", TempSalesLine."Unit of Measure Code");
                if SalesLine.Quantity <> TempSalesLine.Quantity then
                    SalesLine.Validate(Quantity, TempSalesLine.Quantity);
                if SalesLine.Description <> TempSalesLine.Description then
                    SalesLine.Description := TempSalesLine.Description;
                if SalesLine."Description 2" <> TempSalesLine."Description 2" then
                    SalesLine."Description 2" := TempSalesLine."Description 2";
                if SalesLine."Unit Price" <> TempSalesLine."Unit Price" then
                    SalesLine.Validate("Unit Price", TempSalesLine."Unit Price");
                if SalesLine."Line Discount %" <> TempSalesLine."Line Discount %" then
                    SalesLine.Validate("Line Discount %", TempSalesLine."Line Discount %");
                SalesLine.Modify(true);
            end;
        end;

        OnAfterInsertSalesLine(TempSalesLine, SalesLine);
    end;

    local procedure InsertReservationEntry(Element: XmlElement; SalesLine: Record "Sales Line")
    var
        TempReservationEntry: Record "Reservation Entry" temporary;
        ReservationEntry: Record "Reservation Entry";
        ReservationMgt: Codeunit "Reservation Management";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        CurrentEntryStatus: Enum "Reservation Status";
    begin
        Evaluate(TempReservationEntry."Source Type", NpXmlDomMgt.GetXmlAttributeText(Element, 'sourcetype', false), 9);
        Evaluate(TempReservationEntry."Source Subtype", NpXmlDomMgt.GetXmlAttributeText(Element, 'sourcesubtype', false), 9);
        TempReservationEntry."Source ID" := SalesLine."Document No.";
        TempReservationEntry."Source Batch Name" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'sourcebatchname', false), 1, 10);
        Evaluate(TempReservationEntry."Source Prod. Order Line", NpXmlDomMgt.GetXmlAttributeText(Element, 'sourceprodorderline', false), 9);
        TempReservationEntry."Source Ref. No." := SalesLine."Line No.";
        Evaluate(TempReservationEntry.Positive, NpXmlDomMgt.GetXmlAttributeText(Element, 'positive', false), 9);
        TempReservationEntry."Item No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'itemno', 0, false), 1, 20);
        TempReservationEntry."Location Code" := SalesLine."Location Code";
        Evaluate(TempReservationEntry."Quantity (Base)", NpXmlDomMgt.GetXmlText(Element, 'quantitybase', 0, false), 9);
        Evaluate(TempReservationEntry."Reservation Status", NpXmlDomMgt.GetXmlText(Element, 'reservationstatus', 0, false), 9);
        TempReservationEntry.Description := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'description', 0, false), 1, 100);
        Evaluate(TempReservationEntry."Creation Date", NpXmlDomMgt.GetXmlText(Element, 'creationdate', 0, false), 9);
        Evaluate(TempReservationEntry."Expected Receipt Date", NpXmlDomMgt.GetXmlText(Element, 'expectedreceiptdate', 0, false), 9);
        TempReservationEntry."Shipment Date" := SalesLine."Shipment Date";
        TempReservationEntry."Serial No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'serialno', 0, false), 1, 50);
        TempReservationEntry."Created By" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'createdby', 0, false), 1, 50);
        TempReservationEntry."Changed By" := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'changedby', 0, false), 1, 50);
        TempReservationEntry."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
        Evaluate(TempReservationEntry.Quantity, NpXmlDomMgt.GetXmlText(Element, 'quantity', 0, false), 9);
        Evaluate(TempReservationEntry.Binding, NpXmlDomMgt.GetXmlText(Element, 'binding', 0, false), 9);
        Evaluate(TempReservationEntry."Suppressed Action Msg.", NpXmlDomMgt.GetXmlText(Element, 'suppressedactionmsg', 0, false), 9);
        Evaluate(TempReservationEntry."Planning Flexibility", NpXmlDomMgt.GetXmlText(Element, 'planningflexibility', 0, false), 9);
        Evaluate(TempReservationEntry."Warranty Date", NpXmlDomMgt.GetXmlText(Element, 'warrantydate', 0, false), 9);
        Evaluate(TempReservationEntry."Expiration Date", NpXmlDomMgt.GetXmlText(Element, 'expirationdate', 0, false), 9);
        Evaluate(TempReservationEntry."Qty. to Handle (Base)", NpXmlDomMgt.GetXmlText(Element, 'qtytohandlebase', 0, false), 9);
        Evaluate(TempReservationEntry."Qty. to Invoice (Base)", NpXmlDomMgt.GetXmlText(Element, 'qtytoinvoicebase', 0, false), 9);
        Evaluate(TempReservationEntry."Quantity Invoiced (Base)", NpXmlDomMgt.GetXmlText(Element, 'quantityinvoicedbase', 0, false), 9);
        TempReservationEntry."New Serial No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'newserialno', 0, false), 1, 50);
        TempReservationEntry."New Lot No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'newlotno', 0, false), 1, 50);
        Evaluate(TempReservationEntry."Disallow Cancellation", NpXmlDomMgt.GetXmlText(Element, 'disallowcancellation', 0, false), 9);
        TempReservationEntry."Lot No." := CopyStr(NpXmlDomMgt.GetXmlText(Element, 'lotno', 0, false), 1, 50);
        TempReservationEntry."Variant Code" := SalesLine."Variant Code";
        Evaluate(TempReservationEntry.Correction, NpXmlDomMgt.GetXmlText(Element, 'correction', 0, false), 9);
        Evaluate(TempReservationEntry."New Expiration Date", NpXmlDomMgt.GetXmlText(Element, 'newexpirationdate', 0, false), 9);
        TempReservationEntry.UpdateItemTracking();

        if ItemTrackingMgt.IsOrderNetworkEntity(TempReservationEntry."Source Type", SalesLine."Document Type".AsInteger()) and not SalesLine."Drop Shipment" then
            CurrentEntryStatus := CurrentEntryStatus::Surplus
        else
            CurrentEntryStatus := CurrentEntryStatus::Prospect;

        ReservationEntry := TempReservationEntry;
        ReservationEntry.SetPointerFilter();
        ReservationEntry.SetTrackingFilterFromReservEntry(ReservationEntry);
        if not ReservationEntry.FindFirst() then
            CreateReservationEntry(TempReservationEntry, CurrentEntryStatus)
        else begin
            ReservationMgt.SetItemTrackingHandling(1);
            ReservationMgt.DeleteReservEntries(true, 0, ReservationEntry);
            CreateReservationEntry(TempReservationEntry, CurrentEntryStatus);
        end;
    end;

    local procedure CreateReservationEntry(var ReservationEntry: Record "Reservation Entry"; CurrentEntryStatus: Enum "Reservation Status")
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        CreateReservEntry.SetDates(
          ReservationEntry."Warranty Date", ReservationEntry."Expiration Date");
        CreateReservEntry.CreateReservEntryFor(
          ReservationEntry."Source Type",
          ReservationEntry."Source Subtype",
          ReservationEntry."Source ID",
          ReservationEntry."Source Batch Name",
          ReservationEntry."Source Prod. Order Line",
          ReservationEntry."Source Ref. No.",
          ReservationEntry."Qty. per Unit of Measure",
          0,
          Abs(ReservationEntry."Quantity (Base)"),
          ReservationEntry);
        CreateReservEntry.CreateEntry(
          ReservationEntry."Item No.",
          ReservationEntry."Variant Code",
          ReservationEntry."Location Code",
          ReservationEntry.Description,
          0D,
          ReservationEntry."Shipment Date",
          0,
          CurrentEntryStatus);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesHeader(var TempSalesHeader: Record "Sales Header"; var SalesHeader: Record "Sales Header"; var Handeld: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesHeader(var TempSalesHeader: Record "Sales Header"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesLine(var TempSalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handeld: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesLine(var TempSalesLine: Record "Sales Line"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateSalesHeader(var SalesHeader: Record "Sales Header")
    begin
    end;
}

