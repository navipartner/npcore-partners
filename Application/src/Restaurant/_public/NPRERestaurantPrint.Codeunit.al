﻿codeunit 6150664 "NPR NPRE Restaurant Print"
{
    var
        PrintKitchOderConfMsg: Label 'Do you want to send the order to the kitchen now?';
        NoMoreMealGroupsLbl: Label 'No more meal groups left to be sent to the kitchen.';
        NothingToSendLbl: Label 'Nothing to send.';
        LinesHaveAlreadyBeenSent: Label 'One or more lines for %1 ''%2'' and %3 ''%4'' have already been sent to kitchent.\\Please select what do you want to do:\';
        ResendOptions: Label 'Send only new lines,Send all lines including previously sent';
        GlobalPrintTemplate: Record "NPR NPRE Print Templ.";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        NowhereToSend: Label 'Neither Kitchen Printing nor KDS is activated. You need to activate at least one of them to be able to use this functionality.';
        ServingReqestedMsg: Label 'Serving of %1 requested for seating %2 (waiter pad %3).';
        NotTempErr: Label '%1: function call on a non-temporary variable. This is a programming bug, not a user error. Please contact system vendor.';

    internal procedure PrintWaiterPadPreReceiptPressed(WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        PrintWaiterPadToPreReceipt(WaiterPad);
    end;

    internal procedure PrintWaiterPadPreOrderToKitchenPressed(WaiterPad: Record "NPR NPRE Waiter Pad"; ForceResend: Boolean)
    begin
        PrintWaiterPadToKitchen(WaiterPad, GlobalPrintTemplate."Print Type"::"Kitchen Order", '', ForceResend, true);
    end;

    internal procedure LinesAddedToWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
        Confirmed: Boolean;
    begin
        SetupProxy.InitializeUsingWaiterPad(WaiterPad);
        case SetupProxy.AutoSendKitchenOrder() of
            SeatingLocation."Auto Send Kitchen Order"::No:
                Confirmed := false;
            SeatingLocation."Auto Send Kitchen Order"::Yes:
                Confirmed := true;
            SeatingLocation."Auto Send Kitchen Order"::Ask:
                Confirmed := Confirm(PrintKitchOderConfMsg, true);
        end;
        if Confirmed then
            PrintWaiterPadToKitchen(WaiterPad, GlobalPrintTemplate."Print Type"::"Kitchen Order", '', false, false);
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
        TempFlowStatus: Record "NPR NPRE Flow Status" temporary;
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        TempWPadLineBuffer: Record "NPR NPRE W.Pad.Line Outp.Buf." temporary;
        TempPrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Outp.Buf." temporary;
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
                                            WaiterPad, WaiterPadLine, PrintType, TempWPadLineBuffer."Print Category Code", TempWPadLineBuffer."Serving Step", TempPrintTemplateBuffer)
                                        then begin
                                            WaiterPadLine.FindSet();
                                            repeat
                                                LogWaiterPadLinePrint(
                                                  WaiterPadLine, PrintType, TempWPadLineBuffer."Serving Step", TempWPadLineBuffer."Print Category Code", PrintDateTime, 0);
                                            until WaiterPadLine.Next() = 0;
                                        end;
                                    TempWPadLineBuffer."Output Type"::KDS:
                                        KDSUpdated :=
                                          KitchenOrderMgt.SendWPLinesToKitchen(
                                            WaiterPadLine, TempWPadLineBuffer."Serving Step", TempWPadLineBuffer."Print Category Code", PrintType, PrintDateTime) or KDSUpdated;
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
        SendToPrint(TempPrintTemplateBuffer);
        exit(true);
    end;

    local procedure BufferWPadLinesForSending(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLineIn: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; var FlowStatus: Record "NPR NPRE Flow Status"; ForceResend: Boolean; var WPadLineBuffer: Record "NPR NPRE W.Pad.Line Outp.Buf."): Boolean
    var
        TempPrintCategory: Record "NPR NPRE Print/Prod. Cat." temporary;
        SeatingLocation: Record "NPR NPRE Seating Location";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        OutputType: Integer;
        AskResendConfirmation: Boolean;
        OutputTypeIsActive: Boolean;
    begin
        SetupProxy.InitializeUsingWaiterPad(WaiterPad);
        if not (SetupProxy.KitchenPrintingActivated() or SetupProxy.KDSActivated()) then
            Error(NowhereToSend);

        WaiterPadLine.Copy(WaiterPadLineIn);
        WaiterPadLine.FilterGroup(2);
        WaiterPadLine.SetFilter("Line Type", '<>%1', WaiterPadLine."Line Type"::Comment);
        WaiterPadLine.FilterGroup(0);
        if WaiterPadLine.IsEmpty then
            exit(false);

        if not ForceResend then begin
            AskResendConfirmation := SetupProxy.ResendAllOnNewLines() = SeatingLocation."Resend All On New Lines"::Ask;
            if not AskResendConfirmation then
                ForceResend := SetupProxy.ResendAllOnNewLines() = SeatingLocation."Resend All On New Lines"::Yes;
        end;

        WPadLineBuffer.Reset();
        WPadLineBuffer.DeleteAll();

        InitTempPrintCategoryList(TempPrintCategory);

        for OutputType := WaiterPadLine."Output Type Filter"::Print to WaiterPadLine."Output Type Filter"::KDS do begin
            OutputTypeIsActive :=
              ((OutputType = WaiterPadLine."Output Type Filter"::Print) and SetupProxy.KitchenPrintingActivated()) or
              ((OutputType = WaiterPadLine."Output Type Filter"::KDS) and SetupProxy.KDSActivated());
            if OutputTypeIsActive then
                BufferEligibleForSendingWPadLines(
                  WaiterPadLine, OutputType, PrintType, FlowStatus, TempPrintCategory, ForceResend, AskResendConfirmation, WPadLineBuffer);
        end;

        exit(not WPadLineBuffer.IsEmpty());
    end;

    internal procedure BufferEligibleForSendingWPadLines(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; OutputType: Integer; PrintType: Integer; var FlowStatus: Record "NPR NPRE Flow Status"; var PrintCategory: Record "NPR NPRE Print/Prod. Cat."; ForceResend: Boolean; AskResendConfirmation: Boolean; var WPadLineBuffer: Record "NPR NPRE W.Pad.Line Outp.Buf.")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        PrintCategoryFilter: Text;
        SelectedSendOption: Option Cancel,"Only New",All;
    begin
        if WaiterPadLine.IsEmpty or FlowStatus.IsEmpty or PrintCategory.IsEmpty then
            exit;

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
                                      StrMenu(ResendOptions, 1,
                                        StrSubstNo(LinesHaveAlreadyBeenSent, WaiterPad.FieldCaption("Serving Step Code"), FlowStatus.Code, PrintCategory.TableCaption, PrintCategory.Code));
                                    if SelectedSendOption = SelectedSendOption::Cancel then
                                        Error('');
                                    ForceResend := SelectedSendOption = SelectedSendOption::All;
                                end;

                            if not WaiterPadLine."Sent to Kitchen" or ForceResend or
                                (WaiterPadLine."Quantity (Base)" <> WaiterPadLine."Sent to Kitchen Qty. (Base)")
                            then begin
                                WPadLineBuffer."Output Type" := OutputType;
                                WPadLineBuffer."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
                                WPadLineBuffer."Waiter Pad Line No." := WaiterPadLine."Line No.";
                                WPadLineBuffer."Print Category Code" := PrintCategory.Code;
                                WPadLineBuffer."Serving Step" := FlowStatus.Code;
                                if not WPadLineBuffer.Find() then
                                    WPadLineBuffer.Insert();
                            end;
                        end;
                    until PrintCategory.Next() = 0;
            until WaiterPadLine.Next() = 0;
        until FlowStatus.Next() = 0;
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
        if FindAndPrintTemplates(WaiterPad, WaiterPadLine, GlobalPrintTemplate."Print Type"::"Pre Receipt", '', '') then begin
            SetWaiterPadPreReceiptPrinted(WaiterPad, true, true);
            WaiterPadMgt.CloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::Undefined);
        end;
    end;

    local procedure FindAndPrintTemplates(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; PrintCategoryCode: Code[20]; ServingStep: Code[10]): Boolean
    var
        TempPrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Outp.Buf." temporary;
    begin
        TempPrintTemplateBuffer.DeleteAll();
        if FindPrintTemplates(WaiterPad, WaiterPadLine, PrintType, PrintCategoryCode, ServingStep, TempPrintTemplateBuffer) then begin
            SendToPrint(TempPrintTemplateBuffer);
            exit(true);
        end;
        exit(false);
    end;

    local procedure FindPrintTemplates(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; PrintCategoryCode: Code[20]; ServingStep: Code[10]; var PrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Outp.Buf.") TemplateFound: Boolean
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        TempSeatingLocation: Record "NPR NPRE Seating Location" temporary;
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
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
        if not FindForBlankLocation then
            repeat
                if AddPrintTemplatesToBuffer(PrintTemplateBuffer, WaiterPadLine, TempSeatingLocation, PrintType, PrintCategoryCode, ServingStep) then
                    TemplateFound := true
                else
                    FindForBlankLocation := true;
            until TempSeatingLocation.Next() = 0;

        if FindForBlankLocation then begin
            Clear(TempSeatingLocation);
            if AddPrintTemplatesToBuffer(PrintTemplateBuffer, WaiterPadLine, TempSeatingLocation, PrintType, PrintCategoryCode, ServingStep) then
                TemplateFound := true;
        end;
    end;

    local procedure SendToPrint(var PrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Outp.Buf.")
    var
        PrintTemplate: Record "NPR RP Template Header";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        if PrintTemplateBuffer.FindFirst() then
            repeat
                PrintTemplateBuffer.SetRecFilter();
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
                                AddComments(WaiterPadLine);
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
    end;

    local procedure AddPrintTemplatesToBuffer(var PrintTemplateBuffer: Record "NPR NPRE W.Pad.Line Outp.Buf."; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; SeatingLocation: Record "NPR NPRE Seating Location"; PrintType: Integer; PrintCategoryCode: Code[20]; ServingStep: Code[10]): Boolean
    var
        PrintTemplate: Record "NPR NPRE Print Templ.";
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
        repeat
            if WaiterPadLine.FindSet() then
                repeat
                    Clear(PrintTemplateBuffer);
                    PrintTemplateBuffer."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
                    PrintTemplateBuffer."Waiter Pad Line No." := WaiterPadLine."Line No.";
                    PrintTemplateBuffer."Print Template Code" := PrintTemplate."Template Code";
                    if PrintTemplate."Split Print Jobs By" in [PrintTemplate."Split Print Jobs By"::"Print Category", PrintTemplate."Split Print Jobs By"::Both] then
                        PrintTemplateBuffer."Print Category Code" := PrintCategoryCode;
                    if PrintTemplate."Split Print Jobs By" in [PrintTemplate."Split Print Jobs By"::"Serving Step", PrintTemplate."Split Print Jobs By"::Both] then
                        PrintTemplateBuffer."Serving Step" := ServingStep;
                    if not PrintTemplateBuffer.Find() then
                        PrintTemplateBuffer.Insert();
                until WaiterPadLine.Next() = 0;
        until PrintTemplate.Next() = 0;
        exit(true);
    end;

    internal procedure LogWaiterPadLinePrint(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintType: Integer; FlowStatusCode: Code[10]; PrintCategoryCode: Code[20]; PrintDateTime: DateTime; OutputType: Integer)
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
        MessageText := RequestRunServingStepToKitchen(WaiterPad, AutoSelectFlowStatus, FlowStatusCode);
        if MessageText <> '' then
            Message(MessageText);
    end;

    procedure RequestRunServingStepToKitchen(var WaiterPad: Record "NPR NPRE Waiter Pad"; AutoSelectFlowStatus: Boolean; FlowStatusCode: Code[10]): Text
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        if AutoSelectFlowStatus then begin
            FlowStatus.SetCurrentKey("Status Object", "Flow Order");
            FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
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

        while not PrintWaiterPadToKitchen(WaiterPad, GlobalPrintTemplate."Print Type"::"Serving Request", FlowStatusCode, false, not AutoSelectFlowStatus) and AutoSelectFlowStatus do begin
            if FlowStatus.Next() = 0 then
                Error(NoMoreMealGroupsLbl);
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
        if (FlowStatusNew."Flow Order" > FlowStatus."Flow Order") or (WaiterPad."Serving Step Code" = '') then
            WaiterPad.Validate("Serving Step Code", NewFlowStatusCode);
        WaiterPad."Last Req. Serving Step Code" := NewFlowStatusCode;
        WaiterPad.Modify();
    end;

    local procedure AddComments(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        WaiterPadLine2: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine2.SetRange("Waiter Pad No.", WaiterPadLine."Waiter Pad No.");
        WaiterPadLine2 := WaiterPadLine;
        while (WaiterPadLine2.Next() <> 0) and (WaiterPadLine2."Line Type" = WaiterPadLine2."Line Type"::Comment) do begin
            WaiterPadLine := WaiterPadLine2;
            WaiterPadLine.Mark := true;
        end;
    end;

    internal procedure InitTempPrintCategoryList(var PrintCategoryTmp: Record "NPR NPRE Print/Prod. Cat.")
    var
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
    begin
        if not PrintCategoryTmp.IsTemporary then
            Error(NotTempErr, 'CU6150664.InitTempPrintCategoryList');
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

    internal procedure InitTempFlowStatusList(var FlowStatusTmp: Record "NPR NPRE Flow Status"; StatusObject: Enum "NPR NPRE Status Object")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        if not FlowStatusTmp.IsTemporary then
            Error(NotTempErr, 'CU6150664.InitTempFlowStatusList');

        FlowStatusTmp.Reset();
        FlowStatusTmp.DeleteAll();

        FlowStatus.SetRange("Status Object", StatusObject);
        if FlowStatus.FindSet() then
            repeat
                FlowStatusTmp := FlowStatus;
                FlowStatusTmp.Insert();
            until FlowStatus.Next() = 0;

        FlowStatusTmp.Init();
        FlowStatusTmp."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
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
}
