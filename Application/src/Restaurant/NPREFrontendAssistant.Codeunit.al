codeunit 6150679 "NPR NPRE Frontend Assistant"
{
    Access = Internal;

    var
        _JsonHelper: Codeunit "NPR Json Helper";
        _KitchenAction: Option "Accept Change","Set Production Not Started","Start Production","End Production","Set OnHold","Resume","Set Served","Revoke Serving";
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
             'KDS_SetProductionNotStarted',
             'KDS_SetProductionStarted',
             'KDS_SetProductionFinished',
             'KDS_SetOnHold',
             'KDS_Resume',
             'KDS_SetServed',
             'KDS_SendOrderReadyNotifications',
             'KDS_RevokeServing']
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
            'KDS_SetProductionNotStarted':
                RunKitchenAction(Context, _KitchenAction::"Set Production Not Started");
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
            'KDS_RevokeServing':
                RunKitchenAction(Context, _KitchenAction::"Revoke Serving");
            'KDS_SendOrderReadyNotifications':
                CreateOrderReadyNotifications(Context);
        end;
    end;

    local procedure GetRestaurantCode(Context: JsonObject; Required: Boolean) RestaurantCode: Code[20]
    begin
        RestaurantCode := CopyStr(_JsonHelper.GetJText(Context.AsToken(), 'restaurantId', Required), 1, MaxStrLen(RestaurantCode));
    end;

    [Obsolete('We will not need it anymore when we have switched to using the separate KDS API endpoint (codeunit "NPR KDS Frontend Assistant") decoupled from Dragonglass', 'NPR33.0')]
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

    [Obsolete('Use the separate KDS API endpoint (codeunit "NPR KDS Frontend Assistant") decoupled from Dragonglass', 'NPR33.0')]
    local procedure RefreshCustomerDisplayKitchenOrders(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        FrontEnd.RespondToFrontEndMethod(Context, KDSFrontendAssistImpl.RefreshCustomerDisplayKitchenOrders(GetRestaurantCode(Context, false)), FrontEnd);
    end;

    [Obsolete('Use the separate KDS API endpoint (codeunit "NPR KDS Frontend Assistant") decoupled from Dragonglass', 'NPR33.0')]
    local procedure GetSetups(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        FrontEnd.RespondToFrontEndMethod(Context, KDSFrontendAssistImpl.GetSetups(), FrontEnd);
    end;

    [Obsolete('Use the separate KDS API endpoint (codeunit "NPR KDS Frontend Assistant") decoupled from Dragonglass', 'NPR33.0')]
    local procedure RefreshKDSData(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        FrontEnd.RespondToFrontEndMethod(
            Context,
            KDSFrontendAssistImpl.RefreshKDSData(
                GetRestaurantCode(Context, true),
                GetKitchenStationIDFilter(Context),
                _JsonHelper.GetJBoolean(Context.AsToken(), 'includeFinished', false),
                _JsonHelper.GetJDT(Context.AsToken(), 'startingFrom', false)),
            FrontEnd);
    end;

    [Obsolete('Use the separate KDS API endpoint (codeunit "NPR KDS Frontend Assistant") decoupled from Dragonglass', 'NPR33.0')]
    local procedure RunKitchenAction(Context: JsonObject; ActionToRun: Option)
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        RestaurantCode: Code[20];
        KitchenStationFilter: Text;
        KitchenRequestId: BigInteger;
        OrderID: BigInteger;
        KitchenRequestIdTok: label 'kitchenRequestId', Locked = true;
    begin
        KitchenRequestId := _JsonHelper.GetJBigInteger(Context.AsToken(), KitchenRequestIdTok, false);
        OrderID := _JsonHelper.GetJBigInteger(Context.AsToken(), _OrderIdTok, KitchenRequestId = 0);
        KitchenStationFilter := GetKitchenStationIDFilter(Context);
        RestaurantCode := GetRestaurantCode(Context, true);

        KDSFrontendAssistImpl.RunKitchenAction(RestaurantCode, KitchenStationFilter, KitchenRequestId, OrderID, ActionToRun);
    end;

    [Obsolete('Use the separate KDS API endpoint (codeunit "NPR KDS Frontend Assistant") decoupled from Dragonglass', 'NPR33.0')]
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
