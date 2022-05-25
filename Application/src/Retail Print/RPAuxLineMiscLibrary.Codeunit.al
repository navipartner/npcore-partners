codeunit 6014538 "NPR RP Aux - Line Misc Library"
{
    Access = Internal;
    local procedure PrintReceiptText(var TemplateLine: Record "NPR RP Template Line"; RecordID: RecordID; LinePrintMgt: Codeunit "NPR RP Line Print Mgt.")
    var
        Utility: Codeunit "NPR Receipt Footer Mgt.";
        TicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        RecRef: RecordRef;
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        case RecordID.TableNo of
            DATABASE::"NPR POS Entry":
                begin
                    RecRef := RecordID.GetRecord();
                    RecRef.SetTable(POSEntry);
                    POSEntry.Find();
                    POSUnit.Get(POSEntry."POS Unit No.");
                    Utility.GetSalesTicketReceiptText(TicketRcptText, POSUnit);
                end;
        end;
        LinePrintMgt.SetFont(TemplateLine."Type Option");
        repeat
            LinePrintMgt.AddTextField(1, TemplateLine.Align, TicketRcptText."Receipt Text");
        until TicketRcptText.Next() = 0;
    end;

    local procedure AddFunction(var tmpRetailList: Record "NPR Retail List" temporary; Choice: Text)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := Choice;
        tmpRetailList.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnBuildFunctionList', '', false, false)]
    local procedure OnLineBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List")
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux - Line Misc Library" then
            exit;

        AddFunction(tmpRetailList, 'RECEIPT_TEXT');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnFunction', '', false, false)]
    local procedure OnLineFunction(CodeunitID: Integer; FunctionName: Text; RecID: RecordId; var Handled: Boolean; var Skip: Boolean; var TemplateLine: Record "NPR RP Template Line"; sender: Codeunit "NPR RP Line Print Mgt.")
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux - Line Misc Library" then
            exit;

        Handled := true;

        case FunctionName of
            'RECEIPT_TEXT':
                PrintReceiptText(TemplateLine, RecID, sender);
        end;
    end;
}