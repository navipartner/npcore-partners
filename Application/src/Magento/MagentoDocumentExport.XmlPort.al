xmlport 6151402 "NPR Magento Document Export"
{
    Caption = 'Magento Document Export';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/naviconnect/documents';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(documents)
        {
            tableelement(salesinvheader; "Sales Invoice Header")
            {
                MinOccurs = Zero;
                XmlName = 'invoice';
                fieldattribute(no; SalesInvHeader."No.")
                {
                }
                fieldelement(posting_date; SalesInvHeader."Posting Date")
                {
                }
                fieldelement(amount_excl_vat; SalesInvHeader.Amount)
                {
                }
                fieldelement(amount_incl_vat; SalesInvHeader."Amount Including VAT")
                {
                }
                fieldelement(currency_code; SalesInvHeader."Currency Code")
                {
                }
                fieldelement(sell_to_contact; SalesInvHeader."Sell-to Contact")
                {
                }
                fieldelement(your_reference; SalesInvHeader."Your Reference")
                {
                }
                fieldelement(due_date; SalesInvHeader."Due Date")
                {
                }
                fieldelement(remaining_amount; SalesInvHeader."Remaining Amount")
                {
                }
                textelement(salesinvlines)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'lines';
                    tableelement(salesinvline; "Sales Invoice Line")
                    {
                        LinkFields = "Document No." = FIELD("No.");
                        LinkTable = SalesInvHeader;
                        MinOccurs = Zero;
                        XmlName = 'line';
                        fieldattribute(line_no; SalesInvLine."Line No.")
                        {
                        }
                        textelement(salesinvlinetype)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                if LineTypeDict.Get(SalesInvLine.Type.AsInteger(), SalesInvLineType) then;
                            end;
                        }
                        fieldelement(no; SalesInvLine."No.")
                        {
                        }
                        fieldelement(variant_code; SalesInvLine."Variant Code")
                        {
                        }
                        textelement(salesinvlineexternalno)
                        {
                            MaxOccurs = Once;
                            XmlName = 'external_no';

                            trigger OnBeforePassVariable()
                            begin
                                SalesInvLineExternalNo := SalesInvLine."No.";
                                if SalesInvLine."Variant Code" <> '' then
                                    SalesInvLineExternalNo += '_' + SalesInvLine."Variant Code";
                            end;
                        }
                        fieldelement(quantity; SalesInvLine.Quantity)
                        {
                        }
                        fieldelement(unit_price; SalesInvLine."Unit Price")
                        {
                        }
                        fieldelement(line_discount_pct; SalesInvLine."Line Discount %")
                        {
                        }
                        fieldelement(line_discount_amount; SalesInvLine."Line Discount Amount")
                        {
                        }
                        fieldelement(amount; SalesInvLine.Amount)
                        {
                        }
                        fieldelement(vat_pct; SalesInvLine."VAT %")
                        {
                        }
                        fieldelement(amount_including_vat; SalesInvLine."Amount Including VAT")
                        {
                        }

                        trigger OnPreXmlItem()
                        begin

                            if (HideLines) then
                                currXMLport.Break();
                        end;
                    }
                }
                textelement(relateddocumentsinvoice)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'relateddocuments';
                    tableelement(tmpdocumentsearchresultinvoice; "Document Search Result")
                    {
                        MinOccurs = Zero;
                        XmlName = 'document';
                        SourceTableView = WHERE("Doc. Type" = FILTER(< 100));
                        UseTemporary = true;
                        textattribute(relatedtypeinvoice)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                RelatedTypeInvoice := GetRelatedDocTypeAsText(TmpDocumentSearchResultInvoice."Doc. Type");
                            end;
                        }
                        fieldattribute(number; TmpDocumentSearchResultInvoice."Doc. No.")
                        {
                        }
                        fieldattribute(package_tracking_no; TmpDocumentSearchResultInvoice.Description)
                        {
                            Occurrence = Optional;
                        }
                        textattribute(invoice_shipmentmethod)
                        {
                            Occurrence = Optional;
                            XmlName = 'shipment_method_code';

                            trigger OnBeforePassVariable()
                            begin
                                Invoice_ShipmentMethod := '';
                                if (TmpDocumentSearchResultInvoice.Get(120, TmpDocumentSearchResultInvoice."Doc. No.", 0)) then
                                    Invoice_ShipmentMethod := TmpDocumentSearchResultInvoice.Description;
                            end;
                        }
                    }
                }

                trigger OnAfterGetRecord()
                begin

                    if (TmpDocumentSearchResultInvoice.IsTemporary()) then
                        TmpDocumentSearchResultInvoice.DeleteAll();

                    GetRelatedDocs(SalesInvHeader."Order No.", SalesInvHeader."No.", TmpDocumentSearchResultInvoice);

                    if (SalesInvHeader."Currency Code" = '') then
                        SalesInvHeader."Currency Code" := GeneralLedgerSetup."LCY Code";
                end;

                trigger OnPreXmlItem()
                begin
                    if not ExportInvoices then
                        SalesInvHeader.SetFilter("No.", '=%1&<>%1', '');

                    SalesInvHeader.SetRange("Bill-to Customer No.", CustomerNo);
                    SalesInvHeader.SetRange("Posting Date", StartDate, EndDate);

                    if (DocumentNumber <> '') then
                        SalesInvHeader.SetRange("No.", DocumentNumber);
                end;
            }
            tableelement(salescrmemoheader; "Sales Cr.Memo Header")
            {
                MinOccurs = Zero;
                XmlName = 'cr_memo';
                fieldattribute(no; SalesCrMemoHeader."No.")
                {
                }
                fieldelement(posting_date; SalesCrMemoHeader."Posting Date")
                {
                }
                fieldelement(amount_excl_vat; SalesCrMemoHeader.Amount)
                {
                }
                fieldelement(amount_incl_vat; SalesCrMemoHeader."Amount Including VAT")
                {
                }
                fieldelement(currency_code; SalesCrMemoHeader."Currency Code")
                {
                }
                fieldelement(sell_to_contact; SalesCrMemoHeader."Sell-to Contact")
                {
                }
                fieldelement(your_reference; SalesCrMemoHeader."Your Reference")
                {
                }
                textelement(salescrmemolines)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'lines';
                    tableelement(salescrmemoline; "Sales Cr.Memo Line")
                    {
                        LinkFields = "Document No." = FIELD("No.");
                        LinkTable = SalesCrMemoHeader;
                        MinOccurs = Zero;
                        XmlName = 'line';
                        fieldattribute(line_no; SalesCrMemoLine."Line No.")
                        {
                        }
                        textelement(salescrmemolinetype)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                if LineTypeDict.Get(SalesCrMemoLine.Type.AsInteger(), SalesCrMemoLineType) then;
                            end;
                        }
                        fieldelement(no; SalesCrMemoLine."No.")
                        {
                        }
                        fieldelement(variant_code; SalesCrMemoLine."Variant Code")
                        {
                        }
                        textelement(salescrmemolineexternalno)
                        {
                            MaxOccurs = Once;
                            XmlName = 'external_no';

                            trigger OnBeforePassVariable()
                            begin
                                SalesCrMemoLineExternalNo := SalesCrMemoLine."No.";
                                if SalesCrMemoLine."Variant Code" <> '' then
                                    SalesCrMemoLineExternalNo += '_' + SalesCrMemoLine."Variant Code";
                            end;
                        }
                        fieldelement(quantity; SalesCrMemoLine.Quantity)
                        {
                        }
                        fieldelement(unit_price; SalesCrMemoLine."Unit Price")
                        {
                        }
                        fieldelement(line_discount_pct; SalesCrMemoLine."Line Discount %")
                        {
                        }
                        fieldelement(line_discount_amount; SalesCrMemoLine."Line Discount Amount")
                        {
                        }
                        fieldelement(amount; SalesCrMemoLine.Amount)
                        {
                        }
                        fieldelement(vat_pct; SalesCrMemoLine."VAT %")
                        {
                        }
                        fieldelement(amount_including_vat; SalesCrMemoLine."Amount Including VAT")
                        {
                        }

                        trigger OnPreXmlItem()
                        begin
                            if (HideLines) then
                                currXMLport.Break();
                        end;
                    }
                }
                textelement(relateddocumentscrmemo)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'relateddocuments';
                    tableelement(tmpdocumentsearchresultcrmemo; "Document Search Result")
                    {
                        MinOccurs = Zero;
                        XmlName = 'document';
                        SourceTableView = WHERE("Doc. Type" = FILTER(< 100));
                        UseTemporary = true;
                        textattribute(relatedtypecrmemo)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                RelatedTypeCrMemo := GetRelatedDocTypeAsText(TmpDocumentSearchResultCrMemo."Doc. Type");
                            end;
                        }
                        fieldattribute(number; TmpDocumentSearchResultCrMemo."Doc. No.")
                        {
                        }
                        fieldattribute(package_tracking_no; TmpDocumentSearchResultCrMemo.Description)
                        {
                            Occurrence = Optional;
                        }
                        textattribute(crmemo_shipmentmethod)
                        {
                            Occurrence = Optional;
                            XmlName = 'shipment_method_code';

                            trigger OnBeforePassVariable()
                            begin
                                CrMemo_ShipmentMethod := '';
                                if (TmpDocumentSearchResultCrMemo.Get(120, TmpDocumentSearchResultCrMemo."Doc. No.", 0)) then
                                    CrMemo_ShipmentMethod := TmpDocumentSearchResultCrMemo.Description;
                            end;
                        }
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if (TmpDocumentSearchResultCrMemo.IsTemporary()) then
                        TmpDocumentSearchResultCrMemo.DeleteAll();

                    GetRelatedDocs(SalesCrMemoHeader."Return Order No.", SalesCrMemoHeader."No.", TmpDocumentSearchResultCrMemo);

                    if (SalesCrMemoHeader."Currency Code" = '') then
                        SalesCrMemoHeader."Currency Code" := GeneralLedgerSetup."LCY Code";
                end;

                trigger OnPreXmlItem()
                begin
                    if not ExportCrMemos then
                        SalesCrMemoHeader.SetFilter("No.", '=%1&<>%1', '');

                    SalesCrMemoHeader.SetRange("Posting Date", StartDate, EndDate);
                    SalesCrMemoHeader.SetRange("Bill-to Customer No.", CustomerNo);

                    if (DocumentNumber <> '') then
                        SalesCrMemoHeader.SetRange("No.", DocumentNumber);
                end;
            }
            tableelement(salesheader; "Sales Header")
            {
                MinOccurs = Zero;
                XmlName = 'order';
                fieldattribute(no; SalesHeader."No.")
                {
                }
                textattribute(salesheaderdoctype)
                {
                    XmlName = 'document_type';

                    trigger OnBeforePassVariable()
                    begin
                        SalesHeaderDocType := GetOrderDocTypeAsText(SalesHeader);
                    end;
                }
                fieldelement(ext_no; SalesHeader."NPR External Order No.")
                {
                }
                fieldelement(posting_date; SalesHeader."Posting Date")
                {
                }
                fieldelement(amount_excl_vat; SalesHeader.Amount)
                {
                }
                fieldelement(amount_incl_vat; SalesHeader."Amount Including VAT")
                {
                }
                fieldelement(order_date; SalesHeader."Order Date")
                {
                }
                fieldelement(requested_delivery_date; SalesHeader."Requested Delivery Date")
                {
                }
                fieldelement(salesperson_code; SalesHeader."Salesperson Code")
                {
                }
                fieldelement(currency_code; SalesHeader."Currency Code")
                {
                }
                fieldelement(sell_to_contact; SalesHeader."Sell-to Contact")
                {
                }
                fieldelement(your_reference; SalesHeader."Your Reference")
                {
                }
                textelement(saleslines)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'lines';
                    tableelement(salesline; "Sales Line")
                    {
                        LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        LinkTable = SalesHeader;
                        MinOccurs = Zero;
                        XmlName = 'line';
                        fieldattribute(line_no; SalesLine."Line No.")
                        {
                        }
                        textelement(saleslinetype)
                        {
                            XmlName = 'type';
                            trigger OnBeforePassVariable()
                            begin
                                if LineTypeDict.Get(SalesLine.Type.AsInteger(), SalesLineType) then;
                            end;
                        }
                        fieldelement(no; SalesLine."No.")
                        {
                        }
                        fieldelement(variant_code; SalesLine."Variant Code")
                        {
                        }
                        textelement(saleslineexternalno)
                        {
                            MaxOccurs = Once;
                            XmlName = 'external_no';

                            trigger OnBeforePassVariable()
                            begin
                                SalesLineExternalNo := SalesLine."No.";
                                if SalesLine."Variant Code" <> '' then
                                    SalesLineExternalNo += '_' + SalesLine."Variant Code";
                            end;
                        }
                        fieldelement(quantity; SalesLine.Quantity)
                        {
                        }
                        fieldelement(unit_price; SalesLine."Unit Price")
                        {
                        }
                        fieldelement(line_discount_pct; SalesLine."Line Discount %")
                        {
                        }
                        fieldelement(line_discount_amount; SalesLine."Line Discount Amount")
                        {
                        }
                        fieldelement(amount; SalesLine.Amount)
                        {
                        }
                        fieldelement(vat_pct; SalesLine."VAT %")
                        {
                        }
                        fieldelement(amount_including_vat; SalesLine."Amount Including VAT")
                        {
                        }
                        fieldelement(planned_delivery_date; SalesLine."Planned Delivery Date")
                        {
                        }
                        fieldelement(description; SalesLine.Description)
                        {
                        }
                        fieldelement(outstanding_quantity; SalesLine."Outstanding Quantity")
                        {
                        }

                        trigger OnPreXmlItem()
                        begin
                            if (HideLines) then
                                currXMLport.Break();
                        end;
                    }
                }
                textelement(relateddocumentsorder)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'relateddocuments';
                    tableelement(tmpdocumentsearchresultorder; "Document Search Result")
                    {
                        MinOccurs = Zero;
                        XmlName = 'document';
                        SourceTableView = WHERE("Doc. Type" = FILTER(< 100));
                        UseTemporary = true;
                        textattribute(relatedtypeorder)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                RelatedTypeOrder := GetRelatedDocTypeAsText(TmpDocumentSearchResultOrder."Doc. Type");
                            end;
                        }
                        fieldattribute(number; TmpDocumentSearchResultOrder."Doc. No.")
                        {
                        }
                        fieldattribute(package_tracking_no; TmpDocumentSearchResultOrder.Description)
                        {
                            Occurrence = Optional;
                        }
                        textattribute(order_shipmentmethod)
                        {
                            Occurrence = Optional;
                            XmlName = 'shipment_method_code';

                            trigger OnBeforePassVariable()
                            begin
                                Order_ShipmentMethod := '';
                                if (TmpDocumentSearchResultOrder.Get(120, TmpDocumentSearchResultOrder."Doc. No.", 0)) then
                                    Order_ShipmentMethod := TmpDocumentSearchResultOrder.Description;
                            end;
                        }
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if (TmpDocumentSearchResultOrder.IsTemporary()) then
                        TmpDocumentSearchResultOrder.DeleteAll();

                    GetRelatedDocs(SalesHeader."No.", SalesHeader."No.", TmpDocumentSearchResultOrder);

                    if (SalesHeader."Currency Code" = '') then
                        SalesHeader."Currency Code" := GeneralLedgerSetup."LCY Code";
                end;

                trigger OnPreXmlItem()
                begin
                    if not ExportOrders then
                        SalesHeader.SetFilter("No.", '=%1&<>%1', '');

                    SalesHeader.SetRange("Bill-to Customer No.", CustomerNo);
                    SalesHeader.SetRange("Posting Date", StartDate, EndDate);

                    if (DocumentNumber <> '') then
                        SalesHeader.SetRange("No.", DocumentNumber);
                end;
            }
            tableelement(salesshipmentheader; "Sales Shipment Header")
            {
                MinOccurs = Zero;
                XmlName = 'shipment';
                fieldattribute(no; SalesShipmentHeader."No.")
                {
                }
                fieldelement(posting_date; SalesShipmentHeader."Posting Date")
                {
                }
                fieldelement(order_date; SalesShipmentHeader."Order Date")
                {
                }
                fieldelement(currency_code; SalesShipmentHeader."Currency Code")
                {
                }
                fieldelement(sell_to_contact; SalesShipmentHeader."Sell-to Contact")
                {
                }
                fieldelement(your_reference; SalesShipmentHeader."Your Reference")
                {
                }
                textelement(shipment_address)
                {
                    MaxOccurs = Once;
                    XmlName = 'address';
                    fieldattribute(no; SalesShipmentHeader."Ship-to Code")
                    {
                    }
                    fieldelement(name; SalesShipmentHeader."Ship-to Name")
                    {
                    }
                    fieldelement(name2; SalesShipmentHeader."Ship-to Name 2")
                    {
                    }
                    fieldelement(address; SalesShipmentHeader."Ship-to Address")
                    {
                    }
                    fieldelement(address2; SalesShipmentHeader."Ship-to Address 2")
                    {
                    }
                    fieldelement(postcode; SalesShipmentHeader."Ship-to Post Code")
                    {
                    }
                    fieldelement(city; SalesShipmentHeader."Ship-to City")
                    {
                    }
                    fieldelement(contact; SalesShipmentHeader."Ship-to Contact")
                    {
                    }
                }
                textelement(shipment_details)
                {
                    MaxOccurs = Once;
                    XmlName = 'details';
                    fieldelement(shipment_date; SalesShipmentHeader."Shipment Date")
                    {
                    }
                    fieldelement(shipment_method_code; SalesShipmentHeader."Shipment Method Code")
                    {
                    }
                    fieldelement(shipping_agent_code; SalesShipmentHeader."Shipping Agent Code")
                    {
                    }
                    fieldelement(shipping_agent_service_code; SalesShipmentHeader."Shipping Agent Service Code")
                    {
                    }
                    fieldelement(package_tracking_no; SalesShipmentHeader."Package Tracking No.")
                    {
                    }
                    fieldelement(number_of_packages; SalesShipmentHeader."NPR Kolli")
                    {
                    }
                }
                textelement(shipmentlines)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'lines';
                    tableelement(salesshipmentline; "Sales Shipment Line")
                    {
                        LinkFields = "Document No." = FIELD("No.");
                        LinkTable = SalesShipmentHeader;
                        MinOccurs = Zero;
                        XmlName = 'line';
                        fieldattribute(line_no; SalesShipmentLine."Line No.")
                        {
                        }
                        textelement(shipmentlinetype)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                If LineTypeDict.Get(SalesShipmentLine.Type.AsInteger(), ShipmentLineType) then;
                            end;
                        }
                        fieldelement(no; SalesShipmentLine."No.")
                        {
                        }
                        fieldelement(variant_code; SalesShipmentLine."Variant Code")
                        {
                        }
                        textelement(external_no)
                        {
                        }
                        fieldelement(quantity; SalesShipmentLine.Quantity)
                        {
                        }
                        fieldelement(description; SalesShipmentLine.Description)
                        {
                        }

                        trigger OnPreXmlItem()
                        begin
                            if (HideLines) then
                                currXMLport.Break();
                        end;
                    }
                }
                textelement(relateddocuments)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tmpdocsearchresultshipment; "Document Search Result")
                    {
                        XmlName = 'document';
                        SourceTableView = WHERE("Doc. Type" = FILTER(< 100));
                        UseTemporary = true;
                        textattribute(relatedtypeshipment)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                RelatedTypeShipment := GetRelatedDocTypeAsText(TmpDocSearchResultShipment."Doc. Type");
                            end;
                        }
                        fieldattribute(number; TmpDocSearchResultShipment."Doc. No.")
                        {
                        }
                        fieldattribute(package_tracking_no; TmpDocSearchResultShipment.Description)
                        {
                            Occurrence = Optional;
                        }
                        textattribute(shipment_shipmentmethod)
                        {
                            Occurrence = Optional;
                            XmlName = 'shipment_method_code';

                            trigger OnBeforePassVariable()
                            begin
                                Shipment_ShipmentMethod := '';
                                if (TmpDocSearchResultShipment.Get(120, TmpDocSearchResultShipment."Doc. No.", 0)) then
                                    Shipment_ShipmentMethod := TmpDocSearchResultShipment.Description;
                            end;
                        }
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if (TmpDocSearchResultShipment.IsTemporary()) then
                        TmpDocSearchResultShipment.DeleteAll();

                    GetRelatedDocs(SalesShipmentHeader."Order No.", SalesShipmentHeader."No.", TmpDocSearchResultShipment);

                    if (SalesShipmentHeader."Currency Code" = '') then
                        SalesShipmentHeader."Currency Code" := GeneralLedgerSetup."LCY Code";
                end;

                trigger OnPreXmlItem()
                begin
                    if not ExportShipments then
                        SalesShipmentHeader.SetFilter("No.", '=%1&<>%1', '');

                    SalesShipmentHeader.SetRange("Posting Date", StartDate, EndDate);
                    SalesShipmentHeader.SetRange("Bill-to Customer No.", CustomerNo);

                    if (DocumentNumber <> '') then
                        SalesShipmentHeader.SetRange("No.", DocumentNumber);
                end;
            }
            tableelement(salesquote; "Sales Header")
            {
                MinOccurs = Zero;
                XmlName = 'quote';
                fieldattribute(no; SalesQuote."No.")
                {
                }
                textattribute(salesquotedoctype)
                {
                    XmlName = 'document_type';

                    trigger OnBeforePassVariable()
                    begin

                        SalesQuoteDocType := GetOrderDocTypeAsText(SalesQuote);
                    end;
                }
                fieldelement(ext_no; SalesQuote."NPR External Order No.")
                {
                }
                fieldelement(posting_date; SalesQuote."Posting Date")
                {
                }
                fieldelement(amount_excl_vat; SalesQuote.Amount)
                {
                }
                fieldelement(amount_incl_vat; SalesQuote."Amount Including VAT")
                {
                }
                fieldelement(order_date; SalesQuote."Order Date")
                {
                }
                fieldelement(requested_delivery_date; SalesQuote."Requested Delivery Date")
                {
                }
                fieldelement(salesperson_code; SalesQuote."Salesperson Code")
                {
                }
                fieldelement(currency_code; SalesQuote."Currency Code")
                {
                }
                fieldelement(sell_to_contact; SalesQuote."Sell-to Contact")
                {
                }
                fieldelement(your_reference; SalesQuote."Your Reference")
                {
                }
                textelement(quotelines)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'lines';
                    tableelement(quoteline; "Sales Line")
                    {
                        LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        LinkTable = SalesQuote;
                        MinOccurs = Zero;
                        XmlName = 'line';
                        fieldattribute(line_no; QuoteLine."Line No.")
                        {
                        }
                        textelement(quotelinetype)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                if LineTypeDict.Get(SalesLine.Type.AsInteger(), QuoteLineType) then;
                            end;
                        }
                        fieldelement(no; QuoteLine."No.")
                        {
                        }
                        fieldelement(variant_code; QuoteLine."Variant Code")
                        {
                        }
                        textelement(quotelineexternalno)
                        {
                            MaxOccurs = Once;
                            XmlName = 'external_no';

                            trigger OnBeforePassVariable()
                            begin

                                QuoteLineExternalNo := SalesLine."No.";
                                if SalesLine."Variant Code" <> '' then
                                    QuoteLineExternalNo += '_' + SalesLine."Variant Code";
                            end;
                        }
                        fieldelement(quantity; QuoteLine.Quantity)
                        {
                        }
                        fieldelement(unit_price; QuoteLine."Unit Price")
                        {
                        }
                        fieldelement(line_discount_pct; QuoteLine."Line Discount %")
                        {
                        }
                        fieldelement(line_discount_amount; QuoteLine."Line Discount Amount")
                        {
                        }
                        fieldelement(amount; QuoteLine.Amount)
                        {
                        }
                        fieldelement(vat_pct; QuoteLine."VAT %")
                        {
                        }
                        fieldelement(amount_including_vat; QuoteLine."Amount Including VAT")
                        {
                        }
                        fieldelement(planned_delivery_date; QuoteLine."Planned Delivery Date")
                        {
                        }
                        fieldelement(description; QuoteLine.Description)
                        {
                        }
                        fieldelement(outstanding_quantity; QuoteLine."Outstanding Quantity")
                        {
                        }

                        trigger OnPreXmlItem()
                        begin

                            if (HideLines) then
                                currXMLport.Break();
                        end;
                    }
                }
                textelement(relateddocumentsquote)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'relateddocuments';
                }

                trigger OnAfterGetRecord()
                begin

                    if (TmpDocumentSearchResultOrder.IsTemporary()) then
                        TmpDocumentSearchResultOrder.DeleteAll();

                    if (SalesQuote."Currency Code" = '') then
                        SalesQuote."Currency Code" := GeneralLedgerSetup."LCY Code";

                    if (SalesQuote."Due Date" < Today) then
                        currXMLport.Skip();
                end;

                trigger OnPreXmlItem()
                begin

                    if not ExportQuotes then
                        SalesHeader.SetFilter("No.", '=%1&<>%1', '');

                    SalesHeader.SetRange("Bill-to Customer No.", CustomerNo);
                    SalesHeader.SetRange("Posting Date", StartDate, EndDate);

                    if (DocumentNumber <> '') then
                        SalesHeader.SetRange("No.", DocumentNumber);
                end;
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        InitLineTypeDict();
    end;

    trigger OnPreXmlPort()
    begin
        GeneralLedgerSetup.Get();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        LineTypeDict: Dictionary of [Integer, Text];
        CustomerNo: Code[20];
        EndDate: Date;
        StartDate: Date;
        ExportInvoices: Boolean;
        ExportCrMemos: Boolean;
        ExportOrders: Boolean;
        DocumentNumber: Code[20];
        ExportShipments: Boolean;
        HideLines: Boolean;
        ExportQuotes: Boolean;

    procedure SetFilters(NewCustomerNo: Code[20]; NewDocumentNo: Code[20]; NewStartDate: Date; NewEndDate: Date; NewHideLines: Boolean; NewExportInvoices: Boolean; NewExportCrMemos: Boolean; NewExportOrders: Boolean; NewExportShipments: Boolean)
    begin

        CustomerNo := NewCustomerNo;
        EndDate := NewEndDate;
        StartDate := NewStartDate;
        ExportInvoices := NewExportInvoices;
        ExportCrMemos := NewExportCrMemos;
        ExportOrders := NewExportOrders;

        ExportQuotes := false;

        DocumentNumber := NewDocumentNo;
        ExportShipments := NewExportShipments;
        HideLines := NewHideLines;
    end;

    procedure SetQuoteFilter(NewCustomerNo: Code[20]; NewDocumentNo: Code[20]; NewStartDate: Date; NewEndDate: Date; NewHideLines: Boolean)
    begin
        CustomerNo := NewCustomerNo;
        EndDate := NewEndDate;
        StartDate := NewStartDate;

        DocumentNumber := NewDocumentNo;
        HideLines := NewHideLines;

        ExportQuotes := true;

        ExportCrMemos := false;
        ExportInvoices := false;
        ExportOrders := false;
        ExportShipments := false;
    end;

    local procedure InitLineTypeDict()
    var
        LineType: Text;
        IndexOfOrdinal: Integer;
        Ordinal: Integer;
    begin
        foreach Ordinal in Enum::"Sales Line Type".Ordinals() do begin
            IndexOfOrdinal := Enum::"Sales Line Type".Ordinals().IndexOf(Ordinal);
            Enum::"Sales Line Type".Names().Get(IndexOfOrdinal, LineType);
            LineTypeDict.Add(Ordinal, LineType);
        end;
    end;

    local procedure GetRelatedDocs(DocumentNumber: Code[20]; LinkedFromDocNo: Code[20]; var TmpDocumentSearchResult: Record "Document Search Result" temporary)
    var
        LocalSalesShipmentHeader: Record "Sales Shipment Header";
        LocalOrder: Record "Sales Header";
        LocalSalesInvoiceHeader: Record "Sales Invoice Header";
        LocalSalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin

        if (DocumentNumber = '') then
            exit;

        LocalOrder.SetFilter("No.", '=%1', DocumentNumber);
        if (LocalOrder.FindSet()) then begin
            repeat
                TmpDocumentSearchResult.Init();
                TmpDocumentSearchResult."Doc. Type" := 10;
                TmpDocumentSearchResult."Doc. No." := LocalOrder."No.";
                if (TmpDocumentSearchResult."Doc. No." <> LinkedFromDocNo) then
                    if (TmpDocumentSearchResult.Insert()) then;
            until (LocalOrder.Next() = 0);
        end;

        LocalSalesShipmentHeader.SetFilter("Order No.", '=%1', DocumentNumber);
        if (LocalSalesShipmentHeader.FindSet()) then begin
            repeat
                TmpDocumentSearchResult.Init();
                TmpDocumentSearchResult."Doc. Type" := 20;
                TmpDocumentSearchResult."Doc. No." := LocalSalesShipmentHeader."No.";
                TmpDocumentSearchResult.Description := CopyStr(LocalSalesShipmentHeader."Package Tracking No.", 1, MaxStrLen(TmpDocumentSearchResult.Description));
                if (TmpDocumentSearchResult."Doc. No." <> LinkedFromDocNo) then
                    if (TmpDocumentSearchResult.Insert()) then;

                TmpDocumentSearchResult.Init();
                TmpDocumentSearchResult."Doc. Type" := 120;
                TmpDocumentSearchResult."Doc. No." := LocalSalesShipmentHeader."No.";
                TmpDocumentSearchResult.Description := CopyStr(LocalSalesShipmentHeader."Shipment Method Code", 1, MaxStrLen(TmpDocumentSearchResult.Description));
                if (TmpDocumentSearchResult."Doc. No." <> LinkedFromDocNo) then
                    if (TmpDocumentSearchResult.Insert()) then;

            until (LocalSalesShipmentHeader.Next() = 0);
        end;

        LocalSalesInvoiceHeader.SetFilter("Order No.", '=%1', DocumentNumber);
        if (LocalSalesInvoiceHeader.FindSet()) then begin
            repeat
                TmpDocumentSearchResult.Init();
                TmpDocumentSearchResult."Doc. Type" := 30;
                TmpDocumentSearchResult."Doc. No." := LocalSalesInvoiceHeader."No.";
                if (TmpDocumentSearchResult."Doc. No." <> LinkedFromDocNo) then
                    if (TmpDocumentSearchResult.Insert()) then;
            until (LocalSalesInvoiceHeader.Next() = 0);
        end;

        LocalSalesCrMemoHeader.SetFilter("Return Order No.", '=%1', DocumentNumber);
        if (LocalSalesCrMemoHeader.FindSet()) then begin
            repeat
                TmpDocumentSearchResult.Init();
                TmpDocumentSearchResult."Doc. Type" := 40;
                TmpDocumentSearchResult."Doc. No." := LocalSalesCrMemoHeader."No.";
                if (TmpDocumentSearchResult."Doc. No." <> LinkedFromDocNo) then
                    if (TmpDocumentSearchResult.Insert()) then;
            until (LocalSalesCrMemoHeader.Next() = 0);
        end;
    end;

    local procedure GetRelatedDocTypeAsText(DocType: Integer): Text
    begin

        case DocType of
            10:
                exit('Order');
            20:
                exit('Shipment');
            30:
                exit('Invoice');
            40:
                exit('Credit Memo');
        end;
    end;

    local procedure GetOrderDocTypeAsText(LocalSalesHeader: Record "Sales Header"): Text
    begin

        case LocalSalesHeader."Document Type" of
            LocalSalesHeader."Document Type"::"Blanket Order":
                exit('Blank Order');
            LocalSalesHeader."Document Type"::"Credit Memo":
                exit('Credit Memo');
            LocalSalesHeader."Document Type"::Invoice:
                exit('Invoice');
            LocalSalesHeader."Document Type"::Quote:
                exit('Quote');
            LocalSalesHeader."Document Type"::Order:
                exit('Order');
            LocalSalesHeader."Document Type"::"Return Order":
                exit('Return Order');
        end;
    end;
}