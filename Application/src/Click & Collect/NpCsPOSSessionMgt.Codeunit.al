codeunit 6151205 "NPR NpCs POSSession Mgt."
{
    Access = Internal;
    var
        Text000: Label 'Deliver and Print Collect in Store Document';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeletePOSSaleLine(var Rec: Record "NPR POS Sale Line"; RunTrigger: Boolean)
    var
        NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.";
        SaleLinePOS: Record "NPR POS Sale Line";
        EntryNo: Integer;
    begin
        if Rec.IsTemporary then
            exit;

        if not NpCsSaleLinePOSReference.Get(Rec."Register No.", Rec."Sales Ticket No.", Rec."Sale Type", Rec.Date, Rec."Line No.") then
            exit;

        EntryNo := NpCsSaleLinePOSReference."Collect Document Entry No.";
        NpCsSaleLinePOSReference.Delete();

        NpCsSaleLinePOSReference.SetRange("Register No.", Rec."Register No.");
        NpCsSaleLinePOSReference.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        NpCsSaleLinePOSReference.SetRange("Sale Date", Rec.Date);
        NpCsSaleLinePOSReference.SetRange("Collect Document Entry No.", EntryNo);
        if NpCsSaleLinePOSReference.FindSet() then
            repeat
                if SaleLinePOS.Get(
                  NpCsSaleLinePOSReference."Register No.", NpCsSaleLinePOSReference."Sales Ticket No.",
                  NpCsSaleLinePOSReference."Sale Date", NpCsSaleLinePOSReference."Sale Type", NpCsSaleLinePOSReference."Sale Line No.")
                then
                    SaleLinePOS.Delete(true);
            until NpCsSaleLinePOSReference.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSSalesLine', '', true, false)]
    local procedure OnAfterInsertPOSSalesLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.";
    begin
        if not NpCsSaleLinePOSReference.Get(SaleLinePos."Register No.", SaleLinePos."Sales Ticket No.", SaleLinePos."Sale Type", SaleLinePos.Date, SaleLinePos."Line No.") then
            exit;

        case NpCsSaleLinePOSReference."Sale Type" of
            NpCsSaleLinePOSReference."Sale Type"::Sale:
                begin
                    UpdateCollectDocumentDelivery(NpCsSaleLinePOSReference);
                end;
        end;
    end;

    local procedure UpdateCollectDocumentDelivery(NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.")
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
    begin
        if not NpCsDocument.Get(NpCsSaleLinePOSReference."Collect Document Entry No.") then
            exit;

        if (NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Delivered) and (NpCsDocument."Delivery Document Type" = NpCsDocument."Delivery Document Type"::"POS Entry")
          and (NpCsDocument."Delivery Document No." = NpCsSaleLinePOSReference."Sales Ticket No.")
        then
            exit;

        NpCsCollectMgt.UpdateDeliveryStatus(NpCsDocument, NpCsDocument."Delivery Status"::Delivered, NpCsDocument."Delivery Document Type"::"POS Entry", NpCsSaleLinePOSReference."Sales Ticket No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure DeliverCollectDocument(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'DeliverCollectDocument' then
            exit;

        NpCsDocument.SetCurrentKey("Delivery Document Type", "Delivery Document No.");
        NpCsDocument.SetRange("Delivery Document Type", NpCsDocument."Delivery Document Type"::"POS Entry");
        NpCsDocument.SetRange("Delivery Document No.", SalePOS."Sales Ticket No.");
        if NpCsDocument.IsEmpty then
            exit;

        NpCsDocument.FindSet();
        repeat
            NpCsCollectMgt.DeliverDocument(NpCsDocument);
        until NpCsDocument.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'DeliverCollectDocument':
                begin
                    Rec.Description := CopyStr(Text000, 1, MaxStrLen(Rec.Description));
                    Rec."Sequence No." := CurrCodeunitId();
                    Rec.Enabled := true;
                end;
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs POSSession Mgt.");
    end;
}

