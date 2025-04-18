xmlport 6060133 "NPR MM Get Members. TicketList"
{

    Caption = 'Get Membership Ticket List';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(membershiptickets)
        {
            MaxOccurs = Once;
            textelement(getmembershiptickets)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membernumber; tmpMemberInfoCapture."External Member No")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(cardnumber; tmpMemberInfoCapture."External Card No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(membershipnumber; tmpMemberInfoCapture."External Membership No.")
                    {
                    }
                }
                tableelement(tmpmembershipresponse; "NPR MM Membership")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'response';
                    UseTemporary = true;
                    textelement(status)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(errordescription)
                    {
                        MaxOccurs = Once;
                    }
                    tableelement(tmpmember; "NPR MM Member")
                    {
                        XmlName = 'member';
                        UseTemporary = true;
                        fieldelement(membernumber; tmpMember."External Member No.")
                        {
                        }
                        fieldelement(firstname; tmpMember."First Name")
                        {
                        }
                        fieldelement(lastname; tmpMember."Last Name")
                        {
                        }
                        textelement(birthday)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                birthday := Format(tmpMember.Birthday, 0, 9);
                            end;
                        }
                        textelement(membershipinfo)
                        {
                            MinOccurs = Zero;
                            fieldelement(communitycode; tmpMembershipResponse."Community Code")
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(membershipcode; tmpMembershipResponse."Membership Code")
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(membershipnumber; tmpMembershipResponse."External Membership No.")
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(issuedate; tmpMembershipResponse."Issued Date")
                            {
                                MinOccurs = Zero;
                            }
                            textelement(validfromdate)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                XmlName = 'validfromdate';
                            }
                            textelement(validuntildate)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                XmlName = 'validuntildate';
                            }
                            textelement(MembershipPeriods)
                            {
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                                XmlName = 'membershipperiods';

                                tableelement(TmpMembershipEntry; "NPR MM Membership Entry")
                                {
                                    UseTemporary = true;
                                    XmlName = 'period';
                                    MinOccurs = Zero;

                                    fieldattribute(validfromdate; TmpMembershipEntry."Valid From Date")
                                    {

                                    }
                                    fieldattribute(validuntildate; TmpMembershipEntry."Valid Until Date")
                                    {

                                    }
                                    fieldelement(createdate; TmpMembershipEntry."Created At")
                                    {

                                    }
                                    fieldelement(context; TmpMembershipEntry.Context)
                                    {
                                        textattribute(ContextName)
                                        {
                                            XmlName = 'name';
                                            trigger OnBeforePassVariable()
                                            begin
                                                CASE TmpMembershipEntry.Context OF
                                                    TmpMembershipEntry.Context::NEW:
                                                        ContextName := 'New';
                                                    TmpMembershipEntry.Context::AUTORENEW:
                                                        ContextName := 'Auto-Renew';
                                                    TmpMembershipEntry.Context::CANCEL:
                                                        ContextName := 'Cancel';
                                                    TmpMembershipEntry.Context::EXTEND:
                                                        ContextName := 'Extend';
                                                    TmpMembershipEntry.Context::FOREIGN:
                                                        ContextName := 'Foreign Membership';
                                                    TmpMembershipEntry.Context::REGRET:
                                                        ContextName := 'Regret';
                                                    TmpMembershipEntry.Context::RENEW:
                                                        ContextName := 'Renew';
                                                    TmpMembershipEntry.Context::UPGRADE:
                                                        ContextName := 'Upgrade';
                                                END;
                                            end;
                                        }
                                    }

                                    fieldelement(blocked; TmpMembershipEntry.Blocked)
                                    {

                                    }
                                    fieldelement(activateonfirstuse; TmpMembershipEntry."Activate On First Use")
                                    {

                                    }

                                    fieldelement(productid; TmpMembershipEntry."Item No.")
                                    {

                                    }
                                    fieldelement(documentid; TmpMembershipEntry."Import Entry Document ID")
                                    {

                                    }

                                }
                            }
                        }
                    }
                    textelement(membership)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        textelement(owner_ticket_item_no)
                        {
                            XmlName = 'ticket_item_no';

                            trigger OnBeforePassVariable()
                            begin
                                owner_ticket_item_no := MembershipSetup."Ticket Item Barcode";
                            end;
                        }
                        textelement(membercardinality)
                        {

                            trigger OnBeforePassVariable()
                            begin

                                membercardinality := Format(MembershipSetup."Membership Member Cardinality");
                                if (membercardinality = '0') then
                                    membercardinality := '1';
                            end;
                        }
                        textelement(guesttickets)
                        {
                            MinOccurs = Zero;
                            textattribute(xml_admissioncode)
                            {
                                XmlName = 'admissioncode';
                            }
                            textattribute(guestcardinality)
                            {
                            }
                            tableelement(tmpmembershipadmissionsetup; "NPR MM Members. Admis. Setup")
                            {
                                LinkFields = "Membership  Code" = FIELD("Membership Code");
                                LinkTable = tmpMembershipResponse;
                                MinOccurs = Zero;
                                XmlName = 'ticket';
                                UseTemporary = true;
                                fieldattribute(ticket_item_no; tmpMembershipAdmissionSetup."Ticket No.")
                                {
                                }
                                fieldattribute(description; tmpMembershipAdmissionSetup.Description)
                                {
                                }
                                fieldattribute(ticketcardinality; tmpMembershipAdmissionSetup."Max Cardinality")
                                {
                                }
                                fieldattribute(admissioncode; tmpMembershipAdmissionSetup."Admission Code")
                                {
                                }
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
                        DateValidFromDate: Date;
                        DateValidUntilDate: Date;
                    begin

                        if (MembershipSetup.Get(tmpMembershipResponse."Membership Code")) then;
                        MembershipManagement.GetMembershipValidDate(tmpMembershipResponse."Entry No.", Today, DateValidFromDate, DateValidUntilDate);
                        ValidFromDate := Format(DateValidFromDate, 0, 9);
                        ValidUntilDate := Format(DateValidUntilDate, 0, 9);

                    end;
                }
            }
        }
    }

    requestpage
    {
        Caption = 'MM Get Membership Ticket List';

        layout
        {
        }

        actions
        {
        }
    }

    var
        MembershipSetup: Record "NPR MM Membership Setup";
        AdmissionSetup: Record "NPR TM Admission";

    internal procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll();
    end;

    internal procedure AddResponse(MembershipEntryNo: Integer; MemberEntryNo: Integer; ParamAdmissionCode: Code[20])
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipEntry: Record "NPR MM Membership Entry";
        ResponseLbl: Label 'Invalid Admission Code %1';
        Response2Lbl: Label 'Membership %1 does not have a member %2';
    begin

        errordescription := '';
        status := '1';

        if (MembershipEntryNo <= 0) then begin
            AddErrorResponse('Invalid Membership Entry No.');
            exit;
        end;

        if (ParamAdmissionCode <> '') then
            if (not AdmissionSetup.Get(ParamAdmissionCode)) then begin
                AddErrorResponse(StrSubstNo(ResponseLbl, ParamAdmissionCode));
                exit;
            end;

        Membership.Get(MembershipEntryNo);

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);

        if (MemberEntryNo > 0) then begin
            MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
            //IF (MembershipRole.IsEmpty ()) THEN BEGIN
            if (not MembershipRole.FindFirst()) then begin
                AddErrorResponse(StrSubstNo(Response2Lbl, Membership."External Membership No.", tmpMemberInfoCapture."External Member No"));
                exit;
            end;

        end else begin

            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
            if (not MembershipRole.FindFirst()) then begin
                MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::MEMBER);

                if not (MembershipRole.FindFirst()) then
                    Clear(MembershipRole); // MembershipRole."Member Entry No." set to zero

            end;
        end;

        if (Member.Get(MembershipRole."Member Entry No.")) then begin
            tmpMember.TransferFields(Member, true);
            tmpMember.Insert();
        end;

        MembershipEntry.SETFILTER("Membership Entry No.", '=%1', MembershipEntryNo);
        IF (MembershipEntry.FINDSET()) THEN BEGIN
            REPEAT
                TmpMembershipEntry.TRANSFERFIELDS(MembershipEntry, TRUE);
                TmpMembershipEntry.INSERT();
            UNTIL (MembershipEntry.NEXT() = 0);
        END;

        xml_admissioncode := ParamAdmissionCode;

        tmpMembershipResponse.TransferFields(Membership, true);
        if (tmpMembershipResponse.Insert()) then;

        guestcardinality := '9999';
        MembershipAdmissionSetup.SetFilter("Membership  Code", '=%1', Membership."Membership Code");

        if (ParamAdmissionCode <> '') then
            MembershipAdmissionSetup.SetFilter("Admission Code", '=%1', ParamAdmissionCode);

        if (MembershipAdmissionSetup.FindSet()) then begin
            repeat
                if (MembershipAdmissionSetup."Ticket No. Type" = MembershipAdmissionSetup."Ticket No. Type"::NA) then begin
                    if (MembershipAdmissionSetup."Cardinality Type" = MembershipAdmissionSetup."Cardinality Type"::LIMITED) then
                        guestcardinality := Format(MembershipAdmissionSetup."Max Cardinality");
                end else begin
                    tmpMembershipAdmissionSetup.TransferFields(MembershipAdmissionSetup, true);
                    if (MembershipAdmissionSetup."Cardinality Type" = MembershipAdmissionSetup."Cardinality Type"::UNLIMITED) then
                        tmpMembershipAdmissionSetup."Max Cardinality" := 9999;
                    tmpMembershipAdmissionSetup.Insert();
                end;
            until (MembershipAdmissionSetup.Next() = 0);

        end;
    end;

    internal procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';
        if (tmpMembershipResponse.Insert()) then;
    end;
}

