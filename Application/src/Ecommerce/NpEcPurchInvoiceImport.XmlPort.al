xmlport 6151306 "NPR NpEc Purch. Invoice Import"
{
    Caption = 'Magento Purchase Invoice Import';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/purchase_invoice';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(purchase_invoices)
        {
            textelement(purchase_invoice)
            {
                MaxOccurs = Once;
                MinOccurs = Once;
                textattribute(store_code)
                {
                }
                textattribute(invoice_no)
                {
                }
                textelement(posting_date)
                {
                    MaxOccurs = Once;
                }
                textelement(document_date)
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
                textelement(vendor_invoice_no)
                {
                    MaxOccurs = Once;
                }
                tableelement(tempvendor; Vendor)
                {
                    MaxOccurs = Once;
                    XmlName = 'buy_from_vendor';
                    UseTemporary = true;
                    fieldattribute(vendor_no; TempVendor."No.")
                    {
                        Width = 100;
                    }
                    fieldelement(name; TempVendor.Name)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(name_2; TempVendor."Name 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(address; TempVendor.Address)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(address_2; TempVendor."Address 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(post_code; TempVendor."Post Code")
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(city; TempVendor.City)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(country_code; TempVendor."Country/Region Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(contact; TempVendor.Contact)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(email; TempVendor."E-Mail")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(phone; TempVendor."Phone No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                }
                textelement(note)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(purchase_invoice_lines)
                {
                    MaxOccurs = Once;
                    tableelement(temppurchline; "Purchase Line")
                    {
                        AutoSave = true;
                        AutoUpdate = true;
                        MinOccurs = Zero;
                        XmlName = 'purchase_invoice_line';
                        UseTemporary = true;
                        textattribute(purchlinetype)
                        {
                            XmlName = 'type';

                            trigger OnBeforePassVariable()
                            begin
                                PurchLineType := LowerCase(TempPurchLine."Shortcut Dimension 2 Code");
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                TempPurchLine."Shortcut Dimension 2 Code" := PurchLineType;
                            end;
                        }
                        fieldattribute(reference_no; TempPurchLine."Description 2")
                        {
                        }
                        fieldelement(description; TempPurchLine.Description)
                        {
                            MinOccurs = Zero;
                        }
                        textelement(description_2)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable()
                            begin
                                Clear(TempPurchLine9);
                                if TempPurchLine9.Get(TempPurchLine."Document Type", TempPurchLine."Document No.", TempPurchLine."Line No.") then;
                                description_2 := TempPurchLine9."Description 2";
                            end;

                            trigger OnAfterAssignVariable()
                            begin
                                if TempPurchLine9.Get(TempPurchLine."Document Type", TempPurchLine."Document No.", TempPurchLine."Line No.") then begin
                                    TempPurchLine9."Description 2" := description_2;
                                    TempPurchLine9.Modify;
                                end else begin
                                    TempPurchLine9.Init;
                                    TempPurchLine9 := TempPurchLine;
                                    TempPurchLine9."Description 2" := description_2;
                                    TempPurchLine9.Insert;
                                end;
                            end;
                        }
                        fieldelement(direct_unit_cost; TempPurchLine."Direct Unit Cost")
                        {
                        }
                        fieldelement(quantity; TempPurchLine.Quantity)
                        {
                        }
                        fieldelement(discount_pct; TempPurchLine."Line Discount %")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_amount; TempPurchLine."Line Discount Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vat_percent; TempPurchLine."VAT Base Amount")
                        {
                        }
                        fieldelement(line_amount; TempPurchLine."Line Amount")
                        {
                        }

                        trigger OnAfterInitRecord()
                        begin
                            LineNo += 1;
                            TempPurchLine."Line No." := LineNo;
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
        TempPurchLine8: Record "Purchase Line" temporary;
        TempPurchLine9: Record "Purchase Line" temporary;

    procedure GetInvoiceNo(): Text
    begin
        exit(invoice_no);
    end;
}

