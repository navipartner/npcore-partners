codeunit 6248457 "NPR POS Action RegisterGuests" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescLbl: Label 'This action allows you to register member guests based on the last speedgate scan';
        NoGuestsToAddLbl: Label 'There''s no guests to add for this membership';
        RegisterGuestsLbl: Label 'Register Guests';
        AlreadyRegisteredTodayLbl: Label 'guests already registered today', Comment = 'will be prefixed in the javascript with the number of guests already registered';
        GuestsRegisteredLbl: Label 'guests registered!', Comment = 'Used for toaster. Will be prefix in the javascirpt with the total number of guests registered';
        RestrictTodayNameLbl: Label 'Restrict Guests on Today';
        RestrictTodayDescLbl: Label 'Specifies if the code should restrict guest admissions per day.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescLbl);
        WorkflowConfig.AddLabel('noGuestsToAdd', NoGuestsToAddLbl);
        WorkflowConfig.AddLabel('registerGuests', RegisterGuestsLbl);
        WorkflowConfig.AddLabel('alreadyRegistered', AlreadyRegisteredTodayLbl);
        WorkflowConfig.AddLabel('guestsRegistered', GuestsRegisteredLbl);
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
            'const main=async({workflow:r,popup:o,toast:m,captions:n,parameters:f})=>{const s=await r.respond("GetConfiguration");if(!s||!s.success){await o.error(s.errorMessage);return}if(!s.guests||s.guests.length<=0){await o.message(n.noGuestsToAdd);return}const u=[];s.guests.forEach(e=>{const t={type:"plusminus",id:e.token,minValue:0,value:0,caption:e.description};e.maxNumberOfGuests>-1&&(t.maxValue=e.maxNumberOfGuests,f.restrictToday&&e.guestsAdmittedToday>0&&(t.maxValue=e.maxNumberOfGuests-e.guestsAdmittedToday,t.caption=`${t.caption} (${String(e.guestsAdmittedToday)} ${n.alreadyRegistered})`,t.maxValue===0&&(t.maxValue=-1))),u.push(t)});const a=await o.configuration({title:n.registerGuests,settings:u});if(console.log(a),!a)return;const d=[];Object.keys(a).forEach(e=>{d.push({token:e,quantity:Number(a[e])})}),await r.respond("AdmitTokens",{admitTokens:d});debugger;let i="",c=0;if(s.guests.forEach(e=>{const t=a[e.token];t>0&&(c+=t,i!==""&&(i+=", "),i+=`${e.description}: ${t}`)}),i!==""){const e=`${c} ${n.guestsRegistered}`;await m.success(i,{title:e})}};'
        );
    end;
}