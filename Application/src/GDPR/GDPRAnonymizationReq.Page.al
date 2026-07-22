page 6151153 "NPR GDPR Anonymization Req."
{
    Extensible = False;
    Caption = 'Customer Data Anonymization Request';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR GDPR Anonymization Request";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact No."; Rec."Contact No.")
                {

                    ToolTip = 'Specifies the value of the Contact No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Request Received"; Rec."Request Received")
                {

                    ToolTip = 'Specifies the value of the Request Received field';
                    ApplicationArea = NPRRetail;
                }
                field("Processed At"; Rec."Processed At")
                {

                    ToolTip = 'Specifies the value of the Processed At field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Count"; Rec."Log Count")
                {

                    ToolTip = 'Specifies the value of the Log Count field';
                    ApplicationArea = NPRRetail;
                }
                field(Reason; Rec.Reason)
                {

                    ToolTip = 'Specifies the value of the Reason field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Anonymization Log")
            {
                Caption = 'Anonymization Log';
                Ellipsis = true;
                Image = ChangeLog;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                RunObject = Page "NPR Customer GDPR Log Entries";
                RunPageLink = "Customer No" = FIELD("Customer No.");

                ToolTip = 'Executes the Anonymization Log action';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            action(Anonymize)
            {
                Caption = 'Anonymize';
                Image = Absence;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Anonymize action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    GDPRAnonymizationRequest: Record "NPR GDPR Anonymization Request";
                begin
                    CurrPage.SetSelectionFilter(GDPRAnonymizationRequest);
                    AnonymizeCustomer(GDPRAnonymizationRequest);
                    CurrPage.Update(false);
                end;
            }
        }
    }


    var
        FailedToCancelMembershipErr: Label 'Failed to cancel membership.';
        CustomerNotFoundErr: Label 'Customer not found.';
        PersonNotAuthorizedErr: Label 'Contact of type person does not have authority to request anonymization.';

    trigger OnOpenPage()
    begin
        Rec.SetFilter(Status, '<>%1', Rec.Status::ANONYMIZED);
    end;

    local procedure AnonymizeCustomer(var GDPRAnonymizationRequest: Record "NPR GDPR Anonymization Request")
    var
        CustomerGDPRV2: Codeunit "NPR Customer GDPR V2";
    begin
        if CustomerGDPRV2.IsFeatureEnabled() then
            AnonymizeRequestsV2(GDPRAnonymizationRequest)
        else
            AnonymizeRequestsLegacy(GDPRAnonymizationRequest);
    end;

    local procedure AnonymizeRequestsV2(var GDPRAnonymizationRequest: Record "NPR GDPR Anonymization Request")
    var
        MemberCustRunner: Codeunit "NPR GDPR Cust-Member Anon Run";
        NPGDPRAnonRunner: Codeunit "NPR NP GDPR Anon. Runner";
        Sentry: Codeunit "NPR Sentry";
        SentrySpan: Codeunit "NPR Sentry Span";
        RequestEntryNos: List of [Integer];
        RequestEntryNo: Integer;
        MembershipEntryNo: Integer;
        ReasonTxt: Text;
    begin
        // Snapshot the entry numbers of the requests to process, keeping the read cursor separate from the
        // per-request write/commit cycle (a guarded Codeunit.Run below must not run while a FindSet cursor is
        // open across the per-request Commit). Then process each request through a guarded runner and Commit
        // after each, so a mid-operation error rolls back only that request and the loop continues.
        GDPRAnonymizationRequest.SetFilter(Status, '=%1|=%2', GDPRAnonymizationRequest.Status::NEW, GDPRAnonymizationRequest.Status::PENDING);
        if not GDPRAnonymizationRequest.FindSet() then
            exit;
        repeat
            RequestEntryNos.Add(GDPRAnonymizationRequest."Entry No.");
        until GDPRAnonymizationRequest.Next() = 0;

        Sentry.StartSpan(SentrySpan, 'gdpr-anonymize-requests');
        foreach RequestEntryNo in RequestEntryNos do
            if GDPRAnonymizationRequest.Get(RequestEntryNo) then begin
                ReasonTxt := '';
                GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::PENDING;
                GDPRAnonymizationRequest."Processed At" := CurrentDateTime();

                case GDPRAnonymizationRequest.Type of
                    GDPRAnonymizationRequest.Type::PERSON:
                        begin
                            ReasonTxt := PersonNotAuthorizedErr;
                            GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;
                        end;
                    GDPRAnonymizationRequest.Type::COMPANY:
                        case IsMember(GDPRAnonymizationRequest."Customer No.", MembershipEntryNo) of
                            true:
                                begin
                                    MemberCustRunner.SetCustomer(GDPRAnonymizationRequest."Customer No.");
                                    MemberCustRunner.SetMembership(MembershipEntryNo);
                                    if MemberCustRunner.Run() then begin
                                        ReasonTxt := MemberCustRunner.GetReason();
                                        GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::ANONYMIZED;
                                        InsertLogEntry(GDPRAnonymizationRequest."Customer No.");
                                    end else begin
                                        ReasonTxt := GetLastErrorText();
                                        Sentry.AddLastErrorIfProgrammingBug();
                                        GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;
                                    end;
                                end;
                            false:
                                begin
                                    NPGDPRAnonRunner.SetCheckPeriod(false);
                                    NPGDPRAnonRunner.SetCustomer(GDPRAnonymizationRequest."Customer No.");
                                    if NPGDPRAnonRunner.Run() then begin
                                        ReasonTxt := NPGDPRAnonRunner.GetReason();
                                        if NPGDPRAnonRunner.WasAnonymized() then
                                            GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::ANONYMIZED
                                        else
                                            GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;
                                    end else begin
                                        ReasonTxt := GetLastErrorText();
                                        Sentry.AddLastErrorIfProgrammingBug();
                                        GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;
                                    end;
                                end;
                        end;
                end;

                GDPRAnonymizationRequest.Reason := CopyStr(ReasonTxt, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                GDPRAnonymizationRequest.Modify();
                Commit();
            end;
        SentrySpan.Finish();
    end;

    local procedure AnonymizeRequestsLegacy(var GDPRAnonymizationRequest: Record "NPR GDPR Anonymization Request")
    var
        Customer: Record Customer;
        GDPRManagement: Codeunit "NPR MM GDPR Management";
        NPGDPRManagement: Codeunit "NPR NP GDPR Management";
        MemberCustRunner: Codeunit "NPR GDPR Cust-Member Anon Run";
        ReasonTxt: Text;
        MembershipEntryNo: Integer;
    begin
        GDPRAnonymizationRequest.SetFilter(Status, '=%1|=%2', GDPRAnonymizationRequest.Status::NEW, GDPRAnonymizationRequest.Status::PENDING);
        if not GDPRAnonymizationRequest.FindSet() then
            exit;

        repeat
            ReasonTxt := '';
            GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::PENDING;
            GDPRAnonymizationRequest."Processed At" := CurrentDateTime();

            if GDPRAnonymizationRequest.Type = GDPRAnonymizationRequest.Type::COMPANY then
                case IsMember(GDPRAnonymizationRequest."Customer No.", MembershipEntryNo) of
                    true:
                        begin
                            if MemberCustRunner.CancelMembership(MembershipEntryNo) then begin
                                if GDPRManagement.AnonymizeMembership(MembershipEntryNo, false, ReasonTxt) then begin
                                    GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::ANONYMIZED;
                                    InsertLogEntry(GDPRAnonymizationRequest."Customer No.");
                                end;
                            end else
                                ReasonTxt := FailedToCancelMembershipErr;

                            if GDPRAnonymizationRequest.Status <> GDPRAnonymizationRequest.Status::ANONYMIZED then
                                GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;

                            GDPRAnonymizationRequest.Reason := CopyStr(ReasonTxt, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                            GDPRAnonymizationRequest.Modify();
                        end;
                    false:
                        if Customer.Get(GDPRAnonymizationRequest."Customer No.") then begin
                            if NPGDPRManagement.DoAnonymization(GDPRAnonymizationRequest."Customer No.", ReasonTxt) then
                                GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::ANONYMIZED;
                            GDPRAnonymizationRequest.Reason := CopyStr(ReasonTxt, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                            GDPRAnonymizationRequest.Modify();
                        end else begin
                            GDPRAnonymizationRequest.Reason := CopyStr(CustomerNotFoundErr, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                            GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;
                            GDPRAnonymizationRequest.Modify();
                        end;
                end;

            if GDPRAnonymizationRequest.Type = GDPRAnonymizationRequest.Type::PERSON then begin
                ReasonTxt := PersonNotAuthorizedErr;
                GDPRAnonymizationRequest.Reason := CopyStr(ReasonTxt, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;
                GDPRAnonymizationRequest.Modify();
            end;
        until GDPRAnonymizationRequest.Next() = 0;
    end;

    local procedure IsMember(CustomerNo: Code[20]; var MembershipEntryNo: Integer): Boolean
    var
        Membership: Record "NPR MM Membership";
    begin

        Membership.Reset();
        Membership.SetRange("Customer No.", CustomerNo);
        if (Membership.FindFirst()) then begin
            MembershipEntryNo := Membership."Entry No.";
            exit(true);
        end else
            exit(false);

    end;

    local procedure InsertLogEntry(CustNo: Code[20])
    var
        GDPRLogEntry: Record "NPR Customer GDPR Log Entries";
        EntryNo: Integer;
    begin
        if (GDPRLogEntry.FindLast()) then
            EntryNo := GDPRLogEntry."Entry No"
        else
            EntryNo := 0;

        GDPRLogEntry.Init();
        GDPRLogEntry."Entry No" := EntryNo + 1;
        GDPRLogEntry."Customer No" := CustNo;
        GDPRLogEntry.Status := GDPRLogEntry.Status::Anonymised;
        GDPRLogEntry."Log Entry Date Time" := CURRENTDATETIME;
        GDPRLogEntry."Anonymized By" := CopyStr(USERID, 1, MaxStrLen(GDPRLogEntry."Anonymized By"));
        GDPRLogEntry.Insert();
    end;
}
