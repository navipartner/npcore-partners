codeunit 6248286 "NPR MM Update Customer Pending"
{
    Access = Internal;
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        PendingCustomerUpdate: Record "NPR MM Pending Customer Update";
    begin
        PendingCustomerUpdate.SetCurrentKey("Valid From Date");
        PendingCustomerUpdate.SetFilter("Valid From Date", '=%1', WorkDate());
        PendingCustomerUpdate.SetFilter("Update Processed", '=%1', false);
        if PendingCustomerUpdate.FindSet(true) then begin
            repeat
                ApplyUpdate(PendingCustomerUpdate);
                Commit();
            until (PendingCustomerUpdate.Next() = 0);
        end;
    end;

    internal procedure ApplyUpdate(PendingCustomerUpdate: Record "NPR MM Pending Customer Update")
    var
        RecRef: RecordRef;
        Customer: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        Membership: Record "NPR MM Membership";
    begin
        Membership.SetLoadFields("Membership Code");
        if (Membership.Get(PendingCustomerUpdate.MembershipEntryNo)) then
            if ((Membership."Membership Code" <> PendingCustomerUpdate.MembershipCode) and (PendingCustomerUpdate.MembershipCode <> '')) then begin
                Membership."Membership Code" := PendingCustomerUpdate.MembershipCode;
                Membership.Modify();
            end;

        if (Customer.Get(PendingCustomerUpdate."Customer No.")) then
            if ConfigTemplateHeader.Get(PendingCustomerUpdate."Customer Config. Template Code") then begin
                RecRef.GetTable(Customer);
                ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                RecRef.SetTable(Customer);
                Customer.Modify(true);
            end;

        PendingCustomerUpdate."Update Processed" := true;
        PendingCustomerUpdate.Modify();
    end;
}

