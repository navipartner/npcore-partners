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
    begin
        StoreSetup.TestField(ReservationMaxAge);
        UntilDate := Today() - Abs(Today() - CalcDate(StoreSetup.ReservationMaxAge));

        if (StoreSetup.CancelReservationFromDate > UntilDate) then
            exit;

        OpenReservation.SetFilter("Entry Type", '=%1', OpenReservation."Entry Type"::RESERVE);
        OpenReservation.SetFilter("Transaction Date", '%1..%2', StoreSetup.CancelReservationFromDate, UntilDate);
        OpenReservation.SetAutoCalcFields("Reservation is Cancelled", "Reservation is Captured");
        if (OpenReservation.FindSet()) then begin
            repeat
                if ((not OpenReservation."Reservation is Captured") and (not OpenReservation."Reservation is Cancelled")) then
                    PointMgr.ExpireReservations(OpenReservation);

            until (OpenReservation.Next() = 0);
        end;
        StoreSetup.CancelReservationFromDate := UntilDate;
        StoreSetup.Modify();
    end;

}