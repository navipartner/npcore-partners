codeunit 6151006 "NPR POS Quote Mgt."
{
    var
        Text000: Label 'Delete all saved POS Quotes,Review saved POS Quotes';
        EFT_WARNING: Label 'WARNING:\%1 %2 has one or more POS Quotes linked to it with approved EFT transactions inside. These should be voided or completed as the transaction has already occurred!\\Do you want to continue with end of day?';

    procedure CleanupPOSQuotesBeforeBalancing(SalePOS: Record "NPR Sale POS") Confirmed: Boolean
    var
        POSQuoteEntry: Record "NPR POS Quote Entry";
        POSQuotes: Page "NPR POS Quotes";
        SelectedMenu: Integer;
    begin
        if not GuiAllowed then
            exit(true);

        POSQuoteEntry.SetAutoCalcFields("Contains EFT Approval");
        POSQuoteEntry.SetRange("Register No.", SalePOS."Register No.");
        POSQuoteEntry.SetRange("Contains EFT Approval", true);
        if not POSQuoteEntry.IsEmpty then
            if not Confirm(EFT_WARNING, false, SalePOS.FieldCaption("Register No."), SalePOS."Register No.") then
                exit(false);

        POSQuoteEntry.SetRange("Contains EFT Approval");

        if not POSQuoteEntry.FindFirst then
            exit(true);

        SelectedMenu := StrMenu(Text000, 1);
        case SelectedMenu of
            1:
                begin
                    Confirmed := true;
                    POSQuoteEntry.DeleteAll(true);
                end;
            2:
                begin
                    Clear(POSQuotes);
                    POSQuotes.SetIsInEndOfTheDayProcess(true);
                    POSQuotes.LookupMode(true);
                    Confirmed := POSQuotes.RunModal() = ACTION::LookupOK;
                end;
        end;

        exit(Confirmed);
    end;

    procedure SetSalePOSFilter(SalePOS: Record "NPR Sale POS"; var POSQuoteEntry: Record "NPR POS Quote Entry"; "Filter": Option All,Register,Salesperson,"Register+Salesperson")
    begin
        Clear(POSQuoteEntry);
        POSQuoteEntry.FilterGroup(40);
        case Filter of
            Filter::Register:
                begin
                    POSQuoteEntry.SetRange("Register No.", SalePOS."Register No.");
                end;
            Filter::Salesperson:
                begin
                    POSQuoteEntry.SetRange("Salesperson Code", SalePOS."Salesperson Code");
                end;
            Filter::"Register+Salesperson":
                begin
                    POSQuoteEntry.SetRange("Salesperson Code", SalePOS."Salesperson Code");
                    POSQuoteEntry.SetRange("Register No.", SalePOS."Register No.");
                end;
        end;
        POSQuoteEntry.FilterGroup(0);
    end;

    [Obsolete('Please use native Business Central objects instead of dotnet classes.')]
    procedure POSSale2Xml(SalePOS: Record "NPR Sale POS"; var XmlDoc: DotNet "NPRNetXmlDocument")
    var
        BCXmlDoc: XmlDocument;
        Xml: Text;
    begin
        POSSale2Xml(SalePOS, BCXmlDoc);
        XmlDoc := XmlDoc.XmlDocument();
        BCXmlDoc.WriteTo(Xml);
        XmlDoc.Load(Xml);
    end;

    procedure POSSale2Xml(SalePOS: Record "NPR Sale POS"; var XmlDoc: XmlDocument)
    var
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSNewCoupon: Record "NPR NpDc SaleLinePOS NewCoupon";
        NpIaSaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        RetailCrossReference: Record "NPR Retail Cross Reference";
        SaleLinePOS: Record "NPR Sale Line POS";
        NpDcSaleLinePOSNewCouponFieldBuffer: Record "Field" temporary;
        NpDcSaleLinePOSCouponFieldBuffer: Record "Field" temporary;
        NpIaSaleLinePOSAddOnFieldBuffer: Record "Field" temporary;
        NpRvSalesLineReferenceFieldBuffer: Record "Field" temporary;
        NpRvSalesLineFieldBuffer: Record "Field" temporary;
        POSInfoTransactionFieldBuffer: Record "Field" temporary;
        RetailCrossReferenceFieldBuffer: Record "Field" temporary;
        SalePOSFieldBuffer: Record "Field" temporary;
        SaleLinePOSFieldBuffer: Record "Field" temporary;
        XmlRoot: XmlElement;
        Element: XmlElement;
        Element2: XmlElement;
        Element3: XmlElement;
        Element4: XmlElement;
        Element5: XmlElement;
        Element6: XmlElement;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SalePOS);
        FindFields(RecRef, false, SalePOSFieldBuffer);

        RecRef.GetTable(SaleLinePOS);
        FindFields(RecRef, false, SaleLinePOSFieldBuffer);

        RecRef.GetTable(POSInfoTransaction);
        FindFields(RecRef, false, POSInfoTransactionFieldBuffer);

        RecRef.GetTable(NpIaSaleLinePOSAddOn);
        FindFields(RecRef, false, NpIaSaleLinePOSAddOnFieldBuffer);

        RecRef.GetTable(NpRvSalesLine);
        FindFields(RecRef, false, NpRvSalesLineFieldBuffer);

        RecRef.GetTable(NpRvSalesLineReference);
        FindFields(RecRef, false, NpRvSalesLineReferenceFieldBuffer);

        RecRef.GetTable(NpDcSaleLinePOSCoupon);
        FindFields(RecRef, false, NpDcSaleLinePOSCouponFieldBuffer);

        RecRef.GetTable(NpDcSaleLinePOSNewCoupon);
        FindFields(RecRef, false, NpDcSaleLinePOSNewCouponFieldBuffer);

        RecRef.GetTable(RetailCrossReference);
        FindFields(RecRef, false, RetailCrossReferenceFieldBuffer);

        XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?><pos_sale />', XmlDoc);
        XmlDoc.GetRoot(XmlRoot);

        RecRef.GetTable(SalePOS);
        RecRef2Xml(RecRef, XmlRoot, SalePOSFieldBuffer);

        POSInfoTransaction.SetRange("Register No.", SalePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        POSInfoTransaction.SetFilter("Sales Line No.", '=%1', 0);
        if POSInfoTransaction.FindSet then begin
            Element := XmlElement.Create('pos_info_transactions');
            XmlRoot.Add(Element);
            repeat
                Element2 := XmlElement.Create('pos_info_transaction');
                Element.Add(Element2);
                RecRef.GetTable(POSInfoTransaction);
                RecRef2Xml(RecRef, Element2, POSInfoTransactionFieldBuffer);
            until POSInfoTransaction.Next = 0;
        end;

        OnPOSSale2Xml(SalePOS, XmlRoot);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet then begin
            Element := XmlElement.Create('pos_sale_lines');
            XmlRoot.Add(Element);
            repeat
                Element2 := XmlElement.Create('pos_sale_line');
                Element.Add(Element2);

                RecRef.GetTable(SaleLinePOS);
                RecRef2Xml(RecRef, Element2, SaleLinePOSFieldBuffer);

                POSInfoTransaction.SetRange("Register No.", SalePOS."Register No.");
                POSInfoTransaction.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
                if POSInfoTransaction.FindSet then begin
                    Element3 := XmlElement.Create('pos_info_transactions');
                    Element2.Add(Element3);
                    repeat
                        Element4 := XmlElement.Create('pos_info_transaction');
                        Element3.Add(Element4);
                        RecRef.GetTable(POSInfoTransaction);
                        RecRef2Xml(RecRef, Element4, POSInfoTransactionFieldBuffer);
                    until POSInfoTransaction.Next = 0;
                end;

                NpIaSaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
                NpIaSaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                NpIaSaleLinePOSAddOn.SetRange("Sale Type", SaleLinePOS."Sale Type");
                NpIaSaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
                NpIaSaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
                if NpIaSaleLinePOSAddOn.FindSet then begin
                    Element3 := XmlElement.Create('item_addons');
                    Element2.Add(Element3);
                    repeat
                        Element4 := XmlElement.Create('item_addon');
                        Element3.Add(Element4);
                        RecRef.GetTable(NpIaSaleLinePOSAddOn);
                        RecRef2Xml(RecRef, Element4, NpIaSaleLinePOSAddOnFieldBuffer);
                    until NpIaSaleLinePOSAddOn.Next = 0;
                end;

                NpRvSalesLine.SetRange("Retail ID", SaleLinePOS."Retail ID");
                if NpRvSalesLine.FindSet then begin
                    Element3 := XmlElement.Create('retail_vouchers');
                    Element2.Add(Element3);
                    repeat
                        Element4 := XmlElement.Create('retail_voucher');
                        Element3.Add(Element4);
                        RecRef.GetTable(NpRvSalesLine);
                        RecRef2Xml(RecRef, Element4, NpRvSalesLineFieldBuffer);

                        NpRvSalesLineReference.SetRange("Sales Line Id", NpRvSalesLine.Id);
                        if NpRvSalesLineReference.FindSet then begin
                            Element5 := XmlElement.Create('references');
                            Element4.Add(Element3);
                            repeat
                                Element6 := XmlElement.Create('reference');
                                Element5.Add(Element6);
                                RecRef.GetTable(NpRvSalesLineReference);
                                RecRef2Xml(RecRef, Element6, NpRvSalesLineReferenceFieldBuffer);
                            until NpRvSalesLineReference.Next = 0;
                        end;
                    until NpRvSalesLine.Next = 0;
                end;

                NpDcSaleLinePOSCoupon.SetRange("Register No.", SaleLinePOS."Register No.");
                NpDcSaleLinePOSCoupon.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                NpDcSaleLinePOSCoupon.SetRange("Sale Type", SaleLinePOS."Sale Type");
                NpDcSaleLinePOSCoupon.SetRange("Sale Date", SaleLinePOS.Date);
                NpDcSaleLinePOSCoupon.SetRange("Sale Line No.", SaleLinePOS."Line No.");
                if NpDcSaleLinePOSCoupon.FindSet then begin
                    Element3 := XmlElement.Create('discount_coupons');
                    Element2.Add(Element3);
                    repeat
                        Element4 := XmlElement.Create('discount_coupon');
                        Element3.Add(Element4);
                        RecRef.GetTable(NpDcSaleLinePOSCoupon);
                        RecRef2Xml(RecRef, Element4, NpDcSaleLinePOSCouponFieldBuffer);
                    until NpDcSaleLinePOSCoupon.Next = 0;
                end;

                NpDcSaleLinePOSNewCoupon.SetRange("Register No.", SaleLinePOS."Register No.");
                NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                NpDcSaleLinePOSNewCoupon.SetRange("Sale Type", SaleLinePOS."Sale Type");
                NpDcSaleLinePOSNewCoupon.SetRange("Sale Date", SaleLinePOS.Date);
                NpDcSaleLinePOSNewCoupon.SetRange("Sale Line No.", SaleLinePOS."Line No.");
                if NpDcSaleLinePOSNewCoupon.FindSet then begin
                    Element3 := XmlElement.Create('new_discount_coupons');
                    Element2.Add(Element3);
                    repeat
                        Element4 := XmlElement.Create('new_discount_coupon');
                        Element3.Add(Element4);
                        RecRef.GetTable(NpDcSaleLinePOSNewCoupon);
                        RecRef2Xml(RecRef, Element4, NpDcSaleLinePOSNewCouponFieldBuffer);
                    until NpDcSaleLinePOSNewCoupon.Next = 0;
                end;

                if not IsNullGuid(SaleLinePOS."Retail ID") then
                    if RetailCrossReference.Get(SaleLinePOS."Retail ID") then begin
                        Element3 := XmlElement.Create('retail_cross_references');
                        Element2.Add(Element3);
                        Element4 := XmlElement.Create('retail_cross_reference');
                        Element3.Add(Element4);
                        RecRef.GetTable(RetailCrossReference);
                        RecRef2Xml(RecRef, Element4, RetailCrossReferenceFieldBuffer);
                    end;

                OnPOSSaleLine2Xml(SaleLinePOS, Element);
            until SaleLinePOS.Next = 0;
        end;
    end;

    local procedure RecRef2Xml(RecRef: RecordRef; Element: XmlElement; var TempField: Record "Field" temporary)
    var
        Element2: XmlElement;
    begin
        Element.SetAttribute('table_no', Format(RecRef.Number, 0, 9));
        Element2 := XmlElement.Create('Fields');
        Element.Add(Element2);
        if TempField.FindSet then
            repeat
                Field2Xml(RecRef, TempField, Element2);
            until TempField.Next = 0;
    end;

    local procedure FindFields(RecRef: RecordRef; ExclKeyField: Boolean; var TempField: Record "Field" temporary)
    var
        "Field": Record "Field";
        KeyFieldBuffer: Record "Field" temporary;
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        i: Integer;
    begin
        if not TempField.IsTemporary then begin
            TempField.SetFilter("No.", '=%1&<>%1', 1);
            exit;
        end;

        if ExclKeyField then begin
            KeyRef := RecRef.KeyIndex(1);
            for i := 1 to KeyRef.FieldCount do begin
                FieldRef := KeyRef.FieldIndex(i);
                Field.Get(RecRef.Number, FieldRef.Number);
                KeyFieldBuffer.Init;
                KeyFieldBuffer := Field;
                KeyFieldBuffer.Insert;
            end;
        end;

        Clear(TempField);
        TempField.DeleteAll;
        Field.SetRange(TableNo, RecRef.Number);
        Field.SetFilter("No.", '<%1', 2000000000);  //Exclude system fields
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(Enabled, true);
        if not Field.FindSet then
            exit;

        repeat
            if (not ExclKeyField) or (not KeyFieldBuffer.Get(Field.TableNo, Field."No.")) then begin
                TempField.Init;
                TempField := Field;
                TempField.Insert;
            end;
        until Field.Next = 0;
    end;

    local procedure Field2Xml(RecRef: RecordRef; "Field": Record "Field"; var Element: XmlElement)
    var
        Element2: XmlElement;
        FieldValue: Text;
        CData: XmlCData;
    begin
        if not GetFieldValue(RecRef, Field, FieldValue) then
            exit;

        Element2 := XmlElement.Create('field');
        Element2.SetAttribute('field_no', Format(Field."No.", 0, 9));
        Element.Add(Element2);
        CData := XmlCData.Create(FieldValue);
        Element2.Add(CData);
    end;

    local procedure GetFieldValue(RecRef: RecordRef; "Field": Record "Field"; var FieldValue: Text): Boolean
    var
        FieldRef: FieldRef;
    begin
        FieldRef := RecRef.Field(Field."No.");
        case Field.Type of
            Field.Type::BigInteger, Field.Type::Boolean, Field.Type::Date, Field.Type::DateFormula, Field.Type::DateTime, Field.Type::Decimal,
            Field.Type::Duration, Field.Type::GUID, Field.Type::Integer, Field.Type::RecordID, Field.Type::Time:
                begin
                    FieldValue := Format(FieldRef.Value, 0, 9);
                    exit(true);
                end;
            Field.Type::Option:
                begin
                    FieldValue := Format(FieldRef.Value, 0, 2);
                    exit(true);
                end;
            Field.Type::Code, Field.Type::Text:
                begin
                    FieldValue := Format(FieldRef.Value);
                    exit(true);
                end;
        end;

        exit(false);
    end;

    [Obsolete('Please use native Business Central objects instead of dotnet classes.')]
    procedure LoadPOSSaleData(POSQuoteEntry: Record "NPR POS Quote Entry"; var XmlDoc: DotNet "NPRNetXmlDocument"): Boolean
    var
        InStr: InStream;
    begin
        if not POSQuoteEntry."POS Sales Data".HasValue then
            exit(false);
        POSQuoteEntry.CalcFields("POS Sales Data");
        POSQuoteEntry."POS Sales Data".CreateInStream(InStr, TEXTENCODING::UTF8);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStr);
        exit(not IsNull(XmlDoc));
    end;

    procedure LoadPOSSaleData(POSQuoteEntry: Record "NPR POS Quote Entry"; var XmlDoc: XmlDocument): Boolean
    var
        InStr: InStream;
    begin
        if not POSQuoteEntry."POS Sales Data".HasValue then
            exit(false);
        POSQuoteEntry.CalcFields("POS Sales Data");
        POSQuoteEntry."POS Sales Data".CreateInStream(InStr, TEXTENCODING::UTF8);
        exit(XmlDocument.ReadFrom(InStr, XmlDoc));
    end;

    [Obsolete('Please use native Business Central objects instead of dotnet classes.')]
    procedure Xml2POSSale(var XmlDoc: DotNet "NPRNetXmlDocument"; var SalePOS: Record "NPR Sale POS")
    var
        Xml: Text;
        BCXmlDoc: XmlDocument;
    begin
        XmlDocument.ReadFrom(XmlDoc.InnerXml, BCXmlDoc);
        Xml2POSSale(BCXmlDoc, SalePOS);
        BCXmlDoc.WriteTo(Xml);
        XmlDoc := XmlDoc.XmlDocument();
        XmlDoc.LoadXml(Xml);
    end;

    procedure Xml2POSSale(var XmlDoc: XmlDocument; var SalePOS: Record "NPR Sale POS")
    var
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSNewCoupon: Record "NPR NpDc SaleLinePOS NewCoupon";
        NpIaSaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        RetailCrossReference: Record "NPR Retail Cross Reference";
        SaleLinePOS: Record "NPR Sale Line POS";
        NpDcSaleLinePOSNewCouponFieldBuffer: Record "Field" temporary;
        NpDcSaleLinePOSCouponFieldBuffer: Record "Field" temporary;
        NpIaSaleLinePOSAddOnFieldBuffer: Record "Field" temporary;
        NpRvSalesLineReferenceFieldBuffer: Record "Field" temporary;
        NpRvSalesLineFieldBuffer: Record "Field" temporary;
        POSInfoTransactionFieldBuffer: Record "Field" temporary;
        RetailCrossReferenceFieldBuffer: Record "Field" temporary;
        SalePOSFieldBuffer: Record "Field" temporary;
        SaleLinePOSFieldBuffer: Record "Field" temporary;
        Element: XmlElement;
        Root: XmlElement;
        RecRef: RecordRef;
        PrevRec: Text;
        Position: Integer;
        POSInfoTransactionNodes: XmlNodeList;
        POSInfoTransactionNode: XmlNode;
        POSSaleLineNodes: XmlNodeList;
        POSSaleLineNode: XmlNode;
        ItemAddonNodes: XmlNodeList;
        ItemAddonNode: XmlNode;
        RetailVoucherNodes: XmlNodeList;
        RetailVoucherNode: XmlNode;
        ReferenceNodes: XmlNodeList;
        ReferenceNode: XmlNode;
        DiscountCouponNodes: XmlNodeList;
        DiscountCouponNode: XmlNode;
        RetailCrossReferenceNodes: XmlNodeList;
        RetailCrossReferenceNode: XmlNode;
        NewDiscountCouponNodes: XmlNodeList;
        NewDiscountCouponNode: XmlNode;
    begin
        if not XmlDoc.GetRoot(Root) then
            exit;
        if Root.Name <> 'pos_sale' then
            exit;

        RecRef.GetTable(SalePOS);
        FindFields(RecRef, true, SalePOSFieldBuffer);
        if SalePOSFieldBuffer.Get(RecRef.Number, SalePOS.FieldNo("POS Sale ID")) then
            SalePOSFieldBuffer.Delete;
        if SalePOSFieldBuffer.Get(RecRef.Number, SalePOS.FieldNo("Device ID")) then
            SalePOSFieldBuffer.Delete;
        if SalePOSFieldBuffer.Get(RecRef.Number, SalePOS.FieldNo("Host Name")) then
            SalePOSFieldBuffer.Delete;
        if SalePOSFieldBuffer.Get(RecRef.Number, SalePOS.FieldNo("User ID")) then
            SalePOSFieldBuffer.Delete;

        RecRef.GetTable(SaleLinePOS);
        FindFields(RecRef, false, SaleLinePOSFieldBuffer);

        RecRef.GetTable(POSInfoTransaction);
        FindFields(RecRef, false, POSInfoTransactionFieldBuffer);

        RecRef.GetTable(NpIaSaleLinePOSAddOn);
        FindFields(RecRef, false, NpIaSaleLinePOSAddOnFieldBuffer);

        RecRef.GetTable(NpRvSalesLine);
        FindFields(RecRef, false, NpRvSalesLineFieldBuffer);

        RecRef.GetTable(NpRvSalesLineReference);
        FindFields(RecRef, false, NpRvSalesLineReferenceFieldBuffer);

        RecRef.GetTable(NpDcSaleLinePOSCoupon);
        FindFields(RecRef, false, NpDcSaleLinePOSCouponFieldBuffer);

        RecRef.GetTable(NpDcSaleLinePOSNewCoupon);
        FindFields(RecRef, false, NpDcSaleLinePOSNewCouponFieldBuffer);

        RecRef.GetTable(RetailCrossReference);
        FindFields(RecRef, false, RetailCrossReferenceFieldBuffer);

        RecRef.GetTable(SalePOS);
        PrevRec := Format(RecRef);
        Xml2RecRef(Root, SalePOSFieldBuffer, RecRef);
        if PrevRec <> Format(RecRef) then
            RecRef.Modify(true);
        RecRef.SetTable(SalePOS);
        Root.SelectNodes('pos_info_transactions/pos_info_transaction', POSInfoTransactionNodes);
        foreach POSInfoTransactionNode in POSInfoTransactionNodes do begin
            Element := POSInfoTransactionNode.AsXmlElement();
            POSInfoTransaction.Init;
            RecRef.GetTable(POSInfoTransaction);
            Xml2RecRef(Element, POSInfoTransactionFieldBuffer, RecRef);
            RecRef.SetTable(POSInfoTransaction);
            POSInfoTransaction."Register No." := SalePOS."Register No.";
            POSInfoTransaction."Sales Ticket No." := SalePOS."Sales Ticket No.";
            POSInfoTransaction."Sale Date" := SalePOS.Date;
            POSInfoTransaction."Sales Line No." := 0;
            POSInfoTransaction.Insert(true);
        end;

        OnXml2POSSale(Root, SalePOS);

        Root.SelectNodes('pos_sale_lines/pos_sale_line', POSSaleLineNodes);
        foreach POSSaleLineNode in POSSaleLineNodes do begin
            Element := POSSaleLineNode.AsXmlElement();
            SaleLinePOS.Init;
            RecRef.GetTable(SaleLinePOS);
            Xml2RecRef(Element, SaleLinePOSFieldBuffer, RecRef);
            RecRef.SetTable(SaleLinePOS);
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS.Insert(true);

            Element.SelectNodes('pos_info_transactions/pos_info_transaction', POSInfoTransactionNodes);
            foreach POSInfoTransactionNode in POSInfoTransactionNodes do begin
                POSInfoTransaction.Init;
                RecRef.GetTable(POSInfoTransaction);
                Xml2RecRef(POSInfoTransactionNode.AsXmlElement(), POSInfoTransactionFieldBuffer, RecRef);
                RecRef.SetTable(POSInfoTransaction);
                POSInfoTransaction."Register No." := SalePOS."Register No.";
                POSInfoTransaction."Sales Ticket No." := SalePOS."Sales Ticket No.";
                POSInfoTransaction."Sale Date" := SalePOS.Date;
                POSInfoTransaction.Insert(true);
            end;

            Element.SelectNodes('item_addons/item_addon', ItemAddonNodes);
            foreach ItemAddonNode in ItemAddonNodes do begin
                NpIaSaleLinePOSAddOn.Init;
                RecRef.GetTable(NpIaSaleLinePOSAddOn);
                Xml2RecRef(ItemAddonNode.AsXmlElement(), NpIaSaleLinePOSAddOnFieldBuffer, RecRef);
                RecRef.SetTable(NpIaSaleLinePOSAddOn);
                NpIaSaleLinePOSAddOn."Register No." := SalePOS."Register No.";
                NpIaSaleLinePOSAddOn."Sales Ticket No." := SalePOS."Sales Ticket No.";
                NpIaSaleLinePOSAddOn."Sale Date" := SalePOS.Date;
                NpIaSaleLinePOSAddOn.Insert(true);
            end;

            Element.SelectNodes('retail_vouchers/retail_voucher', RetailVoucherNodes);
            foreach RetailVoucherNode in RetailVoucherNodes do begin
                NpRvSalesLine.Init;
                RecRef.GetTable(NpRvSalesLine);
                Xml2RecRef(RetailVoucherNode.AsXmlElement(), NpRvSalesLineFieldBuffer, RecRef);
                RecRef.SetTable(NpRvSalesLine);
                NpRvSalesLine."Retail ID" := SaleLinePOS."Retail ID";
                NpRvSalesLine."Register No." := SalePOS."Register No.";
                NpRvSalesLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
                NpRvSalesLine."Sale Date" := SalePOS.Date;
                NpRvSalesLine.Insert(true);

                RetailVoucherNode.SelectNodes('references/reference', ReferenceNodes);
                foreach ReferenceNode in ReferenceNodes do begin
                    NpRvSalesLineReference.Init;
                    RecRef.GetTable(NpRvSalesLineReference);
                    Xml2RecRef(ReferenceNode.AsXmlElement(), NpRvSalesLineReferenceFieldBuffer, RecRef);
                    RecRef.SetTable(NpRvSalesLineReference);
                    NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
                    NpRvSalesLineReference.Id := NpRvSalesLine."Register No.";
                    NpRvSalesLineReference.Insert(true);
                end;
            end;

            Element.SelectNodes('discount_coupons/discount_coupon', DiscountCouponNodes);
            foreach DiscountCouponNode in DiscountCouponNodes do begin
                NpDcSaleLinePOSCoupon.Init;
                RecRef.GetTable(NpDcSaleLinePOSCoupon);
                Xml2RecRef(DiscountCouponNode.AsXmlElement(), NpDcSaleLinePOSCouponFieldBuffer, RecRef);
                RecRef.SetTable(NpDcSaleLinePOSCoupon);
                NpDcSaleLinePOSCoupon."Register No." := SalePOS."Register No.";
                NpDcSaleLinePOSCoupon."Sales Ticket No." := SalePOS."Sales Ticket No.";
                NpDcSaleLinePOSCoupon."Sale Date" := SalePOS.Date;
                NpDcSaleLinePOSCoupon.Insert(true);
            end;

            Element.SelectNodes('new_discount_coupons/new_discount_coupon', NewDiscountCouponNodes);
            foreach NewDiscountCouponNode in NewDiscountCouponNodes do begin
                NpDcSaleLinePOSNewCoupon.Init;
                RecRef.GetTable(NpDcSaleLinePOSNewCoupon);
                Xml2RecRef(NewDiscountCouponNode.AsXmlElement(), NpDcSaleLinePOSNewCouponFieldBuffer, RecRef);
                RecRef.SetTable(NpDcSaleLinePOSNewCoupon);
                NpDcSaleLinePOSNewCoupon."Register No." := SalePOS."Register No.";
                NpDcSaleLinePOSNewCoupon."Sales Ticket No." := SalePOS."Sales Ticket No.";
                NpDcSaleLinePOSNewCoupon."Sale Date" := SalePOS.Date;
                NpDcSaleLinePOSNewCoupon.Insert(true);
            end;

            Element.SelectNodes('retail_cross_references/retail_cross_reference', RetailCrossReferenceNodes);
            foreach RetailCrossReferenceNode in RetailCrossReferenceNodes do begin
                RetailCrossReference.Init;
                RecRef.GetTable(RetailCrossReference);
                Xml2RecRef(RetailCrossReferenceNode.AsXmlElement(), RetailCrossReferenceFieldBuffer, RecRef);
                RecRef.SetTable(RetailCrossReference);
                Position := StrPos(RetailCrossReference."Record Value", '_');
                if Position <> 0 then
                    RetailCrossReference."Record Value" := StrSubstNo('%1_%2', SalePOS."Sales Ticket No.", CopyStr(RetailCrossReference."Record Value", Position + 1))
                else
                    RetailCrossReference."Record Value" := SalePOS."Sales Ticket No.";
                RetailCrossReference.Insert(true);
            end;

            OnXml2POSSaleLine(Element, SaleLinePOS);
        end;
    end;

    local procedure Xml2RecRef(Element: XmlElement; var TempField: Record "Field" temporary; var RecRef: RecordRef)
    var
        Element2: XmlElement;
        Attr: XmlAttribute;
        FieldNode: XmlNode;
    begin
        if not TempField.FindSet then
            exit;
        Element.Attributes().Get('table_no', Attr);
        if Attr.Value <> Format(RecRef.Number, 0, 9) then
            exit;

        repeat
            if Element.SelectSingleNode('fields/field[@field_no = ' + Format(TempField."No.", 0, 9) + ']', FieldNode) then
                Xml2Field(FieldNode.AsXmlElement(), TempField, RecRef);
        until TempField.Next = 0;
    end;

    local procedure Xml2Field(Element: XmlElement; "Field": Record "Field"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        TextValue: Text;
        DecimalValue: Decimal;
        IntegerValue: Integer;
        BooleanValue: Boolean;
        DateValue: Date;
        TimeValue: Time;
        DateFormulaValue: DateFormula;
        BigIntegerValue: BigInteger;
        DateTimeValue: DateTime;
        DurationValue: Duration;
        GUIDValue: Guid;
        RecordIDValue: RecordID;
    begin
        FieldRef := RecRef.Field(Field."No.");
        case Field.Type of
            Field.Type::BigInteger:
                begin
                    if Evaluate(BigIntegerValue, Element.InnerText, 9) then
                        FieldRef.Value := BigIntegerValue;
                end;
            Field.Type::Boolean:
                begin
                    if Evaluate(BooleanValue, Element.InnerText, 9) then
                        FieldRef.Value := BooleanValue;
                end;
            Field.Type::Date:
                begin
                    if Evaluate(DateValue, Element.InnerText, 9) then
                        FieldRef.Value := DateValue;
                end;
            Field.Type::DateFormula:
                begin
                    if Evaluate(DateFormulaValue, Element.InnerText, 9) then
                        FieldRef.Value := DateFormulaValue;
                end;
            Field.Type::DateTime:
                begin
                    if Evaluate(DateTimeValue, Element.InnerText, 9) then
                        FieldRef.Value := DateTimeValue;
                end;
            Field.Type::Decimal:
                begin
                    if Evaluate(DecimalValue, Element.InnerText, 9) then
                        FieldRef.Value := DecimalValue;
                end;
            Field.Type::Duration:
                begin
                    if Evaluate(DurationValue, Element.InnerText, 9) then
                        FieldRef.Value := DurationValue;
                end;
            Field.Type::GUID:
                begin
                    if Evaluate(GUIDValue, Element.InnerText, 9) then
                        FieldRef.Value := GUIDValue;
                end;
            Field.Type::Integer, Field.Type::Option:
                begin
                    if Evaluate(IntegerValue, Element.InnerText, 9) then
                        FieldRef.Value := IntegerValue;
                end;
            Field.Type::RecordID:
                begin
                    if Evaluate(RecordIDValue, Element.InnerText) then
                        FieldRef.Value := RecordIDValue;
                end;
            Field.Type::Time:
                begin
                    if Evaluate(TimeValue, Element.InnerText) then
                        FieldRef.Value := TimeValue;
                end;
            Field.Type::Code:
                begin
                    TextValue := UpperCase(CopyStr(Element.InnerText, 1, FieldRef.Length));
                    FieldRef.Value := TextValue;
                end;
            Field.Type::Text:
                begin
                    TextValue := CopyStr(Element.InnerText, 1, FieldRef.Length);
                    FieldRef.Value := TextValue;
                end;
        end;
    end;

    procedure ViewPOSSalesData(POSQuoteEntry: Record "NPR POS Quote Entry")
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        StreamReader: DotNet NPRNetStreamReader;
        POSSalesData: Text;
        InStr: InStream;
        Path: Text;
    begin
        if not POSQuoteEntry."POS Sales Data".HasValue then
            exit;

        POSQuoteEntry.CalcFields("POS Sales Data");
        if IsWebClient() then begin
            POSQuoteEntry."POS Sales Data".CreateInStream(InStr);
            StreamReader := StreamReader.StreamReader(InStr);
            POSSalesData := StreamReader.ReadToEnd();
            POSSalesData := NpXmlDomMgt.PrettyPrintXml(POSSalesData);
            Message(POSSalesData);
            exit;
        end;

        TempBlob.FromRecord(POSQuoteEntry, POSQuoteEntry.FieldNo("POS Sales Data"));
        Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + POSQuoteEntry."Sales Ticket No." + '.xml', false);
        HyperLink(Path);
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId, SessionId) then
            exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;

    local procedure OnPOSSale2Xml(SalePOS: Record "NPR Sale POS"; XmlRoot: XmlElement)
    begin
    end;

    local procedure OnPOSSaleLine2Xml(SaleLinePOS: Record "NPR Sale Line POS"; XmlElement: XmlElement)
    begin
    end;

    local procedure OnXml2POSSale(XmlRoot: XmlElement; SalePOS: Record "NPR Sale POS")
    begin
    end;

    local procedure OnXml2POSSaleLine(XmlElement: XmlElement; SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;
}