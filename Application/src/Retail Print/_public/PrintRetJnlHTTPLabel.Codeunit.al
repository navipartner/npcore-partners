codeunit 6184762 "NPR Print RetJnl HTTP Label"
{
    TableNo = "NPR Retail Journal Line";
    EventSubscriberInstance = Manual;

    var
        _PrintJobId: Guid;

    trigger OnRun()
    var
        _this: Codeunit "NPR Print RetJnl HTTP Label";
        LabelManagement: Codeunit "NPR Label Management";
    begin
        BindSubscription(_this);
        _this.SetPrintJobId(Rec."Print Job ID");
        LabelManagement.PrintRetailJournal(Rec, Enum::"NPR Report Selection Type"::"Price Label".AsInteger());
    end;

    procedure SetPrintJobId(PrintJobId: Guid)
    begin
        _PrintJobId := PrintJobId;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Object Output Mgt.", 'OnBeforeSendMatrixPrint', '', true, true)]
    local procedure OnBeforeSendMatrixPrint(var Printer: Interface "NPR IMatrix Printer"; var Skip: Boolean)
    var
        Endpoint: Text;
        Base64PrintJob: Text;
        PrintJobKeyValue: Record "NPR Print Job Key Value";
        OStream: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if IsNullGuid(_PrintJobId) then
            exit;

        Skip := true;
        Printer.PrepareJobForHTTP(Endpoint);
        Base64PrintJob := Printer.GetPrintBufferAsBase64();

        PrintJobKeyValue.Init();
        PrintJobKeyValue."Print Key" := _PrintJobId;
        PrintJobKeyValue."Print Job".CreateOutStream(OStream, TextEncoding::UTF8);
        Base64Convert.FromBase64(Base64PrintJob, OStream);
# pragma warning disable AA0139
        PrintJobKeyValue."Printer HTTP Endpoint" := Endpoint;
# pragma warning restore AA0139
        PrintJobKeyValue.Insert();

        Clear(_PrintJobId);
    end;



}