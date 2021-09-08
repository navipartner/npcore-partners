codeunit 6150670 "NPR NPRE POS Action: SplitBill"
{
    var
        ReadingErr: Label 'reading in %1 of %2';

    local procedure ActionCode(): Code[20]
    begin
        exit('SPLIT_BILL');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('2.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescriptionLbl: Label 'This built-in action splits waiter pads (bills). It can be run from both Sale and Restaurant View';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionLbl, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
                'await workflow.respond("AddPresetValuesToContext");' +

                //Select seating
                'if (!$context.seatingCode) {' +
                '  if ($parameters.SeatingCode) {' +
                '    $context.seatingCode = $parameters.SeatingCode;' +
                '  } else {' +
                '    switch($parameters.SeatingSelectionMethod + "") {' +
                '      case "0":' +
                '        $context.seatingCode = await popup.stringpad({caption: $labels.SeatingIDLbl});' +
                '        break;' +
                '      case "1":' +
                '        $context.seatingCode = await popup.intpad({caption: $labels.SeatingIDLbl});' +
                '        break;' +
                '      case "2":' +
                '        await workflow.respond("SelectSeating");' +
                '        break;' +
                '    }' +
                '  }' +
                '};' +
                'if (!$context.seatingCode) {return};' +

                //Select waiter pad
                'if (!$context.waiterPadNo) {' +
                '    await workflow.respond("SelectWaiterPad");' +
                '};' +
                'if (!$context.waiterPadNo) {return};' +

                //Split waiter pads/bills
                'await workflow.respond("GenerateSplitBillContext");' +
                'console.log("Context: " + JSON.stringify($context));' +
                'result = ' +
                '  await popup.hospitality.splitBill({' +
                '    caption: $labels.PopupCaption,' +
                '    items: $context.items,' +
                '    bills: $context.bills' +
                '  });' +
                'if (result) {await workflow.respond("DoSplit", result)};');

            Sender.RegisterOptionParameter('SeatingSelectionMethod', 'stringPad,intPad,List', 'stringPad');
            Sender.RegisterTextParameter('WaiterPadCode', '');
            Sender.RegisterTextParameter('SeatingCode', '');
            Sender.RegisterTextParameter('SeatingFilter', '');
            Sender.RegisterTextParameter('LocationFilter', '');
            Sender.RegisterOptionParameter('IncludeAllWPads', 'No,Yes,Ask', 'Yes');
            Sender.RegisterBooleanParameter('ReturnToDefaultView', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        CurrentWaiterPad: Record "NPR NPRE Waiter Pad";
        NothingToDoErr: Label 'Nothing has been changed';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        CASE WorkflowStep OF
            'AddPresetValuesToContext':
                AddPresetValuesToContext(Context, POSSession);
            'SelectSeating':
                SelectSeating(Context);
            'SelectWaiterPad':
                SelectWaiterPad(Context);
            'GenerateSplitBillContext':
                begin
                    SaveChangesToWaiterPad(POSSession);
                    GenerateSplitBillContext(Context);
                end;
            'DoSplit':
                begin
                    CleanupSale(POSSession);
                    if not ProcessWaiterPadSplit(Context, CurrentWaiterPad) then
                        Error(NothingToDoErr);
                    UpdateFrontEndView(CurrentWaiterPad, Context, POSSession);
                end;
        end;
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        RestaurantContextUpdated: Boolean;
        SeatingContextUpdated: Boolean;
        WPadContextUpdated: Boolean;
    begin
        POSSession.GetSetup(POSSetup);
        Seating.Code := CopyStr(Context.GetStringParameter('SeatingCode'), 1, MaxStrLen(Seating.Code));
        if Seating.Code <> '' then
            if Seating.Find() then begin
                Context.SetContext('seatingCode', Seating.Code);
                SeatingContextUpdated := true;
                SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
            end;
        WaiterPad."No." := CopyStr(Context.GetStringParameter('WaiterPadCode'), 1, MaxStrLen(WaiterPad."No."));
        if WaiterPad."No." <> '' then
            if WaiterPad.Find() then begin
                Context.SetContext('waiterPadNo', WaiterPad."No.");
                WPadContextUpdated := true;
                SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
                if not SeatingWaiterPadLink.IsEmpty then begin
                    RestaurantContextUpdated := UpdateRestaurantContext(Context, SeatingWaiterPadLink, POSSetup.RestaurantCode());
                    if not RestaurantContextUpdated then
                        RestaurantContextUpdated := UpdateRestaurantContext(Context, SeatingWaiterPadLink, '');
                end;
            end;

        if not RestaurantContextUpdated then
            Context.SetContext('restaurantCode', POSSetup.RestaurantCode());

        if not (SeatingContextUpdated and WPadContextUpdated) then begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);

            if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
                Seating.Get(SalePOS."NPRE Pre-Set Seating Code");
                Context.SetContext('seatingCode', SalePOS."NPRE Pre-Set Seating Code");
            end;

            if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
                WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
                if SalePOS."NPRE Pre-Set Seating Code" <> '' then
                    if not SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.") then
                        WaiterPadMgt.AddNewWaiterPadForSeating(Seating.Code, WaiterPad, SeatingWaiterPadLink);
                WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, false);
                Context.SetContext('waiterPadNo', SalePOS."NPRE Pre-Set Waiter Pad No.");
            end;
        end;
    end;

    local procedure UpdateRestaurantContext(Context: Codeunit "NPR POS JSON Management"; var SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink"; POSRestaurantCode: Code[20]): Boolean
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        if not SeatingWaiterPadLink.FindSet() then
            exit(false);
        repeat
            if Seating.Get(SeatingWaiterPadLink."Seating Code") and (Seating."Seating Location" <> '') then
                if SeatingLocation.Get(Seating."Seating Location") and (SeatingLocation."Restaurant Code" <> '') and
                   ((SeatingLocation."Restaurant Code" = POSRestaurantCode) or (POSRestaurantCode = ''))
                then begin
                    Context.SetContext('restaurantCode', SeatingLocation."Restaurant Code");
                    exit(true);
                end;
        until SeatingWaiterPadLink.Next() = 0;
        exit(false);
    end;

    local procedure SelectSeating(Context: Codeunit "NPR POS JSON Management")
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        WaiterPadPOSMgt.FindSeating(Context, Seating);
        Context.SetContext('seatingCode', Seating.Code);
    end;

    local procedure SelectWaiterPad(Context: Codeunit "NPR POS JSON Management")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        Seating: Record "NPR NPRE Seating";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        WaiterPadPOSMgt.FindSeating(Context, Seating);
        if not WaiterPadPOSMgt.SelectWaiterPad(Seating, WaiterPad) then
            exit;
        Context.SetContext('waiterPadNo', WaiterPad."No.");
    end;

    local procedure GenerateSplitBillContext(Context: Codeunit "NPR POS JSON Management")
    var
        SeatingWPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingCode: Code[20];
        WaiterPadCode: Code[20];
        IncludeAllWPads: Option No,Yes,Ask;
        IncludeAllWPadsQ: Label 'There are multiple waiter pads assigned to the seating %1. Do you want them all to be included in the scope?';
    begin
        WaiterPadCode := CopyStr(Context.GetStringOrFail('waiterPadNo', StrSubstNo(ReadingErr, 'OnAction', ActionCode())), 1, MaxStrLen(WaiterPadCode));
        IncludeAllWPads := Context.GetIntegerParameter('IncludeAllWPads');
        if IncludeAllWPads IN [IncludeAllWPads::Yes, IncludeAllWPads::Ask] then begin
            SeatingCode := CopyStr(Context.GetString('seatingCode'), 1, MaxStrLen(SeatingCode));
            if SeatingCode = '' then
                IncludeAllWPads := IncludeAllWPads::No
            else begin
                SeatingWPadLink.SetCurrentKey(Closed);
                SeatingWPadLink.SetRange("Seating Code", SeatingCode);
                SeatingWPadLink.SetFilter("Waiter Pad No.", '<>%1', WaiterPadCode);
                SeatingWPadLink.SetRange(Closed, false);
                if SeatingWPadLink.IsEmpty then
                    IncludeAllWPads := IncludeAllWPads::No;
            end;
            if IncludeAllWPads = IncludeAllWPads::Ask then
                if Confirm(IncludeAllWPadsQ, true, SeatingCode) then
                    IncludeAllWPads := IncludeAllWPads::Yes
                else
                    IncludeAllWPads := IncludeAllWPads::No;
        end;

        AddCurrentWaiterPadToContext(Context, WaiterPadCode);

        if IncludeAllWPads = IncludeAllWPads::Yes then
            AddOtherWaiterPadsToContext(Context, SeatingWPadLink);
    end;

    local procedure AddCurrentWaiterPadToContext(Context: Codeunit "NPR POS JSON Management"; WaiterPadCode: Code[20])
    var
        WPadLineCollection: JsonArray;
    begin
        GetWaiterPadLines(WPadLineCollection, WaiterPadCode);
        //Context.GetContextObject().Add('items', WPadLineCollection);
        Context.SetContext('items', WPadLineCollection);
    end;

    local procedure AddOtherWaiterPadsToContext(Context: Codeunit "NPR POS JSON Management"; var SeatingWPadLink: Record "NPR NPRE Seat.: WaiterPadLink")
    var
        BillCollection: JsonArray;
        BillContent: JsonObject;
        WPadLineCollection: JsonArray;
    begin
        if SeatingWPadLink.FindSet() then begin
            repeat
                GetWaiterPadLines(WPadLineCollection, SeatingWPadLink."Waiter Pad No.");
                if WPadLineCollection.Count() > 0 then begin
                    Clear(BillContent);
                    BillContent.Add('id', SeatingWPadLink."Waiter Pad No.");
                    BillContent.Add('items', WPadLineCollection);
                    BillCollection.Add(BillContent);
                end;
            until SeatingWPadLink.Next() = 0;

            //Context.GetContextObject().Add('bills', BillCollection);
            Context.SetContext('bills', BillCollection);
        end;
    end;

    local procedure GetWaiterPadLines(var WPadLineCollection: JsonArray; WaiterPadCode: Code[20])
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WPadLineContent: JsonObject;
    begin
        Clear(WPadLineCollection);
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadCode);
        WaiterPadLine.SetRange(Type, WaiterPadLine.Type::Item);
        if WaiterPadLine.FindSet() then
            repeat
                if WaiterPadLine.Quantity - WaiterPadLine."Billed Quantity" > 0 then begin
                    Clear(WPadLineContent);
                    WPadLineContent.Add('key', WaiterPadLine.GetPosition(false));
                    WPadLineContent.Add('no', WaiterPadLine."No.");
                    WPadLineContent.Add('caption', WaiterPadLine.Description + WaiterPadLine."Description 2");
                    WPadLineContent.Add('qty', WaiterPadLine.Quantity - WaiterPadLine."Billed Quantity");
                    WPadLineCollection.Add(WPadLineContent);
                end;
            until WaiterPadLine.Next() = 0;
    end;

    local procedure SaveChangesToWaiterPad(POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSale: Codeunit "NPR POS Sale";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
            WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, false);
            Commit();
        end;
    end;

    local procedure CleanupSale(POSSession: Codeunit "NPR POS Session")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteAll();
    end;

    local procedure ProcessWaiterPadSplit(Context: Codeunit "NPR POS JSON Management"; var CurrentWaiterPad: Record "NPR NPRE Waiter Pad") ChangesFound: Boolean
    var
        FromWaiterPad: Record "NPR NPRE Waiter Pad";
        FromWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        TempTouchedWaiterPad: Record "NPR NPRE Waiter Pad" temporary;
        ToWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        Bills: JsonArray;
        BillLines: JsonArray;
        Bill: JsonToken;
        BillLine: JsonToken;
        ContextJToken: JsonToken;
        MoveQty: Decimal;
    begin
        ChangesFound := false;
        ContextJToken.ReadFrom(Context.ToString());
        if ContextJToken.SelectToken('bills', ContextJToken) then
            if ContextJToken.IsArray then begin
                CurrentWaiterPad.Get(Context.GetStringOrFail('waiterPadNo', StrSubstNo(ReadingErr, 'OnAction', ActionCode())));
                Bills := ContextJToken.AsArray();
                foreach Bill in Bills do begin
                    Bill.AsObject().Get('items', ContextJToken);
                    if ContextJToken.IsArray then begin
                        BillLines := ContextJToken.AsArray();
                        if BillLines.Count > 0 then begin
                            Bill.AsObject().Get('id', ContextJToken);
                            ToWaiterPad."No." := CopyStr(ContextJToken.AsValue().AsText(), 1, MaxStrLen(ToWaiterPad."No."));
                            FindWaiterPad(CurrentWaiterPad, ToWaiterPad);

                            foreach BillLine in BillLines do begin
                                BillLine.AsObject().Get('qty', ContextJToken);
                                MoveQty := ContextJToken.AsValue().AsDecimal();
                                if MoveQty > 0 then begin
                                    BillLine.AsObject().Get('key', ContextJToken);
                                    FromWaiterPadLine.SetPosition(ContextJToken.AsValue().AsText());
                                    if FromWaiterPadLine."Waiter Pad No." <> ToWaiterPad."No." then begin
                                        FromWaiterPad.Get(FromWaiterPadLine."Waiter Pad No.");
                                        FromWaiterPadLine.Find();
                                        WaiterPadPOSMgt.SplitWaiterPadLine(FromWaiterPad, FromWaiterPadLine, MoveQty, ToWaiterPad);

                                        TempTouchedWaiterPad := FromWaiterPad;
                                        if not TempTouchedWaiterPad.Find() then
                                            TempTouchedWaiterPad.Insert();
                                        ChangesFound := true;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;

        if TempTouchedWaiterPad.FindSet() then
            repeat
                FromWaiterPad.Get(TempTouchedWaiterPad."No.");
                WaiterPadMgt.CloseWaiterPad(FromWaiterPad, false);
            until TempTouchedWaiterPad.Next() = 0;
    end;

    local procedure FindWaiterPad(var CurrentWaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        WaiterPad.TestField("No.");
        if WaiterPad.Find() then
            exit;

        Clear(WaiterPad);
        WaiterPadMgt.DuplicateWaiterPadHdr(CurrentWaiterPad, WaiterPad);
        WaiterPadMgt.MoveNumberOfGuests(CurrentWaiterPad, WaiterPad, 1);
    end;

    local procedure UpdateFrontEndView(CurrentWaiterPad: Record "NPR NPRE Waiter Pad"; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
        CurrentView: Codeunit "NPR POS View";
        POSSale: Codeunit "NPR POS Sale";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ReturnToDefaultView: Boolean;
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetCurrentView(CurrentView);
        if CurrentView.Type() = CurrentView.Type() ::Sale then begin
            POSSale.GetCurrentSale(SalePOS);
            WaiterPadPOSMgt.ClearSaleHdrNPREPresetFields(SalePOS, false);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);
        end;

        ReturnToDefaultView := Context.GetBooleanParameter('ReturnToDefaultView');
        if ReturnToDefaultView then
            POSSale.SelectViewForEndOfSale(POSSession)
        else begin
            if CurrentView.Type() = CurrentView.Type() ::Sale then begin
                CurrentWaiterPad.Find();
                if not CurrentWaiterPad.Closed then
                    WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(CurrentWaiterPad, POSSession);
            end;
        end;

        POSSession.RequestRefreshData();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        CaptionIncludeAllWPads: Label 'All Waiter Pads';
        CaptionLocationFilter: Label 'Location Filter';
        CaptionReturnToDefaultView: Label 'Return to Default View on Finish';
        CaptionSeatingCode: Label 'Seating Code';
        CaptionSeatingFilter: Label 'Seating Filter';
        CaptionSeatingSelectionMethod: Label 'Seating Selection Method';
        CaptionWaiterPadCode: Label 'Waiter Pad Code';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        CASE POSParameterValue.Name OF
            'IncludeAllWPads':
                Caption := CaptionIncludeAllWPads;
            'LocationFilter':
                Caption := CaptionLocationFilter;
            'ReturnToDefaultView':
                Caption := CaptionReturnToDefaultView;
            'SeatingCode':
                Caption := CaptionSeatingCode;
            'SeatingFilter':
                Caption := CaptionSeatingFilter;
            'SeatingSelectionMethod':
                Caption := CaptionSeatingSelectionMethod;
            'WaiterPadCode':
                Caption := CaptionWaiterPadCode;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        DescIncludeAllWPads: Label 'Specifies whether all assigned to a seating waiter pads should be included in the scope';
        DescLocationFilter: Label 'Specifies a filter for seating location';
        DescReturnToDefaultView: Label 'Switch to the default view defined for the POS Unit after the Waiter Pad Action has completed';
        DescSeatingCode: Label 'Specifies seating number the action is to be run upon';
        DescSeatingFilter: Label 'Specifies a filter for seating';
        DescSeatingSelectionMethod: Label 'Specifies seating selection method';
        DescWaiterPadCode: Label 'Defines waiter pad number the action is to be run upon. The parameter is set automatically by the system and should not be preset manually';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        CASE POSParameterValue.Name OF
            'IncludeAllWPads':
                Caption := DescIncludeAllWPads;
            'LocationFilter':
                Caption := DescLocationFilter;
            'ReturnToDefaultView':
                Caption := DescReturnToDefaultView;
            'SeatingCode':
                Caption := DescSeatingCode;
            'SeatingFilter':
                Caption := DescSeatingFilter;
            'SeatingSelectionMethod':
                Caption := DescSeatingSelectionMethod;
            'WaiterPadCode':
                Caption := DescWaiterPadCode;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', true, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        OptionIncludeAllWPads: Label 'No,Yes,Ask';
        OptionSeatingSelectionMethod: Label 'StringPad,IntPad,Select from List';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        CASE POSParameterValue.Name OF
            'IncludeAllWPads':
                Caption := OptionIncludeAllWPads;
            'SeatingSelectionMethod':
                Caption := OptionSeatingSelectionMethod;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        //MoreInfoReqLbl: Label 'We need more information';
        PopupCaptionLbl: Label 'Please configure your bills';
        SeatingIDLbl: Label 'Seating Code';
    begin
        Captions.AddActionCaption(ActionCode(), 'PopupCaption', PopupCaptionLbl);
        //Captions.AddActionCaption(ActionCode(), 'WindowTitle', MoreInfoReqLbl);
        Captions.AddActionCaption(ActionCode(), 'SelectSeatingID', SeatingIDLbl);
    end;
}
