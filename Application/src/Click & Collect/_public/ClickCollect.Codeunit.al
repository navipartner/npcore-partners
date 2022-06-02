codeunit 6059847 "NPR Click & Collect"
{
    Access = Public;

    procedure ArchiveCollectDocument(var NpCsDocument: Record "NPR NpCs Document"; DeleteSalesDocument: Boolean): Boolean
    var
        NpCsArchCollectMgt: Codeunit "NPR NpCs Arch. Collect Mgt.";
    begin
        exit(NpCsArchCollectMgt.ArchiveCollectDocument(NpCsDocument, DeleteSalesDocument));
    end;

    procedure RunDocumentCard(NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
    begin
        NpCsCollectMgt.RunDocumentCard(NpCsDocument);
    end;

    procedure RunLog(NpCsDocument: Record "NPR NpCs Document"; WithAutoUpdate: Boolean)
    var
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
    begin
        NpCsCollectMgt.RunLog(NpCsDocument, WithAutoUpdate);
    end;

    procedure GetLastLogMessage(NpCsDocument: Record "NPR NpCs Document"): Text
    begin
        exit(NpCsDocument.GetLastLogMessage());
    end;

    procedure GetLastLogErrorMessage(NpCsDocument: Record "NPR NpCs Document"): Text
    begin
        exit(NpCsDocument.GetLastLogErrorMessage());
    end;

    procedure SendNotificationToCustomer(NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
    end;

    procedure RunCallback(NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsWorkflowMgt.RunCallback(NpCsDocument);
    end;

    procedure InsertLogEntryWithTypeOrderStatus(NpCsDocument: Record "NPR NpCs Document"; LogMessage: Text; ErrorEntry: Boolean; ErrorMessage: Text)
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, ErrorEntry, ErrorMessage);
    end;

    procedure InsertLogEntryWithDummyNpCsWorkflowModule(NpCsDocument: Record "NPR NpCs Document"; LogMessage: Text; ErrorEntry: Boolean; ErrorMessage: Text)
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, ErrorEntry, ErrorMessage);
    end;
}