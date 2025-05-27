codeunit 6248458 "NPR POSActionRegisterGuestsB"
{
    Access = Internal;

    internal procedure GetConfigurationJson(POSUnitNo: Code[10]) Config: JsonObject
    var
        Entry: Record "NPR SGEntryLog";
        Member: Record "NPR MM Member";
        Tickets: Record "NPR TM Ticket";
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipGuest: Record "NPR MM Members. Admis. Setup";
        Speedgate: Codeunit "NPR SG SpeedGate";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ItemNumber: Code[20];
        ItemVariantCode: Code[10];
        Resolver, TicketsCreatedToday : Integer;
        AdmitToken: Guid;
        TempJValue: JsonValue;
        GuestArray: JsonArray;
        TempJObject: JsonObject;
    begin
        if (not TryGetLastScannedMemberCard(POSUnitNo, Entry)) then
            exit(ErrorWithMessage(GetLastErrorText()));

        MemberCard.SetCurrentKey("External Card No.");
        MemberCard.SetRange("External Card No.", Entry.ReferenceNo);
        MemberCard.FindFirst();

        Membership.Get(MemberCard."Membership Entry No.");

        MembershipGuest.SetRange("Membership  Code", Membership."Membership Code");
        if (Entry.AdmissionCode <> '') then
            MembershipGuest.SetRange("Admission Code", Entry.AdmissionCode);

        if (not MembershipGuest.FindSet()) then begin
            TempJValue.SetValueToNull();
            Config.Add('success', true);
            Config.Add('guests', TempJValue);
            exit(Config);
        end;

        Config.Add('success', true);

        repeat
            Clear(TempJObject);

            AdmitToken := Speedgate.CreateMemberGuestAdmissionToken(Entry, MembershipGuest);

            if (MembershipGuest."Cardinality Type" = MembershipGuest."Cardinality Type"::UNLIMITED) then
                MembershipGuest."Max Cardinality" := -1;

            if (Member.Get(MemberCard."Member Entry No.")) then begin

                Tickets.SetCurrentKey("External Member Card No.", "Item No.", "Variant Code", "Document Date");
                Tickets.SetFilter("External Member Card No.", '=%1', Member."External Member No.");

                if (MembershipGuest."Ticket No. Type" = MembershipGuest."Ticket No. Type"::ITEM) then
                    Tickets.SetFilter("Item No.", '=%1', MembershipGuest."Ticket No.");

                if (MembershipGuest."Ticket No. Type" = MembershipGuest."Ticket No. Type"::ITEM_CROSS_REF) then begin
                    if (not TicketRequestManager.TranslateBarcodeToItemVariant(MembershipGuest."Ticket No.", ItemNumber, ItemVariantCode, Resolver)) then
                        Error('Could not resolve barcode to item number for membership code %1, reference %2', MembershipGuest."Membership  Code", MembershipGuest."Ticket No.");
                    Tickets.SetFilter("Item No.", '=%1', ItemNumber);
                end;

                Tickets.SetFilter("Document Date", '=%1', Today());
                TicketsCreatedToday := Tickets.Count();
            end;

            TempJObject.Add('token', Format(AdmitToken, 0, 4).ToLower());
            TempJObject.Add('admissionCode', MembershipGuest."Admission Code");
            TempJObject.Add('description', MembershipGuest.Description);
            TempJObject.Add('maxNumberOfGuests', MembershipGuest."Max Cardinality");
            TempJObject.Add('guestsAdmittedToday', TicketsCreatedToday);
            GuestArray.Add(TempJObject);
        until MembershipGuest.Next() = 0;

        Config.Add('guests', GuestArray);
        exit(Config);
    end;

    internal procedure AdmitTokens(Tokens: JsonArray)
    var
        Speedgate: Codeunit "NPR SG SpeedGate";
        Token, TempToken : JsonToken;
        JHelper: Codeunit "NPR Json Helper";
        Qty: Integer;
    begin
        foreach Token in Tokens do begin
            Token.SelectToken('quantity', TempToken);
            Qty := TempToken.AsValue().AsInteger();
            if (Qty > 0) then
                Speedgate.Admit(
                    JHelper.GetJText(Token, 'token', true),
                    Qty
                );
        end;
    end;

    [TryFunction]
    local procedure TryGetLastScannedMemberCard(POSUnitNo: Code[10]; var Entry: Record "NPR SGEntryLog")
    var
        NullGuid: Guid;
        CouldNotFindScanWithin15MinsErr: Label 'Could not find a recent scan (within 15 minutes) from this POS Unit (scanner id %1)', Comment = '%1 = scanner id';
        NotAMemberCardErr: Label 'Last scanned reference was not a member card.';
        NotAdmittedAndAllowed: Label 'Member card was not admitted and allowed therefore guests cannot be added.';
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        Entry.SetRange(ScannerId, POSUnitNo);
        Entry.SetRange(ParentToken, NullGuid); // We don't want children / guest lines, we want the actual scan!
        Entry.SetFilter(SystemCreatedAt, '>%1', CurrentDateTime() - JobQueueMgt.MinutesToDuration(15));
        if (not Entry.FindLast()) then
            Error(CouldNotFindScanWithin15MinsErr, POSUnitNo);

        if (Entry.ReferenceNumberType <> Entry.ReferenceNumberType::MEMBER_CARD) then
            Error(NotAMemberCardErr);
        if (not (Entry.EntryStatus in [Entry.EntryStatus::ADMITTED, Entry.EntryStatus::PERMITTED_BY_GATE])) then
            Error(NotAdmittedAndAllowed);
    end;

    local procedure ErrorWithMessage(Message: Text) Response: JsonObject
    begin
        Response.Add('success', false);
        Response.Add('errorMessage', Message);
        exit(Response);
    end;
}