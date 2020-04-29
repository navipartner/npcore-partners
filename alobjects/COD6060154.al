codeunit 6060154 "Event Ticket Management"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.30/TJ  /20170228 CASE 265580 Fixed an issue with updating ticket qty. for any item (not just ticket)
    // NPR5.34/TJ  /20170725 CASE 285043 Removed issuing a ticket when registering
    //                                   Function CreateTicketReservRequest is not Local anymore
    //                                   Revoking a ticket can only be achieved if ticket status is Registered
    //                                   Several functions are recoded to either show an error or just exit
    // NPR5.36/TJ  /20170901 CASE 289046 New functions for ticket removal
    //                                   Removed subscriber JobPlanningLineOnAfterDelete and created new subscriber JobPlanningLineOnBeforeDelete
    //                                   Removed subscriber JobPlanningLineTypeOnAfterValidate
    // NPR5.43/TJ  /20170811 CASE 262079 New functions for collecting/showing tickets from ticket server
    // NPR5.45/TJ  /20180122 CASE 303044 Fixed an issue regarding deleting ticket line with blank Ticket Status
    // NPR5.45/TJ  /20180802 CASE 318710 Fixed an issue with ticket confirmation and log
    // NPR5.45/TJ  /20180727 CASE 323386 Fixed the issue with ticket reservation editing
    // NPR5.48/TJ  /20181112 CASE 323386 Allowing ticket quantity change regardless of default schedule
    // NPR5.48/TJ  /20181113 CASE 335824 Removed/recoded any usage of field Ticket No. on table Job Planning Line
    //                                   New function ShowIssuedTickets
    //                                   Revoking is now done from the Ticket List/Ticket Request list


    trigger OnRun()
    begin
    end;

    var
        TicketContext: Label 'TICKET';
        EventMgt: Codeunit "Event Management";
        ProperTicketStatusErr: Label '%1 must be either %2 or %3.';
        TMTicketDIYTicketPrint: Codeunit "TM Ticket DIY Ticket Print";
        EditReservationRedirectText: Label 'To %1 this ticket, please use Edit Reservation and Issue action.';
        ChangeQtyActionText: Label 'edit the quantity for';
        IssueTicketActionText: Label 'issue';

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobPlanningLineOnAfterInsert(var Rec: Record "Job Planning Line";RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        if not RunTrigger then
          exit;

        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
          exit;
        //-NPR5.43 [262079]
        //Rec."Ticket Token" := '';
        Rec.Validate("Ticket Token",'');
        //+NPR5.43 [262079]
        Rec."Ticket Status" := Rec."Ticket Status"::" ";
        //-NPR5.48 [335824]
        //Rec."Ticket No." := '';
        //+NPR5.48 [335824]
        Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure JobPlanningLineOnBeforeDelete(var Rec: Record "Job Planning Line";RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        //-NPR5.36 [289046]
        if not RunTrigger then
          exit;
        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
          exit;
        if IsValidTicket(Rec,false) and not ConfirmTicketDelete(Rec,true,true) then
          Error('');
        //+NPR5.36 [289046]
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure JobPlanningLineNoOnAfterValidate(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";CurrFieldNo: Integer)
    var
        Job: Record Job;
        Resource: Record Resource;
        CancelConfirm: Label 'There is a scheduled meeting request for %1. Do you want to automatically cancel that meeting and send an update to %1?';
    begin
        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
          exit;
        //-NPR5.36 [289046]
        /*
        IF Rec.Type = Rec.Type::Item THEN BEGIN
          IF Rec."No." <> xRec."No." THEN
            DeleteTicketReservRequest(Rec,TRUE,TRUE);
        */
        if IsValidTicket(Rec,false) then begin
          if Rec."No." <> xRec."No." then
            ConfirmTicketDelete(Rec,true,true);
        //+NPR5.36 [289046]
          if Rec."No." <> '' then
            //-NPR5.34 [285043]
            //CreateTicketReservRequest(Rec);
            CreateTicketReservRequest(Rec,false,false);
            //+NPR5.34 [285043]
        end;

    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure JobPlanningLineQuantityOnAfterValidate(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";CurrFieldNo: Integer)
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
          //-NPR5.48 [323386]
          /*
          //-NPR5.45 [323386]
          UpdateAllowed := xRec.Quantity = 0;
          IF NOT UpdateAllowed THEN
            UpdateAllowed := NOT RedirectToEditReservation(Rec,0,CurrFieldNo);
          IF UpdateAllowed THEN
          //+NPR5.45 [323386]
          */
          if CurrFieldNo = Rec.FieldNo(Quantity) then
          //+NPR5.48 [323386]
          UpdateReservReqQty(Rec);
        end;

    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Ticket Token', false, false)]
    local procedure JobPlanningLineTicketTokenOnAfterValidate(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";CurrFieldNo: Integer)
    begin
        if Rec."Ticket Token" = '' then
          Rec.Validate("Ticket Collect Status",Rec."Ticket Collect Status"::" ")
        else if Rec."Ticket Token" <> xRec."Ticket Token" then
          Rec.Validate("Ticket Collect Status",Rec."Ticket Collect Status"::"Not Collected");
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Ticket Collect Status', false, false)]
    local procedure JobPlanningLineTicketCollectStatusOnAfterValidate(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";CurrFieldNo: Integer)
    var
        TMTicket: Record "TM Ticket";
        TMTicketResRequest: Record "TM Ticket Reservation Request";
        ReqExists: Boolean;
    begin
        if Rec."Ticket Collect Status" in [Rec."Ticket Collect Status"::" ",Rec."Ticket Collect Status"::"Not Collected"] then begin
          //-NPR5.48 [335824]
          /*
          IF TMTicket.GET(Rec."Ticket No.") THEN
            ReqExists := TMTicketResRequest.GET(TMTicket."Ticket Reservation Entry No.")
          ELSE BEGIN
          */
          //+NPR5.48 [335824]
            TMTicketResRequest.SetRange("Session Token ID",Rec."Ticket Token");
            ReqExists := TMTicketResRequest.FindFirst;
          //-NPR5.48 [335824]
          //END;
          //+NPR5.48 [335824]
          if ReqExists then begin
            TMTicketResRequest."DIY Print Order Requested" := false;
            TMTicketResRequest.Modify;
          end;
        end;

    end;

    procedure CreateTicketReservRequest(var JobPlanningLine: Record "Job Planning Line";ShowError: Boolean;FromAction: Boolean)
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        QtyZeroOrLessNotAllowed: Label '%1 can''t be less than or equal to 0.';
        TicketResReqExists: Label 'Ticket reservation request already exists.';
    begin
        //-NPR5.34 [285043]
        //IF NOT IsValidTicket(JobPlanningLine) THEN
        if not IsValidTicket(JobPlanningLine,ShowError) then
        //+NPR5.34 [285043]
          exit;
        if JobPlanningLine.Quantity <= 0 then
          //-NPR5.34 [285043]
          if ShowError then
            Error(QtyZeroOrLessNotAllowed)
          else
          //+NPR5.34 [285043]
          exit;
        //-NPR5.34 [285043]
        /*
        IF JobPlanningLine."Ticket Token" <> '' THEN
          EXIT;
        */
        if TicketRequestManager.TokenRequestExists(JobPlanningLine."Ticket Token") then
          if ShowError then
            Error(TicketResReqExists)
          else
            exit;
        
        if not (JobPlanningLine."Ticket Status" in [JobPlanningLine."Ticket Status"::" ",JobPlanningLine."Ticket Status"::Revoked]) then
          if ShowError then
            Error(ProperTicketStatusErr,JobPlanningLine.FieldCaption("Ticket Status"),JobPlanningLine."Ticket Status"::" ",JobPlanningLine."Ticket Status"::Revoked)
          else
            exit;
        //+NPR5.34 [285043]
        CreateReservationRequest(JobPlanningLine,JobPlanningLine."Ticket Token" = '');
        //-NPR5.34 [285043]
        //IssueTicketWithLog(JobPlanningLine,FALSE);
        if FromAction then
          JobPlanningLine.Modify;
        //+NPR5.34 [285043]

    end;

    local procedure CreateReservationRequest(var JobPlanningLine: Record "Job Planning Line";RequestNewToken: Boolean)
    var
        TicketReservRequest: Record "TM Ticket Reservation Request";
        Admission: Record "TM Admission";
        TicketAdmBOM: Record "TM Ticket Admission BOM";
        TicketManagement: Codeunit "TM Ticket Management";
        TicketReqManager: Codeunit "TM Ticket Request Manager";
        AdmSchEntry: Record "TM Admission Schedule Entry";
    begin
        if RequestNewToken then
          //-NPR5.43 [262079]
          //JobPlanningLine."Ticket Token" := TicketReqManager.GetNewToken();
          JobPlanningLine.Validate("Ticket Token",TicketReqManager.GetNewToken());
          //+NPR5.43 [262079]
        JobPlanningLine."Ticket Status" := JobPlanningLine."Ticket Status"::Registered;

        TicketAdmBOM.SetRange("Item No.",JobPlanningLine."No.");
        TicketAdmBOM.SetRange("Variant Code",JobPlanningLine."Variant Code");
        TicketAdmBOM.FindSet();
        repeat
          Admission.Get(TicketAdmBOM."Admission Code");

          Clear(TicketReservRequest);
          TicketReservRequest."Entry No." := 0;
          TicketReservRequest."Session Token ID" := JobPlanningLine."Ticket Token";
          TicketReservRequest."Ext. Line Reference No." := JobPlanningLine."Line No.";
          TicketReservRequest."Admission Code" := TicketAdmBOM."Admission Code";

          TicketReservRequest."External Item Code" := TicketReqManager.GetExternalNo(JobPlanningLine."No.",JobPlanningLine."Variant Code");
          TicketReservRequest.Quantity := JobPlanningLine.Quantity;
          TicketReservRequest."External Member No." := '';
          TicketReservRequest."Admission Description" := Admission.Description;

          case Admission."Default Schedule" of
            Admission."Default Schedule"::TODAY,
            Admission."Default Schedule"::NEXT_AVAILABLE:
              if AdmSchEntry.Get(TicketManagement.GetCurrentScheduleEntry(Admission."Admission Code", true)) then begin
                TicketReservRequest."External Adm. Sch. Entry No." := AdmSchEntry."External Schedule Entry No.";
                TicketReservRequest."Scheduled Time Description" := StrSubstNo('%1 - %2',AdmSchEntry."Admission Start Date",AdmSchEntry."Admission Start Time");
              end;
          end;

          TicketReservRequest."Created Date Time" := CurrentDateTime;
          TicketReservRequest."Request Status" := TicketReservRequest."Request Status"::WIP;
          TicketReservRequest."Request Status Date Time" := CurrentDateTime;
          TicketReservRequest."Expires Date Time" := CurrentDateTime + 1500 * 1000;
          TicketReservRequest.Insert;
        until TicketAdmBOM.Next = 0;
    end;

    local procedure DeleteTicketReservRequest(var JobPlanningLine: Record "Job Planning Line";RemoveRequest: Boolean;RemoveToken: Boolean)
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
    begin
        if JobPlanningLine."Ticket Token" = '' then
          exit;
        TicketRequestManager.DeleteReservationRequest(JobPlanningLine."Ticket Token",RemoveRequest);
        JobPlanningLine."Ticket Status" := JobPlanningLine."Ticket Status"::" ";
        //-NPR5.48 [335824]
        //JobPlanningLine."Ticket No." := '';
        //+NPR5.48 [335824]
        if RemoveToken then
          //-NPR5.43 [262079]
          //JobPlanningLine."Ticket Token" := '';
          JobPlanningLine.Validate("Ticket Token",'');
          //+NPR5.43 [262079]
    end;

    local procedure IsValidTicket(JobPlanningLine: Record "Job Planning Line";ShowError: Boolean): Boolean
    var
        Item: Record Item;
        TicketType: Record "TM Ticket Type";
    begin
        if JobPlanningLine.Type <> JobPlanningLine.Type::Item then
        //-NPR5.34 [285043]
          if ShowError then
            JobPlanningLine.TestField(Type,JobPlanningLine.Type::Item)
          else
        //+NPR5.34 [285043]
          exit(false);
        //-NPR5.36 [289046]
        //Item.GET(JobPlanningLine."No.");
        if Item.Get(JobPlanningLine."No.") then begin
        //+NPR5.36 [289046]
        if Item."Ticket Type" = '' then
        //-NPR5.34 [285043]
          if ShowError then
            Item.TestField("Ticket Type")
          else
        //+NPR5.34 [285043]
          exit(false);
        TicketType.Get(Item."Ticket Type");
        if (not TicketType."Is Ticket") then
        //-NPR5.34 [285043]
          if ShowError then
            TicketType.TestField("Is Ticket")
          else
        //+NPR5.34 [285043]
          exit;
        exit(true);
        //-NPR5.36 [289046]
        end;
        exit(false);
        //+NPR5.36 [289046]
    end;

    procedure IssueTicketWithLog(var JobPlanningLine: Record "Job Planning Line";FromAction: Boolean)
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseMessage: Text;
        ActivityLog: Record "Activity Log";
        ActivityDescription: Label 'Issueing ticket...';
        TicketNo: Code[20];
    begin
        //-NPR5.34 [285043]
        /*
        IF JobPlanningLine."Ticket Status" = JobPlanningLine."Ticket Status"::Revoked THEN BEGIN
        //  DeleteTicketReservRequest(JobPlanningLine,TRUE,FALSE);
          CreateReservationRequest(JobPlanningLine,JobPlanningLine."Ticket Token" = '');
        END;
        */
        IsValidTicket(JobPlanningLine,true);
        //+NPR5.34 [285043]
        //-NPR5.45 [323386]
        RedirectToEditReservation(JobPlanningLine,1,0);
        //+NPR5.45 [323386]
        if TicketRequestManager.IssueTicketFromReservationToken(JobPlanningLine."Ticket Token",false,ResponseMessage) <> 0 then
          ActivityLog.LogActivity(JobPlanningLine.RecordId,1,TicketContext,ActivityDescription,CopyStr(ResponseMessage,1,MaxStrLen(ActivityLog."Activity Message")))
        else
          JobPlanningLine."Ticket Status" := JobPlanningLine."Ticket Status"::Issued;
        //-NPR5.48 [335824]
        /*
        IF TicketRequestManager.GetTokenTicket(JobPlanningLine."Ticket Token",TicketNo) THEN
          JobPlanningLine."Ticket No." := TicketNo;
        */
        //+NPR5.48 [335824]
        if FromAction then
          JobPlanningLine.Modify;

    end;

    procedure EditTicketReservationWithLog(var JobPlanningLine: Record "Job Planning Line")
    var
        ResponseMessage: Text;
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ActivityLog: Record "Activity Log";
        TicketNo: Code[20];
        ActivityDescription: Label 'Editing reservation...';
    begin
        //-NPR5.45 [323386]
        if JobPlanningLine."Ticket Token" = '' then
          exit;
        if AcquireTicketAdmissionSchedule(JobPlanningLine,ResponseMessage) then begin
          JobPlanningLine."Ticket Status" := JobPlanningLine."Ticket Status"::Issued;
          //-NPR5.48 [335824]
          /*
          IF TicketRequestManager.GetTokenTicket(JobPlanningLine."Ticket Token",TicketNo) THEN
            JobPlanningLine."Ticket No." := TicketNo;
          */
          //+NPR5.48 [335824]
          JobPlanningLine.Modify;
        end else if ResponseMessage <> '' then
          ActivityLog.LogActivity(JobPlanningLine.RecordId,1,TicketContext,ActivityDescription,CopyStr(ResponseMessage,1,MaxStrLen(ActivityLog."Activity Message")));
        //+NPR5.45 [323386]

    end;

    procedure EditTicketHolder(JobPlanningLine: Record "Job Planning Line")
    begin
        if JobPlanningLine."Ticket Token" = '' then
          exit;
        AcquireTicketParticipant(JobPlanningLine."Ticket Token",'');
    end;

    local procedure UpdateReservReqQty(var JobPlanningLine: Record "Job Planning Line")
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
    begin
        //-NPR5.30 [265580]
        //-NPR5.34 [285043]
        //IF NOT IsValidTicket(JobPlanningLine) THEN
        if not IsValidTicket(JobPlanningLine,false) then
        //+NPR5.34 [285043]
          exit;
        //+NPR5.30 [265580]
        if JobPlanningLine."Ticket Token" = '' then begin
          //-NPR5.34 [285043]
          //CreateTicketReservRequest(JobPlanningLine);
          CreateTicketReservRequest(JobPlanningLine,false,false);
          //+NPR5.34 [285043]
        //  IssueTicketWithLog(JobPlanningLine,FALSE);
        end;
        //-NPR5.34 [285043]
        if JobPlanningLine."Ticket Status" in [JobPlanningLine."Ticket Status"::Issued,JobPlanningLine."Ticket Status"::Confirmed] then
          Error(ProperTicketStatusErr,JobPlanningLine.FieldCaption("Ticket Status"),JobPlanningLine."Ticket Status"::Registered,JobPlanningLine."Ticket Status"::Revoked);
        //+NPR5.34 [285043]
        TicketRequestManager.UpdateReservationQuantity(JobPlanningLine."Ticket Token",JobPlanningLine.Quantity);
    end;

    local procedure AcquireTicketAdmissionSchedule(var JobPlanningLine: Record "Job Planning Line";var ResponseMessage: Text) LookupOK: Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        DisplayTicketeservationRequest: Page "TM Ticket Make Reservation";
        TicketManagement: Codeunit "TM Ticket Management";
        ResponseCode: Integer;
        NewQty: Integer;
    begin
        TicketReservationRequest.FilterGroup(2);
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        //-NPR5.45 [323386]
        //TicketReservationRequest.SETFILTER("Session Token ID",'=%1',Token);
        TicketReservationRequest.SetFilter("Session Token ID",'=%1',JobPlanningLine."Ticket Token");
        //+NPR5.45 [323386]
        TicketReservationRequest.FilterGroup(0);
        TicketReservationRequest.FindSet();
        repeat
          if TicketReservationRequest."Admission Code" <> '' then
            TicketManagement.GetCurrentScheduleEntry(TicketReservationRequest."Admission Code",true);
        until TicketReservationRequest.Next = 0;
        Commit;
        
        TicketReservationRequest.FindSet();
        DisplayTicketeservationRequest.SetTableView(TicketReservationRequest);
        DisplayTicketeservationRequest.LookupMode(true);
        DisplayTicketeservationRequest.Editable(true);
        //-NPR5.45 [323386]
        /*
        IF DisplayTicketeservationRequest.RUNMODAL = ACTION::LookupOK THEN
          EXIT(TRUE);
        */
        DisplayTicketeservationRequest.LoadTicketRequest(JobPlanningLine."Ticket Token");
        DisplayTicketeservationRequest.SetTicketItem(JobPlanningLine."No.",JobPlanningLine."Variant Code");
        DisplayTicketeservationRequest.AllowQuantityChange(true);
        if DisplayTicketeservationRequest.RunModal = ACTION::LookupOK then begin
          ResponseCode := DisplayTicketeservationRequest.FinalizeReservationRequest(false,ResponseMessage);
          if ResponseCode = 0 then begin
            if DisplayTicketeservationRequest.GetChangedTicketQuantity(NewQty) and (NewQty <> JobPlanningLine.Quantity) then
              JobPlanningLine.Validate(Quantity,NewQty);
            exit(true);
          end;
        end;
        //+NPR5.45 [323386]
        exit(false);

    end;

    local procedure RedirectToEditReservation(JobPlanningLine: Record "Job Planning Line";"Action": Integer;CurrFieldNo: Integer) Redirect: Boolean
    var
        TicketBOM: Record "TM Ticket Admission BOM";
        Admission: Record "TM Admission";
        ErrorMsg: Text;
    begin
        //-NPR5.45 [323386]
        Redirect := false;
        TicketBOM.SetRange("Item No.",JobPlanningLine."No.");
        TicketBOM.SetRange("Variant Code",JobPlanningLine."Variant Code");
        if TicketBOM.FindSet then
          repeat
            Admission.Get(TicketBOM."Admission Code");
            if Admission."Default Schedule" in [Admission."Default Schedule"::SCHEDULE_ENTRY,Admission."Default Schedule"::NONE] then begin
              case Action of
                0:
                  if CurrFieldNo = JobPlanningLine.FieldNo(Quantity) then
                    ErrorMsg := StrSubstNo(EditReservationRedirectText,ChangeQtyActionText);
                1: ErrorMsg := StrSubstNo(EditReservationRedirectText,IssueTicketActionText);
              end;
              if ErrorMsg <> '' then
                Error(ErrorMsg);
              Redirect := true;
            end;
          until (TicketBOM.Next = 0) or Redirect;
        //+NPR5.45 [323386]
    end;

    local procedure AcquireTicketParticipant(Token: Text[100];ExternalMemberNo: Code[20]): Boolean
    var
        TicketNotifyParticipant: Codeunit "TM Ticket Notify Participant";
        MemberManagement: Codeunit "MM Membership Management";
        Member: Record "MM Member";
        SuggestMethod: Option NA,EMAIL,SMS;
        SuggestAddress: Text[100];
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin
        if Token = '' then
          exit(false);

        TicketReservationRequest.SetFilter("Session Token ID",'=%1',Token);
        if TicketReservationRequest.FindFirst() then begin
          SuggestAddress := TicketReservationRequest."Notification Address";
          case TicketReservationRequest."Notification Method" of
            TicketReservationRequest."Notification Method"::EMAIL : SuggestMethod := SuggestMethod::EMAIL;
            TicketReservationRequest."Notification Method"::SMS   : SuggestMethod := SuggestMethod::SMS;
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

        exit(TicketNotifyParticipant.AquireTicketParticipant(Token,SuggestMethod,SuggestAddress));
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

    local procedure CreateRevokeRequest(var JobPlanningLine: Record "Job Planning Line")
    begin
        //-NPR5.48 [335824]
        /*
        Ticket.GET(JobPlanningLine."Ticket No.");
        
        //-NPR5.43 [262079]
        //JobPlanningLine."Ticket Token" := TicketRequestManager.GetNewToken();
        JobPlanningLine.VALIDATE("Ticket Token",TicketRequestManager.GetNewToken());
        //+NPR5.43 [262079]
        
        TicketAccessEntry.SETRANGE("Ticket No.",Ticket."No.");
        TicketAccessEntry.FINDSET;
        REPEAT
          Admission.GET(TicketAccessEntry."Admission Code");
        
          DetTicketAccessEntry.SETRANGE("Ticket Access Entry No.",TicketAccessEntry."Entry No.");
          DetTicketAccessEntry.SETRANGE(Type,DetTicketAccessEntry.Type::ADMITTED);
          IF DetTicketAccessEntry.FINDFIRST THEN
            ERROR(TICKET_USED,JobPlanningLine."Ticket No.",Admission.Description,DetTicketAccessEntry."Created Datetime");
        
          DetTicketAccessEntry.SETRANGE(Type,DetTicketAccessEntry.Type::CANCELED);
          IF DetTicketAccessEntry.FINDFIRST THEN
            ERROR(TICKET_CANCELLED,JobPlanningLine."Ticket No.",DetTicketAccessEntry."Created Datetime");
        
          CLEAR(ReservationRequest);
          ReservationRequest."Entry No." := 0;
          ReservationRequest."Session Token ID" := JobPlanningLine."Ticket Token";
          ReservationRequest."Ext. Line Reference No." := JobPlanningLine."Line No.";
          ReservationRequest."Admission Code" := TicketAccessEntry."Admission Code";
        
          ReservationRequest."Revoke Ticket Request" := TRUE;
          ReservationRequest."Revoke Access Entry No." := TicketAccessEntry."Entry No.";
        
          ReservationRequest."External Member No." := Ticket."External Member Card No.";
          ReservationRequest."Admission Description" := Admission.Description;
        
          ReservationRequest."Created Date Time" := CURRENTDATETIME;
          ReservationRequest."Request Status" := ReservationRequest."Request Status"::WIP;
          ReservationRequest."Request Status Date Time" := CURRENTDATETIME;
          ReservationRequest."Expires Date Time" := CURRENTDATETIME + 1500 * 1000;
          ReservationRequest.INSERT;
        UNTIL TicketAccessEntry.NEXT = 0;
        */
        //+NPR5.48 [335824]

    end;

    procedure ConfirmTicketWithLog(var JobPlanningLine: Record "Job Planning Line")
    var
        ActivityLog: Record "Activity Log";
        ActivityDescription: Label 'Confirming ticket...';
        ResponseMessage: Text;
    begin
        JobPlanningLine.TestField("Ticket Token");
        //-NPR5.48 [335824]
        //JobPlanningLine.TESTFIELD("Ticket No.");
        //+NPR5.48 [335824]
        JobPlanningLine.TestField("Ticket Status",JobPlanningLine."Ticket Status"::Issued);
        //-NPR5.45 [318710]
        /*
        IF NOT ConfirmTicket(JobPlanningLine) THEN
          ActivityLog.LogActivity(JobPlanningLine.RECORDID,1,TicketContext,ActivityDescription,COPYSTR(GETLASTERRORTEXT,1,MAXSTRLEN(ActivityLog."Activity Message")))
        */
        if not ConfirmTicket(JobPlanningLine,ResponseMessage) then
          ActivityLog.LogActivity(JobPlanningLine.RecordId,1,TicketContext,ActivityDescription,CopyStr(ResponseMessage,1,MaxStrLen(ActivityLog."Activity Message")))
        //+NPR5.45 [318710]
        else begin
          JobPlanningLine."Ticket Status" := JobPlanningLine."Ticket Status"::Confirmed;
          JobPlanningLine.Modify;
        end;

    end;

    local procedure ConfirmTicket(JobPlanningLine: Record "Job Planning Line";var ResponseMessage: Text): Boolean
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
    begin
        //-NPR5.45 [318710]
        //TicketRequestManager.ConfirmReservationRequestWithValidate(JobPlanningLine."Ticket Token");
        exit(TicketRequestManager.ConfirmReservationRequest(JobPlanningLine."Ticket Token",ResponseMessage));
        //+NPR5.45 [318710]
    end;

    procedure CheckItemIsTicketAndRemove(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";RemoveRequest: Boolean;RemoveToken: Boolean): Boolean
    var
        Item: Record Item;
    begin
        if IsValidTicket(xRec,false) then
          exit(ConfirmTicketDelete(Rec,RemoveRequest,RemoveToken));
        exit(false);
    end;

    procedure ConfirmTicketDelete(var Rec: Record "Job Planning Line";RemoveRequest: Boolean;RemoveToken: Boolean): Boolean
    var
        TicketRemoveConfirm: Label 'There''s already a ticket reservation or an issued ticket. Do you want these to be removed?';
    begin
        //-NPR5.45 [303044]
        if Rec."Ticket Status" = Rec."Ticket Status"::" " then
          exit(true);
        //+NPR5.45 [303044]

        if Rec."Ticket Status" <> Rec."Ticket Status"::" " then
          if Confirm(TicketRemoveConfirm) then begin
            DeleteTicketReservRequest(Rec,RemoveRequest,RemoveToken);
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
        JobPlanningLine.SetRange("Job No.",Rec."No.");
        SetTicketFilter(JobPlanningLine);
        if JobPlanningLine.FindSet then
          repeat
            CollectSingleTicket(JobPlanningLine,false);
          until JobPlanningLine.Next = 0;
    end;

    procedure CollectSingleTicket(var Rec: Record "Job Planning Line";CheckPrerequisite: Boolean)
    var
        Job: Record Job;
    begin
        if CheckPrerequisite then begin
          Job.Get(Rec."Job No.");
          if not EventMgt.IsEventJob(Job) then
            exit;
          CheckCollectTicketPrerequisites(Rec);
        end;
        UpdateTicketCollectStatus(Rec,CollectTicketWithLog(Rec));
    end;

    [TryFunction]
    procedure CollectTicket(var Rec: Record "Job Planning Line")
    var
        TMTicketSetup: Record "TM Ticket Setup";
        ErrorText: Text;
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketResReqError: Label '%1 not found for %2 %3.';
    begin
        TMTicketSetup.Get();
        TMTicketSetup.TestField("Print Server Order URL");
        //-NPR5.48 [335824]
        /*
        TMTicket.GET(Rec."Ticket No.");
        TMTicketDIYTicketPrint.GenerateTicketPrint(TMTicket."Ticket Reservation Entry No.",TRUE,ErrorText);
        */
        TicketReservationRequest.SetRange("Session Token ID",Rec."Ticket Token");
        if not TicketReservationRequest.FindFirst then
          ErrorText := StrSubstNo(TicketResReqError,TicketReservationRequest.TableCaption,Rec.FieldCaption("Ticket Token"),Rec."Ticket Token");
        if ErrorText = '' then
          TMTicketDIYTicketPrint.GenerateTicketPrint(TicketReservationRequest."Entry No.",true,ErrorText);
        //+NPR5.48 [335824]
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
          ActivityLog.LogActivity(Rec.RecordId,1,'',ActivityDescription,CopyStr(GetLastErrorText,1,MaxStrLen(ActivityLog."Activity Message")));
          exit(false);
        end;
        ActivityLog.LogActivity(Rec.RecordId,0,'',ActivityDescription,TicketsCollected);
        exit(true);
    end;

    local procedure CheckCollectTicketPrerequisites(Rec: Record "Job Planning Line"): Boolean
    var
        NoTicketToCollect: Label 'There is no ticket to collect. It is either already collected or it''s not ready for collecting. Ticket is ready for collecting when %1 is %2.';
    begin
        Rec.SetRecFilter;
        SetTicketFilter(Rec);
        if Rec.IsEmpty then
          Error(NoTicketToCollect,Rec.FieldCaption("Ticket Status"),Format(Rec."Ticket Status"::Issued));
    end;

    local procedure UpdateTicketCollectStatus(var Rec: Record "Job Planning Line";Success: Boolean)
    begin
        if Success then
          Rec.Validate("Ticket Collect Status",Rec."Ticket Collect Status"::Collected)
        else
          Rec.Validate("Ticket Collect Status",Rec."Ticket Collect Status"::Error);
        Rec.Modify;
    end;

    local procedure SetTicketFilter(var Rec: Record "Job Planning Line")
    begin
        Rec.SetRange(Type,Rec.Type::Item);
        //-NPR5.48 [335824]
        //Rec.SETFILTER("Ticket No.",'<>%1','');
        Rec.SetFilter("Ticket Token",'<>%1','');
        //+NPR5.48 [335824]
        Rec.SetRange("Ticket Status",Rec."Ticket Status"::Issued);
    end;

    procedure GetTicketURL(Rec: Record "Job Planning Line"): Text
    var
        TMTicketSetup: Record "TM Ticket Setup";
    begin
        TMTicketSetup.Get();
        exit(StrSubstNo('%1%2',TMTicketSetup."Print Server Order URL",Rec."Ticket Token"));
    end;

    procedure DownloadTicket(Rec: Record "Job Planning Line") FileName: Text
    var
        WebClient: DotNet npNetWebClient;
        FileMgt: Codeunit "File Management";
        LocalFileName: Text;
    begin
        //function created to test specific URLs for download
        //to test, create an action on page 6060151 and call this function
        /*
        FileName := FileMgt.ServerTempFileName('pdf');
        FileName := FileMgt.GetDirectoryName(FileName) + '\' + Rec.Description + '.' + FileMgt.GetExtension(FileName);
        WebClient := WebClient.WebClient;
        //WebClient.DownloadFile(GetTicketURL(Rec),FileName);
        WebClient.DownloadFile('http://test.ticket.navipartner.dk/orderPdf/',FileName);
        LocalFileName := FileMgt.ClientTempFileName('pdf');
        FileMgt.DownloadToFile(FileName,LocalFileName);
        MESSAGE('Downloaded to: ' + LocalFileName);
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
        Rec.TestField("Ticket Collect Status",Rec."Ticket Collect Status"::Collected);
        HyperLink(GetTicketURL(Rec));
    end;

    procedure ShowIssuedTickets(Rec: Record "Job Planning Line")
    var
        TMTicketResReq: Record "TM Ticket Reservation Request";
        TMTicket: Record "TM Ticket";
    begin
        //-NPR5.48 [335824]
        TMTicket.SetRange("Ticket Reservation Entry No.",-1);
        TMTicketResReq.SetRange("Session Token ID",Rec."Ticket Token");
        if TMTicketResReq.FindFirst then
          TMTicket.SetRange("Ticket Reservation Entry No.",TMTicketResReq."Entry No.");
        PAGE.Run(0,TMTicket);
        //+NPR5.48 [335824]
    end;
}

