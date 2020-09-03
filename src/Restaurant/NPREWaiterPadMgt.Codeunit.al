codeunit 6150663 "NPR NPRE Waiter Pad Mgt."
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.53/ALPO/20200108 CASE 380918 Post Seating Code and Number of Guests to POS Entries (for further sales analysis breakedown)
    // NPR5.55/ALPO/20200422 CASE 360258 More user friendly print category selection using multi-selection mode
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale


    trigger OnRun()
    begin
    end;

    var
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        InQuotes: Label '''%1''', Comment = '{Fixed}';
        EmptyCodeINQuotes: Label '''''', Comment = '{Fixed}';

    procedure LinkSeatingToWaiterPad(WaiterPadNo: Code[20]; SeatingCode: Code[20]) LinkAdded: Boolean
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        Seating: Record "NPR NPRE Seating";
    begin
        WaiterPad.Reset;
        WaiterPad.SetRange("No.", WaiterPadNo);
        WaiterPad.FindFirst;

        Seating.Reset;
        Seating.SetRange(Code, SeatingCode);
        Seating.FindFirst;

        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        if not SeatingWaiterPadLink.IsEmpty then begin
            exit(false);
        end else begin
            SeatingWaiterPadLink.Init;
            SeatingWaiterPadLink."Seating Code" := Seating.Code;
            SeatingWaiterPadLink."Waiter Pad No." := WaiterPad."No.";
            SeatingWaiterPadLink.Closed := WaiterPad.Closed;  //NPR5.55 [399170]
            SeatingWaiterPadLink.Insert(true);
            exit(true);
        end;
    end;

    procedure RemoveSeatingWaiterPadLink(WaiterPadNo: Code[20]; SeatingCode: Code[20]) LinkAdded: Boolean
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", SeatingCode);
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadNo);

        if SeatingWaiterPadLink.IsEmpty then begin
            exit(false);
        end else begin
            SeatingWaiterPadLink.FindFirst;
            SeatingWaiterPadLink.Delete(true);
            exit(true);
        end;
    end;

    procedure ChangeSeating(WaiterPadNo: Code[20]; SeatingCode: Code[20]; SeatingCodeNew: Code[20]) Changed: Boolean
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", SeatingCode);
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadNo);

        if SeatingWaiterPadLink.IsEmpty then begin
            exit(false);
        end else begin
            SeatingWaiterPadLink.FindFirst;
            SeatingWaiterPadLink.Rename(SeatingCodeNew, WaiterPadNo);

            //-NPR5.55 [399170]
            if not SeatingWaiterPadLink.Closed then
                SeatingMgt.SetSeatingIsOccupied(SeatingCodeNew);
            SeatingMgt.TrySetSeatingIsCleared(SeatingCode, SetupProxy);
            //+NPR5.55 [399170]

            exit(true);
        end;
    end;

    procedure ChangeWaiterPad(SeatingCode: Code[20]; WaiterPadNo: Code[20]; WaiterPadNoNew: Code[20]) Moved: Boolean
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", SeatingCode);
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadNo);
        if SeatingWaiterPadLink.IsEmpty then begin
            exit(false);
        end else begin
            SeatingWaiterPadLink.FindFirst;
            SeatingWaiterPadLink.Rename(SeatingCode, WaiterPadNoNew);
            exit(true);
        end;
    end;

    procedure InsertWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad"; RunInsert: Boolean)
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        HospitalitySetup: Record "NPR NPRE Restaurant Setup";
        NewWaiterPadNo: Code[20];
    begin
        HospitalitySetup.Get;
        HospitalitySetup.TestField(HospitalitySetup."Waiter Pad No. Serie");

        NewWaiterPadNo := NoSeriesManagement.GetNextNo(HospitalitySetup."Waiter Pad No. Serie", Today, true);

        WaiterPad."No." := NewWaiterPadNo;
        WaiterPad."Start Date" := WorkDate;
        WaiterPad."Start Time" := Time;
        if RunInsert then WaiterPad.Insert(true);
    end;

    procedure AddNewWaiterPadForSeating(SeatingCode: Code[10]; var WaiterPad: Record "NPR NPRE Waiter Pad"; var SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink") OK: Boolean
    var
        Seating: Record "NPR NPRE Seating";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
    begin
        //-NPR5.55 [399170] (Function moved from CU6150660)
        Seating.Get(SeatingCode);
        if WaiterPad."No." = '' then
            InsertWaiterPad(WaiterPad, true);

        SeatingWaiterPadLink.Init;
        SeatingWaiterPadLink."Seating Code" := Seating.Code;
        SeatingWaiterPadLink."Waiter Pad No." := WaiterPad."No.";
        SeatingWaiterPadLink.Insert;

        SeatingMgt.SetSeatingIsOccupied(Seating.Code);

        exit(true);
        //+NPR5.55 [399170]
    end;

    procedure DuplicateWaiterPadHdr(FromWaiterPad: Record "NPR NPRE Waiter Pad"; var NewWaiterPad: Record "NPR NPRE Waiter Pad")
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingWaiterPadLink2: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        //-NPR5.55 [399170]
        NewWaiterPad."No." := '';
        InsertWaiterPad(NewWaiterPad, false);
        NewWaiterPad.TransferFields(FromWaiterPad, false);
        NewWaiterPad."Number of Guests" := 0;
        NewWaiterPad."Billed Number of Guests" := 0;
        NewWaiterPad."Pre-receipt Printed" := false;
        NewWaiterPad.Closed := false;
        NewWaiterPad."Close Date" := 0D;
        NewWaiterPad."Close Time" := 0T;

        SeatingWaiterPadLink.SetRange("Waiter Pad No.", FromWaiterPad."No.");
        if SeatingWaiterPadLink.FindSet then
            repeat
                SeatingWaiterPadLink2 := SeatingWaiterPadLink;
                SeatingWaiterPadLink2."Waiter Pad No." := NewWaiterPad."No.";
                SeatingWaiterPadLink2.Closed := NewWaiterPad.Closed;
                SeatingWaiterPadLink2.Insert;
            until SeatingWaiterPadLink.Next = 0;

        NewWaiterPad.Insert(true);

        WaiterPadPOSMgt.CopyPOSInfoWPad2WPad(FromWaiterPad, 0, NewWaiterPad, 0);
        //+NPR5.55 [399170]
    end;

    procedure MergeWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad"; var MergeToWaiterPad: Record "NPR NPRE Waiter Pad") OK: Boolean
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        NPHWaiterPadPOSManagement: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        //-NPR5.55 [399170]
        MergeToWaiterPad."Number of Guests" := MergeToWaiterPad."Number of Guests" + WaiterPad."Number of Guests";
        MergeToWaiterPad."Billed Number of Guests" := MergeToWaiterPad."Billed Number of Guests" + WaiterPad."Billed Number of Guests";
        MergeToWaiterPad."Pre-receipt Printed" := false;
        MergeToWaiterPad.Modify;

        WaiterPad."Number of Guests" := 0;
        WaiterPad."Billed Number of Guests" := 0;
        WaiterPad."Pre-receipt Printed" := false;
        WaiterPad.Modify;
        //+NPR5.55 [399170]

        WaiterPadLine.Reset;
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        if WaiterPadLine.FindSet then begin
            repeat
                NPHWaiterPadPOSManagement.SplitWaiterPadLine(WaiterPad, WaiterPadLine, WaiterPadLine.Quantity, MergeToWaiterPad);  //NPR5.55 [399170]
                                                                                                                                   //-NPR5.55 [399170]-revoked
                                                                                                                                   /*
                                                                                                                                   MergeToWaiterPadLine.INIT;
                                                                                                                                   MergeToWaiterPadLine.VALIDATE("Waiter Pad No.", MergeToWaiterPad."No.");
                                                                                                                                   MergeToWaiterPadLine.INSERT(TRUE);

                                                                                                                                   //-NPR5.53 [360258]-revoked
                                                                                                                                   //MergeToWaiterPadLine."Sent To. Kitchen Print" := WaiterPadLine."Sent To. Kitchen Print";
                                                                                                                                   //MergeToWaiterPadLine."Print Category" := WaiterPadLine."Print Category";
                                                                                                                                   //+NPR5.53 [360258]-revoked
                                                                                                                                   MergeToWaiterPadLine."Register No." := WaiterPadLine."Register No.";
                                                                                                                                   MergeToWaiterPadLine."Start Date" := WaiterPadLine."Start Date";
                                                                                                                                   MergeToWaiterPadLine."Start Time" := WaiterPadLine."Start Time";
                                                                                                                                   MergeToWaiterPadLine.Type := WaiterPadLine.Type;
                                                                                                                                   MergeToWaiterPadLine."No." := WaiterPadLine."No.";
                                                                                                                                   MergeToWaiterPadLine.Description := WaiterPadLine.Description;
                                                                                                                                   MergeToWaiterPadLine.Quantity := WaiterPadLine.Quantity;
                                                                                                                                   MergeToWaiterPadLine."Sale Type" := WaiterPadLine."Sale Type";
                                                                                                                                   MergeToWaiterPadLine."Description 2" := WaiterPadLine."Description 2";
                                                                                                                                   MergeToWaiterPadLine."Variant Code" := WaiterPadLine."Variant Code";
                                                                                                                                   MergeToWaiterPadLine."Order No. from Web" := WaiterPadLine."Order No. from Web";
                                                                                                                                   MergeToWaiterPadLine."Order Line No. from Web" := WaiterPadLine."Order Line No. from Web";
                                                                                                                                   MergeToWaiterPadLine."Unit Price" := WaiterPadLine."Unit Price";
                                                                                                                                   MergeToWaiterPadLine."Discount Type" := WaiterPadLine."Discount Type";
                                                                                                                                   MergeToWaiterPadLine."Discount Code" := WaiterPadLine."Discount Code";
                                                                                                                                   MergeToWaiterPadLine."Allow Invoice Discount" := WaiterPadLine."Allow Invoice Discount";
                                                                                                                                   MergeToWaiterPadLine."Allow Line Discount" := WaiterPadLine."Allow Line Discount";
                                                                                                                                   MergeToWaiterPadLine."Discount %" := WaiterPadLine."Discount %";
                                                                                                                                   MergeToWaiterPadLine."Discount Amount" := WaiterPadLine."Discount Amount";
                                                                                                                                   MergeToWaiterPadLine."Invoice Discount Amount" := WaiterPadLine."Invoice Discount Amount";
                                                                                                                                   MergeToWaiterPadLine."Currency Code" := WaiterPadLine."Currency Code";
                                                                                                                                   MergeToWaiterPadLine."Unit of Measure Code" := WaiterPadLine."Unit of Measure Code";

                                                                                                                                   MergeToWaiterPadLine.MODIFY(TRUE);

                                                                                                                                   //-NPR5.53 [360258]
                                                                                                                                   WPadLinePrintCategory.SETRANGE("Waiter Pad No.",WaiterPadLine."Waiter Pad No.");
                                                                                                                                   WPadLinePrintCategory.SETRANGE("Waiter Pad Line No.",WaiterPadLine."Line No.");
                                                                                                                                   IF WPadLinePrintCategory.FINDSET THEN
                                                                                                                                     REPEAT
                                                                                                                                       WPadLinePrintCategory2 := WPadLinePrintCategory;
                                                                                                                                       WPadLinePrintCategory2."Waiter Pad No." := MergeToWaiterPadLine."Waiter Pad No.";
                                                                                                                                       WPadLinePrintCategory2."Waiter Pad Line No." := MergeToWaiterPadLine."Line No.";
                                                                                                                                       WPadLinePrintCategory2.INSERT;
                                                                                                                                     UNTIL WPadLinePrintCategory.NEXT = 0;

                                                                                                                                   WPadLinePrntLogEntry.SETCURRENTKEY("Waiter Pad No.","Waiter Pad Line No.");
                                                                                                                                   WPadLinePrntLogEntry.SETRANGE("Waiter Pad No.",WaiterPadLine."Waiter Pad No.");
                                                                                                                                   WPadLinePrntLogEntry.SETRANGE("Waiter Pad Line No.",WaiterPadLine."Line No.");
                                                                                                                                   IF WPadLinePrntLogEntry.FINDSET THEN
                                                                                                                                     REPEAT
                                                                                                                                       WPadLinePrntLogEntry2 := WPadLinePrntLogEntry;
                                                                                                                                       WPadLinePrntLogEntry2."Waiter Pad No." := MergeToWaiterPadLine."Waiter Pad No.";
                                                                                                                                       WPadLinePrntLogEntry2."Waiter Pad Line No." := MergeToWaiterPadLine."Line No.";
                                                                                                                                       WPadLinePrntLogEntry2.MODIFY;
                                                                                                                                     UNTIL WPadLinePrntLogEntry.NEXT = 0;
                                                                                                                                   //+NPR5.53 [360258]

                                                                                                                                   WaiterPadLine.DELETE(TRUE);
                                                                                                                                   */
                                                                                                                                   //+NPR5.55 [399170]-revoked
            until (0 = WaiterPadLine.Next);
        end;

        //-NPR5.55 [399170]-revoked
        /*
        //-NPR5.53 [380918]
        WaiterPad."Number of Guests" := 0;
        WaiterPad."Billed Number of Guests" := 0;
        WaiterPad.MODIFY;
        //+NPR5.53 [380918]
        
        NPHWaiterPadPOSManagement.CloseWaiterPad(WaiterPad);
        */
        //+NPR5.55 [399170]-revoked
        CloseWaiterPad(WaiterPad, false);  //NPR5.55 [399170]
        exit(true);

    end;

    procedure CloseWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad"; ForceClose: Boolean)
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        Handled: Boolean;
        OK: Boolean;
    begin
        //-NPR5.55 [399170]/[384923] (Function moved from CU6150660)
        SetupProxy.InitializeUsingWaiterPad(WaiterPad);

        OnBeforeCloseWaiterPad(WaiterPad, SetupProxy, ForceClose, Handled);
        if Handled then
            exit;

        CleanupWaiterPad(WaiterPad);
        OK := ForceClose;
        if not OK then
            OK := WaiterPadCanBeClosed(WaiterPad, SetupProxy);
        if OK then begin
            WaiterPad."Close Date" := WorkDate;
            WaiterPad."Close Time" := Time;
            WaiterPad.Closed := true;
            WaiterPad.Modify;

            CloseWaiterPadSeatings(WaiterPad, SetupProxy);
        end else begin
            OK := WaiterPadSeatingsCanBeClosed(WaiterPad, SetupProxy);
            if OK then
                CloseWaiterPadSeatings(WaiterPad, SetupProxy);
        end;

        if OK then
            OnAfterCloseWaiterPad(WaiterPad);
        //+NPR5.55 [399170]/[384923]
    end;

    procedure CloseWaiterPadSeatings(var WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy")
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingWaiterPadLink2: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        //-NPR5.55 [399170]/[384923]
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        SeatingWaiterPadLink.SetRange(Closed, false);
        if SeatingWaiterPadLink.FindSet then
            repeat
                CloseWaiterPadSeatingLink(SeatingWaiterPadLink, SetupProxy);
            until SeatingWaiterPadLink.Next = 0;
        //+NPR5.55 [399170]/[384923]
    end;

    local procedure CloseWaiterPadSeatingLink(SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy")
    var
        SeatingWaiterPadLink2: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
    begin
        //-NPR5.55 [399170]/[384923]
        SeatingWaiterPadLink2 := SeatingWaiterPadLink;
        SeatingWaiterPadLink2.Closed := true;
        SeatingWaiterPadLink2.Modify;

        SeatingMgt.TrySetSeatingIsCleared(SeatingWaiterPadLink2."Seating Code", SetupProxy);
        //+NPR5.55 [399170]/[384923]
    end;

    local procedure CleanupWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
    begin
        //-NPR5.55 [399170] (Function moved from CU6150660)
        WaiterPadLine.Reset;
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter(Type, '<>%1', WaiterPadLine.Type::Comment);
        if not WaiterPadLine.IsEmpty then
            exit;

        WaiterPadLine.SetRange(Type, WaiterPadLine.Type::Comment);
        if not WaiterPadLine.IsEmpty then
            WaiterPadLine.DeleteAll(true);

        POSInfoWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        POSInfoWaiterPadLink.DeleteAll;

        OnAfterWaiterPadCleanup(WaiterPad);
        //+NPR5.55 [399170]
    end;

    local procedure WaiterPadCanBeClosed(WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy"): Boolean
    var
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        //-NPR5.55 [399170]/[384923]
        SetupProxy.GetServiceFlowProfile(ServiceFlowProfile);
        case ServiceFlowProfile."Close Waiter Pad On" of
            ServiceFlowProfile."Close Waiter Pad On"::"Pre-Receipt":
                exit(WaiterPad."Pre-receipt Printed");

            ServiceFlowProfile."Close Waiter Pad On"::"Pre-Receipt if Served":
                if WaiterPad."Pre-receipt Printed" then
                    exit(WPIsServed(WaiterPad, SetupProxy));

            ServiceFlowProfile."Close Waiter Pad On"::Payment:
                exit(WPIsPaid(WaiterPad));

            ServiceFlowProfile."Close Waiter Pad On"::"Payment if Served":
                if WPIsPaid(WaiterPad) then
                    exit(WPIsServed(WaiterPad, SetupProxy));
        end;

        exit(false);
        //+NPR5.55 [399170]/[384923]
    end;

    local procedure WaiterPadSeatingsCanBeClosed(WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy"): Boolean
    var
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        //-NPR5.55 [399170]/[384923]
        SetupProxy.GetServiceFlowProfile(ServiceFlowProfile);
        case ServiceFlowProfile."Clear Seating On" of
            ServiceFlowProfile."Clear Seating On"::"Waiter Pad Close":
                exit(WaiterPad.Closed);

            ServiceFlowProfile."Clear Seating On"::"Pre-Receipt":
                exit(WaiterPad."Pre-receipt Printed");

            ServiceFlowProfile."Clear Seating On"::"Pre-Receipt if Served":
                if WaiterPad."Pre-receipt Printed" then
                    exit(WPIsServed(WaiterPad, SetupProxy));
        end;

        exit(false);
        //+NPR5.55 [399170]/[384923]
    end;

    local procedure WPIsPaid(WaiterPad: Record "NPR NPRE Waiter Pad"): Boolean
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        //-NPR5.55 [399170]
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        if WaiterPadLine.FindSet then
            repeat
                if WaiterPadLine.Quantity > WaiterPadLine."Billed Quantity" then
                    exit(false);
            until WaiterPadLine.Next = 0;

        exit(true);
        //+NPR5.55 [399170]
    end;

    local procedure WPIsServed(WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy"): Boolean
    var
        FlowStatusTmp: Record "NPR NPRE Flow Status" temporary;
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenReqSourceParam: Record "NPR NPRE Kitchen Req.Src. Link";
        KitchenStationBuffer: Record "NPR NPRE Kitchen Station Slct." temporary;
        PrintCategoryTmp: Record "NPR NPRE Print/Prod. Cat." temporary;
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WPadLineBuffer: Record "NPR NPRE W.Pad.Line Outp.Buf." temporary;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        //-#NPR5.55 [384923]
        if not SetupProxy.KDSActivated() then
            exit(true);

        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter(Type, '<>%1', WaiterPadLine.Type::Comment);
        if WaiterPadLine.IsEmpty then
            exit(true);

        RestPrint.InitTempFlowStatusList(FlowStatusTmp, FlowStatusTmp."Status Object"::WaiterPadLineMealFlow);
        RestPrint.InitTempPrintCategoryList(PrintCategoryTmp);
        RestPrint.BufferEligibleForSendingWPadLines(
          WaiterPadLine, WaiterPadLine."Output Type Filter"::KDS, WaiterPadLine."Print Type Filter"::"Kitchen Order",
          FlowStatusTmp, PrintCategoryTmp, true, false, WPadLineBuffer);

        if WPadLineBuffer.FindSet then
            repeat
                if WaiterPadLine.Get(WPadLineBuffer."Waiter Pad No.", WPadLineBuffer."Waiter Pad Line No.") then
                    if KitchenOrderMgt.FindApplicableWPLineKitchenStations(
                        KitchenStationBuffer, WaiterPadLine, WPadLineBuffer."Serving Step", WPadLineBuffer."Print Category Code")
                    then begin
                        KitchenOrderMgt.InitKitchenReqSourceFromWaiterPadLine(
                          KitchenReqSourceParam, WaiterPadLine, KitchenStationBuffer."Restaurant Code", WPadLineBuffer."Serving Step", 0DT);
                        KitchenOrderMgt.FindKitchenRequests(KitchenRequest, KitchenReqSourceParam);
                        if not KitchenRequest.FindSet then
                            exit(false);
                        repeat
                            if KitchenRequest."Line Status" <> KitchenRequest."Line Status"::Served then
                                exit(false);
                        until KitchenRequest.Next = 0;
                    end;
            until WPadLineBuffer.Next = 0;

        exit(true);
        //+NPR5.55 [384923]
    end;

    procedure MoveNumberOfGuests(var FromWaiterPad: Record "NPR NPRE Waiter Pad"; var ToWaiterPad: Record "NPR NPRE Waiter Pad"; NumberOfGuests: Integer)
    begin
        //-NPR5.55 [399170]
        ToWaiterPad."Number of Guests" := NumberOfGuests;
        if ToWaiterPad."Number of Guests" < 0 then
            ToWaiterPad."Number of Guests" := 0;
        ToWaiterPad."Billed Number of Guests" := FromWaiterPad."Billed Number of Guests" - FromWaiterPad."Number of Guests" + ToWaiterPad."Number of Guests";
        if ToWaiterPad."Billed Number of Guests" < 0 then
            ToWaiterPad."Billed Number of Guests" := 0;
        ToWaiterPad.Modify;

        FromWaiterPad."Number of Guests" := FromWaiterPad."Number of Guests" - ToWaiterPad."Number of Guests";
        if FromWaiterPad."Number of Guests" < 0 then
            FromWaiterPad."Number of Guests" := 0;
        FromWaiterPad."Billed Number of Guests" := FromWaiterPad."Billed Number of Guests" - ToWaiterPad."Billed Number of Guests";
        if FromWaiterPad."Billed Number of Guests" < 0 then
            FromWaiterPad."Billed Number of Guests" := 0;
        FromWaiterPad.Modify;
        //+NPR5.55 [399170]
    end;

    procedure AssignedPrintCategoriesAsFilterString(AppliesToRecID: RecordID; OnlyForServingStepFilter: Text): Text
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        AssignedPrintCategories: Text;
        Include: Boolean;
    begin
        //-NPR5.55 [382428]
        FilterAssignedPrintCategories(AppliesToRecID, AssignedPrintCategory);
        AssignedPrintCategory.SetFilter("Print/Prod. Category Code", '<>%1', '');
        if not AssignedPrintCategory.FindSet then
            exit('');
        AssignedPrintCategories := '';
        repeat
            if OnlyForServingStepFilter <> '' then begin
                FilterAssignedFlowStatuses(AssignedPrintCategory.RecordId, AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow, AssignedFlowStatus);
                AssignedFlowStatus.SetFilter("Flow Status Code", OnlyForServingStepFilter);
                Include := not AssignedFlowStatus.IsEmpty;
                if not Include then begin
                    AssignedFlowStatus.SetRange("Flow Status Code");
                    Include := AssignedFlowStatus.IsEmpty;  //applicable on all steps
                end;
            end else
                Include := true;

            if Include then begin
                if AssignedPrintCategories <> '' then
                    AssignedPrintCategories := AssignedPrintCategories + '|';
                AssignedPrintCategories := AssignedPrintCategories + StrSubstNo(InQuotes, AssignedPrintCategory."Print/Prod. Category Code");
            end;
        until AssignedPrintCategory.Next = 0;
        exit(AssignedPrintCategories);
        //+NPR5.55 [382428]
    end;

    procedure FilterAssignedPrintCategories(AppliesToRecID: RecordID; var AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.")
    begin
        //-NPR5.55 [382428]
        AssignedPrintCategory.Reset;
        AssignedPrintCategory.SetRange("Table No.", AppliesToRecID.TableNo);
        AssignedPrintCategory.SetRange("Record ID", AppliesToRecID);
        //+NPR5.55 [382428]
    end;

    procedure AssignedFlowStatusesAsFilterString(AppliesToRecID: RecordID; StatusObject: Option; var AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status"): Text
    var
        AssignedFlowStatuses: Text;
    begin
        //-NPR5.55 [382428]
        FilterAssignedFlowStatuses(AppliesToRecID, StatusObject, AssignedFlowStatus);
        AssignedFlowStatus.SetFilter("Flow Status Code", '<>%1', '');
        if not AssignedFlowStatus.FindSet then
            exit('');
        AssignedFlowStatuses := '';
        repeat
            if AssignedFlowStatuses <> '' then
                AssignedFlowStatuses := AssignedFlowStatuses + '|';
            AssignedFlowStatuses := AssignedFlowStatuses + StrSubstNo(InQuotes, AssignedFlowStatus."Flow Status Code");
        until AssignedFlowStatus.Next = 0;
        exit(AssignedFlowStatuses);
        //+NPR5.55 [382428]
    end;

    procedure FilterAssignedFlowStatuses(AppliesToRecID: RecordID; StatusObject: Option; var AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status")
    begin
        //-NPR5.55 [382428]
        AssignedFlowStatus.Reset;
        AssignedFlowStatus.SetRange("Table No.", AppliesToRecID.TableNo);
        AssignedFlowStatus.SetRange("Record ID", AppliesToRecID);
        AssignedFlowStatus.SetRange("Flow Status Object", StatusObject);
        //+NPR5.55 [382428]
    end;

    procedure SelectPrintCategories(AppliesToRecID: RecordID)
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        AssignedFlowStatusTmp: Record "NPR NPRE Assigned Flow Status" temporary;
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        PrintCategoryList: Page "NPR NPRE Slct Prnt Cat.";
        Handled: Boolean;
    begin
        //-NPR5.55 [360258]/[382428]
        PrintCategory.Reset;

        FilterAssignedPrintCategories(AppliesToRecID, AssignedPrintCategory);
        if AssignedPrintCategory.FindSet then
            repeat
                if PrintCategory.Get(AssignedPrintCategory."Print/Prod. Category Code") then begin
                    PrintCategory.Mark := true;

                    FilterAssignedFlowStatuses(AssignedPrintCategory.RecordId, AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow, AssignedFlowStatus);
                    if AssignedFlowStatus.FindSet then
                        repeat
                            AssignedFlowStatusTmp := AssignedFlowStatus;
                            AssignedFlowStatusTmp.Insert;
                        until AssignedFlowStatus.Next = 0;
                end;
            until AssignedPrintCategory.Next = 0;
        Handled := true;

        OnBeforeSelectPrintCategories(AppliesToRecID, PrintCategory, Handled);
        if not Handled then
            exit;

        Clear(PrintCategoryList);
        PrintCategoryList.SetDataset(PrintCategory);
        PrintCategoryList.SetAssignedFlowStatusRecordset(AssignedFlowStatusTmp);
        PrintCategoryList.SetSourceRecID(AppliesToRecID);
        PrintCategoryList.SetMultiSelectionMode(true);
        PrintCategoryList.LookupMode(true);
        if PrintCategoryList.RunModal <> ACTION::LookupOK then
            exit;
        PrintCategoryList.GetDataset(PrintCategory);
        PrintCategoryList.GetAssignedFlowStatusRecordset(AssignedFlowStatusTmp);
        PrintCategory.MarkedOnly(true);

        Handled := false;
        OnAfterSelectPrintCategories(AppliesToRecID, PrintCategory, Handled);
        if Handled then
            exit;

        AssignedPrintCategory.DeleteAll(true);
        if PrintCategory.FindSet then
            repeat
                AssignedPrintCategory.Init;
                AssignedPrintCategory."Table No." := AppliesToRecID.TableNo;
                AssignedPrintCategory."Record ID" := AppliesToRecID;
                AssignedPrintCategory."Print/Prod. Category Code" := PrintCategory.Code;
                AssignedPrintCategory.Insert;

                FilterAssignedFlowStatuses(AssignedPrintCategory.RecordId, AssignedFlowStatusTmp."Flow Status Object"::WaiterPadLineMealFlow, AssignedFlowStatusTmp);
                if AssignedFlowStatusTmp.FindSet then
                    repeat
                        AssignedFlowStatus := AssignedFlowStatusTmp;
                        AssignedFlowStatus.Insert;
                    until AssignedFlowStatusTmp.Next = 0;
            until PrintCategory.Next = 0;

        AssignedFlowStatusTmp.Reset;
        AssignedFlowStatusTmp.DeleteAll;
        //+NPR5.55 [360258]/[382428]
    end;

    procedure AssignWPadLinePrintCategories(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; RemoveExisting: Boolean)
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        NewAssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        RestSetup: Record "NPR NPRE Restaurant Setup";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        Handled: Boolean;
    begin
        //-NPR5.55 [399170]/[382428]
        //(Moved from CU6150660)
        OnBeforeAssignWPadLinePrintCategories(WaiterPadLine, RemoveExisting, Handled);
        if Handled then
            exit;

        if RemoveExisting then
            ClearAssignedPrintCategories(WaiterPadLine.RecordId);

        if (WaiterPadLine.Type <> WaiterPadLine.Type::Item) or (WaiterPadLine."No." = '') then
            exit;

        case SetupProxy.ServingStepDiscoveryMethod() of
            RestSetup."Serving Step Discovery Method"::"Legacy (using print tags)":
                begin
                    if not (Item.Get(WaiterPadLine."No.") and (Item."NPR Print Tags" <> '')) then
                        exit;
                    PrintCategory.SetFilter("Print Tag", ConvertStr(Item."NPR Print Tags", ',', '|'));
                    if PrintCategory.FindSet then
                        repeat
                            AddAssignedPrintCategory(WaiterPadLine.RecordId, PrintCategory, NewAssignedPrintCategory);
                        until PrintCategory.Next = 0;
                    AssignWPadLineServingStepsFromPrintCategories(WaiterPadLine, RemoveExisting);
                end;

            RestSetup."Serving Step Discovery Method"::"Item Routing Profiles":
                begin
                    if not (Item.Get(WaiterPadLine."No.") and (Item."NPR NPRE Item Routing Profile" <> '')) then
                        exit;
                    ItemRoutingProfile.Get(Item."NPR NPRE Item Routing Profile");
                    CopyAssignedPrintCategories(ItemRoutingProfile.RecordId, WaiterPadLine.RecordId);
                    CopyAssignedFlowStatuses(ItemRoutingProfile.RecordId, WaiterPadLine.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);
                end;
        end;
        //+NPR5.55 [399170]/[382428]
    end;

    procedure AddAssignedPrintCategory(AppliesToRecID: RecordID; PrintCategory: Record "NPR NPRE Print/Prod. Cat."; var NewAssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.")
    begin
        //-NPR5.55 [399170]/[382428]
        //(Moved from CU6150660)
        NewAssignedPrintCategory.Init;
        NewAssignedPrintCategory."Table No." := AppliesToRecID.TableNo;
        NewAssignedPrintCategory."Record ID" := AppliesToRecID;
        NewAssignedPrintCategory."Print/Prod. Category Code" := PrintCategory.Code;
        if not NewAssignedPrintCategory.Find then
            NewAssignedPrintCategory.Insert;
        //+NPR5.55 [399170]/[382428]
    end;

    procedure ClearAssignedPrintCategories(AppliesToRecID: RecordID)
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
    begin
        //-NPR5.55 [399170]/[382428]
        //(Moved from CU6150660)
        FilterAssignedPrintCategories(AppliesToRecID, AssignedPrintCategory);
        if not AssignedPrintCategory.IsEmpty then
            AssignedPrintCategory.DeleteAll(true);
        //+NPR5.55 [399170]/[382428]
    end;

    procedure CopyAssignedPrintCategories(FromRecID: RecordID; ToRecID: RecordID)
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        NewAssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        FlowStatus: Record "NPR NPRE Flow Status";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
    begin
        //-NPR5.55 [399170]/[382428]
        ClearAssignedPrintCategories(ToRecID);
        FilterAssignedPrintCategories(FromRecID, AssignedPrintCategory);
        if AssignedPrintCategory.FindSet then
            repeat
                if PrintCategory.Get(AssignedPrintCategory."Print/Prod. Category Code") then begin
                    AddAssignedPrintCategory(ToRecID, PrintCategory, NewAssignedPrintCategory);

                    FilterAssignedFlowStatuses(AssignedPrintCategory.RecordId, AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow, AssignedFlowStatus);
                    if AssignedFlowStatus.FindSet then
                        repeat
                            if FlowStatus.Get(AssignedFlowStatus."Flow Status Code", AssignedFlowStatus."Flow Status Object") then
                                AddAssignedFlowStatus(NewAssignedPrintCategory.RecordId, FlowStatus);
                        until AssignedFlowStatus.Next = 0;
                end;
            until AssignedPrintCategory.Next = 0;
        //+NPR5.55 [399170]/[382428]
    end;

    procedure MoveAssignedPrintCategories(FromRecId: RecordID; ToRecId: RecordID)
    begin
        //-NPR5.55 [382428]
        CopyAssignedPrintCategories(FromRecId, ToRecId);
        ClearAssignedPrintCategories(FromRecId);
        //+NPR5.55 [382428]
    end;

    procedure SelectFlowStatuses(AppliesToRecID: RecordID; StatusObject: Option; var AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        FlowStatusList: Page "NPR NPRE Select Flow Status";
        Handled: Boolean;
    begin
        //-NPR5.55 [382428]
        FlowStatus.Reset;
        FlowStatus.FilterGroup(2);
        FlowStatus.SetRange("Status Object", StatusObject);
        FlowStatus.FilterGroup(0);

        case StatusObject of
            FlowStatus."Status Object"::WaiterPadLineMealFlow:
                begin
                    FilterAssignedFlowStatuses(AppliesToRecID, StatusObject, AssignedFlowStatus);
                    if AssignedFlowStatus.FindSet then
                        repeat
                            if FlowStatus.Get(AssignedFlowStatus."Flow Status Code", AssignedFlowStatus."Flow Status Object") then
                                FlowStatus.Mark := true;
                        until AssignedFlowStatus.Next = 0;
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
        if FlowStatusList.RunModal <> ACTION::LookupOK then
            exit;
        FlowStatusList.GetDataset(FlowStatus);
        FlowStatus.MarkedOnly(true);

        Handled := false;

        case StatusObject of
            FlowStatus."Status Object"::WaiterPadLineMealFlow:
                begin
                    AssignedFlowStatus.DeleteAll(true);
                    if FlowStatus.FindSet then
                        repeat
                            AssignedFlowStatus.Init;
                            AssignedFlowStatus."Table No." := AppliesToRecID.TableNo;
                            AssignedFlowStatus."Record ID" := AppliesToRecID;
                            AssignedFlowStatus."Flow Status Object" := FlowStatus."Status Object";
                            AssignedFlowStatus."Flow Status Code" := FlowStatus.Code;
                            AssignedFlowStatus.Insert;
                        until FlowStatus.Next = 0;
                    Handled := true;
                end;
        end;

        OnAfterSelectFlowStatuses(AppliesToRecID, StatusObject, FlowStatus, Handled);
        //+NPR5.55 [382428]
    end;

    procedure AssignWPadLineServingStepsFromPrintCategories(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; RemoveExisting: Boolean)
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        FlowStatus: Record "NPR NPRE Flow Status";
        Handled: Boolean;
    begin
        //-NPR5.55 [382428]
        if RemoveExisting then
            ClearAssignedFlowStatuses(WaiterPadLine.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);

        if (WaiterPadLine.Type <> WaiterPadLine.Type::Item) or (WaiterPadLine."No." = '') then
            exit;

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if FlowStatus.FindSet then
            repeat
                FilterAssignedPrintCategories(WaiterPadLine.RecordId, AssignedPrintCategory);
                AssignedPrintCategory.SetFilter("Print/Prod. Category Code", FlowStatus.AssignedPrintCategoriesAsFilterString());
                if AssignedPrintCategory.FindSet then begin
                    AddAssignedFlowStatus(WaiterPadLine.RecordId, FlowStatus);
                    repeat
                        AddAssignedFlowStatus(AssignedPrintCategory.RecordId, FlowStatus);
                    until AssignedPrintCategory.Next = 0;
                end;
            until FlowStatus.Next = 0;
        //+NPR5.55 [382428]
    end;

    procedure AddAssignedFlowStatus(AppliesToRecID: RecordID; FlowStatus: Record "NPR NPRE Flow Status")
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        //-NPR5.55 [382428]
        AssignedFlowStatus.Init;
        AssignedFlowStatus."Table No." := AppliesToRecID.TableNo;
        AssignedFlowStatus."Record ID" := AppliesToRecID;
        AssignedFlowStatus."Flow Status Object" := FlowStatus."Status Object";
        AssignedFlowStatus."Flow Status Code" := FlowStatus.Code;
        if not AssignedFlowStatus.Find then
            AssignedFlowStatus.Insert;
        //+NPR5.55 [382428]
    end;

    procedure ClearAssignedFlowStatuses(AppliesToRecID: RecordID; StatusObject: Option)
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        //-NPR5.55 [382428]
        FilterAssignedFlowStatuses(AppliesToRecID, StatusObject, AssignedFlowStatus);
        if not AssignedFlowStatus.IsEmpty then
            AssignedFlowStatus.DeleteAll(true);
        //+NPR5.55 [382428]
    end;

    procedure CopyAssignedFlowStatuses(FromRecId: RecordID; ToRecId: RecordID; StatusObject: Option)
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        //-NPR5.55 [382428]
        ClearAssignedFlowStatuses(ToRecId, StatusObject);
        FilterAssignedFlowStatuses(FromRecId, StatusObject, AssignedFlowStatus);
        if AssignedFlowStatus.FindSet then
            repeat
                if FlowStatus.Get(AssignedFlowStatus."Flow Status Code", AssignedFlowStatus."Flow Status Object") then
                    AddAssignedFlowStatus(ToRecId, FlowStatus);
            until AssignedFlowStatus.Next = 0;
        //+NPR5.55 [382428]
    end;

    procedure MoveAssignedFlowStatuses(FromRecId: RecordID; ToRecId: RecordID; StatusObject: Option)
    begin
        //-NPR5.55 [382428]
        CopyAssignedFlowStatuses(FromRecId, ToRecId, StatusObject);
        ClearAssignedFlowStatuses(FromRecId, StatusObject);
        //+NPR5.55 [382428]
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnBeforeAssignWPadLinePrintCategories(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; RemoveExisting: Boolean; var Handled: Boolean)
    begin
        //NPR5.55 [399170] (Moved from CU6150660)
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeSelectPrintCategories(AppliesToRecID: RecordID; var PrintCategory: Record "NPR NPRE Print/Prod. Cat."; var Handled: Boolean)
    begin
        //NPR5.55 [360258]
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSelectPrintCategories(AppliesToRecID: RecordID; var PrintCategory: Record "NPR NPRE Print/Prod. Cat."; var Handled: Boolean)
    begin
        //NPR5.55 [360258]
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeSelectFlowStatuses(AppliesToRecID: RecordID; StatusObject: Option; var FlowStatus: Record "NPR NPRE Flow Status"; var Handled: Boolean)
    begin
        //NPR5.55 [382428]
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSelectFlowStatuses(AppliesToRecID: RecordID; StatusObject: Option; var FlowStatus: Record "NPR NPRE Flow Status"; var Handled: Boolean)
    begin
        //NPR5.55 [382428]
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCloseWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad"; SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy"; var ForceClose: Boolean; var Handled: Boolean)
    begin
        //NPR5.55 [399170]
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCloseWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        //NPR5.55 [399170]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWaiterPadCleanup(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        //NPR5.55 [399170]
    end;
}

