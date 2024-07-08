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

    procedure InsertLogEntryWithTypeSendOrder(NpCsDocument: Record "NPR NpCs Document"; LogMessage: Text; ErrorEntry: Boolean; ErrorMessage: Text)
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Send Order";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, ErrorEntry, ErrorMessage);
    end;

    procedure InsertLogEntryWithTypeOrderStatus(NpCsDocument: Record "NPR NpCs Document"; LogMessage: Text; ErrorEntry: Boolean; ErrorMessage: Text)
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, ErrorEntry, ErrorMessage);
    end;

    procedure InsertLogEntryWithTypePostProcessing(NpCsDocument: Record "NPR NpCs Document"; LogMessage: Text; ErrorEntry: Boolean; ErrorMessage: Text)
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Post Processing";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, ErrorEntry, ErrorMessage);
    end;

    procedure InsertLogEntryWithDummyNpCsWorkflowModule(NpCsDocument: Record "NPR NpCs Document"; LogMessage: Text; ErrorEntry: Boolean; ErrorMessage: Text)
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, ErrorEntry, ErrorMessage);
    end;

    procedure InsertDeliveryCommentLine(DeliverText: Text; NpCsDocument: Record "NPR NpCs Document"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        NpCsPOSActDelivOrderB: Codeunit "NPR POSAction Deliv. CnC Ord.B";
    begin
        NpCsPOSActDelivOrderB.InsertDeliveryCommentLine(DeliverText, NpCsDocument, POSSaleLine);
    end;

    procedure InsertPOSReference(NpCsDocument: Record "NPR NpCs Document"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        NpCsPOSActDelivOrderB: Codeunit "NPR POSAction Deliv. CnC Ord.B";
    begin
        NpCsPOSActDelivOrderB.InsertPOSReference(NpCsDocument, SaleLinePOS);
    end;

    procedure GetImportNpCsDocumentCodeunit(): Integer
    begin
        exit(Codeunit::"NPR NpCs Imp. Sales Doc.");
    end;

    procedure GetLookupNpCsDocumentCodeunit(): Integer
    begin
        exit(Codeunit::"NPR NpCs Lookup Sales Document");
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterUpdateSalesHeaderLocation(SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterInitReqBody(NpcsDocument: Record "NPR NpCs Document"; var Context: Text);
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeImport(var ImportEntry: Record "NPR Nc Import Entry"; var Element: XmlElement; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterDocumentIsCreated(Element: XmlElement; var SalesHeader: Record "Sales Header"; var NpCsDocument: Record "NPR NpCs Document");
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnFindItemVariant(var Element: XmlElement; var ItemVariant: Record "Item Variant"; var Found: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterInitializeTaskProcessors(var NpCsTaskProcessorSetup: Record "NPR NpCs Task Processor Setup")
    begin
    end;


}