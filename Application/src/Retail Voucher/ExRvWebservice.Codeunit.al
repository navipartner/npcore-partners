codeunit 6151081 "NPR ExRv Webservice"
{
    procedure IssueVouchers(var vouchers: XMLport "NPR ExRv Vouchers")
    var
        TempExRvVoucher: Record "NPR ExRv Voucher" temporary;
        ExRvMgt: Codeunit "NPR ExRv Mgt.";
    begin
        vouchers.Import;
        vouchers.GetSourceTable(TempExRvVoucher);
        if TempExRvVoucher.FindSet then
            repeat
                ExRvMgt.IssueVoucher(TempExRvVoucher);
            until TempExRvVoucher.Next = 0;

        vouchers.SetSourceTable(TempExRvVoucher);
    end;

    procedure GetVouchers(var vouchers: XMLport "NPR ExRv Vouchers")
    var
        ExRvVoucher: Record "NPR ExRv Voucher";
        TempExRvVoucher: Record "NPR ExRv Voucher" temporary;
        ExRvMgt: Codeunit "NPR ExRv Mgt.";
    begin
        vouchers.Import;
        vouchers.GetSourceTable(TempExRvVoucher);
        if TempExRvVoucher.FindSet then
            repeat
                TempExRvVoucher.Open := false;
                if ExRvVoucher.Get(TempExRvVoucher."Voucher Type", TempExRvVoucher."No.") then begin
                    ExRvMgt.UpdateIsOpen(ExRvVoucher);
                    TempExRvVoucher := ExRvVoucher;
                    TempExRvVoucher.Modify;
                end;
            until TempExRvVoucher.Next = 0;

        vouchers.SetSourceTable(TempExRvVoucher);
    end;
}

