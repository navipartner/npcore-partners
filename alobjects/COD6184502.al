codeunit 6184502 "CleanCash AuditRoll Mgt."
{
    // NPR4.21/JHL/20160302 CASE 222417 Create to manage the CleanCash Audit Roll
    // NPR5.26/JHL/20160909 CASE 244106 Add the "CleanCash Reciept No." to the CleanCash AuditRoll. Created funciton GetUniqueTicketNo(...)

    TableNo = "Audit Roll";

    trigger OnRun()
    var
        CleanCashCommunication: Codeunit "CleanCash Communication";
    begin
        Rec.SetRange("Sale Type", Rec."Sale Type"::Sale);

        if Rec. FindFirst then begin
          CreateCleanCashAuditRollRow(Rec);
          CleanCashCommunication.RunSingelSalesTicket(Rec."Sales Ticket No.",Rec."Register No.");
        end;
    end;

    local procedure CreateCleanCashAuditRollRow(var AuditRoll: Record "Audit Roll")
    var
        CleanCashAuditRoll: Record "CleanCash Audit Roll";
        VatRates: array [4] of Decimal;
        VatAmounts: array [4] of Decimal;
        VatRatesNeg: array [4] of Decimal;
        VatAmountsNeg: array [4] of Decimal;
        ReceiptTotal: Decimal;
        ReceiptTotalNeg: Decimal;
        ReceiptTime: Text[100];
        Loops: Integer;
        i: Integer;
        TicketType: Option Sale,Mix,Return;
    begin

        if AuditRoll.FindSet then repeat

          if AuditRoll."VAT %" > 0 then begin
            for i := 1 to 4 do begin
              if (VatRates[i] = 0) or (AuditRoll."VAT %" = VatRates[i]) then begin
                if AuditRoll."Amount Including VAT" > 0 then begin
                  VatRates[i] := AuditRoll."VAT %";
                  VatAmounts[i] += AuditRoll."Amount Including VAT" - AuditRoll."VAT Base Amount";
                end else begin
                  VatRatesNeg[i] := AuditRoll."VAT %";
                  VatAmountsNeg[i] += AuditRoll."Amount Including VAT" - AuditRoll."VAT Base Amount";
                end;
                i := 4;
              end;
            end;
          end;

          if AuditRoll."Amount Including VAT" > 0 then
            ReceiptTotal += AuditRoll."Amount Including VAT"
          else
            ReceiptTotalNeg += AuditRoll."Amount Including VAT";

        until AuditRoll.Next = 0;

        if (ReceiptTotal = 0) and (ReceiptTotalNeg = 0) then
          exit;

        ReceiptTime := Format(AuditRoll."Sale Date",0,'<Year4><Month,2><Day,2>');
        ReceiptTime := ReceiptTime + Format(AuditRoll."Closing Time",0,'<Hours24,2><Filler Character,0><Minutes,2><Filler Character,0>');


        Loops := 1;
        TicketType := TicketType::Sale;

        if ReceiptTotalNeg < 0 then begin
          if ReceiptTotal <> 0 then begin //Must create two reciept, one for the return and one for the rest.
            Loops := 2;
            TicketType := TicketType::Mix;
          end else begin
            TicketType := TicketType::Return;
            Loops := 1;
          end;
        end;

        for i := 1 to Loops do begin
          Clear(CleanCashAuditRoll);

          CleanCashAuditRoll.SetRange("Register No.", AuditRoll."Register No.");
          CleanCashAuditRoll.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
          CleanCashAuditRoll.SetRange("Sale Date",AuditRoll."Sale Date");

          if not  CleanCashAuditRoll.FindFirst then begin
            CleanCashAuditRoll."Register No." := AuditRoll."Register No.";
            CleanCashAuditRoll."Sales Ticket No." := AuditRoll."Sales Ticket No.";
            CleanCashAuditRoll."Sale Date" := AuditRoll."Sale Date";
          end;

          CleanCashAuditRoll.VatAmount4 := TicketType;
          CleanCashAuditRoll."Closing Time" := AuditRoll."Closing Time";

          if ((TicketType = TicketType::Mix) and (i = 2)) or (TicketType = TicketType::Return) then begin
            CleanCashAuditRoll."Receipt Total" := ReceiptTotalNeg;
            CleanCashAuditRoll."Receipt Total Neg" := ReceiptTotalNeg * -1;
            SetVatInformation(CleanCashAuditRoll,VatRatesNeg, VatAmountsNeg);
            CleanCashAuditRoll.Type := CleanCashAuditRoll.Type::Return;
          end else begin
            CleanCashAuditRoll."Receipt Total" := ReceiptTotal;
            CleanCashAuditRoll."Receipt Total Neg" := 0;
            SetVatInformation(CleanCashAuditRoll,VatRates, VatAmounts);
            CleanCashAuditRoll.Type := CleanCashAuditRoll.Type::Sale;
          end;

          //-NPR5.26
          CleanCashAuditRoll."CleanCash Reciept No." := GetUniqueTicketNo(AuditRoll."Register No.");
          //+NPR5.26

          if not CleanCashAuditRoll.Insert then
            CleanCashAuditRoll.Modify;

          Commit;
        end;
    end;

    procedure CreateCleanCashAuditRollRows()
    var
        AuditRoll: Record "Audit Roll";
        AuditRoll2: Record "Audit Roll";
        CleanCashAuditRoll: Record "CleanCash Audit Roll";
        LastSalesTicket: Code[20];
    begin
        //Only used under test, since all CleanCash audit Roll, should be created as the sale transaction is performed.
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);

        if AuditRoll.FindSet then repeat
          if LastSalesTicket <> AuditRoll."Sales Ticket No." then begin
            CleanCashAuditRoll.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
            CleanCashAuditRoll.SetRange("Register No.", AuditRoll."Register No.");
            CleanCashAuditRoll.SetRange("Sale Date", AuditRoll."Sale Date");
            LastSalesTicket := AuditRoll."Sales Ticket No.";
            if not CleanCashAuditRoll.FindFirst then begin
              AuditRoll2.Copy(AuditRoll);
              AuditRoll2.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
              AuditRoll2.SetRange("Register No.", AuditRoll."Register No.");
              AuditRoll2.SetRange("Sale Date", AuditRoll."Sale Date");
              CreateCleanCashAuditRollRow(AuditRoll2);
            end;
         end;
        until AuditRoll.Next = 0;
    end;

    local procedure SetVatInformation(var CleanCashAuditRoll: Record "CleanCash Audit Roll";VatRates: array [4] of Decimal;VatAmounts: array [4] of Decimal)
    begin
        CleanCashAuditRoll.VatRate1 := VatRates[1];
        CleanCashAuditRoll.VatAmount1 := VatAmounts[1];
        CleanCashAuditRoll.VatRate2 := VatRates[2];
        CleanCashAuditRoll.VatAmount2 := VatAmounts[2];
        CleanCashAuditRoll.VatRate3 := VatRates[3];
        CleanCashAuditRoll.VatAmount3 := VatAmounts[3];
        CleanCashAuditRoll.VatRate4 := VatRates[4];
        CleanCashAuditRoll.VatAmount4 := VatAmounts[4];
    end;

    local procedure GetUniqueTicketNo(RegisterNo: Code[20]) TicketNo: Code[10]
    var
        CleanCashRegister: Record "CleanCash Register";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        //-NPR5.26
        CleanCashRegister.Get(RegisterNo);
        TicketNo := NoSeriesManagement.GetNextNo(CleanCashRegister."CleanCash No. Series",Today, true);
        //+NPR5.26
    end;
}

