#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248204 "NPR DigNotif Ticket Impl" implements "NPR IDigNotifAssetProcessor"
{
    Access = Internal;

    procedure ProcessAsset(var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary; var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary; var Context: Codeunit "NPR DigNotif Manifest Context")
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        OrderID: Text;
        DigitalNotifSetup: Record "NPR Digital Notification Setup";
    begin
        DigitalNotifSetup := Context.Setup();
        if DigitalNotifSetup."Exclude Tickets From Manifest" then
            exit;

        // 1. Ecom direct link: use Ticket Reservation Line Id (Guid) for precise 1:1 match
        if not IsNullGuid(TempLineBuffer."Ticket Reservation Line Id") then begin
            if TicketReservationReq.GetBySystemId(TempLineBuffer."Ticket Reservation Line Id") then
                if TicketReservationReq."Request Status" = TicketReservationReq."Request Status"::CONFIRMED then
                    AddTicketsFromReservation(TicketReservationReq, Context);
            exit;
        end;

        // 2. Filter by External Order No. (or Shopify Order ID if available) + line reference / item fallback
        OrderID := TempHeaderBuffer."External Order No.";
        // For Shopify orders use the Shopify Order ID (the canonical identifier used when creating the reservation)
        if TempHeaderBuffer."Shopify Order ID" <> '' then
            OrderID := TempHeaderBuffer."Shopify Order ID";

        FilterTicketReservations(OrderID, TempLineBuffer, TicketReservationReq);
        if not TicketReservationReq.FindSet() then
            exit;

        repeat
            AddTicketsFromReservation(TicketReservationReq, Context);
        until TicketReservationReq.Next() = 0;
    end;

    local procedure FilterTicketReservations(
        OrderID: Text;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        var TicketReservationReq: Record "NPR TM Ticket Reservation Req.")
    begin
        TicketReservationReq.Reset();
        TicketReservationReq.SetRange("External Order No.", OrderID);
        TicketReservationReq.SetRange("Request Status", TicketReservationReq."Request Status"::CONFIRMED);

        // Try precise match first: Ext. Line Reference No.
        TicketReservationReq.SetRange("Ext. Line Reference No.", TempLineBuffer."Line No.");
        if not TicketReservationReq.IsEmpty() then
            exit;

        // Fallback: match by Item No. + Variant Code
        // Process ALL matching reservations to handle multiple timeslots for the same item
        TicketReservationReq.SetRange("Ext. Line Reference No.");
        TicketReservationReq.SetRange("Item No.", TempLineBuffer."No.");
        TicketReservationReq.SetRange("Variant Code", TempLineBuffer."Variant Code");
    end;

    local procedure AddTicketsFromReservation(
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        var Context: Codeunit "NPR DigNotif Manifest Context")
    var
        Ticket: Record "NPR TM Ticket";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        if Context.AlreadyProcessed(TicketReservationReq) then
            exit;

        Ticket.SetLoadFields("Item No.", "Variant Code", "External Ticket No.", SystemId);
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        if Ticket.FindSet() then
            repeat
                TicketAdmissionBOM.SetLoadFields(NPDesignerTemplateId);
                if TicketAdmissionBOM.Get(Ticket."Item No.", Ticket."Variant Code", TicketReservationReq."Admission Code") then
                    if TicketAdmissionBOM.NPDesignerTemplateId <> '' then begin
                        NPDesignerManifestFacade.AddAssetToManifest(
                            Context.ManifestId(),
                            Database::"NPR TM Ticket",
                            Ticket.SystemId,
                            Ticket."External Ticket No.",
                            TicketAdmissionBOM.NPDesignerTemplateId
                        );
                        Context.RegisterAsset();
                    end;
            until Ticket.Next() = 0;
    end;
}
#endif
