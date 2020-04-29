codeunit 6014676 "NpXml Value Endpoint Batch"
{
    // NPR5.23/BR/20160518      CASE 237658 Object created: To be Used as Custom Codeunit in Table Npxml Element
    // NPR5.23.03/BR/20160621   CASE 242337 Code cleaned and restructured
    // NPR5.23.03/MHA/20160726  CASE 242557 Magento reference updated according to NC2.00
    // NPR5.31/BR/20170330      CASE 267459 Fix for errors with mutiple updates

    TableNo = "NpXml Custom Value Buffer";

    trigger OnRun()
    var
        NpXmlTemplate: Record "NpXml Template";
        NpXmlElement: Record "NpXml Element";
    begin
        NpXmlTemplate.Get("Xml Template Code");
        if NpXmlTemplate."Table No." = DATABASE::"Endpoint Request Batch" then begin
         SetEndPointToProcessed(Rec);
        end;
    end;

    var
        EndpointRequestBatch: Record "Endpoint Request Batch";

    local procedure SetEndPointToProcessed(var NpXmlCustomValueBuffer: Record "NpXml Custom Value Buffer")
    var
        RecRef: RecordRef;
    begin
        //-NPR5.31 [267459]
        EndpointRequestBatch.LockTable;
        //+NPR5.31 [267459]
        //-NPR5.23.03
        Clear(RecRef);
        RecRef.Open(NpXmlCustomValueBuffer."Table No.");
        RecRef.SetPosition(NpXmlCustomValueBuffer."Record Position");
        if not  RecRef.Find then
          exit;
        RecRef.SetTable(EndpointRequestBatch);
        if EndpointRequestBatch.Find then begin
          if EndpointRequestBatch.Status = EndpointRequestBatch.Status::"Ready to Send" then begin
            EndpointRequestBatch.Validate(Status,EndpointRequestBatch.Status::Sent);
            EndpointRequestBatch.Modify(true);
            Commit;
          end;
        end;
        //+NPR5.23.03
        //-NPR5.31 [267459]
        Commit;
        //+NPR5.31 [267459]
    end;
}

