codeunit 6014534 "RP Aux - Event Publishers"
{
    // NPR5.40/MMV /20180208 CASE 304639 Changed events to use receipt no. instead of audit roll to make it independent of specific table.
    // NPR5.41/MMV /20180411 CASE 308701 Added FIND to retrieve record data.


    trigger OnRun()
    begin
    end;

    var
        ERROR_UNKNOWNTABLE: Label 'Template line has unknown table selected. Must be either %1 or %2';

    local procedure "// Locals"()
    begin
    end;

    local procedure AddFunction(var tmpRetailList: Record "Retail List" temporary;Choice: Text)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := Choice;
        tmpRetailList.Insert;
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSalesReceiptHeader(var TemplateLine: Record "RP Template Line";ReceiptNo: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSalesReceiptFooter(var TemplateLine: Record "RP Template Line";ReceiptNo: Text)
    begin
    end;

    local procedure "// Event Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"RP Aux - Event Publishers");
        tmpAllObj.Init;
        tmpAllObj := AllObj;
        tmpAllObj.Insert;
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnBuildFunctionList', '', false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer;var tmpRetailList: Record "Retail List" temporary)
    begin
        if CodeunitID <> CODEUNIT::"RP Aux - Event Publishers" then
          exit;

        AddFunction(tmpRetailList, 'RECEIPT_HEADER');
        AddFunction(tmpRetailList, 'RECEIPT_FOOTER');
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnFunction', '', false, false)]
    local procedure OnFunction(CodeunitID: Integer;FunctionName: Text;var TemplateLine: Record "RP Template Line";RecID: RecordID;var Skip: Boolean;var Handled: Boolean)
    var
        AuditRoll: Record "Audit Roll";
        RecRef: RecordRef;
        ReceiptNo: Text;
        POSEntry: Record "POS Entry";
    begin
        if CodeunitID <> CODEUNIT::"RP Aux - Event Publishers" then
          exit;

        Handled := true;

        //-NPR5.40 [304639]
        RecRef := RecID.GetRecord();
        //-NPR5.41 [308701]
        RecRef.Find;
        //+NPR5.41 [308701]
        case RecRef.Number of
          DATABASE::"Audit Roll" :
            begin
              RecRef.SetTable(AuditRoll);
              ReceiptNo := AuditRoll."Sales Ticket No.";
            end;
          DATABASE::"POS Entry" :
            begin
              RecRef.SetTable(POSEntry);
              ReceiptNo := POSEntry."Document No.";
            end;
          else
            Error(ERROR_UNKNOWNTABLE, AuditRoll.TableCaption, POSEntry.TableCaption);
        end;
        //+NPR5.40 [304639]

        with TemplateLine do
          case FunctionName of
        //-NPR5.40 [304639]
            'RECEIPT_HEADER' : OnSalesReceiptHeader(TemplateLine, ReceiptNo);
            'RECEIPT_FOOTER' : OnSalesReceiptFooter(TemplateLine, ReceiptNo);
        //    'RECEIPT_HEADER' :
        //      BEGIN
        //        RecRef := RecID.GETRECORD();
        //        RecRef.SETTABLE(AuditRoll);
        //        AuditRoll.SETRECFILTER();
        //        OnSalesReceiptHeader(TemplateLine, AuditRoll);
        //      END;
        //    'RECEIPT_FOOTER' :
        //      BEGIN
        //        RecRef := RecID.GETRECORD();
        //        RecRef.SETTABLE(AuditRoll);
        //        AuditRoll.SETRECFILTER();
        //        OnSalesReceiptFooter(TemplateLine, AuditRoll);
        //      END;
        //+NPR5.40 [304639]
          end;

        Skip := true; //The actual template line does not need to print anything. The event subscribers might.
    end;
}

