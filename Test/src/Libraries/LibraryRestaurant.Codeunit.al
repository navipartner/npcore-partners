#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85242 "NPR Library - Restaurant"
{
    procedure CreateRestaurantSetup(var NPRERestaurantSetup: Record "NPR NPRE Restaurant Setup")
    var
        LibraryUtility: Codeunit "Library - Utility";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        RecordExists: Boolean;
    begin
        RecordExists := NPRERestaurantSetup.Get();

        if not RecordExists then begin
            NPRERestaurantSetup.Init();
            NPRERestaurantSetup.Code := '';

            LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
            LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'WP000001', 'WP999999');
            NPRERestaurantSetup."Waiter Pad No. Serie" := NoSeries.Code;
        end;

        NPRERestaurantSetup."Auto-Send Kitchen Order" := NPRERestaurantSetup."Auto-Send Kitchen Order"::Yes;
        NPRERestaurantSetup."KDS Active" := true;
        NPRERestaurantSetup."Serving Step Discovery Method" := NPRERestaurantSetup."Serving Step Discovery Method"::"Item Routing Profiles";

        if RecordExists then
            NPRERestaurantSetup.Modify(true)
        else
            NPRERestaurantSetup.Insert(true);
    end;

    procedure CreateServiceFlowProfile(var ServFlowProfile: Record "NPR NPRE Serv.Flow Profile")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ServFlowProfile.Init();
        ServFlowProfile.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(ServFlowProfile.FieldNo(Code), DATABASE::"NPR NPRE Serv.Flow Profile"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR NPRE Serv.Flow Profile", ServFlowProfile.FieldNo(Code)));
        ServFlowProfile.Description := 'Test Service Flow';
        ServFlowProfile."AutoSave to W/Pad on Sale End" := true;
        ServFlowProfile."Close Waiter Pad On" := ServFlowProfile."Close Waiter Pad On"::"Payment if Served";
        ServFlowProfile.Insert(true);
    end;

    procedure CreateRestaurant(var Restaurant: Record "NPR NPRE Restaurant"; ServiceFlowProfileCode: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        Restaurant.Init();
        Restaurant.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(Restaurant.FieldNo(Code), DATABASE::"NPR NPRE Restaurant"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR NPRE Restaurant", Restaurant.FieldNo(Code)));
        Restaurant.Name := 'Test Restaurant';
        Restaurant."Service Flow Profile" := ServiceFlowProfileCode;
        Restaurant."Auto Send Kitchen Order" := Restaurant."Auto Send Kitchen Order"::Yes;
        Restaurant."KDS Active" := Restaurant."KDS Active"::Yes;
        Restaurant.Insert(true);
    end;

    procedure CreatePOSRestaurantProfile(var POSRestProfile: Record "NPR POS NPRE Rest. Profile"; RestaurantCode: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        POSRestProfile.Init();
        POSRestProfile.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(POSRestProfile.FieldNo(Code), DATABASE::"NPR POS NPRE Rest. Profile"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS NPRE Rest. Profile", POSRestProfile.FieldNo(Code)));
        POSRestProfile.Description := 'Test POS Restaurant Profile';
        POSRestProfile."Restaurant Code" := RestaurantCode;
        POSRestProfile.Insert(true);
    end;

    procedure CreateSeatingLocation(var SeatingLocation: Record "NPR NPRE Seating Location"; RestaurantCode: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        SeatingLocation.Init();
        SeatingLocation.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(SeatingLocation.FieldNo(Code), DATABASE::"NPR NPRE Seating Location"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR NPRE Seating Location", SeatingLocation.FieldNo(Code)));
        SeatingLocation.Description := 'Test Seating Location';
        SeatingLocation."Restaurant Code" := RestaurantCode;
        SeatingLocation.Insert(true);
    end;

    procedure CreateSeating(var Seating: Record "NPR NPRE Seating"; SeatingLocationCode: Code[10])
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        Seating.Init();
        Seating.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(Seating.FieldNo(Code), DATABASE::"NPR NPRE Seating"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR NPRE Seating", Seating.FieldNo(Code)));
        Seating."Seating Location" := SeatingLocationCode;
        Seating.Description := 'Test Seating';
        Seating.Capacity := 4;
        Seating.Insert(true);
    end;

    procedure SetupRestaurantForKitchenOrders(var POSUnit: Record "NPR POS Unit"; var Seating: Record "NPR NPRE Seating")
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        SeatingLocation: Record "NPR NPRE Seating Location";
        KitchenStation: Record "NPR NPRE Kitchen Station";
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
    begin
        CreateRestaurantSetup(RestaurantSetup);
        CreateServiceFlowProfile(ServFlowProfile);
        CreateMealFlowStatuses();
        CreateRestaurant(Restaurant, ServFlowProfile.Code);
        CreatePOSRestaurantProfile(POSRestProfile, Restaurant.Code);
        CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        CreateSeating(Seating, SeatingLocation.Code);
        CreateKitchenStation(KitchenStation, Restaurant.Code);
        CreateKitchenStationSelection(KitchenStationSelection, Restaurant.Code, SeatingLocation.Code, KitchenStation.Code);

        POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
        POSUnit.Modify();
    end;

    procedure CreateMealFlowStatuses()
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        // Create at least 2 meal flow statuses to allow kitchen order processing
        // First step: STARTER
        if not FlowStatus.Get('STARTER', FlowStatus."Status Object"::WaiterPadLineMealFlow) then begin
            FlowStatus.Init();
            FlowStatus.Code := 'STARTER';
            FlowStatus."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
            FlowStatus.Description := 'Starter';
            FlowStatus."Flow Order" := 10;
            FlowStatus.Auxiliary := false;
            FlowStatus.Insert(true);
        end;

        // Second step: MAIN
        Clear(FlowStatus);
        if not FlowStatus.Get('MAIN', FlowStatus."Status Object"::WaiterPadLineMealFlow) then begin
            FlowStatus.Init();
            FlowStatus.Code := 'MAIN';
            FlowStatus."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
            FlowStatus.Description := 'Main Course';
            FlowStatus."Flow Order" := 20;
            FlowStatus.Auxiliary := false;
            FlowStatus.Insert(true);
        end;

        // Third step: DESSERT
        Clear(FlowStatus);
        if not FlowStatus.Get('DESSERT', FlowStatus."Status Object"::WaiterPadLineMealFlow) then begin
            FlowStatus.Init();
            FlowStatus.Code := 'DESSERT';
            FlowStatus."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
            FlowStatus.Description := 'Dessert';
            FlowStatus."Flow Order" := 30;
            FlowStatus.Auxiliary := false;
            FlowStatus.Insert(true);
        end;
    end;

    procedure CreateWaiterPadForSeating(SeatingCode: Code[20]; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SeatingWPLink: Record "NPR NPRE Seat.: WaiterPadLink";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        CreateRestaurantSetup(RestaurantSetup);
        Clear(WaiterPad);
        WaiterPadMgt.AddNewWaiterPadForSeating(SeatingCode, WaiterPad, SeatingWPLink);
    end;

    procedure CreateItemAddon(var ItemAddOn: Record "NPR NpIa Item AddOn")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ItemAddOn.Init();
        ItemAddOn."No." := CopyStr(
            LibraryUtility.GenerateRandomCode(ItemAddOn.FieldNo("No."), DATABASE::"NPR NpIa Item AddOn"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR NpIa Item AddOn", ItemAddOn.FieldNo("No.")));
        ItemAddOn.Description := 'Test Item AddOn';
        ItemAddOn.Enabled := true;
        ItemAddOn.Insert(true);
    end;

    procedure CreateItemAddonLine(var ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; AddOnNo: Code[20]; ItemNo: Code[20]; UseUnitPrice: Option; UnitPrice: Decimal)
    var
        ItemAddOnLine2: Record "NPR NpIa Item AddOn Line";
    begin
        ItemAddOnLine2.SetRange("AddOn No.", AddOnNo);
        if ItemAddOnLine2.FindLast() then;

        ItemAddOnLine.Init();
        ItemAddOnLine."AddOn No." := AddOnNo;
        ItemAddOnLine."Line No." := ItemAddOnLine2."Line No." + 10;
        ItemAddOnLine.Type := ItemAddOnLine.Type::Quantity;
        ItemAddOnLine."Item No." := ItemNo;
        ItemAddOnLine.Description := 'Test Addon Line';
        ItemAddOnLine."Use Unit Price" := UseUnitPrice;
        ItemAddOnLine."Unit Price" := UnitPrice;
        ItemAddOnLine.Quantity := 1;
        ItemAddOnLine.Insert(true);
    end;

    procedure LinkItemToAddon(var Item: Record Item; AddonNo: Code[20])
    begin
        Item."NPR Item AddOn No." := AddonNo;
        Item.Modify();
    end;

    procedure CreateMenu(var Menu: Record "NPR NPRE Menu"; RestaurantCode: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        Menu.Init();
        Menu."Restaurant Code" := RestaurantCode;
        Menu.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(Menu.FieldNo(Code), DATABASE::"NPR NPRE Menu"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR NPRE Menu", Menu.FieldNo(Code)));
        Menu.Active := true;
        Menu.Insert(true);
    end;

    procedure CreateMenuCategory(var MenuCategory: Record "NPR NPRE Menu Category"; RestaurantCode: Code[20]; MenuCode: Code[20]; CategoryCode: Code[20])
    begin
        MenuCategory.Init();
        MenuCategory."Restaurant Code" := RestaurantCode;
        MenuCategory."Menu Code" := MenuCode;
        MenuCategory."Category Code" := CategoryCode;
        MenuCategory.Insert(true);
    end;

    procedure CreateMenuItem(var MenuItem: Record "NPR NPRE Menu Item"; RestaurantCode: Code[20]; MenuCode: Code[20]; CategoryCode: Code[20]; ItemNo: Code[20])
    var
        MenuItem2: Record "NPR NPRE Menu Item";
    begin
        MenuItem2.SetRange("Restaurant Code", RestaurantCode);
        MenuItem2.SetRange("Menu Code", MenuCode);
        MenuItem2.SetRange("Category Code", CategoryCode);
        if MenuItem2.FindLast() then;

        MenuItem.Init();
        MenuItem."Restaurant Code" := RestaurantCode;
        MenuItem."Menu Code" := MenuCode;
        MenuItem."Category Code" := CategoryCode;
        MenuItem."Line No." := MenuItem2."Line No." + 10000;
        MenuItem."Item No." := ItemNo;
        MenuItem.Insert(true);
    end;

    procedure SetupUserPOSUnit(POSUnitNo: Code[10])
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR POS Unit No." := POSUnitNo;
        UserSetup.Modify();
    end;

    procedure FinishKitchenOrder(KitchenOrderNo: BigInteger)
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        KitchenOrderMgt.SetHideValidationDialog(true);

        // First mark all lines as "Ready for Serving" to trigger the webhook
        // when the order status changes to "Ready for Serving"
        MarkKitchenOrderReadyForServing(KitchenOrderNo);

        // Then mark lines as served
        KitchenRequest.SetCurrentKey("Order ID");
        KitchenRequest.SetRange("Order ID", KitchenOrderNo);
        KitchenRequest.SetFilter("Line Status", '<>%1&<>%2',
            KitchenRequest."Line Status"::Served,
            KitchenRequest."Line Status"::Cancelled);

        KitchenOrderMgt.SetRequestLinesAsServed(KitchenRequest);
    end;

    procedure MarkKitchenOrderReadyForServing(KitchenOrderNo: BigInteger)
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        // Use application code to properly transition kitchen order to "Ready for Serving"
        // This triggers the proper status update chain and webhook invocation
        KitchenOrderMgt.SetHideValidationDialog(true);

        // Find all kitchen request stations for this order that are not finished/cancelled
        KitchenRequestStation.SetRange("Order ID", KitchenOrderNo);
        KitchenRequestStation.SetFilter("Production Status", '<>%1&<>%2',
            KitchenRequestStation."Production Status"::Finished,
            KitchenRequestStation."Production Status"::Cancelled);

        if KitchenRequestStation.FindSet() then
            repeat
                // First ensure serving is requested on the kitchen request
                // (required for line status to transition to "Ready for Serving")
                KitchenRequest.Get(KitchenRequestStation."Request No.");
                if KitchenRequest."Line Status" = KitchenRequest."Line Status"::Planned then begin
                    KitchenRequest."Line Status" := KitchenRequest."Line Status"::"Serving Requested";
                    KitchenRequest."Serving Requested Date-Time" := CurrentDateTime();
                    KitchenRequest.Modify();
                end;

                // End production on station - this triggers the proper application flow:
                // SetKitchenRequestStationFinished -> UpdateRequestStatusesFromStation ->
                // UpdateOrderStatus -> webhook invocation when order becomes "Ready for Serving"
                KitchenOrderMgt.EndProduction(KitchenRequestStation);
            until KitchenRequestStation.Next() = 0;
    end;

    procedure CreateItemRoutingProfile(var ItemRoutingProfile: Record "NPR NPRE Item Routing Profile")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ItemRoutingProfile.Init();
        ItemRoutingProfile.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(ItemRoutingProfile.FieldNo(Code), DATABASE::"NPR NPRE Item Routing Profile"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR NPRE Item Routing Profile", ItemRoutingProfile.FieldNo(Code)));
        ItemRoutingProfile.Description := 'Test Item Routing Profile';
        ItemRoutingProfile.Insert(true);
    end;

    procedure CreateKitchenStation(var KitchenStation: Record "NPR NPRE Kitchen Station"; RestaurantCode: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        KitchenStation.Init();
        KitchenStation."Restaurant Code" := RestaurantCode;
        KitchenStation.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(KitchenStation.FieldNo(Code), DATABASE::"NPR NPRE Kitchen Station"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR NPRE Kitchen Station", KitchenStation.FieldNo(Code)));
        KitchenStation.Description := 'Test Kitchen Station';
        KitchenStation.Insert(true);
    end;

    procedure CreateKitchenStationSelection(
        var KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        RestaurantCode: Code[20];
        SeatingLocationCode: Code[20];
        KitchenStationCode: Code[20])
    begin
        KitchenStationSelection.Init();
        KitchenStationSelection."Restaurant Code" := RestaurantCode;
        KitchenStationSelection."Seating Location" := SeatingLocationCode;
        KitchenStationSelection."Serving Step" := '';
        KitchenStationSelection."Print Category Code" := '';
        KitchenStationSelection."Production Restaurant Code" := RestaurantCode;
        KitchenStationSelection."Kitchen Station" := KitchenStationCode;
        KitchenStationSelection."Production Step" := 1;
        KitchenStationSelection.Insert(true);
    end;

    procedure AssignFlowStatusToRoutingProfile(ItemRoutingProfile: Record "NPR NPRE Item Routing Profile"; FlowStatusCode: Code[10])
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        ItemRoutingProfileRefresh: Record "NPR NPRE Item Routing Profile";
    begin
        // Re-get the record to ensure RecordId is properly formed after Insert
        ItemRoutingProfileRefresh.Get(ItemRoutingProfile.Code);

        AssignedFlowStatus.Init();
        AssignedFlowStatus."Table No." := DATABASE::"NPR NPRE Item Routing Profile";
        AssignedFlowStatus."Record ID" := ItemRoutingProfileRefresh.RecordId;
        AssignedFlowStatus."Flow Status Object" := AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow;
        AssignedFlowStatus."Flow Status Code" := FlowStatusCode;
        if not AssignedFlowStatus.Find() then
            AssignedFlowStatus.Insert();
    end;

    procedure LinkItemToRoutingProfile(var Item: Record Item; RoutingProfileCode: Code[20])
    begin
        Item."NPR NPRE Item Routing Profile" := RoutingProfileCode;
        Item.Modify();
    end;

    procedure SetupItemForKitchenOrders(var Item: Record Item)
    var
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        // Ensure restaurant setup uses Item Routing Profiles discovery method
        if RestaurantSetup.Get() then begin
            RestaurantSetup."Serving Step Discovery Method" := RestaurantSetup."Serving Step Discovery Method"::"Item Routing Profiles";
            RestaurantSetup.Modify();
        end;

        // Create flow statuses if not exists
        CreateMealFlowStatuses();

        // Create routing profile
        CreateItemRoutingProfile(ItemRoutingProfile);

        // Assign all meal flow statuses to the routing profile
        AssignFlowStatusToRoutingProfile(ItemRoutingProfile, 'STARTER');
        AssignFlowStatusToRoutingProfile(ItemRoutingProfile, 'MAIN');
        AssignFlowStatusToRoutingProfile(ItemRoutingProfile, 'DESSERT');

        // Verify flow statuses are assigned
        AssignedFlowStatus.SetRange("Table No.", DATABASE::"NPR NPRE Item Routing Profile");
        AssignedFlowStatus.SetRange("Record ID", ItemRoutingProfile.RecordId);
        AssignedFlowStatus.SetRange("Flow Status Object", AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow);
        if AssignedFlowStatus.IsEmpty() then
            Error('Failed to assign flow statuses to item routing profile %1', ItemRoutingProfile.Code);

        // Link item to routing profile
        LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);

        // Verify item is linked to routing profile
        Item.Find();
        if Item."NPR NPRE Item Routing Profile" <> ItemRoutingProfile.Code then
            Error('Failed to link item %1 to routing profile %2', Item."No.", ItemRoutingProfile.Code);
    end;

    procedure SeatingStatusReady(): Code[10]
    begin
        exit('READY');
    end;

    procedure SeatingStatusOccupied(): Code[10]
    begin
        exit('OCCUPIED');
    end;

    procedure SeatingStatusBlocked(): Code[10]
    begin
        exit('BLOCKED');
    end;

    procedure WaiterPadStatusReadyForPmt(): Code[10]
    begin
        exit('PAY');
    end;

    procedure CreateSeatingFlowStatuses()
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        CreateFlowStatus(FlowStatus."Status Object"::Seating, SeatingStatusReady(), 'Ready', 10);
        CreateFlowStatus(FlowStatus."Status Object"::Seating, SeatingStatusOccupied(), 'Occupied', 20);
        CreateFlowStatus(FlowStatus."Status Object"::Seating, SeatingStatusBlocked(), 'Blocked', 30);

        // SetSeatingIsReady/Occupied/Blocked resolve the status code to write from these, so without them they write a
        // blank status - which is what the occupied assertions read. The clearing assertions do not depend on them:
        // TrySetSeatingIsCleared takes its code from the service flow profile, and the Blocked recompute inside
        // SetSeatingStatus yields false either way.
        CreateRestaurantSetup(RestaurantSetup);
        RestaurantSetup."Seat.Status: Ready" := SeatingStatusReady();
        RestaurantSetup."Seat.Status: Occupied" := SeatingStatusOccupied();
        RestaurantSetup."Seat.Status: Blocked" := SeatingStatusBlocked();
        RestaurantSetup.Modify();
    end;

    procedure CreateWaiterPadFlowStatuses()
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        CreateFlowStatus(FlowStatus."Status Object"::WaiterPad, WaiterPadStatusReadyForPmt(), 'Ready for Payment', 10);
    end;

    local procedure CreateFlowStatus(StatusObject: Enum "NPR NPRE Status Object"; StatusCode: Code[10]; Description: Text[50]; FlowOrder: Integer)
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        if FlowStatus.Get(StatusCode, StatusObject) then
            exit;
        FlowStatus.Init();
        FlowStatus.Code := StatusCode;
        FlowStatus."Status Object" := StatusObject;
        FlowStatus.Description := Description;
        FlowStatus."Flow Order" := FlowOrder;
        FlowStatus.Auxiliary := false;
        FlowStatus.Insert(true);
    end;

    procedure ConfigureServiceFlowProfile(var ServFlowProfile: Record "NPR NPRE Serv.Flow Profile"; CloseWaiterPadOn: Enum "NPR NPRE Serv.Flow Close W/Pad"; ClearSeatingOn: Enum "NPR NPRE Serv.Flow Clear Seat."; SetReadyForPmtOn: Enum "NPR NPRE W/Pad Status Pmt. On"; OnlyIfFullyPaid: Boolean)
    begin
        // Assigned rather than validated on purpose. The OnValidate triggers on these fields raise a Message and rewrite
        // each other - setting "Close Waiter Pad On" to a Pre-Receipt value forces "Set W/Pad Ready for Pmt. On" back to
        // Manual, for instance - so validating here would silently hand the test a different matrix cell than it asked for.
        // Callers are responsible for asking only for combinations the UI can actually produce.
        ServFlowProfile."Close Waiter Pad On" := CloseWaiterPadOn;
        ServFlowProfile."Clear Seating On" := ClearSeatingOn;
        ServFlowProfile."Set W/Pad Ready for Pmt. On" := SetReadyForPmtOn;
        ServFlowProfile."Only if Fully Paid" := OnlyIfFullyPaid;
        ServFlowProfile."Seating Status after Clearing" := SeatingStatusReady();
        ServFlowProfile."W/Pad Ready for Pmt. Status" := WaiterPadStatusReadyForPmt();
        ServFlowProfile.Modify();
    end;

    procedure SetRestaurantKDSActive(var Restaurant: Record "NPR NPRE Restaurant"; Active: Boolean)
    begin
        if Active then
            Restaurant."KDS Active" := Restaurant."KDS Active"::Yes
        else
            Restaurant."KDS Active" := Restaurant."KDS Active"::No;
        Restaurant.Modify();
    end;

    procedure CreateItemUnitOfMeasure(Item: Record Item; var ItemUnitOfMeasure: Record "Item Unit of Measure"; QtyPerUnitOfMeasure: Decimal)
    var
        UnitOfMeasure: Record "Unit of Measure";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        UnitOfMeasure.Init();
        UnitOfMeasure.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(UnitOfMeasure.FieldNo(Code), Database::"Unit of Measure"), 1, MaxStrLen(UnitOfMeasure.Code));
        UnitOfMeasure.Insert(true);

        ItemUnitOfMeasure.Init();
        ItemUnitOfMeasure."Item No." := Item."No.";
        ItemUnitOfMeasure.Code := UnitOfMeasure.Code;
        ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", QtyPerUnitOfMeasure);
        ItemUnitOfMeasure.Insert(true);
    end;

    procedure AddWaiterPadLine(WaiterPadNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; AttachedToLineNo: Integer; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        Item: Record Item;
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        Item.Get(ItemNo);

        WaiterPadLine.Init();
        ClearLineNoSoTheTableAssignsIt(WaiterPadLine);
        WaiterPadLine."Waiter Pad No." := WaiterPadNo;
        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::Item;
        WaiterPadLine."No." := ItemNo;
        WaiterPadLine.Description := Item.Description;
        WaiterPadLine."Attached to Line No." := AttachedToLineNo;
        if AttachedToLineNo <> 0 then
            WaiterPadLine.Indentation := 1;
        WaiterPadLine.Insert(true);

        if Item."Sales Unit of Measure" <> '' then
            WaiterPadLine.Validate("Unit of Measure Code", Item."Sales Unit of Measure")
        else
            WaiterPadLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
        WaiterPadLine.Validate(Quantity, Quantity);
        WaiterPadLine.Modify(true);

        WaiterPadMgt.AssignWPadLinePrintCategories(WaiterPadLine, true);
    end;

    procedure AddWaiterPadCommentLine(WaiterPadNo: Code[20]; CommentText: Text; AttachedToLineNo: Integer; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        WaiterPadLine.Init();
        ClearLineNoSoTheTableAssignsIt(WaiterPadLine);
        WaiterPadLine."Waiter Pad No." := WaiterPadNo;
        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::Comment;
        WaiterPadLine.Description := CopyStr(CommentText, 1, MaxStrLen(WaiterPadLine.Description));
        WaiterPadLine."Attached to Line No." := AttachedToLineNo;
        if AttachedToLineNo <> 0 then
            WaiterPadLine.Indentation := 1;
        WaiterPadLine.Insert(true);
    end;

    local procedure ClearLineNoSoTheTableAssignsIt(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        // Init() leaves the primary key alone, so a caller that passes the same record variable twice - one call to
        // receive the item line, a second to receive a comment on it - arrives here still holding the first line's
        // "Line No.". The table's OnInsert honours a non-blank "Line No." on purpose, so that add-on lines can be
        // placed directly below their main item, and would take that stale number as a deliberate position: the
        // second insert then collides with the first on the primary key.
        //
        // Blanking it says what these two helpers actually mean - append to the end of the pad, whatever the caller's
        // variable happened to hold - rather than leaving the outcome to depend on how the test declared its
        // variables. The product does the same thing explicitly in NPREWaiterPadPOSMgt, which assigns "Line No." from
        // NewWaiterPadLineNo on every iteration for exactly this reason.
        WaiterPadLine."Line No." := 0;
    end;

    procedure SetWaiterPadLineBilledQuantity(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; BilledQuantity: Decimal)
    begin
        WaiterPadLine.Validate("Billed Quantity", BilledQuantity);
        WaiterPadLine.Modify(true);
    end;
}
#endif
