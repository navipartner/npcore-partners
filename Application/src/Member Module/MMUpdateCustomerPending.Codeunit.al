codeunit 6248286 "NPR MM Update Customer Pending"
{
    Access = Internal;
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        RecRef: RecordRef;
        PendingCustomerUpdate: Record "NPR MM Pending Customer Update";
        Customer: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
    begin
        PendingCustomerUpdate.SetRange("Valid From Date", WorkDate());
        PendingCustomerUpdate.SetRange("Update Processed", false);
        if PendingCustomerUpdate.FindSet(true) then
            repeat
                if Customer.Get(PendingCustomerUpdate."Customer No.") then
                    if ConfigTemplateHeader.Get(PendingCustomerUpdate."Customer Config. Template Code") then begin
                        RecRef.GetTable(Customer);
                        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                        RecRef.SetTable(Customer);
                        Customer.Modify(true);
                        PendingCustomerUpdate."Update Processed" := true;
                        PendingCustomerUpdate.Modify();
                    end;
            until PendingCustomerUpdate.Next() = 0;
    end;

}

