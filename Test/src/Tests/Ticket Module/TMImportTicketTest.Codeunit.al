codeunit 85174 "NPR TM ImportTicketTest"
{

    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportSingleTicket()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario(Schedules);
        Schedules.Get('ALL_DAY', EventTime);

        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 1, 1, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateArrival(JobId); // Open ticket should work today
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportSingleTicketReservation()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('AM', EventTime);

        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 1, 1, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateReservationTimeSlot(JobId, 'AM');
        AssertError ValidateArrival(JobId); // Should fail because reservation is 5 days into the future
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportOrders()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario(Schedules);
        Schedules.Get('ALL_DAY', EventTime);

        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 5, 3, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 5 * 3, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateArrival(JobId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportOrdersWithLineNumbers()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario(Schedules);
        Schedules.Get('ALL_DAY', EventTime);

        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 5, 3, true, TempTicketImport, TempTicketImportLine, true);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 5 * 3, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateArrival(JobId);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportOrdersReservation()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('PM', EventTime);

        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 5, 3, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 5 * 3, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateReservationTimeSlot(JobId, 'PM');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InvalidVisitDate()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('PM', EventTime);

        CreateTicketsToImport(ItemNo, Today(), CalcDate('<-5D>'), EventTime, 1, 1, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(false, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DuplicateTicketNumber()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;

        Assert: Codeunit Assert;
        TicketImport: Record "NPR TM ImportTicketHeader";
        TicketImportLine: Record "NPR TM ImportTicketLine";
        TicketNumber: Code[30];
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('AM', EventTime);

        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 3, 1, true, TempTicketImport, TempTicketImportLine);
        TempTicketImportLine.FindFirst();
        TicketNumber := TempTicketImportLine.PreAssignedTicketNumber;

        TempTicketImportLine.FindLast();
        TempTicketImportLine.Delete();
        TempTicketImportLine.PreAssignedTicketNumber := TicketNumber;
        TempTicketImportLine.Insert();

        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(false, Success, ResponseMessage);

        ValidateLog(JobId, Success, 3 * 1, ResponseMessage);

        TicketImport.SetFilter(JobId, '=%1', JobId);
        Assert.IsTrue(TicketImport.IsEmpty(), TicketImport.TableCaption());

        TicketImportLine.SetFilter(JobId, '=%1', JobId);
        Assert.IsTrue(TicketImportLine.IsEmpty(), TicketImportLine.TableCaption());
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportSingleTicketUnPaid()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario(Schedules);
        Schedules.Get('ALL_DAY', EventTime);

        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 1, 1, false, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        AssertError ValidateArrival(JobId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportSingleTicketUnPaidReservation()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('AM', EventTime);

        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 1, 1, false, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TimeSlotSelection_BeforeAM()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Minute: Integer;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('AM', EventTime);
        Minute := 60 * 1000;

        // Before daily time slot time
        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime - Minute, 1, 1, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateReservationTimeSlot(JobId, 'AM');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TimeSlotSelection_OnAM()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Minute: Integer;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('AM', EventTime);
        Minute := 60 * 1000;

        // On daily AM time slot time
        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 1, 1, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateReservationTimeSlot(JobId, 'AM');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TimeSlotSelection_InAM()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Minute: Integer;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('AM', EventTime);
        Minute := 60 * 1000;

        // During AM time slot time
        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime + Minute, 1, 1, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateReservationTimeSlot(JobId, 'AM');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TimeSlotSelection_BetweenAM_PM()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Minute: Integer;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('PM', EventTime);
        Minute := 60 * 1000;

        // Between AM and PM time slot time
        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime - Minute, 1, 1, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateReservationTimeSlot(JobId, 'PM');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TimeSlotSelection_OnPM()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Minute: Integer;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('PM', EventTime);
        Minute := 60 * 1000;

        // On PM time slot time
        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 1, 1, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateReservationTimeSlot(JobId, 'PM');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TimeSlotSelection_InPM()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Minute: Integer;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('PM', EventTime);
        Minute := 60 * 1000;

        // In PM time slot time
        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime + Minute, 1, 1, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateReservationTimeSlot(JobId, 'PM');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TimeSlotSelection_AfterPM()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Minute: Integer;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario_Reservation(Schedules);
        Schedules.Get('PM', EventTime);
        Minute := 60 * 1000;

        // After PM time slot time
        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime + 95 * Minute, 1, 1, true, TempTicketImport, TempTicketImportLine);
        Success := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine), false, ResponseMessage, JobId);
        Assert.AreEqual(true, Success, ResponseMessage);

        ValidateLog(JobId, Success, 1 * 1, ResponseMessage);
        ValidateHeader(JobId, Success, TempTicketImport);
        ValidateLine(JobId, Success, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateReservationTimeSlot(JobId, 'PM');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ImportOrdersCheckCommitBehavior()
    var
        ItemNo: Code[20];
        Import: Codeunit "NPR TM Import Ticket Facade";
        ResponseMessage: Text;
        Success: Boolean;
        JobId: Code[40];
        TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        Schedules: Dictionary of [Code[20], Time];
        EventTime: Time;
        Assert: Codeunit Assert;
    begin
        ItemNo := SelectImportTestScenario(Schedules);
        Schedules.Get('ALL_DAY', EventTime);

        CreateTicketsToImport(ItemNo, Today(), CalcDate('<+5D>'), EventTime, 5, 3, true, TempTicketImport, TempTicketImportLine);
        JobId := Import.ImportTicketsFromJson(GenerateJson(TempTicketImport, TempTicketImportLine));

        ValidateLog(JobId, true, 5 * 3, ResponseMessage);
        ValidateHeader(JobId, true, TempTicketImport);
        ValidateLine(JobId, true, TempTicketImportLine);
        ValidateTickets(JobId);
        ValidateArrival(JobId);
    end;

    local procedure ValidateLog(JobIdTest: Code[40]; Success: Boolean; TotalTicketCount: Integer; ResponseMessage: Text)
    var
        Log: Record "NPR TM ImportTicketLog";
        Assert: Codeunit Assert;
    begin
        Log.SetFilter(JobId, '=%1', JobIdTest);
        Log.FindFirst();

        Assert.AreEqual(Success, Log.Success, Log.FieldCaption(Success));
        Assert.AreEqual(TotalTicketCount, Log.NumberOfTickets, Log.FieldCaption(NumberOfTickets));

        if (Success) then
            Assert.AreEqual('', Log.ResponseMessage, Log.FieldCaption(Log.ResponseMessage));

        if (not Success) then
            Assert.AreEqual(ResponseMessage, Log.ResponseMessage, Log.FieldCaption(Log.ResponseMessage));

    end;

    local procedure ValidateHeader(
        JobIdTest: Code[40];
        Success: Boolean;
        var TempTicketImport: Record "NPR TM ImportTicketHeader" temporary)
    var
        TicketImport: Record "NPR TM ImportTicketHeader";
        Assert: Codeunit Assert;
    begin

        TicketImport.SetFilter(JobId, '=%1', JobIdTest);
        Assert.AreEqual(Success, TicketImport.FindSet(), TicketImport.TableCaption());
        if (not Success) then
            exit;

        TempTicketImport.Reset();
        TempTicketImport.FindSet();
        repeat
            TicketImport.SetFilter(OrderId, '=%1', TempTicketImport.OrderId);
            TicketImport.FindFirst();

            Assert.AreEqual(TempTicketImport.SalesDate, TicketImport.SalesDate, TicketImport.FieldCaption(SalesDate));
            Assert.AreEqual(TempTicketImport.TotalAmount, TicketImport.TotalAmount, TicketImport.FieldCaption(TotalAmount));
            Assert.AreEqual(TempTicketImport.TotalAmountInclVat, TicketImport.TotalAmountInclVat, TicketImport.FieldCaption(TotalAmountInclVat));
            Assert.AreEqual(TempTicketImport.TotalAmountLcyInclVat, TicketImport.TotalAmountLcyInclVat, TicketImport.FieldCaption(TotalAmountLcyInclVat));
            Assert.AreEqual(TempTicketImport.TotalDiscountAmountInclVat, TicketImport.TotalDiscountAmountInclVat, TicketImport.FieldCaption(TotalDiscountAmountInclVat));
            Assert.AreEqual(TempTicketImport.CurrencyCode, TicketImport.CurrencyCode, TicketImport.FieldCaption(CurrencyCode));
            Assert.AreEqual(TempTicketImport.PaymentReference, TicketImport.PaymentReference, TicketImport.FieldCaption(PaymentReference));

        until (TempTicketImport.Next() = 0);
    end;

    procedure ValidateLine(
        JobIdTest: Code[40];
        Success: Boolean;
        var TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary)
    var
        TicketImportLine: Record "NPR TM ImportTicketLine";
        Assert: Codeunit Assert;
    begin
        TicketImportLine.SetFilter(JobId, '=%1', JobIdTest);
        Assert.AreEqual(Success, TicketImportLine.FindSet(), TicketImportLine.TableCaption());
        if (not Success) then
            exit;

        TempTicketImportLine.Reset();
        TempTicketImportLine.FindSet();
        repeat
            TicketImportLine.SetFilter(OrderId, '=%1', TempTicketImportLine.OrderId);
            TicketImportLine.SetFilter(PreAssignedTicketNumber, '=%1', TempTicketImportLine.PreAssignedTicketNumber);
            TicketImportLine.FindFirst();

            Assert.AreEqual(TempTicketImportLine.ItemReferenceNumber, TicketImportLine.ItemReferenceNumber, TicketImportLine.FieldCaption(ItemReferenceNumber));
            Assert.AreEqual(TempTicketImportLine.Description, TicketImportLine.Description, TicketImportLine.FieldCaption(Description));
            Assert.AreEqual(TempTicketImportLine.ExpectedVisitDate, TicketImportLine.ExpectedVisitDate, TicketImportLine.FieldCaption(ExpectedVisitDate));
            Assert.AreEqual(TempTicketImportLine.ExpectedVisitTime, TicketImportLine.ExpectedVisitTime, TicketImportLine.FieldCaption(ExpectedVisitTime));
            Assert.AreEqual(LowerCase(TempTicketImportLine.TicketHolderEMail), TicketImportLine.TicketHolderEMail, TicketImportLine.FieldCaption(TicketHolderEMail));
            Assert.AreEqual(TempTicketImportLine.TicketHolderName, TicketImportLine.TicketHolderName, TicketImportLine.FieldCaption(TicketHolderName));
            Assert.AreEqual(TempTicketImportLine.MemberNumber, TicketImportLine.MemberNumber, TicketImportLine.FieldCaption(MemberNumber));
            Assert.AreEqual(TempTicketImportLine.MembershipNumber, TicketImportLine.MembershipNumber, TicketImportLine.FieldCaption(MembershipNumber));
            Assert.AreEqual(TempTicketImportLine.Amount, TicketImportLine.Amount, TicketImportLine.FieldCaption(Amount));
            Assert.AreEqual(TempTicketImportLine.AmountInclVat, TicketImportLine.AmountInclVat, TicketImportLine.FieldCaption(AmountInclVat));
            Assert.AreEqual(TempTicketImportLine.AmountLcyInclVat, TicketImportLine.AmountLcyInclVat, TicketImportLine.FieldCaption(AmountLcyInclVat));
            Assert.AreEqual(TempTicketImportLine.DiscountAmountInclVat, TicketImportLine.DiscountAmountInclVat, TicketImportLine.FieldCaption(DiscountAmountInclVat));
            Assert.AreEqual(TempTicketImportLine.CurrencyCode, TicketImportLine.CurrencyCode, TicketImportLine.FieldCaption(CurrencyCode));

            if (TempTicketImportLine.TicketRequestTokenLine <> 0) then
                Assert.AreEqual(TempTicketImportLine.TicketRequestTokenLine, TicketImportLine.TicketRequestTokenLine, TicketImportLine.FieldCaption(TicketRequestTokenLine));

        until (TempTicketImportLine.Next() = 0);
    end;

    local procedure ValidateTickets(JobIdTest: Code[40])
    var
        TicketImportLine: Record "NPR TM ImportTicketLine";
        Ticket: Record "NPR TM Ticket";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Assert: Codeunit Assert;
    begin
        TicketImportLine.SetFilter(JobId, '=%1', JobIdTest);
        TicketImportLine.FindSet();
        repeat
            Ticket.SetFilter("External Ticket No.", '=%1', TicketImportLine.PreAssignedTicketNumber);
            Ticket.FindFirst();
            Assert.AreEqual(TicketImportLine.Amount, Ticket.AmountExclVat, Ticket.FieldCaption(AmountExclVat));
            Assert.AreEqual(TicketImportLine.AmountInclVat, Ticket.AmountInclVat, Ticket.FieldCaption(AmountInclVat));

            TicketRequest.Get(Ticket."Ticket Reservation Entry No.");
            Assert.AreEqual(TicketImportLine.TicketRequestToken, TicketRequest."Session Token ID", TicketRequest.FieldCaption("Session Token ID"));
            Assert.AreEqual(TicketImportLine.TicketRequestTokenLine, TicketRequest."Ext. Line Reference No.", TicketRequest.FieldCaption("Ext. Line Reference No."));
            Assert.AreEqual(TicketImportLine.TicketHolderName, TicketRequest.TicketHolderName, TicketRequest.FieldCaption(TicketHolderName));
            Assert.AreEqual(TicketImportLine.TicketHolderEMail, TicketRequest."Notification Address", TicketRequest.FieldCaption("Notification Address"));
            TicketRequest.TestField("Admission Code");

        until (TicketImportLine.Next() = 0);
    end;

    local procedure ValidateArrival(JobIdTest: Code[40])
    var
        TicketImportLine: Record "NPR TM ImportTicketLine";
        Ticket: Record "NPR TM Ticket";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Assert: Codeunit Assert;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        ApiOk: Boolean;
        ResponseMessage: Text;
    begin
        TicketImportLine.SetFilter(JobId, '=%1', JobIdTest);
        TicketImportLine.FindSet();
        repeat
            Ticket.SetFilter("External Ticket No.", '=%1', TicketImportLine.PreAssignedTicketNumber);
            Ticket.FindFirst();
            TicketRequest.Get(Ticket."Ticket Reservation Entry No.");
            TicketRequest.TestField("Admission Code");

            ApiOk := TicketApiLibrary.ValidateTicketArrival(Ticket."External Ticket No.", '', '', ResponseMessage);
            Assert.IsTrue(ApiOk, ResponseMessage);

        until (TicketImportLine.Next() = 0);
    end;


    local procedure ValidateReservationTimeSlot(JobIdTest: Code[40]; ScheduleCode: Code[20])
    var
        TicketImportLine: Record "NPR TM ImportTicketLine";
        Ticket: Record "NPR TM Ticket";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TimeSlot: Record "NPR TM Admis. Schedule Entry";
        Assert: Codeunit Assert;
    begin
        TicketImportLine.SetFilter(JobId, '=%1', JobIdTest);
        TicketImportLine.FindSet();
        repeat
            Ticket.SetFilter("External Ticket No.", '=%1', TicketImportLine.PreAssignedTicketNumber);
            Ticket.FindFirst();

            TicketRequest.Get(Ticket."Ticket Reservation Entry No.");

            AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            AccessEntry.SetFilter("Admission Code", '=%1', TicketRequest."Admission Code");
            AccessEntry.FindFirst();

            DetAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', AccessEntry."Entry No.");
            DetAccessEntry.SetFilter(Type, '=%1', DetAccessEntry.Type::RESERVATION);
            DetAccessEntry.FindFirst();

            Assert.AreEqual(TicketRequest."External Adm. Sch. Entry No.", DetAccessEntry."External Adm. Sch. Entry No.", TicketRequest.FieldCaption("External Adm. Sch. Entry No."));

            TimeSlot.SetFilter("External Schedule Entry No.", '=%1', DetAccessEntry."External Adm. Sch. Entry No.");
            TimeSlot.SetFilter(Cancelled, '=%1', false);
            TimeSlot.FindFirst();

            Assert.AreEqual(TicketImportLine.ExpectedVisitDate, TimeSlot."Admission Start Date", TimeSlot.FieldCaption("Admission Start Date"));
            Assert.AreEqual(ScheduleCode, TimeSlot."Schedule Code", TimeSlot.FieldCaption("Schedule Code"));

        until (TicketImportLine.Next() = 0);
    end;

    local procedure CreateTicketsToImport(
        ItemReference: Code[20];
        SalesDate: Date;
        ExpectedVisitDate: Date;
        ExpectedVisitTime: Time;
        OrdersToGenerate: Integer;
        TicketsPerOrder: Integer;
        WithPaymentReference: Boolean;
        var TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        var TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary
        )
    begin
        CreateTicketsToImport(
            ItemReference,
            SalesDate,
            ExpectedVisitDate,
            ExpectedVisitTime,
            OrdersToGenerate,
            TicketsPerOrder,
            WithPaymentReference,
            TempTicketImport,
            TempTicketImportLine,
            false);
    end;

    local procedure CreateTicketsToImport(
        ItemReference: Code[20];
        SalesDate: Date;
        ExpectedVisitDate: Date;
        ExpectedVisitTime: Time;
        OrdersToGenerate: Integer;
        TicketsPerOrder: Integer;
        WithPaymentReference: Boolean;
        var TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        var TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;
        AssignOrderLineNumber: Boolean
        )
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        OrderIndex, TicketIndex : Integer;
        VatRate, ExchangeRate : Decimal;
        CurrencyCode: Code[10];
        OrderLineNumber: Integer;
    begin

        CurrencyCode := 'EUR';
        ExchangeRate := 10.12;
        VatRate := 1.17;

        for OrderIndex := 1 to OrdersToGenerate do begin
            TempTicketImport.Init();
            TempTicketImport.OrderId := Format(OrderIndex);
            TempTicketImport.SalesDate := SalesDate;

            if (WithPaymentReference) then
                TicketLibrary.GenerateRandomCode(TempTicketImport.PaymentReference, MaxStrLen(TempTicketImport.PaymentReference));

            if (AssignOrderLineNumber) then
                OrderLineNumber := 10 + Random(10);

            TempTicketImport.CurrencyCode := CurrencyCode;
            TicketLibrary.GenerateRandomText(TempTicketImport.TicketHolderEMail, MaxStrLen(TempTicketImport.TicketHolderEMail));
            TempTicketImport.TicketHolderEMail[3 + Random(10)] := '@';
            TempTicketImport.TicketHolderEMail[StrLen(TempTicketImport.TicketHolderEMail) - 3] := '.';
            TicketLibrary.GenerateRandomText(TempTicketImport.TicketHolderName, MaxStrLen(TempTicketImport.TicketHolderName));

            for TicketIndex := 1 to TicketsPerOrder do begin
                TempTicketImportLine.Init();
                TempTicketImportLine.OrderId := TempTicketImport.OrderId;
                if (AssignOrderLineNumber) then
                    TempTicketImportLine.TicketRequestTokenLine += OrderLineNumber + 10 + Random(10);
                TempTicketImportLine.ItemReferenceNumber := ItemReference;
                TempTicketImportLine.ExpectedVisitDate := ExpectedVisitDate;
                TempTicketImportLine.ExpectedVisitTime := ExpectedVisitTime;

                TicketLibrary.GenerateRandomCode(TempTicketImportLine.PreAssignedTicketNumber, MaxStrLen(TempTicketImportLine.PreAssignedTicketNumber));
                TicketLibrary.GenerateRandomText(TempTicketImportLine.Description, MaxStrLen(TempTicketImportLine.Description));

                TempTicketImportLine.TicketHolderEMail := TempTicketImport.TicketHolderEMail;
                TempTicketImportLine.TicketHolderName := TempTicketImport.TicketHolderName;

                TempTicketImportLine.Amount := (1000 + Random(1000)) / 100;
                TempTicketImportLine.AmountInclVat := TempTicketImportLine.Amount * VatRate;
                TempTicketImportLine.DiscountAmountInclVat := (10 + Random(10)) / 10;
                TempTicketImportLine.CurrencyCode := TempTicketImport.CurrencyCode;
                TempTicketImportLine.AmountLcyInclVat := TempTicketImportLine.AmountInclVat * ExchangeRate;

                TempTicketImport.TotalAmount += TempTicketImportLine.Amount;
                TempTicketImport.TotalAmountInclVat += TempTicketImportLine.AmountInclVat;
                TempTicketImport.TotalDiscountAmountInclVat += TempTicketImportLine.DiscountAmountInclVat;
                TempTicketImport.TotalAmountLcyInclVat := TempTicketImportLine.AmountLcyInclVat;
                TempTicketImportLine.Insert();
            end;

            TempTicketImport.Insert();
        end;
    end;

    local procedure GenerateJson(
        var TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        var TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary
        ) TicketBatch: JsonObject
    var
        TicketOrders, Tickets : JsonArray;
        TicketOrder, Ticket, TicketHolder : JsonObject;
    begin
        TempTicketImport.FindSet();
        repeat
            TicketOrder.ReadFrom('{}');
            TicketOrder.Add('orderNumber', TempTicketImport.OrderId);
            TicketOrder.Add('totalAmount', TempTicketImport.TotalAmount);
            TicketOrder.Add('totalAmountInclVat', TempTicketImport.TotalAmountInclVat);
            TicketOrder.Add('totalDiscountAmountInclVat', TempTicketImport.TotalDiscountAmountInclVat);
            TicketOrder.Add('currencyCode', TempTicketImport.CurrencyCode);
            TicketOrder.Add('totalAmountLcyInclVat', TempTicketImport.TotalAmountLcyInclVat);
            TicketOrder.Add('salesDate', TempTicketImport.SalesDate);
            TicketOrder.Add('paymentReference', TempTicketImport.PaymentReference);

            TempTicketImportLine.SetFilter(OrderId, '=%1', TempTicketImport.OrderId);

            Tickets.ReadFrom('[]');
            if (TempTicketImportLine.FindSet()) then begin
                repeat
                    Ticket.ReadFrom('{}');
                    Ticket.Add('preAssignedTicketNumber', TempTicketImportLine.PreAssignedTicketNumber);
                    Ticket.Add('itemReferenceNumber', TempTicketImportLine.ItemReferenceNumber);
                    if (TempTicketImportLine.TicketRequestTokenLine <> 0) then
                        Ticket.Add('orderLineNumber', TempTicketImportLine.TicketRequestTokenLine);

                    Ticket.Add('description', TempTicketImportLine.Description);
                    Ticket.Add('expectedVisitDate', TempTicketImportLine.ExpectedVisitDate);
                    Ticket.Add('expectedVisitTime', TempTicketImportLine.ExpectedVisitTime);

                    TicketHolder.ReadFrom('{}');
                    TicketHolder.Add('eMail', TempTicketImportLine.TicketHolderEMail);
                    TicketHolder.Add('name', TempTicketImportLine.TicketHolderName);
                    TicketHolder.Add('membershipNumber', TempTicketImportLine.MembershipNumber);
                    TicketHolder.Add('memberNumber', TempTicketImportLine.MemberNumber);
                    Ticket.Add('ticketHolder', TicketHolder);

                    Ticket.Add('amount', TempTicketImportLine.Amount);
                    Ticket.Add('amountInclVat', TempTicketImportLine.AmountInclVat);
                    Ticket.Add('discountAmountInclVat', TempTicketImportLine.DiscountAmountInclVat);
                    Ticket.Add('amountLcyInclVat', TempTicketImportLine.AmountLcyInclVat);

                    Tickets.Add(Ticket);
                until (TempTicketImportLine.Next() = 0);
            end;
            TicketOrder.Add('tickets', Tickets);

            TicketOrders.Add(TicketOrder);
        until (TempTicketImport.Next() = 0);

        TicketBatch.ReadFrom('{}');
        TicketBatch.Add('ticketBatch', TicketOrders);
    end;

    local procedure SelectImportTestScenario_Reservation(var Schedules: Dictionary of [Code[20], Time]) ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_ImportTicketTest_Reservation(Schedules);
        Commit();
    end;


    local procedure SelectImportTestScenario(var Schedules: Dictionary of [Code[20], Time]) ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_ImportTicketTest(Schedules);
        Commit();
    end;

}