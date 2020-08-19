codeunit 6151081 "ExRv Webservice"
{
    // NPR5.40/MHA /20180212  CASE 301346 Object created - External Retail Voucher


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Invalid voucher_type: %1';

        procedure IssueVouchers(var vouchers: XMLport "ExRv Vouchers")
    var
        TempExRvVoucher: Record "ExRv Voucher" temporary;
        ExRvMgt: Codeunit "ExRv Management";
    begin
        vouchers.Import;
        vouchers.GetSourceTable(TempExRvVoucher);
        if TempExRvVoucher.FindSet then
          repeat
            ExRvMgt.IssueVoucher(TempExRvVoucher);
          until TempExRvVoucher.Next = 0;

        vouchers.SetSourceTable(TempExRvVoucher);
    end;

        procedure GetVouchers(var vouchers: XMLport "ExRv Vouchers")
    var
        ExRvVoucher: Record "ExRv Voucher";
        TempExRvVoucher: Record "ExRv Voucher" temporary;
        ExRvMgt: Codeunit "ExRv Management";
    begin
        vouchers.Import;
        vouchers.GetSourceTable(TempExRvVoucher);
        if TempExRvVoucher.FindSet then
          repeat
            TempExRvVoucher.Open := false;
            if ExRvVoucher.Get(TempExRvVoucher."Voucher Type",TempExRvVoucher."No.") then begin
              ExRvMgt.UpdateIsOpen(ExRvVoucher);
              TempExRvVoucher := ExRvVoucher;
              TempExRvVoucher.Modify;
            end;
          until TempExRvVoucher.Next = 0;

        vouchers.SetSourceTable(TempExRvVoucher);
    end;
}

