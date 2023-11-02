codeunit 6014559 "NPR TM Dynamic Price"
{
    Access = Internal;
    procedure CalculateTicketTokenUnitPrice(Token: Text[100]; TokenLineNumber: Integer; OriginalUnitPrice: Decimal; PriceIncludesVAT: Boolean; VatPercentage: Decimal; ReferenceDate: Date; ReferenceTime: Time) TicketUnitPrice: Decimal
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        BasePrice: Decimal;
        AddonPrice: Decimal;
    begin
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
        if (TicketReservationRequest.FindSet()) then begin
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

                if (TicketReservationRequest."Admission Inclusion" = TicketReservationRequest."Admission Inclusion"::REQUIRED) then
                    TicketUnitPrice += BasePrice + AddonPrice;

            until (TicketReservationRequest.Next() = 0);
        end;
        exit(TicketUnitPrice);
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
            HavePriceRule := SelectPriceRule(AdmissionScheduleEntry, BookingDateDate, BookingTime, PriceRule);
            if (HavePriceRule) then
                EvaluatePriceRule(PriceRule, OriginalUnitPrice, UnitPriceIncludesVAT, UnitPriceVatPercentage, IncludeBasePrice, BasePrice, AddonPrice);
        end;

        if (not HavePriceRule) then
            BasePrice := OriginalUnitPrice;

        if (not TicketBOM.Default) and (TicketBOM."Admission Inclusion" = TicketBOM."Admission Inclusion"::REQUIRED) then
            BasePrice := 0;
        exit(HavePriceRule);
    end;

    local procedure GetItemDefaultVat(ItemNo: Code[20]): Decimal
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

    local procedure RemoveVat(Amount: Decimal; VATPercentage: Decimal) NewAmount: Decimal
    begin
        NewAmount := Amount / ((100 + VATPercentage) / 100);
    end;

    local procedure AddVat(Amount: Decimal; VATPercentage: Decimal) NewAmount: Decimal
    begin
        NewAmount := Amount * ((100 + VATPercentage) / 100);
    end;

#pragma warning disable AA0137
    internal procedure SelectPriceRule(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; BookingDate: Date; BookingTime: Time; var SelectedPriceRule: Record "NPR TM Dynamic Price Rule"): Boolean
    var
        DynamicPriceRule: Record "NPR TM Dynamic Price Rule";
    begin

        DynamicPriceRule.SetFilter(ProfileCode, '=%1', AdmissionScheduleEntry."Dynamic Price Profile Code");
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

}