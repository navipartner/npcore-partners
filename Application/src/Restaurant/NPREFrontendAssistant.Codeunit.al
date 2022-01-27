codeunit 6150679 "NPR NPRE Frontend Assistant"
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnConfigureReusableWorkflows', '', true, true)]
    local procedure OnConfigureReusableWorkflows(var Sender: Codeunit "NPR POS UI Management"; POSSession: Codeunit "NPR POS Session"; Setup: Codeunit "NPR POS Setup");
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
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnSetOptions', '', true, true)]
    local procedure OnSetOptions(Setup: Codeunit "NPR POS Setup"; var Options: JsonObject);
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
            Options.Add('npre_SelectTableAction', RestaurantSetup."Select Restaurant Action");
            Options.Add('npre_SelectTableActionParameters', POSActionParameterMgt.GetParametersAsJson(RestaurantSetup.RecordId, RestaurantSetup.FieldNo("Select Restaurant Action")));
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
    local procedure OnRequestWaiterPadData(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        JSON: Codeunit "NPR POS JSON Management";
        RestaurantCode: Code[20];
        LocationCode: Code[20];
    begin
        if Method <> 'RequestWaiterPadData' then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        RestaurantCode := CopyStr(JSON.GetString('restaurantId'), 1, MaxStrLen(RestaurantCode));
        LocationCode := CopyStr(JSON.GetString('locationId'), 1, MaxStrLen(LocationCode));

        RefreshWaiterPadData(POSSession, FrontEnd, RestaurantCode, LocationCode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', true, true)]
    local procedure OnRequestRestaurantLayout(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        JSON: Codeunit "NPR POS JSON Management";
        RestaurantCode: Code[20];
    begin
        if Method <> 'RequestRestaurantLayout' then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        RestaurantCode := CopyStr(JSON.GetString('restaurantId'), 1, MaxStrLen(RestaurantCode));

        RefreshRestaurantLayout(POSSession, FrontEnd, RestaurantCode);
    end;

    procedure RefreshWaiterPadData(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; RestaurantCode: Code[20]; LocationCode: Code[20]);
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
                        if SeatingWaiterPadLink.FindSet() then
                            repeat
                                Clear(WaiterPadSeatingContent);
                                Clear(WaiterPadContent);
                                WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.");
                                WaiterPad.CalcFields("Status Description FF");

                                WaiterPadSeatingContent.Add('restaurantId', SeatingLocation."Restaurant Code");
                                WaiterPadSeatingContent.Add('locationId', SeatingLocation.Code);
                                WaiterPadSeatingContent.Add('seatingId', SeatingWaiterPadLink."Seating Code");
                                WaiterPadSeatingContent.Add('waiterPadId', SeatingWaiterPadLink."Waiter Pad No.");
                                WaiterPadSeatingList.Add(WaiterPadSeatingContent);

                                WaiterPadContent.Add('id', WaiterPad."No.");
                                WaiterPadContent.Add('restaurantId', SeatingLocation."Restaurant Code");
                                if WaiterPad.Description <> '' then
                                    WaiterPadContent.Add('caption', WaiterPad.Description)
                                else
                                    WaiterPadContent.Add('caption', WaiterPad."No.");
                                WaiterPadContent.Add('statusId', WaiterPad.Status);
                                WaiterPadContent.Add('servingStepCode', WaiterPad."Serving Step Code");
                                WaiterPadContent.Add('servingStepColor', GetFlowStatusRgbColorHex(WaiterPad."Serving Step Code", 2));
                                WaiterPadList.Add(WaiterPadContent);
                            until SeatingWaiterPadLink.Next() = 0;
                    until Seating.Next() = 0;
            until SeatingLocation.Next() = 0;

        Request.GetContent().Add('waiterPads', WaiterPadList);
        Request.GetContent().Add('waiterPadSeatingLinks', WaiterPadSeatingList);

        FrontEnd.InvokeFrontEndMethod(Request);
    end;

    procedure RefreshRestaurantLayout(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; RestaurantCode: Code[20]);
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        LocationLayout: Record "NPR NPRE Location Layout";
        Restaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        Request: Codeunit "NPR Front-End: Generic";
        ComponentList: JsonArray;
        ComponentContent: JsonObject;
        LocationList: JsonArray;
        LocationContent: JsonObject;
        RestaurantList: JsonArray;
        RestaurantContent: JsonObject;
        StatusContent: JsonObject;
        StatusObjectList: JsonArray;
        Instr: InStream;
        PropertiesString: Text;
        AddToList: Boolean;
    begin
        SeatingLocation.SetCurrentKey("Restaurant Code");
        Request.SetMethod('UpdateRestaurantLayout');
        if RestaurantCode <> '' then begin
            SeatingLocation.FilterGroup(2);
            SeatingLocation.SetRange("Restaurant Code", RestaurantCode);
            SeatingLocation.FilterGroup(0);
        end;
        if Restaurant.FindSet() then
            repeat
                Clear(RestaurantContent);
                RestaurantContent.Add('id', Restaurant.Code);
                RestaurantContent.Add('caption', Restaurant.Name);
                RestaurantList.Add(RestaurantContent);

                SeatingLocation.SetRange("Restaurant Code", Restaurant.Code);
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
                                Clear(ComponentContent);
                                ComponentContent.Add('id', LocationLayout.Code);
                                ComponentContent.Add('user_friendly_id', LocationLayout."Seating No.");
                                ComponentContent.Add('type', LocationLayout.Type);
                                ComponentContent.Add('caption', LocationLayout.Description);
                                if LocationLayout."Frontend Properties".HasValue() then begin
                                    LocationLayout.CalcFields("Frontend Properties");
                                    LocationLayout."Frontend Properties".CreateInStream(Instr);
                                    Instr.Read(PropertiesString);
                                    ComponentContent.Add('blob', PropertiesString);
                                end else
                                    ComponentContent.Add('blob', '');

                                if LocationLayout.Type = 'table' then begin
                                    AddToList := Seating.Get(LocationLayout.Code);
                                    if AddToList then begin
                                        ComponentContent.Add('blocked', Seating.Blocked);
                                        ComponentContent.Add('statusId', Seating.Status);
                                        ComponentContent.Add('capacity', Seating.Capacity);
                                        ComponentContent.Add('color', Seating.RGBColorCodeHex(true));
                                    end;
                                end else
                                    AddToList := true;

                                if AddToList then
                                    ComponentList.Add(ComponentContent);
                            until LocationLayout.Next() = 0;

                        LocationContent.Add('components', ComponentList);
                        LocationList.Add(LocationContent);
                    until SeatingLocation.Next() = 0;
            until Restaurant.Next() = 0;

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

        FrontEnd.InvokeFrontEndMethod(Request);

        RefreshStatus(POSSession, FrontEnd, RestaurantCode, '');
    end;

    procedure RefreshWaiterPadContent(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; WaiterpadCode: Code[20]);
    var
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        Request: Codeunit "NPR Front-End: Generic";
        WaiterPadList: JsonArray;
        WaiterPadContent: JsonObject;
        WaiterPadLineList: JsonArray;
        WaiterPadLineContent: JsonObject;
        WaiterPadSeatingList: JsonArray;
        WaiterPadSeatingContent: JsonObject;
    begin
        Request.SetMethod('UpdateWaiterPadContent');

        WaiterPad.SetRange("No.", WaiterpadCode);
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
                WaiterPadContent.Add('statusId', WaiterPad.Status);
                WaiterPadContent.Add('servingStepCode', WaiterPad."Serving Step Code");
                WaiterPadContent.Add('servingStepColor', GetFlowStatusRgbColorHex(WaiterPad."Serving Step Code", 2));

                // links to tables
                Clear(WaiterPadSeatingList);
                SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
                if SeatingWaiterPadLink.FindSet() then
                    repeat
                        Seating.Get(SeatingWaiterPadLink."Seating Code");
                        Clear(WaiterPadSeatingContent);
                        WaiterPadSeatingContent.Add('id', SeatingWaiterPadLink."Seating Code");
                        WaiterPadSeatingContent.Add('description', Seating.Description);
                        WaiterPadSeatingContent.Add('statusId', Seating.Status);
                        WaiterPadSeatingList.Add(WaiterPadSeatingContent);
                    until SeatingWaiterPadLink.Next() = 0;
                WaiterPadContent.Add('seatings', WaiterPadSeatingList);

                // Lines
                Clear(WaiterPadLineList);
                WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
                if WaiterPadLine.FindSet() then
                    repeat
                        Clear(WaiterPadLineContent);
                        WaiterPadLineContent.Add('id', FORMAT(WaiterPadLine."Line No.", 0, 9));
                        WaiterPadLineContent.Add('type', FORMAT(WaiterPadLine.Type));
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
        FrontEnd.InvokeFrontEndMethod(Request);
    end;

    procedure RefreshStatus(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; RestaurantCode: Code[20]; LocationCode: Code[20]);
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

        if RestaurantCode <> '' then
            SeatingLocation.SetRange("Restaurant Code", RestaurantCode);
        if LocationCode <> '' then
            SeatingLocation.SetRange(Code, LocationCode);

        if SeatingLocation.FindSet() then
            repeat
                Seating.SetRange("Seating Location", SeatingLocation.Code);
                if Seating.FindSet() then
                    repeat
                        if not SeatingStatus.Contains(Seating.Code) then
                            SeatingStatus.Add(Seating.Code, Seating.Status);

                        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
                        if SeatingWaiterPadLink.FindSet() then
                            repeat
                                if WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.") then
                                    if not WaiterPadStatus.Contains(WaiterPad."No.") then
                                        WaiterPadStatus.Add(WaiterPad."No.", WaiterPad.Status);
                            until SeatingWaiterPadLink.Next() = 0;
                    until Seating.Next() = 0;
            until SeatingLocation.Next() = 0;

        Request.GetContent().Add('seating', SeatingStatus);
        Request.GetContent().Add('waiterPad', WaiterPadStatus);

        FrontEnd.InvokeFrontEndMethod(Request);
    end;

    procedure SetRestaurant(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; RestaurantCode: Code[20])
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
        FrontEnd.InvokeFrontEndMethod(Request);

        RefreshRestaurantLayout(POSSession, FrontEnd, RestaurantCode);
    end;

    local procedure SelectStatusObjects(var NPREFlowStatus: Record "NPR NPRE Flow Status"; var StatusObjectList: JsonArray);
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

    local procedure GetFlowStatusRgbColorHex(StatusCode: Code[10]; StatusObject: Integer): Text
    var
        ColorTable: Record "NPR NPRE Color Table";
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        if not FlowStatus.get(StatusCode, StatusObject) then
            exit('');
        if not ColorTable.get(FlowStatus.Color) then
            ColorTable.Init();
        exit(ColorTable.RGBHexCode(false));
    end;
}
