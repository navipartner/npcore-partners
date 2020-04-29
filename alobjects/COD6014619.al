codeunit 6014619 "Tax Free Last Voucher Print"
{
    // Single instance codeunit for allowing reprint of the last tax free voucher issued by a user session, for integrations that don't allow reprint further back.
    // 
    // PrintType:
    //  0: Thermal
    //  1: PDF
    // 
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        VoucherEntryNo: Integer;
        PrintBlob: Record TempBlob temporary;
        PrintType: Integer;
        Stored: Boolean;

    procedure SetVoucher(VoucherEntryNoIn: Integer;var PrintBlobIn: Record TempBlob temporary;PrintTypeIn: Integer)
    begin
        VoucherEntryNo := VoucherEntryNoIn;
        PrintBlob := PrintBlobIn;
        PrintType := PrintTypeIn;
        Stored := true;
    end;

    procedure GetVoucher(var VoucherEntryNoOut: Integer;var PrintBlobOut: Record TempBlob temporary;var PrintTypeOut: Integer): Boolean
    begin
        VoucherEntryNoOut := VoucherEntryNo;
        PrintBlobOut := PrintBlob;
        PrintTypeOut := PrintType;
        exit(Stored);
    end;
}

