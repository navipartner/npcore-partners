codeunit 6184879 "NPR POSAction TMScheduleSelect" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ActionDescription: Label 'This workflow drives the ticket schedule and ticket holder selection process for front-end UX.', MaxLength = 250;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        TicketHolderLbl: Label 'Ticket Holder';
        TicketHolderCaptionLbl: Label 'Please provide ticket holder information.';
        NameLbl: Label 'Name';
        PhoneLbl: Label 'Phone';
        EmailLbl: Label 'Email';
        LanguageLbl: Label 'Language';
    begin
        WorkflowConfig.SetNonBlockingUI();
        WorkflowConfig.AddLabel('ticketHolderTitle', TicketHolderLbl);
        WorkflowConfig.AddLabel('ticketHolderCaption', TicketHolderCaptionLbl);
        WorkflowConfig.AddLabel('ticketHolderNameLabel', NameLbl);
        WorkflowConfig.AddLabel('ticketHolderEmailLabel', EmailLbl);
        WorkflowConfig.AddLabel('ticketHolderPhoneLabel', PhoneLbl);
        WorkflowConfig.AddLabel('ticketHolderLanguageLabel', LanguageLbl);
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin

        case Step of
            'AssignSameSchedule':
                FrontEnd.WorkflowResponse(AssignSameSchedule(Context, SaleLine));
            'AssignSameScheduleToSet':
                FrontEnd.WorkflowResponse(AssignSameScheduleToSet(Context, SaleLine));

            'ConfigureWorkflow':
                FrontEnd.WorkflowResponse(ConfigureWorkflow(Context));
            'SetTicketHolder':
                FrontEnd.WorkflowResponse(SetTicketHolder(Context));
        End;
    end;


    local procedure ConfigureWorkflow(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Token: Text[100];
        JToken: JsonToken;
        Tokens: JsonArray;
        ForceEditTicketHolder: Boolean;
    begin

        // Get ticket holder data for the first token
        if (Context.HasProperty('TicketTokens')) then begin
            JToken := Context.GetJToken('TicketTokens');
            if (JToken.IsArray()) then
                Tokens := JToken.AsArray();
        end;

        if (Context.HasProperty('TicketToken')) then begin
            Token := CopyStr(Context.GetString('TicketToken'), 1, MaxStrLen(Token));
            Tokens.Add(Token);
        end;

        if (not Context.GetBoolean('EditTicketHolder', ForceEditTicketHolder)) then
            ForceEditTicketHolder := false;

        if (Tokens.Count() = 0) then
            Error('No ticket token provided for workflow configuration.');

        Tokens.Get(0, JToken);
        Token := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(Token));

        AddAdditionExperience(Token, Context);
        GetTicketHolder(Token, ForceEditTicketHolder, Response);
    end;

    local procedure AddAdditionExperience(Token: Text[100]; Context: Codeunit "NPR POS JSON Helper")
    var
        FunctionId: Integer;
        Ticket: Record "NPR TM Ticket";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        POSFunction: Codeunit "NPR POS Action - Ticket Mgt B.";
        POSSession: Codeunit "NPR POS Session";
        TicketReference: Code[50];
    begin
        Context.GetInteger('FunctionId', FunctionId);

        if (FunctionId = 10) then begin //if ticket request has all lines confirmed, not need to create request?
            TicketRequest.SetCurrentKey("Session Token ID");
            TicketRequest.SetFilter("Session Token ID", '=%1', Token);
            if (TicketRequest.FindFirst()) then begin
                Ticket.SetRange("Ticket Reservation Entry No.", TicketRequest."Entry No.");
                if (Ticket.FindFirst()) then
                    TicketReference := Ticket."External Ticket No.";
            end;

            if (TicketReference = '') then
                TicketReference := CopyStr(Token, 1, MaxStrLen(TicketReference));

            POSFunction.AddAdditionalExperience(POSSession, TicketReference);
        end;
    end;


    local procedure GetTicketHolder(Token: Text[100]; ForceEditTicketHolder: Boolean; var Response: JsonObject) CaptureTicketHolder: Boolean
    var
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        RequireParticipantInformation: Option NOT_REQUIRED,OPTIONAL,REQUIRED;
        AdmissionCode: Code[20];
        SuggestNotificationMethod: Enum "NPR TM NotificationMethod";
        SuggestNotificationAddress: Text[100];
        SuggestTicketHolderName: Text[100];
        SuggestTicketHolderLanguage: Code[10];

        // ForceEditTicketHolder: Boolean;

        Language: Record Language;
        JArray: JsonArray;
        JObject: JsonObject;
        NoSpecificLanguageLbl: Label 'No specific language';
    begin

        RequireParticipantInformation := NotifyParticipant.RequireParticipantInfo(Token, AdmissionCode, SuggestNotificationMethod, SuggestNotificationAddress, SuggestTicketHolderName, SuggestTicketHolderLanguage);
        if (RequireParticipantInformation = RequireParticipantInformation::NOT_REQUIRED) then
            if (ForceEditTicketHolder) then
                RequireParticipantInformation := RequireParticipantInformation::OPTIONAL;

        if (RequireParticipantInformation = RequireParticipantInformation::NOT_REQUIRED) then
            exit(false);

        Response.Add('ticketToken', Token);
        Response.Add('ticketHolderName', SuggestTicketHolderName);

        if (SuggestTicketHolderLanguage = '') then
            Response.Add('ticketHolderLanguage', 'NO_LANGUAGE_SELECTED')
        else
            Response.Add('ticketHolderLanguage', SuggestTicketHolderLanguage);

        if (StrPos(SuggestNotificationAddress, '@') > 0) then begin
            Response.Add('ticketHolderEmail', SuggestNotificationAddress);
            Response.Add('ticketHolderPhone', '');
        end else begin
            Response.Add('ticketHolderPhone', DelChr(SuggestNotificationAddress, '<=>', ' '));
            Response.Add('ticketHolderEmail', '');
        end;

        if (Language.FindSet()) then begin
            JObject.Add('value', 'NO_LANGUAGE_SELECTED');
            JObject.Add('caption', StrSubstNo('(%1)', NoSpecificLanguageLbl));
            JArray.Add(JObject);
            repeat
                Clear(JObject);
                JObject.Add('value', Language.Code);
                JObject.Add('caption', Language.Name);
                JArray.Add(JObject);
            until (Language.Next() = 0);
        end;

        Response.Add('availableLanguages', JArray);
        CaptureTicketHolder := RequireParticipantInformation in [RequireParticipantInformation::OPTIONAL, RequireParticipantInformation::REQUIRED];
        Response.Add('CaptureTicketHolder', CaptureTicketHolder);
    end;

    local procedure SetTicketHolder(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Token: Text[100];
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Name: Text;
        Email: Text;
        Phone: Text;
        Language: Text;
        JToken: JsonToken;
        Tokens: JsonArray;
    begin
        // Token := CopyStr(Context.GetString('TicketToken'), 1, MaxStrLen(Token));
        // Get ticket holder data for the first token
        if (Context.HasProperty('TicketTokens')) then begin
            JToken := Context.GetJToken('TicketTokens');
            if (JToken.IsArray()) then
                Tokens := JToken.AsArray();
        end;
        if (Context.HasProperty('TicketToken')) then begin
            Token := CopyStr(Context.GetString('TicketToken'), 1, MaxStrLen(Token));
            Tokens.Add(Token);
        end;

        if (not Context.GetString('ticketHolderName', Name)) then
            Name := '';
        if (not Context.GetString('ticketHolderEmail', Email)) then
            Email := '';
        if (not Context.GetString('ticketHolderPhone', Phone)) then
            Phone := '';
        if (not Context.GetString('ticketHolderLanguage', Language)) then
            Language := '';
        if (Language = 'NO_LANGUAGE_SELECTED') then
            Language := '';


        TicketReservationRequest.SetCurrentKey("Session Token ID");
        foreach JToken in Tokens do begin
            Token := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(Token));

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
                    TicketReservationRequest.Validate(TicketHolderPreferredLanguage, Language.ToUpper());
                    TicketReservationRequest.Modify();

                until (TicketReservationRequest.Next() = 0);
            end;
        end;

        Response.ReadFrom('{}');
        exit;
    end;

    local procedure AssignSameScheduleToSet(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        ConfiguredToken: Text[100];
        TokensToConfigure: JsonArray;
        ForceEditTicketHolder: Boolean;
        FunctionId: Integer;
        SaleLinePos: Record "NPR POS Sale Line";
        RegisterNo: Code[10];
    begin
        if (Context.HasProperty('ConfiguredToken')) then
            ConfiguredToken := CopyStr(Context.GetString('ConfiguredToken'), 1, MaxStrLen(ConfiguredToken));

        if (Context.HasProperty('setSchedulesForTokens')) then
            TokensToConfigure := Context.GetJToken('setSchedulesForTokens').AsArray();

        if (not Context.GetBoolean('EditTicketHolder', ForceEditTicketHolder)) then
            ForceEditTicketHolder := false;

        FunctionId := -1;
        if (Context.HasProperty('FunctionId')) then
            FunctionId := Context.GetInteger('FunctionId');

        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        RegisterNo := SaleLinePOS."Register No.";

        ApplySelectedSchedulesToToken(FunctionId, ConfiguredToken, TokensToConfigure, ForceEditTicketHolder, RegisterNo, Response);
    end;


    local procedure ApplySelectedSchedulesToToken(FunctionId: Integer; MasterToken: Text[100]; TokensToConfigure: JsonArray; ForceEditTicketHolder: Boolean; RegisterNo: Code[10]; Response: JsonObject)
    var
        TicketReservationRequestMaster: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequestSlave: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequestOrder: Record "NPR TM Ticket Reservation Req.";
        SaleLinePOS: Record "NPR POS Sale Line";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";

        RequestToken: Text[100];
        ResponseMessage: Text;

        JToken: JsonToken;
        MissingScheduleCount: Integer;
        ConfiguredTokens: JsonArray;
        TicketHolder: JsonObject;
        TicketHolders: JsonArray;
    begin

        TicketReservationRequestMaster.SetCurrentKey("Session Token ID");
        TicketReservationRequestMaster.SetFilter("Session Token ID", '=%1', MasterToken);

        foreach JToken in TokensToConfigure do begin
            RequestToken := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(RequestToken));
            MissingScheduleCount := 0;

            // For the slave token, find all non-time-slotted reservation lines and assign them the same schedule as the master token if they have the same admission code
            TicketReservationRequestSlave.SetCurrentKey("Session Token ID");
            TicketReservationRequestSlave.SetFilter("Session Token ID", '=%1', RequestToken);
            TicketReservationRequestSlave.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
            TicketReservationRequestSlave.SetFilter("Admission Inclusion", '<>%1', TicketReservationRequestSlave."Admission Inclusion"::NOT_SELECTED);
            if (TicketReservationRequestSlave.FindSet()) then begin
                repeat
                    MissingScheduleCount += 1;

                    TicketReservationRequestMaster.SetFilter("Admission Code", '=%1', TicketReservationRequestSlave."Admission Code");
                    if (TicketReservationRequestMaster.FindFirst()) then begin
                        if (TicketReservationRequestMaster."External Adm. Sch. Entry No." > 0) then begin
                            TicketReservationRequestSlave."External Adm. Sch. Entry No." := TicketReservationRequestMaster."External Adm. Sch. Entry No.";
                            TicketReservationRequestSlave."Scheduled Time Description" := TicketReservationRequestMaster."Scheduled Time Description";
                            TicketReservationRequestSlave.Modify();
                            MissingScheduleCount -= 1;
                        end;
                    end;
                until (TicketReservationRequestSlave.Next() = 0);
            end;

            if (MissingScheduleCount = 0) then begin
                ConfiguredTokens.Add(RequestToken); // Signal that this token has been assigned the same schedule and does not need user selection

                if (0 <> TicketRequestManager.IssueTicketFromReservationToken(RequestToken, false, ResponseMessage)) then begin
                    // Abort the whole process if ticket creation fails
                    Response.Add('CancelScheduleSelection', true); // Request to clean up the sale lines
                    Response.Add('EditSchedule', false);
                    Response.Add('Message', ResponseMessage);
                    exit;
                end;

                TicketReservationRequestOrder.SetCurrentKey("Session Token ID");
                TicketReservationRequestOrder.SetFilter("Session Token ID", '=%1', RequestToken);
                TicketReservationRequestOrder.SetFilter("Primary Request Line", '=%1', true);
                if (TicketReservationRequestOrder.FindFirst()) then begin
                    SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
                    SaleLinePOS.SetFilter("Register No.", '=%1', RegisterNo);
                    SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', TicketReservationRequestOrder."Receipt No.");
                    SaleLinePOS.SetFilter("Line No.", '=%1', TicketReservationRequestOrder."Line No.");
                    if (SaleLinePOS.FindFirst()) then begin
                        SaleLinePOS."Description 2" := TicketReservationRequestOrder."Scheduled Time Description";
                        SaleLinePOS.Modify();
                    end;
                end;
            end;
        end;

        if (GetTicketHolder(MasterToken, ForceEditTicketHolder, TicketHolder)) then
            TicketHolders.Add(TicketHolder);

        Response.Add('AssignedTokens', ConfiguredTokens);
        Response.Add('CancelScheduleSelection', false);
        Response.Add('EditSchedule', (FunctionId = 3) or (ConfiguredTokens.Count() < TokensToConfigure.Count())); // 3 Edit Schedule (forced)
        Response.Add('TicketHolders', TicketHolders);
    end;


    local procedure AssignSameSchedule(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line"): JsonObject
    begin
        exit(AssignSameScheduleWorker(Context, SaleLine));
    end;

    local procedure AssignSameScheduleWorker(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        TicketRetailManagement: Codeunit "NPR TM Ticket Retail Mgt.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        HTMLDisplay: Codeunit "NPR POS HTML Disp. Prof.";
        POSProxyDisplay: Codeunit "NPR POS Proxy - Display";
        SaleLinePOS: Record "NPR POS Sale Line";
        Token: Text[100];
        Tokens, ConfiguredTokens : JsonArray;
        JToken: JsonToken;
        ResponseMessage: Text;

        TicketReservationRequestMaster: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequestCheck, TicketReservationRequestCheck2 : Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequestOrder: Record "NPR TM Ticket Reservation Req.";

        RequiredAdmissionHasTimeSlots, OnlyRequiredAdmissions : Boolean;
        HaveSaleTicketSalesLine: Boolean;
        FunctionId: Integer;
        RegisterNo: Code[10];

        TicketHolder: JsonObject;
        TicketHolders: JsonArray;
        ForceEditTicketHolder: Boolean;
    begin

        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        RegisterNo := SaleLinePOS."Register No.";

        if (Context.HasProperty('TicketTokens')) then begin
            JToken := Context.GetJToken('TicketTokens');
            if (JToken.IsArray()) then
                Tokens := JToken.AsArray();
        end;
        if (Context.HasProperty('TicketToken')) then begin
            Token := CopyStr(Context.GetString('TicketToken'), 1, MaxStrLen(Token));
            Tokens.Add(Token);
        end;

        FunctionId := -1;
        if (Context.HasProperty('FunctionId')) then
            FunctionId := Context.GetInteger('FunctionId');

        if (Tokens.Count() = 0) then begin
            SaleLine.GetCurrentSaleLine(SaleLinePOS);
            if (TicketRequestManager.GetTokenFromReceipt(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then
                Tokens.Add(Token);
        end;

        if (not Context.GetBoolean('EditTicketHolder', ForceEditTicketHolder)) then
            ForceEditTicketHolder := false;

        TicketReservationRequestMaster.Reset();
        TicketReservationRequestMaster.SetCurrentKey("Session Token ID");
        TicketReservationRequestMaster.SetLoadFields("Session Token ID", "Receipt No.", "Line No.");

        TicketReservationRequestCheck.Reset();
        TicketReservationRequestCheck.SetCurrentKey("Session Token ID");

        TicketReservationRequestCheck2.Reset();
        TicketReservationRequestCheck2.SetCurrentKey("Session Token ID");

        TicketReservationRequestOrder.Reset();
        TicketReservationRequestOrder.SetCurrentKey("Session Token ID");

        foreach JToken in Tokens do begin
            Token := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(Token));

            if (FunctionId <> 3) then begin
                HaveSaleTicketSalesLine := false;
                TicketReservationRequestMaster.SetFilter("Session Token ID", '=%1', Token);
                if (TicketReservationRequestMaster.FindFirst()) then begin
                    SaleLinePOS.Reset();
                    SaleLinePOS.SetFilter("Register No.", '=%1', RegisterNo);
                    SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', TicketReservationRequestMaster."Receipt No.");
                    SaleLinePOS.SetFilter("Line No.", '=%1', TicketReservationRequestMaster."Line No.");
                    HaveSaleTicketSalesLine := SaleLinePOS.FindFirst();
                end;

                TicketRetailManagement.AssignSameSchedule(Token, HaveSaleTicketSalesLine and (SaleLinePOS.Indentation > 0));
                TicketRetailManagement.AssignSameNotificationAddress(Token);

                // Are all required admissions configured with time slots?
                TicketReservationRequestCheck.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationRequestCheck.SetFilter("External Adm. Sch. Entry No.", '<=%1', 0);
                TicketReservationRequestCheck.SetFilter("Admission Inclusion", '=%1', TicketReservationRequestCheck."Admission Inclusion"::REQUIRED);
                RequiredAdmissionHasTimeSlots := TicketReservationRequestCheck.IsEmpty();

                // Are there any non-required admissions that user has not selected
                TicketReservationRequestCheck2.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationRequestCheck2.SetFilter("Admission Inclusion", '<>%1', TicketReservationRequestCheck2."Admission Inclusion"::REQUIRED);
                OnlyRequiredAdmissions := TicketReservationRequestCheck2.IsEmpty();

                if (RequiredAdmissionHasTimeSlots and OnlyRequiredAdmissions) then begin
                    ConfiguredTokens.Add(Token); // This token does not need schedule selection 

                    // Create tickets for this token
                    if (0 = TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage)) then begin

                        if (HaveSaleTicketSalesLine) then begin
                            TicketRetailManagement.AdjustPriceOnSalesLine(SaleLinePOS, SaleLinePOS.Quantity);

                            TicketReservationRequestOrder.SetFilter("Session Token ID", '=%1', Token);
                            TicketReservationRequestOrder.SetFilter("Primary Request Line", '=%1', true);
                            if (TicketReservationRequestOrder.FindFirst()) then begin
                                SaleLinePOS."Description 2" := TicketReservationRequestOrder."Scheduled Time Description";
                                SaleLinePOS.Modify();
                            end;

                            POSProxyDisplay.UpdateDisplay(SaleLinePOS);
                        end;
                    end else begin
                        // Abort the whole process if any token fails
                        Response.Add('CancelScheduleSelection', true); // Request to clean up the sale lines
                        Response.Add('EditSchedule', false);
                        Response.Add('Message', ResponseMessage);
                        exit(Response);
                    end;
                end;
            end;

            Clear(TicketHolder);

            if (GetTicketHolder(Token, ForceEditTicketHolder, TicketHolder)) then
                TicketHolders.Add(TicketHolder);

        end;

        HTMLDisplay.UpdateHTMLDisplay();

        Response.Add('AssignedTokens', ConfiguredTokens);
        Response.Add('CancelScheduleSelection', false);
        Response.Add('EditSchedule', (FunctionId = 3) or (ConfiguredTokens.Count() < Tokens.Count())); // 3 Edit Schedule (forced)
        Response.Add('TicketHolders', TicketHolders);

        exit(Response);

    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTMScheduleSelect.js###
'const main=async({workflow:i,context:t,popup:e,toast:l,captions:n})=>{const a=!!(t.EditSchedule&&t.TicketToken)||t.FunctionId===5,r={sameScheduleAssigned:!1,ticketHolders:[],editTicketHolder:!1};debugger;if(a){const c=await handleSingleTokenFlow({workflow:i,context:t,popup:e,toast:l,state:r});if(c?.cancel)return c}else{const c=await handleMultiTokenFlow({workflow:i,context:t,popup:e,toast:l,state:r});if(c?.cancel)return c}if(r.sameScheduleAssigned&&r.ticketHolders.length===0)return{cancel:!1};const d=await getTicketHolderWorkflowConfig({workflow:i,context:t,state:r});if(!(r.editTicketHolder||d.CaptureTicketHolder||r.ticketHolders.length>0))return{cancel:!1};const o=normalizeTicketHolderConfig(d,r.ticketHolders);return await captureTicketHolderInfo({workflow:i,popup:e,wfConfig:o,captions:n}),{cancel:!1}};async function handleSingleTokenFlow({workflow:i,context:t,popup:e,toast:l,state:n}){const a=await i.respond("AssignSameSchedule",t);return n.ticketHolders=a.TicketHolders||[],n.editTicketHolder=n.ticketHolders.length>0||t.EditTicketHolder,a.CancelScheduleSelection?(l.error(a.Message),{cancel:!0}):!a.EditSchedule&&!n.editTicketHolder?{cancel:!1}:t.EditSchedule&&t.TicketToken&&!t.TicketTokens&&await e.entertainment.scheduleSelection({token:t.TicketToken})===null?{cancel:!0}:null}async function handleMultiTokenFlow({workflow:i,context:t,popup:e,toast:l,state:n}){let a=[...t.tokensRequiringScheduleSelection||[]];const r=[...t.tokensRequiringTicketHolder||[]];for(a.length===1&&r.length>0?(t.TicketTokens=a,n.editTicketHolder=!0):r.length>0&&(t.TicketTokens=r,n.editTicketHolder=!0);a.length>0;){const d=a[0];if(await e.entertainment.scheduleSelection({token:d})===null)return{cancel:!0};if(a.length===1)break;t.ConfiguredToken=d,a.shift(),t.setSchedulesForTokens=a;const o=await i.respond("AssignSameScheduleToSet",t);if(o.CancelScheduleSelection)return l.error(o.Message),{cancel:!0};n.sameScheduleAssigned=!0,n.ticketHolders.push(...o.TicketHolders||[]),n.editTicketHolder=n.ticketHolders.length>0;const c=o.AssignedTokens||[];c.length>0&&(a=a.filter(u=>!c.includes(u)))}return null}async function getTicketHolderWorkflowConfig({workflow:i,context:t,state:e}){return e.editTicketHolder?await i.respond("ConfigureWorkflow",t)||{}:{}}function normalizeTicketHolderConfig(i,t){const e=i&&Object.keys(i).length>0?{...i}:{};if(e.ticketHolderName=e.ticketHolderName??"",e.ticketHolderEmail=e.ticketHolderEmail??"",e.ticketHolderPhone=e.ticketHolderPhone??"",e.ticketHolderLanguage=e.ticketHolderLanguage??"",e.availableLanguages=e.availableLanguages??[],t.length>0){const l=t[0]||{};e.ticketHolderName=l.ticketHolderName||e.ticketHolderName,e.ticketHolderEmail=l.ticketHolderEmail||e.ticketHolderEmail,e.ticketHolderPhone=l.ticketHolderPhone||e.ticketHolderPhone,e.ticketHolderLanguage=l.ticketHolderLanguage||e.ticketHolderLanguage,e.availableLanguages=l.availableLanguages||e.availableLanguages}return e}async function captureTicketHolderInfo({workflow:i,popup:t,wfConfig:e,captions:l}){const n=await t.configuration({title:l.ticketHolderTitle,caption:l.ticketHolderCaption,settings:[{id:"ticketHolderName",type:"text",caption:l.ticketHolderNameLabel,value:e.ticketHolderName},{id:"ticketHolderEmail",type:"text",caption:l.ticketHolderEmailLabel,value:e.ticketHolderEmail},{id:"ticketHolderPhone",type:"phoneNumber",caption:l.ticketHolderPhoneLabel,value:e.ticketHolderPhone},{id:"ticketHolderLanguage",type:"radio",caption:l.ticketHolderLanguageLabel,options:e.availableLanguages,value:e.ticketHolderLanguage,vertical:!1}]});n!==null&&await i.respond("SetTicketHolder",n)}'
    );
    end;
}
