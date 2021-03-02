codeunit 6150678 "NPR NPRE RVA: Split WPad/Bill"
{
    var
        ActionDescription: Label 'This built-in action splits waiter pads (bills) from Restaurant View';
        IncludeAllWPadsQ: Label 'There are multiple waiter pads assigned to the seating %1. Do you want them all to be included in the scope?';
        PopupCaption: Label 'Please, configure your bills';
        WPadIsOpenedInPOSSale: Label 'The waiter pad is opened in a POS sale at the moment and might have unsaved changes. Are you sure you want to continue on running the action?';

    local procedure ActionCode(): Text;
    begin
        exit('RV_SPLIT_BILL');
    end;

    local procedure ActionVersion(): Text;
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action");
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
              'popup.message("Start workflow...");' +
              'await workflow.respond("GenerateSplitBillContext");' +
              'result = ' +
              '  await popup.hospitality.splitBill({' +
              '    caption: labels["PopupCaption"],' +
              '    items: $context.items,' +
              '    bills: $context.bills' +
              '  });' +
              'if (result) {await workflow.respond("DoSplit")};');

            Sender.RegisterTextParameter('WaiterPadCode', '');
            Sender.RegisterTextParameter('SeatingCode', '');
            Sender.RegisterOptionParameter('IncludeAllWPads', 'No,Yes,Ask', 'Yes');
            Sender.RegisterBooleanParameter('ReturnToDefaultView', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        POSSale: Codeunit "NPR POS Sale";
        SeatingCode: Code[20];
        WaiterPadCode: Code[20];
        IncludeAllWPads: Option No,Yes,Ask;
        ReturnToDefaultView: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        CASE WorkflowStep OF
            'GenerateSplitBillContext':
                GenerateSplitBillContext(Context);
            'DoSplit':
                ;
        end;

        Message('%1:\%2', WorkflowStep, Context.ToString);

        /*
        if ReturnToDefaultView then begin
              POSSession.GetSale(POSSale);
              POSSale.SelectViewForEndOfSale(POSSession);
          end;

          POSSession.RequestRefreshData();
        */
    end;

    local procedure GenerateSplitBillContext(Context: Codeunit "NPR POS JSON Management");
    var
        SeatingWPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingCode: Code[20];
        WaiterPadCode: Code[20];
        IncludeAllWPads: Option No,Yes,Ask;
    begin
        WaiterPadCode := Context.GetStringParameterOrFail('WaiterPadCode', ActionCode());
        IncludeAllWPads := Context.GetIntegerParameter('IncludeAllWPads');
        if IncludeAllWPads IN [IncludeAllWPads::Yes, IncludeAllWPads::Ask] then begin
            SeatingCode := Context.GetStringParameter('SeatingCode');
            if SeatingCode = '' then
                IncludeAllWPads := IncludeAllWPads::No
            else begin
                SeatingWPadLink.SetRange("Seating Code", SeatingCode);
                SeatingWPadLink.SetFilter("Waiter Pad No.", '<>%1', WaiterPadCode);
                SeatingWPadLink.SetRange(Closed, false);
                if SeatingWPadLink.IsEmpty then
                    IncludeAllWPads := IncludeAllWPads::No;
            end;
            if IncludeAllWPads = IncludeAllWPads::Ask then
                if CONFIRM(IncludeAllWPadsQ, true, SeatingCode) then
                    IncludeAllWPads := IncludeAllWPads::Yes
                else
                    IncludeAllWPads := IncludeAllWPads::No;
        end;

        AddParentWaiterPadToContext(Context, WaiterPadCode);

        if IncludeAllWPads = IncludeAllWPads::Yes then
            AddOtherWaiterPadsToContext(Context, SeatingWPadLink);
    end;

    local procedure AddParentWaiterPadToContext(Context: Codeunit "NPR POS JSON Management"; WaiterPadCode: Code[20]);
    var
        WPadLineCollection: JsonArray;
    begin
        GetWaiterPadLines(WPadLineCollection, WaiterPadCode);
        Context.GetContextObject().Add('items', WPadLineCollection);
    end;

    local procedure AddOtherWaiterPadsToContext(Context: Codeunit "NPR POS JSON Management"; var SeatingWPadLink: Record "NPR NPRE Seat.: WaiterPadLink");
    var
        BillCollection: JsonArray;
        BillContent: JsonObject;
        WPadLineCollection: JsonArray;
    begin
        if SeatingWPadLink.FindSet then begin
            repeat
                GetWaiterPadLines(WPadLineCollection, SeatingWPadLink."Waiter Pad No.");
                if WPadLineCollection.Count > 0 then begin
                    Clear(BillContent);
                    BillContent.Add('id', SeatingWPadLink."Waiter Pad No.");
                    BillContent.Add('items', WPadLineCollection);
                    BillCollection.Add(BillContent);
                end;
            until SeatingWPadLink.Next = 0;

            Context.GetContextObject().Add('bills', BillCollection);
        end;
    end;

    local procedure GetWaiterPadLines(var WPadLineCollection: JsonArray; WaiterPadCode: Code[20]);
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WPadLineContent: JsonObject;
    begin
        Clear(WPadLineCollection);
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadCode);
        WaiterPadLine.SetRange(Type, WaiterPadLine.Type::Item);
        if WaiterPadLine.FindSet then
            repeat
                if WaiterPadLine.Quantity - WaiterPadLine."Billed Quantity" > 0 then begin
                    Clear(WPadLineContent);

                    WPadLineContent.Add('key', WaiterPadLine.GetPosition(false));
                    WPadLineContent.Add('no', WaiterPadLine."No.");
                    WPadLineContent.Add('caption', WaiterPadLine.Description + WaiterPadLine."Description 2");
                    WPadLineContent.Add('qty', WaiterPadLine.Quantity - WaiterPadLine."Billed Quantity");

                    WPadLineCollection.Add(WPadLineContent);
                end;
            until WaiterPadLine.Next = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text);
    var
        CaptionIncludeAllWPads: Label 'All Waiter Pads';
        CaptionReturnToDefaultView: Label 'Return to Default View on Finish';
        CaptionSeatingCode: Label 'Seating Code';
        CaptionWaiterPadCode: Label 'Waiter Pad Code';
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        CASE POSParameterValue.Name OF
            'WaiterPadCode':
                Caption := CaptionWaiterPadCode;
            'SeatingCode':
                Caption := CaptionSeatingCode;
            'IncludeAllWPads':
                Caption := CaptionIncludeAllWPads;
            'ReturnToDefaultView':
                Caption := CaptionReturnToDefaultView;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text);
    var
        DescIncludeAllWPads: Label 'Defines whether all assigned to a seating waiter pads should be included in the scope.';
        DescReturnToDefaultView: Label 'Switch to the default view defined for the POS Unit after the Waiter Pad Action has completed';
        DescSeatingCode: Label 'Defines seating number the action is to be run upon. The parameter is set automatically by the system on the runtime';
        DescWaiterPadCode: Label 'Defines waiter pad number the action is to be run upon. The parameter is set automatically by the system on the runtime';
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        CASE POSParameterValue.Name OF
            'WaiterPadCode':
                Caption := DescWaiterPadCode;
            'SeatingCode':
                Caption := DescSeatingCode;
            'IncludeAllWPads':
                Caption := DescIncludeAllWPads;
            'ReturnToDefaultView':
                Caption := DescReturnToDefaultView;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', true, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text);
    var
        OptionIncludeAllWPads: Label 'No,Yes,Ask';
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        CASE POSParameterValue.Name OF
            'IncludeAllWPads':
                Caption := OptionIncludeAllWPads;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management");
    begin
        Captions.AddActionCaption(ActionCode(), 'PopupCaption', PopupCaption);
    end;
}