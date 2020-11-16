codeunit 6151006 "NPR POS Quote Mgt."
{
    trigger OnRun()
    begin
    end;

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

    procedure POSSale2Xml(SalePOS: Record "NPR Sale POS"; var XmlDoc: DotNet "NPRNetXmlDocument")
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
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlRoot: DotNet NPRNetXmlElement;
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        XmlElement3: DotNet NPRNetXmlElement;
        XmlElement4: DotNet NPRNetXmlElement;
        XmlElement5: DotNet NPRNetXmlElement;
        XmlElement6: DotNet NPRNetXmlElement;
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

        NpXmlDomMgt.InitDoc(XmlDoc, XmlRoot, 'pos_sale');
        RecRef.GetTable(SalePOS);
        RecRef2Xml(RecRef, XmlRoot, SalePOSFieldBuffer);

        POSInfoTransaction.SetRange("Register No.", SalePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        POSInfoTransaction.SetFilter("Sales Line No.", '=%1', 0);
        if POSInfoTransaction.FindSet then begin
            NpXmlDomMgt.AddElement(XmlRoot, 'pos_info_transactions', XmlElement);
            repeat
                NpXmlDomMgt.AddElement(XmlElement, 'pos_info_transaction', XmlElement2);
                RecRef.GetTable(POSInfoTransaction);
                RecRef2Xml(RecRef, XmlElement2, POSInfoTransactionFieldBuffer);
            until POSInfoTransaction.Next = 0;
        end;

        OnPOSSale2Xml(SalePOS, XmlRoot);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet then begin
            NpXmlDomMgt.AddElement(XmlRoot, 'pos_sale_lines', XmlElement);
            repeat
                NpXmlDomMgt.AddElement(XmlElement, 'pos_sale_line', XmlElement2);
                RecRef.GetTable(SaleLinePOS);
                RecRef2Xml(RecRef, XmlElement2, SaleLinePOSFieldBuffer);

                POSInfoTransaction.SetRange("Register No.", SalePOS."Register No.");
                POSInfoTransaction.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
                if POSInfoTransaction.FindSet then begin
                    NpXmlDomMgt.AddElement(XmlElement2, 'pos_info_transactions', XmlElement3);
                    repeat
                        NpXmlDomMgt.AddElement(XmlElement3, 'pos_info_transaction', XmlElement4);
                        RecRef.GetTable(POSInfoTransaction);
                        RecRef2Xml(RecRef, XmlElement4, POSInfoTransactionFieldBuffer);
                    until POSInfoTransaction.Next = 0;
                end;

                NpIaSaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
                NpIaSaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                NpIaSaleLinePOSAddOn.SetRange("Sale Type", SaleLinePOS."Sale Type");
                NpIaSaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
                NpIaSaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
                if NpIaSaleLinePOSAddOn.FindSet then begin
                    NpXmlDomMgt.AddElement(XmlElement2, 'item_addons', XmlElement3);
                    repeat
                        NpXmlDomMgt.AddElement(XmlElement3, 'item_addon', XmlElement4);
                        RecRef.GetTable(NpIaSaleLinePOSAddOn);
                        RecRef2Xml(RecRef, XmlElement4, NpIaSaleLinePOSAddOnFieldBuffer);
                    until NpIaSaleLinePOSAddOn.Next = 0;
                end;

                NpRvSalesLine.SetRange("Retail ID", SaleLinePOS."Retail ID");
                if NpRvSalesLine.FindSet then begin
                    NpXmlDomMgt.AddElement(XmlElement2, 'retail_vouchers', XmlElement3);
                    repeat
                        NpXmlDomMgt.AddElement(XmlElement3, 'retail_voucher', XmlElement4);
                        RecRef.GetTable(NpRvSalesLine);
                        RecRef2Xml(RecRef, XmlElement4, NpRvSalesLineFieldBuffer);

                        NpRvSalesLineReference.SetRange("Sales Line Id", NpRvSalesLine.Id);
                        if NpRvSalesLineReference.FindSet then begin
                            NpXmlDomMgt.AddElement(XmlElement4, 'references', XmlElement5);
                            repeat
                                NpXmlDomMgt.AddElement(XmlElement5, 'reference', XmlElement6);
                                RecRef.GetTable(NpRvSalesLineReference);
                                RecRef2Xml(RecRef, XmlElement6, NpRvSalesLineReferenceFieldBuffer);
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
                    NpXmlDomMgt.AddElement(XmlElement2, 'discount_coupons', XmlElement3);
                    repeat
                        NpXmlDomMgt.AddElement(XmlElement3, 'discount_coupon', XmlElement4);
                        RecRef.GetTable(NpDcSaleLinePOSCoupon);
                        RecRef2Xml(RecRef, XmlElement4, NpDcSaleLinePOSCouponFieldBuffer);
                    until NpDcSaleLinePOSCoupon.Next = 0;
                end;

                NpDcSaleLinePOSNewCoupon.SetRange("Register No.", SaleLinePOS."Register No.");
                NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                NpDcSaleLinePOSNewCoupon.SetRange("Sale Type", SaleLinePOS."Sale Type");
                NpDcSaleLinePOSNewCoupon.SetRange("Sale Date", SaleLinePOS.Date);
                NpDcSaleLinePOSNewCoupon.SetRange("Sale Line No.", SaleLinePOS."Line No.");
                if NpDcSaleLinePOSNewCoupon.FindSet then begin
                    NpXmlDomMgt.AddElement(XmlElement2, 'new_discount_coupons', XmlElement3);
                    repeat
                        NpXmlDomMgt.AddElement(XmlElement3, 'new_discount_coupon', XmlElement4);
                        RecRef.GetTable(NpDcSaleLinePOSNewCoupon);
                        RecRef2Xml(RecRef, XmlElement4, NpDcSaleLinePOSNewCouponFieldBuffer);
                    until NpDcSaleLinePOSNewCoupon.Next = 0;
                end;

                if not IsNullGuid(SaleLinePOS."Retail ID") then
                    if RetailCrossReference.Get(SaleLinePOS."Retail ID") then begin
                        NpXmlDomMgt.AddElement(XmlElement2, 'retail_cross_references', XmlElement3);
                        NpXmlDomMgt.AddElement(XmlElement3, 'retail_cross_reference', XmlElement4);
                        RecRef.GetTable(RetailCrossReference);
                        RecRef2Xml(RecRef, XmlElement4, RetailCrossReferenceFieldBuffer);
                    end;

                OnPOSSaleLine2Xml(SaleLinePOS, XmlElement);
            until SaleLinePOS.Next = 0;
        end;
    end;

    local procedure RecRef2Xml(RecRef: RecordRef; XmlElement: DotNet NPRNetXmlElement; var TempField: Record "Field" temporary)
    var
        XmlElement2: DotNet NPRNetXmlElement;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin
        NpXmlDomMgt.AddAttribute(XmlElement, 'table_no', Format(RecRef.Number, 0, 9));
        NpXmlDomMgt.AddElement(XmlElement, 'fields', XmlElement2);
        if TempField.FindSet then
            repeat
                Field2Xml(RecRef, TempField, XmlElement2);
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

    local procedure Field2Xml(RecRef: RecordRef; "Field": Record "Field"; var XmlElement: DotNet NPRNetXmlElement)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlCDATA: DotNet NPRNetXmlCDataSection;
        XmlElement2: DotNet NPRNetXmlElement;
        FieldValue: Text;
    begin
        if not GetFieldValue(RecRef, Field, FieldValue) then
            exit;

        NpXmlDomMgt.AddElement(XmlElement, 'field', XmlElement2);
        NpXmlDomMgt.AddAttribute(XmlElement2, 'field_no', Format(Field."No.", 0, 9));
        XmlCDATA := XmlElement2.OwnerDocument.CreateCDataSection('');
        XmlElement2.AppendChild(XmlCDATA);
        XmlCDATA.AppendData(FieldValue);
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

    procedure Xml2POSSale(var XmlDoc: DotNet "NPRNetXmlDocument"; var SalePOS: Record "NPR Sale POS")
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
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        XmlElement3: DotNet NPRNetXmlElement;
        XmlRoot: DotNet NPRNetXmlElement;
        RecRef: RecordRef;
        PrevRec: Text;
        Position: Integer;
    begin
        if IsNull(XmlDoc) then
            exit;
        XmlRoot := XmlDoc.DocumentElement;
        if IsNull(XmlRoot) then
            exit;
        if XmlRoot.Name <> 'pos_sale' then
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
        Xml2RecRef(XmlRoot, SalePOSFieldBuffer, RecRef);
        if PrevRec <> Format(RecRef) then
            RecRef.Modify(true);
        RecRef.SetTable(SalePOS);
        foreach XmlElement in XmlRoot.SelectNodes('pos_info_transactions/pos_info_transaction') do begin
            POSInfoTransaction.Init;
            RecRef.GetTable(POSInfoTransaction);
            Xml2RecRef(XmlElement, POSInfoTransactionFieldBuffer, RecRef);
            RecRef.SetTable(POSInfoTransaction);
            POSInfoTransaction."Register No." := SalePOS."Register No.";
            POSInfoTransaction."Sales Ticket No." := SalePOS."Sales Ticket No.";
            POSInfoTransaction."Sale Date" := SalePOS.Date;
            POSInfoTransaction."Sales Line No." := 0;
            POSInfoTransaction.Insert(true);
        end;

        OnXml2POSSale(XmlRoot, SalePOS);

        foreach XmlElement in XmlRoot.SelectNodes('pos_sale_lines/pos_sale_line') do begin
            SaleLinePOS.Init;
            RecRef.GetTable(SaleLinePOS);
            Xml2RecRef(XmlElement, SaleLinePOSFieldBuffer, RecRef);
            RecRef.SetTable(SaleLinePOS);
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS.Insert(true);

            foreach XmlElement2 in XmlElement.SelectNodes('pos_info_transactions/pos_info_transaction') do begin
                POSInfoTransaction.Init;
                RecRef.GetTable(POSInfoTransaction);
                Xml2RecRef(XmlElement2, POSInfoTransactionFieldBuffer, RecRef);
                RecRef.SetTable(POSInfoTransaction);
                POSInfoTransaction."Register No." := SalePOS."Register No.";
                POSInfoTransaction."Sales Ticket No." := SalePOS."Sales Ticket No.";
                POSInfoTransaction."Sale Date" := SalePOS.Date;
                POSInfoTransaction.Insert(true);
            end;

            foreach XmlElement2 in XmlElement.SelectNodes('item_addons/item_addon') do begin
                NpIaSaleLinePOSAddOn.Init;
                RecRef.GetTable(NpIaSaleLinePOSAddOn);
                Xml2RecRef(XmlElement2, NpIaSaleLinePOSAddOnFieldBuffer, RecRef);
                RecRef.SetTable(NpIaSaleLinePOSAddOn);
                NpIaSaleLinePOSAddOn."Register No." := SalePOS."Register No.";
                NpIaSaleLinePOSAddOn."Sales Ticket No." := SalePOS."Sales Ticket No.";
                NpIaSaleLinePOSAddOn."Sale Date" := SalePOS.Date;
                NpIaSaleLinePOSAddOn.Insert(true);
            end;

            foreach XmlElement2 in XmlElement.SelectNodes('retail_vouchers/retail_voucher') do begin
                NpRvSalesLine.Init;
                RecRef.GetTable(NpRvSalesLine);
                Xml2RecRef(XmlElement2, NpRvSalesLineFieldBuffer, RecRef);
                RecRef.SetTable(NpRvSalesLine);
                NpRvSalesLine."Retail ID" := SaleLinePOS."Retail ID";
                NpRvSalesLine."Register No." := SalePOS."Register No.";
                NpRvSalesLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
                NpRvSalesLine."Sale Date" := SalePOS.Date;
                NpRvSalesLine.Insert(true);

                foreach XmlElement3 in XmlElement2.SelectNodes('references/reference') do begin
                    NpRvSalesLineReference.Init;
                    RecRef.GetTable(NpRvSalesLineReference);
                    Xml2RecRef(XmlElement2, NpRvSalesLineReferenceFieldBuffer, RecRef);
                    RecRef.SetTable(NpRvSalesLineReference);
                    NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
                    NpRvSalesLineReference.Id := NpRvSalesLine."Register No.";
                    NpRvSalesLineReference.Insert(true);
                end;
            end;

            foreach XmlElement2 in XmlElement.SelectNodes('discount_coupons/discount_coupon') do begin
                NpDcSaleLinePOSCoupon.Init;
                RecRef.GetTable(NpDcSaleLinePOSCoupon);
                Xml2RecRef(XmlElement2, NpDcSaleLinePOSCouponFieldBuffer, RecRef);
                RecRef.SetTable(NpDcSaleLinePOSCoupon);
                NpDcSaleLinePOSCoupon."Register No." := SalePOS."Register No.";
                NpDcSaleLinePOSCoupon."Sales Ticket No." := SalePOS."Sales Ticket No.";
                NpDcSaleLinePOSCoupon."Sale Date" := SalePOS.Date;
                NpDcSaleLinePOSCoupon.Insert(true);
            end;

            foreach XmlElement2 in XmlElement.SelectNodes('new_discount_coupons/new_discount_coupon') do begin
                NpDcSaleLinePOSNewCoupon.Init;
                RecRef.GetTable(NpDcSaleLinePOSNewCoupon);
                Xml2RecRef(XmlElement2, NpDcSaleLinePOSNewCouponFieldBuffer, RecRef);
                RecRef.SetTable(NpDcSaleLinePOSNewCoupon);
                NpDcSaleLinePOSNewCoupon."Register No." := SalePOS."Register No.";
                NpDcSaleLinePOSNewCoupon."Sales Ticket No." := SalePOS."Sales Ticket No.";
                NpDcSaleLinePOSNewCoupon."Sale Date" := SalePOS.Date;
                NpDcSaleLinePOSNewCoupon.Insert(true);
            end;

            foreach XmlElement2 in XmlElement.SelectNodes('retail_cross_references/retail_cross_reference') do begin
                RetailCrossReference.Init;
                RecRef.GetTable(RetailCrossReference);
                Xml2RecRef(XmlElement2, RetailCrossReferenceFieldBuffer, RecRef);
                RecRef.SetTable(RetailCrossReference);
                Position := StrPos(RetailCrossReference."Record Value", '_');
                if Position <> 0 then
                    RetailCrossReference."Record Value" := StrSubstNo('%1_%2', SalePOS."Sales Ticket No.", CopyStr(RetailCrossReference."Record Value", Position + 1))
                else
                    RetailCrossReference."Record Value" := SalePOS."Sales Ticket No.";
                RetailCrossReference.Insert(true);
            end;

            OnXml2POSSaleLine(XmlElement, SaleLinePOS);
        end;
    end;

    local procedure Xml2RecRef(XmlElement: DotNet NPRNetXmlElement; var TempField: Record "Field" temporary; var RecRef: RecordRef)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlElement2: DotNet NPRNetXmlElement;
    begin
        if not TempField.FindSet then
            exit;
        if NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'table_no', false) <> Format(RecRef.Number, 0, 9) then
            exit;

        repeat
            if NpXmlDomMgt.FindNode(XmlElement, 'fields/field[@field_no = ' + Format(TempField."No.", 0, 9) + ']', XmlElement2) then
                Xml2Field(XmlElement2, TempField, RecRef);
        until TempField.Next = 0;
    end;

    local procedure Xml2Field(XmlElement: DotNet NPRNetXmlElement; "Field": Record "Field"; var RecRef: RecordRef)
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
                    if Evaluate(BigIntegerValue, XmlElement.InnerText, 9) then
                        FieldRef.Value := BigIntegerValue;
                end;
            Field.Type::Boolean:
                begin
                    if Evaluate(BooleanValue, XmlElement.InnerText, 9) then
                        FieldRef.Value := BooleanValue;
                end;
            Field.Type::Date:
                begin
                    if Evaluate(DateValue, XmlElement.InnerText, 9) then
                        FieldRef.Value := DateValue;
                end;
            Field.Type::DateFormula:
                begin
                    if Evaluate(DateFormulaValue, XmlElement.InnerText, 9) then
                        FieldRef.Value := DateFormulaValue;
                end;
            Field.Type::DateTime:
                begin
                    if Evaluate(DateTimeValue, XmlElement.InnerText, 9) then
                        FieldRef.Value := DateTimeValue;
                end;
            Field.Type::Decimal:
                begin
                    if Evaluate(DecimalValue, XmlElement.InnerText, 9) then
                        FieldRef.Value := DecimalValue;
                end;
            Field.Type::Duration:
                begin
                    if Evaluate(DurationValue, XmlElement.InnerText, 9) then
                        FieldRef.Value := DurationValue;
                end;
            Field.Type::GUID:
                begin
                    if Evaluate(GUIDValue, XmlElement.InnerText, 9) then
                        FieldRef.Value := GUIDValue;
                end;
            Field.Type::Integer, Field.Type::Option:
                begin
                    if Evaluate(IntegerValue, XmlElement.InnerText, 9) then
                        FieldRef.Value := IntegerValue;
                end;
            Field.Type::RecordID:
                begin
                    if Evaluate(RecordIDValue, XmlElement.InnerText) then
                        FieldRef.Value := RecordIDValue;
                end;
            Field.Type::Time:
                begin
                    if Evaluate(TimeValue, XmlElement.InnerText) then
                        FieldRef.Value := TimeValue;
                end;
            Field.Type::Code:
                begin
                    TextValue := UpperCase(CopyStr(XmlElement.InnerText, 1, FieldRef.Length));
                    FieldRef.Value := TextValue;
                end;
            Field.Type::Text:
                begin
                    TextValue := CopyStr(XmlElement.InnerText, 1, FieldRef.Length);
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

    local procedure OnPOSSale2Xml(SalePOS: Record "NPR Sale POS"; XmlRoot: DotNet NPRNetXmlElement)
    begin
    end;

    local procedure OnPOSSaleLine2Xml(SaleLinePOS: Record "NPR Sale Line POS"; XmlElement: DotNet NPRNetXmlElement)
    begin
    end;

    local procedure OnXml2POSSale(XmlRoot: DotNet NPRNetXmlElement; SalePOS: Record "NPR Sale POS")
    begin
    end;

    local procedure OnXml2POSSaleLine(XmlElement: DotNet NPRNetXmlElement; SaleLinePOS: Record "NPR Sale Line POS")
    begin
    end;
}