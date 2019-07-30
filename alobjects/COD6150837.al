codeunit 6150837 "POS Action - Boarding Pass"
{
    // NPR5.380/ANEN  /20171117 CASE 296330 Created to scan IATA boarding pass in POS text enter
    // NPR5.45/MHA /20180814  CASE 319706 Deleted function BoardingPassPatternSubscriber()
    // NPR5.49/MHA /20190220  CASE 344084 Added  workflowstep for input of BoardingPassString and Ean Box Event Subscriber


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'POS Action for boarding pass scan';
        ERRNOTVALID: Label 'Scanned code can not be validated as boarding pass.';
        ERRAPCODE: Label 'Boarding pass is not valid.\\Boarding pass does not include airport code %1.\\%2';
        ERR: Label 'Error';
        ERRTRAVELDATE: Label 'Boarding pass is not valid.\\Travel date is not today (%1).\\%2';
        TXTBPASS: Label 'Scanned Boarding Pass';
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
        //-NPR5.49 [344084]
        exit('1.1');
        //+NPR5.49 [344084]
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                //-NPR5.49 [344084]
                Sender.RegisterWorkflowStep(
                  'boardingpass_input',
                    'if(!param.BoardingPassString) {' +
                    '  input({title: labels.BoardingPass,caption: labels.BoardingPass,value: param.BoardingPassString,notBlank: true}).cancel(abort);' +
                    '} else {' +
                    '  context.$boardingpass_input = {"input": param.BoardingPassString};' +
                    '};');
                //+NPR5.49 [344084]
                RegisterWorkflowStep('process', 'respond()');

                RegisterWorkflow(false);
                //-NPR5.49 [344084]
                //RegisterDataBinding();
                //+NPR5.49 [344084]
                RegisterTextParameter('BoardingPassString', '');
                RegisterBooleanParameter('RequiredTravelToday', true);
                RegisterTextParameter('RequiredLegAirPortCode', '');
                RegisterBooleanParameter('ShowTripMessage', true);
                RegisterTextParameter('InfoCode', '');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        //-NPR5.49 [344084]
        Captions.AddActionCaption(ActionCode(), 'BoardingPass', Text001);
        //+NPR5.49 [344084]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupParameterPosInfo(var POSParameterValue: Record "POS Parameter Value"; Handled: Boolean)
    var
        POSInfo: Record "POS Info";
    begin
        //-NPR5.49 [344084]
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
        //+NPR5.49 [344084]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateParameterPosInfo(var POSParameterValue: Record "POS Parameter Value")
    var
        POSInfo: Record "POS Info";
    begin
        //-NPR5.49 [344084]
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
            if POSInfo.FindFirst then
                POSParameterValue.Value := POSInfo.Code;
        end;
        POSInfo.Get(POSParameterValue.Value);
        POSInfo.TestField("Input Type", POSInfo."Input Type"::Text);
        POSInfo.TestField(Type, POSInfo.Type::"Request Data");
        //+NPR5.49 [344084]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: DotNet JObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        SaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
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
        POSInfoManagement: Codeunit "POS Info Management";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        //-NPR5.49 [344084]
        Handled := true;
        //+NPR5.49 [344084]
        JSON.InitializeJObjectParser(Context, FrontEnd);
        //-NPR5.49 [344084]
        //BoardingPassString := JSON.GetStringParameter('BoardingPassString',TRUE);
        JSON.SetScope('$boardingpass_input', true);
        BoardingPassString := JSON.GetString('input', true);
        JSON.SetScope('/', true);
        //+NPR5.49 [344084]
        RequiredTravelToday := JSON.GetBooleanParameter('RequiredTravelToday', true);
        RequiredLegAirPortCode := JSON.GetStringParameter('RequiredLegAirPortCode', true);
        ShowTripMessage := JSON.GetBooleanParameter('ShowTripMessage', true);
        InfoCode := JSON.GetStringParameter('InfoCode', true);

        DecodeBoardingPassString(BoardingPassString, RequiredLegAirPortCode, RequiredLegAirPortCodeInTrip, RequiredLegAirPortFlightDate, TravelStartDate, TravelEndDate, TravelDescription, TravelSaveString);

        if (RequiredLegAirPortCode <> '') and (not RequiredLegAirPortCodeInTrip) then begin
            //-NPR5.49 [344084]
            //POSEventMarshaller.DisplayError(ERR, STRSUBSTNO(ERRAPCODE, RequiredLegAirPortCode, TravelDescription), FALSE);
            //Handled := TRUE;
            //EXIT;
            Error(ERRAPCODE, RequiredLegAirPortCode, TravelDescription);
            //+NPR5.49 [344084]
        end;

        if (RequiredLegAirPortCode <> '') and (RequiredLegAirPortCodeInTrip) and (RequiredTravelToday) and (RequiredLegAirPortFlightDate <> WorkDate) then begin
            //+NPR5.49 [344084]
            //POSEventMarshaller.DisplayError(ERR,STRSUBSTNO(ERRTRAVELDATE, WORKDATE, TravelDescription), FALSE);
            //Handled := TRUE;
            //EXIT;
            Error(ERRTRAVELDATE, WorkDate, TravelDescription);
            //+NPR5.49 [344084]
        end;

        if RequiredTravelToday and ((WorkDate < TravelStartDate) or (WorkDate > TravelEndDate)) then begin
            //-NPR5.49 [344084]
            //POSEventMarshaller.DisplayError(ERR,STRSUBSTNO(ERRTRAVELDATE, WORKDATE, TravelDescription), FALSE);
            //Handled := TRUE;
            //EXIT;
            Error(ERRTRAVELDATE, WorkDate, TravelDescription);
            //+NPR5.49 [344084]
        end;


        if ShowTripMessage then begin
            //-NPR5.49 [344084]
            //POSEventMarshaller.DisplayError(TXTBPASS, TravelDescription, FALSE);
            Message(TravelDescription);
            //+NPR5.49 [344084]
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
        "--1": Integer;
        FromAirportCode: Code[3];
        ToAirportCode: Code[3];
        OperatorFlightNo: Code[8];
        FlightDate: Date;
        "--2": Integer;
    begin
        //Identifies traveldate and airportcodes for trip on boarding pass

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

    local procedure HexToInt(iHexValue: Text) oIntValue: Integer
    var
        Convert: DotNet npNetConvert;
    begin
        oIntValue := Convert.ToInt32(iHexValue, 16);
    end;

    local procedure JulianDateToDate(iJulianDate: Integer) oDate: Date
    var
        CalcDateFormula: Text;
    begin
        //Takes julian day part and makes date
        oDate := CalcDate('<-CY>', WorkDate);
        CalcDateFormula := StrSubstNo('<+%1D>', iJulianDate - 1);
        oDate := CalcDate(CalcDateFormula, oDate);
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "Ean Box Event")
    begin
        //-NPR5.49 [344084]
        if not EanBoxEvent.Get(EventCodeBoardingPass()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeBoardingPass();
            EanBoxEvent."Module Name" := CopyStr(Text000, 1, MaxStrLen(EanBoxEvent."Module Name"));
            EanBoxEvent.Description := CopyStr(Text001, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
        //+NPR5.49 [344084]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "Ean Box Setup Mgt."; EanBoxEvent: Record "Ean Box Event")
    begin
        //-NPR5.49 [344084]
        case EanBoxEvent.Code of
            EventCodeBoardingPass():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'BoardingPassString', true, '');
                end;
        end;
        //+NPR5.49 [344084]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeBoardingPass(EanBoxSetupEvent: Record "Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    begin
        //-NPR5.49 [344084]
        if EanBoxSetupEvent."Event Code" <> EventCodeBoardingPass() then
            exit;

        if BarCodeIsBoardingPass(EanBoxValue) then
            InScope := true;
        //+NPR5.49 [344084]
    end;

    local procedure EventCodeBoardingPass(): Code[20]
    begin
        //-NPR5.49 [344084]
        exit('BOARDING_PASS');
        //+NPR5.49 [344084]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.49 [344084]
        exit(CODEUNIT::"POS Action - Boarding Pass");
        //+NPR5.49 [344084]
    end;

    procedure BarCodeIsBoardingPass(Barcode: Text): Boolean
    var
        IntBuffer: Integer;
    begin
        //-NPR5.49 [344084]
        if StrLen(Barcode) < 60 then
            exit(false);

        if UpperCase(CopyStr(Barcode, 1, 1)) <> 'M' then
            exit(false);

        if not Evaluate(IntBuffer, CopyStr(Barcode, 2, 1)) then
            exit(false);

        exit(true);
        //+NPR5.49 [344084]
    end;
}

