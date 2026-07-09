codeunit 6248436 "NPR TM Ticket Facade"
{
    /// <summary>
    /// Finds every distinct ticket holder associated with a notification address (email or phone) by matching ticket reservation requests, returning one holder per unique reservation session token.
    /// The address is normalized before matching, so callers may pass a raw value.
    /// The passed record is cleared first, and an address with no matching requests simply yields an empty set with no error.
    /// </summary>
    /// <param name="NotificationAddress">The notification address (email/phone) to search by; normalized internally before lookup.</param>
    /// <param name="TicketHolder">Output collection (passed by reference): cleared, then populated with one holder per unique reservation session token found.</param>
    procedure GetTicketHolderFromNotificationAddress(NotificationAddress: Text[100]; var TicketHolder: Record "NPR TM TicketHolder")
    var
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin
        NotifyParticipant.GetTicketHolderFromNotificationAddress(NotificationAddress, TicketHolder);
    end;

    /// <summary>
    /// Propagates each holder's edited notification method, address, name and preferred language onto every ticket reservation request that shares the holder's reservation token, normalizing the address before saving.
    /// Throws when the address is invalid for the chosen method (SMS requires a phone number, EMAIL a valid email address); other methods skip validation.
    /// It takes a table write-lock and Modify()s the matched reservation requests, and resets any filters on the passed record so all holders are processed.
    /// Does nothing if the passed collection is empty.
    /// </summary>
    /// <param name="TicketHolder">Collection of edited holder info (passed by reference); Reset() first so every record is iterated. Fields are read, not written back.</param>
    procedure SetTicketHolderInfo(var TicketHolder: Record "NPR TM TicketHolder")
    var
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin
        NotifyParticipant.SetTicketHolderInfo(TicketHolder);
    end;

    /// <summary>
    /// Stamps a single ticket as printed - sets its Printed Date to today and PrintedDateTime to now, increments PrintCount, and saves.
    /// Silently does nothing if no ticket matches the given id.
    /// The Modify runs without triggers and without an explicit Commit, so persistence follows the caller's transaction.
    /// </summary>
    /// <param name="TicketId">The ticket's SystemId.</param>
    procedure IncrementPrintCount(TicketId: Guid)
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TicketManagement.IncrementPrintCount(TicketId);
    end;

    /// <summary>
    /// Stamps a single ticket as printed - sets its Printed Date to today and PrintedDateTime to now, increments PrintCount, and saves.
    /// Silently does nothing if no ticket matches the given number.
    /// The Modify runs without triggers and without an explicit Commit, so persistence follows the caller's transaction.
    /// </summary>
    /// <param name="TicketNo">The ticket's primary-key No.</param>
    procedure IncrementPrintCount(TicketNo: Code[20])
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TicketManagement.IncrementPrintCount(TicketNo);
    end;

    /// <summary>
    /// Despite the name, this creates BOTH welcome and reservation-reminder notification entries for every admission access entry on the ticket, cancelling any prior pending welcome/reserve reminders first.
    /// The ticket's External Member Card No. is used as the member number.
    /// Generation silently no-ops per admission when the admission's notification profile is blank, missing or blocked, when the reservation address is empty, or when the computed notify date is already in the past.
    /// </summary>
    /// <param name="Ticket">The ticket whose admission access entries drive the notifications.</param>
    procedure CreateTicketWelcomeNotifications(Ticket: Record "NPR TM Ticket")
    var
        TicketNotification: Codeunit "NPR TM Ticket Notify Particpt.";
    begin
        TicketNotification.CreateTicketReservationReminder(Ticket);
    end;

    /// <summary>
    /// Returns the time-of-day of the next upcoming admission schedule start across all (unblocked) admissions in the item's BOM, evaluated in each admission's local timezone and re-expressed in the user's timezone.
    /// When nothing qualifies - empty BOM, all schedules blocked, or nothing upcoming - it returns roughly 00:00:00, which a caller cannot distinguish from a genuine midnight start.
    /// </summary>
    /// <param name="ItemNo">The ticket item whose admission BOM lines are scanned.</param>
    /// <param name="VariantCode">Optional variant filter; applied only when non-blank (blank means all variants of the item).</param>
    /// <returns>The time-of-day of the next possible admission schedule start (see summary for the ~00:00:00 "nothing found" default).</returns>
    procedure GetNextPossibleAdmissionScheduleStartTime(ItemNo: Code[20]; VariantCode: Code[10]): Time
    var
        TMTicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        exit(TMTicketManagement.GetNextPossibleAdmissionScheduleStartTime(ItemNo, VariantCode));
    end;

    /// <summary>
    /// Revokes an already-issued ticket by creating a zero-refund revoke reservation request and immediately executing it, blocking the ticket's access entries right away (not deferred to posting).
    /// No money is refunded - the reverse amount is hard-coded to 0 - and the current UserId is stored as the receipt reference.
    /// Throws if the ticket number doesn't exist or a revoke policy is violated (e.g. an already-admitted UNUSED-policy ticket), but an already-blocked ticket is a silent no-op.
    /// </summary>
    /// <param name="Ticket">The ticket to revoke; only its No. is read and the passed record is not mutated.</param>
    procedure RevokeTicket(Ticket: Record "NPR TM Ticket")
    var
        TMTicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TMTicketManagement.RevokeTicket(Ticket);
    end;

    /// <summary>
    /// Computes a dynamic ticket unit price in two stages: it first resolves the standard ERP price (base, discount %, VAT basis) into the four var outputs, then walks the ticket's admission BOM applying dynamic price rules keyed to the schedule slot that ReferenceDate+ReferenceTime fall into.
    /// ReferenceTime must land inside an admission's schedule window or that admission contributes nothing, and the full ERP-price fallback kicks in only when NO rule matched at all and the accumulated total is still zero - so a partial match (some admissions priced, others out-of-window) leaves the unmatched ones adding nothing.
    /// CustomerNo and Quantity feed only the ERP stage; the returned price is gross and does NOT have ErpDiscountPct applied.
    /// </summary>
    /// <param name="ItemNo">Ticket item; used for both the ERP price lookup and to locate the admission BOM.</param>
    /// <param name="VariantCode">Ticket variant; used for both stages.</param>
    /// <param name="CustomerNo">Customer for customer-specific ERP price lists/discounts; ERP stage only.</param>
    /// <param name="ReferenceDate">Sale date for the ERP price, and must equal the matched schedule entry's admission start date in the dynamic stage.</param>
    /// <param name="ReferenceTime">Dynamic stage only; must fall within a schedule entry's time window for a rule to apply.</param>
    /// <param name="Quantity">ERP stage only (quantity price breaks); when 0 the buffer's decimal quantity is used.</param>
    /// <param name="ErpUnitPrice">Out: the ERP base unit price (0 if no ERP price found).</param>
    /// <param name="ErpDiscountPct">Out: the ERP line discount % (0 if none); returned separately and NOT applied to the return value.</param>
    /// <param name="ErpUnitPriceIncludesVat">Out: whether the ERP unit price is VAT-inclusive; the dynamic price is expressed in the same VAT basis.</param>
    /// <param name="ErpUnitPriceVatPercentage">Out: the ERP VAT % (0 if none).</param>
    /// <returns>The dynamic gross per-unit ticket price, summed across BOM admissions (REQUIRED contribute base+addon, SELECTED contribute addon only); falls back to the ERP unit price when no rule matched.</returns>
    procedure CalculatePrice(
        ItemNo: Code[20]; VariantCode: Code[10];
        CustomerNo: Code[20];
        ReferenceDate: Date; ReferenceTime: Time; Quantity: Integer;
        var ErpUnitPrice: Decimal; var ErpDiscountPct: Decimal; var ErpUnitPriceIncludesVat: Boolean; var ErpUnitPriceVatPercentage: Decimal) TicketUnitPrice: Decimal
    var
        PriceCalculation: Codeunit "NPR TM Dynamic Price";
    begin
        exit(PriceCalculation.CalculatePrice(
            ItemNo, VariantCode,
            CustomerNo,
            ReferenceDate, ReferenceTime, Quantity,
            ErpUnitPrice, ErpDiscountPct, ErpUnitPriceIncludesVat, ErpUnitPriceVatPercentage));
    end;

    /// <summary>
    /// Returns the current wall-clock time in the globally-configured ticket service timezone (TicketSetup.ServiceTimeZoneNo), independent of any admission.
    /// If no service zone is configured it falls back to the BC user/session timezone offset; if a zone is configured but missing from the Time Zone table it silently returns raw UTC.
    /// DST is hand-computed and applied only to a hard-coded set of European zones.
    /// </summary>
    /// <returns>The current DateTime shifted into the configured service timezone.</returns>
    procedure GetLocalDateTimeForService() LocalDateTime: DateTime
    var
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin
        exit(TimeHelper.GetLocalTimeForService());
    end;

    /// <summary>
    /// Text rendering of GetLocalDateTimeForService: the service-timezone "now" formatted as "YYYY-MM-DDTHH:MM:SS &lt;offset&gt;" (e.g. "2026-07-07T14:30:00 +01:00"), with a trailing " DST" when European DST is active.
    /// Same timezone resolution and fallbacks as GetLocalDateTimeForService, so the offset token is +00:00 whenever it falls back to UTC.
    /// </summary>
    /// <returns>The service-timezone current time as ISO-like text with an appended offset (and " DST" suffix when applicable).</returns>
    procedure GetLocalDateTimeForServiceAsText() LocalDateTimeAsText: Text
    var
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin
        exit(TimeHelper.GetLocalTimeForServiceAsText());
    end;

    /// <summary>
    /// Returns the current wall-clock time in a specific admission's timezone, overriding the service timezone only when the admission is found and has its own zone set.
    /// A blank or unknown AdmissionCode (or an admission with no zone) silently falls back to the service timezone.
    /// Beyond that it shares the service-time fallbacks: user/session offset when the resolved zone is 0, raw UTC when the zone id isn't in the Time Zone table, and European-only hand-computed DST.
    /// </summary>
    /// <param name="AdmissionCode">The admission whose timezone is used; blank/not-found falls back to the service timezone.</param>
    /// <returns>The current DateTime shifted into the admission's (or service) timezone.</returns>
    procedure GetLocalDateTimeAtAdmission(AdmissionCode: Code[20]) LocalDateTime: DateTime
    var
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin
        exit(TimeHelper.GetLocalTimeAtAdmission(AdmissionCode));
    end;

    /// <summary>
    /// Text rendering of GetLocalDateTimeAtAdmission: the admission-local "now" formatted as "YYYY-MM-DDTHH:MM:SS &lt;offset&gt;" with a trailing " DST" when European DST is active.
    /// Inherits all of GetLocalDateTimeAtAdmission's resolution and fallback behavior (blank/unknown admission -&gt; service zone; zone 0 -&gt; user offset; unknown zone id -&gt; UTC).
    /// </summary>
    /// <param name="AdmissionCode">The admission whose timezone is used; blank/not-found falls back to the service timezone.</param>
    /// <returns>The admission-local current time as ISO-like text with an appended offset (and " DST" suffix when applicable).</returns>
    procedure GetLocalDateTimeAtAdmissionAsText(AdmissionCode: Code[20]) LocalDateTimeAsText: Text
    var
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin
        exit(TimeHelper.GetLocalTimeAtAdmissionAsText(AdmissionCode));
    end;

}