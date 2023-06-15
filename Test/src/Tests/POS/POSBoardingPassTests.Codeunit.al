codeunit 85052 "NPR POS Boarding Pass Tests"
{
    Subtype = Test;

    var
        LibraryBoardingPass: Codeunit "NPR Library - Boarding Pass";
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSSession: Codeunit "NPR POS Session";
        POSUnit: Record "NPR POS Unit";
        POSSale: Codeunit "NPR POS Sale";
        POSStore: Record "NPR POS Store";
        FromAirportCode: Code[3];
        ToAirPortCode: Code[3];
        OperatorFlightNo: Code[8];
        FlightDate: Date;
        FromAirportCode2: Code[3];
        ToAirPortCode2: Code[3];
        OperatorFlightNo2: Code[8];
        FlightDate2: Date;
        PassengerName: Text;
        PlaceHolder1Lbl: Label '%1\', Locked = true;
        PlaceHolder2Lbl: Label '\%1 > %2 (%3) %4', Locked = true;
        TestMsg: Text;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ClickOnOKMsg1Leg')]
    procedure BoardingPassReqToday1Leg()
    var
        POSActionBoardingPassB: Codeunit "NPR POS Action: Board. Pass B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LegString: Text;
        BoardingPass: Text;
        NoOfLegs: Integer;
        ParamInfoCode: Text;
        ParamReqLEGAirportCode: Code[3];
        ParamReqTravelToday: Boolean;
        ParamShowTripMessage: Boolean;

    begin
        //[Scenario] Boarding pass with 1 travel leg, Required Travel Today = true

        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        //[Given parametars from setup]
        ParamInfoCode := '';
        ParamReqLEGAirportCode := ' ';
        ParamReqTravelToday := true;
        ParamShowTripMessage := true;

        NoOfLegs := 1;

        LibraryBoardingPass.GenerateFlightInfoWorkDate(FromAirportCode, ToAirPortCode, OperatorFlightNo, FlightDate);
        LegString := LibraryBoardingPass.GenerateTravelLeg(FromAirportCode, ToAirPortCode, OperatorFlightNo, FlightDate);
        PassengerName := LibraryBoardingPass.GenerateRand20PassengerName();
        BoardingPass := LibraryBoardingPass.GenerateBoardingPass(Format(NoOfLegs), PassengerName, LegString);

        POSActionBoardingPassB.DecodeBoardingPassString(BoardingPass,
                                                        ParamInfoCode,
                                                        ParamReqLEGAirportCode,
                                                        ParamReqTravelToday,
                                                        ParamShowTripMessage,
                                                        POSSale,
                                                        POSSaleLine);
        ClearAll();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BoardingPassInfoCode1Leg()
    var
        SalePOS: Record "NPR POS Sale";
        POSActionBoardingPassB: Codeunit "NPR POS Action: Board. Pass B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        LegString: Text;
        BoardingPass: Text;
        NoOfLegs: Integer;
        ParamInfoCode: Text;
        ParamReqLEGAirportCode: Code[3];
        ParamReqTravelToday: Boolean;
        ParamShowTripMessage: Boolean;
        TravelSaveString: Text;
        PlaceHolder3Lbl: Label '%1>%2(%3 %4) | ', Locked = true;

    begin
        //[Scenario] Boarding pass with 1 travel leg and parametar Info Code = TEST, Show Message = false

        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        //[Given parametars from setup]
        ParamInfoCode := 'TEST';
        ParamReqLEGAirportCode := ' ';
        ParamReqTravelToday := true;
        ParamShowTripMessage := false;

        NoOfLegs := 1;

        LibraryBoardingPass.GenerateFlightInfoWorkDate(FromAirportCode, ToAirPortCode, OperatorFlightNo, FlightDate);
        LegString := LibraryBoardingPass.GenerateTravelLeg(FromAirportCode, ToAirPortCode, OperatorFlightNo, FlightDate);
        PassengerName := LibraryBoardingPass.GenerateRand20PassengerName();
        BoardingPass := LibraryBoardingPass.GenerateBoardingPass(Format(NoOfLegs), PassengerName, LegString);

        CreatePOSInfo(ParamInfoCode);

        POSActionBoardingPassB.DecodeBoardingPassString(BoardingPass,
                                                        ParamInfoCode,
                                                        ParamReqLEGAirportCode,
                                                        ParamReqTravelToday,
                                                        ParamShowTripMessage,
                                                        POSSale,
                                                        POSSaleLine);

        TravelSaveString := StrSubstNo(PlaceHolder3Lbl, FromAirportCode, ToAirportCode, OperatorFlightNo, FlightDate);

        POSSale.GetCurrentSale(SalePOS);

        POSInfoTransaction.Reset();
        POSInfoTransaction.SetRange("POS Info Code", ParamInfoCode);
        POSInfoTransaction.SetRange("Register No.", SalePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("POS Info", TravelSaveString);
        Assert.IsTrue(POSInfoTransaction.FindFirst(), 'POS Info Transaction is created');
        ClearAll();
    end;

    local procedure CreatePOSInfo(POSInfoCode: code[20])
    var
        POSInfo: Record "NPR POS Info";
    begin
        POSInfo.Init();
        POSInfo.Validate(Code, POSInfoCode);
        POSInfo.Validate("Input Type", POSInfo."Input Type"::Text);
        POSInfo.Validate(Type, POSInfo.Type::"Request Data");
        POSInfo.Insert(true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ClickOnOKMsg1Leg')]
    procedure BoardingPassReqLEGAirportCode1Leg()
    var
        POSActionBoardingPassB: Codeunit "NPR POS Action: Board. Pass B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LegString: Text;
        BoardingPass: Text;
        NoOfLegs: Integer;
        ParamInfoCode: Text;
        ParamReqLEGAirportCode: Code[3];
        ParamReqTravelToday: Boolean;
        ParamShowTripMessage: Boolean;

    begin
        //[Scenario] Boarding pass with 1 travel leg, Required LEG Airport Code = 'AGP'

        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        //[Given parametars from setup]
        ParamInfoCode := '';
        ParamReqLEGAirportCode := 'AGP';
        ParamReqTravelToday := false;
        ParamShowTripMessage := true;

        NoOfLegs := 1;

        LibraryBoardingPass.GenerateFlightInfoWorkDate(FromAirportCode, ToAirPortCode, OperatorFlightNo, FlightDate);
        FromAirportCode := 'AGP';
        LegString := LibraryBoardingPass.GenerateTravelLeg(FromAirportCode, ToAirPortCode, OperatorFlightNo, FlightDate);
        PassengerName := LibraryBoardingPass.GenerateRand20PassengerName();
        BoardingPass := LibraryBoardingPass.GenerateBoardingPass(Format(NoOfLegs), PassengerName, LegString);

        POSActionBoardingPassB.DecodeBoardingPassString(BoardingPass,
                                                        ParamInfoCode,
                                                        ParamReqLEGAirportCode,
                                                        ParamReqTravelToday,
                                                        ParamShowTripMessage,
                                                        POSSale,
                                                        POSSaleLine);
        ClearAll();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ClickOnOKMsg2Leg')]
    procedure BoardingPassReqToday2Leg()
    var
        POSActionBoardingPassB: Codeunit "NPR POS Action: Board. Pass B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LegString: Text;
        BoardingPass: Text;
        NoOfLegs: Integer;
        ParamInfoCode: Text;
        ParamReqLEGAirportCode: Code[3];
        ParamReqTravelToday: Boolean;
        ParamShowTripMessage: Boolean;
        TB: TextBuilder;

    begin
        //[Scenario] Boarding pass with 1 travel leg, Required Travel Today = true

        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        //[Given parametars from setup]
        ParamInfoCode := '';
        ParamReqLEGAirportCode := ' ';
        ParamReqTravelToday := true;
        ParamShowTripMessage := true;

        NoOfLegs := 2;

        //1st Leg
        LibraryBoardingPass.GenerateFlightInfoWorkDate(FromAirportCode, ToAirPortCode, OperatorFlightNo, FlightDate);
        TB.Append(LibraryBoardingPass.GenerateTravelLeg(FromAirportCode, ToAirPortCode, OperatorFlightNo, FlightDate));

        //2nd Leg
        LibraryBoardingPass.GenerateFlightInfoWorkDate(FromAirportCode2, ToAirPortCode2, OperatorFlightNo2, FlightDate2);
        TB.Append(LibraryBoardingPass.GenerateTravelLeg(FromAirportCode2, ToAirPortCode2, OperatorFlightNo2, FlightDate2));

        LegString := TB.ToText();

        PassengerName := LibraryBoardingPass.GenerateRand20PassengerName();
        BoardingPass := LibraryBoardingPass.GenerateBoardingPass(Format(NoOfLegs), PassengerName, LegString);

        POSActionBoardingPassB.DecodeBoardingPassString(BoardingPass,
                                                        ParamInfoCode,
                                                        ParamReqLEGAirportCode,
                                                        ParamReqTravelToday,
                                                        ParamShowTripMessage,
                                                        POSSale,
                                                        POSSaleLine);
        ClearAll();
    end;

    [MessageHandler]
    procedure ClickOnOKMsg1Leg(Msg: Text[1024])
    var
        TB: TextBuilder;
    begin
        TB.Append(StrSubstNo(PlaceHolder1Lbl, PassengerName));
        TB.Append(TestMsg + StrSubstNo(PlaceHolder2Lbl, FromAirportCode, ToAirportCode, OperatorFlightNo, FlightDate));
        TestMsg := TB.ToText();

        Assert.IsTrue(Msg = TestMsg, Msg + ' ' + TestMsg);
    end;

    [MessageHandler]
    procedure ClickOnOKMsg2Leg(Msg: Text[1024])
    var
        TB: TextBuilder;
    begin
        TB.Append(StrSubstNo(PlaceHolder1Lbl, PassengerName));
        TB.Append(TestMsg + StrSubstNo(PlaceHolder2Lbl, FromAirportCode, ToAirportCode, OperatorFlightNo, FlightDate));
        TB.Append(TestMsg + StrSubstNo(PlaceHolder2Lbl, FromAirportCode2, ToAirportCode2, OperatorFlightNo2, FlightDate2));
        TestMsg := TB.ToText();

        Assert.IsTrue(Msg = TestMsg, Msg + ' ' + TestMsg);
    end;

}