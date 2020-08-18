codeunit 6060131 "MM Member Retail Integration"
{
    // MM1.01/TSA/20151222 CASE 230149 NaviPartner Member Management
    // MM1.02/TSA/20151228 CASE 229980 Print function
    // TM1.03/TSA/20160113 CASE 231260 Changed signature on the CreateAccessEntry function
    // MM1.04/TSA/20160115 CASE 231978 General Enhancements
    // MM1.05/TSA/20160121 CASE 232485 Wrapper function accces the member no from card no
    // MM1.05/TSA/20160122 CASE 232485 New functions for POS to create members
    // MM1.07/TSA/20160202 CASE 233246 Handling memberships with cardinality > 1
    // MM1.09/TSA/20160226 CASE 235685 REwork of MM_SCAN_CARD in Touch Sales POS
    // MM1.09/TSA/20160229 CASE 235805 Added support for Sales Context
    // MM1.09/TSA/20160229 CASE 235812 Member Receipt Printing
    // MM1.10/TSA/20160321 CASE 237393 Cancel Membership
    // MM1.10/TSA/20160321 CASE 234209 Show member details on membercard scan
    // MM1.11/TSA/20160422 CASE 233824 Changeing memberships
    // MM1.14/TSA/20150504 CASE 240749 Adapting to NAV 2016 changes for report printing
    // MM1.15/TSA/20160615 CASE 244443 General Bug fix Capture Audit Roll Description on posting
    // MM1.15/TSA/20160817 CASE 244443 General Bug fix Changing signature on AddMemberAndCard function
    // TM1.16/TSA/20160816 CASE 245004 Transport TM1.16 - 19 July 2016
    // MM1.16/TSA/20160908 CASE 251175 Adding support for facial recognition
    // MM1.16/TSA/20160913  CASE 252216 Signature change on search function
    // MM1.17/TSA/20161121  CASE 259001 Member number not set on member issued ticket
    // MM1.17/TSA/20161208  CASE 259671 Extended functionality for handling the start date of membership, signature change on IsMembershipActive and POS_ValidateMemberCardNo
    // MM1.17/TSA/20161208  CASE 259671 Extended functionality, relocated function TranslateBarcodeToItemVariant from web service codeunit
    // MM1.17/TSA/20161227  CASE 262040 Handlind Suggested Membercount In Sales
    // MM1.17/TSA/20161227  CASE 262040 Signature Change on AddMemberAndCard
    // MM1.17/TSA/20161228  CASE 261216 Handling of creation of different membership entities
    // MM1.17/TSA/20161229  CASE 261216 Signature Change on IssueNewMemberCard
    // MM1.17/TSA/20170127  CASE 264681 Print of multiple memberships sales receipts
    // TM1.19/TSA/20170215  CASE 266372 New function PromptForMemberGuestArrival
    // MM1.19/TSA/20170327  CASE 270308 Added auto print of new card
    // MM1.19/TSA/20170421  CASE 271971 MemberInfoCapture.SETCURRENTKEY ("Receipt No.", "Line No.");
    // MM1.19/TSA/20170504  CASE 274890 Debit Sales support - implemented OnAfterDebitSalePostSubscriver() and OnBeforeAuditRollDebitSaleLineInsertSubscriber()
    // NPR5.34/TSA/20170512  CASE 267611 Signature change to TicketRetailManagement.IssueTicket() in function PromptForMemberGuestArrival
    // MM1.19/TSA/20170518  CASE 276779 Membership ActivateMembership and error if not active
    // MM1.19/TSA/20170525  CASE 278061 Handling issues reported by OMA
    // NPR5.34/TSA /20170720 CASE 284248 Changed External Order No to become member no for internal tickets, SetReservationRequestExtraInfo
    // NPR5.34/TSA /20170721 CASE 284653 Added POS_CheckLimitMemberCardArrival in PrePush_MemberArrival();
    // MM1.22/TSA /20170809 CASE 276102 Added a commit before the runmodal
    // MM1.22/TSA /20170816 CASE 287080 Added handling of ADD_ANONYMOUS_MEMBER in IssueMembershipFromAuditRolePosting()
    // MM1.23/TSA /20171004 CASE 257011 Added Anonymous member exception in POS_ValidateMemberCardNo
    // MM1.23/TSA /20171011 CASE 257011 Added supporting functions for MM POS Sales Info
    // MM1.24/TSA /20171129 CASE 298110 Delete of PreEmptive Membership created during Membership Sales as part of cancel sales
    // MM1.25/TSA /20180115 CASE 299537 Added Offline printing option
    // MM1.25/TSA /20180118 CASE 300256 Member Card local or foreign ?
    // MM1.26/TSA /20180124 CASE 299690 Changed POSMemberCard to include membershipentryno
    // MM1.26/MHA /20180202 CASE 302779 Added OnFinishSale POS Workflow
    // MM1.26/TSA /20180209 CASE 305011 Bug when printing member card from sales receipt
    // MM1.26/MMV /20180215 CASE 294655 Item insert performance optimization
    // MM1.29/TSA /20180517 CASE 315777 Changed workflow step discovery process to support auto-added steps not enabled by default.
    // MM1.30/TSA /20180531 CASE 316450 Adding support to auto swipe a member on create
    // MM1.30/TSA /20180615 CASE 319243 Housecleaning - removing unused variables
    // MM1.32/TSA /20180710 CASE 319477 Better clean-up when membership triggering is in a workflow with a pre-commited sales line
    // MM1.32/TSA /20180711 CASE 318132 Wrapped the EndOfSales print in a worker function, renamed the function
    // MM1.32/TSA /20180723 CASE 319845 Fixed dialog cardinality issue
    // MM1.32/TSA /20180724 CASE 320446 Added Description 2
    // MM1.33/TSA /20180809 CASE 324413 Handling long external card numbers
    // MM1.33/TSA /20180816 CASE 325198 Replace Card flow does not require a membership code on membership sales setup
    // MM1.36/TSA /20181112 CASE 335828 Adding a worker function on POS_ValidateMemberCardNo, to have different behaviours from different invokers
    // MM1.36/TSA /20190125 CASE 307440 Refactored functions
    // MM1.36.01/TSA /20190130 CASE 344400 A multi-member membersship sales only printed first member card
    // MM1.40/TSA /20190611 CASE 357360 Adding remote create of memberships: RemoteCreateMembership(), RemoteAddMember(), IsForeignMembership()
    // MM1.40/TSA /20190614 CASE 358685 Changed subscriber for membership activation that are invoiced to customer
    // MM1.40/TSA /20190730 CASE 360275 Added AdmitMembersOnEndOfSalesWorker(), removed AdmittMembersOnCreateMembership(), corrected spelling of "admit"
    // MM1.40/TSA /20190830 CASE 360242 Added a confirm when printing membercard that is blocked
    // MM1.41/TSA /20190910 CASE 368136 Discontinuing old code
    // MM1.44/TSA /20200514 CASE 401199 Changed caption for ADMIT_MEMBERS
    // MM1.44/TSA /20200519 CASE 405500 Account Print did not support template option for printing
    // MM1.45/TSA /20200729 CASE 416671 Signature change on POS_CheckLimitMemberCardArrival()


    var
        MEMBER_MANAGEMENT: Label 'Member Services';
        MEMBER_CARD_NO: Label 'Member Card Number';
        MEMBER_NOT_RECOGNIZED: Label 'Can''t identify member.';
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        MEMBERSHIP_NOT_VALID: Label 'The membership %1 is not valid for today.';
        BLOCKED_NOT_FOUND: Label 'Member %1 is either blocked or not found.';
        CARD_BLOCKED_NOT_FOUND: Label 'Member Card %1 is either blocked or not found.';
        NO_PRINTOUT: Label 'Membership %1 is not setup for printing.';
        MSG_1101: Label 'Quantity must be 1, when selling memberships.';
        MSG_1102: Label 'Member registration aborted.';
        MSG_1103: Label 'Membership code specified on sales item was not found.';
        MSG_1105: Label 'Nothing to edit.';
        MEMBER_NAME: Label 'Member - %1';
        TICKET_NOT_FOUND: Label 'Ticket not found.';
        UI: Codeunit "MM Member POS UI";
        MEMBERCARD_EXPIRED: Label 'The membercard %1 has expired.';
        gLastMessage: Text;
        Text000: Label 'Print Membership';
        INVALID_TICKET_ITEM: Label 'Ticket Item specified on %1 %2, is not valid. ';
        ADMIT_MEMBERS: Label 'Do you want to admit the member(s)?';
        NOT_SUPPORTED_FOR_REMOTE: Label 'This membership action is not supported for a remote membership';
        CONFIRM_CARD_BLOCKED: Label 'This membercard is blocked, do you want to continue anyway?';

    procedure POS_ValidateMemberCardNo(FailWithError: Boolean; AllowVerboseMode: Boolean; InputMode: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT; ActivateMembership: Boolean; var ExternalMemberCardNo: Text[100]): Boolean
    var
        MembershipEntryNo: Integer;
        MemberManagement: Codeunit "MM Membership Management";
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        Member: Record "MM Member";
        MemberEntryNo: Integer;
        MemberCard: Record "MM Member Card";
        NotFoundReasonText: Text;
        MustActivate: Boolean;
        POSMemberCard: Page "MM POS Member Card";
        ForeignMembershipMgr: Codeunit "MM Foreign Membership Mgr.";
        ForeignCardIsValid: Boolean;
        ForeignMembershipEntryNo: Integer;
        ForeignCommunityCode: Code[20];
        ForeignManagerCode: Code[20];
        FormatedCardNumber: Text[50];
        FormatedForeignCardNumber: Text[50];
    begin

        //-MM1.36 [335828]
        exit(
          POS_ValidateMemberCardNoWorker(FailWithError, AllowVerboseMode, InputMode, ActivateMembership, ExternalMemberCardNo, false));
        //+MM1.36 [335828]
    end;

    procedure POS_ShowMemberCard(InputMode: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT; var ExternalMemberCardNo: Text[100]): Boolean
    begin

        //-MM1.36 [335828]
        exit(
          POS_ValidateMemberCardNoWorker(true, true, InputMode, false, ExternalMemberCardNo, true));
        //+MM1.36 [335828]
    end;

    local procedure POS_ValidateMemberCardNoWorker(FailWithError: Boolean; AllowVerboseMode: Boolean; InputMode: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT; ActivateMembership: Boolean; var ExternalMemberCardNo: Text[100]; ForcedConfirmMember: Boolean): Boolean
    var
        MembershipEntryNo: Integer;
        MemberManagement: Codeunit "MM Membership Management";
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        Member: Record "MM Member";
        MemberEntryNo: Integer;
        MemberCard: Record "MM Member Card";
        NotFoundReasonText: Text;
        MustActivate: Boolean;
        POSMemberCard: Page "MM POS Member Card";
        ForeignMembershipMgr: Codeunit "MM Foreign Membership Mgr.";
        ForeignCardIsValid: Boolean;
        ForeignMembershipEntryNo: Integer;
        ForeignCommunityCode: Code[20];
        ForeignManagerCode: Code[20];
        FormatedCardNumber: Text[50];
        FormatedForeignCardNumber: Text[50];
        ShowMemberDialog: Boolean;
        PageAction: Action;
    begin

        //+MM1.36 [335828]
        case InputMode of
            InputMode::NO_PROMPT:
                ; // Prevalidated
            InputMode::CARD_SCAN:
                ExternalMemberCardNo := UI.SearchBox(MEMBER_CARD_NO, MEMBER_MANAGEMENT, 100);
            InputMode::FACIAL_RECOGNITION:
                begin
                    ExternalMemberCardNo := '';
                    if (UI.MemberSearchWithFacialRecognition(MemberEntryNo)) then begin
                        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
                        MemberCard.SetFilter(Blocked, '=%1', false);
                        MemberCard.SetFilter("Valid Until", '>=%1', Today);
                        // should display list when multiple valid cards
                        if (MemberCard.FindFirst()) then
                            ExternalMemberCardNo := MemberCard."External Card No.";

                        if (ExternalMemberCardNo = '') then
                            Error('You do not have a valid membership...');

                    end else begin
                        Error(MEMBER_NOT_RECOGNIZED);
                    end;
                end;
        end;

        if (ExternalMemberCardNo = '') then begin
            if (FailWithError) then
                Error('');
            exit(false);
        end;

        // Check card number if it exists locally

        //-MM1.33 [324413]
        // IF (STRLEN (ExternalMemberCardNo) <= 50) THEN
        //  MembershipEntryNo := MemberManagement.GetMembershipFromExtCardNo (ExternalMemberCardNo, TODAY, NotFoundReasonText);
        //
        // ForeignMembershipEntryNo := ForeignMembershipMgr.DispatchToReplicateForeignMemberCard ('', ExternalMemberCardNo, ForeignCardIsValid, NotFoundReasonText);
        // IF (ForeignCardIsValid) THEN
        //  MembershipEntryNo := ForeignMembershipEntryNo;

        if (StrLen(ExternalMemberCardNo) <= 50) then begin
            MembershipEntryNo := MemberManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText);
            FormatedCardNumber := ExternalMemberCardNo;
        end;

        ForeignMembershipEntryNo := ForeignMembershipMgr.DispatchToReplicateForeignMemberCard('', ExternalMemberCardNo, FormatedForeignCardNumber, ForeignCardIsValid, NotFoundReasonText);
        if (ForeignCardIsValid) then begin
            MembershipEntryNo := ForeignMembershipEntryNo;
            FormatedCardNumber := FormatedForeignCardNumber;
        end;
        //+MM1.33 [324413]


        if (MembershipEntryNo = 0) then begin
            if (FailWithError) then
                if (NotFoundReasonText <> '') then
                    Error(NotFoundReasonText)
                else
                    Error(CARD_BLOCKED_NOT_FOUND, ExternalMemberCardNo);
            exit(false);
        end;

        //IF (NOT MemberManagement.IsMemberCardActive (ExternalMemberCardNo, TODAY)) THEN BEGIN
        if (not MemberManagement.IsMemberCardActive(FormatedCardNumber, Today)) then begin
            if (FailWithError) then begin

                if (AllowVerboseMode) then begin
                    if not (Confirm(MEMBERCARD_EXPIRED, true, ExternalMemberCardNo)) then begin
                        Error(MEMBERCARD_EXPIRED, ExternalMemberCardNo);
                    end;
                end else begin
                    Error(MEMBERCARD_EXPIRED, ExternalMemberCardNo);
                end;

            end else begin
                exit(false);
            end;
        end;

        if (not Membership.Get(MembershipEntryNo)) then begin
            if (FailWithError) then
                Error(CARD_BLOCKED_NOT_FOUND, ExternalMemberCardNo);
            exit(false);
        end;

        if (not MemberManagement.IsMembershipActive(MembershipEntryNo, Today, false)) then begin
            MustActivate := MemberManagement.MembershipNeedsActivation(MembershipEntryNo);

            if (ActivateMembership) then
                if (not MustActivate) then begin
                    if (FailWithError) then
                        Error(MEMBERSHIP_NOT_VALID, ExternalMemberCardNo);
                    exit(false);
                end;

            if (MustActivate) then
                if (not ActivateMembership) then begin
                    if (FailWithError) then
                        Error(MEMBERSHIP_NOT_VALID, ExternalMemberCardNo);
                    exit(false);
                end;
        end;

        MembershipSetup.Get(Membership."Membership Code");
        //-+MM1.23 [257011]
        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then begin
            // IF NOT (Member.GET (MemberManagement.GetMemberFromExtCardNo (ExternalMemberCardNo, TODAY, NotFoundReasonText))) THEN BEGIN
            if not (Member.Get(MemberManagement.GetMemberFromExtCardNo(FormatedCardNumber, Today, NotFoundReasonText))) then begin
                if (FailWithError) then
                    Error(NotFoundReasonText);
                exit(false);
            end;

            //-MM1.36 [335828]
            ShowMemberDialog := (AllowVerboseMode and MembershipSetup."Confirm Member On Card Scan") or (ForcedConfirmMember);
            if (ShowMemberDialog) then begin
                Commit; //[276102] When Facial Recongnition is used and a face is written

                POSMemberCard.LookupMode(true);
                POSMemberCard.SetRecord(Member);
                POSMemberCard.SetMembershipEntryNo(Membership."Entry No.");

                if (POSMemberCard.RunModal() <> ACTION::LookupOK) then
                    Error('');

            end;

            //  IF (AllowVerboseMode) THEN BEGIN
            //    IF (MembershipSetup."Confirm Member On Card Scan") THEN BEGIN
            //      COMMIT; //[276102] When Facial Recongnition is used and a face is written
            //
            //      POSMemberCard.LOOKUPMODE (TRUE);
            //      POSMemberCard.SETRECORD (Member);
            //      POSMemberCard.SetMembershipEntryNo (Membership."Entry No.");
            //      IF (POSMemberCard.RUNMODAL() <> ACTION::LookupOK) THEN BEGIN
            //        ERROR ('');
            //
            //      END;
            //    END;
            //  END;
            //+MM1.36 [335828]

        end;

        if (MustActivate) and (ActivateMembership) then begin
            MemberManagement.ActivateMembershipLedgerEntry(MembershipEntryNo, Today);
        end;

        exit(true);
    end;

    procedure POS_GetExternalTicketItemFromMembership(ExternalMemberCardNo: Text[50]) TicketItemBarcode: Code[20]
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        MemberManagement: Codeunit "MM Membership Management";
        NotFoundReasonText: Text;
    begin

        if (not Membership.Get(MemberManagement.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText))) then
            if (NotFoundReasonText <> '') then
                Error(NotFoundReasonText)
            else
                Error(MEMBERSHIP_NOT_VALID, ExternalMemberCardNo);

        MembershipSetup.Get(Membership."Membership Code");
        MembershipSetup.TestField("Ticket Item Barcode");

        exit(MembershipSetup."Ticket Item Barcode");
    end;

    procedure PrintMembershipOnEndOfSales(SalesReceiptNo: Code[20])
    var
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipSetup: Record "MM Membership Setup";
        ShouldPrint: Boolean;
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipManagement: Codeunit "MM Membership Management";
        MemberCard: Record "MM Member Card";
    begin

        //-MM1.32 [318132]
        PrintMembershipOnEndOfSalesWorker(SalesReceiptNo, false);

        //+MM1.32 [318132]
    end;

    local procedure PrintMembershipOnEndOfSalesWorker(SalesReceiptNo: Code[20]; ForceCardPrint: Boolean)
    var
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipSetup: Record "MM Membership Setup";
        ShouldPrint: Boolean;
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipManagement: Codeunit "MM Membership Management";
        MemberCard: Record "MM Member Card";
        MemberCard2: Record "MM Member Card";
    begin

        //-MM1.32 [318132]
        MembershipEntry.SetFilter("Receipt No.", '=%1', SalesReceiptNo);
        if (not (MembershipEntry.FindSet())) then
            exit;

        repeat
            ShouldPrint := Membership.Get(MembershipEntry."Membership Entry No.");
            ShouldPrint := ShouldPrint and MembershipSetup.Get(Membership."Membership Code");

            if (ShouldPrint) then begin
                Membership.Reset();
                Membership.SetFilter("Entry No.", '=%1', MembershipEntry."Membership Entry No.");

                case MembershipSetup."POS Print Action" of
                    MembershipSetup."POS Print Action"::DIRECT:
                        begin
                            PrintMembershipSalesReceiptWorker(Membership, MembershipSetup);

                            //-#344400 [344400]
                            // IF (MembershipEntry."Member Card Entry No." <> 0) THEN BEGIN
                            //   IF (MemberCard.GET (MembershipEntry."Member Card Entry No.")) THEN BEGIN
                            //     MemberCard.SETRECFILTER ();
                            //     IF (ForceCardPrint OR (CheckSalesSetupForCardPrint (MembershipEntry."Item No."))) THEN
                            //       PrintMemberCardWorker (MemberCard, MembershipSetup);
                            //   END;
                            // END;
                            if (ForceCardPrint or (CheckSalesSetupForCardPrint(MembershipEntry."Item No."))) then begin
                                if (MembershipEntry."Member Card Entry No." <> 0) then begin
                                    MemberCard2.SetFilter("Entry No.", '%1..', MembershipEntry."Member Card Entry No.");
                                    MemberCard2.SetFilter("Membership Entry No.", '=%1', MembershipEntry."Membership Entry No.");
                                    if (MemberCard2.FindSet()) then begin
                                        repeat
                                            MemberCard.Get(MemberCard2."Entry No.");
                                            MemberCard.SetRecFilter();
                                            PrintMemberCardWorker(MemberCard, MembershipSetup);
                                        until (MemberCard2.Next() = 0);
                                    end;
                                end;
                            end;
                            //+#344400 [344400]

                        end;
                    MembershipSetup."POS Print Action"::OFFLINE:
                        begin
                            MembershipManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_MEMBERSHIP, MembershipEntry."Membership Entry No.");

                            //-#344400 [344400]
                            // IF (ForceCardPrint OR (CheckSalesSetupForCardPrint (MembershipEntry."Item No."))) THEN
                            //  MembershipManagement.PrintOffline (MemberInfoCapture."Information Context"::PRINT_CARD, MembershipEntry."Member Card Entry No.");
                            if (ForceCardPrint or (CheckSalesSetupForCardPrint(MembershipEntry."Item No."))) then begin
                                if (MembershipEntry."Member Card Entry No." <> 0) then begin
                                    MemberCard.SetFilter("Entry No.", '%1..', MembershipEntry."Member Card Entry No.");
                                    MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipEntry."Membership Entry No.");
                                    if (MemberCard.FindSet()) then begin
                                        repeat
                                            MembershipManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_CARD, MemberCard."Entry No.");
                                        until (MemberCard.Next() = 0);
                                    end;
                                end;
                            end;
                            //+#344400 [344400]

                        end;
                end;
            end;

        until (MembershipEntry.Next() = 0);
        //+MM1.32 [318132]
    end;

    procedure PrintMembershipSalesReceiptWorker(var Membership: Record "MM Membership"; var MembershipSetup: Record "MM Membership Setup")
    var
        ObjectOutputMgt: Codeunit "Object Output Mgt.";
        LinePrintMgt: Codeunit "RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "Report Printer Interface";
        PrintTemplateMgt: Codeunit "RP Template Mgt.";
    begin

        case MembershipSetup."Receipt Print Object Type" of
            MembershipSetup."Receipt Print Object Type"::NO_PRINT:
                ;

            MembershipSetup."Receipt Print Object Type"::CODEUNIT:
                if ObjectOutputMgt.GetCodeunitOutputPath(MembershipSetup."Receipt Print Object ID") <> '' then
                    LinePrintMgt.ProcessCodeunit(MembershipSetup."Receipt Print Object ID", Membership)
                else
                    CODEUNIT.Run(MembershipSetup."Receipt Print Object ID", Membership);

            MembershipSetup."Receipt Print Object Type"::REPORT:
                ReportPrinterInterface.RunReport(MembershipSetup."Receipt Print Object ID", false, false, Membership);

            MembershipSetup."Receipt Print Object Type"::TEMPLATE:
                PrintTemplateMgt.PrintTemplate(MembershipSetup."Receipt Print Template Code", Membership, 0);
        end;
    end;

    procedure PrintMemberAccountCard(ExternalMemberNo: Code[20])
    var
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        MemberEntryNo: Integer;
        MembershipEntryNo: Integer;
        MemberManagement: Codeunit "MM Membership Management";
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        MemberEntryNo := MemberManagement.GetMemberFromExtMemberNo(ExternalMemberNo);
        if (not Member.Get(MemberEntryNo)) then
            Error(BLOCKED_NOT_FOUND, ExternalMemberNo);

        MembershipEntryNo := MemberManagement.GetMembershipFromExtMemberNo(ExternalMemberNo);
        if (not Membership.Get(MembershipEntryNo)) then
            Error(BLOCKED_NOT_FOUND, ExternalMemberNo);

        MembershipSetup.Get(Membership."Membership Code");
        Member.SetFilter("Entry No.", '=%1', Member."Entry No.");


        case MembershipSetup."POS Print Action" of
            MembershipSetup."POS Print Action"::DIRECT:
                PrintMemberAccountCardWorker(Member, MembershipSetup);
            MembershipSetup."POS Print Action"::OFFLINE:
                MemberManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_ACCOUNT, Member."Entry No.");
        end;
    end;

    procedure PrintMemberAccountCardWorker(var Member: Record "MM Member"; var MembershipSetup: Record "MM Membership Setup")
    var
        ObjectOutputMgt: Codeunit "Object Output Mgt.";
        LinePrintMgt: Codeunit "RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "Report Printer Interface";
        PrintTemplateMgt: Codeunit "RP Template Mgt.";
    begin

        case MembershipSetup."Account Print Object Type" of
            MembershipSetup."Account Print Object Type"::NO_PRINT:
                Error(NO_PRINTOUT, MembershipSetup.Code);

            MembershipSetup."Account Print Object Type"::CODEUNIT:
                if (ObjectOutputMgt.GetCodeunitOutputPath(MembershipSetup."Account Print Object ID") <> '') then
                    LinePrintMgt.ProcessCodeunit(MembershipSetup."Account Print Object ID", Member)
                else
                    CODEUNIT.Run(MembershipSetup."Account Print Object ID", Member);

            MembershipSetup."Account Print Object Type"::REPORT:
                ReportPrinterInterface.RunReport(MembershipSetup."Account Print Object ID", false, false, Member);

          //-MM1.44 [405500]
          MembershipSetup."Account Print Object Type"::TEMPLATE :
            PrintTemplateMgt.PrintTemplate (MembershipSetup."Account Print Template Code", Member, 0);
          //+MM1.44 [405500]

            else
                Error(ILLEGAL_VALUE, MembershipSetup."Account Print Object Type", MembershipSetup.FieldCaption("Account Print Object Type"));
        end;
    end;

    procedure PrintMemberCard(MemberEntryNo: Integer; MemberCardEntryNo: Integer)
    var
        Member: Record "MM Member";
        MemberCard: Record "MM Member Card";
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        MemberManagement: Codeunit "MM Membership Management";
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        if (not MemberCard.Get(MemberCardEntryNo)) then
            Error(CARD_BLOCKED_NOT_FOUND, MemberCardEntryNo);

        if (MemberEntryNo <> MemberCard."Member Entry No.") then
            Error(CARD_BLOCKED_NOT_FOUND, MemberCardEntryNo);

        if (not Member.Get(MemberEntryNo)) then
            Error(BLOCKED_NOT_FOUND, MemberEntryNo);

        Membership.Get(MemberCard."Membership Entry No.");
        MembershipSetup.Get(Membership."Membership Code");

        MemberCard.SetFilter("Entry No.", '=%1', MemberCard."Entry No.");
        MemberCard.FindFirst();

        //-MM1.40 [360242]
        if ((MemberCard.Blocked) or (Membership.Blocked)) then
          if (not Confirm (CONFIRM_CARD_BLOCKED, true)) then
            Error ('');
        //+MM1.40 [360242]

        case MembershipSetup."POS Print Action" of
            MembershipSetup."POS Print Action"::DIRECT:
                PrintMemberCardWorker(MemberCard, MembershipSetup);
            MembershipSetup."POS Print Action"::OFFLINE:
                MemberManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_CARD, MemberCard."Entry No.");
        end;
    end;

    procedure PrintMemberCardWorker(var MemberCard: Record "MM Member Card"; var MembershipSetup: Record "MM Membership Setup")
    var
        ObjectOutputMgt: Codeunit "Object Output Mgt.";
        LinePrintMgt: Codeunit "RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "Report Printer Interface";
        PrintTemplateMgt: Codeunit "RP Template Mgt.";
    begin

        case MembershipSetup."Card Print Object Type" of
            MembershipSetup."Card Print Object Type"::NO_PRINT:
                Error(NO_PRINTOUT, MembershipSetup.Code);

            MembershipSetup."Card Print Object Type"::CODEUNIT:
                if (ObjectOutputMgt.GetCodeunitOutputPath(MembershipSetup."Card Print Object ID") <> '') then
                    LinePrintMgt.ProcessCodeunit(MembershipSetup."Card Print Object ID", MemberCard)
                else
                    CODEUNIT.Run(MembershipSetup."Card Print Object ID", MemberCard);

            MembershipSetup."Card Print Object Type"::REPORT:
                ReportPrinterInterface.RunReport(MembershipSetup."Card Print Object ID", false, false, MemberCard);

            MembershipSetup."Receipt Print Object Type"::TEMPLATE:
                PrintTemplateMgt.PrintTemplate(MembershipSetup."Card Print Template Code", MemberCard, 0);

            else
                Error(ILLEGAL_VALUE, MembershipSetup."Card Print Object Type", MembershipSetup.FieldCaption("Card Print Object Type"));
        end;
    end;

    local procedure CheckSalesSetupForCardPrint(ItemNo: Code[20]): Boolean
    var
        MembershipSalesSetup: Record "MM Membership Sales Setup";
    begin

        MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
        MembershipSalesSetup.SetFilter("No.", '=%1', ItemNo);
        if (not MembershipSalesSetup.FindFirst()) then
            exit(true); // the setup was deleted - assume true

        exit(MembershipSalesSetup."Member Card Type" in [MembershipSalesSetup."Member Card Type"::CARD, MembershipSalesSetup."Member Card Type"::CARD_PASSSERVER]);
    end;

    procedure IssueTicketFromMemberScan(FailWithError: Boolean; ItemNo: Code[20]; VariantCode: Code[10]; Member: Record "MM Member"; var TicketNo: Code[20]; var ResponseMessage: Text) ResponseCode: Integer
    var
        Item: Record Item;
        TicketType: Record "TM Ticket Type";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        Token: Text[100];
        TMDetTicketAccessEntry: Record "TM Det. Ticket Access Entry";
    begin

        Item.Get(ItemNo);
        if (not TicketType.Get(Item."Ticket Type")) then
            exit;
        if (not TicketType."Is Ticket") then
            exit;

        Token := TicketRequestManager.CreateReservationRequest(ItemNo, VariantCode, 1, Member."External Member No.");
        TicketRequestManager.SetReservationRequestExtraInfo(Token, Member."E-Mail Address", Member."External Member No.");

        ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, FailWithError, ResponseMessage);
        if (ResponseCode <> 0) then
            exit(ResponseCode);

        TicketRequestManager.ConfirmReservationRequestWithValidate(Token);

        if (not TicketRequestManager.GetTokenTicket(Token, TicketNo)) then
            Error(TICKET_NOT_FOUND);

        exit(0);
    end;

    procedure NewMemberSalesInfoCapture(SaleLinePOS: Record "Sale Line POS") ReturnCode: Integer
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        Item: Record Item;
        MembershipSetup: Record "MM Membership Setup";
        i: Integer;
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberLinesToSuggest: Integer;
        ReasonMessage: Text;
    begin

        if (SaleLinePOS.Quantity < 0) then
            exit(0); // Not for us, is cancel/regret

        if (not MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, SaleLinePOS."No.")) then
            exit(0);

        if (not Item.Get(SaleLinePOS."No.")) then
            exit(0);

        if (SaleLinePOS.Quantity <> 1) then
            exit(-1101);


        //-MM1.33 [325198]
        // IF (NOT MembershipSetup.GET (MembershipSalesSetup."Membership Code")) THEN
        //  EXIT (-1103);

        if ((MembershipSalesSetup."Membership Code" = '') and
          (MembershipSalesSetup."Business Flow Type" in [MembershipSalesSetup."Business Flow Type"::ADD_CARD, MembershipSalesSetup."Business Flow Type"::REPLACE_CARD])) then begin
            MembershipSetup.Init();
        end else begin
            if (not MembershipSetup.Get(MembershipSalesSetup."Membership Code")) then
                exit(-1103);
        end;
        //+MM1.33 [325198]

        if (MembershipSetup."Membership Member Cardinality" < 2) then
            MembershipSetup."Membership Member Cardinality" := 1;

        //-MM1.32 [319845]
        if (MembershipSetup."Membership Type" = MembershipSetup."Membership Type"::INDIVIDUAL) then begin
            MembershipSetup."Membership Member Cardinality" := 1;
            MembershipSalesSetup."Suggested Membercount In Sales" := 1;
        end;
        //+MM1.32 [319845]

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");

        // create defaults depending how my "revisit" to member info capture occurs
        case MembershipSalesSetup."Business Flow Type" of

            MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                begin
                    MemberLinesToSuggest := MembershipSetup."Membership Member Cardinality";
                    if ((MembershipSalesSetup."Suggested Membercount In Sales" > 0) and
                        (MembershipSalesSetup."Suggested Membercount In Sales" < MembershipSetup."Membership Member Cardinality")) then
                        MemberLinesToSuggest := MembershipSalesSetup."Suggested Membercount In Sales";

                    if (MemberLinesToSuggest <> MemberInfoCapture.Count()) then begin
                        if (MemberInfoCapture.FindFirst()) then
                            MemberInfoCapture.DeleteAll();

                        for i := 1 to MemberLinesToSuggest do begin
                            MemberInfoCapture.Init();
                            MemberInfoCapture."Entry No." := 0;
                            MemberInfoCapture."Receipt No." := SaleLinePOS."Sales Ticket No.";
                            MemberInfoCapture."Line No." := SaleLinePOS."Line No.";
                            MemberInfoCapture."First Name" := StrSubstNo(MEMBER_NAME, i);
                            MemberInfoCapture.Insert();
                        end;
                    end;

                    MemberInfoCapture.Reset();
                    MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
                    MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
                    MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
                    MemberInfoCapture.FindSet();
                    repeat
                        MemberInfoCapture."Item No." := SaleLinePOS."No.";
                        MemberInfoCapture."Membership Code" := MembershipSalesSetup."Membership Code";
                        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
                        MemberInfoCapture.Modify();
                    until (MemberInfoCapture.Next() = 0);
                end;

            MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER,
            MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER,
            MembershipSalesSetup."Business Flow Type"::ADD_CARD,
            MembershipSalesSetup."Business Flow Type"::REPLACE_CARD:
                begin
                    if (MemberInfoCapture.IsEmpty()) then begin
                        MemberInfoCapture.Init();
                        MemberInfoCapture."Entry No." := 0;
                        MemberInfoCapture."Receipt No." := SaleLinePOS."Sales Ticket No.";
                        MemberInfoCapture."Line No." := SaleLinePOS."Line No.";
                        MemberInfoCapture."Item No." := SaleLinePOS."No.";
                        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
                        MemberInfoCapture.Insert();
                    end;
                end;

            else
                Error('Business Flow Type %1 not handled when preparing user input.', MembershipSalesSetup."Business Flow Type");
        end;

        Commit;
        if (DisplayMemberInfoCaptureDialog(SaleLinePOS)) then begin
            Commit;

            MemberInfoCapture.LockTable();

            MemberInfoCapture.Reset();
            MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
            MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
            MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");

          //-MM1.40 [360275]
          if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::NEW) then begin
            if (MembershipSalesSetup."Auto-Admit Member On Sale" = MembershipSalesSetup."Auto-Admit Member On Sale"::ASK) then
              if (Confirm (ADMIT_MEMBERS, true)) then
                MemberInfoCapture.ModifyAll ("Auto-Admit Member", true);

            if (MembershipSalesSetup."Auto-Admit Member On Sale" = MembershipSalesSetup."Auto-Admit Member On Sale"::YES) then
              MemberInfoCapture.ModifyAll ("Auto-Admit Member", true);
          end;
          Commit;
          //+MM1.40 [360275]

            //-MM1.30 [316450]
            //IF (CreateMemberships (FALSE, MemberInfoCapture, ReasonMessage)) THEN
            //  EXIT (1);
            if (CreateMemberships(false, MemberInfoCapture, ReasonMessage)) then begin

                //-MM1.32 [320446]
                if (SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", SaleLinePOS."Line No.")) then begin
                    SaleLinePOS."Description 2" := MemberInfoCapture."External Membership No.";
                    SaleLinePOS.Modify();
                end;
                //+MM1.32 [320446]

            //-MM1.40 [360275]
            //    COMMIT;
            //
            //    IF (MembershipSalesSetup."Auto-Admit Member On Sale" = MembershipSalesSetup."Auto-Admit Member On Sale"::ASK) THEN
            //      IF (NOT CONFIRM (ADMITT_MEMBERS, TRUE)) THEN
            //        EXIT (1);
            //
            //    IF (MembershipSalesSetup."Auto-Admit Member On Sale" <> MembershipSalesSetup."Auto-Admit Member On Sale"::NO) THEN BEGIN
            //      IF (NOT AdmittMembersOnCreateMembership (MemberInfoCapture, MembershipSalesSetup, MembershipSetup, ReasonMessage)) THEN BEGIN
            //        gLastMessage := ReasonMessage;
            //        EXIT (-1100);
            //      END;
            //    END;
            //+MM1.40 [360275]

                Commit;
                exit(1);
            end;
            //+MM1.30 [316450]

            // Failure PATH
            asserterror Error('%1', ReasonMessage); // Should rollback the faulty creations from CreateMemberships

        end;

        DeleteMemberInfoCapture(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
        if (SaleLinePOS.Delete()) then;
        Commit;

        if (ReasonMessage <> '') then begin
            gLastMessage := ReasonMessage;
            exit(-1100);
        end;

        exit(-1102);
    end;

    procedure DisplayMemberInfoCaptureDialog(SaleLinePOS: Record "Sale Line POS") LookupOK: Boolean
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        MemberInfoCapturePage: Page "MM Member Info Capture";
        PageAction: Action;
    begin

        MemberInfoCapture.Reset();
        MemberInfoCapture.FilterGroup(2);
        MemberInfoCapture.Reset();

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
        MemberInfoCapture.FilterGroup(0);

        MemberInfoCapturePage.SetTableView(MemberInfoCapture);
        MemberInfoCapture.FindSet();

        MemberInfoCapturePage.LookupMode(true);
        MemberInfoCapturePage.Editable(true);

        PageAction := MemberInfoCapturePage.RunModal();

        exit(PageAction = ACTION::LookupOK);
    end;

    procedure IssueMembershipFromAuditRolePosting(AuditRoll: Record "Audit Roll")
    var
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', AuditRoll."Sales Ticket No.");
        MemberInfoCapture.SetFilter("Line No.", '=%1', AuditRoll."Line No.");
        if (not MemberInfoCapture.FindSet()) then
            exit;

        if (AuditRoll."No." <> MemberInfoCapture."Item No.") then
            exit;

        //-MM1.36 [307440] Refactored, code moved to worker function
        with AuditRoll do
            IssueMembershipFromEndOfSaleWorker("Sales Ticket No.", "Line No.", "Sale Date", "Unit Price", Amount, "Amount Including VAT", Description, Quantity);
        //+MM1.36 [307440]
    end;

    local procedure IssueMembershipFromEndOfSaleWorker(ReceiptNo: Code[20]; ReceiptLine: Integer; SalesDate: Date; UnitPrice: Decimal; Amount_LCY: Decimal; AmountInclVat_LCY: Decimal; Description: Text; Quantity: Decimal)
    var
        Membership: Record "MM Membership";
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberManagement: Codeunit "MM Membership Management";
        MemberNotification: Codeunit "MM Member Notification";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        ResponseMessage: Text;
    begin

        //-+MM1.36 [307440] Code moved to a local worker function
        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', ReceiptNo);
        MemberInfoCapture.SetFilter("Line No.", '=%1', ReceiptLine);
        if (not MemberInfoCapture.FindSet()) then
            exit;

        MemberInfoCapture.LockTable(true);
        MemberInfoCapture.FindSet();

        repeat
            MemberInfoCapture."Unit Price" := UnitPrice;
            MemberInfoCapture.Amount := Amount_LCY;
            MemberInfoCapture."Amount Incl VAT" := AmountInclVat_LCY;
            MemberInfoCapture.Description := CopyStr(Description, 1, MaxStrLen(MemberInfoCapture.Description));
            MemberInfoCapture.Modify();
        until (MemberInfoCapture.Next() = 0);

        MemberInfoCapture.FindSet();
        case MemberInfoCapture."Information Context" of

            MemberInfoCapture."Information Context"::NEW:
                begin

                    MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.");

                    case MembershipSalesSetup."Business Flow Type" of
                        MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER:
                            ;
                        else
                            if (Quantity <> 1) then
                                Error(GetErrorText(-1101));
                    end;

                    if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::MEMBERSHIP) then begin

              //-MM1.40 [357360]
              //MemberManagement.AddMembershipLedgerEntry_NEW (MemberInfoCapture."Membership Entry No.", SalesDate, MembershipSalesSetup, MemberInfoCapture);
              if (IsForeignMembership (MembershipSalesSetup."Membership Code")) then begin
                RemoteCreateMembership (MemberInfoCapture, MembershipSalesSetup);
                repeat
                  RemoteAddMember (MemberInfoCapture, MembershipSalesSetup);
                until (MemberInfoCapture.Next() = 0);
                //RemoteActivateMembership (MemberInfoCapture, MembershipSalesSetup);

              end else begin
                MemberManagement.AddMembershipLedgerEntry_NEW (MemberInfoCapture."Membership Entry No.", SalesDate, MembershipSalesSetup, MemberInfoCapture);
              end;
              //+MM1.40 [357360]

            end;

                    if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER) then begin
                        repeat

                //-MM1.40 [357360]
                // MemberManagement.AddMemberAndCard (FALSE, MemberInfoCapture."Membership Entry No.", MemberInfoCapture, TRUE, MemberInfoCapture."Member Entry No", ResponseMessage);
                if (IsForeignMembership (MembershipSalesSetup."Membership Code")) then begin
                  RemoteAddMember (MemberInfoCapture, MembershipSalesSetup);
                end else begin
                  MemberManagement.AddMemberAndCard (false, MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);
                end;
                //+MM1.40 [357360]

                        until (MemberInfoCapture.Next() = 0);

                    end;

                    if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER) then begin
                        MemberManagement.AddAnonymousMember(MemberInfoCapture, Quantity);
                    end;

                    if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::REPLACE_CARD) then begin
                        MemberManagement.BlockMemberCard(MemberManagement.GetCardEntryNoFromExtCardNo(MemberInfoCapture."Replace External Card No."), true);
                        MemberManagement.IssueMemberCard(false, MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
                        if (MembershipSalesSetup."Member Card Type" in [MembershipSalesSetup."Member Card Type"::CARD_PASSSERVER, MembershipSalesSetup."Member Card Type"::PASSSERVER]) then
                            MemberNotification.CreateWalletSendNotification(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture."Card Entry No.");
                    end;

                    if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::ADD_CARD) then begin
                        MemberManagement.IssueMemberCard(false, MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
                        if (MembershipSalesSetup."Member Card Type" in [MembershipSalesSetup."Member Card Type"::CARD_PASSSERVER, MembershipSalesSetup."Member Card Type"::PASSSERVER]) then
                            MemberNotification.CreateWalletSendNotification(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture."Card Entry No.");
                    end;

                end;

            MemberInfoCapture."Information Context"::REGRET:
                begin
                    MemberManagement.RegretMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, UnitPrice);
                end;

            MemberInfoCapture."Information Context"::RENEW:
                begin
                    MemberManagement.RenewMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, UnitPrice);
                end;

            MemberInfoCapture."Information Context"::UPGRADE:
                begin
                    MemberManagement.UpgradeMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, UnitPrice);

                    if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.")) then begin
                        if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER) then begin
                            repeat
                                MemberManagement.AddMemberAndCard(false, MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);
                            until (MemberInfoCapture.Next() = 0);
                        end;

                        if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER) then begin
                            MemberManagement.AddAnonymousMember(MemberInfoCapture, Quantity);
                        end;
                    end;

                end;

            MemberInfoCapture."Information Context"::EXTEND:
                begin
                    MemberManagement.ExtendMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, UnitPrice);
                end;

            MemberInfoCapture."Information Context"::CANCEL:
                begin
                    MemberManagement.CancelMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, UnitPrice);
                end;

        end; // END CASE

        //-MM1.40 [360275]
        if (MemberInfoCapture."Auto-Admit Member") then
          AdmitMembersOnEndOfSalesWorker (MemberInfoCapture, ResponseMessage);
        //+MM1.40 [360275]

        MemberInfoCapture.DeleteAll();
    end;

    local procedure CreateMemberships(FailWithError: Boolean; var MemberInfoCapture: Record "MM Member Info Capture"; var ResponseMessage: Text): Boolean
    var
        MemberManagement: Codeunit "MM Membership Management";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipEntryNo: Integer;
    begin

        // Filter should be sent in record variable
        MemberInfoCapture.LockTable(true);

        if (MemberInfoCapture.FindSet()) then begin
            MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.");

          //-MM1.40 [357360]
          if (IsForeignMembership (MembershipSalesSetup."Membership Code")) then begin
            exit (true);
          end;
          //+MM1.40 [357360]

            //-MM1.17 [262040]
            case MembershipSalesSetup."Business Flow Type" of
                MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                    begin
                        MembershipEntryNo := MemberManagement.CreateMembership(MembershipSalesSetup, MemberInfoCapture, false);
                        //MemberInfoCapture."Member Entry No" := MemberManagement.AddMemberAndCard (MembershipEntryNo, MemberInfoCapture, FALSE);
                        if (not (MemberManagement.AddMemberAndCard(FailWithError, MembershipEntryNo, MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage))) then
                            exit(false);

                        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
                        MemberInfoCapture.Modify();

                        while (MemberInfoCapture.Next <> 0) do begin
                            //MemberInfoCapture."Member Entry No" :=  MemberManagement.AddMemberAndCard (MembershipEntryNo, MemberInfoCapture, FALSE);
                            if (not (MemberManagement.AddMemberAndCard(FailWithError, MembershipEntryNo, MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage))) then
                                exit(false);

                            MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
                            MemberInfoCapture.Modify();
                        end;
                    end;

                MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER:
                    begin
                        repeat
                  if (not IsForeignMembership (MembershipSalesSetup."Membership Code")) then //-+MM1.40 [357360]
                    if (not (MemberManagement.AddMemberAndCard (FailWithError, MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage))) then begin
                      exit (false);
                    end;
                            MemberInfoCapture.Modify();
                        until (MemberInfoCapture.Next() = 0);
                        asserterror Error(''); // force a rollback, membercreation will be redone at checkout
                    end;

                //-MM1.22 [287080]
                MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER:
                    begin
                //-MM1.40 [357360]
                if (IsForeignMembership (MembershipSalesSetup."Membership Code")) then
                  Error (NOT_SUPPORTED_FOR_REMOTE);
                //+MM1.40 [357360]

                        MemberManagement.AddAnonymousMember(MemberInfoCapture, MemberInfoCapture.Quantity);
                        asserterror Error(''); // force a rollback, membercreation will be redone at checkout
                    end;
                    //+MM1.22 [287080]

                MembershipSalesSetup."Business Flow Type"::ADD_CARD:
                    begin
                //-MM1.40 [357360]
                if (IsForeignMembership (MembershipSalesSetup."Membership Code")) then
                  Error (NOT_SUPPORTED_FOR_REMOTE);
                //+MM1.40 [357360]

                        if (not MemberManagement.IssueMemberCard(false, MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage)) then
                            exit(false);
                        asserterror Error(''); // force a rollback, membercreation will be redone at checkout
                    end;

                MembershipSalesSetup."Business Flow Type"::REPLACE_CARD:
                    begin
                //-MM1.40 [357360]
                if (IsForeignMembership (MembershipSalesSetup."Membership Code")) then
                  Error (NOT_SUPPORTED_FOR_REMOTE);
                //+MM1.40 [357360]

                        if (MemberInfoCapture."Replace External Card No." <> '') then
                            MemberManagement.BlockMemberCard(MemberManagement.GetCardEntryNoFromExtCardNo(MemberInfoCapture."Replace External Card No."), true);
                        if (not MemberManagement.IssueMemberCard(false, MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage)) then
                            exit(false);
                        asserterror Error(''); // force a rollback, membercreation will be redone at checkout
                    end;

            end;
            //+MM1.17 [262040]

        end;
        exit(true);
    end;

    local procedure AdmitMembersOnEndOfSalesWorker(var MemberInfoCapture: Record "MM Member Info Capture";ReasonText: Text): Boolean
    var
        MembershipSetup: Record "MM Membership Setup";
        Member: Record "MM Member";
        MemberCard: Record "MM Member Card";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        MemberLimitationMgr: Codeunit "MM Member Limitation Mgr.";
        TicketItemNo: Code[20];
        TicketVariantCode: Code[10];
        ResolvingTable: Integer;
        Token: Text[100];
        ReasonCode: Integer;
    begin

        //-MM1.40 [360275]
        with MemberInfoCapture do
          if (not ("Information Context" in ["Information Context"::NEW,
                                            "Information Context"::RENEW,
                                            "Information Context"::UPGRADE,
                                            "Information Context"::EXTEND])) then begin
            exit (false);
          end;

        MembershipSetup.Get (MemberInfoCapture."Membership Code");
        MembershipSetup.TestField("Ticket Item Barcode");
        if (not TranslateBarcodeToItemVariant(MembershipSetup."Ticket Item Barcode", TicketItemNo, TicketVariantCode, ResolvingTable)) then
            Error(INVALID_TICKET_ITEM, MembershipSetup.TableCaption, MembershipSetup.Code);

        // Filter should be sent in record variable
        if (MemberInfoCapture.FindSet()) then begin
            //Guestcheckin
            repeat
                // Swipe each member
                if (Member.Get(MemberInfoCapture."Member Entry No")) then
                    MemberInfoCapture."External Member No" := Member."External Member No.";

                MemberCard.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
                MemberCard.SetFilter("Member Entry No.", '=%1', MemberInfoCapture."Member Entry No");
                if (MemberCard.FindFirst()) then begin
                    if (MemberCard."External Card No." <> '') then
                        MemberLimitationMgr.POS_CheckLimitMemberCardArrival(MemberCard."External Card No.", '', '<auto>', ReasonText, ReasonCode);
                    if (ReasonCode <> 0) then
                Error (ReasonText);
                end;

            Token := TicketRequestManager.POS_CreateReservationRequest (MemberInfoCapture."Receipt No.", MemberInfoCapture."Line No.", TicketItemNo, TicketVariantCode, 1, MemberInfoCapture."External Member No");
            if  (0 <> TicketRequestManager.IssueTicketFromReservationToken (Token, false, ReasonText)) then
              Error (ReasonText);

            if (not TicketRequestManager.ConfirmReservationRequest (Token, ReasonText)) then
              Error (ReasonText);

            TicketRequestManager.RegisterArrivalRequest (Token);

            until (MemberInfoCapture.Next() = 0);
        end;

        exit(true);
        //+MM1.40 [360275]
    end;

    procedure DeletePreemptiveMembership(ReceiptNo: Code[20]; LineNo: Integer)
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MemberManagement: Codeunit "MM Membership Management";
    begin

        //-MM1.24 [298110]
        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', ReceiptNo);
        MemberInfoCapture.SetFilter("Line No.", '=%1', LineNo);
        if (not MemberInfoCapture.FindFirst()) then
            exit;

        if (not MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.")) then
            exit;

        case MembershipSalesSetup."Business Flow Type" of
            MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                MemberManagement.DeleteMembership(MemberInfoCapture."Membership Entry No.", true);
        end;
    end;

    procedure GetErrorText(MsgNo: Integer) ErrorText: Text
    begin

        //-MM1.05
        ErrorText := '';
        case MsgNo of
            -1100:
                exit(gLastMessage);
            -1101:
                exit(MSG_1101);
            -1102:
                exit(MSG_1102);
            -1103:
                exit(MSG_1103);
            -1104:
                exit(CARD_BLOCKED_NOT_FOUND);
            -1105:
                exit(MSG_1105);
        end;
        //+MM1.05
    end;

    local procedure DeleteMemberInfoCapture(ReceiptNo: Code[20]; LineNo: Integer)
    var
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        //-MM1.19 [271971]
        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        //+MM1.19 [271971]
        MemberInfoCapture.SetFilter("Receipt No.", '=%1', ReceiptNo);
        MemberInfoCapture.SetFilter("Line No.", '=%1', LineNo);
        if (not MemberInfoCapture.IsEmpty()) then begin
            MemberInfoCapture.DeleteAll();
            Commit;
        end;
    end;

    local procedure "--Helpers for remote memberships"()
    begin
    end;

    local procedure IsForeignMembership(MembershipCode: Code[20]): Boolean
    var
        NPRMembership: Codeunit "MM NPR Membership";
    begin

        //-MM1.40 [357360]
        exit (NPRMembership.IsForeignMembershipCommunity (MembershipCode));
        //+MM1.40 [357360]
    end;

    local procedure RemoteCreateMembership(var MemberInfoCapture: Record "MM Member Info Capture";MembershipSalesSetup: Record "MM Membership Sales Setup")
    var
        NPRMembership: Codeunit "MM NPR Membership";
        MembershipSetup: Record "MM Membership Setup";
        NotValidReason: Text;
    begin

        //-MM1.40 [357360]
        MembershipSetup.Get (MembershipSalesSetup."Membership Code");

        if (not NPRMembership.CreateRemoteMembership (MembershipSetup."Community Code", MemberInfoCapture, NotValidReason)) then
          Error (NotValidReason);
        //+MM1.40 [357360]
    end;

    local procedure RemoteAddMember(var MemberInfoCapture: Record "MM Member Info Capture";MembershipSalesSetup: Record "MM Membership Sales Setup")
    var
        MembershipSetup: Record "MM Membership Setup";
        NPRMembership: Codeunit "MM NPR Membership";
        NotValidReason: Text;
    begin

        //-MM1.40 [357360]
        MembershipSetup.Get (MembershipSalesSetup."Membership Code");

        if (not NPRMembership.CreateRemoteMember (MembershipSetup."Community Code", MemberInfoCapture, NotValidReason)) then
          Error (NotValidReason);
        //+MM1.40 [357360]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step"; RunTrigger: Boolean)
    begin

        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if Rec."Subscriber Function" <> 'PrintMembershipsOnSale' then
            exit;

        Rec.Description := Text000;
        Rec."Sequence No." := 100;
    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(CODEUNIT::"MM Member Retail Integration");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure PrintMembershipsOnSale(POSSalesWorkflowStep: Record "POS Sales Workflow Step"; SalePOS: Record "Sale POS")
    var
        AuditRoll: Record "Audit Roll";
    begin

        // Transcendence "POS Sale".OnFinishSale() Publisher
        //
        //

        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'PrintMembershipsOnSale' then
            exit;

        AuditRoll.SetRange("Register No.", SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if not AuditRoll.FindFirst then
            exit;

        //-MM1.32 [318132]
        //PrintMembershipSalesReceipt(AuditRoll."Sales Ticket No.");
        PrintMembershipOnEndOfSalesWorker(AuditRoll."Sales Ticket No.", false);
        //-MM1.32 [318132]
    end;

    procedure TranslateBarcodeToItemVariant(Barcode: Text[50]; var ItemNo: Code[20]; var VariantCode: Code[10]; var ResolvingTable: Integer) Found: Boolean
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        AlternativeNo: Record "Alternative No.";
        ItemVariant: Record "Item Variant";
    begin


        ResolvingTable := 0;
        ItemNo := '';
        VariantCode := '';
        if (Barcode = '') then exit(false);

        // Try Item Table
        if (StrLen(Barcode) <= MaxStrLen(Item."No.")) then begin
            if (Item.Get(UpperCase(Barcode))) then begin
                ResolvingTable := DATABASE::Item;
                ItemNo := Item."No.";
                exit(true);
            end;
        end;

        // Try Item Cross Reference
        with ItemCrossReference do begin
            if (StrLen(Barcode) <= MaxStrLen("Cross-Reference No.")) then begin
                SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                SetFilter("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
                SetFilter("Cross-Reference No.", '=%1', UpperCase(Barcode));
                SetFilter("Discontinue Bar Code", '=%1', false);
                if (FindFirst()) then begin
                    ResolvingTable := DATABASE::"Item Cross Reference";
                    ItemNo := "Item No.";
                    VariantCode := "Variant Code";
                    exit(true);
                end;
            end;
        end;

        // Try Alternative No
        with AlternativeNo do begin
            if (StrLen(Barcode) <= MaxStrLen("Alt. No.")) then begin
                SetCurrentKey("Alt. No.", Type);
                SetFilter("Alt. No.", '=%1', UpperCase(Barcode));
                SetFilter(Type, '=%1', Type::Item);
                if (FindFirst()) then begin
                    if (not Item.Get(Code)) then
                        exit(false);
                    if ("Variant Code" <> '') then
                        if (not ItemVariant.Get(Code, "Variant Code")) then
                            exit(false);
                    ResolvingTable := DATABASE::"Alternative No.";
                    ItemNo := Code;
                    VariantCode := "Variant Code";
                    exit(true);
                end;
            end;
        end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014407, 'OnAfterDebitSalePostEvent', '', true, true)]
    local procedure OnAfterDebitSalePostSubscriber(var Sender: Codeunit "Retail Sales Doc. Mgt."; SalePOS: Record "Sale POS"; SalesHeader: Record "Sales Header"; Posted: Boolean; WriteInAuditRoll: Boolean)
    begin

        // Publisher Standard
        // CU 6014407 "Retail Sales Doc. Mgt.".OnAfterDebitSalePostEvent ()
        //

        //-MM1.32 [318132]
        // IF (SalePOS."Sales Ticket No." <> '') THEN
        //  PrintMembershipSalesReceipt (SalePOS."Sales Ticket No.");

        if (SalePOS."Sales Ticket No." = '') then
            exit;

        PrintMembershipOnEndOfSalesWorker(SalePOS."Sales Ticket No.", false);
        //-MM1.32 [318132]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014435, 'OnBeforeAuditRoleLineInsertEvent', '', true, true)]
    local procedure OnBeforeAuditRollDebitSaleLineInsertSubscriber(var Sender: Codeunit "Retail Form Code";var SalePOS: Record "Sale POS";var SaleLinePos: Record "Sale Line POS";var AuditRole: Record "Audit Roll")
    begin

        //-MM1.40 [358685]
        if AuditRole."Sale Type" <> AuditRole."Sale Type"::"Debit Sale" then
          exit;
        //+MM1.40 [358685]

        if (AuditRole.Type = AuditRole.Type::Item) then
          IssueMembershipFromAuditRolePosting (AuditRole);
    end;
}

