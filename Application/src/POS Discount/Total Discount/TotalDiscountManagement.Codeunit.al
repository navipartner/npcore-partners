codeunit 6151077 "NPR Total Discount Management"
{
    Access = Internal;
    procedure GetNoSeries(): Code[20]
    var
        DiscountPriority: Record "NPR Discount Priority";
        NoSeriesCodeTok: Label 'TOTAL-DISC', Locked = true;
        NoSeriesDescriptionTok: Label 'Total Discount No. Series';
    begin
        GetOrInit(DiscountPriority);
        if DiscountPriority."Discount No. Series" = '' then // if not initialized via upgrade codeunit
            DiscountPriority.CreateNoSeries(NoSeriesCodeTok, NoSeriesDescriptionTok, false);

        exit(DiscountPriority."Discount No. Series");
    end;

    procedure GetOrInit(var DiscountPriority: Record "NPR Discount Priority")
    begin
        if DiscountPriority.Get(DiscSourceTableId()) then
            exit;

        DiscountPriority.Init();
        DiscountPriority."Table ID" := DiscSourceTableId();
        DiscountPriority.Priority := GetLowestDiscountPriority() + 1;
        DiscountPriority.Disabled := false;
        DiscountPriority."Discount Calc. Codeunit ID" := DiscCalcCodeunitId();
        DiscountPriority."Cross Line Calculation" := true;
        DiscountPriority.Insert(true);
    end;

    local procedure GetLowestDiscountPriority() LowestDiscountPriority: Integer;
    var
        DiscountPriority: Record "NPR Discount Priority";
    begin
        DiscountPriority.Reset();
        DiscountPriority.SetCurrentKey(Priority);
        DiscountPriority.SetLoadFields(Priority);
        if not DiscountPriority.FindLast() then
            exit;

        LowestDiscountPriority := DiscountPriority.Priority;
    end;

    internal procedure DiscSourceTableId(): Integer
    begin
        exit(DATABASE::"NPR Total Discount Header");
    end;

    local procedure DiscCalcCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Total Discount Management");
    end;

    local procedure TotalDiscountActiveNow(var NPRTotalDiscountHeader: Record "NPR Total Discount Header") Active: Boolean
    begin

        if NPRTotalDiscountHeader.Status <> NPRTotalDiscountHeader.Status::Active then
            exit;

        if NPRTotalDiscountHeader."Starting date" = 0D then
            exit;

        if NPRTotalDiscountHeader."Ending date" = 0D then
            exit;

        if NPRTotalDiscountHeader."Starting date" > Today then
            exit;

        if NPRTotalDiscountHeader."Ending date" < Today then
            exit;

        if (NPRTotalDiscountHeader."Starting date" = Today) and
           (NPRTotalDiscountHeader."Starting time" > Time)
        then
            exit;

        if (NPRTotalDiscountHeader."Ending date" = Today) and
           (NPRTotalDiscountHeader."Ending time" < Time) and
           (NPRTotalDiscountHeader."Ending time" <> 0T)
        then
            exit;

        Active := HasActiveTimeInterval(NPRTotalDiscountHeader);

    end;

    local procedure HasActiveTimeInterval(NPRTotalDiscountHeader: Record "NPR Total Discount Header") HasActiveInterval: Boolean
    var
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
    begin
        NPRTotalDiscTimeInterv.Reset();
        NPRTotalDiscTimeInterv.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);

        HasActiveInterval := not NPRTotalDiscTimeInterv.FindSet(false);
        if HasActiveInterval then
            exit;

        repeat
            HasActiveInterval := IsActiveTimeInterval(NPRTotalDiscTimeInterv, Time, Today);
        until (NPRTotalDiscTimeInterv.Next() = 0) or
              HasActiveInterval;

    end;


    local procedure IsActiveTimeInterval(NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
                                         CheckTime: Time;
                                         CheckDate: Date): Boolean
    begin
        if not IsActiveDay(NPRTotalDiscTimeInterv,
                           CheckDate)
        then
            exit(false);

        if (NPRTotalDiscTimeInterv."Start Time" = 0T) and
           (NPRTotalDiscTimeInterv."End Time" = 0T)
        then
            exit(true);

        if (NPRTotalDiscTimeInterv."Start Time" <= NPRTotalDiscTimeInterv."End Time") or
           (NPRTotalDiscTimeInterv."End Time" = 0T)
        then begin
            if CheckTime < NPRTotalDiscTimeInterv."Start Time" then
                exit(false);

            if NPRTotalDiscTimeInterv."End Time" = 0T then
                exit(true);

            exit(CheckTime <= NPRTotalDiscTimeInterv."End Time");
        end;

        exit((CheckTime >= NPRTotalDiscTimeInterv."Start Time") or
             (CheckTime <= NPRTotalDiscTimeInterv."End Time"));
    end;

    local procedure IsActiveDay(NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
                                CheckDate: Date) ActiveDay: Boolean
    begin
        ActiveDay := NPRTotalDiscTimeInterv."Period Type" = NPRTotalDiscTimeInterv."Period Type"::"Every Day";
        if ActiveDay then
            exit;

        case Date2DWY(CheckDate, 1) of
            1:
                ActiveDay := NPRTotalDiscTimeInterv.Monday;
            2:
                ActiveDay := NPRTotalDiscTimeInterv.Tuesday;
            3:
                ActiveDay := NPRTotalDiscTimeInterv.Wednesday;
            4:
                ActiveDay := NPRTotalDiscTimeInterv.Thursday;
            5:
                ActiveDay := NPRTotalDiscTimeInterv.Friday;
            6:
                ActiveDay := NPRTotalDiscTimeInterv.Saturday;
            7:
                ActiveDay := NPRTotalDiscTimeInterv.Sunday;
        end;
    end;

    local procedure IsSubscribedDiscount(DiscountPriority: Record "NPR Discount Priority") IsSubscribed: Boolean
    begin
        if DiscountPriority.Disabled then
            exit;

        if DiscountPriority."Table ID" <> DiscSourceTableId() then
            exit;

        if (DiscountPriority."Discount Calc. Codeunit ID" <> 0) and
           (DiscountPriority."Discount Calc. Codeunit ID" <> DiscCalcCodeunitId())
        then
            exit;

        IsSubscribed := true;
    end;

    local procedure FindActiveTotalDiscount(var TempNPRTotalDiscountHeader: Record "NPR Total Discount Header" temporary;
                                            SalePOS: Record "NPR POS Sale";
                                            var TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                            var TempTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                            var TempNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit" temporary;
                                            var TotalDiscountSalesAmount: Decimal;
                                            CalculationDate: Date) Found: Boolean;
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        TempTotalDiscountSalesAmountLinePOS: Record "NPR POS Sale Line" temporary;
    begin
        TotalDiscountSalesAmount := 0;

        TempNPRTotalDiscountHeader.Reset();
        if not TempNPRTotalDiscountHeader.IsEmpty then
            TempNPRTotalDiscountHeader.DeleteAll();

        FilterActiveTotalDiscountHeaders(NPRTotalDiscountHeader,
                                         CalculationDate);

        if not NPRTotalDiscountHeader.FindSet() then
            exit;

        repeat
            if TotalDiscountIsActive(NPRTotalDiscountHeader,
                                     SalePOS)
            then begin
                CalcTotalDiscountSalesAmount(NPRTotalDiscountHeader,
                                             TempSaleLinePOS,
                                             TempTotalDiscountSalesAmountLinePOS,
                                             TotalDiscountSalesAmount);

                GetTotalDiscountApplicatonPOSSaleLines(NPRTotalDiscountHeader,
                                                       TempSaleLinePOS,
                                                       TempTotalDiscountSaleLinePOS);

                Found := GetTotalDiscountBenefits(NPRTotalDiscountHeader,
                                                  TotalDiscountSalesAmount,
                                                  TempNPRTotalDiscountBenefit);
                if Found then
                    if not TempNPRTotalDiscountHeader.Get(NPRTotalDiscountHeader.RecordId) then begin
                        TempNPRTotalDiscountHeader.Init();
                        TempNPRTotalDiscountHeader := NPRTotalDiscountHeader;
                        TempNPRTotalDiscountHeader.Insert();
                    end;
            end;
        until (NPRTotalDiscountHeader.Next() = 0) or
               Found;
    end;

    local procedure GetTotalDiscountBenefits(NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                             TotalDiscountSaleAmount: Decimal;
                                             var TempNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit" temporary) Found: Boolean;
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
    begin
        TempNPRTotalDiscountBenefit.Reset();
        if not TempNPRTotalDiscountBenefit.IsEmpty then
            TempNPRTotalDiscountBenefit.DeleteAll();

        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetCurrentKey("Step Amount", Type);
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        NPRTotalDiscountBenefit.SetFilter("Step Amount", '<=%1', TotalDiscountSaleAmount);
        if not NPRTotalDiscountBenefit.FindLast() then
            exit;

        NPRTotalDiscountBenefit.SetRange("Step Amount", NPRTotalDiscountBenefit."Step Amount");
        if not NPRTotalDiscountBenefit.FindSet(false) then
            exit;

        repeat
            TempNPRTotalDiscountBenefit.Init();
            TempNPRTotalDiscountBenefit := NPRTotalDiscountBenefit;
            TempNPRTotalDiscountBenefit.Insert();
        until NPRTotalDiscountBenefit.Next() = 0;

        Found := true;
    end;

    local procedure CalcTotalDiscountSalesAmount(NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                                 var TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                                 var TempTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                                 var TotalDiscountSalesAmount: Decimal);
    begin
        GetTotalDiscountAmountCalculationPOSSaleLines(NPRTotalDiscountHeader,
                                                      TempSaleLinePOS,
                                                      TempTotalDiscountSaleLinePOS);

        TempTotalDiscountSaleLinePOS.CalcSums("Amount Including VAT");
        TotalDiscountSalesAmount := TempTotalDiscountSaleLinePOS."Amount Including VAT";
    end;

    local procedure GetTotalDiscountAmountCalculationPOSSaleLines(NPRTotalDiscountHeader: Record "NPR Total Discount Header"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var TempTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        TempCalcTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary;
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        Found: Boolean;
    begin
        TempTotalDiscountSaleLinePOS.Reset();
        if not TempTotalDiscountSaleLinePOS.IsEmpty then
            TempTotalDiscountSaleLinePOS.DeleteAll();

        CopySaleLinesPOS(TempSaleLinePOS, TempCalcTotalDiscountSaleLinePOS, true);

        case NPRTotalDiscountHeader."Step Amount Calculation" of
            NPRTotalDiscountHeader."Step Amount Calculation"::"No Filters":
                begin
                    TempCalcTotalDiscountSaleLinePOS.Reset();
                    TempCalcTotalDiscountSaleLinePOS.SetRange("Benefit Item", false);
                    TempCalcTotalDiscountSaleLinePOS.SetRange("Shipment Fee", false);
                    CopySaleLinesPOS(TempCalcTotalDiscountSaleLinePOS, TempTotalDiscountSaleLinePOS, true);
                end;
            NPRTotalDiscountHeader."Step Amount Calculation"::"Discount Filters":
                begin
                    NPRTotalDiscountLine.Reset();
                    NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
                    if NPRTotalDiscountLine.IsEmpty then
                        exit;

                    NPRTotalDiscountLine.Reset();
                    NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
                    NPRTotalDiscountLine.SetRange(Type, NPRTotalDiscountLine.Type::All);
                    if not NPRTotalDiscountLine.IsEmpty then begin
                        TempCalcTotalDiscountSaleLinePOS.Reset();
                        TempCalcTotalDiscountSaleLinePOS.SetRange("Benefit Item", false);
                        TempCalcTotalDiscountSaleLinePOS.SetRange("Shipment Fee", false);
                        CopySaleLinesPOS(TempCalcTotalDiscountSaleLinePOS, TempTotalDiscountSaleLinePOS, true);
                        exit;
                    end;

                    TempCalcTotalDiscountSaleLinePOS.Reset();
                    TempCalcTotalDiscountSaleLinePOS.SetRange("Benefit Item", false);
                    TempCalcTotalDiscountSaleLinePOS.SetRange("Shipment Fee", false);
                    if TempCalcTotalDiscountSaleLinePOS.FindSet(false) then
                        repeat
                            NPRTotalDiscountLine.Reset();
                            NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
                            NPRTotalDiscountLine.SetRange(Type, NPRTotalDiscountLine.Type::Item);
                            NPRTotalDiscountLine.SetRange("No.", TempCalcTotalDiscountSaleLinePOS."No.");
                            NPRTotalDiscountLine.SetFilter("Variant Code", '%1|%2', '', TempCalcTotalDiscountSaleLinePOS."Variant Code");
                            NPRTotalDiscountLine.SetFilter("Unit Of Measure Code", '%1|%2', '', TempCalcTotalDiscountSaleLinePOS."Unit of Measure Code");
                            Found := not NPRTotalDiscountLine.IsEmpty;
                            if not Found then begin
                                NPRTotalDiscountLine.SetRange("Variant Code");
                                NPRTotalDiscountLine.SetRange("Unit Of Measure Code");
                                NPRTotalDiscountLine.SetRange(Type, NPRTotalDiscountLine.Type::"Item Category");
                                NPRTotalDiscountLine.SetRange("No.", TempCalcTotalDiscountSaleLinePOS."Item Category Code");
                                Found := not NPRTotalDiscountLine.IsEmpty;
                            end;
                            if not Found then begin
                                NPRTotalDiscountLine.SetRange("Variant Code");
                                NPRTotalDiscountLine.SetRange("Unit Of Measure Code");
                                NPRTotalDiscountLine.SetRange(Type, NPRTotalDiscountLine.Type::Vendor);
                                NPRTotalDiscountLine.SetRange("No.", TempCalcTotalDiscountSaleLinePOS."Vendor No.");
                                Found := not NPRTotalDiscountLine.IsEmpty;
                            end;
                            if Found then
                                CopySaleLinePOS(TempCalcTotalDiscountSaleLinePOS, TempTotalDiscountSaleLinePOS);

                        until TempCalcTotalDiscountSaleLinePOS.Next() = 0;
                end;
        end;
        Clear(TempTotalDiscountSaleLinePOS);
    end;

    local procedure GetTotalDiscountApplicatonPOSSaleLines(NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                                           var TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                                           var TempTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        TempCalcTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary;
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        Found: Boolean;
    begin
        TempTotalDiscountSaleLinePOS.Reset();
        if not TempTotalDiscountSaleLinePOS.IsEmpty then
            TempTotalDiscountSaleLinePOS.DeleteAll();

        CopySaleLinesPOSWithCalculation(TempSaleLinePOS,
                                        TempCalcTotalDiscountSaleLinePOS,
                                        true);

        case NPRTotalDiscountHeader."Discount Application" of
            NPRTotalDiscountHeader."Discount Application"::"No Filters":
                begin
                    CopySaleLinesPOSWithCalculation(TempCalcTotalDiscountSaleLinePOS,
                                                    TempTotalDiscountSaleLinePOS,
                                                    false);
                end;
            NPRTotalDiscountHeader."Discount Application"::"Discount Filters":
                begin
                    NPRTotalDiscountLine.Reset();
                    NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
                    if NPRTotalDiscountLine.IsEmpty then
                        exit;

                    NPRTotalDiscountLine.Reset();
                    NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
                    NPRTotalDiscountLine.SetRange(Type, NPRTotalDiscountLine.Type::All);
                    if not NPRTotalDiscountLine.IsEmpty then begin
                        CopySaleLinesPOSWithCalculation(TempCalcTotalDiscountSaleLinePOS, TempTotalDiscountSaleLinePOS, false);
                        exit;
                    end;

                    TempCalcTotalDiscountSaleLinePOS.Reset();
                    TempCalcTotalDiscountSaleLinePOS.SetRange("Benefit Item", false);
                    TempCalcTotalDiscountSaleLinePOS.SetRange("Shipment Fee", false);
                    if TempCalcTotalDiscountSaleLinePOS.FindSet(false) then
                        repeat
                            NPRTotalDiscountLine.Reset();
                            NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
                            NPRTotalDiscountLine.SetRange(Type, NPRTotalDiscountLine.Type::Item);
                            NPRTotalDiscountLine.SetRange("No.", TempCalcTotalDiscountSaleLinePOS."No.");
                            NPRTotalDiscountLine.SetFilter("Variant Code", '%1|%2', TempCalcTotalDiscountSaleLinePOS."Variant Code", '');
                            NPRTotalDiscountLine.SetFilter("Unit Of Measure Code", '%1|%2', TempCalcTotalDiscountSaleLinePOS."Unit of Measure Code", '');
                            Found := not NPRTotalDiscountLine.IsEmpty;
                            if not Found then begin
                                NPRTotalDiscountLine.SetRange("Variant Code");
                                NPRTotalDiscountLine.SetRange("Unit Of Measure Code");
                                NPRTotalDiscountLine.SetRange(Type, NPRTotalDiscountLine.Type::"Item Category");
                                NPRTotalDiscountLine.SetRange("No.", TempCalcTotalDiscountSaleLinePOS."Item Category Code");
                                Found := not NPRTotalDiscountLine.IsEmpty;
                            end;
                            if not Found then begin
                                NPRTotalDiscountLine.SetRange("Variant Code");
                                NPRTotalDiscountLine.SetRange("Unit Of Measure Code");
                                NPRTotalDiscountLine.SetRange(Type, NPRTotalDiscountLine.Type::Vendor);
                                NPRTotalDiscountLine.SetRange("No.", TempCalcTotalDiscountSaleLinePOS."Vendor No.");
                                Found := not NPRTotalDiscountLine.IsEmpty;
                            end;
                            if Found then
                                CopySaleLineWithCalculation(TempCalcTotalDiscountSaleLinePOS, TempTotalDiscountSaleLinePOS, false);
                        until TempCalcTotalDiscountSaleLinePOS.Next() = 0;
                end;
        end;
        Clear(TempTotalDiscountSaleLinePOS);
    end;

    local procedure CopySaleLinesPOSWithCalculation(var FromTempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                                    var ToTempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                                    UpdateDiscountAmount: Boolean)
    begin
        if not ToTempSaleLinePOS.IsTemporary() then
            exit;

        Clear(ToTempSaleLinePOS);
        if not ToTempSaleLinePOS.IsEmpty then
            ToTempSaleLinePOS.DeleteAll();

        if not FromTempSaleLinePOS.FindSet(false) then
            exit;

        repeat
            CopySaleLineWithCalculation(FromTempSaleLinePOS,
                                        ToTempSaleLinePOS,
                                        UpdateDiscountAmount);
        until FromTempSaleLinePOS.Next() = 0;
    end;

    local procedure CopySaleLinesPOS(var FromTempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                     var ToTempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                     ClearBuffer: Boolean)
    begin
        if not ToTempSaleLinePOS.IsTemporary() then
            exit;

        if ClearBuffer then
            DeleteBuffer(ToTempSaleLinePOS);

        if not FromTempSaleLinePOS.FindSet(false) then
            exit;

        repeat
            CopySaleLinePOS(FromTempSaleLinePOS, ToTempSaleLinePOS);
        until FromTempSaleLinePOS.Next() = 0;
    end;

    local procedure CopySaleLinePOS(var FromTempSaleLinePOS: Record "NPR POS Sale Line" temporary; var ToTempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    begin
        if ToTempSaleLinePOS.Get(FromTempSaleLinePOS.RecordId) then
            exit;

        ToTempSaleLinePOS.Init();
        ToTempSaleLinePOS := FromTempSaleLinePOS;
        ToTempSaleLinePOS.Insert(false);
    end;

    local procedure DeleteBuffer(var ToTempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    begin
        Clear(ToTempSaleLinePOS);
        if not ToTempSaleLinePOS.IsEmpty then
            ToTempSaleLinePOS.DeleteAll();
    end;

    internal procedure ApplyTotalDiscount(SalePOS: Record "NPR POS Sale";
                                       var TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                       CalculationDate: Date)

    var
        TempTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit" temporary;
        TempNPRTotalDiscountHeader: Record "NPR Total Discount Header" temporary;
        ActiveTotalDiscountsFound: Boolean;
        TotalDiscountSalesAmount: Decimal;
    begin
        if DiscountApplied(TempSaleLinePOS) then
            exit;

        ActiveTotalDiscountsFound := FindActiveTotalDiscount(TempNPRTotalDiscountHeader,
                                                             SalePOS,
                                                             TempSaleLinePOS,
                                                             TempTotalDiscountSaleLinePOS,
                                                             TempNPRTotalDiscountBenefit,
                                                             TotalDiscountSalesAmount,
                                                             CalculationDate);
        if ActiveTotalDiscountsFound then begin

            ApplyTotalDiscountBenefits(TempTotalDiscountSaleLinePOS,
                                       TempNPRTotalDiscountBenefit);

            TransferAppliedTotalDiscountSaleLinesToSale(TempTotalDiscountSaleLinePOS,
                                                        TempSaleLinePOS);
        end;

        CleanUpUnrelevantBenefitItems(SalePOS,
                                      TempNPRTotalDiscountBenefit."Total Discount Code",
                                      TempNPRTotalDiscountBenefit."Step Amount");
    end;

    internal procedure CleanUpUnrelevantBenefitItems(SalePOS: Record "NPR POS Sale";
                                                     TotalDiscountCode: Code[20];
                                                     TotalDiscountStepAmount: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetRange("Benefit Item", true);
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', TotalDiscountCode);
        if not SaleLinePOS.IsEmpty then
            SaleLinePOS.DeleteAll(true);

        SaleLinePOS.SetFilter("Total Discount Code", TotalDiscountCode);
        SaleLinePOS.SetFilter("Total Discount Step", '<>%1', TotalDiscountStepAmount);
        if not SaleLinePOS.IsEmpty then
            SaleLinePOS.DeleteAll(true);
    end;

    local procedure CleanUpManualDiscountLines(SalePOS: Record "NPR POS Sale";
                                               CurrSaleLine: Record "NPR POS Sale Line";
                                               xCurrSaleLine: Record "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        LineDiscountAmountWithVAT: Decimal;
        xLineDiscountAmountWithVAT: Decimal;
        LineAmountWithVAT: Decimal;
        LineAmountWithoutDiscountVAT: Decimal;
        xLineAmountWithoutDiscountVAT: Decimal;
        LineDiscountPercent: Decimal;
    begin
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetRange("Discount Type", SaleLinePOS."Discount Type"::Manual);
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        if not SaleLinePOS.FindSet(true) then
            exit;

        repeat
            if SaleLinePOS."Disc. Amt. Without Total Disc." <> 0 then
                if (SaleLinePOS.RecordId <> CurrSaleLine.RecordId) or
                   ((SaleLinePOS.RecordId = CurrSaleLine.RecordId) and ((CurrSaleLine."Discount %" = xCurrSaleLine."Discount %") and ((CurrSaleLine."Discount Amount" = xCurrSaleLine."Discount Amount")) or (CurrSaleLine.Quantity <> xCurrSaleLine.Quantity)))
                then begin

                    LineAmountWithoutDiscountVAT := UnitPriceIncludingVAT(SaleLinePOS) * SaleLinePOS.Quantity;

                    LineDiscountPercent := 0;
                    if CurrSaleLine.Quantity <> xCurrSaleLine.Quantity then begin
                        xLineDiscountAmountWithVAT := SaleLinePOS."Disc. Amt. Without Total Disc.";
                        if not SaleLinePOS."Price Includes VAT" then
                            xLineDiscountAmountWithVAT := CalcAmountWithVAT(xLineDiscountAmountWithVAT,
                                                                           SaleLinePOS."VAT %",
                                                                           0);

                        xLineAmountWithoutDiscountVAT := UnitPriceIncludingVAT(xCurrSaleLine) * xCurrSaleLine.Quantity;
                        if xLineAmountWithoutDiscountVAT <> 0 then
                            LineDiscountPercent := xLineDiscountAmountWithVAT / xLineAmountWithoutDiscountVAT * 100;

                        LineDiscountAmountWithVAT := LineAmountWithoutDiscountVAT * LineDiscountPercent / 100;

                    end else begin
                        LineDiscountAmountWithVAT := SaleLinePOS."Disc. Amt. Without Total Disc.";
                        if not SaleLinePOS."Price Includes VAT" then
                            LineDiscountAmountWithVAT := CalcAmountWithVAT(LineDiscountAmountWithVAT,
                                                                           SaleLinePOS."VAT %",
                                                                           0);
                        if LineAmountWithoutDiscountVAT <> 0 then
                            LineDiscountPercent := LineDiscountAmountWithVAT / LineAmountWithoutDiscountVAT * 100;
                    end;

                    LineAmountWithVAT := LineAmountWithoutDiscountVAT - LineDiscountAmountWithVAT;

                    if not SaleLinePOS."Price Includes VAT" then
                        SaleLinePOS."Discount Amount" := CalcAmountWithoutVAT(LineDiscountAmountWithVAT,
                                                                              SaleLinePOS."VAT %",
                                                                              GeneralLedgerSetup."Amount Rounding Precision")
                    else
                        SaleLinePOS."Discount Amount" := LineDiscountAmountWithVAT;

                    SaleLinePOS."Discount %" := Round(LineDiscountPercent,
                                                      GeneralLedgerSetup."Amount Rounding Precision");

                    SaleLinePOS."Amount Including VAT" := Round(LineAmountWithVAT,
                                                                GeneralLedgerSetup."Amount Rounding Precision");

                    SaleLinePOS.Amount := CalcAmountWithoutVAT(SaleLinePOS."Amount Including VAT",
                                                                SaleLinePOS."VAT %",
                                                                GeneralLedgerSetup."Amount Rounding Precision");
                end;
            ClearTotalDiscountFromSaleLine(SaleLinePOS);
            SaleLinePOS.Modify()
        until SaleLinePOS.Next() = 0;

    end;

    local procedure TransferAppliedTotalDiscountSaleLinesToSale(var FromTempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                                                var ToTempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    begin
        FromTempSaleLinePOS.Reset();
        if not FromTempSaleLinePOS.FindSet(false) then
            exit;

        repeat
            if ToTempSaleLinePOS.Get(FromTempSaleLinePOS.RecordId) then begin
                ToTempSaleLinePOS := FromTempSaleLinePOS;
                ToTempSaleLinePOS.Modify();
            end;
        until FromTempSaleLinePOS.Next() = 0;
    end;

    local procedure ApplyTotalDiscountBenefits(var TempTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                               var TempNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit" temporary)
    begin
        //Discount Amount includes VAT in the current calculation;
        TempNPRTotalDiscountBenefit.Reset();
        TempNPRTotalDiscountBenefit.SetRange(Type, TempNPRTotalDiscountBenefit.Type::Discount);
        if TempNPRTotalDiscountBenefit.FindSet(false) then begin
            repeat
                case TempNPRTotalDiscountBenefit."Value Type" of
                    TempNPRTotalDiscountBenefit."Value Type"::Percent:
                        HandleTotalDiscountPercent(TempTotalDiscountSaleLinePOS,
                                                   TempNPRTotalDiscountBenefit);

                    TempNPRTotalDiscountBenefit."Value Type"::Amount:
                        HandleTotalDiscountAmount(TempTotalDiscountSaleLinePOS,
                                                  TempNPRTotalDiscountBenefit);
                end;
            until TempNPRTotalDiscountBenefit.Next() = 0;
            exit
        end;

        TempNPRTotalDiscountBenefit.Reset();
        TempNPRTotalDiscountBenefit.SetFilter(Type, '%1|%2', TempNPRTotalDiscountBenefit.Type::Item, TempNPRTotalDiscountBenefit.Type::"Item List");
        if not TempNPRTotalDiscountBenefit.FindFirst() then
            exit;

        TempTotalDiscountSaleLinePOS.Reset();
        if not TempTotalDiscountSaleLinePOS.FindSet() then
            exit;

        repeat
            TempTotalDiscountSaleLinePOS."Discount Calculated" := true;
            TempTotalDiscountSaleLinePOS."Total Discount Code" := TempNPRTotalDiscountBenefit."Total Discount Code";
            TempTotalDiscountSaleLinePOS."Total Discount Step" := TempNPRTotalDiscountBenefit."Step Amount";
            TempTotalDiscountSaleLinePOS.Modify()
        until TempTotalDiscountSaleLinePOS.Next() = 0;

    end;

    local procedure FilterActiveTotalDiscountHeaders(var NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                                     CalculationDate: Date);
    begin
        NPRTotalDiscountHeader.Reset();
        NPRTotalDiscountHeader.SetCurrentKey(Status,
                                            Priority,
                                            "Starting Date",
                                            "Ending date");
        NPRTotalDiscountHeader.SetRange(Status, NPRTotalDiscountHeader.Status::Active);
        NPRTotalDiscountHeader.SetFilter("Starting Date", '<=%1|=%2', CalculationDate, 0D);//
        NPRTotalDiscountHeader.SetFilter("Ending Date", '>=%1|=%2', CalculationDate, 0D);
        NPRTotalDiscountHeader.SetLoadFields(Status,
                                             Priority,
                                             "Starting Date",
                                             "Ending date",
                                             "Customer Disc. Group Filter");
    end;

    internal procedure ActiveTotalDiscountsExist(CalculationDate: Date) ActiveTotalDiscountsExist: Boolean;
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
    begin
        FilterActiveTotalDiscountHeaders(NPRTotalDiscountHeader, CalculationDate);
        ActiveTotalDiscountsExist := not NPRTotalDiscountHeader.IsEmpty;
    end;

    local procedure CheckDiscountPriority(CurrNPRDiscountPriority: Record "NPR Discount Priority")
    var
        NPRDiscountPriority: Record "NPR Discount Priority";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        PriorityErrorLbl: Label 'Table %1 %2 must be with the lowest priority.';
    begin
        if CurrNPRDiscountPriority."Table ID" = NPRTotalDiscountManagement.DiscSourceTableId() then begin
            NPRDiscountPriority.Reset();
            NPRDiscountPriority.SetCurrentKey(Priority);
            NPRDiscountPriority.SetFilter(Priority, '>%1', CurrNPRDiscountPriority.Priority);
            if NPRDiscountPriority.FindLast() then
                Error(PriorityErrorLbl,
                      CurrNPRDiscountPriority."Table ID",
                      CurrNPRDiscountPriority."Table Name");

            exit;
        end;

        if not NPRDiscountPriority.Get(NPRTotalDiscountManagement.DiscSourceTableId()) then
            exit;

        if NPRDiscountPriority.Priority < CurrNPRDiscountPriority.Priority then
            Error(PriorityErrorLbl,
                  NPRDiscountPriority."Table ID",
                  NPRDiscountPriority."Table Name");
    end;

    internal procedure GetTotalDiscountBenefitItemsForSale(SalePOS: Record "NPR POS Sale";
                                                           NPRBenefitItemsCollection: Enum "NPR Benefit Items Collection";
                                                           var TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary) Found: Boolean;
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        TemporaryRecordErrorLbl: Label 'The provided table is not temporary';
    begin
        if not TempNPRTotalDiscBenItemBuffer.IsTemporary then
            Error(TemporaryRecordErrorLbl);

        TempNPRTotalDiscBenItemBuffer.Reset();
        if not TempNPRTotalDiscBenItemBuffer.IsEmpty then
            TempNPRTotalDiscBenItemBuffer.DeleteAll();

        SaleLinePOS.Reset();
        SaleLinePOS.SetCurrentKey("Register No.",
                                  "Sales Ticket No.",
                                  "Line Type",
                                  "Total Discount Code",
                                  "Benefit Item");

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        SaleLinePOS.SetRange("Benefit Item", false);
        SaleLinePOS.SetRange("Shipment Fee", false);
        SaleLinePOS.SetLoadFields("Register No.",
                                  "Sales Ticket No.",
                                  "Line Type",
                                  "Total Discount Code",
                                  "Benefit Item",
                                  "Shipment Fee",
                                  "Total Discount Step");

        if not SaleLinePOS.FindFirst() then
            exit;

        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", SaleLinePOS."Total Discount Code");
        NPRTotalDiscountBenefit.SetRange("Step Amount", SaleLinePOS."Total Discount Step");
        NPRTotalDiscountBenefit.SetFilter(Type, '%1|%2', NPRTotalDiscountBenefit.Type::Item, NPRTotalDiscountBenefit.Type::"Item List");

        case NPRBenefitItemsCollection of
            NPRBenefitItemsCollection::"Input Needed":
                NPRTotalDiscountBenefit.SetRange("No Input Needed", false);
            NPRBenefitItemsCollection::"No Input Needed":
                NPRTotalDiscountBenefit.SetRange("No Input Needed", true);
        end;

        if not NPRTotalDiscountBenefit.FindSet(false) then
            exit;

        repeat
            case NPRTotalDiscountBenefit.Type of
                NPRTotalDiscountBenefit.Type::Item:
                    PopulateTotalDiscountBenefitBufferFromTotalDiscountBenefit(NPRTotalDiscountBenefit,
                                                                           TempNPRTotalDiscBenItemBuffer);
                NPRTotalDiscountBenefit.Type::"Item List":
                    PopulateTotalDiscountBenefitBufferFromItemList(NPRTotalDiscountBenefit,
                                                                               TempNPRTotalDiscBenItemBuffer);
            end;
        until NPRTotalDiscountBenefit.Next() = 0;
        Clear(TempNPRTotalDiscBenItemBuffer);
        Found := true;

    end;

    internal procedure CheckIfBenefitItemsAddedToPOSSale(SalePOS: Record "NPR POS Sale") Found: Boolean;
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin

        SaleLinePOS.Reset();
        SaleLinePOS.SetCurrentKey("Register No.",
                                  "Sales Ticket No.",
                                  "Line Type",
                                  "Total Discount Code",
                                  "Benefit Item");

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        SaleLinePOS.SetRange("Benefit Item", true);
        Found := not SaleLinePOS.IsEmpty;
    end;

    local procedure PopulateTotalDiscountBenefitBufferFromTotalDiscountBenefit(NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
                                                                               var TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        EntryNo: Integer;
        TemporaryRecordErrorLbl: Label 'The provided table is not temporary';
    begin
        if not TempNPRTotalDiscBenItemBuffer.IsTemporary then
            Error(TemporaryRecordErrorLbl);

        if NPRTotalDiscountBenefit.Type <> NPRTotalDiscountBenefit.Type::Item then
            exit;

        TempNPRTotalDiscBenItemBuffer.Reset();
        TempNPRTotalDiscBenItemBuffer.SetRange("Item No.", NPRTotalDiscountBenefit."No.");
        TempNPRTotalDiscBenItemBuffer.SetRange("Variant Code", NPRTotalDiscountBenefit."Variant Code");
        TempNPRTotalDiscBenItemBuffer.SetRange("Unit Price", NPRTotalDiscountBenefit.Value);
        TempNPRTotalDiscBenItemBuffer.SetRange("Benefit List Code", '');
        if not TempNPRTotalDiscBenItemBuffer.FindFirst() then begin
            EntryNo := GetLastEntryNoFromTotalDiscountBenefitBuffer(TempNPRTotalDiscBenItemBuffer) + 1;

            if not Item.Get(NPRTotalDiscountBenefit."No.") then
                Clear(Item);

            if ItemVariant.Get(NPRTotalDiscountBenefit."No.",
                               NPRTotalDiscountBenefit."Variant Code")
            then
                Clear(ItemVariant);

            TempNPRTotalDiscBenItemBuffer.Init();
            TempNPRTotalDiscBenItemBuffer."Entry No." := EntryNo;
            TempNPRTotalDiscBenItemBuffer."Item No." := NPRTotalDiscountBenefit."No.";
            TempNPRTotalDiscBenItemBuffer."Variant Code" := NPRTotalDiscountBenefit."Variant Code";
            TempNPRTotalDiscBenItemBuffer."Unit Price" := NPRTotalDiscountBenefit.Value;
            TempNPRTotalDiscBenItemBuffer."Total Discount Code" := NPRTotalDiscountBenefit."Total Discount Code";
            TempNPRTotalDiscBenItemBuffer."Total Discount Step" := NPRTotalDiscountBenefit."Step Amount";
            TempNPRTotalDiscBenItemBuffer."Unit of Measure Code" := Item."Base Unit of Measure";
            TempNPRTotalDiscBenItemBuffer.ItemID := ItemVariant.SystemId;
            if IsNullGuid(TempNPRTotalDiscBenItemBuffer.ItemID) then
                TempNPRTotalDiscBenItemBuffer.ItemID := item.SystemId;

            TempNPRTotalDiscBenItemBuffer.Description := CopyStr(ItemVariant.Description,
                                                                 1,
                                                                 MaxStrLen(TempNPRTotalDiscBenItemBuffer.Description));

            if TempNPRTotalDiscBenItemBuffer.Description = '' then
                TempNPRTotalDiscBenItemBuffer.Description := CopyStr(Item.Description,
                                                                     1,
                                                                     MaxStrLen(TempNPRTotalDiscBenItemBuffer.Description));
            TempNPRTotalDiscBenItemBuffer."No Input Needed" := NPRTotalDiscountBenefit."No Input Needed";
            TempNPRTotalDiscBenItemBuffer.Insert();
        end;

        TempNPRTotalDiscBenItemBuffer.Quantity += NPRTotalDiscountBenefit.Quantity;
        TempNPRTotalDiscBenItemBuffer.Modify();
    end;

    local procedure PopulateTotalDiscountBenefitBufferFromItemList(NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
                                                                   var TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        NPRItemBenefitListHeader: Record "NPR Item Benefit List Header";
        NPRItemBenefitListLine: Record "NPR Item Benefit List Line";
        EntryNo: Integer;
        TemporaryRecordErrorLbl: Label 'The provided table is not temporary';
    begin
        if NPRTotalDiscountBenefit.Type <> NPRTotalDiscountBenefit.Type::"Item List" then
            exit;

        if NPRTotalDiscountBenefit."No." = '' then
            exit;
        if not TempNPRTotalDiscBenItemBuffer.IsTemporary then
            Error(TemporaryRecordErrorLbl);

        if not NPRItemBenefitListHeader.Get(NPRTotalDiscountBenefit."No.") then
            Clear(NPRItemBenefitListHeader);


        NPRItemBenefitListLine.Reset();
        NPRItemBenefitListLine.SetRange("List Code", NPRTotalDiscountBenefit."No.");
        if not NPRItemBenefitListLine.FindSet(false) then
            exit;

        repeat
            TempNPRTotalDiscBenItemBuffer.Reset();
            TempNPRTotalDiscBenItemBuffer.SetRange("Item No.", NPRItemBenefitListLine."No.");
            TempNPRTotalDiscBenItemBuffer.SetRange("Variant Code", NPRItemBenefitListLine."Variant Code");
            TempNPRTotalDiscBenItemBuffer.SetRange("Unit Price", NPRItemBenefitListLine."Unit Price");
            TempNPRTotalDiscBenItemBuffer.SetRange("Benefit List Code", NPRItemBenefitListLine."List Code");
            if not TempNPRTotalDiscBenItemBuffer.FindFirst() then begin
                EntryNo := GetLastEntryNoFromTotalDiscountBenefitBuffer(TempNPRTotalDiscBenItemBuffer) + 1;

                if not Item.Get(NPRItemBenefitListLine."No.") then
                    Clear(Item);

                if ItemVariant.Get(NPRItemBenefitListLine."No.",
                                   NPRItemBenefitListLine."Variant Code")
                then
                    Clear(ItemVariant);

                TempNPRTotalDiscBenItemBuffer.Init();
                TempNPRTotalDiscBenItemBuffer."Entry No." := EntryNo;
                TempNPRTotalDiscBenItemBuffer."Item No." := NPRItemBenefitListLine."No.";
                TempNPRTotalDiscBenItemBuffer."Variant Code" := NPRItemBenefitListLine."Variant Code";
                TempNPRTotalDiscBenItemBuffer."Unit Price" := NPRItemBenefitListLine."Unit Price";
                TempNPRTotalDiscBenItemBuffer."Total Discount Code" := NPRTotalDiscountBenefit."Total Discount Code";
                TempNPRTotalDiscBenItemBuffer."Total Discount Step" := NPRTotalDiscountBenefit."Step Amount";
                TempNPRTotalDiscBenItemBuffer."Unit of Measure Code" := Item."Base Unit of Measure";
                TempNPRTotalDiscBenItemBuffer.ItemID := ItemVariant.SystemId;
                if IsNullGuid(TempNPRTotalDiscBenItemBuffer.ItemID) then
                    TempNPRTotalDiscBenItemBuffer.ItemID := item.SystemId;

                TempNPRTotalDiscBenItemBuffer.Description := CopyStr(ItemVariant.Description,
                                                                     1,
                                                                     MaxStrLen(TempNPRTotalDiscBenItemBuffer.Description));

                if TempNPRTotalDiscBenItemBuffer.Description = '' then
                    TempNPRTotalDiscBenItemBuffer.Description := CopyStr(Item.Description,
                                                                         1,
                                                                         MaxStrLen(TempNPRTotalDiscBenItemBuffer.Description));
                TempNPRTotalDiscBenItemBuffer."No Input Needed" := NPRTotalDiscountBenefit."No Input Needed";
                TempNPRTotalDiscBenItemBuffer."Benefit List Code" := NPRItemBenefitListLine."List Code";
                TempNPRTotalDiscBenItemBuffer.Insert();
            end;

            TempNPRTotalDiscBenItemBuffer.Quantity += NPRItemBenefitListLine.Quantity;
            TempNPRTotalDiscBenItemBuffer.Modify();
        until NPRItemBenefitListLine.Next() = 0;

    end;


    local procedure GetLastEntryNoFromTotalDiscountBenefitBuffer(var TempCurrNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary) EntryNo: Integer;
    var
        TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
        TemporaryRecordErrorLbl: Label 'The provided table is not temporary';
    begin
        if not TempNPRTotalDiscBenItemBuffer.IsTemporary then
            Error(TemporaryRecordErrorLbl);

        TempNPRTotalDiscBenItemBuffer.CopyFilters(TempCurrNPRTotalDiscBenItemBuffer);
        TempNPRTotalDiscBenItemBuffer := TempCurrNPRTotalDiscBenItemBuffer;

        TempCurrNPRTotalDiscBenItemBuffer.Reset();
        if not TempCurrNPRTotalDiscBenItemBuffer.FindLast() then
            Clear(TempCurrNPRTotalDiscBenItemBuffer);

        EntryNo := TempCurrNPRTotalDiscBenItemBuffer."Entry No.";

        TempCurrNPRTotalDiscBenItemBuffer.Reset();
        TempCurrNPRTotalDiscBenItemBuffer.CopyFilters(TempNPRTotalDiscBenItemBuffer);
        TempCurrNPRTotalDiscBenItemBuffer := TempNPRTotalDiscBenItemBuffer;

    end;

    internal procedure CalcAmountWithoutVAT(Amount: Decimal;
                                         VATPercent: Decimal;
                                         RoundingPrecision: Decimal) AmountWithoutVAT: Decimal
    begin
        if VATPercent = 0 then
            AmountWithoutVAT := Amount
        else
            AmountWithoutVAT := Amount / (1 + VATPercent / 100);

        if RoundingPrecision = 0 then
            exit;

        AmountWithoutVAT := Round(AmountWithoutVAT, RoundingPrecision);
    end;

    internal procedure CalcAmountWithVAT(Amount: Decimal;
                                      VATPercent: Decimal;
                                      RoundingPrecision: Decimal) AmountWithVAT: Decimal
    begin
        if VATPercent = 0 then
            AmountWithVAT := Amount
        else
            AmountWithVAT := Amount * (1 + VATPercent / 100);

        if RoundingPrecision = 0 then
            exit;

        AmountWithVAT := Round(AmountWithVAT, RoundingPrecision);
    end;

    local procedure HandleTotalDiscountPercent(var TempTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                               var TempNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit" temporary)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        LineTotalDiscountAmountWithVAT: Decimal;
        LineAmountWithoutDiscountVAT: Decimal;
        LineDiscountAmountWithVAT: Decimal;
        LineDiscountPercent: Decimal;
    begin
        //Discount Amount includes VAT in the current calculation;
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        TempTotalDiscountSaleLinePOS.Reset();
        if TempTotalDiscountSaleLinePOS.FindSet(true) then
            repeat

                LineAmountWithoutDiscountVAT := UnitPriceIncludingVAT(TempTotalDiscountSaleLinePOS) * TempTotalDiscountSaleLinePOS.Quantity;
                LineTotalDiscountAmountWithVAT := (TempTotalDiscountSaleLinePOS."Amount Including VAT") * TempNPRTotalDiscountBenefit.Value / 100;
                LineDiscountAmountWithVAT := TempTotalDiscountSaleLinePOS."Discount Amount" + LineTotalDiscountAmountWithVAT;

                LineDiscountPercent := 0;
                if LineAmountWithoutDiscountVAT <> 0 then
                    LineDiscountPercent := LineDiscountAmountWithVAT / LineAmountWithoutDiscountVAT * 100;

                TempTotalDiscountSaleLinePOS."Total Discount Amount" := Round(LineTotalDiscountAmountWithVAT, GeneralLedgerSetup."Amount Rounding Precision");
                TempTotalDiscountSaleLinePOS."Disc. Amt. Without Total Disc." := TempTotalDiscountSaleLinePOS."Discount Amount";
                TempTotalDiscountSaleLinePOS."Discount Amount" := Round(LineDiscountAmountWithVAT, GeneralLedgerSetup."Amount Rounding Precision");
                TempTotalDiscountSaleLinePOS."Discount %" := LineDiscountPercent;
                TempTotalDiscountSaleLinePOS."Total Discount Code" := TempNPRTotalDiscountBenefit."Total Discount Code";
                TempTotalDiscountSaleLinePOS."Total Discount Step" := TempNPRTotalDiscountBenefit."Step Amount";
                TempTotalDiscountSaleLinePOS."Amount Including VAT" := LineAmountWithoutDiscountVAT - TempTotalDiscountSaleLinePOS."Discount Amount";
                TempTotalDiscountSaleLinePOS.Amount := CalcAmountWithoutVAT(TempTotalDiscountSaleLinePOS."Amount Including VAT",
                                                                            TempTotalDiscountSaleLinePOS."VAT %",
                                                                            GeneralLedgerSetup."Amount Rounding Precision");
                TempTotalDiscountSaleLinePOS."Discount Calculated" := true;
                TempTotalDiscountSaleLinePOS.Modify();

            until TempTotalDiscountSaleLinePOS.Next() = 0;

        //Discount Amount includes VAT in the current calculation so have to substract it from the discount amounts
        UpdateTotalDiscountVAT(TempTotalDiscountSaleLinePOS);
    end;

    local procedure HandleTotalDiscountAmount(var TempTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                              var TempNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit" temporary)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        LineTotalDiscountAmountWithVAT: Decimal;
        LineAmountWithoutDiscountVAT: Decimal;
        LineDiscountAmountWithVAT: Decimal;
        LineDiscountPercent: Decimal;
        LineAmountWithVAT: Decimal;
        RemainingTotalDiscountAmountWithVAT: Decimal;
        TotalDiscountMultiplier: Decimal;
    begin
        //Discount Amount includes VAT in the current calculation;
        if TempNPRTotalDiscountBenefit."Value Type" <> TempNPRTotalDiscountBenefit."Value Type"::Amount then
            exit;

        TempTotalDiscountSaleLinePOS.Reset();
        TempTotalDiscountSaleLinePOS.CalcSums("Amount Including VAT");

        if TempTotalDiscountSaleLinePOS."Amount Including VAT" <> 0 then
            TotalDiscountMultiplier := TempNPRTotalDiscountBenefit.Value / TempTotalDiscountSaleLinePOS."Amount Including VAT";

        if not TempTotalDiscountSaleLinePOS.FindSet(true) then
            exit;

        repeat
            LineAmountWithoutDiscountVAT := UnitPriceIncludingVAT(TempTotalDiscountSaleLinePOS) * TempTotalDiscountSaleLinePOS.Quantity;

            LineAmountWithVAT := TempTotalDiscountSaleLinePOS."Amount Including VAT";
            LineTotalDiscountAmountWithVAT := LineAmountWithVAT * TotalDiscountMultiplier;
            LineDiscountAmountWithVAT := TempTotalDiscountSaleLinePOS."Discount Amount" + LineTotalDiscountAmountWithVAT;

            LineDiscountPercent := 0;
            if LineAmountWithoutDiscountVAT <> 0 then
                LineDiscountPercent := LineDiscountAmountWithVAT / LineAmountWithoutDiscountVAT * 100;

            TempTotalDiscountSaleLinePOS."Disc. Amt. Without Total Disc." := TempTotalDiscountSaleLinePOS."Discount Amount";
            TempTotalDiscountSaleLinePOS."Discount Amount" := Round(LineDiscountAmountWithVAT, GeneralLedgerSetup."Amount Rounding Precision");
            TempTotalDiscountSaleLinePOS."Total Discount Amount" := Round(LineTotalDiscountAmountWithVAT, GeneralLedgerSetup."Amount Rounding Precision");
            TempTotalDiscountSaleLinePOS."Discount %" := LineDiscountPercent;
            TempTotalDiscountSaleLinePOS."Amount Including VAT" := LineAmountWithoutDiscountVAT - TempTotalDiscountSaleLinePOS."Discount Amount";
            TempTotalDiscountSaleLinePOS.Amount := CalcAmountWithoutVAT(TempTotalDiscountSaleLinePOS."Amount Including VAT",
                                                                        TempTotalDiscountSaleLinePOS."VAT %",
                                                                         GeneralLedgerSetup."Amount Rounding Precision");
            TempTotalDiscountSaleLinePOS."Total Discount Code" := TempNPRTotalDiscountBenefit."Total Discount Code";
            TempTotalDiscountSaleLinePOS."Total Discount Step" := TempNPRTotalDiscountBenefit."Step Amount";
            TempTotalDiscountSaleLinePOS."Discount Calculated" := true;
            TempTotalDiscountSaleLinePOS.Modify();

        until TempTotalDiscountSaleLinePOS.Next() = 0;

        TempTotalDiscountSaleLinePOS.Reset();
        TempTotalDiscountSaleLinePOS.CalcSums("Total Discount Amount");

        RemainingTotalDiscountAmountWithVAT := TempNPRTotalDiscountBenefit.Value - TempTotalDiscountSaleLinePOS."Total Discount Amount";

        if RemainingTotalDiscountAmountWithVAT <> 0 then
            if TempTotalDiscountSaleLinePOS.FindSet(true) then
                repeat
                    LineAmountWithoutDiscountVAT := UnitPriceIncludingVAT(TempTotalDiscountSaleLinePOS) * TempTotalDiscountSaleLinePOS.Quantity;
                    LineTotalDiscountAmountWithVAT := RemainingTotalDiscountAmountWithVAT;

                    if TempTotalDiscountSaleLinePOS."Amount Including VAT" < RemainingTotalDiscountAmountWithVAT then
                        LineTotalDiscountAmountWithVAT := TempTotalDiscountSaleLinePOS."Amount Including VAT";

                    RemainingTotalDiscountAmountWithVAT -= LineTotalDiscountAmountWithVAT;

                    LineDiscountPercent := 0;
                    if LineAmountWithoutDiscountVAT <> 0 then
                        LineDiscountPercent := (LineTotalDiscountAmountWithVAT + TempTotalDiscountSaleLinePOS."Discount Amount") / LineAmountWithoutDiscountVAT * 100;

                    TempTotalDiscountSaleLinePOS."Total Discount Amount" += LineTotalDiscountAmountWithVAT;
                    TempTotalDiscountSaleLinePOS."Discount Amount" += LineTotalDiscountAmountWithVAT;
                    TempTotalDiscountSaleLinePOS."Discount %" := LineDiscountPercent;
                    TempTotalDiscountSaleLinePOS."Amount Including VAT" := LineAmountWithoutDiscountVAT - TempTotalDiscountSaleLinePOS."Discount Amount";
                    TempTotalDiscountSaleLinePOS.Amount := CalcAmountWithoutVAT(TempTotalDiscountSaleLinePOS."Amount Including VAT",
                                                                                TempTotalDiscountSaleLinePOS."VAT %",
                                                                                GeneralLedgerSetup."Amount Rounding Precision");
                    TempTotalDiscountSaleLinePOS."Discount Calculated" := true;
                    TempTotalDiscountSaleLinePOS.Modify();

                until (TempTotalDiscountSaleLinePOS.Next() = 0) or
                      (RemainingTotalDiscountAmountWithVAT <= 0);

        //Discount Amount includes VAT in the current calculation so have to substract it from the discount amounts
        UpdateTotalDiscountVAT(TempTotalDiscountSaleLinePOS);
    end;

    local procedure UnitPriceIncludingVAT(SaleLinePOS: Record "NPR POS Sale Line"): Decimal
    begin
        if SaleLinePOS."Price Includes VAT" then
            exit(SaleLinePOS."Unit Price");
        exit(SaleLinePOS."Unit Price" * (1 + SaleLinePOS."VAT %" / 100));
    end;

    local procedure DiscountAmountIncludingVAT(SaleLinePOS: Record "NPR POS Sale Line"): Decimal
    begin
        if SaleLinePOS."Price Includes VAT" then
            exit(SaleLinePOS."Discount Amount");
        exit(SaleLinePOS."Discount Amount" * (1 + SaleLinePOS."VAT %" / 100));
    end;


    local procedure CopySaleLineWithCalculation(var FromSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                                var ToSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                                UpdateDiscountAmount: Boolean)

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if ToSaleLinePOS.Get(FromSaleLinePOS.RecordId) then
            exit;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        ToSaleLinePOS.Init();
        ToSaleLinePOS := FromSaleLinePOS;

        if UpdateDiscountAmount then
            ToSaleLinePOS."Discount Amount" := DiscountAmountIncludingVAT(ToSaleLinePOS);

        ToSaleLinePOS."Amount Including VAT" := UnitPriceIncludingVAT(ToSaleLinePOS) * ToSaleLinePOS.Quantity - ToSaleLinePOS."Discount Amount";
        ToSaleLinePOS.Amount := CalcAmountWithoutVAT(ToSaleLinePOS."Amount Including VAT",
                                                     ToSaleLinePOS."VAT %",
                                                     GeneralLedgerSetup."Amount Rounding Precision");
        ToSaleLinePOS.Insert();
    end;

    local procedure DiscountApplied(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary) DiscountApplied: Boolean
    begin
        TempSaleLinePOS.Reset();
        TempSaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        DiscountApplied := not TempSaleLinePOS.IsEmpty;

        TempSaleLinePOS.Reset();
    end;

    local procedure UpdatePOSSaleEntryTotalDiscountFields(var POSSalesLine: Record "NPR POS Entry Sales Line";
                                                          SaleLinePOS: Record "NPR POS Sale Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        POSSalesLine."Total Discount Code" := SaleLinePOS."Total Discount Code";
        POSSalesLine."Total Discount Step" := SaleLinePOS."Total Discount Step";
        POSSalesLine."Benefit Item" := SaleLinePOS."Benefit Item";
        POSSalesLine."Benefit List Code" := SaleLinePOS."Benefit List Code";

        if SaleLinePOS."Price Includes VAT" then begin
            POSSalesLine."Line Total Disc Amt Excl Tax" := CalcAmountWithoutVAT(SaleLinePOS."Total Discount Amount",
                                                                        SaleLinePOS."VAT %",
                                                                        GeneralLedgerSetup."Amount Rounding Precision");

            POSSalesLine."Line Total Disc Amt Incl Tax" := SaleLinePOS."Total Discount Amount";
        end else begin
            POSSalesLine."Line Total Disc Amt Excl Tax" := SaleLinePOS."Total Discount Amount";

            POSSalesLine."Line Total Disc Amt Incl Tax" := CalcAmountWithVAT(SaleLinePOS."Total Discount Amount",
                                                                             SaleLinePOS."VAT %",
                                                                             GeneralLedgerSetup."Amount Rounding Precision");

        end;
    end;

    local procedure CustomerDiscountGroupFilterPassed(NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                                      SalePOS: Record "NPR POS Sale") FilterPassed: Boolean
    var
        TempSalePOS: Record "NPR POS Sale" temporary;
    begin
        TempSalePOS.Init();
        TempSalePOS := SalePOS;
        TempSalePOS.Insert();

        TempSalePOS.Reset();
        TempSalePOS.SetFilter("Customer Disc. Group", NPRTotalDiscountHeader."Customer Disc. Group Filter");
        FilterPassed := not TempSalePOS.IsEmpty;
    end;

    local procedure TotalDiscountIsActive(NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                          SalePOS: Record "NPR POS Sale") IsActive: Boolean
    begin
        IsActive := CustomerDiscountGroupFilterPassed(NPRTotalDiscountHeader,
                                                      SalePOS);
        if not IsActive then
            exit;

        IsActive := TotalDiscountActiveNow(NPRTotalDiscountHeader);

    end;

    internal procedure UpdateTotalDiscountVAT(var TempTotalDiscountSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        TempTotalDiscountSaleLinePOS.Reset();
        if not TempTotalDiscountSaleLinePOS.FindSet(true) then
            exit;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        repeat
            if not TempTotalDiscountSaleLinePOS."Price Includes VAT" then begin
                TempTotalDiscountSaleLinePOS."Disc. Amt. Without Total Disc." := CalcAmountWithoutVAT(TempTotalDiscountSaleLinePOS."Disc. Amt. Without Total Disc.",
                                                                                                      TempTotalDiscountSaleLinePOS."VAT %",
                                                                                                      GeneralLedgerSetup."Amount Rounding Precision");

                TempTotalDiscountSaleLinePOS."Total Discount Amount" := CalcAmountWithoutVAT(TempTotalDiscountSaleLinePOS."Total Discount Amount",
                                                                                             TempTotalDiscountSaleLinePOS."VAT %",
                                                                                             GeneralLedgerSetup."Amount Rounding Precision");
                TempTotalDiscountSaleLinePOS.Modify();
            end;
        until TempTotalDiscountSaleLinePOS.Next() = 0;

    end;

    internal procedure AddManualDiscountSaleLines(SalePOS: Record "NPR POS Sale";
                                                  var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if not TempSaleLinePOS.IsTemporary() then
            exit;

        SaleLinePOS.Reset();
        SaleLinePOS.SetCurrentKey("Register No.",
                                  "Sales Ticket No.",
                                  Date,
                                  "Sale Type",
                                  "Line Type",
                                  "Discount Type");

        SaleLinePOS.SetRange("Discount Type", SaleLinePOS."Discount Type"::Manual);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        SaleLinePOS.SetRange("Benefit Item", false);
        SaleLinePOS.SetRange("Shipment Fee", false);
        if not SaleLinePOS.FindSet(false) then
            exit;

        repeat
            SaleLinePOS.TestField("Price Includes VAT", SalePOS."Prices Including VAT");
            if not TempSaleLinePOS.Get(SaleLinePOS.RecordId) then begin
                TempSaleLinePOS := SaleLinePOS;
                TempSaleLinePOS.Insert();
            end;
        until SaleLinePOS.Next() = 0;
    end;

    internal procedure CheckIfItemHasTotalDiscount(Item: Record Item;
                                                   var TotalDiscountExists: Boolean)
    var
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
    begin
        NPRTotalDiscountLine.Reset();
        NPRTotalDiscountLine.SetRange(Status, NPRTotalDiscountLine.Status::Active);
        NPRTotalDiscountLine.SetFilter("Starting Date", '<=%1', Today);
        NPRTotalDiscountLine.SetFilter("Ending Date", '>=%1', Today);
        NPRTotalDiscountLine.SetRange(type, NPRTotalDiscountLine.Type::All);

        TotalDiscountExists := not NPRTotalDiscountLine.IsEmpty;
        if TotalDiscountExists then
            exit;

        NPRTotalDiscountLine.SetRange(type, NPRTotalDiscountLine.Type::Item);
        NPRTotalDiscountLine.SetRange("No.", Item."No.");

        TotalDiscountExists := not NPRTotalDiscountLine.IsEmpty;
        if TotalDiscountExists then
            exit;

        NPRTotalDiscountLine.SetRange(type, NPRTotalDiscountLine.Type::"Item Category");
        NPRTotalDiscountLine.SetRange("No.", Item."Item Category Code");

        TotalDiscountExists := not NPRTotalDiscountLine.IsEmpty;
        if TotalDiscountExists then
            exit;

    end;

    local procedure GetActiveTotalDsicountLines(Item: Record Item;
                                                var TempNPRTotalDiscountLine: Record "NPR Total Discount Line" temporary)
    var
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        TemporaryTableErrorLbl: Label 'You must provide a temporary table as a parameter.';
    begin
        if not TempNPRTotalDiscountLine.IsTemporary then
            Error(TemporaryTableErrorLbl);

        TempNPRTotalDiscountLine.Reset();
        if not TempNPRTotalDiscountLine.IsEmpty then
            TempNPRTotalDiscountLine.DeleteAll();

        NPRTotalDiscountLine.Reset();
        NPRTotalDiscountLine.SetRange(Status, NPRTotalDiscountLine.Status::Active);
        NPRTotalDiscountLine.SetFilter("Starting Date", '<=%1', Today);
        NPRTotalDiscountLine.SetFilter("Ending Date", '>=%1', Today);
        NPRTotalDiscountLine.SetRange(type, NPRTotalDiscountLine.Type::All);
        if NPRTotalDiscountLine.FindSet(false) then
            repeat
                if not TempNPRTotalDiscountLine.Get(NPRTotalDiscountLine.RecordId) then begin
                    TempNPRTotalDiscountLine := NPRTotalDiscountLine;
                    TempNPRTotalDiscountLine.Insert();
                end;
            until NPRTotalDiscountLine.Next() = 0;

        NPRTotalDiscountLine.SetRange(type, NPRTotalDiscountLine.Type::Item);
        NPRTotalDiscountLine.SetRange("No.", Item."No.");
        if NPRTotalDiscountLine.FindSet(false) then
            repeat
                if not TempNPRTotalDiscountLine.Get(NPRTotalDiscountLine.RecordId) then begin
                    TempNPRTotalDiscountLine := NPRTotalDiscountLine;
                    TempNPRTotalDiscountLine.Insert();
                end;
            until NPRTotalDiscountLine.Next() = 0;



        NPRTotalDiscountLine.SetRange(type, NPRTotalDiscountLine.Type::"Item Category");
        NPRTotalDiscountLine.SetRange("No.", Item."Item Category Code");
        if NPRTotalDiscountLine.FindSet(false) then
            repeat
                if not TempNPRTotalDiscountLine.Get(NPRTotalDiscountLine.RecordId) then begin
                    TempNPRTotalDiscountLine := NPRTotalDiscountLine;
                    TempNPRTotalDiscountLine.Insert();
                end;
            until NPRTotalDiscountLine.Next() = 0;

        TempNPRTotalDiscountLine.Reset();


    end;

    internal procedure LookUpTotalDiscountLines(Item: Record Item;
                                                var TempNPRTotalDiscountLine: Record "NPR Total Discount Line" temporary) LookUpOk: Boolean
    var

    begin
        TempNPRTotalDiscountLine.Reset();
        GetActiveTotalDsicountLines(Item,
                                    TempNPRTotalDiscountLine);
        LookUpOk := Page.RunModal(0, TempNPRTotalDiscountLine) = Action::LookupOK;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Discount Priority", 'OnAfterValidateEvent', 'Priority', true, true)]
    local procedure OnAfterValidateDiscountPriority(var Rec: Record "NPR Discount Priority";
                                                   var xRec: Record "NPR Discount Priority")
    begin
        if Rec.Priority <> xRec.Priority then
            CheckDiscountPriority(Rec);
    end;

    internal procedure ClearTotalDiscountFromSaleLine(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS."Total Discount Amount" := 0;
        SaleLinePOS."Total Discount Code" := '';
        SaleLinePOS."Total Discount Step" := 0;
        SaleLinePOS."Disc. Amt. Without Total Disc." := 0;
    end;

    internal procedure CleanTotalDiscountFromSale(SalePOS: Record "NPR POS Sale"; CurrSaleLine: Record "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        LineDiscountAmountWithVAT: Decimal;
        LineAmountWithVAT: Decimal;
        LineAmountWithoutDiscountVAT: Decimal;
        LineDiscountPercent: Decimal;
    begin
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        SaleLinePOS.SetRange("Benefit Item", true);
        if not SaleLinePOS.IsEmpty then
            SaleLinePOS.DeleteAll(true);

        SaleLinePOS.SetRange("Benefit Item");
        if not SaleLinePOS.FindSet(true) then
            exit;

        repeat
            if CurrSaleLine.RecordId <> SaleLinePOS.RecordId then begin
                LineAmountWithoutDiscountVAT := UnitPriceIncludingVAT(SaleLinePOS) * SaleLinePOS.Quantity;

                LineDiscountPercent := 0;

                LineDiscountAmountWithVAT := SaleLinePOS."Disc. Amt. Without Total Disc.";
                if not SaleLinePOS."Price Includes VAT" then
                    LineDiscountAmountWithVAT := CalcAmountWithVAT(LineDiscountAmountWithVAT, SaleLinePOS."VAT %", 0);

                if LineAmountWithoutDiscountVAT <> 0 then
                    LineDiscountPercent := LineDiscountAmountWithVAT / LineAmountWithoutDiscountVAT * 100;


                LineAmountWithVAT := LineAmountWithoutDiscountVAT - LineDiscountAmountWithVAT;

                if not SaleLinePOS."Price Includes VAT" then
                    SaleLinePOS."Discount Amount" := CalcAmountWithoutVAT(LineDiscountAmountWithVAT, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision")
                else
                    SaleLinePOS."Discount Amount" := LineDiscountAmountWithVAT;

                SaleLinePOS."Discount %" := Round(LineDiscountPercent, GeneralLedgerSetup."Amount Rounding Precision");

                SaleLinePOS."Amount Including VAT" := Round(LineAmountWithVAT, GeneralLedgerSetup."Amount Rounding Precision");

                SaleLinePOS.Amount := CalcAmountWithoutVAT(SaleLinePOS."Amount Including VAT", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
            end;

            ClearTotalDiscountFromSaleLine(SaleLinePOS);
            SaleLinePOS.Modify()
        until SaleLinePOS.Next() = 0;

    end;

    internal procedure TestBenefitItem(SaleLinePOS: Record "NPR POS Sale Line")
    var
        BenefitItemErrorLbl: Label 'You cannot edit a benefit item line.';
    begin
        if not SaleLinePOS."Benefit Item" then
            exit;

        Error(BenefitItemErrorLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'ApplyDiscount', '', true, true)]
    local procedure OnApplyDiscount(DiscountPriority: Record "NPR Discount Priority";
                                    SalePOS: Record "NPR POS Sale";
                                    var TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                    Rec: Record "NPR POS Sale Line";
                                    xRec: Record "NPR POS Sale Line";
                                    LineOperation: Option Insert,Modify,Delete,Total;
                                    RecalculateAllLines: Boolean)
    begin
        if not IsSubscribedDiscount(DiscountPriority) then
            exit;

        if LineOperation = LineOperation::Total then
            exit;


        CleanUpUnrelevantBenefitItems(SalePOS,
                                      '',
                                      0);
        CleanUpManualDiscountLines(SalePOS,
                                   Rec,
                                   xRec);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'ApplyDiscountTotal', '', true, true)]
    local procedure ApplyDiscountTotal(DiscountPriority: Record "NPR Discount Priority";
                                       SalePOS: Record "NPR POS Sale";
                                       var TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
                                       Rec: Record "NPR POS Sale Line";
                                       xRec: Record "NPR POS Sale Line";
                                       LineOperation: Option Insert,Modify,Delete,Total;
                                       RecalculateAllLines: Boolean)
    begin
        if not IsSubscribedDiscount(DiscountPriority) then
            exit;

        if LineOperation <> LineOperation::Total then
            exit;


        AddManualDiscountSaleLines(SalePOS, TempSaleLinePOS);

        ApplyTotalDiscount(SalePOS, TempSaleLinePOS, Today)

    end;


    [EventSubscriber(ObjectType::Table, DATABASE::"NPR POS Sale Line", 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnAfterValidateQuantity(var Rec: Record "NPR POS Sale Line";
                                            var xRec: Record "NPR POS Sale Line";
                                            RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        TestBenefitItem(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnBeforeInsertPOSSalesLine', '', true, true)]
    local procedure OnBeforeInsertPOSSalesLine(POSEntry: Record "NPR POS Entry";
                                               SalePOS: Record "NPR POS Sale";
                                               var POSSalesLine: Record "NPR POS Entry Sales Line";
                                               SaleLinePOS: Record "NPR POS Sale Line")
    begin
        UpdatePOSSaleEntryTotalDiscountFields(POSSalesLine,
                                              SaleLinePOS)

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale", 'OnBeforeModifySaleLineCustomerInformation', '', true, true)]
    local procedure OnBeforeModifySaleLineCustomerInformation(var POSSale: Record "NPR POS Sale"; xPOSSale: Record "NPR POS Sale"; var POSSaleLine: Record "NPR POS Sale Line"; xPOSSaleLine: Record "NPR POS Sale Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        if POSSaleLine."Price Includes VAT" = xPOSSaleLine."Price Includes VAT" then
            exit;

        if POSSaleLine."Price Includes VAT" then begin
            POSSaleLine."Disc. Amt. Without Total Disc." := CalcAmountWithVAT(POSSaleLine."Disc. Amt. Without Total Disc.",
                                                                              POSSaleLine."VAT %",
                                                                              GeneralLedgerSetup."Amount Rounding Precision");

            POSSaleLine."Total Discount Amount" := CalcAmountWithVAT(POSSaleLine."Total Discount Amount",
                                                                     POSSaleLine."VAT %",
                                                                     GeneralLedgerSetup."Amount Rounding Precision");



        end else begin
            POSSaleLine."Disc. Amt. Without Total Disc." := CalcAmountWithoutVAT(POSSaleLine."Disc. Amt. Without Total Disc.",
                                                                                         POSSaleLine."VAT %",
                                                                                         GeneralLedgerSetup."Amount Rounding Precision");

            POSSaleLine."Total Discount Amount" := CalcAmountWithoutVAT(POSSaleLine."Total Discount Amount",
                                                                        POSSaleLine."VAT %",
                                                                        GeneralLedgerSetup."Amount Rounding Precision");

        end;

        POSSaleLine.Modify();

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'InitDiscountPriority', '', true, true)]
    local procedure OnInitDiscountPriority(var DiscountPriority: Record "NPR Discount Priority")
    begin
        GetOrInit(DiscountPriority);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'OnFindActiveSaleLineDiscounts', '', false, false)]
    local procedure OnFindActiveSaleLineDiscounts(var tmpDiscountPriority: Record "NPR Discount Priority" temporary;
                                                  Rec: Record "NPR POS Sale Line";
                                                  xRec: Record "NPR POS Sale Line";
                                                  LineOperation: Option Insert,Modify,Delete,Total)
    var
        DiscountPriority: Record "NPR Discount Priority";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        IsActive: Boolean;
    begin
        if not DiscountPriority.Get(DiscSourceTableId()) then
            exit;

        if not IsSubscribedDiscount(DiscountPriority) then
            exit;

        if LineOperation = LineOperation::Total then begin
            tmpDiscountPriority.Reset();
            if not tmpDiscountPriority.IsEmpty then
                tmpDiscountPriority.DeleteAll();
        end;

        FilterActiveTotalDiscountHeaders(NPRTotalDiscountHeader,
                                         Today);

        IsActive := not NPRTotalDiscountHeader.IsEmpty;

        if IsActive then begin
            tmpDiscountPriority.Init();
            tmpDiscountPriority := DiscountPriority;
            tmpDiscountPriority.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'OnFindActiveSaleLineDiscountsTotal', '', false, false)]
    local procedure OnFindActiveSaleLineDiscountsTotal(var tmpDiscountPriority: Record "NPR Discount Priority" temporary;
                                                       Rec: Record "NPR POS Sale Line";
                                                       xRec: Record "NPR POS Sale Line";
                                                       LineOperation: Option Insert,Modify,Delete,Total)
    var
        DiscountPriority: Record "NPR Discount Priority";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        IsActive: Boolean;
    begin
        if not DiscountPriority.Get(DiscSourceTableId()) then
            exit;

        if not IsSubscribedDiscount(DiscountPriority) then
            exit;

        if LineOperation <> LineOperation::Total then
            exit;

        tmpDiscountPriority.Reset();
        if not tmpDiscountPriority.IsEmpty then
            tmpDiscountPriority.DeleteAll();


        FilterActiveTotalDiscountHeaders(NPRTotalDiscountHeader,
                                         Today);

        IsActive := not NPRTotalDiscountHeader.IsEmpty;

        if IsActive then begin
            tmpDiscountPriority.Init();
            tmpDiscountPriority := DiscountPriority;
            tmpDiscountPriority.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterTransferToSalesLine', '', false, false)]
    local procedure OnAfterTransferToSalesLine(NPRPOSSaleLine: Record "NPR POS Sale Line"; var SaleLine: Record "Sales Line")
    begin
        SaleLine."NPR Total Discount Code" := NPRPOSSaleLine."Total Discount Code";
        SaleLine."NPR Total Discount Amount" := NPRPOSSaleLine."Total Discount Amount";
        SaleLine."NPR Total Discount Step" := NPRPOSSaleLine."Total Discount Step";
        SaleLine."NPR Benefit Item" := NPRPOSSaleLine."Benefit Item";
        SaleLine."NPR Disc Amt W/out Total Disc" := NPRPOSSaleLine."Disc. Amt. Without Total Disc.";
        SaleLine."NPR Benefit List Code" := NPRPOSSaleLine."Benefit List Code";
    end;
}