codeunit 6151348 "NPR Tickets Sold Metric" implements "NPR ICustomer Date Metric"
{
    Access = Internal;
    Permissions =
        TableData "NPR Customer Metric Open Entry" = RID;

    var
        _IsGroupTicketByItem: Dictionary of [Code[20], Boolean];

    procedure GetEventType(): Enum "NPR Billing Event Type"
    begin
        exit(Enum::"NPR Billing Event Type"::TICKETS_SOLD_COUNT);
    end;

    procedure IsDelta(): Boolean
    begin
        exit(true);
    end;

    procedure Calculate(var MetricSync: Record "NPR Customer Metric Sync"; var Metadata: JsonObject): Decimal
    var
        OneHour: Duration;
        OneDay: Duration;
    begin
        OneHour := 60 * 60 * 1000;
        OneDay := 24 * OneHour;
        // Request numbers are given when a request is inserted, before it commits, so the newest hour waits for the next run.
        // An unconfirmed request is followed for at least 30 days, as long as an unpaid web order keeps its reservation.
        exit(CountTicketsSold(MetricSync, CurrentDateTime() - OneHour, CurrentDateTime() - 30 * OneDay));
    end;

    internal procedure CountTicketsSold(var MetricSync: Record "NPR Customer Metric Sync"; CreatedBefore: DateTime; FollowSince: DateTime) TicketsSold: Integer
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        LastSentEntryNo: Integer;
        LastEntryNo: Integer;
    begin
        if not MetricSync.FindLastSentEntryNo(LastSentEntryNo) then
            // The first event starts at the business date instead of covering the whole history
            LastSentEntryNo := LastEntryNoCreatedBefore(CreateDateTime(MetricSync."Business Date", 0T));

        TicketsSold := CountConfirmedOpenRequests(MetricSync.Metric, FollowSince);

        MetricSync."Last Entry No." := LastSentEntryNo;
        LastEntryNo := LastEntryNoCreatedBefore(CreatedBefore);
        if LastEntryNo <= LastSentEntryNo then
            exit(TicketsSold);

        TicketRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        TicketRequest.SetRange("Entry No.", LastSentEntryNo + 1, LastEntryNo);
        TicketRequest.SetRange("Entry Type", TicketRequest."Entry Type"::PRIMARY);
        TicketRequest.SetRange("Revoke Ticket Request", false);
        TicketRequest.SetFilter(Quantity, '>%1', 0);
        TicketRequest.SetLoadFields("Primary Request Line", "Receipt No.", "Request Status", "Entry Type", "Revoke Ticket Request", Quantity, "Item No.", "Expires Date Time", SystemCreatedAt);
        if TicketRequest.FindSet() then
            repeat
                if IsSoldTicketLine(TicketRequest) then
                    TicketsSold += TicketsOnRequest(TicketRequest)
                else
                    if IsOpen(TicketRequest) and IsFollowed(TicketRequest, FollowSince) then
                        RememberOpenRequest(MetricSync.Metric, TicketRequest."Entry No.");
            until TicketRequest.Next() = 0;
        MetricSync."Last Entry No." := LastEntryNo;
    end;

    local procedure CountConfirmedOpenRequests(Metric: Enum "NPR Customer Metric"; FollowSince: DateTime) TicketsSold: Integer
    var
        OpenEntry: Record "NPR Customer Metric Open Entry";
        ClosedOpenEntry: Record "NPR Customer Metric Open Entry";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        OpenEntry.SetRange(Metric, Metric);
        if not OpenEntry.FindSet() then
            exit;
        TicketRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        TicketRequest.SetLoadFields("Primary Request Line", "Receipt No.", "Request Status", "Entry Type", "Revoke Ticket Request", Quantity, "Item No.", "Expires Date Time", SystemCreatedAt);
        repeat
            ClosedOpenEntry := OpenEntry;
            if not TicketRequest.Get(OpenEntry."Entry No.") then
                ClosedOpenEntry.Delete()
            else
                if IsSoldTicketLine(TicketRequest) then begin
                    TicketsSold += TicketsOnRequest(TicketRequest);
                    ClosedOpenEntry.Delete();
                end else
                    if not IsOpen(TicketRequest) or not IsFollowed(TicketRequest, FollowSince) then
                        ClosedOpenEntry.Delete();
        until OpenEntry.Next() = 0;
    end;

    local procedure IsFollowed(TicketRequest: Record "NPR TM Ticket Reservation Req."; FollowSince: DateTime): Boolean
    begin
        // A paid web order keeps its request open with a later expiry until a confirmation retry succeeds, which can be much later
        exit((TicketRequest.SystemCreatedAt >= FollowSince) or (TicketRequest."Expires Date Time" > CurrentDateTime()));
    end;

    local procedure RememberOpenRequest(Metric: Enum "NPR Customer Metric"; EntryNo: Integer)
    var
        OpenEntry: Record "NPR Customer Metric Open Entry";
    begin
        OpenEntry.Metric := Metric;
        OpenEntry."Entry No." := EntryNo;
        if OpenEntry.Insert() then;
    end;

    local procedure IsOpen(TicketRequest: Record "NPR TM Ticket Reservation Req."): Boolean
    begin
        if not IsSale(TicketRequest) then
            exit(false);
        // A POS line only becomes the primary line once its time slot is chosen
        if not TicketRequest."Primary Request Line" and (TicketRequest."Receipt No." = '') then
            exit(false);
        // An expired line can be reserved again and confirmed until the expiry sweep deletes it
        exit(TicketRequest."Request Status" in [TicketRequest."Request Status"::REGISTERED, TicketRequest."Request Status"::WIP, TicketRequest."Request Status"::EXPIRED]);
    end;

    local procedure IsSoldTicketLine(TicketRequest: Record "NPR TM Ticket Reservation Req."): Boolean
    begin
        if not TicketRequest."Primary Request Line" or not IsSale(TicketRequest) then
            exit(false);
        // A request only becomes RESERVED after it was confirmed, when it is attached to an order or moved to another receipt
        exit(TicketRequest."Request Status" in [TicketRequest."Request Status"::CONFIRMED, TicketRequest."Request Status"::RESERVED]);
    end;

    local procedure IsSale(TicketRequest: Record "NPR TM Ticket Reservation Req."): Boolean
    begin
        exit((TicketRequest."Entry Type" = TicketRequest."Entry Type"::PRIMARY) and not TicketRequest."Revoke Ticket Request" and (TicketRequest.Quantity > 0));
    end;

    local procedure TicketsOnRequest(TicketRequest: Record "NPR TM Ticket Reservation Req."): Integer
    begin
        if IsGroupTicket(TicketRequest."Item No.") then
            exit(1);
        exit(TicketRequest.Quantity);
    end;

    local procedure IsGroupTicket(ItemNo: Code[20]) GroupTicket: Boolean
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
    begin
        if _IsGroupTicketByItem.Get(ItemNo, GroupTicket) then
            exit(GroupTicket);
        Item.SetLoadFields("NPR Ticket Type");
        if Item.Get(ItemNo) then begin
            TicketType.SetLoadFields("Admission Registration");
            if TicketType.Get(Item."NPR Ticket Type") then
                GroupTicket := TicketType."Admission Registration" = TicketType."Admission Registration"::GROUP;
        end;
        _IsGroupTicketByItem.Add(ItemNo, GroupTicket);
    end;

    local procedure LastEntryNoCreatedBefore(CreatedBefore: DateTime): Integer
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        TicketRequest.SetFilter(SystemCreatedAt, '<%1', CreatedBefore);
        TicketRequest.SetLoadFields("Entry No.");
        if TicketRequest.FindLast() then
            exit(TicketRequest."Entry No.");
    end;
}
