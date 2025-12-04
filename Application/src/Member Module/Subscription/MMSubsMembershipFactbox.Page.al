page 6150897 "NPR MM SubsMembershipFactbox"
{
    Extensible = False;
    Caption = 'Related Memberships Factbox';
    PageType = ListPart;
    SourceTable = "NPR MM MembershipPmtMethodMap";
    UsageCategory = None;
    RefreshOnActivate = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Memberships)
            {
                field(MembershipNo; _Membership."External Membership No.")
                {
                    Caption = 'External Membership No.';
                    ToolTip = 'Specifies the external membership number.';
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    begin
                        ShowMembership();
                    end;

                }
                field(MembershipCode; _Membership."Membership Code")
                {
                    Caption = 'Membership Code';
                    ToolTip = 'Specifies the membership code.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    var
        _Membership: Record "NPR MM Membership";

    trigger OnAfterGetRecord()
    begin
        _Membership.SetLoadFields("External Membership No.", "Membership Code");
        if not _Membership.GetBySystemId(Rec.MembershipId) then
            _Membership.Init();
    end;

    local procedure ShowMembership()
    var
        Membership: Record "NPR MM Membership";
        MembershipCard: Page "NPR MM Membership Card";
    begin
        if not Membership.GetBySystemId(Rec.MembershipId) then
            exit;
        MembershipCard.SetRecord(Membership);
        MembershipCard.Run();
    end;
}
