codeunit 6151106 "NpRi Task Queue Mgt."
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    TableNo = "Task Line";

    trigger OnRun()
    begin
        if GetParameterBool('RUN_DATA_COLLECTIONS') then
          RunDataCollections();
        if GetParameterBool('RUN_REIMBURSEMENTS') then
          RunReimbursements();
    end;

    local procedure RunDataCollections()
    var
        NpRiReimbursement: Record "NpRi Reimbursement";
        NpRiDataCollectionMgt: Codeunit "NpRi Data Collection Mgt.";
    begin
        NpRiReimbursement.SetFilter("Party Type",'<>%1','');
        NpRiReimbursement.SetFilter("Party No.",'<>%1','');
        NpRiReimbursement.SetFilter("Template Code",'<>%1','');
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
        NpRiReimbursement: Record "NpRi Reimbursement";
        NpRiReimbursementMgt: Codeunit "NpRi Reimbursement Mgt.";
    begin
        NpRiReimbursement.SetFilter("Party Type",'<>%1','');
        NpRiReimbursement.SetFilter("Party No.",'<>%1','');
        NpRiReimbursement.SetFilter("Template Code",'<>%1','');
        NpRiReimbursement.SetFilter("Reimbursement Date",'<>%1&>=%2',0D,Today);
        NpRiReimbursement.SetFilter("Posting Date",'<>%1',0D);
        if not NpRiReimbursement.FindSet then
          exit;

        repeat
          Clear(NpRiReimbursementMgt);
          if NpRiReimbursementMgt.Run(NpRiReimbursement) then;
          Commit;
        until NpRiReimbursement.Next = 0;
    end;
}

