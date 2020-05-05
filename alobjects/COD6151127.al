codeunit 6151127 "POS Action - Insert Item AddOn"
{
    // NPR5.48/MHA /20181113 CASE 334922 Object created - Insert Item AddOns directly from POS Action
    // NPR5.52/ALPO/20190912 CASE 354309 Updated function call to respect the new signature
    // NPR5.54/ALPO/20200219 CASE 374666 Item AddOns: auto-insert fixed quantity lines regardless of user response
    //                                     - Function Approve(): new call parameter: OnlyFixedQtyLines (boolean)
    //                                     - Functions InitScript(), InitScriptData(), CreateUserInterface(), WebDepCode(), InitCss(), InitHtml()
    //                                       moved out to CU 6151125 to avoid excessive code dublication

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        CurrNpIaItemAddOn: Record "NpIa Item AddOn";
        [WithEvents]
        Model: DotNet npNetModel;
        ActiveModelID: Guid;
        Text000: Label 'Insert Item AddOns directly from POS Action';

    local procedure ActionCode(): Text
    begin
        exit('INSERT_ITEM_ADDONS');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            Text000,
            ActionVersion(),
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('select_addon',
              'if (param.ItemAddOnNo) {' +
              '  context.item_addon = param.ItemAddOnNo;' +
              '} else {' +
              '  respond();' +
              '}'
            );
            RegisterWorkflowStep('insert_addons',
              'if (context.item_addon) {' +
              '  respond();' +
              '}'
            );
            RegisterWorkflow(false);

            RegisterTextParameter('ItemAddOnNo','');
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupItemAddOn(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        NpIaItemAddOn: Record "NpIa Item AddOn";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'ItemAddOnNo' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        Handled := true;

        NpIaItemAddOn.SetRange(Enabled,true);
        if PAGE.RunModal(0,NpIaItemAddOn) = ACTION::LookupOK then
          POSParameterValue.Value := NpIaItemAddOn."No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'select_addon':
            OnActionSelectAddOn(JSON,FrontEnd);
          'insert_addons' :
            OnActionInsertAddOns(JSON,POSSession,FrontEnd);
        end;

        Handled := true;
    end;

    local procedure OnActionSelectAddOn(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        NpIaItemAddOn: Record "NpIa Item AddOn";
    begin
        NpIaItemAddOn.SetRange(Enabled,true);
        if PAGE.RunModal(0,NpIaItemAddOn) <> ACTION::LookupOK then
          exit;

        JSON.SetContext('item_addon',NpIaItemAddOn."No.");
        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure OnActionInsertAddOns(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        NpIaItemAddOn: Record "NpIa Item AddOn";
        SalePOS: Record "Sale POS";
        AppliesToSaleLinePOS: Record "Sale Line POS";
        NpIaItemAddOnMgt: Codeunit "NpIa Item AddOn Mgt.";
        POSSale: Codeunit "POS Sale";
        AddOnNo: Code[20];
    begin
        JSON.SetScope('/',true);
        AddOnNo := JSON.GetString('item_addon',true);
        NpIaItemAddOn.Get(AddOnNo);
        NpIaItemAddOn.TestField(Enabled);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        CurrNpIaItemAddOn := NpIaItemAddOn;
        //CreateUserInterface(SalePOS,NpIaItemAddOn);  //NPR5.54 [374666]-revoked
        //-NPR5.54 [374666]
        Clear(AppliesToSaleLinePOS);
        NpIaItemAddOnMgt.CreateUserInterface(Model,SalePOS,AppliesToSaleLinePOS,NpIaItemAddOn);
        //+NPR5.54 [374666]
        ActiveModelID := FrontEnd.ShowModel(Model);
    end;

    local procedure "--- Approve"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', true, true)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";ModelID: Guid;Sender: Text;EventName: Text;var Handled: Boolean)
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
        Approve(EventName,FrontEnd,Sender <> 'approve');
        FrontEnd.CloseModel(ModelID);
        //+NPR5.54 [374666]

    end;

    local procedure Approve(JsonText: Text;FrontEnd: Codeunit "POS Front End Management";OnlyFixedQtyLines: Boolean)
    var
        POSSession: Codeunit "POS Session";
        NpIaItemAddOnMgt: Codeunit "NpIa Item AddOn Mgt.";
        POSJavaScriptInterface: Codeunit "POS JavaScript Interface";
        AddOnLines: DotNet JToken;
    begin
        AddOnLines := AddOnLines.Parse(JsonText);
        FrontEnd.GetSession(POSSession);
        //NpIaItemAddOnMgt.InsertPOSAddOnLines(CurrNpIaItemAddOn,AddOnLines,POSSession,0);  //NPR5.54 [374666]-revoked
        NpIaItemAddOnMgt.InsertPOSAddOnLines(CurrNpIaItemAddOn,AddOnLines,POSSession,0,OnlyFixedQtyLines);  //NPR5.54 [374666]

        POSSession.RequestRefreshData();
        POSJavaScriptInterface.RefreshData(POSSession,FrontEnd);
    end;

    trigger Model::OnModelControlEvent(control: DotNet npNetControl;eventName: Text;data: DotNet npNetDictionary_Of_T_U)
    begin
    end;

    trigger Model::OnTimer()
    begin
    end;
}

