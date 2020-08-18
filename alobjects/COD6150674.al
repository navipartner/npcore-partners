codeunit 6150674 "NPRE Kitchen Order Mgt."
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200420 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale


    trigger OnRun()
    begin
    end;

    var
        GlobalKitchenOrder: Record "NPRE Kitchen Order";
        SetupProxy: Codeunit "NPRE Restaurant Setup Proxy";
        AlreadyFinishedMsg: Label 'The production of the item has already been marked as finished. Are you sure you want to start over?';
        MustBeTempMsg: Label '%1: function call on a non-temporary variable. This is a programming bug, not a user error. Please contact system vendor.';
        RequestCancelledMsg: Label 'The kitchen request is cancelled. Are you sure you want to continue?';

    procedure SendWPLinesToKitchen(var WaiterPadLineIn: Record "NPRE Waiter Pad Line";FlowStatusCode: Code[10];PrintCategoryCode: Code[20];RequestType: Option "Order","Serving Request";SentDateTime: DateTime): Boolean
    var
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPRE Restaurant Print";
        Success: Boolean;
    begin
        if not (RequestType in [RequestType::Order, RequestType::"Serving Request"]) then
          exit(false);

        if SentDateTime = 0DT then
          SentDateTime := CurrentDateTime;

        WaiterPadLine.Copy(WaiterPadLineIn);
        if WaiterPadLine.FindSet then
          repeat
            if SendWPLineToKitchen(WaiterPadLine, FlowStatusCode, PrintCategoryCode, RequestType, SentDateTime) then begin
              RestaurantPrint.LogWaiterPadLinePrint(WaiterPadLine, RequestType, FlowStatusCode, PrintCategoryCode, SentDateTime, 1);
              Success := true;
            end;
          until WaiterPadLine.Next = 0;

        exit(Success);
    end;

    local procedure SendWPLineToKitchen(WaiterPadLine: Record "NPRE Waiter Pad Line";FlowStatusCode: Code[10];PrintCategoryCode: Code[20];RequestType: Option "Order","Serving Request";SentDateTime: DateTime): Boolean
    var
        KitchenRequest: Record "NPRE Kitchen Request";
        KitchenRequest2: Record "NPRE Kitchen Request";
        KitchenRequestParam: Record "NPRE Kitchen Request";
        KitchenReqSourceParam: Record "NPRE Kitchen Req. Source Link";
        KitchenStation: Record "NPRE Kitchen Station";
        KitchenStationBuffer: Record "NPRE Kitchen Station Selection" temporary;
    begin
        if not FindApplicableWPLineKitchenStations(KitchenStationBuffer, WaiterPadLine, FlowStatusCode, PrintCategoryCode) then
          exit(false);

        KitchenRequestParam.InitFromWaiterPadLine(WaiterPadLine);
        KitchenRequestParam."Restaurant Code" := KitchenStationBuffer."Restaurant Code";
        KitchenRequestParam."Serving Step" := FlowStatusCode;
        KitchenRequestParam."Created Date-Time" := SentDateTime;
        InitKitchenReqSourceFromWaiterPadLine(
          KitchenReqSourceParam, WaiterPadLine, KitchenStationBuffer."Restaurant Code", KitchenRequestParam."Serving Step", KitchenRequestParam."Created Date-Time");

        FindKitchenRequests(KitchenRequest, KitchenReqSourceParam);
        HandleQtyChange(KitchenRequest, KitchenRequestParam, KitchenReqSourceParam);

        if KitchenRequest.FindSet then
          repeat
            KitchenRequest2 := KitchenRequest;
            if RequestType = RequestType::"Serving Request" then begin
              KitchenRequest2."Serving Requested Date-Time" := SentDateTime;
              if KitchenRequest2."Line Status" = KitchenRequest2."Line Status"::Planned then
                KitchenRequest2."Line Status" := KitchenRequest2."Line Status"::"Serving Requested";
              UpdateRequestLineStatus(KitchenRequest2);
              KitchenRequest2.Modify;
            end;

            KitchenStationBuffer.FindSet;
            repeat
              KitchenStation.Get(KitchenStationBuffer."Production Restaurant Code", KitchenStationBuffer."Kitchen Station");
              CreateKitchenStationRequest(KitchenRequest2, KitchenStation);
            until KitchenStationBuffer.Next = 0;

            UpdateOrderStatus(KitchenRequest2."Order ID");
          until KitchenRequest.Next = 0;
        exit(true);
    end;

    procedure FindKitchenRequests(var KitchenRequest: Record "NPRE Kitchen Request";KitchenReqSourceParam: Record "NPRE Kitchen Req. Source Link")
    var
        KitchenReqWSourceQry: Query "NPRE Kitchen Request w. Source";
    begin
        KitchenRequest.Reset;
        KitchenRequest.SetAutoCalcFields(Quantity, "Quantity (Base)");

        KitchenReqWSourceQry.SetRange(Source_Document_Type, KitchenReqSourceParam."Source Document Type");
        KitchenReqWSourceQry.SetRange(Source_Document_Subtype, KitchenReqSourceParam."Source Document Subtype");
        KitchenReqWSourceQry.SetRange(Source_Document_No, KitchenReqSourceParam."Source Document No.");
        KitchenReqWSourceQry.SetRange(Source_Document_Line_No, KitchenReqSourceParam."Source Document Line No.");
        KitchenReqWSourceQry.SetRange(Restaurant_Code, KitchenReqSourceParam."Restaurant Code");
        KitchenReqWSourceQry.SetRange(Serving_Step, KitchenReqSourceParam."Serving Step");
        KitchenReqWSourceQry.SetFilter(Line_Status, '<>%1', KitchenRequest."Line Status"::Cancelled);
        KitchenReqWSourceQry.Open;
        while KitchenReqWSourceQry.Read do begin
          KitchenRequest.Get(KitchenReqWSourceQry.Request_No);
          KitchenRequest.Mark(true);
        end;
        KitchenRequest.MarkedOnly(true);
    end;

    local procedure FindKitchenOrderId(KitchenRequest: Record "NPRE Kitchen Request";KitchenReqSourceLink: Record "NPRE Kitchen Req. Source Link"): BigInteger
    var
        Restaurant: Record "NPRE Restaurant";
        KitchenReqWSourceQry: Query "NPRE Kitchen Request w. Source";
    begin
        if GlobalKitchenOrder."Order ID" = 0 then begin
          SetupProxy.SetRestaurant(KitchenRequest."Restaurant Code");
          if SetupProxy.OrderIDAssignmentMethod = Restaurant."Order ID Assign. Method"::"Same for Source Document" then begin
            KitchenReqWSourceQry.SetRange(Source_Document_Type, KitchenReqSourceLink."Source Document Type");
            KitchenReqWSourceQry.SetRange(Source_Document_Subtype, KitchenReqSourceLink."Source Document Subtype");
            KitchenReqWSourceQry.SetRange(Source_Document_No, KitchenReqSourceLink."Source Document No.");
            KitchenReqWSourceQry.SetRange(Order_Status, GlobalKitchenOrder.Status::Active, GlobalKitchenOrder.Status::Planned);
            KitchenReqWSourceQry.SetFilter(Order_ID, '<>%1', 0);
            KitchenReqWSourceQry.Open;
            if KitchenReqWSourceQry.Read then
              GlobalKitchenOrder.Get(KitchenReqWSourceQry.Order_ID);
          end;

          if GlobalKitchenOrder."Order ID" = 0 then begin
            GlobalKitchenOrder.Init;
            GlobalKitchenOrder.Status := GlobalKitchenOrder.Status::Planned;
            GlobalKitchenOrder.Priority := DefaultPriority(KitchenRequest);
            GlobalKitchenOrder."Created Date-Time" := KitchenRequest."Created Date-Time";
            GlobalKitchenOrder."Restaurant Code" := KitchenRequest."Restaurant Code";
            GlobalKitchenOrder.Insert;
          end;
        end;
        exit(GlobalKitchenOrder."Order ID");
    end;

    local procedure HandleQtyChange(var KitchenRequest: Record "NPRE Kitchen Request";KitchenRequestParam: Record "NPRE Kitchen Request";KitchenReqSourceParam: Record "NPRE Kitchen Req. Source Link")
    begin
        KitchenRequest.FilterGroup(2);
        KitchenRequest.SetFilter("Line Status", '<>%1', KitchenRequest."Line Status"::Cancelled);
        KitchenRequest.SetFilter("Production Status", '<>%1', KitchenRequest."Production Status"::Cancelled);
        KitchenRequest.FilterGroup(0);

        if KitchenRequest.FindSet then
          repeat
            KitchenReqSourceParam.Quantity := KitchenReqSourceParam.Quantity - KitchenRequest.Quantity;
            KitchenReqSourceParam."Quantity (Base)" := KitchenReqSourceParam."Quantity (Base)" - KitchenRequest."Quantity (Base)";
          until KitchenRequest.Next = 0;
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

    local procedure AllocateQtyChangeToExistingKitchenRequests(var KitchenRequest: Record "NPRE Kitchen Request";var KitchenReqSourceParam: Record "NPRE Kitchen Req. Source Link")
    var
        xKitchenReqSourceParam: Record "NPRE Kitchen Req. Source Link";
    begin
        if KitchenReqSourceParam.Quantity = 0 then
          exit;

        if KitchenRequest.FindSet then
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
          until (KitchenRequest.Next = 0) or (KitchenReqSourceParam.Quantity = 0);
    end;

    local procedure SetQtyChanged(KitchenRequest: Record "NPRE Kitchen Request")
    var
        KitchenRequestStation: Record "NPRE Kitchen Request Station";
    begin
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequestStation.ModifyAll("Qty. Change Not Accepted", true);
    end;

    procedure InitKitchenReqSourceFromWaiterPadLine(var KitchenReqSource: Record "NPRE Kitchen Req. Source Link";WaiterPadLine: Record "NPRE Waiter Pad Line";RestaurantCode: Code[20];ServingStep: Code[10];SentDateTime: DateTime)
    begin
        KitchenReqSource.Init;
        KitchenReqSource.InitSource(WaiterPadLine.RecordId);
        KitchenReqSource."Restaurant Code" := RestaurantCode;
        KitchenReqSource."Serving Step" := ServingStep;
        KitchenReqSource."Created Date-Time" := SentDateTime;
        KitchenReqSource.Quantity := WaiterPadLine.Quantity;
        KitchenReqSource."Quantity (Base)" := WaiterPadLine."Quantity (Base)";
    end;

    local procedure CreateKitchenRequest(var KitchenRequest: Record "NPRE Kitchen Request";KitchenRequestParam: Record "NPRE Kitchen Request";KitchenReqSourceParam: Record "NPRE Kitchen Req. Source Link")
    begin
        KitchenRequest := KitchenRequestParam;
        KitchenRequest."Line Status" := KitchenRequest."Line Status"::Planned;
        KitchenRequest."Production Status" := KitchenRequest."Production Status"::"Not Started";
        KitchenRequest."Order ID" := FindKitchenOrderId(KitchenRequest, KitchenReqSourceParam);
        KitchenRequest.Priority := GlobalKitchenOrder.Priority;
        KitchenRequest."Request No." := 0;
        KitchenRequest.Insert(true);

        CreateKitchenRequestSourceLink(KitchenRequest, KitchenReqSourceParam);
    end;

    local procedure CreateKitchenRequestSourceLink(var KitchenRequest: Record "NPRE Kitchen Request";KitchenReqSourceParam: Record "NPRE Kitchen Req. Source Link")
    var
        KitchenReqSourceLink: Record "NPRE Kitchen Req. Source Link";
    begin
        KitchenReqSourceLink := KitchenReqSourceParam;
        KitchenReqSourceLink."Request No." := KitchenRequest."Request No.";
        KitchenReqSourceLink."Entry No." := 0;
        KitchenReqSourceLink.Insert;
    end;

    local procedure CreateKitchenStationRequest(KitchenRequest: Record "NPRE Kitchen Request";KitchenStation: Record "NPRE Kitchen Station")
    var
        KitchenOrdLineStation: Record "NPRE Kitchen Request Station";
    begin
        with KitchenOrdLineStation do begin
          SetRange("Request No.", KitchenRequest."Request No.");
          SetRange("Production Restaurant Code", KitchenStation."Restaurant Code");
          SetRange("Kitchen Station", KitchenStation.Code);
          SetFilter("Production Status", '<>%1', "Production Status"::Cancelled);
          if IsEmpty then begin
            Init;
            "Request No." := KitchenRequest."Request No.";
            "Line No." := KitchenRequest.GetNextStationReqLineNo();
            "Production Restaurant Code" := KitchenStation."Restaurant Code";
            "Kitchen Station" := KitchenStation.Code;
            "Production Status" := "Production Status"::"Not Started";
            "Order ID" := KitchenRequest."Order ID";
            Insert;
          end;
        end;
    end;

    procedure FindApplicableWPLineKitchenStations(var KitchenStationBuffer: Record "NPRE Kitchen Station Selection";WaiterPadLine: Record "NPRE Waiter Pad Line";FlowStatusCode: Code[10];PrintCategoryCode: Code[20]): Boolean
    var
        KitchenStationSelection: Record "NPRE Kitchen Station Selection";
        Seating: Record "NPRE Seating";
        SeatingLocation: Record "NPRE Seating Location";
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        if not KitchenStationBuffer.IsTemporary then
          Error(MustBeTempMsg,'CU6150674.FindKitchenStations');

        Clear(KitchenStationBuffer);
        KitchenStationBuffer.DeleteAll;

        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadLine."Waiter Pad No.");
        SeatingWaiterPadLink.SetFilter("Seating Code", '<>%1', '');
        if SeatingWaiterPadLink.IsEmpty then
          SeatingWaiterPadLink.SetRange("Seating Code");
        if SeatingWaiterPadLink.FindFirst then begin
          Seating.Get(SeatingWaiterPadLink."Seating Code");
          if not SeatingLocation.Get(Seating."Seating Location") then
            SeatingLocation.Init;

          KitchenStationSelection.Reset;
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
              if not KitchenStationBuffer.Find then
                KitchenStationBuffer.Insert;
            until KitchenStationSelection.Next = 0;
        end;

        exit(KitchenStationBuffer.FindSet);
    end;

    local procedure GetKitchenStationSelection(var KitchenStationSelection: Record "NPRE Kitchen Station Selection"): Boolean
    begin
        with KitchenStationSelection do begin
          SetRange("Restaurant Code", "Restaurant Code");
          SetRange("Seating Location", "Seating Location");
          SetRange("Serving Step", "Serving Step");
          SetRange("Print Category Code", "Print Category Code");
          if IsEmpty then begin
            SetRange("Seating Location", '');
            if IsEmpty then begin
              SetRange("Seating Location", "Seating Location");
              SetRange("Serving Step", '');
              if IsEmpty then begin
                SetRange("Seating Location", '');
                if IsEmpty then begin
                  SetRange("Seating Location", "Seating Location");
                  SetRange("Serving Step", "Serving Step");
                  SetRange("Print Category Code", '');
                  if IsEmpty then begin
                    SetRange("Seating Location", '');
                    if IsEmpty then begin
                      SetRange("Seating Location", "Seating Location");
                      SetRange("Serving Step", '');
                      if IsEmpty then begin
                        SetRange("Seating Location", '');
                        if IsEmpty and ("Restaurant Code" <> '') then begin
                          "Restaurant Code" := '';
                          exit(GetKitchenStationSelection(KitchenStationSelection));
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
        exit(KitchenStationSelection.FindSet);
    end;

    procedure DefaultPriority(KitchenRequest: Record "NPRE Kitchen Request"): Integer
    begin
        exit(100);
    end;

    procedure StartProduction(var KitchenRequestStation: Record "NPRE Kitchen Request Station")
    var
        KitchenRequest: Record "NPRE Kitchen Request";
    begin
        with KitchenRequestStation do begin
          if "Production Status" = "Production Status"::Started then
            exit;
          KitchenRequest.Get("Request No.");
          if KitchenRequest."Line Status" = KitchenRequest."Line Status"::Cancelled then
            if not Confirm(RequestCancelledMsg, false) then
              Error('');
          if "Production Status" = "Production Status"::Finished then
            if not Confirm(AlreadyFinishedMsg, true) then
              Error('');

          if "Start Date-Time" = 0DT then
            "Start Date-Time" := CurrentDateTime;
          "End Date-Time" := 0DT;
          "On Hold" := false;
          "Production Status" := "Production Status"::Started;
          Modify;
        end;
        UpdateRequestStatusesFromStation(KitchenRequestStation);
    end;

    procedure EndProduction(var KitchenRequestStation: Record "NPRE Kitchen Request Station")
    begin
        with KitchenRequestStation do begin
          if "Production Status" in ["Production Status"::"Not Started", "Production Status"::Finished, "Production Status"::Cancelled] then
            FieldError("Production Status");

          "End Date-Time" := CurrentDateTime;
          "On Hold" := false;
          "Production Status" := "Production Status"::Finished;
          Modify;
        end;
        UpdateRequestStatusesFromStation(KitchenRequestStation);
    end;

    procedure AcceptQtyChange(var KitchenRequestStation: Record "NPRE Kitchen Request Station")
    begin
        if KitchenRequestStation."Qty. Change Not Accepted" then begin
          KitchenRequestStation."Qty. Change Not Accepted" := false;
          KitchenRequestStation."Last Qty. Change Accepted" := CurrentDateTime;
          KitchenRequestStation.Modify;
        end;
    end;

    local procedure UpdateRequestStatusesFromStation(KitchenRequestStation: Record "NPRE Kitchen Request Station")
    var
        KitchenRequest: Record "NPRE Kitchen Request";
    begin
        KitchenRequest.Get(KitchenRequestStation."Request No.");
        UpdateRequestStatuses(KitchenRequest);
    end;

    local procedure UpdateRequestStatuses(var KitchenRequest: Record "NPRE Kitchen Request")
    begin
        UpdateRequestProdStatus(KitchenRequest);
        UpdateRequestLineStatus(KitchenRequest);
        KitchenRequest.Modify;

        UpdateOrderStatus(KitchenRequest."Order ID");
    end;

    local procedure UpdateRequestProdStatus(var KitchenRequest: Record "NPRE Kitchen Request")
    var
        KitchenRequestStation: Record "NPRE Kitchen Request Station";
    begin
        with KitchenRequest do begin
          KitchenRequestStation.SetRange("Request No.", "Request No.");
          if not KitchenRequestStation.FindSet then
            exit;

          "Production Status" := -1;
          repeat
            if KitchenRequestStation."On Hold" then begin
              "Production Status" := "Production Status"::"On Hold";
              exit;
            end;

            if "Production Status" in [-1, "Production Status"::Cancelled] then
              "Production Status" := KitchenRequestStation."Production Status"
            else
              case true of
                (KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::"Not Started") and
                  ("Production Status" = "Production Status"::Finished),
                (KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::Started),
                (KitchenRequestStation."Production Status" = KitchenRequestStation."Production Status"::Finished) and
                  ("Production Status" = "Production Status"::"Not Started"):
                begin
                  "Production Status" := "Production Status"::Started;
                end;
              end;
          until KitchenRequestStation.Next = 0;
        end;
    end;

    local procedure UpdateRequestLineStatus(var KitchenRequest: Record "NPRE Kitchen Request")
    begin
        with KitchenRequest do
          case true of
            ("Line Status" = "Line Status"::"Serving Requested") and ("Production Status" = "Production Status"::Finished):
              "Line Status" := "Line Status"::"Ready for Serving";

            ("Line Status" in ["Line Status"::"Ready for Serving", "Line Status"::Served]) and
            not ("Production Status" in ["Production Status"::Finished, "Production Status"::Cancelled]):
              if "Serving Requested Date-Time" <> 0DT then
                "Line Status" := "Line Status"::"Serving Requested"
              else
                "Line Status" := "Line Status"::Planned;
          end;
    end;

    local procedure UpdateOrderStatus(OrderID: BigInteger)
    var
        KitchenOrder: Record "NPRE Kitchen Order";
        KitchenRequest: Record "NPRE Kitchen Request";
    begin
        KitchenOrder.Get(OrderID);
        KitchenOrder.Status := KitchenOrder.Status::Cancelled;

        KitchenRequest.SetCurrentKey("Order ID");
        KitchenRequest.SetRange("Order ID", KitchenOrder."Order ID");
        KitchenRequest.SetFilter("Line Status", '<>%1', KitchenRequest."Line Status"::Cancelled);
        if KitchenRequest.FindSet then
          repeat
            case KitchenRequest."Line Status" of
              KitchenRequest."Line Status"::"Ready for Serving",
              KitchenRequest."Line Status"::"Serving Requested": begin
                KitchenOrder.Status := KitchenOrder.Status::Active;
                KitchenOrder.Modify;
                exit;
              end;

              KitchenRequest."Line Status"::Planned:
                KitchenOrder.Status := KitchenOrder.Status::Planned;

              KitchenRequest."Line Status"::Served:
                if KitchenOrder.Status = KitchenOrder.Status::Cancelled then
                  KitchenOrder.Status := KitchenOrder.Status::Finished;
            end;
          until KitchenRequest.Next = 0;

        KitchenOrder.Modify;
    end;

    procedure SetRequestLinesAsServed(var KitchenRequest: Record "NPRE Kitchen Request")
    var
        KitchenRequest2: Record "NPRE Kitchen Request";
    begin
        if KitchenRequest.FindSet then
          repeat
            KitchenRequest2 := KitchenRequest;
            SetRequestLineAsServed(KitchenRequest);
          until KitchenRequest.Next = 0;
    end;

    local procedure SetRequestLineAsServed(var KitchenRequest: Record "NPRE Kitchen Request")
    var
        KitchenOrder: Record "NPRE Kitchen Order";
    begin
        KitchenRequest.TestField("Line Status", KitchenRequest."Line Status"::"Ready for Serving");
        KitchenRequest."Line Status" := KitchenRequest."Line Status"::Served;
        KitchenRequest.Modify;

        UpdateOrderStatus(KitchenRequest."Order ID");
    end;

    procedure KDSAvailable(): Boolean
    begin
        exit(true);
    end;

    procedure SplitWaiterPadLineKitchenReqSourceLinks(FromWaiterPadLine: Record "NPRE Waiter Pad Line";NewWaiterPadLine: Record "NPRE Waiter Pad Line";FullLineTransfer: Boolean)
    var
        KitchenReqSourceLink: Record "NPRE Kitchen Req. Source Link";
        NewKitchenReqSourceLink: Record "NPRE Kitchen Req. Source Link";
        RemainingQtyToMove: Decimal;
    begin
        KitchenReqSourceLink.SetCurrentKey(
          "Source Document Type","Source Document Subtype","Source Document No.","Source Document Line No.","Serving Step","Request No.");
        KitchenReqSourceLink.SetRange("Source Document Type", KitchenReqSourceLink."Source Document Type"::"Waiter Pad");
        KitchenReqSourceLink.SetRange("Source Document Subtype", 0);
        KitchenReqSourceLink.SetRange("Source Document No.", FromWaiterPadLine."Waiter Pad No.");
        KitchenReqSourceLink.SetRange("Source Document Line No.", FromWaiterPadLine."Line No.");
        if KitchenReqSourceLink.FindSet then
          repeat
            if FullLineTransfer then begin
              NewKitchenReqSourceLink := KitchenReqSourceLink;
              NewKitchenReqSourceLink."Source Document No." := NewWaiterPadLine."Waiter Pad No.";
              NewKitchenReqSourceLink."Source Document Line No." := NewWaiterPadLine."Line No.";
              NewKitchenReqSourceLink.Modify;
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
                  NewKitchenReqSourceLink.Insert;

                  NewKitchenReqSourceLink."Source Document No." := NewWaiterPadLine."Waiter Pad No.";
                  NewKitchenReqSourceLink."Source Document Line No." := NewWaiterPadLine."Line No.";
                  NewKitchenReqSourceLink.Quantity := -NewKitchenReqSourceLink.Quantity;
                  NewKitchenReqSourceLink."Quantity (Base)" := -NewKitchenReqSourceLink."Quantity (Base)";
                  NewKitchenReqSourceLink."Entry No." := 0;
                  NewKitchenReqSourceLink.Insert;
                end;

                KitchenReqSourceLink.FindLast;
                KitchenReqSourceLink.SetRange("Request No.");
              until (KitchenReqSourceLink.Next = 0) or (RemainingQtyToMove = 0);
              KitchenReqSourceLink.FindLast;
              KitchenReqSourceLink.SetRange("Serving Step");
            end;
          until KitchenReqSourceLink.Next = 0;
    end;

    procedure CancelKitchenOrder(var KitchenOrderIn: Record "NPRE Kitchen Order")
    var
        KitchenOrder: Record "NPRE Kitchen Order";
        KitchenRequest: Record "NPRE Kitchen Request";
    begin
        KitchenOrder := KitchenOrderIn;
        KitchenOrder.Status := KitchenOrder.Status::Cancelled;
        KitchenOrder.Modify;

        KitchenRequest.SetCurrentKey("Order ID");
        KitchenRequest.SetRange("Order ID", KitchenOrder."Order ID");
        if KitchenRequest.FindSet then
          repeat
            CancelKitchenRequest(KitchenRequest);
          until KitchenRequest.Next = 0;
    end;

    procedure CancelKitchenRequest(var KitchenRequestIn: Record "NPRE Kitchen Request")
    var
        KitchenRequest: Record "NPRE Kitchen Request";
    begin
        KitchenRequest := KitchenRequestIn;
        KitchenRequest."Line Status" := KitchenRequest."Line Status"::Cancelled;
        KitchenRequest.Modify;
    end;
}

