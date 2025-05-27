codeunit 6248457 "NPR POS Action RegisterGuests" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescLbl: Label 'This action allows you to register member guests based on the last speedgate scan';
        NoGuestsToAddLbl: Label 'There''s no guests to add for this membership';
        RegisterGuestsLbl: Label 'Register Guests';
        AlreadyRegisteredTodayLbl: Label 'guests already registered today', Comment = 'will be prefixed in the javascript with the number of guests already registerd';
        RestrictTodayNameLbl: Label 'Restrict Guests on Today';
        RestrictTodayDescLbl: Label 'Specifies if the code should restrict guest admissions per day.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescLbl);
        WorkflowConfig.AddLabel('noGuestsToAdd', NoGuestsToAddLbl);
        WorkflowConfig.AddLabel('registerGuests', RegisterGuestsLbl);
        WorkflowConfig.AddLabel('alreadyRegistered', AlreadyRegisteredTodayLbl);
        WorkflowConfig.AddBooleanParameter('restrictToday', false, RestrictTodayNameLbl, RestrictTodayDescLbl);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        RegisterGuestsBackend: Codeunit "NPR POSActionRegisterGuestsB";
        POSUnit: Record "NPR POS Unit";
        Tokens: JsonArray;
    begin
        case Step of
            'GetConfiguration':
                begin
                    Setup.GetPOSUnit(POSUnit);
                    FrontEnd.WorkflowResponse(RegisterGuestsBackend.GetConfigurationJson(POSUnit."No."));
                end;
            'AdmitTokens':
                begin
                    Tokens := Context.GetJToken('admitTokens').AsArray();
                    RegisterGuestsBackend.AdmitTokens(Tokens);
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
            //###NPR_INJECT_FROM_FILE:POSActionRegisterGuests.js###
            'const main=async({workflow:o,popup:i,captions:n,parameters:c})=>{const s=await o.respond("GetConfiguration");if(!s||!s.success){await i.error(s.errorMessage);return}if(!s.guests||s.guests.length<=0){await i.message(n.noGuestsToAdd);return}const r=[];s.guests.forEach(e=>{const t={type:"plusminus",id:e.token,minValue:0,value:0,caption:e.description};e.maxNumberOfGuests>-1&&(t.maxValue=e.maxNumberOfGuests,c.restrictToday&&e.guestsAdmittedToday>0&&(t.maxValue=e.maxNumberOfGuests-e.guestsAdmittedToday,t.caption=`${t.caption} (${String(e.guestsAdmittedToday)} ${n.alreadyRegistered})`,t.maxValue===0&&(t.maxValue=-1))),r.push(t)});const a=await i.configuration({title:n.registerGuests,settings:r});if(console.log(a),!a)return;const u=[];Object.keys(a).forEach(e=>{u.push({token:e,quantity:Number(a[e])})}),await o.respond("AdmitTokens",{admitTokens:u})};'
        );
    end;
}