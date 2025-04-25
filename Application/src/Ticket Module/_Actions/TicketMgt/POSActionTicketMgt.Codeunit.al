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
        CouponAliasCode: Label 'Coupon Alias Code';
        AdmissionCodeCaption: Label 'Admission Code';
        AdmissionCodeDescription: Label 'Admission Code';
        InputOptionLabel: Label 'Standard,MPOS NFC Scan', locked = true, MaxLength = 250;
        InputMethodDescription: Label 'Determines how to input the ticket number.';
        FunctionOptionLabel: Label 'Admission Count,Register Arrival,Revoke Reservation,Edit Reservation,Reconfirm Reservation,Edit Ticketholder,Change Confirmed Ticket Quantity,Pickup Ticket Reservation,Convert To Membership,Register Departure,Additional Experience,Ticket to Coupon', Locked = true, MaxLength = 250;
    begin
        WorkflowConfig.AddActionDescription(ActionDescription());
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter('Function', FunctionOptionLabel, 'Register Arrival', 'Function', 'Function', FunctionOptionLabel);
        WorkflowConfig.AddOptionParameter('InputMethod', InputOptionLabel, 'Standard', 'Input Method', InputMethodDescription, InputOptionLabel);
        WorkflowConfig.AddTextParameter('Admission Code', '', AdmissionCodeCaption, AdmissionCodeDescription);
        WorkflowConfig.AddTextParameter('CouponAliasCode', '', CouponAliasCode, CouponAliasCode);
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
                FrontEnd.WorkflowResponse(DoWorkflowFunction(Context, FrontEnd, Setup.GetPOSUnitNo()));
            'FinalizeTicketChange':
                FrontEnd.WorkflowResponse(FinalizeTicketChange(Context));
        end;
    end;

    local procedure InitRequest(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLineRec: Record "NPR POS Sale Line";
        FunctionId: integer;
    begin
        SaleLine.GetCurrentSaleLine(SaleLineRec);

        Context.GetInteger('FunctionId', FunctionId);
        Context.SetContext('ShowTicketDialog', ShowTicketNumberDialogForFunction(Context, SaleLineRec));
        Context.SetContext('ShowTicketQtyDialog', ShowTicketQtyDialogForFunction(Context));
        Context.SetContext('ShowReferenceDialog', ShowReferenceDialogForFunction(Context));
        Context.SetContext('UseFrontEndUx', UseFrontEndUx(FunctionId));
    end;

    internal procedure UseFrontEndUxForScheduleSelection(): boolean
    begin
        exit(UseFrontEndUx(3));
    end;

    internal procedure UseFrontEndUxForScheduleSelection2(): boolean
    begin
        exit(UseFrontEndUx(10));
    end;

    local procedure UseFrontEndUx(FunctionId: integer): boolean
    var
        TicketRetailManager: Codeunit "NPR TM Ticket Retail Mgt.";
    begin

        if (not TicketRetailManager.UseFrontEndScheduleUX()) then
            exit(false);

        // these functions are supported by the front ux
        exit(FunctionId in [
            3, // Edit Reservation
            5,  // Edit TicketHolde
            10  // Additional Experience
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
                10, // Register Additional Experience
                11  // Ticket to Coupon 
        ]));

    end;

    local procedure RefineWorkflow(Context: Codeunit "NPR POS JSON Helper")
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        FunctionId: Integer;
        AdmissionCode: Code[20];
        ExternalTicketNumber: Code[30];
        TicketMaxQty: Integer;
        TicketCurrentQty: Integer;
        ShowQtyDialog: Boolean;
        DefaultTicketNumber: Text;
        ShowWelcomeMessage: Boolean;
        TicketToken: Text[100];
        NewToken: Text[100];
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

        Context.SetContext('UseFrontEndUx', UseFrontEndUx(FunctionId));


        if (FunctionId = 10) then begin
            NewToken := GetNewTicketToken(ExternalTicketNumber);
            if (NewToken <> '') and (NewToken <> TicketToken) then
                Context.SetContext('TicketToken', NewToken);
        end else begin
            if (TicketRequestManager.GetTicketToken(ExternalTicketNumber, TicketToken)) then
                Context.SetContext('TicketToken', TicketToken);
        end;
        AdmissionCode := CopyStr(Context.GetStringParameter('Admission Code'), 1, MaxStrLen(AdmissionCode));
        ShowQtyDialog := GetGroupTicketQuantity(ExternalTicketNumber, AdmissionCode, FunctionId, TicketCurrentQty, TicketMaxQty);
        Context.SetContext('TicketMaxQty', TicketMaxQty);
        if (TicketMaxQty <> TicketCurrentQty) then
            Context.SetContext('TicketMaxQty', StrSubstNo('%1 of %2', TicketCurrentQty, TicketMaxQty));
        Context.SetContext('ShowTicketQtyDialog', ShowQtyDialog);
    end;

    local procedure GetGroupTicketQuantity(ExternalTicketNumber: Code[50]; AdmissionCode: Code[20]; FunctionId: Integer; var TicketCurrentQty: Integer; var TicketMaxQty: Integer) ShowQtyDialogOut: Boolean
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        IsAdmitted: Boolean;
    begin

        // Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalTicketNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (not Ticket.FindFirst()) then
            exit(false);

        Ticket.TestField(Blocked, false);
        TicketType.Get(Ticket."Ticket Type Code");

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (AdmissionCode <> '') then
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        TicketAccessEntry.FindFirst();

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
        IsAdmitted := DetTicketAccessEntry.FindFirst();

        TicketMaxQty := TicketAccessEntry.Quantity;
        DetTicketAccessEntry.SetFilter(Type, '=%1|=%2|=%3', DetTicketAccessEntry.Type::PAYMENT, DetTicketAccessEntry.Type::PREPAID, DetTicketAccessEntry.Type::POSTPAID);
        if (DetTicketAccessEntry.FindFirst()) then
            TicketMaxQty := DetTicketAccessEntry.Quantity;

        TicketCurrentQty := TicketAccessEntry.Quantity;
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        if (DetTicketAccessEntry.FindFirst()) then
            TicketCurrentQty := DetTicketAccessEntry.Quantity;

        ShowQtyDialogOut := ((not IsAdmitted) and (TicketType."Admission Registration" = TicketType."Admission Registration"::GROUP));
        if (FunctionId = 2) then
            ShowQtyDialogOut := false;

        exit(ShowQtyDialogOut);
    end;

    local procedure DoWorkflowFunction(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; PosUnitNo: Code[10]) Response: JsonObject
    var
        POSSession: Codeunit "NPR POS Session";
        FunctionId: Integer;
        DefaultTicketNumber: Text;
        AdmissionCode: Code[20];
        CouponAliasCode: Code[20];
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
        CouponAliasCode := CopyStr(Context.GetStringParameter('CouponAliasCode'), 1, MaxStrLen(CouponAliasCode));
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
                    if (SetGroupTicketConfirmedQuantity(Context, ExternalTicketNumber, AdmissionCode, true)) then
                        POSFunction.RegisterArrival(ExternalTicketNumber, AdmissionCode, PosUnitNo, WithTicketPrint, ResponseText);
                end;
            2:
                POSFunction.RevokeTicketReservation(POSSession, ExternalTicketNumber, false);
            3:
                POSFunction.EditReservation(POSSession, ExternalTicketNumber);
            4:
                POSFunction.ReconfirmReservation(POSSession);
            5:
                POSFunction.EditTicketHolder(POSSession, ExternalTicketNumber);
            6:
                SetGroupTicketConfirmedQuantity(Context, ExternalTicketNumber, '', false);
            7:
                POSFunction.PickupPreConfirmedTicket(TicketReference, true, true, true);
            8:
                POSFunction.ConvertToMembership(POSSession, FrontEnd, ExternalTicketNumber, AdmissionCode);
            9:
                POSFunction.RegisterDeparture(ExternalTicketNumber, AdmissionCode);
            10:
                begin
                    if not UseFrontEndUx(10) then
                        POSFunction.AddAdditionalExperience(POSSession, ExternalTicketNumber);
                end;
            11:
                POSFunction.ExchangeTicketForCoupon(POSSession, ExternalTicketNumber, CouponAliasCode, Response);
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

    local procedure FinalizeTicketChange(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        DefaultTicketNumber: Text[50];
        TicketToken: Text[100];
        FunctionId: Integer;
    begin
        DefaultTicketNumber := CopyStr(Context.GetString('TicketNumber'), 1, MaxStrLen(DefaultTicketNumber));
        Context.GetInteger('FunctionId', FunctionId);
        if UseFrontEndUx(FunctionId) then
            Context.SetContext('TicketToken', GetNewTicketToken(DefaultTicketNumber)); //get new ticket token from change request

        TicketToken := CopyStr(Context.GetString('TicketToken'), 1, MaxStrLen(TicketToken));

        TicketRequestManager.ConfirmChangeRequestDynamicTicket(TicketToken);
        Response.ReadFrom('{}');
    end;

    local procedure GetNewTicketToken(TicketReference: Code[50]) Token: Text[100]
    var
        Ticket: Record "NPR TM Ticket";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketRequestEntryNo: Integer;
    begin
        if (TicketReference <> '') then begin
            TicketRequest.SetCurrentKey("Session Token ID");
            TicketRequest.SetFilter("Session Token ID", '=%1', TicketReference);
            if (not TicketRequest.FindFirst()) then begin
                Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(Ticket."External Ticket No.")));
                if (not Ticket.FindFirst()) then
                    Error(ILLEGAL_VALUE, TicketReference, TICKET_NUMBER);

                Ticket.TestField(Blocked, false);
                TicketRequestManager.GetTicketToken(Ticket."No.", Token);

                Clear(TicketRequest);
                TicketRequest.SetCurrentKey("Session Token ID");
                TicketRequest.SetFilter("Session Token ID", '=%1', Token);
                if TicketRequest.FindFirst() then;
            end;

            Token := TicketRequest."Session Token ID";
            TicketRequestEntryNo := TicketRequest."Entry No.";

            if TicketRequestEntryNo <> 0 then begin
                Clear(TicketRequest);
                TicketRequest.SetFilter("Request Status", '%1|%2|%3', TicketRequest."Request Status"::REGISTERED, TicketRequest."Request Status"::WIP, TicketRequest."Request Status"::OPTIONAL);
                TicketRequest.SetRange("Superseeds Entry No.", TicketRequestEntryNo);
                if TicketRequest.FindLast() then
                    Token := TicketRequest."Session Token ID";
            end;
        end;
    end;

    local procedure ActionDescription(): Text[250]
    begin
        exit('This action handles ticket management functions.');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTicketMgt.Codeunit.js### 
'const main=async({workflow:r,context:e,popup:s,parameters:u,captions:a})=>{const T=["Admission Count","Register Arrival","Revoke Reservation","Edit Reservation","Reconfirm Reservation","Edit Ticketholder","Change Confirmed Ticket Quantity","Pickup Ticket Reservation","Convert To Membership","Register Departure","Additional Experience","Ticket to Coupon"],k=["Standard","MPOS NFC Scan"],n=Number(u.Function),m=Number(u.InputMethod),f=k[m],t={},o=a.TicketTitle.substitute(T[n].toString());t.FunctionId=n,t.DefaultTicketNumber=u.DefaultTicketNumber,await r.respond("ConfigureWorkflow",t);debugger;let c;if(e.ShowTicketDialog){if(f==="Standard"){if(c=await s.input({caption:a.TicketPrompt,title:o}),!c)return}else if(f==="MPOS NFC Scan"){const i=await r.run("MPOS_API",{context:{IsFromWorkflow:!0,FunctionName:"NFC_SCAN",Parameters:{}}});if(!i.IsSuccessful){s.error(i.ErrorMessage,"mPOS NFC Error");return}if(!i.Result.ID)return;c=i.Result.ID}}t.TicketNumber=c,await r.respond("RefineWorkflow",t);let l;if(e.ShowTicketQtyDialog&&(l=await s.numpad({caption:a.TicketQtyPrompt.substitute(e.TicketMaxQty),title:o}),l===null))return;let d;if(!(e.ShowReferenceDialog&&(d=await s.input({caption:a.ReferencePrompt,title:o}),d===null))){if(e.UseFrontEndUx){if((await r.run("TM_SCHEDULE_SELECT",{context:{TicketToken:e.TicketToken,EditTicketHolder:n===3||n===5,EditSchedule:n===3||n===10,FunctionId:n}})).cancel){toast.warning("Schedule not updated",{title:o});return}n===10&&await r.respond("FinalizeTicketChange",t)}else{t.TicketQuantity=l,t.TicketReference=d;const i=await r.respond("DoAction",t);i.coupon&&(toast.success(`Coupon: ${i.coupon.reference_no}`,{title:o}),await r.run("SCAN_COUPON",{parameters:{ReferenceNo:i.coupon.reference_no}}))}e.Verbose?await s.message({caption:e.VerboseMessage,title:o}):e.VerboseMessage&&toast.success(e.VerboseMessage,{title:o})}};'
        )
    end;

    local procedure SetGroupTicketConfirmedQuantity(Context: Codeunit "NPR POS JSON Helper"; TicketReference: Code[50]; AdmissionCode: Code[20]; ValidatePayment: Boolean): Boolean
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TICKET_UNPAID: Label 'Ticket is not valid for admission until it has been paid in full. Admission %1 is missing payment information.';
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

        if (ValidatePayment) then begin
            TicketAccessEntry.SetCurrentKey("Ticket No.");
            TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            TicketAccessEntry.FindSet();
            repeat
                if (not TicketManagement.CheckAdmissionIsPaid(TicketAccessEntry."Entry No.")) then
                    Error(TICKET_UNPAID, AdmissionCode);
            until (TicketAccessEntry.Next() = 0);
        end;

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
                    if EanBoxEvent."Action Code" = Format(Enum::"NPR POS Workflow"::TM_TICKETMGMT_3) then begin
                        Sender.SetNonEditableParameterValues(EanBoxEvent, 'DefaultTicketNumber', true, '');
                        Sender.SetNonEditableParameterValues(EanBoxEvent, 'Function', false, 'Register Arrival');
                    end;
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
