report 6014473 "NPR Common balancing A4"
{
    // NPR70.00.00.00/LS/280613
    // NPR5.36/TJ  /20170927 CASE 286283 Renamed variables/functions/control names/ with danish specific letters into english letters
    // NPR5.39/JLK /20180212  CASE 300892 Removed CurrReport.PAGENO due to AL warning
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Common balancing A4.rdlc';

    Caption = 'Common Balancing A4';

    dataset
    {
        dataitem(Sales; "NPR Period")
        {
            CalcFields = "Pay Out";
            DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "No.");
            RequestFilterFields = "Date Closed";
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(ObjectDetails; ObjectDetails)
            {
            }
            column(Heading; 'Samlet kasserapport for den ' + Format(GetFilter("Date Closed")))
            {
            }
            column(Date_Time; Format(Today) + ' / ' + Format(Time))
            {
            }
            column(RegisterNo_Sales; Sales."Register No.")
            {
            }
            column(SalesPerson; SalesPerson)
            {
            }
            column(Closed_Sales; Format(dato) + ' / ' + Format(tid, 5))
            {
            }
            column(nKunder_Sales; nKunder)
            {
            }
            column(NetTurnover_Sales; netTurnover)
            {
            }
            column(GrossRevenue_Sales; grossRevenue)
            {
            }
            column(debetsalg_Sales; debetsalg)
            {
            }
            column(gavekortsalg_Sales; gavekortsalg)
            {
            }
            column(tilgodebeviser_Sales; tilgodebeviser)
            {
            }
            column(indbetalinger_Sales; indbetalinger)
            {
            }
            column(udbetalinger_Sales; udbetalinger)
            {
            }
            column(returantal_Sales; returantal)
            {
            }
            column(ReturnAmount_Sales; returnAmount)
            {
            }
            column(gkdebet_Sales; gkdebet)
            {
            }
            column(sumsalg_Sales; sumsalg[n])
            {
            }

            trigger OnAfterGetRecord()
            begin
                nKunder := 0;

                calcSales;

                gavekortsalg := Sales."Gift Voucher Sales";
                debetsalg := Sales."Debit Sale";
                tilgodebeviser := Sales."Credit Voucher issuing";
                indbetalinger := Sales."Cash Received";
                udbetalinger := Sales."Pay Out";
                returantal := Sales."Negative Sales Count";
                returnAmount := Sales."Negative Sales Amount";
                kontantoms := Sales."Net. Cash Change";
                gkdebet := Sales."Gift Voucher Debit";

                show_today := false;

                tnKunder += nKunder;
                tkontantoms += kontantoms;
                TNetTurnover += netTurnover;
                TGrossRevenue += grossRevenue;
                tgavekortsalg += gavekortsalg;
                tDebetsalg += debetsalg;
                ttilgodebeviser += tilgodebeviser;
                tindbetalinger += indbetalinger;
                tudbetalinger += udbetalinger;
                treturantal += returantal;
                treReturnAmount += returnAmount;
                tgkdebet += gkdebet;

                n += 1;
                sumsalg[n] := grossRevenue + gavekortsalg + tilgodebeviser + indbetalinger + udbetalinger + debetsalg;
                tsumsalg += sumsalg[n];

                kontrolsum[n] := kontantoms + debetsalg + gkdebet;

                afrunding[n] := tilgodebeviser +
                                gavekortsalg +
                                indbetalinger -
                                udbetalinger +
                                grossRevenue -
                                kontantoms -
                                gkdebet;

                show_today := true;
                dato := "Date Closed";
                tid := "Closing Time";

                if "Salesperson/Purchaser".Get("Salesperson Code") then
                    SalesPerson := "Salesperson/Purchaser".Name
                else
                    SalesPerson := '';
            end;

            trigger OnPreDataItem()
            begin
                if GetFilter("Date Closed") = '' then
                    Error(text001);

                //-NPR5.39
                //objver := utility.ReportVersion(CurrReport.OBJECTID);
                //+NPR5.39
            end;
        }
        dataitem(Balancing; "NPR Period")
        {
            DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "No.");

            trigger OnAfterGetRecord()
            begin
                if "Salesperson/Purchaser".Get("Salesperson Code") then
                    SalesPerson := "Salesperson/Purchaser".Name
                else
                    SalesPerson := '';

                kontantoms := Balancing."Net. Cash Change";
                dankort := Balancing."Net. Dankort Change";
                diff := Balancing.Difference;
                bank := Balancing."Deposit in Bank";
                veksel := Balancing."Change Register";
                primo := Balancing."Opening Cash";
                check := Balancing.Cheque;

                tdankort += dankort;
                tdiff += diff;
                tbank += bank;
                tveksel += veksel;
                tAbehold += "Balanced Cash Amount";
                tkontantoms += kontantoms;
                tprimo += primo;
                tcheck += check;

                dato := "Date Closed";
                tid := "Closing Time";

                kasse.Get("Register No.");
            end;

            trigger OnPreDataItem()
            begin

                SetView(Sales.GetView);

                if skiftsideprsektion then CurrReport.NewPage;

                n := 0;
            end;
        }
        dataitem(OtherPayments; "NPR Period")
        {
            DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "No.");
            dataitem(OtherPaymentsDetails; "Integer")
            {
                DataItemTableView = SORTING(Number);

                trigger OnPreDataItem()
                begin
                    i := 0;
                    i_max := 0;

                    CalcOtherCurrency();
                    calcGavekort();
                    calcTilgodebeviser();
                    calcManuelleKort();
                    calcTerminalKort();

                    SetRange(Number, 1, i_max);

                    n += 1;
                    BetalingerTotal := sumValuta + sumIndGavekort + sumIndTilgode + sumTerminalKort + sumManuelleKort;
                    kontrolsum[n] += BetalingerTotal;
                    tkontrolsum += kontrolsum[n];

                    afrunding[n] -= BetalingerTotal;
                    tAfrunding += afrunding[n];
                end;
            }

            trigger OnAfterGetRecord()
            begin
                dato := "Date Closed";
                tid := "Closing Time";
            end;

            trigger OnPreDataItem()
            begin
                SetView(Sales.GetView);

                if skiftsideprsektion then CurrReport.NewPage;

                n := 0;
            end;
        }
        dataitem(ControlSum; "NPR Period")
        {
            DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "No.");

            trigger OnAfterGetRecord()
            begin
                n += 1;

                dato := "Date Closed";
                tid := "Closing Time";
            end;

            trigger OnPreDataItem()
            begin
                SetView(Sales.GetView);

                if skiftsideprsektion then CurrReport.NewPage;

                n := 0;
            end;
        }
        dataitem(NotBalanced; "NPR Register")
        {
            DataItemTableView = SORTING(Status) WHERE(Status = FILTER(<> Afsluttet));

            trigger OnAfterGetRecord()
            var
                ar1: Record "NPR Audit Roll";
            begin
                CurrReport.Skip; //indtil alle andre kasser slettet

                Clear("Salesperson/Purchaser");

                ar1.SetRange("Register No.", "Register No.");
                ar1.SetRange("Sales Ticket No.", NotBalanced."Opened on Sales Ticket");
                ar1.SetRange("Sale Date", NotBalanced."Opened Date");
                if ar1.Find('-') then begin
                    salespersoncode := ar1."Salesperson Code";
                    if "Salesperson/Purchaser".Get(salespersoncode) then
                        SalesPerson := "Salesperson/Purchaser".Name;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if skiftsideprsektion then CurrReport.NewPage;
            end;
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

    labels
    {
        Report_Caption = 'Status Locations';
        Report_Info_Caption = 'Report info';
        Printed_Date_Caption = 'Printed date/time';
        Turnover_Caption = 'Turnover(Sales)';
        Register_Caption = 'Register';
        Name_Caption = 'Name';
        Closed_Caption = 'Closed';
        Number_Exp_Caption = 'Number exp.';
        Net_Sales_Caption = 'Net Sales';
        Cash_Sales_Caption = 'Cash Sales';
        Debit_Sale_Caption = 'Debit Sale';
        Sold_Vouchers_Caption = 'Sold Vouchers';
        Issued_Voucher_Caption = 'Issued Voucher';
        Deposits_Caption = 'Deposits';
        Payout_Caption = 'Payout';
        Return_Qty_Caption = 'Return Qty';
        ReturnAmt_Caption = 'Return Amt';
        GiftCard_Debit_Caption = 'GiftCard_Debit';
        Sum_Caption = 'Sum';
        Total_Caption = 'Total';
        Balancing_Heading_Caption = 'Settlement (counted at the cash exit)';
        Closed_d_Caption = 'Closed d';
        Primobeh_Caption = 'Primobeh.';
        Cash_Caption = 'Cash';
        Check_Caption = 'Check';
        Counted_Caption = 'Counted';
        Diff_Caption = 'Diff';
        Bank_Caption = 'Bank';
        Vekselboks_Caption = 'Vekselboks';
    }

    trigger OnInitReport()
    begin
        npc.Get;
        decformattxt := '<Precision,2:3><Standard Format,0>';
    end;

    var
        npc: Record "NPR Retail Setup";
        show_today: Boolean;
        dato: Date;
        tid: Time;
        skiftsideprsektion: Boolean;
        decformattxt: Text[100];
        tgkdebet: Decimal;
        sumsalg: array[100] of Decimal;
        tsumsalg: Decimal;
        udbetalinger: Decimal;
        indbetalinger: Decimal;
        gavekortsalg: Decimal;
        debetsalg: Decimal;
        tilgodebeviser: Decimal;
        nKunder: Integer;
        dankort: Decimal;
        diff: Decimal;
        bank: Decimal;
        veksel: Decimal;
        netTurnover: Decimal;
        grossRevenue: Decimal;
        kontantoms: Decimal;
        vareforbrug: Decimal;
        coverage: Decimal;
        TNetTurnover: Decimal;
        TGrossRevenue: Decimal;
        tAbehold: Decimal;
        tindbetalinger: Decimal;
        tudbetalinger: Decimal;
        tgavekortsalg: Decimal;
        ttilgodebeviser: Decimal;
        tDebetsalg: Decimal;
        tnKunder: Integer;
        returantal: Integer;
        returnAmount: Decimal;
        treturantal: Integer;
        treReturnAmount: Decimal;
        totalrabat: Decimal;
        flerstyksrabat: Decimal;
        brugerrabat: Decimal;
        perioderabat: Decimal;
        linierabat: Decimal;
        mixprisrabat: Decimal;
        brugerrabpct: Decimal;
        flerstyksrabpct: Decimal;
        mixprisrabpct: Decimal;
        perioderabpct: Decimal;
        linierabpct: Decimal;
        rabatpct: Decimal;
        check: Decimal;
        tcheck: Decimal;
        tdankort: Decimal;
        tdiff: Decimal;
        tbank: Decimal;
        tveksel: Decimal;
        tkontantoms: Decimal;
        "Salesperson/Purchaser": Record "Salesperson/Purchaser";
        SalesPerson: Text[100];
        kasse: Record "NPR Register";
        salespersoncode: Code[10];
        primo: Decimal;
        tprimo: Decimal;
        Valuta: array[100] of Text[30];
        tValuta: Decimal;
        txtValuta: array[100] of Text[100];
        sumValuta: Decimal;
        sumTxtValuta: Text[30];
        IndGavekort: array[100] of Text[30];
        tIndGavekort: Decimal;
        txtIndGavekort: array[100] of Text[100];
        sumIndGavekort: Decimal;
        sumTxtIndGavekort: Text[30];
        IndTilgode: array[100] of Text[30];
        tIndTilgode: Decimal;
        txtIndTilgode: array[100] of Text[100];
        sumIndTilgode: Decimal;
        sumTxtIndTilgode: Text[30];
        ManuelleKort: array[100] of Text[30];
        tManuelleKort: Decimal;
        txtManuelleKort: array[100] of Text[100];
        sumManuelleKort: Decimal;
        sumTxtManuelleKort: Text[30];
        Terminalkort: array[100] of Text[30];
        tTerminalkort: Decimal;
        txtTerminalkort: array[100] of Text[100];
        sumTerminalKort: Decimal;
        sumTxtTerminalKort: Text[30];
        i: Integer;
        i_max: Integer;
        payment: Record "NPR Payment Type POS";
        kontrolsum: array[100] of Decimal;
        tkontrolsum: Decimal;
        BetalingerTotal: Decimal;
        gkdebet: Decimal;
        n: Integer;
        afrunding: array[100] of Decimal;
        tAfrunding: Decimal;
        text001: Label 'Filter missing on field "Date closed"';
        ObjectDetails: Text[100];
        CurrReport_PAGENOCaptionLbl: Label 'Page';

    procedure calcSales()
    var
        ar: Record "NPR Audit Roll";
        lastReceipt: Code[10];
    begin

        nKunder := 0;

        ar.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);

        ar.SetRange("Register No.", Sales."Register No.");
        ar.SetFilter("Sales Ticket No.", '%1..%2', Sales."Opening Sales Ticket No.", Sales."Sales Ticket No.");
        ar.SetRange("Sale Type", ar."Sale Type"::Sale);

        ar.CalcSums(Amount);
        netTurnover := ar.Amount;

        ar.CalcSums("Amount Including VAT");
        grossRevenue := ar."Amount Including VAT";

        ar.CalcSums("Line Discount Amount");
        totalrabat := ar."Line Discount Amount";

        ar.CalcSums(Cost);
        vareforbrug := ar.Cost;

        if ar.Find('-') then
            repeat
                if (ar."Sale Type" = ar."Sale Type"::Sale) then begin
                    if ar."Sales Ticket No." <> lastReceipt then
                        nKunder += 1;
                    lastReceipt := ar."Sales Ticket No.";
                end;
                case ar."Discount Type" of
                    ar."Discount Type"::Campaign:
                        perioderabat := perioderabat + ar."Line Discount Amount";
                    ar."Discount Type"::Mix:
                        mixprisrabat := mixprisrabat + ar."Line Discount Amount";
                    ar."Discount Type"::Quantity:
                        flerstyksrabat := flerstyksrabat + ar."Line Discount Amount";
                    ar."Discount Type"::Manual:
                        brugerrabat := brugerrabat + ar."Line Discount Amount";
                    5:
                        linierabat := linierabat + ar."Line Discount Amount";
                    0:
                        linierabat := linierabat + ar."Line Discount Amount";
                end;
            until ar.Next = 0;

        if netTurnover <> 0 then
            coverage := (netTurnover - vareforbrug) * 100 / netTurnover;

        if (netTurnover - vareforbrug < 0) and (coverage > 0) then coverage := coverage * (-1);

        if grossRevenue <> 0 then begin
            brugerrabpct := brugerrabat * 100 / grossRevenue;
            flerstyksrabpct := flerstyksrabat * 100 / grossRevenue;
            mixprisrabpct := mixprisrabat * 100 / grossRevenue;
            perioderabpct := perioderabat * 100 / grossRevenue;
            linierabpct := linierabat * 100 / grossRevenue;
            rabatpct := totalrabat * 100 / grossRevenue;
        end;
    end;

    procedure CalcOtherCurrency()
    begin

        payment.Reset;
        payment.SetCurrentKey("Processing Type");
        payment.SetRange("Date Filter", OtherPayments."Date Closed");
        payment.SetRange("Register Filter", OtherPayments."Register No.");
        payment.SetFilter("Processing Type", '%1',
                          payment."Processing Type"::"Foreign Currency");
        payment.SetFilter("Receipt Filter", '%1..%2',
                          OtherPayments."Opening Sales Ticket No.",
                          OtherPayments."Sales Ticket No.");

        i := 0;

        Clear(Valuta);
        Clear(txtValuta);
        sumValuta := 0;
        sumTxtValuta := '';
        if payment.Find('-') then
            repeat
                payment.CalcFields("Amount in Audit Roll");
                if payment."Amount in Audit Roll" <> 0 then begin
                    i += 1;
                    txtValuta[i] := payment."G/L Account No." + ' ' + payment."No.";
                    Valuta[i] := Format(payment."Amount in Audit Roll", 0, decformattxt);
                    tValuta += payment."Amount in Audit Roll";
                    sumValuta += payment."Amount in Audit Roll";
                    sumTxtValuta := Format(tValuta, 0, decformattxt);
                end;
            until payment.Next = 0;

        if i > i_max then
            i_max := i;
    end;

    procedure calcGavekort()
    begin

        payment.Reset;
        payment.SetCurrentKey("Processing Type");
        payment.SetRange("Date Filter", OtherPayments."Date Closed");
        payment.SetRange("Register Filter", OtherPayments."Register No.");
        payment.SetFilter("Processing Type", '%1|%2',
                          payment."Processing Type"::"Gift Voucher",
                          payment."Processing Type"::"Foreign Gift Voucher");
        payment.SetFilter("Receipt Filter", '%1..%2',
                          OtherPayments."Opening Sales Ticket No.",
                          OtherPayments."Sales Ticket No.");

        i := 0;

        Clear(txtIndGavekort);
        Clear(IndGavekort);
        Clear(sumIndGavekort);
        Clear(sumTxtIndGavekort);
        if payment.Find('-') then
            repeat
                payment.CalcFields("Amount in Audit Roll");
                if payment."Amount in Audit Roll" <> 0 then begin
                    i += 1;
                    txtIndGavekort[i] := payment."G/L Account No." + ' ' + payment."No.";
                    IndGavekort[i] := Format(payment."Amount in Audit Roll", 0, decformattxt);
                    tIndGavekort += payment."Amount in Audit Roll";
                    sumIndGavekort += payment."Amount in Audit Roll";
                    sumTxtIndGavekort := Format(sumIndGavekort, 0, decformattxt);
                end;
            until payment.Next = 0;

        if i > i_max then
            i_max := i;
    end;

    procedure calcTilgodebeviser()
    begin

        payment.Reset;
        payment.SetCurrentKey("Processing Type");
        payment.SetRange("Date Filter", OtherPayments."Date Closed");
        payment.SetRange("Register Filter", OtherPayments."Register No.");
        payment.SetFilter("Processing Type", '%1|%2',
                          payment."Processing Type"::"Credit Voucher",
                          payment."Processing Type"::"Foreign Credit Voucher");
        payment.SetFilter("Receipt Filter", '%1..%2',
                          OtherPayments."Opening Sales Ticket No.",
                          OtherPayments."Sales Ticket No.");

        i := 0;
        Clear(IndTilgode);
        Clear(txtIndTilgode);
        Clear(sumIndTilgode);
        Clear(sumTxtIndTilgode);
        if payment.Find('-') then
            repeat
                payment.CalcFields("Amount in Audit Roll");
                if payment."Amount in Audit Roll" <> 0 then begin
                    i += 1;
                    txtIndTilgode[i] := payment."G/L Account No." + ' ' + payment."No.";
                    IndTilgode[i] := Format(payment."Amount in Audit Roll", 0, decformattxt);
                    tIndTilgode += payment."Amount in Audit Roll";
                    sumIndTilgode += payment."Amount in Audit Roll";
                    sumTxtIndTilgode := Format(sumIndTilgode, 0, decformattxt);
                end;
            until payment.Next = 0;

        if i > i_max then
            i_max := i;
    end;

    procedure calcManuelleKort()
    begin

        payment.Reset;
        payment.SetCurrentKey("Processing Type");
        payment.SetRange("Date Filter", OtherPayments."Date Closed");
        payment.SetRange("Register Filter", OtherPayments."Register No.");
        payment.SetFilter("Processing Type", '%1',
                          payment."Processing Type"::"Manual Card",
                          payment."Processing Type"::"Other Credit Cards");
        payment.SetFilter("Receipt Filter", '%1..%2',
                          OtherPayments."Opening Sales Ticket No.",
                          OtherPayments."Sales Ticket No.");

        i := 0;

        Clear(ManuelleKort);
        Clear(txtManuelleKort);
        Clear(sumManuelleKort);
        Clear(sumTxtManuelleKort);
        if payment.Find('-') then
            repeat
                payment.CalcFields("Amount in Audit Roll");
                if payment."Amount in Audit Roll" <> 0 then begin
                    i += 1;
                    txtManuelleKort[i] := payment."G/L Account No." + ' ' + payment."No.";
                    ManuelleKort[i] := Format(payment."Amount in Audit Roll", 0, decformattxt);
                    tManuelleKort += payment."Amount in Audit Roll";
                    sumManuelleKort += payment."Amount in Audit Roll";
                    sumTxtManuelleKort := Format(tValuta, 0, decformattxt);
                end;
            until payment.Next = 0;

        if i > i_max then
            i_max := i;
    end;

    procedure calcTerminalKort()
    begin

        payment.Reset;
        payment.SetCurrentKey("Processing Type");
        payment.SetRange("Date Filter", OtherPayments."Date Closed");
        payment.SetRange("Register Filter", OtherPayments."Register No.");
        payment.SetFilter("Processing Type", '%1',
                          payment."Processing Type"::"Terminal Card");
        payment.SetFilter("Receipt Filter", '%1..%2',
                          OtherPayments."Opening Sales Ticket No.",
                          OtherPayments."Sales Ticket No.");

        i := 0;

        Clear(Terminalkort);
        Clear(txtTerminalkort);
        Clear(sumTerminalKort);
        Clear(sumTxtTerminalKort);
        if payment.Find('-') then
            repeat
                payment.CalcFields("Amount in Audit Roll");
                if payment."Amount in Audit Roll" <> 0 then begin
                    i += 1;
                    txtTerminalkort[i] := payment."G/L Account No." + ' ' + payment."No.";
                    Terminalkort[i] := Format(payment."Amount in Audit Roll", 0, decformattxt);
                    tTerminalkort += payment."Amount in Audit Roll";
                    sumTerminalKort += payment."Amount in Audit Roll";
                    sumTxtTerminalKort := Format(tValuta, 0, decformattxt);
                end;
            until payment.Next = 0;

        if i > i_max then
            i_max := i;
    end;
}

