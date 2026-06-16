#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248201 "NPR DigNotif Membership Impl" implements "NPR IDigNotifAssetProcessor"
{
    Access = Internal;

    procedure ProcessAsset(var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary; var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary; var Context: Codeunit "NPR DigNotif Manifest Context")
    begin
        if TempHeaderBuffer."Document Type" = TempHeaderBuffer."Document Type"::"Ecom Sales Document" then
            ProcessEcomMembershipAssets(TempHeaderBuffer, TempLineBuffer, Context)
        else
            ProcessPostedDocMembershipAssets(TempHeaderBuffer, TempLineBuffer, Context);
    end;

    local procedure ProcessEcomMembershipAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        var Context: Codeunit "NPR DigNotif Manifest Context")
    var
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        Membership: Record "NPR MM Membership";
    begin
        // Link rows are guaranteed: every membership op writes one.
        EcomSalesMembershipLink.SetCurrentKey("Source System Id", "Source Line System Id");
        EcomSalesMembershipLink.SetRange("Source System Id", TempHeaderBuffer."Source Document Id");
        EcomSalesMembershipLink.SetRange("Source Line System Id", TempLineBuffer."Source Line System Id");
        if EcomSalesMembershipLink.FindSet() then
            repeat
                if Membership.GetBySystemId(EcomSalesMembershipLink."Membership System Id") then
                    TryAddMembershipAsset(Membership, Context);
            until EcomSalesMembershipLink.Next() = 0;
    end;

    local procedure ProcessPostedDocMembershipAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        var Context: Codeunit "NPR DigNotif Manifest Context")
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
    begin
        // Match by order doc no + item no, not line no.: "Document Line No." is stamped at order
        // import, not posting, so it won't align with posted lines.
        if TempHeaderBuffer."Shopify Order ID" <> '' then
            MembershipEntry.SetRange("Document No.", TempHeaderBuffer."Shopify Order ID")
        else
            MembershipEntry.SetRange("Document No.", TempHeaderBuffer."External Order No.");
        MembershipEntry.SetRange("Item No.", TempLineBuffer."No.");
        MembershipEntry.SetRange(Blocked, false);
        if not MembershipEntry.FindSet() then
            exit;

        repeat
            if Membership.Get(MembershipEntry."Membership Entry No.") then
                TryAddMembershipAsset(Membership, Context);
        until MembershipEntry.Next() = 0;
    end;

    local procedure TryAddMembershipAsset(
        Membership: Record "NPR MM Membership";
        var Context: Codeunit "NPR DigNotif Manifest Context")
    var
        MemberNotificSetup: Record "NPR MM Member Notific. Setup";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        // A membership purchased once must appear once across the whole document.
        if Context.AlreadyProcessed(Membership) then
            exit;

        if not FindWelcomeManifestSetup(Membership, MemberNotificSetup) then
            exit;
        if MemberNotificSetup.ManifestAsset = MemberNotificSetup.ManifestAsset::NONE then
            exit;
        if MemberNotificSetup.NPDesignerTemplateId = '' then
            exit;

        case MemberNotificSetup.ManifestAsset of
            MemberNotificSetup.ManifestAsset::MEMBERSHIP:
                begin
                    NPDesignerManifestFacade.AddAssetToManifest(
                        Context.ManifestId(), Database::"NPR MM Membership", Membership.SystemId,
                        Membership."External Membership No.", MemberNotificSetup.NPDesignerTemplateId);
                    Context.RegisterAsset();
                end;
            MemberNotificSetup.ManifestAsset::MEMBER:
                if ResolveMembershipMember(Membership, Member) then begin
                    NPDesignerManifestFacade.AddAssetToManifest(
                        Context.ManifestId(), Database::"NPR MM Member", Member.SystemId,
                        Member."External Member No.", MemberNotificSetup.NPDesignerTemplateId);
                    Context.RegisterAsset();
                end;
            MemberNotificSetup.ManifestAsset::MEMBERSHIP_CARD:
                if ResolveMembershipCard(Membership, MemberCard) then begin
                    NPDesignerManifestFacade.AddAssetToManifest(
                        Context.ManifestId(), Database::"NPR MM Member Card", MemberCard.SystemId,
                        MemberCard."External Card No.", MemberNotificSetup.NPDesignerTemplateId);
                    Context.RegisterAsset();
                end;
        end;
    end;

    local procedure FindWelcomeManifestSetup(
        Membership: Record "NPR MM Membership";
        var MemberNotificSetup: Record "NPR MM Member Notific. Setup"): Boolean
    begin
        MemberNotificSetup.SetLoadFields(ManifestAsset, NPDesignerTemplateId);
        MemberNotificSetup.SetRange(Type, MemberNotificSetup.Type::WELCOME);
        MemberNotificSetup.SetRange("Community Code", Membership."Community Code");
        MemberNotificSetup.SetRange("Membership Code", Membership."Membership Code");
        exit(MemberNotificSetup.FindFirst());
    end;

    local procedure ResolveMembershipMember(
        Membership: Record "NPR MM Membership";
        var Member: Record "NPR MM Member"): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        // Representative member: first non-blocked ADMIN; fallback first non-blocked non-anonymous role.
        MembershipRole.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipRole.SetRange(Blocked, false);
        MembershipRole.SetRange("Member Role", MembershipRole."Member Role"::ADMIN);
        if not MembershipRole.FindFirst() then begin
            MembershipRole.SetRange("Member Role");
            MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);
            if not MembershipRole.FindFirst() then
                exit(false);
        end;
        exit(Member.Get(MembershipRole."Member Entry No."));
    end;

    local procedure ResolveMembershipCard(
        Membership: Record "NPR MM Membership";
        var MemberCard: Record "NPR MM Member Card"): Boolean
    var
        Member: Record "NPR MM Member";
    begin
        // The newest non-blocked card of the membership's representative member.
        if not ResolveMembershipMember(Membership, Member) then
            exit(false);
        MemberCard.SetCurrentKey("Entry No.");
        MemberCard.SetRange("Membership Entry No.", Membership."Entry No.");
        MemberCard.SetRange("Member Entry No.", Member."Entry No.");
        MemberCard.SetRange(Blocked, false);
        exit(MemberCard.FindLast());
    end;
}
#endif
