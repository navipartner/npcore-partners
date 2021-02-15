codeunit 6014619 "NPR TaxFree LastVouch.Print"
{
    // Single instance codeunit for allowing reprint of the last tax free voucher issued by a user session, for integrations that don't allow reprint further back.
    // 
    // PrintType:
    //  0: Thermal
    //  1: PDF
    SingleInstance = true;

    var
        PrintBlob: Codeunit "Temp Blob";
        Stored: Boolean;
        PrintType: Integer;
        VoucherEntryNo: Integer;

    procedure SetVoucher(VoucherEntryNoIn: Integer; var PrintBlobIn: Codeunit "Temp Blob"; PrintTypeIn: Integer)
    begin
        VoucherEntryNo := VoucherEntryNoIn;
        PrintBlob := PrintBlobIn;
        PrintType := PrintTypeIn;
        Stored := true;
    end;

    procedure GetVoucher(var VoucherEntryNoOut: Integer; var PrintBlobOut: Codeunit "Temp Blob"; var PrintTypeOut: Integer): Boolean
    begin
        VoucherEntryNoOut := VoucherEntryNo;
        PrintBlobOut := PrintBlob;
        PrintTypeOut := PrintType;
        exit(Stored);
    end;
}

