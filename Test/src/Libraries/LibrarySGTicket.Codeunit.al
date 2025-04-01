codeunit 85216 "NPR Library - SG Ticket"
{
    Access = Internal;

    procedure NoSpeedGateSetup()
    var
        SpeedGateDefault: Record "NPR SG SpeedGateDefault";
        SpeedGate: Record "NPR SG SpeedGate";
    begin
        SpeedGateDefault.DeleteAll();
        SpeedGate.DeleteAll();
    end;

    procedure DefaultSetup(RequireScannerId: Boolean; PermitTickets: Boolean; TicketProfileCode: Code[10]; AllowedNumbersList: Code[10])
    var
        SpeedGateDefault: Record "NPR SG SpeedGateDefault";
    begin
        NoSpeedGateSetup();
        SpeedGateDefault.RequireScannerId := RequireScannerId;
        SpeedGateDefault.PermitTickets := PermitTickets;
        SpeedGateDefault.DefaultTicketProfileCode := TicketProfileCode;
        SpeedGateDefault.AllowedNumbersList := AllowedNumbersList;
        SpeedGateDefault.Insert();
    end;

    procedure GateSetup(ScannerId: Code[10]; PermitTickets: Boolean; TicketProfileCode: Code[10]; AllowedNumbersList: Code[10])
    var
        SpeedGate: Record "NPR SG SpeedGate";
    begin

        SpeedGate.SetFilter(ScannerId, '=%1', ScannerId);

        if (SpeedGate.FindFirst()) then
            SpeedGate.Delete();

        SpeedGate.ScannerId := ScannerId;
        SpeedGate.PermitTickets := PermitTickets;
        SpeedGate.TicketProfileCode := TicketProfileCode;
        SpeedGate.AllowedNumbersList := AllowedNumbersList;

        SpeedGate.Insert(true);
    end;

    procedure AddToWhiteList(Prefix: Code[30]; NumberLength: Integer; Strict: Boolean) ListCode: Code[10]
    var
        NumberWhiteList: Record "NPR SG AllowedNumbersList";
        NumberWhiteListLine: Record "NPR SG NumberWhiteListLine";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ListCode := TicketLibrary.GenerateCode10();
        if (NumberWhiteList.Get(ListCode)) then begin
            NumberWhiteListLine.SetFilter(NumberWhiteListLine.Code, '=%1', ListCode);
            NumberWhiteListLine.DeleteAll();
            NumberWhiteList.Delete();
        end;

        NumberWhiteList.Code := ListCode;
        NumberWhiteList.ValidateMode := NumberWhiteList.ValidateMode::FLEXIBLE;
        if (Strict) then
            NumberWhiteList.ValidateMode := NumberWhiteList.ValidateMode::STRICT;
        NumberWhiteList.Insert();

        AddToWhiteList(NumberWhiteList.Code, Prefix, NumberLength);
    end;

    procedure AddToWhiteList(Code: Code[10]; Prefix: Code[30]; NumberLength: Integer)
    var
        NumberWhiteListLine: Record "NPR SG NumberWhiteListLine";
    begin
        NumberWhiteListLine.Code := Code;
        NumberWhiteListLine.Type := NumberWhiteListLine.Type::TICKET;
        NumberWhiteListLine.Prefix := Prefix;
        NumberWhiteListLine.NumberLength := NumberLength;
        NumberWhiteListLine.Insert();
    end;

    procedure CreateProfile() ListCode: Code[10]
    begin
        exit(CreateProfile(false));
    end;

    procedure CreateProfile(PermitTheTicketRequestToken: Boolean) ListCode: Code[10]
    var
        TicketProfile: Record "NPR SG TicketProfile";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ListCode := TicketLibrary.GenerateCode10();
        if (TicketProfile.Get(ListCode)) then
            TicketProfile.Delete();

        TicketProfile.Code := ListCode;
        TicketProfile.PermitTicketRequestToken := PermitTheTicketRequestToken;
        TicketProfile.Insert(true);
    end;


    procedure AddToProfile(Code: Code[10]; Allow: Boolean; ItemNo: Code[20]; AdmissionCode: Code[20]; CalendarCode: Code[10]; FromTime: Time; UntilTime: Time)
    var
        TicketProfileLine: Record "NPR SG TicketProfileLine";
    begin
        TicketProfileLine.Code := Code;
        TicketProfileLine.RuleType := TicketProfileLine.RuleType::ALLOW;
        if (not Allow) then
            TicketProfileLine.RuleType := TicketProfileLine.RuleType::REJECT;
        TicketProfileLine.ItemNo := ItemNo;
        TicketProfileLine.AdmissionCode := AdmissionCode;
        TicketProfileLine.CalendarCode := CalendarCode;
        TicketProfileLine.PermitFromTime := FromTime;
        TicketProfileLine.PermitUntilTime := UntilTime;
        TicketProfileLine.Insert(true);
    end;
}