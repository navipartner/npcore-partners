codeunit 6014536 "RP Aux - EFT Print Helper"
{
    // NPR5.36/MMV /20170913 CASE 287022 Created codeunit
    // 
    // Codeunit only exists because the table "Credit Card Transaction" on which EFT receipts are currently based requires some overarching logic in order to recognize seperate prints bundled together.
    // 
    // NPR5.37/MMV /20171020 CASE 293784 Detect when to cut between continuous receipt data correctly.
    // NPR5.46/MMV /20180925 CASE 290734 EFT framework refactoring


    trigger OnRun()
    begin
    end;

    var
        Caption_Copy: Label '*** Copy ***';

    local procedure "// Locals"()
    begin
    end;

    local procedure AddFunction(var tmpRetailList: Record "Retail List" temporary;Choice: Text)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := Choice;
        tmpRetailList.Insert;
    end;

    local procedure "// Event Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"RP Aux - EFT Print Helper");
        tmpAllObj.Init;
        tmpAllObj := AllObj;
        tmpAllObj.Insert;
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnBuildFunctionList', '', false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer;var tmpRetailList: Record "Retail List" temporary)
    begin
        if CodeunitID <> CODEUNIT::"RP Aux - EFT Print Helper" then
          exit;

        AddFunction(tmpRetailList, 'PRINT_COPY');
        AddFunction(tmpRetailList, 'CUT_BETWEEN');
    end;

    [EventSubscriber(ObjectType::Table, 6014445, 'OnFunction', '', false, false)]
    local procedure OnFunction(CodeunitID: Integer;FunctionName: Text;var TemplateLine: Record "RP Template Line";RecID: RecordID;var Skip: Boolean;var Handled: Boolean)
    var
        RecRef: RecordRef;
        CreditCardTransaction: Record "Credit Card Transaction";
        NewReceipt: Boolean;
        CreditCardTransaction2: Record "Credit Card Transaction";
        FirstReceipt: Boolean;
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        if CodeunitID <> CODEUNIT::"RP Aux - EFT Print Helper" then
          exit;

        Handled := true;

        if RecID.TableNo <> DATABASE::"Credit Card Transaction" then
          exit;

        RecRef := RecID.GetRecord;
        RecRef.SetTable(CreditCardTransaction);

        if not CreditCardTransaction.Find then
          exit;

        //-NPR5.46 [290734]
        //FirstReceipt := CreditCardTransaction."Entry No." = 1;
        EFTTransactionRequest.Get(CreditCardTransaction."EFT Trans. Request Entry No.");
        //+NPR5.46 [290734]

        CreditCardTransaction2.SetRange("Register No.", CreditCardTransaction."Register No.");
        CreditCardTransaction2.SetRange("Sales Ticket No.", CreditCardTransaction."Sales Ticket No.");
        CreditCardTransaction2.SetRange(Type, 0);
        CreditCardTransaction2.SetFilter("Entry No.", '<%1', CreditCardTransaction."Entry No.");
        //-NPR5.46 [290734]
        NewReceipt := true;
        if CreditCardTransaction2.FindLast then
          NewReceipt := (CreditCardTransaction."Receipt No." <> CreditCardTransaction2."Receipt No.") or (CreditCardTransaction."EFT Trans. Request Entry No." <> CreditCardTransaction2."EFT Trans. Request Entry No.");
        // IF CreditCardTransaction2.FINDLAST THEN
        //  NewReceipt := (CreditCardTransaction."No. Printed" = CreditCardTransaction2."No. Printed")
        //                AND ((CreditCardTransaction."Receipt No." <> CreditCardTransaction2."Receipt No.") OR (CreditCardTransaction."EFT Trans. Request Entry No." <> CreditCardTransaction2."EFT Trans. Request Entry No."));
        //+NPR5.46 [290734]

        with TemplateLine do
          case FunctionName of
            'PRINT_COPY' :
        //-NPR5.46 [290734]
        //      IF NewReceipt OR FirstReceipt THEN
        //        IF CreditCardTransaction."No. Printed" > 0 THEN
              if NewReceipt then
                if EFTTransactionRequest."No. of Reprints" > 0 then
        //+NPR5.46 [290734]
                  TemplateLine."Processing Value" := Caption_Copy;
        //-NPR5.46 [290734]
        //    'CUT_BETWEEN' :
        //      IF NewReceipt AND (NOT FirstReceipt) THEN BEGIN
        //        TemplateLine."Type Option" := 'Control'; //Change to PAPERCUT when properly implemented.
        //        TemplateLine."Processing Value" := 'PAPERCUT';
        //      END;
        //+NPR5.46 [290734]
          end;
    end;
}

