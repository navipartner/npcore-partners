report 6014401 "NPR Counter Report A4"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Counter Report A4.rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Counter Report A4';
    dataset
    {
        dataitem("Audit Roll"; "NPR Audit Roll")
        {
            DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.");
            RequestFilterFields = "Register No.", "Sales Ticket No.";
            column(ReportCaption; RegisterReportText)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(ShortcutDimension1Code_AuditRoll; "Shortcut Dimension 1 Code")
            {
            }
            column(RegisterNo_AuditRoll; "Register No.")
            {
            }
            column(SalesTicketNo_AuditRoll; "Sales Ticket No.")
            {
            }
            column(OpeningHours_AuditRoll; Format(Opentime) + ' .. ' + Format(Closetime))
            {
            }
            column(TicketCount; Ekspeditionstaeller)
            {
            }
            column(Sales_Ticket_No_AuditRollCalc1; AuditRollCalc1."Sales Ticket No.")
            {
            }
            column(Sales_Ticket_No_AuditRoll; "Sales Ticket No.")
            {
            }
            column(SaleDate_AuditRoll; "Sale Date")
            {
            }
            column(Description_AuditRoll; Description)
            {
            }
            column(OpeningCash; OpeningCash)
            {
            }
            column(RegisterMovement; RegisterMovement)
            {
            }
            column(RegisterMovementNeg; RegisterMovementNeg)
            {
            }
            column(TerminalCardMovement; TerminalCardMovement)
            {
            }
            column(TerminalCardMovementNeg; TerminalCardMovementNeg)
            {
            }
            column(Visa_DKMovement; CreditMovement)
            {
            }
            column(Visa_DKMovementNeg; CreditMovementNeg)
            {
            }
            column(OtherCardNetChange; OtherCardNetChange)
            {
            }
            column(OtherCardNetChangeNegative; OtherCardNetChangeNegative)
            {
            }
            column(UnknownCCMovement; UnknownCCMovement)
            {
            }
            column(UnknownCCMovementNeg; UnknownCCMovementNeg)
            {
            }
            column(GiftVoucherMovement; GiftVoucherMovement)
            {
            }
            column(GiftVoucherMovementNeg; GiftVoucherMovementNeg)
            {
            }
            column(CreditVoucherIn; CreditVoucherIn)
            {
            }
            column(CreditVoucherOut; CreditVoucherOut)
            {
            }
            column(MovementPos; MovementPos)
            {
            }
            column(MovementNeg; MovementNeg)
            {
            }
            column(TransferToBank; TransferToBank)
            {
            }
            column(NegCreditCardBalance; CreditCardBalanceNeg)
            {
            }
            column(CreditCardBalance; CreditCardBalance)
            {
            }
            column(CashDifference; CashDifference)
            {
            }
            column(ClosingCash_AuditRoll; "Closing Cash")
            {
            }
            column(BalancePos; BalancePos)
            {
            }
            column(BalanceNeg; BalanceNeg)
            {
            }
            column(GrossTurnover; GrossTurnover)
            {
            }
            column(DebitSaleCaption; Text10600004)
            {
            }
            column(DebitSale; DebitSale)
            {
            }
            column(PaymentsCaption; Text10600005)
            {
            }
            column(CustomerDeposits; CustomerDeposits)
            {
            }
            column(WithdrawalsCaption; Text10600006)
            {
            }
            column(PayOut_GlobalPeriod; GlobalPeriod."Pay Out")
            {
            }
            column(NetTurnover; NetTurnover)
            {
            }
            column(ItemCost; ItemCost)
            {
            }
            column(Profit_LCY; NetTurnover - ItemCost)
            {
            }
            column(CoverageAmt; CoverageAmt)
            {
            }
            column(CampaignDiscount; CampaignDiscount)
            {
            }
            column(CampaignDiscountPct; CampaignDiscountPct)
            {
            }
            column(QuantityDiscount; QuantityDiscount)
            {
            }
            column(QuantityDiscountPct; QuantityDiscountPct)
            {
            }
            column(MixDiscount; MixDiscount)
            {
            }
            column(MixDiscountPct; MixDiscountPct)
            {
            }
            column(ManualDiscount; ManualDiscount)
            {
            }
            column(ManualDiscountPct; ManualDiscountPct)
            {
            }
            column(TotalDiscount; TotalDiscount)
            {
            }
            column(TotalDiscountPct; TotalDiscountPct)
            {
            }

            trigger OnAfterGetRecord()
            begin
                GlobalPeriod.SetRange("Register No.", "Register No.");
                GlobalPeriod.SetRange("Sales Ticket No.", "Sales Ticket No.");
                GlobalPeriod.FindLast();

                AuditRoll1.SetCurrentKey("Sale Date", "Sale Type");
                AuditRoll1.SetRange("Sale Date", "Audit Roll"."Sale Date");
                AuditRoll1.SetRange("Sale Type", AuditRoll1."Sale Type"::Sale);
                if AuditRoll1.FindFirst() then
                    Opentime := AuditRoll1."Starting Time";
                if AuditRoll1.FindLast() then
                    Closetime := AuditRoll1."Closing Time";
                if AuditRoll1.FindSet() then
                    repeat
                        if Sidstebon <> AuditRoll1."Sales Ticket No." then
                            Ekspeditionstaeller += 1;
                        Sidstebon := AuditRoll1."Sales Ticket No.";
                    until AuditRoll1.Next() = 0;
                AuditRoll1.SetRange("Sale Date");
                AuditRoll1.SetRange("Sale Type");

                if RetailSetup."Show Counting on Counter Rep." then
                    GetCountAmount("Balance Amount");

                if RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER" then begin
                    RegisterReportText := Text10600000;
                    AuditRollCalc1.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);
                    AuditRollCalc1.SetRange("Register No.", "Register No.");
                    AuditRollCalc1.SetRange("Sales Ticket No.", "Sales Ticket No.");
                    AuditRollCalc1.SetRange("Sale Type", AuditRollCalc1."Sale Type"::Comment);
                    AuditRollCalc1.SetRange(Type, AuditRollCalc1.Type::"Open/Close");
                    if AuditRollCalc1.Find('-') then begin
                        AuditRollCalc1.SetRange("Sales Ticket No.");
                        AuditRollCalc1.Next(-1);
                    end;

                    if Calc then begin
                        AuditRollCalc2.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);
                        Register.FindFirst();
                        RegisterLast.FindLast();
                        AuditRollCalc2.SetFilter("Register No.", '%1..%2', Register."Register No.", RegisterLast."Register No.");

                        AuditRollCalc2.SetFilter("Sales Ticket No.", '%1..%2', AuditRollCalc1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                        AuditRollCalc2.SetRange("Sale Type", AuditRollCalc2."Sale Type"::Sale);
                        AuditRollCalc2.CalcSums(Amount);
                        NetTurnover := AuditRollCalc2.Amount;

                        AuditRollCalc2.CalcSums("Amount Including VAT");
                        GrossTurnover := AuditRollCalc2."Amount Including VAT";
                        AuditRollCalc2.CalcSums("Line Discount Amount");
                        TotalDiscount := AuditRollCalc2."Line Discount Amount";
                        AuditRollCalc2.CalcSums(Cost);
                        ItemCost := AuditRollCalc2.Cost;
                        if AuditRollCalc2.FindSet() then
                            repeat
                                case AuditRollCalc2."Discount Type" of
                                    AuditRollCalc2."Discount Type"::Campaign:
                                        CampaignDiscount := CampaignDiscount + AuditRollCalc2."Line Discount Amount";
                                    AuditRollCalc2."Discount Type"::Mix:
                                        MixDiscount := MixDiscount + AuditRollCalc2."Line Discount Amount";
                                    AuditRollCalc2."Discount Type"::Quantity:
                                        QuantityDiscount := QuantityDiscount + AuditRollCalc2."Line Discount Amount";
                                    AuditRollCalc2."Discount Type"::Manual:
                                        ManualDiscount := ManualDiscount + AuditRollCalc2."Line Discount Amount";
                                end;
                            until AuditRollCalc2.Next() = 0;
                        if NetTurnover <> 0 then
                            CoverageAmt := (NetTurnover - ItemCost) * 100 / NetTurnover;

                        if (NetTurnover - ItemCost < 0) and (CoverageAmt > 0) then
                            CoverageAmt := CoverageAmt * (-1);

                        if GrossTurnover <> 0 then begin
                            ManualDiscountPct := ManualDiscount * 100 / GrossTurnover;
                            QuantityDiscountPct := QuantityDiscount * 100 / GrossTurnover;
                            MixDiscountPct := MixDiscount * 100 / GrossTurnover;
                            CampaignDiscountPct := CampaignDiscount * 100 / GrossTurnover;
                            TotalDiscountPct := TotalDiscount * 100 / GrossTurnover;
                        end;
                    end;
                end;

                if RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL then begin
                    RegisterReportText := Text10600001;
                    Clear(AuditRollCalc2);
                    AuditRollCalc2.SetCurrentKey("Sale Date", "Sale Type");
                    AuditRollCalc2.SetRange("Sale Type", AuditRollCalc2."Sale Type"::Sale);
                    AuditRollCalc2.SetRange("Sale Date", "Sale Date");
                    AuditRollCalc2.CalcSums(Amount);
                    NetTurnover := AuditRollCalc2.Amount;
                    AuditRollCalc2.CalcSums("Amount Including VAT");
                    GrossTurnover := AuditRollCalc2."Amount Including VAT";
                    AuditRollCalc2.CalcSums("Line Discount Amount");
                    TotalDiscount := AuditRollCalc2."Line Discount Amount";
                    AuditRollCalc2.CalcSums(Cost);
                    ItemCost := AuditRollCalc2.Cost;
                    if AuditRollCalc2.FindSet() then
                        repeat
                            case AuditRollCalc2."Discount Type" of
                                AuditRollCalc2."Discount Type"::Campaign:
                                    CampaignDiscount := CampaignDiscount + AuditRollCalc2."Line Discount Amount";
                                AuditRollCalc2."Discount Type"::Mix:
                                    MixDiscount := MixDiscount + AuditRollCalc2."Line Discount Amount";
                                AuditRollCalc2."Discount Type"::Quantity:
                                    QuantityDiscount := QuantityDiscount + AuditRollCalc2."Line Discount Amount";
                                AuditRollCalc2."Discount Type"::Manual:
                                    ManualDiscount := ManualDiscount + AuditRollCalc2."Line Discount Amount";
                            end;
                        until AuditRollCalc2.Next() = 0;
                    if NetTurnover <> 0 then
                        CoverageAmt := (NetTurnover - ItemCost) * 100 / NetTurnover;

                    if (NetTurnover - ItemCost < 0) and (CoverageAmt > 0) then
                        CoverageAmt := CoverageAmt * (-1);

                    if GrossTurnover <> 0 then begin
                        ManualDiscountPct := ManualDiscount * 100 / GrossTurnover;
                        QuantityDiscountPct := QuantityDiscount * 100 / GrossTurnover;
                        MixDiscountPct := MixDiscount * 100 / GrossTurnover;
                        CampaignDiscountPct := CampaignDiscount * 100 / GrossTurnover;
                        TotalDiscountPct := TotalDiscount * 100 / GrossTurnover;
                    end;
                end;

                DebitSale := 0;
                AuditRollCalc2.Reset();
                AuditRollCalc2.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);
                AuditRollCalc2.SetRange("Register No.", "Register No.");
                AuditRollCalc2.SetFilter("Sales Ticket No.", '%1..%2', AuditRollCalc1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                AuditRollCalc2.SetRange("Sale Type", AuditRollCalc2."Sale Type"::"Debit Sale");
                AuditRollCalc2.CalcSums("Amount Including VAT");
                AuditRollCalc2.CalcSums(Amount);
                DebitSale := AuditRollCalc2."Amount Including VAT";

                CustomerDeposits := 0;
                AuditRollCalc2.Reset();
                AuditRollCalc2.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);
                AuditRollCalc2.SetRange("Register No.", "Register No.");
                AuditRollCalc2.SetFilter("Sales Ticket No.", '%1..%2', AuditRollCalc1."Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                AuditRollCalc2.SetRange(Type, AuditRollCalc2.Type::Customer);
                AuditRollCalc2.SetRange("Sale Type", AuditRollCalc2."Sale Type"::Deposit);
                AuditRollCalc2.CalcSums(Amount);
                CustomerDeposits := AuditRollCalc2.Amount;

                MovementPos := 0;
                MovementNeg := 0;
                StartPos := 0;
                i := 1;
                for i := 1 to 8 do begin
                    for NumCount := 1 to StrLen("Audit Roll"."Balance Sundries") do
                        if CopyStr("Audit Roll"."Balance Sundries", NumCount, 1) = ';' then begin
                            if StartPos > 0 then
                                StartPos := EndPos + 1
                            else
                                StartPos := 1;
                            EndPos := NumCount;
                            CodeConvert := CopyStr("Audit Roll"."Balance Sundries", StartPos, EndPos - StartPos);
                            if CodeConvert <> '' then
                                case i of
                                    1:
                                        begin
                                            Evaluate(OpeningCash, CodeConvert);
                                            if OpeningCash > 0 then
                                                BalanceUpdate(OpeningCash, true)
                                            else
                                                BalanceUpdate(OpeningCash, false);
                                        end;
                                    2:
                                        begin
                                            Evaluate(RegisterMovement, CodeConvert);
                                            if RegisterMovement > 0 then
                                                BalanceUpdate(RegisterMovement, true)
                                            else begin
                                                RegisterMovementNeg := RegisterMovement;
                                                BalanceUpdate(RegisterMovement, false);
                                            end;
                                        end;
                                    3:
                                        Evaluate(CreditVoucherMovement, CodeConvert);
                                    4:
                                        begin
                                            Evaluate(GiftVoucherMovement, CodeConvert);
                                            if GiftVoucherMovement > 0 then
                                                BalanceUpdate(GiftVoucherMovement, true)
                                            else begin
                                                GiftVoucherMovementNeg := GiftVoucherMovement;
                                                BalanceUpdate(GiftVoucherMovement, false);
                                            end;
                                        end;
                                    5:
                                        begin
                                            Evaluate(UnknownCCMovement, CodeConvert);
                                            if UnknownCCMovement > 0 then
                                                BalanceUpdate(UnknownCCMovement, true)
                                            else begin
                                                UnknownCCMovementNeg := UnknownCCMovement;
                                                BalanceUpdate(UnknownCCMovement, false);
                                            end;
                                        end;
                                    6:
                                        begin
                                            Evaluate(TerminalCardMovement, CodeConvert);
                                            if TerminalCardMovement > 0 then
                                                BalanceUpdate(TerminalCardMovement, true)
                                            else begin
                                                TerminalCardMovementNeg := TerminalCardMovement;
                                                BalanceUpdate(TerminalCardMovement, false);
                                            end;
                                        end;
                                    7:
                                        begin
                                            Evaluate(CreditMovement, CodeConvert);
                                            if CreditMovement > 0 then
                                                BalanceUpdate(CreditMovement, true)
                                            else begin
                                                CreditMovementNeg := CreditMovement;
                                                BalanceUpdate(CreditMovement, false);
                                            end;
                                        end;
                                    8:
                                        begin
                                            Evaluate(OtherCardNetChange, CodeConvert);
                                            if OtherCardNetChange > 0 then
                                                BalanceUpdate(OtherCardNetChange, true)
                                            else begin
                                                OtherCardNetChangeNegative := OtherCardNetChange;
                                                BalanceUpdate(OtherCardNetChange, false);
                                            end;
                                        end;
                                end;
                            i := i + 1;
                        end;
                end;

                TransferToBank := "Audit Roll"."Transferred to Balance Account";
                CashDifference := OpeningCash + RegisterMovement - TransferToBank - "Closing Cash";
                CreditCardBalance := OtherCardNetChange + CreditMovement + TerminalCardMovement + UnknownCCMovement;
                "Closing Cash" := "Audit Roll"."Closing Cash";

                CreditCardBalanceNeg := 0;
                if CreditCardBalance < 0 then
                    CreditCardBalanceNeg := CreditCardBalance;

                if CashDifference < 0 then begin
                    BalancePos := MovementPos + (-CashDifference);
                    BalanceNeg := MovementNeg + TransferToBank + "Closing Cash";
                end else begin
                    BalancePos := MovementPos;
                    BalanceNeg := MovementNeg + TransferToBank + CashDifference + "Closing Cash";
                end;
                if CreditCardBalance < 0 then
                    BalancePos := BalancePos + (-CreditCardBalance)
                else
                    BalanceNeg := BalanceNeg + CreditCardBalance;

                AuditRollCreditVoucher.SetRange("Register No.", "Audit Roll"."Register No.");
                AuditRollCreditVoucher.SetRange("Sale Date", "Audit Roll"."Sale Date");
                AuditRollCreditVoucher.SetFilter(Description, '%1', '*Tilgodebevis*');

                if AuditRollCreditVoucher.FindSet() then
                    repeat
                        if (AuditRollCreditVoucher."Sale Type" = AuditRollCreditVoucher."Sale Type"::Deposit) then
                            CreditVoucherIn := AuditRollCreditVoucher."Amount Including VAT"
                        else
                            CreditVoucherOut := AuditRollCreditVoucher."Amount Including VAT";
                    until AuditRollCreditVoucher.Next() = 0;

                if (CreditVoucherIn - CreditVoucherOut) > 0 then
                    BalanceUpdate(CreditVoucherIn - CreditVoucherOut, true)
                else
                    BalanceUpdate(CreditVoucherIn - CreditVoucherOut, false);

                FromTicket := AuditRollCalc1."Sales Ticket No.";
                ToTicket := "Audit Roll"."Sales Ticket No.";

                if RegisterMovement < 0 then
                    RegisterMovement := 0;

                if GiftVoucherMovement < 0 then
                    GiftVoucherMovement := 0;

                if UnknownCCMovement < 0 then
                    UnknownCCMovement := 0;

                if TerminalCardMovement < 0 then
                    TerminalCardMovement := 0;

                if CreditMovement < 0 then
                    CreditMovement := 0;

                if OtherCardNetChange < 0 then
                    OtherCardNetChange := 0;
            end;

            trigger OnPreDataItem()
            begin
                RetailSetup.Get();
                Calc := true;
            end;
        }
        dataitem("Payment Type POS"; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("No.", "Register No.");
            column(No_PaymentTypePOS; "No.")
            {
            }
            column(RegisterNo_PaymentTypePOS; "Register No.")
            {
            }
            column(RegisterFilterText; RegisterFilterText)
            {
            }
            column(Description_PaymentTypePOS; Description)
            {
            }
            column(Amountinauditroll_PaymentTypePOS; "Amount in Audit Roll")
            {
            }

            trigger OnPreDataItem()
            begin
                if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
                    "Payment Type POS".SetRange("Date Filter", AuditRollCalc2."Sale Date");
                    Register.FindFirst();
                    RegisterLast.FindLast();
                    "Payment Type POS".SetRange("Register Filter", Register."Register No.", RegisterLast."Register No.");
                    "Payment Type POS".CalcFields("Amount in Audit Roll");
                end;

                if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
                    "Payment Type POS".SetRange("Date Filter", AuditRollCalc1."Sale Date");
                    "Payment Type POS".SetRange("Register Filter", AuditRollCalc1."Register No.");
                    "Payment Type POS".CalcFields("Amount in Audit Roll");
                end;

                RegisterFilterText := Text10600002 + Format(GetRangeMin("Register Filter")) + '..' + Format(GetRangeMax("Register Filter"));
                if (GetRangeMin("Register Filter") = GetRangeMax("Register Filter")) then
                    RegisterFilterText := Text10600002 + Format(GetRangeMax("Register Filter"));
            end;
        }
        dataitem("G/L Account"; "G/L Account")
        {
            column(No_GLAccount; "No.")
            {
            }
            column(Name_GLAccount; Name)
            {
            }
            column(GLEntryInAuditRoll_GLAccount; "NPR G/L Entry in Audit Roll")
            {
            }
            column(NameNo_PaymentTypePOS; Name + '  ' + Format("No."))
            {
            }

            trigger OnAfterGetRecord()
            begin
                if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
                    "G/L Account".SetRange("Date Filter", AuditRollCalc2."Sale Date");
                    "G/L Account".SetRange("G/L Account"."NPR Register Filter", AuditRollCalc2."Register No.");
                end;

                if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
                    "G/L Account".SetRange("Date Filter", AuditRollCalc1."Sale Date");
                    "G/L Account".SetRange("G/L Account"."NPR Register Filter", AuditRollCalc1."Register No.");
                end;
                SetRange("NPR Retail Payment", true);
                CalcFields("NPR G/L Entry in Audit Roll");
            end;
        }
        dataitem(AuditRollReturnSale; "NPR Audit Roll")
        {
            DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date");
            column(SalesTicketNo_AuditRollReturnSale; "Sales Ticket No.")
            {
            }
            column(ReturnTicketTotal; ReturnTicketTotal)
            {
            }
            column(AmountIncludingVAT_AuditRollReturnSale; "Amount Including VAT")
            {
            }

            trigger OnAfterGetRecord()
            begin
                ReturnAmountTotal += "Amount Including VAT";
                if (LastTicketNo <> "Sales Ticket No.") then
                    ReturnTicketTotal += 1;
                LastTicketNo := "Sales Ticket No.";
            end;

            trigger OnPreDataItem()
            begin
                ReturnAmountTotal := 0;
                ReturnTicketTotal := 0;

                AuditRollReturnSale.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);
                AuditRollReturnSale.SetRange("Register No.", "Audit Roll"."Register No.");
                AuditRollReturnSale.SetRange("Sales Ticket No.", FromTicket, ToTicket);

                AuditRollReturnSale.SetRange(Type, AuditRollReturnSale.Type::Item);
                AuditRollReturnSale.SetRange(Quantity, -9999, 0);
            end;
        }
        dataitem(PaymentTypeCounting; "NPR Payment Type POS")
        {
            DataItemTableView = SORTING("Register No.", "Processing Type") WHERE("Processing Type" = FILTER(Cash | "Foreign Currency"), "To be Balanced" = CONST(true));
            column(No_PaymenTypeCounting; "No.")
            {
            }
            column(Description_PaymentTypeCounting; Description)
            {
            }
            dataitem(PeriodLine; "NPR Period Line")
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

                trigger OnPreDataItem()
                begin
                    SetRange("Register No.", "Audit Roll"."Register No.");
                    SetRange("Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                    SetRange("Payment Type No.", PaymentTypeCounting."No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not RetailSetup."Show Counting on Counter Rep." then
                    CurrReport.Skip();
            end;
        }
    }

    labels
    {
        Pament_Type_Caption = 'Payment Type:';
        Payment_Type_Out_Caption = 'Payment Type/Pay Out:';
        Name__Caption = 'Name';
        PayOut__Caption = 'Pay Out:';
        PayOut__AuditRoll_Caption = 'Pay Out in Audit Roll';
        No_Transactions_Caption = 'No. of transactions';
        AmtIncl_VAT_Caption = 'Amount Including VAT';
        Return_Sale_Caption = 'Pay Out:';
        Footer_Caption = 'Payment Type/Pay Out:';
        DepartmentCodeCaptionLbl = 'Department Code';
        RegisterNoCaptionLbl = 'Register No.';
        SalesTicketNoCaptionLbl = 'Sales Ticket No.';
        OpeningHoursCaptionLbl = 'Opening Hours';
        SalesCounterCaptionLbl = 'Sales Counter';
        AllAmtInclVATCaptionLbl = 'All amounts incl. VAT';
        FromSalesTicketCaptionLbl = 'From Sales Ticket';
        SalesTicketNoTicketFilterCaptionLbl = 'Sales Ticket No. Filter';
        ToSalesTicketCaptionLbl = 'To Sales Ticket';
        ClosingDateCaptionLbl = 'Closing Date';
        DescriptionCaptionLbl = 'Description';
        TodayMovementsCaptionLbl = 'Today''''s Movements:';
        OpeningCashCaptionLbl = 'Opening Cash';
        RegisterMovementCaptionLbl = 'Register Movement';
        TerminalCardMovementCaptionLbl = 'Terminal Card Movement';
        ManualCardMovementCaptionLbl = 'Manual Card Movement';
        OtherCCMovementCaptionLbl = 'Other Credit Card Movement';
        UnknownCCMovementCaptionLbl = 'Unknown Credit Card Movement';
        GiftVoucherMovementCaptionLbl = 'Gift Voucher Movement';
        CreditVoucherMovementCaptionLbl = 'Credit Voucher Movement';
        TransferredToBankCaptionLbl = 'Transferred to Bank';
        CreditCardBalanceCaptionLbl = 'Credit Card Balance';
        DifferenceCaptionLbl = 'Difference';
        ClosingCashCaptionLbl = 'Closing Cash';
        DebitCaptionLbl = 'Debit';
        CreditCaptionLbl = 'Credit';
        CurrReport_PAGENOCaptionLbl = 'Page';
        ReportCaptionLbl = 'Salesperson/Itemgroup';
        KeyFiguresCaptionLbl = 'Key Figures:';
        GrossTuroverCaptionLbl = 'Gross Turnover';
        NetTurnoverCaptionLbl = 'Net Turnover';
        COGS_LCY_CaptionLbl = 'COGS (LCY)';
        Profit_LCY_CaptionLbl = 'Profit (LCY)';
        PCT_CaptionLbl = '%';
        PeriodDiscount_CaptionLbl = 'Period Discount';
        MultiUnitDiscount_CaptionLbl = 'Multiple Unit Discount';
        MixPriceDiscount_CaptionLbl = 'Mix Price Discount';
        UserDiscount_CaptionLbl = 'User Discount';
        TotalDiscount_CaptionLbl = 'Total Discount';
        PaymentTypePayOut_CaptionLbl = 'Payment Type/Pay Out:';
        PaymentType_CaptionLbl = 'Payment Type:';
        AmtInAuditRoll_CaptionLbl = 'Amount in Audit Roll';
        PayOut_CaptionLbl = 'Pay Out:';
        PayOutInAuditRoll_CaptionLbl = 'Pay Out in Audit Roll';
        Name_CaptionLbl = 'Name';
        NoTransactions_CaptionLbl = 'No. of transactions';
        AmtInclVAT_CaptionLbl = 'Amount Including VAT';
        CountUnit_CaptionLbl = 'Count Unit:';
        Qty_CaptionLbl = 'Qty.:';
        Total_CaptionLbl = 'Total:';
        UnitLbl = 'Unit';
        NoLbl = 'Qty';
        TotalLbl = 'Total';
        TotalCaseLbl = 'Total %1';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        DebitSale := 0;
    end;

    var
        CompanyInformation: Record "Company Information";
        AuditRoll1: Record "NPR Audit Roll";
        AuditRollCalc1: Record "NPR Audit Roll";
        AuditRollCalc2: Record "NPR Audit Roll";
        AuditRollCreditVoucher: Record "NPR Audit Roll";
        GlobalPeriod: Record "NPR Period";
        Register: Record "NPR Register";
        RegisterLast: Record "NPR Register";
        RetailSetup: Record "NPR Retail Setup";
        Calc: Boolean;
        FromTicket: Code[20];
        LastTicketNo: Code[20];
        ToTicket: Code[20];
        Sidstebon: Code[30];
        CodeConvert: Code[50];
        BalanceNeg: Decimal;
        BalancePos: Decimal;
        CampaignDiscount: Decimal;
        CampaignDiscountPct: Decimal;
        CashDifference: Decimal;
        CountTotalOut: array[15] of Decimal;
        CountUnitsOut: array[15] of Decimal;
        CoverageAmt: Decimal;
        CreditCardBalance: Decimal;
        CreditCardBalanceNeg: Decimal;
        CreditMovement: Decimal;
        CreditMovementNeg: Decimal;
        CreditVoucherIn: Decimal;
        CreditVoucherMovement: Decimal;
        CreditVoucherOut: Decimal;
        CustomerDeposits: Decimal;
        DebitSale: Decimal;
        GiftVoucherMovement: Decimal;
        GiftVoucherMovementNeg: Decimal;
        GrossTurnover: Decimal;
        ItemCost: Decimal;
        ManualDiscount: Decimal;
        ManualDiscountPct: Decimal;
        MixDiscount: Decimal;
        MixDiscountPct: Decimal;
        MovementNeg: Decimal;
        MovementPos: Decimal;
        NetTurnover: Decimal;
        OpeningCash: Decimal;
        OtherCardNetChange: Decimal;
        OtherCardNetChangeNegative: Decimal;
        QuantityDiscount: Decimal;
        QuantityDiscountPct: Decimal;
        RegisterMovement: Decimal;
        RegisterMovementNeg: Decimal;
        ReturnAmountTotal: Decimal;
        TerminalCardMovement: Decimal;
        TerminalCardMovementNeg: Decimal;
        TotalDiscount: Decimal;
        TotalDiscountPct: Decimal;
        TransferToBank: Decimal;
        UnknownCCMovement: Decimal;
        UnknownCCMovementNeg: Decimal;
        Ekspeditionstaeller: Integer;
        EndPos: Integer;
        i: Integer;
        NumCount: Integer;
        ReturnTicketTotal: Integer;
        StartPos: Integer;
        Text10600004: Label 'Debit Sales';
        Text10600005: Label 'Payments';
        Text10600002: Label 'Register filter:';
        Text10600001: Label 'Register Report (overall)';
        Text10600000: Label 'Register Report (per register)';
        Text10600006: Label 'Withdrawals';
        RegisterFilterText: Text[50];
        RegisterReportText: Text[50];
        Closetime: Time;
        Opentime: Time;

    procedure BalanceUpdate(Amt: Decimal; Pos: Boolean)
    begin
        if Pos then
            MovementPos := MovementPos + Amt
        else
            MovementNeg := MovementNeg + Amt;
    end;

    procedure GetCountAmount(BalanceAmountText: Text[200])
    var
        BPos: Integer;
        CntPnt: Integer;
        EPos: Integer;
        NpkCountUnits: Text[200];
        Tmp2: array[30] of Text[250];
    begin
        i := 1;
        EPos := 1;
        BPos := 1;
        Clear(CountTotalOut);
        Clear(CountUnitsOut);

        NpkCountUnits := RetailSetup."Register Cnt. Units";

        while EPos <> 0 do begin
            EPos := StrPos(NpkCountUnits, ':');
            if EPos <> 0 then begin
                NpkCountUnits[EPos] := '@';
                Tmp2[i] := CopyStr(NpkCountUnits, BPos, EPos - BPos);
            end;
            if (EPos = 0) then
                Tmp2[i] := CopyStr(NpkCountUnits, BPos, StrLen(NpkCountUnits) - BPos + 1);
            BPos := EPos + 1;
            i += 1;
        end;

        CntPnt := i;
        EPos := 1;
        BPos := 1;

        while EPos <> 0 do begin
            EPos := StrPos(BalanceAmountText, ';');
            if EPos <> 0 then begin
                BalanceAmountText[EPos] := '@';
                Tmp2[i] := CopyStr(BalanceAmountText, BPos, EPos - BPos);
            end;
            BPos := EPos + 1;
            i += 1;
            if i > 29 then
                EPos := 0;
        end;

        for i := 1 to 15 do begin
            if not Evaluate(CountUnitsOut[i], Tmp2[i]) then
                CountUnitsOut[i] := 0;
            if not Evaluate(CountTotalOut[i], Tmp2[28 - i]) then
                CountTotalOut[i] := 0;
        end;

        for i := 1 to 15 do begin
            if CountUnitsOut[i] <> 0 then
                CountTotalOut[i] := CountTotalOut[i] / CountUnitsOut[i]
            else
                CountTotalOut[i] := 0;
        end;
    end;
}

