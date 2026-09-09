codeunit 85415 "NPR NPRE Seating Status Tests"
{
    // [FEATURE] Seating status lifecycle: moving a table between statuses and keeping the Blocked flag in step
    Subtype = Test;

    var
        _Restaurant: Record "NPR NPRE Restaurant";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        _Assert: Codeunit Assert;
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _RestaurantInitialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingMovedToBlockedAndBack_StatusSet_BlockedFlagFollowsTheStatusCode()
    var
        Seating: Record "NPR NPRE Seating";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
    begin
        // [SCENARIO] The Blocked flag a table is filtered on is derived from the status code, so the two cannot drift apart
        // [GIVEN] A restaurant setup naming a blocked status code, and a seating that is currently ready
        Initialize();
        CreateReadySeating(Seating);

        // [WHEN] The seating is moved to the blocked status
        SeatingMgt.SetSeatingIsBlocked(Seating.Code);

        // [THEN] It is flagged as blocked
        Seating.Get(Seating.Code);
        _Assert.AreEqual(
            _LibraryRestaurant.SeatingStatusBlocked(), Seating.Status, 'The seating should carry the blocked status code.');
        _Assert.IsTrue(Seating.Blocked, 'A seating in the blocked status should be flagged as blocked.');

        // [WHEN] It is moved back to ready
        SeatingMgt.SetSeatingIsReady(Seating.Code);

        // [THEN] The flag is cleared again
        Seating.Get(Seating.Code);
        _Assert.AreEqual(
            _LibraryRestaurant.SeatingStatusReady(), Seating.Status, 'The seating should carry the ready status code.');
        _Assert.IsFalse(Seating.Blocked, 'A seating returned to the ready status should no longer be flagged as blocked.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingAlreadyInStatus_SetToTheSameStatus_ReportsNoChange()
    var
        Seating: Record "NPR NPRE Seating";
        xSeating: Record "NPR NPRE Seating";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
    begin
        // [SCENARIO] Re-stating the status a table already has is not a change, so callers do not write or notify for nothing
        // [GIVEN] A seating already in the ready status
        Initialize();
        CreateReadySeating(Seating);
        Seating.Get(Seating.Code);
        xSeating := Seating;

        // [WHEN] It is set to the ready status again
        // [THEN] The setter reports that nothing changed
        _Assert.IsFalse(
            SeatingMgt.SetSeatingStatus(Seating, xSeating, _LibraryRestaurant.SeatingStatusReady()),
            'Setting a seating to the status it already has should report no change.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlockedSeating_StatusCleared_BlockedFlagIsLeftBehind()
    var
        Seating: Record "NPR NPRE Seating";
        xSeating: Record "NPR NPRE Seating";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
    begin
        // [SCENARIO] Clearing the status of a blocked table leaves it flagged blocked with no status to explain why
        //
        // [!] This pins current behaviour rather than endorsing it. SetSeatingStatus only recomputes Blocked when the
        //     new status code is non-blank, so a seating cleared back to a blank status keeps whatever flag it had.
        //     A table in that state is filtered out as blocked while its status shows nothing.
        // [GIVEN] A seating in the blocked status
        Initialize();
        CreateReadySeating(Seating);
        SeatingMgt.SetSeatingIsBlocked(Seating.Code);
        Seating.Get(Seating.Code);
        xSeating := Seating;

        // [WHEN] Its status is cleared
        _Assert.IsTrue(
            SeatingMgt.SetSeatingStatus(Seating, xSeating, ''),
            'Clearing a non-blank status should report a change.');
        Seating.Modify();

        // [THEN] The status is gone but the flag remains
        Seating.Get(Seating.Code);
        _Assert.AreEqual('', Seating.Status, 'The seating status should have been cleared.');
        _Assert.IsTrue(Seating.Blocked, 'Clearing the status does not recompute the Blocked flag, so it survives.');
    end;

    local procedure CreateReadySeating(var Seating: Record "NPR NPRE Seating")
    var
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        SeatingMgt.SetSeatingIsReady(Seating.Code);
        Seating.Get(Seating.Code);
    end;

    local procedure Initialize()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        if _RestaurantInitialized then
            exit;
        _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        _LibraryRestaurant.CreateMealFlowStatuses();

        // Without these the restaurant setup carries no status codes and every status setter is a silent no-op.
        _LibraryRestaurant.CreateSeatingFlowStatuses();
        _LibraryRestaurant.CreateServiceFlowProfile(_ServFlowProfile);
        _LibraryRestaurant.CreateRestaurant(_Restaurant, _ServFlowProfile.Code);
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _RestaurantInitialized := true;
        Commit();
    end;
}
