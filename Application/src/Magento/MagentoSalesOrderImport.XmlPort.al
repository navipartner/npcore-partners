xmlport 6151401 "NPR Magento Sales Order Import"
{
    Caption = 'Magento Sales Order Import';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/sales_order';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(sales_orders)
        {
            textelement(sales_order)
            {
                MaxOccurs = Once;
                MinOccurs = Once;
                textattribute(order_no)
                {
                }
                textattribute(website_code)
                {
                    Occurrence = Optional;
                }
                textelement(order_date)
                {
                    MaxOccurs = Once;
                }
                textelement(currency_code)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(currency_factor)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(external_document_no)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(magento_coupon)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(your_reference)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(use_customer_salesperson)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                tableelement(tempcustomer; Customer)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'sell_to_customer';
                    UseTemporary = true;
                    fieldattribute(customer_no; TempCustomer."Telex No.")
                    {
                        Width = 100;
                    }
                    fieldattribute(tax_class; TempCustomer."VAT Registration No.")
                    {
                    }
                    fieldelement(name; TempCustomer.Name)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(name_2; TempCustomer."Name 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(address; TempCustomer.Address)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(address_2; TempCustomer."Address 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(post_code; TempCustomer."Post Code")
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(city; TempCustomer.City)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(country_code; TempCustomer."Country/Region Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(contact; TempCustomer.Contact)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(email; TempCustomer."E-Mail")
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(phone; TempCustomer."Phone No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(ean)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(vat_registration_no)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(invoice_email)
                    {
                        MinOccurs = Zero;
                        MaxOccurs = Once;
                    }
                }
                tableelement(tempcustomer2; Customer)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'ship_to_customer';
                    UseTemporary = true;
                    fieldelement(name; TempCustomer2.Name)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(name_2; TempCustomer2."Name 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(address; TempCustomer2.Address)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(address_2; TempCustomer2."Address 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(post_code; TempCustomer2."Post Code")
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(city; TempCustomer2.City)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(country_code; TempCustomer2."Country/Region Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(contact; TempCustomer2.Contact)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                }
                textelement(store_code)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(prices_excluding_vat)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(payments)
                {
                    tableelement(temppaymentline; "NPR Magento Payment Line")
                    {
                        MinOccurs = Zero;
                        XmlName = 'payment_method';
                        UseTemporary = true;
                        textattribute(paymentmethodtype)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                PaymentMethodType := LowerCase(TempPaymentLine."Document No.");
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                TempPaymentLine."Document No." := PaymentMethodType;
                            end;
                        }
                        fieldattribute(code; TempPaymentLine.Description)
                        {
                        }
                        textelement(payment_type)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            XmlName = 'payment_type';

                            trigger OnBeforePassVariable()
                            begin
                                payment_type := LowerCase(TempPaymentLine."No.");
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                TempPaymentLine."No." := payment_type;
                            end;
                        }
                        fieldelement(transaction_id; TempPaymentLine."External Reference No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(payment_amount; TempPaymentLine.Amount)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Once;
                        }
                        fieldelement(payment_fee; TempPaymentLine."Last Amount")
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                        }
                        fieldelement(shopper_reference; TempPaymentLine."Payment Gateway Shopper Ref.")
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                        }

                        trigger OnBeforeInsertRecord()
                        begin
                            LineNo += 1;
                            TempPaymentLine."Line No." := LineNo;
                        end;
                    }
                }
                tableelement(tempsalesline4; "Sales Line")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'shipment';
                    UseTemporary = true;
                    fieldelement(shipment_method; TempSalesLine4.Description)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(shipment_service; TempSalesLine4."Description 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(shipment_fee; TempSalesLine4."Unit Price")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(shipment_date; TempSalesLine4."Posting Date")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(delivery_location; TempSalesLine4."Location Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    tableelement(tempnpcsdocument; "NPR NpCs Document")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'collect_in_store';
                        UseTemporary = true;
                        fieldattribute(store_code; TempNpCsDocument."To Store Code")
                        {
                        }
                        fieldelement(allow_partial_delivery; TempNpCsDocument."Allow Partial Delivery")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(notify_customer_via_email; TempNpCsDocument."Notify Customer via E-mail")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(notify_customer_via_sms; TempNpCsDocument."Notify Customer via Sms")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(customer_email; TempNpCsDocument."Customer E-mail")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(customer_phone; TempNpCsDocument."Customer Phone No.")
                        {
                            MinOccurs = Zero;
                        }
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        LineNo += 1;
                        TempSalesLine4."Line No." := LineNo;
                    end;
                }
                textelement(comments)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tempitem; Item)
                    {
                        MinOccurs = Zero;
                        XmlName = 'comment_line';
                        UseTemporary = true;
                        fieldattribute(type; TempItem.Description)
                        {
                            Occurrence = Optional;
                        }
                        textelement(comment)
                        {
                            MaxOccurs = Once;

                            trigger OnBeforePassVariable()
                            var
                                InStream: InStream;
                                Line: Text;
                            begin
                                comment := '';
                                if TempItem."NPR Magento Description".HasValue() then begin
                                    TempItem.CalcFields("NPR Magento Description");
                                    TempItem."NPR Magento Description".CreateInStream(InStream);
                                    while not InStream.EOS do begin
                                        InStream.ReadText(Line);
                                        comment += Line;
                                    end;
                                end;
                            end;

                            trigger OnAfterAssignVariable()
                            var
                                OutStream: OutStream;
                            begin
                                Clear(TempItem."NPR Magento Description");
                                TempItem."NPR Magento Description".CreateOutStream(OutStream);
                                OutStream.WriteText(comment);
                            end;
                        }

                        trigger OnAfterInitRecord()
                        begin
                            Clear(TempItem);
                            comment := '';
                        end;

                        trigger OnBeforeInsertRecord()
                        begin
                            LineNo += 1;
                            TempItem."No." := Format(10000000000.0 + LineNo);
                        end;
                    }
                }
                textelement(sales_order_lines)
                {
                    MaxOccurs = Once;
                    tableelement(tempsalesline; "Sales Line")
                    {
                        AutoSave = true;
                        AutoUpdate = true;
                        MinOccurs = Once;
                        XmlName = 'sales_order_line';
                        UseTemporary = true;
                        textattribute(salesorderlinetype)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                SalesOrderLineType := LowerCase(TempSalesLine."Shortcut Dimension 2 Code");
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                TempSalesLine."Shortcut Dimension 2 Code" := SalesOrderLineType;
                            end;
                        }
                        fieldattribute(external_no; TempSalesLine."Description 2")
                        {
                        }
                        fieldelement(description; TempSalesLine.Description)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(description_2)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable()
                            begin
                                Clear(TempSalesLine9);
                                if TempSalesLine9.Get(TempSalesLine."Document Type", TempSalesLine."Document No.", TempSalesLine."Line No.") then;
                                description_2 := TempSalesLine9."Description 2";
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                if TempSalesLine9.Get(TempSalesLine."Document Type", TempSalesLine."Document No.", TempSalesLine."Line No.") then begin
                                    TempSalesLine9."Description 2" := description_2;
                                    TempSalesLine9.Modify();
                                end else begin
                                    TempSalesLine9.Init();
                                    TempSalesLine9 := TempSalesLine;
                                    TempSalesLine9."Description 2" := description_2;
                                    TempSalesLine9.Insert();
                                end;
                            end;
                        }
                        fieldelement(unit_price_incl_vat; TempSalesLine."Unit Price")
                        {
                        }
                        fieldelement(unit_price_excl_vat; TempSalesLine."Unit Cost (LCY)")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(quantity; TempSalesLine.Quantity)
                        {
                        }
                        fieldelement(unit_of_measure; TempSalesLine."Unit of Measure")
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_pct; TempSalesLine."Line Discount %")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_amount; TempSalesLine."Line Discount Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vat_percent; TempSalesLine."VAT Base Amount")
                        {
                        }
                        fieldelement(line_amount_incl_vat; TempSalesLine."Line Amount")
                        {
                        }
                        fieldelement(line_amount_excl_vat; TempSalesLine.Amount)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(requested_delivery_date; TempSalesLine."Requested Delivery Date")
                        {
                            MinOccurs = Zero;
                        }

                        trigger OnAfterInitRecord()
                        begin
                            LineNo += 1;
                            TempSalesLine."Line No." := LineNo;
                        end;

                        trigger OnBeforeInsertRecord()
                        begin
                        end;
                    }
                }
            }
        }
    }

    var
        TempSalesLine9: Record "Sales Line" temporary;
        LineNo: Integer;

    procedure GetOrderNo(): Text
    begin
        exit(order_no);
    end;

    procedure GetWebsiteCode(): Text
    begin
        exit(website_code);
    end;
}