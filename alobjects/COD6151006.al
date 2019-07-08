codeunit 6151006 "POS Quote Mgt."
{
    // NPR5.48/MHA /20181115  CASE 334633 Object created
    // NPR5.48/MHA /20181130  CASE 338208 Added POS Sales Data (.xml) functionality to fully back/restore POS Sale


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Delete all saved POS Quotes,Terminate/Delete saved POS Quotes manually';

    procedure CleanupPOSQuotes(SalePOS: Record "Sale POS") Confirmed: Boolean
    var
        POSQuoteEntry: Record "POS Quote Entry";
        SelectedMenu: Integer;
    begin
        if not GuiAllowed then
          exit(true);

        SetSalePOSFilter(SalePOS,POSQuoteEntry);
        if not POSQuoteEntry.FindFirst then
          exit(true);

        Confirmed := false;
        SelectedMenu := StrMenu(Text000,1);
        case SelectedMenu of
          1:
            begin
              Confirmed := true;
              POSQuoteEntry.DeleteAll(true);
            end;
          2:
            begin
              Confirmed := PAGE.RunModal(0,POSQuoteEntry) = ACTION::LookupOK;
            end;
        end;

        exit(Confirmed);
    end;

    procedure SetSalePOSFilter(SalePOS: Record "Sale POS";var POSQuoteEntry: Record "POS Quote Entry")
    var
        RetailSetup: Record "Retail Setup";
    begin
        Clear(POSQuoteEntry);
        POSQuoteEntry.FilterGroup(40);
        RetailSetup.Get;
        case RetailSetup."Show saved expeditions" of
          RetailSetup."Show saved expeditions"::Register:
            begin
              POSQuoteEntry.SetRange("Register No.",SalePOS."Register No.");
            end;
          RetailSetup."Show saved expeditions"::Salesperson:
            begin
              POSQuoteEntry.SetRange("Salesperson Code",SalePOS."Salesperson Code");
            end;
          RetailSetup."Show saved expeditions"::"Register+Salesperson":
            begin
              POSQuoteEntry.SetRange("Salesperson Code",SalePOS."Salesperson Code");
              POSQuoteEntry.SetRange("Register No.",SalePOS."Register No.");
            end;
        end;
        POSQuoteEntry.FilterGroup(0);
    end;

    procedure POSSale2Xml(SalePOS: Record "Sale POS";var XmlDoc: DotNet XmlDocument)
    var
        NpDcSaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
        NpDcSaleLinePOSNewCoupon: Record "NpDc Sale Line POS New Coupon";
        NpIaSaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
        NpRvSaleLinePOSReference: Record "NpRv Sale Line POS Reference";
        NpRvSaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        POSInfoTransaction: Record "POS Info Transaction";
        SaleLinePOS: Record "Sale Line POS";
        NpDcSaleLinePOSNewCouponFieldBuffer: Record "Field" temporary;
        NpDcSaleLinePOSCouponFieldBuffer: Record "Field" temporary;
        NpIaSaleLinePOSAddOnFieldBuffer: Record "Field" temporary;
        NpRvSaleLinePOSReferenceFieldBuffer: Record "Field" temporary;
        NpRvSaleLinePOSVoucherFieldBuffer: Record "Field" temporary;
        POSInfoTransactionFieldBuffer: Record "Field" temporary;
        SalePOSFieldBuffer: Record "Field" temporary;
        SaleLinePOSFieldBuffer: Record "Field" temporary;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlRoot: DotNet XmlElement;
        XmlElement: DotNet XmlElement;
        XmlElement2: DotNet XmlElement;
        XmlElement3: DotNet XmlElement;
        XmlElement4: DotNet XmlElement;
        RecRef: RecordRef;
    begin
        //-NPR5.48 [338208]
        RecRef.GetTable(SalePOS);
        FindFields(RecRef,false,SalePOSFieldBuffer);

        RecRef.GetTable(SaleLinePOS);
        FindFields(RecRef,false,SaleLinePOSFieldBuffer);

        RecRef.GetTable(POSInfoTransaction);
        FindFields(RecRef,false,POSInfoTransactionFieldBuffer);

        RecRef.GetTable(NpIaSaleLinePOSAddOn);
        FindFields(RecRef,false,NpIaSaleLinePOSAddOnFieldBuffer);

        RecRef.GetTable(NpRvSaleLinePOSVoucher);
        FindFields(RecRef,false,NpRvSaleLinePOSVoucherFieldBuffer);

        RecRef.GetTable(NpRvSaleLinePOSReference);
        FindFields(RecRef,false,NpRvSaleLinePOSReferenceFieldBuffer);

        RecRef.GetTable(NpDcSaleLinePOSCoupon);
        FindFields(RecRef,false,NpDcSaleLinePOSCouponFieldBuffer);

        RecRef.GetTable(NpDcSaleLinePOSNewCoupon);
        FindFields(RecRef,false,NpDcSaleLinePOSNewCouponFieldBuffer);

        NpXmlDomMgt.InitDoc(XmlDoc,XmlRoot,'pos_sale');
        RecRef.GetTable(SalePOS);
        RecRef2Xml(RecRef,XmlRoot,SalePOSFieldBuffer);

        POSInfoTransaction.SetRange("Register No.",SalePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        POSInfoTransaction.SetFilter("Sales Line No.",'=%1',0);
        if POSInfoTransaction.FindSet then begin
          NpXmlDomMgt.AddElement(XmlRoot,'pos_info_transactions',XmlElement);
          repeat
            NpXmlDomMgt.AddElement(XmlElement,'pos_info_transaction',XmlElement2);
            RecRef.GetTable(POSInfoTransaction);
            RecRef2Xml(RecRef,XmlElement2,POSInfoTransactionFieldBuffer);
          until POSInfoTransaction.Next = 0;
        end;

        OnPOSSale2Xml(SalePOS,XmlRoot);

        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet then begin
          NpXmlDomMgt.AddElement(XmlRoot,'pos_sale_lines',XmlElement);
          repeat
            NpXmlDomMgt.AddElement(XmlElement,'pos_sale_line',XmlElement2);
            RecRef.GetTable(SaleLinePOS);
            RecRef2Xml(RecRef,XmlElement2,SaleLinePOSFieldBuffer);

            POSInfoTransaction.SetRange("Register No.",SalePOS."Register No.");
            POSInfoTransaction.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
            POSInfoTransaction.SetRange("Sales Line No.",SaleLinePOS."Line No.");
            if POSInfoTransaction.FindSet then begin
              NpXmlDomMgt.AddElement(XmlElement2,'pos_info_transactions',XmlElement3);
              repeat
                NpXmlDomMgt.AddElement(XmlElement3,'pos_info_transaction',XmlElement4);
                RecRef.GetTable(POSInfoTransaction);
                RecRef2Xml(RecRef,XmlElement4,POSInfoTransactionFieldBuffer);
              until POSInfoTransaction.Next = 0;
            end;

            NpIaSaleLinePOSAddOn.SetRange("Register No.",SaleLinePOS."Register No.");
            NpIaSaleLinePOSAddOn.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
            NpIaSaleLinePOSAddOn.SetRange("Sale Type",SaleLinePOS."Sale Type");
            NpIaSaleLinePOSAddOn.SetRange("Sale Date",SaleLinePOS.Date);
            NpIaSaleLinePOSAddOn.SetRange("Sale Line No.",SaleLinePOS."Line No.");
            if NpIaSaleLinePOSAddOn.FindSet then begin
              NpXmlDomMgt.AddElement(XmlElement2,'item_addons',XmlElement3);
              repeat
                NpXmlDomMgt.AddElement(XmlElement3,'item_addon',XmlElement4);
                RecRef.GetTable(NpIaSaleLinePOSAddOn);
                RecRef2Xml(RecRef,XmlElement4,NpIaSaleLinePOSAddOnFieldBuffer);
              until NpIaSaleLinePOSAddOn.Next = 0;
            end;

            NpRvSaleLinePOSVoucher.SetRange("Register No.",SaleLinePOS."Register No.");
            NpRvSaleLinePOSVoucher.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
            NpRvSaleLinePOSVoucher.SetRange("Sale Type",SaleLinePOS."Sale Type");
            NpRvSaleLinePOSVoucher.SetRange("Sale Date",SaleLinePOS.Date);
            NpRvSaleLinePOSVoucher.SetRange("Sale Line No.",SaleLinePOS."Line No.");
            if NpRvSaleLinePOSVoucher.FindSet then begin
              NpXmlDomMgt.AddElement(XmlElement2,'retail_vouchers',XmlElement3);
              repeat
                NpXmlDomMgt.AddElement(XmlElement3,'retail_voucher',XmlElement4);
                RecRef.GetTable(NpRvSaleLinePOSVoucher);
                RecRef2Xml(RecRef,XmlElement4,NpRvSaleLinePOSVoucherFieldBuffer);
              until NpRvSaleLinePOSVoucher.Next = 0;
            end;

            NpRvSaleLinePOSReference.SetRange("Register No.",SaleLinePOS."Register No.");
            NpRvSaleLinePOSReference.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
            NpRvSaleLinePOSReference.SetRange("Sale Type",SaleLinePOS."Sale Type");
            NpRvSaleLinePOSReference.SetRange("Sale Date",SaleLinePOS.Date);
            NpRvSaleLinePOSReference.SetRange("Sale Line No.",SaleLinePOS."Line No.");
            if NpRvSaleLinePOSReference.FindSet then begin
              NpXmlDomMgt.AddElement(XmlElement2,'retail_voucher_payments',XmlElement3);
              repeat
                NpXmlDomMgt.AddElement(XmlElement3,'retail_voucher_payment',XmlElement4);
                RecRef.GetTable(NpRvSaleLinePOSReference);
                RecRef2Xml(RecRef,XmlElement4,NpRvSaleLinePOSReferenceFieldBuffer);
              until NpRvSaleLinePOSReference.Next = 0;
            end;

            NpDcSaleLinePOSCoupon.SetRange("Register No.",SaleLinePOS."Register No.");
            NpDcSaleLinePOSCoupon.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
            NpDcSaleLinePOSCoupon.SetRange("Sale Type",SaleLinePOS."Sale Type");
            NpDcSaleLinePOSCoupon.SetRange("Sale Date",SaleLinePOS.Date);
            NpDcSaleLinePOSCoupon.SetRange("Sale Line No.",SaleLinePOS."Line No.");
            if NpDcSaleLinePOSCoupon.FindSet then begin
              NpXmlDomMgt.AddElement(XmlElement2,'discount_coupons',XmlElement3);
              repeat
                NpXmlDomMgt.AddElement(XmlElement3,'discount_coupon',XmlElement4);
                RecRef.GetTable(NpDcSaleLinePOSCoupon);
                RecRef2Xml(RecRef,XmlElement4,NpDcSaleLinePOSCouponFieldBuffer);
              until NpDcSaleLinePOSCoupon.Next = 0;
            end;

            NpDcSaleLinePOSNewCoupon.SetRange("Register No.",SaleLinePOS."Register No.");
            NpDcSaleLinePOSNewCoupon.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
            NpDcSaleLinePOSNewCoupon.SetRange("Sale Type",SaleLinePOS."Sale Type");
            NpDcSaleLinePOSNewCoupon.SetRange("Sale Date",SaleLinePOS.Date);
            NpDcSaleLinePOSNewCoupon.SetRange("Sale Line No.",SaleLinePOS."Line No.");
            if NpDcSaleLinePOSNewCoupon.FindSet then begin
              NpXmlDomMgt.AddElement(XmlElement2,'new_discount_coupons',XmlElement3);
              repeat
                NpXmlDomMgt.AddElement(XmlElement3,'new_discount_coupon',XmlElement4);
                RecRef.GetTable(NpDcSaleLinePOSNewCoupon);
                RecRef2Xml(RecRef,XmlElement4,NpDcSaleLinePOSNewCouponFieldBuffer);
              until NpDcSaleLinePOSNewCoupon.Next = 0;
            end;

            OnPOSSaleLine2Xml(SaleLinePOS,XmlElement);
          until SaleLinePOS.Next = 0;
        end;
        //+NPR5.48 [338208]
    end;

    local procedure RecRef2Xml(RecRef: RecordRef;XmlElement: DotNet XmlElement;var TempField: Record "Field" temporary)
    var
        XmlElement2: DotNet XmlElement;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        //-NPR5.48 [338208]
        NpXmlDomMgt.AddAttribute(XmlElement,'table_no',Format(RecRef.Number,0,9));
        NpXmlDomMgt.AddElement(XmlElement,'fields',XmlElement2);
        if TempField.FindSet then
          repeat
            Field2Xml(RecRef,TempField,XmlElement2);
          until TempField.Next = 0;
        //+NPR5.48 [338208]
    end;

    local procedure FindFields(RecRef: RecordRef;ExclKeyField: Boolean;var TempField: Record "Field" temporary)
    var
        "Field": Record "Field";
        KeyFieldBuffer: Record "Field" temporary;
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        i: Integer;
    begin
        //-NPR5.48 [338208]
        if not TempField.IsTemporary then begin
          TempField.SetFilter("No.",'=%1&<>%1',1);
          exit;
        end;

        if ExclKeyField then begin
          KeyRef := RecRef.KeyIndex(1);
          for i := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(i);
            Field.Get(RecRef.Number,FieldRef.Number);
            KeyFieldBuffer.Init;
            KeyFieldBuffer := Field;
            KeyFieldBuffer.Insert;
          end;
        end;

        Clear(TempField);
        TempField.DeleteAll;
        Field.SetRange(TableNo,RecRef.Number);
        Field.SetRange(Class,Field.Class::Normal);
        Field.SetRange(Enabled,true);
        if not Field.FindSet then
          exit;

        repeat
          if (not ExclKeyField) or (not KeyFieldBuffer.Get(Field.TableNo,Field."No.")) then begin
            TempField.Init;
            TempField := Field;
            TempField.Insert;
          end;
        until Field.Next = 0;
        //+NPR5.48 [338208]
    end;

    local procedure Field2Xml(RecRef: RecordRef;"Field": Record "Field";var XmlElement: DotNet XmlElement)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlCDATA: DotNet XmlCDataSection;
        XmlElement2: DotNet XmlElement;
        FieldValue: Text;
    begin
        //-NPR5.48 [338208]
        if not GetFieldValue(RecRef,Field,FieldValue) then
          exit;

        NpXmlDomMgt.AddElement(XmlElement,'field',XmlElement2);
        NpXmlDomMgt.AddAttribute(XmlElement2,'field_no',Format(Field."No.",0,9));
        XmlCDATA := XmlElement2.OwnerDocument.CreateCDataSection('');
        XmlElement2.AppendChild(XmlCDATA);
        XmlCDATA.AppendData(FieldValue);
        //+NPR5.48 [338208]
    end;

    local procedure GetFieldValue(RecRef: RecordRef;"Field": Record "Field";var FieldValue: Text): Boolean
    var
        FieldRef: FieldRef;
    begin
        //-NPR5.48 [338208]
        FieldRef := RecRef.Field(Field."No.");
        case Field.Type of
          Field.Type::BigInteger,Field.Type::Boolean,Field.Type::Date,Field.Type::DateFormula,Field.Type::DateTime,Field.Type::Decimal,
          Field.Type::Duration,Field.Type::GUID,Field.Type::Integer,Field.Type::RecordID,Field.Type::Time:
            begin
              FieldValue := Format(FieldRef.Value,0,9);
              exit(true);
            end;
          Field.Type::Option:
            begin
              FieldValue := Format(FieldRef.Value,0,2);
              exit(true);
            end;
          Field.Type::Code,Field.Type::Text:
            begin
              FieldValue := Format(FieldRef.Value);
              exit(true);
            end;
        end;

        exit(false);
        //+NPR5.48 [338208]
    end;

    procedure LoadPOSSaleData(POSQuoteEntry: Record "POS Quote Entry";var XmlDoc: DotNet XmlDocument): Boolean
    var
        InStr: InStream;
    begin
        //-NPR5.48 [338208]
        if not POSQuoteEntry."POS Sales Data".HasValue then
          exit(false);
        POSQuoteEntry.CalcFields("POS Sales Data");
        POSQuoteEntry."POS Sales Data".CreateInStream(InStr,TEXTENCODING::UTF8);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStr);
        exit(not IsNull(XmlDoc));
        //+NPR5.48 [338208]
    end;

    procedure Xml2POSSale(var XmlDoc: DotNet XmlDocument;var SalePOS: Record "Sale POS")
    var
        NpDcSaleLinePOSCoupon: Record "NpDc Sale Line POS Coupon";
        NpDcSaleLinePOSNewCoupon: Record "NpDc Sale Line POS New Coupon";
        NpIaSaleLinePOSAddOn: Record "NpIa Sale Line POS AddOn";
        NpRvSaleLinePOSReference: Record "NpRv Sale Line POS Reference";
        NpRvSaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        POSInfoTransaction: Record "POS Info Transaction";
        SaleLinePOS: Record "Sale Line POS";
        NpDcSaleLinePOSNewCouponFieldBuffer: Record "Field" temporary;
        NpDcSaleLinePOSCouponFieldBuffer: Record "Field" temporary;
        NpIaSaleLinePOSAddOnFieldBuffer: Record "Field" temporary;
        NpRvSaleLinePOSReferenceFieldBuffer: Record "Field" temporary;
        NpRvSaleLinePOSVoucherFieldBuffer: Record "Field" temporary;
        POSInfoTransactionFieldBuffer: Record "Field" temporary;
        SalePOSFieldBuffer: Record "Field" temporary;
        SaleLinePOSFieldBuffer: Record "Field" temporary;
        XmlElement: DotNet XmlElement;
        XmlElement2: DotNet XmlElement;
        XmlRoot: DotNet XmlElement;
        RecRef: RecordRef;
        PrevRec: Text;
    begin
        //-NPR5.48 [338208]
        if IsNull(XmlDoc) then
          exit;
        XmlRoot := XmlDoc.DocumentElement;
        if IsNull(XmlRoot) then
          exit;
        if XmlRoot.Name <> 'pos_sale' then
          exit;

        RecRef.GetTable(SalePOS);
        FindFields(RecRef,true,SalePOSFieldBuffer);
        if SalePOSFieldBuffer.Get(RecRef.Number,SalePOS.FieldNo("POS Sale ID")) then
          SalePOSFieldBuffer.Delete;

        RecRef.GetTable(SaleLinePOS);
        FindFields(RecRef,false,SaleLinePOSFieldBuffer);

        RecRef.GetTable(POSInfoTransaction);
        FindFields(RecRef,false,POSInfoTransactionFieldBuffer);

        RecRef.GetTable(NpIaSaleLinePOSAddOn);
        FindFields(RecRef,false,NpIaSaleLinePOSAddOnFieldBuffer);

        RecRef.GetTable(NpRvSaleLinePOSVoucher);
        FindFields(RecRef,false,NpRvSaleLinePOSVoucherFieldBuffer);

        RecRef.GetTable(NpRvSaleLinePOSReference);
        FindFields(RecRef,false,NpRvSaleLinePOSReferenceFieldBuffer);

        RecRef.GetTable(NpDcSaleLinePOSCoupon);
        FindFields(RecRef,false,NpDcSaleLinePOSCouponFieldBuffer);

        RecRef.GetTable(NpDcSaleLinePOSNewCoupon);
        FindFields(RecRef,false,NpDcSaleLinePOSNewCouponFieldBuffer);

        RecRef.GetTable(SalePOS);
        PrevRec := Format(RecRef);
        Xml2RecRef(XmlRoot,SalePOSFieldBuffer,RecRef);
        if PrevRec <>  Format(RecRef) then
          RecRef.Modify(true);
        RecRef.SetTable(SalePOS);
        foreach XmlElement in XmlRoot.SelectNodes('pos_info_transactions/pos_info_transaction') do begin
          POSInfoTransaction.Init;
          RecRef.GetTable(POSInfoTransaction);
          Xml2RecRef(XmlElement,POSInfoTransactionFieldBuffer,RecRef);
          RecRef.SetTable(POSInfoTransaction);
          POSInfoTransaction."Register No." := SalePOS."Register No.";
          POSInfoTransaction."Sales Ticket No." := SalePOS."Sales Ticket No.";
          POSInfoTransaction."Sales Line No." := 0;
          POSInfoTransaction.Insert(true);
        end;

        OnXml2POSSale(XmlRoot,SalePOS);

        foreach XmlElement in XmlRoot.SelectNodes('pos_sale_lines/pos_sale_line') do begin
          SaleLinePOS.Init;
          RecRef.GetTable(SaleLinePOS);
          Xml2RecRef(XmlElement,SaleLinePOSFieldBuffer,RecRef);
          RecRef.SetTable(SaleLinePOS);
          SaleLinePOS."Register No." := SalePOS."Register No.";
          SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
          SaleLinePOS.Insert(true);

          foreach XmlElement2 in XmlElement.SelectNodes('pos_info_transactions/pos_info_transaction') do begin
            POSInfoTransaction.Init;
            RecRef.GetTable(POSInfoTransaction);
            Xml2RecRef(XmlElement2,POSInfoTransactionFieldBuffer,RecRef);
            RecRef.SetTable(POSInfoTransaction);
            POSInfoTransaction."Register No." := SalePOS."Register No.";
            POSInfoTransaction."Sales Ticket No." := SalePOS."Sales Ticket No.";
            POSInfoTransaction.Insert(true);
          end;

          foreach XmlElement2 in XmlElement.SelectNodes('item_addons/item_addon') do begin
            NpIaSaleLinePOSAddOn.Init;
            RecRef.GetTable(NpIaSaleLinePOSAddOn);
            Xml2RecRef(XmlElement2,NpIaSaleLinePOSAddOnFieldBuffer,RecRef);
            RecRef.SetTable(NpIaSaleLinePOSAddOn);
            NpIaSaleLinePOSAddOn."Register No." := SalePOS."Register No.";
            NpIaSaleLinePOSAddOn."Sales Ticket No." := SalePOS."Sales Ticket No.";
            NpIaSaleLinePOSAddOn.Insert(true);
          end;

          foreach XmlElement2 in XmlElement.SelectNodes('retail_vouchers/retail_voucher') do begin
            NpRvSaleLinePOSVoucher.Init;
            RecRef.GetTable(NpRvSaleLinePOSVoucher);
            Xml2RecRef(XmlElement2,NpRvSaleLinePOSVoucherFieldBuffer,RecRef);
            RecRef.SetTable(NpRvSaleLinePOSVoucher);
            NpRvSaleLinePOSVoucher."Register No." := SalePOS."Register No.";
            NpRvSaleLinePOSVoucher."Sales Ticket No." := SalePOS."Sales Ticket No.";
            NpRvSaleLinePOSVoucher.Insert(true);
          end;

          foreach XmlElement2 in XmlElement.SelectNodes('retail_voucher_payments/retail_voucher_payment') do begin
            NpRvSaleLinePOSReference.Init;
            RecRef.GetTable(NpRvSaleLinePOSReference);
            Xml2RecRef(XmlElement2,NpRvSaleLinePOSReferenceFieldBuffer,RecRef);
            RecRef.SetTable(NpRvSaleLinePOSReference);
            NpRvSaleLinePOSReference."Register No." := SalePOS."Register No.";
            NpRvSaleLinePOSReference."Sales Ticket No." := SalePOS."Sales Ticket No.";
            NpRvSaleLinePOSReference.Insert(true);
          end;

          foreach XmlElement2 in XmlElement.SelectNodes('discount_coupons/discount_coupon') do begin
            NpDcSaleLinePOSCoupon.Init;
            RecRef.GetTable(NpDcSaleLinePOSCoupon);
            Xml2RecRef(XmlElement2,NpDcSaleLinePOSCouponFieldBuffer,RecRef);
            RecRef.SetTable(NpDcSaleLinePOSCoupon);
            NpDcSaleLinePOSCoupon."Register No." := SalePOS."Register No.";
            NpDcSaleLinePOSCoupon."Sales Ticket No." := SalePOS."Sales Ticket No.";
            NpDcSaleLinePOSCoupon.Insert(true);
          end;

          foreach XmlElement2 in XmlElement.SelectNodes('new_discount_coupons/new_discount_coupon') do begin
            NpDcSaleLinePOSNewCoupon.Init;
            RecRef.GetTable(NpDcSaleLinePOSNewCoupon);
            Xml2RecRef(XmlElement2,NpDcSaleLinePOSNewCouponFieldBuffer,RecRef);
            RecRef.SetTable(NpDcSaleLinePOSNewCoupon);
            NpDcSaleLinePOSNewCoupon."Register No." := SalePOS."Register No.";
            NpDcSaleLinePOSNewCoupon."Sales Ticket No." := SalePOS."Sales Ticket No.";
            NpDcSaleLinePOSNewCoupon.Insert(true);
          end;

          OnXml2POSSaleLine(XmlElement,SaleLinePOS);
        end;
        //+NPR5.48 [338208]
    end;

    local procedure Xml2RecRef(XmlElement: DotNet XmlElement;var TempField: Record "Field" temporary;var RecRef: RecordRef)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement2: DotNet XmlElement;
    begin
        //-NPR5.48 [338208]
        if not TempField.FindSet then
          exit;
        if NpXmlDomMgt.GetXmlAttributeText(XmlElement,'table_no',false) <> Format(RecRef.Number,0,9) then
          exit;

        repeat
          if NpXmlDomMgt.FindNode(XmlElement,'fields/field[@field_no = ' + Format(TempField."No.",0,9) + ']',XmlElement2) then
            Xml2Field(XmlElement2,TempField,RecRef);
        until TempField.Next = 0;
        //+NPR5.48 [338208]
    end;

    local procedure Xml2Field(XmlElement: DotNet XmlElement;"Field": Record "Field";var RecRef: RecordRef)
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
        //-NPR5.48 [338208]
        FieldRef := RecRef.Field(Field."No.");
        case Field.Type of
          Field.Type::BigInteger:
            begin
              if Evaluate(BigIntegerValue,XmlElement.InnerText,9) then
                FieldRef.Value := BigIntegerValue;
            end;
          Field.Type::Boolean:
            begin
              if Evaluate(BooleanValue,XmlElement.InnerText,9) then
                FieldRef.Value := BooleanValue;
            end;
          Field.Type::Date:
            begin
              if Evaluate(DateValue,XmlElement.InnerText,9) then
                FieldRef.Value := DateValue;
            end;
          Field.Type::DateFormula:
            begin
              if Evaluate(DateFormulaValue,XmlElement.InnerText,9) then
                FieldRef.Value := DateFormulaValue;
            end;
          Field.Type::DateTime:
            begin
              if Evaluate(DateTimeValue,XmlElement.InnerText,9) then
                FieldRef.Value := DateTimeValue;
            end;
          Field.Type::Decimal:
            begin
              if Evaluate(DecimalValue,XmlElement.InnerText,9) then
                FieldRef.Value := DecimalValue;
            end;
          Field.Type::Duration:
            begin
              if Evaluate(DurationValue,XmlElement.InnerText,9) then
                FieldRef.Value := DurationValue;
            end;
          Field.Type::GUID:
            begin
              if Evaluate(GUIDValue,XmlElement.InnerText,9) then
                FieldRef.Value := GUIDValue;
            end;
          Field.Type::Integer,Field.Type::Option:
            begin
              if Evaluate(IntegerValue,XmlElement.InnerText,9) then
                FieldRef.Value := IntegerValue;
            end;
          Field.Type::RecordID:
            begin
              if Evaluate(RecordIDValue,XmlElement.InnerText) then
                FieldRef.Value := RecordIDValue;
            end;
          Field.Type::Time:
            begin
              if Evaluate(TimeValue,XmlElement.InnerText) then
                FieldRef.Value := TimeValue;
            end;
          Field.Type::Code:
            begin
              TextValue := UpperCase(CopyStr(XmlElement.InnerText,1,FieldRef.Length));
              FieldRef.Value := TextValue;
            end;
          Field.Type::Text:
            begin
              TextValue := CopyStr(XmlElement.InnerText,1,FieldRef.Length);
              FieldRef.Value := TextValue;
            end;
        end;
        //+NPR5.48 [338208]
    end;

    procedure ViewPOSSalesData(POSQuoteEntry: Record "POS Quote Entry")
    var
        TempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        StreamReader: DotNet StreamReader;
        POSSalesData: Text;
        InStr: InStream;
        Path: Text;
    begin
        //-NPR5.48 [338208]
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

        TempBlob.Blob := POSQuoteEntry."POS Sales Data";
        Path := FileMgt.BLOBExport(TempBlob,TemporaryPath + POSQuoteEntry."Sales Ticket No." + '.xml',false);
        HyperLink(Path);
        //+NPR5.48 [338208]
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        //-NPR5.48 [338208]
        if ActiveSession.Get(ServiceInstanceId,SessionId) then
          exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
        //+NPR5.48 [338208]
    end;

    local procedure OnPOSSale2Xml(SalePOS: Record "Sale POS";XmlRoot: DotNet XmlElement)
    begin
        //-NPR5.48 [338208]
        //+NPR5.48 [338208]
    end;

    local procedure OnPOSSaleLine2Xml(SaleLinePOS: Record "Sale Line POS";XmlElement: DotNet XmlElement)
    begin
        //-NPR5.48 [338208]
        //+NPR5.48 [338208]
    end;

    local procedure OnXml2POSSale(XmlRoot: DotNet XmlElement;SalePOS: Record "Sale POS")
    begin
        //-NPR5.48 [338208]
        //+NPR5.48 [338208]
    end;

    local procedure OnXml2POSSaleLine(XmlElement: DotNet XmlElement;SaleLinePOS: Record "Sale Line POS")
    begin
        //-NPR5.48 [338208]
        //+NPR5.48 [338208]
    end;
}

