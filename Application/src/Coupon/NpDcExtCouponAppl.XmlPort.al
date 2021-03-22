xmlport 6151590 "NPR NpDc Ext. Coupon Appl."
{
    Caption = 'NpDc Coupon Application';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/discount_coupon';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(coupon_application)
        {
            tableelement(tempsaleposreq; "NPR Sale POS")
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                XmlName = 'request';
                UseTemporary = true;
                textelement(documentnoreq)
                {
                    XmlName = 'document_no';
                }
                textelement(possaleslinesreq)
                {
                    MaxOccurs = Once;
                    XmlName = 'pos_sales_lines';
                    tableelement(tempsalelineposreq; "NPR Sale Line POS")
                    {
                        XmlName = 'pos_sales_line';
                        UseTemporary = true;
                        fieldattribute(line_no; TempSaleLinePOSReq."Line No.")
                        {
                        }
                        fieldelement(item_no; TempSaleLinePOSReq."No.")
                        {
                        }
                        fieldelement(variant_code; TempSaleLinePOSReq."Variant Code")
                        {
                        }
                        fieldelement(description; TempSaleLinePOSReq.Description)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(description_2; TempSaleLinePOSReq."Description 2")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(unit_price_incl_vat; TempSaleLinePOSReq."Unit Price")
                        {
                        }
                        fieldelement(quantity; TempSaleLinePOSReq.Quantity)
                        {
                        }
                        fieldelement(unit_of_measure; TempSaleLinePOSReq."Unit of Measure Code")
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_pct; TempSaleLinePOSReq."Discount %")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_amount; TempSaleLinePOSReq."Discount Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vat_percent; TempSaleLinePOSReq."VAT %")
                        {
                        }
                        fieldelement(line_amount_incl_vat; TempSaleLinePOSReq."Amount Including VAT")
                        {
                        }
                        fieldelement(magento_brand; TempSaleLinePOSReq."Magento Brand")
                        {
                            MinOccurs = Zero;
                        }

                        trigger OnAfterInitRecord()
                        begin
                            TempSaleLinePOSReq.Type := TempSaleLinePOSReq.Type::Item;
                        end;

                        trigger OnBeforeInsertRecord()
                        var
                            Item: Record Item;
                            ItemVariant: Record "Item Variant";
                        begin
                            if TempSaleLinePOSReq.Description = '' then begin
                                Item.Get(TempSaleLinePOSReq."No.");
                                TempSaleLinePOSReq.Description := Item.Description;
                            end;
                            if TempSaleLinePOSReq."Magento Brand" = '' then begin
                                Item.Get(TempSaleLinePOSReq."No.");
                                TempSaleLinePOSReq."Magento Brand" := Item."NPR Magento Brand";
                            end;
                            if (TempSaleLinePOSReq."Description 2" = '') and (TempSaleLinePOSReq."Variant Code" <> '') then begin
                                ItemVariant.Get(TempSaleLinePOSReq."No.", TempSaleLinePOSReq."Variant Code");
                                TempSaleLinePOSReq."Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(TempSaleLinePOSReq."Description 2"));
                            end;
                        end;
                    }
                }
                textelement(discount_coupons)
                {
                    MaxOccurs = Once;
                    tableelement(tempnpdcextcouponbuffer; "NPR NpDc Ext. Coupon Buffer")
                    {
                        XmlName = 'discount_coupon';
                        UseTemporary = true;
                        fieldattribute(reference_no; TempNpDcExtCouponBuffer."Reference No.")
                        {

                            trigger OnAfterAssignField()
                            var
                                NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
                            begin
                            end;
                        }

                        trigger OnBeforeInsertRecord()
                        begin
                            TempNpDcExtCouponBuffer."Document No." := DocumentNoReq;
                            CouponLineNo += 10000;
                            TempNpDcExtCouponBuffer."Line No." := CouponLineNo;
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    currXMLport.Break;
                end;
            }
            tableelement(tempsaleposres; "NPR Sale POS")
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                XmlName = 'response';
                UseTemporary = true;
                textelement(documentnores)
                {
                    XmlName = 'document_no';

                    trigger OnBeforePassVariable()
                    begin
                        DocumentNoRes := DocumentNoReq;
                    end;
                }
                textelement(possaleslinesres)
                {
                    MaxOccurs = Once;
                    XmlName = 'pos_sales_lines';
                    tableelement(tempsalelineposres; "NPR Sale Line POS")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'pos_sales_line';
                        UseTemporary = true;
                        fieldattribute(line_no; TempSaleLinePOSRes."Line No.")
                        {
                        }
                        fieldelement(item_no; TempSaleLinePOSRes."No.")
                        {
                        }
                        fieldelement(variant_code; TempSaleLinePOSRes."Variant Code")
                        {
                        }
                        fieldelement(description; TempSaleLinePOSRes.Description)
                        {
                        }
                        fieldelement(description_2; TempSaleLinePOSRes."Description 2")
                        {
                        }
                        fieldelement(unit_price_incl_vat; TempSaleLinePOSRes."Unit Price")
                        {
                        }
                        fieldelement(quantity; TempSaleLinePOSRes.Quantity)
                        {
                        }
                        fieldelement(unit_of_measure; TempSaleLinePOSRes."Unit of Measure Code")
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_pct; TempSaleLinePOSRes."Discount %")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(discount_amount; TempSaleLinePOSRes."Discount Amount")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(vat_percent; TempSaleLinePOSRes."VAT %")
                        {
                        }
                        fieldelement(line_amount_incl_vat; TempSaleLinePOSRes."Amount Including VAT")
                        {
                        }
                        fieldelement(magento_brand; TempSaleLinePOSRes."Magento Brand")
                        {
                        }

                    }
                }

                trigger OnAfterInitRecord()
                begin
                    currXMLport.Break;
                end;
            }
        }
    }

    var
        CouponLineNo: Integer;

    procedure GetRequest(var TempSalePOSReq2: Record "NPR Sale POS" temporary; var TempSaleLinePOSReq2: Record "NPR Sale Line POS" temporary; var TempNpDcExtCouponBuffer2: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    begin
        TempSalePOSReq2.Copy(TempSalePOSReq, true);
        TempSaleLinePOSReq2.Copy(TempSaleLinePOSReq, true);
        TempNpDcExtCouponBuffer2.Copy(TempNpDcExtCouponBuffer, true);
    end;

    procedure SetResponse(var TempSalePOSRes2: Record "NPR Sale POS" temporary; var TempSaleLinePOSRes2: Record "NPR Sale Line POS" temporary)
    begin
        TempSalePOSRes.Copy(TempSalePOSRes2, true);
        TempSaleLinePOSRes.Copy(TempSaleLinePOSRes2, true);
    end;
}

