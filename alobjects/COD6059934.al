codeunit 6059934 "Doc. Exch. File - Doc. Status"
{
    // NPR5.27/TJ/20160929 CASE 248831 Updated calling of DocExchFileMgt.UpdateSalesDoc as parameters have been changed

    TableNo = "Task Line";

    trigger OnRun()
    begin
        CheckPostedInvoices();
    end;

    local procedure CheckPostedInvoices()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        DocExchFileMgt: Codeunit "Doc. Exch. File Mgt.";
        RecordRef: RecordRef;
        DocExchPath: Record "Doc. Exchange Path";
    begin
        with SalesInvHeader do begin
          SetRange("Doc. Exch. Exported",true);
          SetFilter("Doc. Exch. Framework Status",'<>%1',"Doc. Exch. Framework Status"::"Delivered to Recepient");
          if FindSet then
            repeat
              RecordRef.Get("Doc. Exch. Setup Path Used");

        //-NPR5.27 [248831]
        //      PostedSalesDoc := SalesInvHeader;
              RecordRef.SetTable(DocExchPath);
              RecordRef.GetTable(SalesInvHeader);
        //+NPR5.27 [248831]

              DocExchFileMgt.UpdateSalesDoc(RecordRef,DocExchPath,false,1);
            until Next = 0;
        end;
    end;
}

