codeunit 6060101 "NPR Data Cleanup GCVI"
{
    // NPR4.10/JC/20150318  CASE 207094 Data collect for Customer, Vendor and Item
    // NPR5.23/JC/20160330  CASE 237816 Extend with G/L account & rename


    trigger OnRun()
    begin
        if GuiAllowed then
            if not Confirm(DelConfirmTxt) then
                exit;


        DataCleanupCVI.SetCurrentKey("Cleanup Action", "Approve Delete", IsError, IsDeleted, Retries);
        DataCleanupCVI.SetRange("Cleanup Action", DataCleanupCVI."Cleanup Action"::Delete);//-NPR5.23
        DataCleanupCVI.SetRange("Approve Delete", true);
        DataCleanupCVI.SetRange(IsError, false);
        DataCleanupCVI.SetRange(IsDeleted, false);
        DataCleanupCVI.SetFilter(Retries, '<10');
        if DataCleanupCVI.FindSet(false, false) then
            repeat
                DataCleanupCVI2.Get(DataCleanupCVI."Cleanup Action", DataCleanupCVI.Type, DataCleanupCVI."No.");//-NPR5.23

                if not CODEUNIT.Run(CODEUNIT::"NPR Data Cleanup GCVI Line", DataCleanupCVI2) then begin
                    DataCleanupCVI2.Status := GetLastErrorText;
                    DataCleanupCVI2.IsError := true;
                end else begin
                    DataCleanupCVI2.Status := 'SUCCESS';
                    DataCleanupCVI2.IsDeleted := true;
                    DataCleanupCVI2.IsProcessed := true;//-NPR5.23
                    DataCleanupCVI2.Success := true;
                end;
                DataCleanupCVI2.Retries := DataCleanupCVI2.Retries + 1;
                DataCleanupCVI2.Modify(true);
                Commit;
            until DataCleanupCVI.Next = 0;


        //-NPR5.23
        DataCleanupCVI.SetCurrentKey("Cleanup Action", "Approve Rename", IsError, IsRenamed, Retries); //-NPR5.23
        DataCleanupCVI.SetRange("Cleanup Action", DataCleanupCVI."Cleanup Action"::Rename);
        DataCleanupCVI.SetRange("Approve Rename", true);
        DataCleanupCVI.SetRange(IsError, false);
        DataCleanupCVI.SetRange(IsRenamed, false);
        DataCleanupCVI.SetFilter(Retries, '<10');
        if DataCleanupCVI.FindSet(false, false) then
            repeat
                DataCleanupCVI2.Get(DataCleanupCVI."Cleanup Action", DataCleanupCVI.Type, DataCleanupCVI."No.");//-NPR5.23

                if not CODEUNIT.Run(CODEUNIT::"NPR Data Cleanup GCVI Line", DataCleanupCVI2) then begin
                    DataCleanupCVI2.Status := GetLastErrorText;
                    DataCleanupCVI2.IsError := true;
                end else begin
                    DataCleanupCVI2.Status := 'SUCCESS';
                    DataCleanupCVI2.IsRenamed := true;
                    DataCleanupCVI2.IsProcessed := true;//-NPR5.23
                    DataCleanupCVI2.Success := true;
                end;
                DataCleanupCVI2.Retries := DataCleanupCVI2.Retries + 1;
                DataCleanupCVI2.Modify(true);
                Commit;
            until DataCleanupCVI.Next = 0;
        //+NPR5.23

        Message(DoneTxt);
    end;

    var
        DataCleanupCVI: Record "NPR Data Cleanup GCVI";
        DelConfirmTxt: Label 'Do you want to process(delete/rename) entries in Data Cleanup table?';
        DoneTxt: Label 'Task completed !';
        DataCleanupCVI2: Record "NPR Data Cleanup GCVI";
}

