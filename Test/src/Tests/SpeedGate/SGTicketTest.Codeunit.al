codeunit 85217 "NPR SG TicketTest"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitNoSetup()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', '');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitNoSetupInvalidTicket()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        LogEntryNo := SpeedGate.CreateInitialEntry('FOOBAR-ASDFGHJKL', '', '');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedUnknown(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_DenyTicket()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', '');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedUnknown(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_DefaultSetup()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.DefaultSetup(false, true, '', '');
        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', '');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_RequireGate()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.DefaultSetup(true, true, '', '');
        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', '');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedUnknown(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_InvalidTicketProfile()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.DefaultSetup(true, true, 'FOOBAR', '');
        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', '');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedUnknown(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_InvalidGate()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.DefaultSetup(true, true, '', '');
        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', 'FOOBAR');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedUnknown(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_InvalidGateNotRequired()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.DefaultSetup(false, true, '', '');
        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', 'FOOBAR');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_02_WrongGate()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.DefaultSetup(false, true, '', '');
        SpeedGateLibrary.GateSetup('GATE01', false, '', '');
        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedUnknown(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_02_CorrectGate()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', '');
        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_02_GateDeniesTicket()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
    begin
        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', false, '', '');
        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedUnknown(LogEntryNo);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_03()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();
        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, true);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, '', 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_03_Reject()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();
        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, true);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(GetOneTicket(), '', 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedRejected(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_03_Unknown()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();
        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry('FOOBAR', '', 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedUnknown(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_04_InvalidAdmission()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', '');

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, 'FOOBAR', 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedRejected(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_04_ValidAdmission()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', '');

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_01()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        TicketProfileCode := SpeedGateLibrary.CreateProfile(); // Empty profile - deny all

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, '');

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedUnknown(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_02()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile(); // Empty profile - deny 

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedTicket(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_03()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', 'FOO-ADM', '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedTicket(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_04()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, 'FOO-ITEM', '', '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedTicket(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_05()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, 'FOO-ITEM', 'FOO-ADM', '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedTicket(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_06()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, Ticket."Item No.", '', '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_07()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', TicketAccessEntry."Admission Code", '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_08()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, Ticket."Item No.", TicketAccessEntry."Admission Code", '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_09()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', '', '', 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_06_TicketProfile_01()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', '', '', Time() - 5 * 1000, Time() + 5 * 1000);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_06_TicketProfile_02()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', '', '', Time() + 5 * 1000, Time() + 10 * 1000);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedTicket(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_06_TicketProfile_03()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', '', '', Time() - 10 * 1000, Time() - 5 * 1000);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedTicket(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_06_TicketProfile_04()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];
        CalenderCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        CalenderCode := TicketLibrary.CreateBaseCalendar('');
        TicketLibrary.SetNonWorking(CalenderCode, 'Test', 1, Today(), 0);

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', '', CalenderCode, 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidateDeniedTicket(LogEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_06_TicketProfile_05()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        LogEntryNo: Integer;
        EntryLog: Record "NPR SGEntryLog";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketProfileCode: Code[10];
        CalenderCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        CalenderCode := TicketLibrary.CreateBaseCalendar('');
        TicketLibrary.SetNonWorking(CalenderCode, 'Test', 1, CalcDate('<+1D>'), 0);
        TicketLibrary.SetNonWorking(CalenderCode, 'Test', 1, CalcDate('<-1D>'), 0);

        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', '', CalenderCode, 0T, 0T);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, WhitelistCode);

        LogEntryNo := SpeedGate.CreateInitialEntry(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01');
        SpeedGate.CheckNumberAtGate(LogEntryNo);
        ValidatePermitted(LogEntryNo);
    end;

    [Normal]
    procedure ValidatePermitted(EntryLogNo: Integer)
    var
        EntryLog: Record "NPR SGEntryLog";
    begin
        EntryLog.Get(EntryLogNo);
        EntryLog.TestField(ReferenceNumberType, EntryLog.ReferenceNumberType::TICKET);
        EntryLog.TestField(EntryStatus, EntryLog.EntryStatus::PERMITTED_BY_GATE);
    end;

    [Normal]
    procedure ValidateDeniedUnknown(EntryLogNo: Integer)
    var
        EntryLog: Record "NPR SGEntryLog";
    begin
        EntryLog.Get(EntryLogNo);
        EntryLog.TestField(ReferenceNumberType, EntryLog.ReferenceNumberType::UNKNOWN);
        EntryLog.TestField(EntryStatus, EntryLog.EntryStatus::DENIED_BY_GATE);
    end;


    procedure ValidateDeniedRejected(EntryLogNo: Integer)
    var
        EntryLog: Record "NPR SGEntryLog";
    begin
        EntryLog.Get(EntryLogNo);
        EntryLog.TestField(ReferenceNumberType, EntryLog.ReferenceNumberType::REJECTED);
        EntryLog.TestField(EntryStatus, EntryLog.EntryStatus::DENIED_BY_GATE);
    end;

    procedure ValidateDeniedTicket(EntryLogNo: Integer)
    var
        EntryLog: Record "NPR SGEntryLog";
    begin
        EntryLog.Get(EntryLogNo);
        EntryLog.TestField(ReferenceNumberType, EntryLog.ReferenceNumberType::TICKET);
        EntryLog.TestField(EntryStatus, EntryLog.EntryStatus::DENIED_BY_GATE);
    end;

    [Normal]
    procedure GetOneTicket() ExternalTicketNumber: Code[30]
    var
        TicketQuantityPerOrder: Integer;
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
    begin
        TicketQuantityPerOrder := 1;
        CreateTicket(TicketQuantityPerOrder, TmpCreatedTickets);
        TmpCreatedTickets.Reset();
        TmpCreatedTickets.FindFirst();
        ExternalTicketNumber := TmpCreatedTickets."External Ticket No.";
    end;

    [Normal]
    procedure CreateTicket(TicketQuantityPerOrder: Integer; var TmpCreatedTickets: Record "NPR TM Ticket" temporary)
    var
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := TicketSmokeTestScenario();

        NumberOfTicketOrders := 1;
        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');
    end;

    [Normal]
    local procedure TicketSmokeTestScenario() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
    end;
}