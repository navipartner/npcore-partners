codeunit 6060154 "NPR Event Ticket Mgt."
{
    var
        TicketContext: Label 'TICKET';
        EventMgt: Codeunit "NPR Event Management";
        ProperTicketStatusErr: Label '%1 must be either %2 or %3.';
        TMTicketDIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
        EditReservationRedirectText: Label 'To %1 this ticket, please use Edit Reservation and Issue action.';
        ChangeQtyActionText: Label 'edit the quantity for';
        IssueTicketActionText: Label 'issue';

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobPlanningLineOnAfterInsert(var Rec: Record "Job Planning Line"; RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        if not RunTrigger then
            exit;

        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
            exit;
        Rec.Validate("NPR Ticket Token", '');
        Rec."NPR Ticket Status" := Rec."NPR Ticket Status"::" ";
        Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure JobPlanningLineOnBeforeDelete(var Rec: Record "Job Planning Line"; RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        if not RunTrigger then
            exit;
        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
            exit;
        if IsValidTicket(Rec, false) and not ConfirmTicketDelete(Rec, true, true) then
            Error('');
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure JobPlanningLineNoOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    var
        Job: Record Job;
        Resource: Record Resource;
        CancelConfirm: Label 'There is a scheduled meeting request for %1. Do you want to automatically cancel that meeting and send an update to %1?';
    begin
        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
            exit;
        if IsValidTicket(Rec, false) then begin
            if Rec."No." <> xRec."No." then
                ConfirmTicketDelete(Rec, true, true);
            if Rec."No." <> '' then
                CreateTicketReservRequest(Rec, false, false);
        end;

    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure JobPlanningLineQuantityOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    var
        Job: Record Job;
        UpdateAllowed: Boolean;
    begin
        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
            exit;
        if Rec.Type = Rec.Type::Item then begin
            if Rec.Quantity = xRec.Quantity then
                exit;
            if CurrFieldNo = Rec.FieldNo(Quantity) then
                UpdateReservReqQty(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'NPR Ticket Token', false, false)]
    local procedure JobPlanningLineTicketTokenOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        if Rec."NPR Ticket Token" = '' then
            Rec.Validate("NPR Ticket Collect Status", Rec."NPR Ticket Collect Status"::" ")
        else
            if Rec."NPR Ticket Token" <> xRec."NPR Ticket Token" then
                Rec.Validate("NPR Ticket Collect Status", Rec."NPR Ticket Collect Status"::"Not Collected");
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'NPR Ticket Collect Status', false, false)]
    local procedure JobPlanningLineTicketCollectStatusOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    var
        TMTicket: Record "NPR TM Ticket";
        TMTicketResRequest: Record "NPR TM Ticket Reservation Req.";
        ReqExists: Boolean;
    begin
        if Rec."NPR Ticket Collect Status" in [Rec."NPR Ticket Collect Status"::" ", Rec."NPR Ticket Collect Status"::"Not Collected"] then begin
            TMTicketResRequest.SetRange("Session Token ID", Rec."NPR Ticket Token");
            ReqExists := TMTicketResRequest.FindFirst;
            if ReqExists then begin
                TMTicketResRequest."DIY Print Order Requested" := false;
                TMTicketResRequest.Modify;
            end;
        end;

    end;

    procedure CreateTicketReservRequest(var JobPlanningLine: Record "Job Planning Line"; ShowError: Boolean; FromAction: Boolean)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        QtyZeroOrLessNotAllowed: Label '%1 can''t be less than or equal to 0.';
        TicketResReqExists: Label 'Ticket reservation request already exists.';
    begin
        if not IsValidTicket(JobPlanningLine, ShowError) then
            exit;
        if JobPlanningLine.Quantity <= 0 then
            if ShowError then
                Error(QtyZeroOrLessNotAllowed)
            else
                exit;
        if TicketRequestManager.TokenRequestExists(JobPlanningLine."NPR Ticket Token") then
            if ShowError then
                Error(TicketResReqExists)
            else
                exit;

        if not (JobPlanningLine."NPR Ticket Status" in [JobPlanningLine."NPR Ticket Status"::" ", JobPlanningLine."NPR Ticket Status"::Revoked]) then
            if ShowError then
                Error(ProperTicketStatusErr, JobPlanningLine.FieldCaption("NPR Ticket Status"), JobPlanningLine."NPR Ticket Status"::" ", JobPlanningLine."NPR Ticket Status"::Revoked)
            else
                exit;
        JobPlanningLine.Validate("NPR Ticket Token", TicketRequestManager.POS_CreateReservationRequest('', 0, JobPlanningLine."No.", JobPlanningLine."Variant Code", JobPlanningLine.Quantity, ''));
        JobPlanningLine."NPR Ticket Status" := JobPlanningLine."NPR Ticket Status"::Registered;
        if FromAction then
            JobPlanningLine.Modify;
    end;

    local procedure DeleteTicketReservRequest(var JobPlanningLine: Record "Job Planning Line"; RemoveRequest: Boolean; RemoveToken: Boolean)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        if JobPlanningLine."NPR Ticket Token" = '' then
            exit;
        TicketRequestManager.DeleteReservationRequest(JobPlanningLine."NPR Ticket Token", RemoveRequest);
        JobPlanningLine."NPR Ticket Status" := JobPlanningLine."NPR Ticket Status"::" ";
        if RemoveToken then
            JobPlanningLine.Validate("NPR Ticket Token", '');
    end;

    local procedure IsValidTicket(JobPlanningLine: Record "Job Planning Line"; ShowError: Boolean): Boolean
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
    begin
        if JobPlanningLine.Type <> JobPlanningLine.Type::Item then
            if ShowError then
                JobPlanningLine.TestField(Type, JobPlanningLine.Type::Item)
            else
                exit(false);
        if Item.Get(JobPlanningLine."No.") then begin
            if Item."NPR Ticket Type" = '' then
                if ShowError then
                    Item.TestField("NPR Ticket Type")
                else
                    exit(false);
            TicketType.Get(Item."NPR Ticket Type");
            if (not TicketType."Is Ticket") then
                if ShowError then
                    TicketType.TestField("Is Ticket")
                else
                    exit;
            exit(true);
        end;
        exit(false);
    end;

    procedure IssueTicketWithLog(var JobPlanningLine: Record "Job Planning Line"; FromAction: Boolean)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseMessage: Text;
        ActivityLog: Record "Activity Log";
        ActivityDescription: Label 'Issueing ticket...';
        TicketNo: Code[20];
    begin
        IsValidTicket(JobPlanningLine, true);
        RedirectToEditReservation(JobPlanningLine, 1, 0);
        if TicketRequestManager.IssueTicketFromReservationToken(JobPlanningLine."NPR Ticket Token", false, ResponseMessage) <> 0 then
            ActivityLog.LogActivity(JobPlanningLine.RecordId, 1, TicketContext, ActivityDescription, CopyStr(ResponseMessage, 1, MaxStrLen(ActivityLog."Activity Message")))
        else
            JobPlanningLine."NPR Ticket Status" := JobPlanningLine."NPR Ticket Status"::Issued;

        if FromAction then
            JobPlanningLine.Modify;
    end;

    procedure EditTicketReservationWithLog(var JobPlanningLine: Record "Job Planning Line")
    var
        ResponseMessage: Text;
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ActivityLog: Record "Activity Log";
        TicketNo: Code[20];
        ActivityDescription: Label 'Editing reservation...';
    begin
        if JobPlanningLine."NPR Ticket Token" = '' then
            exit;
        if AcquireTicketAdmissionSchedule(JobPlanningLine, ResponseMessage) then begin
            JobPlanningLine."NPR Ticket Status" := JobPlanningLine."NPR Ticket Status"::Issued;
            JobPlanningLine.Modify;
        end else
            if ResponseMessage <> '' then
                ActivityLog.LogActivity(JobPlanningLine.RecordId, 1, TicketContext, ActivityDescription, CopyStr(ResponseMessage, 1, MaxStrLen(ActivityLog."Activity Message")));
    end;

    procedure EditTicketHolder(JobPlanningLine: Record "Job Planning Line")
    begin
        if JobPlanningLine."NPR Ticket Token" = '' then
            exit;
        AcquireTicketParticipant(JobPlanningLine."NPR Ticket Token", '');
    end;

    local procedure UpdateReservReqQty(var JobPlanningLine: Record "Job Planning Line")
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        if not IsValidTicket(JobPlanningLine, false) then
            exit;
        if JobPlanningLine."NPR Ticket Token" = '' then begin
            CreateTicketReservRequest(JobPlanningLine, false, false);
        end;
        if JobPlanningLine."NPR Ticket Status" in [JobPlanningLine."NPR Ticket Status"::Issued, JobPlanningLine."NPR Ticket Status"::Confirmed] then
            Error(ProperTicketStatusErr, JobPlanningLine.FieldCaption("NPR Ticket Status"), JobPlanningLine."NPR Ticket Status"::Registered, JobPlanningLine."NPR Ticket Status"::Revoked);
        TicketRequestManager.UpdateReservationQuantity(JobPlanningLine."NPR Ticket Token", JobPlanningLine.Quantity);
    end;

    local procedure AcquireTicketAdmissionSchedule(var JobPlanningLine: Record "Job Planning Line"; var ResponseMessage: Text) LookupOK: Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        DisplayTicketeservationRequest: Page "NPR TM Ticket Make Reserv.";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ResponseCode: Integer;
        NewQty: Integer;
    begin
        TicketReservationRequest.FilterGroup(2);
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', JobPlanningLine."NPR Ticket Token");
        TicketReservationRequest.FilterGroup(0);
        TicketReservationRequest.FindSet();
        repeat
            if TicketReservationRequest."Admission Code" <> '' then
                TicketManagement.GetCurrentScheduleEntry(TicketReservationRequest."Admission Code", true);
        until TicketReservationRequest.Next = 0;
        Commit;

        TicketReservationRequest.FindSet();
        DisplayTicketeservationRequest.SetTableView(TicketReservationRequest);
        DisplayTicketeservationRequest.LookupMode(true);
        DisplayTicketeservationRequest.Editable(true);
        DisplayTicketeservationRequest.LoadTicketRequest(JobPlanningLine."NPR Ticket Token");
        DisplayTicketeservationRequest.SetTicketItem(JobPlanningLine."No.", JobPlanningLine."Variant Code");
        DisplayTicketeservationRequest.AllowQuantityChange(true);
        if DisplayTicketeservationRequest.RunModal = ACTION::LookupOK then begin
            ResponseCode := DisplayTicketeservationRequest.FinalizeReservationRequest(false, ResponseMessage);
            if ResponseCode = 0 then begin
                if DisplayTicketeservationRequest.GetChangedTicketQuantity(NewQty) and (NewQty <> JobPlanningLine.Quantity) then
                    JobPlanningLine.Validate(Quantity, NewQty);
                exit(true);
            end;
        end;
        exit(false);

    end;

    local procedure RedirectToEditReservation(JobPlanningLine: Record "Job Planning Line"; "Action": Integer; CurrFieldNo: Integer) Redirect: Boolean
    var
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        ErrorMsg: Text;
    begin
        Redirect := false;
        TicketBOM.SetRange("Item No.", JobPlanningLine."No.");
        TicketBOM.SetRange("Variant Code", JobPlanningLine."Variant Code");
        if TicketBOM.FindSet then
            repeat
                Admission.Get(TicketBOM."Admission Code");
                if Admission."Default Schedule" in [Admission."Default Schedule"::SCHEDULE_ENTRY, Admission."Default Schedule"::NONE] then begin
                    case Action of
                        0:
                            if CurrFieldNo = JobPlanningLine.FieldNo(Quantity) then
                                ErrorMsg := StrSubstNo(EditReservationRedirectText, ChangeQtyActionText);
                        1:
                            ErrorMsg := StrSubstNo(EditReservationRedirectText, IssueTicketActionText);
                    end;
                    if ErrorMsg <> '' then
                        Error(ErrorMsg);
                    Redirect := true;
                end;
            until (TicketBOM.Next = 0) or Redirect;
    end;

    local procedure AcquireTicketParticipant(Token: Text[100]; ExternalMemberNo: Code[20]): Boolean
    var
        TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
        Member: Record "NPR MM Member";
        SuggestMethod: Option NA,EMAIL,SMS;
        SuggestAddress: Text[100];
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if Token = '' then
            exit(false);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if TicketReservationRequest.FindFirst() then begin
            SuggestAddress := TicketReservationRequest."Notification Address";
            case TicketReservationRequest."Notification Method" of
                TicketReservationRequest."Notification Method"::EMAIL:
                    SuggestMethod := SuggestMethod::EMAIL;
                TicketReservationRequest."Notification Method"::SMS:
                    SuggestMethod := SuggestMethod::SMS;
                else
                    SuggestMethod := SuggestMethod::NA;
            end;
        end;

        if ExternalMemberNo <> '' then
            if Member.Get(MemberManagement.GetMemberFromExtMemberNo(ExternalMemberNo)) then begin
                case Member."Notification Method" of
                    Member."Notification Method"::EMAIL:
                        begin
                            SuggestMethod := SuggestMethod::EMAIL;
                            SuggestAddress := Member."E-Mail Address";
                        end;
                end;
            end;

        exit(TicketNotifyParticipant.AquireTicketParticipant(Token, SuggestMethod, SuggestAddress));
    end;

    procedure RevokeTicketWithLog(var JobPlanningLine: Record "Job Planning Line")
    begin
        //-NPR5.48 [335824]
        /*
        //-NPR5.34 [285043]
        {
        JobPlanningLine.TESTFIELD("Ticket Token");
        JobPlanningLine.TESTFIELD("Ticket No.");
        JobPlanningLine.TESTFIELD("Ticket Status",JobPlanningLine."Ticket Status"::Issued);
        }
        JobPlanningLine.TESTFIELD("Ticket Status",JobPlanningLine."Ticket Status"::Registered);
        //+NPR5.34 [285043]
        //until revoking is fixed, we'll simply delete request
        {
        CreateRevokeRequest(JobPlanningLine);
        IF TicketRequestManager.RevokeReservationTokenRequest(JobPlanningLine."Ticket Token",FALSE,FALSE,ResponseMessage) <> 0 THEN
          ActivityLog.LogActivity(JobPlanningLine.RECORDID,1,TicketContext,ActivityDescription,ResponseMessage)
        ELSE BEGIN
        }
        DeleteTicketReservRequest(JobPlanningLine,TRUE,FALSE);
        JobPlanningLine."Ticket Status" := JobPlanningLine."Ticket Status"::Revoked;
        JobPlanningLine.MODIFY;
        //END;
        */
        //+NPR5.48 [335824]
    end;

    procedure ConfirmTicketWithLog(var JobPlanningLine: Record "Job Planning Line")
    var
        ActivityLog: Record "Activity Log";
        ActivityDescription: Label 'Confirming ticket...';
        ResponseMessage: Text;
    begin
        JobPlanningLine.TestField("NPR Ticket Token");
        JobPlanningLine.TestField("NPR Ticket Status", JobPlanningLine."NPR Ticket Status"::Issued);
        if not ConfirmTicket(JobPlanningLine, ResponseMessage) then
            ActivityLog.LogActivity(JobPlanningLine.RecordId, 1, TicketContext, ActivityDescription, CopyStr(ResponseMessage, 1, MaxStrLen(ActivityLog."Activity Message")))
        else begin
            JobPlanningLine."NPR Ticket Status" := JobPlanningLine."NPR Ticket Status"::Confirmed;
            JobPlanningLine.Modify;
        end;
    end;

    local procedure ConfirmTicket(JobPlanningLine: Record "Job Planning Line"; var ResponseMessage: Text): Boolean
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        exit(TicketRequestManager.ConfirmReservationRequest(JobPlanningLine."NPR Ticket Token", ResponseMessage));
    end;

    procedure CheckItemIsTicketAndRemove(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; RemoveRequest: Boolean; RemoveToken: Boolean): Boolean
    var
        Item: Record Item;
    begin
        if IsValidTicket(xRec, false) then
            exit(ConfirmTicketDelete(Rec, RemoveRequest, RemoveToken));
        exit(false);
    end;

    procedure ConfirmTicketDelete(var Rec: Record "Job Planning Line"; RemoveRequest: Boolean; RemoveToken: Boolean): Boolean
    var
        TicketRemoveConfirm: Label 'There''s already a ticket reservation or an issued ticket. Do you want these to be removed?';
    begin
        if Rec."NPR Ticket Status" = Rec."NPR Ticket Status"::" " then
            exit(true);

        if Rec."NPR Ticket Status" <> Rec."NPR Ticket Status"::" " then
            if Confirm(TicketRemoveConfirm) then begin
                DeleteTicketReservRequest(Rec, RemoveRequest, RemoveToken);
                exit(true);
            end;
        exit(false);
    end;

    procedure CollectTickets(Rec: Record Job)
    var
        RecRef: RecordRef;
        JobPlanningLine: Record "Job Planning Line";
    begin
        if not EventMgt.IsEventJob(Rec) then
            exit;
        JobPlanningLine.SetRange("Job No.", Rec."No.");
        SetTicketFilter(JobPlanningLine);
        if JobPlanningLine.FindSet then
            repeat
                CollectSingleTicket(JobPlanningLine, false);
            until JobPlanningLine.Next = 0;
    end;

    procedure CollectSingleTicket(var Rec: Record "Job Planning Line"; CheckPrerequisite: Boolean)
    var
        Job: Record Job;
    begin
        if CheckPrerequisite then begin
            Job.Get(Rec."Job No.");
            if not EventMgt.IsEventJob(Job) then
                exit;
            CheckCollectTicketPrerequisites(Rec);
        end;
        UpdateTicketCollectStatus(Rec, CollectTicketWithLog(Rec));
    end;

    [TryFunction]
    procedure CollectTicket(var Rec: Record "Job Planning Line")
    var
        TMTicketSetup: Record "NPR TM Ticket Setup";
        ErrorText: Text;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketResReqError: Label '%1 not found for %2 %3.';
    begin
        TMTicketSetup.Get();
        TMTicketSetup.TestField("Print Server Order URL");
        TicketReservationRequest.SetRange("Session Token ID", Rec."NPR Ticket Token");
        if not TicketReservationRequest.FindFirst then
            ErrorText := StrSubstNo(TicketResReqError, TicketReservationRequest.TableCaption, Rec.FieldCaption("NPR Ticket Token"), Rec."NPR Ticket Token");
        if ErrorText = '' then
            TMTicketDIYTicketPrint.GenerateTicketPrint(TicketReservationRequest."Entry No.", true, ErrorText);
        if ErrorText <> '' then
            Error(ErrorText);

    end;

    procedure CollectTicketWithLog(var Rec: Record "Job Planning Line"): Boolean
    var
        ActivityLog: Record "Activity Log";
        ActivityDescription: Label 'Contacting ticket server...';
        TicketsCollected: Label 'Tickets successfuly collected.';
    begin
        if not CollectTicket(Rec) then begin
            ActivityLog.LogActivity(Rec.RecordId, 1, '', ActivityDescription, CopyStr(GetLastErrorText, 1, MaxStrLen(ActivityLog."Activity Message")));
            exit(false);
        end;
        ActivityLog.LogActivity(Rec.RecordId, 0, '', ActivityDescription, TicketsCollected);
        exit(true);
    end;

    local procedure CheckCollectTicketPrerequisites(Rec: Record "Job Planning Line"): Boolean
    var
        NoTicketToCollect: Label 'There is no ticket to collect. It is either already collected or it''s not ready for collecting. Ticket is ready for collecting when %1 is %2.';
    begin
        Rec.SetRecFilter;
        SetTicketFilter(Rec);
        if Rec.IsEmpty then
            Error(NoTicketToCollect, Rec.FieldCaption("NPR Ticket Status"), Format(Rec."NPR Ticket Status"::Issued));
    end;

    local procedure UpdateTicketCollectStatus(var Rec: Record "Job Planning Line"; Success: Boolean)
    begin
        if Success then
            Rec.Validate("NPR Ticket Collect Status", Rec."NPR Ticket Collect Status"::Collected)
        else
            Rec.Validate("NPR Ticket Collect Status", Rec."NPR Ticket Collect Status"::Error);
        Rec.Modify;
    end;

    local procedure SetTicketFilter(var Rec: Record "Job Planning Line")
    begin
        Rec.SetRange(Type, Rec.Type::Item);
        Rec.SetFilter("NPR Ticket Token", '<>%1', '');
        Rec.SetRange("NPR Ticket Status", Rec."NPR Ticket Status"::Issued);
    end;

    procedure GetTicketURL(Rec: Record "Job Planning Line"): Text
    var
        TMTicketSetup: Record "NPR TM Ticket Setup";
    begin
        TMTicketSetup.Get();
        exit(StrSubstNo('%1%2', TMTicketSetup."Print Server Order URL", Rec."NPR Ticket Token"));
    end;

    procedure DownloadTicket(Rec: Record "Job Planning Line") FileName: Text
    var
        WebClient: HttpClient;
        Response: HttpResponseMessage;
        FileMgt: Codeunit "File Management";
        Stream: InStream;
        LocalFileName: Text;
    begin
        //function created to test specific URLs for download
        //to test, create an action on page 6060151 and call this function
        /*
        FileName := Rec.Description + '.' + FileMgt.GetExtension(FileName);
        //WebClient.Get('http://test.ticket.navipartner.dk/orderPdf/', Response);
        WebClient.Get(GetTicketURL(Rec), Response);
        if (not Response.IsSuccessStatusCode()) then
            exit;
        Response.Content.ReadAs(Stream);
        DownloadFromStream(Stream, 'Save file', '', 'PDF File (*.pdf)|*.pdf', FileName);
        Message(FileName + 'downloaded to default Downloads folder or selected folder.');
        */
    end;

    procedure ShowTicketPrintout(Rec: Record "Job Planning Line")
    var
        NoTicketPrintout: Label 'You first need to collect printouts by running Collect Ticket Printouts action.';
        NotIssuedTicketErr: Label 'Line needs to be issued ticket.';
    begin
        Rec.SetRecFilter;
        SetTicketFilter(Rec);
        if Rec.IsEmpty then
            Error(NotIssuedTicketErr);
        Rec.TestField("NPR Ticket Collect Status", Rec."NPR Ticket Collect Status"::Collected);
        HyperLink(GetTicketURL(Rec));
    end;

    procedure ShowIssuedTickets(Rec: Record "Job Planning Line")
    var
        TMTicketResReq: Record "NPR TM Ticket Reservation Req.";
        TMTicket: Record "NPR TM Ticket";
    begin
        TMTicket.SetRange("Ticket Reservation Entry No.", -1);
        TMTicketResReq.SetRange("Session Token ID", Rec."NPR Ticket Token");
        if TMTicketResReq.FindFirst then
            TMTicket.SetRange("Ticket Reservation Entry No.", TMTicketResReq."Entry No.");
        PAGE.Run(0, TMTicket);
    end;
}

