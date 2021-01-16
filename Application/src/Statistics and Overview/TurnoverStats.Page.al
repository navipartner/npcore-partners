page 6014483 "NPR Turnover Stats"
{
    // NPR7.000.000    23.01.2013    TS    : This code was on the control's OnFormat Trigger.
    // NPR4.12/JDH/20150702 CASE 217884 Changed Caption to avoid confusion
    // NPR4.12/JDH/20150702 CASE 217885 Changed Caption to avoid confusion
    // NPR4.14/BHR/20150812 CASE 220173 Set property of page InsertAllowed=no deleteAllowed=0
    // NPR5.30/TJ /20170215 CASE 265504 Changed ENU captions on actions with word Register in their name
    // NPR5.35/TJ /20170816 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                  Removed unused variables
    // NPR5.40/BHR /20180316 CASE 308385 Removed unused function CallSub
    // NPR5.53/ALPO/20191024 CASE 371955 Rounding related fields moved to POS Posting Profiles
    // NPR5.55/YAHA/20200717 CASE 414769 Adding Date Filter

    UsageCategory = None;
    Caption = 'Turnover';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR Sale POS";

    layout
    {
        area(content)
        {
            field(DepartmentFilter; DepartmentFilter)
            {
                ApplicationArea = All;
                Caption = 'Depertment Filter';
                TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
                ToolTip = 'Specifies the value of the Depertment Filter field';

                trigger OnValidate()
                var
                    "Filter": Code[30];
                begin
                    RetailSetup.Get;
                    if RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER" then
                        Filter := StrSubstNo('=%1', RegisterNo2);
                    //-NPR5.55 [414769]
                    //TurnoverStatistics(Filter);
                    TurnoverStatistics(Filter, StartDate, EndDate);
                    //+NPR5.55 [414769]
                    CurrPage.sub1.PAGE.SetDeptFilter(DepartmentFilter);
                    CurrPage.Update(true);
                end;
            }
            field("Start Date"; StartDate)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the StartDate field';

                trigger OnValidate()
                var
                    "Filter": Code[30];
                begin
                    //-NPR5.55 [414769]
                    RetailSetup.Get;
                    if RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER" then
                        Filter := StrSubstNo('=%1', RegisterNo2);
                    TurnoverStatistics(Filter, StartDate, EndDate);
                    //CurrPage.sub1.PAGE.SetDateFilter(TRUE);
                    CurrPage.Update(true);
                    //+NPR5.55 [414769]
                end;
            }
            field("End Date"; EndDate)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the EndDate field';

                trigger OnValidate()
                var
                    "Filter": Code[30];
                begin
                    //-NPR5.55 [414769]
                    RetailSetup.Get;
                    if RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER" then
                        Filter := StrSubstNo('=%1', RegisterNo2);
                    TurnoverStatistics(Filter, StartDate, EndDate);
                    //CurrPage.sub1.PAGE.SetDateFilter(TRUE);
                    CurrPage.Update(true);
                    //+NPR5.55 [414769]
                end;
            }
            group("Audit Roll")
            {
                Caption = 'Audit Roll';
                grid(Control6150616)
                {
                    ShowCaption = false;
                    group(Control6150636)
                    {
                        ShowCaption = false;
                        field(RegisterNo; RegisterNo)
                        {
                            ApplicationArea = All;
                            Caption = 'Register No.';
                            ToolTip = 'Specifies the value of the Register No. field';

                            trigger OnValidate()
                            begin
                                //+TS
                                /*
                               IF Statistikmenu = Statistikmenu::Omsætning THEN
                                 IF Opsætning.Balancing = Opsætning.Balancing::SAMLET THEN
                                   Text := KasseText;
                               */
                                //-TS

                            end;
                        }
                        field(SaleAmount; SaleAmount)
                        {
                            ApplicationArea = All;
                            Caption = 'Cash Sale';
                            ToolTip = 'Specifies the value of the Cash Sale field';
                        }
                        field(DebitSaleAmt; DebitSaleAmt)
                        {
                            ApplicationArea = All;
                            Caption = 'Debit Sale';
                            ToolTip = 'Specifies the value of the Debit Sale field';
                        }
                        field(CreditedSaleAmount; CreditedSaleAmount)
                        {
                            ApplicationArea = All;
                            Caption = 'Credited Sale';
                            ToolTip = 'Specifies the value of the Credited Sale field';
                        }
                        field(GiftVoucherAmount; GiftVoucherAmount)
                        {
                            ApplicationArea = All;
                            Caption = 'Gift Voucher';
                            ToolTip = 'Specifies the value of the Gift Voucher field';
                        }
                        field(CreditVoucherAmount; CreditVoucherAmount)
                        {
                            ApplicationArea = All;
                            Caption = 'Credit Voucher';
                            ToolTip = 'Specifies the value of the Credit Voucher field';
                        }
                        field(TotalAmount; TotalAmount)
                        {
                            ApplicationArea = All;
                            Caption = 'Total';
                            ToolTip = 'Specifies the value of the Total field';
                        }
                        field("SaleAmount + CreditedSaleAmount + DebitSaleAmt"; SaleAmount + CreditedSaleAmount + DebitSaleAmt)
                        {
                            ApplicationArea = All;
                            Caption = 'Revenue';
                            ToolTip = 'Specifies the value of the Revenue field';
                        }
                        field(AuditRollNoOfSales; AuditRollNoOfSales)
                        {
                            ApplicationArea = All;
                            Caption = 'No. of Sales';
                            ToolTip = 'Specifies the value of the No. of Sales field';
                        }
                        field(AuditRollAverageSaleAmt; AuditRollAverageSaleAmt)
                        {
                            ApplicationArea = All;
                            Caption = 'Average Sales';
                            ToolTip = 'Specifies the value of the Average Sales field';
                        }
                    }
                }
                group(Control6150627)
                {
                    ShowCaption = false;
                    field(DebitProfitAmount; DebitProfitAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Debit Sale CM';
                        ToolTip = 'Specifies the value of the Debit Sale CM field';
                    }
                    field(DebitProfitPct; DebitProfitPct)
                    {
                        ApplicationArea = All;
                        Caption = 'Debit CM %';
                        ToolTip = 'Specifies the value of the Debit CM % field';
                    }
                    field(PaymentAmount; PaymentAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Payment';
                        ToolTip = 'Specifies the value of the Payment field';
                    }
                    field(PayoutAmount; PayoutAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Payout';
                        ToolTip = 'Specifies the value of the Payout field';
                    }
                    field(ProfitAmount; ProfitAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Profit (LCY)';
                        ToolTip = 'Specifies the value of the Profit (LCY) field';
                    }
                    field(ProfitPct; ProfitPct)
                    {
                        ApplicationArea = All;
                        Caption = 'Profit (%)';
                        ToolTip = 'Specifies the value of the Profit (%) field';
                    }
                }
            }
            part(sub1; "NPR Turnover Statistics")
            {
                Caption = 'Turnover Statistics';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Select1)
            {
                Caption = 'Select 1';
                action("Local Register")
                {
                    Caption = '&Local Cash Register';
                    Image = Register;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Local Cash Register action';

                    trigger OnAction()
                    var
                        "Filter": Text[250];
                    begin
                        Filter := StrSubstNo('=%1', RegisterNo2);
                        //-NPR5.55 [414769]
                        //TurnoverStatistics(Filter);
                        TurnoverStatistics(Filter, StartDate, EndDate);
                        //+NPR5.55 [414769]
                        CurrPage.Update(true);
                    end;
                }
                action("Select register")
                {
                    Caption = 'Select Cash Register';
                    Image = SelectField;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+F9';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Select Cash Register action';

                    trigger OnAction()
                    var
                        Register: Record "NPR Register";
                        RegisterList: Page "NPR Register List";
                    begin
                        RegisterList.LookupMode(true);
                        if not (RegisterList.RunModal = ACTION::LookupOK) then
                            exit;
                        RegisterList.GetRecord(Register);
                        //-NPR5.55 [414769]
                        //TurnoverStatistics(STRSUBSTNO('=%1',Register."Register No."));
                        TurnoverStatistics(StrSubstNo('=%1', Register."Register No."), StartDate, EndDate);
                        //+NPR5.55 [414769]
                    end;
                }
                action("All Registers")
                {
                    Caption = 'All Cash Registers';
                    Image = Register;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+F8';
                    ApplicationArea = All;
                    ToolTip = 'Executes the All Cash Registers action';

                    trigger OnAction()
                    begin
                        //-NPR5.55 [414769]
                        //TurnoverStatistics('');
                        TurnoverStatistics('', StartDate, EndDate);
                        //+NPR5.55 [414769]
                    end;
                }
            }
        }
    }

    trigger OnInit()
    begin
        OnInit1;
        SetType(1);

        CurrPage.sub1.PAGE.Init;
        //CurrForm.Kassenummer.ACTIVATE;

        //CurrForm.tsCloseform.VISIBLE(tsmode);
    end;

    var
        TurnoverCaption: Label 'Turnover report';
        RetailSetup: Record "NPR Retail Setup";
        RetailContractSetup: Record "NPR Retail Contr. Setup";
        RetailFormCode: Codeunit "NPR Retail Form Code";
        InsuranceCompanyCode: Code[50];
        RegisterNo: Code[20];
        DepartmentFilter: Text[250];
        DebitSaleAmt: Decimal;
        PayoutAmount: Decimal;
        PaymentAmount: Decimal;
        SaleAmount: Decimal;
        TotalAmount: Decimal;
        GiftVoucherAmount: Decimal;
        CreditVoucherAmount: Decimal;
        CreditedSaleAmount: Decimal;
        ProfitAmount: Decimal;
        ProfitPct: Decimal;
        DebitProfitAmount: Decimal;
        DebitProfitPct: Decimal;
        AuditRollAverageSaleAmt: Decimal;
        AuditRollNoOfSales: Integer;
        StatisticType: Option Sale,Turnover;
        Utility: Codeunit "NPR Utility";
        SaleDate: Date;
        RegisterNo2: Code[10];
        TSMode: Boolean;
        DateFilter2: Text;
        StartDate: Date;
        EndDate: Date;

    procedure SetType(No: Integer)
    begin
        //AktiverMenu
        StatisticType := No;

        //CurrForm.Afdelingsfilter.VISIBLE( "Nr." = Statistikmenu::Omsætning );

        RetailSetup.Get;
        if RetailSetup."Internal Dept. Code" <> '' then
            DepartmentFilter := StrSubstNo('<>%1', RetailSetup."Internal Dept. Code");
        //CurrForm.CAPTION("Oms. Caption");
    end;

    procedure TurnoverStatistics(RegisterFilter: Text[250]; StartDateFilter: Date; EndDateFilter: Date)
    var
        AuditRoll: Record "NPR Audit Roll";
        TotalCost: Decimal;
        TotalNetAmt: Decimal;
        Register: Record "NPR Register";
        Txt001: Label 'All registers';
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        //TurnoverStatistics

        //-NPR5.55 [414769]
        //IF SaleDate = 0D THEN
        //  SaleDate := TODAY;

        if EndDateFilter = 0D then
            EndDateFilter := Today;
        //+NPR5.55 [414769]

        IF StartDateFilter = 0D THEN
            StartDateFilter := TODAY;



        if RegisterFilter = '' then
            RegisterNo := Txt001
        else
            RegisterNo := CopyStr(RegisterFilter, 2, StrLen(RegisterFilter) - 1);

        RetailSetup.Get;
        AuditRoll.SetCurrentKey("Register No.", "Sale Date", "Sale Type", Type, Quantity);
        AuditRoll.SetFilter("Register No.", RegisterFilter);
        //-NPR5.55 [414769]
        //AuditRoll.SETRANGE("Sale Date",SaleDate);
        AuditRoll.SetFilter("Sale Date", '%1..%2', StartDateFilter, EndDateFilter);
        //+NPR5.55 [414769]

        if DepartmentFilter <> '' then
            AuditRoll.SetFilter("Shortcut Dimension 1 Code", DepartmentFilter)
        else
            AuditRoll.SetRange("Shortcut Dimension 1 Code");

        TotalCost := 0;
        TotalNetAmt := 0;

        // Salg
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.SetFilter(Quantity, '>0');
        AuditRoll.CalcSums("Amount Including VAT");
        SaleAmount := AuditRoll."Amount Including VAT";
        AuditRoll.SetRange(Quantity);

        AuditRoll.SetCurrentKey("Register No.", "Sale Date", "Sale Type", Type, Quantity, "Receipt Type");
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.SetFilter(Quantity, '<0');
        AuditRoll.SetRange("Receipt Type", AuditRoll."Receipt Type"::"Negative receipt");
        AuditRoll.CalcSums("Amount Including VAT");
        CreditedSaleAmount := AuditRoll."Amount Including VAT";
        AuditRoll.SetRange("Receipt Type", AuditRoll."Receipt Type"::"Return items");
        AuditRoll.CalcSums("Amount Including VAT");
        SaleAmount += AuditRoll."Amount Including VAT";
        AuditRoll.SetCurrentKey("Register No.", "Sale Date", "Sale Type", Type, Quantity);
        AuditRoll.SetRange("Receipt Type");
        AuditRoll.SetRange(Quantity);

        AuditRoll.SetCurrentKey("Register No.", "Sale Date", "Sale Type", Type);
        AuditRoll.CalcSums(Amount);
        AuditRoll.CalcSums(Cost);
        TotalNetAmt += AuditRoll.Amount;
        TotalCost += AuditRoll.Cost;

        //Samlet debetsalg
        AuditRoll.SetCurrentKey("Sale Date", "Sale Type", Type, "Gift voucher ref.", "Register No.");
        // Revisionsrulle.SETRANGE( "Sale Type", Revisionsrulle."Sale Type"::Bemærkning );
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::"Debit Sale");
        AuditRoll.SetRange("Gift voucher ref.", '');
        AuditRoll.CalcSums("Amount Including VAT");
        AuditRoll.CalcSums(Amount);
        AuditRoll.CalcSums(Cost);
        DebitSaleAmt := AuditRoll."Amount Including VAT";
        DebitProfitAmount := AuditRoll.Amount - AuditRoll.Cost;
        if AuditRoll.Amount <> 0 then
            DebitProfitPct := DebitProfitAmount / AuditRoll.Amount * 100
        else
            DebitProfitPct := 0;

        // Gavekort + tilgodebevis
        // Udbetaling
        // Indbetaling

        AuditRoll.SetFilter("Gift voucher ref.", '<>%1', '');
        AuditRoll.CalcSums("Amount Including VAT");
        GiftVoucherAmount := AuditRoll."Amount Including VAT";
        AuditRoll.SetRange("Gift voucher ref.");

        // Total
        AuditRoll.SetCurrentKey("Register No.", "Sale Type", Type, "No.", "Sale Date");
        if not Register.Get(RegisterNo2) then
            Register.Find('-');
        //-NPR5.53 [371955]
        POSUnit.Get(Register."Register No.");
        POSSetup.SetPOSUnit(POSUnit);
        //+NPR5.53 [371955]

        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Deposit);
        AuditRoll.SetRange(Type, AuditRoll.Type::"G/L");
        AuditRoll.SetRange("No.", Register."Gift Voucher Account");


        AuditRoll.CalcSums(AuditRoll."Amount Including VAT");
        GiftVoucherAmount += AuditRoll."Amount Including VAT";
        AuditRoll.SetRange("No.", Register."Credit Voucher Account");
        AuditRoll.CalcSums(AuditRoll."Amount Including VAT");
        CreditVoucherAmount := AuditRoll."Amount Including VAT";
        AuditRoll.SetRange("No.");

        // Udbetaling
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::"Out payment");
        AuditRoll.SetRange(Type, AuditRoll.Type::"G/L");
        //AuditRoll.SETFILTER("No.",'<>%1&<>%2',Register.Rounding,Register."Gift Voucher Discount Account");  //NPR5.53 [371955]-revoked
        AuditRoll.SetFilter("No.", '<>%1&<>%2', POSSetup.RoundingAccount(true), Register."Gift Voucher Discount Account");  //NPR5.53 [371955]
        AuditRoll.CalcSums(AuditRoll."Amount Including VAT");
        PayoutAmount := AuditRoll."Amount Including VAT";
        AuditRoll.SetRange("No.");

        // Indbetaling
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Deposit);
        AuditRoll.SetRange(Type, AuditRoll.Type::Customer);
        AuditRoll.CalcSums(AuditRoll."Amount Including VAT");
        PaymentAmount := AuditRoll."Amount Including VAT";

        // Total
        TotalAmount := SaleAmount + CreditedSaleAmount +
                               GiftVoucherAmount + CreditVoucherAmount +
                               DebitSaleAmt;

        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);

        ProfitAmount := TotalNetAmt - TotalCost;
        if TotalNetAmt <> 0 then
            ProfitPct := ProfitAmount / TotalNetAmt * 100
        else
            ProfitPct := 0;
        //-NPR5.55 [414769]
        //CalculateSaleLineNoAmount(RegisterFilter,SaleDate);
        CalculateSaleLineNoAmount(RegisterFilter, StartDateFilter, EndDateFilter);
        //+NPR5.55 [414769]
        StartDate := StartDateFilter;
        EndDate := EndDateFilter;
    end;

    procedure CalculateSaleLineNoAmount(RegisterFilter: Text[250]; StartDate: Date; EndDate: Date)
    var
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        //CalculateSaleLineNoAmount
        if RegisterFilter <> '' then
            PaymentTypePOS.SetFilter("Register Filter", RegisterFilter)
        else
            PaymentTypePOS.SetRange("Register Filter");
        //-NPR5.55 [414769]
        //IF CalculationDate <> 0D THEN
        //PaymentTypePOS.SETRANGE("Date Filter",CalculationDate)
        if (StartDate <> 0D) and (EndDate <> 0D) then
            PaymentTypePOS.SetFilter("Date Filter", '%1..%2', StartDate, EndDate)
        //+NPR5.55 [414769]
        else
            PaymentTypePOS.SetRange("Date Filter");

        PaymentTypePOS.CalcFields("No. of Sales in Audit Roll", "Normal Sale in Audit Roll", "No. of Deb. Sales in Aud. Roll",
          "Debit Sale in Audit Roll");
        AuditRollNoOfSales := PaymentTypePOS."No. of Sales in Audit Roll";
        AuditRollNoOfSales += PaymentTypePOS."No. of Deb. Sales in Aud. Roll";
        if AuditRollNoOfSales <> 0 then
            AuditRollAverageSaleAmt := (PaymentTypePOS."Normal Sale in Audit Roll" + PaymentTypePOS."Debit Sale in Audit Roll") / AuditRollNoOfSales
        else
            AuditRollAverageSaleAmt := 0;
    end;

    procedure OnInit1()
    var
        "Filter": Text[250];
    begin
        //OnInit
        if RetailContractSetup.Get then
            InsuranceCompanyCode := RetailContractSetup."Default Insurance Company";

        RegisterNo2 := RetailFormCode.FetchRegisterNumber;

        //CurrForm.Kassenummer.VISIBLE( TRUE );
        SetType(1);
        RetailSetup.Get;
        case RetailSetup."F9 Statistics When Login" of
            RetailSetup."F9 Statistics When Login"::"Show all registers":
                Filter := '';
            RetailSetup."F9 Statistics When Login"::"Show local register":
                Filter := StrSubstNo('=%1', RegisterNo2);
        end;
        //-NPR5.55 [414769]
        TurnoverStatistics(Filter, SaleDate, EndDate);
        //+NPR5.55 [414769]
    end;

    procedure GetTurnoverStats(var NPRTempBuffer: Record "NPR TEMP Buffer")
    var
        Txt001: Label 'Sale';
        Txt002: Label 'Return sale';
        Txt003: Label 'Gift voucher';
        Txt004: Label 'Credit voucher';
        Txt005: Label 'Debit sale';
        Txt006: Label 'Total';
        Txt007: Label 'Payment';
        Txt008: Label 'Outpayment';
        Txt009: Label 'Profit contribution';
        Txt010: Label 'Contribution ratio';
        i: Integer;
        j: Integer;
        Txt011: Label 'Number of sales total';
        Txt012: Label 'Number of sales (average)';
    begin
        // GetTurnoverStats

        i := 1;
        NPRTempBuffer.Init;
        NPRTempBuffer."Line No." := i;
        NPRTempBuffer.Description := TurnoverCaption;
        NPRTempBuffer.Bold := true;
        NPRTempBuffer.Sel := true;
        NPRTempBuffer.Insert;

        for j := 1 to 15 do begin
            i += 1;
            NPRTempBuffer.Init;
            NPRTempBuffer."Line No." := i;
            NPRTempBuffer.Bold := true;
            case j of
                1:
                    begin
                        NPRTempBuffer.Description := Txt001;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(SaleAmount, 2);
                    end;
                2:
                    begin
                        NPRTempBuffer.Description := Txt002;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(CreditedSaleAmount, 2);
                    end;
                3:
                    begin
                        NPRTempBuffer.Description := Txt003;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(GiftVoucherAmount, 2);
                    end;
                4:
                    begin
                        NPRTempBuffer.Description := Txt004;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(CreditVoucherAmount, 2);
                    end;
                5:
                    begin
                        NPRTempBuffer.Description := Txt005;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(DebitSaleAmt, 2);
                    end;
                6:
                    begin
                        NPRTempBuffer.Description := Txt006;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(TotalAmount, 2);
                        NPRTempBuffer.Bold := true;
                        NPRTempBuffer."Bold 2" := true;
                    end;
                7:
                    begin
                        NPRTempBuffer.Description := Txt007;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(PaymentAmount, 2);
                    end;
                8:
                    begin
                        NPRTempBuffer.Description := Txt008;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(PayoutAmount, 2);
                    end;
                9:
                    begin
                        NPRTempBuffer.Description := Txt009;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(ProfitAmount, 2);
                    end;
                10:
                    begin
                        NPRTempBuffer.Description := Txt010;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(ProfitPct, 3);
                    end;
                11:
                    begin
                        NPRTempBuffer.Description := Txt011;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(AuditRollNoOfSales, 0);
                    end;
                12:
                    begin
                        NPRTempBuffer.Description := Txt012;
                        NPRTempBuffer."Description 2" := Utility.FormatDec2Text(AuditRollAverageSaleAmt, 2);
                    end;
            end;
            NPRTempBuffer.Insert;
        end;
    end;

    procedure SetTSMode(TSMode1: Boolean)
    begin
        //SetTSmode
        TSMode := TSMode1;
    end;
}

