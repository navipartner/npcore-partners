codeunit 6150762 "NPR Front-End: StartTrans." implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _transactionNo: Text;
        _salesPerson: Text;
        _register: Text;

    procedure Initialize(Sale: Record "NPR Sale POS")
    begin
        _transactionNo := Sale."Sales Ticket No.";
        _salesPerson := Sale."Salesperson Code";
        _register := Sale."Register No.";
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'StartTransaction');
        Json.Add('Content', _content);
        Json.Add('TransactionNo', _transactionNo);
        _content.Add('salesPerson', _salesPerson);
        _content.Add('register', _register);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}