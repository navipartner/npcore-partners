#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248221 "NPR MembershipApiTranslation"
{
    Access = Internal;

    internal procedure MemberRoleToText(MemberRole: Option): Text
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
                exit('true');
            Member."E-Mail News Letter"::NO:
                exit('false');
            else
                exit('unknown');
        end;
    end;

    internal procedure MembershipEntryContextToText(Context: Option): Text
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

}
#endif