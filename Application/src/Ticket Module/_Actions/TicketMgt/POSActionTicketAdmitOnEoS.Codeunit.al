codeunit 6248422 "NPR POSAction TicketAdmitOnEoS" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ActionDescription: Label 'Admit Ticket on End of Sale';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ToastTitle: Label 'Admitting Ticket on End of Sale';
        ToastBody: Label 'Admitting ticket: %1...';
    begin
        WorkflowConfig.AddActionDescription(_ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('ToastTitle', ToastTitle);
        WorkflowConfig.AddLabel('ToastBody', ToastBody);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'HandleTicketAdmitOnEoS':
                FrontEnd.WorkflowResponse(HandleTicketAdmitOnEoS(Context));
        end;
    end;

    local procedure HandleTicketAdmitOnEoS(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        CustomParameters: JsonObject;
        JsonToken: JsonToken;
        PosUnitNo: Code[10];
        AdmitMethod: Text;
        Tokens: JsonArray;
        Token: JsonToken;
        TicketsAdmittedArray, TicketsRejectedArray : JsonArray;
    begin
        CustomParameters := Context.GetJsonObject('customParameters');

        CustomParameters.Get('posUnitNo', JsonToken);
        PosUnitNo := CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(PosUnitNo));

        CustomParameters.Get('admitMethod', JsonToken);
        AdmitMethod := JsonToken.AsValue().AsText();

        CustomParameters.Get('tokens', JsonToken);
        Tokens := JsonToken.AsArray();

        case AdmitMethod of
            'WORKFLOW_LEGACY':
                foreach Token in Tokens do
                    AdmitTicketLegacy(CopyStr(Token.AsValue().AsText(), 1, 100), PosUnitNo, TicketsAdmittedArray);
            'WORKFLOW_SPEED_GATE':
                foreach Token in Tokens do
                    AdmitTicketSpeedGate(CopyStr(Token.AsValue().AsText(), 1, 100), PosUnitNo, TicketsAdmittedArray, TicketsRejectedArray);
            else
                Error('This is a programming error - Invalid admit mode: %1', AdmitMethod);
        end;

        Response.Add('admitMethod', AdmitMethod);
        Response.Add('posUnitNo', PosUnitNo);
        Response.Add('ticketsAdmitted', TicketsAdmittedArray);
        Response.Add('ticketsRejected', TicketsRejectedArray);
    end;


    local procedure AdmitTicketLegacy(Token: Text[100]; PosUnitNo: Code[10]; var TicketsArray: JsonArray)
    var
        TicketReservation: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketReservation.SetCurrentKey("Session Token ID");
        TicketReservation.SetFilter("Session Token ID", '=%1', Token);
        TicketReservation.SetFilter("Primary Request Line", '=%1', true);
        TicketReservation.SetFilter("Request Status", '=%1', TicketReservation."Request Status"::CONFIRMED);
        if (not TicketReservation.FindSet()) then
            exit;

        repeat
            if (TicketRequestManager.IsReservationRequest(Token)) then begin
                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservation."Entry No.");
                if (Ticket.FindSet()) then
                    repeat
                        if (TicketReservation.EndOfSaleAdmitMode = TicketReservation.EndOfSaleAdmitMode::SALE) then
                            if (TicketManagement.AdmitTicketFromEndOfSale(Token, Ticket, PosUnitNo)) then
                                TicketsArray.Add(Ticket."External Ticket No.");

                        if (TicketReservation.EndOfSaleAdmitMode = TicketReservation.EndOfSaleAdmitMode::SCAN) then
                            if (TicketManagement.RegisterTicketBomAdmissionArrival(Ticket, PosUnitNo, '', 1)) then
                                TicketsArray.Add(Ticket."External Ticket No.");

                    until (Ticket.Next() = 0);
            end;
        until (TicketReservation.Next() = 0);
    end;

    local procedure AdmitTicketSpeedGate(Token: Text[100]; PosUnitNo: Code[10]; var TicketsAdmittedList: JsonArray; var TicketsRejectedList: JsonArray)
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketReservation: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        SpeedGate: Codeunit "NPR SG SpeedGate";
        AdmitToken: Guid;
        AdmitToCodes: List of [Code[20]];
        IsCheckedBySubscriber, IsValid : Boolean;
        ResponseCode: Integer;
        ResponseMessage: Text;
        ApiError: Enum "NPR API Error Code";
        ErrorMessage: Label '%1: %2';
    begin
        TicketReservation.SetCurrentKey("Session Token ID");
        TicketReservation.SetFilter("Session Token ID", '=%1', Token);
        TicketReservation.SetFilter("Primary Request Line", '=%1', true);
        TicketReservation.SetFilter("Request Status", '=%1', TicketReservation."Request Status"::CONFIRMED);
        if (not TicketReservation.FindSet()) then
            exit;

        repeat
            if (TicketRequestManager.IsReservationRequest(Token)) and (TicketReservation.EndOfSaleAdmitMode <> TicketReservation.EndOfSaleAdmitMode::NO_ADMIT_ON_EOS) then begin
                SpeedGate.SetEndOfSalesAdmitMode(TicketReservation.EndOfSaleAdmitMode = TicketReservation.EndOfSaleAdmitMode::SALE);

                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservation."Entry No.");
                if (Ticket.FindSet()) then
                    repeat
                        if (SpeedGate.CheckTicket(PosUnitNo, Ticket."External Ticket No.", '', AdmitToCodes, ResponseCode)) then begin

                            AdmitToken := SpeedGate.CreateAdmitToken(Ticket."External Ticket No.", '', PosUnitNo);
                            SpeedGate.Admit(AdmitToken, 1);

                            TicketManagement.OnAfterPosTicketArrival(IsCheckedBySubscriber, IsValid, Ticket."No.", Ticket."External Member Card No.", Token, ResponseMessage);
                            if ((IsCheckedBySubscriber) and (not IsValid)) then
                                TicketsRejectedList.Add(ResponseMessage)
                            else
                                TicketsAdmittedList.Add(Ticket."External Ticket No.");

                        end else begin
                            if (ResponseCode > 0) then
                                TicketsRejectedList.Add(StrSubstNo(ErrorMessage, ResponseCode, ApiError.Names.Get(ApiError.Ordinals.IndexOf(ResponseCode))));

                        end;
                    until (Ticket.Next() = 0);
            end;
        until (TicketReservation.Next() = 0);
    end;

    internal procedure AddPostEndOfSaleWorkflow(Sale: Codeunit "NPR POS Sale"; var PostWorkflows: JsonObject)
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        POSSale: Record "NPR POS Sale";
        ActionParameters: JsonObject;
        Tokens: JsonArray;
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        CustomerParameters: JsonObject;
        POSUnit: Record "NPR POS Unit";
        TicketProfile: Record "NPR TM POS Ticket Profile";
        AdmitMethod: Enum "NPR TM AdmitTicketOnEoSMethod";
    begin
        Sale.GetCurrentSale(POSSale);
        if (not TicketManagement.AdmitTicketsFromWorkflowOnEndSale(POSSale."Register No.")) then
            exit;

        TicketRequest.SetCurrentKey("Receipt No.");
        TicketRequest.SetLoadFields("Session Token ID", "Receipt No.", "Primary Request Line");
        TicketRequest.SetFilter("Receipt No.", '=%1', POSSale."Sales Ticket No.");
        TicketRequest.SetFilter("Primary Request Line", '=%1', true);
        if (not TicketRequest.FindSet()) then
            exit;

        repeat
            Tokens.Add(TicketRequest."Session Token ID");
        until (TicketRequest.Next() = 0);

        POSUnit.SetLoadFields("POS Ticket Profile");
        POSUnit.Get(POSSale."Register No.");
        TicketProfile.Get(POSUnit."POS Ticket Profile");
        AdmitMethod := TicketProfile.EndOfSaleAdmitMethod;

        CustomerParameters.Add('salesTicketNo', POSSale."Sales Ticket No.");
        CustomerParameters.Add('posUnitNo', POSSale."Register No.");
        CustomerParameters.Add('tokens', Tokens);
        CustomerParameters.Add('admitMethod', AdmitMethod.Names.Get(AdmitMethod.Ordinals.IndexOf(AdmitMethod.AsInteger())));
        CustomerParameters.Add('showSpinner', TicketProfile.ShowSpinnerDuringWorkflowAdmit);
        ActionParameters.Add('customParameters', CustomerParameters);

        PostWorkflows.Add(Format(Enum::"NPR POS Workflow"::TM_TICKET_ADMIT_EOS), ActionParameters);
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTicketAdmitOnEoS.Codeunit.js### 
'const main=async({workflow:a,context:n,popup:r,captions:t})=>{let s=null;n.customParameters.showSpinner&&(s=await r.spinner({caption:"Checking and admitting tickets...",abortEnabled:!1}));try{const{ticketsAdmitted:e,ticketsRejected:o}=await a.respond("HandleTicketAdmitOnEoS");if(e.length>0)for(const i of e)toast.success(`${t.ToastBody.substitute(i)}`,{title:t.ToastTitle});if(o.length>0)for(const i of o)toast.error(`${i}`,{title:t.ToastTitle})}catch(e){toast.error(e.message,{title:t.ToastTitle})}finally{s&&s.close()}};'
        )
    end;

}