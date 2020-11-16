xmlport 6151148 "NPR M2 Customer Item By Period"
{
    // NPR5.49/TSA /20190307 CASE 345375 Initial Version
    // MAG2.25/TSA /20200401 CASE 399020 Added a conditional filter for location code

    Caption = 'Customer Item By Period';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(CustomerItem)
        {
            tableelement(tmpdaterequest; Date)
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                fieldelement(PeriodStart; TmpDateRequest."Period Start")
                {
                }
                fieldelement(PeriodEnd; TmpDateRequest."Period End")
                {
                }
                textelement(ViewBy)
                {
                    MaxOccurs = Once;

                    trigger OnAfterAssignVariable()
                    begin

                        InvalidViewByOption := false;
                        case UpperCase(ViewBy) of
                            'DATE':
                                TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Date;
                            'WEEK':
                                TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Week;
                            'MONTH':
                                TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Month;
                            'QUARTER':
                                TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Quarter;
                            'YEAR':
                                TmpDateRequest."Period Type" := TmpDateRequest."Period Type"::Year;
                            else
                                InvalidViewByOption := true;
                        end;
                    end;
                }
                textelement(ViewAs)
                {
                    MaxOccurs = Once;

                    trigger OnAfterAssignVariable()
                    begin

                        case UpperCase(ViewAs) of
                            'NETCHANGE':
                                ViewAsOption := ViewAsOption::NETCHANGE;
                            'BALANCEATDATE':
                                ViewAsOption := ViewAsOption::BALANCEATDATE;
                            else
                                ViewAsOption := ViewAsOption::UNDEFINED;
                        end;
                    end;
                }
                textelement(Customer)
                {
                    MaxOccurs = Once;
                    textattribute(SellTo)
                    {
                    }
                }
                textelement(LocationCode)
                {
                    MaxOccurs = Once;
                }
                textelement(requestitems)
                {
                    MaxOccurs = Once;
                    XmlName = 'Items';
                    tableelement(tmpitemrequest; "Item Cross Reference")
                    {
                        XmlName = 'Item';
                        UseTemporary = true;
                        fieldattribute(ItemNumber; TmpItemRequest."Item No.")
                        {
                        }
                        fieldattribute(VariantCode; TmpItemRequest."Variant Code")
                        {
                        }
                    }
                }
            }
            textelement(Response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(Status)
                {
                    MaxOccurs = Once;
                    textelement(ResponseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ResponseMessage)
                    {
                        MaxOccurs = Once;
                    }
                }
                textelement(Items)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tmpitemresponse; "Item Cross Reference")
                    {
                        XmlName = 'Item';
                        UseTemporary = true;
                        fieldattribute(ItemNumber; TmpItemResponse."Item No.")
                        {
                        }
                        fieldattribute(VariantCode; TmpItemResponse."Variant Code")
                        {
                        }
                        tableelement(dateresponse; Date)
                        {
                            LinkTable = TmpItemResponse;
                            XmlName = 'Period';
                            fieldattribute(PeriodStart; DateResponse."Period Start")
                            {
                            }
                            fieldattribute(PeriodEnd; DateResponse."Period End")
                            {
                            }
                            fieldattribute(PeriodName; DateResponse."Period Name")
                            {
                            }
                            textelement(NotShipped)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                tableelement(tmpsalesline; "Sales Line")
                                {
                                    LinkTable = DateResponse;
                                    MinOccurs = Zero;
                                    XmlName = 'Type';
                                    UseTemporary = true;
                                    textattribute(notshippeddocytype)
                                    {
                                        XmlName = 'DocumentType';

                                        trigger OnBeforePassVariable()
                                        begin

                                            with TmpSalesLine do
                                                case TmpSalesLine."Document Type" of
                                                    "Document Type"::Quote:
                                                        NotShippedDocyType := 'quote';
                                                    "Document Type"::Order:
                                                        NotShippedDocyType := 'order';
                                                    "Document Type"::"Return Order":
                                                        NotShippedDocyType := 'returnorder';
                                                    "Document Type"::Invoice:
                                                        NotShippedDocyType := 'invoice';
                                                    "Document Type"::"Credit Memo":
                                                        NotShippedDocyType := 'creditmemo';
                                                    "Document Type"::"Blanket Order":
                                                        NotShippedDocyType := 'blanketorder';
                                                    else
                                                        NotShippedDocyType := 'uncategorized';
                                                end;
                                        end;
                                    }
                                    textattribute(outstandingqty)
                                    {
                                        XmlName = 'Quantity';

                                        trigger OnBeforePassVariable()
                                        begin

                                            OutstandingQty := Format(Abs(TmpSalesLine."Outstanding Quantity"), 0, 9);
                                        end;
                                    }
                                    textattribute(outstandingamt)
                                    {
                                        XmlName = 'AmountLCY';

                                        trigger OnBeforePassVariable()
                                        begin

                                            OutstandingAmt := Format(Abs(TmpSalesLine."Outstanding Amount (LCY)"), 0, 9);
                                        end;
                                    }
                                }

                                trigger OnBeforePassVariable()
                                begin

                                    if (TmpSalesLine.IsEmpty()) then currXMLport.Skip;
                                end;
                            }
                            textelement(Shipped)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                tableelement(tmpitemledgerentry; "Item Ledger Entry")
                                {
                                    LinkTable = DateResponse;
                                    MaxOccurs = Unbounded;
                                    MinOccurs = Zero;
                                    XmlName = 'Type';
                                    UseTemporary = true;
                                    textattribute(shippeddoctype)
                                    {
                                        XmlName = 'DocumentType';

                                        trigger OnBeforePassVariable()
                                        begin

                                            with TmpItemLedgerEntry do
                                                case "Document Type" of
                                                    "Document Type"::"Sales Shipment":
                                                        ShippedDocType := 'shipment';
                                                    "Document Type"::"Sales Return Receipt":
                                                        ShippedDocType := 'return';
                                                    "Document Type"::"Sales Invoice":
                                                        ShippedDocType := 'invoice';
                                                    "Document Type"::"Sales Credit Memo":
                                                        ShippedDocType := 'creditmemo';
                                                    else
                                                        ShippedDocType := 'uncategorized';
                                                end;
                                        end;
                                    }
                                    textattribute(qtyshipped)
                                    {
                                        XmlName = 'Quantity';

                                        trigger OnBeforePassVariable()
                                        begin

                                            QtyShipped := Format(Abs(TmpItemLedgerEntry.Quantity), 0, 9);
                                        end;
                                    }
                                    textattribute(amtshipped)
                                    {
                                        XmlName = 'AmountLCY';

                                        trigger OnBeforePassVariable()
                                        begin

                                            AmtShipped := Format(Abs(AmountShippedArray[TmpItemLedgerEntry."Document Type".AsInteger()]), 0, 9);
                                        end;
                                    }
                                }

                                trigger OnBeforePassVariable()
                                begin
                                    if (TmpItemLedgerEntry.IsEmpty()) then currXMLport.Skip;
                                end;
                            }
                            textelement(Invoiced)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                tableelement(tmpvalueentry; "Value Entry")
                                {
                                    LinkTable = DateResponse;
                                    MinOccurs = Zero;
                                    XmlName = 'Type';
                                    UseTemporary = true;
                                    textattribute(invoiceddoctype)
                                    {
                                        XmlName = 'DocumentType';

                                        trigger OnBeforePassVariable()
                                        begin

                                            with TmpValueEntry do
                                                case "Document Type" of
                                                    "Document Type"::"Sales Invoice":
                                                        InvoicedDocType := 'invoice';
                                                    "Document Type"::"Sales Credit Memo":
                                                        InvoicedDocType := 'creditmemo';
                                                    else
                                                        InvoicedDocType := 'uncategorized';
                                                end;
                                        end;
                                    }
                                    textattribute(qtyinvoiced)
                                    {
                                        XmlName = 'Quantity';

                                        trigger OnBeforePassVariable()
                                        begin

                                            QtyInvoiced := Format(Abs(TmpValueEntry."Invoiced Quantity"), 0, 9);
                                        end;
                                    }
                                    textattribute(amtinvoiced)
                                    {
                                        XmlName = 'AmountLCY';

                                        trigger OnBeforePassVariable()
                                        begin

                                            AmtInvoiced := Format(Abs(TmpValueEntry."Sales Amount (Actual)"), 0, 9);
                                        end;
                                    }
                                }

                                trigger OnBeforePassVariable()
                                begin

                                    if (TmpValueEntry.IsEmpty()) then currXMLport.Skip;
                                end;
                            }

                            trigger OnAfterGetRecord()
                            var
                                PeriodStart: Date;
                            begin

                                PeriodStart := DateResponse."Period Start";
                                if (ViewAsOption = ViewAsOption::BALANCEATDATE) then
                                    PeriodStart := 0D;

                                with DateResponse do begin
                                    GetNotShippedItems(PeriodStart, "Period End", TmpItemResponse."Item No.", TmpItemResponse."Variant Code", LocationCode, SellTo);
                                    GetShippedItems(PeriodStart, "Period End", TmpItemResponse."Item No.", TmpItemResponse."Variant Code", LocationCode, SellTo);
                                    GetInvoicedItems(PeriodStart, "Period End", TmpItemResponse."Item No.", TmpItemResponse."Variant Code", LocationCode, SellTo);
                                end;
                            end;
                        }
                    }

                    trigger OnBeforePassVariable()
                    begin

                        TmpItemResponse.Reset();
                        if (TmpItemResponse.IsEmpty()) then currXMLport.Break;
                    end;
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

    trigger OnInitXmlPort()
    begin

        StartTime := Time
    end;

    var
        StartTime: Time;
        ViewAsOption: Option UNDEFINED,NETCHANGE,BALANCEATDATE;
        InvalidViewByOption: Boolean;
        AmountShippedArray: array[10] of Decimal;

    procedure ValidateRequest()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Location: Record Location;
        Customer: Record Customer;
        InvalidDate: Boolean;
        ItemExists: Boolean;
        PartialResult: Boolean;
        PeriodStart: Date;
        PeriodEnd: Date;
    begin

        if (TmpItemResponse.IsTemporary()) then
            TmpItemResponse.DeleteAll();

        TmpItemRequest.Reset;
        TmpItemRequest.FindSet();
        repeat
            TmpItemResponse.TransferFields(TmpItemRequest, true);

            ItemExists := Item.Get(TmpItemRequest."Item No.");
            if ((ItemExists) and (TmpItemRequest."Variant Code" <> '')) then
                ItemExists := ItemVariant.Get(TmpItemRequest."Item No.", TmpItemRequest."Variant Code");

            if (ItemExists) then
                TmpItemResponse.Insert();

            if (not ItemExists) then
                PartialResult := true;

        until (TmpItemRequest.Next() = 0);

        TmpDateRequest.FindFirst();
        InvalidDate := (TmpDateRequest."Period Start" = 0D) or (TmpDateRequest."Period End" = 0D);
        if (not InvalidDate) then begin

            // Align to first & last date within period
            case TmpDateRequest."Period Type" of
                TmpDateRequest."Period Type"::Date:
                    begin
                        PeriodStart := TmpDateRequest."Period Start";
                        PeriodEnd := TmpDateRequest."Period End";
                    end;
                TmpDateRequest."Period Type"::Week:
                    begin
                        PeriodStart := CalcDate('<-1W+CW+1D>', TmpDateRequest."Period Start");
                        PeriodEnd := CalcDate('<CW>', TmpDateRequest."Period End");
                    end;

                TmpDateRequest."Period Type"::Month:
                    begin
                        PeriodStart := CalcDate('<-1M+CM+1D>', TmpDateRequest."Period Start");
                        PeriodEnd := CalcDate('<CM>', TmpDateRequest."Period End");
                    end;

                TmpDateRequest."Period Type"::Quarter:
                    begin
                        PeriodStart := CalcDate('<-1Q+CQ+1D>', TmpDateRequest."Period Start");
                        PeriodEnd := CalcDate('<CQ>', TmpDateRequest."Period End");
                    end;
                TmpDateRequest."Period Type"::Year:
                    begin
                        PeriodStart := CalcDate('<-1Y+CY+1D>', TmpDateRequest."Period Start");
                        PeriodEnd := CalcDate('<CY>', TmpDateRequest."Period End");
                    end;
            end;
            TmpDateRequest."Period Start" := PeriodStart;
            TmpDateRequest."Period End" := PeriodEnd;

            DateResponse.SetFilter("Period Start", '%1..%2', TmpDateRequest."Period Start", TmpDateRequest."Period End");
            DateResponse.SetFilter("Period Type", '=%1', TmpDateRequest."Period Type");

        end;

        ResponseCode := 'OK';
        ResponseMessage := '';

        if (PartialResult) then begin
            ResponseCode := 'WARNING';
            ResponseMessage := 'Partial result, some items were not found.'
        end;

        if (LocationCode <> '') and (not Location.Get(LocationCode)) then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Invalid location code.'
        end;

        if (SellTo <> '') and (not Customer.Get(SellTo)) then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Invalid SellTo Customer Code.'
        end;

        if (InvalidDate) then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Period date range is invalid.'
        end;

        if (TmpDateRequest."Period End" < TmpDateRequest."Period Start") or (TmpDateRequest."Period Start" > TmpDateRequest."Period End") then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Period date range is invalid.'
        end;

        if (ViewAsOption = ViewAsOption::UNDEFINED) then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Invalid ViewAs option. Use NetChange|BalanceAtDate'
        end;

        if (InvalidViewByOption) then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'Invalid ViewBy option. Use one of Date|Week|Month|Quarter|Year.'
        end;

        //Prevent response when there is an error
        if (ResponseCode = 'ERROR') then
            if (TmpItemResponse.IsTemporary()) then
                TmpItemResponse.DeleteAll();
    end;

    local procedure GetNotShippedItems(PeriodStart: Date; PeriodEnd: Date; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; SellToCustomerNo: Code[20])
    var
        SalesLine: Record "Sales Line";
    begin

        TmpSalesLine.Reset();
        if (TmpSalesLine.IsTemporary()) then
            TmpSalesLine.DeleteAll();

        SalesLine.SetFilter(Type, '=%1', SalesLine.Type::Item);
        SalesLine.SetFilter("No.", '=%1', ItemNo);
        SalesLine.SetFilter("Sell-to Customer No.", '=%1', SellToCustomerNo);
        SalesLine.SetFilter("Planned Shipment Date", '%1..%2', PeriodStart, PeriodEnd);
        SalesLine.SetFilter("Variant Code", '=%1', VariantCode);
        if (LocationCode <> '') then //-+MAG2.25 [399020]
            SalesLine.SetFilter("Location Code", '=%1', LocationCode);

        if (SalesLine.FindSet()) then begin
            repeat
                if (not TmpSalesLine.Get(SalesLine."Document Type", 'BOGUS', 10000)) then begin
                    TmpSalesLine.Init;
                    TmpSalesLine."Document Type" := SalesLine."Document Type";
                    TmpSalesLine."Document No." := 'BOGUS';
                    TmpSalesLine."Line No." := 10000;
                    TmpSalesLine.Insert();
                end;

                if (SalesLine."Qty. per Unit of Measure" = 0) then
                    SalesLine."Qty. per Unit of Measure" := 1;
                TmpSalesLine."Outstanding Quantity" += SalesLine."Outstanding Quantity" * SalesLine."Qty. per Unit of Measure";
                TmpSalesLine."Outstanding Amount (LCY)" += SalesLine."Outstanding Amount (LCY)" / (100 + SalesLine."VAT %") * 100;
                TmpSalesLine.Modify();

            until (SalesLine.Next() = 0);
        end;
    end;

    local procedure GetShippedItems(PeriodStart: Date; PeriodEnd: Date; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; SellToCustomerNo: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin

        if (TmpItemLedgerEntry.IsTemporary()) then
            TmpItemLedgerEntry.DeleteAll();

        Clear(AmountShippedArray);

        ItemLedgerEntry.SetFilter("Entry Type", '=%1', ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetFilter("Item No.", '=%1', ItemNo);
        ItemLedgerEntry.SetFilter("Variant Code", '=%1', VariantCode);
        if (LocationCode <> '') then //-+MAG2.25 [399020]
            ItemLedgerEntry.SetFilter("Location Code", '=%1', LocationCode);
        ItemLedgerEntry.SetFilter("Source Type", '=%1', ItemLedgerEntry."Source Type"::Customer);
        ItemLedgerEntry.SetFilter("Source No.", '=%1', SellToCustomerNo);
        ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', PeriodStart, PeriodEnd);

        if (ItemLedgerEntry.FindSet()) then begin
            repeat
                TmpItemLedgerEntry.SetFilter("Item No.", '=%1', ItemNo);
                TmpItemLedgerEntry.SetFilter("Variant Code", '=%1', VariantCode);
                TmpItemLedgerEntry.SetFilter("Document Type", '=%1', ItemLedgerEntry."Document Type");

                if (not TmpItemLedgerEntry.FindFirst()) then begin
                    TmpItemLedgerEntry.Reset();
                    TmpItemLedgerEntry.Init();
                    TmpItemLedgerEntry."Entry No." := TmpItemLedgerEntry.Count() + 1;
                    TmpItemLedgerEntry."Item No." := ItemNo;
                    TmpItemLedgerEntry."Variant Code" := VariantCode;
                    TmpItemLedgerEntry."Document Type" := ItemLedgerEntry."Document Type";
                    TmpItemLedgerEntry.Insert();
                end;

                ItemLedgerEntry.CalcFields("Sales Amount (Actual)", "Sales Amount (Expected)");
                TmpItemLedgerEntry.Quantity += ItemLedgerEntry.Quantity;

                // Partial shipments
                // All decimal amount fields are flowfields on item ledger
                if (ItemLedgerEntry."Sales Amount (Actual)" = 0) then
                    AmountShippedArray[ItemLedgerEntry."Document Type".AsInteger()] += ItemLedgerEntry."Sales Amount (Expected)"
                else
                    AmountShippedArray[ItemLedgerEntry."Document Type".AsInteger()] += ItemLedgerEntry."Sales Amount (Actual)";

                TmpItemLedgerEntry.Modify();

            until (ItemLedgerEntry.Next() = 0);
        end;
    end;

    local procedure GetInvoicedItems(PeriodStart: Date; PeriodEnd: Date; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; SellToCustomerNo: Code[20])
    var
        ValueEntry: Record "Value Entry";
    begin

        if (TmpValueEntry.IsTemporary()) then
            TmpValueEntry.DeleteAll();

        ValueEntry.SetFilter("Item Ledger Entry Type", '=%1', ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetFilter("Item No.", '=%1', ItemNo);
        ValueEntry.SetFilter("Variant Code", '=%1', VariantCode);
        if (LocationCode <> '') then //-+MAG2.25 [399020]
            ValueEntry.SetFilter("Location Code", '=%1', LocationCode);
        ValueEntry.SetFilter("Source Type", '=%1', ValueEntry."Source Type"::Customer);
        ValueEntry.SetFilter("Source No.", '=%1', SellToCustomerNo);
        ValueEntry.SetFilter("Posting Date", '%1..%2', PeriodStart, PeriodEnd);
        ValueEntry.SetFilter("Document Type", '=%1|=%2', ValueEntry."Document Type"::"Sales Invoice", ValueEntry."Document Type"::"Sales Credit Memo");

        if (ValueEntry.FindSet()) then begin
            repeat
                TmpValueEntry.SetFilter("Item No.", '=%1', ItemNo);
                TmpValueEntry.SetFilter("Variant Code", '=%1', VariantCode);
                TmpValueEntry.SetFilter("Document Type", '=%1', ValueEntry."Document Type");

                if (not TmpValueEntry.FindFirst()) then begin
                    TmpValueEntry.Reset();
                    TmpValueEntry.Init();
                    TmpValueEntry."Entry No." := TmpValueEntry.Count() + 1;
                    TmpValueEntry."Item No." := ItemNo;
                    TmpValueEntry."Variant Code" := VariantCode;
                    TmpValueEntry."Document Type" := ValueEntry."Document Type";
                    TmpValueEntry.Insert();
                end;

                TmpValueEntry."Invoiced Quantity" += ValueEntry."Invoiced Quantity";
                TmpValueEntry."Sales Amount (Actual)" += ValueEntry."Sales Amount (Actual)";

                TmpValueEntry.Modify();

            until (ValueEntry.Next() = 0);
        end;
    end;
}

