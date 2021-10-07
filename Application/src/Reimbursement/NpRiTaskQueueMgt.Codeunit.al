codeunit 6151106 "NPR NpRi Task Queue Mgt."
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
    begin
        // Expected "Parmeter String" like: RUN_DATA_COLLECTIONS,RUN_REIMBURSEMENTS
        JQParamStrMgt.Parse(Rec."Parameter String");

        if JQParamStrMgt.GetParamValueAsBoolean(ParamRunDataCollections()) then
            RunDataCollections();

        if JQParamStrMgt.GetParamValueAsBoolean(ParamRunReimbursements()) then
            RunReimbursements();
    end;

    procedure ParamRunDataCollections(): Text
    begin
        exit('RUN_DATA_COLLECTIONS');
    end;

    procedure ParamRunReimbursements(): Text
    begin
        exit('RUN_REIMBURSEMENTS');
    end;

    local procedure RunDataCollections()
    var
        NpRiReimbursement: Record "NPR NpRi Reimbursement";
        NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
    begin
        NpRiReimbursement.SetFilter("Party Type", '<>%1', '');
        NpRiReimbursement.SetFilter("Party No.", '<>%1', '');
        NpRiReimbursement.SetFilter("Template Code", '<>%1', '');
        if NpRiReimbursement.FindSet(true) then
            repeat
                Clear(NpRiDataCollectionMgt);
                if NpRiDataCollectionMgt.Run(NpRiReimbursement) then;
                Commit();
            until NpRiReimbursement.Next() = 0;
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
        if NpRiReimbursement.FindSet(true) then
            repeat
                Clear(NpRiReimbursementMgt);
                if NpRiReimbursementMgt.Run(NpRiReimbursement) then;
                Commit();
            until NpRiReimbursement.Next() = 0;
    end;
}