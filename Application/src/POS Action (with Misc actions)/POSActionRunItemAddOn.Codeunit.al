codeunit 6151128 "NPR POS Action: Run Item AddOn"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        CurrNpIaItemAddOn: Record "NPR NpIa Item AddOn";
        [WithEvents]
        Model: DotNet NPRNetModel;
        ActiveModelID: Guid;
        Text000: Label 'Insert Item AddOns from the currently selected POS Sales Line';
        BaseLineNo: Integer;

    local procedure ActionCode(): Text
    begin
        exit('RUN_ITEM_ADDONS');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  Text000,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Multiple)
then begin
            Sender.RegisterWorkflowStep('run_addons', 'respond();');

            Sender.RegisterWorkflow(false);
            Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');
            Sender.RegisterCustomJavaScriptLogic('enable', 'return row.getField("ItemAddOn.ItemAddOn").rawValue;');
            Sender.RegisterIntegerParameter('BaseLineNo', 0);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        BaseLineNo := JSON.GetIntegerParameter('BaseLineNo');

        case WorkflowStep of
            'run_addons':
                OnActionRunAddOns(POSSession, FrontEnd);
        end;

        Handled := true;
    end;

    local procedure OnActionRunAddOns(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Item: Record Item;
        NpIaItemAddOn: Record "NPR NpIa Item AddOn";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        AppliesToLineNo: Integer;
        UpdateCurrentSaleLine: Boolean;
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if BaseLineNo <> 0 then
            AppliesToLineNo := BaseLineNo
        else
            AppliesToLineNo := FindAppliesToLineNo(SaleLinePOS);
        UpdateCurrentSaleLine := SaleLinePOS."Line No." <> AppliesToLineNo;
        SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo);
        IF UpdateCurrentSaleLine THEN
            POSSaleLine.SetPosition(SaleLinePOS.GetPosition());

        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit;
        Item.Get(SaleLinePOS."No.");
        Item.TestField("NPR Item AddOn No.");

        NpIaItemAddOn.Get(Item."NPR Item AddOn No.");
        NpIaItemAddOn.TestField(Enabled);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        CurrNpIaItemAddOn := NpIaItemAddOn;
        if not NpIaItemAddOnMgt.UserInterfaceIsRequired(NpIaItemAddOn) then begin
            NpIaItemAddOnMgt.InsertFixedPOSAddOnLinesSilent(NpIaItemAddOn, POSSession, AppliesToLineNo);
            if NpIaItemAddOnMgt.InsertedWithAutoSplitKey() then
                POSSession.ChangeViewSale();  //there is no other way to refresh the lines, so they appear in correct order
            exit;
        end;
        NpIaItemAddOnMgt.CreateUserInterface(Model, SalePOS, SaleLinePOS, NpIaItemAddOn);
        ActiveModelID := FrontEnd.ShowModel(Model);
    end;

    //--- Approve ---

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', true, true)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    begin
        if ModelID <> ActiveModelID then
            exit;

        Handled := true;

        Approve(EventName, FrontEnd, Sender <> 'approve');
        FrontEnd.CloseModel(ModelID);
    end;

    local procedure Approve(JsonText: Text; FrontEnd: Codeunit "NPR POS Front End Management"; OnlyFixedQtyLines: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        POSJavaScriptInterface: Codeunit "NPR POS JavaScript Interface";
        AddOnLines: JsonToken;
        AppliesToLineNo: Integer;
    begin
        AddOnLines.ReadFrom(JsonText);
        FrontEnd.GetSession(POSSession);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if BaseLineNo <> 0 then
            AppliesToLineNo := BaseLineNo
        else
            AppliesToLineNo := FindAppliesToLineNo(SaleLinePOS);
        if NpIaItemAddOnMgt.InsertPOSAddOnLines(CurrNpIaItemAddOn, AddOnLines, POSSession, AppliesToLineNo, OnlyFixedQtyLines) then begin
            SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo);
            POSSaleLine.SetPosition(SaleLinePOS.GetPosition);
            if NpIaItemAddOnMgt.InsertedWithAutoSplitKey() then begin
                POSSession.ChangeViewSale();  //there is no other way to refresh the lines, so they appear in correct order
                exit;
            end;
            POSSession.RequestRefreshData();
        end;
        POSJavaScriptInterface.RefreshData(POSSession, FrontEnd);
    end;

    //--- Aux ---

    local procedure FindAppliesToLineNo(SaleLinePOS: Record "NPR POS Sale Line"): Integer
    var
        NpIaSaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        NpIaSaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
        NpIaSaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpIaSaleLinePOSAddOn.SetRange("Sale Type", SaleLinePOS."Sale Type");
        NpIaSaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
        NpIaSaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        if NpIaSaleLinePOSAddOn.FindFirst() then
            exit(NpIaSaleLinePOSAddOn."Applies-to Line No.");

        if SaleLinePOS.Accessory then
            exit(SaleLinePOS."Main Line No.");

        exit(SaleLinePOS."Line No.");
    end;

    trigger Model::OnModelControlEvent(control: DotNet NPRNetControl; eventName: Text; data: DotNet NPRNetDictionary_Of_T_U)
    begin
    end;

    trigger Model::OnTimer()
    begin
    end;
}