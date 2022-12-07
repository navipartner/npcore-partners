codeunit 6059839 "NPR POS Action: Board. Pass B"
{
    Access = Internal;
    procedure DecodeBoardingPassString(iBoardingPassString: Text; InfoCode: Text; iRequiredFromAirPortCode: Code[3]; RequiredTravelToday: Boolean; ShowTripMessage: Boolean; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSInfoManagement: Codeunit "NPR POS Info Management";
        NoOfLegs: Integer;
        PassengerName: Text;
        LegString: Text;
        TravelDescription: Text;
        TravelSaveString: Text;
        HexLengthOfFreeSection: Text[2];
        IntLengthOfFreeSection: Integer;
        LegStringArray: array[10] of Text;
        NewStartRead: Integer;
        CurrentLeg: Integer;
        FromAirportCode: Code[3];
        ToAirportCode: Code[3];
        OperatorFlightNo: Code[8];
        FlightDate: Date;
        oTravelStartDate: Date;
        oTravelEndDate: Date;
        PlaceHolderLbl: Label '%1\', Locked = true;
        PlaceHolder2Lbl: Label '\%1 > %2 (%3) %4', Locked = true;
        PlaceHolder3Lbl: Label '%1>%2(%3 %4) | ', Locked = true;
        NotValidErr: Label 'Scanned code can not be validated as boarding pass.';
        ApCodeErr: Label 'Boarding pass is not valid.\\Boarding pass does not include airport code %1.\\%2';
        TravelDateErr: Label 'Boarding pass is not valid.\\Travel date is not today (%1).\\%2';
    begin

        if not Evaluate(NoOfLegs, CopyStr(iBoardingPassString, 2, 1)) then
            Error(NotValidErr);

        if NoOfLegs = 0 then
            Error(NotValidErr);

        PassengerName := CopyStr(iBoardingPassString, 3, 20);

        LegString := CopyStr(iBoardingPassString, 24, 37);
        CurrentLeg := 1;
        NewStartRead := 61;
        LegStringArray[CurrentLeg] := LegString;

        while NoOfLegs > CurrentLeg do begin
            CurrentLeg := CurrentLeg + 1;
            HexLengthOfFreeSection := CopyStr(LegString, 36, 2);
            IntLengthOfFreeSection := HexToInt(HexLengthOfFreeSection);
            NewStartRead := NewStartRead + IntLengthOfFreeSection;
            LegString := CopyStr(iBoardingPassString, NewStartRead, 37);
            LegStringArray[CurrentLeg] := LegString;
        end;

        TravelDescription := StrSubstNo(PlaceHolderLbl, PassengerName);
        TravelSaveString := '';
        oTravelStartDate := 0D;
        oTravelEndDate := 0D;
        CurrentLeg := 1;
        repeat
            FromAirportCode := '';
            ToAirportCode := '';
            OperatorFlightNo := '';
            FlightDate := 0D;
            DecodeTravelLeg(LegStringArray[CurrentLeg], FromAirportCode, ToAirportCode, OperatorFlightNo, FlightDate);

            if (iRequiredFromAirPortCode <> '') and (iRequiredFromAirPortCode <> FromAirportCode) then
                Error(ApCodeErr, iRequiredFromAirPortCode, TravelDescription);

            if (FlightDate <> 0D) and (oTravelStartDate = 0D) then
                oTravelStartDate := FlightDate;

            if (FlightDate <> 0D) and (oTravelEndDate = 0D) then
                oTravelEndDate := FlightDate;

            if (FlightDate < oTravelStartDate) then
                oTravelStartDate := FlightDate;

            if (FlightDate > oTravelEndDate) then
                oTravelEndDate := FlightDate;

            if (RequiredTravelToday) and (FlightDate <> WorkDate()) then
                Error(TravelDateErr, WorkDate(), TravelDescription);

            if RequiredTravelToday and ((WorkDate() < oTravelStartDate) or (WorkDate() > oTravelEndDate)) then
                Error(TravelDateErr, WorkDate(), TravelDescription);

            TravelDescription := TravelDescription + StrSubstNo(PlaceHolder2Lbl, FromAirportCode, ToAirportCode, OperatorFlightNo, FlightDate);
            TravelSaveString := TravelSaveString + StrSubstNo(PlaceHolder3Lbl, FromAirportCode, ToAirportCode, OperatorFlightNo, FlightDate);

            CurrentLeg := CurrentLeg + 1;

        until (CurrentLeg > NoOfLegs);

        if ShowTripMessage then
            Message(TravelDescription);

        Sale.GetCurrentSale(SalePOS);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if InfoCode <> '' then
            POSInfoManagement.ProcessPOSInfoText(SaleLinePOS, SalePOS, CopyStr(InfoCode, 1, 20), TravelSaveString);

    end;

    local procedure HexToInt(HexValue: Text) Result: Integer
    var
        i, Base, Len, j : Integer;
    begin
        Base := 1;
        Result := 0;
        Len := STRLEN(HexValue);

        for i := 0 to Len - 1 do begin
            j := Len - i;
            if (HexValue[j] >= '0') AND (HexValue[j] <= '9') then begin
                Result := Result + (HexValue[j] - 48) * Base;
                Base := Base * 16;
            end else
                if (HexValue[j] >= 'A') and (HexValue[j] <= 'F') then begin
                    Result := Result + (HexValue[j] - 55) * Base;
                    Base := Base * 16;
                end;
        end;
    end;

    local procedure DecodeTravelLeg(iLegString: Text; var oFromAirportCode: Code[3]; var oToAirportCode: Code[3]; var oOperatorFlightNo: Code[8]; var oFlightDate: Date)
    var
        JulianFlightDateText: Text;
        JulianFlightDateInteger: Integer;
    begin

        oFromAirportCode := CopyStr(iLegString, 8, 3);
        oToAirportCode := CopyStr(iLegString, 11, 3);
        oOperatorFlightNo := CopyStr(iLegString, 14, 8);
        JulianFlightDateText := CopyStr(iLegString, 22, 3);
        if Evaluate(JulianFlightDateInteger, JulianFlightDateText) then begin
            oFlightDate := JulianDateToDate(JulianFlightDateInteger);
        end;
    end;

    local procedure JulianDateToDate(iJulianDate: Integer) oDate: Date
    var
        CalcDateFormula: Text;
        DateFormulaLbl: Label '<+%1D>', Locked = true;
    begin
        oDate := CalcDate('<-CY>', WorkDate());
        CalcDateFormula := StrSubstNo(DateFormulaLbl, iJulianDate - 1);
        oDate := CalcDate(CalcDateFormula, oDate);
    end;
}