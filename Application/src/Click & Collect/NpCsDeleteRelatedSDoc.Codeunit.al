codeunit 6151211 "NPR NpCs Delete Related S.Doc."
{
    Access = Internal;
    TableNo = "NPR NpCs Document";

    trigger OnRun()
    begin
        DeleteRelatedSalesHeader(Rec);
    end;

    local procedure DeleteRelatedSalesHeader(NpCsDocument: Record "NPR NpCs Document")
    var
        SalesHeader: Record "Sales Header";
        MustBePostedLbl: Label 'Sales %1 %2 must be posted when %3 = %4';
    begin
        if not SalesHeader.Get(NpCsDocument."Document Type", NpCsDocument."Document No.") then
            exit;

        case NpCsDocument."Bill via" of
            NpCsDocument."Bill via"::POS:
                SalesHeader.Delete(true);

            NpCsDocument."Bill via"::"Sales Document":
                begin
                    if (NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Delivered) and NpCsDocument."Store Stock" then
                        Error(MustBePostedLbl,
                            NpCsDocument."Document Type", NpCsDocument."Document No.", NpCsDocument.FieldCaption("Bill via"), NpCsDocument."Bill via");
                    SalesHeader.Delete(true);
                end;
        end;
    end;
}
