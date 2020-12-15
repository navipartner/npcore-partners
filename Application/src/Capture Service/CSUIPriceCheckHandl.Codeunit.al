codeunit 6151391 "NPR CS UI Price Check Handl."
{
    TableNo = "NPR CS UI Header";

    trigger OnRun()
    var
        MiniformMgmt: Codeunit "NPR CS UI Management";
    begin
        MiniformMgmt.Initialize(
          CSUIHeader, Rec, DOMxmlin, ReturnedNode,
          RootNode, CSCommunication, CSUserId,
          CurrentCode, StackCode, WhseEmpId, LocationFilter, CSSessionId);

        if Code <> CurrentCode then
            PrepareData
        else
            ProcessInput;

        Clear(DOMxmlin);
    end;

    var
        CSUIHeader: Record "NPR CS UI Header";
        CSCommunication: Codeunit "NPR CS Communication";
        CSMgt: Codeunit "NPR CS Management";
        RecRef: RecordRef;
        DOMxmlin: XmlDocument;
        ReturnedNode: XmlNode;
        RootNode: XmlNode;
        CSUserId: Text[250];
        Remark: Text[250];
        WhseEmpId: Text[250];
        LocationFilter: Text[250];
        CurrentCode: Text[250];
        StackCode: Text[250];
        ActiveInputField: Integer;
        CSSessionId: Text;
        Text000: Label 'Function not Found.';
        Text002: Label 'Failed to add the attribute: %1.';
        Text005: Label 'Barcode is blank';
        Text006: Label 'No input Node found.';
        Text008: Label 'Input value Length Error';
        Text010: Label 'Barcode %1 doesn''t exist';
        Text011: Label 'Qty. is blank';
        Text013: Label 'Input value is not valid';
        Text015: Label '%1 : %2 %3';
        Text016: Label '%1 : %2';
        "--": Integer;
        FoundSalesPrice: Boolean;
        AllowLineDisc: Boolean;
        AllowInvDisc: Boolean;
        LineDiscPerCent: Decimal;
        QtyPerUOM: Decimal;
        QtySalesPrice: Decimal;
        VATCalcType: Enum "Tax Calculation Type";
        PricesInclVAT: Boolean;
        VATPostingSetup: Record "VAT Posting Setup";
        VATBusPostingGr: Code[10];
        VATPerCent: Decimal;
        PricesInCurrency: Boolean;
        ExchRateDate: Date;
        Currency: Record Currency;
        CurrencyFactor: Decimal;
        GLSetup: Record "General Ledger Setup";

    local procedure ProcessInput()
    var
        FuncGroup: Record "NPR CS UI Function Group";
        RecId: RecordID;
        TextValue: Text[250];
        TableNo: Integer;
        FldNo: Integer;
        FuncRecId: RecordID;
        FuncTableNo: Integer;
        FuncRecRef: RecordRef;
        FuncFieldId: Integer;
        FuncName: Code[10];
        FuncValue: Text;
        CSPriceCheckHandling: Record "NPR CS Price Check Handl.";
        CSPriceCheckHandling2: Record "NPR CS Price Check Handl.";
        CSFieldDefaults: Record "NPR CS Field Defaults";
        CommaString: Text;
        Values: List of [Text];
        Separator: Text;
        Value: Text;
    begin
        if RootNode.AsXmlAttribute().SelectSingleNode('Header/Input', ReturnedNode) then
            TextValue := ReturnedNode.AsXmlElement().InnerText
        else
            Error(Text006);

        Evaluate(TableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'TableNo'));
        RecRef.Open(TableNo);
        Evaluate(RecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'RecordID'));
        if RecRef.Get(RecId) then begin
            RecRef.SetTable(CSPriceCheckHandling);
            RecRef.SetRecFilter;
            CSCommunication.SetRecRef(RecRef);
        end else begin
            CSCommunication.RunPreviousUI(DOMxmlin);
            exit;
        end;

        FuncGroup.KeyDef := CSCommunication.GetFunctionKey(CSUIHeader.Code, TextValue);
        ActiveInputField := 1;

        case FuncGroup.KeyDef of
            FuncGroup.KeyDef::Esc:
                begin
                    DeleteEmptyDataLines();
                    CSCommunication.RunPreviousUI(DOMxmlin);
                end;
            FuncGroup.KeyDef::"Function":
                begin
                    FuncName := CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncName');
                    case FuncName of
                        'DEFAULT':
                            begin
                                FuncValue := CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncValue');
                                Evaluate(FuncFieldId, CSCommunication.GetNodeAttribute(ReturnedNode, 'FieldID'));
                                if CSFieldDefaults.Get(CSUserId, CurrentCode, FuncFieldId) then begin
                                    CSFieldDefaults.Value := FuncValue;
                                    CSFieldDefaults.Modify;
                                end else begin
                                    Clear(CSFieldDefaults);
                                    CSFieldDefaults.Id := CSUserId;
                                    CSFieldDefaults."Use Case Code" := CurrentCode;
                                    CSFieldDefaults."Field No" := FuncFieldId;
                                    CSFieldDefaults.Insert;
                                    CSFieldDefaults.Value := FuncValue;
                                    CSFieldDefaults.Modify;
                                end;
                            end;
                        'DELETELINE':
                            begin
                                Evaluate(FuncTableNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncTableNo'));
                                FuncRecRef.Open(FuncTableNo);
                                Evaluate(FuncRecId, CSCommunication.GetNodeAttribute(ReturnedNode, 'FuncRecordID'));
                                if FuncRecRef.Get(FuncRecId) then begin
                                    FuncRecRef.SetTable(CSPriceCheckHandling2);
                                    CSPriceCheckHandling2.Delete(true);
                                end;
                            end;
                    end;
                end;
            FuncGroup.KeyDef::Reset:
                Reset();
            FuncGroup.KeyDef::Input:
                begin
                    Evaluate(FldNo, CSCommunication.GetNodeAttribute(ReturnedNode, 'FieldID'));

                    CommaString := TextValue;
                    Separator := ',';
                    Values := CommaString.Split(Separator);

                    foreach Value in Values do begin

                        if Value <> '' then begin

                            case FldNo of
                                CSPriceCheckHandling.FieldNo(Barcode):
                                    CheckBarcode(CSPriceCheckHandling, Value);
                                CSPriceCheckHandling.FieldNo(Qty):
                                    CheckQty(CSPriceCheckHandling, Value);
                                else begin
                                        CSCommunication.FieldSetvalue(RecRef, FldNo, Value);
                                    end;
                            end;

                            CSPriceCheckHandling.Modify;

                            RecRef.GetTable(CSPriceCheckHandling);
                            CSCommunication.SetRecRef(RecRef);
                            ActiveInputField := CSCommunication.GetActiveInputNo(CurrentCode, FldNo);
                            if Remark = '' then
                                if CSCommunication.LastEntryField(CurrentCode, FldNo) then begin

                                    Clear(CSFieldDefaults);
                                    CSFieldDefaults.SetRange(Id, CSUserId);
                                    CSFieldDefaults.SetRange("Use Case Code", CurrentCode);
                                    if CSFieldDefaults.FindSet then begin
                                        repeat
                                            CSCommunication.FieldSetvalue(RecRef, CSFieldDefaults."Field No", CSFieldDefaults.Value);
                                            RecRef.SetTable(CSPriceCheckHandling);
                                            RecRef.SetRecFilter;
                                            CSCommunication.SetRecRef(RecRef);
                                        until CSFieldDefaults.Next = 0;
                                    end;

                                    UpdateDataLine(CSPriceCheckHandling);
                                    RecRef.GetTable(CSPriceCheckHandling);
                                    CSCommunication.SetRecRef(RecRef);

                                    ActiveInputField := 1;
                                end else
                                    ActiveInputField += 1;
                        end;
                    end;
                end;
            else
                Error(Text000);
        end;

        if not (FuncGroup.KeyDef in [FuncGroup.KeyDef::Esc, FuncGroup.KeyDef::Register]) then
            SendForm(ActiveInputField);
    end;

    local procedure PrepareData()
    var
        CSPriceCheckHandling: Record "NPR CS Price Check Handl.";
        RecId: RecordID;
        TableNo: Integer;
    begin
        DeleteEmptyDataLines();
        CreateDataLine(CSPriceCheckHandling);

        RecId := CSPriceCheckHandling.RecordId;

        RecRef.Open(RecId.TableNo);
        RecRef.Get(RecId);
        RecRef.SetRecFilter;

        CSCommunication.SetRecRef(RecRef);
        ActiveInputField := 1;
        SendForm(ActiveInputField);
    end;

    local procedure SendForm(InputField: Integer)
    var
        Records: DotNet NPRNetXmlElement;
    begin
        CSCommunication.EncodeUI(CSUIHeader, StackCode, DOMxmlin, InputField, Remark, CSUserId);
        CSCommunication.GetReturnXML(DOMxmlin);
        CSMgt.SendXMLReply(DOMxmlin);
    end;

    local procedure CheckBarcode(var CSPriceCheckHandling: Record "NPR CS Price Check Handl."; InputValue: Text)
    var
        QtyToHandle: Decimal;
    begin
        if InputValue = '' then begin
            Remark := Text005;
            exit;
        end;

        if StrLen(InputValue) > MaxStrLen(CSPriceCheckHandling.Barcode) then begin
            Remark := Text008;
            exit;
        end;

        CSPriceCheckHandling.Barcode := InputValue;
    end;

    local procedure CheckQty(var CSPriceCheckHandling: Record "NPR CS Price Check Handl."; InputValue: Text)
    var
        Qty: Decimal;
    begin
        if InputValue = '' then begin
            Remark := Text011;
            exit;
        end;

        if not Evaluate(Qty, InputValue) then begin
            Remark := Text013;
            exit;
        end;

        CSPriceCheckHandling.Qty := Qty;
    end;

    local procedure CreateDataLine(var CSPriceCheckHandling: Record "NPR CS Price Check Handl.")
    var
        NewCSPriceCheckHandling: Record "NPR CS Price Check Handl.";
        LineNo: Integer;
        RecRef: RecordRef;
    begin
        Clear(NewCSPriceCheckHandling);
        NewCSPriceCheckHandling.SetRange(Id, CSSessionId);
        if NewCSPriceCheckHandling.FindLast then
            LineNo := NewCSPriceCheckHandling."Line No." + 1
        else
            LineNo := 1;

        CSPriceCheckHandling.Init;
        CSPriceCheckHandling.Id := CSSessionId;
        CSPriceCheckHandling."Line No." := LineNo;
        CSPriceCheckHandling."Created By" := UserId;
        CSPriceCheckHandling.Created := CurrentDateTime;
        CSPriceCheckHandling.Qty := NewCSPriceCheckHandling.Qty;
        CSPriceCheckHandling."Location Filter" := LocationFilter;

        RecRef.GetTable(CSPriceCheckHandling);

        CSPriceCheckHandling."Table No." := RecRef.Number;

        CSPriceCheckHandling."Record Id" := CSPriceCheckHandling.RecordId;
        CSPriceCheckHandling.Insert(true);
    end;

    local procedure UpdateDataLine(var CSPriceCheckHandling: Record "NPR CS Price Check Handl.")
    var
        LineNo: Integer;
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        CSFieldDefaults: Record "NPR CS Field Defaults";
        CSSetup: Record "NPR CS Setup";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if BarcodeLibrary.TranslateBarcodeToItemVariant(CSPriceCheckHandling.Barcode, ItemNo, VariantCode, ResolvingTable, true) then begin
            CSPriceCheckHandling."Item No." := ItemNo;
            CSPriceCheckHandling."Variant Code" := VariantCode;

            if (ResolvingTable = DATABASE::"Item Cross Reference") then begin
                with ItemCrossReference do begin
                    if (StrLen(CSPriceCheckHandling.Barcode) <= MaxStrLen("Cross-Reference No.")) then begin
                        SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                        SetFilter("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
                        SetFilter("Cross-Reference No.", '=%1', UpperCase(CSPriceCheckHandling.Barcode));
                        if FindFirst() then
                            CSPriceCheckHandling."Unit of Measure" := ItemCrossReference."Unit of Measure";
                    end;
                end;
            end;
        end else begin
            Remark := StrSubstNo(Text010, CSPriceCheckHandling.Barcode);
            ClearDataLines(CSPriceCheckHandling);
        end;

        if Remark = '' then
            GetItemPricesV2(CSPriceCheckHandling);
        CSPriceCheckHandling.Modify(true);
    end;

    local procedure DeleteEmptyDataLines()
    var
        CSPriceCheckHandling: Record "NPR CS Price Check Handl.";
    begin
        CSPriceCheckHandling.SetRange(Id, CSSessionId);
        CSPriceCheckHandling.DeleteAll(true);
    end;

    local procedure ClearDataLines(var CSPriceCheckHandling: Record "NPR CS Price Check Handl.")
    begin
        CSPriceCheckHandling."Item No." := '';
        CSPriceCheckHandling."Item Description" := '';
        CSPriceCheckHandling."Variant Code" := '';
        CSPriceCheckHandling."Variant Description" := '';
        CSPriceCheckHandling."Unit Cost ex. VAT" := 0;
        CSPriceCheckHandling."Unit Cost incl. VAT" := 0;
        CSPriceCheckHandling."Unit Price ex. VAT" := 0;
        CSPriceCheckHandling."Unit Price incl. VAT" := 0;
        CSPriceCheckHandling."Customer Unit Price ex. VAT" := 0;
        CSPriceCheckHandling."Customer Unit Price incl. VAT" := 0;
        CSPriceCheckHandling."Currency Code" := '';
    end;

    local procedure Reset()
    var
        CSPriceCheckHandling: Record "NPR CS Price Check Handl.";
    begin
        Clear(CSPriceCheckHandling);
        CSPriceCheckHandling.SetRange(Id, CSSessionId);
        CSPriceCheckHandling.SetRange(Handled, true);
        CSPriceCheckHandling.DeleteAll(true);
    end;

    procedure GetItemPrices(var CSPriceCheckHandling: Record "NPR CS Price Check Handl."): Decimal
    var
        VATPostingSetup: Record "VAT Posting Setup";
        ItemPriceExclVAT: Decimal;
        SalesPrice: Record "Sales Price";
        POSSalesPriceCalcMgt: Codeunit "NPR POS Sales Price Calc. Mgt.";
        TempSalePOS: Record "NPR Sale POS" temporary;
        TempSaleLinePOS: Record "NPR Sale Line POS" temporary;
        Customer: Record Customer;
        CSSetup: Record "NPR CS Setup";
        Item: Record Item;
        CurrencyCode: Code[10];
        RetailFormCode: Codeunit "NPR Retail Form Code";
        Register: Record "NPR Register";
    begin
        Item.Get(CSPriceCheckHandling."Item No.");

        GLSetup.Get;
        CSSetup.Get;

        CSSetup.TestField("Price Calc. Customer No.");
        Customer.Get(CSSetup."Price Calc. Customer No.");

        if (CSPriceCheckHandling."Currency Code" <> '') then
            CurrencyCode := CSPriceCheckHandling."Currency Code";

        if (CurrencyCode = '') then
            CurrencyCode := Customer."Currency Code";

        if (CurrencyCode = '') then
            CurrencyCode := GLSetup."LCY Code";

        CSPriceCheckHandling."Currency Code" := CurrencyCode;

        if not VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
            VATPostingSetup.Init;

        TempSaleLinePOS.Type := TempSaleLinePOS.Type::Item;
        TempSaleLinePOS."Currency Code" := CurrencyCode;
        TempSaleLinePOS."No." := Item."No.";
        TempSaleLinePOS."Variant Code" := CSPriceCheckHandling."Variant Code";
        POSSalesPriceCalcMgt.InitTempPOSItemSale(TempSaleLinePOS, TempSalePOS);

        TempSalePOS."Register No." := RetailFormCode.FetchRegisterNumber;

        if not Register.Get(TempSalePOS."Register No.") then
            Register.Init;

        if Customer."Customer Price Group" <> '' then
            TempSalePOS."Customer Price Group" := Customer."Customer Price Group"
        else
            TempSalePOS."Customer Price Group" := Register."Customer Price Group";

        if Customer."Customer Disc. Group" <> '' then
            TempSalePOS."Customer Disc. Group" := Customer."Customer Disc. Group"
        else
            TempSalePOS."Customer Disc. Group" := Register."Customer Disc. Group";

        TempSaleLinePOS."Price Includes VAT" := Item."Price Includes VAT";
        TempSaleLinePOS."Customer Price Group" := TempSalePOS."Customer Price Group";
        TempSaleLinePOS."Item Disc. Group" := Item."Item Disc. Group";
        TempSaleLinePOS.Silent := true;
        TempSaleLinePOS.Date := TempSalePOS.Date;
        TempSaleLinePOS.Validate(Quantity, CSPriceCheckHandling.Qty);
        TempSaleLinePOS."Register No." := Register."Register No.";

        POSSalesPriceCalcMgt.FindItemPrice(TempSalePOS, TempSaleLinePOS);

        if Item."Price Includes VAT" then begin
            CSPriceCheckHandling."Unit Cost ex. VAT" := (Item."Unit Cost" / (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Unit Cost incl. VAT" := Item."Unit Cost";
            CSPriceCheckHandling."Unit Price ex. VAT" := (Item."Unit Price" / (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Unit Price incl. VAT" := Item."Unit Price";
            CSPriceCheckHandling."Customer Unit Price incl. VAT" := (TempSaleLinePOS."Unit Price" * (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Customer Unit Price ex. VAT" := TempSaleLinePOS."Unit Price";
            CSPriceCheckHandling."Total Cost ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Cost ex. VAT";
            CSPriceCheckHandling."Total Cost incl. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Cost incl. VAT";
            CSPriceCheckHandling."Total Price ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Price ex. VAT";
            CSPriceCheckHandling."Total Price incl. VAT" := CSPriceCheckHandling.Qty * Item."Unit Price";
            CSPriceCheckHandling."Total Customer Price incl. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Customer Unit Price incl. VAT";
            CSPriceCheckHandling."Total Customer Price ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Customer Unit Price ex. VAT";
        end else begin
            CSPriceCheckHandling."Unit Cost incl. VAT" := (Item."Unit Cost" * (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Unit Cost ex. VAT" := Item."Unit Cost";
            CSPriceCheckHandling."Unit Price incl. VAT" := (Item."Unit Price" * (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Unit Price ex. VAT" := Item."Unit Price";
            CSPriceCheckHandling."Customer Unit Price ex. VAT" := TempSaleLinePOS."Unit Price";
            CSPriceCheckHandling."Customer Unit Price incl. VAT" := (TempSaleLinePOS."Unit Price" * (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Total Cost incl. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Cost incl. VAT";
            CSPriceCheckHandling."Total Cost ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Cost ex. VAT";
            CSPriceCheckHandling."Total Price incl. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Price incl. VAT";
            CSPriceCheckHandling."Total Price ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Price ex. VAT";
            CSPriceCheckHandling."Total Customer Price ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Customer Unit Price ex. VAT";
            CSPriceCheckHandling."Total Customer Price incl. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Customer Unit Price incl. VAT";
        end;
    end;

    procedure GetItemPricesV2(var CSPriceCheckHandling: Record "NPR CS Price Check Handl."): Decimal
    var
        Customer: Record Customer;
        CSSetup: Record "NPR CS Setup";
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Discount: Decimal;
        Total: Decimal;
        PriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        CurrExchRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
        TempSalesPrice: Record "Sales Price" temporary;
        TempSalesLineDisc: Record "Sales Line Discount" temporary;
        pricemgt: Codeunit "Sales Price Calc. Mgt.";
    begin
        Item.Get(CSPriceCheckHandling."Item No.");

        CSSetup.Get;
        CSSetup.TestField("Price Calc. Customer No.");
        Customer.Get(CSSetup."Price Calc. Customer No.");

        Total := 0;
        Discount := 0;

        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';

        SalesHeader."Sell-to Customer No." := Customer."No.";

        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Bill-to Customer No.", Customer."No.");
        SalesHeader.SetHideValidationDialog(false);

        SalesHeader."Prices Including VAT" := Customer."Prices Including VAT";

        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := Item."No.";

        SalesLine.Quantity := CSPriceCheckHandling.Qty;

        VATPostingSetup.Get(Customer."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");
        AllowLineDisc := Customer."Allow Line Disc.";
        AllowInvDisc := false;
        QtySalesPrice := SalesLine.Quantity;
        QtyPerUOM := 1;
        VATCalcType := VATPostingSetup."VAT Calculation Type";

        PricesInclVAT := Customer."Prices Including VAT";
        VATBusPostingGr := Customer."VAT Bus. Posting Group";
        VATPerCent := VATPostingSetup."VAT %";
        PricesInCurrency := true;

        SalesLine."VAT %" := VATPostingSetup."VAT %";

        ExchRateDate := Today;
        GLSetup.Get;
        if Currency.Get(SalesHeader."Currency Code") then begin
            Currency.SetRecFilter();
            CurrencyFactor := CurrExchRate.ExchangeRate(ExchRateDate, Currency.Code);
        end else begin
            CurrencyFactor := 1
        end;

        Clear(TempSalesPrice);
        Clear(TempSalesLineDisc);
        TempSalesPrice.DeleteAll;
        TempSalesLineDisc.DeleteAll;

        pricemgt.FindSalesLineDisc(TempSalesLineDisc, Customer."No.", '', Customer."Customer Disc. Group", '', Item."No.", Item."Item Disc. Group", '', Item."Base Unit of Measure", Currency.Code, ExchRateDate, false);
        CalcBestLineDisc(TempSalesLineDisc);
        LineDiscPerCent := TempSalesLineDisc."Line Discount %";

        SalesLine."Line Discount %" := TempSalesLineDisc."Line Discount %";

        pricemgt.FindSalesPrice(TempSalesPrice, Customer."No.", '', Customer."Customer Price Group", '', Item."No.", '', Item."Base Unit of Measure", Currency.Code, ExchRateDate, false);
        CalcBestUnitPrice(TempSalesPrice, Item);

        LineDiscPerCent := 0;
        SalesLine."Unit Price" := CalcLineAmount(TempSalesPrice);
        LineDiscPerCent := TempSalesLineDisc."Line Discount %";

        SalesLine."Line Discount Amount" :=
        Round(
          Round(SalesLine.Quantity * TempSalesPrice."Unit Price", Currency."Amount Rounding Precision") *
          LineDiscPerCent / 100, Currency."Amount Rounding Precision");

        if Currency.Code <> '' then
            CSPriceCheckHandling."Currency Code" := Currency.Code
        else
            CSPriceCheckHandling."Currency Code" := GLSetup."LCY Code";

        if Item."Price Includes VAT" then begin
            CSPriceCheckHandling."Unit Cost ex. VAT" := (Item."Unit Cost" / (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Unit Cost incl. VAT" := Item."Unit Cost";
            CSPriceCheckHandling."Unit Price ex. VAT" := (Item."Unit Price" / (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Unit Price incl. VAT" := Item."Unit Price";
        end else begin
            CSPriceCheckHandling."Unit Cost incl. VAT" := (Item."Unit Cost" * (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Unit Cost ex. VAT" := Item."Unit Cost";
            CSPriceCheckHandling."Unit Price incl. VAT" := (Item."Unit Price" * (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Unit Price ex. VAT" := Item."Unit Price";
        end;

        if PricesInclVAT then begin
            CSPriceCheckHandling."Customer Unit Price incl. VAT" := SalesLine."Unit Price";//(TempSaleLinePOS."Unit Price" * (1 + (VATPostingSetup."VAT %" / 100)));
            CSPriceCheckHandling."Customer Unit Price ex. VAT" := SalesLine."Unit Price" / (1 + (VATPostingSetup."VAT %" / 100));

            CSPriceCheckHandling."Total Cost ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Cost ex. VAT";
            CSPriceCheckHandling."Total Cost incl. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Cost incl. VAT";
            CSPriceCheckHandling."Total Price ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Price ex. VAT";
            CSPriceCheckHandling."Total Price incl. VAT" := CSPriceCheckHandling.Qty * Item."Unit Price";
            CSPriceCheckHandling."Total Customer Price incl. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Customer Unit Price incl. VAT";
            CSPriceCheckHandling."Total Customer Price ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Customer Unit Price ex. VAT";
        end else begin
            CSPriceCheckHandling."Customer Unit Price ex. VAT" := SalesLine."Unit Price";
            CSPriceCheckHandling."Customer Unit Price incl. VAT" := (SalesLine."Unit Price" * (1 + (VATPostingSetup."VAT %" / 100)));

            CSPriceCheckHandling."Total Cost incl. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Cost incl. VAT";
            CSPriceCheckHandling."Total Cost ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Cost ex. VAT";
            CSPriceCheckHandling."Total Price incl. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Price incl. VAT";
            CSPriceCheckHandling."Total Price ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Unit Price ex. VAT";
            CSPriceCheckHandling."Total Customer Price ex. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Customer Unit Price ex. VAT";
            CSPriceCheckHandling."Total Customer Price incl. VAT" := CSPriceCheckHandling.Qty * CSPriceCheckHandling."Customer Unit Price incl. VAT";
        end;
    end;

    procedure CalcBestLineDisc(var SalesLineDisc: Record "Sales Line Discount")
    var
        BestSalesLineDisc: Record "Sales Line Discount";
    begin
        with SalesLineDisc do begin
            if FindSet then
                repeat
                    if IsInMinQty("Unit of Measure Code", "Minimum Quantity") then
                        case true of
                            ((BestSalesLineDisc."Currency Code" = '') and ("Currency Code" <> '')) or
                          ((BestSalesLineDisc."Variant Code" = '') and ("Variant Code" <> '')):
                                BestSalesLineDisc := SalesLineDisc;
                            ((BestSalesLineDisc."Currency Code" = '') or ("Currency Code" <> '')) and
                          ((BestSalesLineDisc."Variant Code" = '') or ("Variant Code" <> '')):
                                if BestSalesLineDisc."Line Discount %" < "Line Discount %" then
                                    BestSalesLineDisc := SalesLineDisc;
                        end;
                until Next = 0;
        end;

        SalesLineDisc := BestSalesLineDisc;
    end;

    procedure CalcBestUnitPrice(var SalesPrice: Record "Sales Price"; item: Record Item)
    var
        BestSalesPrice: Record "Sales Price";
    begin
        with SalesPrice do begin
            FoundSalesPrice := FindSet;
            if FoundSalesPrice then
                repeat
                    if IsInMinQty("Unit of Measure Code", "Minimum Quantity") then begin
                        ConvertPriceToVAT(
                          "Price Includes VAT", item."VAT Prod. Posting Group",
                          "VAT Bus. Posting Gr. (Price)", "Unit Price");
                        ConvertPriceToUoM("Unit of Measure Code", "Unit Price");
                        ConvertPriceLCYToFCY("Currency Code", "Unit Price");

                        case true of
                            ((BestSalesPrice."Currency Code" = '') and ("Currency Code" <> '')) or
                          ((BestSalesPrice."Variant Code" = '') and ("Variant Code" <> '')):
                                BestSalesPrice := SalesPrice;
                            ((BestSalesPrice."Currency Code" = '') or ("Currency Code" <> '')) and
                          ((BestSalesPrice."Variant Code" = '') or ("Variant Code" <> '')):
                                if (BestSalesPrice."Unit Price" = 0) or
                                   (CalcLineAmount(BestSalesPrice) > CalcLineAmount(SalesPrice))
                                then
                                    BestSalesPrice := SalesPrice;
                        end;
                    end;
                until Next = 0;
        end;

        // No price found in agreement
        if BestSalesPrice."Unit Price" = 0 then begin
            ConvertPriceToVAT(
              item."Price Includes VAT", item."VAT Prod. Posting Group",
              item."VAT Bus. Posting Gr. (Price)", item."Unit Price");
            ConvertPriceToUoM('', item."Unit Price");
            ConvertPriceLCYToFCY('', item."Unit Price");

            Clear(BestSalesPrice);
            BestSalesPrice."Unit Price" := item."Unit Price";
            BestSalesPrice."Allow Line Disc." := AllowLineDisc;
            BestSalesPrice."Allow Invoice Disc." := AllowInvDisc;
        end;

        SalesPrice := BestSalesPrice;
    end;

    procedure CalcLineAmount(SalesPrice: Record "Sales Price"): Decimal
    begin
        with SalesPrice do begin
            if "Allow Line Disc." then
                exit("Unit Price" * (1 - LineDiscPerCent / 100));
            exit("Unit Price");
        end;
    end;

    local procedure IsInMinQty(UnitofMeasureCode: Code[10]; MinQty: Decimal): Boolean
    begin
        if UnitofMeasureCode = '' then
            exit(MinQty <= QtyPerUOM * QtySalesPrice);
        exit(MinQty <= QtySalesPrice);
    end;

    local procedure ConvertPriceToVAT(FromPricesInclVAT: Boolean; FromVATProdPostingGr: Code[10]; FromVATBusPostingGr: Code[10]; var UnitPrice: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if FromPricesInclVAT then begin
            VATPostingSetup.Get(FromVATBusPostingGr, FromVATProdPostingGr);

            case VATPostingSetup."VAT Calculation Type" of
                VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                    VATPostingSetup."VAT %" := 0;
                VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                    Error(
                      Text010,
                      VATPostingSetup.FieldCaption("VAT Calculation Type"),
                      VATPostingSetup."VAT Calculation Type");
            end;

            case VATCalcType of
                VATCalcType::"Normal VAT",
                VATCalcType::"Full VAT",
                VATCalcType::"Sales Tax":
                    begin
                        if PricesInclVAT then begin
                            if VATBusPostingGr <> FromVATBusPostingGr then
                                UnitPrice := UnitPrice * (100 + VATPerCent) / (100 + VATPostingSetup."VAT %");
                        end else
                            UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                VATCalcType::"Reverse Charge VAT":
                    UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
            end;
        end else
            if PricesInclVAT then
                UnitPrice := UnitPrice * (1 + VATPerCent / 100);
    end;

    local procedure ConvertPriceToUoM(UnitOfMeasureCode: Code[10]; var UnitPrice: Decimal)
    begin
        if UnitOfMeasureCode = '' then
            UnitPrice := UnitPrice * QtyPerUOM;
    end;

    local procedure ConvertPriceLCYToFCY(CurrencyCode: Code[10]; var UnitPrice: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if PricesInCurrency then begin
            if CurrencyCode = '' then
                UnitPrice :=
                  CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate, Currency.Code, UnitPrice, CurrencyFactor);
            UnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
        end else
            UnitPrice := Round(UnitPrice, GLSetup."Unit-Amount Rounding Precision");
    end;
}
