codeunit 6014534 "NPR RP Aux: Event Publishers"
{
    // NPR5.40/MMV /20180208 CASE 304639 Changed events to use receipt no. instead of audit roll to make it independent of specific table.
    // NPR5.41/MMV /20180411 CASE 308701 Added FIND to retrieve record data.


    trigger OnRun()
    begin
    end;

    var
        ERROR_UNKNOWNTABLE: Label 'Template line has unknown table selected. Must be %1';

    local procedure AddFunction(var tmpRetailList: Record "NPR Retail List" temporary; Choice: Text)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := Choice;
        tmpRetailList.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSalesReceiptHeader(var TemplateLine: Record "NPR RP Template Line"; ReceiptNo: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSalesReceiptFooter(var TemplateLine: Record "NPR RP Template Line"; ReceiptNo: Text)
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"NPR RP Aux: Event Publishers");
        tmpAllObj.Init();
        tmpAllObj := AllObj;
        tmpAllObj.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnBuildFunctionList', '', false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux: Event Publishers" then
            exit;

        AddFunction(tmpRetailList, 'RECEIPT_HEADER');
        AddFunction(tmpRetailList, 'RECEIPT_FOOTER');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnFunction', '', false, false)]
    local procedure OnFunction(CodeunitID: Integer; FunctionName: Text; var TemplateLine: Record "NPR RP Template Line"; RecID: RecordID; var Skip: Boolean; var Handled: Boolean)
    var
        RecRef: RecordRef;
        ReceiptNo: Text;
        POSEntry: Record "NPR POS Entry";
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux: Event Publishers" then
            exit;

        Handled := true;

        RecRef := RecID.GetRecord();
        RecRef.Find();
        case RecRef.Number of
            DATABASE::"NPR POS Entry":
                begin
                    RecRef.SetTable(POSEntry);
                    ReceiptNo := POSEntry."Document No.";
                end;
            else
                Error(ERROR_UNKNOWNTABLE, POSEntry.TableCaption);
        end;

        case FunctionName of
            'RECEIPT_HEADER':
                OnSalesReceiptHeader(TemplateLine, ReceiptNo);
            'RECEIPT_FOOTER':
                OnSalesReceiptFooter(TemplateLine, ReceiptNo);
        end;

        Skip := true; //The actual template line does not need to print anything. The event subscribers might.
    end;
}

