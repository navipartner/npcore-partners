xmlport 6151195 "NpCs Sales Document"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // #344264/MHA /20190717  CASE 344264 Added <config_template> under <sell_to_customer> and changed <delivery_only> to <from_store_stock>

    Caption = 'Collect Sales Document';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/collect_in_store_sales_document';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(sales_documents)
        {
            MaxOccurs = Once;
            tableelement(tempsalesheader;"Sales Header")
            {
                MaxOccurs = Once;
                XmlName = 'sales_document';
                UseTemporary = true;
                fieldattribute(document_type;TempSalesHeader."Document Type")
                {
                }
                fieldattribute(document_no;TempSalesHeader."No.")
                {
                }
                textelement(reference_no)
                {
                    MaxOccurs = Once;
                }
                textelement(to_document_type)
                {
                    MaxOccurs = Once;
                }
                textelement(from_store)
                {
                    MaxOccurs = Once;
                    textattribute(store_code)
                    {
                    }
                    textelement(company_name)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(name)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(service_url)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(service_username)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(service_password)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(email)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(mobile_phone_no)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(callback)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        textattribute(encoding)
                        {
                            Occurrence = Optional;
                        }
                    }
                }
                fieldelement(order_date;TempSalesHeader."Order Date")
                {
                }
                fieldelement(posting_date;TempSalesHeader."Posting Date")
                {
                }
                fieldelement(due_date;TempSalesHeader."Due Date")
                {
                }
                textelement(sell_to_customer)
                {
                    MaxOccurs = Once;
                    fieldattribute(customer_no;TempSalesHeader."Sell-to Customer No.")
                    {
                    }
                    fieldattribute(customer_mapping;TempSalesHeader."No. Printed")
                    {
                        Occurrence = Optional;
                    }
                    fieldelement(name;TempSalesHeader."Sell-to Customer Name")
                    {
                    }
                    fieldelement(name_2;TempSalesHeader."Sell-to Customer Name 2")
                    {
                    }
                    fieldelement(address;TempSalesHeader."Sell-to Address")
                    {
                    }
                    fieldelement(address_2;TempSalesHeader."Sell-to Address 2")
                    {
                    }
                    fieldelement(post_code;TempSalesHeader."Sell-to Post Code")
                    {
                    }
                    fieldelement(city;TempSalesHeader."Sell-to City")
                    {
                    }
                    fieldelement(country_code;TempSalesHeader."Sell-to Country/Region Code")
                    {
                    }
                    fieldelement(contact;TempSalesHeader."Sell-to Contact")
                    {
                    }
                    fieldelement(phone_no;TempSalesHeader."Bill-to Company")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(email;TempSalesHeader."Bill-to E-mail")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(config_template;TempSalesHeader."Customer Posting Group")
                    {
                        MinOccurs = Zero;
                    }
                }
                textelement(customernotification)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'notification';
                    textelement(send_notification_from_store)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(notify_customer_via_email)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(email_template_pending)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(email_template_confirmed)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(email_template_rejected)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(email_template_expired)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(notify_customer_via_sms)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(sms_template_pending)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(sms_template_confirmed)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(sms_template_rejected)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(sms_template_expired)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(processing_expiry_duration)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(delivery_expiry_days_qty)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                }
                fieldelement(bill_to_customer_no;TempSalesHeader."Bill-to Customer No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(archive_on_delivery)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(store_stock)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                textelement(bill_via)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(delivery_print_template_pos)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(delivery_print_template_sales_doc)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(prepaid_amount)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(prepayment_account_no)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                fieldelement(location_code;TempSalesHeader."Location Code")
                {
                }
                fieldelement(salesperson_code;TempSalesHeader."Salesperson Code")
                {
                }
                fieldelement(payment_method_code;TempSalesHeader."Payment Method Code")
                {
                }
                fieldelement(shipment_method_code;TempSalesHeader."Shipment Method Code")
                {
                }
                fieldelement(prices_including_vat;TempSalesHeader."Prices Including VAT")
                {
                }
                textelement(sales_lines)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tempsalesline;"Sales Line")
                    {
                        LinkFields = "Document Type"=FIELD("Document Type"),"Document No."=FIELD("No.");
                        LinkTable = TempSalesHeader;
                        MinOccurs = Zero;
                        XmlName = 'sales_line';
                        UseTemporary = true;
                        fieldattribute(line_no;TempSalesLine."Line No.")
                        {
                        }
                        fieldelement(type;TempSalesLine.Type)
                        {
                        }
                        fieldelement(no;TempSalesLine."No.")
                        {
                        }
                        fieldelement(variant_code;TempSalesLine."Variant Code")
                        {
                        }
                        fieldelement(cross_reference_no;TempSalesLine."Cross-Reference No.")
                        {
                        }
                        fieldelement(unit_of_measure_code;TempSalesLine."Unit of Measure Code")
                        {
                        }
                        fieldelement(description;TempSalesLine.Description)
                        {
                        }
                        fieldelement(description_2;TempSalesLine."Description 2")
                        {
                        }
                        fieldelement(unit_price;TempSalesLine."Unit Price")
                        {
                        }
                        fieldelement(quantity;TempSalesLine.Quantity)
                        {
                        }
                        fieldelement(line_discount_pct;TempSalesLine."Line Discount %")
                        {
                        }
                        fieldelement(line_discount_amount;TempSalesLine."Line Discount Amount")
                        {
                        }
                        fieldelement(vat_pct;TempSalesLine."VAT %")
                        {
                        }
                        fieldelement(line_amount;TempSalesLine."Line Amount")
                        {
                        }

                        trigger OnAfterInitRecord()
                        begin
                            TempSalesLine."Document Type" := TempSalesHeader."Document Type";
                            TempSalesLine."Document No." := TempSalesHeader."No.";
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

    procedure CopySourceTable(var TempSalesHeader2: Record "Sales Header" temporary)
    begin
        TempSalesHeader2.Copy(TempSalesHeader,true);
    end;
}

