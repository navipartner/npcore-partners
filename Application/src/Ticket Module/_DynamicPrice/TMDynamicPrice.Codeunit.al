codeunit 6014559 "NPR TM Dynamic Price"
{
    Access = Internal;
    internal procedure CalculatePrice(
        ItemNo: Code[20];
        VariantCode: Code[10];
        CustomerNo: Code[20];
        ReferenceDate: Date;
        ReferenceTime: Time;
        Quantity: Integer;
        var ErpUnitPrice: Decimal;
        var ErpDiscountPct: Decimal;
        var ErpUnitPriceIncludesVat: Boolean;
        var ErpUnitPriceVatPercentage: Decimal) TicketUnitPrice: Decimal
    var
    begin
        if (CalculateErpUnitPrice(ItemNo, VariantCode, CustomerNo, ReferenceDate, Quantity, ErpUnitPrice, ErpDiscountPct, ErpUnitPriceIncludesVat, ErpUnitPriceVatPercentage)) then
            TicketUnitPrice := CalculateTicketBomListPrice(ItemNo, VariantCode, ErpUnitPrice, ErpUnitPriceIncludesVat, ErpUnitPriceVatPercentage, ReferenceDate, ReferenceTime);
    end;

    internal procedure CalculatedTicketPriceAfterErpPrice(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        TicketUnitPrice: Decimal;
        Token: Text[100];
        TokenLineNumber: Integer;
        ForceItemAddOnUnitPrice: Boolean;
        DiscountAmount: Decimal;
        DiscountPercent: Decimal;
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin

        if (not IsTicketSalesLine(SaleLinePOS)) then
            exit;

        Sentry.StartSpan(Span, 'bc.ticket.calc-dynamic-price');

        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token, TokenLineNumber)) then begin
            if (SaleLinePOS.Indentation > 0) then begin
                // Addon price should might override ticket dynamic price
                SaleLinePOSAddOn.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.");
                SaleLinePOSAddOn.SetFilter("Register No.", '=%1', SaleLinePOS."Register No.");
                SaleLinePOSAddOn.SetFilter("Sales Ticket No.", '=%1', SaleLinePOS."Sales Ticket No.");
                SaleLinePOSAddOn.SetFilter("Sale Date", '=%1', SaleLinePOS.Date);
                SaleLinePOSAddOn.SetFilter("Sale Line No.", '=%1', SaleLinePOS."Line No.");
                if (SaleLinePOSAddOn.FindFirst()) then begin
                    if (SaleLinePOS."Discount %" <> 0) then begin
                        if (SaleLinePOSAddOn.DiscountAmount <> 0) then
                            DiscountAmount := SaleLinePOS."Discount Amount";
                        if (SaleLinePOSAddOn.DiscountPercent <> 0) then
                            DiscountPercent := saleLinePOS."Discount %";
                    end;

                    if (ItemAddOnLine.Get(SaleLinePOSAddOn."AddOn No.", SaleLinePOSAddOn."AddOn Line No.")) then
                        ForceItemAddOnUnitPrice := ((ItemAddOnLine."Use Unit Price" = ItemAddOnLine."Use Unit Price"::Always) or
                                                    ((ItemAddOnLine."Use Unit Price" = ItemAddOnLine."Use Unit Price"::"Non-Zero") and (ItemAddOnLine."Unit Price" <> 0)));
                end;
            end;

            if (ForceItemAddOnUnitPrice) then begin
                SaleLinePOS."Unit Price" := ItemAddOnLine."Unit Price";

            end else begin
                if (GetTicketUnitPrice(Token, TokenLineNumber, SaleLinePOS."Unit Price", SaleLinePOS."Price Includes VAT", SaleLinePOS."VAT %", TicketUnitPrice)) then
                    if (SaleLinePOS."Unit Price" <> TicketUnitPrice) then
                        SaleLinePOS."Unit Price" := TicketUnitPrice;
            end;

            if (not SaleLinePOS.IsTemporary) then begin
                if (DiscountAmount <> 0) then
                    SaleLinePOS.Validate("Discount Amount", DiscountAmount);

                if (DiscountPercent <> 0) then
                    SaleLinePOS.Validate("Discount %", DiscountPercent);
            end;

        end;

        Span.Finish();
    end;

    [TryFunction]
    internal procedure CalculateErpUnitPrice(
        ItemNo: Code[20];
        VariantCode: Code[10];
        CustomerNo: Code[20];
        ReferenceDate: Date;
        Quantity: Integer;
        var UnitPrice: Decimal;
        var DiscountPct: Decimal;
        var UnitPriceIncludesVat: Boolean;
        var UnitPriceVatPercentage: Decimal)
    var
        AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer";
    begin
        Clear(AdmCapacityPriceBuffer);
        AdmCapacityPriceBuffer.EntryNo := 1;
        AdmCapacityPriceBuffer.ItemNumber := ItemNo;
        AdmCapacityPriceBuffer.VariantCode := VariantCode;
        AdmCapacityPriceBuffer.CustomerNo := CustomerNo;
        AdmCapacityPriceBuffer.ReferenceDate := ReferenceDate;
        AdmCapacityPriceBuffer.Quantity := Quantity;

        CalculateErpPrice(AdmCapacityPriceBuffer);

        UnitPrice := AdmCapacityPriceBuffer.UnitPrice;
        DiscountPct := AdmCapacityPriceBuffer.DiscountPct;
        UnitPriceIncludesVat := AdmCapacityPriceBuffer.UnitPriceIncludesVat;
        UnitPriceVatPercentage := AdmCapacityPriceBuffer.UnitPriceVatPercentage;
    end;

    internal procedure CalculateErpPrice(var AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer") ValidErpPrice: Boolean
    var
        M2PriceService: Codeunit "NPR M2 POS Price WebService";
        TempSalePOS: Record "NPR POS Sale" temporary;
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
        OriginalWorkDate: Date;
    begin
        TempSalePOS."Sales Ticket No." := Format(AdmCapacityPriceBuffer.EntryNo);
        TempSalePOS."Customer No." := AdmCapacityPriceBuffer.CustomerNo;
        TempSalePOS.Date := AdmCapacityPriceBuffer.ReferenceDate;
        TempSalePOS.Insert();

        TempSaleLinePOS."Sales Ticket No." := TempSalePOS."Sales Ticket No.";
        TempSaleLinePOS."Line No." := AdmCapacityPriceBuffer.EntryNo;
        TempSaleLinePOS."Line Type" := TempSaleLinePOS."Line Type"::Item;
        TempSaleLinePOS."No." := AdmCapacityPriceBuffer.ItemNumber;
        TempSaleLinePOS."Variant Code" := AdmCapacityPriceBuffer.VariantCode;
        TempSaleLinePOS.Quantity := AdmCapacityPriceBuffer.Quantity;
        TempSaleLinePOS.Date := AdmCapacityPriceBuffer.ReferenceDate;
        TempSaleLinePOS."Allow Line Discount" := true;
        TempSaleLinePOS.Insert();

        OriginalWorkDate := WorkDate();
        WorkDate(AdmCapacityPriceBuffer.ReferenceDate);
        ValidErpPrice := M2PriceService.TryPosQuoteRequest(TempSalePOS, TempSaleLinePOS, TempTotalDiscBenItemBuffer);
        if (ValidErpPrice) then begin
            AdmCapacityPriceBuffer.UnitPrice := TempSaleLinePOS."Unit Price";
            AdmCapacityPriceBuffer.DiscountPct := TempSaleLinePOS."Discount %";
            AdmCapacityPriceBuffer.TotalDiscountAmount := TempSaleLinePOS."Discount Amount";
            AdmCapacityPriceBuffer.UnitPriceIncludesVat := TempSaleLinePOS."Price Includes VAT";
            AdmCapacityPriceBuffer.UnitPriceVatPercentage := TempSaleLinePOS."VAT %";
        end else begin
            AdmCapacityPriceBuffer.UnitPrice := 0;
            AdmCapacityPriceBuffer.DiscountPct := 0;
            AdmCapacityPriceBuffer.TotalDiscountAmount := 0;
            AdmCapacityPriceBuffer.UnitPriceIncludesVat := false;
            AdmCapacityPriceBuffer.UnitPriceVatPercentage := 0;
        end;
        WorkDate(OriginalWorkDate);
    end;

    procedure CalculateTicketTokenUnitPrice(Token: Text[100]; TokenLineNumber: Integer; OriginalUnitPrice: Decimal; PriceIncludesVAT: Boolean; VatPercentage: Decimal; ReferenceDate: Date; ReferenceTime: Time) TicketUnitPrice: Decimal
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        BasePrice: Decimal;
        AddonPrice: Decimal;
        PreviousTicketNo: Text[30];
    begin
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
        if (TicketReservationRequest.FindSet()) then begin
            PreviousTicketNo := TicketReservationRequest."External Ticket Number";

            repeat
                CalculateScheduleEntryPrice(
                    TicketReservationRequest."Item No.",
                    TicketReservationRequest."Variant Code",
                    TicketReservationRequest."Admission Code",
                    TicketReservationRequest."External Adm. Sch. Entry No.",
                    OriginalUnitPrice,
                    PriceIncludesVAT,
                    VatPercentage,
                    ReferenceDate,
                    ReferenceTime,
                    BasePrice,
                    AddonPrice
                );

                if (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::REVOKE) then
                    if (TicketReservationRequest."External Ticket Number" <> PreviousTicketNo) then
                        break;

                if (TicketReservationRequest."Admission Inclusion" = TicketReservationRequest."Admission Inclusion"::REQUIRED) then
                    TicketUnitPrice += BasePrice + AddonPrice;

                PreviousTicketNo := TicketReservationRequest."External Ticket Number";

            until (TicketReservationRequest.Next() = 0);
        end;
        exit(TicketUnitPrice);
    end;

    procedure CalculateTicketBomListPrice(ItemNo: Code[20]; VariantCode: Code[10]; OriginalUnitPrice: Decimal; PriceIncludesVAT: Boolean; VatPercentage: Decimal; ReferenceDate: Date; ReferenceTime: Time) TicketUnitPrice: Decimal
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        BasePrice: Decimal;
        AddonPrice: Decimal;
    begin
        AdmissionScheduleEntry.Reset();
        AdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");

        TicketBom.Reset();
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
        if (TicketBom.FindSet()) then begin
            repeat
                BasePrice := 0;
                AddonPrice := 0;
                AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TicketBom."Admission Code");
                AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
                AdmissionScheduleEntry.SetFilter("Admission Start Time", '<=%1', ReferenceTime);
                AdmissionScheduleEntry.SetFilter("Admission End Time", '>%1', ReferenceTime);
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindFirst()) then
                    CalculateScheduleEntryPrice(
                        TicketBom."Item No.",
                        TicketBom."Variant Code",
                        TicketBom."Admission Code",
                        AdmissionScheduleEntry."External Schedule Entry No.",
                        OriginalUnitPrice,
                        PriceIncludesVAT,
                        VatPercentage,
                        ReferenceDate,
                        ReferenceTime,
                        BasePrice,
                        AddonPrice
                    )
                else begin
                    if (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::REQUIRED) then
                        TicketUnitPrice += OriginalUnitPrice;
                end;

                if (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::REQUIRED) then
                    TicketUnitPrice += BasePrice + AddonPrice;

                if (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::SELECTED) then
                    TicketUnitPrice += AddonPrice;

            until (TicketBom.Next() = 0);
        end;
        exit(TicketUnitPrice);
    end;


    internal procedure SetTicketAdmissionDynamicUnitPrice(
        var ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AdmScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        OriginalUnitPrice: Decimal; DiscountPct: Decimal; PriceIncludesVAT: Boolean; VatPercentage: Decimal;
        ReferenceDateDate: DateTime)
    var
        PriceRule: Record "NPR TM Dynamic Price Rule";
        GeneralLedgerSetup: Record "General Ledger Setup";
        HavePriceRule: Boolean;
        DynamicPrice, BasePrice, AddonPrice : Decimal;
    begin

        if (AdmScheduleEntry."Entry No." > 0) and (AdmScheduleEntry."External Schedule Entry No." > 0) then
            HavePriceRule := SelectPriceRule(AdmScheduleEntry, ReservationRequest."Item No.", ReservationRequest."Variant Code", DT2Date(ReferenceDateDate), DT2Time(ReferenceDateDate), PriceRule);
        if (HavePriceRule) then
            EvaluatePriceRule(PriceRule, OriginalUnitPrice, PriceIncludesVAT, VatPercentage, false, BasePrice, AddonPrice);

        if ((not ReservationRequest."Primary Request Line") and (ReservationRequest."Admission Inclusion" = ReservationRequest."Admission Inclusion"::REQUIRED)) then
            OriginalUnitPrice := 0;

        ReservationRequest.UnitAmountInclVat := 0;
        ReservationRequest.UnitAmount := 0;
        DynamicPrice := OriginalUnitPrice;

        if (not HavePriceRule) then begin
            GeneralLedgerSetup.Get();
            PriceRule.RoundingPrecision := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
            PriceRule.RoundingDirection := GeneralLedgerSetup."Inv. Rounding Type (LCY)";
        end;

        if (HavePriceRule) then begin
            case (PriceRule.PricingOption) of
                PriceRule.PricingOption::NA:
                    DynamicPrice := OriginalUnitPrice;
                PriceRule.PricingOption::FIXED:
                    DynamicPrice := BasePrice;
                PriceRule.PricingOption::RELATIVE:
                    DynamicPrice := OriginalUnitPrice + AddonPrice;
                PriceRule.PricingOption::PERCENT:
                    DynamicPrice := OriginalUnitPrice + AddonPrice;
            end;
        end;

        DynamicPrice -= DynamicPrice * DiscountPct / 100;

        if (PriceIncludesVAT) then begin
            ReservationRequest.UnitAmountInclVat := RoundAmount(DynamicPrice, PriceRule.RoundingPrecision, PriceRule.RoundingDirection);
            ReservationRequest.UnitAmount := RoundAmount(RemoveVat(DynamicPrice, VatPercentage), PriceRule.RoundingPrecision, PriceRule.RoundingDirection);
        end else begin
            ReservationRequest.UnitAmount := RoundAmount(DynamicPrice, PriceRule.RoundingPrecision, PriceRule.RoundingDirection);
            ReservationRequest.UnitAmountInclVat := RoundAmount(AddVat(DynamicPrice, VatPercentage), PriceRule.RoundingPrecision, PriceRule.RoundingDirection);
        end;

        ReservationRequest.Amount := ReservationRequest.UnitAmount * ReservationRequest.Quantity;
        ReservationRequest.AmountInclVat := ReservationRequest.UnitAmountInclVat * ReservationRequest.Quantity;

    end;


    procedure CalculateTicketTokenUnitPrice(Token: Text[100]; OriginalUnitPrice: Decimal; PriceIncludesVAT: Boolean; VatPercentage: Decimal; ReferenceDate: Date; ReferenceTime: Time; var TempPriceRuleBuffer: Record "NPR TM Price Rule Buffer" temporary) TicketUnitPrice: Decimal
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        BasePriceOut: Decimal;
        AddonPriceOut: Decimal;
        TempSelectedPriceRuleOut: Record "NPR TM Dynamic Price Rule" temporary;
    begin
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                if (CalculateScheduleEntryPrice(
                        TicketReservationRequest."Item No.",
                        TicketReservationRequest."Variant Code",
                        TicketReservationRequest."Admission Code",
                        TicketReservationRequest."External Adm. Sch. Entry No.",
                        OriginalUnitPrice,
                        PriceIncludesVAT,
                        VatPercentage,
                        ReferenceDate,
                        ReferenceTime,
                        BasePriceOut,
                        AddonPriceOut,
                        TempSelectedPriceRuleOut)) then begin

                    if (TicketReservationRequest."Admission Inclusion" = TicketReservationRequest."Admission Inclusion"::REQUIRED) then
                        TicketUnitPrice += BasePriceOut + AddonPriceOut;

                    TempPriceRuleBuffer.ExtAdmissionScheduleEntryNo := TicketReservationRequest."External Adm. Sch. Entry No.";
                    TempPriceRuleBuffer.ProfileCode := TempSelectedPriceRuleOut.ProfileCode;
                    TempPriceRuleBuffer.LineNo := TempSelectedPriceRuleOut.LineNo;
                    TempPriceRuleBuffer.PricingOption := TempSelectedPriceRuleOut.PricingOption;
                    TempPriceRuleBuffer.Amount := TempSelectedPriceRuleOut.Amount;
                    TempPriceRuleBuffer.Percentage := TempSelectedPriceRuleOut.Percentage;
                    TempPriceRuleBuffer.AmountIncludesVAT := TempSelectedPriceRuleOut.AmountIncludesVAT;
                    TempPriceRuleBuffer.VatPercentage := TempSelectedPriceRuleOut.VatPercentage;
                    TempPriceRuleBuffer.BasePrice := BasePriceOut;
                    TempPriceRuleBuffer.AddonPrice := AddonPriceOut;
                    if (not TempPriceRuleBuffer.Insert()) then;
                end;

            until (TicketReservationRequest.Next() = 0);
        end;
        exit(TicketUnitPrice);
    end;


    procedure GetTicketUnitPrice(Token: Text[100]; TokenLineNumber: Integer; OriginalUnitPrice: Decimal; PriceIncludesVAT: Boolean; VatPercentage: Decimal; var NewTicketPrice: Decimal): Boolean
    begin
        NewTicketPrice := CalculateTicketTokenUnitPrice(Token, TokenLineNumber, OriginalUnitPrice, PriceIncludesVAT, VatPercentage, Today(), Time());
        exit((OriginalUnitPrice <> NewTicketPrice) and (NewTicketPrice >= 0));
    end;

    procedure CalculateRequiredTicketUnitPrice(TicketItemNo: Code[20]; TicketVariantCode: Code[10]; var Price: Decimal) HasPrice: Boolean
    var
        AdmissionScheduleEntryNo: Integer;
        BasePrice, AddOnPrice, TicketPrice : Decimal;
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmSchEntry: Record "NPR TM Admis. Schedule Entry";
        TicketTimeHelper: Codeunit "NPR TM TimeHelper";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketDynamicPrice: Codeunit "NPR TM Dynamic Price";
        CurrDT: DateTime;
    begin
        TicketBOM.SetRange("Item No.", TicketItemNo);
        TicketBOM.SetRange("Variant Code", TicketVariantCode);
        TicketBOM.SetRange("Admission Inclusion", TicketBOM."Admission Inclusion"::REQUIRED);
        if (not TicketBOM.FindSet()) then
            exit(false);

        repeat
            CurrDT := TicketTimeHelper.GetLocalTimeAtAdmission(TicketBOM."Admission Code");
            AdmissionScheduleEntryNo := TicketManagement.GetCurrentScheduleEntry(TicketItemNo, TicketVariantCode, TicketBOM."Admission Code", false, 1);
            if (AdmissionScheduleEntryNo > 0) then begin
                AdmSchEntry.SetLoadFields("External Schedule Entry No.");
                AdmSchEntry.Get(AdmissionScheduleEntryNo);

                TicketDynamicPrice.CalculateScheduleEntryPrice(
                    TicketItemNo,
                    TicketVariantCode,
                    TicketBOM."Admission Code",
                    AdmSchEntry."External Schedule Entry No.",
                    DT2Date(CurrDT),
                    DT2Time(CurrDT),
                    BasePrice,
                    AddOnPrice
               );

                TicketPrice += (BasePrice + AddOnPrice);
            end;
        until (TicketBOM.Next() = 0);

        Price := RoundAmount(TicketPrice, 0, 0 /* nearest */);
        exit(true);
    end;

    procedure CalculateScheduleEntryPrice(TicketItemNo: Code[20]; TicketVariantCode: Code[10]; AdmissionCode: Code[20]; ExternalScheduleEntryNo: Integer; BookingDateDate: Date; BookingTime: Time; var BasePrice: Decimal; var AddonPrice: Decimal) HavePriceRule: Boolean
    var
        Item: Record "Item";
        SelectedPriceRule: Record "NPR TM Dynamic Price Rule";
    begin
        if (not Item.Get(TicketItemNo)) then
            exit;

        HavePriceRule := CalculateScheduleEntryPrice(
                            TicketItemNo,
                            TicketVariantCode,
                            AdmissionCode,
                            ExternalScheduleEntryNo,
                            Item."Unit Price",
                            Item."Price Includes VAT",
                            GetItemDefaultVat(TicketItemNo),
                            BookingDateDate,
                            BookingTime,
                            BasePrice,
                            AddonPrice,
                            SelectedPriceRule
                        );
    end;

    procedure CalculateScheduleEntryErpPrice(TicketItemNo: Code[20]; TicketVariantCode: Code[10]; AdmissionCode: Code[20]; ExternalScheduleEntryNo: Integer; BookingDateDate: Date; BookingTime: Time; var BasePrice: Decimal; var AddonPrice: Decimal) HavePriceRule: Boolean
    var
        Item: Record "Item";
        SelectedPriceRule: Record "NPR TM Dynamic Price Rule";
        UnitPrice: Decimal;
        DiscountPct: Decimal;
        UnitPriceIncludesVat: Boolean;
        UnitPriceVatPercentage: Decimal;
    begin
        if (not Item.Get(TicketItemNo)) then
            exit;

        CalculateErpUnitPrice(TicketItemNo, TicketVariantCode, '', BookingDateDate, 1, UnitPrice, DiscountPct, UnitPriceIncludesVat, UnitPriceVatPercentage);

        HavePriceRule := CalculateScheduleEntryPrice(
                            TicketItemNo,
                            TicketVariantCode,
                            AdmissionCode,
                            ExternalScheduleEntryNo,
                            UnitPrice,
                            UnitPriceIncludesVat,
                            UnitPriceVatPercentage,
                            BookingDateDate,
                            BookingTime,
                            BasePrice,
                            AddonPrice,
                            SelectedPriceRule
                        );
    end;


    procedure CalculateScheduleEntryPrice(TicketItemNo: Code[20]; TicketVariantCode: Code[10]; AdmissionCode: Code[20]; ExternalScheduleEntryNo: Integer; OriginalUnitPrice: Decimal; UnitPriceIncludesVAT: Boolean; UnitPriceVatPercentage: Decimal; BookingDateDate: Date; BookingTime: Time; var BasePrice: Decimal; var AddonPrice: Decimal) HavePriceRule: Boolean
    var
        SelectedPriceRule: Record "NPR TM Dynamic Price Rule";
    begin
        HavePriceRule := CalculateScheduleEntryPrice(
                           TicketItemNo,
                           TicketVariantCode,
                           AdmissionCode,
                           ExternalScheduleEntryNo,
                           OriginalUnitPrice,
                           UnitPriceIncludesVat,
                           UnitPriceVatPercentage,
                           BookingDateDate,
                           BookingTime,
                           BasePrice,
                           AddonPrice,
                           SelectedPriceRule
                       );
    end;

    procedure CalculateScheduleEntryPrice(TicketItemNo: Code[20]; TicketVariantCode: Code[10]; AdmissionCode: Code[20]; ExternalScheduleEntryNo: Integer; OriginalUnitPrice: Decimal; UnitPriceIncludesVAT: Boolean; UnitPriceVatPercentage: Decimal; BookingDateDate: Date; BookingTime: Time; var BasePrice: Decimal; var AddonPrice: Decimal; var SelectedPriceRule: Record "NPR TM Dynamic Price Rule") HavePriceRule: Boolean
    var
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        PriceRule: Record "NPR TM Dynamic Price Rule";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Item: Record Item;
        IncludeBasePrice: Boolean;
    begin
        if (not Admission.Get(AdmissionCode)) then
            Admission.Init();

        if (not TicketBOM.Get(TicketItemNo, TicketVariantCode, AdmissionCode)) then
            TicketBOM.Init();

        BasePrice := 0;
        AddonPrice := 0;

        IncludeBasePrice := TicketBOM.Default;

        // Get different unit price from admission. 
        if (Admission."Additional Experience Item No." <> '') then begin
            Item.Get(Admission."Additional Experience Item No.");

            OriginalUnitPrice := Item."Unit Price";
            UnitPriceVatPercentage := GetItemDefaultVat(Item."No.");
            if Item."Price Includes VAT" and not UnitPriceIncludesVAT then
                OriginalUnitPrice := RemoveVat(Item."Unit Price", UnitPriceVatPercentage);
            if not Item."Price Includes VAT" and UnitPriceIncludesVAT then
                OriginalUnitPrice := AddVat(Item."Unit Price", UnitPriceVatPercentage);
            IncludeBasePrice := true;
        end;

        HavePriceRule := false;
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExternalScheduleEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (AdmissionScheduleEntry.FindLast()) then begin
            HavePriceRule := SelectPriceRule(AdmissionScheduleEntry, TicketItemNo, TicketVariantCode, BookingDateDate, BookingTime, PriceRule);
            if (HavePriceRule) then
                EvaluatePriceRule(PriceRule, OriginalUnitPrice, UnitPriceIncludesVAT, UnitPriceVatPercentage, IncludeBasePrice, BasePrice, AddonPrice);
        end;

        if (not HavePriceRule) then
            BasePrice := OriginalUnitPrice;

        if (not TicketBOM.Default) and (TicketBOM."Admission Inclusion" = TicketBOM."Admission Inclusion"::REQUIRED) then
            BasePrice := 0;
        exit(HavePriceRule);
    end;

    internal procedure GetItemDefaultVat(ItemNo: Code[20]): Decimal
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
    begin
        if (not Item.Get(ItemNo)) then
            exit(0);

        VATPostingSetup.SetFilter("VAT Bus. Posting Group", '=%1', Item."VAT Bus. Posting Gr. (Price)");
        VATPostingSetup.SetFilter("VAT Prod. Posting Group", '=%1', Item."VAT Prod. Posting Group");
        if (not VATPostingSetup.FindFirst()) then
            exit(0);

        exit(VATPostingSetup."VAT %");
    end;

    internal procedure EvaluatePriceRule(PriceRule: Record "NPR TM Dynamic Price Rule"; UnitPrice: Decimal; UnitPriceIncludesVAT: Boolean; UnitPriceVatPercentage: Decimal; UnitPriceIsDefaultBasePrice: Boolean; var BasePrice: Decimal; var AddonPrice: Decimal);
    var
        UnitPriceExVat, RuleAmountExVat : Decimal;
    begin
        BasePrice := 0;
        AddonPrice := 0;

        UnitPriceExVat := UnitPrice;
        if (UnitPriceIncludesVAT) then
            UnitPriceExVat := RemoveVat(UnitPrice, UnitPriceVatPercentage);

        RuleAmountExVat := PriceRule.Amount;
        if (PriceRule.AmountIncludesVAT) then
            RuleAmountExVat := RemoveVat(PriceRule.Amount, PriceRule.VatPercentage);

        if (UnitPriceIsDefaultBasePrice) then
            BasePrice := UnitPriceExVat;


        case (PriceRule.PricingOption) of
            PriceRule.PricingOption::NA:
                ;
            PriceRule.PricingOption::FIXED: // final price is base
                BasePrice := RuleAmountExVat;

            PriceRule.PricingOption::PERCENT: // final price is unit price +/- a percentage
                AddonPrice := (UnitPriceExVat * PriceRule.Percentage / 100);

            PriceRule.PricingOption::RELATIVE: // final price is base + addon
                AddonPrice := RuleAmountExVat;
        end;

        // VAT Adjust
        if (UnitPriceIncludesVAT) then begin
            BasePrice := AddVat(BasePrice, UnitPriceVatPercentage);
            AddonPrice := AddVat(AddonPrice, UnitPriceVatPercentage);
        end;

        BasePrice := RoundAmount(BasePrice, PriceRule.RoundingPrecision, PriceRule.RoundingDirection);
        AddonPrice := RoundAmount(AddonPrice, PriceRule.RoundingPrecision, PriceRule.RoundingDirection);
    end;

    procedure RoundAmount(Amount: Decimal; Precision: Decimal; Direction: Option): Decimal
    var
        PriceRule: Record "NPR TM Dynamic Price Rule";
    begin
        if (Precision <= 0) then
            Precision := 0.01;

        if ((Direction < PriceRule.RoundingDirection::Nearest) or (Direction > PriceRule.RoundingDirection::Down)) then
            Direction := PriceRule.RoundingDirection::Nearest;

        if (Direction = PriceRule.RoundingDirection::Nearest) then
            exit(Round(Amount, Precision, '='));
        if (Direction = PriceRule.RoundingDirection::Up) then
            exit(Round(Amount, Precision, '>'));
        if (Direction = PriceRule.RoundingDirection::Down) then
            exit(Round(Amount, Precision, '<'));
    end;


    internal procedure FindPriceProfiles(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; var TempPriceRules: Record "NPR TM DynamicPriceItemList" temporary): Boolean
    var
        DynamicPriceList: Record "NPR TM DynamicPriceItemList";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmissionScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        if (not TempPriceRules.IsTemporary) then
            Error('This function must only be called on a temporary record.');

        // Current item price profiles
        DynamicPriceList.SetFilter(ItemNo, '=%1', ItemNo);
        if (DynamicPriceList.FindSet()) then begin
            repeat
                TempPriceRules.TransferFields(DynamicPriceList, true);
                TempPriceRules.SystemId := DynamicPriceList.SystemId;
                if (not TempPriceRules.Insert()) then;
            until (DynamicPriceList.Next() = 0);
        end;

        // All item price profiles
        TicketBOM.SetFilter("Item No.", '=%1', ItemNo);
        if (VariantCode <> '') then
            TicketBOM.SetFilter("Variant Code", '=%1', VariantCode);
        if (AdmissionCode <> '') then
            TicketBOM.SetFilter("Admission Code", '=%1', AdmissionCode);

        if (TicketBOM.FindSet()) then begin
            repeat
                AdmissionScheduleLine.SetCurrentKey("Admission Code", "Schedule Code");
                AdmissionScheduleLine.SetFilter("Admission Code", '=%1', TicketBOM."Admission Code");
                if (AdmissionScheduleLine.FindSet()) then begin
                    repeat
                        TempPriceRules.Init();
                        TempPriceRules.ItemNo := ItemNo;
                        TempPriceRules.VariantCode := TicketBOM."Variant Code";
                        TempPriceRules.AdmissionCode := TicketBOM."Admission Code";
                        TempPriceRules.ScheduleCode := AdmissionScheduleLine."Schedule Code";
                        if (not TempPriceRules.Insert()) then;
                    until (AdmissionScheduleLine.Next() = 0);
                end;
            until (TicketBOM.Next() = 0);
        end;

        exit(not TempPriceRules.IsEmpty());
    end;

    internal procedure FindPriceProfiles(AdmissionCode: Code[20]; ScheduleCode: Code[20]; var TempPriceRules: Record "NPR TM DynamicPriceItemList" temporary): Boolean
    var
        DynamicPriceList: Record "NPR TM DynamicPriceItemList";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmissionScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        if (not TempPriceRules.IsTemporary) then
            Error('This function must only be called on a temporary record.');

        // Current item price profiles
        DynamicPriceList.SetFilter(AdmissionCode, '=%1', AdmissionCode);
        if (ScheduleCode <> '') then
            DynamicPriceList.SetFilter(ScheduleCode, '=%1', ScheduleCode);
        if (DynamicPriceList.FindSet()) then begin
            repeat
                TempPriceRules.TransferFields(DynamicPriceList, true);
                TempPriceRules.SystemId := DynamicPriceList.SystemId;
                if (not TempPriceRules.Insert()) then;
            until (DynamicPriceList.Next() = 0);
        end;

        TicketBOM.SetCurrentKey("Admission Code");
        TicketBOM.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (TicketBOM.FindSet()) then begin
            repeat
                AdmissionScheduleLine.SetCurrentKey("Admission Code", "Schedule Code");
                AdmissionScheduleLine.SetFilter("Admission Code", '=%1', AdmissionCode);
                if (ScheduleCode <> '') then
                    AdmissionScheduleLine.SetFilter("Schedule Code", '=%1', ScheduleCode);
                if (AdmissionScheduleLine.FindSet()) then begin
                    repeat
                        TempPriceRules.Init();
                        TempPriceRules.ItemNo := TicketBOM."Item No.";
                        TempPriceRules.VariantCode := TicketBOM."Variant Code";
                        TempPriceRules.AdmissionCode := TicketBOM."Admission Code";
                        TempPriceRules.ScheduleCode := AdmissionScheduleLine."Schedule Code";
                        if (not TempPriceRules.Insert()) then;
                    until (AdmissionScheduleLine.Next() = 0);
                end;
            until (TicketBOM.Next() = 0);
        end;

        exit(not TempPriceRules.IsEmpty());
    end;

    internal procedure FindPriceProfiles(ProfileCode: Code[20]; var TempPriceRules: Record "NPR TM DynamicPriceItemList" temporary): Boolean
    var
        DynamicPriceList: Record "NPR TM DynamicPriceItemList";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmissionScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        if (not TempPriceRules.IsTemporary) then
            Error('This function must only be called on a temporary record.');

        // Current item price profiles
        DynamicPriceList.SetFilter(ItemPriceCode, '=%1', ProfileCode);
        if (DynamicPriceList.FindSet()) then begin
            repeat
                TempPriceRules.TransferFields(DynamicPriceList, true);
                TempPriceRules.SystemId := DynamicPriceList.SystemId;
                if (not TempPriceRules.Insert()) then;
            until (DynamicPriceList.Next() = 0);
        end;

        AdmissionScheduleLine.SetFilter("Dynamic Price Profile Code", '=%1', ProfileCode);
        if (AdmissionScheduleLine.FindSet()) then begin
            repeat
                TicketBOM.SetCurrentKey("Admission Code");
                TicketBOM.SetFilter("Admission Code", '=%1', AdmissionScheduleLine."Admission Code");
                if (TicketBOM.FindSet()) then begin
                    repeat
                        TempPriceRules.Init();
                        TempPriceRules.ItemNo := TicketBOM."Item No.";
                        TempPriceRules.VariantCode := TicketBOM."Variant Code";
                        TempPriceRules.AdmissionCode := TicketBOM."Admission Code";
                        TempPriceRules.ScheduleCode := AdmissionScheduleLine."Schedule Code";
                        if (DynamicPriceList.Get(TempPriceRules.ItemNo, TempPriceRules.VariantCode, TempPriceRules.AdmissionCode, TempPriceRules.ScheduleCode)) then begin
                            TempPriceRules.TransferFields(DynamicPriceList, true);
                            TempPriceRules.SystemId := DynamicPriceList.SystemId;
                        end;
                        if (not TempPriceRules.Insert()) then;
                    until (TicketBOM.Next() = 0);
                end;
            until (AdmissionScheduleLine.Next() = 0);
        end;

        exit(not TempPriceRules.IsEmpty());
    end;

    local procedure RemoveVat(Amount: Decimal; VATPercentage: Decimal) NewAmount: Decimal
    begin
        NewAmount := Amount / ((100 + VATPercentage) / 100);
    end;

    local procedure AddVat(Amount: Decimal; VATPercentage: Decimal) NewAmount: Decimal
    begin
        NewAmount := Amount * ((100 + VATPercentage) / 100);
    end;

#pragma warning disable AA0137
    internal procedure SelectPriceRule(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; ItemNo: Code[20]; VariantCode: Code[10]; BookingDate: Date; BookingTime: Time; var SelectedPriceRule: Record "NPR TM Dynamic Price Rule"): Boolean
    var
        DynamicPriceRule: Record "NPR TM Dynamic Price Rule";
        ItemProfileList: Record "NPR TM DynamicPriceItemList";
        PriceProfileCode: Code[10];
    begin

        PriceProfileCode := AdmissionScheduleEntry."Dynamic Price Profile Code";

        if (ItemProfileList.Get(ItemNo, VariantCode, AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code")) then
            if (ItemProfileList.ItemPriceCode <> '') then
                PriceProfileCode := ItemProfileList.ItemPriceCode;

        DynamicPriceRule.SetFilter(ProfileCode, '=%1', PriceProfileCode);
        DynamicPriceRule.SetFilter(Blocked, '=%1', false);
        if (not DynamicPriceRule.FindFirst()) then begin
            SelectedPriceRule.Init();
            SelectedPriceRule.Blocked := true;
            exit(false);
        end;

        SelectedPriceRule.TransferFields(DynamicPriceRule, true);
        if (DynamicPriceRule.Count() = 1) then
            exit(ValidatePriceRule(SelectedPriceRule, BookingDate, AdmissionScheduleEntry."Admission Start Date"));

        SelectedPriceRule.Init();
        SelectedPriceRule.Blocked := true;

        DynamicPriceRule.SetFilter(BookingDateFrom, '<=%1', BookingDate);
        DynamicPriceRule.SetFilter(BookingDateUntil, '>=%1|=%2', BookingDate, 0D);
        DynamicPriceRule.SetFilter(EventDateFrom, '<=%1', AdmissionScheduleEntry."Admission Start Date");
        DynamicPriceRule.SetFilter(EventDateUntil, '>=%1|=%2', AdmissionScheduleEntry."Admission End Date", 0D);
        if (not DynamicPriceRule.FindSet()) then
            exit(false);

        repeat
            if (ValidatePriceRule(DynamicPriceRule, BookingDate, AdmissionScheduleEntry."Admission Start Date")) then
                CompareAndSelectPriceRule(DynamicPriceRule, SelectedPriceRule);
        until (DynamicPriceRule.Next() = 0);

        exit(ValidatePriceRule(SelectedPriceRule, BookingDate, AdmissionScheduleEntry."Admission Start Date"));
    end;
#pragma warning restore AA0137
    local procedure ValidatePriceRule(DynamicPriceRule: Record "NPR TM Dynamic Price Rule"; BookingDate: Date; EventDate: Date): Boolean
    begin
        if (DynamicPriceRule.Blocked) then
            exit(false);

        if (not ((DynamicPriceRule.BookingDateFrom <= BookingDate) and ((DynamicPriceRule.BookingDateUntil >= BookingDate) or (DynamicPriceRule.BookingDateUntil = 0D)))) then
            exit(false);

        if (not ((DynamicPriceRule.EventDateFrom <= EventDate) and ((DynamicPriceRule.EventDateUntil >= EventDate) or (DynamicPriceRule.EventDateUntil = 0D)))) then
            exit(false);

        if (not ValidateRelativeDate(DynamicPriceRule.RelativeBookingDateFormula, BookingDate)) then
            exit(false);

        if (not ValidateRelativeDate(DynamicPriceRule.RelativeEventDateFormula, EventDate)) then
            exit(false);

        if (GetDateFormulaPriorityWeight(DynamicPriceRule.RelativeUntilEventDate) > 0) then
            if (CalcDate(DynamicPriceRule.RelativeUntilEventDate, BookingDate) < EventDate) then
                exit(false);

        exit(true);
    end;

    local procedure ValidateRelativeDate(RelativeDateFormula: DateFormula; ReferenceDate: Date): Boolean
    var
        DateHelper: date;
    begin
        if (ReferenceDate = 0D) then
            exit(false);

        // IMPORTANT: On the 15th D15 evaluates to the 15th next month. WD5 on a Friday is Friday 7 days from now
        // To get at "D15" rule to work, it needs to be entered as D15 - 1M
        // D28..D31 in January would return February 28. Thus with a relative booking date of "D31-1M" it would be valid on January 28.
        // Relative DF include WD1 == Monday, D15 == 15th every month, M5 == May 01, etc
        DateHelper := CalcDate(RelativeDateFormula, ReferenceDate);

        case (GetDateFormulaPriorityWeight(RelativeDateFormula)) of
            0: // blank
                exit(true);
            1: // Year
                exit(Date2DMY(ReferenceDate, 3) = Date2DMY(DateHelper, 3));
            4: // Quarter
                exit(not ((DateHelper < ReferenceDate) or (CalcDate(RelativeDateFormula, CalcDate('<-1Q>', ReferenceDate)) > ReferenceDate)));
            7: // Weekday
                exit(CalcDate('<-1W>', DateHelper) = ReferenceDate);
            12: // Month
                exit(Date2DMY(ReferenceDate, 2) = Date2DMY(DateHelper, 2));
            30: // Day
                begin
                    // Selecting DateHelper month January as it has 31 days. 
                    // Since <D31> in April will actually return 0430
                    DateHelper := CalcDate(RelativeDateFormula, DMY2Date(1, 1, 2024));
                    exit(Date2DMY(ReferenceDate, 1) = Date2DMY(DateHelper, 1));
                end;
            52: // WeekNumber
                exit(not ((DateHelper < ReferenceDate) or (CalcDate(RelativeDateFormula, CalcDate('<-1W>', ReferenceDate)) > ReferenceDate)));
            365: // Specific date
                exit(CalcDate(RelativeDateFormula, ReferenceDate) = ReferenceDate);
            else
                exit(CalcDate(RelativeDateFormula, ReferenceDate) = ReferenceDate);
        end;
    end;

    local procedure CompareAndSelectPriceRule(NewPriceRule: Record "NPR TM Dynamic Price Rule"; var SelectedPriceRule: Record "NPR TM Dynamic Price Rule"): Boolean
    begin
        if (SelectedPriceRule.Blocked) then begin
            if (NewPriceRule.Blocked) then
                exit(false);

            SelectedPriceRule.TransferFields(NewPriceRule, true);
            exit(true);
        end;

        // If the new rule has a wider total date range span, it can be discarded
        if (NewPriceRule.RuleRangeSize() > SelectedPriceRule.RuleRangeSize()) then
            exit(false);

        if (GetDateFormulaPriorityWeight(NewPriceRule.RelativeBookingDateFormula) < GetDateFormulaPriorityWeight(SelectedPriceRule.RelativeBookingDateFormula)) then
            exit(false);

        if (GetDateFormulaPriorityWeight(NewPriceRule.RelativeEventDateFormula) < GetDateFormulaPriorityWeight(SelectedPriceRule.RelativeEventDateFormula)) then
            exit(false);

        if (GetDateFormulaPriorityWeight(NewPriceRule.RelativeUntilEventDate) < GetDateFormulaPriorityWeight(SelectedPriceRule.RelativeUntilEventDate)) then
            exit(false);

        // Which date formula is the smaller of the two.
        if ((GetDateFormulaPriorityWeight(NewPriceRule.RelativeUntilEventDate) > 0) and (GetDateFormulaPriorityWeight(SelectedPriceRule.RelativeUntilEventDate) > 0)) then
            if ((CalcDate(NewPriceRule.RelativeUntilEventDate) - Today()) > (CalcDate(SelectedPriceRule.RelativeUntilEventDate) - Today())) then
                exit(false);

        // if everything is equal, bias is higher line number to make it deterministic. 
        if (NewPriceRule.LineNo < SelectedPriceRule.LineNo) then
            exit(false);

        SelectedPriceRule.TransferFields(NewPriceRule, true);
        exit(true);
    end;

    local procedure GetDateFormulaPriorityWeight(RelativeDateFormula: DateFormula) Weight: Integer
    var
        BlankDateFormula: DateFormula;
        DateFormulaText: Text;
    begin
        if (RelativeDateFormula = BlankDateFormula) then
            exit(0);

        DateFormulaText := Format(RelativeDateFormula, 0, 9);
        if (StrPos(DateFormulaText, '+') > 0) or (StrPos(DateFormulaText, '-') > 0) then
            exit(365);

        case (CopyStr(DateFormulaText, 1, 1)) of
            'D':
                Weight := 30;
            'M':
                Weight := 12;
            'Q':
                Weight := 4;
            'Y':
                Weight := 1;
            'W':
                if (CopyStr(DateFormulaText, 2, 1) = 'D') then
                    Weight := 7 else
                    Weight := 52;
            'C':
                Weight := 365; // User did their own relative calculation
            else
                Weight := 365; // Failsafe
        end;
    end;

    local procedure GetRequestToken(ReceiptNo: Code[20]; LineNumber: Integer; var Token: Text[100]; var TokenLineNumber: Integer): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        Token := '';

        if (ReceiptNo = '') then
            exit(false);

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        TicketReservationRequest.ReadIsolation(IsolationLevel::ReadUncommitted);
#ENDIF
        TicketReservationRequest.SetCurrentKey("Receipt No.");
        TicketReservationRequest.SetFilter("Receipt No.", '=%1', ReceiptNo);
        TicketReservationRequest.SetFilter("Line No.", '=%1', LineNumber);
        TicketReservationRequest.SetLoadFields("Session Token ID", "Ext. Line Reference No.");
        if (TicketReservationRequest.FindFirst()) then begin
            Token := TicketReservationRequest."Session Token ID";
            TokenLineNumber := TicketReservationRequest."Ext. Line Reference No.";
        end;

        exit(Token <> '');
    end;


    local procedure IsTicketSalesLine(SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
        Item: Record Item;
    begin
        if (not Item.Get(SaleLinePOS."No.")) then
            exit(false);

        if (Item."NPR Ticket Type" = '') then
            exit(false);

        if (not TicketType.Get(Item."NPR Ticket Type")) then
            exit(false);

        exit(true);
    end;

}