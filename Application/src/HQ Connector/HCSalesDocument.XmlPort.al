xmlport 6150902 "NPR HC Sales Document"
{
    Caption = 'HC Sales Document';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(salesdocument)
        {
            textelement(insertsalesdocument)
            {
                tableelement(salesheader; "Sales Header")
                {
                    XmlName = 'salesheader';
                    UseTemporary = true;
                    fieldattribute(documenttype; SalesHeader."Document Type")
                    {
                    }
                    fieldattribute(documentno; SalesHeader."No.")
                    {
                    }
                    fieldelement(selltocustomerno; SalesHeader."Sell-to Customer No.")
                    {
                    }
                    fieldelement(billtocustomerno; SalesHeader."Bill-to Customer No.")
                    {
                    }
                    fieldelement(billtoname; SalesHeader."Bill-to Name")
                    {
                    }
                    fieldelement(billtoname2; SalesHeader."Bill-to Name 2")
                    {
                    }
                    fieldelement(billtoaddress; SalesHeader."Bill-to Address")
                    {
                    }
                    fieldelement(billtoaddress2; SalesHeader."Bill-to Address 2")
                    {
                    }
                    fieldelement(billtocity; SalesHeader."Bill-to City")
                    {
                    }
                    fieldelement(billtocontact; SalesHeader."Bill-to Contact")
                    {
                    }
                    fieldelement(yourreference; SalesHeader."Your Reference")
                    {
                    }
                    fieldelement(shiptocode; SalesHeader."Ship-to Code")
                    {
                    }
                    fieldelement(shiptoname; SalesHeader."Ship-to Name")
                    {
                    }
                    fieldelement(shiptoname2; SalesHeader."Ship-to Name 2")
                    {
                    }
                    fieldelement(shiptoaddress; SalesHeader."Ship-to Address")
                    {
                    }
                    fieldelement(shiptoaddress2; SalesHeader."Ship-to Address 2")
                    {
                    }
                    fieldelement(shiptocity; SalesHeader."Ship-to City")
                    {
                    }
                    fieldelement(shiptocontact; SalesHeader."Ship-to Contact")
                    {
                    }
                    fieldelement(orderdate; SalesHeader."Order Date")
                    {
                    }
                    fieldelement(postingdate; SalesHeader."Posting Date")
                    {
                    }
                    fieldelement(shipmentdate; SalesHeader."Shipment Date")
                    {
                    }
                    fieldelement(postingdescription; SalesHeader."Posting Description")
                    {
                    }
                    fieldelement(paymenttermscode; SalesHeader."Payment Terms Code")
                    {
                    }
                    fieldelement(duedate; SalesHeader."Due Date")
                    {
                    }
                    fieldelement(paymentdiscount; SalesHeader."Payment Discount %")
                    {
                    }
                    fieldelement(pmtdiscountdate; SalesHeader."Pmt. Discount Date")
                    {
                    }
                    fieldelement(shipmentmethod; SalesHeader."Shipment Method Code")
                    {
                    }
                    fieldelement(locationcode; SalesHeader."Location Code")
                    {
                    }
                    fieldelement(shortcutdimension1; SalesHeader."Shortcut Dimension 1 Code")
                    {
                    }
                    fieldelement(shortcutdimension2; SalesHeader."Shortcut Dimension 2 Code")
                    {
                    }
                    fieldelement(customerpostinggroup; SalesHeader."Customer Posting Group")
                    {
                    }
                    fieldelement(currencycode; SalesHeader."Currency Code")
                    {
                    }
                    fieldelement(currencyfactor; SalesHeader."Currency Factor")
                    {
                    }
                    fieldelement(customerpricegroup; SalesHeader."Customer Price Group")
                    {
                    }
                    fieldelement(pricesincludingvat; SalesHeader."Prices Including VAT")
                    {
                    }
                    fieldelement(invoicedisccode; SalesHeader."Invoice Disc. Code")
                    {
                    }
                    fieldelement(customerdisccode; SalesHeader."Customer Disc. Group")
                    {
                    }
                    fieldelement(languagecode; SalesHeader."Language Code")
                    {
                    }
                    fieldelement(salespersoncode; SalesHeader."Salesperson Code")
                    {
                    }
                    fieldelement(orderclass; SalesHeader."Order Class")
                    {
                    }
                    fieldelement(onhold; SalesHeader."On Hold")
                    {
                    }
                    fieldelement(balaccountno; SalesHeader."Bal. Account No.")
                    {
                    }
                    fieldelement(recalulatieinvoicedisc; SalesHeader."Recalculate Invoice Disc.")
                    {
                    }
                    fieldelement(vatregistrationno; SalesHeader."VAT Registration No.")
                    {
                    }
                    fieldelement(combineshipments; SalesHeader."Combine Shipments")
                    {
                    }
                    fieldelement(reasoncode; SalesHeader."Reason Code")
                    {
                    }
                    fieldelement(genbuspostinggroup; SalesHeader."Gen. Bus. Posting Group")
                    {
                    }
                    fieldelement(eu3partytrade; SalesHeader."EU 3-Party Trade")
                    {
                    }
                    fieldelement(transactiontype; SalesHeader."Transaction Type")
                    {
                    }
                    fieldelement(transportmethod; SalesHeader."Transport Method")
                    {
                    }
                    fieldelement(vatcountryregioncode; SalesHeader."VAT Country/Region Code")
                    {
                    }
                    fieldelement(selltocustomername; SalesHeader."Sell-to Customer Name")
                    {
                    }
                    fieldelement(selltocustomername2; SalesHeader."Sell-to Customer Name 2")
                    {
                    }
                    fieldelement(selltoaddress; SalesHeader."Sell-to Address")
                    {
                    }
                    fieldelement(selltoaddress2; SalesHeader."Sell-to Address 2")
                    {
                    }
                    fieldelement(selltocity; SalesHeader."Sell-to City")
                    {
                    }
                    fieldelement(selltocontact; SalesHeader."Sell-to Contact")
                    {
                    }
                    fieldelement(billtopostcode; SalesHeader."Bill-to Post Code")
                    {
                    }
                    fieldelement(billtocounty; SalesHeader."Bill-to County")
                    {
                    }
                    fieldelement(billtocountryregioncode; SalesHeader."Bill-to Country/Region Code")
                    {
                    }
                    fieldelement(selltopostcode; SalesHeader."Sell-to Post Code")
                    {
                    }
                    fieldelement(selltocounty; SalesHeader."Sell-to County")
                    {
                    }
                    fieldelement(selltocountryregioncode; SalesHeader."Sell-to Country/Region Code")
                    {
                    }
                    fieldelement(shiptopostcode; SalesHeader."Ship-to Post Code")
                    {
                    }
                    fieldelement(shiptocounty; SalesHeader."Ship-to County")
                    {
                    }
                    fieldelement(shiptocountryregioncode; SalesHeader."Ship-to Country/Region Code")
                    {
                    }
                    fieldelement(balaccounttype; SalesHeader."Bal. Account Type")
                    {
                    }
                    fieldelement(exitpoint; SalesHeader."Exit Point")
                    {
                    }
                    fieldelement(documentdate; SalesHeader."Document Date")
                    {
                    }
                    fieldelement(externaldocumentno; SalesHeader."External Document No.")
                    {
                    }
                    fieldelement("area"; SalesHeader."Area")
                    {
                    }
                    fieldelement(transactionspecification; SalesHeader."Transaction Specification")
                    {
                    }
                    fieldelement(paymentmethodcode; SalesHeader."Payment Method Code")
                    {
                    }
                    fieldelement(shippingagentcode; SalesHeader."Shipping Agent Code")
                    {
                    }
                    fieldelement(packagetrackingno; SalesHeader."Package Tracking No.")
                    {
                    }
                    fieldelement(noseries; SalesHeader."No. Series")
                    {
                    }
                    fieldelement(postingnoseries; SalesHeader."Posting No. Series")
                    {
                    }
                    fieldelement(shippingnoseries; SalesHeader."Shipping No. Series")
                    {
                    }
                    fieldelement(taxareacode; SalesHeader."Tax Area Code")
                    {
                    }
                    fieldelement(taxliable; SalesHeader."Tax Liable")
                    {
                    }
                    fieldelement(vatbuspostinggroup; SalesHeader."VAT Bus. Posting Group")
                    {
                    }
                    fieldelement(reserve; SalesHeader.Reserve)
                    {
                    }
                    fieldelement(appliestoid; SalesHeader."Applies-to ID")
                    {
                    }
                    fieldelement(vatbasediscountperc; SalesHeader."VAT Base Discount %")
                    {
                    }
                    fieldelement(status; SalesHeader.Status)
                    {
                    }
                    fieldelement(invoicediscountcalculation; SalesHeader."Invoice Discount Calculation")
                    {
                    }
                    fieldelement(invoicediscountvalue; SalesHeader."Invoice Discount Value")
                    {
                    }
                    fieldelement(quoteno; SalesHeader."Quote No.")
                    {
                    }
                    textelement(creditcardno)
                    {
                    }
#if BC17
                    fieldelement(selltocustomertemplatecode; SalesHeader."Sell-to Customer Template Code")
                    {
                    }
#else
                    fieldelement(selltocustomertemplatecode; SalesHeader."Sell-to Customer Templ. Code")
                    {
                    }
#endif
                    fieldelement(selltocontactno; SalesHeader."Sell-to Contact No.")
                    {
                    }
                    fieldelement(billtocontactno; SalesHeader."Bill-to Contact No.")
                    {
                    }
#if BC17
                    fieldelement(billtocustomertemplatecode; SalesHeader."Bill-to Customer Template Code")
                    {
                    }
#else
                    fieldelement(billtocustomertemplatecode; SalesHeader."Bill-to Customer Templ. Code")
                    {
                    }
#endif
                    fieldelement(opportunityno; SalesHeader."Opportunity No.")
                    {
                    }
                    fieldelement(responsibilitycenter; SalesHeader."Responsibility Center")
                    {
                    }
                    fieldelement(shippingadvice; SalesHeader."Shipping Advice")
                    {
                    }
                    fieldelement(requesteddeliverydate; SalesHeader."Requested Delivery Date")
                    {
                    }
                    fieldelement(promiseddeliverydate; SalesHeader."Promised Delivery Date")
                    {
                    }
                    fieldelement(shippingtime; SalesHeader."Shipping Time")
                    {
                    }
                    fieldelement(outboundwhsehandlingtime; SalesHeader."Outbound Whse. Handling Time")
                    {
                    }
                    fieldelement(shippingagenetservicecode; SalesHeader."Shipping Agent Service Code")
                    {
                    }
                    fieldelement(lateordershipping; SalesHeader."Late Order Shipping")
                    {
                    }
                    fieldelement(allowlinedisc; SalesHeader."Allow Line Disc.")
                    {
                    }
                    tableelement("Sales Line"; "Sales Line")
                    {
                        LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        LinkTable = SalesHeader;
                        XmlName = 'salesline';
                        UseTemporary = true;
                        fieldattribute(documenttype; "Sales Line"."Document Type")
                        {
                        }
                        fieldattribute(documentno; "Sales Line"."Document No.")
                        {
                        }
                        fieldattribute(lineno; "Sales Line"."Line No.")
                        {
                        }
                        fieldelement(type; "Sales Line".Type)
                        {
                        }
                        fieldelement(no; "Sales Line"."No.")
                        {
                        }
                        fieldelement(locationcode; "Sales Line"."Location Code")
                        {
                        }
                        fieldelement(postinggroup; "Sales Line"."Posting Group")
                        {
                        }
                        fieldelement(shipmentdate; "Sales Line"."Shipment Date")
                        {
                        }
                        fieldelement(description; "Sales Line".Description)
                        {
                        }
                        fieldelement(description2; "Sales Line"."Description 2")
                        {
                        }
                        fieldelement(unitofmeasure; "Sales Line"."Unit of Measure")
                        {
                        }
                        fieldelement(quantity; "Sales Line".Quantity)
                        {
                        }
                        fieldelement(outstandingquantity; "Sales Line"."Outstanding Quantity")
                        {
                        }
                        fieldelement(qtytoinvoice; "Sales Line"."Qty. to Invoice")
                        {
                        }
                        fieldelement(qtytoship; "Sales Line"."Qty. to Ship")
                        {
                        }
                        fieldelement(unitprice; "Sales Line"."Unit Price")
                        {
                        }
                        fieldelement(unitcostlcy; "Sales Line"."Unit Cost (LCY)")
                        {
                        }
                        fieldelement(vatpercent; "Sales Line"."VAT %")
                        {
                        }
                        fieldelement(linediscountpercent; "Sales Line"."Line Discount %")
                        {
                        }
                        fieldelement(linediscountamount; "Sales Line"."Line Discount Amount")
                        {
                        }
                        fieldelement(amount; "Sales Line".Amount)
                        {
                        }
                        fieldelement(amountincludingvat; "Sales Line"."Amount Including VAT")
                        {
                        }
                        fieldelement(allowinvoicedisc; "Sales Line"."Allow Invoice Disc.")
                        {
                        }
                        fieldelement(grossweight; "Sales Line"."Gross Weight")
                        {
                        }
                        fieldelement(netweight; "Sales Line"."Net Weight")
                        {
                        }
                        fieldelement(unitsperparcel; "Sales Line"."Units per Parcel")
                        {
                        }
                        fieldelement(unitvolume; "Sales Line"."Unit Volume")
                        {
                        }
                        fieldelement(shortcutdimension1code; "Sales Line"."Shortcut Dimension 1 Code")
                        {
                        }
                        fieldelement(shortcutdimension2code; "Sales Line"."Shortcut Dimension 2 Code")
                        {
                        }
                        fieldelement(customerpricegroup; "Sales Line"."Customer Price Group")
                        {
                        }
                        fieldelement(jobno; "Sales Line"."Job No.")
                        {
                        }
                        fieldelement(worktypecode; "Sales Line"."Work Type Code")
                        {
                        }
                        fieldelement(recalculateinvoicedisc; "Sales Line"."Recalculate Invoice Disc.")
                        {
                        }
                        fieldelement(outstandingamount; "Sales Line"."Outstanding Amount")
                        {
                        }
                        fieldelement(qtyshippednotinvoiced; "Sales Line"."Qty. Shipped Not Invoiced")
                        {
                        }
                        fieldelement(shippednotinvoiced; "Sales Line"."Shipped Not Invoiced")
                        {
                        }
                        fieldelement(quantityshipped; "Sales Line"."Quantity Shipped")
                        {
                        }
                        fieldelement(quantityinvoiced; "Sales Line"."Quantity Invoiced")
                        {
                        }
                        fieldelement(profitpercent; "Sales Line"."Profit %")
                        {
                        }
                        fieldelement(billtocustomerno; "Sales Line"."Bill-to Customer No.")
                        {
                        }
                        fieldelement(invdiscountamount; "Sales Line"."Inv. Discount Amount")
                        {
                        }
                        fieldelement(dropshipment; "Sales Line"."Drop Shipment")
                        {
                        }
                        fieldelement(genbuspostinggroup; "Sales Line"."Gen. Bus. Posting Group")
                        {
                        }
                        fieldelement(genprodpostinggroup; "Sales Line"."Gen. Prod. Posting Group")
                        {
                        }
                        fieldelement(vatcalculationtype; "Sales Line"."VAT Calculation Type")
                        {
                        }
                        fieldelement(transactiontype; "Sales Line"."Transaction Type")
                        {
                        }
                        fieldelement(transportmethod; "Sales Line"."Transport Method")
                        {
                        }
                        fieldelement(attachedtolineno; "Sales Line"."Attached to Line No.")
                        {
                        }
                        fieldelement(exitpoint; "Sales Line"."Exit Point")
                        {
                        }
                        fieldelement("area"; "Sales Line"."Area")
                        {
                        }
                        fieldelement(transactionspecification; "Sales Line"."Transaction Specification")
                        {
                        }
                        fieldelement(taxcategory; "Sales Line"."Tax Category")
                        {
                        }
                        fieldelement(taxareacode; "Sales Line"."Tax Area Code")
                        {
                        }
                        fieldelement(taxliable; "Sales Line"."Tax Liable")
                        {
                        }
                        fieldelement(taxgroupcode; "Sales Line"."Tax Group Code")
                        {
                        }
                        fieldelement(vatclausecode; "Sales Line"."VAT Clause Code")
                        {
                        }
                        fieldelement(vatbuspostinggroup; "Sales Line"."VAT Bus. Posting Group")
                        {
                        }
                        fieldelement(vatprodpostinggroup; "Sales Line"."VAT Prod. Posting Group")
                        {
                        }
                        fieldelement(currencycode; "Sales Line"."Currency Code")
                        {
                        }
                        fieldelement(outstandingamountlcy; "Sales Line"."Outstanding Amount (LCY)")
                        {
                        }
                        fieldelement(shippednotinvoicedlcy; "Sales Line"."Shipped Not Invoiced (LCY)")
                        {
                        }
                        fieldelement(reserve; "Sales Line".Reserve)
                        {
                        }
                        fieldelement(vatbaseamount; "Sales Line"."VAT Base Amount")
                        {
                        }
                        fieldelement(unitcost; "Sales Line"."Unit Cost")
                        {
                        }
                        fieldelement(systemcreatedentry; "Sales Line"."System-Created Entry")
                        {
                        }
                        fieldelement(lineamount; "Sales Line"."Line Amount")
                        {
                        }
                        fieldelement(vatdifference; "Sales Line"."VAT Difference")
                        {
                        }
                        fieldelement(invdiscamounttoinvoice; "Sales Line"."Inv. Disc. Amount to Invoice")
                        {
                        }
                        fieldelement(vatidentifier; "Sales Line"."VAT Identifier")
                        {
                        }
                        fieldelement(icpartnerreftype; "Sales Line"."IC Partner Ref. Type")
                        {
                        }
                        fieldelement(icpartnerreference; "Sales Line"."IC Item Reference No.")
                        {
                        }
                        fieldelement(prepaymentpercent; "Sales Line"."Prepayment %")
                        {
                        }
                        fieldelement(prepmtlineamount; "Sales Line"."Prepmt. Line Amount")
                        {
                        }
                        fieldelement(prepmtamtinv; "Sales Line"."Prepmt. Amt. Inv.")
                        {
                        }
                        fieldelement(prepmtamtinclvat; "Sales Line"."Prepmt. Amt. Incl. VAT")
                        {
                        }
                        fieldelement(prepaymentamount; "Sales Line"."Prepayment Amount")
                        {
                        }
                        fieldelement(prepmtvatbaseamt; "Sales Line"."Prepmt. VAT Base Amt.")
                        {
                        }
                        fieldelement(prepaymentvatpercent; "Sales Line"."Prepayment VAT %")
                        {
                        }
                        fieldelement(prepmtvatcalctype; "Sales Line"."Prepmt. VAT Calc. Type")
                        {
                        }
                        fieldelement(prepaymentvatidentifier; "Sales Line"."Prepayment VAT Identifier")
                        {
                        }
                        fieldelement(prepaymenttaxareacode; "Sales Line"."Prepayment Tax Area Code")
                        {
                        }
                        fieldelement(prepaymenttaxliable; "Sales Line"."Prepayment Tax Liable")
                        {
                        }
                        fieldelement(prepaymenttaxgroupcode; "Sales Line"."Prepayment Tax Group Code")
                        {
                        }
                        fieldelement(prepmtamttodeduct; "Sales Line"."Prepmt Amt to Deduct")
                        {
                        }
                        fieldelement(prepmtamtdeducted; "Sales Line"."Prepmt Amt Deducted")
                        {
                        }
                        fieldelement(prepaymentline; "Sales Line"."Prepayment Line")
                        {
                        }
                        fieldelement(prepmtamountinvinclvat; "Sales Line"."Prepmt. Amount Inv. Incl. VAT")
                        {
                        }
                        fieldelement(prepmtamountinvlcy; "Sales Line"."Prepmt. Amount Inv. (LCY)")
                        {
                        }
                        fieldelement(icpartnercode; "Sales Line"."IC Partner Code")
                        {
                        }
                        fieldelement(prepmtvatamountinvlcy; "Sales Line"."Prepmt. VAT Amount Inv. (LCY)")
                        {
                        }
                        fieldelement(prepaymentvatdifference; "Sales Line"."Prepayment VAT Difference")
                        {
                        }
                        fieldelement(prepmtvatdifftodeduct; "Sales Line"."Prepmt VAT Diff. to Deduct")
                        {
                        }
                        fieldelement(prepmtvatdiffdeducted; "Sales Line"."Prepmt VAT Diff. Deducted")
                        {
                        }
                        fieldelement(qtytoassembletoorder; "Sales Line"."Qty. to Assemble to Order")
                        {
                        }
                        fieldelement(qtytoasmtoorderbase; "Sales Line"."Qty. to Asm. to Order (Base)")
                        {
                        }
                        fieldelement(jobtaskno; "Sales Line"."Job Task No.")
                        {
                        }
                        fieldelement(jobcontractentryno; "Sales Line"."Job Contract Entry No.")
                        {
                        }
                        fieldelement(deferralcode; "Sales Line"."Deferral Code")
                        {
                        }
                        fieldelement(returnsdeferralstartdate; "Sales Line"."Returns Deferral Start Date")
                        {
                        }
                        fieldelement(variantcode; "Sales Line"."Variant Code")
                        {
                        }
                        fieldelement(bincode; "Sales Line"."Bin Code")
                        {
                        }
                        fieldelement(qtyperunitofmeasure; "Sales Line"."Qty. per Unit of Measure")
                        {
                        }
                        fieldelement(planned; "Sales Line".Planned)
                        {
                        }
                        fieldelement(unitofmeasurecode; "Sales Line"."Unit of Measure Code")
                        {
                        }
                        fieldelement(quantitybase; "Sales Line"."Quantity (Base)")
                        {
                        }
                        fieldelement(outstandingqtybase; "Sales Line"."Outstanding Qty. (Base)")
                        {
                        }
                        fieldelement(qtytoinvoicebase; "Sales Line"."Qty. to Invoice (Base)")
                        {
                        }
                        fieldelement(qtytoshipbase; "Sales Line"."Qty. to Ship (Base)")
                        {
                        }
                        fieldelement(qtyshippednotinvdbase; "Sales Line"."Qty. Shipped Not Invd. (Base)")
                        {
                        }
                        fieldelement(qtyshippedbase; "Sales Line"."Qty. Shipped (Base)")
                        {
                        }
                        fieldelement(qtyinvoicedbase; "Sales Line"."Qty. Invoiced (Base)")
                        {
                        }
                        fieldelement(fapostingdate; "Sales Line"."FA Posting Date")
                        {
                        }
                        fieldelement(depreciationbookcode; "Sales Line"."Depreciation Book Code")
                        {
                        }
                        fieldelement(depruntilfapostingdate; "Sales Line"."Depr. until FA Posting Date")
                        {
                        }
                        fieldelement(duplicateindepreciationbook; "Sales Line"."Duplicate in Depreciation Book")
                        {
                        }
                        fieldelement(useduplicationlist; "Sales Line"."Use Duplication List")
                        {
                        }
                        fieldelement(responsibilitycenter; "Sales Line"."Responsibility Center")
                        {
                        }
                        fieldelement(outofstocksubstitution; "Sales Line"."Out-of-Stock Substitution")
                        {
                        }
                        fieldelement(originallyorderedno; "Sales Line"."Originally Ordered No.")
                        {
                        }
                        fieldelement(originallyorderedvarcode; "Sales Line"."Originally Ordered Var. Code")
                        {
                        }
                        fieldelement(crossreferenceno; "Sales Line"."Item Reference No.")
                        {
                        }
                        fieldelement(unitofmeasurecrossref; "Sales Line"."Item Reference Unit of Measure")
                        {
                        }
                        fieldelement(crossreferencetype; "Sales Line"."Item Reference Type")
                        {
                        }
                        fieldelement(crossreferencetypeno; "Sales Line"."Item Reference Type No.")
                        {
                        }
                        fieldelement(itemcategorycode; "Sales Line"."Item Category Code")
                        {
                        }
                        fieldelement(nonstock; "Sales Line".Nonstock)
                        {
                        }
                        fieldelement(purchasingcode; "Sales Line"."Purchasing Code")
                        {
                        }
                        fieldelement(specialorder; "Sales Line"."Special Order")
                        {
                        }
                        fieldelement(completelyshipped; "Sales Line"."Completely Shipped")
                        {
                        }
                        fieldelement(requesteddeliverydate; "Sales Line"."Requested Delivery Date")
                        {
                        }
                        fieldelement(promiseddeliverydate; "Sales Line"."Promised Delivery Date")
                        {
                        }
                        fieldelement(shippingtime; "Sales Line"."Shipping Time")
                        {
                        }
                        fieldelement(outboundwhsehandlingtime; "Sales Line"."Outbound Whse. Handling Time")
                        {
                        }
                        fieldelement(planneddeliverydate; "Sales Line"."Planned Delivery Date")
                        {
                        }
                        fieldelement(plannedshipmentdate; "Sales Line"."Planned Shipment Date")
                        {
                        }
                        fieldelement(shippingagentcode; "Sales Line"."Shipping Agent Code")
                        {
                        }
                        fieldelement(shippingagentservicecode; "Sales Line"."Shipping Agent Service Code")
                        {
                        }
                        fieldelement(allowitemchargeassignment; "Sales Line"."Allow Item Charge Assignment")
                        {
                        }
                        fieldelement(returnqtytoreceive; "Sales Line"."Return Qty. to Receive")
                        {
                        }
                        fieldelement(returnqtytoreceivebase; "Sales Line"."Return Qty. to Receive (Base)")
                        {
                        }
                        fieldelement(returnqtyrcdnotinvd; "Sales Line"."Return Qty. Rcd. Not Invd.")
                        {
                        }
                        fieldelement(retqtyrcdnotinvdbase; "Sales Line"."Ret. Qty. Rcd. Not Invd.(Base)")
                        {
                        }
                        fieldelement(returnrcdnotinvd; "Sales Line"."Return Rcd. Not Invd.")
                        {
                        }
                        fieldelement(returnrcdnotinvdlcy; "Sales Line"."Return Rcd. Not Invd. (LCY)")
                        {
                        }
                        fieldelement(returnqtyreceived; "Sales Line"."Return Qty. Received")
                        {
                        }
                        fieldelement(returnqtyreceivedbase; "Sales Line"."Return Qty. Received (Base)")
                        {
                        }
                        fieldelement(bomitemno; "Sales Line"."BOM Item No.")
                        {
                        }
                        fieldelement(returnreasoncode; "Sales Line"."Return Reason Code")
                        {
                        }
                        fieldelement(allowlinedisc; "Sales Line"."Allow Line Disc.")
                        {
                        }
                        fieldelement(customerdiscgroup; "Sales Line"."Customer Disc. Group")
                        {
                        }
                        tableelement("Reservation Entry"; "Reservation Entry")
                        {
                            LinkFields = "Source Subtype" = FIELD("Document Type"), "Source ID" = FIELD("Document No."), "Source Ref. No." = FIELD("Line No.");
                            LinkTable = "Sales Line";
                            MinOccurs = Zero;
                            XmlName = 'reservationentry';
                            UseTemporary = true;
                            fieldattribute(sourcetype; "Reservation Entry"."Source Type")
                            {
                            }
                            fieldattribute(sourcesubtype; "Reservation Entry"."Source Subtype")
                            {
                            }
                            fieldattribute(sourceid; "Reservation Entry"."Source ID")
                            {
                            }
                            fieldattribute(sourcebatchname; "Reservation Entry"."Source Batch Name")
                            {
                            }
                            fieldattribute(sourceprodorderline; "Reservation Entry"."Source Prod. Order Line")
                            {
                            }
                            fieldattribute(sourcerefno; "Reservation Entry"."Source Ref. No.")
                            {
                            }
                            fieldattribute(positive; "Reservation Entry".Positive)
                            {
                            }
                            fieldelement(itemno; "Reservation Entry"."Item No.")
                            {
                            }
                            fieldelement(locationcode; "Reservation Entry"."Location Code")
                            {
                            }
                            fieldelement(quantitybase; "Reservation Entry"."Quantity (Base)")
                            {
                            }
                            fieldelement(reservationstatus; "Reservation Entry"."Reservation Status")
                            {
                            }
                            fieldelement(description; "Reservation Entry".Description)
                            {
                            }
                            fieldelement(creationdate; "Reservation Entry"."Creation Date")
                            {
                            }
                            fieldelement(expectedreceiptdate; "Reservation Entry"."Expected Receipt Date")
                            {
                            }
                            fieldelement(shipmentdate; "Reservation Entry"."Shipment Date")
                            {
                            }
                            fieldelement(serialno; "Reservation Entry"."Serial No.")
                            {
                            }
                            fieldelement(createdby; "Reservation Entry"."Created By")
                            {
                            }
                            fieldelement(changedby; "Reservation Entry"."Changed By")
                            {
                            }
                            fieldelement(qtyperunitofmeasure; "Reservation Entry"."Qty. per Unit of Measure")
                            {
                            }
                            fieldelement(quantity; "Reservation Entry".Quantity)
                            {
                            }
                            fieldelement(binding; "Reservation Entry".Binding)
                            {
                            }
                            fieldelement(suppressedactionmsg; "Reservation Entry"."Suppressed Action Msg.")
                            {
                            }
                            fieldelement(planningflexibility; "Reservation Entry"."Planning Flexibility")
                            {
                            }
                            fieldelement(warrantydate; "Reservation Entry"."Warranty Date")
                            {
                            }
                            fieldelement(expirationdate; "Reservation Entry"."Expiration Date")
                            {
                            }
                            fieldelement(qtytohandlebase; "Reservation Entry"."Qty. to Handle (Base)")
                            {
                            }
                            fieldelement(qtytoinvoicebase; "Reservation Entry"."Qty. to Invoice (Base)")
                            {
                            }
                            fieldelement(quantityinvoicedbase; "Reservation Entry"."Quantity Invoiced (Base)")
                            {
                            }
                            fieldelement(newserialno; "Reservation Entry"."New Serial No.")
                            {
                            }
                            fieldelement(newlotno; "Reservation Entry"."New Lot No.")
                            {
                            }
                            fieldelement(disallowcancellation; "Reservation Entry"."Disallow Cancellation")
                            {
                            }
                            fieldelement(lotno; "Reservation Entry"."Lot No.")
                            {
                            }
                            fieldelement(variantcode; "Reservation Entry"."Variant Code")
                            {
                            }
                            fieldelement(correction; "Reservation Entry".Correction)
                            {
                            }
                            fieldelement(newexpirationdate; "Reservation Entry"."New Expiration Date")
                            {
                            }
                            fieldelement(itemtracking; "Reservation Entry"."Item Tracking")
                            {
                            }
                        }
                    }
                }
            }
        }
    }
}

