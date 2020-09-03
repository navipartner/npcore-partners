codeunit 6150906 "NPR HC Sales Doc. Mgt."
{
    // NPR5.38/BR  /20171031 CASE 295007 HQ Connector Created Object
    // NPR5.48/TJ  /20181221 CASE 336517 Added sales lines/tracking
    // NPR5.48/TJ  /20190129 CASE 340446 Changes for version 2018
    // NPR5.52/TJ  /20190910 CASE 365896 Added publisher OnAfterUpdateSalesHeader

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet "NPRNetXmlDocument";
    begin
        if LoadXmlDoc(XmlDoc) then
            UpdateSales(XmlDoc);
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

    local procedure UpdateSales(XmlDoc: DotNet "NPRNetXmlDocument")
    var
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
    begin
        if IsNull(XmlDoc) then
            exit;

        XmlElement := XmlDoc.DocumentElement;

        if IsNull(XmlElement) then
            exit;

        if not NpXmlDomMgt.FindNodes(XmlElement, 'salesdocumentimport', XmlNodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(XmlElement, 'salesdocument', XmlNodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(XmlElement, 'insertsalesdocument', XmlNodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(XmlElement, 'salesheader', XmlNodeList) then
            exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            UpdateSalesHeader(XmlElement);
        end;
    end;

    local procedure UpdateSalesHeader(ItemXmlElement: DotNet NPRNetXmlElement) Imported: Boolean
    var
        SalesHeader: Record "Sales Header";
        ChildXmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
    begin
        if IsNull(ItemXmlElement) then
            exit(false);

        InsertSalesHeader(ItemXmlElement, SalesHeader);

        //-NPR5.48 [336517]
        NpXmlDomMgt.FindNodes(ItemXmlElement, 'salesline', XmlNodeList);
        for i := 0 to XmlNodeList.Count - 1 do begin
            ChildXmlElement := XmlNodeList.ItemOf(i);
            UpdateSalesLine(ChildXmlElement, SalesHeader);
        end;
        //+NPR5.48 [336517]

        Commit;

        //-NPR5.52 [365896]
        OnAfterUpdateSalesHeader(SalesHeader);
        //+NPR5.52 [365896]

        exit(true);
    end;

    local procedure UpdateSalesLine(ItemXmlElement: DotNet NPRNetXmlElement; SalesHeader: Record "Sales Header"): Boolean
    var
        TempSalesLine: Record "Sales Line" temporary;
        SalesLine: Record "Sales Line";
        ChildXmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
        XPath: Text;
    begin
        //-NPR5.48 [336517]
        if IsNull(ItemXmlElement) then
            exit(false);

        InsertSalesLine(ItemXmlElement, SalesHeader, SalesLine, TempSalesLine);
        XPath := StrSubstNo('reservationentry[@sourcetype="37" and @sourcesubtype="%1" and @sourceid="%2" and @sourcebatchname="" and @sourceprodorderline="0" and @sourcerefno="%3" and @positive="false"]',
                            Format(TempSalesLine."Document Type", 0, 2), TempSalesLine."Document No.", Format(TempSalesLine."Line No."));
        NpXmlDomMgt.FindNodes(ItemXmlElement, XPath, XmlNodeList);
        for i := 0 to XmlNodeList.Count - 1 do begin
            ChildXmlElement := XmlNodeList.ItemOf(i);
            UpdateReservationEntry(ChildXmlElement, SalesLine);
        end;

        exit(true);
        //+NPR5.48 [336517]
    end;

    local procedure UpdateReservationEntry(ItemXmlElement: DotNet NPRNetXmlElement; SalesLine: Record "Sales Line"): Boolean
    begin
        //-NPR5.48 [336517]
        if IsNull(ItemXmlElement) then
            exit(false);

        InsertReservationEntry(ItemXmlElement, SalesLine);

        exit(true);
        //+NPR5.48 [336517]
    end;

    local procedure "--- Database"()
    begin
    end;

    local procedure InsertSalesHeader(XmlElement: DotNet NPRNetXmlElement; var SalesHeader: Record "Sales Header")
    var
        TempSalesHeader: Record "Sales Header" temporary;
        Handeld: Boolean;
    begin
        //-NPR5.48 [336517]
        //EVALUATE(TempSalesHeader."Document Type",NpXmlDomMgt.GetXmlText(XmlElement,'documenttype',0,FALSE),9);
        //EVALUATE(TempSalesHeader."No.",NpXmlDomMgt.GetXmlText(XmlElement,'documentno',0,FALSE),9);
        Evaluate(TempSalesHeader."Document Type", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'documenttype', false), 9);
        TempSalesHeader."No." := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'documentno', false);
        //+NPR5.48 [336517]
        Evaluate(TempSalesHeader."Sell-to Customer No.", NpXmlDomMgt.GetXmlText(XmlElement, 'selltocustomerno', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Customer No.", NpXmlDomMgt.GetXmlText(XmlElement, 'billtocustomerno', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Name", NpXmlDomMgt.GetXmlText(XmlElement, 'billtoname', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Name 2", NpXmlDomMgt.GetXmlText(XmlElement, 'billtoname2', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Address", NpXmlDomMgt.GetXmlText(XmlElement, 'billtoaddress', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Address 2", NpXmlDomMgt.GetXmlText(XmlElement, 'billtoaddress2', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to City", NpXmlDomMgt.GetXmlText(XmlElement, 'billtocity', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Contact", NpXmlDomMgt.GetXmlText(XmlElement, 'billtocontact', 0, false), 9);
        Evaluate(TempSalesHeader."Your Reference", NpXmlDomMgt.GetXmlText(XmlElement, 'yourreference', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Code", NpXmlDomMgt.GetXmlText(XmlElement, 'shiptocode', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Name", NpXmlDomMgt.GetXmlText(XmlElement, 'shiptoname', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Name 2", NpXmlDomMgt.GetXmlText(XmlElement, 'shiptoname2', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Address", NpXmlDomMgt.GetXmlText(XmlElement, 'shiptoaddress', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Address 2", NpXmlDomMgt.GetXmlText(XmlElement, 'shiptoaddress2', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to City", NpXmlDomMgt.GetXmlText(XmlElement, 'shiptocity', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Contact", NpXmlDomMgt.GetXmlText(XmlElement, 'shiptocontact', 0, false), 9);
        Evaluate(TempSalesHeader."Order Date", NpXmlDomMgt.GetXmlText(XmlElement, 'orderdate', 0, false), 9);
        Evaluate(TempSalesHeader."Posting Date", NpXmlDomMgt.GetXmlText(XmlElement, 'postingdate', 0, false), 9);
        Evaluate(TempSalesHeader."Shipment Date", NpXmlDomMgt.GetXmlText(XmlElement, 'shipmentdate', 0, false), 9);
        Evaluate(TempSalesHeader."Posting Description", NpXmlDomMgt.GetXmlText(XmlElement, 'postingdescription', 0, false), 9);
        Evaluate(TempSalesHeader."Payment Terms Code", NpXmlDomMgt.GetXmlText(XmlElement, 'paymenttermscode', 0, false), 9);
        Evaluate(TempSalesHeader."Due Date", NpXmlDomMgt.GetXmlText(XmlElement, 'duedate', 0, false), 9);
        Evaluate(TempSalesHeader."Payment Discount %", NpXmlDomMgt.GetXmlText(XmlElement, 'paymentdiscount', 0, false), 9);
        Evaluate(TempSalesHeader."Pmt. Discount Date", NpXmlDomMgt.GetXmlText(XmlElement, 'pmtdiscountdate', 0, false), 9);
        Evaluate(TempSalesHeader."Shipment Method Code", NpXmlDomMgt.GetXmlText(XmlElement, 'shipmentmethod', 0, false), 9);
        Evaluate(TempSalesHeader."Location Code", NpXmlDomMgt.GetXmlText(XmlElement, 'locationcode', 0, false), 9);
        Evaluate(TempSalesHeader."Shortcut Dimension 1 Code", NpXmlDomMgt.GetXmlText(XmlElement, 'shortcutdimension1', 0, false), 9);
        Evaluate(TempSalesHeader."Shortcut Dimension 2 Code", NpXmlDomMgt.GetXmlText(XmlElement, 'shortcutdimension2', 0, false), 9);
        Evaluate(TempSalesHeader."Customer Posting Group", NpXmlDomMgt.GetXmlText(XmlElement, 'customerpostinggroup', 0, false), 9);
        Evaluate(TempSalesHeader."Currency Code", NpXmlDomMgt.GetXmlText(XmlElement, 'currencycode', 0, false), 9);
        Evaluate(TempSalesHeader."Currency Factor", NpXmlDomMgt.GetXmlText(XmlElement, 'currencyfactor', 0, false), 9);
        Evaluate(TempSalesHeader."Customer Price Group", NpXmlDomMgt.GetXmlText(XmlElement, 'customerpricegroup', 0, false), 9);
        Evaluate(TempSalesHeader."Prices Including VAT", NpXmlDomMgt.GetXmlText(XmlElement, 'pricesincludingvat', 0, false), 9);
        Evaluate(TempSalesHeader."Invoice Disc. Code", NpXmlDomMgt.GetXmlText(XmlElement, 'invoicedisccode', 0, false), 9);
        Evaluate(TempSalesHeader."Customer Disc. Group", NpXmlDomMgt.GetXmlText(XmlElement, 'customerdisccode', 0, false), 9);
        Evaluate(TempSalesHeader."Language Code", NpXmlDomMgt.GetXmlText(XmlElement, 'languagecode', 0, false), 9);
        Evaluate(TempSalesHeader."Salesperson Code", NpXmlDomMgt.GetXmlText(XmlElement, 'salespersoncode', 0, false), 9);
        Evaluate(TempSalesHeader."Order Class", NpXmlDomMgt.GetXmlText(XmlElement, 'orderclass', 0, false), 9);
        Evaluate(TempSalesHeader."On Hold", NpXmlDomMgt.GetXmlText(XmlElement, 'onhold', 0, false), 9);
        Evaluate(TempSalesHeader."Bal. Account No.", NpXmlDomMgt.GetXmlText(XmlElement, 'balaccountno', 0, false), 9);
        //-NPR5.48 [336517]
        //EVALUATE(TempSalesHeader."Recalculate Invoice Disc.",NpXmlDomMgt.GetXmlText(XmlElement,'recalulatieinvoicedisc',0,FALSE),9);
        //+NPR5.48 [336517]
        Evaluate(TempSalesHeader."VAT Registration No.", NpXmlDomMgt.GetXmlText(XmlElement, 'vatregistrationno', 0, false), 9);
        Evaluate(TempSalesHeader."Combine Shipments", NpXmlDomMgt.GetXmlText(XmlElement, 'combineshipments', 0, false), 9);
        Evaluate(TempSalesHeader."Reason Code", NpXmlDomMgt.GetXmlText(XmlElement, 'reasoncode', 0, false), 9);
        Evaluate(TempSalesHeader."Gen. Bus. Posting Group", NpXmlDomMgt.GetXmlText(XmlElement, 'genbuspostinggroup', 0, false), 9);
        Evaluate(TempSalesHeader."EU 3-Party Trade", NpXmlDomMgt.GetXmlText(XmlElement, 'eu3partytrade', 0, false), 9);
        Evaluate(TempSalesHeader."Transaction Type", NpXmlDomMgt.GetXmlText(XmlElement, 'transactiontype', 0, false), 9);
        Evaluate(TempSalesHeader."Transport Method", NpXmlDomMgt.GetXmlText(XmlElement, 'transportmethod', 0, false), 9);
        Evaluate(TempSalesHeader."VAT Country/Region Code", NpXmlDomMgt.GetXmlText(XmlElement, 'vatcountryregioncode', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Customer Name", NpXmlDomMgt.GetXmlText(XmlElement, 'selltocustomername', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Customer Name 2", NpXmlDomMgt.GetXmlText(XmlElement, 'selltocustomername2', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Address", NpXmlDomMgt.GetXmlText(XmlElement, 'selltoaddress', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Address 2", NpXmlDomMgt.GetXmlText(XmlElement, 'selltoaddress2', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to City", NpXmlDomMgt.GetXmlText(XmlElement, 'selltocity', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Contact", NpXmlDomMgt.GetXmlText(XmlElement, 'selltocontact', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Post Code", NpXmlDomMgt.GetXmlText(XmlElement, 'billtopostcode', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to County", NpXmlDomMgt.GetXmlText(XmlElement, 'billtocounty', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Country/Region Code", NpXmlDomMgt.GetXmlText(XmlElement, 'billtocountryregioncode', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Post Code", NpXmlDomMgt.GetXmlText(XmlElement, 'selltopostcode', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to County", NpXmlDomMgt.GetXmlText(XmlElement, 'selltocounty', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Country/Region Code", NpXmlDomMgt.GetXmlText(XmlElement, 'selltocountryregioncode', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Post Code", NpXmlDomMgt.GetXmlText(XmlElement, 'shiptopostcode', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to County", NpXmlDomMgt.GetXmlText(XmlElement, 'shiptocounty', 0, false), 9);
        Evaluate(TempSalesHeader."Ship-to Country/Region Code", NpXmlDomMgt.GetXmlText(XmlElement, 'shiptocountryregioncode', 0, false), 9);
        Evaluate(TempSalesHeader."Bal. Account Type", NpXmlDomMgt.GetXmlText(XmlElement, 'balaccounttype', 0, false), 9);
        Evaluate(TempSalesHeader."Exit Point", NpXmlDomMgt.GetXmlText(XmlElement, 'exitpoint', 0, false), 9);
        Evaluate(TempSalesHeader."Document Date", NpXmlDomMgt.GetXmlText(XmlElement, 'documentdate', 0, false), 9);
        Evaluate(TempSalesHeader."External Document No.", NpXmlDomMgt.GetXmlText(XmlElement, 'externaldocumentno', 0, false), 9);
        Evaluate(TempSalesHeader.Area, NpXmlDomMgt.GetXmlText(XmlElement, 'area', 0, false), 9);
        Evaluate(TempSalesHeader."Transaction Specification", NpXmlDomMgt.GetXmlText(XmlElement, 'transactionspecification', 0, false), 9);
        Evaluate(TempSalesHeader."Payment Method Code", NpXmlDomMgt.GetXmlText(XmlElement, 'paymentmethodcode', 0, false), 9);
        Evaluate(TempSalesHeader."Shipping Agent Code", NpXmlDomMgt.GetXmlText(XmlElement, 'shippingagentcode', 0, false), 9);
        Evaluate(TempSalesHeader."Package Tracking No.", NpXmlDomMgt.GetXmlText(XmlElement, 'packagetrackingno', 0, false), 9);
        Evaluate(TempSalesHeader."No. Series", NpXmlDomMgt.GetXmlText(XmlElement, 'noseries', 0, false), 9);
        Evaluate(TempSalesHeader."Posting No. Series", NpXmlDomMgt.GetXmlText(XmlElement, 'postingnoseries', 0, false), 9);
        Evaluate(TempSalesHeader."Shipping No. Series", NpXmlDomMgt.GetXmlText(XmlElement, 'shippingnoseries', 0, false), 9);
        Evaluate(TempSalesHeader."Tax Area Code", NpXmlDomMgt.GetXmlText(XmlElement, 'taxareacode', 0, false), 9);
        Evaluate(TempSalesHeader."Tax Liable", NpXmlDomMgt.GetXmlText(XmlElement, 'taxliable', 0, false), 9);
        Evaluate(TempSalesHeader."VAT Bus. Posting Group", NpXmlDomMgt.GetXmlText(XmlElement, 'vatbuspostinggroup', 0, false), 9);
        Evaluate(TempSalesHeader.Reserve, NpXmlDomMgt.GetXmlText(XmlElement, 'reserve', 0, false), 9);
        Evaluate(TempSalesHeader."Applies-to ID", NpXmlDomMgt.GetXmlText(XmlElement, 'appliestoid', 0, false), 9);
        Evaluate(TempSalesHeader."VAT Base Discount %", NpXmlDomMgt.GetXmlText(XmlElement, 'vatbasediscountperc', 0, false), 9);
        Evaluate(TempSalesHeader.Status, NpXmlDomMgt.GetXmlText(XmlElement, 'status', 0, false), 9);
        Evaluate(TempSalesHeader."Invoice Discount Calculation", NpXmlDomMgt.GetXmlText(XmlElement, 'invoicediscountcalculation', 0, false), 9);
        Evaluate(TempSalesHeader."Invoice Discount Value", NpXmlDomMgt.GetXmlText(XmlElement, 'invoicediscountvalue', 0, false), 9);
        Evaluate(TempSalesHeader."Quote No.", NpXmlDomMgt.GetXmlText(XmlElement, 'quoteno', 0, false), 9);
        //EVALUATE(TempSalesHeader."Credit Card No.",NpXmlDomMgt.GetXmlText(XmlElement,'creditcardno',0,FALSE),9); //NAV 2017
        Evaluate(TempSalesHeader."Sell-to Customer Template Code", NpXmlDomMgt.GetXmlText(XmlElement, 'selltocustomertemplatecode', 0, false), 9);
        Evaluate(TempSalesHeader."Sell-to Contact No.", NpXmlDomMgt.GetXmlText(XmlElement, 'selltocontactno', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Contact No.", NpXmlDomMgt.GetXmlText(XmlElement, 'billtocontactno', 0, false), 9);
        Evaluate(TempSalesHeader."Bill-to Customer Template Code", NpXmlDomMgt.GetXmlText(XmlElement, 'billtocustomertemplatecode', 0, false), 9);
        Evaluate(TempSalesHeader."Opportunity No.", NpXmlDomMgt.GetXmlText(XmlElement, 'opportunityno', 0, false), 9);
        Evaluate(TempSalesHeader."Responsibility Center", NpXmlDomMgt.GetXmlText(XmlElement, 'responisbilitycenter', 0, false), 9);
        Evaluate(TempSalesHeader."Shipping Advice", NpXmlDomMgt.GetXmlText(XmlElement, 'shippingadvice', 0, false), 9);
        Evaluate(TempSalesHeader."Requested Delivery Date", NpXmlDomMgt.GetXmlText(XmlElement, 'requesteddeliverydate', 0, false), 9);
        Evaluate(TempSalesHeader."Promised Delivery Date", NpXmlDomMgt.GetXmlText(XmlElement, 'promiseddeliverydate', 0, false), 9);
        Evaluate(TempSalesHeader."Shipping Time", NpXmlDomMgt.GetXmlText(XmlElement, 'shippingtime', 0, false), 9);
        Evaluate(TempSalesHeader."Outbound Whse. Handling Time", NpXmlDomMgt.GetXmlText(XmlElement, 'outboundwhsehandlingtime', 0, false), 9);
        Evaluate(TempSalesHeader."Shipping Agent Service Code", NpXmlDomMgt.GetXmlText(XmlElement, 'shippingagenetservicecode', 0, false), 9);
        //-NPR5.48 [336517]
        //EVALUATE(TempSalesHeader."Late Order Shipping",NpXmlDomMgt.GetXmlText(XmlElement,'lateordershipping',0,FALSE),9);
        //+NPR5.48 [336517]
        Evaluate(TempSalesHeader."Allow Line Disc.", NpXmlDomMgt.GetXmlText(XmlElement, 'allowlinedisc', 0, false), 9);

        //-NPR5.48 [336517]
        OnBeforeInsertSalesHeader(TempSalesHeader, SalesHeader, Handeld);
        //Record insert
        //IF NOT SalesHeader.GET(TempSalesHeader."Document Type",TempSalesHeader."No.") THEN BEGIN
        if not Handeld then begin
            SalesHeader.SetRange("External Document No.", TempSalesHeader."External Document No.");
            if not SalesHeader.FindFirst then begin
                //+NPR5.48 [336517]
                SalesHeader.Init;
                SalesHeader.Validate("Document Type", TempSalesHeader."Document Type");
                //-NPR5.48 [336517]
                //SalesHeader.VALIDATE("No.",TempSalesHeader."No.");
                //SalesHeader.INSERT;
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
            SalesHeader.Reset;
            //+NPR5.48 [336517]
        end;

        //-NPR5.48 [336517]
        OnAfterInsertSalesHeader(TempSalesHeader, SalesHeader);
        //+NPR5.48 [336517]
    end;

    local procedure InsertSalesLine(XmlElement: DotNet NPRNetXmlElement; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line")
    var
        Handeld: Boolean;
    begin
        //-NPR5.48 [336517]
        Evaluate(TempSalesLine."Document Type", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'documenttype', false), 9);
        TempSalesLine."Document No." := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'documentno', false);
        Evaluate(TempSalesLine."Line No.", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'lineno', false), 9);
        Evaluate(TempSalesLine.Type, NpXmlDomMgt.GetXmlText(XmlElement, 'type', 0, false), 9);
        TempSalesLine."No." := NpXmlDomMgt.GetXmlText(XmlElement, 'no', 0, false);
        TempSalesLine."Location Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'locationcode', 0, false);
        TempSalesLine."Posting Group" := NpXmlDomMgt.GetXmlText(XmlElement, 'postinggroup', 0, false);
        Evaluate(TempSalesLine."Shipment Date", NpXmlDomMgt.GetXmlText(XmlElement, 'shipmentdate', 0, false), 9);
        TempSalesLine.Description := NpXmlDomMgt.GetXmlText(XmlElement, 'description', 0, false);
        TempSalesLine."Description 2" := NpXmlDomMgt.GetXmlText(XmlElement, 'description2', 0, false);
        TempSalesLine."Unit of Measure" := NpXmlDomMgt.GetXmlText(XmlElement, 'unitofmeasure', 0, false);
        Evaluate(TempSalesLine.Quantity, NpXmlDomMgt.GetXmlText(XmlElement, 'quantity', 0, false), 9);
        Evaluate(TempSalesLine."Outstanding Quantity", NpXmlDomMgt.GetXmlText(XmlElement, 'outstandingquantity', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Invoice", NpXmlDomMgt.GetXmlText(XmlElement, 'qtytoinvoice', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Ship", NpXmlDomMgt.GetXmlText(XmlElement, 'qtytoship', 0, false), 9);
        Evaluate(TempSalesLine."Unit Price", NpXmlDomMgt.GetXmlText(XmlElement, 'unitprice', 0, false), 9);
        Evaluate(TempSalesLine."Unit Cost (LCY)", NpXmlDomMgt.GetXmlText(XmlElement, 'unitcostlcy', 0, false), 9);
        Evaluate(TempSalesLine."VAT %", NpXmlDomMgt.GetXmlText(XmlElement, 'vatpercent', 0, false), 9);
        Evaluate(TempSalesLine."Line Discount %", NpXmlDomMgt.GetXmlText(XmlElement, 'linediscountpercent', 0, false), 9);
        Evaluate(TempSalesLine."Line Discount Amount", NpXmlDomMgt.GetXmlText(XmlElement, 'linediscountamount', 0, false), 9);
        Evaluate(TempSalesLine.Amount, NpXmlDomMgt.GetXmlText(XmlElement, 'amount', 0, false), 9);
        Evaluate(TempSalesLine."Amount Including VAT", NpXmlDomMgt.GetXmlText(XmlElement, 'amountincludingvat', 0, false), 9);
        Evaluate(TempSalesLine."Allow Invoice Disc.", NpXmlDomMgt.GetXmlText(XmlElement, 'allowinvoicedisc', 0, false), 9);
        Evaluate(TempSalesLine."Gross Weight", NpXmlDomMgt.GetXmlText(XmlElement, 'grossweight', 0, false), 9);
        Evaluate(TempSalesLine."Net Weight", NpXmlDomMgt.GetXmlText(XmlElement, 'netweight', 0, false), 9);
        Evaluate(TempSalesLine."Units per Parcel", NpXmlDomMgt.GetXmlText(XmlElement, 'unitsperparcel', 0, false), 9);
        Evaluate(TempSalesLine."Unit Volume", NpXmlDomMgt.GetXmlText(XmlElement, 'unitvolume', 0, false), 9);
        TempSalesLine."Shortcut Dimension 1 Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'shortcutdimension1code', 0, false);
        TempSalesLine."Shortcut Dimension 2 Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'shortcutdimension2code', 0, false);
        TempSalesLine."Customer Price Group" := NpXmlDomMgt.GetXmlText(XmlElement, 'customerpricegroup', 0, false);
        TempSalesLine."Job No." := NpXmlDomMgt.GetXmlText(XmlElement, 'jobno', 0, false);
        TempSalesLine."Work Type Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'worktypecode', 0, false);
        Evaluate(TempSalesLine."Recalculate Invoice Disc.", NpXmlDomMgt.GetXmlText(XmlElement, 'recalculateinvoicedisc', 0, false), 9);
        Evaluate(TempSalesLine."Outstanding Amount", NpXmlDomMgt.GetXmlText(XmlElement, 'outstandingamount', 0, false), 9);
        Evaluate(TempSalesLine."Qty. Shipped Not Invoiced", NpXmlDomMgt.GetXmlText(XmlElement, 'qtyshippednotinvoiced', 0, false), 9);
        Evaluate(TempSalesLine."Shipped Not Invoiced", NpXmlDomMgt.GetXmlText(XmlElement, 'shippednotinvoiced', 0, false), 9);
        Evaluate(TempSalesLine."Quantity Shipped", NpXmlDomMgt.GetXmlText(XmlElement, 'quantityshipped', 0, false), 9);
        Evaluate(TempSalesLine."Quantity Invoiced", NpXmlDomMgt.GetXmlText(XmlElement, 'quantityinvoiced', 0, false), 9);
        Evaluate(TempSalesLine."Profit %", NpXmlDomMgt.GetXmlText(XmlElement, 'profitpercent', 0, false), 9);
        TempSalesLine."Bill-to Customer No." := NpXmlDomMgt.GetXmlText(XmlElement, 'billtocustomerno', 0, false);
        Evaluate(TempSalesLine."Inv. Discount Amount", NpXmlDomMgt.GetXmlText(XmlElement, 'invdiscountamount', 0, false), 9);
        Evaluate(TempSalesLine."Drop Shipment", NpXmlDomMgt.GetXmlText(XmlElement, 'dropshipment', 0, false), 9);
        TempSalesLine."Gen. Bus. Posting Group" := NpXmlDomMgt.GetXmlText(XmlElement, 'genbuspostinggroup', 0, false);
        TempSalesLine."Gen. Prod. Posting Group" := NpXmlDomMgt.GetXmlText(XmlElement, 'genprodpostinggroup', 0, false);
        Evaluate(TempSalesLine."VAT Calculation Type", NpXmlDomMgt.GetXmlText(XmlElement, 'vatcalculationtype', 0, false), 9);
        TempSalesLine."Transaction Type" := NpXmlDomMgt.GetXmlText(XmlElement, 'transactiontype', 0, false);
        TempSalesLine."Transport Method" := NpXmlDomMgt.GetXmlText(XmlElement, 'transportmethod', 0, false);
        Evaluate(TempSalesLine."Attached to Line No.", NpXmlDomMgt.GetXmlText(XmlElement, 'attachedtolineno', 0, false), 9);
        TempSalesLine."Exit Point" := NpXmlDomMgt.GetXmlText(XmlElement, 'exitpoint', 0, false);
        TempSalesLine.Area := NpXmlDomMgt.GetXmlText(XmlElement, 'area', 0, false);
        TempSalesLine."Transaction Specification" := NpXmlDomMgt.GetXmlText(XmlElement, 'transactionspecification', 0, false);
        TempSalesLine."Tax Category" := NpXmlDomMgt.GetXmlText(XmlElement, 'taxcategory', 0, false);
        TempSalesLine."Tax Area Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'taxareacode', 0, false);
        Evaluate(TempSalesLine."Tax Liable", NpXmlDomMgt.GetXmlText(XmlElement, 'taxliable', 0, false), 9);
        TempSalesLine."Tax Group Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'taxgroupcode', 0, false);
        TempSalesLine."VAT Clause Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'vatclausecode', 0, false);
        TempSalesLine."VAT Bus. Posting Group" := NpXmlDomMgt.GetXmlText(XmlElement, 'vatbuspostinggroup', 0, false);
        TempSalesLine."VAT Prod. Posting Group" := NpXmlDomMgt.GetXmlText(XmlElement, 'vatprodpostinggroup', 0, false);
        TempSalesLine."Currency Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'currencycode', 0, false);
        Evaluate(TempSalesLine."Outstanding Amount (LCY)", NpXmlDomMgt.GetXmlText(XmlElement, 'outstandingamountlcy', 0, false), 9);
        Evaluate(TempSalesLine."Shipped Not Invoiced (LCY)", NpXmlDomMgt.GetXmlText(XmlElement, 'shippednotinvoicedlcy', 0, false), 9);
        Evaluate(TempSalesLine.Reserve, NpXmlDomMgt.GetXmlText(XmlElement, 'reserve', 0, false), 9);
        Evaluate(TempSalesLine."VAT Base Amount", NpXmlDomMgt.GetXmlText(XmlElement, 'vatbaseamount', 0, false), 9);
        Evaluate(TempSalesLine."Unit Cost", NpXmlDomMgt.GetXmlText(XmlElement, 'unitcost', 0, false), 9);
        Evaluate(TempSalesLine."System-Created Entry", NpXmlDomMgt.GetXmlText(XmlElement, 'systemcreatedentry', 0, false), 9);
        Evaluate(TempSalesLine."Line Amount", NpXmlDomMgt.GetXmlText(XmlElement, 'lineamount', 0, false), 9);
        Evaluate(TempSalesLine."VAT Difference", NpXmlDomMgt.GetXmlText(XmlElement, 'vatdifference', 0, false), 9);
        Evaluate(TempSalesLine."Inv. Disc. Amount to Invoice", NpXmlDomMgt.GetXmlText(XmlElement, 'invdiscamounttoinvoice', 0, false), 9);
        TempSalesLine."VAT Identifier" := NpXmlDomMgt.GetXmlText(XmlElement, 'vatidentifier', 0, false);
        Evaluate(TempSalesLine."IC Partner Ref. Type", NpXmlDomMgt.GetXmlText(XmlElement, 'icpartnerreftype', 0, false), 9);
        TempSalesLine."IC Partner Reference" := NpXmlDomMgt.GetXmlText(XmlElement, 'icpartnerreference', 0, false);
        Evaluate(TempSalesLine."Prepayment %", NpXmlDomMgt.GetXmlText(XmlElement, 'prepaymentpercent', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. Line Amount", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtlineamount', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. Amt. Inv.", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtamtinv', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. Amt. Incl. VAT", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtamtinclvat', 0, false), 9);
        Evaluate(TempSalesLine."Prepayment Amount", NpXmlDomMgt.GetXmlText(XmlElement, 'prepaymentamount', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. VAT Base Amt.", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtvatbaseamt', 0, false), 9);
        Evaluate(TempSalesLine."Prepayment VAT %", NpXmlDomMgt.GetXmlText(XmlElement, 'prepaymentvatpercent', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. VAT Calc. Type", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtvatcalctype', 0, false), 9);
        TempSalesLine."Prepayment VAT Identifier" := NpXmlDomMgt.GetXmlText(XmlElement, 'prepaymentvatidentifier', 0, false);
        TempSalesLine."Prepayment Tax Area Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'prepaymenttaxareacode', 0, false);
        Evaluate(TempSalesLine."Prepayment Tax Liable", NpXmlDomMgt.GetXmlText(XmlElement, 'prepaymenttaxliable', 0, false), 9);
        TempSalesLine."Prepayment Tax Group Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'prepaymenttaxgroupcode', 0, false);
        Evaluate(TempSalesLine."Prepmt Amt to Deduct", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtamttodeduct', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt Amt Deducted", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtamtdeducted', 0, false), 9);
        Evaluate(TempSalesLine."Prepayment Line", NpXmlDomMgt.GetXmlText(XmlElement, 'prepaymentline', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. Amount Inv. Incl. VAT", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtamountinvinclvat', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt. Amount Inv. (LCY)", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtamountinvlcy', 0, false), 9);
        TempSalesLine."IC Partner Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'icpartnercode', 0, false);
        Evaluate(TempSalesLine."Prepmt. VAT Amount Inv. (LCY)", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtvatamountinvlcy', 0, false), 9);
        Evaluate(TempSalesLine."Prepayment VAT Difference", NpXmlDomMgt.GetXmlText(XmlElement, 'prepaymentvatdifference', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt VAT Diff. to Deduct", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtvatdifftodeduct', 0, false), 9);
        Evaluate(TempSalesLine."Prepmt VAT Diff. Deducted", NpXmlDomMgt.GetXmlText(XmlElement, 'prepmtvatdiffdeducted', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Assemble to Order", NpXmlDomMgt.GetXmlText(XmlElement, 'qtytoassembletoorder', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Asm. to Order (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'qtytoasmtoorderbase', 0, false), 9);
        TempSalesLine."Job Task No." := NpXmlDomMgt.GetXmlText(XmlElement, 'jobtaskno', 0, false);
        Evaluate(TempSalesLine."Job Contract Entry No.", NpXmlDomMgt.GetXmlText(XmlElement, 'jobcontractentryno', 0, false), 9);
        TempSalesLine."Deferral Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'deferralcode', 0, false);
        Evaluate(TempSalesLine."Returns Deferral Start Date", NpXmlDomMgt.GetXmlText(XmlElement, 'returnsdeferralstartdate', 0, false), 9);
        TempSalesLine."Variant Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'variantcode', 0, false);
        TempSalesLine."Bin Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'bincode', 0, false);
        Evaluate(TempSalesLine."Qty. per Unit of Measure", NpXmlDomMgt.GetXmlText(XmlElement, 'qtyperunitofmeasure', 0, false), 9);
        Evaluate(TempSalesLine.Planned, NpXmlDomMgt.GetXmlText(XmlElement, 'planned', 0, false), 9);
        TempSalesLine."Unit of Measure Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'unitofmeasurecode', 0, false);
        Evaluate(TempSalesLine."Quantity (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'quantitybase', 0, false), 9);
        Evaluate(TempSalesLine."Outstanding Qty. (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'outstandingqtybase', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Invoice (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'qtytoinvoicebase', 0, false), 9);
        Evaluate(TempSalesLine."Qty. to Ship (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'qtytoshipbase', 0, false), 9);
        Evaluate(TempSalesLine."Qty. Shipped Not Invd. (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'qtyshippednotinvdbase', 0, false), 9);
        Evaluate(TempSalesLine."Qty. Shipped (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'qtyshippedbase', 0, false), 9);
        Evaluate(TempSalesLine."Qty. Invoiced (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'qtyinvoicedbase', 0, false), 9);
        Evaluate(TempSalesLine."FA Posting Date", NpXmlDomMgt.GetXmlText(XmlElement, 'fapostingdate', 0, false), 9);
        TempSalesLine."Depreciation Book Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'depreciationbookcode', 0, false);
        Evaluate(TempSalesLine."Depr. until FA Posting Date", NpXmlDomMgt.GetXmlText(XmlElement, 'depruntilfapostingdate', 0, false), 9);
        TempSalesLine."Duplicate in Depreciation Book" := NpXmlDomMgt.GetXmlText(XmlElement, 'duplicateindepreciationbook', 0, false);
        Evaluate(TempSalesLine."Use Duplication List", NpXmlDomMgt.GetXmlText(XmlElement, 'useduplicationlist', 0, false), 9);
        TempSalesLine."Responsibility Center" := NpXmlDomMgt.GetXmlText(XmlElement, 'responsibilitycenter', 0, false);
        Evaluate(TempSalesLine."Out-of-Stock Substitution", NpXmlDomMgt.GetXmlText(XmlElement, 'outofstocksubstitution', 0, false), 9);
        TempSalesLine."Originally Ordered No." := NpXmlDomMgt.GetXmlText(XmlElement, 'originallyorderedno', 0, false);
        TempSalesLine."Originally Ordered Var. Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'originallyorderedvarcode', 0, false);
        TempSalesLine."Cross-Reference No." := NpXmlDomMgt.GetXmlText(XmlElement, 'crossreferenceno', 0, false);
        TempSalesLine."Unit of Measure (Cross Ref.)" := NpXmlDomMgt.GetXmlText(XmlElement, 'unitofmeasurecrossref', 0, false);
        Evaluate(TempSalesLine."Cross-Reference Type", NpXmlDomMgt.GetXmlText(XmlElement, 'crossreferencetype', 0, false), 9);
        TempSalesLine."Cross-Reference Type No." := NpXmlDomMgt.GetXmlText(XmlElement, 'crossreferencetypeno', 0, false);
        TempSalesLine."Item Category Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'itemcategorycode', 0, false);
        Evaluate(TempSalesLine.Nonstock, NpXmlDomMgt.GetXmlText(XmlElement, 'nonstock', 0, false), 9);
        TempSalesLine."Purchasing Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'purchasingcode', 0, false);
        Evaluate(TempSalesLine."Special Order", NpXmlDomMgt.GetXmlText(XmlElement, 'specialorder', 0, false), 9);
        Evaluate(TempSalesLine."Completely Shipped", NpXmlDomMgt.GetXmlText(XmlElement, 'completelyshipped', 0, false), 9);
        Evaluate(TempSalesLine."Requested Delivery Date", NpXmlDomMgt.GetXmlText(XmlElement, 'requesteddeliverydate', 0, false), 9);
        Evaluate(TempSalesLine."Promised Delivery Date", NpXmlDomMgt.GetXmlText(XmlElement, 'promiseddeliverydate', 0, false), 9);
        Evaluate(TempSalesLine."Shipping Time", NpXmlDomMgt.GetXmlText(XmlElement, 'shippingtime', 0, false), 9);
        Evaluate(TempSalesLine."Outbound Whse. Handling Time", NpXmlDomMgt.GetXmlText(XmlElement, 'outboundwhsehandlingtime', 0, false), 9);
        Evaluate(TempSalesLine."Planned Delivery Date", NpXmlDomMgt.GetXmlText(XmlElement, 'planneddeliverydate', 0, false), 9);
        Evaluate(TempSalesLine."Planned Shipment Date", NpXmlDomMgt.GetXmlText(XmlElement, 'plannedshipmentdate', 0, false), 9);
        TempSalesLine."Shipping Agent Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'shippingagentcode', 0, false);
        TempSalesLine."Shipping Agent Service Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'shippingagentservicecode', 0, false);
        Evaluate(TempSalesLine."Allow Item Charge Assignment", NpXmlDomMgt.GetXmlText(XmlElement, 'allowitemchargeassignment', 0, false), 9);
        Evaluate(TempSalesLine."Return Qty. to Receive", NpXmlDomMgt.GetXmlText(XmlElement, 'returnqtytoreceive', 0, false), 9);
        Evaluate(TempSalesLine."Return Qty. to Receive (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'returnqtytoreceivebase', 0, false), 9);
        Evaluate(TempSalesLine."Return Qty. Rcd. Not Invd.", NpXmlDomMgt.GetXmlText(XmlElement, 'returnqtyrcdnotinvd', 0, false), 9);
        Evaluate(TempSalesLine."Ret. Qty. Rcd. Not Invd.(Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'retqtyrcdnotinvdbase', 0, false), 9);
        Evaluate(TempSalesLine."Return Rcd. Not Invd.", NpXmlDomMgt.GetXmlText(XmlElement, 'returnrcdnotinvd', 0, false), 9);
        Evaluate(TempSalesLine."Return Rcd. Not Invd. (LCY)", NpXmlDomMgt.GetXmlText(XmlElement, 'returnrcdnotinvdlcy', 0, false), 9);
        Evaluate(TempSalesLine."Return Qty. Received", NpXmlDomMgt.GetXmlText(XmlElement, 'returnqtyreceived', 0, false), 9);
        Evaluate(TempSalesLine."Return Qty. Received (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'returnqtyreceivedbase', 0, false), 9);
        TempSalesLine."BOM Item No." := NpXmlDomMgt.GetXmlText(XmlElement, 'bomitemno', 0, false);
        TempSalesLine."Return Reason Code" := NpXmlDomMgt.GetXmlText(XmlElement, 'returnreasoncode', 0, false);
        Evaluate(TempSalesLine."Allow Line Disc.", NpXmlDomMgt.GetXmlText(XmlElement, 'allowlinedisc', 0, false), 9);
        TempSalesLine."Customer Disc. Group" := NpXmlDomMgt.GetXmlText(XmlElement, 'customerdiscgroup', 0, false);

        OnBeforeInsertSalesLine(TempSalesLine, SalesHeader, SalesLine, Handeld);

        if not Handeld then begin
            if not SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", TempSalesLine."Line No.") then begin
                SalesLine.Init;
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
        //+NPR5.48 [336517]
    end;

    local procedure InsertReservationEntry(XmlElement: DotNet NPRNetXmlElement; SalesLine: Record "Sales Line")
    var
        TempReservationEntry: Record "Reservation Entry" temporary;
        CurrentEntryStatus: Option Reservation,Tracking,Surplus,Prospect;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ReservationEntry: Record "Reservation Entry";
        ReservationMgt: Codeunit "Reservation Management";
    begin
        //-NPR5.48 [336517]
        Evaluate(TempReservationEntry."Source Type", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'sourcetype', false), 9);
        Evaluate(TempReservationEntry."Source Subtype", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'sourcesubtype', false), 9);
        TempReservationEntry."Source ID" := SalesLine."Document No.";
        TempReservationEntry."Source Batch Name" := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'sourcebatchname', false);
        Evaluate(TempReservationEntry."Source Prod. Order Line", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'sourceprodorderline', false), 9);
        TempReservationEntry."Source Ref. No." := SalesLine."Line No.";
        Evaluate(TempReservationEntry.Positive, NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'positive', false), 9);
        TempReservationEntry."Item No." := NpXmlDomMgt.GetXmlText(XmlElement, 'itemno', 0, false);
        TempReservationEntry."Location Code" := SalesLine."Location Code";
        Evaluate(TempReservationEntry."Quantity (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'quantitybase', 0, false), 9);
        Evaluate(TempReservationEntry."Reservation Status", NpXmlDomMgt.GetXmlText(XmlElement, 'reservationstatus', 0, false), 9);
        TempReservationEntry.Description := NpXmlDomMgt.GetXmlText(XmlElement, 'description', 0, false);
        Evaluate(TempReservationEntry."Creation Date", NpXmlDomMgt.GetXmlText(XmlElement, 'creationdate', 0, false), 9);
        Evaluate(TempReservationEntry."Expected Receipt Date", NpXmlDomMgt.GetXmlText(XmlElement, 'expectedreceiptdate', 0, false), 9);
        TempReservationEntry."Shipment Date" := SalesLine."Shipment Date";
        TempReservationEntry."Serial No." := NpXmlDomMgt.GetXmlText(XmlElement, 'serialno', 0, false);
        TempReservationEntry."Created By" := NpXmlDomMgt.GetXmlText(XmlElement, 'createdby', 0, false);
        TempReservationEntry."Changed By" := NpXmlDomMgt.GetXmlText(XmlElement, 'changedby', 0, false);
        TempReservationEntry."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
        Evaluate(TempReservationEntry.Quantity, NpXmlDomMgt.GetXmlText(XmlElement, 'quantity', 0, false), 9);
        Evaluate(TempReservationEntry.Binding, NpXmlDomMgt.GetXmlText(XmlElement, 'binding', 0, false), 9);
        Evaluate(TempReservationEntry."Suppressed Action Msg.", NpXmlDomMgt.GetXmlText(XmlElement, 'suppressedactionmsg', 0, false), 9);
        Evaluate(TempReservationEntry."Planning Flexibility", NpXmlDomMgt.GetXmlText(XmlElement, 'planningflexibility', 0, false), 9);
        Evaluate(TempReservationEntry."Warranty Date", NpXmlDomMgt.GetXmlText(XmlElement, 'warrantydate', 0, false), 9);
        Evaluate(TempReservationEntry."Expiration Date", NpXmlDomMgt.GetXmlText(XmlElement, 'expirationdate', 0, false), 9);
        Evaluate(TempReservationEntry."Qty. to Handle (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'qtytohandlebase', 0, false), 9);
        Evaluate(TempReservationEntry."Qty. to Invoice (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'qtytoinvoicebase', 0, false), 9);
        Evaluate(TempReservationEntry."Quantity Invoiced (Base)", NpXmlDomMgt.GetXmlText(XmlElement, 'quantityinvoicedbase', 0, false), 9);
        TempReservationEntry."New Serial No." := NpXmlDomMgt.GetXmlText(XmlElement, 'newserialno', 0, false);
        TempReservationEntry."New Lot No." := NpXmlDomMgt.GetXmlText(XmlElement, 'newlotno', 0, false);
        Evaluate(TempReservationEntry."Disallow Cancellation", NpXmlDomMgt.GetXmlText(XmlElement, 'disallowcancellation', 0, false), 9);
        TempReservationEntry."Lot No." := NpXmlDomMgt.GetXmlText(XmlElement, 'lotno', 0, false);
        TempReservationEntry."Variant Code" := SalesLine."Variant Code";
        Evaluate(TempReservationEntry.Correction, NpXmlDomMgt.GetXmlText(XmlElement, 'correction', 0, false), 9);
        Evaluate(TempReservationEntry."New Expiration Date", NpXmlDomMgt.GetXmlText(XmlElement, 'newexpirationdate', 0, false), 9);
        TempReservationEntry.UpdateItemTracking();

        if ItemTrackingMgt.IsOrderNetworkEntity(TempReservationEntry."Source Type", SalesLine."Document Type") and not SalesLine."Drop Shipment" then
            CurrentEntryStatus := CurrentEntryStatus::Surplus
        else
            CurrentEntryStatus := CurrentEntryStatus::Prospect;

        ReservationEntry := TempReservationEntry;
        //-NPR5.48 [340446]
        /*
        ReservationMgt.SetPointerFilter(ReservationEntry);
        ReservationEntry.SETRANGE("Lot No.",TempReservationEntry."Lot No.");
        ReservationEntry.SETRANGE("Serial No.",TempReservationEntry."Serial No.");
        */
        ReservationEntry.SetPointerFilter;
        ReservationEntry.SetTrackingFilterFromReservEntry(ReservationEntry);
        //+NPR5.48 [340446]
        if not ReservationEntry.FindFirst then
            CreateReservationEntry(TempReservationEntry, CurrentEntryStatus)
        else begin
            ReservationMgt.SetItemTrackingHandling(1);
            ReservationMgt.DeleteReservEntries(true, 0, ReservationEntry);
            CreateReservationEntry(TempReservationEntry, CurrentEntryStatus);
        end;
        //+NPR5.48 [336517]

    end;

    local procedure CreateReservationEntry(var ReservationEntry: Record "Reservation Entry"; CurrentEntryStatus: Option Reservation,Tracking,Surplus,Prospect)
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        //-NPR5.48 [336517]
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
          ReservationEntry."Serial No.",
          ReservationEntry."Lot No.");
        CreateReservEntry.CreateEntry(
          ReservationEntry."Item No.",
          ReservationEntry."Variant Code",
          ReservationEntry."Location Code",
          ReservationEntry.Description,
          0D,
          ReservationEntry."Shipment Date",
          0,
          CurrentEntryStatus);
        //+NPR5.48 [336517]
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

