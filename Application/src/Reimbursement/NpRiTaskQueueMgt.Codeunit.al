codeunit 6151106 "NPR NpRi Task Queue Mgt."
{
    TableNo = "NPR Task Line";

    trigger OnRun()
    begin
        if Rec.GetParameterBool('RUN_DATA_COLLECTIONS') then
            RunDataCollections();
        if Rec.GetParameterBool('RUN_REIMBURSEMENTS') then
            RunReimbursements();
    end;

    local procedure RunDataCollections()
    var
        NpRiReimbursement: Record "NPR NpRi Reimbursement";
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
    begin
        NpRiReimbursement.SetFilter("Party Type", '<>%1', '');
        NpRiReimbursement.SetFilter("Party No.", '<>%1', '');
        NpRiReimbursement.SetFilter("Template Code", '<>%1', '');
        if not NpRiReimbursement.FindSet then
            exit;

        repeat
            Clear(NpRiDataCollectionMgt);
            if NpRiDataCollectionMgt.Run(NpRiReimbursement) then;
            Commit;
        until NpRiReimbursement.Next = 0;
    end;

    local procedure RunReimbursements()
    var
        NpRiReimbursement: Record "NPR NpRi Reimbursement";
        NpRiReimbursementMgt: Codeunit "NPR NpRi Reimbursement Mgt.";
    begin
        NpRiReimbursement.SetFilter("Party Type", '<>%1', '');
        NpRiReimbursement.SetFilter("Party No.", '<>%1', '');
        NpRiReimbursement.SetFilter("Template Code", '<>%1', '');
        NpRiReimbursement.SetFilter("Reimbursement Date", '<>%1&>=%2', 0D, Today);
        NpRiReimbursement.SetFilter("Posting Date", '<>%1', 0D);
        if not NpRiReimbursement.FindSet then
            exit;

        repeat
            Clear(NpRiReimbursementMgt);
            if NpRiReimbursementMgt.Run(NpRiReimbursement) then;
            Commit;
        until NpRiReimbursement.Next = 0;
    end;
}

