report 6060128 "NPR MM Sync. Community Cust."
{
    Caption = 'Sync. Community Customers';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;

    dataset
    {
        dataitem(Community; "NPR MM Member Community")
        {
            RequestFilterFields = "Code";

            trigger OnAfterGetRecord()
            begin

                if (Community."Membership to Cust. Rel.") then
                    CreateMissingMembershipCustomers(Community.Code);
            end;

        }
    }
    var
        MembershipCodeLbl: Label 'Membership Code: #1################## @2@@@@@@@@@@@@@@@@@@';

    local procedure CreateMissingMembershipCustomers(CommunityCode: Code[20])
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Window: Dialog;
        CurrentRow: Integer;
        MaxRow: Integer;
        UpdateWindowEvery: Integer;
    begin

        MembershipSetup.SetFilter("Community Code", '=%1', CommunityCode);
        if (MembershipSetup.FindSet()) then begin
            MembershipSetup.TestField("Customer Config. Template Code");
            Window.Open(MembershipCodeLbl);
            repeat
                Membership.SetFilter("Membership Code", '=%1', MembershipSetup.Code);
                Membership.SetFilter(Blocked, '=%1', false);
                MaxRow := Membership.Count();
                UpdateWindowEvery := (MaxRow div 100) + 1;
                CurrentRow := 0;
                Window.Update(1, MembershipSetup.Code);

                if (Membership.FindSet()) then
                    repeat
                        MembershipManagement.SynchronizeCustomerAndContact(Membership."Entry No.");
                        if (CurrentRow mod UpdateWindowEvery = 0) then
                            Window.Update(2, Round(CurrentRow / MaxRow * 10000, 1));
                        CurrentRow += 1;
                    until (Membership.Next() = 0);
            until (MembershipSetup.Next() = 0);
            Window.Close();
        end;
    end;
}

