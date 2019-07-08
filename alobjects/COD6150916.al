codeunit 6150916 "HC Post Sales Header"
{
    // NPR5.47/JDH /20181015 CASE 325323 Posting of Sales Header From HC module

    TableNo = "Sales Header";

    trigger OnRun()
    begin
        SalesHeader.Copy(Rec);
        Code;
        Rec := SalesHeader;
    end;

    var
        SalesHeader: Record "Sales Header";

    local procedure "Code"()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesPostViaJobQueue: Codeunit "Sales Post via Job Queue";
        SalesPost: Codeunit "Sales-Post";
    begin
        with SalesHeader do begin
          case "Document Type" of
            "Document Type"::Order:
              begin
                Ship := true;
                Invoice := true;
              end;
            "Document Type"::"Return Order":
              begin
                Receive := true;
                Invoice := true;
              end
          end;
          "Print Posted Documents" := false;

          SalesSetup.Get;
          if SalesSetup."Post with Job Queue" then
            SalesPostViaJobQueue.EnqueueSalesDoc(SalesHeader)
          else
            CODEUNIT.Run(CODEUNIT::"Sales-Post",SalesHeader);
        end;
    end;
}

