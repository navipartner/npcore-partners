codeunit 6059768 "NaviDocs Management TQ"
{
    // NPR5.23/THRO/20160601 CASE 236043 Changed to use Task queue.
    //                                   Removed Posting functionality
    // NPR5.26/THRO/20160810 CASE 248662 Let Handling profile determine what to handle
    // NPR5.30/THRO/20170209 CASE 243998 CleanupNaviDocs function added

    TableNo = "Task Line";

    trigger OnRun()
    var
        NaviDocsSetup: Record "NaviDocs Setup";
    begin
        //-NPR5.23 [236043]
        // IF NaviDocsSetup.GET AND NaviDocsSetup."Enable NaviDocs" AND NaviDocsSetup."Enable NAS" THEN BEGIN
        //  IF NaviDocsSetup."Enable Posting Management" THEN
        //    PostManageNaviDocs();
        //  IF NaviDocsSetup."Enable Document Management" THEN
        //    DocManageNaviDocs();
        // END;
        //-NPR5.26 [248662]
        //IF NaviDocsSetup.GET AND NaviDocsSetup."Enable NaviDocs" AND NaviDocsSetup."Enable Document Management" THEN
        if NaviDocsSetup.Get and NaviDocsSetup."Enable NaviDocs" then
        //+NPR5.26 [248662]
          DocManageNaviDocs;
        //+NPR5.23 [236043]
        //-NPR5.30 [243998]
        CleanupNaviDocs;
        //+NPR5.30 [243998]
    end;

    procedure DocManageNaviDocs()
    var
        NaviDocsSetup: Record "NaviDocs Setup";
        NaviDocsHandlingProfile: Record "NaviDocs Handling Profile";
        NaviDocsEntry: Record "NaviDocs Entry";
        NaviDocsEntry2: Record "NaviDocs Entry";
        NaviDocsMgt: Codeunit "NaviDocs Management";
    begin
        //-NPR5.30 [243998]
        if not NaviDocsSetup.Get then
          exit;
        if not NaviDocsSetup."Enable NaviDocs" then
          exit;
        //+NPR5.30 [243998]

        NaviDocsEntry.Reset;
        NaviDocsEntry.SetCurrentKey(Status);
        NaviDocsEntry.SetRange(Status,0,1);
        //-NPR5.26 [248662]
        //NaviDocsEntry.SETRANGE(Type,NaviDocsEntry.Type::"2");
        //NaviDocsEntry.SETRANGE("Document Handling Option",Customer."Document Processing"::Email);
        NaviDocsHandlingProfile.SetRange("Handle by NAS",true);
        if NaviDocsHandlingProfile.FindSet then
          repeat
            NaviDocsEntry.SetRange("Document Handling Profile",NaviDocsHandlingProfile.Code);
        //+NPR5.26 [248662]
            NaviDocsEntry.SetFilter("Processed Qty.",'<%1',NaviDocsSetup."Max Retry Qty");
            if NaviDocsEntry.FindSet(true) then
              repeat
                NaviDocsEntry2.Copy(NaviDocsEntry);
                NaviDocsMgt.Run(NaviDocsEntry2);
                Commit;
              until NaviDocsEntry.Next = 0;
        //-NPR5.26 [248662]
          until NaviDocsHandlingProfile.Next = 0;
        //+NPR5.26 [248662]
    end;

    local procedure CleanupNaviDocs()
    var
        NaviDocsSetup: Record "NaviDocs Setup";
        NaviDocsEntry: Record "NaviDocs Entry";
        DeleteLogsBeforeDate: Date;
    begin
        //-NPR5.30 [243998]
        if not NaviDocsSetup.Get then
          exit;
        if NaviDocsSetup."Keep Log for" = 0 then
          exit;
        DeleteLogsBeforeDate := DT2Date(CreateDateTime(Today,000000T) - NaviDocsSetup."Keep Log for");
        NaviDocsEntry.Reset;
        NaviDocsEntry.SetFilter("Insert Date",'<%1',DeleteLogsBeforeDate);
        if NaviDocsEntry.FindSet then
          repeat
            NaviDocsEntry.Delete(true);
          until NaviDocsEntry.Next = 0;
        //+NPR5.30 [243998]
    end;
}

