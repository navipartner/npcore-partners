codeunit 6014682 "NPR MM Smart Search"
{
    internal procedure SearchMember(SearchTerm: Text[100]; var Member: Record "NPR MM Member")
    begin
        MemberSearchWorker(SearchTerm, Member);
    end;

    internal procedure SearchMembership(SearchTerm: Text[100]; var Membership: Record "NPR MM Membership")
    begin
        MembershipSearchWorker(SearchTerm, Membership);
    end;

    internal procedure SearchMemberCard(SearchTerm: Text[100]; var MemberCard: Record "NPR MM Member Card")
    begin
        MemberCardSearchWorker(SearchTerm, MemberCard);
    end;

    local procedure MemberSearchWorker(SearchTerm: Text[100]; var Member: Record "NPR MM Member")
    var
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipEntry: Record "NPR MM Membership Entry";
        MemberFound: Boolean;
    begin
        Member.FilterGroup := -1;
        Member.SetFilter("External Member No.", '%1', UpperCase(SearchTerm));
        Member.SetFilter("First Name", '%1', '@' + SearchTerm);
        Member.SetFilter("Last Name", '%1', '@' + SearchTerm);
        Member.SetFilter("E-Mail Address", '%1', LowerCase(ConvertStr(SearchTerm, '@', '?')));
        Member.SetFilter("Phone No.", '%1', SearchTerm);
        Member.SetFilter("Display Name", '%1', SearchTerm);
        Member.FilterGroup := 0;

        Member.SetLoadFields("Entry No.");

        MemberFound := Member.FindSet();
        if (MemberFound) then
            repeat
                Member.Mark(true);
            until (Member.Next() = 0);

        if (not MemberFound) then begin
            Membership.SetLoadFields("Entry No.", "External Membership No.");
            Membership.SetFilter("External Membership No.", '%1', UpperCase(SearchTerm));
            if (Membership.FindSet()) then begin
                repeat
                    MembershipRole.SetLoadFields("Membership Entry No.", "Member Entry No.");
                    MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                    if (MembershipRole.FindSet()) then begin
                        repeat
                            if (Member.Get(MembershipRole."Member Entry No.")) then begin
                                MemberFound := true;
                                Member.Mark(true);
                            end;
                        until (MembershipRole.Next() = 0);
                    end;
                until (Membership.Next() = 0);
            end;
        end;

        if (not MemberFound) then begin
            MemberCard.SetLoadFields("External Card No.", "Member Entry No.");
            MemberCard.SetFilter("External Card No.", '%1', UpperCase(SearchTerm));
            if (MemberCard.FindSet()) then begin
                repeat
                    if (Member.Get(MemberCard."Member Entry No.")) then begin
                        MemberFound := true;
                        Member.Mark(true);
                    end;
                until (MemberCard.Next() = 0);
            end;
        end;

        if (not MemberFound) then begin
            MembershipEntry.SetLoadFields("Membership Entry No.");
            MembershipEntry.SetFilter("Receipt No.", '=%1', UpperCase(SearchTerm));
            if (MembershipEntry.FindSet()) then begin
                repeat
                    MembershipRole.SetLoadFields("Membership Entry No.", "Member Entry No.");
                    MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntry."Membership Entry No.");
                    if (MembershipRole.FindSet()) then begin
                        repeat
                            if (Member.Get(MembershipRole."Member Entry No.")) then begin
                                MemberFound := true;
                                Member.Mark(true);
                            end;
                        until (MembershipRole.Next() = 0);
                    end;
                until (MembershipEntry.Next() = 0);
            end;
        end;
    end;

    local procedure MembershipSearchWorker(SearchTerm: Text[100]; var Membership: Record "NPR MM Membership")
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipFound: Boolean;
    begin
        if (not MembershipFound) then begin
            Membership.FilterGroup := -1;
            Membership.SetFilter("External Membership No.", '%1', UpperCase(SearchTerm));
            Membership.SetFilter("Customer No.", '%1', UpperCase(SearchTerm));
            Membership.SetFilter("Company Name", '%1', SearchTerm);
            Membership.FilterGroup := 0;

            Membership.SetLoadFields("Entry No.");
            if (Membership.FindSet()) then begin
                repeat
                    MembershipFound := true;
                    Membership.Mark(true);
                until (Membership.Next() = 0);
            end;
        end;

        if (not MembershipFound) then begin
            MemberCard.SetLoadFields("External Card No.", "Membership Entry No.");
            MemberCard.SetFilter("External Card No.", '%1', UpperCase(SearchTerm));
            if (MemberCard.FindSet()) then begin
                repeat
                    if (Membership.Get(MemberCard."Membership Entry No.")) then begin
                        MembershipFound := true;
                        Membership.Mark(true);
                    end;
                until (MemberCard.Next() = 0);
            end;
        end;

        if (not MembershipFound) then begin
            Member.FilterGroup := -1;
            Member.SetFilter("External Member No.", '%1', UpperCase(SearchTerm));
            Member.SetFilter("First Name", '%1', '@' + SearchTerm);
            Member.SetFilter("Last Name", '%1', '@' + SearchTerm);
            Member.SetFilter("E-Mail Address", '%1', LowerCase(ConvertStr(SearchTerm, '@', '?')));
            Member.SetFilter("Phone No.", '%1', SearchTerm);
            Member.SetFilter("Display Name", '%1', SearchTerm);
            Member.FilterGroup := 0;

            Member.SetLoadFields("Entry No.");

            if (Member.FindSet()) then begin
                repeat
                    MembershipRole.SetLoadFields("Membership Entry No.", "Member Entry No.");
                    MembershipRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
                    if (MembershipRole.FindSet()) then begin
                        repeat
                            if (Membership.Get(MembershipRole."Membership Entry No.")) then begin
                                MembershipFound := true;
                                Membership.Mark(true);
                            end;
                        until (MembershipRole.Next() = 0);
                    end;
                until (Member.Next() = 0);
            end;
        end;

        if (not MembershipFound) then begin
            MembershipEntry.SetLoadFields("Membership Entry No.");
            MembershipEntry.SetFilter("Receipt No.", '=%1', UpperCase(SearchTerm));
            if (MembershipEntry.FindSet()) then begin
                repeat
                    if (Membership.Get(MembershipEntry."Membership Entry No.")) then begin
                        MembershipFound := true;
                        Membership.Mark(true);
                    end;
                until (MembershipEntry.Next() = 0);
            end;
        end;

    end;

    local procedure MemberCardSearchWorker(SearchTerm: Text[100]; var MemberCard: Record "NPR MM Member Card")
    var
        Member: Record "NPR MM Member";
        MemberShip: Record "NPR MM Membership";
        MemberCard2: Record "NPR MM Member Card";
        MembershipFound: Boolean;
    begin

        MemberCard.SetLoadFields("Entry No.");

        if (not MembershipFound) then begin
            MemberCard2.FilterGroup := -1;
            MemberCard2.SetFilter("External Card No.", '%1', UpperCase(SearchTerm));
            MemberCard2.FilterGroup := 0;

            MemberCard2.SetLoadFields("Entry No.");
            if (MemberCard2.FindSet()) then begin
                repeat
                    MemberCard.Get(MemberCard2."Entry No.");
                    MemberCard.Mark(true);
                until (MemberCard2.Next() = 0);
            end;
        end;

        if (not MembershipFound) then begin
            Membership.FilterGroup := -1;
            Membership.SetFilter("External Membership No.", '%1', UpperCase(SearchTerm));
            Membership.FilterGroup := 0;

            Membership.SetLoadFields("Entry No.");
            if (Membership.FindSet()) then begin
                MemberCard2.Reset();
                repeat
                    MemberCard2.SetFilter("Membership Entry No.", '=%1', MemberShip."Entry No.");
                    MemberCard2.SetLoadFields("Entry No.");
                    if (MemberCard2.FindSet()) then begin
                        repeat
                            MembershipFound := true;
                            MemberCard.Get(MemberCard2."Entry No.");
                            MemberCard.Mark(true);
                        until (MemberCard2.Next() = 0);
                    end;
                until (Membership.Next() = 0);
            end;
        end;

        if (not MembershipFound) then begin
            Member.FilterGroup := -1;
            Member.SetFilter("External Member No.", '%1', UpperCase(SearchTerm));
            Member.SetFilter("First Name", '%1', '@' + SearchTerm);
            Member.SetFilter("Last Name", '%1', '@' + SearchTerm);
            Member.SetFilter("E-Mail Address", '%1', LowerCase(ConvertStr(SearchTerm, '@', '?')));
            Member.SetFilter("Phone No.", '%1', SearchTerm);
            Member.SetFilter("Display Name", '%1', SearchTerm);
            Member.FilterGroup := 0;

            Member.SetLoadFields("Entry No.");

            if (Member.FindSet()) then begin
                MemberCard2.Reset();
                repeat
                    MemberCard2.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
                    MemberCard2.SetLoadFields("Entry No.");
                    if (MemberCard2.FindSet()) then begin
                        repeat
                            MembershipFound := true;
                            MemberCard.Get(MemberCard2."Entry No.");
                            MemberCard.Mark(true);
                        until (MemberCard2.Next() = 0);
                    end;
                until (Member.Next() = 0);
            end;
        end;
    end;

}