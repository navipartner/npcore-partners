codeunit 6248436 "NPR TM Ticket Facade"
{
    procedure GetTicketHolderFromNotificationAddress(NotificationAddress: Text[100]; var TicketHolder: Record "NPR TM TicketHolder")
    var
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin
        NotifyParticipant.GetTicketHolderFromNotificationAddress(NotificationAddress, TicketHolder);
    end;

    procedure SetTicketHolderInfo(var TicketHolder: Record "NPR TM TicketHolder")
    var
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin
        NotifyParticipant.SetTicketHolderInfo(TicketHolder);
    end;

    procedure IncrementPrintCount(TicketId: Guid)
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TicketManagement.IncrementPrintCount(TicketId);
    end;

    procedure IncrementPrintCount(TicketNo: Code[20])
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TicketManagement.IncrementPrintCount(TicketNo);
    end;

    procedure CreateTicketWelcomeNotifications(Ticket: Record "NPR TM Ticket")
    var
        TicketNotification: Codeunit "NPR TM Ticket Notify Particpt.";
    begin
        TicketNotification.CreateTicketReservationReminder(Ticket);
    end;

    procedure GetNextPossibleAdmissionScheduleStartTime(ItemNo: Code[20]; VariantCode: Code[10]): Time
    var
        TMTicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        exit(TMTicketManagement.GetNextPossibleAdmissionScheduleStartTime(ItemNo, VariantCode));
    end;

    procedure RevokeTicket(Ticket: Record "NPR TM Ticket")
    var
        TMTicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TMTicketManagement.RevokeTicket(Ticket);
    end;

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

}