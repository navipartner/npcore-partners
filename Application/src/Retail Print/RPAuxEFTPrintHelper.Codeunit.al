codeunit 6014536 "NPR RP Aux: EFT Print Helper"
{
    Access = Internal;
    // Codeunit only exists because the table "Credit Card Transaction" on which EFT receipts are currently based requires some overarching logic in order to recognize seperate prints bundled together.

    var
        Caption_Copy: Label '*** Copy ***';

    local procedure AddFunction(var tmpRetailList: Record "NPR Retail List" temporary; Choice: Text)
    begin
        tmpRetailList.Number += 1;
#pragma warning disable AA0139
        tmpRetailList.Choice := Choice;
#pragma warning restore AA0139
        tmpRetailList.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"NPR RP Aux: EFT Print Helper");
        tmpAllObj.Init();
        tmpAllObj := AllObj;
        tmpAllObj.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnBuildFunctionList', '', false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux: EFT Print Helper" then
            exit;

        AddFunction(tmpRetailList, 'PRINT_COPY');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Line Print Mgt.", 'OnFunction', '', false, false)]
    local procedure OnFunction(CodeunitID: Integer; FunctionName: Text; var TemplateLine: Record "NPR RP Template Line"; RecID: RecordID; var Skip: Boolean; var Handled: Boolean)
    var
        RecRef: RecordRef;
        CreditCardTransaction: Record "NPR EFT Receipt";
        NewReceipt: Boolean;
        CreditCardTransaction2: Record "NPR EFT Receipt";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux: EFT Print Helper" then
            exit;

        Handled := true;

        if RecID.TableNo <> DATABASE::"NPR EFT Receipt" then
            exit;

        RecRef := RecID.GetRecord();
        RecRef.SetTable(CreditCardTransaction);

        if not CreditCardTransaction.Find() then
            exit;

        EFTTransactionRequest.Get(CreditCardTransaction."EFT Trans. Request Entry No.");

        CreditCardTransaction2.SetRange("Register No.", CreditCardTransaction."Register No.");
        CreditCardTransaction2.SetRange("Sales Ticket No.", CreditCardTransaction."Sales Ticket No.");
        CreditCardTransaction2.SetRange(Type, 0);
        CreditCardTransaction2.SetFilter("Entry No.", '<%1', CreditCardTransaction."Entry No.");
        NewReceipt := true;
        if CreditCardTransaction2.FindLast() then
            NewReceipt := (CreditCardTransaction."Receipt No." <> CreditCardTransaction2."Receipt No.") or (CreditCardTransaction."EFT Trans. Request Entry No." <> CreditCardTransaction2."EFT Trans. Request Entry No.");
        case FunctionName of
            'PRINT_COPY':
                if NewReceipt then
                    if EFTTransactionRequest."No. of Reprints" > 0 then
                        TemplateLine."Processing Value" := Caption_Copy;
        end;
    end;
}

