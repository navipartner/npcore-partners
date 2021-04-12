codeunit 6014677 "NPR Endpoint Send Req. Batch"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created: To be Used as Scheduled task
    // NPR5.30/ANEN/20170227 CASE 267582 Removing call to CheckMaxRequests.
    // NPR5.31/BR  /20170330 CASE 267459 Fix for errors with mutiple updates


    trigger OnRun()
    begin
        //-NPR5.30 [267582]
        //CheckMaxRequests;
        //+NPR5.30 [267582]

        CheckWaitingRequests;
    end;

    local procedure CheckMaxRequests()
    var
        Endpoint: Record "NPR Endpoint";
        EndpointRequestBatch: Record "NPR Endpoint Request Batch";
    begin
        Endpoint.Reset();
        Endpoint.SetRange(Active, true);
        Endpoint.SetFilter("Max. Requests per Batch", '>%1', 0);
        if Endpoint.FindSet() then
            repeat
                EndpointRequestBatch.Reset();
                EndpointRequestBatch.SetCurrentKey("Endpoint Code", "No.");
                EndpointRequestBatch.SetRange("Endpoint Code", Endpoint.Code);
                EndpointRequestBatch.SetRange(Status, EndpointRequestBatch.Status::Collecting);
                //-NPR5.31 [267459]
                //IF EndpointRequestBatch.FindSet() THEN REPEAT
                if EndpointRequestBatch.FindSet(true, true) then
                    repeat
                        //+NPR5.31 [267459]
                        EndpointRequestBatch.CalcFields("No. of Requests");
                        if EndpointRequestBatch."No. of Requests" >= Endpoint."Max. Requests per Batch" then begin
                            EndpointRequestBatch.Validate(Status, EndpointRequestBatch.Status::"Ready to Send");
                            EndpointRequestBatch.Modify(true);
                        end;
                    until EndpointRequestBatch.Next() = 0;
            until Endpoint.Next() = 0;
    end;

    local procedure CheckWaitingRequests()
    var
        Endpoint: Record "NPR Endpoint";
        EndpointRequest: Record "NPR Endpoint Request";
        EndpointRequestBatch: Record "NPR Endpoint Request Batch";
    begin
        //-NPR5.31 [267459]
        EndpointRequestBatch.LockTable();
        //+NPR5.31 [267459]
        Endpoint.Reset();
        Endpoint.SetRange(Active, true);
        Endpoint.SetFilter("Wait to Send", '>%1', 0);
        if Endpoint.FindSet() then
            repeat
                EndpointRequestBatch.Reset();
                EndpointRequestBatch.SetCurrentKey("Endpoint Code", "No.");
                EndpointRequestBatch.SetRange("Endpoint Code", Endpoint.Code);
                EndpointRequestBatch.SetRange(Status, EndpointRequestBatch.Status::Collecting);
                //-NPR5.31 [267459]
                //IF EndpointRequestBatch.FindSet() THEN REPEAT
                if EndpointRequestBatch.FindSet(true, true) then
                    repeat
                        //+NPR5.31 [267459]
                        EndpointRequest.Reset();
                        EndpointRequest.SetRange("Request Batch No.", EndpointRequestBatch."No.");
                        EndpointRequest.FindLast();
                        if (CurrentDateTime - EndpointRequest."Date Created") > Endpoint."Wait to Send" then begin
                            EndpointRequestBatch.Validate(Status, EndpointRequestBatch.Status::"Ready to Send");
                            EndpointRequestBatch.Modify(true);
                        end;
                    until EndpointRequestBatch.Next() = 0;
            until Endpoint.Next() = 0;
    end;

    local procedure DeleteOldRequestbatches()
    var
        Endpoint: Record "NPR Endpoint";
        EndpointRequestBatch: Record "NPR Endpoint Request Batch";
    begin
        Endpoint.Reset();
        Endpoint.SetRange(Active, true);
        Endpoint.SetFilter("Delete Sent Requests After", '>1');
        if Endpoint.FindSet() then
            repeat
                EndpointRequestBatch.Reset();
                EndpointRequestBatch.SetCurrentKey("Endpoint Code", Status);
                EndpointRequestBatch.SetRange("Endpoint Code", Endpoint.Code);
                EndpointRequestBatch.SetRange(Status, EndpointRequestBatch.Status::Sent);
                //-NPR5.31 [267459]
                //IF EndpointRequestBatch.FindSet() THEN REPEAT
                if EndpointRequestBatch.FindSet(true, true) then
                    repeat
                        //+NPR5.31 [267459]
                        if EndpointRequestBatch."Sent Date" <> 0DT then
                            if CurrentDateTime - EndpointRequestBatch."Sent Date" > Endpoint."Delete Sent Requests After" then
                                EndpointRequestBatch.Delete(true);
                    until EndpointRequestBatch.Next() = 0;
            until Endpoint.Next() = 0;
    end;
}

