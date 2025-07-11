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
            'AssignSameSchedule':
                FrontEnd.WorkflowResponse(AssignSameSchedule(Context, SaleLine));
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
        SuggestNotificationMethod: Enum "NPR TM NotificationMethod";
        SuggestNotificationAddress: Text[100];
        SuggestTicketHolderName: Text[100];
        Token: Text[100];
        NewToken: Text[100];
        ForceEditTicketHolder: Boolean;
        FunctionId: Integer;
        Ticket: Record "NPR TM Ticket";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        POSFunction: Codeunit "NPR POS Action - Ticket Mgt B.";
        POSSession: Codeunit "NPR POS Session";
        TicketReference: Code[50];
    begin
        Token := CopyStr(Context.GetString('TicketToken'), 1, MaxStrLen(Token));
        Context.GetInteger('FunctionId', FunctionId);

        if FunctionId = 10 then begin //if ticket request has all lines confirmed, not need to create request?
            TicketRequest.SetCurrentKey("Session Token ID");
            TicketRequest.SetFilter("Session Token ID", '=%1', Token);
            if TicketRequest.FindFirst() then begin
                Ticket.SetRange("Ticket Reservation Entry No.", TicketRequest."Entry No.");
                if Ticket.FindFirst() then
                    TicketReference := Ticket."External Ticket No.";
            end;

            if TicketReference = '' then
                TicketReference := CopyStr(Token, 1, MaxStrLen(TicketReference));

            POSFunction.AddAdditionalExperience(POSSession, TicketReference);
        end;

        NewToken := GetNewTicketToken(Token);
        if NewToken <> '' then
            Context.SetContext('TicketToken', NewToken);

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

    local procedure GetNewTicketToken(TicketReference: Code[100]) Token: Text[100]
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestEntryNo: Integer;
    begin
        if (TicketReference <> '') then begin
            TicketRequest.SetCurrentKey("Session Token ID");
            TicketRequest.SetFilter("Session Token ID", '=%1', TicketReference);
            if TicketRequest.FindFirst() then
                TicketRequestEntryNo := TicketRequest."Entry No.";
        end;

        if TicketRequestEntryNo <> 0 then begin
            Clear(TicketRequest);
            TicketRequest.SetFilter("Request Status", '%1|%2|%3', TicketRequest."Request Status"::REGISTERED, TicketRequest."Request Status"::WIP, TicketRequest."Request Status"::OPTIONAL);
            TicketRequest.SetRange("Superseeds Entry No.", TicketRequestEntryNo);
            if TicketRequest.FindLast() then
                Token := TicketRequest."Session Token ID";
        end;
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


    local procedure AssignSameSchedule(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        TicketRetailManagement: Codeunit "NPR TM Ticket Retail Mgt.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        HTMLDisplay: Codeunit "NPR POS HTML Disp. Prof.";
        POSProxyDisplay: Codeunit "NPR POS Proxy - Display";
        SaleLinePOS: Record "NPR POS Sale Line";
        Token: Text[100];
        ResponseMessage: Text;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        RequiredAdmissionHasTimeSlots, OnlyRequiredAdmissions : Boolean;
        Item: Record "Item";
        HaveSaleTicketSalesLine: Boolean;
        FunctionId: Integer;
    begin

        Token := CopyStr(Context.GetString('TicketToken'), 1, MaxStrLen(Token));

        // 3 Edit Schedule (forced)
        FunctionId := -1;
        if (Context.HasProperty('FunctionId')) then
            FunctionId := Context.GetInteger('FunctionId');

        HaveSaleTicketSalesLine := true;
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (Item.Get(SaleLinePOS."No.")) then begin
            if (Item."NPR Item AddOn No." <> '') then begin
                HaveSaleTicketSalesLine := false;
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetCurrentKey("Session Token ID");
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                if (TicketReservationRequest.FindFirst()) then begin
                    SaleLinePOS.Reset();
                    SaleLinePOS.SetFilter("Register No.", '=%1', SaleLinePOS."Register No.");
                    SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', TicketReservationRequest."Receipt No.");
                    SaleLinePOS.SetFilter("Line No.", '=%1', TicketReservationRequest."Line No.");
                    HaveSaleTicketSalesLine := SaleLinePOS.FindFirst();
                end;
            end;
        end;

        TicketRetailManagement.AssignSameSchedule(Token, HaveSaleTicketSalesLine and (SaleLinePOS.Indentation > 0));
        TicketRetailManagement.AssignSameNotificationAddress(Token);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
        TicketReservationRequest.SetRange("Admission Inclusion", TicketReservationRequest."Admission Inclusion"::REQUIRED);
        RequiredAdmissionHasTimeSlots := TicketReservationRequest.IsEmpty();

        TicketReservationRequest.SetRange("External Adm. Sch. Entry No.");
        TicketReservationRequest.SetFilter("Admission Inclusion", '<>%1', TicketReservationRequest."Admission Inclusion"::REQUIRED);
        OnlyRequiredAdmissions := TicketReservationRequest.IsEmpty();

        if ((not (RequiredAdmissionHasTimeSlots and OnlyRequiredAdmissions)) or (FunctionId = 3)) then begin
            Response.Add('CancelScheduleSelection', false);
            Response.Add('EditSchedule', true);
            exit(Response);
        end;

        if (0 = TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage)) then begin
            if (HaveSaleTicketSalesLine) then begin
                TicketRetailManagement.AdjustPriceOnSalesLine(SaleLinePOS, SaleLinePOS.Quantity);

                TicketReservationRequest.Reset();
                TicketReservationRequest.SetCurrentKey("Session Token ID");
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
                if (TicketReservationRequest.FindFirst()) then begin
                    SaleLinePOS."Description 2" := TicketReservationRequest."Scheduled Time Description";
                    SaleLinePOS.Modify();
                end;

                HTMLDisplay.UpdateHTMLDisplay();
                POSProxyDisplay.UpdateDisplay(SaleLinePOS);
            end;
        end else begin
            Response.Add('CancelScheduleSelection', true);
            Response.Add('EditSchedule', false);
            Response.Add('Message', ResponseMessage);
            exit(Response);
        end;

        Response.Add('CancelScheduleSelection', false);
        Response.Add('EditSchedule', false);
        exit(Response);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTMScheduleSelect.js###
'const main=async({workflow:t,context:e,popup:i})=>{debugger;const a=await t.respond("AssignSameSchedule",e);if(a.CancelScheduleSelection)return toast.error(a.Message),{cancel:!0};if(!a.EditSchedule)return{cancel:!1};const l=await t.respond("ConfigureWorkflow",e);return e.EditSchedule&&await i.entertainment.scheduleSelection({token:e.TicketToken})===null?{cancel:!0}:((l.CaptureTicketHolder||e.EditTicketHolder)&&await captureTicketHolderInfo(t,l),{cancel:!1})};async function captureTicketHolderInfo(t,e){const i=await popup.configuration({title:e.ticketHolderTitle,caption:e.ticketHolderCaption,settings:[{id:"ticketHolderName",type:"text",caption:e.ticketHolderNameLabel,value:e.ticketHolderName},{id:"ticketHolderEmail",type:"text",caption:e.ticketHolderEmailLabel,value:e.ticketHolderEmail},{id:"ticketHolderPhone",type:"phoneNumber",caption:e.ticketHolderPhoneLabel,value:e.ticketHolderPhone}]});i!==null&&await t.respond("SetTicketHolder",i)}'
    );
    end;
}
