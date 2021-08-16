xmlport 6151121 "NPR MM GDPR GetSet Appr. State"
{

    Caption = 'GDPR Get Set Approval State';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(members)
        {
            textelement(getsegdprtapproval)
            {
                tableelement(tmpmemberinforequest; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(cardnumber; tmpMemberInfoRequest."External Card No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(datasubjectid; tmpMemberInfoRequest."User Logon ID")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(gdpr_approval; tmpMemberInfoRequest."GDPR Approval")
                    {
                        MinOccurs = Zero;
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
                    tableelement(tmpmember; "NPR MM Membership Role")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'member';
                        UseTemporary = true;
                        textelement(displayname)
                        {
                            MaxOccurs = Once;
                            XmlName = 'displayname';
                        }
                        textelement(memberrole)
                        {
                            XmlName = 'role';

                            trigger OnBeforePassVariable()
                            begin
                                MemberRole := Format(tmpMember."Member Role");
                            end;
                        }
                        textelement(approvaltext)
                        {
                            MaxOccurs = Once;
                            XmlName = 'gdpr_approval';

                            trigger OnBeforePassVariable()
                            var
                                MembershipRole: Record "NPR MM Membership Role";
                            begin
                                if (MembershipRole.Get(tmpMember."Membership Entry No.", tmpMember."Member Entry No.")) then begin
                                    MembershipRole.CalcFields("GDPR Approval");
                                    ApprovalText := Format(MembershipRole."GDPR Approval");
                                end;
                            end;
                        }
                        textelement(statechange)
                        {
                            MaxOccurs = Once;
                            XmlName = 'gdpr_approval_datetime';
                        }
                        textelement(agreementdescription)
                        {
                            MaxOccurs = Once;
                            XmlName = 'gdpr_description';
                        }
                        textelement(agreementurl)
                        {
                            MaxOccurs = Once;
                            XmlName = 'gdpr_url';
                        }
                        textelement(agreementno)
                        {
                            MaxOccurs = Once;
                            XmlName = 'gdpr_agreement';
                        }
                        textelement(agreementversion)
                        {
                            MaxOccurs = Once;
                            XmlName = 'gdpr_version';
                        }
                        textelement(agreementactivefrom)
                        {
                            MaxOccurs = Once;
                            XmlName = 'gdpr_validfrom';
                        }
                        textelement(guardians)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            tableelement(tmpguardians; "NPR MM Membership Role")
                            {
                                MinOccurs = Zero;
                                XmlName = 'guardian';
                                UseTemporary = true;
                                fieldelement(membershipnumber; TmpGuardians."External Membership No.")
                                {
                                }
                                fieldelement(datasubjectid; TmpGuardians."GDPR Data Subject Id")
                                {
                                }
                                fieldelement(displayname; TmpGuardians."Member Display Name")
                                {
                                }
                                textelement(guardianapprovaltext)
                                {
                                    XmlName = 'gdpr_approval';

                                    trigger OnBeforePassVariable()
                                    var
                                        MembershipRole: Record "NPR MM Membership Role";
                                    begin
                                        if (MembershipRole.Get(TmpGuardians."Membership Entry No.", TmpGuardians."Member Entry No.")) then begin
                                            MembershipRole.CalcFields("GDPR Approval");
                                            GuardianApprovalText := Format(MembershipRole."GDPR Approval");
                                        end;
                                    end;
                                }
                            }
                        }
                        textelement(dependents)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            tableelement(tmpdependents; "NPR MM Membership Role")
                            {
                                MinOccurs = Zero;
                                XmlName = 'dependent';
                                UseTemporary = true;
                                fieldelement(membershipnumber; TmpDependents."External Membership No.")
                                {
                                }
                                fieldelement(datasubjectid; TmpDependents."GDPR Data Subject Id")
                                {
                                }
                                fieldelement(displayname; TmpDependents."Member Display Name")
                                {
                                }
                                textelement(dependentapprovaltext)
                                {
                                    XmlName = 'gdpr_approval';

                                    trigger OnBeforePassVariable()
                                    var
                                        MembershipRole: Record "NPR MM Membership Role";
                                    begin
                                        if (MembershipRole.Get(TmpDependents."Membership Entry No.", TmpDependents."Member Entry No.")) then begin
                                            MembershipRole.CalcFields("GDPR Approval");
                                            DependentApprovalText := Format(MembershipRole."GDPR Approval");
                                        end;
                                    end;
                                }
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


    procedure ClearResponse()
    begin

        tmpMember.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        GDPRConsentLog: Record "NPR GDPR Consent Log";
        GDPRAgreementVersion: Record "NPR GDPR Agreement Version";
    begin

        errordescription := '';
        status := '1';

        if (MembershipEntryNo <= 0) then
            exit;

        Member.Get(MemberEntryNo);
        Membership.Get(MembershipEntryNo);
        MembershipRole.Get(MembershipEntryNo, MemberEntryNo);
        tmpMember.TransferFields(MembershipRole, true);
        tmpMember.Insert();

        DisplayName := Member."Display Name";

        MembershipRole.CalcFields("GDPR Current Entry No.");
        if (GDPRConsentLog.Get(MembershipRole."GDPR Current Entry No.")) then begin
            GDPRAgreementVersion.Get(GDPRConsentLog."Agreement No.", GDPRConsentLog."Agreement Version");
            StateChange := Format(GDPRConsentLog."State Change", 0, 9);
            AgreementUrl := GDPRAgreementVersion.URL;
            AgreementNo := GDPRAgreementVersion."No.";
            AgreementVersion := Format(GDPRConsentLog."Agreement Version");
            AgreementDescription := GDPRAgreementVersion.Description;
            AgreementActiveFrom := Format(GDPRAgreementVersion."Activation Date", 0, 9);
        end;

        MembershipRole.Reset();
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Entry No.", '<>%1', MemberEntryNo);
        if (MembershipRole.FindSet()) then begin
            repeat
                if (MembershipRole."Member Role" = MembershipRole."Member Role"::GUARDIAN) then begin
                    TmpGuardians.TransferFields(MembershipRole, true);
                    TmpGuardians.Insert();
                end;

                if (MembershipRole."Member Role" <> MembershipRole."Member Role"::GUARDIAN) then begin
                    TmpDependents.TransferFields(MembershipRole, true);
                    TmpDependents.Insert();
                end;
            until MembershipRole.Next() = 0;
        end;
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';
    end;
}

