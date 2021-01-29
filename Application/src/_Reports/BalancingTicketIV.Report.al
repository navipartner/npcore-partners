report 6060108 "NPR Balancing Ticket IV"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Balancing Ticket IV.rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Counter Report Ticket IV';
    dataset
    {
        dataitem("Audit Roll"; "NPR Audit Roll")
        {
            DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.");
            RequestFilterFields = "Register No.", "Sales Ticket No.";
            column(TitelTxt; TitelTXT)
            {
            }
            column(SalesPersonName; StrSubstNo(RegisterClosedLbl, Saelger.Name))
            {
            }
            column(LineNo_AuditRoll; "Line No.")
            {
            }
            column(DepartmentCode_AuditRoll; "Department Code")
            {
            }
            column(RegisterNo_AuditRoll; "Register No.")
            {
            }
            column(SalesTicketNo_AuditRoll; "Sales Ticket No.")
            {
            }
            column(Expeditions; Format(Ekspeditionstaeller) + ' /  ' + Format(Cancelledtransactions))
            {
            }
            column(SaleDate_AuditRoll; "Sale Date")
            {
            }
            column(OpenTime; OpenTime)
            {
            }
            column(CloseTime; ' / ' + Format(CloseTime))
            {
            }
            column(MoneyBagNo_AuditRoll; "Money bag no.")
            {
            }
            column(Bruttoomsaetning; Bruttoomsaetning)
            {
            }
            column(debitnewcalc; Debitnewcalc)
            {
            }
            column(DebitBruttoTogether; Debitnewcalc + Bruttoomsaetning)
            {
            }
            column(Gavekortsalg; Gavekortsalg)
            {
            }
            column(Tilgodebevisudstedelse; Tilgodebevisudstedelse)
            {
            }
            column(Debitorindbetalinger; Debitorindbetalinger)
            {
            }
            column(Udbetalinger; Udbetalinger)
            {
            }
            column(TotalAllAbove; Tilgodebevisudstedelse + Gavekortsalg + Debitorindbetalinger - Udbetalinger + Bruttoomsaetning + Debitnewcalc)
            {
            }
            column(Primo; Primo)
            {
            }
            column(Kontantbevaeg; Kontantbevaeg)
            {
            }
            column(KontantPrimoTogether; Kontantbevaeg + Primo)
            {
            }
            column(Optaltkassebeholdning; Optaltkassebeholdning)
            {
            }
            column(Kassedifference; Kassedifference)
            {
            }
            column(ClosingCash_AuditRoll; "Closing Cash")
            {
            }
            column(OverfoertBank; OverfoertBank)
            {
            }
            column(changecash; Changecash)
            {
            }
            column(Afrundet; Afrundet)
            {
            }
            dataitem(Period; "NPR Period")
            {
                DataItemLink = "Sales Ticket No." = FIELD("Sales Ticket No."), "Register No." = FIELD("Register No.");
                DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "No.") ORDER(Ascending);
                column(No_Period; Period."No.")
                {
                }
                column(NoOfSales_Period; "Sales (Qty)")
                {
                }
                column(NoOFGoodsSolg_Period; "No. Of Goods Sold")
                {
                }
                column(NoOfCashRecepts_Period; "No. Of Cash Receipts")
                {
                }
                column(NoOfCashBoxOpenings_Period; "No. Of Cash Box Openings")
                {
                }
                column(NoOfReceiptCopies_Period; "No. Of Receipt Copies")
                {
                }
                column(VatInfoString_Period; "VAT Info String")
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                Register.Get("Register No.");
                if Saelger.Get("Salesperson Code") then;

                GlobalPeriod.SetRange("Register No.", "Register No.");
                GlobalPeriod.SetRange("Sales Ticket No.", "Sales Ticket No.");
                GlobalPeriod.FindLast();

                TitelTXT := Register.Description;

                Revisionsrulle1.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);
                Revisionsrulle1.SetRange("Register No.", "Register No.");
                Revisionsrulle1.SetRange("Sales Ticket No.", "Sales Ticket No.");
                Revisionsrulle1.SetRange("Sale Type", Revisionsrulle1."Sale Type"::Comment);
                Revisionsrulle1.SetRange(Type, Revisionsrulle1.Type::"Open/Close");
                if Revisionsrulle1.FindFirst() then begin
                    Revisionsrulle1.SetRange("Sales Ticket No.");
                    Revisionsrulle1.Next(-1);
                end;

                Nettoomsaetning := GlobalPeriod."Net Turnover (LCY)";
                Bruttoomsaetning := GlobalPeriod."Sales (LCY)";
                Totalrabat := GlobalPeriod."Total Discount (LCY)";
                Vareforbrug := GlobalPeriod."Net Cost (LCY)";
                Perioderabat := GlobalPeriod."Campaign Discount (LCY)";
                Mixprisrabat := GlobalPeriod."Mix Discount (LCY)";
                Flerstyksrabat := GlobalPeriod."Quantity Discount (LCY)";
                Brugerrabat := GlobalPeriod."Custom Discount (LCY)";
                Linierabat := GlobalPeriod."Line Discount (LCY)";
                Daekningsgrad := GlobalPeriod."Profit %";

                if Bruttoomsaetning <> 0 then begin
                    Brugerrabpct := Brugerrabat * 100 / Bruttoomsaetning;
                    Flerstyksrabpct := Flerstyksrabat * 100 / Bruttoomsaetning;
                    Mixprisrabpct := Mixprisrabat * 100 / Bruttoomsaetning;
                    Perioderabpct := Perioderabat * 100 / Bruttoomsaetning;
                    Linierabpct := Linierabat * 100 / Bruttoomsaetning;
                    RabatPct := Totalrabat * 100 / Bruttoomsaetning;
                end;

                OpenTime := GlobalPeriod."Opening Time";
                CloseTime := GlobalPeriod."Closing Time";
                Ekspeditionstaeller := GlobalPeriod."Sales (Qty)";
                Cancelledtransactions := GlobalPeriod."Cancelled Sales";
                Sidstebon := GlobalPeriod."Sales Ticket No.";

                BevaegPos := 0;
                BevaegNeg := 0;

                ReturBonTotal := GlobalPeriod."Negative Sales Count";
                ReturBeloebTotal := GlobalPeriod."Negative Sales Amount";

                Primo := GlobalPeriod."Opening Cash";
                BalanceUpdate(Primo, Primo > 0);

                Kontantbevaeg := GlobalPeriod."Net. Cash Change";
                BalanceUpdate(Kontantbevaeg, Kontantbevaeg > 0);

                Tilgodebevisbevaeg := GlobalPeriod."Net. Credit Voucher Change";

                Gavekortbevaeg := GlobalPeriod."Net. Gift Voucher Change";
                BalanceUpdate(Gavekortbevaeg, Gavekortbevaeg > 0);

                UkendteKortbevaeg := GlobalPeriod."Net. Terminal Change";
                BalanceUpdate(UkendteKortbevaeg, UkendteKortbevaeg > 0);

                Dankortbevaeg := GlobalPeriod."Net. Dankort Change";
                BalanceUpdate(Dankortbevaeg, Dankortbevaeg > 0);

                "Visa/Dkbevaeg" := GlobalPeriod."Net. VisaCard Change";
                BalanceUpdate("Visa/Dkbevaeg", "Visa/Dkbevaeg" > 0);

                OtherCardNetChange := GlobalPeriod."Net. Change Other Cedit Cards";
                BalanceUpdate(OtherCardNetChange, OtherCardNetChange > 0);

                Gavekortsalg := GlobalPeriod."Gift Voucher Sales";
                BalanceUpdate(Gavekortsalg, Gavekortsalg > 0);

                Tilgodebevisudstedelse := GlobalPeriod."Credit Voucher issuing";
                BalanceUpdate(Tilgodebevisudstedelse, Tilgodebevisudstedelse > 0);

                Debitorindbetalinger := GlobalPeriod."Cash Received";
                BalanceUpdate(Debitorindbetalinger, Debitorindbetalinger > 0);

                Udbetalinger := GlobalPeriod."Pay Out";
                BalanceUpdate(Udbetalinger, Udbetalinger > 0);

                Debetsalg := GlobalPeriod."Debit Sale";
                Debitnewcalc := GlobalPeriod."Debit Sale";
                BalanceUpdate(Debetsalg, Debetsalg > 0);

                Gkdebet := GlobalPeriod."Gift Voucher Debit";
                BalanceUpdate(Gkdebet, Gkdebet > 0);

                Changecash := GlobalPeriod."Change Register";
                OverfoertBank := GlobalPeriod."Deposit in Bank";
                Kassedifference := GlobalPeriod.Difference;
                Kreditkortsaldo := OtherCardNetChange + "Visa/Dkbevaeg" + Dankortbevaeg + UkendteKortbevaeg;
                Optaltkassebeholdning := GlobalPeriod."Balanced Cash Amount";

                if Kassedifference < 0 then begin
                    BalancePos := BevaegPos + (-Kassedifference);
                    BalanceNeg := BevaegNeg + OverfoertBank + GlobalPeriod."Balanced Cash Amount";
                end else begin
                    BalancePos := BevaegPos;
                    BalanceNeg := BevaegNeg + OverfoertBank + Kassedifference + GlobalPeriod."Balanced Cash Amount";
                end;
                if Kreditkortsaldo < 0 then
                    BalancePos := BalancePos + (-Kreditkortsaldo)
                else
                    BalanceNeg := BalanceNeg + Kreditkortsaldo;

                RevRulleTilgodebevis.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);
                if not (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then
                    RevRulleTilgodebevis.SetRange("Register No.", "Audit Roll"."Register No.");
                RevRulleTilgodebevis.SetFilter("Sales Ticket No.", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");

                RevRulleTilgodebevis.SetRange(Type, RevRulleTilgodebevis.Type::"G/L");
                RevRulleTilgodebevis.SetRange("Sale Type", RevRulleTilgodebevis."Sale Type"::Deposit);
                if RevRulleTilgodebevis.FindFirst() then
                    repeat
                        if RevRulleTilgodebevis."Credit voucher ref." <> '' then
                            TilgodeInd := RevRulleTilgodebevis."Amount Including VAT";
                    until RevRulleTilgodebevis.Next() = 0;

                RevRulleTilgodebevis.SetRange(Type, RevRulleTilgodebevis.Type::Payment);
                RevRulleTilgodebevis.SetRange("Sale Type", RevRulleTilgodebevis."Sale Type"::Payment);
                if RevRulleTilgodebevis.FindFirst() then
                    repeat
                        if RevRulleTilgodebevis."Credit voucher ref." <> '' then
                            TilgodeUd := RevRulleTilgodebevis."Amount Including VAT";
                    until RevRulleTilgodebevis.Next() = 0;

                if (TilgodeInd - TilgodeUd) > 0 then
                    BalanceUpdate(TilgodeInd - TilgodeUd, true)
                else
                    BalanceUpdate(TilgodeInd - TilgodeUd, false);

                Frabon := Revisionsrulle1."Sales Ticket No.";
                Tilbon := "Audit Roll"."Sales Ticket No.";
                Optaltchecks := GlobalPeriod.Cheque;
                BalanceUpdate(Optaltchecks, Optaltchecks > 0);

                Afrundet := (Tilgodebevisudstedelse + Gavekortsalg + Debitorindbetalinger - Udbetalinger + Bruttoomsaetning + Debetsalg);
            end;

            trigger OnPreDataItem()
            begin
                Opsaetning.Get();

                Beregn := true;
            end;
        }
        dataitem("Payment Type POS"; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("No.", "Register No.");
            column(Description_PaymentTypePos; Description)
            {
            }
            column(AmountInAuditRoll_PaymentTypePos; "Amount in Audit Roll")
            {
            }

            trigger OnPostDataItem()
            begin
                BetalingerTotal := BetalingerTotal + "Amount in Audit Roll";
            end;

            trigger OnPreDataItem()
            begin
                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then begin
                    "Payment Type POS".SetRange("Date Filter", Revisionsrulle2."Sale Date");
                    Kasserec.FindFirst();
                    Kasserecsidste.FindLast();
                    "Payment Type POS".SetRange("Register Filter", Kasserec."Register No.", Kasserecsidste."Register No.");
                    "Payment Type POS".SetRange("Processing Type", "Processing Type"::"Foreign Currency");
                    "Payment Type POS".SetFilter("Receipt Filter", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    "Payment Type POS".CalcFields("Amount in Audit Roll");
                end;

                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::"PER REGISTER") then begin
                    "Payment Type POS".SetRange("Date Filter", GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                    "Payment Type POS".SetRange("Register Filter", GlobalPeriod."Register No.");
                    "Payment Type POS".SetRange("Processing Type", "Processing Type"::"Foreign Currency");
                    "Payment Type POS".SetFilter("Receipt Filter", '%1..%2', GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No.");
                    "Payment Type POS".CalcFields("Amount in Audit Roll");
                end;

                ShowHeader := true;
            end;
        }
        dataitem(Gavekort; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("No.", "Register No.");
            column(Description_Gavekort; Description)
            {
            }
            column(AmountInAuditRoll_Gavekort; "Amount in Audit Roll")
            {
            }

            trigger OnPostDataItem()
            begin
                BetalingerTotal := BetalingerTotal + "Amount in Audit Roll";
            end;

            trigger OnPreDataItem()
            begin
                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then begin
                    Gavekort.SetRange("Date Filter", Revisionsrulle2."Sale Date");
                    Kasserec.FindFirst();
                    Kasserecsidste.FindLast();
                    Gavekort.SetRange("Register Filter", Kasserec."Register No.", Kasserecsidste."Register No.");
                    Gavekort.SetRange("Processing Type", "Processing Type"::"Gift Voucher");
                    Gavekort.SetFilter("Receipt Filter", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    Gavekort.CalcFields("Amount in Audit Roll");
                end;

                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::"PER REGISTER") then begin
                    Gavekort.SetRange("Date Filter", GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                    Gavekort.SetRange("Register Filter", GlobalPeriod."Register No.");
                    Gavekort.SetRange("Processing Type", "Processing Type"::"Gift Voucher");
                    Gavekort.SetFilter("Receipt Filter", '%1..%2', GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No.");
                    Gavekort.CalcFields("Amount in Audit Roll");
                end;

                ShowHeader := true;
            end;
        }
        dataitem("Fremmed Gavekort"; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("No.", "Register No.");
            column(Description_FremmedGavekort; Description)
            {
            }
            column(AmountInAuditRoll_FremmedGavekort; "Amount in Audit Roll")
            {
            }

            trigger OnPostDataItem()
            begin
                BetalingerTotal += "Amount in Audit Roll";
            end;

            trigger OnPreDataItem()
            begin
                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then begin
                    "Fremmed Gavekort".SetRange("Date Filter", Revisionsrulle2."Sale Date");
                    Kasserec.FindFirst();
                    Kasserecsidste.FindLast();
                    "Fremmed Gavekort".SetRange("Register Filter", Kasserec."Register No.", Kasserecsidste."Register No.");
                    "Fremmed Gavekort".SetRange("Processing Type", "Processing Type"::"Foreign Gift Voucher");
                    "Fremmed Gavekort".SetFilter("Receipt Filter", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    "Fremmed Gavekort".CalcFields("Amount in Audit Roll");
                end;

                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::"PER REGISTER") then begin
                    "Fremmed Gavekort".SetRange("Date Filter", GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                    "Fremmed Gavekort".SetRange("Register Filter", GlobalPeriod."Register No.");
                    "Fremmed Gavekort".SetRange("Processing Type", "Processing Type"::"Foreign Gift Voucher");
                    "Fremmed Gavekort".SetFilter("Receipt Filter", '%1..%2', GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No."
                  );
                    "Fremmed Gavekort".CalcFields("Amount in Audit Roll");
                end;

                ShowHeader := true;
            end;
        }
        dataitem(Tilgodebevis; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("No.", "Register No.");
            column(Description_Tilgodebevis; Description)
            {
            }
            column(AmountInAuditRoll_Tilgodebevis; "Amount in Audit Roll")
            {
            }

            trigger OnPostDataItem()
            begin
                BetalingerTotal := BetalingerTotal + "Amount in Audit Roll";
            end;

            trigger OnPreDataItem()
            begin
                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then begin
                    "Payment Type POS".SetRange("Date Filter", Revisionsrulle2."Sale Date");
                    Kasserec.FindFirst();
                    Kasserecsidste.FindLast();
                    Tilgodebevis.SetRange("Register Filter", Kasserec."Register No.", Kasserecsidste."Register No.");
                    Tilgodebevis.SetRange("Processing Type", "Processing Type"::"Credit Voucher");
                    Tilgodebevis.SetFilter("Receipt Filter", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    Tilgodebevis.CalcFields("Amount in Audit Roll");
                end;

                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::"PER REGISTER") then begin
                    Tilgodebevis.SetRange("Date Filter", GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                    Tilgodebevis.SetRange("Register Filter", GlobalPeriod."Register No.");
                    Tilgodebevis.SetRange("Processing Type", "Processing Type"::"Credit Voucher");
                    Tilgodebevis.SetFilter("Receipt Filter", '%1..%2', GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No.");
                    Tilgodebevis.CalcFields("Amount in Audit Roll");
                end;

                ShowHeader := true;
            end;
        }
        dataitem("Fremmed Tilgodebevis"; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("No.", "Register No.");
            column(Description_FremmedTilgodebevis; Description)
            {
            }
            column(AmountInAuditRoll_FremmedTilgodebevis; "Amount in Audit Roll")
            {
            }

            trigger OnPostDataItem()
            begin
                BetalingerTotal += "Amount in Audit Roll";
            end;

            trigger OnPreDataItem()
            begin
                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then begin
                    "Fremmed Tilgodebevis".SetRange("Date Filter", Revisionsrulle2."Sale Date");
                    Kasserec.FindFirst();
                    Kasserecsidste.FindLast();
                    "Fremmed Tilgodebevis".SetRange("Register Filter", Kasserec."Register No.", Kasserecsidste."Register No.");
                    "Fremmed Tilgodebevis".SetRange("Processing Type", "Processing Type"::"Foreign Credit Voucher");
                    "Fremmed Tilgodebevis".SetFilter("Receipt Filter", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    "Fremmed Tilgodebevis".CalcFields("Amount in Audit Roll");
                end;

                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::"PER REGISTER") then begin
                    "Fremmed Tilgodebevis".SetRange("Date Filter", GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                    "Fremmed Tilgodebevis".SetRange("Register Filter", GlobalPeriod."Register No.");
                    "Fremmed Tilgodebevis".SetRange("Processing Type", "Processing Type"::"Foreign Credit Voucher");
                    "Fremmed Tilgodebevis".SetFilter("Receipt Filter", '%1..%2', GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No.");
                    "Fremmed Tilgodebevis".CalcFields("Amount in Audit Roll");
                end;

                ShowHeader := true;
            end;
        }
        dataitem(TerminalCard; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("No.", "Register No.");
            column(Description_TerminalCard; Description)
            {
            }
            column(AmountInAuditRoll_TerminalCard; "Amount in Audit Roll")
            {
            }

            trigger OnAfterGetRecord()
            begin
                if ("Amount in Audit Roll" <> 0) and not ShowHeader then
                    ShowHeader := true;
            end;

            trigger OnPostDataItem()
            begin
                BetalingerTotal := BetalingerTotal + "Amount in Audit Roll";
            end;

            trigger OnPreDataItem()
            begin
                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then begin
                    "Payment Type POS".SetRange("Date Filter", Revisionsrulle2."Sale Date");
                    Kasserec.FindFirst();
                    Kasserecsidste.FindLast();
                    TerminalCard.SetRange("Register Filter", Kasserec."Register No.", Kasserecsidste."Register No.");
                    TerminalCard.SetRange("Processing Type", "Processing Type"::"Terminal Card");
                    TerminalCard.SetFilter("Receipt Filter", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    TerminalCard.CalcFields("Amount in Audit Roll");
                end;

                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::"PER REGISTER") then begin
                    TerminalCard.SetFilter("Date Filter", '%1..%2', GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                    TerminalCard.SetRange("Register Filter", GlobalPeriod."Register No.");
                    TerminalCard.SetRange("Processing Type", "Processing Type"::"Terminal Card");
                    TerminalCard.SetFilter("Receipt Filter", '%1..%2',
                                           GlobalPeriod."Opening Sales Ticket No.",
                                           GlobalPeriod."Sales Ticket No.");
                    TerminalCard.CalcFields("Amount in Audit Roll");
                end;

                ShowHeader := true;
            end;
        }
        dataitem(OtherCreditCards; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("No.", "Register No.");
            column(Description_OtherCreditCards; Description)
            {
            }
            column(AmountInAuditRoll_OtherCreditCards; "Amount in Audit Roll")
            {
            }

            trigger OnAfterGetRecord()
            begin
                if ("Amount in Audit Roll" <> 0) and not ShowHeader then
                    ShowHeader := true;
            end;

            trigger OnPostDataItem()
            begin
                BetalingerTotal := BetalingerTotal + "Amount in Audit Roll";
            end;

            trigger OnPreDataItem()
            begin
                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then begin
                    "Payment Type POS".SetRange("Date Filter", Revisionsrulle2."Sale Date");
                    Kasserec.FindFirst();
                    Kasserecsidste.FindLast();
                    OtherCreditCards.SetRange("Register Filter", Kasserec."Register No.", Kasserecsidste."Register No.");
                    OtherCreditCards.SetRange("Processing Type", "Processing Type"::"Other Credit Cards");
                    OtherCreditCards.SetFilter("Receipt Filter", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    OtherCreditCards.CalcFields("Amount in Audit Roll");
                end;

                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::"PER REGISTER") then begin
                    OtherCreditCards.SetRange("Date Filter", GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                    OtherCreditCards.SetRange("Register Filter", GlobalPeriod."Register No.");
                    OtherCreditCards.SetRange("Processing Type", "Processing Type"::"Other Credit Cards");
                    OtherCreditCards.SetFilter("Receipt Filter", '%1..%2', GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No.");
                    OtherCreditCards.CalcFields("Amount in Audit Roll");
                end;

                ShowHeader := true;
            end;
        }
        dataitem(ManualCards; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("No.", "Register No.");
            column(Description_ManualCards; Description)
            {
            }
            column(AmountInAuditRoll_ManualCards; "Amount in Audit Roll")
            {
            }

            trigger OnAfterGetRecord()
            begin
                if ("Amount in Audit Roll" <> 0) and not ShowHeader then
                    ShowHeader := true;
            end;

            trigger OnPostDataItem()
            begin
                BetalingerTotal := BetalingerTotal + "Amount in Audit Roll";
            end;

            trigger OnPreDataItem()
            begin
                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then begin
                    "Payment Type POS".SetRange("Date Filter", Revisionsrulle2."Sale Date");
                    Kasserec.FindFirst();
                    Kasserecsidste.FindLast();
                    ManualCards.SetRange("Register Filter", Kasserec."Register No.", Kasserecsidste."Register No.");
                    ManualCards.SetRange("Processing Type", "Processing Type"::"Manual Card");
                    ManualCards.SetFilter("Receipt Filter", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    ManualCards.CalcFields("Amount in Audit Roll");
                end;

                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::"PER REGISTER") then begin
                    ManualCards.SetRange("Date Filter", GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                    ManualCards.SetRange("Register Filter", GlobalPeriod."Register No.");
                    ManualCards.SetRange("Processing Type", "Processing Type"::"Manual Card");
                    ManualCards.SetFilter("Receipt Filter", '%1..%2', GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No.");
                    ManualCards.CalcFields("Amount in Audit Roll");
                end;

                ShowHeader := true;
            end;
        }
        dataitem(Terminal; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("No.", "Register No.");
            column(Description_Terminal; Description)
            {
            }
            column(AmountInAuditRoll_Terminal; "Amount in Audit Roll")
            {
            }

            trigger OnAfterGetRecord()
            begin
                if ("Amount in Audit Roll" <> 0) and not ShowHeader then
                    ShowHeader := true;
            end;

            trigger OnPostDataItem()
            begin
                BetalingerTotal := BetalingerTotal + "Amount in Audit Roll";
            end;

            trigger OnPreDataItem()
            begin
                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then begin
                    "Payment Type POS".SetRange("Date Filter", Revisionsrulle2."Sale Date");
                    Kasserec.FindFirst();
                    Kasserecsidste.FindLast();
                    Terminal.SetRange("Register Filter", Kasserec."Register No.", Kasserecsidste."Register No.");
                    Terminal.SetRange("Processing Type", "Processing Type"::EFT);
                    Terminal.SetFilter("Receipt Filter", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    Terminal.CalcFields("Amount in Audit Roll");
                end;

                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::"PER REGISTER") then begin
                    Terminal.SetFilter("Date Filter", '%1..%2', GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                    Terminal.SetRange("Register Filter", GlobalPeriod."Register No.");
                    Terminal.SetRange("Processing Type", "Processing Type"::EFT);
                    Terminal.SetFilter("Receipt Filter", '%1..%2',
                                           GlobalPeriod."Opening Sales Ticket No.",
                                           GlobalPeriod."Sales Ticket No.");
                    Terminal.CalcFields("Amount in Audit Roll");
                end;

                ShowHeader := true;
            end;
        }
        dataitem(ForeignCurrency; "NPR Payment Type POS")
        {
            CalcFields = "Amount in Audit Roll";
            DataItemTableView = SORTING("No.", "Register No.") ORDER(Ascending) WHERE("Processing Type" = CONST("Foreign Currency"));
            column(Description_ForeignCurrency; Description)
            {
            }
            column(AmountInAuditRoll_ForeignCurrency; "Amount in Audit Roll")
            {
            }

            trigger OnPreDataItem()
            begin
                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::TOTAL) then begin
                    "Payment Type POS".SetRange("Date Filter", Revisionsrulle2."Sale Date");
                    Kasserec.FindFirst();
                    Kasserecsidste.FindLast();
                    ForeignCurrency.SetRange("Register Filter", Kasserec."Register No.", Kasserecsidste."Register No.");
                    ForeignCurrency.SetRange("Processing Type", "Processing Type"::"Foreign Currency");
                    ForeignCurrency.SetFilter("Receipt Filter", '%1..%2', Revisionsrulle1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    ForeignCurrency.CalcFields("Amount in Audit Roll");
                end;

                if (Opsaetning."Balancing Posting Type" = Opsaetning."Balancing Posting Type"::"PER REGISTER") then begin
                    ForeignCurrency.SetFilter("Date Filter", '%1..%2', GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                    ForeignCurrency.SetRange("Register Filter", GlobalPeriod."Register No.");
                    ForeignCurrency.SetRange("Processing Type", "Processing Type"::"Foreign Currency");
                    ForeignCurrency.SetFilter("Receipt Filter", '%1..%2',
                                           GlobalPeriod."Opening Sales Ticket No.",
                                           GlobalPeriod."Sales Ticket No.");
                    ForeignCurrency.CalcFields("Amount in Audit Roll");
                end;
            end;
        }
        dataitem(Gavekortrabatkonto; "G/L Account")
        {
            DataItemTableView = SORTING("No.");
            column(GLEntryInAuditRoll_Gavekortrabatkonto; "NPR G/L Entry in Audit Roll")
            {
            }

            trigger OnAfterGetRecord()
            begin
                Gavekortrabatkonto.SetRange("Date Filter", GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                Gavekortrabatkonto.SetRange("NPR Register Filter", GlobalPeriod."Register No.");
                Gavekortrabatkonto.SetFilter("NPR Sales Ticket No. Filter", '%1..%2',
                                             GlobalPeriod."Opening Sales Ticket No.",
                                             GlobalPeriod."Sales Ticket No.");
                Gavekortrabatkonto.CalcFields("NPR G/L Entry in Audit Roll");
            end;

            trigger OnPreDataItem()
            begin
                Gavekortrabatkonto.SetRange("No.", Register."Gift Voucher Discount Account");
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(Number_Integer; Integer.Number)
            {
            }
            column(debetsalg; Debetsalg)
            {
            }
            column(gkdebet; Gkdebet)
            {
            }
            column(ReturBonTotal_Integer; ReturBonTotal)
            {
            }
            column(ReturnTotal_Integer; ReturBeloebTotal)
            {
            }
            column(BetalingerTotal_Integer; BetalingerTotal)
            {
            }
        }
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.") WHERE("NPR Retail Payment" = CONST(true));
            column(NameNo_GLAccount; Name + '  ' + Format("No."))
            {
            }
            column(GLEntryInAuditRoll_GLAccount; "NPR G/L Entry in Audit Roll")
            {
            }
            column(Udbetalinger_GLAccount; Udbetalinger)
            {
            }

            trigger OnAfterGetRecord()
            begin
                "G/L Account".SetRange("Date Filter", GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
                "G/L Account".SetRange("NPR Register Filter", GlobalPeriod."Register No.");
                "G/L Account".SetFilter("NPR Sales Ticket No. Filter", '%1..%2', GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No.");
                "G/L Account".CalcFields("NPR G/L Entry in Audit Roll");
            end;
        }
        dataitem(PaymentTypeCounting; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("Register No.", "Processing Type") WHERE("Processing Type" = FILTER(Cash | "Foreign Currency"), "To be Balanced" = CONST(true));
            column(Description_PaymentTypeCounting; Description)
            {
            }
            column(detailedcounting; DetailedCounting)
            {
            }
            dataitem("Period Line"; "NPR Period Line")
            {
                DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Payment Type No.", Weight);
                column(SalesTicketNo_PeriodLine; "Sales Ticket No.")
                {
                }
                column(Weight_PeriodLine; Weight)
                {
                }
                column(Qty_PeriodLine; Quantity)
                {
                }
                column(Amount_PeriodLine; Amount)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    CountTotalFooter += "Period Line".Amount;
                end;

                trigger OnPreDataItem()
                begin
                    if not Opsaetning."Show Counting on Counter Rep." then
                        CurrReport.Break();

                    SetRange("Register No.", "Audit Roll"."Register No.");
                    SetRange("Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    SetRange("Payment Type No.", PaymentTypeCounting."No.");

                    CountTotalFooter := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not Opsaetning."Show Counting on Counter Rep." then
                    CurrReport.Skip;

                "Period Line".SetRange("Register No.", "Audit Roll"."Register No.");
                "Period Line".SetRange("Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                "Period Line".SetRange("Payment Type No.", PaymentTypeCounting."No.");

                DetailedCounting := "Period Line".FindFirst();
            end;
        }
    }


    labels
    {
        DepartmentCode_Lbl = 'Department Code';
        RegisterNo_Lbl = 'Register No.';
        ReceiptNo_Lbl = 'Receipt No.';
        EndDate_Lbl = 'Finishing Date';
        OpenTime_Lbl = 'Opening Time';
        MoneyBagNo_Lbl = 'Money Bag No.';
        Turnover_Lbl = 'Turnover';
        CashSales_Lbl = 'Cash Sales';
        DebetSales_Lbl = 'Credit Sales';
        TotalSales_Lbl = 'Total Sales';
        GiftCardSales_Lbl = 'Gift Voucher Sales';
        VoucherSales_Lbl = 'Credit Voucher Sales';
        Payments_Lbl = 'Pay In';
        PaymentsOut_Lbl = 'Pay Out';
        Sum_Lbl = 'Sum';
        Calculated_Lbl = 'Settled';
        DanishKroner_Lbl = '_';
        Prime_Lbl = 'Initial Stock';
        RegisterDD_Lbl = 'Register reg. d. d.';
        SystemInventory_Lbl = 'Inventory acc. to the system';
        Counted_Lbl = 'Counted';
        RegisterDiff_Lbl = 'Register diff.';
        NextDaysOpening_Lbl = 'Tomorrows opening inventory ';
        PutIntoBank_Lbl = 'Inserted in the bank';
        ExchangeRegister_Lbl = 'Exchange register';
        NoOfSales_Lbl = 'No. of sales';
        NoOfGoodSold_Lbl = 'No. of sold items';
        NoOfCash_Lbl = 'No. of cash sales ';
        NoOfRegisterOpen_Lbl = 'No. of register openings';
        NoOfCopies_Lbl = 'No. of receipt copies';
        VatInfo_Lbl = 'Tax information';
        OtherPayments_Lbl = 'Other Payments';
        PayedOtherValues_Lbl = 'Payed with other currencies';
        PayedGiftCard_Lbl = 'Payed with gift vouchers:';
        PayedForeignGiftCard_Lbl = 'Payed with foreign gift vouchers:';
        PayedVoucher_Lbl = 'Payed with credit vouchers:';
        PayedForeignVoucher_Lbl = 'Payed with foreign credit vouchers:';
        PayedDankort_Lbl = 'Payed with dankort ternimal:';
        PayedOtherCreditCard_Lbl = 'Paid with other credit card:';
        ManuelCard_Lbl = 'Manuel card: ';
        TerminalDesc_Lbl = 'Terminal: Signture / not approved card types: ';
        ForeignCurr_Lbl = 'Foreign valuta: ';
        GiftCardDisc_Lbl = 'Gift voucher discount: ';
        DebetSalesGift_Lbl = 'Credit sales / Gift voucher: ';
        ControlSum_Lbl = 'Checksum: ';
        Calculation_Lbl = 'Rounding: ';
        ReturnSales_Lbl = 'Return Sales:';
        Payments2_Lbl = 'Down Payments: ';
        CountingDetails_Lbl = 'Counting details';
        NothingCounted_Lbl = 'Nothing counted ';
        Unit_Lbl = 'Unit';
        No_Lbl = 'Qty';
        Total_Lbl = 'Total';
        TotalCase_Lbl = 'TOTAL';
        Cash_Lbl = 'Cash';
    }

    trigger OnPreReport()
    begin
        Firmaoplysninger.Get();
        Opsaetning.Get;
        Debetsalg := 0;
        BetalingerTotal := 0;
        CountTotalFooter := 0;
    end;

    var
        Firmaoplysninger: Record "Company Information";
        Revisionsrulle1: Record "NPR Audit Roll";
        Revisionsrulle2: Record "NPR Audit Roll";
        RevRulleTilgodebevis: Record "NPR Audit Roll";
        GlobalPeriod: Record "NPR Period";
        Kasserec: Record "NPR Register";
        Kasserecsidste: Record "NPR Register";
        Register: Record "NPR Register";
        Opsaetning: Record "NPR Retail Setup";
        Saelger: Record "Salesperson/Purchaser";
        Beregn: Boolean;
        DetailedCounting: Boolean;
        ShowHeader: Boolean;
        Frabon: Code[10];
        Tilbon: Code[10];
        Sidstebon: Code[30];
        Afrundet: Decimal;
        BalanceNeg: Decimal;
        BalancePos: Decimal;
        BetalingerTotal: Decimal;
        BevaegNeg: Decimal;
        BevaegPos: Decimal;
        Brugerrabat: Decimal;
        Brugerrabpct: Decimal;
        Bruttoomsaetning: Decimal;
        Changecash: Decimal;
        CountTotalFooter: Decimal;
        Daekningsgrad: Decimal;
        Dankortbevaeg: Decimal;
        Debetsalg: Decimal;
        Debitnewcalc: Decimal;
        Debitorindbetalinger: Decimal;
        Flerstyksrabat: Decimal;
        Flerstyksrabpct: Decimal;
        Gavekortbevaeg: Decimal;
        Gavekortsalg: Decimal;
        Gkdebet: Decimal;
        Kassedifference: Decimal;
        Kontantbevaeg: Decimal;
        Kreditkortsaldo: Decimal;
        Linierabat: Decimal;
        Linierabpct: Decimal;
        Mixprisrabat: Decimal;
        Mixprisrabpct: Decimal;
        Nettoomsaetning: Decimal;
        Optaltchecks: Decimal;
        Optaltkassebeholdning: Decimal;
        OtherCardNetChange: Decimal;
        OverfoertBank: Decimal;
        Perioderabat: Decimal;
        Perioderabpct: Decimal;
        Primo: Decimal;
        RabatPct: Decimal;
        ReturBeloebTotal: Decimal;
        Tilgodebevisbevaeg: Decimal;
        Tilgodebevisudstedelse: Decimal;
        TilgodeInd: Decimal;
        TilgodeUd: Decimal;
        Totalrabat: Decimal;
        Udbetalinger: Decimal;
        UkendteKortbevaeg: Decimal;
        Vareforbrug: Decimal;
        "Visa/Dkbevaeg": Decimal;
        Cancelledtransactions: Integer;
        Ekspeditionstaeller: Integer;
        ReturBonTotal: Integer;
        RegisterClosedLbl: Label 'Register closed by %1', Comment = '%1 = Salesperson Name';
        TitelTXT: Text[50];
        CloseTime: Time;
        OpenTime: Time;

    procedure BalanceUpdate(Beloeb: Decimal; pos: Boolean)
    begin
        if pos then
            BevaegPos := BevaegPos + Beloeb
        else
            BevaegNeg := BevaegNeg + Beloeb;
    end;
}

