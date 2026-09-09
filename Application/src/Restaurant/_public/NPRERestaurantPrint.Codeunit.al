codeunit 6150664 "NPR NPRE Restaurant Print"
{
    var
        _PrintTemplate: Record "NPR NPRE Print Templ.";
        _SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        _IsCancelledSale: Boolean;
        NoMoreMealGroupsLbl: Label 'No more meal groups left to be sent to the kitchen.';
        NothingToSendLbl: Label 'Nothing to send.';
        LinesHaveAlreadyBeenSent: Label 'One or more lines for %1 ''%2'' and %3 ''%4'' have already been sent to kitchent.\\Please select what do you want to do:\';
        ResendOptions: Label 'Send only new lines,Send all lines including previously sent';
        NowhereToSend: Label 'Neither Kitchen Printing nor KDS is activated. You need to activate at least one of them to be able to use this functionality.';

    internal procedure PrintWaiterPadPreReceiptPressed(WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        PrintWaiterPadToPreReceipt(WaiterPad);
    end;

    internal procedure PrintWaiterPadPreOrderToKitchenPressed(WaiterPad: Record "NPR NPRE Waiter Pad"; ForceResend: Boolean)
    begin
        PrintWaiterPadToKitchen(WaiterPad, _PrintTemplate."Print Type"::"Kitchen Order", '', ForceResend, true);
    end;

    internal procedure LinesAddedToWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Sentry: Codeunit "NPR Sentry";
        Confirmed: Boolean;
        PrintKitchOderConfMsg: Label 'Do you want to send the order to the kitchen now?';
    begin
        _SetupProxy.InitializeUsingWaiterPad(WaiterPad);
        case _SetupProxy.AutoSendKitchenOrder() of
            Enum::"NPR NPRE Auto Send Kitch.Order"::No:
                Confirmed := false;
            Enum::"NPR NPRE Auto Send Kitch.Order"::Yes:
                Confirmed := true;
            Enum::"NPR NPRE Auto Send Kitch.Order"::Ask:
                Confirmed := Sentry.Confirm(PrintKitchOderConfMsg, true);
        end;
        if Confirmed then
            PrintWaiterPadToKitchen(WaiterPad, _PrintTemplate."Print Type"::"Kitchen Order", '', false, false);
    end;

    local procedure PrintWaiterPadToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad"; PrintType: Integer; FlowStatusCode: Code[10]; ForceResend: Boolean; ShowMsgIfNothingToSend: Boolean): Boolean
    var
        NPHWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        NPHWaiterPadLine.Reset();
        NPHWaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        exit(PrintWaiterPadLinesToKitchen(WaiterPad, NPHWaiterPadLine, PrintType, FlowStatusCode, ForceResend, ShowMsgIfNothingToSend));
    end;

    internal procedure PrintWaiterPadLinesToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLineIn: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; FlowStatusCode: Code[10]; ForceResend: Boolean; ShowNothingToSendErr: Boolean): Boolean
    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        NewRestaurantPrintExp: Codeunit "NPR New Restaurant Print Exp.";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        ModifiersUpdated: Boolean;
        Result: Boolean;
        UseHandlerCodeunitRoute: Boolean;
    begin
        //A dish whose add-on lines changed is not eligible for sending itself, and removing its last add-on line leaves nothing
        //eligible at all. Reconcile the kitchen's copy before the routines below decide there is nothing to send: telling the
        //waiter "Nothing to send." rolls this back, so what was updated has to count as something sent.
        //Only for kitchen orders: the serving request flows read this return value as "the serving step was requested", and a
        //modifier reconcile is not a serving request.
        if PrintType = _PrintTemplate."Print Type"::"Kitchen Order" then
            ModifiersUpdated := KitchenOrderMgt.RefreshWaiterPadKitchenRequestModifiers(WaiterPad);

        //Both print implementations share this orchestration. They differ in two places, each branched where it happens
        //rather than by duplicating everything around it: AddPrintTemplatesToBuffer, which reads a different template
        //master table per route, and DispatchPrintJobs, which hands the job over differently. The feature flag is read
        //once here and the answer passed down, so the two cannot disagree, the flag is not re-read per buffered row, and
        //the span below cannot end up labelled for the route that did not run.
        UseHandlerCodeunitRoute := NewRestaurantPrintExp.IsFeatureEnabled();
        if UseHandlerCodeunitRoute then
            Sentry.StartSpan(Span, 'bc.restaurant.waiterpad.print-to-kitchen')
        else
            Sentry.StartSpan(Span, 'bc.restaurant.waiterpad.print-to-kitchen-legacy');
        Result := PrintWaiterPadLinesToKitchenImpl(WaiterPad, WaiterPadLineIn, PrintType, FlowStatusCode, ForceResend, ShowNothingToSendErr and not ModifiersUpdated, UseHandlerCodeunitRoute);
        Span.Finish();
        exit(Result or ModifiersUpdated);
    end;

    local procedure PrintWaiterPadLinesToKitchenImpl(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLineIn: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; FlowStatusCode: Code[10]; ForceResend: Boolean; ShowNothingToSendErr: Boolean; UseHandlerCodeunitRoute: Boolean): Boolean
    var
        TempFlowStatus: Record "NPR NPRE Flow Status" temporary;
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        TempWPadLineBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        TempPrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        PrintDateTime: DateTime;
        KDSUpdated: Boolean;
    begin
        InitTempFlowStatusList(TempFlowStatus, TempFlowStatus."Status Object"::WaiterPadLineMealFlow);
        if FlowStatusCode <> '' then
            TempFlowStatus.SetRange(Code, FlowStatusCode);

        if not BufferWPadLinesForSending(WaiterPad, WaiterPadLineIn, PrintType, TempFlowStatus, ForceResend, TempWPadLineBuffer) then begin
            if ShowNothingToSendErr then
                Error(NothingToSendLbl);
            exit(false);
        end;

        TempPrintTemplateBuffer.DeleteAll();
        PrintDateTime := CurrentDateTime;

        TempFlowStatus.SetCurrentKey("Status Object", "Flow Order");  //ensure serving steps are processed in correct order
        if TempFlowStatus.FindSet() then
            repeat
                TempWPadLineBuffer.SetRange("Serving Step", TempFlowStatus.Code);
                if TempWPadLineBuffer.FindFirst() then
                    repeat
                        TempWPadLineBuffer.SetRange("Output Type", TempWPadLineBuffer."Output Type");
                        repeat
                            WaiterPadLine.Reset();
                            TempWPadLineBuffer.SetRange("Print Category Code", TempWPadLineBuffer."Print Category Code");
                            TempWPadLineBuffer.FindSet();
                            repeat
                                if WaiterPadLine.Get(TempWPadLineBuffer."Waiter Pad No.", TempWPadLineBuffer."Waiter Pad Line No.") then
                                    WaiterPadLine.Mark := true;
                            until TempWPadLineBuffer.Next() = 0;

                            WaiterPadLine.MarkedOnly(true);
                            if not WaiterPadLine.IsEmpty then
                                case TempWPadLineBuffer."Output Type" of
                                    TempWPadLineBuffer."Output Type"::Print:
                                        if FindPrintTemplates(
                                            WaiterPad, WaiterPadLine, PrintType, TempWPadLineBuffer."Print Category Code", TempWPadLineBuffer."Serving Step", TempPrintTemplateBuffer, UseHandlerCodeunitRoute)
                                        then begin
                                            WaiterPadLine.FindSet();
                                            repeat
                                                LogWaiterPadLinePrint(
                                                    WaiterPadLine, PrintType, TempWPadLineBuffer."Serving Step", TempWPadLineBuffer."Print Category Code", PrintDateTime, 0, 0);
                                            until WaiterPadLine.Next() = 0;
                                        end;
                                    TempWPadLineBuffer."Output Type"::KDS:
                                        KDSUpdated :=
                                            KitchenOrderMgt.SendWPLinesToKitchen(
                                                WaiterPad, WaiterPadLine, TempWPadLineBuffer."Serving Step", TempWPadLineBuffer."Print Category Code", PrintType, PrintDateTime) or KDSUpdated;
                                end;

                            TempWPadLineBuffer.DeleteAll();
                            TempWPadLineBuffer.SetRange("Print Category Code");
                        until not TempWPadLineBuffer.FindFirst();  //Print category loop
                        TempWPadLineBuffer.SetRange("Output Type");
                    until not TempWPadLineBuffer.FindFirst();  //Output type loop
            until TempFlowStatus.Next() = 0;

        if TempPrintTemplateBuffer.IsEmpty and not KDSUpdated then begin
            if ShowNothingToSendErr then
                Error(NothingToSendLbl);
            exit(false);
        end;

        Commit();  //Print routine requires transaction to be ended
        DispatchPrintJobs(TempPrintTemplateBuffer, UseHandlerCodeunitRoute);
        exit(true);
    end;

    local procedure DispatchPrintJobs(var PrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer"; UseHandlerCodeunitRoute: Boolean)
    begin
        //Handing the job over is one of the two places the implementations genuinely differ - the other is
        //AddPrintTemplatesToBuffer, which reads a different template master table per route. Both are named for the
        //mechanism rather than for which came first: the "New Restaurant Print Experience" feature flag is the handler
        //codeunit route, and everything before it is the retail print template route.
        if UseHandlerCodeunitRoute then
            SendToPrintViaHandlerCodeunit(PrintTemplateBuffer)
        else
            SendToPrintViaRPTemplate(PrintTemplateBuffer);
    end;

    local procedure BufferWPadLinesForSending(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLineIn: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; var FlowStatus: Record "NPR NPRE Flow Status"; ForceResend: Boolean; var WPadLineBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer"): Boolean
    var
        TempPrintCategory: Record "NPR NPRE Print/Prod. Cat." temporary;
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        OutputType: Integer;
        AskResendConfirmation: Boolean;
        OutputTypeIsActive: Boolean;
    begin
        _SetupProxy.InitializeUsingWaiterPad(WaiterPad);
        if not (_SetupProxy.KitchenPrintingActivated() or _SetupProxy.KDSActivated()) then
            Error(NowhereToSend);

        WaiterPadLine.Copy(WaiterPadLineIn);
        WaiterPadLine.FilterGroup(2);
        WaiterPadLine.SetFilter("Line Type", '<>%1', WaiterPadLine."Line Type"::Comment);
        WaiterPadLine.FilterGroup(0);
        if WaiterPadLine.IsEmpty then
            exit(false);

        if not ForceResend then begin
            AskResendConfirmation := _SetupProxy.ResendAllOnNewLines() = Enum::"NPR NPRE Send All on New Lines"::Ask;
            if not AskResendConfirmation then
                ForceResend := _SetupProxy.ResendAllOnNewLines() = Enum::"NPR NPRE Send All on New Lines"::Yes;
        end;

        Sentry.StartSpan(Span, 'bc.restaurant.waiterpad.print-to-kitchen.buffer');

        WPadLineBuffer.Reset();
        WPadLineBuffer.DeleteAll();

        InitTempPrintCategoryList(TempPrintCategory);

        for OutputType := WaiterPadLine."Output Type Filter"::Print to WaiterPadLine."Output Type Filter"::KDS do begin
            case OutputType of
                WaiterPadLine."Output Type Filter"::Print:
                    OutputTypeIsActive := _SetupProxy.KitchenPrintingActivated() and (not _IsCancelledSale or _SetupProxy.PrintOnSaleCancelActivated());
                WaiterPadLine."Output Type Filter"::KDS:
                    OutputTypeIsActive := _SetupProxy.KDSActivated();
            end;
            if OutputTypeIsActive then
                BufferEligibleForSendingWPadLines(
                  WaiterPadLine, OutputType, PrintType, FlowStatus, TempPrintCategory, ForceResend, AskResendConfirmation, WPadLineBuffer);
        end;

        Span.Finish();
        exit(not WPadLineBuffer.IsEmpty());
    end;

    local procedure BufferEligibleForSendingWPadLines(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; OutputType: Integer; PrintType: Integer; var FlowStatus: Record "NPR NPRE Flow Status"; var PrintCategory: Record "NPR NPRE Print/Prod. Cat."; ForceResend: Boolean; AskResendConfirmation: Boolean; var WPadLineBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        PrintCategoryFilter: Text;
        SelectedSendOption: Option Cancel,"Only New",All;
        NextEntryNo: Integer;
    begin
        if WaiterPadLine.IsEmpty() or FlowStatus.IsEmpty() or PrintCategory.IsEmpty() then
            exit;

        Sentry.StartSpan(Span, 'bc.restaurant.waiterpad.buffer-eligible-lines');

        if WPadLineBuffer.FindLast() then
            NextEntryNo := WPadLineBuffer."Entry No." + 1
        else
            NextEntryNo := 1;

        FlowStatus.SetCurrentKey("Status Object", "Flow Order");
        FlowStatus.FindSet();
        repeat
            WaiterPadLine.FindSet();
            repeat
                PrintCategoryFilter := WaiterPadMgt.AssignedPrintCategoriesAsFilterString(WaiterPadLine.RecordId, FlowStatus.Code);
                if PrintCategoryFilter <> '' then
                    PrintCategory.SetFilter(Code, PrintCategoryFilter)
                else
                    PrintCategory.SetRange(Code, '');
                if PrintCategory.FindSet() then
                    repeat
                        if WPadLineIsInScopeForSending(WaiterPadLine, PrintType, OutputType, FlowStatus.Code, PrintCategory.Code) then begin
                            WaiterPadLine.CalcFields("Sent to Kitchen", "Sent to Kitchen Qty. (Base)");
                            if AskResendConfirmation then
                                if not ForceResend and WaiterPadLine."Sent to Kitchen" and
                                    (WaiterPadLine."Quantity (Base)" = WaiterPadLine."Sent to Kitchen Qty. (Base)")
                                then begin
                                    AskResendConfirmation := false;
                                    SelectedSendOption :=
                                      Sentry.StrMenu(ResendOptions, 1,
                                        StrSubstNo(LinesHaveAlreadyBeenSent, WaiterPad.FieldCaption("Serving Step Code"), FlowStatus.Code, PrintCategory.TableCaption, PrintCategory.Code));
                                    if SelectedSendOption = SelectedSendOption::Cancel then
                                        Error('');
                                    ForceResend := SelectedSendOption = SelectedSendOption::All;
                                end;

                            if not WaiterPadLine."Sent to Kitchen" or ForceResend or
                                (WaiterPadLine."Quantity (Base)" <> WaiterPadLine."Sent to Kitchen Qty. (Base)")
                            then begin
                                WPadLineBuffer."Entry No." := NextEntryNo;
                                NextEntryNo += 1;
                                WPadLineBuffer."Output Type" := OutputType;
                                WPadLineBuffer."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
                                WPadLineBuffer."Waiter Pad Line No." := WaiterPadLine."Line No.";
                                WPadLineBuffer."Print Category Code" := PrintCategory.Code;
                                WPadLineBuffer."Serving Step" := FlowStatus.Code;
                                WPadLineBuffer.Insert();
                            end;
                        end;
                    until PrintCategory.Next() = 0;
            until WaiterPadLine.Next() = 0;
        until FlowStatus.Next() = 0;

        Span.Finish();
    end;

    internal procedure AllEligibleKDSLinesServed(var WaiterPadLineParam: Record "NPR NPRE Waiter Pad Line"): Boolean
    var
        TempFlowStatus: Record "NPR NPRE Flow Status" temporary;
        TempPrintCategory: Record "NPR NPRE Print/Prod. Cat." temporary;
        TempWPadLineBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        //Which lines are outstanding is decided by the same eligibility rules that decide what gets sent. Both print
        //implementations now share those rules and one output buffer, so this no longer has to pick a side.

        //Taken by reference and copied, the same way BufferWPadLinesForSending does it. By reference because the caller's
        //filters are the only thing scoping this to one waiter pad, and an AL record parameter passed by value arrives
        //without them - measured on BC28, and the reason an earlier revision of this procedure scanned every waiter pad line
        //in the company. Copied because the buffering below leaves its own filters and a moved cursor on what it is handed.
        WaiterPadLine.Copy(WaiterPadLineParam);
        InitTempFlowStatusList(TempFlowStatus, TempFlowStatus."Status Object"::WaiterPadLineMealFlow);
        InitTempPrintCategoryList(TempPrintCategory);

        //ForceResend is forced on, so the buffer holds every line in scope for KDS output whether or not it was ever sent.
        //That is deliberate: an in-scope line the kitchen was never told about has no requests and therefore reads as
        //unserved below, and food nobody asked the kitchen for is not food that has been served.
        BufferEligibleForSendingWPadLines(
            WaiterPadLine, WaiterPadLine."Output Type Filter"::KDS, WaiterPadLine."Print Type Filter"::"Kitchen Order",
            TempFlowStatus, TempPrintCategory, true, false, TempWPadLineBuffer);
        if TempWPadLineBuffer.FindSet() then
            repeat
                if not WPadLineIsServed(
                    TempWPadLineBuffer."Waiter Pad No.", TempWPadLineBuffer."Waiter Pad Line No.",
                    TempWPadLineBuffer."Serving Step", TempWPadLineBuffer."Print Category Code")
                then
                    exit(false);
            until TempWPadLineBuffer.Next() = 0;
        exit(true);
    end;

    local procedure WPadLineIsServed(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; ServingStep: Code[10]; PrintCategoryCode: Code[20]): Boolean
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenReqSource: Record "NPR NPRE Kitchen Req.Src. Link";
        TempKitchenStationBuffer: Record "NPR NPRE Kitchen Station Slct." temporary;
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        LineGoneTok: Label 'served: the line was buffered as eligible but no longer exists', Locked = true;
        NoKitchenRequestsTok: Label 'unserved: no kitchen requests found for the line', Locked = true;
        NoStationsTok: Label 'served: routing resolves no kitchen station for the line''s current seating', Locked = true;
        RequestNotServedTok: Label 'unserved: a kitchen request is not yet served', Locked = true;
    begin
        //The line was buffered as eligible moments ago but is no longer there, so there is nothing left to serve.
        if not WaiterPadLine.Get(WaiterPadNo, WaiterPadLineNo) then begin
            LogServedCheckOutcome(WaiterPadNo, WaiterPadLineNo, ServingStep, PrintCategoryCode, LineGoneTok);
            exit(true);
        end;

        //Routing does not resolve for this line's current seating, so it is treated as nothing outstanding.
        //This asks whether routing resolves *now*, not whether anything was ever routed to produce the line, and the two
        //diverge once a pad moves seating: ChangeSeating relinks without re-routing, so a pad moved to a location whose
        //restaurant has no matching station selection reports every line served while the kitchen is still cooking.
        //Note the asymmetry with the FindKitchenRequestsForSourceDoc guard further down, which reads its own absence of
        //evidence the other way: no stations resolved means served, no requests found means unserved. Pre-existing, and
        //the mirror of the cancelled-request case in CORE-1961 - both infer a serving state from something missing.
        //This branch is the one that frees a table early, so it is logged even though it answers in the affirmative.
        if not KitchenOrderMgt.FindApplicableWPLineKitchenStations(
            TempKitchenStationBuffer, WaiterPadLine, ServingStep, PrintCategoryCode)
        then begin
            LogServedCheckOutcome(WaiterPadNo, WaiterPadLineNo, ServingStep, PrintCategoryCode, NoStationsTok);
            exit(true);
        end;

        KitchenOrderMgt.InitKitchenReqSourceFromWaiterPadLine(
            KitchenReqSource, WaiterPadLine, TempKitchenStationBuffer."Restaurant Code", '', '', ServingStep, 0DT);
        KitchenRequest.Reset();
        KitchenOrderMgt.FindKitchenRequestsForSourceDoc(KitchenRequest, KitchenReqSource);
        if not KitchenRequest.FindSet() then begin
            LogServedCheckOutcome(WaiterPadNo, WaiterPadLineNo, ServingStep, PrintCategoryCode, NoKitchenRequestsTok);
            exit(false);
        end;
        repeat
            if KitchenRequest."Line Status" <> KitchenRequest."Line Status"::Served then begin
                LogServedCheckOutcome(WaiterPadNo, WaiterPadLineNo, ServingStep, PrintCategoryCode, RequestNotServedTok);
                exit(false);
            end;
        until KitchenRequest.Next() = 0;
        exit(true);
    end;

    local procedure LogServedCheckOutcome(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; ServingStep: Code[10]; PrintCategoryCode: Code[20]; Outcome: Text)
    var
        Sentry: Codeunit "NPR Sentry";
        ServedCheckKeyTok: Label 'npre.waiterpad.%1.line-%2.served-check', Locked = true;
        ServedCheckDetailsTok: Label 'serving step ''%1'', print category ''%2'': %3', Locked = true;
    begin
        //Both directions are recorded, not just the vetoes. A false blocks the pad close and TryCloseWaiterPad discards it
        //with no error - the symptom this change set exists to make diagnosable - but the two affirmative-on-absence paths
        //are worse when they are wrong: the pad closes and the seating clears while the kitchen is still cooking, and
        //nobody notices until the food arrives at a reseated table.
        //
        //Keyed per pad and line rather than by a constant. The Sentry scope is the whole transaction and the data is
        //last-write-wins, while TryCloseWaiterPad runs once per posted sales line and once per kitchen request source
        //link - so a constant key would leave a sale spanning several pads reporting only whichever was checked last.
        Sentry.AddTransactionData(
            StrSubstNo(ServedCheckKeyTok, WaiterPadNo, WaiterPadLineNo),
            StrSubstNo(ServedCheckDetailsTok, ServingStep, PrintCategoryCode, Outcome));
    end;

    local procedure WPadLineIsInScopeForSending(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; OutputType: Integer; ServingStepCode: Code[10]; PrintCategoryCode: Code[20]): Boolean
    begin
        WaiterPadLine.SetRange("Print Type Filter", PrintType);
        WaiterPadLine.SetRange("Output Type Filter", OutputType);
        WaiterPadLine.SetRange("Serving Step Filter", ServingStepCode);
        WaiterPadLine.SetRange("Print Category Filter", PrintCategoryCode);

        exit(
          ((WaiterPadLine.NoOfServingSteps() > 0) or
           ((WaiterPadLine.TotalNoOfServingSteps() = 0) and (ServingStepCode = '')))
          and
          ((WaiterPadLine.NoOfPrintCategories() > 0) or
           ((WaiterPadLine.TotalNoOfPrintCategories() = 0) and (PrintCategoryCode = ''))));
    end;

    local procedure PrintWaiterPadToPreReceipt(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        if FindAndPrintTemplates(WaiterPad, WaiterPadLine, _PrintTemplate."Print Type"::"Pre Receipt", '', '') then begin
            SetWaiterPadPreReceiptPrinted(WaiterPad, true, true);
            WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::Undefined);
        end;
    end;

    local procedure FindAndPrintTemplates(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; PrintCategoryCode: Code[20]; ServingStep: Code[10]): Boolean
    var
        TempPrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        NewRestaurantPrintExp: Codeunit "NPR New Restaurant Print Exp.";
        UseHandlerCodeunitRoute: Boolean;
    begin
        //Finding the templates is shared. Which template master table is read, and how the job is handed over, are not:
        //the handler codeunit route runs a codeunit named on the template, the retail print template route resolves an
        //"NPR RP Template Header" and prints it directly. Resolved once here and passed to both.
        UseHandlerCodeunitRoute := NewRestaurantPrintExp.IsFeatureEnabled();
        TempPrintTemplateBuffer.DeleteAll();
        if not FindPrintTemplates(WaiterPad, WaiterPadLine, PrintType, PrintCategoryCode, ServingStep, TempPrintTemplateBuffer, UseHandlerCodeunitRoute) then
            exit(false);

        DispatchPrintJobs(TempPrintTemplateBuffer, UseHandlerCodeunitRoute);
        exit(true);
    end;

    local procedure SendToPrintViaRPTemplate(var PrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer")
    var
        PrintTemplate: Record "NPR RP Template Header";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin
        Sentry.StartSpan(Span, 'bc.restaurant.waiterpad.send-to-print-legacy');
        if PrintTemplateBuffer.FindFirst() then
            repeat
                //The group is spelled out rather than taken from SetRecFilter(), which filters the fields of the current
                //key. That was the whole group on the old buffer, whose primary key was these six fields; on the shared
                //buffer the primary key is the surrogate "Entry No.", so SetRecFilter() would select a single row and
                //each waiter pad line would be printed as its own job. SendToPrintViaHandlerCodeunit spells out the same
                //group for the same reason. No key on the shared buffer expresses this one - Key2 carries "Codeunit ID"
                //where the legacy route needs "Print Template Code" - so SetCurrentKey is not a shortcut here either.
                //Group membership is identical to the old buffer's; the order the groups come out in is not. The old
                //buffer had one key and walked groups in "Print Template Code"/"Serving Step"/"Print Category Code"
                //order. Here the current key is "Entry No.", so groups come out in insertion order, which is serving
                //step "Flow Order" - starter ticket before main course rather than alphabetical by template code. That
                //is the better order for a kitchen and is why no SetCurrentKey is added to restore the old one. Order
                //within a group is unaffected: the print below iterates the waiter pad line's own key, not this buffer.
                PrintTemplateBuffer.SetRange("Output Type", PrintTemplateBuffer."Output Type");
                PrintTemplateBuffer.SetRange("Waiter Pad No.", PrintTemplateBuffer."Waiter Pad No.");
                PrintTemplateBuffer.SetRange("Print Template Code", PrintTemplateBuffer."Print Template Code");
                PrintTemplateBuffer.SetRange("Serving Step", PrintTemplateBuffer."Serving Step");
                PrintTemplateBuffer.SetRange("Print Category Code", PrintTemplateBuffer."Print Category Code");
                PrintTemplateBuffer.SetRange("Waiter Pad Line No.");

                PrintTemplate.Get(PrintTemplateBuffer."Print Template Code");
                PrintTemplate.CalcFields("Table ID");
                case PrintTemplate."Table ID" of
                    DATABASE::"NPR NPRE Waiter Pad":
                        begin
                            WaiterPad.Get(PrintTemplateBuffer."Waiter Pad No.");
                            WaiterPad.SetRecFilter();
                            RPTemplateMgt.PrintTemplate(PrintTemplate.Code, WaiterPad, 0);
                        end;

                    DATABASE::"NPR NPRE Waiter Pad Line":
                        begin
                            WaiterPadLine.Reset();
                            PrintTemplateBuffer.FindSet();
                            repeat
                                WaiterPadLine.Get(PrintTemplateBuffer."Waiter Pad No.", PrintTemplateBuffer."Waiter Pad Line No.");
                                WaiterPadLine.Mark(true);
                                KitchenPrintMgt.AddComments(WaiterPadLine);
                            until PrintTemplateBuffer.Next() = 0;
                            WaiterPadLine.SetRange("Waiter Pad No.", PrintTemplateBuffer."Waiter Pad No.");
                            WaiterPadLine.SetRange("Print Category Filter", PrintTemplateBuffer."Print Category Code");
                            WaiterPadLine.MarkedOnly(true);
                            RPTemplateMgt.PrintTemplate(PrintTemplate.Code, WaiterPadLine, 0);
                        end;
                end;

                PrintTemplateBuffer.DeleteAll();
                PrintTemplateBuffer.Reset();
            until not PrintTemplateBuffer.FindFirst();
        Span.Finish();
    end;

    local procedure SendToPrintViaHandlerCodeunit(var PrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer")
    var
        TempJobBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin
        if not PrintTemplateBuffer.FindFirst() then
            exit;

        Sentry.StartSpan(Span, 'bc.restaurant.waiterpad.send-to-print');
        repeat
            PrintTemplateBuffer.SetRange("Output Type", PrintTemplateBuffer."Output Type");
            PrintTemplateBuffer.SetRange("Waiter Pad No.", PrintTemplateBuffer."Waiter Pad No.");
            PrintTemplateBuffer.SetRange("Codeunit ID", PrintTemplateBuffer."Codeunit ID");
            PrintTemplateBuffer.SetRange("Serving Step", PrintTemplateBuffer."Serving Step");
            PrintTemplateBuffer.SetRange("Print Category Code", PrintTemplateBuffer."Print Category Code");
            PrintTemplateBuffer.SetRange("Waiter Pad Line No.");

            TempJobBuffer.Reset();
            TempJobBuffer.DeleteAll();
            if PrintTemplateBuffer.FindSet() then
                repeat
                    TempJobBuffer := PrintTemplateBuffer;
                    TempJobBuffer.Insert();
                until PrintTemplateBuffer.Next() = 0;
            Codeunit.Run(PrintTemplateBuffer."Codeunit ID", TempJobBuffer);

            PrintTemplateBuffer.DeleteAll();
            PrintTemplateBuffer.Reset();
        until not PrintTemplateBuffer.FindFirst();
        Span.Finish();
    end;

    local procedure FindPrintTemplates(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; PrintCategoryCode: Code[20]; ServingStep: Code[10]; var PrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer"; UseHandlerCodeunitRoute: Boolean) TemplateFound: Boolean
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        TempSeatingLocation: Record "NPR NPRE Seating Location" temporary;
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        RestaurantCodes: List of [Code[20]];
        RestaurantCode: Code[20];
        FindForBlankLocation: Boolean;
    begin
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        if SeatingWaiterPadLink.FindSet() then
            repeat
                if Seating.Get(SeatingWaiterPadLink."Seating Code") then
                    if Seating."Seating Location" <> '' then begin
                        SeatingLocation.Code := Seating."Seating Location";
                        if not SeatingLocation.Find() then
                            SeatingLocation.Init();
                        TempSeatingLocation := SeatingLocation;
                        TempSeatingLocation.Insert();
                    end;
            until SeatingWaiterPadLink.Next() = 0;

        TemplateFound := false;
        FindForBlankLocation := not TempSeatingLocation.FindSet();
        if FindForBlankLocation then
            RestaurantCodes.Add('')
        else
            repeat
                if AddPrintTemplatesToBuffer(PrintTemplateBuffer, WaiterPadLine, TempSeatingLocation, PrintType, PrintCategoryCode, ServingStep, UseHandlerCodeunitRoute) then
                    TemplateFound := true
                else begin
                    if not RestaurantCodes.Contains(TempSeatingLocation."Restaurant Code") then
                        RestaurantCodes.Add(TempSeatingLocation."Restaurant Code");
                    FindForBlankLocation := true;
                end;
            until TempSeatingLocation.Next() = 0;

        if FindForBlankLocation then begin
            Clear(TempSeatingLocation);
            foreach RestaurantCode in RestaurantCodes do begin
                TempSeatingLocation."Restaurant Code" := RestaurantCode;
                if AddPrintTemplatesToBuffer(PrintTemplateBuffer, WaiterPadLine, TempSeatingLocation, PrintType, PrintCategoryCode, ServingStep, UseHandlerCodeunitRoute) then
                    TemplateFound := true;
            end;
        end;
    end;

    local procedure AddPrintTemplatesToBuffer(var PrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer";
                                            var WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
                                            SeatingLocation: Record "NPR NPRE Seating Location";
                                            PrintType: Integer;
                                            PrintCategoryCode: Code[20];
                                            ServingStep: Code[10];
                                            UseHandlerCodeunitRoute: Boolean): Boolean
    begin
        //The two routes read different template master tables - one names a retail print template, the other a
        //handler codeunit - so this is a real fork rather than duplication. The buffer they fill is the same either way.
        //The route is resolved once per print run and passed in, so this and DispatchPrintJobs cannot disagree.
        if UseHandlerCodeunitRoute then
            exit(AddHandlerCodeunitJobsToBuffer(PrintTemplateBuffer, WaiterPadLine, SeatingLocation, PrintType, PrintCategoryCode, ServingStep));
        exit(AddRPTemplateJobsToBuffer(PrintTemplateBuffer, WaiterPadLine, SeatingLocation, PrintType, PrintCategoryCode, ServingStep));
    end;

    local procedure AddHandlerCodeunitJobsToBuffer(var PrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer";
                                            var WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
                                            SeatingLocation: Record "NPR NPRE Seating Location";
                                            PrintType: Integer;
                                            PrintCategoryCode: Code[20];
                                            ServingStep: Code[10]): Boolean
    var
        PrintTemplate: Record "NPR NPRE Print Template";
        BufferPrintCategoryCode: Code[20];
        BufferServingStep: Code[10];
        NextEntryNo: Integer;
    begin
        PrintTemplate.SetRange("Print Type", PrintType);
        PrintTemplate.SetRange("Seating Location", SeatingLocation.Code);
        PrintTemplate.SetRange("Print Category Code", PrintCategoryCode);
        PrintTemplate.SetRange("Restaurant Code", SeatingLocation."Restaurant Code");
        PrintTemplate.SetRange("Serving Step", ServingStep);
        if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
            PrintTemplate.SetRange("Print Category Code", '');
        if PrintTemplate.IsEmpty and (ServingStep <> '') then begin
            if PrintCategoryCode <> '' then
                PrintTemplate.SetRange("Print Category Code", PrintCategoryCode);
            PrintTemplate.SetRange("Serving Step", '');
            if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
                PrintTemplate.SetRange("Print Category Code", '');
        end;

        if PrintTemplate.IsEmpty and (SeatingLocation."Restaurant Code" <> '') then begin
            PrintTemplate.SetRange("Restaurant Code", '');
            PrintTemplate.SetRange("Serving Step", ServingStep);
            PrintTemplate.SetRange("Print Category Code", PrintCategoryCode);
            if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
                PrintTemplate.SetRange("Print Category Code", '');
            if PrintTemplate.IsEmpty and (ServingStep <> '') then begin
                if PrintCategoryCode <> '' then
                    PrintTemplate.SetRange("Print Category Code", PrintCategoryCode);
                PrintTemplate.SetRange("Serving Step", '');
                if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
                    PrintTemplate.SetRange("Print Category Code", '');
            end;
        end;
        if not PrintTemplate.FindSet() then
            exit(false);

        if PrintTemplateBuffer.FindLast() then
            NextEntryNo := PrintTemplateBuffer."Entry No." + 1
        else
            NextEntryNo := 1;

        repeat
            BufferPrintCategoryCode := '';
            BufferServingStep := '';
            if PrintTemplate."Split Print Jobs By" in [PrintTemplate."Split Print Jobs By"::"Print Category", PrintTemplate."Split Print Jobs By"::Both] then
                BufferPrintCategoryCode := PrintCategoryCode;
            if PrintTemplate."Split Print Jobs By" in [PrintTemplate."Split Print Jobs By"::"Serving Step", PrintTemplate."Split Print Jobs By"::Both] then
                BufferServingStep := ServingStep;

            if WaiterPadLine.FindSet() then
                repeat
                    //Same duplicate guard as the retail print template route, and needed here for the same reason:
                    //FindPrintTemplates calls this once per seating location the pad is linked to and again for a blank
                    //location, so a pad spanning two locations that both fall back to one generic template resolves that
                    //template twice. The legacy buffer got this for free from its primary key; the shared buffer is keyed
                    //by a surrogate entry number, so it has to be spelled out. Without it SendToPrintViaHandlerCodeunit
                    //groups both copies into a single job - it does not filter "Entry No." - and the handler prints every
                    //dish twice on one ticket, with no error and nothing in telemetry.
                    PrintTemplateBuffer.Reset();
                    PrintTemplateBuffer.SetRange("Waiter Pad No.", WaiterPadLine."Waiter Pad No.");
                    PrintTemplateBuffer.SetRange("Waiter Pad Line No.", WaiterPadLine."Line No.");
                    PrintTemplateBuffer.SetRange("Codeunit ID", PrintTemplate."Codeunit ID");
                    PrintTemplateBuffer.SetRange("Print Category Code", BufferPrintCategoryCode);
                    PrintTemplateBuffer.SetRange("Serving Step", BufferServingStep);
                    if PrintTemplateBuffer.IsEmpty() then begin
                        PrintTemplateBuffer.Reset();
                        PrintTemplateBuffer.Init();
                        PrintTemplateBuffer."Entry No." := NextEntryNo;
                        NextEntryNo += 1;
                        PrintTemplateBuffer."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
                        PrintTemplateBuffer."Waiter Pad Line No." := WaiterPadLine."Line No.";
                        PrintTemplateBuffer."Codeunit ID" := PrintTemplate."Codeunit ID";
                        PrintTemplateBuffer."Print Category Code" := BufferPrintCategoryCode;
                        PrintTemplateBuffer."Serving Step" := BufferServingStep;
                        PrintTemplateBuffer.Insert();
                    end;
                    PrintTemplateBuffer.Reset();
                until WaiterPadLine.Next() = 0;
        until PrintTemplate.Next() = 0;
        exit(true);
    end;

    local procedure AddRPTemplateJobsToBuffer(var PrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer";
                                            var WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
                                            SeatingLocation: Record "NPR NPRE Seating Location";
                                            PrintType: Integer;
                                            PrintCategoryCode: Code[20];
                                            ServingStep: Code[10]): Boolean
    var
        PrintTemplate: Record "NPR NPRE Print Templ.";
        BufferPrintCategoryCode: Code[20];
        BufferServingStep: Code[10];
        NextEntryNo: Integer;
    begin
        if PrintTemplateBuffer.FindLast() then
            NextEntryNo := PrintTemplateBuffer."Entry No." + 1
        else
            NextEntryNo := 1;

        PrintTemplate.SetRange("Print Type", PrintType);
        PrintTemplate.SetRange("Seating Location", SeatingLocation.Code);
        PrintTemplate.SetRange("Print Category Code", PrintCategoryCode);
        PrintTemplate.SetRange("Restaurant Code", SeatingLocation."Restaurant Code");
        PrintTemplate.SetRange("Serving Step", ServingStep);
        if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
            PrintTemplate.SetRange("Print Category Code", '');
        if PrintTemplate.IsEmpty and (ServingStep <> '') then begin
            if PrintCategoryCode <> '' then
                PrintTemplate.SetRange("Print Category Code", PrintCategoryCode);
            PrintTemplate.SetRange("Serving Step", '');
            if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
                PrintTemplate.SetRange("Print Category Code", '');
        end;

        if PrintTemplate.IsEmpty and (SeatingLocation."Restaurant Code" <> '') then begin
            PrintTemplate.SetRange("Restaurant Code", '');
            PrintTemplate.SetRange("Serving Step", ServingStep);
            PrintTemplate.SetRange("Print Category Code", PrintCategoryCode);
            if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
                PrintTemplate.SetRange("Print Category Code", '');
            if PrintTemplate.IsEmpty and (ServingStep <> '') then begin
                if PrintCategoryCode <> '' then
                    PrintTemplate.SetRange("Print Category Code", PrintCategoryCode);
                PrintTemplate.SetRange("Serving Step", '');
                if PrintTemplate.IsEmpty and (PrintCategoryCode <> '') then
                    PrintTemplate.SetRange("Print Category Code", '');
            end;
        end;
        if not PrintTemplate.FindSet() then
            exit(false);
        repeat
            if WaiterPadLine.FindSet() then
                repeat
                    BufferPrintCategoryCode := '';
                    BufferServingStep := '';
                    if PrintTemplate."Split Print Jobs By" in [PrintTemplate."Split Print Jobs By"::"Print Category", PrintTemplate."Split Print Jobs By"::Both] then
                        BufferPrintCategoryCode := PrintCategoryCode;
                    if PrintTemplate."Split Print Jobs By" in [PrintTemplate."Split Print Jobs By"::"Serving Step", PrintTemplate."Split Print Jobs By"::Both] then
                        BufferServingStep := ServingStep;

                    //This used to be a Find on the legacy buffer's primary key. The shared buffer is keyed by a
                    //surrogate entry number instead, so the same guard is written out here. It is not redundant:
                    //FindPrintTemplates calls this once per seating location and again for a blank location, so two
                    //locations resolving to the same template would otherwise queue the same line twice.
                    //AddHandlerCodeunitJobsToBuffer carries the same guard, keyed on "Codeunit ID" where this one is
                    //keyed on "Print Template Code" - that is the only difference between them.
                    PrintTemplateBuffer.Reset();
                    PrintTemplateBuffer.SetRange("Waiter Pad No.", WaiterPadLine."Waiter Pad No.");
                    PrintTemplateBuffer.SetRange("Waiter Pad Line No.", WaiterPadLine."Line No.");
                    PrintTemplateBuffer.SetRange("Print Template Code", PrintTemplate."Template Code");
                    PrintTemplateBuffer.SetRange("Print Category Code", BufferPrintCategoryCode);
                    PrintTemplateBuffer.SetRange("Serving Step", BufferServingStep);
                    if PrintTemplateBuffer.IsEmpty() then begin
                        PrintTemplateBuffer.Reset();
                        PrintTemplateBuffer.Init();
                        PrintTemplateBuffer."Entry No." := NextEntryNo;
                        NextEntryNo += 1;
                        PrintTemplateBuffer."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
                        PrintTemplateBuffer."Waiter Pad Line No." := WaiterPadLine."Line No.";
                        PrintTemplateBuffer."Print Template Code" := PrintTemplate."Template Code";
                        PrintTemplateBuffer."Print Category Code" := BufferPrintCategoryCode;
                        PrintTemplateBuffer."Serving Step" := BufferServingStep;
                        PrintTemplateBuffer.Insert();
                    end;
                    PrintTemplateBuffer.Reset();
                until WaiterPadLine.Next() = 0;
        until PrintTemplate.Next() = 0;
        exit(true);
    end;

    internal procedure LogWaiterPadLinePrint(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; FlowStatusCode: Code[10]; PrintCategoryCode: Code[20]; PrintDateTime: DateTime; OutputType: Integer; OrderID: BigInteger)
    var
        NewWPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        NewWPadLinePrintLogEntry.Init();
        NewWPadLinePrintLogEntry."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
        NewWPadLinePrintLogEntry."Waiter Pad Line No." := WaiterPadLine."Line No.";
        NewWPadLinePrintLogEntry."Print Type" := PrintType;
        NewWPadLinePrintLogEntry."Print Category Code" := PrintCategoryCode;
        NewWPadLinePrintLogEntry."Flow Status Object" := NewWPadLinePrintLogEntry."Flow Status Object"::WaiterPadLineMealFlow;
        NewWPadLinePrintLogEntry."Flow Status Code" := FlowStatusCode;
        NewWPadLinePrintLogEntry."Sent Date-Time" := PrintDateTime;
        NewWPadLinePrintLogEntry."Output Type" := OutputType;
        NewWPadLinePrintLogEntry."Kitchen Order ID" := OrderID;

        WaiterPadLine.SetRange("Print Type Filter", NewWPadLinePrintLogEntry."Print Type");
        WaiterPadLine.SetRange("Serving Step Filter", NewWPadLinePrintLogEntry."Flow Status Code");
        WaiterPadLine.SetRange("Print Category Filter", NewWPadLinePrintLogEntry."Print Category Code");
        WaiterPadLine.SetRange("Output Type Filter", NewWPadLinePrintLogEntry."Output Type");
        WaiterPadLine.CalcFields("Sent to Kitchen Qty. (Base)");

        NewWPadLinePrintLogEntry."Sent Quanity (Base)" := WaiterPadLine."Quantity (Base)" - WaiterPadLine."Sent to Kitchen Qty. (Base)";

        InsertWaiterPadLinePrintLogEntry(NewWPadLinePrintLogEntry);
    end;

    internal procedure InsertWaiterPadLinePrintLogEntry(var NewWPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry")
    begin
        NewWPadLinePrintLogEntry."Entry No." := 0;
        NewWPadLinePrintLogEntry.Insert();
    end;

    internal procedure SplitWaiterPadLinePrintLogEntries(FromWaiterPadLine: Record "NPR NPRE Waiter Pad Line"; NewWaiterPadLine: Record "NPR NPRE Waiter Pad Line"; FullLineTransfer: Boolean)
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
        NewWPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        WPadLinePrintLogEntry.SetCurrentKey(
          "Waiter Pad No.", "Waiter Pad Line No.", "Print Type", "Print Category Code", "Flow Status Object", "Flow Status Code", "Output Type");
        WPadLinePrintLogEntry.SetRange("Waiter Pad No.", FromWaiterPadLine."Waiter Pad No.");
        WPadLinePrintLogEntry.SetRange("Waiter Pad Line No.", FromWaiterPadLine."Line No.");
        if WPadLinePrintLogEntry.FindSet() then
            repeat
                NewWPadLinePrintLogEntry := WPadLinePrintLogEntry;
                if FullLineTransfer then begin
                    NewWPadLinePrintLogEntry."Waiter Pad No." := NewWaiterPadLine."Waiter Pad No.";
                    NewWPadLinePrintLogEntry."Waiter Pad Line No." := NewWaiterPadLine."Line No.";
                    NewWPadLinePrintLogEntry.Modify();
                end else begin
                    NewWPadLinePrintLogEntry."Sent Date-Time" := CurrentDateTime;
                    NewWPadLinePrintLogEntry."Sent Quanity (Base)" := -NewWaiterPadLine."Quantity (Base)";
                    NewWPadLinePrintLogEntry.Context := NewWPadLinePrintLogEntry.Context::"Line Splitting";
                    InsertWaiterPadLinePrintLogEntry(NewWPadLinePrintLogEntry);

                    NewWPadLinePrintLogEntry."Waiter Pad No." := NewWaiterPadLine."Waiter Pad No.";
                    NewWPadLinePrintLogEntry."Waiter Pad Line No." := NewWaiterPadLine."Line No.";
                    NewWPadLinePrintLogEntry."Sent Quanity (Base)" := NewWaiterPadLine."Quantity (Base)";
                    InsertWaiterPadLinePrintLogEntry(NewWPadLinePrintLogEntry);

                    WPadLinePrintLogEntry.SetRange("Print Type", WPadLinePrintLogEntry."Print Type");
                    WPadLinePrintLogEntry.SetRange("Print Category Code", WPadLinePrintLogEntry."Print Category Code");
                    WPadLinePrintLogEntry.SetRange("Flow Status Object", WPadLinePrintLogEntry."Flow Status Object");
                    WPadLinePrintLogEntry.SetRange("Flow Status Code", WPadLinePrintLogEntry."Flow Status Code");
                    WPadLinePrintLogEntry.SetRange("Output Type", WPadLinePrintLogEntry."Output Type");
                    WPadLinePrintLogEntry.FindLast();
                    WPadLinePrintLogEntry.SetRange("Print Type");
                    WPadLinePrintLogEntry.SetRange("Print Category Code");
                    WPadLinePrintLogEntry.SetRange("Flow Status Object");
                    WPadLinePrintLogEntry.SetRange("Flow Status Code");
                    WPadLinePrintLogEntry.SetRange("Output Type");
                end;
            until WPadLinePrintLogEntry.Next() = 0;
    end;

    procedure RequestRunServingStepToKitchenWithMessage(var WaiterPad: Record "NPR NPRE Waiter Pad"; AutoSelectFlowStatus: Boolean; FlowStatusCode: Code[10])
    var
        MessageText: Text;
    begin
        MessageText := RequestRunServingStepToKitchen(WaiterPad, AutoSelectFlowStatus, FlowStatusCode, false);
        if MessageText <> '' then
            Message(MessageText);
    end;

    procedure RequestRunServingStepToKitchen(var WaiterPad: Record "NPR NPRE Waiter Pad"; AutoSelectFlowStatus: Boolean; FlowStatusCode: Code[10]): Text
    begin
        exit(RequestRunServingStepToKitchen(WaiterPad, AutoSelectFlowStatus, FlowStatusCode, false));
    end;

    procedure RequestRunServingStepToKitchen(var WaiterPad: Record "NPR NPRE Waiter Pad"; AutoSelectFlowStatus: Boolean; FlowStatusCode: Code[10]; SuppressError: Boolean): Text
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        ServingReqestedMsg: Label 'Serving of %1 requested for seating %2 (waiter pad %3).';
    begin
        if AutoSelectFlowStatus then begin
            FlowStatus.SetCurrentKey("Status Object", "Flow Order");
            FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
            FlowStatus.SetRange(Auxiliary, false);
            if WaiterPad."Serving Step Code" = '' then
                FlowStatus.FindFirst()
            else begin
                FlowStatus.setrange(Code, WaiterPad."Serving Step Code");
                FlowStatus.FindFirst();
                FlowStatus.setrange(Code);
                if FlowStatus.Next() = 0 then
                    Error(NoMoreMealGroupsLbl);
            end;
            FlowStatusCode := FlowStatus.Code;
        end;
        if FlowStatusCode = '' then
            exit;

        SetWaiterPadMealFlowStatus(WaiterPad, FlowStatusCode);

        while not PrintWaiterPadToKitchen(WaiterPad, _PrintTemplate."Print Type"::"Serving Request", FlowStatusCode, false, not AutoSelectFlowStatus) and AutoSelectFlowStatus do begin
            if FlowStatus.Next() = 0 then begin
                if not SuppressError then
                    Error(NoMoreMealGroupsLbl);
                exit(NoMoreMealGroupsLbl);
            end;
            FlowStatusCode := FlowStatus.Code;
            SetWaiterPadMealFlowStatus(WaiterPad, FlowStatusCode);
        end;

        WaiterPad.CalcFields("Current Seating FF");
        if FlowStatusCode <> FlowStatus.Code then
            FlowStatus.Get(FlowStatusCode, FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if FlowStatus.Description = '' then
            FlowStatus.Description := FlowStatus.Code;

        exit(StrSubstNo(ServingReqestedMsg, FlowStatus.Description, WaiterPad."Current Seating FF", WaiterPad."No."));
    end;

    internal procedure SelectAndRequestRunServingStepToKitchen(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        FlowStatus.SetCurrentKey("Status Object", "Flow Order");
        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if WaiterPad."Serving Step Code" <> '' then
            FlowStatus.Get(WaiterPad."Serving Step Code", FlowStatus."Status Object"::WaiterPadLineMealFlow);

        if PAGE.RunModal(0, FlowStatus) = Action::LookupOK then
            RequestRunServingStepToKitchenWithMessage(WaiterPad, false, FlowStatus.Code);
    end;

    local procedure SetWaiterPadMealFlowStatus(var WaiterPad: Record "NPR NPRE Waiter Pad"; NewFlowStatusCode: Code[10])
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        FlowStatusNew: Record "NPR NPRE Flow Status";
    begin
        if NewFlowStatusCode = '' then
            exit;
        if WaiterPad."Serving Step Code" <> '' then
            FlowStatus.Get(WaiterPad."Serving Step Code", FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatusNew.Get(NewFlowStatusCode, FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if ((FlowStatusNew."Flow Order" > FlowStatus."Flow Order") or (WaiterPad."Serving Step Code" = '')) and not FlowStatusNew.Auxiliary then
            WaiterPad.Validate("Serving Step Code", NewFlowStatusCode);
        WaiterPad."Last Req. Serving Step Code" := NewFlowStatusCode;
        WaiterPad.Modify();
    end;

    local procedure InitTempPrintCategoryList(var PrintCategoryTmp: Record "NPR NPRE Print/Prod. Cat.")
    var
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
    begin
        if not PrintCategoryTmp.IsTemporary() then
            _SetupProxy.ThrowNonTempException('CU6150664.InitTempPrintCategoryList');
        PrintCategoryTmp.Reset();
        PrintCategoryTmp.DeleteAll();
        if PrintCategory.FindSet() then
            repeat
                PrintCategoryTmp := PrintCategory;
                PrintCategoryTmp.Insert();
            until PrintCategory.Next() = 0;
        PrintCategoryTmp.Init();
        PrintCategoryTmp.Code := '';
        if not PrintCategoryTmp.Find() then
            PrintCategoryTmp.Insert();
    end;

    local procedure InitTempFlowStatusList(var FlowStatusTmp: Record "NPR NPRE Flow Status"; StatusObject: Enum "NPR NPRE Status Object")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        if not FlowStatusTmp.IsTemporary() then
            _SetupProxy.ThrowNonTempException('CU6150664.InitTempFlowStatusList');

        FlowStatusTmp.Reset();
        FlowStatusTmp.DeleteAll();

        FlowStatus.SetRange("Status Object", StatusObject);
        if FlowStatus.FindSet() then
            repeat
                FlowStatusTmp := FlowStatus;
                FlowStatusTmp.Insert();
            until FlowStatus.Next() = 0;

        FlowStatusTmp.Init();
        FlowStatusTmp."Status Object" := StatusObject;
        FlowStatusTmp.Code := '';
        if not FlowStatusTmp.Find() then
            FlowStatusTmp.Insert();
    end;

    internal procedure SetWaiterPadPreReceiptPrinted(var WaiterPad: Record "NPR NPRE Waiter Pad"; Printed: Boolean; ModifyRec: Boolean)
    begin
        WaiterPad."Pre-receipt Printed" := Printed;
        if ModifyRec then
            WaiterPad.Modify();
    end;

    internal procedure SetIsCancelledSale(Cancelled: Boolean)
    begin
        _IsCancelledSale := Cancelled;
    end;
}
