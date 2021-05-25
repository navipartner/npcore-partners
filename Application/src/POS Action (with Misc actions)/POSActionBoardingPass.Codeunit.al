codeunit 6150837 "NPR POS Action: Boarding Pass"
{


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'POS Action for boarding pass scan';
        ERRNOTVALID: Label 'Scanned code can not be validated as boarding pass.';
        ERRAPCODE: Label 'Boarding pass is not valid.\\Boarding pass does not include airport code %1.\\%2';
        ERRTRAVELDATE: Label 'Boarding pass is not valid.\\Travel date is not today (%1).\\%2';
        Text000: Label 'Tax Free';
        Text001: Label 'Boarding Pass';

    local procedure "---POS Action functions"()
    begin
    end;

    local procedure ActionCode(): Text
    begin
        exit('BOARDINGPASS');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep(
              'boardingpass_input',
                'if(!param.BoardingPassString) {' +
                '  input({title: labels.BoardingPass,caption: labels.BoardingPass,value: param.BoardingPassString,notBlank: true}).cancel(abort);' +
                '} else {' +
                '  context.$boardingpass_input = {"input": param.BoardingPassString};' +
                '};');
            Sender.RegisterWorkflowStep('process', 'respond()');

            Sender.RegisterWorkflow(false);
            Sender.RegisterTextParameter('BoardingPassString', '');
            Sender.RegisterBooleanParameter('RequiredTravelToday', true);
            Sender.RegisterTextParameter('RequiredLegAirPortCode', '');
            Sender.RegisterBooleanParameter('ShowTripMessage', true);
            Sender.RegisterTextParameter('InfoCode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'BoardingPass', Text001);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupParameterPosInfo(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        POSInfo: Record "NPR POS Info";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'InfoCode' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        POSInfo.SetRange("Input Type", POSInfo."Input Type"::Text);
        POSInfo.SetRange(Type, POSInfo.Type::"Request Data");
        if PAGE.RunModal(0, POSInfo) = ACTION::LookupOK then
            POSParameterValue.Value := POSInfo.Code;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateParameterPosInfo(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        POSInfo: Record "NPR POS Info";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'InfoCode' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not POSInfo.Get(POSParameterValue.Value) then begin
            POSInfo.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            POSInfo.SetRange("Input Type", POSInfo."Input Type"::Text);
            POSInfo.SetRange(Type, POSInfo.Type::"Request Data");
            if POSInfo.FindFirst() then
                POSParameterValue.Value := POSInfo.Code;
        end;
        POSInfo.Get(POSParameterValue.Value);
        POSInfo.TestField("Input Type", POSInfo."Input Type"::Text);
        POSInfo.TestField(Type, POSInfo.Type::"Request Data");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        BoardingPassString: Text;
        RequiredTravelToday: Boolean;
        RequiredLegAirPortCode: Code[3];
        TravelStartDate: Date;
        TravelEndDate: Date;
        TravelDescription: Text;
        TravelSaveString: Text;
        RequiredLegAirPortCodeInTrip: Boolean;
        RequiredLegAirPortFlightDate: Date;
        ShowTripMessage: Boolean;
        InfoCode: Text;
        POSInfoManagement: Codeunit "NPR POS Info Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        SettingScopeErr: Label 'setting scope in %1';
        ReadingErr: Label 'reading in %1';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
        JSON.InitializeJObjectParser(Context, FrontEnd);

        JSON.SetScope('$boardingpass_input', StrSubstNo(SettingScopeErr, ActionCode()));
        BoardingPassString := JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, ActionCode()));
        JSON.SetScopeRoot();
        RequiredTravelToday := JSON.GetBooleanParameterOrFail('RequiredTravelToday', ActionCode());
        RequiredLegAirPortCode := JSON.GetStringParameterOrFail('RequiredLegAirPortCode', ActionCode());
        ShowTripMessage := JSON.GetBooleanParameterOrFail('ShowTripMessage', ActionCode());
        InfoCode := JSON.GetStringParameterOrFail('InfoCode', ActionCode());

        DecodeBoardingPassString(BoardingPassString, RequiredLegAirPortCode, RequiredLegAirPortCodeInTrip, RequiredLegAirPortFlightDate, TravelStartDate, TravelEndDate, TravelDescription, TravelSaveString);

        if (RequiredLegAirPortCode <> '') and (not RequiredLegAirPortCodeInTrip) then begin

            Error(ERRAPCODE, RequiredLegAirPortCode, TravelDescription);
        end;

        if (RequiredLegAirPortCode <> '') and (RequiredLegAirPortCodeInTrip) and (RequiredTravelToday) and (RequiredLegAirPortFlightDate <> WorkDate()) then begin
            Error(ERRTRAVELDATE, WorkDate(), TravelDescription);
        end;

        if RequiredTravelToday and ((WorkDate() < TravelStartDate) or (WorkDate() > TravelEndDate)) then begin
            Error(ERRTRAVELDATE, WorkDate(), TravelDescription);
        end;


        if ShowTripMessage then begin
            Message(TravelDescription);
        end;


        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if InfoCode <> '' then begin
            POSInfoManagement.ProcessPOSInfoText(SaleLinePOS, SalePOS, InfoCode, TravelSaveString);
        end;

        POSSession.RequestRefreshData();

        Handled := true;
    end;

    local procedure "--Processing"()
    begin
    end;

    local procedure DecodeBoardingPassString(iBoardingPassString: Text; iRequiredFromAirPortCode: Text; var oRequiredFromAirPortCodeInTrip: Boolean; var oRequiredFromAirPortFlightDate: Date; var oTravelStartDate: Date; var oTravelEndDate: Date; var oTravelDescription: Text; var oTravelSaveString: Text)
    var
        NoOfLegs: Integer;
        PassengerName: Text;
        LegString: Text;
        HexLengthOfFreeSection: Text[2];
        IntLengthOfFreeSection: Integer;
        LegStringArray: array[10] of Text;
        NewStartRead: Integer;
        CurrentLeg: Integer;
        FromAirportCode: Code[3];
        ToAirportCode: Code[3];
        OperatorFlightNo: Code[8];
        FlightDate: Date;
    begin

        if not Evaluate(NoOfLegs, CopyStr(iBoardingPassString, 2, 1)) then Error(ERRNOTVALID);
        if NoOfLegs = 0 then Error(ERRNOTVALID);

        oRequiredFromAirPortCodeInTrip := false;
        if (iBoardingPassString = '') then oRequiredFromAirPortCodeInTrip := true;

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

        oTravelDescription := StrSubstNo('%1\', PassengerName);
        oTravelSaveString := '';
        oTravelStartDate := 0D;
        oTravelEndDate := 0D;
        CurrentLeg := 1;
        repeat
            FromAirportCode := '';
            ToAirportCode := '';
            OperatorFlightNo := '';
            FlightDate := 0D;
            DecodeTravelLeg(LegStringArray[CurrentLeg], FromAirportCode, ToAirportCode, OperatorFlightNo, FlightDate);

            if (iRequiredFromAirPortCode <> '') and (FromAirportCode = iRequiredFromAirPortCode) then begin
                oRequiredFromAirPortCodeInTrip := true;
                oRequiredFromAirPortFlightDate := FlightDate;
            end;

            if (FlightDate <> 0D) and (oTravelStartDate = 0D) then oTravelStartDate := FlightDate;
            if (FlightDate <> 0D) and (oTravelEndDate = 0D) then oTravelEndDate := FlightDate;

            if (FlightDate < oTravelStartDate) then oTravelStartDate := FlightDate;
            if (FlightDate > oTravelEndDate) then oTravelEndDate := FlightDate;

            oTravelDescription := oTravelDescription + StrSubstNo('\%1 > %2 (%3) %4', FromAirportCode, ToAirportCode, OperatorFlightNo, FlightDate);
            oTravelSaveString := oTravelSaveString + StrSubstNo('%1>%2(%3 %4) | ', FromAirportCode, ToAirportCode, OperatorFlightNo, FlightDate);
            CurrentLeg := CurrentLeg + 1;
        until (CurrentLeg > NoOfLegs);
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

    local procedure JulianDateToDate(iJulianDate: Integer) oDate: Date
    var
        CalcDateFormula: Text;
    begin
        oDate := CalcDate('<-CY>', WorkDate());
        CalcDateFormula := StrSubstNo('<+%1D>', iJulianDate - 1);
        oDate := CalcDate(CalcDateFormula, oDate);
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    begin
        if not EanBoxEvent.Get(EventCodeBoardingPass()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeBoardingPass();
            EanBoxEvent."Module Name" := CopyStr(Text000, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(Text001, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeBoardingPass():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'BoardingPassString', true, '');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeBoardingPass(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeBoardingPass() then
            exit;

        if BarCodeIsBoardingPass(EanBoxValue) then
            InScope := true;
    end;

    local procedure EventCodeBoardingPass(): Code[20]
    begin
        exit('BOARDING_PASS');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Action: Boarding Pass");
    end;

    procedure BarCodeIsBoardingPass(Barcode: Text): Boolean
    var
        IntBuffer: Integer;
    begin
        if StrLen(Barcode) < 60 then
            exit(false);

        if UpperCase(CopyStr(Barcode, 1, 1)) <> 'M' then
            exit(false);

        if not Evaluate(IntBuffer, CopyStr(Barcode, 2, 1)) then
            exit(false);

        exit(true);
    end;
}

