xmlport 6151300 "NpEc Sales Order Import"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce

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
                textattribute(store_code)
                {
                }
                textattribute(order_no)
                {
                }
                textelement(order_date)
                {
                    MaxOccurs = Once;
                }
                textelement(posting_date)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(prices_incl_vat)
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
                tableelement(tempcustomer;Customer)
                {
                    MaxOccurs = Once;
                    XmlName = 'sell_to_customer';
                    UseTemporary = true;
                    fieldattribute(customer_no;TempCustomer."Telex No.")
                    {
                        Width = 100;
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
                textelement(payments)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(temppaymentline;"Magento Payment Line")
                    {
                        MinOccurs = Zero;
                        XmlName = 'payment';
                        UseTemporary = true;
                        fieldattribute(code;TempPaymentLine.Description)
                        {
                        }
                        textelement(payment_type)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            XmlName = 'card_type';

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
                    XmlName = 'shipment_method';
                    UseTemporary = true;
                    fieldattribute(code;TempSalesLine4.Description)
                    {
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

                    trigger OnBeforeInsertRecord()
                    begin
                        LineNo += 1;
                        TempSalesLine4."Line No." := LineNo;
                    end;
                }
                textelement(note)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(sales_order_lines)
                {
                    MaxOccurs = Once;
                    tableelement(tempsalesline;"Sales Line")
                    {
                        AutoSave = true;
                        AutoUpdate = true;
                        MinOccurs = Zero;
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
                        fieldattribute(reference_no;TempSalesLine."Description 2")
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
                                Clear(TempSalesLine9);
                                if TempSalesLine9.Get(TempSalesLine."Document Type",TempSalesLine."Document No.",TempSalesLine."Line No.") then;
                                description_2 := TempSalesLine9."Description 2";
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                if TempSalesLine9.Get(TempSalesLine."Document Type",TempSalesLine."Document No.",TempSalesLine."Line No.") then begin
                                  TempSalesLine9."Description 2" := description_2;
                                  TempSalesLine9.Modify;
                                end else begin
                                  TempSalesLine9.Init;
                                  TempSalesLine9 := TempSalesLine;
                                  TempSalesLine9."Description 2" := description_2;
                                  TempSalesLine9.Insert;
                                end;
                            end;
                        }
                        fieldelement(unit_price;TempSalesLine."Unit Price")
                        {
                        }
                        fieldelement(quantity;TempSalesLine.Quantity)
                        {
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
                        fieldelement(line_amount;TempSalesLine."Line Amount")
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
        TempSalesLine8: Record "Sales Line" temporary;
        TempSalesLine9: Record "Sales Line" temporary;

    procedure GetOrderNo(): Text
    begin
        exit(order_no);
    end;
}

