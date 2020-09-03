codeunit 6151128 "NPR POS Action: Run Item AddOn"
{
    // NPR5.48/MHA /20181113 CASE 334922 Object created - Insert Item AddOns from the currently selected POS Sales Line
    // NPR5.52/ALPO/20190912 CASE 354309 Suggest Item AddOns on after POS sale line insert
    // NPR5.54/ALPO/20200218 CASE 388951 Removed SuggestItemAddOnsOnSaleLineInsert workflow step from sale workflow AFTER_INSERT_LINE. Moved to POS Action 'ITEM'
    // NPR5.54/ALPO/20200219 CASE 374666 Item AddOns: auto-insert fixed quantity lines
    //                                     - Function Approve(): new call parameter: OnlyFixedQtyLines (boolean)
    //                                     - Functions InitScript(), InitScriptData(), CreateUserInterface(), WebDepCode(), InitCss(), InitHtml()
    //                                       moved out to CU 6151125 to avoid excessive code dublication

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
        //EXIT('1.0');  //NPR5.52 [354309]-revoked
        exit('1.1');  //NPR5.52 [354309]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              Text000,
              ActionVersion(),
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('run_addons', 'respond();');

                RegisterWorkflow(false);
                Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');
                Sender.RegisterCustomJavaScriptLogic('enable', 'return row.getField("ItemAddOn.ItemAddOn").rawValue;');
                RegisterIntegerParameter('BaseLineNo', 0);  //NPR5.52 [354309]
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        //-NPR5.52 [354309]
        JSON.InitializeJObjectParser(Context, FrontEnd);
        BaseLineNo := JSON.GetIntegerParameter('BaseLineNo', false);
        //+NPR5.52 [354309]

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
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        AddOnNo: Code[20];
        AppliesToLineNo: Integer;
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        //-NPR5.52 [354309]
        if BaseLineNo <> 0 then
            AppliesToLineNo := BaseLineNo
        else
            //+NPR5.52 [354309]
            AppliesToLineNo := FindAppliesToLineNo(SaleLinePOS);
        SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo);

        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit;
        Item.Get(SaleLinePOS."No.");
        Item.TestField("NPR Item AddOn No.");

        NpIaItemAddOn.Get(Item."NPR Item AddOn No.");
        NpIaItemAddOn.TestField(Enabled);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        CurrNpIaItemAddOn := NpIaItemAddOn;
        //CreateUserInterface(SalePOS,AppliesToLineNo,NpIaItemAddOn);  //NPR5.52 [354309]-revoked
        //CreateUserInterface(SalePOS,SaleLinePOS,NpIaItemAddOn);  //NPR5.52 [354309]  //NPR5.54 [374666]-revoked
        //+NPR5.54 [374666]
        if not NpIaItemAddOnMgt.UserInterfaceIsRequired(NpIaItemAddOn) then begin
            NpIaItemAddOnMgt.InsertFixedPOSAddOnLinesSilent(NpIaItemAddOn, POSSession, AppliesToLineNo);
            exit;
        end;
        NpIaItemAddOnMgt.CreateUserInterface(Model, SalePOS, SaleLinePOS, NpIaItemAddOn);
        //+NPR5.54 [374666]
        ActiveModelID := FrontEnd.ShowModel(Model);
    end;

    local procedure "--- Approve"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', true, true)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    begin
        if ModelID <> ActiveModelID then
            exit;

        Handled := true;

        //-NPR5.54 [374666]-revoked
        /*
        CASE Sender OF
          'approve':
            BEGIN
              Approve(EventName,FrontEnd);
              FrontEnd.CloseModel(ModelID);
            END;
          'cancel','close':
            BEGIN
              FrontEnd.CloseModel(ModelID);
            END;
        END;
        */
        //+NPR5.54 [374666]-revoked
        //-NPR5.54 [374666]
        Approve(EventName, FrontEnd, Sender <> 'approve');
        FrontEnd.CloseModel(ModelID);
        //+NPR5.54 [374666]

    end;

    local procedure Approve(JsonText: Text; FrontEnd: Codeunit "NPR POS Front End Management"; OnlyFixedQtyLines: Boolean)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        POSJavaScriptInterface: Codeunit "NPR POS JavaScript Interface";
        AddOnLines: DotNet JToken;
        AppliesToLineNo: Integer;
    begin
        AddOnLines := AddOnLines.Parse(JsonText);
        FrontEnd.GetSession(POSSession);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        //-NPR5.52 [354309]
        if BaseLineNo <> 0 then
            AppliesToLineNo := BaseLineNo
        else
            //+NPR5.52 [354309]
            AppliesToLineNo := FindAppliesToLineNo(SaleLinePOS);
        //NpIaItemAddOnMgt.InsertPOSAddOnLines(CurrNpIaItemAddOn,AddOnLines,POSSession,AppliesToLineNo);  //NPR5.54 [374666]-revoked
        if NpIaItemAddOnMgt.InsertPOSAddOnLines(CurrNpIaItemAddOn, AddOnLines, POSSession, AppliesToLineNo, OnlyFixedQtyLines) then begin  //NPR5.54 [374666]
                                                                                                                                           //-NPR5.52 [354309]
            SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo);
            POSSaleLine.SetPosition(SaleLinePOS.GetPosition);
            //+NPR5.52 [354309]
            POSSession.RequestRefreshData();
        end;  //NPR5.54 [374666]
        POSJavaScriptInterface.RefreshData(POSSession, FrontEnd);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure FindAppliesToLineNo(SaleLinePOS: Record "NPR Sale Line POS"): Integer
    var
        NpIaSaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        NpIaSaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
        NpIaSaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpIaSaleLinePOSAddOn.SetRange("Sale Type", SaleLinePOS."Sale Type");
        NpIaSaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
        NpIaSaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        if NpIaSaleLinePOSAddOn.FindFirst then
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

