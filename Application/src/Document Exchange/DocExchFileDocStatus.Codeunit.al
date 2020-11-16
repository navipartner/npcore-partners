codeunit 6059934 "NPR Doc.Exch.File: Doc.Status"
{
    // NPR5.27/TJ/20160929 CASE 248831 Updated calling of DocExchFileMgt.UpdateSalesDoc as parameters have been changed

    TableNo = "NPR Task Line";

    trigger OnRun()
    begin
        CheckPostedInvoices();
    end;

    local procedure CheckPostedInvoices()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        DocExchFileMgt: Codeunit "NPR Doc. Exch. File Mgt.";
        RecordRef: RecordRef;
        DocExchPath: Record "NPR Doc. Exchange Path";
    begin
        with SalesInvHeader do begin
            SetRange("NPR Doc. Exch. Exported", true);
            SetFilter("NPR Doc. Exch. Fr.work Status", '<>%1', "NPR Doc. Exch. Fr.work Status"::"Delivered to Recepient");
            if FindSet then
                repeat
                    RecordRef.Get("NPR Doc. Exch. Setup Path Used");

                    //-NPR5.27 [248831]
                    //      PostedSalesDoc := SalesInvHeader;
                    RecordRef.SetTable(DocExchPath);
                    RecordRef.GetTable(SalesInvHeader);
                    //+NPR5.27 [248831]

                    DocExchFileMgt.UpdateSalesDoc(RecordRef, DocExchPath, false, 1);
                until Next = 0;
        end;
    end;
}

