codeunit 6014624 "Touch Screen - Balancing Mgt."
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.11/VB/20150629 CASE 213003 Support for Web Client (JavaScript) client - additional changes
    // NPR4.14/VB/20150909 CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.14/VB/20150925 CASE 222938 Version increase for NaviPartner.POS.Web assembly reference(s), due to refactoring of QUANTITY_POS and QUANTITY_NEG functions.
    // NPR4.15/VB/20150930 CASE 224237 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR9   /VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.22/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.22/JDH/20160331 CASE 237986 EOD - find the date that the register open was done, and make that date the minimum date
    // NPR5.26/JDH /20160919 CASE 248141 Removed unused vars and textconstants
    // NPR5.31/VB/20170324 CASE 270035 Fixing issue with subtotal missing from register balancing page
    // NPR5.32/CLVA/20170526 CASE 268630 Fix wrong mapping of "Cost of Goods Sold"
    // NPR5.48/BHR /20181120 CASE 329505 Add amount pertaining to different Document types
    // NPR5.48/TJ  /20181120 CASE 336040 Fixed wrong counting of negative sales
    // NPR5.53/ALPO/20191024 CASE 371955 Rounding related fields moved to POS Posting Profiles
    // NPR5.53/ALPO/20191025 CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register
    // NPR5.54/TJ  /20200302 CASE 393478 Recoding for removed field "Finish Register Warning


    trigger OnRun()
    begin
    end;

    var
        Rec: Record "Payment Type POS";
        POSUnit: Record "POS Unit";
        Marshaller: Codeunit "POS Event Marshaller";
        "--- GENERAL": Integer;
        countedUltimo: Boolean;
        countedBank: Boolean;
        SalesPerson: Record "Salesperson/Purchaser";
        RegisterFilter: Text[250];
        ReceiptFilter: Text[250];
        closingType: Option Cancel,Normal,Saved;
        "Payment Type - Detailed": Record "Payment Type - Detailed";
        PaymentDiff: Decimal;
        PaymentDiffeuro: Decimal;
        PaymentAuditRoll: Decimal;
        d: Dialog;
        "--- DISCOUNT INFO": Integer;
        "Customer Discount (LCY)": Decimal;
        "Customer Discount %": Decimal;
        "BOM Discount (LCY)": Decimal;
        "BOM Discount %": Decimal;
        "Line Discount (LCY)": Decimal;
        "Line Discount %": Decimal;
        "Custom Discount (LCY)": Decimal;
        "Custom Discount %": Decimal;
        "Quantity Discount (LCY)": Decimal;
        "Quantity Discount %": Decimal;
        "Mix Discount (LCY)": Decimal;
        "Mix Discount %": Decimal;
        "Campaign Discount (LCY)": Decimal;
        "Campaign Discount %": Decimal;
        "--- SALES INFO": Integer;
        "Profit %": Decimal;
        "Profit Amount (LCY)": Decimal;
        "Net Cost (LCY)": Decimal;
        "Net Turnover (LCY)": Decimal;
        "Total Discount (LCY)": Decimal;
        "Total Discount %": Decimal;
        "Sales (Qty)": Integer;
        "Sales (LCY)": Decimal;
        "Sales Debit (Qty)": Integer;
        "Sales (Staff)": Decimal;
        CancelledSales: Integer;
        MoneyBagNo: Code[20];
        Gavekortdebet: Decimal;
        Kasse: Record Register;
        npc: Record "Retail Setup";
        "------ INFO": Integer;
        "Currencies Amount (LCY)": Decimal;
        "Credit Cards": Decimal;
        Primo: Decimal;
        VisaDk: Decimal;
        "Other Credit Cards": Decimal;
        Dank: Decimal;
        "Gift Vouchers": Decimal;
        "Customer Payments": Decimal;
        "Out Payments": Decimal;
        DebetSalg: Decimal;
        "Cash Movements": Decimal;
        Udstedtegavekort: Decimal;
        Udstedtetilgodebeviser: Decimal;
        "Credit Vouches": Decimal;
        InvoiceAmt: Decimal;
        OrderAmt: Decimal;
        ReturnAmt: Decimal;
        CRNoteAmt: Decimal;
        "--- END OF DAY": Integer;
        "Turnover (LCY)": Decimal;
        Check: Decimal;
        "Sum (LCY)": Decimal;
        "Diff (LCY)": Decimal;
        "Bank (LCY)": Decimal;
        "Ultimo (LCY)": Decimal;
        "Change (LCY)": Decimal;
        EuroAmount: Decimal;
        NegativeBonQty: Integer;
        NegativeBonAmount: Decimal;
        Statusbar: Text[100];
        "Diff (Euro)": Decimal;
        "Total (Euro)": Decimal;
        "Sum (Euro)": Decimal;
        Comment: Text[50];
        "--- Statistics": Integer;
        NoOfGoodsSold: Decimal;
        NoOfCashReciepts: Integer;
        NoOfCashBoxOpenings: Integer;
        NoOfReceiptCopies: Integer;
        VatRates: array [10] of Decimal;
        VatAmounts: array [10] of Decimal;
        "--- DotNet Vars": Integer;
        Text10600000: Label 'You cannot transfer more than %1 to the bank!';
        Text10600004: Label 'No money has been transferred to the bank. Continue?';
        Text10600005: Label 'No money has been transferred to next opening. Continue?';
        Text10600006: Label 'You have not filled out money bag no. Continue?';
        Text10600016: Label 'You cannot transfer more than %1 to the bank!';
        t009: Label 'Do you want to finish balancing?';
        t0095: Label 'Do you wish to cancel the register balancing?';
        t011: Label 'Amount';
        t018: Label 'Error';
        t020: Label 'The amount must be greater than 0';
        t021: Label 'Balance?';
        t022: Label 'Ultimo amount can not be negativ!';
        t023: Label 'Saved balancing';
        t024: Label 'A saved balancing exists.\Do you want to continue this counting?';
        t025: Label 'Cancel and save counting?';
        t026: Label 'Do you want to save the counting?';
        t029: Label 'Scan or type money bag no.';
        t030: Label 'Balancing';
        t031: Label 'Sales occur on this register after this balancing. Cancel and save countings.';
        text031: Label 'Exchange amount';
        text032: Label 'Change amount is disabled on this register. All money counted must be transferred to either the bank or ultimo amount!';
        text033: Label 'Count';
        text034: Label 'No coin types exist for %1';
        text035: Label 'New ultimo amount';
        text036: Label 'Ultimo amount can only be changed by counting';
        text037: Label 'The amount must be rounded to nearest %1';
        text038: Label 'Transfer to bank';
        text039: Label 'Transfer to bank can only be changed by counting';
        UI: Codeunit "POS Web UI Management";

    procedure Initialize()
    begin
        with Rec do begin
          SetCurrentKey("No.","Register No.");
          Ascending(true);
          SetRange("To be Balanced",true);
          if not Rec.FindSet() then;
        end;
    end;

    procedure SetPosition(Position: Text)
    begin
        with Rec do begin
          SetPosition(Position);
          Find;
        end;
    end;

    procedure OnAfterGetCurrRecord()
    begin
        with Rec do begin
          calcPaymentType;
          calcTotals;
        end;
    end;

    procedure DoTheBalancing()
    begin
        with Rec do begin
          Primo    := 0;
          "Turnover (LCY)"    := 0;
          VisaDk   := 0;
          Dank     := 0;
          "Other Credit Cards"   := 0;
          "Credit Cards" := 0;
          "Gift Vouchers"    := 0;
          "Credit Vouches"   := 0;
          EuroAmount := 0;
          Udstedtegavekort        :=0;
          Udstedtetilgodebeviser  :=0;
          "Customer Payments" := 0;
          "Out Payments" := 0;
          "Cash Movements" := 0;
          Statusbar  := '';

          npc.Get;

          SetFilter("Register No.", '%1|%2', '', Kasse."Register No.");
          SetFilter("Processing Type", '%1|%2', "Processing Type"::Cash, "Processing Type"::"Foreign Currency");

          initLines;

          case npc."Balancing Posting Type" of
            npc."Balancing Posting Type"::"PER REGISTER" : begin
                                           RegisterFilter := Kasse."Register No.";
                                           Initialisering(Kasse."Register No.");
                                           //Kasse.Status := Kasse.Status::"Under afslutning";
                                           //Kasse."Status Set By Sales Ticket" := Sale."Sales Ticket No.";
                                           //Kasse.MODIFY;
                                         end;
            npc."Balancing Posting Type"::TOTAL      : begin
                                           if Kasse.FindSet then repeat
                                             RegisterFilter += '|' + Kasse."Register No.";
                                             Initialisering(Kasse."Register No.");
                                             //Kasse.Status := Kasse.Status::"Under afslutning";
                                             //Kasse."Status Set By Sales Ticket" := Sale."Sales Ticket No.";
                                             //Kasse.MODIFY;
                                           until Kasse.Next = 0;
                                           RegisterFilter := DelStr(RegisterFilter,1,1);
                                         end;
          end;
          SetFilter("Register Filter", RegisterFilter);
        end;
    end;

    procedure pushAuditRoll()
    var
        formAR: Page "Audit Roll";
        ar: Record "Audit Roll";
    begin
        with Rec do begin
          ar.SetFilter("Register No.", GetFilter("Register Filter"));
          ar.SetFilter("Sales Ticket No.", ReceiptFilter);
          ar.SetRange("Sale Type", ar."Sale Type"::Payment);
          ar.SetRange(Type, ar.Type::Payment);
          //ar.SETFILTER("Salesperson Code", getfilter("Salesperson filter"));
          ar.SetRange("No.", "No.");
          if ar.FindLast then;

          formAR.SetExtFilters(true);
          formAR.SetTableView(ar);
          formAR.RunModal;
        end;
    end;

    procedure pushCount()
    var
        "Payment Type - Detailed": Record "Payment Type - Detailed";
        formBalLine: Page "Touch Screen - Balancing Line";
        Dec: Decimal;
    begin
        with Rec do begin
          "Payment Type - Detailed".SetRange("Payment No.", "No.");
          "Payment Type - Detailed".SetFilter("Register No.", GetFilter("Register No."));
          case "Payment Type - Detailed".Count of
            0 : Marshaller.DisplayError(text033,StrSubstNo(text034, Description),true);
            1 : begin
                  "Payment Type - Detailed".FindFirst;
                  Dec := "Payment Type - Detailed".Amount;
                  if not Marshaller.NumPad(Description,Dec,false,false) then
                    exit;
                  if Dec mod "Payment Type - Detailed".Weight <> 0 then
                    Marshaller.DisplayError(text033,text037,true);
                  "Payment Type - Detailed".Amount := Dec;
                  "Payment Type - Detailed".Modify;
                end;
            else
                begin
                  formBalLine.BalancingNow;
                  formBalLine.SetTableView("Payment Type - Detailed");
                  formBalLine.RunModal;
                end;
          end;
          calcTotals;
        end;
    end;

    procedure GetMoneyBagNo(): Code[20]
    begin
        exit(MoneyBagNo);
    end;

    procedure SetMoneyBagNo(MoneyBagNoIn: Code[20])
    begin
        MoneyBagNo := MoneyBagNoIn;
    end;

    procedure OnQueryClose(): Boolean
    begin
        if closingType = closingType::Normal then begin
          if "Ultimo (LCY)" < 0 then
            Marshaller.DisplayError(t021, t022, true);
          if (not Kasse."End of day - Exchange Amount") and ("Change (LCY)" <> 0) then
            Marshaller.DisplayError(text031,text032,true);

          //-NPR5.54 [393478]
          //IF npc."Finish Register Warning" AND ("Bank (LCY)" = 0) THEN BEGIN
          if "Bank (LCY)" = 0 then begin
          //+NPR5.54 [393478]
            if not Marshaller.Confirm(t021, Text10600004) then begin
              closingType := closingType::Cancel;
              exit(false);
            end;
            end;
          //-NPR5.54 [393478]
          //IF npc."Finish Register Warning" AND ("Ultimo (LCY)" = 0) THEN
          if "Ultimo (LCY)" = 0 then
          //+NPR5.54 [393478]
            if not Marshaller.Confirm(t021, Text10600005) then begin
              closingType := closingType::Cancel;
              exit(false);
            end;
          //-NPR5.54 [393478]
          //IF npc."Finish Register Warning" AND (MoneyBagNo = '') THEN
          if MoneyBagNo = '' then
          //+NPR5.54 [393478]
            if not Marshaller.Confirm(t021, Text10600006) then begin
              closingType := closingType::Cancel;
              exit(false);
            end;
          if not Marshaller.Confirm(t021, t009) then begin
            closingType := closingType::Cancel;
            exit(false);
          end;
        end else begin
          if not Marshaller.Confirm(t021, t0095) then begin
            closingType := closingType::Cancel;
            exit(false);
          end;
          if Marshaller.Confirm(t025, t026) then
            closingType := closingType::Saved
          else begin
            closingType := closingType::Cancel;
            "Payment Type - Detailed".SetRange("Register No.", Kasse."Register No.");
            "Payment Type - Detailed".DeleteAll(true);
            Commit;
          end;
        end;

        exit(true);
    end;

    procedure "------"()
    begin
    end;

    procedure Initialisering(RegNo: Code[20])
    var
        FirstReceiptNo: Code[20];
        "Audit Roll": Record "Audit Roll";
        "Payment Type POS": Record "Payment Type POS";
        ThisReceiptNo: Code[20];
        aReceiptType_count: array [10] of Integer;
        aReceiptType_amount: array [10] of Decimal;
        t001: Label 'Opening receipt is missing!';
        i: Integer;
        item: Record Item;
        countdec: Decimal;
        cust: Record Customer;
        lastReceipt: Code[10];
        t002: Label 'Please wait...';
        t003: Label 'Searching for last End of day';
        t004: Label 'Customer payments';
        t005: Label 'Counting';
        t006: Label 'Outpayments';
        t007: Label 'Debit sales';
        t008: Label 'Cash inventory';
        t009: Label 'Foreign currencies';
        t010: Label 'Terminal transactions';
        t011: Label 'Manual cards';
        t012: Label 'Other credit cards';
        t013: Label 'Cash terminal';
        t014: Label 'Received/issued gift vouchers';
        t015: Label 'Received/issued credit vouchers';
        t016: Label 'Number of sales, staff sale etc.';
        t017: Label 'Net turnover';
        t018: Label 'Net cost';
        t020: Label 'Total discount';
        t021: Label 'Negative sale (returned goods etc.)';
        t022: Label 'Custom discount type';
        t023: Label 'Profit';
        GvFilter: Text[30];
        GvActFilter: Text[30];
        AuditRoll2: Record "Audit Roll";
        TempAmount: Decimal;
        POSSetup: Codeunit "POS Setup";
    begin
        with Rec do begin
          npc.Get;
        
          d.Open(t005 + '\#1##############################\' + t002);
        
          DebetSalg        := 0;
          Udstedtegavekort := 0;
          "Gift Vouchers"            := 0;
          Gavekortdebet    := 0;
          "Turnover (LCY)"            := 0;
          EuroAmount       := 0;
          "Total (Euro)"        := 0;
          Dank             := 0;
          VisaDk           := 0;
          "Other Credit Cards"           := 0;
          "Credit Cards"         := 0;
          "Credit Vouches"             := 0;
          NegativeBonAmount := 0;
          NegativeBonQty    := 0;
         //-NPR5.48 [329505]
          OrderAmt := 0;
          InvoiceAmt := 0;
          ReturnAmt := 0;
          CRNoteAmt := 0;
         //+NPR5.48 [329505]
          Primo := Kasse."Opening Cash";
        
          //-NPR5.53 [371955]
          POSUnit.Get(Kasse."Register No.");
          POSSetup.SetPOSUnit(POSUnit);
          //+NPR5.53 [371955]
        
          /* FIND LAST OPEN/CLOSE */
        
          d.Update(1, t003);
        
          /* SET KEY ----- */
        
          "Audit Roll".SetCurrentKey("Register No.",
                                     "Sales Ticket No.",
                                     "Sale Type",
                                     Type);
        
          SetFilter("Register Filter", '%1', Kasse."Register No.");
        
          // Nies 16072007 - Speedup.
          "Audit Roll".SetRange("Register No.", Kasse."Register No.");
          "Audit Roll".SetFilter("Sales Ticket No.", '<>%1', '');
          ReceiptFilter := StrSubstNo('>=%1',Kasse."Opened on Sales Ticket");
          "Audit Roll".SetFilter("Sales Ticket No.", ReceiptFilter);
          //-NPR5.22
          //find the date that the register open was done, and make that date the minimum date
          if "Audit Roll".FindFirst then
            "Audit Roll".SetFilter("Sale Date", '%1..', "Audit Roll"."Sale Date");
          //+NPR5.22
        
          if "Audit Roll".FindLast then
            ReceiptFilter := StrSubstNo('..%1',"Audit Roll"."Sales Ticket No.");
          if not "Audit Roll".FindSet then
             Error(t001)
          else
            ReceiptFilter := StrSubstNo('%1' + ReceiptFilter,"Audit Roll"."Sales Ticket No.");
        
        
          SetFilter("Register Filter", RegisterFilter);
          SetFilter("Receipt Filter", ReceiptFilter);
        
          /* CALCULATIONS */
        
          if "Audit Roll".Next > 0 then begin
        
            /* SET INITIAL FILTERS */
        
            FirstReceiptNo := "Audit Roll"."Sales Ticket No.";
        
            "Audit Roll".SetFilter("Sales Ticket No." , ReceiptFilter);
        
            /* CUSTOMER PAYMENTS */
        
            d.Update(1, t004);
            "Audit Roll".SetRange( "Sale Type", "Audit Roll"."Sale Type"::Deposit );
            "Audit Roll".SetRange( Type, "Audit Roll".Type::Customer );
            "Audit Roll".CalcSums( "Amount Including VAT" );
            "Customer Payments" := "Audit Roll"."Amount Including VAT";
        
            /* G/L PAYOUTS */
        
            d.Update(1, t006);
            "Audit Roll".SetRange( "Sale Type", "Audit Roll"."Sale Type"::"Out payment" );
            "Audit Roll".SetRange( Type, "Audit Roll".Type::"G/L" );
            //"Audit Roll".SETFILTER( "No.", '<>%1', Kasse.Rounding );  //NPR5.53 [371955]-revoked
            "Audit Roll".SetFilter("No.",'<>%1',POSSetup.RoundingAccount(true));  //NPR5.53 [371955]
            "Audit Roll".CalcSums( "Amount Including VAT" );
            "Out Payments" := "Audit Roll"."Amount Including VAT";
        
            /* DEBIT SALES */
        
            d.Update(1, t007);
            "Audit Roll".SetRange( "Sale Type", "Audit Roll"."Sale Type"::"Debit Sale" );
            "Audit Roll".SetRange( Type, "Audit Roll".Type::Item );
            "Audit Roll".SetRange("No.");
            if "Audit Roll".FindSet() then repeat
              //"Audit Roll".CALCSUMS( "Amount Including VAT" );
              if "Audit Roll"."Gift voucher ref." = '' then
                DebetSalg += "Audit Roll"."Amount Including VAT"
              else begin
                Udstedtegavekort += "Audit Roll"."Amount Including VAT";
                "Gift Vouchers" := "Gift Vouchers" - "Audit Roll"."Amount Including VAT";
                Gavekortdebet+= "Audit Roll"."Amount Including VAT"
              end;
            until "Audit Roll".Next = 0;
        
          //-NPR5.48 [329505]
            "Audit Roll".SetRange( "Sale Type", "Audit Roll"."Sale Type"::"Debit Sale" );
            "Audit Roll".SetRange( Type, "Audit Roll".Type::Comment );
            "Audit Roll".SetRange("No.");
            if "Audit Roll".FindSet then repeat
              TempAmount := 0;
              AuditRoll2.Reset;
              AuditRoll2.SetRange( "Sale Type", "Audit Roll"."Sale Type"::"Debit Sale" );
              AuditRoll2.SetRange( Type, "Audit Roll".Type::Item );
              AuditRoll2.SetRange("Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
              if AuditRoll2.FindSet then
                repeat
                  TempAmount += AuditRoll2."Amount Including VAT";
                until AuditRoll2.Next=0;
        
                case "Audit Roll"."Document Type" of
                    "Audit Roll"."Document Type"::Order :
                      OrderAmt += TempAmount;
                    "Audit Roll"."Document Type"::Invoice :
                      InvoiceAmt += TempAmount;
                    "Audit Roll"."Document Type"::"Return Order" :
                      ReturnAmt+= TempAmount ;
                    "Audit Roll"."Document Type"::"Credit Memo" :
                      CRNoteAmt += TempAmount ;
                end;
        
            until "Audit Roll".Next =0;
        
          //+NPR5.48 [329505]
        
        
        
            /* CASH INVENTORY */
        
            d.Update(1, t008);
        
            "Audit Roll".SetRange(Type, "Audit Roll".Type::Payment);
            "Audit Roll".SetRange("Sale Type","Audit Roll"."Sale Type"::Payment);
            "Payment Type POS".SetRange(Status, "Payment Type POS".Status::Active);
            "Payment Type POS".SetRange("Processing Type", "Payment Type POS"."Processing Type"::Cash);
            if "Payment Type POS".FindSet then repeat
              "Audit Roll".SetRange("No.","Payment Type POS"."No.");
              "Audit Roll".CalcSums( "Amount Including VAT" );
              "Cash Movements" += "Audit Roll"."Amount Including VAT";
            until "Payment Type POS".Next = 0;
        
            /* CURRENCY */
        
            d.Update(1, t009);
        
            "Payment Type POS".SetRange( "Processing Type", "Payment Type POS"."Processing Type"::"Foreign Currency" );
            if "Payment Type POS".FindSet then repeat
              // IF NOT "Payment Type POS".Euro THEN BEGIN
                "Audit Roll".SetRange(Type, "Audit Roll".Type::Payment);
                "Audit Roll".SetRange( "No.", "Payment Type POS"."No." );
                "Audit Roll".CalcSums( "Amount Including VAT", "Currency Amount" );
                "Currencies Amount (LCY)" := "Audit Roll"."Amount Including VAT";
              // END;
              if "Payment Type POS".Euro then begin
                EuroAmount += "Audit Roll"."Amount Including VAT";
                "Total (Euro)" += "Audit Roll"."Currency Amount";
              end;
            until "Payment Type POS".Next = 0;
        
            /* CREDIT CARDS */
        
            d.Update(1, t010);
        
            "Payment Type POS".SetRange("Processing Type","Payment Type POS"."Processing Type"::"Terminal Card");
            if "Payment Type POS".FindSet then repeat
              "Audit Roll".SetRange(Type, "Audit Roll".Type::Payment);
              "Audit Roll".SetRange("No.","Payment Type POS"."No.");
              "Audit Roll".CalcSums("Amount Including VAT");
              Dank := Dank + "Audit Roll"."Amount Including VAT";
            until "Payment Type POS".Next = 0;
        
            /* MANUAL CREDIT CARDS */
        
            d.Update(1, t011);
        
            "Payment Type POS".SetRange("Processing Type","Payment Type POS"."Processing Type"::"Manual Card");
            if "Payment Type POS".FindSet then repeat
              "Audit Roll".SetRange(Type, "Audit Roll".Type::Payment);
              "Audit Roll".SetRange("No.","Payment Type POS"."No.");
              "Audit Roll".CalcSums("Amount Including VAT");
              VisaDk += "Audit Roll"."Amount Including VAT";
            until "Payment Type POS".Next = 0;
        
            /* OTHER CREDIT CARDS */
        
            d.Update(1, t012);
        
            "Payment Type POS".SetRange("Processing Type","Payment Type POS"."Processing Type"::"Other Credit Cards");
            if "Payment Type POS".FindSet then repeat
              "Audit Roll".SetRange(Type, "Audit Roll".Type::Payment);
              "Audit Roll".SetRange("No.","Payment Type POS"."No.");
              "Audit Roll".CalcSums("Amount Including VAT");
              "Other Credit Cards" += "Audit Roll"."Amount Including VAT";
            until "Payment Type POS".Next = 0;
        
            /* TERMINAL CARDS */
        
            d.Update(1, t013);
        
            "Payment Type POS".SetRange("Processing Type","Payment Type POS"."Processing Type"::EFT);
            if "Payment Type POS".FindSet then begin
              "Audit Roll".SetRange(Type, "Audit Roll".Type::Payment);
              "Audit Roll".SetRange("No.","Payment Type POS"."No.");
              "Audit Roll".CalcSums("Amount Including VAT");
              "Credit Cards" += "Audit Roll"."Amount Including VAT";
            end;
        
            /* RECEIVED CREDIT VOUCHERS */
        
            d.Update(1, t015);
        
            "Payment Type POS".SetRange("Processing Type","Payment Type POS"."Processing Type"::"Credit Voucher");
            if "Payment Type POS".FindSet then begin
              "Audit Roll".SetRange(Type, "Audit Roll".Type::Payment);
              "Audit Roll".SetRange("No.","Payment Type POS"."No.");
              "Audit Roll".CalcSums("Amount Including VAT");
              Udstedtetilgodebeviser:="Audit Roll"."Amount Including VAT";
              "Credit Vouches"  += "Audit Roll"."Amount Including VAT";
        
              /* BUT NOT OUT-HANDED CREDIT VOUCHERS */
        
              "Audit Roll".SetRange(Type, "Audit Roll".Type::"G/L");
              "Audit Roll".SetRange("Sale Type","Audit Roll"."Sale Type"::Deposit);
              "Audit Roll".SetRange("No.",Kasse."Credit Voucher Account");
              "Audit Roll".CalcSums("Amount Including VAT");
              "Credit Vouches"  -= "Audit Roll"."Amount Including VAT";
              Udstedtetilgodebeviser:="Audit Roll"."Amount Including VAT";
            end;
        
            /* RECEIVED GIFT VOUCHERS */
        
            d.Update(1, t014);
        
            "Payment Type POS".SetRange("Processing Type","Payment Type POS"."Processing Type"::"Gift Voucher");
            if "Payment Type POS".FindSet then repeat
              GvFilter    += '|' + "Payment Type POS"."No.";
              GvActFilter += '|' + "Payment Type POS"."G/L Account No.";
            until "Payment Type POS".Next = 0;
        
            GvFilter    := CopyStr(GvFilter,   2);
            GvActFilter := CopyStr(GvActFilter,2);
        
            /* CREATED GIFT VOUCHERS */
        
            "Audit Roll".SetRange(Type, "Audit Roll".Type::"G/L");
            "Audit Roll".SetFilter("Sale Type",'%1|%2',"Audit Roll"."Sale Type"::Deposit,"Audit Roll"."Sale Type"::"Debit Sale");
            "Audit Roll".SetFilter("No.",GvActFilter);
            "Audit Roll".CalcSums("Amount Including VAT");
            "Gift Vouchers" -= "Audit Roll"."Amount Including VAT";
            Udstedtegavekort +="Audit Roll"."Amount Including VAT"  ;
        
            "Audit Roll".SetRange(Type, "Audit Roll".Type::Payment);
            "Audit Roll".SetRange("Sale Type","Audit Roll"."Sale Type"::Payment);
            "Audit Roll".SetFilter("No.",GvFilter);
            "Audit Roll".CalcSums("Amount Including VAT");
        
            /* ALL SALES */
        
            "Sales (Qty)" := 0;
            "Sales (LCY)" := 0;
            "Sales (Staff)" := 0;
            "Sales Debit (Qty)" := 0;
        
            d.Update(1, t016);
        
            "Audit Roll".SetRange("No.");
            "Audit Roll".SetRange("Sale Type");
            "Audit Roll".SetRange(Type);
            if "Audit Roll".FindSet then repeat
              if ("Audit Roll"."Sale Type" = "Audit Roll"."Sale Type"::Sale) then begin
                if "Audit Roll"."Sales Ticket No." <> lastReceipt then begin
                  if "Audit Roll".Type = "Audit Roll".Type::Cancelled then begin
                    CancelledSales += 1;
                  end else begin
                    "Sales (Qty)" += 1;
                    //"Sales (LCY)" += "Audit Roll"."Amount Including VAT";
                  end;
                end;
                "Sales (LCY)" += "Audit Roll"."Amount Including VAT";
                if item.Get("Audit Roll"."No.") then;
                if "Audit Roll"."Customer No." <> '' then begin
                  if cust.Get("Audit Roll"."Customer No.") then begin
                    if (cust."Customer Disc. Group" = npc."Staff Disc. Group") or
                       (cust."Customer Price Group" = npc."Staff Price Group") then begin
                         "Sales (Staff)" += "Audit Roll"."Amount Including VAT";
                    end;
                  end;
                end;
                lastReceipt := "Audit Roll"."Sales Ticket No.";
              end else if  "Audit Roll"."Sales Ticket No." <> lastReceipt then
                if "Audit Roll"."Sale Type" = "Audit Roll"."Sale Type"::"Debit Sale" then begin
                  "Sales Debit (Qty)" += 1;
                  "Sales (Qty)" += 1;
                  lastReceipt := "Audit Roll"."Sales Ticket No.";
                end;
            until "Audit Roll".Next = 0;
        
        
            /* NET TURNOVER */
        
            d.Update(1, t017);
        
            "Audit Roll".SetRange("No.");
            "Audit Roll".SetRange("Sale Type", "Audit Roll"."Sale Type"::Sale);
            "Audit Roll".SetRange(Type, "Audit Roll".Type::Item);
            "Audit Roll".CalcSums(Amount,"Amount Including VAT");
            "Net Turnover (LCY)" := "Audit Roll".Amount;
            "Turnover (LCY)" += "Audit Roll"."Amount Including VAT";
        
        
            /* NET COST */
        
            d.Update(1, t018);
        
            "Audit Roll".CalcSums(Cost);
            "Net Cost (LCY)" := "Audit Roll".Cost;
        
            /* TOTAL DISCOUNT */
        
            d.Update(1, t020);
        
            "Audit Roll".CalcSums("Line Discount Amount");
            "Total Discount (LCY)" := "Audit Roll"."Line Discount Amount";
        
            /* NEGATIVE SALES */
        
            d.Update(1, t021);
        
            CountNegSales( Kasse."Register No.");
            GetStatsOfTheDay("Audit Roll");
        
            /* DIVERSE DISCOUNTS */
        
            d.Update(1, t022);
        
            "Audit Roll".SetFilter("Sales Ticket No.", ReceiptFilter);
            "Audit Roll".CalcSums("Line Discount Amount");
            "Total Discount (LCY)" := "Audit Roll"."Line Discount Amount";
        
            if "Audit Roll".FindSet then repeat
              case "Audit Roll"."Discount Type" of
                "Audit Roll"."Discount Type"::Campaign      :
                   "Campaign Discount (LCY)" += "Audit Roll"."Line Discount Amount";
                "Audit Roll"."Discount Type"::Mix         :
                   "Mix Discount (LCY)" += "Audit Roll"."Line Discount Amount";
                "Audit Roll"."Discount Type"::Quantity     :
                   "Quantity Discount (LCY)" += "Audit Roll"."Line Discount Amount";
                "Audit Roll"."Discount Type"::Manual :
                   "Custom Discount (LCY)" += "Audit Roll"."Line Discount Amount";
                "Audit Roll"."Discount Type"::"BOM List" :
                   "BOM Discount (LCY)" += "Audit Roll"."Line Discount Amount";
                "Audit Roll"."Discount Type"::Customer :
                   "Customer Discount (LCY)" += "Audit Roll"."Line Discount Amount";
        
                else
                   "Line Discount (LCY)" += "Audit Roll"."Line Discount Amount";
              end;
            until "Audit Roll".Next = 0;
        
            d.Update(1, t023);
        
            "Profit Amount (LCY)" := "Net Turnover (LCY)" - "Net Cost (LCY)";
        
            if "Net Turnover (LCY)" <> 0 then
              "Profit %" := "Profit Amount (LCY)" * 100 / "Net Turnover (LCY)";
        
            if ("Profit Amount (LCY)" < 0) and ("Profit %" >0) then
              "Profit %" := -"Profit %";
        
            if "Turnover (LCY)" <> 0 then begin
              "Custom Discount %"   := Round("Custom Discount (LCY)"   * 100 / "Turnover (LCY)",0.01);
              "Quantity Discount %" := Round("Quantity Discount (LCY)" * 100 / "Turnover (LCY)",0.01);
              "Mix Discount %"      := Round("Mix Discount (LCY)"      * 100 / "Turnover (LCY)",0.01);
              "Campaign Discount %" := Round("Campaign Discount (LCY)" * 100 / "Turnover (LCY)",0.01);
              "Line Discount %"     := Round("Line Discount (LCY)"     * 100 / "Turnover (LCY)",0.01);
              "Total Discount %"    := Round("Total Discount (LCY)"    * 100 / "Turnover (LCY)",0.01);
              "BOM Discount %"      := Round("BOM Discount (LCY)"      * 100 / "Turnover (LCY)",0.01);
              "Customer Discount %" := Round("Customer Discount (LCY)" * 100 / "Turnover (LCY)",0.01);
            end;
          end;
        
          "Diff (LCY)" := Primo + "Cash Movements";
          "Diff (Euro)" := "Total (Euro)";
        
          d.Close;
        end;

    end;

    procedure CountNegSales("Register No.": Code[10])
    var
        "Payment Type": Record "Payment Type POS";
        rAuditRoll: Record "Audit Roll";
        PreviousBonNo: Code[20];
        PositiveBonQty: Integer;
        PositiveBonAmount: Decimal;
        aReceiptType_count: array [10] of Integer;
        aReceiptType_amount: array [10] of Decimal;
        thisReceiptNo: Code[10];
        i: Integer;
    begin
        // Nies Tweakup
        NegativeBonQty := 0;
        NegativeBonAmount := 0;

        rAuditRoll.SetCurrentKey("Register No.",
                                   "Sales Ticket No.",
                                   "Sale Type",
                                   Type);


        rAuditRoll.SetRange("Register No.","Register No.");
        rAuditRoll.SetFilter("Sales Ticket No.",'%1..', Kasse."Opened on Sales Ticket" );
        //-NPR5.22
        if rAuditRoll.FindFirst then
            rAuditRoll.SetFilter("Sale Date", '%1..', rAuditRoll."Sale Date");
        //+NPR5.22

        rAuditRoll.SetRange(Type, rAuditRoll.Type::Payment);
        rAuditRoll.SetRange("Sale Type", rAuditRoll."Sale Type"::Payment);
        rAuditRoll.SetFilter("Receipt Type",'%1', rAuditRoll."Receipt Type"::"Negative receipt");
        rAuditRoll.SetRange("No.");

        if rAuditRoll.FindSet then repeat
          if "Payment Type".Get(rAuditRoll."No.") then begin
            if (rAuditRoll."Amount Including VAT" < 0) then begin
              if ("Payment Type"."Processing Type" = "Payment Type"."Processing Type"::Cash) or
                  ("Payment Type"."Via Terminal" and
                  ("Payment Type"."Processing Type" <> "Payment Type"."Processing Type"::"Gift Voucher"))
              then begin
                if (PreviousBonNo <> rAuditRoll."Sales Ticket No.") then begin
                  NegativeBonQty += 1;
                  NegativeBonAmount += rAuditRoll."Amount Including VAT";
                  //-NPR5.48 [336040]
                  PreviousBonNo := rAuditRoll."Sales Ticket No.";
                  //+NPR5.48 [336040]
                end;
              end;
            end;
          end;
          //-NPR5.48 [336040]
          //PreviousBonNo := rAuditRoll."Sales Ticket No.";
          //-NPR5.48 [336040]
        until rAuditRoll.Next = 0;
    end;

    procedure saveBalancedRegister(var Sale: Record "Sale POS";AfslutDato: Date;AfslutTid: Time;Afsluttet: Boolean)
    var
        Kasseperiode: Record Period;
        "Period Line": Record "Period Line";
        "Payment Type - Detailed": Record "Payment Type - Detailed";
        ar: Record "Audit Roll";
        AuditRoll: Record "Audit Roll";
        Itt: Integer;
    begin
        ar.SetRange("Register No.", Sale."Register No.");
        //ar.
        if ar.FindLast then begin
          if ar."Sales Ticket No." > Sale."Sales Ticket No." then
            Marshaller.DisplayError(t018,t031,true);
        end;
        POSUnit.Get(Kasse."Register No.");  //NPR5.53 [371956]
        
        Kasseperiode.Init;
        Kasseperiode."Register No."               := Kasse."Register No.";
        Kasseperiode."Sales Ticket No."           := Sale."Sales Ticket No.";
        Kasseperiode.Description                  := t030;
        
        if Afsluttet then
          Kasseperiode.Status                     := Kasseperiode.Status::Balanced
        else
          Kasseperiode.Status                     := Kasseperiode.Status::Ongoing;
        
        Kasseperiode."Salesperson Code"           := Sale."Salesperson Code";
        Kasseperiode."Date Closed"                := AfslutDato;
        Kasseperiode."Date Saved"                 := Today;
        Kasseperiode."Closing Time"               := AfslutTid;
        Kasseperiode."Saving  Time"               := Time;
        Kasseperiode."Sales Ticket No."           := Sale."Sales Ticket No.";
        Kasseperiode."Opening Sales Ticket No."   := Kasse."Opened on Sales Ticket";
        AuditRoll.SetRange("Register No.",Kasse."Register No.");
        AuditRoll.SetRange("Sales Ticket No.",Kasseperiode."Opening Sales Ticket No.");
        if AuditRoll.FindSet then begin
          Kasseperiode."Date Opened"              := AuditRoll."Sale Date";
          Kasseperiode."Opening Time"             := AuditRoll."Starting Time";
        end;
        Kasseperiode."Opening Cash"               := Primo;
        Kasseperiode."Net. Cash Change"           := "Cash Movements";
        Kasseperiode."Net. Credit Voucher Change" := "Credit Vouches";
        Kasseperiode."Net. Gift Voucher Change"   := "Gift Vouchers";
        Kasseperiode."Net. Terminal Change"       := "Credit Cards";
        Kasseperiode."Net. Dankort Change"        := Dank;
        Kasseperiode."Net. VisaCard Change"       := VisaDk;
        Kasseperiode."Net. Change Other Cedit Cards" := "Other Credit Cards";
        Kasseperiode."Gift Voucher Sales"         := Udstedtegavekort;
        Kasseperiode."Credit Voucher issuing"     := Udstedtetilgodebeviser;
        Kasseperiode."Cash Received"              := "Customer Payments";
        Kasseperiode."Pay Out"                    := "Out Payments";
        Kasseperiode."Debit Sale"                 := DebetSalg;
        //-NPR5.48 [329505]
        Kasseperiode."Invoice Amount"             := InvoiceAmt;
        Kasseperiode."Order Amount"               := OrderAmt;
        Kasseperiode."Credit Memo Amount"         := CRNoteAmt;
        Kasseperiode."Return Amount"              := ReturnAmt;
        //+NPR5.48 [329505]
        Kasseperiode."Negative Sales Count"                  := NegativeBonQty;
        Kasseperiode."Negative Sales Amount"                  := NegativeBonAmount;
        Kasseperiode.Cheque                       := Check;
        Kasseperiode."Balanced Cash Amount"       := "Sum (LCY)";
        Kasseperiode."Closing Cash"               := "Ultimo (LCY)";
        Kasseperiode.Difference                   := "Diff (LCY)";
        Kasseperiode."Deposit in Bank"            := "Bank (LCY)";
        Kasseperiode."Gift Voucher Debit"         := Gavekortdebet;
        Kasseperiode."Euro Difference"            := PaymentDiffeuro;
        Kasseperiode."Change Register"            := "Change (LCY)";
        //-NPR5.53 [371956]-revoked
        //Kasseperiode."Shortcut Dimension 1 Code"  := Kasse."Global Dimension 1 Code";
        //Kasseperiode."Shortcut Dimension 2 Code"  := Kasse."Global Dimension 2 Code";
        //+NPR5.53 [371956]-revoked
        //-NPR5.53 [371956]
        Kasseperiode."Shortcut Dimension 1 Code"  := POSUnit."Global Dimension 1 Code";
        Kasseperiode."Shortcut Dimension 2 Code"  := POSUnit."Global Dimension 2 Code";
        //+NPR5.53 [371956]
        Kasseperiode."Location Code"              := Kasse."Location Code";
        Kasseperiode."Money bag no."              := CopyStr(MoneyBagNo,1,MaxStrLen(Kasseperiode."Money bag no."));
        Kasseperiode."Alternative Register No."   := Sale."Alternative Register No.";
        Kasseperiode.Comment                      := Comment;
        
        Kasseperiode.WriteBalancingInfo;
        
        Kasseperiode."Sales (Qty)"             := "Sales (Qty)";
        Kasseperiode."Sales (LCY)"             := "Sales (LCY)";
        Kasseperiode."Debit Sales (Qty)"       := "Sales Debit (Qty)";
        Kasseperiode."Cancelled Sales"         := CancelledSales;
        Kasseperiode."Campaign Discount (LCY)" := "Campaign Discount (LCY)";
        Kasseperiode."Mix Discount (LCY)"      := "Mix Discount (LCY)";
        Kasseperiode."Quantity Discount (LCY)" := "Quantity Discount (LCY)";
        Kasseperiode."Line Discount (LCY)"     := "Line Discount (LCY)";
        Kasseperiode."Custom Discount (LCY)"   := "Custom Discount (LCY)";
        Kasseperiode."Total Discount (LCY)"    := "Total Discount (LCY)";
        Kasseperiode."Net Turnover (LCY)"      := "Net Turnover (LCY)";
        Kasseperiode."Net Cost (LCY)"          := "Net Cost (LCY)";
        Kasseperiode."Turnover Including VAT"  :=  "Turnover (LCY)" ;
        Kasseperiode."Currencies Amount (LCY)" := "Currencies Amount (LCY)";
        Kasseperiode."Profit Amount (LCY)"     := "Profit Amount (LCY)";
        Kasseperiode."Profit %"                := "Profit %";
        
        /* Save Statistics */
        Kasseperiode."No. Of Goods Sold"        := NoOfGoodsSold;
        Kasseperiode."No. Of Cash Receipts"     := NoOfCashReciepts;
        Kasseperiode."No. Of Cash Box Openings" := NoOfCashBoxOpenings;
        Kasseperiode."No. Of Receipt Copies"    := NoOfReceiptCopies;
        for Itt := 1 to 10 do
          if VatRates[Itt] > 0 then
            Kasseperiode."VAT Info String" += Format(VatRates[Itt]) + ':' + Format(VatAmounts[Itt]) + ';';
        
        Kasseperiode.Insert(true);
        
        /* SAVE REGISTER COUNTING */
        
        "Payment Type - Detailed".SetFilter("Register No.", RegisterFilter);
        if "Payment Type - Detailed".FindSet then repeat
          if "Payment Type - Detailed".Quantity <> 0 then begin
            "Period Line".Init;
            "Period Line"."Register No."      := Kasseperiode."Register No.";
            "Period Line"."Sales Ticket No."  := Kasseperiode."Sales Ticket No.";
            "Period Line"."No."               := Kasseperiode."No.";
            "Period Line"."Payment Type No."  := "Payment Type - Detailed"."Payment No.";
            "Period Line".Weight              := "Payment Type - Detailed".Weight;
            "Period Line".Quantity            := "Payment Type - Detailed".Quantity;
            "Period Line".Amount              := "Payment Type - Detailed".Amount;
            if not "Period Line".Insert(true) then
              "Period Line".Modify(true);
          end;
        until "Payment Type - Detailed".Next = 0;

    end;

    procedure getClosingType(): Integer
    begin
        exit(closingType);
    end;

    procedure "-----"()
    begin
    end;

    procedure pushUltimo(dec1: Decimal)
    begin
        if dec1 < 0 then
          Marshaller.DisplayError(t018,t020,true);

        if (not Kasse."End of day - Exchange Amount" and (dec1 > ("Bank (LCY)" + "Ultimo (LCY)"))) or
          (Kasse."End of day - Exchange Amount" and (0 > ("Sum (LCY)" - "Bank (LCY)" - dec1)) )
        then
          Marshaller.DisplayError(t018,StrSubstNo(Text10600016, "Bank (LCY)" + "Ultimo (LCY)"),true);

        "Ultimo (LCY)" := dec1;

        if Kasse."End of day - Exchange Amount" then
          "Change (LCY)"       := "Sum (LCY)" - "Bank (LCY)" - dec1
        else
          "Bank (LCY)"         := "Sum (LCY)" - dec1;
    end;

    procedure pushBank(dec1: Decimal)
    begin
        if dec1 < 0 then
          Marshaller.DisplayError(t018,t020,true);

        if (not Kasse."End of day - Exchange Amount" and (dec1 > ("Bank (LCY)" + "Ultimo (LCY)"))) or
           (Kasse."End of day - Exchange Amount"     and (0 > "Sum (LCY)" - dec1 - "Ultimo (LCY)"))
        then
          Marshaller.DisplayError(t018,StrSubstNo(Text10600000, "Ultimo (LCY)" + "Bank (LCY)"),true);

        "Bank (LCY)"  := dec1;

        if Kasse."End of day - Exchange Amount" then
          "Change (LCY)"       := "Sum (LCY)" - dec1 - "Ultimo (LCY)"
        else
          "Ultimo (LCY)"       := "Sum (LCY)" - dec1;
    end;

    procedure initLines()
    var
        Lines: Record "Payment Type - Detailed";
        PaymentPrefix: Record "Payment Type - Prefix";
    begin
        with Rec do begin
          Lines.Reset;
          Lines.SetRange("Register No.", Kasse."Register No.");
          if Lines.FindSet then begin
            if Marshaller.Confirm(t023, t024) then
              exit
            else
              Lines.DeleteAll(true);
          end;

          PaymentPrefix.SetFilter("Register No.", Rec.GetFilter("Register No."));

          if FindSet then repeat
            PaymentPrefix.SetRange("Payment Type", "No.");
            if PaymentPrefix.FindSet() then repeat
              Lines.Init;
              Lines."Payment No."  := "No.";
              Lines."Register No." := Kasse."Register No.";
              Lines.Weight         := PaymentPrefix.Weight;
              if not Lines.Insert(true) then;
            until PaymentPrefix.Next = 0;
          until Next = 0;

          if FindSet() then;
        end;
    end;

    procedure initForm(RegNo: Code[20];"Sales Person": Code[10])
    begin
        SalesPerson.Get("Sales Person");

        if not Kasse.Get(RegNo) then
          exit;
    end;

    procedure valutaBeloebDec(paycode: Code[10];dec: Decimal) ret: Decimal
    var
        betvalg: Record "Payment Type POS";
    begin
        betvalg.Reset;
        betvalg.SetRange("No.", paycode);

        if betvalg.FindSet() then begin
          if betvalg."Fixed Rate" <> 0 then
            ret := dec/betvalg."Fixed Rate"*100
          else
            ret := dec;
        end else
          ret := 0;
    end;

    procedure calcTotals()
    var
        Payment1: Record "Payment Type POS";
    begin
        // Calculate ALL Payment Type = Cash as one number

        "Bank (LCY)"   := 0;
        "Ultimo (LCY)" := 0;
        "Sum (LCY)"    := 0;
        "Change (LCY)" := 0;

        Payment1.SetFilter("Register Filter", RegisterFilter);
        Payment1.SetFilter("Receipt Filter", ReceiptFilter);
        Payment1.SetRange("Processing Type", Payment1."Processing Type"::Cash);

        if Payment1.FindSet() then repeat
          if (Payment1.Status = Payment1.Status::Active) and
             (Payment1."To be Balanced" = true) then begin
               Payment1.SetRange("No.", Payment1."No.");
               Payment1.CalcFields("Balancing Total");
               "Sum (LCY)" += Payment1."Balancing Total";
               case Payment1."Balancing Type" of
                 Payment1."Balancing Type"::Primo :
                   begin
                     "Ultimo (LCY)" += Payment1."Balancing Total";
                     countedUltimo := true;
                   end;
                 Payment1."Balancing Type"::Bank :
                   begin
                     "Bank (LCY)" += Payment1."Balancing Total";
                     countedBank := true;
                   end;
               end;
               if Payment1."Is Check" = true then
                 Check += Payment1."Balancing Total";
               Payment1.SetRange("No.");
          end;
        until Payment1.Next = 0;

        "Diff (LCY)" := Primo + "Cash Movements" - "Sum (LCY)" + "Bank (LCY)";
        "Diff (Euro)" := "Total (Euro)" - "Sum (Euro)";

        if Kasse."End of day - Exchange Amount" then
          "Change (LCY)" := "Sum (LCY)"
        else
          "Ultimo (LCY)" := "Sum (LCY)";
    end;

    procedure calcPaymentType()
    var
        Payment1: Record "Payment Type POS";
    begin
        with Rec do begin
          Payment1.SetFilter("Register Filter", RegisterFilter);
          Payment1.SetFilter("Receipt Filter", ReceiptFilter);

          Payment1.SetRange("No.", "No.");

          Payment1.FindSet();

          Payment1.CalcFields("Amount in Audit Roll", "Balancing Total");

          PaymentAuditRoll := valutaBeloebDec(Payment1."No.", Payment1."Amount in Audit Roll");

          PaymentDiff := 0;

          case Payment1."No." of
            Kasse."Primary Payment Type" :
              begin
                PaymentDiff := Primo + PaymentAuditRoll - Payment1."Balancing Total";
              end;
            else
              begin
                PaymentDiff := PaymentAuditRoll - Payment1."Balancing Total";
              end;
          end;

          if Rec.Euro then begin
            PaymentDiffeuro := "Total (Euro)" - Payment1."Balancing Total";
          end;
        end;
    end;

    procedure "----"()
    begin
    end;

    procedure GetStatsOfTheDay(var AuditRoll: Record "Audit Roll")
    var
        PaymentTypePOS: Record "Payment Type POS";
        LastRecieptNo: Code[20];
        Itt: Integer;
    begin
        /* NoOfGoodsSold */
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type,AuditRoll.Type::Item);
        AuditRoll.CalcSums(Quantity);
        NoOfGoodsSold := AuditRoll.Quantity;
        
        /* NoOfCashReciepts */
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Payment);
        AuditRoll.SetRange(Type,AuditRoll.Type::Payment);
        if AuditRoll.FindSet then repeat
          if  PaymentTypePOS.Get(AuditRoll."No.") and
             (PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::Cash) and
             (AuditRoll."Sales Ticket No." <> LastRecieptNo)
             then
          begin
            LastRecieptNo    := AuditRoll."Sales Ticket No.";
            NoOfCashReciepts += 1;
          end;
        until AuditRoll.Next = 0;
        
        /* NoOfCasBoxOpenings */
        AuditRoll.SetRange("Sale Type");
        AuditRoll.SetRange(Type);
        AuditRoll.SetRange("Receipt Type",AuditRoll."Receipt Type"::"Change money");
        if AuditRoll.FindSet then repeat
          NoOfCashBoxOpenings += 1;
        until AuditRoll.Next = 0;
        
        AuditRoll.SetRange("Receipt Type");
        AuditRoll.SetRange("Drawer Opened",true);
        if AuditRoll.FindSet then repeat
          NoOfCashBoxOpenings += 1;
        until AuditRoll.Next = 0;
        AuditRoll.SetRange("Drawer Opened");
        
        /* NoOfReceiptCopiesAndAmount */
        AuditRoll.SetFilter("Copy No.",'>%1',0);
        if AuditRoll.FindSet then repeat
          if (AuditRoll."Sales Ticket No." <> LastRecieptNo) then
          begin
            NoOfReceiptCopies += AuditRoll."Copy No.";
            LastRecieptNo     := AuditRoll."Sales Ticket No.";
          end;
        until AuditRoll.Next = 0;
        
        AuditRoll.SetRange("Copy No.");
        
        /* Vat Amounts */
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type,AuditRoll.Type::Item);
        if AuditRoll.FindSet then repeat
          if AuditRoll."VAT %" > 0 then begin
            for Itt := 1 to 10 do begin
              if (VatRates[Itt] = 0) or
                 (AuditRoll."VAT %" = VatRates[Itt]) then begin
                VatRates[Itt]   := AuditRoll."VAT %";
                VatAmounts[Itt] += AuditRoll."Amount Including VAT" - AuditRoll.Amount;
                Itt := 10;
              end;
            end;
          end;
        until AuditRoll.Next = 0;
        
        SortVatArrays;

    end;

    procedure SortVatArrays()
    var
        I: Integer;
        J: Integer;
        MinJ: Integer;
        "Min": Decimal;
        NewVatRates: array [10] of Decimal;
        NewVatAmounts: array [10] of Decimal;
    begin
        /* Sorting vat arrays naively in squared time */
        for I := 1 to 10 do begin
          Min   := 100;
          for J := 1 to 10 do begin
            if (VatRates[J] < Min) and (VatRates[J] > 0) then begin
              Min  := VatRates[J];
              MinJ := J
            end;
          end;
          if MinJ > 0 then begin
            VatRates[MinJ] := 0;
            NewVatRates[I] := Min;
            NewVatAmounts[I] := VatAmounts[MinJ];
            MinJ := 0;
          end else I := 10;
        end;
        
        for I := 1 to 10 do begin
          VatRates[I]   := NewVatRates[I];
          VatAmounts[I] := NewVatAmounts[I];
        end;

    end;

    procedure "---- dotNet"()
    begin
    end;

    procedure UpdateFigures(var PeriodFigures: DotNet npNetDictionary_Of_T_U;var BalancingFigures: DotNet npNetDictionary_Of_T_U;var CountingLines: DotNet npNetDataGrid;var Subtotal: Text)
    begin
        PeriodFigures := PeriodFigures.Dictionary();
        PeriodFigures.Add('BankLCY',UI.FormatDecimal("Bank (LCY)"));
        PeriodFigures.Add('ChangeLCY',UI.FormatDecimal("Change (LCY)"));
        PeriodFigures.Add('Comment',Comment);
        PeriodFigures.Add('DiffLCY',UI.FormatDecimal("Diff (LCY)"));
        PeriodFigures.Add('MoneyBagNo',MoneyBagNo);
        PeriodFigures.Add('SumLCY',UI.FormatDecimal("Sum (LCY)"));
        PeriodFigures.Add('UltimoLCY',UI.FormatDecimal("Ultimo (LCY)"));

        BalancingFigures := BalancingFigures.Dictionary();
        BalancingFigures.Add('BOMListDiscountAmount',UI.FormatDecimal("BOM Discount (LCY)"));
        BalancingFigures.Add('BOMListDiscountPct',UI.FormatDecimal("BOM Discount %"));
        BalancingFigures.Add('CampaignDiscountAmount',UI.FormatDecimal("Campaign Discount (LCY)"));
        BalancingFigures.Add('CampaignDiscountPct',UI.FormatDecimal("Campaign Discount %"));
        BalancingFigures.Add('CashMovements',UI.FormatDecimal("Cash Movements"));
        BalancingFigures.Add('CreditCards',UI.FormatDecimal(Dank));
        BalancingFigures.Add('CreditVouchers',UI.FormatDecimal("Credit Vouches"));
        BalancingFigures.Add('CustomerDiscountAmount',UI.FormatDecimal("Customer Discount (LCY)"));
        BalancingFigures.Add('CustomerPayments',UI.FormatDecimal("Customer Payments"));
        BalancingFigures.Add('DiscountAmountPct',UI.FormatDecimal("Customer Discount %"));
        BalancingFigures.Add('ForeignCurrency',UI.FormatDecimal("Currencies Amount (LCY)"));
        BalancingFigures.Add('GiftVouchers',UI.FormatDecimal("Gift Vouchers"));
        BalancingFigures.Add('LineDiscountAmount',UI.FormatDecimal("Line Discount (LCY)"));
        BalancingFigures.Add('LineDiscountPct',UI.FormatDecimal("Line Discount %"));
        BalancingFigures.Add('ManualCards',UI.FormatDecimal(VisaDk));
        BalancingFigures.Add('MidTotal',UI.FormatDecimal(Primo + "Cash Movements"));
        BalancingFigures.Add('MixedDiscountAmount',UI.FormatDecimal("Mix Discount (LCY)"));
        BalancingFigures.Add('MixedDiscountPct',UI.FormatDecimal("Mix Discount %"));
        BalancingFigures.Add('NegativeSalesAmount',UI.FormatDecimal(NegativeBonAmount));
        BalancingFigures.Add('NetCostAmount',UI.FormatDecimal("Net Cost (LCY)"));
        BalancingFigures.Add('NetTurnOver',UI.FormatDecimal("Net Turnover (LCY)"));
        BalancingFigures.Add('OtherCreditCards',UI.FormatDecimal("Other Credit Cards"));
        BalancingFigures.Add('OutPayments',UI.FormatDecimal("Out Payments"));
        BalancingFigures.Add('PrimoBalance',UI.FormatDecimal(Primo));
        BalancingFigures.Add('ProfitAmount',UI.FormatDecimal("Profit Amount (LCY)"));
        BalancingFigures.Add('ProfitCoverage',UI.FormatDecimal(Round("Profit %",0.01,'<')));
        BalancingFigures.Add('QuantityDiscountAmount',UI.FormatDecimal("Quantity Discount (LCY)"));
        BalancingFigures.Add('QuantityDiscountPct',UI.FormatDecimal("Quantity Discount %"));
        BalancingFigures.Add('QuantityOfCancelledSales',UI.FormatInteger(CancelledSales));
        BalancingFigures.Add('QuantityOfNegativeSales',UI.FormatInteger(NegativeBonQty));
        BalancingFigures.Add('QuantityOfSales',UI.FormatInteger("Sales (Qty)"));
        BalancingFigures.Add('ReceiptFilter',ReceiptFilter);
        BalancingFigures.Add('RegisterFilter',RegisterFilter);
        BalancingFigures.Add('SalesPersonDiscountAmount',UI.FormatDecimal("Custom Discount (LCY)"));
        BalancingFigures.Add('SalesPersonDiscountPct',UI.FormatDecimal("Custom Discount %"));
        BalancingFigures.Add('StaffSales',UI.FormatDecimal("Sales (Staff)"));
        BalancingFigures.Add('TerminalTotal',UI.FormatDecimal("Credit Cards"));
        BalancingFigures.Add('TotalDiscountAmount',UI.FormatDecimal("Total Discount (LCY)"));
        BalancingFigures.Add('TotalDiscountPct',UI.FormatDecimal("Total Discount %"));
        //-NPR5.32
        //BalancingFigures.Add('TurnOver',UI.FormatDecimal("Net Turnover (LCY)"));
        BalancingFigures.Add('TurnOver',UI.FormatDecimal("Profit Amount (LCY)"));
        //+NPR5.32

        SetCountingLines(CountingLines);

        //-NPR5.31
        Subtotal := UI.FormatDecimal("Sum (LCY)")
        //+NPR5.31
    end;

    procedure ButtonClickedHandler(ButtonCode: Code[20]): Boolean
    var
        RetailFormCode: Codeunit "Retail Form Code";
        Dec: Decimal;
    begin
        with Rec do
          case ButtonCode of
            'CANCEL'        :
              begin
                closingType := closingType::Cancel;
                exit(true);
              end;
            'OPEN_DRAWER'   :
              RetailFormCode.OpenRegister();
            'AUDIT_ROLL'    :
              pushAuditRoll;
            'COUNTING'      :
              pushCount;
            'SCROLL_UP'     :
              if FindFirst then;
            'SCROLL_DOWN'   :
              if FindLast then;
            'ULTIMO_LCY'    :
              begin
                if countedUltimo then
                  Marshaller.DisplayError(text035,text036,true);

                Dec := "Change (LCY)" + "Ultimo (LCY)";
                if not Marshaller.NumPad(t011,Dec,false,false) then
                  exit;

                pushUltimo(Dec);
              end;
            'BANK_LCY'      :
              begin
                if countedBank then
                  Marshaller.DisplayError(text038,text039,true);

                Dec := "Change (LCY)" + "Bank (LCY)";
                if not Marshaller.NumPad(t011,Dec,false,false) then
                  exit;

                pushBank(Dec);
              end;
            'MONEY_BAG'     :
              begin
                if not Marshaller.NumPadCode(t029,MoneyBagNo,false,false) then
                  exit;
              end;
            'DELETE'        :
              begin
                calcTotals;
              end;
            'END_BALANCING' :
              begin
                closingType := closingType::Normal;
                exit(true);
              end;
          end;
    end;

    procedure MessageEventReadyHandler(MessageCode: Integer;MessageText: Text)
    begin
    end;

    local procedure SetCountingLines(var CountingLines: DotNet npNetDataGrid)
    var
        RecRef: RecordRef;
        Util: Codeunit "POS Web Utilities";
        UI: Codeunit "POS Web UI Management";
        Columns: array [40] of Integer;
    begin
        CountingLines := CountingLines.DataGrid();

        with Rec do begin
          UI.ConfigureBalancingLinesGrid(CountingLines);

          RecRef.GetTable(Rec);
          Util.NavRecordToRows(RecRef,CountingLines);
        end;
    end;

    procedure GetUltimoLCY(): Decimal
    begin
        exit("Ultimo (LCY)");
    end;

    procedure GetBankLCY(): Decimal
    begin
        exit("Bank (LCY)");
    end;

    procedure GetComment(): Text[50]
    begin
        exit(Comment);
    end;

    procedure SetComment(CommentIn: Text)
    begin
        Comment := CopyStr(CommentIn,1,MaxStrLen(Comment));
    end;
}

