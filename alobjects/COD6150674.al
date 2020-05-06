codeunit 6150674 "NPRE Kitchen Order Mgt."
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant


    trigger OnRun()
    begin
    end;

    var
        IncorrectFunctionCallMsg: Label '%1: incorrect function call. %2. This indicates a programming bug, not a user error.';
        MustBeTempMsg: Label 'Must be called with temporary record variable';
        KitchenOrder: Record "NPRE Kitchen Order";
        SetupProxy: Codeunit "NPRE Restaurant Setup Proxy";
        AlreadyFinishedMsg: Label 'The production of the item has already been finished. Are you sure you want to start over?';

    procedure SendWPLinesToKitchen(var WaiterPadLineIn: Record "NPRE Waiter Pad Line";FlowStatusCode: Code[10];PrintCategoryCode: Code[20];RequestType: Option "Order","Serving Request";SentDateTime: DateTime): Boolean
    var
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPRE Restaurant Print";
        Success: Boolean;
    begin
        if not (RequestType in [RequestType::Order,RequestType::"Serving Request"]) then
          exit(false);

        if SentDateTime = 0DT then
          SentDateTime := CurrentDateTime;

        WaiterPadLine.Copy(WaiterPadLineIn);
        if WaiterPadLine.FindSet then
          repeat
            if SendWPLineToKitchen(WaiterPadLine,FlowStatusCode,PrintCategoryCode,RequestType,SentDateTime) then begin
              RestaurantPrint.LogWaiterPadLinePrint(WaiterPadLine,RequestType,FlowStatusCode,PrintCategoryCode,SentDateTime,1);
              Success := true;
            end;
          until WaiterPadLine.Next = 0;

        exit(Success);
    end;

    local procedure SendWPLineToKitchen(WaiterPadLine: Record "NPRE Waiter Pad Line";FlowStatusCode: Code[10];PrintCategoryCode: Code[20];RequestType: Option "Order","Serving Request";SentDateTime: DateTime): Boolean
    var
        KitchenRequest: Record "NPRE Kitchen Request";
        KitchenRequestParam: Record "NPRE Kitchen Request";
        KitchenStation: Record "NPRE Kitchen Station";
        KitchenStationBuffer: Record "NPRE Kitchen Station Selection" temporary;
    begin
        if not FindApplicableWPLineKitchenStations(KitchenStationBuffer,WaiterPadLine,FlowStatusCode,PrintCategoryCode) then
          exit(false);

        repeat
          KitchenRequestParam.InitFromWaiterPadLine(WaiterPadLine);
          KitchenRequestParam."Restaurant Code" := KitchenStationBuffer."Restaurant Code";
          KitchenRequestParam."Serving Step" := FlowStatusCode;
          KitchenRequestParam."Created Date-Time" := SentDateTime;
          FindKitchenRequestEntry(KitchenRequest,KitchenRequestParam);

          if RequestType = RequestType::"Serving Request" then begin
            KitchenRequest."Serving Requested Date-Time" := SentDateTime;
            if KitchenRequest."Line Status" = KitchenRequest."Line Status"::Planned then
              KitchenRequest."Line Status" := KitchenRequest."Line Status"::"Serving Requested";
            UpdateRequestLineStatus(KitchenRequest);
            KitchenRequest.Modify;
          end;

          KitchenStation.Get(KitchenStationBuffer."Production Restaurant Code",KitchenStationBuffer."Kitchen Station");
          CreateKitchenStationRequest(KitchenRequest,KitchenStation);
          UpdateOrderStatus(KitchenOrder);
        until KitchenStationBuffer.Next = 0;
        exit(true);
    end;

    local procedure FindKitchenRequestEntry(var KitchenRequest: Record "NPRE Kitchen Request";KitchenRequestParam: Record "NPRE Kitchen Request")
    begin
        with KitchenRequest do begin
          SetRange("Source Document Type",KitchenRequestParam."Source Document Type");
          SetRange("Source Document Subtype",KitchenRequestParam."Source Document Subtype");
          SetRange("Source Document No.",KitchenRequestParam."Source Document No.");
          SetRange("Source Document Line No.",KitchenRequestParam."Source Document Line No.");
          SetRange("Restaurant Code",KitchenRequestParam."Restaurant Code");
          SetRange("Serving Step",KitchenRequestParam."Serving Step");
          SetFilter("Line Status",'<>%1',"Line Status"::Cancelled);
          if FindFirst then
            KitchenOrder.Get("Order ID")
          else begin
            KitchenRequest := KitchenRequestParam;
            "Line Status" := "Line Status"::Planned;
            "Production Status" := "Production Status"::"Not Started";
            "Order ID" := FindKitchenOrderId(KitchenRequest);
            Priority := KitchenOrder.Priority;
            "Request No." := 0;
            Insert(true);
          end;
        end;
    end;

    local procedure FindKitchenOrderId(KitchenRequest: Record "NPRE Kitchen Request"): BigInteger
    var
        KitchenRequest2: Record "NPRE Kitchen Request";
        Restaurant: Record "NPRE Restaurant";
    begin
        if KitchenOrder."Order ID" = 0 then begin
          SetupProxy.SetRestaurant(KitchenRequest."Restaurant Code");
          if SetupProxy.OrderIDAssignmentMethod = Restaurant."Order ID Assign. Method"::"Same for Source Document" then begin
            KitchenRequest2.SetRange("Source Document Type",KitchenRequest."Source Document Type");
            KitchenRequest2.SetRange("Source Document Subtype",KitchenRequest."Source Document Subtype");
            KitchenRequest2.SetRange("Source Document No.",KitchenRequest."Source Document No.");
            KitchenRequest2.SetFilter("Order ID",'<>%1',0);
            if KitchenRequest2.FindFirst then
              KitchenOrder.Get(KitchenRequest2."Order ID");
          end;

          if KitchenOrder."Order ID" = 0 then begin
            KitchenOrder.Init;
            KitchenOrder.Status := KitchenOrder.Status::Planned;
            KitchenOrder.Priority := DefaultPriority(KitchenRequest);
            KitchenOrder."Created Date-Time" := KitchenRequest."Created Date-Time";
            KitchenOrder."Restaurant Code" := KitchenRequest."Restaurant Code";
            KitchenOrder.Insert;
          end;
        end;
        exit(KitchenOrder."Order ID");
    end;

    local procedure CreateKitchenStationRequest(KitchenRequest: Record "NPRE Kitchen Request";KitchenStation: Record "NPRE Kitchen Station")
    var
        KitchenOrdLineStation: Record "NPRE Kitchen Request Station";
    begin
        with KitchenOrdLineStation do begin
          SetRange("Request No.",KitchenRequest."Request No.");
          SetRange("Production Restaurant Code",KitchenStation."Restaurant Code");
          SetRange("Kitchen Station",KitchenStation.Code);
          SetFilter("Production Status",'<>%1',"Production Status"::Cancelled);
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

    local procedure FindApplicableWPLineKitchenStations(var KitchenStationBuffer: Record "NPRE Kitchen Station Selection";WaiterPadLine: Record "NPRE Waiter Pad Line";FlowStatusCode: Code[10];PrintCategoryCode: Code[20]): Boolean
    var
        KitchenStationSelection: Record "NPRE Kitchen Station Selection";
        Seating: Record "NPRE Seating";
        SeatingLocation: Record "NPRE Seating Location";
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        if not KitchenStationBuffer.IsTemporary then
          Error(IncorrectFunctionCallMsg,'CU6150674.FindKitchenStations',MustBeTempMsg);

        Clear(KitchenStationBuffer);
        KitchenStationBuffer.DeleteAll;

        SeatingWaiterPadLink.SetRange("Waiter Pad No.",WaiterPadLine."Waiter Pad No.");
        SeatingWaiterPadLink.SetFilter("Seating Code",'<>%1','');
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
          SetRange("Restaurant Code","Restaurant Code");
          SetRange("Seating Location","Seating Location");
          SetRange("Serving Step","Serving Step");
          SetRange("Print Category Code","Print Category Code");
          if IsEmpty then begin
            SetRange("Seating Location",'');
            if IsEmpty then begin
              SetRange("Seating Location","Seating Location");
              SetRange("Serving Step",'');
              if IsEmpty then begin
                SetRange("Seating Location",'');
                if IsEmpty then begin
                  SetRange("Seating Location","Seating Location");
                  SetRange("Serving Step","Serving Step");
                  SetRange("Print Category Code",'');
                  if IsEmpty then begin
                    SetRange("Seating Location",'');
                    if IsEmpty then begin
                      SetRange("Seating Location","Seating Location");
                      SetRange("Serving Step",'');
                      if IsEmpty then begin
                        SetRange("Seating Location",'');
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
    begin
        with KitchenRequestStation do begin
          if "Production Status" = "Production Status"::Finished then
            if not Confirm(AlreadyFinishedMsg,true) then
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
          if "Production Status" in ["Production Status"::"Not Started","Production Status"::Finished,"Production Status"::Cancelled] then
            FieldError("Production Status");

          "End Date-Time" := CurrentDateTime;
          "On Hold" := false;
          "Production Status" := "Production Status"::Finished;
          Modify;
        end;
        UpdateRequestStatusesFromStation(KitchenRequestStation);
    end;

    local procedure UpdateRequestStatusesFromStation(KitchenRequestStation: Record "NPRE Kitchen Request Station")
    var
        KitchenRequest: Record "NPRE Kitchen Request";
    begin
        KitchenRequest.Get(KitchenRequestStation."Request No.");
        UpdateRequestStatuses(KitchenRequest);
    end;

    local procedure UpdateRequestStatuses(var KitchenRequest: Record "NPRE Kitchen Request")
    var
        KitchenOrder: Record "NPRE Kitchen Order";
    begin
        UpdateRequestProdStatus(KitchenRequest);
        UpdateRequestLineStatus(KitchenRequest);
        KitchenRequest.Modify;

        KitchenOrder.Get(KitchenRequest."Order ID");
        UpdateOrderStatus(KitchenOrder);
    end;

    local procedure UpdateRequestProdStatus(var KitchenRequest: Record "NPRE Kitchen Request")
    var
        KitchenRequestStation: Record "NPRE Kitchen Request Station";
    begin
        with KitchenRequest do begin
          KitchenRequestStation.SetRange("Request No.","Request No.");
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
            not ("Production Status" in ["Production Status"::Finished,"Production Status"::Cancelled]):
              if "Serving Requested Date-Time" <> 0DT then
                "Line Status" := "Line Status"::"Serving Requested"
              else
                "Line Status" := "Line Status"::Planned;
          end;
    end;

    local procedure UpdateOrderStatus(var KitchenOrder: Record "NPRE Kitchen Order")
    var
        KitchenRequest: Record "NPRE Kitchen Request";
    begin
        with KitchenOrder do begin
          Status := Status::Cancelled;

          KitchenRequest.SetCurrentKey("Order ID");
          KitchenRequest.SetRange("Order ID","Order ID");
          KitchenRequest.SetFilter("Line Status",'<>%1',KitchenRequest."Line Status"::Cancelled);
          if KitchenRequest.FindSet then
            repeat
              case KitchenRequest."Line Status" of
                KitchenRequest."Line Status"::"Ready for Serving",
                KitchenRequest."Line Status"::"Serving Requested": begin
                  Status := Status::Active;
                  Modify;
                  exit;
                end;

                KitchenRequest."Line Status"::Planned:
                  Status := Status::Planned;

                KitchenRequest."Line Status"::Served:
                  if Status = Status::Cancelled then
                    Status := Status::Finished;
              end;
            until KitchenRequest.Next = 0;

          Modify;
        end;
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
        KitchenRequest.TestField("Line Status",KitchenRequest."Line Status"::"Ready for Serving");
        KitchenRequest."Line Status" := KitchenRequest."Line Status"::Served;
        KitchenRequest.Modify;

        KitchenOrder.Get(KitchenRequest."Order ID");
        UpdateOrderStatus(KitchenOrder);
    end;

    procedure KDSAvailable(): Boolean
    begin
        exit(false);
    end;
}

