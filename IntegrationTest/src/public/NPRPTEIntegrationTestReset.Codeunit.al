codeunit 61000 "NPRPTE Integration Test Reset"
{
    procedure ResetState()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        POSSavedSaleLine: Record "NPR POS Saved Sale Line";
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        POSUnit: Record "NPR POS Unit";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSAuditLog: Record "NPR POS Audit Log";
        EnvironmentInfo: Codeunit "Environment Information";
        TMTicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        TMTicket: Record "NPR TM Ticket";
        TMDetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TMTicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TMTicketNotifEntry: Record "NPR TM Ticket Notif. Entry";
        MMMember: Record "NPR MM Member";
        MMMemberCard: Record "NPR MM Member Card";
        MMMembershipEntry: Record "NPR MM Membership Entry";
        MMMembersPointsEntry: Record "NPR MM Members. Points Entry";
        MMSponsorsTicketEntry: Record "NPR MM Sponsors. Ticket Entry";
        MMMemberInfoCapture: Record "NPR MM Member Info Capture";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpDcCoupon: Record "NPR NpDc Coupon";
        ExchangeLabel: Record "NPR Exchange Label";
        POSRMALine: Record "NPR POS RMA Line";
    begin
        if not EnvironmentInfo.IsSandbox() then
            exit;

        POSEntry.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
        POSEntryTaxLine.DeleteAll();
        POSWorkshiftCheckpoint.DeleteAll();
        POSSavedSaleEntry.DeleteAll();
        POSSavedSaleLine.DeleteAll();
        POSSale.DeleteAll();
        POSSaleLine.DeleteAll();
        POSEntryOutputLog.DeleteAll();
        POSAuditLog.DeleteAll();

        NpRvVoucher.DeleteAll();
        NpDcCoupon.DeleteAll();
        ExchangeLabel.DeleteAll();
        POSRMALine.DeleteAll();

        TMTicket.DeleteAll();
        TMDetTicketAccessEntry.DeleteAll();
        TMTicketReservationReq.DeleteAll();
        TMTicketNotifEntry.DeleteAll();
        TMTicketAccessEntry.DeleteAll();

        MMMember.DeleteAll();
        MMMemberCard.DeleteAll();
        MMMembershipEntry.DeleteAll();
        MMMembersPointsEntry.DeleteAll();
        MMSponsorsTicketEntry.DeleteAll();
        MMMemberInfoCapture.DeleteAll();

        POSUnit.ModifyAll(Status, POSUnit.Status::OPEN);

        if GuiAllowed then
            Message('State reset');
    end;


}