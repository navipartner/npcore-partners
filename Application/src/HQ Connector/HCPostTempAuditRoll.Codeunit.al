codeunit 6150902 "NPR HC Post Temp Audit Roll"
{
    trigger OnRun()
    var
        RevRulle: Record "NPR HC Audit Roll";
    begin
        RevRulle.SetFilter("No.", '<>%1', '');
        RevRulle.ModifyAll(Posted, false);
        RevRulle.ModifyAll("Item Entry Posted", false);
    end;

    var
        Dummy: Record "NPR HC Audit Roll Posting" temporary;
        FinKldLinie: Record "Gen. Journal Line" temporary;
        GeneralPostingSetup: Record "General Posting Setup";
        BetalingsValg: Record "NPR HC Payment Type POS";
        VarekldLinie: Record "Item Journal Line" temporary;
        Debitorpost: Record "Cust. Ledger Entry" temporary;
        RevisionUdbetaling: Record "NPR HC Audit Roll Posting" temporary;
        HCRetailSetup: Record "NPR HC Retail Setup";
        Debitorpost1: Record "Cust. Ledger Entry";
        Vare: Record Item;
        Kasse: Record "NPR HC Register";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        Window: Dialog;
        BogfDate: Date;
        blank: Code[10];
        AccountType: Option "G/L",Customer,Vendor,Bank,"Fixed Asset";
        Finkllbr: Integer;
        Varekllbr: Integer;
        DebPostLbrNr: Integer;
        Total: Integer;
        Counter: Integer;
        WindowIsOpen: Boolean;
        PostOnlySalesTicketNo: Boolean;
        StraksBogfVarePostFraEkspAfsl: Boolean;
        DoNotPost: Boolean;
        StraksBogf: Boolean;
        DebugPostingMsg: Boolean;
        ProgressVis: Boolean;
        GlobalPostingNo: Code[20];
        GenJournalLine: Record "Gen. Journal Line";
        ItemJournalLine: Record "Item Journal Line";
        GeneralLedgerSetup: Record "General Ledger Setup";

    procedure PostItemSale(var TempPost: Record "NPR HC Audit Roll Posting" temporary)
    var
        "S & R Setup": Record "Sales & Receivables Setup";
        Item: Record Item;
    begin
        with TempPost do begin
            SetRange("Sale Date", TempPost."Sale Date");
            SetFilter("Sales Ticket No.", TempPost.GetFilter("Sales Ticket No."));
            PrintKey('"Virksomheds-bogf�ringsgruppe","Produkt-bogf�ringsgruppe", Ekspeditionsart, Type', GetFilters, 9);
            CalcSums("Amount Including VAT", "Line Discount Amount");
            if not GeneralPostingSetup.Get(GetRangeMax("Gen. Bus. Posting Group"), GetRangeMax("Gen. Prod. Posting Group")) then begin
                TempPost.TestField(Type, TempPost.Type::Item);
                Item.Get("No.");
                "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                GeneralPostingSetup.Get(GetRangeMax("Gen. Bus. Posting Group"), "Gen. Prod. Posting Group");
            end;
            GeneralPostingSetup.TestField("Sales Account");
            GeneralPostingSetup.TestField("Sales Line Disc. Account");

            PrintKey('F�r Dim', '', 91);
            HCRetailSetup.Get;

            PrintKey('Efter Dim', '', 92);

            // Posting off full amount
            "S & R Setup".Get;
            if ("S & R Setup"."Discount Posting" = "S & R Setup"."Discount Posting"::"All Discounts") or
               ("S & R Setup"."Discount Posting" = "S & R Setup"."Discount Posting"::"Line Discounts")
              then begin
                if ("Amount Including VAT" + TempPost."Line Discount Amount") <> 0 then
                    PostTransaction(GeneralPostingSetup."Sales Account", -("Amount Including VAT" + TempPost."Line Discount Amount"),
                                     "Register No.", AccountType::"G/L", "Shortcut Dimension 1 Code", '', BogfDate, TempPost)
            end else
                PostTransaction(GeneralPostingSetup."Sales Account", -("Amount Including VAT"),
                                 "Register No.", AccountType::"G/L", TempPost."Shortcut Dimension 1 Code", '', BogfDate, TempPost);

            // Posting of discount amount
            if (TempPost."Line Discount Amount" <> 0) and
              ("S & R Setup"."Discount Posting" = "S & R Setup"."Discount Posting"::"All Discounts") or
              ("S & R Setup"."Discount Posting" = "S & R Setup"."Discount Posting"::"Line Discounts") then
                PostTransaction(GeneralPostingSetup."Sales Line Disc. Account", TempPost."Line Discount Amount", "Register No.", AccountType::"G/L",
                                TempPost."Shortcut Dimension 1 Code", '', BogfDate, TempPost);

        end;
    end;

    procedure PostRegisterTransactions(var TempPost: Record "NPR HC Audit Roll Posting" temporary)
    var
        CurrentPost: Record "NPR HC Audit Roll Posting" temporary;
        BankAccount: Record "Bank Account";
    begin
        GeneralLedgerSetup.Get;

        HCRetailSetup.Get;

        with TempPost do begin
            SetCurrentKey("Sale Type", Type, "No.");
            SetRange("Sale Date", "Sale Date");
            SetRange("No.", "No.");
            PrintKey('Ekspeditionsart, Type, Nummer', GetFilters, 10);
            CalcSums("Amount Including VAT", "Currency Amount");
            BetalingsValg.Get("No.");
            if BetalingsValg."Account Type" = BetalingsValg."Account Type"::"G/L Account" then begin
                if "Amount Including VAT" <> 0 then begin
                    PostTransaction(GetPaymentPostingSetup(BetalingsValg, "Register No."), "Amount Including VAT", "Register No.", AccountType::"G/L",
                                    TempPost."Department Code", '', BogfDate, TempPost);
                    SetFilter("Posting Date", '%1..', CalcDate('+1<D>', "Sale Date"));
                    CalcSums("Amount Including VAT");
                    if "Amount Including VAT" <> 0 then begin
                        CurrentPost := TempPost;
                        FindFirst;
                        repeat
                            SetRange("Posting Date", "Posting Date");
                            FindLast;
                            CalcSums("Amount Including VAT");
                            PostDayClearing(TempPost, BetalingsValg, "Amount Including VAT");
                            SetFilter("Posting Date", '>%1', CurrentPost."Sale Date");
                        until Next = 0;
                    end;
                    SetRange("Posting Date");
                    TempPost := CurrentPost;
                end;
            end;

            if BetalingsValg."Account Type" = BetalingsValg."Account Type"::Customer then begin
                BetalingsValg.TestField("Customer No.");
                if "Amount Including VAT" <> 0 then
                    PostTransaction(BetalingsValg."Customer No.", "Amount Including VAT", "Register No.", AccountType::Customer,
                    TempPost."Department Code", '', BogfDate, TempPost);
            end;
            if BetalingsValg."Account Type" = BetalingsValg."Account Type"::Bank then begin
                BankAccount.Get(GetPaymentPostingSetup(BetalingsValg, "Register No."));
                if (BankAccount."Currency Code" <> '') and (BankAccount."Currency Code" <> GeneralLedgerSetup."LCY Code") and ("Currency Amount" <> 0) then
                    PostTransaction(BankAccount."No.", "Currency Amount", "Register No.", AccountType::Bank,
                                     TempPost."Department Code", '', BogfDate, TempPost)
                else
                    if "Amount Including VAT" <> 0 then
                        PostTransaction(BankAccount."No.", "Amount Including VAT", "Register No.", AccountType::Bank,
                                         TempPost."Department Code", '', BogfDate, TempPost);
            end;
        end;
    end;

    procedure PostRegisterTransactionsPerEntry(var RevRulle: Record "NPR HC Audit Roll Posting" temporary)
    var
        Betalingsvalg: Record "NPR HC Payment Type POS";
        BankAccount: Record "Bank Account";
    begin
        GeneralLedgerSetup.Get;

        with RevRulle do begin
            Betalingsvalg.Get("No.");

            if Betalingsvalg."Account Type" = Betalingsvalg."Account Type"::"G/L Account" then begin
                if "Amount Including VAT" <> 0 then begin
                    PostTransaction(
                      GetPaymentPostingSetup(Betalingsvalg, RevRulle."Register No."),
                      "Amount Including VAT",
                      RevRulle."Register No.",
                      AccountType::"G/L",
                      RevRulle."Department Code",
                      RevRulle.Description,
                      BogfDate,
                      RevRulle);
                    if (RevRulle."Posting Date" <> 0D) and (RevRulle."Posting Date" <> RevRulle."Sale Date") then begin
                        PostDayClearing(RevRulle, Betalingsvalg, "Amount Including VAT");
                    end;
                end;
            end;

            if Betalingsvalg."Account Type" = Betalingsvalg."Account Type"::Customer then begin
                Betalingsvalg.TestField("Customer No.");
                if "Amount Including VAT" <> 0 then
                    PostTransaction(
                      Betalingsvalg."Customer No.",
                      "Amount Including VAT",
                      RevRulle."Register No.",
                      AccountType::Customer,
                      RevRulle."Department Code",
                      RevRulle.Description,
                      BogfDate,
                      RevRulle);
            end;

            if Betalingsvalg."Account Type" = Betalingsvalg."Account Type"::Bank then begin
                BankAccount.Get(GetPaymentPostingSetup(Betalingsvalg, RevRulle."Register No."));
                if (BankAccount."Currency Code" <> '') and (BankAccount."Currency Code" <> GeneralLedgerSetup."LCY Code") and ("Currency Amount" <> 0) then
                    PostTransaction(
                                 GetPaymentPostingSetup(Betalingsvalg, RevRulle."Register No."),
                                 "Currency Amount",
                                 RevRulle."Register No.",
                                 AccountType::Bank,
                                 RevRulle."Department Code",
                                 RevRulle.Description,
                                 BogfDate,
                                 RevRulle)
                else
                    if "Amount Including VAT" <> 0 then
                        PostTransaction(
                                         BankAccount."No.",
                                         "Amount Including VAT",
                                         RevRulle."Register No.",
                                         AccountType::Bank,
                                         RevRulle."Department Code",
                                         RevRulle.Description,
                                         BogfDate,
                                         RevRulle);
            end;
        end;
    end;

    procedure PostTransaction(AccNo: Code[20]; Amount2: Decimal; CashRegisterNo: Code[10]; AccType: Integer; GlobalDimension1: Code[20]; ForceDesc: Text[80]; PostingDate: Date; var TempPost: Record "NPR HC Audit Roll Posting" temporary)
    var
        Bogf1: Label 'Todays changes %1 Register %2';
        Bogf2: Label 'Paind on %1 Register %2';
        ItemGL: Record Item;
    begin
        Kasse.Get(CashRegisterNo);
        Clear(FinKldLinie);
        if Finkllbr = 0 then
            Finkllbr := GetLastGenJournalLine;
        Finkllbr += 10000;
        FinKldLinie."Line No." := Finkllbr;

        FinKldLinie."Document No." := GetDocumentNo(TempPost);
        FinKldLinie."Journal Template Name" := HCRetailSetup."Gen. Journal Template";
        FinKldLinie."Journal Batch Name" := HCRetailSetup."Gen. Journal Batch";
        FinKldLinie."Posting Date" := PostingDate;
        FinKldLinie."Document Date" := PostingDate;
        case AccType of
            AccountType::"G/L":
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";
            AccountType::Customer:
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::Customer;
            AccountType::Vendor:
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::Vendor;
            AccountType::Bank:
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::"Bank Account";
            AccountType::"Fixed Asset":
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::"Fixed Asset";
        end;

        FinKldLinie."Source Code" := HCRetailSetup."Posting Source Code";
        FinKldLinie."Bal. Account No." := '';
        FinKldLinie.Validate("Account No.", AccNo);

        if TempPost.Type = TempPost.Type::Item then
            FinKldLinie.Validate("Gen. Posting Type", FinKldLinie."Gen. Posting Type"::Sale);

        if TempPost.Type = TempPost.Type::Item then begin
            if ItemGL.Get(TempPost."No.") then begin
                FinKldLinie.Validate("Gen. Prod. Posting Group", ItemGL."Gen. Prod. Posting Group");
                FinKldLinie.Validate("VAT Prod. Posting Group", ItemGL."VAT Prod. Posting Group");
            end;

        end;

        FinKldLinie.Validate(Amount, Amount2);

        case AccType of
            AccountType::"G/L":
                begin
                    if RevisionUdbetaling."Sale Type" = RevisionUdbetaling."Sale Type"::"Out payment" then begin
                        FinKldLinie.Description := CopyStr(RevisionUdbetaling.Description, 1, 50);
                        Clear(RevisionUdbetaling);
                    end else
                        FinKldLinie.Description := StrSubstNo(Bogf1, PostingDate, CashRegisterNo);
                end;
            AccountType::Customer:
                FinKldLinie.Description := StrSubstNo(Bogf2, PostingDate, CashRegisterNo);
            AccountType::Bank:
                FinKldLinie.Description := StrSubstNo(Bogf1, PostingDate, CashRegisterNo);
        end;

        if ForceDesc <> '' then
            FinKldLinie.Description := ForceDesc;

        Kasse.Get(CashRegisterNo);

        FinKldLinie."Document Date" := PostingDate;
        FinKldLinie."System-Created Entry" := true;
        HCRetailSetup.Get;

        FinKldLinie."Shortcut Dimension 1 Code" := TempPost."Shortcut Dimension 1 Code";
        FinKldLinie."Shortcut Dimension 2 Code" := TempPost."Shortcut Dimension 2 Code";
        FinKldLinie."Dimension Set ID" := TempPost."Dimension Set ID";

        FinKldLinie.Insert;
        if HCRetailSetup."Gen. Journal Batch" <> '' then begin
            GenJournalLine := FinKldLinie;
            GenJournalLine.Insert(true);
        end;
    end;

    procedure PostTodaysGLEntries(var TempPost: Record "NPR HC Audit Roll Posting" temporary)
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        HCRetailSetup.Get;
        Clear(Counter);
        if FinKldLinie.Find('-') then begin
            Total := FinKldLinie.Count;
            repeat
                Counter += 1;
                if HCRetailSetup."Gen. Journal Batch" = '' then
                    GenJnlPostLine.RunWithCheck(FinKldLinie);
                UpdateStatusWindow(10, '', Round(Counter / Total) * 10000);
            until FinKldLinie.Next = 0;
        end;

        Clear(Counter);

        if VarekldLinie.Find('-') then begin
            Total := VarekldLinie.Count;
            repeat
                Counter += 1;
                if HCRetailSetup."Item Journal Batch" = '' then
                    ItemJnlPostLine.RunWithCheck(VarekldLinie);
                UpdateStatusWindow(11, '', Round(Counter / Total) * 10000);
            until VarekldLinie.Next = 0;
        end else
            UpdateStatusWindow(11, '', 10000);

        Debitorpost1.LockTable;
        if Debitorpost.Find('-') then begin
            if Debitorpost1.Find('+') then;
            DebPostLbrNr := Debitorpost1."Entry No.";
            repeat
                Debitorpost1 := Debitorpost;
                Debitorpost1."Entry No." := Debitorpost."Entry No." + DebPostLbrNr;
                HCRetailSetup.Get;
            until Debitorpost.Next = 0;
        end;
    end;

    procedure PostTodaysItemEntries(var TempPost: Record "NPR HC Audit Roll Posting" temporary)
    begin
        HCRetailSetup.Get;
        Clear(Counter);

        if VarekldLinie.Find('-') then begin
            Total := VarekldLinie.Count;
            repeat
                Counter += 1;
                if HCRetailSetup."Item Journal Batch" = '' then
                    ItemJnlPostLine.RunWithCheck(VarekldLinie);
                UpdateStatusWindow(11, '', Round(Counter / Total) * 10000);
            until VarekldLinie.Next = 0;
        end else
            UpdateStatusWindow(11, '', 10000);
    end;

    procedure PosterFremValDifferencer(var Rec: Record "NPR HC Audit Roll Posting" temporary)
    var
        DiffTekst: Label 'Cash register %1, Difference %2 %3';
        AuditRoll: Record "NPR HC Audit Roll";
        Betalingsvalg: Record "NPR HC Payment Type POS";
        HCAuditRoll2: Record "NPR HC Audit Roll";
        CurrencyAmount: Decimal;
        Amount2: Decimal;
        Difference: Decimal;
        ErrNotSet: Label 'Fixedprice on paymentsselection %1 has not been set';
    begin
        HCRetailSetup.Get();
        Kasse.Get(Rec."Register No.");

        Rec.TestField(Type, Rec.Type::"Open/Close");
        Rec.TestField(Posted, false);
        Rec.TestField(Balancing, true);

        HCAuditRoll2.SetRange("Register No.", Rec."Register No.");
        HCAuditRoll2.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");

        Betalingsvalg.SetRange("To be Balanced", true);
        Betalingsvalg.SetRange("Processing Type",
                               Betalingsvalg."Processing Type"::"Foreign Currency");

        if Betalingsvalg.FindSet then
            repeat
                Amount2 := 0;
                CurrencyAmount := 0;

                AuditRoll.SetRange("Register No.", Rec."Register No.");
                AuditRoll.SetRange("Sale Date", Rec."Sale Date");
                if AuditRoll.FindFirst then
                    repeat
                        if (AuditRoll."Sale Type" = AuditRoll."Sale Type"::Payment) and
                          (AuditRoll.Type = AuditRoll.Type::Payment) and
                          (AuditRoll."No." = Betalingsvalg."No.") then
                            CurrencyAmount += AuditRoll."Currency Amount";
                    until (AuditRoll.Next = 0) or (AuditRoll.Type = AuditRoll.Type::"Open/Close");
                HCAuditRoll2.SetRange("Payment Type No.", Betalingsvalg."No.");

                if HCAuditRoll2.FindSet then
                    repeat
                        Amount2 += HCAuditRoll2.Amount;
                    until HCAuditRoll2.Next = 0;

                Difference := CurrencyAmount - Amount2;

                // Insert G/L journal line.
                if Difference > 0 then begin

                    if Finkllbr = 0 then
                        Finkllbr := GetLastGenJournalLine;
                    Finkllbr += 10000;
                    FinKldLinie.Init;
                    FinKldLinie."Journal Template Name" := HCRetailSetup."Gen. Journal Template";
                    FinKldLinie."Journal Batch Name" := HCRetailSetup."Gen. Journal Batch";

                    FinKldLinie."Line No." := Finkllbr;

                    FinKldLinie."Document No." := GetDocumentNo(Rec);

                    FinKldLinie."Posting Date" := Rec."Sale Date";
                    FinKldLinie."Document Date" := Rec."Sale Date";
                    FinKldLinie."Source Code" := HCRetailSetup."Posting Source Code";

                    if Difference > 0 then
                        FinKldLinie.Validate("Account No.", Kasse."Difference Account");
                    if Difference < 0 then
                        FinKldLinie.Validate("Account No.", Kasse."Difference Account - Neg.");

                    if (Betalingsvalg."Fixed Rate" <= 0) and
                       (Betalingsvalg."Processing Type" <> Betalingsvalg."Processing Type"::Cash) then
                        Error(ErrNotSet, Betalingsvalg."No.");

                    if Betalingsvalg."Processing Type" <> Betalingsvalg."Processing Type"::Cash then
                        FinKldLinie.Validate(Amount, Difference * Betalingsvalg."Fixed Rate" / 100)
                    else
                        FinKldLinie.Validate(Amount, Difference * Betalingsvalg."Fixed Rate" / 100);

                    if Betalingsvalg."Account Type" = Betalingsvalg."Account Type"::"G/L Account" then begin
                        FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";
                        FinKldLinie.Validate("Bal. Account No.", GetPaymentPostingSetup(Betalingsvalg, Rec."Register No."));
                    end;
                    if Betalingsvalg."Account Type" = Betalingsvalg."Account Type"::Bank then begin
                        FinKldLinie."Account Type" := FinKldLinie."Account Type"::"Bank Account";
                        FinKldLinie.Validate("Bal. Account No.", GetPaymentPostingSetup(Betalingsvalg, Rec."Register No."));
                    end;

                    FinKldLinie.Description := StrSubstNo(DiffTekst, Rec."Register No.", Difference, Betalingsvalg.Description);

                    FinKldLinie."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
                    FinKldLinie."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
                    FinKldLinie."Dimension Set ID" := Rec."Dimension Set ID";

                    HCRetailSetup.Get;

                    FinKldLinie."System-Created Entry" := true;

                    FinKldLinie.Insert;
                    if HCRetailSetup."Gen. Journal Batch" <> '' then begin
                        GenJournalLine := FinKldLinie;
                        GenJournalLine.Insert(true);
                    end;
                end;
            until Betalingsvalg.Next = 0;
    end;

    procedure PosterVarekladde(var RevRulle: Record "NPR HC Audit Roll Posting" temporary; Straks: Boolean; Bogfdate: Date): Boolean
    var
        Sporing: Record "Reservation Entry";
        Varepost: Record "Item Ledger Entry";
        ErrSerial: Label 'Serialno. %2 on item %1 has allready been sold!';
        ItemTrackingCode: Record "Item Tracking Code";
        Item: Record Item;
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        HCRetailSetup.Get;

        with RevRulle do begin
            CreateRetPurchOrder(RevRulle);

            Kasse.Get("Register No.");
            VarekldLinie.Init;
            if Varekllbr = 0 then
                Varekllbr := GetLastItemJournalLine;
            Varekllbr += 10000;
            VarekldLinie."Journal Template Name" := HCRetailSetup."Item Journal Template";
            VarekldLinie."Journal Batch Name" := HCRetailSetup."Item Journal Batch";
            VarekldLinie."Line No." := Varekllbr;

            if HCRetailSetup."Appendix no. eq Sales Ticket" then
                VarekldLinie."Document No." := "Sales Ticket No."
            else
                VarekldLinie."Document No." := GetDocumentNo(RevRulle);

            VarekldLinie."Entry Type" := VarekldLinie."Entry Type"::Sale;
            VarekldLinie."Source No." := "Customer No.";
            VarekldLinie."Source Type" := VarekldLinie."Source Type"::Customer;

            VarekldLinie."Posting Date" := Bogfdate;
            VarekldLinie."Document Date" := Bogfdate;
            VarekldLinie."Discount Amount" := "Line Discount Amount";
            if (VarekldLinie."Discount Amount" <> 0) and Item.Get(RevRulle."No.") then begin
                if Item."Price Includes VAT" then
                    VarekldLinie."Discount Amount" := VarekldLinie."Discount Amount" / ((100 + RevRulle."VAT %") / 100);
            end;
            VarekldLinie."Reason Code" := "Reason Code";
            VarekldLinie."Bin Code" := "Bin Code";

            if Vare.Type <> Vare.Type::Service then
                VarekldLinie.Validate("Item No.", "No.")
            else begin
                VarekldLinie."Item No." := "No.";
                VarekldLinie."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
                VarekldLinie."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
            end;
            VarekldLinie.Validate(Quantity, Quantity);
            if not ItemUnitofMeasure.Get("No.", Unit) then begin
                Item.Get("No.");
                VarekldLinie.Validate("Unit of Measure Code", Item."Base Unit of Measure");
            end else
                VarekldLinie.Validate("Unit of Measure Code", Unit);
            VarekldLinie.Validate(Amount, Amount);
            VarekldLinie."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            VarekldLinie.Description := Description;
            VarekldLinie."Salespers./Purch. Code" := "Salesperson Code";
            if Lokationskode = '' then
                VarekldLinie."Location Code" := Kasse."Location Code" else
                VarekldLinie."Location Code" := Lokationskode;
            VarekldLinie."Source Code" := HCRetailSetup."Posting Source Code";
            if "Serial No." <> '' then begin
                Sporing.SetCurrentKey("Entry No.", Positive);
                Sporing.SetRange(Positive, false);
                if Sporing.Find('+') then;
                Sporing.Init;
                Sporing."Entry No." += 1;
                Sporing.Positive := false;
                Sporing."Item No." := "No.";
                Sporing."Location Code" := Lokationskode;
                Sporing."Quantity (Base)" := -Quantity;
                Sporing."Reservation Status" := Sporing."Reservation Status"::Prospect;
                Vare.TestField("Item Tracking Code");
                ItemTrackingCode.Get(Vare."Item Tracking Code");
                if ItemTrackingCode."SN Specific Tracking" then begin
                    Varepost.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
                    Varepost.SetRange(Open, true);
                    Varepost.SetRange(Positive, true);
                    Varepost.SetRange("Serial No.", "Serial No.");
                    Varepost.SetRange("Item No.", "No.");
                    Varepost.FindFirst;
                    Sporing."Creation Date" := Varepost."Posting Date";
                end else begin
                    if Quantity <= 0 then begin
                        Sporing."Creation Date" := Today;
                        VarekldLinie.Validate(Amount, -VarekldLinie.Amount);
                    end;
                end;
                Sporing."Source Type" := 83;
                Sporing."Source Subtype" := 1;
                Sporing."Source ID" := VarekldLinie."Journal Template Name";
                Sporing."Source Batch Name" := VarekldLinie."Journal Batch Name";
                Sporing."Source Ref. No." := VarekldLinie."Line No.";
                Sporing."Expected Receipt Date" := Today;
                Sporing."Serial No." := "Serial No.";
                Sporing."Created By" := RevRulle."Salesperson Code";
                Sporing."Qty. per Unit of Measure" := Quantity;
                Sporing.Quantity := -Quantity;
                Sporing."Qty. to Handle (Base)" := -Quantity;
                Sporing."Qty. to Invoice (Base)" := -Quantity;
                Sporing.Insert;
            end;
            VarekldLinie."Variant Code" := CopyStr("Variant Code", 1, 10);

            if "Unit Cost" <> 0 then
                VarekldLinie.Validate("Unit Cost", "Unit Cost");

            VarekldLinie.Validate("Return Reason Code", "Return Reason Code");
            VarekldLinie."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            VarekldLinie."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            VarekldLinie."Dimension Set ID" := "Dimension Set ID";

            VarekldLinie.Insert;
            if HCRetailSetup."Item Journal Batch" <> '' then begin
                ItemJournalLine := VarekldLinie;
                ItemJournalLine.Insert(true);
            end;

            if Straks then begin
                if HCRetailSetup."Item Journal Batch" = '' then
                    ItemJnlPostLine.RunWithCheck(VarekldLinie);
            end;
        end;

    end;

    procedure PosterDebitorIndbetaling(var RevRulle: Record "NPR HC Audit Roll Posting" temporary)
    var
        Kasse: Record "NPR HC Register";
        txtIndbetaling: Label 'Payment';
        txtIndbetalingSales: Label 'Payment on %1 %2';
        Bogf1: Label 'POS-Debitsale on %1 Register %2';
        txtKasse: Label '%1/Register %2';
        TmpJrnlLineDimloc: Codeunit "Temp Blob";
        SalesHeader: Record "Sales Header";
        SalesPostYNPrepmt: Codeunit "Sales-Post Prepayment (Yes/No)";
        SalesPost: Codeunit "Sales-Post";
        SalesDocTypeText: Text;
        PrepayPercent: Decimal;
        txtSalesQuote: Label 'quote';
        txtSalesOrder: Label 'order';
        txtSalesInoice: Label 'invoice';
        txtSalesCreditMemo: Label 'credit memo';
        txtSalesBlanketOrder: Label 'blanket order';
        txtSalesReturnOrder: Label 'return order';
    begin
        Clear(FinKldLinie);

        with RevRulle do begin
            HCRetailSetup.Get;
            if Finkllbr = 0 then
                Finkllbr := GetLastGenJournalLine;
            Finkllbr += 10000;
            FinKldLinie."Line No." := Finkllbr;
            FinKldLinie."Journal Template Name" := HCRetailSetup."Gen. Journal Template";
            FinKldLinie."Journal Batch Name" := HCRetailSetup."Gen. Journal Batch";
            FinKldLinie."Document No." := GetDocumentNo(RevRulle);

            FinKldLinie."Posting Date" := BogfDate;
            FinKldLinie."Document Date" := BogfDate;
            FinKldLinie."Source Code" := HCRetailSetup."Posting Source Code";
            FinKldLinie."Bal. Account No." := '';
            if "Sale Type" = "Sale Type"::Deposit then begin
                FinKldLinie.Validate("Document Type", FinKldLinie."Document Type"::Payment);
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::Customer;
                FinKldLinie.Validate("Account No.", "No.");
                FinKldLinie.Validate(Amount, -"Amount Including VAT");
                FinKldLinie."Allow Application" := true;
                /*************************************************************************
                * Bruges kun i forbindelse med udl�sninger fa gl.Butik3 / Butik2000     *
                * l�sninger. Konverterer debetsalg til finansposteringer p� debitor     *
                *************************************************************************/
                if "N3 Debit Sale Conversion" then
                    FinKldLinie.Description := StrSubstNo(Bogf1, BogfDate, "Register No.")
                else begin
                    if RevRulle."Sales Document No." <> '' then begin
                        case RevRulle."Sales Document Type" of
                            SalesHeader."Document Type"::Quote:
                                SalesDocTypeText := txtSalesQuote;
                            SalesHeader."Document Type"::Order:
                                SalesDocTypeText := txtSalesOrder;
                            SalesHeader."Document Type"::Invoice:
                                SalesDocTypeText := txtSalesInoice;
                            SalesHeader."Document Type"::"Credit Memo":
                                SalesDocTypeText := txtSalesCreditMemo;
                            SalesHeader."Document Type"::"Blanket Order":
                                SalesDocTypeText := txtSalesBlanketOrder;
                            SalesHeader."Document Type"::"Return Order":
                                SalesDocTypeText := txtSalesReturnOrder;
                        end;
                        FinKldLinie.Description := StrSubstNo(txtIndbetalingSales, SalesDocTypeText, RevRulle."Sales Document No.");
                    end else
                        FinKldLinie.Description := txtIndbetaling;
                end;
            end;


            if (Type = Type::Payment) then begin
                BetalingsValg.Get("No.");
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";
                FinKldLinie.Validate("Account No.", GetPaymentPostingSetup(BetalingsValg, "Register No."));
                FinKldLinie.Validate(Amount, "Amount Including VAT");
                FinKldLinie.Description := StrSubstNo(txtKasse, Description, "Register No.");
            end;

            if (Type = Type::"G/L") then begin
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";
                FinKldLinie.Validate("Account No.", "No.");
                FinKldLinie.Validate(Amount, "Amount Including VAT");
                FinKldLinie.Description := StrSubstNo(txtKasse, Description, "Register No.")
            end;

            Kasse.Get("Register No.");

            FinKldLinie."Document Date" := BogfDate;
            FinKldLinie."Applies-to Doc. Type" := RevRulle."Buffer Document Type";
            FinKldLinie.Validate("Applies-to Doc. No.", RevRulle."Buffer Invoice No.");
            FinKldLinie."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            FinKldLinie."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            FinKldLinie."Dimension Set ID" := "Dimension Set ID";

            HCRetailSetup.Get;

            FinKldLinie."System-Created Entry" := true;

            FinKldLinie.Insert;

            if HCRetailSetup."Gen. Journal Batch" <> '' then begin
                GenJournalLine := FinKldLinie;
                GenJournalLine.Insert(true);
            end;

            Modify;

            if SalesHeader.Get("Sales Document Type", "Sales Document No.") then begin
                if "Sales Document Prepayment" then begin
                    SalesHeader.CalcFields("Amount Including VAT");
                    SalesHeader.SetHideValidationDialog(true);
                    SalesHeader.Validate("Prepayment %", RevRulle."Sales Doc. Prepayment %");
                    SalesHeader.Modify(true);
                    PostPrepmtInvoiceYN(SalesHeader);

                end;
                if "Sales Document Invoice" or "Sales Document Ship" then begin
                    SalesHeader.Ship := "Sales Document Ship";
                    SalesHeader.Invoice := "Sales Document Invoice";
                    SalesHeader.Modify;
                    SalesPost.Run(SalesHeader);
                end;
            end;
        end;

    end;

    procedure PosterKasseAfslutning(var Rec: Record "NPR HC Audit Roll Posting" temporary)
    var
        "Bogf. Tekst 1": Label 'EOD register %1';
        "Bogf. Tekst 2": Label 'Cash register %1 to bank';
        "Bogf. Tekst 3": Label 'Register %1 to Change Register';
    begin

        HCRetailSetup.Get();
        Kasse.Get(Rec."Register No.");

        Rec.TestField(Type, Rec.Type::"Open/Close");
        Rec.TestField(Posted, false);
        Rec.TestField(Balancing, true);

        // ********************************
        //  Difference
        // ********************************

        if Rec.Difference <> 0 then begin
            if Finkllbr = 0 then
                Finkllbr := GetLastGenJournalLine;
            Finkllbr += 10000;
            FinKldLinie.Init;
            FinKldLinie."Line No." := Finkllbr;
            FinKldLinie."Journal Template Name" := HCRetailSetup."Gen. Journal Template";
            FinKldLinie."Journal Batch Name" := HCRetailSetup."Gen. Journal Batch";
            FinKldLinie."Document No." := GetDocumentNo(Rec);

            FinKldLinie."Posting Date" := Rec."Sale Date";
            FinKldLinie."Document Date" := Rec."Sale Date";
            FinKldLinie."Source Code" := HCRetailSetup."Posting Source Code";

            if Rec.Difference > 0 then
                FinKldLinie.Validate("Account No.", Kasse."Difference Account");

            if Rec.Difference < 0 then
                FinKldLinie.Validate("Account No.", Kasse."Difference Account - Neg.");

            FinKldLinie.Validate(Amount, Rec.Difference);
            FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";

            FinKldLinie.Validate("Bal. Account No.", Kasse.Account);
            FinKldLinie.Description := StrSubstNo("Bogf. Tekst 1", Rec."Register No.");
            FinKldLinie."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
            FinKldLinie."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
            FinKldLinie."Dimension Set ID" := Rec."Dimension Set ID";

            HCRetailSetup.Get;

            FinKldLinie."System-Created Entry" := true;

            FinKldLinie.Insert;
            if HCRetailSetup."Gen. Journal Batch" <> '' then begin
                GenJournalLine := FinKldLinie;
                GenJournalLine.Insert(true);
            end;

        end;

        PosterFremValDifferencer(Rec);

        // ********************************
        //  Overf¢r til Bank
        // ********************************

        if Rec."Transferred to Balance Account" <> 0 then begin
            if Finkllbr = 0 then
                Finkllbr := GetLastGenJournalLine;
            Finkllbr += 10000;
            FinKldLinie.Init;
            FinKldLinie."Journal Template Name" := HCRetailSetup."Gen. Journal Template";
            FinKldLinie."Journal Batch Name" := HCRetailSetup."Gen. Journal Batch";
            FinKldLinie."Line No." := Finkllbr;

            FinKldLinie."Document No." := GetDocumentNo(Rec);

            FinKldLinie."Posting Date" := Rec."Sale Date";
            FinKldLinie."Document Date" := Rec."Sale Date";
            if Kasse."Balanced Type" = Kasse."Balanced Type"::Finans then
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account"
            else
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::"Bank Account";
            FinKldLinie."Source Code" := HCRetailSetup."Posting Source Code";

            FinKldLinie.Validate("Account No.", Kasse."Balance Account");
            FinKldLinie.Validate(Amount, Rec."Transferred to Balance Account");

            FinKldLinie.Validate("Bal. Account No.", Kasse.Account);

            FinKldLinie.Description := StrSubstNo("Bogf. Tekst 2", Rec."Register No.");

            FinKldLinie."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
            FinKldLinie."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
            FinKldLinie."Dimension Set ID" := Rec."Dimension Set ID";

            HCRetailSetup.Get;

            FinKldLinie."System-Created Entry" := true;

            FinKldLinie.Insert;

            if HCRetailSetup."Gen. Journal Batch" <> '' then begin
                GenJournalLine := FinKldLinie;
                GenJournalLine.Insert(true);
            end;

        end;


        // ********************************
        //  Overf¢r til Vekselkasse
        // ********************************

        if Rec."Change Register" <> 0 then begin
            if Finkllbr = 0 then
                Finkllbr := GetLastGenJournalLine;
            Finkllbr += 10000;
            FinKldLinie.Init;
            FinKldLinie."Journal Template Name" := HCRetailSetup."Gen. Journal Template";
            FinKldLinie."Journal Batch Name" := HCRetailSetup."Gen. Journal Batch";
            FinKldLinie."Line No." := Finkllbr;

            FinKldLinie."Document No." := GetDocumentNo(Rec);

            FinKldLinie."Posting Date" := Rec."Sale Date";
            FinKldLinie."Document Date" := Rec."Sale Date";
            if Kasse."Balanced Type" = Kasse."Balanced Type"::Finans then
                FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";

            FinKldLinie."Source Code" := HCRetailSetup."Posting Source Code";
            Kasse.TestField("Register Change Account");
            FinKldLinie.Validate("Account No.", Kasse."Register Change Account");
            FinKldLinie.Validate(Amount, Rec."Change Register");

            FinKldLinie.Validate("Bal. Account No.", Kasse.Account);
            FinKldLinie.Description := StrSubstNo("Bogf. Tekst 3", Rec."Register No.");

            FinKldLinie."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
            FinKldLinie."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
            FinKldLinie."Dimension Set ID" := Rec."Dimension Set ID";

            HCRetailSetup.Get;

            FinKldLinie."System-Created Entry" := true;

            FinKldLinie.Insert;

            if HCRetailSetup."Gen. Journal Batch" <> '' then begin
                GenJournalLine := FinKldLinie;
                GenJournalLine.Insert(true);
            end;

        end;
    end;

    procedure OpenStatusWindow()
    var
        ln100: Label ' Transferring             @100@@@@@@@@@@@@@@@@ \';
        ln101: Label ' Removing Old Lines       @101@@@@@@@@@@@@@@@@ \';
        ln102: Label ' Testing                  @102@@@@@@@@@@@@@@@@ \\';
        ln103: Label ' Updating Changes         @103@@@@@@@@@@@@@@@@ \';
        ln1: Label ' G/L Posting \';
        ln2: Label ' Processing Date          #1################## \';
        ln3: Label ' Register No.             #2################## \';
        ln5: Label ' Customer payment         @6@@@@@@@@@@@@@@@@@@ \';
        ln4: Label ' Debit No-Sale Entry      @8@@@@@@@@@@@@@@@@@@ \';
        ln6: Label ' Item Posting             @3@@@@@@@@@@@@@@@@@@ \';
        ln7: Label ' G/L Item Posting         @4@@@@@@@@@@@@@@@@@@ \';
        ln8: Label ' Net Change               @5@@@@@@@@@@@@@@@@@@ \';
        ln10: Label ' G/L / Payout             @7@@@@@@@@@@@@@@@@@@ \\';
        ln11: Label ' Posting G/L Entries      @10@@@@@@@@@@@@@@@@@ \';
        ln12: Label ' Posting Item Entries     @11@@@@@@@@@@@@@@@@@ \\';
    begin
        //StatusVindueÅben()

        WindowIsOpen := true;

        Window.Open(ln100 + ln101 + ln102 + ln1 + ln2 + ln3 + ln4 + ln5 + ln7 + ln8 + ln10 + ln11 + ln6 + ln12 + ln103);
    end;

    procedure ClearStatusWindow()
    var
        heltal: Record "Integer";
    begin
        if not WindowIsOpen then
            exit;

        heltal.SetRange(Number, 3, 11);
        if heltal.Find('-') then
            repeat
                Window.Update(heltal.Number, 0);
            until heltal.Next = 0;

        Window.Update(103, 0);
    end;

    procedure CloseStatusWindow(Text: Text[100])
    begin
        if not WindowIsOpen then
            exit;
        Window.Close;
        WindowIsOpen := false;
    end;

    procedure UpdateStatusWindow(Number: Integer; Text: Text[100]; Value: Integer)
    begin
        if not WindowIsOpen then exit;

        if (Number in [1, 2]) then
            Window.Update(Number, Text)
        else
            Window.Update(Number, Value)
    end;

    procedure GetDocumentNo(var TempPost: Record "NPR HC Audit Roll Posting" temporary): Code[20]
    var
        txtPos: Label 'POS %1-%2';
    begin
        if PostOnlySalesTicketNo then
            if GlobalPostingNo = '' then
                exit(StrSubstNo(txtPos, TempPost."Register No.", TempPost."Sales Ticket No."))
            else
                exit(StrSubstNo(txtPos, Kasse."Register No.", GlobalPostingNo))
        else
            exit(StrSubstNo(txtPos, Kasse."Register No.", GlobalPostingNo));
    end;

    procedure StraksBogfCurrent(SetProp: Boolean)
    begin
        StraksBogf := SetProp;
    end;

    procedure PrintKey("Key": Text[250]; "Filter": Text[500]; ID: Integer)
    var
        Msg: Label 'Key : %1\Filter : %2\ID : %3';
        t001: Label 'Debug posting stopped';
    begin
        if DebugPostingMsg then
            if not Confirm(Msg, true, Key, Filter, ID) then
                Error(t001);
    end;

    procedure RunPost(var Rec: Record "NPR HC Audit Roll Posting" temporary)
    var
        BetValgRec: Record "NPR HC Payment Type POS";
        XBonNr: Code[20];
        ChangeSum: Decimal;
        ChangeDep: Code[20];
    begin
        with Rec do begin
            DebugPostingMsg := false;
            HCRetailSetup.Get();

            if not Rec.FindLast then
                exit;

            if not DoNotPost then begin
                Kasse.Get("Register No.");
                PostOnlySalesTicketNo := true;
                if FindSet then begin
                    XBonNr := "Sales Ticket No.";
                    repeat
                        if (XBonNr <> "Sales Ticket No.") then
                            PostOnlySalesTicketNo := false;
                        XBonNr := "Sales Ticket No.";
                    until (Next = 0) or (not PostOnlySalesTicketNo);
                end;

                HCRetailSetup.Get;

                FinKldLinie.DeleteAll;
                VarekldLinie.DeleteAll;
                Debitorpost.DeleteAll;

                HCRetailSetup.TestField("Posting Source Code");
                BogfDate := Rec."Sale Date";

                UpdateStatusWindow(1, Format(BogfDate), 0);
                UpdateStatusWindow(2, "Register No.", 0);

                LockTable;

                /* #########################################
                   Post register balancing (end-of-day )
                  ######################################### */

                Reset;
                SetCurrentKey(Type, Balancing);
                SetRange(Type, Type::"Open/Close");
                SetRange(Balancing, true);
                PrintKey('Type,Kasseafslutning', GetFilters, 1);
                if FindFirst then
                    repeat
                        PosterKasseAfslutning(Rec);
                    until Next = 0;

                /* #########################################
                   Post customer entries to debit zero sales
                  ######################################### */

                Clear(Quantity);
                Clear(Dummy);
                Reset;
                if Debitorpost.Find('+')
                  then
                    ;
                SetCurrentKey("Sale Type", Type, "Customer Type", "Customer No.");
                SetRange("Sale Type", "Sale Type"::Payment);
                SetRange(Type, Type::Payment);
                SetRange("Customer Type", "Customer Type"::Alm);
                SetFilter("Customer No.", '<> %1', blank);
                Total := Count;
                PrintKey('Ekspeditionsart, Type, Debitortype, Kundenummer', GetFilters, 2);
                Dummy.CopyFilters(Rec);
                if FindSet then begin
                    repeat
                        Counter += Count;
                        SetCurrentKey("Sale Type", Type, "Customer Type", "Customer No.");
                        CopyFilters(Dummy);
                        FindLast;
                        UpdateStatusWindow(8, '', Round(Counter / Total) * 10000);
                    until Next = 0;
                end;
                UpdateStatusWindow(8, '', 10000);

                /* ########################################
                  Post payments on customer account
                  ######################################## */

                Reset;
                Clear(Quantity);
                SetCurrentKey("Sale Type", Type);
                SetRange("Sale Type", "Sale Type"::Deposit);
                SetRange(Type, Type::Customer);
                Total := Count;
                PrintKey('Ekspeditionsart, Type', GetFilters, 3);
                if FindSet then begin
                    repeat
                        Counter += 1;
                        PosterDebitorIndbetaling(Rec);
                        UpdateStatusWindow(6, '', Round(Counter / Total) * 10000);
                    until Next = 0
                end;
                UpdateStatusWindow(6, '', 10000);

                /* ################################################
                  Post (item) sales on g/l accounts
                  ################################################ */

                Clear(Dummy);
                Clear(Counter);
                Reset;
                SetCurrentKey("Sale Type", Type,
                                "Gen. Bus. Posting Group", "Gen. Prod. Posting Group",
                                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID",
                                "VAT Bus. Posting Group", "VAT Prod. Posting Group");
                SetRange("Sale Type", "Sale Type"::Sale);
                SetRange(Type, Type::Item);
                Total := Count;
                PrintKey('Kassenummer,Ekspeditionsdato,Ekspeditionsart,Type,Bogf�rt...', GetFilters, 5);
                PrintKey('"Virksomheds-bogf�ringsgruppe","Produkt-bogf�ringsgruppe"', GetFilters, 5);
                Dummy.CopyFilters(Rec);
                if FindFirst then begin
                    repeat
                        SetRange("Gen. Bus. Posting Group", "Gen. Bus. Posting Group");
                        SetRange("Gen. Prod. Posting Group", "Gen. Prod. Posting Group");
                        SetRange("VAT Bus. Posting Group", "VAT Bus. Posting Group");
                        SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");
                        SetRange("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
                        SetRange("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
                        SetRange("Dimension Set ID", "Dimension Set ID");
                        Counter += Count;
                        PostItemSale(Rec);
                        SetCurrentKey("Sale Type", Type,
                                        "Gen. Bus. Posting Group", "Gen. Prod. Posting Group",
                                        "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID",
                                        "VAT Bus. Posting Group", "VAT Prod. Posting Group");
                        FindLast;
                        CopyFilters(Dummy);
                        UpdateStatusWindow(4, '', Round(Counter / Total) * 10000);
                    until Next = 0;
                end;
                UpdateStatusWindow(4, '', 10000);

                /* ##############################################
                  Post money transactions - Payments
                  ############################################## */

                Clear(Counter);
                Clear(Dummy);
                Reset;
                SetCurrentKey("Sale Type", Type, "No.", "Posting Date", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID");
                SetRange("Sale Type", "Sale Type"::Payment);
                SetRange(Type, Type::Payment);
                Total := Count;
                PrintKey('Ekspeditionsart, Type, Nummer', GetFilters, 6);
                Dummy.CopyFilters(Rec);
                if FindSet then begin
                    repeat
                        BetValgRec.Get("No.");
                        case BetValgRec.Posting of
                            BetValgRec.Posting::Condensed:
                                begin
                                    SetRange("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
                                    SetRange("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
                                    SetRange("Dimension Set ID", "Dimension Set ID");
                                    PostRegisterTransactions(Rec);
                                    Counter += Count;
                                    SetCurrentKey("Sale Type", Type, "No.", "Posting Date", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID");
                                    FindLast;
                                    CopyFilters(Dummy);
                                    UpdateStatusWindow(5, '', Round(Counter / Total) * 10000);
                                end;
                            BetValgRec.Posting::"Single Entry":
                                begin
                                    PostRegisterTransactionsPerEntry(Rec);
                                    Counter += 1;
                                    UpdateStatusWindow(5, '', Round(Counter / Total) * 10000);
                                end;
                        end;
                    until Next = 0;
                end;
                UpdateStatusWindow(5, '', 10000);

                /* #################################################################
                  Post payments on g/l account - gift/credit vouchers
                  ################################################################# */

                Clear(Counter);
                Reset;
                SetCurrentKey("Sale Type", Type);
                SetRange("Sale Type", "Sale Type"::Deposit);
                SetRange(Type, Type::"G/L");
                Total := Count;
                PrintKey('Ekspeditionsart, Type', GetFilters, 7);
                if FindSet then
                    repeat
                        Counter += 1;
                        PostTransaction("No.", -"Amount Including VAT", "Register No.", AccountType::"G/L", "Department Code", '', BogfDate, Rec);
                        UpdateStatusWindow(9, '', Round(Counter / Total) * 10000);
                    until Next = 0;
                UpdateStatusWindow(9, '', 10000);

                /* ##############################################
                  Post outpayments on g/l accounts
                  ############################################## */

                Clear(Counter);
                Reset;
                SetCurrentKey("Sale Type", Type);
                SetRange("Sale Type", "Sale Type"::"Out payment");
                SetRange(Type, Type::"G/L");
                Total := Count;
                PrintKey('Ekspeditionsart,Type', GetFilters, 8);
                if FindSet then
                    repeat
                        RevisionUdbetaling := Rec;
                        Counter += 1;
                        if "No." = Kasse.Rounding then begin
                            ChangeSum += "Amount Including VAT";
                            ChangeDep := "Department Code";
                        end else
                            PostTransaction("No.", "Amount Including VAT", "Register No.", AccountType::"G/L", "Department Code", '', BogfDate, Rec);
                        UpdateStatusWindow(7, '', Round(Counter / Total) * 10000);
                    until Next = 0;
                if ChangeSum <> 0 then
                    PostTransaction(Kasse.Rounding, ChangeSum, "Register No.", AccountType::"G/L", ChangeDep, '', BogfDate, Rec);

                UpdateStatusWindow(7, '', 10000);

                Reset;

                PostTodaysGLEntries(Rec);

                Reset;

                SetRange("Posted Doc. No.", '');
                ModifyAll("Posted Doc. No.", GetDocumentNo(Rec));
                SetRange("Posted Doc. No.");
                ModifyAll(Posted, true);
                FinKldLinie.DeleteAll(true);
                VarekldLinie.DeleteAll(true);

            end;   /*** DoNotbogf�r ***/

            Reset;

        end;

    end;

    procedure RunPostItemLedger(var Rec: Record "NPR HC Audit Roll Posting" temporary)
    var
        XBonNr: Code[20];
    begin
        with Rec do begin
            DebugPostingMsg := false;
            HCRetailSetup.Get();

            if not Rec.FindLast then
                exit;

            if not DoNotPost then begin
                PostOnlySalesTicketNo := true;
                if Find('-') then begin
                    XBonNr := "Sales Ticket No.";
                    repeat
                        if (XBonNr <> "Sales Ticket No.") then
                            PostOnlySalesTicketNo := false;
                        XBonNr := "Sales Ticket No.";
                    until (Next = 0) or (not PostOnlySalesTicketNo);
                end;

                HCRetailSetup.Get;

                FinKldLinie.DeleteAll;
                VarekldLinie.DeleteAll;
                Debitorpost.DeleteAll;

                HCRetailSetup.TestField("Posting Source Code");
                BogfDate := Rec."Sale Date";

                UpdateStatusWindow(1, Format(BogfDate), 0);
                UpdateStatusWindow(2, "Register No.", 0);

                LockTable;

                /* ##############################################
                  Post�rer Varebev�gelser
                  ############################################## */

                Reset;
                SetCurrentKey("Sale Type", Type, "Item Entry Posted");
                SetRange("Sale Type", "Sale Type"::Sale);
                SetRange(Type, Type::Item);
                SetRange("Item Entry Posted", false);
                Total := Count;
                Clear(Counter);
                PrintKey('Ekspeditionsart, Type, "Varepost bogf�rt"', GetFilters, 4);
                if FindSet then begin
                    repeat
                        Counter += 1;
                        if Quantity <> 0 then begin
                            PosterVarekladde(Rec, false, BogfDate);
                        end;
                        UpdateStatusWindow(3, '', Round(Counter / Total) * 10000);
                    until Next = 0;
                end;
                UpdateStatusWindow(3, '', 10000);

                Rec.ModifyAll("Item Entry Posted", true);

                Reset;

                PostTodaysItemEntries(Rec);

                Reset;

            end;   /*** DoNotbogf�r ***/

            if StraksBogfVarePostFraEkspAfsl then begin
                SetCurrentKey("Sale Type", Type, "Item Entry Posted");
                SetRange("Sale Type", "Sale Type"::Sale);
                SetRange(Type, Type::Item);
                SetRange("Item Entry Posted", false);


                if FindSet then
                    repeat
                        PosterVarekladde(Rec, true, Rec."Sale Date");
                        Modify;
                    until Next = 0;
                ModifyAll("Item Entry Posted", true);
            end;

            Reset;

        end;

    end;

    procedure SetProgressVis(Vis: Boolean)
    begin
        ProgressVis := Vis;
    end;

    procedure RunTest(var Rec: Record "NPR HC Audit Roll Posting" temporary)
    var
        Vare: Record Item;
        Debitor: Record Customer;
        Finanskonto: Record "G/L Account";
        Betalingsvalg: Record "NPR HC Payment Type POS";
        "BogfOps.": Record "General Posting Setup";
        MomsbogfOps: Record "VAT Posting Setup";
        VirksBogfGrp: Record "Gen. Business Posting Group";
        ProdBogfGrp: Record "Gen. Product Posting Group";
        DebBogfGrp: Record "Customer Posting Group";
        t001: Label 'Item %1 %2 does not exists. Posting has terminated!';
        t002: Label 'Customer %1 %2 does not exists. Posting terminated!';
        t003: Label 'Financialaccount %1 %2 does not exists. Posting terminated!';
        nCount: Integer;
        nTotal: Integer;
    begin
        with Rec do begin
            Reset;
            SetCurrentKey("Sale Date");
            nTotal := Rec.Count;

            if Find('-') then
                repeat
                    if ProgressVis then begin
                        nCount += 1;
                        Window.Update(102, Round(nCount / nTotal * 10000, 1, '>'));
                    end;

                    if ("Sale Type" <> "Sale Type"::Comment) and not (Type in [Type::Cancelled, Type::Comment]) then
                        TestField("No.");
                    case "Sale Type" of

                        /*-1-*/
                        "Sale Type"::Sale:
                            begin
                                if Vare."VAT Bus. Posting Gr. (Price)" <> '' then
                                    "VAT Bus. Posting Group" := Vare."VAT Bus. Posting Gr. (Price)"
                                else begin
                                    HCRetailSetup.Get;
                                    HCRetailSetup.TestField("Vat Bus. Posting Group");
                                    "VAT Bus. Posting Group" := HCRetailSetup."Vat Bus. Posting Group";
                                end;
                                Modify;
                                TestField("Gen. Bus. Posting Group");
                                "BogfOps.".Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group");
                                "BogfOps.".TestField("Sales Account");
                                Finanskonto.Get("BogfOps."."Sales Account");
                                VirksBogfGrp.Get("Gen. Bus. Posting Group");
                                ProdBogfGrp.Get("Gen. Prod. Posting Group");
                                MomsbogfOps.Get(VirksBogfGrp."Def. VAT Bus. Posting Group", ProdBogfGrp."Def. VAT Prod. Posting Group");
                                MomsbogfOps.TestField("Sales VAT Account");
                                Finanskonto.Get(MomsbogfOps."Sales VAT Account");
                                Finanskonto.TestField(Blocked, false);

                                /*######------SLUT------######*/

                            end;


                        /*-2-*/
                        "Sale Type"::Deposit:
                            begin

                                if Type = Type::Customer then begin
                                    if not Debitor.Get("No.") then
                                        Error(t002, "No.", Description);

                                    /*##########################################################
                                     ## Kodestykket er tilf�jet i forbindelse med indl�sning ##
                                     ## fra tekstbaseret Navision ---30112000 NP-MD          ##
                                     ##########################################################*/

                                    DebBogfGrp.Get(Debitor."Customer Posting Group");
                                    DebBogfGrp.TestField("Receivables Account");
                                    Finanskonto.Get(DebBogfGrp."Receivables Account");
                                    Finanskonto.TestField(Blocked, false);

                                    /*######------SLUT------######*/

                                end;
                            end;

                        /*-3-*/
                        "Sale Type"::"Out payment":
                            begin
                                if Type = Type::"G/L" then begin
                                    if not Finanskonto.Get("No.") then
                                        Error(t003,
                                          "No.", Description);
                                    Finanskonto.TestField(Blocked, false);
                                end;
                            end;

                        /*-4-*/
                        "Sale Type"::Payment:
                            begin

                                Betalingsvalg.Get("No.");
                                /*##########################################################
                                 ## Kodestykket er tilf�jet i forbindelse med indl�sning ##
                                 ## fra tekstbaseret Navision ---30112000 NP-MD          ##
                                 ##########################################################*/

                                case Betalingsvalg."Account Type" of
                                    Betalingsvalg."Account Type"::"G/L Account":
                                        begin
                                            Finanskonto.Get(GetPaymentPostingSetup(Betalingsvalg, Rec."Register No."));
                                        end;
                                    Betalingsvalg."Account Type"::Customer:
                                        begin
                                            Betalingsvalg.TestField("Customer No.");
                                            Debitor.Get(Betalingsvalg."Customer No.");
                                        end;
                                end;

                                Finanskonto.TestField(Blocked, false);
                                /*######------SLUT------######*/

                            end;
                        "Sale Type"::Comment:
                            begin
                                case Type of
                                    Type::"Open/Close":
                                        begin
                                            if "Transferred to Balance Account" <> 0 then begin

                                            end;
                                            if Difference <> 0 then begin

                                            end;
                                        end;
                                end;
                            end;
                    end;
                until Next = 0;
        end;
        if ProgressVis then
            Window.Update(102, 10000);

    end;

    procedure RunTransfer(var TempPost: Record "NPR HC Audit Roll Posting" temporary; var Revisionsrulle: Record "NPR HC Audit Roll"): Integer
    begin
        if WindowIsOpen then
            exit(TempPost.TransferFromRev(Revisionsrulle, TempPost, Window))
        else
            exit(TempPost.TransferFromRevSilent(Revisionsrulle, TempPost));
    end;

    procedure RunTransferItemLedger(var TempPost: Record "NPR HC Audit Roll Posting" temporary; var Revisionsrulle: Record "NPR HC Audit Roll"): Integer
    begin
        if WindowIsOpen then
            exit(TempPost.TransferFromRevItemLedger(Revisionsrulle, TempPost, Window))
        else
            exit(TempPost.TransferFromRevSilentItemLedg(Revisionsrulle, TempPost));
    end;

    procedure RemoveSuspendedPayouts(var Rulle: Record "NPR HC Audit Roll Posting" temporary)
    var
        nCount: Integer;
        nTotal: Integer;
        Linie: Record "NPR HC Audit Roll Posting" temporary;
    begin
        Rulle.SetCurrentKey("Sale Type", Type, "No.");
        Rulle.SetRange("Sale Type", Rulle."Sale Type"::"Out payment");
        Rulle.SetRange(Type, Rulle.Type::"G/L");
        Rulle.SetRange("No.", '*');

        nTotal := Rulle.Count;
        nCount := 0;

        Linie.CopyFilters(Rulle);
        if Rulle.Find('-') then
            repeat
                if ProgressVis then begin
                    nCount += 1;
                    Window.Update(101, Round(nCount / nTotal * 5000, 1, '>'));
                end;
                Rulle.Reset;
                Rulle.SetCurrentKey("Sales Ticket No.");
                Rulle.SetRange("Sales Ticket No.", Rulle."Sales Ticket No.");
                Rulle.DeleteAll;
                Rulle.SetCurrentKey("Sale Type", Type, "No.");
                Rulle.CopyFilters(Linie);
            until Rulle.Next = 0;

        Rulle.SetRange("Sale Type", Rulle."Sale Type"::Deposit);
        Rulle.SetRange(Type, Rulle.Type::Customer);
        nTotal := Rulle.Count;
        nCount := 0;

        Linie.CopyFilters(Rulle);
        if Rulle.Find('-') then
            repeat
                if ProgressVis then begin
                    nCount += 1;
                    Window.Update(101, Round(nCount / nTotal * 5000 + 50000, 1, '>'));
                end;
                Rulle.Reset;
                Rulle.SetCurrentKey("Sales Ticket No.");
                Rulle.SetRange("Sales Ticket No.", Rulle."Sales Ticket No.");
                Rulle.DeleteAll;
                Rulle.SetCurrentKey("Sale Type", Type, "No.");
                Rulle.CopyFilters(Linie);
            until Rulle.Next = 0;
        if ProgressVis then
            Window.Update(101, 10000);
    end;

    procedure RunUpdateChanges(var TempPost: Record "NPR HC Audit Roll Posting" temporary)
    begin
        if WindowIsOpen then
            TempPost.UpdateChanges(Window)
        else
            TempPost.UpdateChangesSilent();
    end;

    procedure PostDayClearing(var TempAuditRoll: Record "NPR HC Audit Roll Posting" temporary; var PaymentType: Record "NPR HC Payment Type POS"; Amount: Decimal)
    begin
        PaymentType.TestField("Day Clearing Account");

        with TempAuditRoll do begin
            PostTransaction(
              GetPaymentPostingSetup(PaymentType, "Register No."), -"Amount Including VAT", "Register No.", AccountType::"G/L",
              "Department Code", Description, BogfDate, TempAuditRoll);
            PostTransaction(
              PaymentType."Day Clearing Account", "Amount Including VAT", "Register No.", AccountType::"G/L",
              "Department Code", Description, BogfDate, TempAuditRoll);
            PostTransaction(
              GetPaymentPostingSetup(PaymentType, "Register No."), "Amount Including VAT", "Register No.", AccountType::"G/L",
              "Department Code", Description, "Posting Date", TempAuditRoll);
            PostTransaction(
              PaymentType."Day Clearing Account", -"Amount Including VAT", "Register No.", AccountType::"G/L",
              "Department Code", Description, "Posting Date", TempAuditRoll);
        end;
    end;

    procedure getNewPostingNo(increment1: Boolean): Code[20]
    var
        Nos: Codeunit NoSeriesManagement;
        npc: Record "NPR HC Retail Setup";
        code20: Code[20];
    begin
        //Instead of kasse."Last G/L Posting No."
        npc.Get;
        code20 := Nos.GetNextNo(npc."Posting No. Management", Today, increment1);

        exit(code20);
    end;

    procedure setPostingNo("Last G/L Posting No. 1": Code[20])
    begin
        GlobalPostingNo := "Last G/L Posting No. 1";
    end;

    procedure CreateRetPurchOrder(AuditRoll: Record "NPR HC Audit Roll Posting"): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if (AuditRoll.Vendor = '') or (AuditRoll.Type <> AuditRoll.Type::Item) or
           (AuditRoll.Quantity > 0) then
            exit(false);

        if AuditRoll."Return Reason Code" = '' then
            exit(false);

        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Return Order");
        PurchaseHeader.SetRange("Order Date", Today);
        PurchaseHeader.SetRange("Your Reference", AuditRoll."Sales Ticket No.");
        PurchaseHeader.SetRange("Buy-from Vendor No.", AuditRoll.Vendor);
        if PurchaseHeader.Count > 0 then begin
            exit(false);
        end;

        CreateRetPurchHeader(PurchaseHeader, AuditRoll);
        CreateRetPurchLines(PurchaseHeader, AuditRoll);
        exit(true);
    end;

    procedure CreateRetPurchHeader(var PurchaseHeader: Record "Purchase Header"; AuditRoll: Record "NPR HC Audit Roll Posting")
    begin
        PurchaseHeader.Init;
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Return Order";
        PurchaseHeader.Validate("Buy-from Vendor No.", AuditRoll.Vendor);
        PurchaseHeader.Validate("Posting Date", Today);
        PurchaseHeader.Validate("Order Date", Today);
        PurchaseHeader."Your Reference" := AuditRoll."Sales Ticket No.";
        PurchaseHeader."Purchaser Code" := AuditRoll."Salesperson Code";

        PurchaseHeader.Insert(true);
    end;

    procedure CreateRetPurchLines(PurchaseHeader: Record "Purchase Header"; AuditRoll: Record "NPR HC Audit Roll Posting")
    var
        PurchaseLine: Record "Purchase Line";
        AuditRollTemp: Record "NPR HC Audit Roll";
    begin
        AuditRollTemp.SetRange("Register No.", AuditRoll."Register No.");
        AuditRollTemp.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
        AuditRollTemp.SetRange("Sale Date", AuditRoll."Sale Date");
        AuditRollTemp.SetRange(Type, AuditRollTemp.Type::Item);
        AuditRollTemp.SetRange(Vendor, AuditRoll.Vendor);
        AuditRollTemp.SetFilter(Quantity, '<0');

        if AuditRollTemp.Find('-') then
            repeat
                PurchaseLine.Init;
                PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                PurchaseLine."Document No." := PurchaseHeader."No.";
                PurchaseLine."Line No." := AuditRollTemp."Line No.";
                PurchaseLine.Type := PurchaseLine.Type::Item;
                PurchaseLine.Validate("No.", AuditRollTemp."No.");
                PurchaseLine.Validate(Quantity, -AuditRollTemp.Quantity);
                PurchaseLine."Return Reason Code" := AuditRollTemp."Return Reason Code";
                PurchaseLine.Insert(true);
            until AuditRollTemp.Next = 0;
    end;

    procedure PostPrepmtInvoiceYN(var SalesHeader2: Record "Sales Header")
    var
        SalesHeader: Record "Sales Header";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
    begin
        SalesHeader.Copy(SalesHeader2);
        with SalesHeader do begin
            SalesPostPrepayments.Invoice(SalesHeader);
            Commit;
            SalesHeader2 := SalesHeader;
        end;
    end;

    procedure PostPrepmtCrMemoYN(var SalesHeader2: Record "Sales Header")
    var
        SalesHeader: Record "Sales Header";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
    begin
        SalesHeader.Copy(SalesHeader2);
        with SalesHeader do begin
            SalesPostPrepayments.CreditMemo(SalesHeader);
            Commit;
            SalesHeader2 := SalesHeader;
        end;
    end;

    local procedure GetLastGenJournalLine(): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if HCRetailSetup."Gen. Journal Batch" = '' then
            exit(0);
        GenJournalLine.SetRange("Journal Template Name", HCRetailSetup."Gen. Journal Template");
        GenJournalLine.SetRange("Journal Batch Name", HCRetailSetup."Gen. Journal Batch");
        if GenJournalLine.FindLast then
            exit(GenJournalLine."Line No.");
        exit(0);
    end;

    local procedure GetLastItemJournalLine(): Integer
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        if HCRetailSetup."Item Journal Batch" = '' then
            exit(0);
        ItemJournalLine.SetRange("Journal Template Name", HCRetailSetup."Item Journal Template");
        ItemJournalLine.SetRange("Journal Batch Name", HCRetailSetup."Item Journal Batch");
        if ItemJournalLine.FindLast then
            exit(ItemJournalLine."Line No.");
        exit(0);
    end;

    local procedure GetPaymentPostingSetup(BCPaymentTypePOS: Record "NPR HC Payment Type POS"; BCRegisterCode: Code[10]): Code[20]
    var
        BCRegister: Record "NPR HC Register";
        BCPaymentTypePostingSetup: Record "NPR HC Paym.Type Post.Setup";
    begin
        case BCPaymentTypePOS."Account Type" of
            BCPaymentTypePOS."Account Type"::Bank:
                begin
                    if BCPaymentTypePostingSetup.Get(BCPaymentTypePOS."No.", BCRegisterCode) then
                        if BCPaymentTypePostingSetup."Bank Account No." <> '' then
                            exit(BCPaymentTypePostingSetup."Bank Account No.");
                    BCPaymentTypePOS.TestField("Bank Acc. No.");
                    exit(BCPaymentTypePOS."Bank Acc. No.");
                end;
            BCPaymentTypePOS."Account Type"::"G/L Account":
                begin
                    if BCPaymentTypePostingSetup.Get(BCPaymentTypePOS."No.", BCRegisterCode) then
                        if BCPaymentTypePostingSetup."G/L Account No." <> '' then
                            exit(BCPaymentTypePostingSetup."G/L Account No.");
                    BCPaymentTypePOS.TestField("G/L Account No.");
                    exit(BCPaymentTypePOS."G/L Account No.");
                end;
        end;
    end;

    procedure ApplyToSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Last Posting No." = '' then
            exit;

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order,
            SalesHeader."Document Type"::Invoice:
                begin
                    FinKldLinie."Applies-to Doc. Type" := FinKldLinie."Applies-to Doc. Type"::Invoice;
                end;
            SalesHeader."Document Type"::"Credit Memo",
            SalesHeader."Document Type"::"Return Order":
                begin
                    FinKldLinie."Applies-to Doc. Type" := FinKldLinie."Applies-to Doc. Type"::"Credit Memo";
                end;
        end;
        if HCRetailSetup."Gen. Journal Batch" <> '' then begin
            GenJournalLine."Applies-to Doc. Type" := FinKldLinie."Applies-to Doc. Type";
            GenJournalLine.Validate("Applies-to Doc. No.", SalesHeader."Last Posting No.");
            GenJournalLine.Insert;
        end else begin
            FinKldLinie.Validate("Applies-to Doc. No.", SalesHeader."Last Posting No.");
            FinKldLinie.Modify;
        end;
    end;
}

