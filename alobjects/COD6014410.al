codeunit 6014410 "POS Apply Customer Entries"
{
    // --->> NPR Version 1.8 md
    // Nyoprettet(gl bogf�r revisionsrulle passivt er hermed erstattet)
    // <<--- NPR Version 1.8 slut
    // 
    // //Ohm - 02/08/2006 - code rewritten
    // NPR5.29/TJ  /20170118 CASE 263523 Changed local variable UdlignDebPost in OnRun to point to new page 6014493
    // NPR5.29/JDH /20170126 CASE 264618 Deleted unused functions
    // NPR5.36/TJ  /20170920 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.38/MHA /20180105  CASE 301053 Add ConstValue to Text Constants Txt001 and Txt002
    // NPR5.43/THRO/20180604  CASE 313966 Added option to set filters on Cust. Ledger Entry
    // NPR5.48/TSA /20190207 CASE 344901 Added UpdateAmounts to get VAT calculated correctly when ApplyCustomerEntries() (legacy)
    // NPR5.50/MMV /20181114 CASE 300557 Added function BalanceInvoice from CU 6014505.
    //                                   Moved OnRun trigger to separate function.
    // NPR5.52/TJ  /20191003 CASE 335729 Fixed the filtering order when using SETVIEW
    // NPR5.53/MMV /20200108 CASE 373453 Save reference to posted document when balancing it.

    Permissions = TableData "Cust. Ledger Entry"=rimd;
    TableNo = "Sale Line POS";

    trigger OnRun()
    var
        SaleLinePOS: Record "Sale Line POS";
        CustLedgEntry: Record "Cust. Ledger Entry";
        Currency: Record Currency;
        POSApplyCustomerEntries: Page "POS Apply Customer Entries";
        CurrencyCode: Code[10];
        OK: Boolean;
        AccountType: Option "G/L",Customer,Vendor,Bank,"Fixed Asset";
        "Field": Record "Field";
        LineAmount: Decimal;
        LineNo: Integer;
    begin
        //-NPR5.50 [300557]
        ApplyCustomerEntriesLegacy(Rec);
        //+NPR5.50 [300557]
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Txt001: Label 'Application cancelled.';
        Txt002: Label '%1 in %2 will be change from %3 to %4.\Continue?';
        Txt003: Label 'Balancing of %1.';
        CustLedgerEntryView: Text;
        ERROR_DOUBLE_ENTRY: Label 'Error. Document %1 %2 is already selected for balancing.';
        CONFIRM_BALANCE: Label 'Do you wish to apply %1 %2 for customer %3?';
        BALANCING_OF: Label 'Balancing of %1';

    procedure ApplyCustomerEntriesLegacy(var SaleLinePOSIn: Record "Sale Line POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        CustLedgEntry: Record "Cust. Ledger Entry";
        Currency: Record Currency;
        POSApplyCustomerEntries: Page "POS Apply Customer Entries";
        CurrencyCode: Code[10];
        OK: Boolean;
        AccountType: Option "G/L",Customer,Vendor,Bank,"Fixed Asset";
        "Field": Record "Field";
        LineAmount: Decimal;
        LineNo: Integer;
    begin
        with SaleLinePOSIn do begin
          if CustLedgerEntryView <> '' then
            CustLedgEntry.SetView(CustLedgerEntryView);

          CustLedgEntry.SetCurrentKey("Customer No.",Open,Positive);
          CustLedgEntry.SetRange("Customer No.","No.");
          CustLedgEntry.SetRange(Open,true);
          if "Buffer ID" = '' then
            TestField("Register No.");
          TestField("Sales Ticket No.");
          "Buffer ID" := StrSubstNo('%1-%2',"Register No.","Sales Ticket No.");
          Commit;

          SaleLinePOS := SaleLinePOSIn;

          POSApplyCustomerEntries.SetSalesLine(SaleLinePOS,SaleLinePOS.FieldNo("Buffer ID"));
          POSApplyCustomerEntries.SetRecord(CustLedgEntry);
          POSApplyCustomerEntries.SetTableView(CustLedgEntry);
          POSApplyCustomerEntries.LookupMode(true);
          OK := POSApplyCustomerEntries.RunModal = ACTION::LookupOK;
          Clear(POSApplyCustomerEntries);
          if not OK then
            exit;

          CustLedgEntry.Reset;
          CustLedgEntry.SetCurrentKey("Customer No.",Open,Positive);
          CustLedgEntry.SetRange("Customer No.","No.");
          CustLedgEntry.SetRange(Open,true);
          CustLedgEntry.SetRange("Applies-to ID",UserId);

          DeleteExistingLines(SaleLinePOSIn);
          if Amount = 0 then
            Delete;

          LineNo := GetLineNo(SaleLinePOSIn);

          if CustLedgEntry.Find('-') then begin
            CurrencyCode := CustLedgEntry."Currency Code";
            repeat
              LineNo += 1;
              SaleLinePOS.Init;
              SaleLinePOS := SaleLinePOSIn;
              SaleLinePOS."Line No." := LineNo;
              SaleLinePOS.Insert(true);
              CheckCurrency(CurrencyCode,CustLedgEntry."Currency Code",AccountType::Customer,true);

              CustLedgEntry.CalcFields("Remaining Amount");
              CustLedgEntry."Remaining Amount" := Round(CustLedgEntry."Remaining Amount",Currency."Amount Rounding Precision");
              CustLedgEntry."Original Pmt. Disc. Possible" := Round(CustLedgEntry."Original Pmt. Disc. Possible",Currency."Amount Rounding Precision");

              if (Type = Type::Customer) and
                ("Sale Type" = "Sale Type"::Deposit) and
                  (CustLedgEntry."Document Type" = CustLedgEntry."Document Type"::Invoice) and
                    (Date <= CustLedgEntry."Pmt. Discount Date") then
                LineAmount := (CustLedgEntry."Remaining Amount" - CustLedgEntry."Original Pmt. Disc. Possible")
              else
                LineAmount := CustLedgEntry."Remaining Amount";

               SaleLinePOS."Buffer Document Type" := CustLedgEntry."Document Type";
               SaleLinePOS."Buffer Document No." := CustLedgEntry."Document No.";
               SaleLinePOS.Validate(Quantity,1);
               SaleLinePOS.Validate("Unit Price",LineAmount);
               SaleLinePOS.Description := StrSubstNo(Txt003,CustLedgEntry.Description);
               SaleLinePOS.UpdateAmounts (SaleLinePOS);
               SaleLinePOS.Modify;
             until CustLedgEntry.Next = 0;

            if "Currency Code" <> CurrencyCode then
              if Amount = 0 then begin
                if not Confirm(Txt002,true,
                  FieldName("Currency Code"),TableName,"Currency Code",
                  CustLedgEntry."Currency Code") then
                  Error(Txt001);
                "Currency Code" := CustLedgEntry."Currency Code"
              end else
                CheckCurrency("Currency Code",CustLedgEntry."Currency Code",AccountType::Customer,true);
          end else
            "Buffer ID" := '';
        end;
    end;

    procedure DeleteExistingLines(var SaleLinePOS: Record "Sale Line POS")
    begin
        SaleLinePOS.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Buffer Document No.",'<>%1','');
        SaleLinePOS.DeleteAll;
    end;

    procedure GetLineNo(var SaleLinePOS: Record "Sale Line POS") LineNo: Integer
    begin
        SaleLinePOS.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
        SaleLinePOS.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Buffer Document No.",'<>%1','');
        if SaleLinePOS.Find('+') then
          LineNo := SaleLinePOS."Line No."
        else
          LineNo := 10000;
    end;

    procedure CheckCurrency(ApplicationCurrencyCode: Code[10];CompareToCurrencyCode: Code[10];AccountType: Option "G/L",Customer,Vendor,Bank,"Fixed Asset";ShowError: Boolean): Boolean
    var
        Currency: Record Currency;
        Currency2: Record Currency;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        CurrencyApplication: Option "None",EMU,All;
        Txt001: Label 'All Ledger Entries must be the same currency';
        Txt002: Label 'All Ledger Entries must be the same currency,or in one or more of the EMU-Currencies';
        Txt003: Label 'All Ledger Entries on a Vendor must be the same currency';
    begin
        if (ApplicationCurrencyCode = CompareToCurrencyCode) then
          exit(true);

        case AccountType of
          AccountType::Customer:
            begin
              SalesReceivablesSetup.Get;
              CurrencyApplication := SalesReceivablesSetup."Appln. between Currencies";
              case CurrencyApplication of
                CurrencyApplication::None:
                  begin
                    if ApplicationCurrencyCode <> CompareToCurrencyCode then
                      if ShowError then
                        Error(Txt001)
                      else
                        exit(false);
                  end;
                CurrencyApplication::EMU:
                  begin
                    GeneralLedgerSetup.Get;
                    if not Currency.Get(ApplicationCurrencyCode) then
                      Currency."EMU Currency" := GeneralLedgerSetup."EMU Currency";
                    if not Currency2.Get(CompareToCurrencyCode) then
                      Currency2."EMU Currency" := GeneralLedgerSetup."EMU Currency";
                    if not Currency."EMU Currency" or not Currency2."EMU Currency" then
                      if ShowError then
                        Error(Txt002)
                      else
                        exit(false);
                  end;
              end;
            end;
          AccountType::Vendor:
            begin
              PurchasesPayablesSetup.Get;
              CurrencyApplication := PurchasesPayablesSetup."Appln. between Currencies";
              case CurrencyApplication of
                CurrencyApplication::None:
                  begin
                    if ApplicationCurrencyCode <> CompareToCurrencyCode then
                      if ShowError then
                        Error(Txt003)
                      else
                        exit(false);
                  end;
                CurrencyApplication::EMU:
                  begin
                    GeneralLedgerSetup.Get;
                    if not Currency.Get(ApplicationCurrencyCode) then
                      Currency."EMU Currency" := GeneralLedgerSetup."EMU Currency";
                    if not Currency2.Get(CompareToCurrencyCode) then
                      Currency2."EMU Currency" := GeneralLedgerSetup."EMU Currency";
                    if not Currency."EMU Currency" or not Currency2."EMU Currency" then
                      if ShowError then
                        Error(Txt002)
                      else
                        exit(false);
                  end;
              end;
            end;
        end;

        exit(true);
    end;

    procedure SetCustLedgerEntryView(TableView: Text)
    begin
        //-NPR5.43 [313966]
        CustLedgerEntryView := TableView;
        //+NPR5.43 [313966]
    end;

    procedure SelectCustomerEntries(var POSSession: Codeunit "POS Session";CustLedgerEntryView: Text)
    var
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        SaleLinePOS: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
        CustLedgEntry: Record "Cust. Ledger Entry";
        POSApplyCustomerEntries: Page "POS Apply Customer Entries";
    begin
        //-NPR5.50 [300557]
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        
        SalePOS.TestField("Customer No.");
        SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
        //-NPR5.52 [335729]
        if CustLedgerEntryView <> '' then
          CustLedgEntry.SetView(CustLedgerEntryView);
        //+NPR5.52 [335729]
        CustLedgEntry.SetRange("Customer No.", SalePOS."Customer No.");
        CustLedgEntry.SetRange(Open, true);
        //-NPR5.52 [335729]
        /*
        IF CustLedgerEntryView <> '' THEN
          CustLedgEntry.SETVIEW(CustLedgerEntryView);
        */
        //+NPR5.52 [335729]
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Buffer ID" := StrSubstNo('%1-%2', SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
        POSApplyCustomerEntries.SetSalesLine(SaleLinePOS, SaleLinePOS.FieldNo("Buffer ID"));
        POSApplyCustomerEntries.SetRecord(CustLedgEntry);
        POSApplyCustomerEntries.SetTableView(CustLedgEntry);
        POSApplyCustomerEntries.LookupMode(true);
        if POSApplyCustomerEntries.RunModal <> ACTION::LookupOK then
          exit;
        DeleteExistingLines(SaleLinePOS);
        POSSaleLine.RefreshCurrent();
        
        CustLedgEntry.Reset;
        CustLedgEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgEntry.SetRange("Customer No.", SalePOS."Customer No.");
        CustLedgEntry.SetRange(Open, true);
        CustLedgEntry.SetRange("Applies-to ID", UserId);
        
        if not CustLedgEntry.FindSet then
          exit;
        
        repeat
          CreateApplyingPOSSaleLine(POSSaleLine, CustLedgEntry);
        until CustLedgEntry.Next = 0;
        //+NPR5.50 [300557]

    end;

    procedure BalanceDocument(var POSSession: Codeunit "POS Session";DocumentType: Integer;DocumentNo: Code[20];Silent: Boolean)
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SaleLinePOSCheck: Record "Sale Line POS";
        LineAmount: Decimal;
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.50 [300557]
        if DocumentNo = '' then
          exit;

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgerEntry.SetRange("Document Type",DocumentType);
        CustLedgerEntry.SetRange("Document No.",DocumentNo);
        if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then
          if SalePOS."Customer No." <> '' then
            CustLedgerEntry.SetRange("Customer No.",SalePOS."Customer No.");
        CustLedgerEntry.FindFirst;
        CustLedgerEntry.TestField(Open);

        if not Silent then
          if not Confirm(StrSubstNo(CONFIRM_BALANCE,CustLedgerEntry."Document Type",CustLedgerEntry."Document No.",CustLedgerEntry."Customer No."),true) then
            Error('');

        if SalePOS."Customer No." = '' then begin
          SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
          SalePOS.Validate("Customer No.",CustLedgerEntry."Customer No.");
          SalePOS.Modify;
          POSSale.RefreshCurrent();
        end else begin
          SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
          SalePOS.TestField("Customer No.",CustLedgerEntry."Customer No.");
        end;

        CreateApplyingPOSSaleLine(POSSaleLine, CustLedgerEntry);
        //+NPR5.50 [300557]
    end;

    local procedure CreateApplyingPOSSaleLine(var POSSaleLine: Codeunit "POS Sale Line";CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        SaleLinePOS: Record "Sale Line POS";
        LineAmount: Decimal;
    begin
        //-NPR5.50 [300557]
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        with SaleLinePOS do begin
          if (Type = Type::Customer) and
             ("Sale Type" = "Sale Type"::Deposit) and
               (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) and
                 (Date <= CustLedgerEntry."Pmt. Discount Date") then
                  LineAmount := (CustLedgerEntry."Remaining Amount" - CustLedgerEntry."Original Pmt. Disc. Possible")
          else
            LineAmount := CustLedgerEntry."Remaining Amount";

          "Sale Type" := "Sale Type"::Deposit;
          Type := SaleLinePOS.Type::Customer;
          Validate("No.", CustLedgerEntry."Customer No.");
          "Buffer Document Type" := CustLedgerEntry."Document Type";
          "Buffer Document No." := CustLedgerEntry."Document No.";
          "Buffer ID" := "Register No." + '-' + "Sales Ticket No.";

        //-NPR5.53 [373453]
          case CustLedgerEntry."Document Type" of
            CustLedgerEntry."Document Type"::Invoice :
              begin
                "Posted Sales Document Type" := "Posted Sales Document Type"::INVOICE;
                "Posted Sales Document No." := CustLedgerEntry."Document No.";
              end;
            CustLedgerEntry."Document Type"::"Credit Memo" :
              begin
                "Posted Sales Document Type" := "Posted Sales Document Type"::CREDIT_MEMO;
                "Posted Sales Document No." := CustLedgerEntry."Document No.";
              end;
          end;
        //+NPR5.53 [373453]

          Validate(Quantity, 1);
          Validate("Unit Price", LineAmount);
          Description := StrSubstNo(BALANCING_OF, CustLedgerEntry.Description);

          CheckCurrency(SaleLinePOS."Currency Code", CustLedgerEntry."Currency Code", 1, true);
          UpdateAmounts(SaleLinePOS);
        end;

        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
        //+NPR5.50 [300557]
    end;
}

