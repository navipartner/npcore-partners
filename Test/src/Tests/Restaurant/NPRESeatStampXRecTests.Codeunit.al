codeunit 85520 "NPR NPRE Seat Stamp xRec Tests"
{
    // [FEATURE] Restaurant seating setup last-modified stamp: moves between restaurants stamp both sides, and the subscribers leave xRec to later subscribers
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";

    [Test]
    procedure SeatingDescriptionChangeStampsItsRestaurant()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Changing a seating's description from code moves its restaurant's seating setup stamp forward.
        // [GIVEN] A restaurant with a seating, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        _LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] The description is changed from code
        Seating.Description := 'Window table';
        Seating.Modify(true);

        // [THEN] The restaurant is stamped
        _Assert.IsTrue(WasStamped(Restaurant.Code), 'The seating''s restaurant must be stamped');
    end;

    [Test]
    procedure SeatingModifyWithoutTriggersStillStampsItsRestaurant()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] A seating modified from code without running triggers still moves its restaurant's seating setup stamp forward.
        // [GIVEN] A restaurant with a seating, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        _LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] The capacity is changed without running triggers
        Seating.Capacity += 2;
        Seating.Modify(false);

        // [THEN] The restaurant is stamped
        _Assert.IsTrue(WasStamped(Restaurant.Code), 'A modify without triggers must still stamp the restaurant');
    end;

    [Test]
    procedure SeatingStatusAndWaiterPadChangeLeavesItsRestaurantUnstamped()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Changing only a seating's status and current waiter pad description from code leaves its restaurant's seating setup stamp alone.
        // [GIVEN] A restaurant with a seating, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        _LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] Only the status and the current waiter pad description are changed from code
        Seating.Status := 'OCCUPIED';
        Seating."Current Waiter Pad Description" := 'Table party of four';
        Seating.Modify(true);

        // [THEN] The restaurant is not stamped
        _Assert.IsFalse(WasStamped(Restaurant.Code), 'An operational change must not stamp the restaurant');
    end;

    [Test]
    procedure SeatingDeleteStampsItsRestaurant()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Deleting a seating moves its restaurant's seating setup stamp forward.
        // [GIVEN] A restaurant with a seating, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        _LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] The seating is deleted
        Seating.Delete(true);

        // [THEN] The restaurant is stamped
        _Assert.IsTrue(WasStamped(Restaurant.Code), 'A delete must stamp the restaurant');
    end;

    [Test]
    procedure SeatingRenameStampsItsRestaurant()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Renaming a seating moves its restaurant's seating setup stamp forward.
        // [GIVEN] A restaurant with a seating, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        _LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] The seating is renamed
        Seating.Rename(CopyStr('RN-' + Seating.Code, 1, MaxStrLen(Seating.Code)));

        // [THEN] The restaurant is stamped
        _Assert.IsTrue(WasStamped(Restaurant.Code), 'A rename must stamp the restaurant');
    end;

    [Test]
    procedure SeatingLocationDescriptionChangeStampsItsRestaurant()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Changing a seating location's description from code moves its restaurant's seating setup stamp forward.
        // [GIVEN] A restaurant with a seating location, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] The description is changed from code
        SeatingLocation.Description := 'Terrace';
        SeatingLocation.Modify(true);

        // [THEN] The restaurant is stamped
        _Assert.IsTrue(WasStamped(Restaurant.Code), 'The location''s restaurant must be stamped');
    end;

    [Test]
    procedure SeatingMovedToAnotherRestaurantStampsBothRestaurants()
    var
        NewRestaurant: Record "NPR NPRE Restaurant";
        OldRestaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        NewSeatingLocation: Record "NPR NPRE Seating Location";
        OldSeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Moving a seating to a location of another restaurant from code stamps the restaurant it left as well as the one it joined.
        // [GIVEN] Two restaurants with a seating location each and a seating in the first, both stamped in the past
        _LibraryRestaurant.CreateRestaurant(OldRestaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(OldSeatingLocation, OldRestaurant.Code);
        _LibraryRestaurant.CreateSeating(Seating, OldSeatingLocation.Code);
        _LibraryRestaurant.CreateRestaurant(NewRestaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(NewSeatingLocation, NewRestaurant.Code);
        StampInThePast(OldRestaurant.Code);
        StampInThePast(NewRestaurant.Code);

        // [WHEN] The seating is moved from code
        Seating."Seating Location" := NewSeatingLocation.Code;
        Seating.Modify(true);

        // [THEN] The restaurant it left is stamped
        _Assert.IsTrue(WasStamped(OldRestaurant.Code), 'The restaurant the seating left must be stamped');

        // [THEN] The restaurant it joined is stamped
        _Assert.IsTrue(WasStamped(NewRestaurant.Code), 'The restaurant the seating joined must be stamped');
    end;

    [Test]
    procedure SeatingLocationMovedToAnotherRestaurantStampsBothRestaurants()
    var
        NewRestaurant: Record "NPR NPRE Restaurant";
        OldRestaurant: Record "NPR NPRE Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Moving a seating location to another restaurant from code stamps the restaurant it left as well as the one it joined.
        // [GIVEN] Two restaurants and a seating location in the first, both stamped in the past
        _LibraryRestaurant.CreateRestaurant(OldRestaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, OldRestaurant.Code);
        _LibraryRestaurant.CreateRestaurant(NewRestaurant, '');
        StampInThePast(OldRestaurant.Code);
        StampInThePast(NewRestaurant.Code);

        // [WHEN] The seating location is moved from code
        SeatingLocation."Restaurant Code" := NewRestaurant.Code;
        SeatingLocation.Modify(true);

        // [THEN] The restaurant it left is stamped
        _Assert.IsTrue(WasStamped(OldRestaurant.Code), 'The restaurant the location left must be stamped');

        // [THEN] The restaurant it joined is stamped
        _Assert.IsTrue(WasStamped(NewRestaurant.Code), 'The restaurant the location joined must be stamped');
    end;

    [Test]
    procedure LocationLayoutMovedToAnotherRestaurantStampsBothRestaurants()
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        NewRestaurant: Record "NPR NPRE Restaurant";
        OldRestaurant: Record "NPR NPRE Restaurant";
        NewSeatingLocation: Record "NPR NPRE Seating Location";
        OldSeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Moving a layout component to a location of another restaurant from code stamps the restaurant it left as well as the one it joined.
        // [GIVEN] Two restaurants with a seating location each and a layout component in the first, both stamped in the past
        _LibraryRestaurant.CreateRestaurant(OldRestaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(OldSeatingLocation, OldRestaurant.Code);
        _LibraryRestaurant.CreateRestaurant(NewRestaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(NewSeatingLocation, NewRestaurant.Code);
        CreateLocationLayout(LocationLayout, OldSeatingLocation.Code);
        StampInThePast(OldRestaurant.Code);
        StampInThePast(NewRestaurant.Code);

        // [WHEN] The layout component is moved from code
        LocationLayout."Seating Location" := NewSeatingLocation.Code;
        LocationLayout.Modify(true);

        // [THEN] The restaurant it left is stamped
        _Assert.IsTrue(WasStamped(OldRestaurant.Code), 'The restaurant the component left must be stamped');

        // [THEN] The restaurant it joined is stamped
        _Assert.IsTrue(WasStamped(NewRestaurant.Code), 'The restaurant the component joined must be stamped');
    end;

    [Test]
    procedure CodeDrivenSeatingModifyLeavesXRecUntouchedForLaterSubscribers()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        NewSeatingLocation: Record "NPR NPRE Seating Location";
        OldSeatingLocation: Record "NPR NPRE Seating Location";
        TestXRecProbe: Codeunit "NPR Test xRec Probe";
    begin
        // [SCENARIO] A code-driven modify of a seating reaches later subscribers with the xRec the platform supplied, which carries the location being written rather than the one on disk.
        // [GIVEN] A restaurant with two seating locations and a seating in the first
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(OldSeatingLocation, Restaurant.Code);
        _LibraryRestaurant.CreateSeatingLocation(NewSeatingLocation, Restaurant.Code);
        _LibraryRestaurant.CreateSeating(Seating, OldSeatingLocation.Code);

        // [GIVEN] A probe subscriber observing the modify event
        BindSubscription(TestXRecProbe);

        // [WHEN] The seating is moved from code
        Seating."Seating Location" := NewSeatingLocation.Code;
        Seating.Modify(true);

        // [THEN] The probe saw the modify with xRec still carrying the new location
        _Assert.IsTrue(TestXRecProbe.ModifySeen(Database::"NPR NPRE Seating"), 'The probe must observe the seating modify');
        _Assert.IsTrue(TestXRecProbe.XRecCarriesRecValue(Database::"NPR NPRE Seating"), 'The seating stamp subscriber must not replace xRec');
    end;

    [Test]
    procedure CodeDrivenSeatingLocationModifyLeavesXRecUntouchedForLaterSubscribers()
    var
        NewRestaurant: Record "NPR NPRE Restaurant";
        OldRestaurant: Record "NPR NPRE Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
        TestXRecProbe: Codeunit "NPR Test xRec Probe";
    begin
        // [SCENARIO] A code-driven modify of a seating location reaches later subscribers with the xRec the platform supplied, which carries the restaurant being written rather than the one on disk.
        // [GIVEN] Two restaurants and a seating location in the first
        _LibraryRestaurant.CreateRestaurant(OldRestaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, OldRestaurant.Code);
        _LibraryRestaurant.CreateRestaurant(NewRestaurant, '');

        // [GIVEN] A probe subscriber observing the modify event
        BindSubscription(TestXRecProbe);

        // [WHEN] The seating location is moved from code
        SeatingLocation."Restaurant Code" := NewRestaurant.Code;
        SeatingLocation.Modify(true);

        // [THEN] The probe saw the modify with xRec still carrying the new restaurant
        _Assert.IsTrue(TestXRecProbe.ModifySeen(Database::"NPR NPRE Seating Location"), 'The probe must observe the seating location modify');
        _Assert.IsTrue(TestXRecProbe.XRecCarriesRecValue(Database::"NPR NPRE Seating Location"), 'The seating location stamp subscriber must not replace xRec');
    end;

    [Test]
    procedure CodeDrivenLocationLayoutModifyLeavesXRecUntouchedForLaterSubscribers()
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        Restaurant: Record "NPR NPRE Restaurant";
        NewSeatingLocation: Record "NPR NPRE Seating Location";
        OldSeatingLocation: Record "NPR NPRE Seating Location";
        TestXRecProbe: Codeunit "NPR Test xRec Probe";
    begin
        // [SCENARIO] A code-driven modify of a layout component reaches later subscribers with the xRec the platform supplied, which carries the location being written rather than the one on disk.
        // [GIVEN] A restaurant with two seating locations and a layout component in the first
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(OldSeatingLocation, Restaurant.Code);
        _LibraryRestaurant.CreateSeatingLocation(NewSeatingLocation, Restaurant.Code);
        CreateLocationLayout(LocationLayout, OldSeatingLocation.Code);

        // [GIVEN] A probe subscriber observing the modify event
        BindSubscription(TestXRecProbe);

        // [WHEN] The layout component is moved from code
        LocationLayout."Seating Location" := NewSeatingLocation.Code;
        LocationLayout.Modify(true);

        // [THEN] The probe saw the modify with xRec still carrying the new location
        _Assert.IsTrue(TestXRecProbe.ModifySeen(Database::"NPR NPRE Location Layout"), 'The probe must observe the layout modify');
        _Assert.IsTrue(TestXRecProbe.XRecCarriesRecValue(Database::"NPR NPRE Location Layout"), 'The layout stamp subscriber must not replace xRec');
    end;

    [Test]
    procedure SeatingLocationDeleteStampsItsRestaurant()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Deleting a seating location moves its restaurant's seating setup stamp forward.
        // [GIVEN] A restaurant with a seating location, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] The seating location is deleted
        SeatingLocation.Delete(true);

        // [THEN] The restaurant is stamped
        _Assert.IsTrue(WasStamped(Restaurant.Code), 'A seating location delete must stamp the restaurant');
    end;

    [Test]
    procedure SeatingLocationRenameStampsItsRestaurant()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Renaming a seating location moves its restaurant's seating setup stamp forward.
        // [GIVEN] A restaurant with a seating location, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] The seating location is renamed
        SeatingLocation.Rename(CopyStr('RN-' + SeatingLocation.Code, 1, MaxStrLen(SeatingLocation.Code)));

        // [THEN] The restaurant is stamped
        _Assert.IsTrue(WasStamped(Restaurant.Code), 'A seating location rename must stamp the restaurant');
    end;

    [Test]
    procedure LocationLayoutDescriptionChangeStampsItsRestaurant()
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        Restaurant: Record "NPR NPRE Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Changing a layout component's description from code moves its restaurant's seating setup stamp forward.
        // [GIVEN] A restaurant with a seating location and a layout component, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        CreateLocationLayout(LocationLayout, SeatingLocation.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] The description is changed from code
        LocationLayout.Description := 'Moved decoration';
        LocationLayout.Modify(true);

        // [THEN] The restaurant is stamped
        _Assert.IsTrue(WasStamped(Restaurant.Code), 'A layout component change must stamp the restaurant');
    end;

    [Test]
    procedure LocationLayoutDeleteStampsItsRestaurant()
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        Restaurant: Record "NPR NPRE Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Deleting a layout component moves its restaurant's seating setup stamp forward.
        // [GIVEN] A restaurant with a seating location and a layout component, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        CreateLocationLayout(LocationLayout, SeatingLocation.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] The layout component is deleted
        LocationLayout.Delete(true);

        // [THEN] The restaurant is stamped
        _Assert.IsTrue(WasStamped(Restaurant.Code), 'A layout component delete must stamp the restaurant');
    end;

    [Test]
    procedure LocationLayoutRenameStampsItsRestaurant()
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        Restaurant: Record "NPR NPRE Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        // [SCENARIO] Renaming a layout component moves its restaurant's seating setup stamp forward.
        // [GIVEN] A restaurant with a seating location and a layout component, stamped in the past
        _LibraryRestaurant.CreateRestaurant(Restaurant, '');
        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        CreateLocationLayout(LocationLayout, SeatingLocation.Code);
        StampInThePast(Restaurant.Code);

        // [WHEN] The layout component is renamed
        LocationLayout.Rename(CopyStr('RN-' + LocationLayout.Code, 1, MaxStrLen(LocationLayout.Code)));

        // [THEN] The restaurant is stamped
        _Assert.IsTrue(WasStamped(Restaurant.Code), 'A layout component rename must stamp the restaurant');
    end;

    local procedure CreateLocationLayout(var LocationLayout: Record "NPR NPRE Location Layout"; SeatingLocationCode: Code[10])
    begin
        LocationLayout.Init();
        LocationLayout.Code := CopyStr('LAYOUT-' + Format(CreateGuid()), 1, MaxStrLen(LocationLayout.Code));
        LocationLayout.Type := 'decoration';
        LocationLayout."Seating Location" := SeatingLocationCode;
        LocationLayout.Description := 'Test decoration';
        LocationLayout.Insert(true);
    end;

    local procedure PastStamp(): DateTime
    begin
        exit(CreateDateTime(DMY2Date(1, 1, 2020), 120000T));
    end;

    local procedure StampInThePast(RestaurantCode: Code[20])
    var
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        Restaurant.Get(RestaurantCode);
        Restaurant."Seating Setup Last Modified At" := PastStamp();
        Restaurant.Modify(false);
    end;

    local procedure WasStamped(RestaurantCode: Code[20]): Boolean
    var
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        Restaurant.Get(RestaurantCode);
        exit(Restaurant."Seating Setup Last Modified At" <> PastStamp());
    end;
}
