codeunit 6150663 "NPR NPRE Waiter Pad Mgt."
{
    Access = Internal;

    var
        _WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        _InQuotes: Label '''%1''', Locked = true;

    procedure LinkSeatingToWaiterPad(WaiterPad: Record "NPR NPRE Waiter Pad"; SeatingCode: Code[20]; var SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink"): Boolean
    var
        SeatingWaiterPadLink2: Record "NPR NPRE Seat.: WaiterPadLink";
        Seating: Record "NPR NPRE Seating";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
    begin
        if SeatingWaiterPadLink.Get(SeatingCode, WaiterPad."No.") then
            exit(false);

        Seating.Get(SeatingCode);
        Seating.TestField(Blocked, false);
        SeatingWaiterPadLink2.SetCurrentKey("Waiter Pad No.", Primary);
        SeatingWaiterPadLink2.SetRange("Waiter Pad No.", WaiterPad."No.");
        SeatingWaiterPadLink2.SetRange(Primary, true);

        SeatingWaiterPadLink.Init();
        SeatingWaiterPadLink."Seating Code" := Seating.Code;
        SeatingWaiterPadLink."Waiter Pad No." := WaiterPad."No.";
        SeatingWaiterPadLink.Closed := WaiterPad.Closed;
        SeatingWaiterPadLink.Primary := SeatingWaiterPadLink2.IsEmpty();
        SeatingWaiterPadLink.Insert(true);

        if SeatingWaiterPadLink.Primary then
            KitchenOrderMgt.UpdateKitchenReqSourceSeating(Enum::"NPR NPRE K.Req.Source Doc.Type"::"Waiter Pad", 0, WaiterPad."No.", 0, SeatingCode);

        if not SeatingWaiterPadLink.Closed then
            SeatingMgt.SetSeatingIsOccupied(Seating.Code);
        exit(true);
    end;

    procedure RemoveSeatingWaiterPadLink(WaiterPadNo: Code[20]; SeatingCode: Code[20]): Boolean
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingWaiterPadLink2: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
    begin
        SeatingWaiterPadLink."Seating Code" := SeatingCode;
        SeatingWaiterPadLink."Waiter Pad No." := WaiterPadNo;

        if not SeatingWaiterPadLink.Find() then
            exit(false);

        if SeatingWaiterPadLink.Primary then begin
            SeatingWaiterPadLink2.SetCurrentKey("Waiter Pad No.", Primary);
            SeatingWaiterPadLink2.SetRange("Waiter Pad No.", WaiterPadNo);
            SeatingWaiterPadLink2.SetRange(Primary, false);
            if SeatingWaiterPadLink2.FindFirst() then begin
                SeatingWaiterPadLink2.Primary := true;
                SeatingWaiterPadLink2.Modify();
            end;
        end;

        SeatingWaiterPadLink.Delete(true);
        SeatingMgt.TrySetSeatingIsCleared(SeatingCode);
        exit(true);
    end;

    procedure ChangeSeating(WaiterPad: Record "NPR NPRE Waiter Pad"; SeatingCode: Code[20]; SeatingCodeNew: Code[20]): Boolean
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        RemoveSeatingWaiterPadLink(WaiterPad."No.", SeatingCode);
        exit(LinkSeatingToWaiterPad(WaiterPad, SeatingCodeNew, SeatingWaiterPadLink));
    end;

    procedure ChangeWaiterPad(SeatingCode: Code[20]; FromWaiterPadNo: Code[20]; NewWaiterPad: Record "NPR NPRE Waiter Pad"): Boolean
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        RemoveSeatingWaiterPadLink(FromWaiterPadNo, SeatingCode);
        exit(LinkSeatingToWaiterPad(NewWaiterPad, SeatingCode, SeatingWaiterPadLink));
    end;

    procedure CreateNewWaiterPad(SeatingCode: Code[20]; NumberOfGuests: Integer; AssignedWaiterCode: Code[20]; CustomerDetails: Dictionary of [Text, Text]; var WaiterPad: Record "NPR NPRE Waiter Pad"): Boolean
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        Clear(WaiterPad);
        SetPartySize(WaiterPad, NumberOfGuests);
        WaiterPad."Assigned Waiter Code" := AssignedWaiterCode;
        WaiterPad.Description := CopyStr(GetDictionaryValue(CustomerDetails, WaiterPad.FieldName(Description)), 1, MaxStrLen(WaiterPad.Description));
        WaiterPad."Customer Phone No." := CopyStr(GetDictionaryValue(CustomerDetails, WaiterPad.FieldName("Customer Phone No.")), 1, MaxStrLen(WaiterPad."Customer Phone No."));
        WaiterPad."Customer E-Mail" := CopyStr(GetDictionaryValue(CustomerDetails, WaiterPad.FieldName("Customer E-Mail")), 1, MaxStrLen(WaiterPad."Customer E-Mail"));
        exit(AddNewWaiterPadForSeating(SeatingCode, WaiterPad, SeatingWaiterPadLink));
    end;

    local procedure GetDictionaryValue(KeyValueDictionary: Dictionary of [Text, Text]; "Key": Text) Value: Text
    begin
        if not KeyValueDictionary.ContainsKey("Key") then
            exit('');
        KeyValueDictionary.Get("Key", Value);
    end;

    procedure SetPartySize(WaiterPadNo: Code[20]; NumberOfGuests: Integer)
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        WaiterPad.Get(WaiterPadNo);
        SetPartySize(WaiterPad, NumberOfGuests);
        WaiterPad.Modify();
    end;

    procedure SetPartySize(var WaiterPad: Record "NPR NPRE Waiter Pad"; NumberOfGuests: Integer)
    begin
        if NumberOfGuests < 0 then
            NumberOfGuests := 0;
        WaiterPad."Number of Guests" := NumberOfGuests;
    end;

    procedure InsertWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad"; RunInsert: Boolean)
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        HospitalitySetup: Record "NPR NPRE Restaurant Setup";
        NewWaiterPadNo: Code[20];
    begin
        HospitalitySetup.Get();
        HospitalitySetup.TestField("Waiter Pad No. Serie");

        NewWaiterPadNo := NoSeriesManagement.GetNextNo(HospitalitySetup."Waiter Pad No. Serie", Today, true);

        WaiterPad."No." := NewWaiterPadNo;
        if RunInsert then WaiterPad.Insert(true);
    end;

    procedure AddNewWaiterPadForSeating(SeatingCode: Code[20]; var WaiterPad: Record "NPR NPRE Waiter Pad"; var SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink"): Boolean
    begin
        if WaiterPad."No." = '' then
            InsertWaiterPad(WaiterPad, true);

        exit(LinkSeatingToWaiterPad(WaiterPad, SeatingCode, SeatingWaiterPadLink));
    end;

    procedure DuplicateWaiterPadHdr(FromWaiterPad: Record "NPR NPRE Waiter Pad"; var NewWaiterPad: Record "NPR NPRE Waiter Pad")
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingWaiterPadLink2: Record "NPR NPRE Seat.: WaiterPadLink";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        NewWaiterPad."No." := '';
        InsertWaiterPad(NewWaiterPad, false);
        NewWaiterPad.TransferFields(FromWaiterPad, false);
        NewWaiterPad."Number of Guests" := 0;
        NewWaiterPad."Billed Number of Guests" := 0;
        RestaurantPrint.SetWaiterPadPreReceiptPrinted(NewWaiterPad, false, false);
        NewWaiterPad.Closed := false;
        NewWaiterPad."Close Date" := 0D;
        NewWaiterPad."Close Time" := 0T;

        SeatingWaiterPadLink.SetRange("Waiter Pad No.", FromWaiterPad."No.");
        if SeatingWaiterPadLink.FindSet() then
            repeat
                SeatingWaiterPadLink2 := SeatingWaiterPadLink;
                SeatingWaiterPadLink2."Waiter Pad No." := NewWaiterPad."No.";
                SeatingWaiterPadLink2.Closed := NewWaiterPad.Closed;
                SeatingWaiterPadLink2.Insert();
            until SeatingWaiterPadLink.Next() = 0;

        NewWaiterPad.Insert(true);

        _WaiterPadPOSMgt.CopyPOSInfoWPad2WPad(FromWaiterPad, 0, NewWaiterPad, 0);
    end;

    procedure MergeWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad"; var MergeToWaiterPad: Record "NPR NPRE Waiter Pad") OK: Boolean
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        SetPartySize(MergeToWaiterPad, MergeToWaiterPad."Number of Guests" + WaiterPad."Number of Guests");
        MergeToWaiterPad."Billed Number of Guests" := MergeToWaiterPad."Billed Number of Guests" + WaiterPad."Billed Number of Guests";
        if MergeToWaiterPad."Customer No." = '' then
            MergeToWaiterPad."Customer No." := WaiterPad."Customer No.";
        if MergeToWaiterPad.Description = '' then
            MergeToWaiterPad.Description := WaiterPad.Description;
        if MergeToWaiterPad."Customer Phone No." = '' then
            MergeToWaiterPad."Customer Phone No." := WaiterPad."Customer Phone No.";
        if MergeToWaiterPad."Customer E-Mail" = '' then
            MergeToWaiterPad."Customer E-Mail" := WaiterPad."Customer E-Mail";
        RestaurantPrint.SetWaiterPadPreReceiptPrinted(MergeToWaiterPad, false, true);

        WaiterPad."Number of Guests" := 0;
        WaiterPad."Billed Number of Guests" := 0;
        RestaurantPrint.SetWaiterPadPreReceiptPrinted(WaiterPad, false, true);

        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        if WaiterPadLine.FindSet() then begin
            repeat
                _WaiterPadPOSMgt.SplitWaiterPadLine(WaiterPad, WaiterPadLine, WaiterPadLine.Quantity, MergeToWaiterPad);
            until WaiterPadLine.Next() = 0;
        end;

        TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Split/Merge Waiter Pad");
        exit(true);
    end;

    procedure TryCloseWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad"; ForceClose: Boolean; CloseReason: Enum "NPR NPRE W/Pad Closing Reason")
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        IsServed: Option Undefined,No,Yes;
        Handled: Boolean;
        OK: Boolean;
    begin
        if WaiterPad.Closed then
            exit;

        SetupProxy.InitializeUsingWaiterPad(WaiterPad);

        OnBeforeCloseWaiterPad(WaiterPad, SetupProxy, ForceClose, Handled);
        if Handled then
            exit;

        CleanupWaiterPad(WaiterPad);
        OK := ForceClose;
        if not OK then
            OK := WaiterPadCanBeClosed(WaiterPad, SetupProxy, IsServed);
        if OK then begin
            WaiterPad."Close Date" := WorkDate();
            WaiterPad."Close Time" := Time;
            WaiterPad.Closed := true;
            WaiterPad."Close Reason" := CloseReason;
            WaiterPad.Modify();

            CloseWaiterPadSeatings(WaiterPad);
        end else begin
            OK := WaiterPadSeatingsCanBeClosed(WaiterPad, SetupProxy, IsServed);
            if OK then
                CloseWaiterPadSeatings(WaiterPad)
            else
                if WaiterPadIsReadyForPayment(WaiterPad, SetupProxy, IsServed) then
                    SetWaiterPadStatusInPayment(WaiterPad, SetupProxy);
        end;

        if OK then
            OnAfterCloseWaiterPad(WaiterPad);
    end;

    procedure CloseWaiterPadSeatings(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        SeatingWaiterPadLink.Reset();
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        SeatingWaiterPadLink.SetRange(Closed, false);
        if SeatingWaiterPadLink.FindSet() then
            repeat
                CloseWaiterPadSeatingLink(SeatingWaiterPadLink);
            until SeatingWaiterPadLink.Next() = 0;
    end;

    local procedure CloseWaiterPadSeatingLink(SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink")
    var
        SeatingWaiterPadLink2: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
    begin
        SeatingWaiterPadLink2 := SeatingWaiterPadLink;
        SeatingWaiterPadLink2.Closed := true;
        SeatingWaiterPadLink2.Modify();

        SeatingMgt.TrySetSeatingIsCleared(SeatingWaiterPadLink2."Seating Code");
    end;

    local procedure CleanupWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
    begin
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter("Line Type", '<>%1', WaiterPadLine."Line Type"::Comment);
        if not WaiterPadLine.IsEmpty() then
            exit;

        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Comment);
        if not WaiterPadLine.IsEmpty() then
            WaiterPadLine.DeleteAll(true);

        POSInfoWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        POSInfoWaiterPadLink.DeleteAll();

        OnAfterWaiterPadCleanup(WaiterPad);
    end;

    local procedure WaiterPadCanBeClosed(WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy"; var IsServed: Option Undefined,No,Yes): Boolean
    var
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter("Quantity (Base)", '<>%1', 0);
        if WaiterPadLine.IsEmpty() then
            exit(true);

        SetupProxy.GetServiceFlowProfile(ServiceFlowProfile);
        case ServiceFlowProfile."Close Waiter Pad On" of
            ServiceFlowProfile."Close Waiter Pad On"::"Pre-Receipt":
                exit(WaiterPad."Pre-receipt Printed");

            ServiceFlowProfile."Close Waiter Pad On"::"Pre-Receipt if Served":
                if WaiterPad."Pre-receipt Printed" then begin
                    if IsServed = IsServed::Undefined then
                        if WPIsServed(WaiterPad, SetupProxy) then
                            IsServed := IsServed::Yes
                        else
                            IsServed := IsServed::No;
                    exit(IsServed = IsServed::Yes);
                end;

            ServiceFlowProfile."Close Waiter Pad On"::Payment:
                exit(WPIsPaid(WaiterPad, ServiceFlowProfile."Only if Fully Paid"));

            ServiceFlowProfile."Close Waiter Pad On"::"Payment if Served":
                if WPIsPaid(WaiterPad, ServiceFlowProfile."Only if Fully Paid") then begin
                    if IsServed = IsServed::Undefined then
                        if WPIsServed(WaiterPad, SetupProxy) then
                            IsServed := IsServed::Yes
                        else
                            IsServed := IsServed::No;
                    exit(IsServed = IsServed::Yes);
                end;
        end;

        exit(false);
    end;

    local procedure WaiterPadSeatingsCanBeClosed(WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy"; var IsServed: Option Undefined,No,Yes): Boolean
    var
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        SetupProxy.GetServiceFlowProfile(ServiceFlowProfile);
        case ServiceFlowProfile."Clear Seating On" of
            ServiceFlowProfile."Clear Seating On"::"Waiter Pad Close":
                exit(WaiterPad.Closed);

            ServiceFlowProfile."Clear Seating On"::"Pre-Receipt":
                exit(WaiterPad."Pre-receipt Printed");

            ServiceFlowProfile."Clear Seating On"::"Pre-Receipt if Served":
                if WaiterPad."Pre-receipt Printed" then begin
                    if IsServed = IsServed::Undefined then
                        if WPIsServed(WaiterPad, SetupProxy) then
                            IsServed := IsServed::Yes
                        else
                            IsServed := IsServed::No;
                    exit(IsServed = IsServed::Yes);
                end;
        end;

        exit(false);
    end;

    local procedure SetWaiterPadStatusInPayment(var WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy")
    var
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        SetupProxy.GetServiceFlowProfile(ServiceFlowProfile);
        if ServiceFlowProfile."W/Pad Ready for Pmt. Status" = '' then
            exit;
        if SetWaiterPadStatus(WaiterPad, ServiceFlowProfile."W/Pad Ready for Pmt. Status") then
            WaiterPad.Modify();
    end;

    procedure SetWaiterPadStatus(var WaiterPad: Record "NPR NPRE Waiter Pad"; NewStatusCode: Code[10]): Boolean
    var
        xWaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        if WaiterPad.Status = NewStatusCode then
            exit(false);

        xWaiterPad := WaiterPad;
        WaiterPad.Validate(Status, NewStatusCode);
        OnAfterChangeWaiterPadStatus(xWaiterPad, WaiterPad);
        exit(true);
    end;

    local procedure WaiterPadIsReadyForPayment(WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy"; var IsServed: Option Undefined,No,Yes): Boolean
    var
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        SetupProxy.GetServiceFlowProfile(ServiceFlowProfile);
        case ServiceFlowProfile."Set W/Pad Ready for Pmt. On" of
            ServiceFlowProfile."Set W/Pad Ready for Pmt. On"::"Pre-Receipt":
                exit(WaiterPad."Pre-receipt Printed");

            ServiceFlowProfile."Set W/Pad Ready for Pmt. On"::"Pre-Receipt if Served":
                if WaiterPad."Pre-receipt Printed" then begin
                    if IsServed = IsServed::Undefined then
                        if WPIsServed(WaiterPad, SetupProxy) then
                            IsServed := IsServed::Yes
                        else
                            IsServed := IsServed::No;
                    exit(IsServed = IsServed::Yes);
                end;
        end;

        exit(false);
    end;

    local procedure WPIsPaid(WaiterPad: Record "NPR NPRE Waiter Pad"; OnlyIfFullyPaid: Boolean): Boolean
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter("Line Type", '<>%1', WaiterPadLine."Line Type"::Comment);
        if WaiterPadLine.FindSet() then
            repeat
                if not OnlyIfFullyPaid then begin
                    if WaiterPadLine."Billed Quantity" <> 0 then
                        exit(true);
                end else
                    if WaiterPadLine.Quantity > WaiterPadLine."Billed Quantity" then
                        exit(false);
            until WaiterPadLine.Next() = 0;

        exit(OnlyIfFullyPaid);
    end;

    local procedure WPIsServed(WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy"): Boolean
    var
        TempFlowStatus: Record "NPR NPRE Flow Status" temporary;
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link";
        TempKitchenStationBuffer: Record "NPR NPRE Kitchen Station Slct." temporary;
        TempPrintCategory: Record "NPR NPRE Print/Prod. Cat." temporary;
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        TempWPadLineBuffer: Record "NPR NPRE W.Pad.Line Outp.Buf." temporary;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        if not SetupProxy.KDSActivated() then
            exit(true);

        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter("Line Type", '<>%1', WaiterPadLine."Line Type"::Comment);
        if WaiterPadLine.IsEmpty() then
            exit(true);

        RestPrint.InitTempFlowStatusList(TempFlowStatus, TempFlowStatus."Status Object"::WaiterPadLineMealFlow);
        RestPrint.InitTempPrintCategoryList(TempPrintCategory);
        RestPrint.BufferEligibleForSendingWPadLines(
            WaiterPadLine, WaiterPadLine."Output Type Filter"::KDS, WaiterPadLine."Print Type Filter"::"Kitchen Order",
            TempFlowStatus, TempPrintCategory, true, false, TempWPadLineBuffer);

        if TempWPadLineBuffer.FindSet() then
            repeat
                if WaiterPadLine.Get(TempWPadLineBuffer."Waiter Pad No.", TempWPadLineBuffer."Waiter Pad Line No.") then
                    if KitchenOrderMgt.FindApplicableWPLineKitchenStations(
                        TempKitchenStationBuffer, WaiterPadLine, TempWPadLineBuffer."Serving Step", TempWPadLineBuffer."Print Category Code")
                    then begin
                        KitchenOrderMgt.InitKitchenReqSourceFromWaiterPadLine(
                            KitchenReqSourceParam, WaiterPadLine, TempKitchenStationBuffer."Restaurant Code", '', '', TempWPadLineBuffer."Serving Step", 0DT);
                        KitchenRequest.Reset();
                        KitchenOrderMgt.FindKitchenRequestsForSourceDoc(KitchenRequest, KitchenReqSourceParam);
                        if not KitchenRequest.FindSet() then
                            exit(false);
                        repeat
                            if KitchenRequest."Line Status" <> KitchenRequest."Line Status"::Served then
                                exit(false);
                        until KitchenRequest.Next() = 0;
                    end;
            until TempWPadLineBuffer.Next() = 0;

        exit(true);
    end;

    procedure MoveNumberOfGuests(var FromWaiterPad: Record "NPR NPRE Waiter Pad"; var ToWaiterPad: Record "NPR NPRE Waiter Pad"; NumberOfGuests: Integer)
    begin
        SetPartySize(ToWaiterPad, NumberOfGuests);
        ToWaiterPad."Billed Number of Guests" := FromWaiterPad."Billed Number of Guests" - FromWaiterPad."Number of Guests" + ToWaiterPad."Number of Guests";
        if ToWaiterPad."Billed Number of Guests" < 0 then
            ToWaiterPad."Billed Number of Guests" := 0;
        ToWaiterPad.Modify();

        SetPartySize(FromWaiterPad, FromWaiterPad."Number of Guests" - ToWaiterPad."Number of Guests");
        FromWaiterPad."Billed Number of Guests" := FromWaiterPad."Billed Number of Guests" - ToWaiterPad."Billed Number of Guests";
        if FromWaiterPad."Billed Number of Guests" < 0 then
            FromWaiterPad."Billed Number of Guests" := 0;
        FromWaiterPad.Modify();
    end;

    procedure AssignedPrintCategoriesAsFilterString(AppliesToRecID: RecordID; OnlyForServingStepFilter: Text): Text
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        AssignedPrintCategories: Text;
        Include: Boolean;
    begin
        FilterAssignedPrintCategories(AppliesToRecID, AssignedPrintCategory);
        AssignedPrintCategory.SetFilter("Print/Prod. Category Code", '<>%1', '');
        if not AssignedPrintCategory.FindSet() then
            exit('');
        AssignedPrintCategories := '';
        repeat
            if OnlyForServingStepFilter <> '' then begin
                FilterAssignedFlowStatuses(AssignedPrintCategory.RecordId, AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow, AssignedFlowStatus);
                AssignedFlowStatus.SetFilter("Flow Status Code", OnlyForServingStepFilter);
                Include := not AssignedFlowStatus.IsEmpty();
                if not Include then begin
                    AssignedFlowStatus.SetRange("Flow Status Code");
                    Include := AssignedFlowStatus.IsEmpty();  //applicable on all steps
                end;
            end else
                Include := true;

            if Include then begin
                if AssignedPrintCategories <> '' then
                    AssignedPrintCategories := AssignedPrintCategories + '|';
                AssignedPrintCategories := AssignedPrintCategories + StrSubstNo(_InQuotes, AssignedPrintCategory."Print/Prod. Category Code");
            end;
        until AssignedPrintCategory.Next() = 0;
        exit(AssignedPrintCategories);
    end;

    procedure FilterAssignedPrintCategories(AppliesToRecID: RecordID; var AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.")
    begin
        AssignedPrintCategory.Reset();
        AssignedPrintCategory.SetRange("Table No.", AppliesToRecID.TableNo);
        AssignedPrintCategory.SetRange("Record ID", AppliesToRecID);
    end;

    procedure AssignedFlowStatusesAsFilterString(AppliesToRecID: RecordID; StatusObject: Enum "NPR NPRE Status Object"; var AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status"): Text
    var
        AssignedFlowStatuses: Text;
    begin
        FilterAssignedFlowStatuses(AppliesToRecID, StatusObject, AssignedFlowStatus);
        AssignedFlowStatus.SetFilter("Flow Status Code", '<>%1', '');
        if not AssignedFlowStatus.FindSet() then
            exit('');
        AssignedFlowStatuses := '';
        repeat
            if AssignedFlowStatuses <> '' then
                AssignedFlowStatuses := AssignedFlowStatuses + '|';
            AssignedFlowStatuses := AssignedFlowStatuses + StrSubstNo(_InQuotes, AssignedFlowStatus."Flow Status Code");
        until AssignedFlowStatus.Next() = 0;
        exit(AssignedFlowStatuses);
    end;

    procedure FilterAssignedFlowStatuses(AppliesToRecID: RecordID; StatusObject: Enum "NPR NPRE Status Object"; var AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status")
    begin
        AssignedFlowStatus.Reset();
        AssignedFlowStatus.SetRange("Table No.", AppliesToRecID.TableNo);
        AssignedFlowStatus.SetRange("Record ID", AppliesToRecID);
        AssignedFlowStatus.SetRange("Flow Status Object", StatusObject);
    end;

    procedure SelectPrintCategories(AppliesToRecID: RecordID)
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        TempAssignedFlowStatus: Record "NPR NPRE Assigned Flow Status" temporary;
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        PrintCategoryList: Page "NPR NPRE Slct Prnt Cat.";
        Handled: Boolean;
    begin
        PrintCategory.Reset();

        FilterAssignedPrintCategories(AppliesToRecID, AssignedPrintCategory);
        if AssignedPrintCategory.FindSet() then
            repeat
                if PrintCategory.Get(AssignedPrintCategory."Print/Prod. Category Code") then begin
                    PrintCategory.Mark := true;

                    FilterAssignedFlowStatuses(AssignedPrintCategory.RecordId, AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow, AssignedFlowStatus);
                    if AssignedFlowStatus.FindSet() then
                        repeat
                            TempAssignedFlowStatus := AssignedFlowStatus;
                            TempAssignedFlowStatus.Insert();
                        until AssignedFlowStatus.Next() = 0;
                end;
            until AssignedPrintCategory.Next() = 0;
        Handled := true;

        OnBeforeSelectPrintCategories(AppliesToRecID, PrintCategory, Handled);
        if not Handled then
            exit;

        Clear(PrintCategoryList);
        PrintCategoryList.SetDataset(PrintCategory);
        PrintCategoryList.SetAssignedFlowStatusRecordset(TempAssignedFlowStatus);
        PrintCategoryList.SetSourceRecID(AppliesToRecID);
        PrintCategoryList.SetMultiSelectionMode(true);
        PrintCategoryList.LookupMode(true);
        if PrintCategoryList.RunModal() <> ACTION::LookupOK then
            exit;
        PrintCategoryList.GetDataset(PrintCategory);
        PrintCategoryList.GetAssignedFlowStatusRecordset(TempAssignedFlowStatus);
        PrintCategory.MarkedOnly(true);

        Handled := false;
        OnAfterSelectPrintCategories(AppliesToRecID, PrintCategory, Handled);
        if Handled then
            exit;

        AssignedPrintCategory.DeleteAll(true);
        if PrintCategory.FindSet() then
            repeat
                AssignedPrintCategory.Init();
                AssignedPrintCategory."Table No." := AppliesToRecID.TableNo;
                AssignedPrintCategory."Record ID" := AppliesToRecID;
                AssignedPrintCategory."Print/Prod. Category Code" := PrintCategory.Code;
                AssignedPrintCategory.Insert();

                FilterAssignedFlowStatuses(AssignedPrintCategory.RecordId, TempAssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow, TempAssignedFlowStatus);
                if TempAssignedFlowStatus.FindSet() then
                    repeat
                        AssignedFlowStatus := TempAssignedFlowStatus;
                        AssignedFlowStatus.Insert();
                    until TempAssignedFlowStatus.Next() = 0;
            until PrintCategory.Next() = 0;

        TempAssignedFlowStatus.Reset();
        TempAssignedFlowStatus.DeleteAll();
    end;

    procedure AssignWPadLinePrintCategories(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; RemoveExisting: Boolean)
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        NewAssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        Handled: Boolean;
    begin
        OnBeforeAssignWPadLinePrintCategories(WaiterPadLine, RemoveExisting, Handled);
        if Handled then
            exit;

        if RemoveExisting then
            ClearAssignedPrintCategories(WaiterPadLine.RecordId);

        if (WaiterPadLine."Line Type" <> WaiterPadLine."Line Type"::Item) or (WaiterPadLine."No." = '') then
            exit;

        case SetupProxy.ServingStepDiscoveryMethod() of
            Enum::"NPR NPRE Serv.Step Discovery"::"Legacy (using print tags)":
                begin
                    if not (Item.Get(WaiterPadLine."No.") and (Item."NPR Print Tags" <> '')) then
                        exit;
                    PrintCategory.SetFilter("Print Tag", ConvertStr(Item."NPR Print Tags", ',', '|'));
                    if PrintCategory.FindSet() then
                        repeat
                            AddAssignedPrintCategory(WaiterPadLine.RecordId, PrintCategory, NewAssignedPrintCategory);
                        until PrintCategory.Next() = 0;
                    AssignWPadLineServingStepsFromPrintCategories(WaiterPadLine, RemoveExisting);
                end;

            Enum::"NPR NPRE Serv.Step Discovery"::"Item Routing Profiles":
                begin
                    if not Item.Get(WaiterPadLine."No.") then
                        exit;
                    if Item."NPR NPRE Item Routing Profile" = '' then
                        exit;
                    ItemRoutingProfile.Get(Item."NPR NPRE Item Routing Profile");
                    CopyAssignedPrintCategories(ItemRoutingProfile.RecordId, WaiterPadLine.RecordId);
                    CopyAssignedFlowStatuses(ItemRoutingProfile.RecordId, WaiterPadLine.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);
                end;
        end;
    end;

    procedure AddAssignedPrintCategory(AppliesToRecID: RecordID; PrintCategory: Record "NPR NPRE Print/Prod. Cat."; var NewAssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.")
    begin
        NewAssignedPrintCategory.Init();
        NewAssignedPrintCategory."Table No." := AppliesToRecID.TableNo;
        NewAssignedPrintCategory."Record ID" := AppliesToRecID;
        NewAssignedPrintCategory."Print/Prod. Category Code" := PrintCategory.Code;
        if not NewAssignedPrintCategory.Find() then
            NewAssignedPrintCategory.Insert();
    end;

    procedure ClearAssignedPrintCategories(AppliesToRecID: RecordID)
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
    begin
        FilterAssignedPrintCategories(AppliesToRecID, AssignedPrintCategory);
        if not AssignedPrintCategory.IsEmpty() then
            AssignedPrintCategory.DeleteAll(true);
    end;

    procedure CopyAssignedPrintCategories(FromRecID: RecordID; ToRecID: RecordID)
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        NewAssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        FlowStatus: Record "NPR NPRE Flow Status";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
    begin
        ClearAssignedPrintCategories(ToRecID);
        FilterAssignedPrintCategories(FromRecID, AssignedPrintCategory);
        if AssignedPrintCategory.FindSet() then
            repeat
                if PrintCategory.Get(AssignedPrintCategory."Print/Prod. Category Code") then begin
                    AddAssignedPrintCategory(ToRecID, PrintCategory, NewAssignedPrintCategory);

                    FilterAssignedFlowStatuses(AssignedPrintCategory.RecordId, AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow, AssignedFlowStatus);
                    if AssignedFlowStatus.FindSet() then
                        repeat
                            if FlowStatus.Get(AssignedFlowStatus."Flow Status Code", AssignedFlowStatus."Flow Status Object") then
                                AddAssignedFlowStatus(NewAssignedPrintCategory.RecordId, FlowStatus);
                        until AssignedFlowStatus.Next() = 0;
                end;
            until AssignedPrintCategory.Next() = 0;
    end;

    procedure MoveAssignedPrintCategories(FromRecId: RecordID; ToRecId: RecordID)
    begin
        CopyAssignedPrintCategories(FromRecId, ToRecId);
        ClearAssignedPrintCategories(FromRecId);
    end;

    procedure SelectFlowStatuses(AppliesToRecID: RecordID; StatusObject: Enum "NPR NPRE Status Object"; var AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        FlowStatusList: Page "NPR NPRE Select Flow Status";
        Handled: Boolean;
    begin
        FlowStatus.Reset();
        FlowStatus.FilterGroup(2);
        FlowStatus.SetRange("Status Object", StatusObject);
        FlowStatus.FilterGroup(0);

        case StatusObject of
            FlowStatus."Status Object"::WaiterPadLineMealFlow:
                begin
                    FilterAssignedFlowStatuses(AppliesToRecID, StatusObject, AssignedFlowStatus);
                    if AssignedFlowStatus.FindSet() then
                        repeat
                            if FlowStatus.Get(AssignedFlowStatus."Flow Status Code", AssignedFlowStatus."Flow Status Object") then
                                FlowStatus.Mark := true;
                        until AssignedFlowStatus.Next() = 0;
                    Handled := true;
                end;
        end;

        OnBeforeSelectFlowStatuses(AppliesToRecID, StatusObject, FlowStatus, Handled);
        if not Handled then
            exit;

        Clear(FlowStatusList);
        FlowStatusList.SetDataset(FlowStatus);
        FlowStatusList.SetMultiSelectionMode(true);
        FlowStatusList.LookupMode(true);
        if FlowStatusList.RunModal() <> ACTION::LookupOK then
            exit;
        FlowStatusList.GetDataset(FlowStatus);
        FlowStatus.MarkedOnly(true);

        Handled := false;

        case StatusObject of
            FlowStatus."Status Object"::WaiterPadLineMealFlow:
                begin
                    AssignedFlowStatus.DeleteAll(true);
                    if FlowStatus.FindSet() then
                        repeat
                            AssignedFlowStatus.Init();
                            AssignedFlowStatus."Table No." := AppliesToRecID.TableNo;
                            AssignedFlowStatus."Record ID" := AppliesToRecID;
                            AssignedFlowStatus."Flow Status Object" := FlowStatus."Status Object";
                            AssignedFlowStatus."Flow Status Code" := FlowStatus.Code;
                            AssignedFlowStatus.Insert();
                        until FlowStatus.Next() = 0;
                    Handled := true;
                end;
        end;

        OnAfterSelectFlowStatuses(AppliesToRecID, StatusObject, FlowStatus, Handled);
    end;

    procedure AssignWPadLineServingStepsFromPrintCategories(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; RemoveExisting: Boolean)
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        if RemoveExisting then
            ClearAssignedFlowStatuses(WaiterPadLine.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);

        if (WaiterPadLine."Line Type" <> WaiterPadLine."Line Type"::Item) or (WaiterPadLine."No." = '') then
            exit;

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if FlowStatus.FindSet() then
            repeat
                FilterAssignedPrintCategories(WaiterPadLine.RecordId, AssignedPrintCategory);
                AssignedPrintCategory.SetFilter("Print/Prod. Category Code", FlowStatus.AssignedPrintCategoriesAsFilterString());
                if AssignedPrintCategory.FindSet() then begin
                    AddAssignedFlowStatus(WaiterPadLine.RecordId, FlowStatus);
                    repeat
                        AddAssignedFlowStatus(AssignedPrintCategory.RecordId, FlowStatus);
                    until AssignedPrintCategory.Next() = 0;
                end;
            until FlowStatus.Next() = 0;
    end;

    procedure AddAssignedFlowStatus(AppliesToRecID: RecordID; FlowStatus: Record "NPR NPRE Flow Status")
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        AssignedFlowStatus.Init();
        AssignedFlowStatus."Table No." := AppliesToRecID.TableNo;
        AssignedFlowStatus."Record ID" := AppliesToRecID;
        AssignedFlowStatus."Flow Status Object" := FlowStatus."Status Object";
        AssignedFlowStatus."Flow Status Code" := FlowStatus.Code;
        if not AssignedFlowStatus.Find() then
            AssignedFlowStatus.Insert();
    end;

    procedure ClearAssignedFlowStatuses(AppliesToRecID: RecordID; StatusObject: Enum "NPR NPRE Status Object")
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        FilterAssignedFlowStatuses(AppliesToRecID, StatusObject, AssignedFlowStatus);
        if not AssignedFlowStatus.IsEmpty() then
            AssignedFlowStatus.DeleteAll(true);
    end;

    procedure CopyAssignedFlowStatuses(FromRecId: RecordID; ToRecId: RecordID; StatusObject: Enum "NPR NPRE Status Object")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        ClearAssignedFlowStatuses(ToRecId, StatusObject);
        FilterAssignedFlowStatuses(FromRecId, StatusObject, AssignedFlowStatus);
        if AssignedFlowStatus.FindSet() then
            repeat
                if FlowStatus.Get(AssignedFlowStatus."Flow Status Code", AssignedFlowStatus."Flow Status Object") then
                    AddAssignedFlowStatus(ToRecId, FlowStatus);
            until AssignedFlowStatus.Next() = 0;
    end;

    procedure MoveAssignedFlowStatuses(FromRecId: RecordID; ToRecId: RecordID; StatusObject: Enum "NPR NPRE Status Object")
    begin
        CopyAssignedFlowStatuses(FromRecId, ToRecId, StatusObject);
        ClearAssignedFlowStatuses(FromRecId, StatusObject);
    end;

    procedure EnableWaiterPadRetentionPolicies()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if not RetentionPolicySetup.WritePermission() then
            exit;
        if RetentionPolicySetup.Get(Database::"NPR NPRE Waiter Pad") and not RetentionPolicySetup.Enabled then begin
            RetentionPolicySetup.Validate(Enabled, true);
            RetentionPolicySetup.Modify(true);
        end;
        if RetentionPolicySetup.Get(Database::"NPR NPRE W.Pad Prnt LogEntry") and not RetentionPolicySetup.Enabled then begin
            RetentionPolicySetup.Validate(Enabled, true);
            RetentionPolicySetup.Modify(true);
        end;
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeAssignWPadLinePrintCategories(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; RemoveExisting: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSelectPrintCategories(AppliesToRecID: RecordID; var PrintCategory: Record "NPR NPRE Print/Prod. Cat."; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSelectPrintCategories(AppliesToRecID: RecordID; var PrintCategory: Record "NPR NPRE Print/Prod. Cat."; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSelectFlowStatuses(AppliesToRecID: RecordID; StatusObject: Enum "NPR NPRE Status Object"; var FlowStatus: Record "NPR NPRE Flow Status"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterSelectFlowStatuses(AppliesToRecID: RecordID; StatusObject: Enum "NPR NPRE Status Object"; var FlowStatus: Record "NPR NPRE Flow Status"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCloseWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy"; var ForceClose: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCloseWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWaiterPadCleanup(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterChangeWaiterPadStatus(xWaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
    end;
}
