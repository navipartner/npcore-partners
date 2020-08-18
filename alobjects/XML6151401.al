xmlport 6151401 "Magento Sales Order Import"
{
    // MAG1.01/MHA /20150201  CASE 204133 Object created
    // MAG1.03/MHA /20150205  CASE 199932 Added element gift_vouchers
    // MAG1.04/TSA /20150212  CASE 201682 Change Shipment Node from Text to Table
    // MAG1.05/TS  /20150223  CASE 201682 Change Buffer Field for shipment_method
    // MAG1.14/MHA /20150423  CASE 211266 Added the following elements:
    //                                    sales_order/external_document_no
    //                                    sales_order/sell_to_customer/ean
    //                                    sales_order/shipment/shipment_service
    // MAG1.15/MHA /20150507  CASE 2013394 Changed buffer table for comments to BLOB in order to remove length restriction
    // MAG1.18/MHA /20150709  CASE 218282 Localization neutrality implemented
    // MAG1.20/TS  /20150810  CASE 218524 Added unit_code to sales_order_line
    // MAG1.22/TS  /20160105  CASE 230767 Added Currency_code
    // MAG1.22/MHA /20160115  CASE 232034 Updated Xml Port to Preserve Whitespaces
    // MAG1.22/TS  /20160203  CASE 233611 Reading Multiple comments
    // MAG1.22/MHA /20160209  CASE 233765 Corrected buffering of PaymentMethodType in connection to multiple payments
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.02/TS  /20170131  CASE 265017 Removed Table link on gift_voucher node and there were no precedent link
    // MAG2.04/TS  /20170421  CASE 269100 Added link Table and Link Fields to associate Gift Voucher to corresponding SalesLine.
    // MAG2.10/MHA /20171218  CASE 299976 Added <vat_registration_no> under <sales_order/sell_to_customer>
    // MAG2.11/MHA /20180319  CASE 308406 Specific value removed from XmlVersionNo in order to be V2 extension compliant
    // MAG2.11/TS  /20180323  CASE 288763 Changed transaction_id to text
    // MAG2.12/TS  /20180406  CASE 288763 Correct Variable Assignment
    // MAG2.17/TS  /20181025  CASE 324190 Added Description_2
    // MAG2.19/MMV /20190314  CASE 347687 Added handling of shopper reference
    // MAG2.20/MHA /20190411  CASE 349994 Added <use_customer_salesperson>
    // MAG2.20/MHA /20190417  CASE 352201 Added <store_code>
    // MAG2.22/BHR /20190604  CASE 350006 Added <requested_delivery_date>
    // MAG2.26/MHA /20200526  CASE 406591 Added <collect_in_store> under <shipment> and fixed min/max occurences on several elements
    // NPR5.55/MHA /20200730  CASE 412507 Added <prices_excluding_vat>, <unit_price_excl_vat>, <line_amount_excl_vat>

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
                    tableelement(temppaymentline;"Magento Payment Line")
                    {
                        MinOccurs = Zero;
                        XmlName = 'payment_method';
                        UseTemporary = true;
                        textattribute(paymentmethodtype)
                        {
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
                            MinOccurs = Zero;
                        }
                        fieldelement(payment_amount;TempPaymentLine.Amount)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Once;
                        }
                        fieldelement(payment_fee;TempPaymentLine."Last Amount")
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                        }
                        fieldelement(shopper_reference;TempPaymentLine."Payment Gateway Shopper Ref.")
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
                    XmlName = 'shipment';
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
                    fieldelement(shipment_fee;TempSalesLine4."Unit Price")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(shipment_date;TempSalesLine4."Posting Date")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(delivery_location;TempSalesLine4."Location Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    tableelement(tempnpcsdocument;"NpCs Document")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'collect_in_store';
                        UseTemporary = true;
                        fieldattribute(store_code;TempNpCsDocument."To Store Code")
                        {
                        }
                        fieldelement(allow_partial_delivery;TempNpCsDocument."Allow Partial Delivery")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(notify_customer_via_email;TempNpCsDocument."Notify Customer via E-mail")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(notify_customer_via_sms;TempNpCsDocument."Notify Customer via Sms")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(customer_email;TempNpCsDocument."Customer E-mail")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(customer_phone;TempNpCsDocument."Customer Phone No.")
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
                            MaxOccurs = Once;

                            trigger OnBeforePassVariable()
                            var
                                InStream: InStream;
                                Line: Text;
                            begin
                                comment := '';
                                //-MAG2.00
                                // IF TempItem."Webshop Description".HASVALUE THEN BEGIN
                                //  TempItem.CALCFIELDS("Webshop Description");
                                //  TempItem."Webshop Description".CREATEINSTREAM(InStream);
                                //  WHILE NOT InStream.EOS  DO BEGIN
                                //    InStream.READTEXT(Line);
                                //    comment += Line;
                                //  END;
                                // END;
                                if TempItem."Magento Description".HasValue then begin
                                  TempItem.CalcFields("Magento Description");
                                  TempItem."Magento Description".CreateInStream(InStream);
                                  while not InStream.EOS  do begin
                                    InStream.ReadText(Line);
                                    comment += Line;
                                  end;
                                 end;
                                //+MAG2.00
                            end;

                            trigger OnAfterAssignVariable()
                            var
                                OutStream: OutStream;
                            begin
                                //-MAG2.00
                                //CLEAR(TempItem."Webshop Description");
                                //TempItem."Webshop Description".CREATEOUTSTREAM(OutStream);
                                //OutStream.WRITETEXT(comment);
                                Clear(TempItem."Magento Description");
                                TempItem."Magento Description".CreateOutStream(OutStream);
                                OutStream.WriteText(comment);
                                //+MAG2.00
                            end;
                        }

                        trigger OnAfterInitRecord()
                        begin
                            //-MAG1.15
                            Clear(TempItem);
                            comment := '';
                            //+MAG1.15
                        end;

                        trigger OnBeforeInsertRecord()
                        begin
                            //-MAG1.15
                            LineNo += 1;
                            TempItem."No." := Format(10000000000.0 + LineNo);
                            //+MAG1.15
                        end;
                    }
                }
                textelement(sales_order_lines)
                {
                    MaxOccurs = Once;
                    tableelement(tempsalesline;"Sales Line")
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
                                //-MAG1.18
                                SalesOrderLineType := LowerCase(TempSalesLine."Shortcut Dimension 2 Code");
                                //+MAG1.18
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                //-MAG1.18
                                TempSalesLine."Shortcut Dimension 2 Code" := SalesOrderLineType;
                                //+MAG1.18
                            end;
                        }
                        fieldattribute(external_no;TempSalesLine."Description 2")
                        {
                        }
                        fieldelement(description;TempSalesLine.Description)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(description_2)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable()
                            begin
                                //-MAG2.17 [324190]
                                Clear(TempSalesLine9);
                                if TempSalesLine9.Get(TempSalesLine."Document Type",TempSalesLine."Document No.",TempSalesLine."Line No.") then;
                                description_2 := TempSalesLine9."Description 2";
                                //+MAG2.17 [324190]
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                //-MAG2.17 [324190]
                                if TempSalesLine9.Get(TempSalesLine."Document Type",TempSalesLine."Document No.",TempSalesLine."Line No.") then begin
                                  TempSalesLine9."Description 2" := description_2;
                                  TempSalesLine9.Modify;
                                end else begin
                                  TempSalesLine9.Init;
                                  TempSalesLine9 := TempSalesLine;
                                  TempSalesLine9."Description 2" := description_2;
                                  TempSalesLine9.Insert;
                                end;
                                //+MAG2.17 [324190]
                            end;
                        }
                        fieldelement(unit_price_incl_vat;TempSalesLine."Unit Price")
                        {
                        }
                        fieldelement(unit_price_excl_vat;TempSalesLine."Unit Cost (LCY)")
                        {
                            MinOccurs = Zero;
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
                        fieldelement(line_amount_excl_vat;TempSalesLine.Amount)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(gift_vouchers)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            tableelement(tempgiftvoucher;"Gift Voucher")
                            {
                                AutoUpdate = true;
                                MinOccurs = Zero;
                                XmlName = 'gift_voucher';
                                UseTemporary = true;
                                fieldattribute(external_no;TempGiftVoucher."No.")
                                {
                                }
                                fieldattribute(certificate_number;TempGiftVoucher."External Reference No.")
                                {
                                }
                                fieldelement(amount;TempGiftVoucher.Amount)
                                {
                                }
                                fieldelement(name;TempGiftVoucher.Name)
                                {
                                }
                                textelement(giftvouchermessage)
                                {
                                    XmlName = 'message';

                                    trigger OnBeforePassVariable()
                                    var
                                        InStr: InStream;
                                        Line: Text;
                                    begin
                                        TempGiftVoucher.CalcFields("Gift Voucher Message");
                                        TempGiftVoucher."Gift Voucher Message".CreateInStream(InStr);
                                        GiftVoucherMessage := '';
                                        while not InStr.EOS do begin
                                          InStr.ReadText(Line);
                                          GiftVoucherMessage += Line;
                                        end;
                                    end;
                                }

                                trigger OnPreXmlItem()
                                begin
                                    //-MAG2.04
                                    TempGiftVoucher.SetRange("Primary Key Length" ,TempSalesLine."Line No." );
                                    //+MAG2.04
                                end;

                                trigger OnBeforeInsertRecord()
                                var
                                    OutStr: OutStream;
                                begin
                                    TempGiftVoucher."Primary Key Length" := TempSalesLine."Line No.";
                                    TempGiftVoucher."Gift Voucher Message".CreateOutStream(OutStr);
                                    OutStr.WriteText(GiftVoucherMessage);
                                end;
                            }
                        }
                        fieldelement(requested_delivery_date;TempSalesLine."Requested Delivery Date")
                        {
                            MinOccurs = Zero;
                        }

                        trigger OnAfterInitRecord()
                        begin
                            //-MAG2.04
                            LineNo += 1;
                            TempSalesLine."Line No." := LineNo;
                            //+MAG2.04
                        end;

                        trigger OnBeforeInsertRecord()
                        begin
                            //-MAG2.04
                            //LineNo += 1;
                            //TempSalesLine."Line No." := LineNo;
                            //+MAG2.04
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
        TempSalesLine8: Record "Sales Line" temporary;
        TempSalesLine9: Record "Sales Line" temporary;

    procedure GetOrderNo(): Text
    begin
        exit(order_no);
    end;

    procedure GetWebsiteCode(): Text
    begin
        exit(website_code);
    end;
}

