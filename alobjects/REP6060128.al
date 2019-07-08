report 6060128 "MM Sync. Community Customers"
{
    // MM1.10/TSA/20160404  CASE 233948 Report to create or update membership to customer
    // MM1.17/TSA/20161121  CASE 258982 Changed how partially created business relations was corrected

    Caption = 'Sync. Community Customers';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Community;"MM Member Community")
        {
            RequestFilterFields = "Code";

            trigger OnAfterGetRecord()
            begin

                if (Community."Membership to Cust. Rel.") then
                  CreateMissingMembershipCustomers (Community.Code);
            end;

            trigger OnPreDataItem()
            var
                UpdateWindowEvery: Integer;
            begin
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        TEXT001: Label 'Membership Code: #1################## @2@@@@@@@@@@@@@@@@@@';

    local procedure CreateMissingMembershipCustomers(CommunityCode: Code[20])
    var
        MembershipSetup: Record "MM Membership Setup";
        Membership: Record "MM Membership";
        MembershipManagement: Codeunit "MM Membership Management";
        Window: Dialog;
        CurrentRow: Integer;
        MaxRow: Integer;
        UpdateWindowEvery: Integer;
    begin

        MembershipSetup.SetFilter ("Community Code", '=%1', CommunityCode);
        if (MembershipSetup.FindSet ()) then begin
          MembershipSetup.TestField ("Customer Config. Template Code");
          Window.Open (TEXT001);
          repeat
            Membership.SetFilter ("Membership Code", '=%1', MembershipSetup.Code);
            Membership.SetFilter (Blocked, '=%1', false);
            MaxRow := Membership.Count();
            UpdateWindowEvery := (MaxRow div 100) + 1;
            CurrentRow := 0;
            Window.Update (1, MembershipSetup.Code);

            if (Membership.FindSet ()) then begin
              repeat
                //IF (Membership."Customer No." = '') THEN BEGIN
                  MembershipManagement.SynchronizeCustomerAndContact (Membership."Entry No.");
                //END;

                if (CurrentRow mod UpdateWindowEvery = 0) then
                  Window.Update (2, Round (CurrentRow/MaxRow*10000,1));
                CurrentRow += 1;

              until (Membership.Next () = 0);
            end;

          until (MembershipSetup.Next () = 0);
          Window.Close ();
        end;
    end;
}

