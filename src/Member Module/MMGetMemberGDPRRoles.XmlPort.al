xmlport 6060144 "NPR MM Get Member GDPR Roles"
{
    // MM1.35/TSA /20181023 CASE 333592 Initial version

    Caption = 'Get Member GDPR Roles';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(members)
        {
            textelement(getmembers)
            {
                tableelement(tmpmemberinforequest; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membernumber; tmpMemberInfoRequest."External Member No")
                    {
                    }
                    fieldelement(cardnumber; tmpMemberInfoRequest."External Card No.")
                    {
                    }
                }
                textelement(response)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textelement(status)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(errordescription)
                    {
                        MaxOccurs = Once;
                    }
                    tableelement(tmpmembershiprole; "NPR MM Membership Role")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'member';
                        UseTemporary = true;
                        textattribute(memberrole)
                        {
                            XmlName = 'role';

                            trigger OnBeforePassVariable()
                            var
                                MembershipRole: Record "NPR MM Membership Role";
                            begin
                                MemberRole := Format(TmpMembershipRole."Member Role");
                            end;
                        }
                        textelement(displayname)
                        {
                            MaxOccurs = Once;
                            XmlName = 'displayname';

                            trigger OnBeforePassVariable()
                            var
                                Member: Record "NPR MM Member";
                            begin

                                DisplayName := '';
                                if (Member.Get(TmpMembershipRole."Member Entry No.")) then
                                    DisplayName := Member."Display Name";
                            end;
                        }
                        fieldelement(membershipnumber; TmpMembershipRole."External Membership No.")
                        {
                        }
                        fieldelement(membershipcode; TmpMembershipRole."Membership Code")
                        {
                        }
                        fieldelement(membernumber; TmpMembershipRole."External Member No.")
                        {
                        }
                        fieldelement(datasubjectid; TmpMembershipRole."GDPR Data Subject Id")
                        {
                        }
                        fieldelement(gdpr_agreement; TmpMembershipRole."GDPR Agreement No.")
                        {
                        }
                        textelement(approvaltext)
                        {
                            XmlName = 'gdpr_approval';

                            trigger OnBeforePassVariable()
                            var
                                MembershipRole: Record "NPR MM Membership Role";
                            begin
                                // MembershipRole.GET (tmpMemberInfoResponse."Membership Entry No.", tmpMemberInfoResponse."Member Entry No");
                                TmpMembershipRole.CalcFields("GDPR Approval");
                                ApprovalText := Format(TmpMembershipRole."GDPR Approval");
                            end;
                        }
                        textelement(agreementurl)
                        {
                            XmlName = 'gdpr_url';

                            trigger OnBeforePassVariable()
                            var
                                GDPRConsentLog: Record "NPR GDPR Consent Log";
                                GDPRAgreementVersion: Record "NPR GDPR Agreement Version";
                            begin

                                AgreementUrl := '';
                                TmpMembershipRole.CalcFields("GDPR Current Entry No.");
                                if (GDPRConsentLog.Get(TmpMembershipRole."GDPR Current Entry No.")) then begin
                                    GDPRAgreementVersion.Get(GDPRConsentLog."Agreement No.", GDPRConsentLog."Agreement Version");
                                    AgreementUrl := GDPRAgreementVersion.URL;
                                end;
                            end;
                        }
                        textelement(cards)
                        {
                            tableelement(membercard; "NPR MM Member Card")
                            {
                                LinkFields = "Membership Entry No." = FIELD("Membership Entry No."), "Member Entry No." = FIELD("Member Entry No.");
                                LinkTable = TmpMembershipRole;
                                MinOccurs = Zero;
                                XmlName = 'card';
                                SourceTableView = WHERE(Blocked = CONST(false));
                                fieldelement(cardnumber; MemberCard."External Card No.")
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    // IF (MemberCard."Valid Until" > TODAY) THEN
                                    //  currXMLport.BREAK ();
                                end;
                            }
                        }
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'MM Get Membership Members';

        layout
        {
        }

        actions
        {
        }
    }

    var
        NOT_FOUND: Label 'Filter combination removed all results.';

    procedure ClearResponse()
    begin

        TmpMembershipRole.DeleteAll();
    end;

    procedure AddResponse(MemberEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
    begin

        errordescription := '';
        status := '1';

        if (MemberEntryNo <= 0) then
            exit;

        Member.Get(MemberEntryNo);

        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);

        if (MembershipRole.FindSet()) then begin
            repeat

                TmpMembershipRole.TransferFields(MembershipRole, true);
                TmpMembershipRole.Insert();

            until (MembershipRole.Next() = 0);
        end;

        if (TmpMembershipRole.Count() = 0) then
            AddErrorResponse(NOT_FOUND);
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';
    end;
}

