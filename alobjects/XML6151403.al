xmlport 6151403 "Magento Return Order Import"
{
    // MAG2.12/MHA /20180425  CASE 309647 Object created - Sales Return Order Import
    // MAG2.20/MHA /20190411  CASE 349994 Added <use_customer_salesperson>
    // MAG2.24/MHA /20191120  CASE 319135 Added @type attribute to <payment_refund>
    // MAG2.24/ZESO/20200131  CASE 384878 Set type attribute on payment_refund to optional

    Caption = 'Magento Sales Order Import';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/sales_return_order';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(sales_return_orders)
        {
            textelement(sales_return_order)
            {
                MaxOccurs = Once;
                MinOccurs = Once;
                textattribute(return_order_no)
                {
                }
                textattribute(website_code)
                {
                    Occurrence = Optional;
                }
                textelement(return_order_date)
                {
                    MaxOccurs = Once;
                }
                textelement(currency_code)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(external_document_no)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(use_customer_salesperson)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                tableelement(tempcustomer;Customer)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'sell_to_customer';
                    UseTemporary = true;
                    fieldattribute(customer_no;TempCustomer."Telex No.")
                    {
                        Width = 100;
                    }
                    fieldattribute(tax_class;TempCustomer."VAT Registration No.")
                    {
                    }
                    fieldelement(name;TempCustomer.Name)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(name_2;TempCustomer."Name 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(address;TempCustomer.Address)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(address_2;TempCustomer."Address 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(post_code;TempCustomer."Post Code")
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(city;TempCustomer.City)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(country_code;TempCustomer."Country/Region Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(contact;TempCustomer.Contact)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(email;TempCustomer."E-Mail")
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(phone;TempCustomer."Phone No.")
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
                }
                tableelement(tempcustomer2;Customer)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'ship_to_customer';
                    UseTemporary = true;
                    fieldelement(name;TempCustomer2.Name)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(name_2;TempCustomer2."Name 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(address;TempCustomer2.Address)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(address_2;TempCustomer2."Address 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(post_code;TempCustomer2."Post Code")
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(city;TempCustomer2.City)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(country_code;TempCustomer2."Country/Region Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(contact;TempCustomer2.Contact)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                }
                textelement(payment_refunds)
                {
                    tableelement(temppaymentline;"Magento Payment Line")
                    {
                        MinOccurs = Zero;
                        XmlName = 'payment_refund';
                        UseTemporary = true;
                        textattribute(paymentmethodtype)
                        {
                            Occurrence = Optional;
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                //-MAG1.22
                                PaymentMethodType := LowerCase(TempPaymentLine."Document No.");
                                //+MAG1.22
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                //-MAG1.22
                                TempPaymentLine."Document No." := PaymentMethodType;
                                //+MAG1.22
                            end;
                        }
                        fieldattribute(code;TempPaymentLine.Description)
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
                        fieldelement(transaction_id;TempPaymentLine."External Reference No.")
                        {
                            MaxOccurs = Unbounded;
                        }
                        fieldelement(amount;TempPaymentLine.Amount)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Once;
                        }
                        fieldelement(payment_fee_refund;TempPaymentLine."Last Amount")
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
                tableelement(tempsalesline4;"Sales Line")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'shipment_refund';
                    UseTemporary = true;
                    fieldelement(shipment_method;TempSalesLine4.Description)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(shipment_service;TempSalesLine4."Description 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(shipment_fee_refund;TempSalesLine4."Unit Price")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
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
                    tableelement(tempitem;Item)
                    {
                        MinOccurs = Zero;
                        XmlName = 'comment_line';
                        UseTemporary = true;
                        fieldattribute(type;TempItem.Description)
                        {
                            Occurrence = Optional;
                        }
                        textelement(comment)
                        {

                            trigger OnBeforePassVariable()
                            var
                                InStream: InStream;
                                Line: Text;
                            begin
                                comment := '';
                                if TempItem."Magento Description".HasValue then begin
                                  TempItem.CalcFields("Magento Description");
                                  TempItem."Magento Description".CreateInStream(InStream);
                                  while not InStream.EOS  do begin
                                    InStream.ReadText(Line);
                                    comment += Line;
                                  end;
                                 end;
                            end;

                            trigger OnAfterAssignVariable()
                            var
                                OutStream: OutStream;
                            begin
                                Clear(TempItem."Magento Description");
                                TempItem."Magento Description".CreateOutStream(OutStream);
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
                textelement(sales_return_order_lines)
                {
                    MaxOccurs = Once;
                    tableelement(tempsalesline;"Sales Line")
                    {
                        AutoSave = true;
                        AutoUpdate = true;
                        MinOccurs = Once;
                        XmlName = 'sales_return_order_line';
                        UseTemporary = true;
                        textattribute(salesreturnorderlinetype)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                SalesReturnOrderLineType := LowerCase(TempSalesLine."Shortcut Dimension 2 Code");
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                TempSalesLine."Shortcut Dimension 2 Code" := SalesReturnOrderLineType;
                            end;
                        }
                        fieldattribute(external_no;TempSalesLine."Description 2")
                        {
                        }
                        fieldelement(description;TempSalesLine.Description)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(unit_price_incl_vat;TempSalesLine."Unit Price")
                        {
                        }
                        fieldelement(quantity;TempSalesLine.Quantity)
                        {
                        }
                        fieldelement(unit_of_measure;TempSalesLine."Unit of Measure")
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_pct;TempSalesLine."Line Discount %")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_amount;TempSalesLine."Line Discount Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vat_percent;TempSalesLine."VAT Base Amount")
                        {
                        }
                        fieldelement(line_amount_incl_vat;TempSalesLine."Line Amount")
                        {
                        }

                        trigger OnAfterInitRecord()
                        begin
                            LineNo += 1;
                            TempSalesLine."Line No." := LineNo;
                        end;
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        LineNo: Integer;

    procedure GetReturnOrderNo(): Text
    begin
        exit(return_order_no);
    end;

    procedure GetWebsiteCode(): Text
    begin
        exit(website_code);
    end;
}

