codeunit 6014676 "NPR NpXml Value Endp. Batch"
{
    Access = Internal;
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        NpXmlTemplate.Get(Rec."Xml Template Code");
        if NpXmlTemplate."Table No." = DATABASE::"NPR Endpoint Request Batch" then begin
            SetEndPointToProcessed(Rec);
        end;
    end;

    var
        EndpointRequestBatch: Record "NPR Endpoint Request Batch";

    local procedure SetEndPointToProcessed(var NpXmlCustomValueBuffer: Record "NPR NpXml Custom Val. Buffer")
    var
        RecRef: RecordRef;
    begin
        EndpointRequestBatch.LockTable();
        Clear(RecRef);
        RecRef.Open(NpXmlCustomValueBuffer."Table No.");
        RecRef.SetPosition(NpXmlCustomValueBuffer."Record Position");
        if not RecRef.Find() then
            exit;
        RecRef.SetTable(EndpointRequestBatch);
        if EndpointRequestBatch.Find() then begin
            if EndpointRequestBatch.Status = EndpointRequestBatch.Status::"Ready to Send" then begin
                EndpointRequestBatch.Validate(Status, EndpointRequestBatch.Status::Sent);
                EndpointRequestBatch.Modify(true);
                Commit();
            end;
        end;
        Commit();
    end;
}

