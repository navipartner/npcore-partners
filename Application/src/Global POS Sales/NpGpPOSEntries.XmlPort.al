xmlport 6151167 "NPR NpGp POS Entries"
{
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
            tableelement(tempnpgppossalesentry; "NPR NpGp POS Sales Entry")
            {
                MinOccurs = Zero;
                XmlName = 'sales_entry';
                UseTemporary = true;
                fieldattribute(pos_store_code; TempNpGpPOSSalesEntry."POS Store Code")
                {
                }
                fieldattribute(pos_unit_no; TempNpGpPOSSalesEntry."POS Unit No.")
                {
                }
                fieldattribute(document_no; TempNpGpPOSSalesEntry."Document No.")
                {
                }
                fieldattribute(company; TempNpGpPOSSalesEntry."Original Company")
                {
                }
                fieldelement(entry_time; TempNpGpPOSSalesEntry."Entry Time")
                {
                }
                fieldelement(entry_type; TempNpGpPOSSalesEntry."Entry Type")
                {
                }
                fieldelement(customer_no; TempNpGpPOSSalesEntry."Customer No.")
                {

                }
                fieldelement(retail_id; TempNpGpPOSSalesEntry.SystemId)
                {
                }
                fieldelement(posting_date; TempNpGpPOSSalesEntry."Posting Date")
                {
                }
                fieldelement(fiscal_no; TempNpGpPOSSalesEntry."Fiscal No.")
                {
                }
                fieldelement(salesperson_code; TempNpGpPOSSalesEntry."Salesperson Code")
                {
                }
                fieldelement(currency_code; TempNpGpPOSSalesEntry."Currency Code")
                {
                }
                fieldelement(currency_factor; TempNpGpPOSSalesEntry."Currency Factor")
                {
                }
                fieldelement(sales_amount; TempNpGpPOSSalesEntry."Sales Amount")
                {
                }
                fieldelement(discount_amount; TempNpGpPOSSalesEntry."Discount Amount")
                {
                }
                fieldelement(total_amount; TempNpGpPOSSalesEntry."Total Amount")
                {
                }
                fieldelement(total_tax_amount; TempNpGpPOSSalesEntry."Total Tax Amount")
                {
                }
                fieldelement(total_amount_incl_tax; TempNpGpPOSSalesEntry."Total Amount Incl. Tax")
                {
                }
                textelement(sales_lines)
                {
                    tableelement(tempnpgppossalesline; "NPR NpGp POS Sales Line")
                    {
                        LinkFields = "POS Entry No." = FIELD("Entry No.");
                        LinkTable = TempNpGpPOSSalesEntry;
                        MinOccurs = Zero;
                        XmlName = 'sales_line';
                        UseTemporary = true;
                        fieldattribute(line_no; TempNpGpPOSSalesLine."Line No.")
                        {
                        }
                        fieldelement(retail_id; TempNpGpPOSSalesLine.SystemId)
                        {
                        }
                        fieldelement(type; TempNpGpPOSSalesLine.Type)
                        {
                        }
                        fieldelement(no; TempNpGpPOSSalesLine."No.")
                        {
                        }
                        fieldelement(variant_code; TempNpGpPOSSalesLine."Variant Code")
                        {
                        }
                        fieldelement(cross_reference_no; TempNpGpPOSSalesLine."Cross-Reference No.")
                        {
                        }
                        fieldelement(bom_item_no; TempNpGpPOSSalesLine."BOM Item No.")
                        {
                        }
                        fieldelement(location_code; TempNpGpPOSSalesLine."Location Code")
                        {
                        }
                        fieldelement(description; TempNpGpPOSSalesLine.Description)
                        {
                        }
                        fieldelement(description_2; TempNpGpPOSSalesLine."Description 2")
                        {
                        }
                        fieldelement(quantity; TempNpGpPOSSalesLine.Quantity)
                        {
                        }
                        fieldelement(unit_of_measure_code; TempNpGpPOSSalesLine."Unit of Measure Code")
                        {
                        }
                        fieldelement(qty_per_unit_of_measure; TempNpGpPOSSalesLine."Qty. per Unit of Measure")
                        {
                        }
                        fieldelement(quantity_base; TempNpGpPOSSalesLine."Quantity (Base)")
                        {
                        }
                        fieldelement(unit_price; TempNpGpPOSSalesLine."Unit Price")
                        {
                        }
                        fieldelement(currency_code; TempNpGpPOSSalesLine."Currency Code")
                        {
                        }
                        fieldelement(vat_pct; TempNpGpPOSSalesLine."VAT %")
                        {
                        }
                        fieldelement(line_discount_pct; TempNpGpPOSSalesLine."Line Discount %")
                        {
                        }
                        fieldelement(line_discount_amount_excl_vat; TempNpGpPOSSalesLine."Line Discount Amount Excl. VAT")
                        {
                        }
                        fieldelement(line_discount_amount_incl_vat; TempNpGpPOSSalesLine."Line Discount Amount Incl. VAT")
                        {
                        }
                        fieldelement(line_amount; TempNpGpPOSSalesLine."Line Amount")
                        {
                        }
                        fieldelement(amount_excl_vat; TempNpGpPOSSalesLine."Amount Excl. VAT")
                        {
                        }
                        fieldelement(amount_incl_vat; TempNpGpPOSSalesLine."Amount Incl. VAT")
                        {
                        }
                        fieldelement(line_discount_amount_excl_vat_lcy; TempNpGpPOSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)")
                        {
                        }
                        fieldelement(line_discount_amount_incl_vat_lcy; TempNpGpPOSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)")
                        {
                        }
                        fieldelement(amount_excl_vat_lcy; TempNpGpPOSSalesLine."Amount Excl. VAT (LCY)")
                        {
                        }
                        fieldelement(amount_incl_vat_lcy; TempNpGpPOSSalesLine."Amount Incl. VAT (LCY)")
                        {
                        }
                        fieldelement(global_reference; TempNpGpPOSSalesLine."Global Reference")
                        {
                        }
                        textelement(extension_fields)
                        {
                            MinOccurs = Zero;
                            textelement(extension_field)
                            {
                                MinOccurs = Zero;
                                textelement(field_no)
                                {
                                }
                                textelement(field_value)
                                {

                                    trigger OnAfterAssignVariable()
                                    var
                                        RecRef: RecordRef;
                                        FldRef: FieldRef;
                                        FieldNo: Integer;
                                    begin
                                        if Evaluate(FieldNo, field_no) then begin
                                            RecRef.GetTable(TempNpGpPOSSalesLine);
                                            FldRef := RecRef.Field(FieldNo);
                                            if Evaluate(FldRef, field_value, 9) then
                                                RecRef.SetTable(TempNpGpPOSSalesLine);
                                        end;
                                    end;
                                }
                            }
                        }

                        trigger OnBeforeInsertRecord()
                        begin
                            TempNpGpPOSSalesLine."POS Entry No." := TempNpGpPOSSalesEntry."Entry No.";
                            TempNpGpPOSSalesLine.Return := TempNpGpPOSSalesLine.Quantity < 0;
                        end;
                    }
                }
                textelement(pos_info_entries)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tempnpgpposinfoposentry; "NPR NpGp POS Info POS Entry")
                    {
                        MinOccurs = Zero;
                        XmlName = 'pos_info_entry';
                        UseTemporary = true;
                        fieldattribute(pos_info_code; TempNpGpPOSInfoPOSEntry."POS Info Code")
                        {
                        }
                        fieldattribute(entry_no; TempNpGpPOSInfoPOSEntry."Entry No.")
                        {
                        }
                        fieldelement(sales_line_no; TempNpGpPOSInfoPOSEntry."Sales Line No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(pos_info; TempNpGpPOSInfoPOSEntry."POS Info")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(no; TempNpGpPOSInfoPOSEntry."No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(quantity; TempNpGpPOSInfoPOSEntry.Quantity)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(price; TempNpGpPOSInfoPOSEntry.Price)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(net_amount; TempNpGpPOSInfoPOSEntry."Net Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(gross_amount; TempNpGpPOSInfoPOSEntry."Gross Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_amount; TempNpGpPOSInfoPOSEntry."Discount Amount")
                        {
                            MinOccurs = Zero;
                        }

                        trigger OnBeforeInsertRecord()
                        begin
                            TempNpGpPOSInfoPOSEntry."POS Entry No." := TempNpGpPOSSalesEntry."Entry No.";
                        end;
                    }
                }
                textelement(pos_payment_lines)
                {
                    tableelement(tempnpgppospaymentlines; "NPR NpGp POS Payment Line")
                    {
                        LinkFields = "POS Entry No." = FIELD("Entry No.");
                        LinkTable = TempNpGpPOSSalesEntry;
                        MinOccurs = Zero;
                        XmlName = 'payment_line';
                        UseTemporary = true;
                        fieldattribute(payline_no; TempNpGpPOSPaymentLines."Line No.")
                        {
                        }
                        fieldelement(paydoc_no; TempNpGpPOSPaymentLines."Document No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(payMethod; TempNpGpPOSPaymentLines."POS Payment Method Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(payDesc; TempNpGpPOSPaymentLines.Description)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(payAmount; TempNpGpPOSPaymentLines."Payment Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(currencyCode; TempNpGpPOSPaymentLines."Currency Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(amountLCY; TempNpGpPOSPaymentLines."Amount (LCY)")
                        {
                            MinOccurs = Zero;
                        }
                        trigger OnBeforeInsertRecord()
                        begin
                            TempNpGpPOSPaymentLines."POS Entry No." := TempNpGpPOSSalesEntry."Entry No.";
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

    internal procedure GetSourceTables(var TempNpGpPOSSalesEntryTo: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSSalesLineTo: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSInfoPOSEntryTo: Record "NPR NpGp POS Info POS Entry" temporary; var TempNpGpPOSPaymentLinesTo: Record "NPR NpGp POS Payment Line" temporary)
    begin
        TempNpGpPOSSalesEntryTo.Copy(TempNpGpPOSSalesEntry, true);
        TempNpGpPOSSalesLineTo.Copy(TempNpGpPOSSalesLine, true);
        TempNpGpPOSInfoPOSEntryTo.Copy(TempNpGpPOSInfoPOSEntry, true);
        TempNpGpPOSPaymentLinesTo.Copy(TempNpGpPOSPaymentLines, true);
    end;

    internal procedure SetSourceTables(var TempNpGpPOSSalesEntryFrom: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSSalesLineFrom: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSInfoPOSEntryFrom: Record "NPR NpGp POS Info POS Entry" temporary; var TempNpGpPOSPaymentLinesFrom: Record "NPR NpGp POS Payment Line" temporary)
    begin
        TempNpGpPOSSalesEntry.Copy(TempNpGpPOSSalesEntryFrom, true);
        TempNpGpPOSSalesLine.Copy(TempNpGpPOSSalesLineFrom, true);
        TempNpGpPOSInfoPOSEntry.Copy(TempNpGpPOSInfoPOSEntryFrom, true);
        TempNpGpPOSPaymentLines.Copy(TempNpGpPOSPaymentLinesFrom, true);
    end;
}

