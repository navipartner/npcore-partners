codeunit 6248197 "NPR POS Action: SIPreInv Ins B"
{
    Access = Internal;

    internal procedure InsertSalesbookReceiptInfo(Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        SIPOSSale: Record "NPR SI POS Sale";
        SetNumber: Text;
        SerialNumber: Text;
        ReceiptNo: Code[20];
        IssueDate: Date;
    begin
        if not InputSalesBookInitialInfo(SetNumber, SerialNumber, ReceiptNo, IssueDate) then
            exit;

        Sale.GetCurrentSale(POSSale);
        SIPOSSale."POS Sale SystemId" := POSSale.SystemId;
        SIPOSSale."SI SB Set Number" := CopyStr(SetNumber, 1, MaxStrLen(SIPOSSale."SI SB Set Number"));
        SIPOSSale."SI SB Serial Number" := CopyStr(SerialNumber, 1, MaxStrLen(SIPOSSale."SI SB Serial Number"));
        SIPOSSale."SI SB Receipt No." := CopyStr(ReceiptNo, 1, MaxStrLen(SIPOSSale."SI SB Receipt No."));
        SIPOSSale."SI SB Receipt Issue Date" := IssueDate;

        if not SIPOSSale.Insert() then
            SIPOSSale.Modify();
    end;

    local procedure InputSalesBookInitialInfo(var SetNumber: Text; var SerialNumber: Text; var ReceiptNo: Code[20]; var IssueDate: Date): Boolean
    var
        InputDialog: Page "NPR Input Dialog";
        SetNumberLbl: Label 'Salesbook Set Number';
        SerialNumberLbl: Label 'Salesbook Serial Number';
        ReceiptNoLbl: Label 'Salesbook Receipt No.';
        IssueDateLbl: Label 'Salesbook Receipt Issue Date';
        SalesbookInputCaption: Label 'Salesbook Receipt Information';
        ReceiptNo2: Code[50];
    begin
        InputDialog.Caption(SalesbookInputCaption);

        SetNumber := 'XX';
        SerialNumber := 'XXXX-XXXXXXX';
        ReceiptNo := 'XXXX';
        IssueDate := WorkDate();
        InputDialog.SetInput(1, SetNumber, SetNumberLbl);
        InputDialog.SetInput(2, SerialNumber, SerialNumberLbl);
        InputDialog.SetInput(3, ReceiptNo, ReceiptNoLbl);
        InputDialog.SetInput(4, IssueDate, IssueDateLbl);

        if not (InputDialog.RunModal() = Action::OK) then
            exit(false);

        InputDialog.InputText(1, SetNumber);
        InputDialog.InputText(2, SerialNumber);
        InputDialog.InputCodeValue(3, ReceiptNo2);
        InputDialog.InputDate(4, IssueDate);

        ReceiptNo := CopyStr(ReceiptNo2, 1, MaxStrLen(ReceiptNo));

        exit((SetNumber <> '') and (SerialNumber <> '') and (ReceiptNo <> '') and (IssueDate <> 0D));
    end;
}