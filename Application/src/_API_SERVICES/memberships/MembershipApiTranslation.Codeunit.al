#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248221 "NPR MembershipApiTranslation"
{
    Access = Internal;

    internal procedure MemberRoleToText(MemberRole: Option): Text[50]
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        case MemberRole of
            MembershipRole."Member Role"::ADMIN:
                exit('membershipAdmin');
            MembershipRole."Member Role"::MEMBER:
                exit('member');
            MembershipRole."Member Role"::ANONYMOUS:
                exit('anonymous');
            MembershipRole."Member Role"::GUARDIAN:
                exit('guardian');
            MembershipRole."Member Role"::DEPENDENT:
                exit('dependent');
            else
                exit('unknownRole');
        end;
    end;

    internal procedure GenderAsText(Gender: Option): Text
    var
        Member: Record "NPR MM Member";
    begin
        case Gender of
            Member.Gender::FEMALE:
                exit('female');
            Member.Gender::MALE:
                exit('male');
            Member.Gender::OTHER:
                exit('other');
            Member.Gender::NOT_SPECIFIED:
                exit('notSpecified');
            else
                exit('unknownGender');
        end;
    end;

    internal procedure NewsLetterAsText(NewsLetter: Option): Text
    var
        Member: Record "NPR MM Member";
    begin
        case NewsLetter of
            Member."E-Mail News Letter"::YES:
                exit('yes');
            Member."E-Mail News Letter"::NO:
                exit('no');
            else
                exit('unknown');
        end;
    end;

    internal procedure MembershipEntryContextToText(Context: Option): Text[50]
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        case Context of
            MembershipEntry.Context::NEW:
                exit('new');
            MembershipEntry.Context::REGRET:
                exit('regret');
            MembershipEntry.Context::RENEW:
                exit('renew');
            MembershipEntry.Context::UPGRADE:
                exit('upgrade');
            MembershipEntry.Context::EXTEND:
                exit('extend');
            MembershipEntry.Context::CANCEL:
                exit('cancel');
            MembershipEntry.Context::AUTORENEW:
                exit('autoRenew');
            MembershipEntry.Context::FOREIGN:
                exit('foreignMembership');
            else
                exit('unknownContext');
        end;
    end;

    internal procedure GdprApprovalAsText(GdprApproval: Option): Text
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin

        case GdprApproval of

            MembershipRole."GDPR Approval"::PENDING:
                exit('pending');
            MembershipRole."GDPR Approval"::ACCEPTED:
                exit('accepted');
            MembershipRole."GDPR Approval"::REJECTED:
                exit('rejected');
            MembershipRole."GDPR Approval"::DELEGATED:
                exit('delegated');
            else
                exit('notApplicable');
        end;
    end;

    internal procedure MembershipEntryLinkContextToText(Context: Option): Text
    var
        MembershipEntryLink: Record "NPR MM Membership Entry Link";
    begin
        case Context of
            MembershipEntryLink.Context::NEW:
                exit('new');
            MembershipEntryLink.Context::REGRET:
                exit('regret');
            MembershipEntryLink.Context::RENEW:
                exit('renew');
            MembershipEntryLink.Context::UPGRADE:
                exit('upgrade');
            MembershipEntryLink.Context::EXTEND:
                exit('extend');
            MembershipEntryLink.Context::LIST:
                exit('list');
            MembershipEntryLink.Context::CANCEL:
                exit('cancel');
            MembershipEntryLink.Context::AUTORENEW:
                exit('autoRenew');
            MembershipEntryLink.Context::FOREIGN:
                exit('foreignMembership');
            MembershipEntryLink.Context::PRINT_CARD:
                exit('printCard');
            MembershipEntryLink.Context::PRINT_ACCOUNT:
                exit('printAccount');
            MembershipEntryLink.Context::PRINT_MEMBERSHIP:
                exit('printMembership');
            else
                exit('unknownContext');
        end;
    end;

}
#endif