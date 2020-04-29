codeunit 6151082 "ExRv Task Queue Mgt."
{
    // NPR5.40/MHA /20180226  CASE 301346 Object created - External Retail Voucher

    TableNo = "Task Line";

    trigger OnRun()
    begin
        if GetParameterBool('POST_VOUCHERS') then
          PostVouchers();
    end;

    local procedure PostVouchers()
    var
        ExRvVoucher: Record "ExRv Voucher";
        ExRvMgt: Codeunit "ExRv Management";
    begin
        ExRvVoucher.SetRange(Posted,false);
        if ExRvVoucher.IsEmpty then
          exit;

        ExRvVoucher.FindSet;
        repeat
          ExRvMgt.PostVoucher(ExRvVoucher);
        until ExRvVoucher.Next = 0;
    end;
}

