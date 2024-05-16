codeunit 6060123 "NPR POSAction: Ticket Mgt." implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        TICKET_NUMBER: Label 'Ticket Number';

        TicketNumberPrompt: Label 'Enter Ticketnumber';
        TicketTitle: Label '%1 - Ticket Management.';
        TicketQtyPrompt: Label 'Confirm new group ticket quantity (current quantity is %1)';
        ReferencePrompt: Label 'Enter Ticket Reference Number';
        Welcome: Label 'Welcome.';
        Text000: Label 'Update Ticket metadata on Sale Line Insert';


    #region WORKFLOW 3
    // WORKFLOW 3 START

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::TM_TICKETMGMT_3));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        SuppressWelcomeMessage: Label 'Suppress Welcome Message';
        PrintTicketOnArrival: Label 'Print Ticket On Arrival';
        DefaultTicketNumber: Label 'Default Ticket Number';
        AdmissionCodeCaption: Label 'Admission Code';
        AdmissionCodeDescription: Label 'Admission Code';
        InputOptionLabel: Label 'Standard,MPOS NFC Scan', locked = true, MaxLength = 250;
        InputMethodDescription: Label 'Determines how to input the ticket number.';
        FunctionOptionLabel: Label 'Admission Count,Register Arrival,Revoke Reservation,Edit Reservation,Reconfirm Reservation,Edit Ticketholder,Change Confirmed Ticket Quantity,Pickup Ticket Reservation,Convert To Membership,Register Departure,Additional Experience', Locked = true, MaxLength = 250;
    begin
        WorkflowConfig.AddActionDescription(ActionDescription());
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter('Function', FunctionOptionLabel, 'Register Arrival', 'Function', 'Function', FunctionOptionLabel);
        WorkflowConfig.AddOptionParameter('InputMethod', InputOptionLabel, 'Standard', 'Input Method', InputMethodDescription, InputOptionLabel);
        WorkflowConfig.AddTextParameter('Admission Code', '', AdmissionCodeCaption, AdmissionCodeDescription);
        WorkflowConfig.AddTextParameter('DefaultTicketNumber', '', DefaultTicketNumber, DefaultTicketNumber);
        WorkflowConfig.AddBooleanParameter('PrintTicketOnArrival', false, PrintTicketOnArrival, PrintTicketOnArrival);
        WorkflowConfig.AddBooleanParameter('SuppressWelcomeMessage', false, SuppressWelcomeMessage, SuppressWelcomeMessage);
        WorkflowConfig.AddLabel('TicketPrompt', TicketNumberPrompt);
        WorkflowConfig.AddLabel('TicketQtyPrompt', TicketQtyPrompt);
        WorkflowConfig.AddLabel('TicketTitle', TicketTitle);
        WorkflowConfig.AddLabel('ReferencePrompt', ReferencePrompt);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'ConfigureWorkflow':
                InitRequest(Context, SaleLine);
            'RefineWorkflow':
                RefineWorkflow(Context);
            'DoAction':
                DoWorkflowFunction(Context, FrontEnd, Setup.GetPOSUnitNo());
        end;
    end;

    local procedure InitRequest(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLineRec: Record "NPR POS Sale Line";
    begin
        SaleLine.GetCurrentSaleLine(SaleLineRec);

        Context.SetContext('ShowTicketDialog', ShowTicketNumberDialogForFunction(Context, SaleLineRec));
        Context.SetContext('ShowTicketQtyDialog', ShowTicketQtyDialogForFunction(Context));
        Context.SetContext('ShowReferenceDialog', ShowReferenceDialogForFunction(Context));
        Context.SetContext('UseFrontEndUx', ShowScheduleSelectionDialogForFunction(Context));
    end;

    local procedure ShowScheduleSelectionDialogForFunction(Context: Codeunit "NPR POS JSON Helper"): boolean
    var
        FunctionId: integer;
        TicketRetailManager: Codeunit "NPR TM Ticket Retail Mgt.";
    begin

        if (not TicketRetailManager.UseFrontEndScheduleUX()) then
            exit(false);

        Context.GetInteger('FunctionId', FunctionId);
        exit(FunctionId in [
            3 // Edit Reservation
        ])
    end;


    local procedure ShowTicketQtyDialogForFunction(Context: Codeunit "NPR POS JSON Helper"): boolean
    var
        FunctionId: integer;
    begin
        Context.GetInteger('FunctionId', FunctionId);
        exit(FunctionId in [
            6 // Change Confirmed Ticket Quantity
        ])
    end;

    local procedure ShowReferenceDialogForFunction(Context: Codeunit "NPR POS JSON Helper"): boolean
    var
        FunctionId: integer;
    begin
        Context.GetInteger('FunctionId', FunctionId);
        exit(FunctionId in [
            7 // Pick-up Ticket Reservation
        ])
    end;

    local procedure ShowTicketNumberDialogForFunction(Context: Codeunit "NPR POS JSON Helper"; SaleLineRec: Record "NPR POS Sale Line"): boolean
    var
        POSFunction: Codeunit "NPR POS Action - Ticket Mgt B.";
        Token: Text[100];
        DefaultTicketNumber: Text;
        FunctionId: integer;
        IsTicketLine: Boolean;
    begin
        Context.GetString('DefaultTicketNumber', DefaultTicketNumber);
        if (DefaultTicketNumber <> '') then
            exit(false);

        Context.GetInteger('FunctionId', FunctionId);
        if (FunctionId in [3, 5]) then begin // Edit Reservation, // Edit TicketHolder
            IsTicketLine := POSFunction.GetRequestToken(SaleLineRec."Sales Ticket No.", SaleLineRec."Line No.", Token);
            if (IsTicketLine) then
                Context.SetContext('TicketToken', Token);
            exit(not IsTicketLine);
        end;

        exit((
            FunctionId in [
                1, // Register Arrival
                2, // Revoke Ticket Reservation
                4, // Reconfirm Reservation 
                6, // Change Confirmed Ticket Quantity
                8, // Convert To Membership
                9, // Register Departure
                10 // Register Additional Experience
        ]));

    end;

    local procedure RefineWorkflow(Context: Codeunit "NPR POS JSON Helper")
    var
        TicketRetailManager: Codeunit "NPR TM Ticket Retail Mgt.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        FunctionId: Integer;
        AdmissionCode: Code[20];
        ExternalTicketNumber: Code[30];
        TicketMaxQty: Integer;
        ShowQtyDialog: Boolean;
        DefaultTicketNumber: Text;
        ShowWelcomeMessage: Boolean;
        TicketToken: Text[100];
    begin
        Context.GetInteger('FunctionId', FunctionId);
        DefaultTicketNumber := Context.GetStringParameter('DefaultTicketNumber');

        if (DefaultTicketNumber = '') then
            if (not Context.GetString('TicketNumber', DefaultTicketNumber)) then
                exit;

        ExternalTicketNumber := CopyStr(DefaultTicketNumber, 1, MaxStrLen(ExternalTicketNumber));
        ShowWelcomeMessage := not (Context.GetBooleanParameter('SuppressWelcomeMessage'));

        if (FunctionId = 1) then begin
            Context.SetContext('Verbose', ShowWelcomeMessage);
            Context.SetContext('VerboseMessage', Welcome);
        end;

        if (FunctionId = 3) then begin
            if (TicketRequestManager.GetTicketToken(ExternalTicketNumber, TicketToken)) then begin
                Context.SetContext('UseFrontEndUx', TicketRetailManager.UseFrontEndScheduleUX());
                Context.SetContext('TicketToken', TicketToken);
            end;
        end;

        AdmissionCode := CopyStr(Context.GetStringParameter('Admission Code'), 1, MaxStrLen(AdmissionCode));
        TicketMaxQty := GetGroupTicketQuantity(Context, ExternalTicketNumber, AdmissionCode, FunctionId, ShowQtyDialog);
        Context.SetContext('TicketMaxQty', TicketMaxQty);
        Context.SetContext('ShowTicketQtyDialog', ShowQtyDialog);

    end;

    local procedure GetGroupTicketQuantity(Context: Codeunit "NPR POS JSON Helper"; ExternalTicketNumber: Code[50]; AdmissionCode: Code[20]; FunctionId: Integer; var ShowQtyDialogOut: Boolean) TicketMaxQty: Integer
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        IsAdmitted: Boolean;
    begin
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalTicketNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (not Ticket.FindFirst()) then begin
            // Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);
            ShowQtyDialogOut := false;
            exit(0);
        end;

        Ticket.TestField(Blocked, false);
        TicketType.Get(Ticket."Ticket Type Code");

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (AdmissionCode <> '') then
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        TicketAccessEntry.FindFirst();

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        if (AdmissionCode = '') then begin
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        end;

        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
        IsAdmitted := DetTicketAccessEntry.FindFirst();

        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        DetTicketAccessEntry.FindFirst();
        TicketMaxQty := DetTicketAccessEntry.Quantity;

        ShowQtyDialogOut := ((not IsAdmitted) and (TicketType."Admission Registration" = TicketType."Admission Registration"::GROUP));
        if (FunctionId = 2) then
            ShowQtyDialogOut := false;

        Context.SetContext('TicketQty', TicketAccessEntry.Quantity);
        Context.SetContext('TicketMaxQty', TicketMaxQty);
        Context.SetContext('ShowTicketQtyDialog', ShowQtyDialogOut);

        exit(TicketMaxQty);
    end;

    local procedure DoWorkflowFunction(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; PosUnitNo: Code[10])
    var
        POSSession: Codeunit "NPR POS Session";
        FunctionId: Integer;
        DefaultTicketNumber: Text;
        AdmissionCode: Code[20];
        TicketReference: Text[50];
        WithTicketPrint: Boolean;
        ExternalTicketNumber: Code[50];
        ShowWelcomeMessage: Boolean;
        POSFunction: Codeunit "NPR POS Action - Ticket Mgt B.";
        ResponseText: Text;
    begin
        Context.GetInteger('FunctionId', FunctionId);
        DefaultTicketNumber := Context.GetStringParameter('DefaultTicketNumber');
        AdmissionCode := CopyStr(Context.GetStringParameter('Admission Code'), 1, MaxStrLen(AdmissionCode));
        WithTicketPrint := Context.GetBooleanParameter('PrintTicketOnArrival');

        if (ShowReferenceDialogForFunction(Context)) then
            TicketReference := CopyStr(Context.GetString('TicketReference'), 1, MaxStrLen(TicketReference));

        if (DefaultTicketNumber = '') then
            Context.GetString('TicketNumber', DefaultTicketNumber);

        ExternalTicketNumber := CopyStr(DefaultTicketNumber, 1, MaxStrLen(ExternalTicketNumber));

        case FunctionId of
            0:
                POSFunction.ShowQuickStatistics(AdmissionCode);
            1:
                begin
                    if (SetGroupTicketConfirmedQuantity(Context, ExternalTicketNumber, AdmissionCode)) then
                        POSFunction.RegisterArrival(ExternalTicketNumber, AdmissionCode, PosUnitNo, WithTicketPrint, ResponseText);
                end;
            2:
                POSFunction.RevokeTicketReservation(POSSession, ExternalTicketNumber);
            3:
                POSFunction.EditReservation(POSSession, ExternalTicketNumber);
            4:
                POSFunction.ReconfirmReservation(POSSession);
            5:
                POSFunction.EditTicketHolder(POSSession, ExternalTicketNumber);
            6:
                SetGroupTicketConfirmedQuantity(Context, ExternalTicketNumber, '');
            7:
                POSFunction.PickupPreConfirmedTicket(TicketReference, true, true, true);
            8:
                POSFunction.ConvertToMembership(POSSession, FrontEnd, ExternalTicketNumber, AdmissionCode);
            9:
                POSFunction.RegisterDeparture(ExternalTicketNumber, AdmissionCode);
            10:
                POSFunction.AddAdditionalExperience(POSSession, ExternalTicketNumber);
            else
                Error('Function with ID %1 is not implemented.', FunctionId);
        end;

        ShowWelcomeMessage := not (Context.GetBooleanParameter('SuppressWelcomeMessage'));
        if (FunctionId = 1) then begin
            Context.SetContext('Verbose', ShowWelcomeMessage);
            Context.SetContext('VerboseMessage', StrSubstNo('%1 %2', Welcome, ResponseText));
        end;

        POSSession.RequestRefreshData();
    end;

    local procedure ActionDescription(): Text[250]
    begin
        exit('This action handles ticket management functions.');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTicketMgt.Codeunit.js### 
'let main=async({workflow:i,context:e,popup:n,parameters:u,captions:r})=>{var T=["Admission Count","Register Arrival","Revoke Reservation","Edit Reservation","Reconfirm Reservation","Edit Ticketholder","Change Confirmed Ticket Quantity","Pickup Ticket Reservation","Convert To Membership","Register Departure","Additional Experience"],f=["Standard","MPOS NFC Scan"];let c=Number(u.Function),k=Number(u.InputMethod),s=f[k],t={};windowTitle=r.TicketTitle.substitute(T[c].toString()),t.FunctionId=c,t.DefaultTicketNumber=u.DefaultTicketNumber,await i.respond("ConfigureWorkflow",t);debugger;let a;if(e.ShowTicketDialog){if(s==="Standard"){if(a=await n.input({caption:r.TicketPrompt,title:windowTitle}),!a)return}else if(s==="MPOS NFC Scan"){var o=await i.run("MPOS_API",{context:{IsFromWorkflow:!0,FunctionName:"NFC_SCAN",Parameters:{}}});if(!o.IsSuccessful){n.error(o.ErrorMessage,"mPOS NFC Error");return}if(!o.Result.ID)return;a=o.Result.ID}}t.TicketNumber=a,await i.respond("RefineWorkflow",t);let l;if(e.ShowTicketQtyDialog&&(l=await n.numpad({caption:r.TicketQtyPrompt.substitute(e.TicketMaxQty),title:windowTitle}),l===null))return;let d;if(!(e.ShowReferenceDialog&&(d=await n.input({caption:r.ReferencePrompt,title:windowTitle}),d===null)))if(e.UseFrontEndUx){if((await i.run("TM_SCHEDULE_SELECT",{context:{TicketToken:e.TicketToken,EditTicketHolder:c===3}})).cancel){toast.warning("Schedule not updated",{title:windowTitle});return}e.VerboseMessage}else t.TicketQuantity=l,t.TicketReference=d,await i.respond("DoAction",t),e.Verbose&&await n.message({caption:e.VerboseMessage,title:windowTitle})};'
        )
    end;

    local procedure SetGroupTicketConfirmedQuantity(Context: Codeunit "NPR POS JSON Helper"; TicketReference: Code[50]; AdmissionCode: Code[20]): Boolean
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        ResponseMessage: Text;
        NewTicketQty: Integer;
        QtyChanged: Boolean;
    begin
        if (TicketReference = '') then
            Error(ILLEGAL_VALUE, TicketReference, TICKET_NUMBER);

        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', TicketReference);
        if (TicketRequest.FindFirst()) then
            exit(true); // Ticket order - cant change quantity

        if (not TicketManagement.GetTicket("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, TicketReference, Ticket)) then
            Error(ILLEGAL_VALUE, TicketReference, TICKET_NUMBER);

        Ticket.TestField(Blocked, false);
        Context.GetInteger('TicketQuantity', NewTicketQty);
        if (NewTicketQty <= 0) then
            exit(true); // Accept current quantity on ticket. 

        QtyChanged := TicketManagement.AttemptChangeConfirmedTicketQuantity(Ticket."No.", AdmissionCode, NewTicketQty, ResponseMessage);

        Context.SetContext('Verbose', (not QtyChanged));
        if (not QtyChanged) then
            Context.SetContext('VerboseMessage', ResponseMessage);

        exit(QtyChanged);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        TMTicket: Record "NPR TM Ticket";
    begin
        if (not EanBoxEvent.Get(EventCodeExternalTicketNo())) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeExternalTicketNo();
            EanBoxEvent."Module Name" := 'Ticket Management';
            EanBoxEvent.Description := CopyStr(TMTicket.FieldCaption("External Ticket No."), 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        case EanBoxEvent.Code of
            EventCodeExternalTicketNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'DefaultTicketNumber', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'Function', false, 'Register Arrival');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeExternalTicketNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        TMTicket: Record "NPR TM Ticket";
    begin
        if (EanBoxSetupEvent."Event Code" <> EventCodeExternalTicketNo()) then
            exit;

        if (StrLen(EanBoxValue) > MaxStrLen(TMTicket."External Ticket No.")) then
            exit;

        TMTicket.SetRange("External Ticket No.", EanBoxValue);
        if not TMTicket.IsEmpty() then
            InScope := true;
    end;

    local procedure EventCodeExternalTicketNo(): Code[20]
    begin
        exit('TICKET_ARRIVAL');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'UpdateTicketOnSaleLineInsert':
                begin
                    Rec.Description := Text000;
                    Rec."Sequence No." := 20;
                end;
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR POSAction: Ticket Mgt.");
    end;






    #endregion


    #region OBSOLETED
    local procedure ActionVersion(): Text[30]
    begin
        exit('1.99');
    end;

    local procedure ActionCode(VersionCode: Code[10]): Code[20]
    var
        TICKETMGMTLbl: Label 'TM_TICKETMGMT_%1', Locked = true;
    begin
        if (VersionCode <> '') then
            exit(StrSubstNo(TICKETMGMTLbl, VersionCode));

        exit('TM_TICKETMGMT');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(''),
          ActionDescription(),
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('', 'respond ();');
            Sender.RegisterWorkflow(true);
        end;

        if (Sender.DiscoverAction20(
          ActionCode('2'),
          ActionDescription(),
          ActionVersion()))
        then begin
            Sender.RegisterWorkflow20('await workflow.respond ("ObsoleteMessage");');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if (not Action.IsThisAction(ActionCode(''))) then
            exit;

        Handled := true;

        Message('This action has been deprecated. Please use action TM_TICKETMGMT_3 instead.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if (not Action.IsThisAction(ActionCode('2'))) then
            exit;

        Handled := true;

        Message('This action has been deprecated. Please use action TM_TICKETMGMT_3 instead.');
    end;
    #endregion

}
