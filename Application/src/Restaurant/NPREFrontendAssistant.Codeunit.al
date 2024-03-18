codeunit 6150679 "NPR NPRE Frontend Assistant"
{
    Access = Internal;

    var
        _JsonHelper: Codeunit "NPR Json Helper";
        _KitchenAction: Option "Accept Change","Start Production","End Production","Set OnHold","Resume","Set Served";
        _OrderIdTok: label 'orderId', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnConfigureReusableWorkflows', '', true, true)]
    local procedure OnConfigureReusableWorkflows(var Sender: Codeunit "NPR POS UI Management"; POSSession: Codeunit "NPR POS Session"; Setup: Codeunit "NPR POS Setup")
    var
        TempPOSAction: Record "NPR POS Action" temporary;
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ConfigureReusableWorkflowLbl: Label '%1, %2', Locked = true;
    begin
        if not RestaurantSetup.Get() then
            exit;

        if RestaurantSetup."New Waiter Pad Action" <> '' then begin
            POSSession.RetrieveSessionAction(RestaurantSetup."New Waiter Pad Action", TempPOSAction);
            Sender.ConfigureReusableWorkflow(
                TempPOSAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, RestaurantSetup.TableCaption, RestaurantSetup.FieldCaption("New Waiter Pad Action")), RestaurantSetup.FieldNo("New Waiter Pad Action"));
        end;

        if RestaurantSetup."Select Waiter Pad Action" <> '' then begin
            POSSession.RetrieveSessionAction(RestaurantSetup."Select Waiter Pad Action", TempPOSAction);
            Sender.ConfigureReusableWorkflow(
                TempPOSAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, RestaurantSetup.TableCaption, RestaurantSetup.FieldCaption("Select Waiter Pad Action")), RestaurantSetup.FieldNo("Select Waiter Pad Action"));
        end;

        if RestaurantSetup."Select Table Action" <> '' then begin
            POSSession.RetrieveSessionAction(RestaurantSetup."Select Table Action", TempPOSAction);
            Sender.ConfigureReusableWorkflow(
                TempPOSAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, RestaurantSetup.TableCaption, RestaurantSetup.FieldCaption("Select Table Action")), RestaurantSetup.FieldNo("Select Table Action"));
        end;

        if RestaurantSetup."Select Restaurant Action" <> '' then begin
            POSSession.RetrieveSessionAction(RestaurantSetup."Select Restaurant Action", TempPOSAction);
            Sender.ConfigureReusableWorkflow(
                TempPOSAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, RestaurantSetup.TableCaption, RestaurantSetup.FieldCaption("Select Restaurant Action")), RestaurantSetup.FieldNo("Select Restaurant Action"));
        end;

        if RestaurantSetup."Save Layout Action" <> '' then begin
            POSSession.RetrieveSessionAction(RestaurantSetup."Save Layout Action", TempPOSAction);
            Sender.ConfigureReusableWorkflow(
                TempPOSAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, RestaurantSetup.TableCaption, RestaurantSetup.FieldCaption("Save Layout Action")), RestaurantSetup.FieldNo("Save Layout Action"));
        end;

        if RestaurantSetup."Set Waiter Pad Status Action" <> '' then begin
            POSSession.RetrieveSessionAction(RestaurantSetup."Set Waiter Pad Status Action", TempPOSAction);
            Sender.ConfigureReusableWorkflow(
                TempPOSAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, RestaurantSetup.TableCaption, RestaurantSetup.FieldCaption("Set Waiter Pad Status Action")), RestaurantSetup.FieldNo("Set Waiter Pad Status Action"));
        end;

        if RestaurantSetup."Set Table Status Action" <> '' then begin
            POSSession.RetrieveSessionAction(RestaurantSetup."Set Table Status Action", TempPOSAction);
            Sender.ConfigureReusableWorkflow(
                TempPOSAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, RestaurantSetup.TableCaption, RestaurantSetup.FieldCaption("Set Table Status Action")), RestaurantSetup.FieldNo("Set Table Status Action"));
        end;

        if RestaurantSetup."Set Number of Guests Action" <> '' then begin
            POSSession.RetrieveSessionAction(RestaurantSetup."Set Number of Guests Action", TempPOSAction);
            Sender.ConfigureReusableWorkflow(
                TempPOSAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, RestaurantSetup.TableCaption, RestaurantSetup.FieldCaption("Set Number of Guests Action")), RestaurantSetup.FieldNo("Set Number of Guests Action"));
        end;

        if RestaurantSetup."Go to POS Action" <> '' then begin
            POSSession.RetrieveSessionAction(RestaurantSetup."Go to POS Action", TempPOSAction);
            Sender.ConfigureReusableWorkflow(
                TempPOSAction, POSSession, StrSubstNo(ConfigureReusableWorkflowLbl, RestaurantSetup.TableCaption, RestaurantSetup.FieldCaption("Go to POS Action")), RestaurantSetup.FieldNo("Go to POS Action"));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnSetOptions', '', true, true)]
    local procedure OnSetOptions(Setup: Codeunit "NPR POS Setup"; var Options: JsonObject)
    var
        POSRestaurantProfile: Record "NPR POS NPRE Rest. Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        SeatingLocation: Record "NPR NPRE Seating Location";
        POSActionParameterMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        if not RestaurantSetup.Get() then
            exit;

        if RestaurantSetup."New Waiter Pad Action" <> '' then begin
            Options.Add('npre_NewWaiterPadAction', RestaurantSetup."New Waiter Pad Action");
            Options.Add('npre_NewWaiterPadActionParameters', POSActionParameterMgt.GetParametersAsJson(RestaurantSetup.RecordId, RestaurantSetup.FieldNo("New Waiter Pad Action")));
        end;

        if RestaurantSetup."Select Waiter Pad Action" <> '' then begin
            Options.Add('npre_SelectWaiterPadAction', RestaurantSetup."Select Waiter Pad Action");
            Options.Add('npre_SelectWaiterPadActionParameters', POSActionParameterMgt.GetParametersAsJson(RestaurantSetup.RecordId, RestaurantSetup.FieldNo("Select Waiter Pad Action")));
        end;

        if RestaurantSetup."Select Table Action" <> '' then begin
            Options.Add('npre_SelectTableAction', RestaurantSetup."Select Table Action");
            Options.Add('npre_SelectTableActionParameters', POSActionParameterMgt.GetParametersAsJson(RestaurantSetup.RecordId, RestaurantSetup.FieldNo("Select Table Action")));
        end;

        if RestaurantSetup."Select Restaurant Action" <> '' then begin
            Options.Add('npre_SelectRestaurantAction', RestaurantSetup."Select Restaurant Action");
            Options.Add('npre_SelectRestaurantActionParameters', POSActionParameterMgt.GetParametersAsJson(RestaurantSetup.RecordId, RestaurantSetup.FieldNo("Select Restaurant Action")));
        end;

        if RestaurantSetup."Save Layout Action" <> '' then begin
            Options.Add('npre_SaveLayoutAction', RestaurantSetup."Save Layout Action");
            Options.Add('npre_SaveLayoutActionParameters', POSActionParameterMgt.GetParametersAsJson(RestaurantSetup.RecordId, RestaurantSetup.FieldNo("Save Layout Action")));
        end;

        if RestaurantSetup."Set Waiter Pad Status Action" <> '' then begin
            Options.Add('npre_SetWaiterPadStatusAction', RestaurantSetup."Set Waiter Pad Status Action");
            Options.Add('npre_SetWaiterPadStatusParameters', POSActionParameterMgt.GetParametersAsJson(RestaurantSetup.RecordId, RestaurantSetup.FieldNo("Set Waiter Pad Status Action")));
        end;

        if RestaurantSetup."Set Table Status Action" <> '' then begin
            Options.Add('npre_SetTableStatusAction', RestaurantSetup."Set Table Status Action");
            Options.Add('npre_SetTableStatusParameters', POSActionParameterMgt.GetParametersAsJson(RestaurantSetup.RecordId, RestaurantSetup.FieldNo("Set Table Status Action")));
        end;

        if RestaurantSetup."Set Number of Guests Action" <> '' then begin
            Options.Add('npre_SetNumberOfGuestsAction', RestaurantSetup."Set Number of Guests Action");
            Options.Add('npre_SetNumberOfGuestsParameters', POSActionParameterMgt.GetParametersAsJson(RestaurantSetup.RecordId, RestaurantSetup.FieldNo("Set Number of Guests Action")));
        end;

        if RestaurantSetup."Go to POS Action" <> '' then begin
            Options.Add('npre_GotoPOSAction', RestaurantSetup."Go to POS Action");
            Options.Add('npre_GotoPOSParameters', POSActionParameterMgt.GetParametersAsJson(RestaurantSetup.RecordId, RestaurantSetup.FieldNo("Go to POS Action")));
        end;

        Setup.GetPOSRestProfile(POSRestaurantProfile);
        if POSRestaurantProfile."Restaurant Code" <> '' then
            SeatingLocation.SetRange("Restaurant Code", POSRestaurantProfile."Restaurant Code");
        if POSRestaurantProfile."Default Seating Location" <> '' then
            SeatingLocation.SetRange(Code, POSRestaurantProfile."Default Seating Location");
        if SeatingLocation.FindFirst() then begin
            Options.Add('npre_DefaultLocationId', SeatingLocation.Code);
            Options.Add('npre_DefaultRestaurantId', SeatingLocation."Restaurant Code");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', true, true)]
    local procedure OnRequestRestaurantViewData(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        LocationCode: Code[20];
    begin
        if Method in
            ['RequestWaiterPadData',
             'RequestRestaurantLayout',
             'RequestKitchenOrders',
             'RequestKDSData',
             'KDS_GetSetups',
             'KDS_AcceptChange',
             'KDS_SetProductionStarted',
             'KDS_SetProductionFinished',
             'KDS_SetOnHold',
             'KDS_Resume',
             'KDS_SetServed',
             'KDS_SendOrderReadyNotifications']
        then
            Handled := true;

        case Method of
            'RequestWaiterPadData':
                begin
                    LocationCode := CopyStr(_JsonHelper.GetJText(Context.AsToken(), 'locationId', false), 1, MaxStrLen(LocationCode));
                    RefreshWaiterPadData(POSSession, FrontEnd, GetRestaurantCode(Context, false), LocationCode);
                end;
            'RequestRestaurantLayout':
                RefreshRestaurantLayout(FrontEnd, GetRestaurantCode(Context, false));
            'RequestKitchenOrders':
                RefreshCustomerDisplayKitchenOrders(Context, FrontEnd);
            'RequestKDSData':
                RefreshKDSData(Context, FrontEnd);
            'KDS_GetSetups':
                GetSetups(Context, FrontEnd);

            'KDS_AcceptChange':
                RunKitchenAction(Context, _KitchenAction::"Accept Change");
            'KDS_SetProductionStarted':
                RunKitchenAction(Context, _KitchenAction::"Start Production");
            'KDS_SetProductionFinished':
                RunKitchenAction(Context, _KitchenAction::"End Production");
            'KDS_SetOnHold':
                RunKitchenAction(Context, _KitchenAction::"Set OnHold");
            'KDS_Resume':
                RunKitchenAction(Context, _KitchenAction::"Resume");
            'KDS_SetServed':
                RunKitchenAction(Context, _KitchenAction::"Set Served");
            'KDS_SendOrderReadyNotifications':
                CreateOrderReadyNotifications(Context);
        end;
    end;

    local procedure GetRestaurantCode(Context: JsonObject; Required: Boolean) RestaurantCode: Code[20]
    begin
        RestaurantCode := CopyStr(_JsonHelper.GetJText(Context.AsToken(), 'restaurantId', Required), 1, MaxStrLen(RestaurantCode));
    end;

    local procedure GetRestaurantList(Context: JsonObject; var TempRestaurant: Record "NPR NPRE Restaurant")
    var
        Restaurant: Record "NPR NPRE Restaurant";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        RestaurantCode: Code[20];
    begin
        if not TempRestaurant.IsTemporary() then
            SetupProxy.ThrowNonTempException('CU6150679.GetRestaurantList');
        Clear(TempRestaurant);
        TempRestaurant.DeleteAll();

        RestaurantCode := GetRestaurantCode(Context, false);
        if RestaurantCode <> '' then begin
            Restaurant.Get(RestaurantCode);
            TempRestaurant := Restaurant;
            TempRestaurant.Insert();
        end else
            SetupProxy.GetRestaurantList(TempRestaurant);
    end;

    local procedure GetKitchenStationIDFilter(Context: JsonObject): Text
    begin
        exit(_JsonHelper.GetJText(Context.AsToken(), 'stationId', false));
    end;

    internal procedure RefreshWaiterPadData(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; RestaurantCode: Code[20]; LocationCode: Code[20])
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        Request: Codeunit "NPR Front-End: Generic";
        WaiterPadList: JsonArray;
        WaiterPadContent: JsonObject;
        WaiterPadSeatingList: JsonArray;
        WaiterPadSeatingContent: JsonObject;
    begin
        Request.SetMethod('UpdateWaiterPadData');

        if RestaurantCode <> '' then begin
            SeatingLocation.SetCurrentKey("Restaurant Code");
            SeatingLocation.SetRange("Restaurant Code", RestaurantCode);
        end;
        //if LocationCode <> '' then
        //    SeatingLocation.SetRange(Code, LocationCode);

        SeatingWaiterPadLink.SetCurrentKey(Closed);
        SeatingWaiterPadLink.SetRange(Closed, false);
        if SeatingLocation.FindSet() then
            repeat
                Seating.SetCurrentKey("Seating Location");
                Seating.SetRange("Seating Location", SeatingLocation.Code);
                if Seating.FindSet() then
                    repeat
                        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
                        if SeatingWaiterPadLink.FindSet() then begin
                            repeat
                                Clear(WaiterPadSeatingContent);
                                Clear(WaiterPadContent);
                                WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.");
                                WaiterPad.CalcFields("Status Description FF");

                                WaiterPadSeatingContent.Add('restaurantId', SeatingLocation."Restaurant Code");
                                WaiterPadSeatingContent.Add('locationId', SeatingLocation.Code);
                                WaiterPadSeatingContent.Add('seatingId', SeatingWaiterPadLink."Seating Code");
                                WaiterPadSeatingContent.Add('waiterPadId', SeatingWaiterPadLink."Waiter Pad No.");
                                WaiterPadSeatingContent.Add('primary', SeatingWaiterPadLink.Primary);
                                WaiterPadSeatingList.Add(WaiterPadSeatingContent);

                                WaiterPadContent.Add('id', WaiterPad."No.");
                                WaiterPadContent.Add('restaurantId', SeatingLocation."Restaurant Code");
                                if WaiterPad.Description <> '' then
                                    WaiterPadContent.Add('caption', WaiterPad.Description)
                                else
                                    WaiterPadContent.Add('caption', WaiterPad."No.");
                                WaiterPadContent.Add('numberOfGuests', WaiterPad."Number of Guests");
                                WaiterPadList.Add(WaiterPadContent);
                            until SeatingWaiterPadLink.Next() = 0;
                            Seating.Mark(true);
                        end;
                    until Seating.Next() = 0;
            until SeatingLocation.Next() = 0;

        Request.GetContent().Add('waiterPads', WaiterPadList);
        Request.GetContent().Add('waiterPadSeatingLinks', WaiterPadSeatingList);

        FrontEnd.InvokeFrontEndMethod2(Request);

        Seating.MarkedOnly(true);
        if Seating.IsEmpty() then
            exit;
        RefreshStatus(FrontEnd, RestaurantCode, '', Seating.GetSelectionFilter());
    end;

    local procedure RefreshRestaurantLayout(FrontEnd: Codeunit "NPR POS Front End Management"; RestaurantCode: Code[20])
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        LocationLayout: Record "NPR NPRE Location Layout";
        Restaurant: Record "NPR NPRE Restaurant";
        TempRestaurant: Record "NPR NPRE Restaurant" temporary;
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        UserSetup: Record "User Setup";
        Request: Codeunit "NPR Front-End: Generic";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        ComponentList: JsonArray;
        LocationList: JsonArray;
        RestaurantList: JsonArray;
        StatusObjectList: JsonArray;
        ComponentContent: JsonObject;
        FrontEndProperties: JsonObject;
        LocationContent: JsonObject;
        RestaurantContent: JsonObject;
        SeatingFrontEndSetup: JsonObject;
        StatusContent: JsonObject;
        Instr: InStream;
        PropertiesString: Text;
        AddToList: Boolean;
        IsTable: Boolean;
    begin
        if not UserSetup.Get(UserId()) then
            Clear(UserSetup);
        if RestaurantCode <> '' then begin
            SeatingLocation.FilterGroup(2);
            SeatingLocation.SetRange("Restaurant Code", RestaurantCode);
            SeatingLocation.FilterGroup(0);

            if not UserSetup."NPR Allow Restaurant Switch" then begin
                Restaurant.Get(RestaurantCode);
                TempRestaurant := Restaurant;
                TempRestaurant.Insert();
            end;
        end;
        if TempRestaurant.IsEmpty() then begin
            SetupProxy.GetRestaurantList(TempRestaurant);
            if UserSetup."NPR Restaurant Switch Filter" <> '' then
                TempRestaurant.SetFilter(Code, UserSetup."NPR Restaurant Switch Filter");
        end;
        SeatingLocation.SetCurrentKey("Restaurant Code");
        Request.SetMethod('UpdateRestaurantLayout');

        if TempRestaurant.FindSet() then
            repeat
                Clear(RestaurantContent);
                RestaurantContent.Add('id', TempRestaurant.Code);
                RestaurantContent.Add('caption', TempRestaurant.Name);
                RestaurantList.Add(RestaurantContent);

                SeatingLocation.SetRange("Restaurant Code", TempRestaurant.Code);
                if SeatingLocation.FindSet() then
                    repeat
                        Clear(LocationContent);
                        LocationContent.Add('id', SeatingLocation.Code);
                        LocationContent.Add('caption', SeatingLocation.Description);
                        LocationContent.Add('restaurantId', SeatingLocation."Restaurant Code");

                        Seating.SetCurrentKey("Seating Location");
                        Seating.SetRange("Seating Location", SeatingLocation.Code);
                        if Seating.FindSet() then
                            repeat
                                if not LocationLayout.Get(Seating.Code) then begin
                                    LocationLayout.Code := Seating.Code;
                                    LocationLayout.Type := 'table';
                                    LocationLayout.Insert();
                                end;
                                if (LocationLayout."Seating No." <> Seating."Seating No.") or
                                   (LocationLayout.Description <> Seating.Description) or
                                   (LocationLayout."Seating Location" <> SeatingLocation.Code)
                                then begin
                                    LocationLayout."Seating No." := Seating."Seating No.";
                                    LocationLayout.Description := Seating.Description;
                                    LocationLayout."Seating Location" := SeatingLocation.Code;
                                    LocationLayout.Modify();
                                end;
                            until Seating.Next() = 0;

                        Clear(ComponentList);
                        LocationLayout.SetCurrentKey("Seating Location");
                        LocationLayout.SetRange("Seating Location", SeatingLocation.Code);
                        if LocationLayout.FindSet() then
                            repeat
                                IsTable := LocationLayout.Type = 'table';
                                if IsTable then
                                    AddToList := Seating.Get(LocationLayout.Code)
                                else
                                    AddToList := true;

                                if AddToList then begin
                                    Clear(ComponentContent);
                                    ComponentContent.Add('id', LocationLayout.Code);
                                    ComponentContent.Add('user_friendly_id', LocationLayout."Seating No.");
                                    ComponentContent.Add('type', LocationLayout.Type);
                                    ComponentContent.Add('caption', LocationLayout.Description);
                                    if LocationLayout."Frontend Properties".HasValue() then begin
                                        LocationLayout.CalcFields("Frontend Properties");
                                        LocationLayout."Frontend Properties".CreateInStream(Instr);
                                        if IsTable and FrontEndProperties.ReadFrom(Instr) and FrontEndProperties.Contains('chairs') then begin
                                            SeatingFrontEndSetup := _JsonHelper.GetJsonToken(FrontEndProperties.AsToken(), 'chairs').AsObject();
                                            if SeatingFrontEndSetup.Contains('count') then
                                                SeatingFrontEndSetup.Remove('count');
                                            SeatingFrontEndSetup.Add('count', Seating.Capacity);
                                            if SeatingFrontEndSetup.Contains('min') then
                                                SeatingFrontEndSetup.Remove('min');
                                            SeatingFrontEndSetup.Add('min', Seating."Min Party Size");
                                            if SeatingFrontEndSetup.Contains('max') then
                                                SeatingFrontEndSetup.Remove('max');
                                            SeatingFrontEndSetup.Add('max', Seating."Max Party Size");
                                            FrontEndProperties.Replace('chairs', SeatingFrontEndSetup);
                                            FrontEndProperties.WriteTo(PropertiesString);
                                        end else
                                            Instr.Read(PropertiesString);
                                        ComponentContent.Add('blob', PropertiesString);
                                    end else
                                        ComponentContent.Add('blob', '');

                                    if IsTable then begin
                                        ComponentContent.Add('blocked', Seating.Blocked);
                                        ComponentContent.Add('statusId', Seating.Status);
                                        ComponentContent.Add('capacity', Seating.Capacity);
                                        ComponentContent.Add('color', Seating.RGBColorCodeHex(true));
                                    end;

                                    ComponentList.Add(ComponentContent);
                                end;
                            until LocationLayout.Next() = 0;

                        LocationContent.Add('components', ComponentList);
                        LocationList.Add(LocationContent);
                    until SeatingLocation.Next() = 0;
            until TempRestaurant.Next() = 0;

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::Seating);
        FlowStatus.SetRange("Available in Front-End", true);
        SelectStatusObjects(FlowStatus, StatusObjectList);
        StatusContent.Add('seating', StatusObjectList);

        FlowStatus.SetFilter("Status Object", '%1|%2', FlowStatus."Status Object"::WaiterPad, FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatus.SetRange("Available in Front-End", true);
        SelectStatusObjects(FlowStatus, StatusObjectList);
        StatusContent.Add('waiterPad', StatusObjectList);

        Request.GetContent().Add('restaurants', RestaurantList);
        Request.GetContent().Add('locations', LocationList);
        Request.GetContent().Add('statuses', StatusContent);

        FrontEnd.InvokeFrontEndMethod2(Request);

        RefreshStatus(FrontEnd, RestaurantCode, '', '');
    end;

    internal procedure RefreshWaiterPadContent(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        Request: Codeunit "NPR Front-End: Generic";
        WaiterPadList: JsonArray;
        WaiterPadContent: JsonObject;
        WaiterPadLineList: JsonArray;
        WaiterPadLineContent: JsonObject;
        WaiterPadSeatingList: JsonArray;
        WaiterPadSeatingContent: JsonObject;
    begin
        //Not currently used
        Request.SetMethod('UpdateWaiterPadContent');

        if WaiterPad.FindSet() then
            repeat
                // head
                WaiterPad.CalcFields("Status Description FF");

                Clear(WaiterPadContent);
                WaiterPadContent.Add('id', WaiterPad."No.");
                if WaiterPad.Description <> '' then
                    WaiterPadContent.Add('caption', WaiterPad.Description)
                else
                    WaiterPadContent.Add('caption', WaiterPad."No.");
                WaiterPadContent.Add('numberOfGuests', WaiterPad."Number of Guests");

                // links to tables
                Clear(WaiterPadSeatingList);
                SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
                SeatingWaiterPadLink.SetRange(Closed, false);
                if SeatingWaiterPadLink.FindSet() then
                    repeat
                        Seating.Get(SeatingWaiterPadLink."Seating Code");
                        Clear(WaiterPadSeatingContent);
                        WaiterPadSeatingContent.Add('id', SeatingWaiterPadLink."Seating Code");
                        WaiterPadSeatingContent.Add('description', Seating.Description);
                        WaiterPadSeatingContent.Add('statusId', Seating.Status);
                        WaiterPadSeatingContent.Add('primary', SeatingWaiterPadLink.Primary);
                        WaiterPadSeatingList.Add(WaiterPadSeatingContent);
                        Seating.Mark(true);
                    until SeatingWaiterPadLink.Next() = 0;
                WaiterPadContent.Add('seatings', WaiterPadSeatingList);

                // Lines
                Clear(WaiterPadLineList);
                WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
                if WaiterPadLine.FindSet() then
                    repeat
                        Clear(WaiterPadLineContent);
                        WaiterPadLineContent.Add('id', FORMAT(WaiterPadLine."Line No.", 0, 9));
                        WaiterPadLineContent.Add('type', FORMAT(WaiterPadLine."Line Type"));
                        WaiterPadLineContent.Add('itemNo', WaiterPadLine."No.");
                        WaiterPadLineContent.Add('quantity', WaiterPadLine.Quantity);
                        WaiterPadLineContent.Add('unitPrice', FORMAT(WaiterPadLine."Unit Price"));
                        WaiterPadLineContent.Add('amountExclVat', FORMAT(WaiterPadLine."Amount Excl. VAT"));
                        WaiterPadLineContent.Add('amountInclVat', FORMAT(WaiterPadLine."Amount Incl. VAT"));
                        WaiterPadLineContent.Add('priceIncludesVat', WaiterPadLine."Price Includes VAT");
                        if WaiterPadLine."Price Includes VAT" then
                            WaiterPadLineContent.Add('amount', FORMAT(WaiterPadLine."Amount Incl. VAT"))
                        else
                            WaiterPadLineContent.Add('amount', FORMAT(WaiterPadLine."Amount Excl. VAT"));
                        WaiterPadLineContent.Add('lineStatus', WaiterPadLine."Line Status");
                        WaiterPadLineContent.Add('description', WaiterPadLine.Description);
                        WaiterPadLineContent.Add('description2', WaiterPadLine."Description 2");
                        WaiterPadLineContent.Add('variantCode', WaiterPadLine."Variant Code");
                        WaiterPadLineList.Add(WaiterPadLineContent);
                    until WaiterPadLine.Next() = 0;
                WaiterPadContent.Add('lines', WaiterPadLineList);

                WaiterPadList.Add(WaiterPadContent);
            until WaiterPad.Next() = 0;

        Request.GetContent().Add('waiterPads', WaiterPadList);
        FrontEnd.InvokeFrontEndMethod2(Request);

        Seating.MarkedOnly(true);
        if Seating.IsEmpty() then
            exit;
        RefreshStatus(FrontEnd, '', '', Seating.GetSelectionFilter());
    end;

    procedure RefreshStatus(FrontEnd: Codeunit "NPR POS Front End Management"; RestaurantFilter: Text; SeatingLocationFilter: Text; SeatingFilter: Text)
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        Request: Codeunit "NPR Front-End: Generic";
        SeatingStatus: JsonObject;
        WaiterPadStatus: JsonObject;
    begin
        Request.SetMethod('UpdateRestaurantStatuses');

        if RestaurantFilter <> '' then
            SeatingLocation.SetFilter("Restaurant Code", RestaurantFilter);
        if SeatingLocationFilter <> '' then
            SeatingLocation.SetFilter(Code, SeatingLocationFilter);
        if SeatingFilter <> '' then
            Seating.SetFilter(Code, SeatingFilter);

        if SeatingLocation.FindSet() then
            repeat
                Seating.SetRange("Seating Location", SeatingLocation.Code);
                if Seating.FindSet() then
                    repeat
                        if not SeatingStatus.Contains(Seating.Code) then
                            SeatingStatus.Add(Seating.Code, StatusAndColor(Seating.Status, Seating.RGBColorCodeHex(false)));

                        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
                        SeatingWaiterPadLink.SetRange(Closed, false);
                        if SeatingWaiterPadLink.FindSet() then
                            repeat
                                if WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.") and not WaiterPad.Closed then
                                    if not WaiterPadStatus.Contains(WaiterPad."No.") then
                                        WaiterPadStatus.Add(WaiterPad."No.", StatusAndColor(WaiterPad.WaiterPadFrontEndStatus(), WaiterPad.RGBColorCodeHex(false)));
                            until SeatingWaiterPadLink.Next() = 0;
                    until Seating.Next() = 0;
            until SeatingLocation.Next() = 0;

        Request.GetContent().Add('seating', SeatingStatus);
        Request.GetContent().Add('waiterPad', WaiterPadStatus);

        FrontEnd.InvokeFrontEndMethod2(Request);
    end;

    local procedure StatusAndColor(StatusCode: Code[10]; RGBColorCodeHex: Text): JsonObject
    var
        SeatingProperties: JsonObject;
    begin
        SeatingProperties.Add('status', StatusCode);
        SeatingProperties.Add('color', RGBColorCodeHex);
        exit(SeatingProperties);
    end;

    internal procedure SetRestaurant(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; RestaurantCode: Code[20])
    var
        Request: Codeunit "NPR Front-End: Generic";
        Setup: Codeunit "NPR POS Setup";
    begin
        if RestaurantCode = '' then begin
            POSSession.GetSetup(Setup);
            RestaurantCode := Setup.RestaurantCode();
            if RestaurantCode = '' then
                exit;
        end;

        Request.SetMethod('SetRestaurant');
        Request.GetContent().Add('restaurantId', RestaurantCode);
        FrontEnd.InvokeFrontEndMethod2(Request);

        RefreshRestaurantLayout(FrontEnd, RestaurantCode);
    end;

    local procedure SelectStatusObjects(var NPREFlowStatus: Record "NPR NPRE Flow Status"; var StatusObjectList: JsonArray)
    var
        ColorTable: Record "NPR NPRE Color Table";
        StatusObjectContent: JsonObject;
    begin
        Clear(StatusObjectList);
        if NPREFlowStatus.FindSet() then
            repeat
                Clear(StatusObjectContent);
                StatusObjectContent.Add('id', NPREFlowStatus.Code);
                StatusObjectContent.Add('ordinal', NPREFlowStatus."Flow Order");
                StatusObjectContent.Add('caption', NPREFlowStatus.Description);
                if ColorTable.Get(NPREFlowStatus.Color) then
                    StatusObjectContent.Add('color', ColorTable.RGBHexCode(false))
                else
                    StatusObjectContent.Add('color', '');
                StatusObjectContent.Add('icon', NPREFlowStatus."Icon Class");
                StatusObjectList.Add(StatusObjectContent);
            until NPREFlowStatus.Next() = 0;
    end;

    local procedure RefreshCustomerDisplayKitchenOrders(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        TempRestaurant: Record "NPR NPRE Restaurant" temporary;
        KitchenOrderList: JsonArray;
        KitchenOrderContent: JsonObject;
        Response: JsonObject;
    begin
        GetRestaurantList(Context, TempRestaurant);

        KitchenOrder.SetCurrentKey("Restaurant Code", "Order Status", Priority, "Created Date-Time");
        KitchenOrder.SetRange("Order Status", KitchenOrder."Order Status"::"Ready for Serving", KitchenOrder."Order Status"::Planned);

        TempRestaurant.FindSet();
        repeat
            KitchenOrder.SetRange("Restaurant Code", TempRestaurant.Code);
            if KitchenOrder.FindSet() then
                repeat
                    Clear(KitchenOrderContent);
                    KitchenOrderContent.Add('restaurantId', KitchenOrder."Restaurant Code");
                    KitchenOrderContent.Add('orderId', KitchenOrder."Order ID");
                    KitchenOrderContent.Add('orderStatus', KitchenOrder."Order Status".AsInteger());
                    KitchenOrderContent.Add('orderStatusName', StatusEnumValueName(KitchenOrder."Order Status"));
                    KitchenOrderContent.Add('priority', KitchenOrder.Priority);
                    KitchenOrderContent.Add('orderCreatedDT', KitchenOrder."Created Date-Time");
                    KitchenOrderList.Add(KitchenOrderContent);
                until KitchenOrder.Next() = 0;
        until TempRestaurant.Next() = 0;

        Response.Add('orders', KitchenOrderList);
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure GetSetups(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        Response: JsonObject;
    begin
        if not RestaurantSetup.Get() then
            RestaurantSetup.Init();
        Response.Add('warningAfterMinutes', RestaurantSetup."Delayed Ord. Threshold 1 (min)");
        Response.Add('errorAfterMinutes', RestaurantSetup."Delayed Ord. Threshold 2 (min)");
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure RefreshKDSData(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Response: JsonObject;
    begin
        Response.Add('orders',
            GenerateKDSData(
                GetRestaurantCode(Context, true),
                GetKitchenStationIDFilter(Context),
                _JsonHelper.GetJBoolean(Context.AsToken(), 'includeFinished', false),
                _JsonHelper.GetJDT(Context.AsToken(), 'startingFrom', false)));
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    internal procedure GenerateKDSData(RestaurantCode: Code[20]; KitchenStationFilter: Text; IncludeFinished: Boolean; StartingFromDT: DateTime) Orders: JsonArray
    var
        NotificationEntry: Record "NPR NPRE Notification Entry";
        NotificationHandler: Codeunit "NPR NPRE Notification Handler";
        KitchenReqStationsQry: Query "NPR NPRE Kitchen Req. Stations";
        CustomerDetailsDic: Dictionary of [Text, List of [Text]];
        KitchenRequests: JsonArray;
        KitchenStations: JsonArray;
        KitchenRequest: JsonObject;
        KitchenStation: JsonObject;
        OrderHdr: JsonObject;
        NullJsonValue: JsonValue;
        LastOrderID: BigInteger;
        LastRequestNo: BigInteger;
    begin
        if IncludeFinished then begin
            if StartingFromDT = 0DT then
                StartingFromDT := CreateDateTime(Today() - 7, 0T);
            KitchenReqStationsQry.SetFilter(Created_DateTime, '%1..', StartingFromDT);
        end else
            KitchenReqStationsQry.SetRange(Order_Status, "NPR NPRE Kitchen Order Status"::"Ready for Serving", "NPR NPRE Kitchen Order Status"::Planned);
        if KitchenStationFilter <> '' then begin
            KitchenReqStationsQry.SetRange(Production_Restaurant_Code, RestaurantCode);
            KitchenReqStationsQry.SetFilter(Kitchen_Station, KitchenStationFilter);
            if not IncludeFinished then
                KitchenReqStationsQry.SetRange(Station_Production_Status, "NPR NPRE K.Req.L. Prod.Status"::"Not Started", "NPR NPRE K.Req.L. Prod.Status"::"On Hold");
        end else
            KitchenReqStationsQry.SetRange(Restaurant_Code, RestaurantCode);
        KitchenReqStationsQry.Open();

        LastOrderID := 0;
        NullJsonValue.SetValueToNull();
        while KitchenReqStationsQry.Read() do begin
            //Kitchen order header
            if LastOrderID <> KitchenReqStationsQry.Order_ID then begin
                if LastOrderID <> 0 then begin
                    if LastRequestNo <> 0 then
                        FinishKitchenRequest(KitchenRequest, KitchenStations, KitchenRequests);
                    FinishOrder(OrderHdr, KitchenRequests, CustomerDetailsDic, Orders);
                end;
                LastRequestNo := 0;
                LastOrderID := KitchenReqStationsQry.Order_ID;

                Clear(OrderHdr);
                Clear(KitchenRequests);
                Clear(CustomerDetailsDic);
                OrderHdr.Add('orderId', KitchenReqStationsQry.Order_ID);
                OrderHdr.Add('restaurantId', KitchenReqStationsQry.Restaurant_Code);
                OrderHdr.Add('orderStatus', KitchenReqStationsQry.Order_Status.AsInteger());
                OrderHdr.Add('orderStatusName', StatusEnumValueName(KitchenReqStationsQry.Order_Status));
                OrderHdr.Add('priority', KitchenReqStationsQry.Order_Priority);
                OrderHdr.Add('orderCreatedDT', KitchenReqStationsQry.Created_DateTime);
                if KitchenReqStationsQry.Expected_Dine_DateTime <> 0DT then
                    OrderHdr.Add('orderExpectedDineDT', KitchenReqStationsQry.Expected_Dine_DateTime)
                else
                    OrderHdr.Add('orderExpectedDineDT', NullJsonValue);
                if NotificationHandler.FindLastOrderReadyNotification(KitchenReqStationsQry.Order_ID, "NPR NPRE Notif. Recipient"::CUSTOMER, NotificationEntry) then
                    OrderHdr.Add('orderReadyNotifStatusName', StatusEnumValueName(NotificationEntry."Notification Send Status"))
                else
                    OrderHdr.Add('orderReadyNotifStatusName', NullJsonValue);
            end;

            //Kitchen order line
            if LastRequestNo <> KitchenReqStationsQry.Request_No then begin
                if LastRequestNo <> 0 then
                    FinishKitchenRequest(KitchenRequest, KitchenStations, KitchenRequests);
                LastRequestNo := KitchenReqStationsQry.Request_No;

                Clear(KitchenRequest);
                Clear(KitchenStations);
                KitchenRequest.Add('requestId', KitchenReqStationsQry.Request_No);
                KitchenRequest.Add('lineStatus', KitchenReqStationsQry.Line_Status.AsInteger());
                KitchenRequest.Add('lineStatusName', StatusEnumValueName(KitchenReqStationsQry.Line_Status));
                KitchenRequest.Add('productionStatus', KitchenReqStationsQry.Production_Status.AsInteger());
                KitchenRequest.Add('productionStatusName', StatusEnumValueName(KitchenReqStationsQry.Production_Status));
                KitchenRequest.Add('servingStep', KitchenReqStationsQry.Serving_Step);
                KitchenRequest.Add('lineType', KitchenReqStationsQry.Line_Type.AsInteger());
                KitchenRequest.Add('lineTypeName', LineTypeEnumValueName(KitchenReqStationsQry.Line_Type));
                KitchenRequest.Add('itemNo', KitchenReqStationsQry.Item_No);
                KitchenRequest.Add('variantCode', KitchenReqStationsQry.Variant_Code);
                KitchenRequest.Add('lineDescription', KitchenReqStationsQry.Description);
                KitchenRequest.Add('quantity', KitchenReqStationsQry.Quantity);
                KitchenRequest.Add('UoM', KitchenReqStationsQry.Unit_of_Measure_Code);
                KitchenRequest.Add('lineModifiers', AddItemAddonsAndComments(KitchenReqStationsQry.Request_No));
                RetrieveCustomerDetails(KitchenReqStationsQry.Request_No, CustomerDetailsDic);
            end;

            //Kitchen order line station
            Clear(KitchenStation);
            KitchenStation.Add('entryId', KitchenReqStationsQry.KitchenReqStation_SystemId);
            KitchenStation.Add('productionRestaurantId', KitchenReqStationsQry.Production_Restaurant_Code);
            KitchenStation.Add('productionStep', KitchenReqStationsQry.Kitchen_Station);
            KitchenStation.Add('stationId', KitchenReqStationsQry.Kitchen_Station);
            KitchenStation.Add('stationProductionStatus', KitchenReqStationsQry.Station_Production_Status.AsInteger());
            KitchenStation.Add('stationProductionStatusName', StatusEnumValueName(KitchenReqStationsQry.Station_Production_Status));
            KitchenStations.Add(KitchenStation);
        end;
        KitchenReqStationsQry.Close();

        if LastOrderID <> 0 then begin
            if LastRequestNo <> 0 then
                FinishKitchenRequest(KitchenRequest, KitchenStations, KitchenRequests);
            FinishOrder(OrderHdr, KitchenRequests, CustomerDetailsDic, Orders);
        end;
    end;

    local procedure AddItemAddonsAndComments(KitchenRequestNo: BigInteger) LineModifiers: JsonArray
    var
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
        Line: JsonObject;
    begin
        Clear(LineModifiers);
        KitchenRequestModifier.SetRange("Request No.", KitchenRequestNo);
        if KitchenRequestModifier.FindSet() then
            repeat
                Clear(Line);
                Line.Add('type', LineTypeEnumValueName(KitchenRequestModifier."Line Type"));
                Line.Add('itemNo', KitchenRequestModifier."No.");
                Line.Add('variantCode', KitchenRequestModifier."Variant Code");
                Line.Add('lineDescription', KitchenRequestModifier.Description);
                Line.Add('lineDescription2', KitchenRequestModifier."Description 2");
                Line.Add('quantity', KitchenRequestModifier.Quantity);
                Line.Add('UoM', KitchenRequestModifier."Unit of Measure Code");
                Line.Add('indentation', KitchenRequestModifier.Indentation);
                LineModifiers.Add(Line);
            until KitchenRequestModifier.Next() = 0;
    end;

    local procedure RetrieveCustomerDetails(KitchenRequestNo: BigInteger; var CustomerDetailsDic: Dictionary of [Text, List of [Text]])
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KitchReqSrcbyDoc: Query "NPR NPRE Kitch.Req.Src. by Doc";
        CustomerNameTok: Label 'customerName', Locked = true;
        CustomerPhoneNoTok: Label 'customerPhoneNo', Locked = true;
    begin
        KitchReqSrcbyDoc.SetRange(Request_No_, KitchenRequestNo);
        KitchReqSrcbyDoc.SetFilter(QuantityBase, '<>%1', 0);
        if not KitchReqSrcbyDoc.Open() then
            exit;
        while KitchReqSrcbyDoc.Read() do
            case KitchReqSrcbyDoc.Source_Document_Type of
                KitchReqSrcbyDoc.Source_Document_Type::"Waiter Pad":
                    if WaiterPad.Get(KitchReqSrcbyDoc.Source_Document_No_) then begin
                        AddCustomerDetailToDict(CustomerNameTok, WaiterPad.Description, CustomerDetailsDic);
                        AddCustomerDetailToDict(CustomerPhoneNoTok, WaiterPad."Customer Phone No.", CustomerDetailsDic);
                    end;
            end;
        KitchReqSrcbyDoc.Close();
    end;


    local procedure AddCustomerDetailToDict("Key": Text; "Value": Text; var CustomerDetailsDic: Dictionary of [Text, List of [Text]])
    var
        CustomerInfoValues: List of [Text];
    begin
        if "Value" = '' then
            exit;
        if not CustomerDetailsDic.ContainsKey("Key") then begin
            CustomerInfoValues.Add("Value");
            CustomerDetailsDic.Add("Key", CustomerInfoValues);
        end else
            if not CustomerDetailsDic.Get("Key").Contains("Value") then
                CustomerDetailsDic.Get("Key").Add("Value");
    end;

    local procedure FinishKitchenRequest(KitchenRequest: JsonObject; KitchenStations: JsonArray; var KitchenRequests: JsonArray)
    begin
        KitchenRequest.Add('kitchenStations', KitchenStations);
        KitchenRequests.Add(KitchenRequest);
    end;

    local procedure FinishOrder(OrderHdr: JsonObject; KitchenRequests: JsonArray; CustomerDetailsDic: Dictionary of [Text, List of [Text]]; Orders: JsonArray)
    var
        CustomerInfoKey: Text;
        CustomerInfoValues: List of [Text];
    begin
        foreach CustomerInfoKey in CustomerDetailsDic.Keys() do
            if CustomerDetailsDic.Get(CustomerInfoKey, CustomerInfoValues) then
                OrderHdr.Add(CustomerInfoKey, ListToText(CustomerInfoValues));
        OrderHdr.Add('kitchenRequests', KitchenRequests);
        Orders.Add(OrderHdr);
    end;

    local procedure ListToText(CustomerInfoValues: List of [Text]): Text
    var
        CustomerInfoValue: Text;
        CustomerInfoValueString: Text;
    begin
        foreach CustomerInfoValue in CustomerInfoValues do
            if CustomerInfoValue <> '' then begin
                if CustomerInfoValueString <> '' then
                    CustomerInfoValueString := CustomerInfoValueString + ', ';
                CustomerInfoValueString := CustomerInfoValueString + CustomerInfoValue;
            end;
        exit(CustomerInfoValueString);
    end;

    local procedure StatusEnumValueName(OrderStatus: Enum "NPR NPRE Kitchen Order Status") Result: Text
    begin
        OrderStatus.Names().Get(OrderStatus.Ordinals().IndexOf(OrderStatus.AsInteger()), Result);
    end;

    local procedure StatusEnumValueName(LineStatus: Enum "NPR NPRE K.Request Line Status") Result: Text
    begin
        LineStatus.Names().Get(LineStatus.Ordinals().IndexOf(LineStatus.AsInteger()), Result);
    end;

    local procedure StatusEnumValueName(ProductionStatus: Enum "NPR NPRE K.Req.L. Prod.Status") Result: Text
    begin
        ProductionStatus.Names().Get(ProductionStatus.Ordinals().IndexOf(ProductionStatus.AsInteger()), Result);
    end;

    local procedure StatusEnumValueName(NotificationSendStatus: Enum "NPR NPRE Notification Status") Result: Text
    begin
        NotificationSendStatus.Names().Get(NotificationSendStatus.Ordinals().IndexOf(NotificationSendStatus.AsInteger()), Result);
    end;

    local procedure LineTypeEnumValueName(LineType: Enum "NPR POS Sale Line Type") Result: Text
    begin
        LineType.Names().Get(LineType.Ordinals().IndexOf(LineType.AsInteger()), Result);
    end;

    local procedure RunKitchenAction(Context: JsonObject; ActionToRun: Option)
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
        KitchenStationFilter: Text;
        KitchenRequestId: BigInteger;
        OrderID: BigInteger;
        MissingContextParamErr: label 'Either ''%1'' or ''%2'' must be specified.', Comment = '%1 and %2 - json context tag names.';
        KitchenRequestIdTok: label 'kitchenRequestId', Locked = true;
    begin
        KitchenRequestId := _JsonHelper.GetJBigInteger(Context.AsToken(), KitchenRequestIdTok, false);
        OrderID := _JsonHelper.GetJBigInteger(Context.AsToken(), _OrderIdTok, KitchenRequestId = 0);
        if (OrderID = 0) and (KitchenRequestId = 0) then
            Error(MissingContextParamErr, KitchenRequestIdTok, _OrderIdTok);
        KitchenStationFilter := GetKitchenStationIDFilter(Context);
        RestaurantCode := GetRestaurantCode(Context, true);

        KitchenOrderMgt.SetHideValidationDialog(true);

        if (ActionToRun In [_KitchenAction::"Set OnHold", _KitchenAction::"Resume"]) and (KitchenRequestId = 0) and (KitchenStationFilter = '') then begin
            KitchenOrder.Get(OrderID);
            KitchenOrderMgt.SetKitchenOrderOnHold(KitchenOrder, ActionToRun = _KitchenAction::"Set OnHold");
            exit;
        end;

        if KitchenRequestId <> 0 then
            KitchenRequest.SetRange("Request No.", KitchenRequestId)
        else
            KitchenRequest.SetRange("Order ID", OrderID);

        if KitchenStationFilter <> '' then begin
            KitchenRequest.SetFilter("Kitchen Station Filter", KitchenStationFilter);
            KitchenRequest.SetRange("Production Restaurant Filter", RestaurantCode);
        end else
            KitchenRequest.SetRange("Restaurant Code", RestaurantCode);
        if ActionToRun = _KitchenAction::"Set Served" then
            KitchenRequest.SetRange("Line Status", KitchenRequest."Line Status"::"Ready for Serving", KitchenRequest."Line Status"::Planned);

        if KitchenRequest.FindSet(true) then
            repeat
                case ActionToRun of
                    _KitchenAction::"Accept Change",
                    _KitchenAction::"Start Production",
                    _KitchenAction::"End Production",
                    _KitchenAction::"Set OnHold",
                    _KitchenAction::"Resume":
                        begin
                            GetRequestStations(KitchenRequest, KitchenRequestStation);
                            if KitchenRequestStation.FindSet(true) then
                                repeat
                                    case ActionToRun of
                                        _KitchenAction::"Accept Change":
                                            KitchenOrderMgt.AcceptQtyChange(KitchenRequestStation);
                                        _KitchenAction::"Start Production":
                                            KitchenOrderMgt.StartProduction(KitchenRequest, KitchenRequestStation);
                                        _KitchenAction::"End Production":
                                            KitchenOrderMgt.EndProduction(KitchenRequestStation);
                                        _KitchenAction::"Set OnHold",
                                        _KitchenAction::"Resume":
                                            KitchenOrderMgt.SetKitchenRequestStationOnHold(KitchenRequestStation, ActionToRun = _KitchenAction::"Set OnHold", true);
                                    end;
                                until KitchenRequestStation.Next() = 0;
                        end;

                    _KitchenAction::"Set Served":
                        KitchenOrderMgt.SetRequestLineAsServed(KitchenRequest);
                end;
            until KitchenRequest.Next() = 0;
    end;

    local procedure GetRequestStations(var KitchenRequest: Record "NPR NPRE Kitchen Request"; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        KitchenRequestStation.Reset();
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequest.CopyFilter("Production Restaurant Filter", KitchenRequestStation."Production Restaurant Code");
        KitchenRequest.CopyFilter("Kitchen Station Filter", KitchenRequestStation."Kitchen Station");
    end;

    local procedure CreateOrderReadyNotifications(Context: JsonObject)
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        NotificationHandler: Codeunit "NPR NPRE Notification Handler";
        OrderID: BigInteger;
    begin
        OrderID := _JsonHelper.GetJBigInteger(Context.AsToken(), _OrderIdTok, true);
        KitchenOrder.Get(OrderID);
        NotificationHandler.CreateOrderNotifications(KitchenOrder, "NPR NPRE Notification Trigger"::KDS_ORDER_READY_FOR_SERVING, 0DT);
    end;
}
