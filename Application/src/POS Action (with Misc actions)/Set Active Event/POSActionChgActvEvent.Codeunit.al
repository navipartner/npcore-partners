codeunit 6060161 "NPR POS Action: Chg.Actv.Event" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescription: Label 'Set an Event Management module event as active for current POS unit and sale';
        ParameterDialogType_OptionNameLbl: Label 'TextField,List', Locked = true;
        ParameterDialogType_OptionCaptionsLbl: Label 'TextField,List';
        ParameterDialogType_NameLbl: Label 'Dialog Type';
        ParamClearEvent_NameLbl: Label 'Clear event';
        ParamCurrSale_NameLbl: Label 'Only Current Sale';
        EventNoLbl: Label 'Event No.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('DialogType',
            ParameterDialogType_OptionNameLbl,
#pragma warning disable AA0139
            SelectStr(2, ParameterDialogType_OptionNameLbl),
#pragma warning restore 
            ParameterDialogType_NameLbl,
            ParameterDialogType_NameLbl,
            ParameterDialogType_OptionCaptionsLbl);
        WorkflowConfig.AddBooleanParameter('ClearEvent', false, ParamClearEvent_NameLbl, ParamClearEvent_NameLbl);
        WorkflowConfig.AddBooleanParameter('OnlyCurrentSale', false, ParamCurrSale_NameLbl, ParamCurrSale_NameLbl);
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSale());

        WorkflowConfig.AddLabel('confirmTitle', EventNoLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        BusinessLogic: Codeunit "NPR POS Act:Chg.Actv.Event BL";
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        DialogType: Option TextField,List;
        EventNo: Code[20];
        ClearEvent: Boolean;
        OnlyCurrentSale: Boolean;
    begin
        case Step of
            'ProcessChange':
                begin
                    DialogType := Context.GetIntegerParameter('DialogType');
                    if not (DialogType in [DialogType::TextField, DialogType::List]) then
                        DialogType := DialogType::List;
                    ClearEvent := Context.GetBooleanParameter('ClearEvent');
                    if ClearEvent then
                        EventNo := '';
                    OnlyCurrentSale := Context.GetBooleanParameter('OnlyCurrentSale');

                    if not ClearEvent then begin
                        Sale.GetCurrentSale(SalePOS);
                        SalePOS.TestField("Register No.");
                        POSUnit.Get(SalePOS."Register No.");

                        case DialogType of
                            DialogType::TextField:
                                EventNo := CopyStr(Context.GetString('textfield'), 1, MaxStrLen(EventNo));
                            DialogType::List:
                                begin
                                    EventNo := POSUnit.FindActiveEventFromCurrPOSUnit();
                                    if not BusinessLogic.SelectEventFromList(EventNo) then
                                        exit;
                                end;
                        end;
                    end;

                    BusinessLogic.UpdateCurrentEvent(Sale, EventNo, not OnlyCurrentSale);
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionChgActvEvent.js###
'let main=async({workflow:n,parameters:i,popup:a,captions:e})=>{if(!i.ClearEvent&&i.DialogType==i.DialogType.TextField){var l=await a.input({title:e.confirmTitle,caption:e.confirmLead,value:""});if(l==null)return}await n.respond("ProcessChange",{textfield:l})};'
        );
    end;
}

