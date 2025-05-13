codeunit 85113 "NPR TM Statistics Test"
{
    Subtype = Test;

    var
        _RevisitPolicy: Option NA,NONINITIAL,DAILY_NONINITIAL,NEVER;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Admission_Policy_Never_01()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketStatistics: Record "NPR TM Ticket Access Stats";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketMgt: Codeunit "NPR TM Ticket Management";
        StatisticsMgt: Codeunit "NPR TM Ticket Access Stats";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectStatisticsScenario(_RevisitPolicy::NEVER);

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        TmpCreatedTickets.FindFirst();
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 111000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 111100T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 111200T);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 121000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 121100T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 121200T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 121300T);

        StatisticsMgt.BuildCompressedStatistics(Today(), false);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        // [Test]
        TicketStatistics.SetFilter("Item No.", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour", '=%1', 10);

        TicketStatistics.SetAutoCalcFields("Sum Admission Count", "Sum Admission Count (Neg)", "Sum Admission Count (Re-Entry)", "Sum Generated Count (Pos)", "Sum Generated Count (Neg)");
        TicketStatistics.SetFilter("Item No. Filter", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date Filter", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', 10);

        TicketStatistics.FindFirst();
        Assert.AreEqual(2, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 10.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');

        TicketStatistics.SetFilter("Admission Hour", '=%1', 11);
        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', 11);
        TicketStatistics.FindFirst();
        Assert.AreEqual(3, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 11.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');

        TicketStatistics.SetFilter("Admission Hour", '=%1', 12);
        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', 12);
        TicketStatistics.FindFirst();
        Assert.AreEqual(4, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 12.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Admission_Policy_Never_02()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketStatistics: Record "NPR TM Ticket Access Stats";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketMgt: Codeunit "NPR TM Ticket Management";
        StatisticsMgt: Codeunit "NPR TM Ticket Access Stats";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectStatisticsScenario(_RevisitPolicy::NEVER);

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        TmpCreatedTickets.FindFirst();
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 111000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 111100T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 111200T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 121000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 121100T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 121200T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 121300T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        // [Test]
        TicketStatistics.SetFilter("Item No.", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour", '=%1', 10);
        TicketStatistics.SetAutoCalcFields("Sum Admission Count", "Sum Admission Count (Neg)", "Sum Admission Count (Re-Entry)", "Sum Generated Count (Pos)", "Sum Generated Count (Neg)");
        TicketStatistics.SetFilter("Item No. Filter", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date Filter", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', 10);

        TicketStatistics.FindFirst();
        Assert.AreEqual(2, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 10.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');

        TicketStatistics.SetFilter("Admission Hour", '=%1', 11);
        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', 11);
        TicketStatistics.FindFirst();
        Assert.AreEqual(3, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 11.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');

        TicketStatistics.SetFilter("Admission Hour", '=%1', 12);
        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', 12);
        TicketStatistics.FindFirst();
        Assert.AreEqual(4, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 12.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Admission_Policy_Never_03()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketStatistics: Record "NPR TM Ticket Access Stats";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketMgt: Codeunit "NPR TM Ticket Management";
        StatisticsMgt: Codeunit "NPR TM Ticket Access Stats";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectStatisticsScenario(_RevisitPolicy::NEVER);

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        TmpCreatedTickets.FindFirst();
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        // [Test]
        TicketStatistics.SetFilter("Item No.", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour", '=%1', 10);

        TicketStatistics.SetAutoCalcFields("Sum Admission Count", "Sum Admission Count (Neg)", "Sum Admission Count (Re-Entry)", "Sum Generated Count (Pos)", "Sum Generated Count (Neg)");
        TicketStatistics.SetFilter("Item No. Filter", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date Filter", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', 10);

        TicketStatistics.FindFirst();
        Assert.AreEqual(6, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 10.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');

        TicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+1D>'));
        TicketStatistics.SetFilter("Admission Date Filter", '=%1', CalcDate('<+1D>'));
        TicketStatistics.SetAutoCalcFields("Sum Admission Count", "Sum Admission Count (Neg)", "Sum Admission Count (Re-Entry)", "Sum Generated Count (Pos)", "Sum Generated Count (Neg)");
        TicketStatistics.FindFirst();
        Assert.AreEqual(6, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 10.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Admission_Policy_DailyInitial_01()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketStatistics: Record "NPR TM Ticket Access Stats";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketMgt: Codeunit "NPR TM Ticket Management";
        StatisticsMgt: Codeunit "NPR TM Ticket Access Stats";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectStatisticsScenario(_RevisitPolicy::DAILY_NONINITIAL);

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        TmpCreatedTickets.FindFirst();
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        // [Test]
        TicketStatistics.SetFilter("Item No.", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour", '=%1', 10);

        TicketStatistics.SetAutoCalcFields("Sum Admission Count", "Sum Admission Count (Neg)", "Sum Admission Count (Re-Entry)", "Sum Generated Count (Pos)", "Sum Generated Count (Neg)");
        TicketStatistics.SetFilter("Item No. Filter", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date Filter", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', 10);

        TicketStatistics.FindFirst();
        Assert.AreEqual(1, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 10.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(5, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');

        TicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+1D>'));
        TicketStatistics.SetFilter("Admission Date Filter", '=%1', CalcDate('<+1D>'));
        TicketStatistics.SetAutoCalcFields("Sum Admission Count", "Sum Admission Count (Neg)", "Sum Admission Count (Re-Entry)", "Sum Generated Count (Pos)", "Sum Generated Count (Neg)");
        TicketStatistics.FindFirst();
        Assert.AreEqual(1, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 10.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(5, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Admission_Policy_NonInitial_Admitt()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketStatistics: Record "NPR TM Ticket Access Stats";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketMgt: Codeunit "NPR TM Ticket Management";
        StatisticsMgt: Codeunit "NPR TM Ticket Access Stats";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := SelectStatisticsScenario(_RevisitPolicy::NONINITIAL);

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        TmpCreatedTickets.FindFirst();

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        // [Test]
        TicketStatistics.SetFilter("Item No.", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour", '=%1', 10);

        TicketStatistics.SetAutoCalcFields("Sum Admission Count", "Sum Admission Count (Neg)", "Sum Admission Count (Re-Entry)", "Sum Generated Count (Pos)", "Sum Generated Count (Neg)");
        TicketStatistics.SetFilter("Item No. Filter", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date Filter", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', 10);

        TicketStatistics.FindFirst();
        Assert.AreEqual(1, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 10.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(5, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');

        TicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+1D>'));
        TicketStatistics.SetFilter("Admission Date Filter", '=%1', CalcDate('<+1D>'));
        TicketStatistics.SetAutoCalcFields("Sum Admission Count", "Sum Admission Count (Neg)", "Sum Admission Count (Re-Entry)", "Sum Generated Count (Pos)", "Sum Generated Count (Neg)");
        TicketStatistics.FindFirst();
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 10.');
        Assert.AreEqual(0, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(6, TicketStatistics."Sum Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Admission_Policy_NonInitial_Revoke()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketStatistics: Record "NPR TM Ticket Access Stats";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketMgt: Codeunit "NPR TM Ticket Management";
        StatisticsMgt: Codeunit "NPR TM Ticket Access Stats";
        TicketRequestMgt: Codeunit "NPR TM Ticket Request Manager";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
        Token: Text[100];
        AmountToReverse: Decimal;
        QtyToReverse: Integer;
        AdmissionHour: Integer;
    begin

        ItemNo := SelectStatisticsScenario(_RevisitPolicy::NONINITIAL);

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        TmpCreatedTickets.FindFirst();

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);
        ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101100T);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);


        Token := TicketRequestMgt.GetNewToken();
        TicketRequestMgt.POS_CreateRevokeRequest(Token, TmpCreatedTickets."No.", CopyStr(UserId(), 1, 20), 0, AmountToReverse, QtyToReverse);
        TicketRequestMgt.RevokeReservationTokenRequest(Token, false);
        StatisticsMgt.BuildCompressedStatistics(Today(), false);

        // Revoked admissions are created on time of revoke - there is small window of error here
        // the transaction might have been inserted the previous hour, which in theory could be yesterday
        Evaluate(AdmissionHour, Format(Time(), 0, '<Hours24>'));

        // [Test]
        TicketStatistics.SetFilter("Item No.", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour", '=%1', AdmissionHour);

        TicketStatistics.SetAutoCalcFields("Sum Admission Count", "Sum Admission Count (Neg)", "Sum Admission Count (Re-Entry)", "Sum Generated Count (Pos)", "Sum Generated Count (Neg)");
        TicketStatistics.SetFilter("Item No. Filter", '=%1', ItemNo);
        TicketStatistics.SetFilter("Admission Date Filter", '=%1', CalcDate('<+0D>'));
        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', AdmissionHour);

        // daily non-initial. 
        // Since there were 2 different days of admission, it would seem logical to have 2 revokes.
        // But because the revokes are created at the time of the revoke action, all cancel admissions entries will have the same date.
        // Thus there will be only 1 negative for this test
        TicketStatistics.FindFirst();
        Assert.AreEqual(1, TicketStatistics."Sum Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Admission_Policy_DailyNonInitial_AdHoc()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketStatistics: Record "NPR TM Ticket Access Stats";
        TempTicketStatistics: Record "NPR TM Ticket Access Stats" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketMgt: Codeunit "NPR TM Ticket Management";
        StatisticsMgt: Codeunit "NPR TM Ticket Access Stats";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
        AdmissionCount, N : Integer;
    begin

        ItemNo := SelectStatisticsScenario(_RevisitPolicy::DAILY_NONINITIAL);

        NumberOfTicketOrders := 1;
        TicketQuantityPerOrder := 1;
        AdmissionCount := 6;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');

        TmpCreatedTickets.FindFirst();

        for N := 1 to AdmissionCount do
            ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+0D'), 101000T);

        for N := 1 to AdmissionCount do
            ValidateTicketForArrival(TmpCreatedTickets, '', -1, CalcDate('<+1D'), 101000T);

        StatisticsMgt.BuildCompressedStatisticsAdHoc(CalcDate('<+0D>'), CalcDate('<+1D>'), TempTicketStatistics);

        // [Test]
        // Nothing should be in persitent table
        TicketStatistics.SetFilter("Item No.", '=%1', ItemNo);
        Assert.IsTrue(TicketStatistics.IsEmpty(), 'Found unexpected persistent statistics when doing adhoc calculation.');

        // Stats should be in temp table
        TempTicketStatistics.SetFilter("Item No.", '=%1', ItemNo);
        TempTicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+0D>'));
        TempTicketStatistics.SetFilter("Admission Hour", '=%1', 10);
        TempTicketStatistics.FindFirst();
        Assert.AreEqual(1, TempTicketStatistics."Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 10.');
        Assert.AreEqual(0, TempTicketStatistics."Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(AdmissionCount - 1, TempTicketStatistics."Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');

        TempTicketStatistics.SetFilter("Admission Date", '=%1', CalcDate('<+1D>'));
        TempTicketStatistics.SetFilter("Admission Hour", '=%1', 10);
        TempTicketStatistics.FindFirst();
        Assert.AreEqual(1, TempTicketStatistics."Admission Count", 'Number of registered arrivals in statistics does not match actual number of arrivals for hour 10.');
        Assert.AreEqual(0, TempTicketStatistics."Admission Count (Neg)", 'Admission Count (Neg) must be zero unless ticket was revoked');
        Assert.AreEqual(AdmissionCount - 1, TempTicketStatistics."Admission Count (Re-Entry)", 'Re-Entry count must be zero when revisit policy is Never');
    end;

    [Normal]
    local procedure ValidateTicketForArrival(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; AdmissionScheduleEntryNo: Integer; EventDate: Date; EventTime: Time)
    var
        TicketMgt: Codeunit "NPR TM Ticket Management";
    begin
        TicketMgt.ValidateTicketForArrival(Ticket, '', -1, CreateDateTime(EventDate, EventTime), '');
    end;

    [Normal]
    local procedure SelectStatisticsScenario(RevisitPolicy: Option NA,NONINITIAL,DAILY_NONINITIAL,NEVER) ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_TicketStatistics(RevisitPolicy);
    end;
}