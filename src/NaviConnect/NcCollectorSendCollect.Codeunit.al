codeunit 6151529 "NPR Nc Collector Send Collect."
{
    // NC2.01 /BR  /20160909  CASE 250447 NaviConnect: Object created
    // NC2.04 /BR  /20170510  CASE 274524 Call cleanup function


    trigger OnRun()
    begin
        CheckMaxLines;
        CheckWaitingLines;
        //-NC2.04
        DeleteOldCollections;
        //+NC2.04
    end;

    local procedure CheckMaxLines()
    var
        NcCollector: Record "NPR Nc Collector";
        NcCollection: Record "NPR Nc Collection";
    begin
        NcCollector.Reset;
        NcCollector.SetRange(Active, true);
        NcCollector.SetFilter("Max. Lines per Collection", '>%1', 0);
        if NcCollector.FindSet then
            repeat
                NcCollection.Reset;
                NcCollection.SetCurrentKey("Collector Code", "No.");
                NcCollection.SetRange("Collector Code", NcCollector.Code);
                NcCollection.SetRange(Status, NcCollection.Status::Collecting);
                if NcCollection.FindSet then
                    repeat
                        NcCollection.CalcFields("No. of Lines");
                        if NcCollection."No. of Lines" >= NcCollector."Max. Lines per Collection" then begin
                            NcCollection.Validate(Status, NcCollection.Status::"Ready to Send");
                            NcCollection.Modify(true);
                        end;
                    until NcCollection.Next = 0;
            until NcCollection.Next = 0;
    end;

    local procedure CheckWaitingLines()
    var
        NcCollector: Record "NPR Nc Collector";
        NcCollectionLine: Record "NPR Nc Collection Line";
        NcCollection: Record "NPR Nc Collection";
    begin
        NcCollector.Reset;
        NcCollector.SetRange(Active, true);
        NcCollector.SetFilter("Wait to Send", '>%1', 0);
        if NcCollector.FindSet then
            repeat
                NcCollection.Reset;
                NcCollection.SetCurrentKey("Collector Code", "No.");
                NcCollection.SetRange("Collector Code", NcCollector.Code);
                NcCollection.SetRange(Status, NcCollection.Status::Collecting);
                if NcCollection.FindSet then
                    repeat
                        NcCollectionLine.Reset;
                        NcCollectionLine.SetRange("Collection No.", NcCollection."No.");
                        NcCollectionLine.FindLast;
                        if (CurrentDateTime - NcCollectionLine."Date Created") > NcCollector."Wait to Send" then begin
                            NcCollection.Validate(Status, NcCollection.Status::"Ready to Send");
                            NcCollection.Modify(true);
                        end;
                    until NcCollection.Next = 0;
            until NcCollector.Next = 0;
    end;

    local procedure DeleteOldCollections()
    var
        NcCollector: Record "NPR Nc Collector";
        NcCollectionLine: Record "NPR Nc Collection Line";
        NcCollection: Record "NPR Nc Collection";
    begin
        NcCollector.Reset;
        NcCollector.SetRange(Active, true);
        NcCollector.SetFilter("Delete Sent Collections After", '>1');
        if NcCollector.FindSet then
            repeat
                NcCollection.Reset;
                NcCollection.SetCurrentKey("Collector Code", Status);
                NcCollection.SetRange("Collector Code", NcCollector.Code);
                NcCollection.SetRange(Status, NcCollection.Status::Sent);
                if NcCollection.FindSet then
                    repeat
                        if NcCollection."Sent Date" <> 0DT then
                            if CurrentDateTime - NcCollection."Sent Date" > NcCollector."Delete Sent Collections After" then
                                NcCollection.Delete(true);
                    until NcCollection.Next = 0;
            until NcCollector.Next = 0;
    end;
}

