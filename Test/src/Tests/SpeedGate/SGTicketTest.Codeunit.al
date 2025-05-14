codeunit 85217 "NPR SG TicketTest"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitNoSetup()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.NoSpeedGateSetup();

        ValidatePermitted(SpeedGate.CreateAdmitToken(GetOneTicket(), '', ''));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitNoSetupInvalidTicket()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.NoSpeedGateSetup();

        ValidateDeniedUnknown(SpeedGate.CreateAdmitToken('FOOBAR-ASDFGHJKL', '', ''));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_DenyTicket()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.DefaultSetup(false, false, '', '');

        ValidateDeniedUnknown(SpeedGate.CreateAdmitToken(GetOneTicket(), '', ''));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_DefaultSetup()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.DefaultSetup(false, true, '', '');

        ValidatePermitted(SpeedGate.CreateAdmitToken(GetOneTicket(), '', ''));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_RequireGate()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.DefaultSetup(true, true, '', '');

        ValidateDeniedUnknown(SpeedGate.CreateAdmitToken(GetOneTicket(), '', ''));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_InvalidTicketProfile()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.DefaultSetup(true, true, 'FOOBAR', '');

        ValidateDeniedUnknown(SpeedGate.CreateAdmitToken(GetOneTicket(), '', ''));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_InvalidGate()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.DefaultSetup(true, true, '', '');

        ValidateDeniedUnknown(SpeedGate.CreateAdmitToken(GetOneTicket(), '', 'FOOBAR'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitDefaultSetup_01_InvalidGateNotRequired()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.DefaultSetup(false, true, '', '');

        ValidatePermitted(SpeedGate.CreateAdmitToken(GetOneTicket(), '', 'FOOBAR'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_02_WrongGate()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.DefaultSetup(false, true, '', '');
        SpeedGateLibrary.GateSetup('GATE01', false, '', '');

        ValidateDeniedUnknown(SpeedGate.CreateAdmitToken(GetOneTicket(), '', 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_02_CorrectGate()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', '');

        ValidatePermitted(SpeedGate.CreateAdmitToken(GetOneTicket(), '', 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_02_GateDeniesTicket()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
    begin
        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', false, '', '');

        ValidateDeniedUnknown(SpeedGate.CreateAdmitToken(GetOneTicket(), '', 'GATE01'));
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_03()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();
        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, true);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', WhitelistCode);

        ValidatePermitted(SpeedGate.CreateAdmitToken(ExternalTicketNumber, '', 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_03_Reject()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();
        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, true);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', WhitelistCode);

        ValidateDeniedRejected(SpeedGate.CreateAdmitToken(GetOneTicket(), '', 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_03_Unknown()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();
        WhitelistCode := SpeedGateLibrary.AddToWhitelist(ExternalTicketNumber, 0, false);

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', WhitelistCode);

        ValidateDeniedUnknown(SpeedGate.CreateAdmitToken('FOOBAR', '', 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_04_InvalidAdmission()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
    begin
        ExternalTicketNumber := GetOneTicket();

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', '');

        ValidateDeniedRejected(SpeedGate.CreateAdmitToken(ExternalTicketNumber, 'FOOBAR', 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_04_ValidAdmission()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidatePermitted(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_04_ValidAdmission_02()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        HaveError: Boolean;
        ErrorMessage: Text;
    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', '');

        SpeedGate.Admit(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01', true, HaveError, ErrorMessage), 1);
        if (HaveError) or (ErrorMessage <> '') then
            Error('Expected no error and no error message, but got %1: %2', HaveError, ErrorMessage);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_04_RevokedTicket_01()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketCount: Integer;
        AmountToReverse: Decimal;
        QtyToReverse: Integer;
        Token: Text[100];
    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', '');

        AmountToReverse := 0;
        QtyToReverse := 0;
        TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", 'RECEIPT-NO', 0, AmountToReverse, QtyToReverse);
        TicketRequestManager.RevokeReservationTokenRequest(Token, false);

        ValidateDeniedTicket(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_04_RevokedTicket_02()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketCount: Integer;
        AmountToReverse: Decimal;
        QtyToReverse: Integer;
        Token: Text[100];
        HaveError: Boolean;
        ErrorMessage: Text;
    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', '');

        AmountToReverse := 0;
        QtyToReverse := 0;
        TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", 'RECEIPT-NO', 0, AmountToReverse, QtyToReverse);
        TicketRequestManager.RevokeReservationTokenRequest(Token, false);

        asserterror SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01', true, HaveError, ErrorMessage);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_04_RevokedTicket_03()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketCount: Integer;
        AmountToReverse: Decimal;
        QtyToReverse: Integer;
        Token: Text[100];
        HaveError: Boolean;
        ErrorMessage: Text;
    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', '');

        AmountToReverse := 0;
        QtyToReverse := 0;
        TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", 'RECEIPT-NO', 0, AmountToReverse, QtyToReverse);
        TicketRequestManager.RevokeReservationTokenRequest(Token, false);

        SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01', false, HaveError, ErrorMessage);

        if (not HaveError) or (ErrorMessage = '') then
            Error('Expected error and error message, but got none');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_04_RevokedTicket_04()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        ExternalTicketNumber: Code[30];
        WhitelistCode: Code[10];
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketCount: Integer;
        AmountToReverse: Decimal;
        QtyToReverse: Integer;
        Token: Text[100];
        HaveError: Boolean;
        ErrorMessage: Text;

    begin
        ExternalTicketNumber := GetOneTicket();
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindFirst();

        SpeedGateLibrary.DefaultSetup(false, false, '', '');
        SpeedGateLibrary.GateSetup('GATE01', true, '', '');

        AmountToReverse := 0;
        QtyToReverse := 0;
        TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", 'RECEIPT-NO', 0, AmountToReverse, QtyToReverse);
        TicketRequestManager.RevokeReservationTokenRequest(Token, false);

        asserterror SpeedGate.Admit(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01', false, HaveError, ErrorMessage), 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_01()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidateDeniedUnknown(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_02()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidateDeniedTicket(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_03()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidateDeniedTicket(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_04()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidateDeniedTicket(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_05()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidateDeniedTicket(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_06()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidatePermitted(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_07()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidatePermitted(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_08()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidatePermitted(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_05_TicketProfile_09()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidatePermitted(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_06_TicketProfile_01()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidatePermitted(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_06_TicketProfile_02()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidateDeniedTicket(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_06_TicketProfile_03()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
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

        ValidateDeniedTicket(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_06_TicketProfile_04()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
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

        ValidateDeniedTicket(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryAdmitGateSetup_06_TicketProfile_05()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
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

        ValidatePermitted(SpeedGate.CreateAdmitToken(ExternalTicketNumber, TicketAccessEntry."Admission Code", 'GATE01'));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketType_Scan()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicket());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Activation Method" := TicketType."Activation Method"::SCAN;
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_TYPE;
        TicketType.Modify();

        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsFalse(AttemptToAdmit, 'Expected to not be able to admit ticket with SCAN activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 0, StrSubstNo('Expected zero admit to admissions, but got %1', AdmitToAdmissions.Count()));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketType_NA()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicket());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Activation Method" := TicketType."Activation Method"::NA;
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_TYPE;
        TicketType.Modify();

        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsFalse(AttemptToAdmit, 'Expected to not be able to admit ticket with NA activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 0, StrSubstNo('Expected zero admit to admissions, but got %1', AdmitToAdmissions.Count()));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketType_POS_DEFAULT()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";

        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicket());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Activation Method" := TicketType."Activation Method"::POS_DEFAULT;
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_TYPE;
        TicketType.Modify();

        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsTrue(AttemptToAdmit, 'Expected to be able to admit ticket with POS_DEFAULT activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 1, StrSubstNo('Expected 1 admit to admissions, but got %1', AdmitToAdmissions.Count()));

        AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo);
        ValidatePermitted(AdmitToken);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketType_POS_ALL()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";

        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicketWithTwoAdmissions());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Activation Method" := TicketType."Activation Method"::POS_ALL;
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_TYPE;
        TicketType.Modify();

        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsTrue(AttemptToAdmit, 'Expected to be able to admit ticket with POS_ALL activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 2, StrSubstNo('Expected 1 admit to admissions, but got %1', AdmitToAdmissions.Count()));

        AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo);
        ValidatePermitted(AdmitToken);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketBom_SCAN()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";

        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicketWithTwoAdmissions());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_BOM;
        TicketType.Modify();

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.FindSet();
        repeat
            TicketBom."Activation Method" := TicketBom."Activation Method"::SCAN;
            TicketBom.Modify();
        until TicketBom.Next() = 0;

        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsFalse(AttemptToAdmit, 'Expected to not be able to admit ticket with SCAN activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 0, StrSubstNo('Expected zero admit to admissions, but got %1', AdmitToAdmissions.Count()));

        asserterror SpeedGate.Admit(SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo), 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketBom_NA()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";

        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicketWithTwoAdmissions());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_BOM;
        TicketType.Modify();

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.FindSet();
        repeat
            TicketBom."Activation Method" := TicketBom."Activation Method"::NA;
            TicketBom.Modify();
        until TicketBom.Next() = 0;

        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsFalse(AttemptToAdmit, 'Expected to not be able to admit ticket with NA activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 0, StrSubstNo('Expected zero admit to admissions, but got %1', AdmitToAdmissions.Count()));

        asserterror SpeedGate.Admit(SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo), 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketBom_POS()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";

        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicketWithTwoAdmissions());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_BOM;
        TicketType.Modify();

        // Default value is SCAN
        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.FindFirst();
        TicketBom."Activation Method" := TicketBom."Activation Method"::POS;
        TicketBom.Modify();

        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsTrue(AttemptToAdmit, 'Expected to not be able to admit ticket with POS activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 1, StrSubstNo('Expected zero admit to admissions, but got %1', AdmitToAdmissions.Count()));

        AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo);
        ValidatePermitted(AdmitToken);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketBom_ALWAYS()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";

        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicketWithTwoAdmissions());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_BOM;
        TicketType.Modify();

        // Default value is SCAN
        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.FindLast();
        TicketBom."Activation Method" := TicketBom."Activation Method"::ALWAYS;
        TicketBom.Modify();

        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsTrue(AttemptToAdmit, 'Expected to be able to admit ticket with ALWAYS activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 1, StrSubstNo('Expected zero admit to admissions, but got %1', AdmitToAdmissions.Count()));

        AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo);
        ValidatePermitted(AdmitToken);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketBom_PER_UNIT()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";

        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        AdmitCount: Integer;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        SpeedGateLibrary.NoSpeedGateSetup();
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicketWithTwoAdmissions());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_BOM;
        TicketType.Modify();

        // Default value is SCAN
        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.FindSet();
        repeat
            TicketBom."Activation Method" := TicketBom."Activation Method"::PER_UNIT;
            TicketBom.Modify();
        until TicketBom.Next() = 0;

        // The PER_UNIT will revert to default admission code when no profiles are set up.
        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsTrue(AttemptToAdmit, 'Expected to be able to admit ticket with PER_UNIT activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 1, StrSubstNo('Expected zero admit to admissions, but got %1', AdmitToAdmissions.Count()));

        // Speed gate has no profiles, speed gate should end up picking default admission code
        AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo);
        AdmitCount := ValidatePermitted(AdmitToken);
        Assert.AreEqual(AdmitCount, 1, StrSubstNo('Expected 1 admissions to be admitted, but got %1', AdmitCount));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketBom_PER_UNIT_2()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";

        TicketProfileCode: Code[10];
        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.DefaultSetup(false, false, TicketProfileCode, '');
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicketWithTwoAdmissions());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_BOM;
        TicketType.Modify();

        // Default value is SCAN
        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.FindSet();
        repeat
            TicketBom."Activation Method" := TicketBom."Activation Method"::PER_UNIT;
            TicketBom.Modify();
        until TicketBom.Next() = 0;

        // The check will not be able to fill the admission code list, so it will be empty. 
        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsFalse(AttemptToAdmit, 'Expected to be able to admit ticket with PER_UNIT activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 0, StrSubstNo('Expected zero admit to admissions, but got %1', AdmitToAdmissions.Count()));

        // Speed gate has an empty ticket profile, speed gate admit should fail
        AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo);
        asserterror SpeedGate.Admit(AdmitToken, 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketBom_PER_UNIT_3()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";

        TicketProfileCode: Code[10];
        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        AdmitCount: Integer;
        Assert: Codeunit "Assert";
        ResponseCode: Integer;
    begin
        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        SpeedGateLibrary.DefaultSetup(false, false, TicketProfileCode, '');
        CreatePosUnit(PosUnitNo);

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicketWithTwoAdmissions());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_BOM;
        TicketType.Modify();

        // Default value is SCAN, add all admission codes to the profile
        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.FindSet();
        repeat
            TicketBom."Activation Method" := TicketBom."Activation Method"::PER_UNIT;
            TicketBom.Modify();
            SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', TicketBom."Admission Code", '', 0T, 0T);
        until TicketBom.Next() = 0;

        // The check will not be able to fill the admission code list, so it will be empty. 
        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsTrue(AttemptToAdmit, 'Expected to be able to admit ticket with PER_UNIT activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 2, StrSubstNo('Expected zero admit to admissions, but got %1', AdmitToAdmissions.Count()));

        // Speed gate has an ticket profile with valid admissions, speed gate admit should succeed
        AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo);
        AdmitCount := ValidatePermitted(AdmitToken);
        Assert.AreEqual(AdmitCount, 2, StrSubstNo('Expected 2 admissions to be admitted, but got %1', AdmitCount));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmitFromEndSales_TicketBom_PER_UNIT_4()
    var
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        PosUnit: Record "NPR POS Unit";
        PosTicketProfile: Record "NPR TM POS Ticket Profile";

        TicketProfileCode: Code[10];
        AdmitToken: Guid;
        PosUnitNo: Code[10];
        AdmitToAdmissions: List of [Code[20]];
        AttemptToAdmit: Boolean;
        AdmitCount: Integer;
        Assert: Codeunit "Assert";
        GateId: Guid;
        ResponseCode: Integer;
    begin
        // Default profile is empty - deny admission
        SpeedGateLibrary.DefaultSetup(false, false, SpeedGateLibrary.CreateProfile(), '');

        // create a pos unit, assign the scanner id to the profile
        CreatePosUnit(PosUnitNo);
        PosUnit.Get(PosUnitNo);
        PosTicketProfile.Get(PosUnit."POS Ticket Profile");

        TicketProfileCode := SpeedGateLibrary.CreateProfile();
        GateId := SpeedGateLibrary.GateSetup('GATE01', true, TicketProfileCode, '');
        PosTicketProfile.ScannerIdForUnitAdmitEoSId := GateId;
        PosTicketProfile.Modify();

        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', GetOneTicketWithTwoAdmissions());
        Ticket.FindFirst();

        TicketType.Get(Ticket."Ticket Type Code");
        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_BOM;
        TicketType.Modify();

        // Default value is SCAN, add all admission codes to the profile associated with GATE01
        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.FindSet();
        repeat
            TicketBom."Activation Method" := TicketBom."Activation Method"::PER_UNIT;
            TicketBom.Modify();
            SpeedGateLibrary.AddToProfile(TicketProfileCode, true, '', TicketBom."Admission Code", '', 0T, 0T);
        until TicketBom.Next() = 0;

        // The check will not be able to fill the admission code list, so it will be empty. 
        SpeedGate.SetEndOfSalesAdmitMode();
        AttemptToAdmit := SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToAdmissions, ResponseCode);

        Assert.IsTrue(AttemptToAdmit, 'Expected to be able to admit ticket with PER_UNIT activation method during end sale.');
        Assert.AreEqual(AdmitToAdmissions.Count(), 2, StrSubstNo('Expected zero admit to admissions, but got %1', AdmitToAdmissions.Count()));

        // Speed gate has an empty ticket profile, 
        // pos unit has a dedicated gate to read profile from (GATE01) 
        // speed gate admit should succeed
        AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo);
        AdmitCount := ValidatePermitted(AdmitToken);

        Assert.AreEqual(AdmitCount, 2, StrSubstNo('Expected 2 admissions to be admitted, but got %1', AdmitCount));
    end;

    [Normal]
    procedure ValidatePermitted(AdmitToken: Guid) AdmitCount: Integer
    var
        EntryLog: Record "NPR SGEntryLog";
        SpeedGate: Codeunit "NPR SG SpeedGate";
    begin
        EntryLog.SetCurrentKey(Token);
        EntryLog.SetFilter(Token, '=%1', AdmitToken);
        EntryLog.FindSet();
        repeat
            EntryLog.TestField(ReferenceNumberType, EntryLog.ReferenceNumberType::TICKET);
            EntryLog.TestField(EntryStatus, EntryLog.EntryStatus::PERMITTED_BY_GATE);
        until (EntryLog.Next() = 0);

        SpeedGate.Admit(AdmitToken, 1);

        EntryLog.FindSet();
        repeat
            EntryLog.TestField(EntryStatus, EntryLog.EntryStatus::ADMITTED);
            ValidateAdmitted(EntryLog.ReferenceNo, EntryLog.AdmissionCode, EntryLog.ScannerId);
            AdmitCount += 1;
        until (EntryLog.Next() = 0);
    end;

    [Normal]
    procedure ValidateDeniedUnknown(AdmitToken: Guid)
    var
        EntryLog: Record "NPR SGEntryLog";
        SpeedGate: Codeunit "NPR SG SpeedGate";
    begin
        EntryLog.SetCurrentKey(Token);
        EntryLog.SetFilter(Token, '=%1', AdmitToken);
        EntryLog.FindFirst();

        EntryLog.TestField(ReferenceNumberType, EntryLog.ReferenceNumberType::UNKNOWN);
        EntryLog.TestField(EntryStatus, EntryLog.EntryStatus::DENIED_BY_GATE);

        asserterror SpeedGate.Admit(AdmitToken, 1);
    end;

    [Normal]
    procedure ValidateDeniedRejected(AdmitToken: Guid)
    var
        EntryLog: Record "NPR SGEntryLog";
        SpeedGate: Codeunit "NPR SG SpeedGate";
    begin
        EntryLog.SetCurrentKey(Token);
        EntryLog.SetFilter(Token, '=%1', AdmitToken);
        EntryLog.FindFirst();

        EntryLog.TestField(ReferenceNumberType, EntryLog.ReferenceNumberType::REJECTED);
        EntryLog.TestField(EntryStatus, EntryLog.EntryStatus::DENIED_BY_GATE);

        asserterror SpeedGate.Admit(AdmitToken, 1);
    end;

    [Normal]
    procedure ValidateDeniedTicket(AdmitToken: Guid)
    var
        EntryLog: Record "NPR SGEntryLog";
        SpeedGate: Codeunit "NPR SG SpeedGate";
    begin
        EntryLog.SetCurrentKey(Token);
        EntryLog.SetFilter(Token, '=%1', AdmitToken);
        EntryLog.FindFirst();

        EntryLog.TestField(ReferenceNumberType, EntryLog.ReferenceNumberType::TICKET);
        EntryLog.TestField(EntryStatus, EntryLog.EntryStatus::DENIED_BY_GATE);

        asserterror SpeedGate.Admit(AdmitToken, 1);
    end;

    procedure CreatePosUnit(var PosUnitNo: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        PosTicketProfile: Record "NPR TM POS Ticket Profile";
    begin

        if (PosTicketProfile.Get('POS_TM_01')) then
            PosTicketProfile.Delete();

        PosTicketProfile.Init();
        PosTicketProfile.Code := 'POS_TM_01';
        PosTicketProfile."Description" := 'DEFAULT';
        PosTicketProfile.Insert(true);

        if (POSUnit.Get('POS_TM_01')) then
            POSUnit.Delete();

        POSUnit.Init();
        POSUnit."No." := 'POS_TM_01';
        POSUnit.Name := 'POS_TM_01';
        POSUnit."POS Ticket Profile" := PosTicketProfile.Code;
        POSUnit.Insert(true);

        POSUnitNo := POSUnit."No.";
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
    procedure GetOneTicketWithTwoAdmissions() ExternalTicketNumber: Code[30]
    var
        TicketQuantityPerOrder: Integer;
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
    begin
        TicketQuantityPerOrder := 1;
        CreateTicket2(TicketQuantityPerOrder, TmpCreatedTickets);
        TmpCreatedTickets.Reset();
        TmpCreatedTickets.FindFirst();
        ExternalTicketNumber := TmpCreatedTickets."External Ticket No.";
    end;

    [Normal]
    procedure CreateTicket(TicketQuantityPerOrder: Integer; var TmpCreatedTickets: Record "NPR TM Ticket" temporary) ResponseToken: Text[100];
    var
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
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
    procedure CreateTicket2(TicketQuantityPerOrder: Integer; var TmpCreatedTickets: Record "NPR TM Ticket" temporary) ResponseToken: Text[100];
    var
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := TicketSmokeTestScenario2();

        NumberOfTicketOrders := 1;
        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');
    end;

    [Normal]
    local procedure ValidateAdmitted(ExternalTicketNumber: Code[30]; AdmissionCode: Code[20]; GateCode: Code[10])
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        Ticket.SetFilter(Ticket."External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        TicketAccessEntry.FindFirst();
        TicketAccessEntry.TestField("Access Date");
        TicketAccessEntry.TestField("Access Time");

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
        if (DetTicketAccessEntry.Count() <> 1) then
            Error('Expected 1 Admitted DetTicketAccessEntry, but found %1', DetTicketAccessEntry.Count());

        //DetTicketAccessEntry.TestField("Scanner Station ID", GateCode);
    end;

    [Normal]
    local procedure TicketSmokeTestScenario() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
    end;

    local procedure TicketSmokeTestScenario2() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_SmokeTest2();
    end;
}