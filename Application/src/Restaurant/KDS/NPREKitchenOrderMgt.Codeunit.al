codeunit 6150674 "NPR NPRE Kitchen Order Mgt."
{
    Access = Internal;

    var
        GlobalKitchenOrder: Record "NPR NPRE Kitchen Order";
        NotificationHandler: Codeunit "NPR NPRE Notification Handler";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        _HideValidationDialog: Boolean;
        AlreadyFinishedMsg: Label 'Production of the item has already been marked as finished. Are you sure you want to start over?';
        RequestCancelledMsg: Label 'The kitchen request is cancelled. Are you sure you want to continue?';

    procedure SendWPLinesToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLineIn: Record "NPR NPRE Waiter Pad Line"; FlowStatusCode: Code[10]; PrintCategoryCode: Code[20]; RequestType: Option "Order","Serving Request"; SentDateTime: DateTime): Boolean
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        Success: Boolean;
    begin
        if not (RequestType in [RequestType::Order, RequestType::"Serving Request"]) then
            exit(false);

        if SentDateTime = 0DT then
            SentDateTime := CurrentDateTime();

        WaiterPadLine.Copy(WaiterPadLineIn);
        if WaiterPadLine.FindSet() then
            repeat
                if SendWPLineToKitchen(WaiterPad, WaiterPadLine, FlowStatusCode, PrintCategoryCode, RequestType, SentDateTime) then begin
                    RestaurantPrint.LogWaiterPadLinePrint(WaiterPadLine, RequestType, FlowStatusCode, PrintCategoryCode, SentDateTime, 1);
                    Success := true;
                end;
            until WaiterPadLine.Next() = 0;

        exit(Success);
    end;

    local procedure SendWPLineToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad"; WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; FlowStatusCode: Code[10]; PrintCategoryCode: Code[20]; RequestType: Option "Order","Serving Request"; SentDateTime: DateTime): Boolean
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequest2: Record "NPR NPRE Kitchen Request";
        KitchenRequestParam: Record "NPR NPRE Kitchen Request";
        KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link";
        KitchenStation: Record "NPR NPRE Kitchen Station";
        TempKitchenStationBuffer: Record "NPR NPRE Kitchen Station Slct." temporary;
        TouchedKitchenOrderList: List of [BigInteger];
        TouchedKitchenOrderID: BigInteger;
    begin
        if not FindApplicableWPLineKitchenStations(TempKitchenStationBuffer, WaiterPadLine, FlowStatusCode, PrintCategoryCode) then
            exit(false);

        WaiterPad.CalcFields("Current Seating FF");
        KitchenRequestParam.InitFromWaiterPadLine(WaiterPadLine);
        KitchenRequestParam."Restaurant Code" := TempKitchenStationBuffer."Restaurant Code";
        KitchenRequestParam."Serving Step" := FlowStatusCode;
        KitchenRequestParam."Created Date-Time" := SentDateTime;
        InitKitchenReqSourceFromWaiterPadLine(
            KitchenReqSourceParam, WaiterPadLine, TempKitchenStationBuffer."Restaurant Code", WaiterPad."Current Seating FF",
            WaiterPad."Assigned Waiter Code", KitchenRequestParam."Serving Step", KitchenRequestParam."Created Date-Time");

        KitchenRequest.Reset();
        FindKitchenRequestsForSourceDoc(KitchenRequest, KitchenReqSourceParam);
        HandleQtyChange(KitchenRequest, KitchenRequestParam, KitchenReqSourceParam);

        if KitchenRequest.FindSet() then
            repeat
                KitchenRequest2 := KitchenRequest;
                if RequestType = RequestType::"Serving Request" then begin
                    KitchenRequest2."Serving Requested Date-Time" := SentDateTime;
                    if KitchenRequest2."Line Status" = KitchenRequest2."Line Status"::Planned then
                        KitchenRequest2."Line Status" := KitchenRequest2."Line Status"::"Serving Requested";
                    UpdateRequestLineStatus(KitchenRequest2);
                    KitchenRequest2.Modify();
                end;

                TempKitchenStationBuffer.FindSet();
                repeat
                    KitchenStation.Get(TempKitchenStationBuffer."Production Restaurant Code", TempKitchenStationBuffer."Kitchen Station");
                    CreateKitchenStationRequest(KitchenRequest2, KitchenStation, TempKitchenStationBuffer."Production Step");
                until TempKitchenStationBuffer.Next() = 0;

                if not TouchedKitchenOrderList.Contains(KitchenRequest2."Order ID") then
                    TouchedKitchenOrderList.Add(KitchenRequest2."Order ID");
            until KitchenRequest.Next() = 0;

        foreach TouchedKitchenOrderID in TouchedKitchenOrderList do
            UpdateOrderStatus(TouchedKitchenOrderID);

        exit(true);
    end;

    procedure FindKitchenRequestsForSourceDoc(var KitchenRequest: Record "NPR NPRE Kitchen Request"; KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link")
    var
        KitchenReqWSourceQry: Query "NPR NPRE Kitchen Req. w Source";
    begin
        KitchenReqWSourceQry.SetRange(Source_Document_Type, KitchenReqSourceParam."Source Document Type");
        KitchenReqWSourceQry.SetRange(Source_Document_Subtype, KitchenReqSourceParam."Source Document Subtype");
        KitchenReqWSourceQry.SetRange(Source_Document_No, KitchenReqSourceParam."Source Document No.");
        if KitchenReqSourceParam."Source Document Line No." <> 0 then
            KitchenReqWSourceQry.SetRange(Source_Document_Line_No, KitchenReqSourceParam."Source Document Line No.");
        if KitchenReqSourceParam."Restaurant Code" <> '' then
            KitchenReqWSourceQry.SetRange(Restaurant_Code, KitchenReqSourceParam."Restaurant Code");
        if KitchenReqSourceParam."Serving Step" <> '' then
            KitchenReqWSourceQry.SetRange(Serving_Step, KitchenReqSourceParam."Serving Step");
        KitchenReqWSourceQry.SetFilter(Line_Status, '<>%1', KitchenRequest."Line Status"::Cancelled);
        KitchenReqWSourceQry.Open();
        while KitchenReqWSourceQry.Read() do begin
            KitchenRequest.Get(KitchenReqWSourceQry.Request_No);
            KitchenRequest.Mark(true);
        end;
        KitchenRequest.MarkedOnly(true);
    end;

    procedure FindKitchenRequestsForWaiterOrSeating(var KitchenRequest: Record "NPR NPRE Kitchen Request"; KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link")
    var
        KitchenReqWSourceQry: Query "NPR NPRE Kitchen Req. w Source";
    begin
        if KitchenReqSourceParam."Restaurant Code" <> '' then
            KitchenReqWSourceQry.SetRange(Restaurant_Code, KitchenReqSourceParam."Restaurant Code");
        if KitchenReqSourceParam."Serving Step" <> '' then
            KitchenReqWSourceQry.SetRange(Serving_Step, KitchenReqSourceParam."Serving Step");
        if KitchenReqSourceParam."Assigned Waiter Code" <> '' then
            KitchenReqWSourceQry.SetRange(Assigned_Waiter_Code, KitchenReqSourceParam."Assigned Waiter Code");
        if KitchenReqSourceParam."Seating Code" <> '' then
            KitchenReqWSourceQry.SetRange(Seating_Code, KitchenReqSourceParam."Seating Code");
        KitchenReqWSourceQry.SetFilter(Line_Status, '<>%1', KitchenRequest."Line Status"::Cancelled);
        KitchenReqWSourceQry.Open();
        while KitchenReqWSourceQry.Read() do begin
            KitchenRequest.Get(KitchenReqWSourceQry.Request_No);
            KitchenRequest.Mark(true);
        end;
        KitchenRequest.MarkedOnly(true);
    end;

    local procedure FindKitchenOrderId(KitchenRequest: Record "NPR NPRE Kitchen Request"; KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link"): BigInteger
    var
        KitchenReqWSourceQry: Query "NPR NPRE Kitchen Req. w Source";
    begin
        if GlobalKitchenOrder."Order ID" = 0 then begin
            SetupProxy.SetRestaurant(KitchenRequest."Restaurant Code");
            if SetupProxy.OrderIDAssignmentMethod() = Enum::"NPR NPRE Ord.ID Assign. Method"::"Same for Source Document" then begin
                KitchenReqWSourceQry.SetRange(Source_Document_Type, KitchenReqSourceLink."Source Document Type");
                KitchenReqWSourceQry.SetRange(Source_Document_Subtype, KitchenReqSourceLink."Source Document Subtype");
                KitchenReqWSourceQry.SetRange(Source_Document_No, KitchenReqSourceLink."Source Document No.");
                KitchenReqWSourceQry.SetRange(Order_Status, GlobalKitchenOrder."Order Status"::"Ready for Serving", GlobalKitchenOrder."Order Status"::Planned);
                KitchenReqWSourceQry.SetFilter(Order_ID, '<>%1', 0);
                KitchenReqWSourceQry.Open();
                if KitchenReqWSourceQry.Read() then
                    GlobalKitchenOrder.Get(KitchenReqWSourceQry.Order_ID);
            end;

            if GlobalKitchenOrder."Order ID" = 0 then begin
                GlobalKitchenOrder.Init();
                GlobalKitchenOrder."Order Status" := GlobalKitchenOrder."Order Status"::Planned;
                GlobalKitchenOrder.Priority := DefaultPriority(KitchenRequest);
                GlobalKitchenOrder."Created Date-Time" := KitchenRequest."Created Date-Time";
                GlobalKitchenOrder."Restaurant Code" := KitchenRequest."Restaurant Code";
                GlobalKitchenOrder.Insert();
                NotificationHandler.CreateOrderNotifications(GlobalKitchenOrder, "NPR NPRE Notification Trigger"::KDS_ORDER_NEW, 0DT);
            end;
        end;
        exit(GlobalKitchenOrder."Order ID");
    end;

    local procedure HandleQtyChange(var KitchenRequest: Record "NPR NPRE Kitchen Request"; KitchenRequestParam: Record "NPR NPRE Kitchen Request"; KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link")
    begin
        KitchenRequest.FilterGroup(2);
        KitchenRequest.SetFilter("Line Status", '<>%1', KitchenRequest."Line Status"::Cancelled);
        KitchenRequest.SetFilter("Production Status", '<>%1', KitchenRequest."Production Status"::Cancelled);
        KitchenRequest.FilterGroup(0);

        KitchenRequest.SetSourceDocLinkFilter(KitchenReqSourceParam);
        KitchenRequest.SetAutoCalcFields(Quantity, "Quantity (Base)");
        if KitchenRequest.FindSet() then
            repeat
                KitchenReqSourceParam.Quantity := KitchenReqSourceParam.Quantity - KitchenRequest.Quantity;
                KitchenReqSourceParam."Quantity (Base)" := KitchenReqSourceParam."Quantity (Base)" - KitchenRequest."Quantity (Base)";
            until KitchenRequest.Next() = 0;
        KitchenRequest.ClearSourceDocLinkFilter();
        if KitchenReqSourceParam.Quantity = 0 then
            exit;

        KitchenRequest.SetRange("Line Status", KitchenRequest."Line Status"::"Serving Requested", KitchenRequest."Line Status"::Planned);
        KitchenRequest.SetRange("Production Status", KitchenRequest."Production Status"::"Not Started", KitchenRequest."Production Status"::"On Hold");
        AllocateQtyChangeToExistingKitchenRequests(KitchenRequest, KitchenReqSourceParam);

        if KitchenReqSourceParam.Quantity < 0 then begin
            //Allocate quantity decrease, even if production has already been finished
            KitchenRequest.SetRange("Production Status");
            AllocateQtyChangeToExistingKitchenRequests(KitchenRequest, KitchenReqSourceParam);

            if KitchenReqSourceParam.Quantity < 0 then begin
                //Allocate quantity decrease, even if items have already been served
                KitchenRequest.SetRange("Line Status");
                AllocateQtyChangeToExistingKitchenRequests(KitchenRequest, KitchenReqSourceParam);
            end;
        end;

        KitchenRequest.SetRange("Line Status");
        KitchenRequest.SetRange("Production Status");

        if KitchenReqSourceParam.Quantity > 0 then begin
            //New request for quantity increase
            CreateKitchenRequest(KitchenRequest, KitchenRequestParam, KitchenReqSourceParam);
            KitchenRequest.Mark(true);
        end;
    end;

    local procedure AllocateQtyChangeToExistingKitchenRequests(var KitchenRequest: Record "NPR NPRE Kitchen Request"; var KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link")
    var
        xKitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        if KitchenReqSourceParam.Quantity = 0 then
            exit;

        if KitchenRequest.FindSet() then
            repeat
                if (KitchenRequest.Quantity > 0) or (KitchenReqSourceParam.Quantity > 0) then begin
                    xKitchenReqSourceParam := KitchenReqSourceParam;
                    if KitchenRequest.Quantity + KitchenReqSourceParam.Quantity <= 0 then begin
                        KitchenReqSourceParam.Quantity := -KitchenRequest.Quantity;
                        KitchenReqSourceParam."Quantity (Base)" := -KitchenRequest."Quantity (Base)";
                        CancelKitchenRequest(KitchenRequest);
                    end else begin
                        CreateKitchenRequestSourceLink(KitchenRequest, KitchenReqSourceParam);
                        SetQtyChanged(KitchenRequest);
                    end;

                    KitchenReqSourceParam.Quantity := xKitchenReqSourceParam.Quantity - KitchenReqSourceParam.Quantity;
                    KitchenReqSourceParam."Quantity (Base)" := xKitchenReqSourceParam."Quantity (Base)" - KitchenReqSourceParam."Quantity (Base)";
                end;
            until (KitchenRequest.Next() = 0) or (KitchenReqSourceParam.Quantity = 0);
    end;

    local procedure SetQtyChanged(KitchenRequest: Record "NPR NPRE Kitchen Request")
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequestStation.ModifyAll("Qty. Change Not Accepted", true);
    end;

    procedure InitKitchenReqSourceFromWaiterPadLine(var KitchenReqSource: Record "NPR NPRE Kitchen Req.Src. Link"; WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; RestaurantCode: Code[20]; SeatingCode: Code[20]; WaiterCode: Code[20]; ServingStep: Code[10]; SentDateTime: DateTime)
    begin
        KitchenReqSource.Init();
        KitchenReqSource.InitSource(WaiterPadLine.RecordId);
        KitchenReqSource."Restaurant Code" := RestaurantCode;
        KitchenReqSource."Seating Code" := SeatingCode;
        KitchenReqSource."Assigned Waiter Code" := WaiterCode;
        KitchenReqSource."Serving Step" := ServingStep;
        KitchenReqSource."Created Date-Time" := SentDateTime;
        KitchenReqSource.Quantity := WaiterPadLine.Quantity;
        KitchenReqSource."Quantity (Base)" := WaiterPadLine."Quantity (Base)";
    end;

    local procedure CreateKitchenRequest(var KitchenRequest: Record "NPR NPRE Kitchen Request"; KitchenRequestParam: Record "NPR NPRE Kitchen Request"; KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link")
    begin
        KitchenRequest := KitchenRequestParam;
        KitchenRequest."Line Status" := KitchenRequest."Line Status"::Planned;
        KitchenRequest."Production Status" := KitchenRequest."Production Status"::"Not Started";
        KitchenRequest."Order ID" := FindKitchenOrderId(KitchenRequest, KitchenReqSourceParam);
        KitchenRequest.Priority := GlobalKitchenOrder.Priority;
        KitchenRequest."Request No." := 0;
        KitchenRequest.Insert(true);

        CreateKitchenRequestSourceLink(KitchenRequest, KitchenReqSourceParam);
        CreateKitchenrequestModifiers(KitchenRequest, KitchenReqSourceParam);
    end;

    local procedure CreateKitchenRequestSourceLink(KitchenRequest: Record "NPR NPRE Kitchen Request"; KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link")
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        KitchenReqSourceLink := KitchenReqSourceParam;
        KitchenReqSourceLink."Request No." := KitchenRequest."Request No.";
        KitchenReqSourceLink."Entry No." := 0;
        KitchenReqSourceLink.Insert();
    end;

    local procedure CreateKitchenrequestModifiers(KitchenRequest: Record "NPR NPRE Kitchen Request"; KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link")
    var
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        case KitchenReqSourceParam."Source Document Type" of
            KitchenReqSourceParam."Source Document Type"::"Waiter Pad":
                begin
                    WaiterPadLine.SetRange("Waiter Pad No.", KitchenReqSourceParam."Source Document No.");
                    WaiterPadLine.SetRange("Attached to Line No.", KitchenReqSourceParam."Source Document Line No.");
                    if WaiterPadLine.FindSet() then
                        repeat
                            KitchenRequestModifier.Init();
                            KitchenRequestModifier."Request No." := KitchenRequest."Request No.";
                            KitchenRequestModifier."Line No." += 10000;
                            KitchenRequestModifier."Line Type" := WaiterPadLine."Line Type";
                            KitchenRequestModifier."No." := WaiterPadLine."No.";
                            KitchenRequestModifier.Description := WaiterPadLine.Description;
                            KitchenRequestModifier."Description 2" := WaiterPadLine."Description 2";
                            KitchenRequestModifier.Indentation := WaiterPadLine.Indentation;
                            KitchenRequestModifier.Quantity := WaiterPadLine.Quantity;
                            KitchenRequestModifier."Quantity (Base)" := WaiterPadLine."Quantity (Base)";
                            KitchenRequestModifier."Qty. per Unit of Measure" := WaiterPadLine."Qty. per Unit of Measure";
                            KitchenRequestModifier."Unit of Measure Code" := WaiterPadLine."Unit of Measure Code";
                            KitchenRequestModifier.Insert();
                        until WaiterPadLine.Next() = 0;
                end;
        end;
    end;

    local procedure CreateKitchenStationRequest(KitchenRequest: Record "NPR NPRE Kitchen Request"; KitchenStation: Record "NPR NPRE Kitchen Station"; ProductionStep: Integer)
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequestStation.SetRange("Production Restaurant Code", KitchenStation."Restaurant Code");
        KitchenRequestStation.SetRange("Kitchen Station", KitchenStation.Code);
        KitchenRequestStation.SetFilter("Production Status", '<>%1', KitchenRequestStation."Production Status"::Cancelled);
        if KitchenRequestStation.IsEmpty() then begin
            KitchenRequestStation.Init();
            KitchenRequestStation."Request No." := KitchenRequest."Request No.";
            KitchenRequestStation."Parent Request No." := KitchenRequest."Parent Request No.";
            KitchenRequestStation."Line No." := KitchenRequest.GetNextStationReqLineNo();
            KitchenRequestStation."Production Restaurant Code" := KitchenStation."Restaurant Code";
            KitchenRequestStation."Kitchen Station" := KitchenStation.Code;
            KitchenRequestStation."Production Step" := ProductionStep;
            KitchenRequestStation."Production Status" := KitchenRequestStation."Production Status"::"Not Started";
            KitchenRequestStation."Order ID" := KitchenRequest."Order ID";
            ForwardKitchenStationRequestStatuses(KitchenRequestStation, 1);
            KitchenRequestStation.Insert();
            ForwardKitchenStationRequestStatuses(KitchenRequestStation, 0);
        end;
    end;

    local procedure ForwardKitchenStationRequestStatuses(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station"; Direction: Option Forward,Backward)
    begin
        ForwardKitchenStationRequestStatusesByProductionStep(KitchenRequestStation, Direction);
        ForwardKitchenStationRequestStatusesToParentRequests(KitchenRequestStation, Direction);
    end;

    local procedure ForwardKitchenStationRequestStatusesByProductionStep(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station"; Direction: Option Forward,Backward)
    var
        KitchenRequestStation2: Record "NPR NPRE Kitchen Req. Station";
    begin
        if (Direction = Direction::Backward) and (KitchenRequestStation."Production Step" = 0) then
            exit;

        KitchenRequestStation2.SetRange("Request No.", KitchenRequestStation."Request No.");
        KitchenRequestStation2.SetFilter("Line No.", '<>%1', KitchenRequestStation."Line No.");

        case Direction of
            Direction::Forward:
                begin
                    if KitchenRequestStation."Production Status" in [KitchenRequestStation."Production Status"::Finished, KitchenRequestStation."Production Status"::Cancelled] then begin
                        KitchenRequestStation2.SetRange("Production Step", KitchenRequestStation."Production Step");
                        KitchenRequestStation2.SetRange("Production Status", KitchenRequestStation2."Production Status"::"Not Started", KitchenRequestStation2."Production Status"::"On Hold");
                        if not KitchenRequestStation2.IsEmpty() then
                            exit;

                        KitchenRequestStation2.SetFilter("Production Step", '>%1', KitchenRequestStation."Production Step");
                        KitchenRequestStation2.SetRange("Production Status", KitchenRequestStation2."Production Status"::Pending);
                        KitchenRequestStation2.SetCurrentKey("Request No.", "Production Step");
                        if KitchenRequestStation2.FindFirst() then begin
                            KitchenRequestStation2.SetRange("Production Step", KitchenRequestStation2."Production Step");
                            KitchenRequestStation2.ModifyAll("Production Status", KitchenRequestStation2."Production Status"::"Not Started");
                        end;
                    end else begin
                        KitchenRequestStation2.SetFilter("Production Step", '>%1', KitchenRequestStation."Production Step");
                        KitchenRequestStation2.SetRange("Production Status", KitchenRequestStation2."Production Status"::"Not Started");
                        if KitchenRequestStation2.IsEmpty() then
                            exit;
                        KitchenRequestStation2.ModifyAll("Production Status", KitchenRequestStation2."Production Status"::Pending);
                    end;
                end;

            Direction::Backward:
                begin
                    if KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::"Not Started" then begin
                        KitchenRequestStation2.SetFilter("Production Step", '<%1', KitchenRequestStation."Production Step");
                        KitchenRequestStation2.SetRange("Production Status", KitchenRequestStation2."Production Status"::"Not Started", KitchenRequestStation2."Production Status"::"On Hold");
                        if not KitchenRequestStation2.IsEmpty() then
                            KitchenRequestStation."Production Status" := KitchenRequestStation."Production Status"::Pending;
                    end;
                end;
        end;
    end;

    local procedure ForwardKitchenStationRequestStatusesToParentRequests(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station"; Direction: Option Forward,Backward)
    var
        KitchenRequestStation2: Record "NPR NPRE Kitchen Req. Station";
    begin
        if (Direction = Direction::Forward) and (KitchenRequestStation."Parent Request No." = 0) then
            exit;

        case Direction of
            Direction::Forward:
                begin
                    if KitchenRequestStation."Production Status" in [KitchenRequestStation."Production Status"::Finished, KitchenRequestStation."Production Status"::Cancelled] then begin
                        KitchenRequestStation2.SetRange("Parent Request No.", KitchenRequestStation."Parent Request No.");
                        KitchenRequestStation2.SetRange("Production Status", KitchenRequestStation2."Production Status"::"Not Started", KitchenRequestStation2."Production Status"::"On Hold");
                        if not KitchenRequestStation2.IsEmpty() then
                            exit;

                        KitchenRequestStation2.SetRange("Parent Request No.");
                        KitchenRequestStation2.SetRange("Request No.", KitchenRequestStation."Parent Request No.");
                        KitchenRequestStation2.SetRange("Production Status", KitchenRequestStation2."Production Status"::Pending);
                        KitchenRequestStation2.SetCurrentKey("Request No.", "Production Step");
                        if KitchenRequestStation2.FindFirst() then begin
                            KitchenRequestStation2.SetRange("Production Step", KitchenRequestStation2."Production Step");
                            KitchenRequestStation2.ModifyAll("Production Status", KitchenRequestStation2."Production Status"::"Not Started");
                        end;
                    end else begin
                        KitchenRequestStation2.SetRange("Request No.", KitchenRequestStation."Parent Request No.");
                        KitchenRequestStation2.SetRange("Production Status", KitchenRequestStation2."Production Status"::"Not Started");
                        if KitchenRequestStation2.IsEmpty() then
                            exit;
                        KitchenRequestStation2.ModifyAll("Production Status", KitchenRequestStation2."Production Status"::Pending);
                    end;
                end;

            Direction::Backward:
                begin
                    if KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::"Not Started" then begin
                        KitchenRequestStation2.SetRange("Parent Request No.", KitchenRequestStation."Request No.");
                        KitchenRequestStation2.SetRange("Production Status", KitchenRequestStation2."Production Status"::"Not Started", KitchenRequestStation2."Production Status"::"On Hold");
                        if not KitchenRequestStation2.IsEmpty() then
                            KitchenRequestStation."Production Status" := KitchenRequestStation."Production Status"::Pending;
                    end;
                end;
        end;
    end;

    procedure FindApplicableWPLineKitchenStations(var KitchenStationBuffer: Record "NPR NPRE Kitchen Station Slct."; WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; FlowStatusCode: Code[10]; PrintCategoryCode: Code[20]): Boolean
    var
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        if not KitchenStationBuffer.IsTemporary() then
            SetupProxy.ThrowNonTempException('CU6150674.FindKitchenStations');

        Clear(KitchenStationBuffer);
        KitchenStationBuffer.DeleteAll();

        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadLine."Waiter Pad No.");
        SeatingWaiterPadLink.SetFilter("Seating Code", '<>%1', '');
        if SeatingWaiterPadLink.IsEmpty() then
            SeatingWaiterPadLink.SetRange("Seating Code");
        if SeatingWaiterPadLink.FindFirst() then begin
            Seating.Get(SeatingWaiterPadLink."Seating Code");
            if not SeatingLocation.Get(Seating."Seating Location") then
                SeatingLocation.Init();

            KitchenStationSelection.Reset();
            KitchenStationSelection."Restaurant Code" := SeatingLocation."Restaurant Code";
            KitchenStationSelection."Seating Location" := Seating."Seating Location";
            KitchenStationSelection."Serving Step" := FlowStatusCode;
            KitchenStationSelection."Print Category Code" := PrintCategoryCode;
            if GetKitchenStationSelection(KitchenStationSelection) then
                repeat
                    KitchenStationBuffer."Restaurant Code" := KitchenStationSelection."Restaurant Code";
                    if KitchenStationSelection."Production Restaurant Code" = '' then
                        KitchenStationBuffer."Production Restaurant Code" := SeatingLocation."Restaurant Code"
                    else
                        KitchenStationBuffer."Production Restaurant Code" := KitchenStationSelection."Production Restaurant Code";
                    KitchenStationBuffer."Kitchen Station" := KitchenStationSelection."Kitchen Station";
                    KitchenStationBuffer."Production Step" := KitchenStationSelection."Production Step";
                    if not KitchenStationBuffer.Find() then
                        KitchenStationBuffer.Insert();

                    if KitchenStationBuffer."Production Step" <> KitchenStationSelection."Production Step" then begin
                        KitchenStationBuffer."Production Step" := KitchenStationSelection."Production Step";
                        KitchenStationBuffer.Modify();
                    end;
                until KitchenStationSelection.Next() = 0;
        end;

        exit(KitchenStationBuffer.FindSet());
    end;

    local procedure GetKitchenStationSelection(var KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct."): Boolean
    begin
        KitchenStationSelection.SetRange("Restaurant Code", KitchenStationSelection."Restaurant Code");
        KitchenStationSelection.SetRange("Seating Location", KitchenStationSelection."Seating Location");
        KitchenStationSelection.SetRange("Serving Step", KitchenStationSelection."Serving Step");
        KitchenStationSelection.SetRange("Print Category Code", KitchenStationSelection."Print Category Code");
        if KitchenStationSelection.IsEmpty() then begin
            KitchenStationSelection.SetRange("Seating Location", '');
            if KitchenStationSelection.IsEmpty() then begin
                KitchenStationSelection.SetRange("Seating Location", KitchenStationSelection."Seating Location");
                KitchenStationSelection.SetRange("Serving Step", '');
                if KitchenStationSelection.IsEmpty() then begin
                    KitchenStationSelection.SetRange("Seating Location", '');
                    if KitchenStationSelection.IsEmpty() then begin
                        KitchenStationSelection.SetRange("Seating Location", KitchenStationSelection."Seating Location");
                        KitchenStationSelection.SetRange("Serving Step", KitchenStationSelection."Serving Step");
                        KitchenStationSelection.SetRange("Print Category Code", '');
                        if KitchenStationSelection.IsEmpty() then begin
                            KitchenStationSelection.SetRange("Seating Location", '');
                            if KitchenStationSelection.IsEmpty() then begin
                                KitchenStationSelection.SetRange("Seating Location", KitchenStationSelection."Seating Location");
                                KitchenStationSelection.SetRange("Serving Step", '');
                                if KitchenStationSelection.IsEmpty() then begin
                                    KitchenStationSelection.SetRange("Seating Location", '');
                                    if KitchenStationSelection.IsEmpty() and (KitchenStationSelection."Restaurant Code" <> '') then begin
                                        KitchenStationSelection."Restaurant Code" := '';
                                        exit(GetKitchenStationSelection(KitchenStationSelection));
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        exit(KitchenStationSelection.FindSet());
    end;

    procedure DefaultPriority(KitchenRequest: Record "NPR NPRE Kitchen Request"): Integer
    begin
        exit(100);
    end;

    procedure SetProductionNotStarted(KitchenRequest: Record "NPR NPRE Kitchen Request"; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        if KitchenRequestStation."Production Status" in [KitchenRequestStation."Production Status"::Pending, KitchenRequestStation."Production Status"::"Not Started"] then
            exit;
        if KitchenRequest."Line Status" = KitchenRequest."Line Status"::Cancelled then
            if not _HideValidationDialog and GuiAllowed() then
                if not Confirm(RequestCancelledMsg, false) then
                    Error('');
        if KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::Finished then
            if not _HideValidationDialog and GuiAllowed() then
                if not Confirm(AlreadyFinishedMsg, true) then
                    Error('');

        KitchenRequestStation."Start Date-Time" := 0DT;
        KitchenRequestStation."End Date-Time" := 0DT;
        KitchenRequestStation."On Hold" := false;
        KitchenRequestStation."Production Status" := KitchenRequestStation."Production Status"::"Not Started";
        ForwardKitchenStationRequestStatuses(KitchenRequestStation, 1);
        KitchenRequestStation.Modify();
        ForwardKitchenStationRequestStatuses(KitchenRequestStation, 0);
        UpdateRequestStatusesFromStation(KitchenRequestStation, true);
    end;

    procedure StartProduction(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        KitchenRequest.Get(KitchenRequestStation."Request No.");
        StartProduction(KitchenRequest, KitchenRequestStation);
    end;

    procedure StartProduction(KitchenRequest: Record "NPR NPRE Kitchen Request"; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        if KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::Started then
            exit;
        if KitchenRequest."Line Status" = KitchenRequest."Line Status"::Cancelled then
            if not _HideValidationDialog and GuiAllowed() then
                if not Confirm(RequestCancelledMsg, false) then
                    Error('');
        if KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::Finished then
            if not _HideValidationDialog and GuiAllowed() then
                if not Confirm(AlreadyFinishedMsg, true) then
                    Error('');

        if KitchenRequestStation."Start Date-Time" = 0DT then
            KitchenRequestStation."Start Date-Time" := CurrentDateTime();
        KitchenRequestStation."End Date-Time" := 0DT;
        KitchenRequestStation."On Hold" := false;
        KitchenRequestStation."Production Status" := KitchenRequestStation."Production Status"::Started;
        KitchenRequestStation.Modify();
        ForwardKitchenStationRequestStatuses(KitchenRequestStation, 0);
        UpdateRequestStatusesFromStation(KitchenRequestStation, true);
    end;

    procedure EndProduction(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    var
        NotStartedMsg: Label 'Production of the item hasn’t started yet. Are you sure you want to mark it as finished now?';
    begin
        if KitchenRequestStation."Production Status" in
            [KitchenRequestStation."Production Status"::Finished, KitchenRequestStation."Production Status"::Cancelled]
        then begin
            if _HideValidationDialog or not GuiAllowed() then
                exit;
            KitchenRequestStation.FieldError("Production Status");
        end;

        if KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::"Not Started" then
            if not _HideValidationDialog and GuiAllowed() then
                if not Confirm(NotStartedMsg, true) then
                    Error('');

        SetKitchenRequestStationFinished(KitchenRequestStation);
    end;

    procedure AcceptQtyChange(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        if KitchenRequestStation."Qty. Change Not Accepted" then begin
            KitchenRequestStation."Qty. Change Not Accepted" := false;
            KitchenRequestStation."Last Qty. Change Accepted" := CurrentDateTime();
            KitchenRequestStation.Modify();
        end;
    end;

    local procedure UpdateRequestStatusesFromStation(KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station"; RefreshOrderStatus: Boolean)
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        KitchenRequest.Get(KitchenRequestStation."Request No.");
        UpdateRequestStatuses(KitchenRequest, RefreshOrderStatus);
    end;

    local procedure UpdateRequestStatuses(var KitchenRequest: Record "NPR NPRE Kitchen Request"; RefreshOrderStatus: Boolean)
    begin
        UpdateRequestProdStatus(KitchenRequest);
        UpdateRequestLineStatus(KitchenRequest);
        KitchenRequest.Modify();

        if RefreshOrderStatus then
            UpdateOrderStatus(KitchenRequest."Order ID");
    end;

    local procedure UpdateRequestProdStatus(var KitchenRequest: Record "NPR NPRE Kitchen Request")
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        ProductionStatusUpdated: Boolean;
    begin
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        if not KitchenRequestStation.FindSet() then
            exit;

        ProductionStatusUpdated := false;
        repeat
            if KitchenRequestStation."On Hold" then begin
                KitchenRequest."Production Status" := KitchenRequest."Production Status"::"On Hold";
                exit;
            end;

            if not ProductionStatusUpdated or (KitchenRequest."Production Status" = KitchenRequest."Production Status"::Cancelled) then begin
                KitchenRequest."Production Status" := KitchenRequestStation."Production Status";
                ProductionStatusUpdated := true;
            end else
                case true of
                    (KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::"Not Started") and
                        (KitchenRequest."Production Status" = KitchenRequest."Production Status"::Finished),
                    (KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::Started),
                    (KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::Finished) and
                        (KitchenRequest."Production Status" = KitchenRequest."Production Status"::"Not Started"):
                        begin
                            KitchenRequest."Production Status" := KitchenRequest."Production Status"::Started;
                        end;
                end;
        until KitchenRequestStation.Next() = 0;
    end;

    local procedure UpdateRequestLineStatus(var KitchenRequest: Record "NPR NPRE Kitchen Request")
    var
        ParentKitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        case true of
            (KitchenRequest."Line Status" = KitchenRequest."Line Status"::"Serving Requested") and (KitchenRequest."Production Status" = KitchenRequest."Production Status"::Finished):
                begin
                    if KitchenRequest."Parent Request No." <> 0 then begin
                        ParentKitchenRequest.Get(KitchenRequest."Parent Request No.");
                        if ParentKitchenRequest."Line Status" <> ParentKitchenRequest."Line Status"::"Ready for Serving" then
                            exit;
                    end;
                    KitchenRequest."Line Status" := KitchenRequest."Line Status"::"Ready for Serving";
                    UpdateChildRequestLineStatus(KitchenRequest);
                end;

            (KitchenRequest."Line Status" = KitchenRequest."Line Status"::"Ready for Serving") and
            not (KitchenRequest."Production Status" in [KitchenRequest."Production Status"::Finished, KitchenRequest."Production Status"::Cancelled]):
                begin
                    if KitchenRequest."Serving Requested Date-Time" <> 0DT then
                        KitchenRequest."Line Status" := KitchenRequest."Line Status"::"Serving Requested"
                    else
                        KitchenRequest."Line Status" := KitchenRequest."Line Status"::Planned;
                    UpdateChildRequestLineStatus(KitchenRequest);
                end;
        end;
    end;

    local procedure UpdateChildRequestLineStatus(KitchenRequest: Record "NPR NPRE Kitchen Request")
    var
        ChildKitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        ChildKitchenRequest.SetRange("Parent Request No.", KitchenRequest."Request No.");
        if KitchenRequest."Line Status" = KitchenRequest."Line Status"::"Ready for Serving" then
            ChildKitchenRequest.SetRange("Line Status", ChildKitchenRequest."Line Status"::"Serving Requested", ChildKitchenRequest."Line Status"::Planned)
        else
            ChildKitchenRequest.SetRange("Line Status", ChildKitchenRequest."Line Status"::"Ready for Serving");
        if not ChildKitchenRequest.IsEmpty() then
            ChildKitchenRequest.ModifyAll("Line Status", KitchenRequest."Line Status");
    end;

    local procedure UpdateOrderStatus(OrderID: BigInteger)
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        xKitchenOrder: Record "NPR NPRE Kitchen Order";
    begin
        KitchenOrder.Get(OrderID);
        xKitchenOrder := KitchenOrder;
        UpdateOrderStatus(KitchenOrder);
        KitchenOrder.Modify();

        if KitchenOrder."Order Status" = KitchenOrder."Order Status"::"Ready for Serving" then
            if xKitchenOrder."Order Status" <> xKitchenOrder."Order Status"::"Ready for Serving" then
                NotificationHandler.CreateOrderNotifications(KitchenOrder, "NPR NPRE Notification Trigger"::KDS_ORDER_READY_FOR_SERVING, 0DT);
    end;

    internal procedure UpdateOrderStatus(var KitchenOrder: Record "NPR NPRE Kitchen Order")
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        OrderIsReadyForServingOn: Enum "NPR NPRE Order Ready Serving";
    begin
        SetupProxy.SetRestaurant(KitchenOrder."Restaurant Code");
        OrderIsReadyForServingOn := SetupProxy.KitchenOrderIsReadyForServingOn();

        KitchenOrder."Order Status" := KitchenOrder."Order Status"::Cancelled;

        KitchenRequest.SetCurrentKey("Order ID");
        KitchenRequest.SetRange("Order ID", KitchenOrder."Order ID");
        KitchenRequest.SetFilter("Line Status", '<>%1', KitchenRequest."Line Status"::Cancelled);
        if KitchenRequest.FindSet() then
            repeat
                case KitchenRequest."Line Status" of
                    KitchenRequest."Line Status"::"Ready for Serving":
                        begin
                            if OrderIsReadyForServingOn = OrderIsReadyForServingOn::"Any Request" then begin
                                KitchenOrder."Order Status" := KitchenOrder."Order Status"::"Ready for Serving";
                                exit;
                            end;
                            if KitchenOrder."Order Status" In [KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status"::Cancelled] then
                                KitchenOrder."Order Status" := KitchenOrder."Order Status"::"Ready for Serving";
                        end;

                    KitchenRequest."Line Status"::"Serving Requested",
                    KitchenRequest."Line Status"::Planned:
                        case KitchenRequest."Production Status" of
                            KitchenRequest."Production Status"::Started:
                                begin
                                    KitchenOrder."Order Status" := KitchenOrder."Order Status"::"In-Production";
                                    if OrderIsReadyForServingOn = OrderIsReadyForServingOn::"All Requests" then
                                        exit;
                                end;
                            KitchenRequest."Production Status"::Finished:
                                begin
                                    if OrderIsReadyForServingOn = OrderIsReadyForServingOn::"Any Request" then begin
                                        KitchenOrder."Order Status" := KitchenOrder."Order Status"::"Ready for Serving";
                                        exit;
                                    end;
                                    if KitchenOrder."Order Status" In [KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status"::Cancelled] then
                                        KitchenOrder."Order Status" := KitchenOrder."Order Status"::"Ready for Serving";
                                end;
                            else begin
                                if KitchenOrder."Order Status" In
                                    [KitchenOrder."Order Status"::"Ready for Serving",
                                     KitchenOrder."Order Status"::Planned,
                                     KitchenOrder."Order Status"::Finished,
                                     KitchenOrder."Order Status"::Cancelled]
                                then
                                    if KitchenRequest."Line Status" = KitchenRequest."Line Status"::"Serving Requested" then
                                        KitchenOrder."Order Status" := KitchenOrder."Order Status"::Released
                                    else
                                        KitchenOrder."Order Status" := KitchenOrder."Order Status"::Planned;
                            end;
                        end;

                    KitchenRequest."Line Status"::Served:
                        if KitchenOrder."Order Status" = KitchenOrder."Order Status"::Cancelled then
                            KitchenOrder."Order Status" := KitchenOrder."Order Status"::Finished;
                end;
            until KitchenRequest.Next() = 0;
    end;

    procedure SetRequestLinesAsServed(var KitchenRequest: Record "NPR NPRE Kitchen Request")
    var
        KitchenRequest2: Record "NPR NPRE Kitchen Request";
    begin
        if KitchenRequest.IsEmpty() then
            exit;

        CheckLineStatusesBeforeServing(KitchenRequest);

        if KitchenRequest.FindSet() then
            repeat
                KitchenRequest2 := KitchenRequest;
                SetRequestLineAsServed(KitchenRequest2);
            until KitchenRequest.Next() = 0;
    end;

    procedure SetRequestLineAsServed(var KitchenRequest: Record "NPR NPRE Kitchen Request")
    begin
        SetChildRequestLinesAsServed(KitchenRequest);
        if KitchenRequest."Line Status" in [KitchenRequest."Line Status"::Served, KitchenRequest."Line Status"::Cancelled] then
            KitchenRequest.FieldError("Line Status");
        KitchenRequest."Line Status" := KitchenRequest."Line Status"::Served;
        KitchenRequest.Modify();

        CancelKitchenStationRequests(KitchenRequest, true);
        UpdateOrderStatus(KitchenRequest."Order ID");
        AttemptToCloseSourceDocument(KitchenRequest);
    end;

    local procedure SetChildRequestLinesAsServed(KitchenRequest: Record "NPR NPRE Kitchen Request")
    var
        ChildKitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        ChildKitchenRequest.SetRange("Parent Request No.", KitchenRequest."Request No.");
        ChildKitchenRequest.SetRange("Line Status", ChildKitchenRequest."Line Status"::"Ready for Serving", ChildKitchenRequest."Line Status"::Planned);
        if ChildKitchenRequest.FindSet(true) then
            repeat
                SetRequestLineAsServed(ChildKitchenRequest);
            until ChildKitchenRequest.Next() = 0;
    end;

    procedure RevokeServingForRequestLine(var KitchenRequest: Record "NPR NPRE Kitchen Request")
    begin
        RevokeServingForChildRequestLines(KitchenRequest);
        KitchenRequest.TestField("Line Status", KitchenRequest."Line Status"::Served);
        KitchenRequest."Line Status" := KitchenRequest."Line Status"::"Ready for Serving";
        KitchenRequest.Modify();

        UpdateOrderStatus(KitchenRequest."Order ID");
        ReopenSourceDocument(KitchenRequest);
    end;

    local procedure RevokeServingForChildRequestLines(KitchenRequest: Record "NPR NPRE Kitchen Request")
    var
        ChildKitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        ChildKitchenRequest.SetRange("Parent Request No.", KitchenRequest."Request No.");
        ChildKitchenRequest.SetRange("Line Status", ChildKitchenRequest."Line Status"::Served);
        if ChildKitchenRequest.FindSet(true) then
            repeat
                RevokeServingForRequestLine(ChildKitchenRequest);
            until ChildKitchenRequest.Next() = 0;
    end;

    local procedure CheckLineStatusesBeforeServing(var KitchenRequest: Record "NPR NPRE Kitchen Request")
    var
        KitchenRequest2: Record "NPR NPRE Kitchen Request";
        AlreadyServedOrCancelledMsg: Label 'Served or cancelled kitchen requests have been skipped, as those cannot be served again.';
        ChildReqSkippedMsg: Label 'Child kitchen requests have been skipped, as those must be served together with their parent request.';
        ConfirmServingQst: Label 'One or more selected serving requests are not in Ready for Serving status. Are you sure want to mark them as served anyway?';
    begin
        KitchenRequest2.Copy(KitchenRequest);
        KitchenRequest2.FilterGroup(2);
        if not _HideValidationDialog and GuiAllowed() then begin
            KitchenRequest2.SetRange("Line Status", KitchenRequest2."Line Status"::Served, KitchenRequest2."Line Status"::Cancelled);
            if not KitchenRequest2.IsEmpty() then
                Message(AlreadyServedOrCancelledMsg);

            KitchenRequest2.SetRange("Line Status", KitchenRequest2."Line Status"::"Serving Requested", KitchenRequest2."Line Status"::Planned);
            if not KitchenRequest2.IsEmpty() then
                if not Confirm(ConfirmServingQst, false) then
                    Error('');

            KitchenRequest2.SetRange("Line Status", KitchenRequest2."Line Status"::"Ready for Serving", KitchenRequest2."Line Status"::Planned);
            KitchenRequest2.SetFilter("Parent Request No.", '<>%1', 0);
            if not KitchenRequest2.IsEmpty() then
                Message(ChildReqSkippedMsg);
        end else
            KitchenRequest2.SetRange("Line Status", KitchenRequest2."Line Status"::"Ready for Serving", KitchenRequest2."Line Status"::Planned);
        KitchenRequest2.SetRange("Parent Request No.", 0);
        KitchenRequest2.FilterGroup(0);
        KitchenRequest.Copy(KitchenRequest2);
    end;

    procedure KDSAvailable(): Boolean
    begin
        exit(true);
    end;

    procedure SplitWaiterPadLineKitchenReqSourceLinks(FromWaiterPadLine: Record "NPR NPRE Waiter Pad Line"; NewWaiterPad: Record "NPR NPRE Waiter Pad"; NewWaiterPadLine: Record "NPR NPRE Waiter Pad Line"; FullLineTransfer: Boolean)
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
        NewKitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
        RemainingQtyToMove: Decimal;
    begin
        NewWaiterPad.CalcFields("Current Seating FF");
        FilterKitchenReqSourceLinks(KitchenReqSourceLink."Source Document Type"::"Waiter Pad", 0, FromWaiterPadLine."Waiter Pad No.", FromWaiterPadLine."Line No.", KitchenReqSourceLink);
        KitchenReqSourceLink.SetCurrentKey(
            "Source Document Type", "Source Document Subtype", "Source Document No.", "Source Document Line No.", "Serving Step", "Request No.");
        if KitchenReqSourceLink.FindSet() then
            repeat
                if FullLineTransfer then begin
                    NewKitchenReqSourceLink := KitchenReqSourceLink;
                    NewKitchenReqSourceLink."Source Document No." := NewWaiterPadLine."Waiter Pad No.";
                    NewKitchenReqSourceLink."Source Document Line No." := NewWaiterPadLine."Line No.";
                    NewKitchenReqSourceLink."Seating Code" := NewWaiterPad."Current Seating FF";
                    NewKitchenReqSourceLink."Assigned Waiter Code" := NewWaiterPad."Assigned Waiter Code";
                    NewKitchenReqSourceLink.Modify();
                end else begin
                    KitchenReqSourceLink.SetRange("Serving Step", KitchenReqSourceLink."Serving Step");
                    RemainingQtyToMove := NewWaiterPadLine.Quantity;
                    repeat
                        NewKitchenReqSourceLink := KitchenReqSourceLink;
                        KitchenReqSourceLink.SetRange("Request No.", KitchenReqSourceLink."Request No.");
                        KitchenReqSourceLink.CalcSums(Quantity);

                        if KitchenReqSourceLink.Quantity > 0 then begin
                            if RemainingQtyToMove > KitchenReqSourceLink.Quantity then
                                NewKitchenReqSourceLink.Validate(Quantity, -NewKitchenReqSourceLink.Quantity)
                            else
                                NewKitchenReqSourceLink.Validate(Quantity, -RemainingQtyToMove);
                            RemainingQtyToMove := RemainingQtyToMove + NewKitchenReqSourceLink.Quantity;
                            NewKitchenReqSourceLink.Context := NewKitchenReqSourceLink.Context::"Line Splitting";
                            NewKitchenReqSourceLink."Entry No." := 0;
                            NewKitchenReqSourceLink.Insert();

                            NewKitchenReqSourceLink."Source Document No." := NewWaiterPadLine."Waiter Pad No.";
                            NewKitchenReqSourceLink."Source Document Line No." := NewWaiterPadLine."Line No.";
                            NewKitchenReqSourceLink."Seating Code" := NewWaiterPad."Current Seating FF";
                            NewKitchenReqSourceLink."Assigned Waiter Code" := NewWaiterPad."Assigned Waiter Code";
                            NewKitchenReqSourceLink.Quantity := -NewKitchenReqSourceLink.Quantity;
                            NewKitchenReqSourceLink."Quantity (Base)" := -NewKitchenReqSourceLink."Quantity (Base)";
                            NewKitchenReqSourceLink."Entry No." := 0;
                            NewKitchenReqSourceLink.Insert();
                        end;

                        KitchenReqSourceLink.FindLast();
                        KitchenReqSourceLink.SetRange("Request No.");
                    until (KitchenReqSourceLink.Next() = 0) or (RemainingQtyToMove = 0);
                    KitchenReqSourceLink.FindLast();
                    KitchenReqSourceLink.SetRange("Serving Step");
                end;
            until KitchenReqSourceLink.Next() = 0;
    end;

    procedure CancelKitchenOrder(var KitchenOrder: Record "NPR NPRE Kitchen Order")
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequest2: Record "NPR NPRE Kitchen Request";
    begin
        KitchenRequest.SetCurrentKey("Order ID");
        KitchenRequest.SetRange("Order ID", KitchenOrder."Order ID");
        if KitchenRequest.FindSet() then
            repeat
                KitchenRequest2 := KitchenRequest;
                CancelKitchenRequest(KitchenRequest2);
            until KitchenRequest.Next() = 0;

        UpdateOrderStatus(KitchenOrder);
        KitchenOrder.Modify();
    end;

    procedure CancelKitchenRequest(var KitchenRequest: Record "NPR NPRE Kitchen Request")
    begin
        if not (KitchenRequest."Line Status" in [KitchenRequest."Line Status"::Served, KitchenRequest."Line Status"::Cancelled]) then begin
            KitchenRequest."Line Status" := KitchenRequest."Line Status"::Cancelled;
            KitchenRequest.Modify();
        end;

        CancelKitchenStationRequests(KitchenRequest, false);
    end;

    procedure CancelKitchenStationRequests(var KitchenRequest: Record "NPR NPRE Kitchen Request"; CalledByServing: Boolean)
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        KitchenRequestStation2: Record "NPR NPRE Kitchen Req. Station";
    begin
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequest.CopyFilter("Kitchen Station Filter", KitchenRequestStation."Kitchen Station");
        if KitchenRequestStation.FindSet() then
            repeat
                KitchenRequestStation2 := KitchenRequestStation;
                CancelKitchenStationRequest(KitchenRequest, KitchenRequestStation2, CalledByServing);
            until KitchenRequestStation.Next() = 0;
    end;

    procedure CancelKitchenStationRequest(KitchenRequest: Record "NPR NPRE Kitchen Request"; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station"; CalledByServing: Boolean)
    var
        HandleAction: Enum "NPR NPRE Req.Handl.on Serving";
    begin
        if KitchenRequestStation."Production Status" in [KitchenRequestStation."Production Status"::Finished, KitchenRequestStation."Production Status"::Cancelled] then
            exit;

        if CalledByServing then begin
            SetupProxy.SetRestaurant(KitchenRequest."Restaurant Code");
            HandleAction := SetupProxy.StationReqHandlingOnServing();
            case true of
                (HandleAction = HandleAction::"Finish All"),
                (HandleAction in [HandleAction::"Finish Started", HandleAction::"Finish Started/Cancel Not Started"]) and
                (KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::Started):
                    SetKitchenRequestStationFinished(KitchenRequestStation);

                (HandleAction = HandleAction::"Cancel All Unfinished"),
                (HandleAction = HandleAction::"Finish Started/Cancel Not Started") and
                (KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::"Not Started"):
                    SetKitchenRequestStationCancelled(KitchenRequestStation);
            end;
        end else
            SetKitchenRequestStationCancelled(KitchenRequestStation);
    end;

    local procedure SetKitchenRequestStationFinished(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        KitchenRequestStation."End Date-Time" := CurrentDateTime();
        KitchenRequestStation."On Hold" := false;
        KitchenRequestStation."Production Status" := KitchenRequestStation."Production Status"::Finished;
        KitchenRequestStation.Modify();
        ForwardKitchenStationRequestStatuses(KitchenRequestStation, 0);
        UpdateRequestStatusesFromStation(KitchenRequestStation, true);
    end;

    local procedure SetKitchenRequestStationCancelled(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        KitchenRequestStation."Production Status" := KitchenRequestStation."Production Status"::Cancelled;
        KitchenRequestStation.Modify();
        ForwardKitchenStationRequestStatuses(KitchenRequestStation, 0);
        UpdateRequestStatusesFromStation(KitchenRequestStation, false);
    end;

    procedure SetKitchenOrderOnHold(var KitchenOrder: Record "NPR NPRE Kitchen Order"; NewOnHold: Boolean)
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        KitchenRequestStation2: Record "NPR NPRE Kitchen Req. Station";
    begin
        if KitchenOrder."On Hold" = NewOnHold then
            exit;

        KitchenRequest.SetCurrentKey("Order ID");
        KitchenRequest.SetRange("Order ID", KitchenOrder."Order ID");
        if KitchenRequest.FindSet() then
            repeat
                KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
                KitchenRequestStation.SetRange("On Hold", not NewOnHold);
                KitchenRequestStation.SetRange("Production Status", KitchenRequestStation."Production Status"::"Not Started", KitchenRequestStation."Production Status"::Started);
                if KitchenRequestStation.FindSet() then
                    repeat
                        KitchenRequestStation2 := KitchenRequestStation;
                        SetKitchenRequestStationOnHold(KitchenRequestStation2, NewOnHold, false);
                    until KitchenRequestStation.Next() = 0;
            until KitchenRequest.Next() = 0;

        KitchenOrder."On Hold" := NewOnHold;
        UpdateOrderStatus(KitchenOrder);
        KitchenOrder.Modify();
    end;

    procedure SetKitchenRequestStationOnHold(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station"; NewOnHold: Boolean; RefreshOrderStatus: Boolean)
    begin
        if KitchenRequestStation."On Hold" = NewOnHold then
            exit;
        if not (KitchenRequestStation."Production Status" in
            [KitchenRequestStation."Production Status"::"Not Started",
             KitchenRequestStation."Production Status"::Pending,
             KitchenRequestStation."Production Status"::Started])
        then
            exit;

        KitchenRequestStation."On Hold" := NewOnHold;
        KitchenRequestStation.Modify();
        UpdateRequestStatusesFromStation(KitchenRequestStation, RefreshOrderStatus);
    end;

    local procedure AttemptToCloseSourceDocument(KitchenRequest: Record "NPR NPRE Kitchen Request")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        KitchReqSrcbyDoc: Query "NPR NPRE Kitch.Req.Src. by Doc";
    begin
        KitchReqSrcbyDoc.SetRange(Request_No_, KitchenRequest."Request No.");
        KitchReqSrcbyDoc.SetFilter(QuantityBase, '<>%1', 0);
        if not KitchReqSrcbyDoc.Open() then
            exit;
        while KitchReqSrcbyDoc.Read() do
            case KitchReqSrcbyDoc.Source_Document_Type of
                KitchReqSrcbyDoc.Source_Document_Type::"Waiter Pad":
                    if WaiterPad.Get(KitchReqSrcbyDoc.Source_Document_No_) then
                        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");
            end;
        KitchReqSrcbyDoc.Close();
    end;

    local procedure ReopenSourceDocument(KitchenRequest: Record "NPR NPRE Kitchen Request")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        KitchReqSrcbyDoc: Query "NPR NPRE Kitch.Req.Src. by Doc";
    begin
        KitchReqSrcbyDoc.SetRange(Request_No_, KitchenRequest."Request No.");
        KitchReqSrcbyDoc.SetFilter(QuantityBase, '<>%1', 0);
        if not KitchReqSrcbyDoc.Open() then
            exit;
        while KitchReqSrcbyDoc.Read() do
            case KitchReqSrcbyDoc.Source_Document_Type of
                KitchReqSrcbyDoc.Source_Document_Type::"Waiter Pad":
                    if WaiterPad.Get(KitchReqSrcbyDoc.Source_Document_No_) then
                        WaiterPadMgt.ReopenWaiterPad(WaiterPad);
            end;
        KitchReqSrcbyDoc.Close();
    end;

    procedure UpdateKitchenReqSourceSeating(SourceDocType: Enum "NPR NPRE K.Req.Source Doc.Type"; SourceDocSubtype: Integer; SourceDocNo: Code[20]; SourceDocLinNo: Integer; NewSeatingCode: Code[20])
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        FilterKitchenReqSourceLinks(SourceDocType, SourceDocSubtype, SourceDocNo, SourceDocLinNo, KitchenReqSourceLink);
        if KitchenReqSourceLink.IsEmpty() then
            exit;
        KitchenReqSourceLink.ModifyAll("Seating Code", NewSeatingCode);
    end;

    procedure UpdateKitchenReqSourceWaiter(SourceDocType: Enum "NPR NPRE K.Req.Source Doc.Type"; SourceDocSubtype: Integer; SourceDocNo: Code[20]; SourceDocLinNo: Integer; NewWaiterCode: Code[20])
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        FilterKitchenReqSourceLinks(SourceDocType, SourceDocSubtype, SourceDocNo, SourceDocLinNo, KitchenReqSourceLink);
        if KitchenReqSourceLink.IsEmpty() then
            exit;
        KitchenReqSourceLink.ModifyAll("Assigned Waiter Code", NewWaiterCode);
    end;

    local procedure FilterKitchenReqSourceLinks(SourceDocType: Enum "NPR NPRE K.Req.Source Doc.Type"; SourceDocSubtype: Integer; SourceDocNo: Code[20]; SourceDocLinNo: Integer; var KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link")
    begin
        KitchenReqSourceLink.Reset();
        KitchenReqSourceLink.SetRange("Source Document Type", SourceDocType);
        KitchenReqSourceLink.SetRange("Source Document Subtype", SourceDocSubtype);
        KitchenReqSourceLink.SetRange("Source Document No.", SourceDocNo);
        if SourceDocLinNo <> 0 then
            KitchenReqSourceLink.SetRange("Source Document Line No.", SourceDocLinNo);
    end;

    procedure EnableKitchenOrderRetentionPolicy()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if not RetentionPolicySetup.WritePermission() then
            exit;
        if not RetentionPolicySetup.Get(Database::"NPR NPRE Kitchen Order") or RetentionPolicySetup.Enabled then
            exit;
        RetentionPolicySetup.Validate(Enabled, true);
        RetentionPolicySetup.Modify(true);
    end;

    procedure RegisterKDSWebservice()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
        ServiceNameTok: Label 'KDS', Locked = true, MaxLength = 240;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Codeunit, Codeunit::"NPR KDS Frontend Assistant", ServiceNameTok, true);
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        _HideValidationDialog := NewHideValidationDialog;
    end;

    procedure GetHideValidationDialog(): Boolean
    begin
        exit(_HideValidationDialog);
    end;
}
