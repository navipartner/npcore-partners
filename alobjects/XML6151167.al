xmlport 6151167 "NpGp POS Entries"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Global POS Sales Entries';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/global_pos_sales';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(sales_entries)
        {
            MaxOccurs = Once;
            tableelement(tempnpgppossalesentry;"NpGp POS Sales Entry")
            {
                MinOccurs = Zero;
                XmlName = 'sales_entry';
                UseTemporary = true;
                fieldattribute(pos_store_code;TempNpGpPOSSalesEntry."POS Store Code")
                {
                }
                fieldattribute(pos_unit_no;TempNpGpPOSSalesEntry."POS Unit No.")
                {
                }
                fieldattribute(document_no;TempNpGpPOSSalesEntry."Document No.")
                {
                }
                fieldelement(entry_time;TempNpGpPOSSalesEntry."Entry Time")
                {
                }
                fieldelement(entry_type;TempNpGpPOSSalesEntry."Entry Type")
                {
                }
                fieldelement(retail_id;TempNpGpPOSSalesEntry."Retail ID")
                {
                }
                fieldelement(posting_date;TempNpGpPOSSalesEntry."Posting Date")
                {
                }
                fieldelement(fiscal_no;TempNpGpPOSSalesEntry."Fiscal No.")
                {
                }
                fieldelement(salesperson_code;TempNpGpPOSSalesEntry."Salesperson Code")
                {
                }
                fieldelement(currency_code;TempNpGpPOSSalesEntry."Currency Code")
                {
                }
                fieldelement(currency_factor;TempNpGpPOSSalesEntry."Currency Factor")
                {
                }
                fieldelement(sales_amount;TempNpGpPOSSalesEntry."Sales Amount")
                {
                }
                fieldelement(discount_amount;TempNpGpPOSSalesEntry."Discount Amount")
                {
                }
                fieldelement(total_amount;TempNpGpPOSSalesEntry."Total Amount")
                {
                }
                fieldelement(total_tax_amount;TempNpGpPOSSalesEntry."Total Tax Amount")
                {
                }
                fieldelement(total_amount_incl_tax;TempNpGpPOSSalesEntry."Total Amount Incl. Tax")
                {
                }
                textelement(sales_lines)
                {
                    tableelement(tempnpgppossalesline;"NpGp POS Sales Line")
                    {
                        LinkFields = "POS Entry No."=FIELD("Entry No.");
                        LinkTable = TempNpGpPOSSalesEntry;
                        MinOccurs = Zero;
                        XmlName = 'sales_line';
                        UseTemporary = true;
                        fieldattribute(line_no;TempNpGpPOSSalesLine."Line No.")
                        {
                        }
                        fieldelement(retail_id;TempNpGpPOSSalesLine."Retail ID")
                        {
                        }
                        fieldelement(type;TempNpGpPOSSalesLine.Type)
                        {
                        }
                        fieldelement(no;TempNpGpPOSSalesLine."No.")
                        {
                        }
                        fieldelement(variant_code;TempNpGpPOSSalesLine."Variant Code")
                        {
                        }
                        fieldelement(cross_reference_no;TempNpGpPOSSalesLine."Cross-Reference No.")
                        {
                        }
                        fieldelement(bom_item_no;TempNpGpPOSSalesLine."BOM Item No.")
                        {
                        }
                        fieldelement(location_code;TempNpGpPOSSalesLine."Location Code")
                        {
                        }
                        fieldelement(description;TempNpGpPOSSalesLine.Description)
                        {
                        }
                        fieldelement(description_2;TempNpGpPOSSalesLine."Description 2")
                        {
                        }
                        fieldelement(quantity;TempNpGpPOSSalesLine.Quantity)
                        {
                        }
                        fieldelement(unit_of_measure_code;TempNpGpPOSSalesLine."Unit of Measure Code")
                        {
                        }
                        fieldelement(qty_per_unit_of_measure;TempNpGpPOSSalesLine."Qty. per Unit of Measure")
                        {
                        }
                        fieldelement(quantity_base;TempNpGpPOSSalesLine."Quantity (Base)")
                        {
                        }
                        fieldelement(unit_price;TempNpGpPOSSalesLine."Unit Price")
                        {
                        }
                        fieldelement(currency_code;TempNpGpPOSSalesLine."Currency Code")
                        {
                        }
                        fieldelement(vat_pct;TempNpGpPOSSalesLine."VAT %")
                        {
                        }
                        fieldelement(line_discount_pct;TempNpGpPOSSalesLine."Line Discount %")
                        {
                        }
                        fieldelement(line_discount_amount_excl_vat;TempNpGpPOSSalesLine."Line Discount Amount Excl. VAT")
                        {
                        }
                        fieldelement(line_discount_amount_incl_vat;TempNpGpPOSSalesLine."Line Discount Amount Incl. VAT")
                        {
                        }
                        fieldelement(line_amount;TempNpGpPOSSalesLine."Line Amount")
                        {
                        }
                        fieldelement(amount_excl_vat;TempNpGpPOSSalesLine."Amount Excl. VAT")
                        {
                        }
                        fieldelement(amount_incl_vat;TempNpGpPOSSalesLine."Amount Incl. VAT")
                        {
                        }
                        fieldelement(line_discount_amount_excl_vat_lcy;TempNpGpPOSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)")
                        {
                        }
                        fieldelement(line_discount_amount_incl_vat_lcy;TempNpGpPOSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)")
                        {
                        }
                        fieldelement(amount_excl_vat_lcy;TempNpGpPOSSalesLine."Amount Excl. VAT (LCY)")
                        {
                        }
                        fieldelement(amount_incl_vat_lcy;TempNpGpPOSSalesLine."Amount Incl. VAT (LCY)")
                        {
                        }

                        trigger OnBeforeInsertRecord()
                        begin
                            TempNpGpPOSSalesLine."POS Entry No." := TempNpGpPOSSalesEntry."Entry No.";
                        end;
                    }
                }
                textelement(pos_info_entries)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tempnpgpposinfoposentry;"NpGp POS Info POS Entry")
                    {
                        MinOccurs = Zero;
                        XmlName = 'pos_info_entry';
                        UseTemporary = true;
                        fieldattribute(pos_info_code;TempNpGpPOSInfoPOSEntry."POS Info Code")
                        {
                        }
                        fieldattribute(entry_no;TempNpGpPOSInfoPOSEntry."Entry No.")
                        {
                        }
                        fieldelement(sales_line_no;TempNpGpPOSInfoPOSEntry."Sales Line No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(pos_info;TempNpGpPOSInfoPOSEntry."POS Info")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(no;TempNpGpPOSInfoPOSEntry."No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(quantity;TempNpGpPOSInfoPOSEntry.Quantity)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(price;TempNpGpPOSInfoPOSEntry.Price)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(net_amount;TempNpGpPOSInfoPOSEntry."Net Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(gross_amount;TempNpGpPOSInfoPOSEntry."Gross Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_amount;TempNpGpPOSInfoPOSEntry."Discount Amount")
                        {
                            MinOccurs = Zero;
                        }

                        trigger OnBeforeInsertRecord()
                        begin
                            TempNpGpPOSInfoPOSEntry."POS Entry No." := TempNpGpPOSSalesEntry."Entry No.";
                        end;
                    }
                }

                trigger OnBeforeInsertRecord()
                begin
                    EntryNo += 1;
                    TempNpGpPOSSalesEntry."Entry No." := EntryNo;
                end;
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
        EntryNo: BigInteger;

    procedure GetSourceTables(var TempNpGpPOSSalesEntryTo: Record "NpGp POS Sales Entry" temporary;var TempNpGpPOSSalesLineTo: Record "NpGp POS Sales Line" temporary;var TempNpGpPOSInfoPOSEntryTo: Record "NpGp POS Info POS Entry" temporary)
    begin
        TempNpGpPOSSalesEntryTo.Copy(TempNpGpPOSSalesEntry,true);
        TempNpGpPOSSalesLineTo.Copy(TempNpGpPOSSalesLine,true);
        TempNpGpPOSInfoPOSEntryTo.Copy(TempNpGpPOSInfoPOSEntryTo,true);
    end;

    procedure SetSourceTables(var TempNpGpPOSSalesEntryFrom: Record "NpGp POS Sales Entry" temporary;var TempNpGpPOSSalesLineFrom: Record "NpGp POS Sales Line" temporary;var TempNpGpPOSInfoPOSEntryFrom: Record "NpGp POS Info POS Entry" temporary)
    begin
        TempNpGpPOSSalesEntry.Copy(TempNpGpPOSSalesEntryFrom,true);
        TempNpGpPOSSalesLine.Copy(TempNpGpPOSSalesLineFrom,true);
        TempNpGpPOSInfoPOSEntryFrom.Copy(TempNpGpPOSInfoPOSEntry,true);
    end;
}

