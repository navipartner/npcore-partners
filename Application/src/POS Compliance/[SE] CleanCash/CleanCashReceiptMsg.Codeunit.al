codeunit 6014459 "NPR CleanCash Receipt Msg." implements "NPR CleanCash XCCSP Interface"
{

    // This method is not implement for receipt message type
    procedure CreateRequest(PosUnitNo: Code[10]; var EntryNo: Integer): Boolean
    begin
        exit(false);
    end;

    procedure CreateRequest(PosEntry: Record "NPR POS Entry"; RequestType: Enum "NPR CleanCash Request Type"; var EntryNo: Integer): Boolean
    var
        TmpVat: Record "NPR CleanCash Trans. VAT" temporary;
        Amount: Decimal;
        IsSales: Boolean;
    begin

        // CleanCash needs individual receipts for sales and retur sales
        IsSales := (RequestType = RequestType::RegisterSalesReceipt);

        GetReceiptVat(PosEntry, IsSales, Amount, TmpVat);
        EntryNo := StoreCleanCashReceipt(PosEntry, Amount, TmpVat);

        exit(EntryNo <> 0);
    end;

    local procedure GetReceiptVat(PosEntry: Record "NPR POS Entry"; Positive: Boolean; var TotalAmount: Decimal; var TmpVat: Record "NPR CleanCash Trans. VAT" temporary)
    var
        PosSalesLine: Record "NPR POS Entry Sales Line";
        VatClassId: Integer;
    begin
        PosSalesLine.SetFilter("POS Entry No.", '=%1', PosEntry."Entry No.");
        PosSalesLine.SetFilter(Type, '%1|%2|%3|%4', PosSalesLine.Type::"G/L Account", PosSalesLine.Type::Item, PosSalesLine.Type::Rounding, PosSalesLine.Type::Voucher);
        if (Positive) then
            PosSalesLine.SetFilter(Quantity, '>%1', 0);
        if (not Positive) then
            PosSalesLine.SetFilter(Quantity, '<%1', 0);

        if (not PosSalesLine.FindSet()) then
            exit;

        repeat
            TmpVat.Reset();
            VatClassId := TmpVat.Count();

            TmpVat.SetFilter(Percentage, '=%1', PosSalesLine."VAT %");
            if (not TmpVat.FindFirst()) then begin
                TmpVat."VAT Class" := VatClassId + 1;
                TmpVat.Percentage := PosSalesLine."VAT %";
                TmpVat.Amount := PosSalesLine."Amount Incl. VAT (LCY)" - PosSalesLine."Amount Excl. VAT (LCY)";
                TmpVat.Insert();
            end else begin
                TmpVat.Amount := PosSalesLine."Amount Incl. VAT (LCY)" - PosSalesLine."Amount Excl. VAT (LCY)";
                TmpVat.Modify();
            end;

            TotalAmount += PosSalesLine."Amount Incl. VAT (LCY)";

        until (PosSalesLine.Next() = 0);

        TmpVat.Reset();
    end;

    local procedure StoreCleanCashReceipt(PosEntry: Record "NPR POS Entry"; TotalAmount: Decimal; var TmpVat: Record "NPR CleanCash Trans. VAT" temporary): Integer
    var
        CleanCashTransaction: Record "NPR CleanCash Trans. Request";
        CleanCashVat: Record "NPR CleanCash Trans. VAT";
        CleanCashSetup: Record "NPR CleanCash Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ReceiptType: Enum "NPR CleanCash Receipt Type";
    begin

        if (not CleanCashSetup.Get(PosEntry."POS Unit No.")) then
            exit(0);

        if (TotalAmount = 0) then
            exit(0);

        CleanCashTransaction.SetFilter("POS Entry No.", '=%1', PosEntry."Entry No.");
        if (TotalAmount > 0) then
            CleanCashTransaction.SetFilter("Request Type", '=%1', CleanCashTransaction."Request Type"::RegisterSalesReceipt);
        if (TotalAmount < 0) then
            CleanCashTransaction.SetFilter("Request Type", '=%1', CleanCashTransaction."Request Type"::RegisterReturnReceipt);

        CleanCashTransaction.SetFilter("Request Send Status", '=%1', CleanCashTransaction."Request Send Status"::COMPLETE);
        ReceiptType := ReceiptType::normal;
        if (not CleanCashTransaction.IsEmpty()) then
            ReceiptType := ReceiptType::kopia;

        if (CleanCashSetup.Training) then
            ReceiptType := ReceiptType::ovning;

        // If there is an failed or pending normal receipt entry already created - reuse it.
        if (ReceiptType = ReceiptType::normal) then begin
            CleanCashTransaction.SetFilter("Request Send Status", '<>%1', CleanCashTransaction."Request Send Status"::COMPLETE);
            if (not CleanCashTransaction.FindFirst()) then
                CleanCashTransaction.Insert();
        end else begin
            // repeating copies, training and proforma transactions - create new entries.
            CleanCashTransaction.Insert();
        end;

        CleanCashTransaction.Init();
        CleanCashTransaction."POS Entry No." := PosEntry."Entry No.";
        CleanCashTransaction."POS Document No." := PosEntry."Document No.";
        CleanCashTransaction."POS Unit No." := PosEntry."POS Unit No.";
        CleanCashTransaction."Request Datetime" := CurrentDateTime;
        CleanCashTransaction."Request Send Status" := CleanCashTransaction."Request Send Status"::PENDING;
        CleanCashTransaction."Request Type" := CleanCashTransaction."Request Type"::RegisterSalesReceipt;

        CleanCashTransaction."Receipt DateTime" := CreateDateTime(PosEntry."Document Date", PosEntry."Ending Time");
        CleanCashTransaction."Receipt Type" := ReceiptType;

        CleanCashTransaction."Receipt Id" := NoSeriesManagement.GetNextNo(CleanCashSetup."CleanCash No. Series", Today, true);
        CleanCashTransaction."Organisation No." := CleanCashSetup."Organization ID";
        CleanCashTransaction."Pos Id" := CleanCashSetup."CleanCash Register No.";

        CleanCashTransaction."Receipt Total" := TotalAmount;
        if (TotalAmount < 0) then begin
            CleanCashTransaction."Negative Total" := abs(TotalAmount);
            CleanCashTransaction."Request Type" := CleanCashTransaction."Request Type"::RegisterReturnReceipt;
        end;

        if (TmpVat.FindSet()) then begin
            repeat
                CleanCashVat.TransferFields(TmpVat, true);
                CleanCashVat."Request Entry No." := CleanCashTransaction."Entry No.";
                CleanCashVat.Insert();
            until (TmpVat.Next() = 0);
        end;

        CleanCashTransaction.Modify();
        exit(CleanCashTransaction."Entry No.");
    end;


    procedure GetRequestXml(CleanCashTransactionRequest: Record "NPR CleanCash Trans. Request"; var XmlDoc: XmlDocument) Success: Boolean;
    var
        CleanCashXCCSPProtocol: Codeunit "NPR CleanCash XCCSP Protocol";
        CleanCashTransactionVat: Record "NPR CleanCash Trans. VAT";
        XmlNs: Text;
        Data: XmlElement;
        VatList: XmlElement;
        Vat: XmlElement;
        Envelope: XmlElement;
        Receipt: XmlElement;
        EnumName: Text;
        DateTimeLbl: Label '%1%2', Locked = true;
    begin

        XmlNs := CleanCashXCCSPProtocol.GetNamespace();

        CleanCashTransactionVat.SetFilter("Request Entry No.", '=%1', CleanCashTransactionRequest."Entry No.");
        if (not CleanCashTransactionVat.FindSet()) then
            Error('No VAT transactions found for POS Entry %1.', CleanCashTransactionRequest."Entry No.");

        VatList := XmlElement.Create('VatList', XmlNs);
        repeat
            Vat := XmlElement.Create('Vat', XmlNs);
            Vat.Add(CleanCashXCCSPProtocol.AddElement('Class', Format(CleanCashTransactionVat."VAT Class", 0, '<Integer>'), XmlNs));
            Vat.Add(CleanCashXCCSPProtocol.AddElement('Percentage', Format(CleanCashTransactionVat.Percentage, 0, '<Precision,2:2><Integer><Comma,,><Decimals>'), XmlNs));
            Vat.Add(CleanCashXCCSPProtocol.AddElement('Amount', Format(CleanCashTransactionVat.Amount, 0, '<Precision,2:2><Sign><Integer><Comma,,><Decimals>'), XmlNs));
            VatList.Add(Vat);
        until (CleanCashTransactionVat.Next() = 0);

        Receipt := XmlElement.Create('Receipt', XmlNs);
        Receipt.Add(CleanCashXCCSPProtocol.AddElement('IsNewSession', '1', XmlNs));
        Receipt.Add(CleanCashXCCSPProtocol.AddElement('SerialNo', Format(CleanCashTransactionRequest."POS Entry No.", 0, '<Integer>'), XmlNs));
        Receipt.Add(CleanCashXCCSPProtocol.AddElement('Date',
            StrSubstNo(DateTimeLbl,
                Format(DT2Date(CleanCashTransactionRequest."Receipt DateTime"), 0, '<Filler Character,0><Year4><Month,2><Day,2>'),
                Format(DT2Time(CleanCashTransactionRequest."Receipt DateTime"), 0, '<Filler Character,0><Hours24,2><Minutes,2>')), XmlNs));

        Receipt.Add(CleanCashXCCSPProtocol.AddElement('ReceiptId', CleanCashTransactionRequest."Receipt Id", XmlNs));
        Receipt.Add(CleanCashXCCSPProtocol.AddElement('PosId', CleanCashTransactionRequest."Pos Id", XmlNs));
        Receipt.Add(CleanCashXCCSPProtocol.AddElement('OrgNo', CleanCashTransactionRequest."Organisation No.", XmlNs));
        Receipt.Add(CleanCashXCCSPProtocol.AddElement('ReceiptTotal', Format(CleanCashTransactionRequest."Receipt Total", 0, '<Precision,2:2><Sign><Integer><Comma,,><Decimals>'), XmlNs));
        Receipt.Add(CleanCashXCCSPProtocol.AddElement('NegativeTotal', Format(CleanCashTransactionRequest."Negative Total", 0, '<Precision,2:2><Sign><Integer><Comma,,><Decimals>'), XmlNs));
        "NPR CleanCash Receipt Type".Names().Get("NPR CleanCash Receipt Type".Ordinals().IndexOf(CleanCashTransactionRequest."Receipt Type".AsInteger()), EnumName);
        Receipt.Add(CleanCashXCCSPProtocol.AddElement('ReceiptType', EnumName, XmlNs));

        Receipt.Add(VatList);

        Data := XmlElement.Create('data', XmlNs);
        Data.Add(Receipt);

        Envelope := XmlElement.Create('request', XmlNs);
        Envelope.Add(CleanCashXCCSPProtocol.AddElement('type', 'RegisterReceipt', XmlNs));
        Envelope.Add(Data);

        XmlDoc := XmlDocument.Create();
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'ISO-8859-1', 'yes'));

        XmlDoc.Add(Envelope);

        exit(true);
    end;

    procedure SerializeResponse(var CleanCashTransactionRequest: Record "NPR CleanCash Trans. Request"; XmlDoc: XmlDocument; var ResponseEntryNo: Integer) Success: Boolean
    var
        CleanCashResponse: Record "NPR CleanCash Trans. Response";
        CleanCashXCCSPProtocol: Codeunit "NPR CleanCash XCCSP Protocol";
        EnumAsText: Text;
        DataElement: XmlElement;
        Element: XmlElement;
        NamespaceManager: XmlNamespaceManager;
        Node: XmlNode;
    begin

        CleanCashResponse.SetFilter("Request Entry No.", '=%1', CleanCashTransactionRequest."Entry No.");
        if (not CleanCashResponse.FindLast()) then
            CleanCashResponse."Request Entry No." := CleanCashTransactionRequest."Entry No.";
        CleanCashResponse."Response No." += 1;
        CleanCashResponse.Init();

        CleanCashResponse."Response Datetime" := CurrentDateTime();

        NamespaceManager.NameTable(XmlDoc.NameTable());
        NamespaceManager.AddNamespace('cc', CleanCashXCCSPProtocol.GetNamespace());
        XmlDoc.GetRoot(Element);

        if (Element.SelectSingleNode('cc:type[text()="Fault"]', NamespaceManager, Node)) then
            CleanCashXCCSPProtocol.SerializeFaultInfo(Element, NamespaceManager, CleanCashResponse);

        if (Element.SelectSingleNode('cc:type[text()="RegisterReceiptResponse"]', NamespaceManager, Node)) then begin

            if (Element.SelectSingleNode('cc:data', NamespaceManager, Node)) then begin
                DataElement := Node.AsXmlElement();
                CleanCashXCCSPProtocol.GetElementInnerText(NamespaceManager, DataElement, 'cc:RegisterResult/cc:Code', CleanCashResponse."CleanCash Code");
                CleanCashXCCSPProtocol.GetElementInnerText(NamespaceManager, DataElement, 'cc:RegisterResult/cc:UnitId', CleanCashResponse."CleanCash Unit Id");

                CleanCashXCCSPProtocol.GetElementInnerText(NamespaceManager, DataElement, 'cc:RegisterResult/cc:UnitMainStatus', EnumAsText);
                if (not Evaluate(CleanCashResponse."CleanCash Main Status", EnumAsText)) then
                    CleanCashResponse."CleanCash Main Status" := CleanCashResponse."CleanCash Main Status"::NO_VALUE;

                CleanCashXCCSPProtocol.GetElementInnerText(NamespaceManager, DataElement, 'cc:RegisterResult/cc:UnitStorageStatus', EnumAsText);
                if (not Evaluate(CleanCashResponse."CleanCash Storage Status", EnumAsText)) then
                    CleanCashResponse."CleanCash Storage Status" := CleanCashResponse."CleanCash Storage Status"::NO_VALUE;

                if (CleanCashTransactionRequest."Receipt Type" = CleanCashTransactionRequest."Receipt Type"::ovning) then
                    CleanCashResponse."CleanCash Code" := '*** CleanCash Training Mode *** CleanCash Training Mode ***';

                CleanCashTransactionRequest."CleanCash Code" := CleanCashResponse."CleanCash Code";
                CleanCashTransactionRequest."CleanCash Unit Id" := CleanCashResponse."CleanCash Unit Id";
                CleanCashTransactionRequest."CleanCash Main Status" := CleanCashResponse."CleanCash Main Status";
                CleanCashTransactionRequest."CleanCash Storage Status" := CleanCashResponse."CleanCash Storage Status";
            end;
        end;

        exit(CleanCashResponse.Insert());

    end;

    procedure AddToPrintBuffer(var LinePrintMgt: Codeunit "NPR RP Line Print Mgt."; var CleanCashTransaction: Record "NPR CleanCash Trans. Request")
    var
        CleanCashTransactionCopy: Record "NPR CleanCash Trans. Request";
        ReceiptNoLbl: Label 'Receipt No.';
        SerialNoLbl: Label 'Serial No.';
        ControlCodeLbl: Label 'Control Code:';
    begin

        CleanCashTransactionCopy.Copy(CleanCashTransaction);

        if (not CleanCashTransaction.HasFilter()) then
            CleanCashTransactionCopy.SetRecFilter();

        if (not CleanCashTransactionCopy.FindSet()) then
            exit;

        LinePrintMgt.NewLine();
        repeat
            LinePrintMgt.AddTextField(1, 0, ReceiptNoLbl);
            LinePrintMgt.AddTextField(2, 2, CleanCashTransactionCopy."Receipt Id");
            LinePrintMgt.NewLine();

            LinePrintMgt.AddTextField(1, 0, SerialNoLbl);
            LinePrintMgt.AddTextField(2, 2, CleanCashTransactionCopy."CleanCash Unit Id");
            LinePrintMgt.NewLine();

            LinePrintMgt.AddLine(ControlCodeLbl);
            LinePrintMgt.AddLine(CopyStr(CleanCashTransactionCopy."CleanCash Code", 1, 30));
            LinePrintMgt.AddLine(CopyStr(CleanCashTransactionCopy."CleanCash Code", 31, 60));
            LinePrintMgt.NewLine();
        until (CleanCashTransactionCopy.Next() = 0);

    end;
}