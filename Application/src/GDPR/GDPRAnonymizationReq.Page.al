﻿page 6151153 "NPR GDPR Anonymization Req."
{
    Extensible = False;
    Caption = 'GDPR Anonymization Request';
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


    trigger OnOpenPage()
    begin
        Rec.SetFilter(Status, '<>%1', Rec.Status::ANONYMIZED);
    end;

    local procedure AnonymizeCustomer(var GDPRAnonymizationRequest: Record "NPR GDPR Anonymization Request")
    var
        Customer: Record Customer;
        GDPRManagement: Codeunit "NPR MM GDPR Management";
        NPGDPRManagement: Codeunit "NPR NP GDPR Management";
        ReasonTxt: Text;
        MembershipEntryNo: Integer;
    begin

        GDPRAnonymizationRequest.SetFilter(Status, '=%1|=%2', GDPRAnonymizationRequest.Status::NEW, GDPRAnonymizationRequest.Status::PENDING);

        if (GDPRAnonymizationRequest.FindSet()) then begin
            repeat
                ReasonTxt := '';
                GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::PENDING;
                GDPRAnonymizationRequest."Processed At" := CURRENTDATETIME();

                if (GDPRAnonymizationRequest.Type = GDPRAnonymizationRequest.Type::COMPANY) then begin

                    case IsMember(GDPRAnonymizationRequest."Customer No.", MembershipEntryNo) OF
                        true:
                            begin
                                if (CancelMembership(MembershipEntryNo)) then
                                    if (GDPRManagement.AnonymizeMembership(MembershipEntryNo, false, ReasonTxt)) then begin
                                        GDPRAnonymizationRequest.Status := Rec.Status::ANONYMIZED;
                                        InsertLogEntry(Rec."Customer No.");
                                    end;
                                GDPRAnonymizationRequest.Reason := CopyStr(ReasonTxt, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                                GDPRAnonymizationRequest.Modify();
                            end;

                        false:
                            begin

                                if (Customer.Get(GDPRAnonymizationRequest."Customer No.")) then begin
                                    if (NPGDPRManagement.DoAnonymization(GDPRAnonymizationRequest."Customer No.", ReasonTxt)) then begin
                                        GDPRAnonymizationRequest.Status := Rec.Status::ANONYMIZED;
                                    end;
                                    GDPRAnonymizationRequest.Reason := CopyStr(ReasonTxt, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                                    GDPRAnonymizationRequest.Modify();
                                end else begin
                                    Rec.Reason := 'Customer not found.';
                                    GDPRAnonymizationRequest.Reason := CopyStr(ReasonTxt, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                                    GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;
                                    GDPRAnonymizationRequest.Modify();
                                end;

                            end;
                    end;

                end;

                if (GDPRAnonymizationRequest.Type = GDPRAnonymizationRequest.Type::PERSON) then begin
                    ReasonTxt := 'Contact of type person does not have authority to request anonymization.';

                    GDPRAnonymizationRequest.Reason := CopyStr(ReasonTxt, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                    GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;

                    GDPRAnonymizationRequest.Modify();

                end;
            until (GDPRAnonymizationRequest.NEXT() = 0);

        end;

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

    local procedure CancelMembership(MembershipEntryNo: Integer): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
    begin

        if (Membership.Get(MembershipEntryNo)) then begin
            Membership.VALIDATE(Blocked, true);
            Membership."Block Reason" := Membership."Block Reason"::ANONYMIZED;
            Membership.Modify(true);

            MemberInfoCapture.Init();
            MemberInfoCapture."Entry No." := 0;
            MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
            MemberInfoCapture."External Membership No." := Membership."External Membership No.";
            MemberInfoCapture."Membership Code" := Membership."Membership Code";
            MemberInfoCapture."Item No." := GetItemNo(Membership."Membership Code");
            MemberInfoCapture.Insert();

            MemberManagement.CancelMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price");
            exit(true);
        end;
        exit(false);

    end;

    local procedure GetItemNo(MembershipCode: Code[20]): Code[20]
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        if (MembershipCode = '') then
            exit;

        AlterationSetup.Reset();
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::CANCEL);
        AlterationSetup.SetRange("From Membership Code", MembershipCode);
        if (AlterationSetup.FindFirst()) then
            exit(AlterationSetup."Sales Item No.");

    end;

    local procedure InsertLogEntry(CustNo: Code[20])
    var
        GDPRLogEntry: Record "NPR Customer GDPR Log Entries";
        EntryNo: Integer;
    begin

        if (GDPRLogEntry.FindLast()) then
            EntryNo := GDPRLogEntry."Entry No" + 1
        else
            EntryNo := 1;

        GDPRLogEntry.Init();
        GDPRLogEntry."Entry No" := EntryNo + 1;
        GDPRLogEntry."Customer No" := CustNo;
        GDPRLogEntry.Status := GDPRLogEntry.Status::Anonymised;
        GDPRLogEntry."Log Entry Date Time" := CURRENTDATETIME;
        GDPRLogEntry."Anonymized By" := CopyStr(USERID, 1, MaxStrLen(GDPRLogEntry."Anonymized By"));
        GDPRLogEntry.Insert();

    end;

}

