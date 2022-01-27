codeunit 6150916 "NPR HC Post S.Header"
{
    Access = Internal;
    TableNo = "Sales Header";

    trigger OnRun()
    begin
        SalesHeader.Copy(Rec);
        Code();
        Rec := SalesHeader;
    end;

    var
        SalesHeader: Record "Sales Header";

    local procedure "Code"()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesPostViaJobQueue: Codeunit "Sales Post via Job Queue";
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    SalesHeader.Ship := true;
                    SalesHeader.Invoice := true;
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    SalesHeader.Receive := true;
                    SalesHeader.Invoice := true;
                end
        end;
        SalesHeader."Print Posted Documents" := false;

        SalesSetup.Get();
        if SalesSetup."Post with Job Queue" then
            SalesPostViaJobQueue.EnqueueSalesDoc(SalesHeader)
        else
            CODEUNIT.Run(CODEUNIT::"Sales-Post", SalesHeader);
    end;
}

