codeunit 6014527 "Credit Card Protocol Helper"
{
    // NPR5.00/NPKNAV/20160113  CASE 220508 NP Retail 2016
    // NPR5.27/JHL/20161006 CASE 254661 Included the function CutCardPan to cut the CardPan or givecard to the right length.
    // NPR5.36/TJ  /20170918  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.40/MMV /20180315 CASE 290734 Support for new EFT BIN table
    // NPR5.42/MMV /20180507 CASE 306689 Added support for location specific payment type.
    //                                   Commented out deprecated function ResolvePrefix()


    trigger OnRun()
    begin
    end;

    procedure CreateErrorReceipt(SaleLinePOS: Record "Sale Line POS";ResultText: Text[100])
    var
        CompanyInformation: Record "Company Information";
        SalePOS: Record "Sale POS";
        Transaction: Record "EFT Receipt";
        ResultAmount: Decimal;
        EntryNo: Integer;
    begin
        SalePOS.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.");
        CompanyInformation.Get;
        Evaluate(ResultAmount,SelectStr(2,ResultText));

        Transaction.LockTable;
        Transaction.SetCurrentKey("Register No.","Sales Ticket No.",Type);
        if (Transaction.FindLast()) then;
        EntryNo := Transaction."Entry No.";

        CreateTransactionLine(SalePOS,SaleLinePOS,EntryNo,0,CompanyInformation.Name);
        CreateTransactionLine(SalePOS,SaleLinePOS,EntryNo,0,'************************');
        CreateTransactionLine(SalePOS,SaleLinePOS,EntryNo,0,'Bel¢b (DKK): ' + Format(ResultAmount / 100,0,'<Sign><Integer><Decimals,3>'));
        CreateTransactionLine(SalePOS,SaleLinePOS,EntryNo,0,'Kort: ' + SelectStr(1,ResultText));
        CreateTransactionLine(SalePOS,SaleLinePOS,EntryNo,0,'GENNEMF¥RT');
        CreateTransactionLine(SalePOS,SaleLinePOS,EntryNo,0,'Terminalbon mangler');
        CreateTransactionLine(SalePOS,SaleLinePOS,EntryNo,0,'************************');
        CreateTransactionLine(SalePOS,SaleLinePOS,EntryNo,3,SelectStr(1,ResultText));
    end;

    procedure FindPaymentType(CardPan: Code[20];var PaymentTypePOS: Record "Payment Type POS";LocationCode: Code[10]): Boolean
    var
        PaymentTypePrefix: Record "Payment Type - Prefix";
        "Filter": Text[30];
        Len: Integer;
    begin
        //-NPR5.42 [306689]
        //IF MatchEFTBINRange(CardPan, PaymentTypePOS) THEN
        if MatchEFTBINRange(CardPan, PaymentTypePOS, LocationCode) then
        //+NPR5.42 [306689]
          exit(true);

        Filter := CardPan;
        Len := StrLen(Filter);
        while Len > 0 do begin
          PaymentTypePrefix.SetRange(PaymentTypePrefix.Prefix,Filter);
          if PaymentTypePrefix.Find('-') then
            repeat
              PaymentTypePOS.Reset;
              PaymentTypePOS.SetCurrentKey("No.","Via Terminal");
              PaymentTypePOS.SetRange("No.",PaymentTypePrefix."Payment Type");
              PaymentTypePOS.SetRange("Via Terminal",true);
        //-NPR5.42 [306689]
        //      IF PaymentTypePOS.FIND('-') THEN BEGIN
        //        EXIT(TRUE);
        //      END;
              PaymentTypePOS.SetRange("Location Code", LocationCode);
              if PaymentTypePOS.FindFirst then
                exit(true)
              else if LocationCode <> '' then begin
                PaymentTypePOS.SetRange("Location Code", '');
                if PaymentTypePOS.FindFirst then
                  exit(true);
              end;
        //+NPR5.42 [306689]
            until (PaymentTypePrefix.Next = 0);
          Len := Len - 1;
          Filter := CopyStr(Filter,1,Len);
        end;
        exit(false);
    end;

    procedure ResolvePrefix(PAN: Code[30];var PaymentNo: Code[10]): Code[20]
    var
        PaymentTypePOS: Record "Payment Type POS";
        PaymentTypePrefix: Record "Payment Type - Prefix";
        "Filter": Code[30];
        Len: Integer;
    begin
        //-NPR5.42 [306689]
        // Filter := PAN;
        // Len := STRLEN(Filter);
        // WHILE Len > 0 DO BEGIN
        //  PaymentTypePrefix.SETRANGE(Prefix,Filter);
        //  IF PaymentTypePrefix.FIND('-') THEN
        //    REPEAT
        //      PaymentTypePOS.RESET;
        //      PaymentTypePOS.SETCURRENTKEY("No.","Via Terminal");
        //      PaymentTypePOS.SETRANGE("No.",PaymentTypePrefix."Payment Type");
        //      PaymentTypePOS.SETRANGE("Via Terminal",TRUE);
        //      IF PaymentTypePOS.FIND('-') THEN BEGIN
        //        PaymentNo := PaymentTypePOS."No.";
        //        EXIT(PaymentTypePOS."No.");
        //      END;
        //    UNTIL (PaymentTypePrefix.NEXT = 0);
        //  Len := Len - 1;
        //  Filter := COPYSTR(Filter,1,Len);
        // END;
        // EXIT('');
        //+NPR5.42 [306689]
    end;

    procedure CalcTransFee(PaymentTypePOS: Record "Payment Type POS";Amount: Decimal;NeedConfirm: Boolean) Fee: Decimal
    var
        TxtFee: Label 'Should fee of %1 be used?';
        AddFee: Boolean;
        FeeAmount: Decimal;
    begin
        if PaymentTypePOS."Rounding Precision" = 0 then
          PaymentTypePOS."Rounding Precision" := 0.25;

        if ((Amount > PaymentTypePOS."Maximum Amount") and (PaymentTypePOS."Maximum Amount" > 0)) or
           ((Amount < PaymentTypePOS."Minimum Amount") and (PaymentTypePOS."Minimum Amount" > 0)) then
          FeeAmount := 0.0
        else
          FeeAmount := Round(Amount * PaymentTypePOS."Fee Pct." / 100 + PaymentTypePOS."Fixed Fee",PaymentTypePOS."Rounding Precision");

        AddFee := true;
        if NeedConfirm then
          AddFee := DIALOG.Confirm(StrSubstNo(TxtFee,FeeAmount),true);

        if AddFee then
          exit(FeeAmount)
        else
          exit(0.0);
    end;

    local procedure CreateTransactionLine(SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS";var EntryNo: Integer;Type: Integer;ReceiptText: Text)
    var
        CreditCardTransaction: Record "EFT Receipt";
    begin
        CreditCardTransaction.Init;
        CreditCardTransaction."Entry No." := EntryNo;
        CreditCardTransaction.Date := Today;
        CreditCardTransaction.Type := Type;
        CreditCardTransaction."Transaction Time"  := Time;
        CreditCardTransaction.Text := ReceiptText;
        CreditCardTransaction."Register No." := SalePOS."Register No.";
        CreditCardTransaction."Sales Ticket No." := SalePOS."Sales Ticket No.";
        CreditCardTransaction."Line No." := SaleLinePOS."Line No.";
        CreditCardTransaction."Salesperson Code" := SalePOS."Salesperson Code";
        CreditCardTransaction.Insert;

        EntryNo += 100;
    end;

    procedure CutCardPan(CardPan: Code[100]): Code[30]
    var
        TextPosition: Integer;
    begin
        //-NPR5.27
        if StrLen(CardPan) = 0 then
          exit(CardPan);

        TextPosition := StrPos(CardPan,'D');
        if TextPosition <> 0 then
          exit(CopyStr(CardPan,1,TextPosition - 1));

        exit(CardPan)
        //+NPR5.27
    end;

    local procedure MatchEFTBINRange(CardPan: Code[20];var PaymentTypePOS: Record "Payment Type POS";LocationCode: Code[10]): Boolean
    var
        EFTBINRange: Record "EFT BIN Range";
        EFTBINGroup: Record "EFT BIN Group";
        EFTBINGroupPaymentLink: Record "EFT BIN Group Payment Link";
    begin
        if EFTBINRange.IsEmpty then
          exit(false); //Fallback to old prefix table

        if not EFTBINRange.FindMatch(CardPan) then
          exit(false);

        //-NPR5.42 [306689]
        // IF NOT EFTBINGroup.GET(EFTBINRange."BIN Group Code") THEN
        //  EXIT(FALSE);
        //
        // EXIT(PaymentTypePOS.GET(EFTBINGroup."Payment Type POS"));

        if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", LocationCode) then
          if LocationCode = '' then
            exit(false)
          else
            if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", '') then
              exit(false);

        exit(PaymentTypePOS.Get(EFTBINGroupPaymentLink."Payment Type POS"));
        //+NPR5.42 [306689]
    end;
}

