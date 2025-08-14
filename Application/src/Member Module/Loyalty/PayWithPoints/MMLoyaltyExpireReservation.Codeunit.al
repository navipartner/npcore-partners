codeunit 6184912 "NPR MMLoyaltyExpireReservation"
{
    Access = Internal;

    trigger OnRun()
    begin
        ExpireReservationAllStores();
    end;

    internal procedure ExpireReservationAllStores()
    var
        StoreSetup: Record "NPR MM Loyalty Store Setup";
    begin
        StoreSetup.SetFilter(Setup, '=%1|=%2', StoreSetup.Setup::SERVER, StoreSetup.Setup::BOTH);
        if (not StoreSetup.FindSet()) then
            exit;
        repeat
            ExpireReservationStore(StoreSetup);
            Commit();
        until (StoreSetup.Next() = 0)

    end;

    internal procedure ExpireReservationStore(StoreSetup: Record "NPR MM Loyalty Store Setup")
    var
        OpenReservation: Record "NPR MM Loy. LedgerEntry (Srvr)";
        PointMgr: Codeunit "NPR MM Loy. Point Mgr (Server)";
        UntilDate: Date;
        EmptyDateFormula: DateFormula;
    begin
        ExpireReservationBasedExprireAt(StoreSetup);
        if StoreSetup.ReservationMaxAge = EmptyDateFormula then
            exit;
        UntilDate := Today() - Abs(Today() - CalcDate(StoreSetup.ReservationMaxAge));

        if (StoreSetup.CancelReservationFromDate > UntilDate) then
            exit;
        FilterReservationsToStore(OpenReservation, StoreSetup);
        OpenReservation.SetFilter("Transaction Date", '%1..%2', StoreSetup.CancelReservationFromDate, UntilDate);
        OpenReservation.SetAutoCalcFields("Reservation is Cancelled", "Reservation is Captured");
        if (OpenReservation.FindSet()) then
            repeat
                if ((not OpenReservation."Reservation is Captured") and (not OpenReservation."Reservation is Cancelled")) then begin
                    PointMgr.ExpireReservations(OpenReservation);
                    Commit();
                end;

            until (OpenReservation.Next() = 0);
        StoreSetup.CancelReservationFromDate := UntilDate;
        StoreSetup.Modify();
    end;

    local procedure ExpireReservationBasedExprireAt(var StoreSetup: Record "NPR MM Loyalty Store Setup")
    var
        OpenReservation: Record "NPR MM Loy. LedgerEntry (Srvr)";
        PointMgr: Codeunit "NPR MM Loy. Point Mgr (Server)";
        Now: DateTime;
    begin
        Now := CurrentDateTime;
        FilterReservationsToStore(OpenReservation, StoreSetup);
        if StoreSetup.LastExpireUpdate = 0DT then
            StoreSetup.LastExpireUpdate := CreateDateTime(20000101D, 000000T);
        OpenReservation.SetRange("Expires At", StoreSetup.LastExpireUpdate, Now);
        OpenReservation.SetAutoCalcFields("Reservation is Cancelled", "Reservation is Captured");
        if (OpenReservation.FindSet()) then
            repeat
                if ((not OpenReservation."Reservation is Captured") and (not OpenReservation."Reservation is Cancelled")) then begin
                    PointMgr.ExpireReservations(OpenReservation);
                    Commit();
                end;
            until (OpenReservation.Next() = 0);
        StoreSetup.LastExpireUpdate := Now;
        StoreSetup.Modify(false);
    end;

    local procedure FilterReservationsToStore(var Reservation: Record "NPR MM Loy. LedgerEntry (Srvr)"; StoreSetup: Record "NPR MM Loyalty Store Setup")
    begin
        Reservation.SetFilter("Company Name", '=%1', StoreSetup."Client Company Name");
        Reservation.SetFilter("POS Store Code", '=%1', StoreSetup."Store Code");
        Reservation.SetFilter("POS Unit Code", '=%1', StoreSetup."Unit Code");
        Reservation.SetFilter("Entry Type", '=%1', Reservation."Entry Type"::RESERVE);
    end;

}