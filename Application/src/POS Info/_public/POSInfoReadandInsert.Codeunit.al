codeunit 6059835 "NPR POS Info Read and Insert"
{
    Access = Public;

    var
        POSInfoMgmt: Codeunit "NPR POS Info Management";

    procedure GetPOSInfo(POSInfoCode: Code[20]; RegisterNo: Code[10]; SalesTicketNo: Code[20]; LineNo: Integer): Text[250]
    var
        POSInfo: Text[250];
    begin
        POSInfo := '';
        POSInfo := POSInfoMgmt.GetPOSInfo(POSInfoCode, RegisterNo, SalesTicketNo, LineNo);
        exit(POSInfo);
    end;

    procedure GetPOSInfo(POSInfoCode: Code[20]; RegisterNo: Code[10]; SalesTicketNo: Code[20]): Text[250]
    var
        POSInfo: Text[250];
    begin
        POSInfo := '';
        POSInfo := POSInfoMgmt.GetPOSInfo(POSInfoCode, RegisterNo, SalesTicketNo);
        exit(POSInfo);
    end;

    procedure UpdatePOSInfo(POSInfoCode: Code[20]; SalePOS: Record "NPR POS Sale"; POSInfoText: Text)

    begin
        POSInfoMgmt.UpsertPOSInfo(POSInfoCode, SalePOS, POSInfoText);
    end;

    procedure UpdatePOSInfo(POSInfoCode: Code[20]; SalePOSLine: Record "NPR POS Sale Line"; POSInfoText: Text)

    begin
        POSInfoMgmt.UpsertPOSInfo(POSInfoCode, SalePOSLine, POSInfoText);
    end;

    procedure FindPOSInfoTransaction(RegisterNo: Code[10]; SalesTicketNo: Code[20]; SalesLineNo: Integer; POSInfoCode: Code[20]; POSInfo: Text[250]): Boolean
    begin
        exit(POSInfoMgmt.FindPOSInfoTransaction(RegisterNo, SalesTicketNo, SalesLineNo, POSInfoCode, POSInfo));
    end;

    procedure DeletePOSInfoTransaction(RegisterNo: Code[10]; SalesTicketNo: Code[20]; SalesLineNo: Integer; POSInfoCode: Code[20]; POSInfo: Text[250])

    begin
        POSInfoMgmt.DeletePOSInfoTransaction(RegisterNo, SalesTicketNo, SalesLineNo, POSInfoCode, POSInfo);
    end;

}