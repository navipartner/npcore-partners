codeunit 6184879 "NPR POSAction TMScheduleSelect" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ActionDescription: Label 'This workflow drives the ticket schedule and ticket holder selection process for front-end UX.', MaxLength = 250;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'ConfigureWorkflow':
                FrontEnd.WorkflowResponse(ConfigureWorkflow(Context));
            'SetTicketHolder':
                FrontEnd.WorkflowResponse(SetTicketHolder(Context));
        End;
    end;

    local procedure ConfigureWorkflow(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        RequireParticipantInformation: Option NOT_REQUIRED,OPTIONAL,REQUIRED;
        AdmissionCode: Code[20];
        SuggestNotificationMethod: Option NA,EMAIL,SMS;
        SuggestNotificationAddress: Text[100];
        SuggestTicketHolderName: Text[100];
        Token: Text[100];
        ForceEditTicketHolder: Boolean;
    begin
        Token := CopyStr(Context.GetString('TicketToken'), 1, MaxStrLen(Token));
        Response.Add('ticketHolderTitle', 'Ticket Holder');
        Response.Add('ticketHolderCaption', 'Please provide ticket holder information.');
        Response.Add('ticketHolderNameLabel', 'Name');
        Response.Add('ticketHolderEmailLabel', 'Email');
        Response.Add('ticketHolderPhoneLabel', 'Phone');

        RequireParticipantInformation := NotifyParticipant.RequireParticipantInfo(Token, AdmissionCode, SuggestNotificationMethod, SuggestNotificationAddress, SuggestTicketHolderName);
        if (RequireParticipantInformation = RequireParticipantInformation::NOT_REQUIRED) then
            if (Context.GetBoolean('EditTicketHolder', ForceEditTicketHolder)) then
                if (ForceEditTicketHolder) then
                    RequireParticipantInformation := RequireParticipantInformation::OPTIONAL;

        Response.Add('ticketHolderName', SuggestTicketHolderName);

        if (StrPos(SuggestNotificationAddress, '@') > 0) then begin
            Response.Add('ticketHolderEmail', SuggestNotificationAddress);
            Response.Add('ticketHolderPhone', '');
        end else begin
            Response.Add('ticketHolderPhone', DelChr(SuggestNotificationAddress, '<=>', ' '));
            Response.Add('ticketHolderEmail', '');
        end;

        Response.Add('CaptureTicketHolder', RequireParticipantInformation in [RequireParticipantInformation::OPTIONAL, RequireParticipantInformation::REQUIRED]);

        exit;
    end;

    local procedure SetTicketHolder(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Token: Text[100];
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Name: Text;
        Email: Text;
        Phone: Text;
    begin
        Token := CopyStr(Context.GetString('TicketToken'), 1, MaxStrLen(Token));

        if (not Context.GetString('ticketHolderName', Name)) then
            Name := '';
        if (not Context.GetString('ticketHolderEmail', Email)) then
            Email := '';
        if (not Context.GetString('ticketHolderPhone', Phone)) then
            Phone := '';

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);

        if (TicketReservationRequest.FindSet()) then begin
            repeat
                if ((Email <> '') and (StrPos(Email, '@') > 0)) then begin
                    TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::Email;
                    TicketReservationRequest."Notification Address" := CopyStr(Email, 1, MaxStrLen(TicketReservationRequest."Notification Address"));
                end;
                // Phone number bias
                if ((Phone <> '') and (DelChr(Phone, '<=>', '+1234567890 ') = '') and (StrLen(Phone) >= 5)) then begin
                    TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::SMS;
                    TicketReservationRequest."Notification Address" := CopyStr(Phone, 1, MaxStrLen(TicketReservationRequest."Notification Address"));
                end;
                TicketReservationRequest.TicketHolderName := CopyStr(Name, 1, MaxStrLen(TicketReservationRequest.TicketHolderName));
                TicketReservationRequest.Modify();

            until (TicketReservationRequest.Next() = 0);
        end;

        Response.ReadFrom('{}');
        exit;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTMScheduleSelect.js###
'const main=async({workflow:t,context:e,popup:i})=>{debugger;const l=await t.respond("ConfigureWorkflow",e);debugger;return e.EditSchedule&&await i.entertainment.scheduleSelection({token:e.TicketToken})===null?{cancel:!0}:((l.CaptureTicketHolder||e.EditTicketHolder)&&await captureTicketHolderInfo(t,l),{cancel:!1})};async function captureTicketHolderInfo(t,e){const i=await popup.configuration({title:e.ticketHolderTitle,caption:e.ticketHolderCaption,settings:[{id:"ticketHolderName",type:"text",caption:e.ticketHolderNameLabel,value:e.ticketHolderName},{id:"ticketHolderEmail",type:"text",caption:e.ticketHolderEmailLabel,value:e.ticketHolderEmail},{id:"ticketHolderPhone",type:"phoneNumber",caption:e.ticketHolderPhoneLabel,value:e.ticketHolderPhone}]});i!==null&&await t.respond("SetTicketHolder",i)}'
    );
    end;
}
