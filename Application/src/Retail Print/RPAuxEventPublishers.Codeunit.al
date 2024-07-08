codeunit 6014534 "NPR RP Aux: Event Publishers"
{
    Access = Internal;

    var
        ERROR_UNKNOWNTABLE: Label 'Template line has unknown table selected. Must be %1';

    local procedure AddFunction(var tmpRetailList: Record "NPR Retail List" temporary; Choice: Text)
    begin
        tmpRetailList.Number += 1;
#pragma warning disable AA0139
        tmpRetailList.Choice := Choice;
#pragma warning restore AA0139
        tmpRetailList.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSalesReceiptHeader(var TemplateLine: Record "NPR RP Template Line"; ReceiptNo: Text; LinePrintMgt: Codeunit "NPR RP Line Print Mgt.")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSalesReceiptFooter(var TemplateLine: Record "NPR RP Template Line"; ReceiptNo: Text; LinePrintMgt: Codeunit "NPR RP Line Print Mgt.")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"NPR RP Aux: Event Publishers");
        tmpAllObj.Init();
        tmpAllObj := AllObj;
        tmpAllObj.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnBuildFunctionList', '', false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux: Event Publishers" then
            exit;

        AddFunction(tmpRetailList, 'RECEIPT_HEADER');
        AddFunction(tmpRetailList, 'RECEIPT_FOOTER');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnFunction', '', false, false)]
    local procedure OnFunction(CodeunitID: Integer; FunctionName: Text; var TemplateLine: Record "NPR RP Template Line"; RecID: RecordID; var Skip: Boolean; var Handled: Boolean; sender: Codeunit "NPR RP Line Print Mgt.")
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
                OnSalesReceiptHeader(TemplateLine, ReceiptNo, sender);
            'RECEIPT_FOOTER':
                OnSalesReceiptFooter(TemplateLine, ReceiptNo, sender);
        end;

        Skip := true; //The actual template line does not need to print anything. The event subscribers might.
    end;
}

