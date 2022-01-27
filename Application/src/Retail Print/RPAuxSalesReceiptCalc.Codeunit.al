codeunit 6014526 "NPR RP Aux: SalesReceipt Calc."
{
    Access = Internal;
    // NPR5.43/MMV /20180628 CASE 315937 Created object


    trigger OnRun()
    begin
    end;

    local procedure AddFunction(var tmpRetailList: Record "NPR Retail List" temporary; Choice: Text)
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := Choice;
        tmpRetailList.Insert();
    end;

    local procedure POSSalesLineUnitPriceInclVATExclDiscount(POSSalesLine: Record "NPR POS Entry Sales Line"): Decimal
    begin
        if POSSalesLine.Quantity = 0 then
            exit(0);
        exit((POSSalesLine."Amount Incl. VAT" + POSSalesLine."Line Discount Amount Incl. VAT") / POSSalesLine.Quantity);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnBuildFunctionCodeunitList', '', false, false)]
    local procedure OnBuildFunctionCodeunitList(var tmpAllObj: Record AllObj temporary)
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(AllObj."Object Type"::Codeunit, CODEUNIT::"NPR RP Aux: SalesReceipt Calc.");
        tmpAllObj.Init();
        tmpAllObj := AllObj;
        tmpAllObj.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnBuildFunctionList', '', false, false)]
    local procedure OnBuildFunctionList(CodeunitID: Integer; var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux: SalesReceipt Calc." then
            exit;

        AddFunction(tmpRetailList, 'UNITPRICEINCLVATEXCLDISC_2_2');
        AddFunction(tmpRetailList, 'UNITPRICEINCLVATEXCLDISC_0_2');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RP Template Line", 'OnFunction', '', false, false)]
    local procedure OnFunction(CodeunitID: Integer; FunctionName: Text; var TemplateLine: Record "NPR RP Template Line"; RecID: RecordID; var Skip: Boolean; var Handled: Boolean)
    var
        RecRef: RecordRef;
        POSSalesLine: Record "NPR POS Entry Sales Line";
        FunctionTxt: Text;
        Parameters: Text;
        MinDecimals: Integer;
        MaxDecimals: Integer;
        Result: Decimal;
        FormadDecLbl: Label '<Precision,%1:%2><Standard Format,2>', Locked = true;
    begin
        if CodeunitID <> CODEUNIT::"NPR RP Aux: SalesReceipt Calc." then
            exit;

        Handled := true;

        case RecID.TableNo of
            DATABASE::"NPR POS Entry Sales Line":
                begin
                    RecRef := RecID.GetRecord();
                    RecRef.Find();
                    RecRef.SetTable(POSSalesLine);
                end;
            else
                exit;
        end;

        FunctionTxt := CopyStr(FunctionName, 1, StrPos(FunctionName, '_') - 1);
        Parameters := CopyStr(FunctionName, StrPos(FunctionName, '_') + 1);
        Evaluate(MinDecimals, CopyStr(Parameters, 1, StrPos(Parameters, '_') - 1));
        Evaluate(MaxDecimals, CopyStr(Parameters, StrPos(Parameters, '_') + 1));

        case FunctionTxt of
            'UNITPRICEINCLVATEXCLDISC':
                case RecID.TableNo of
                    DATABASE::"NPR POS Entry Sales Line":
                        Result := POSSalesLineUnitPriceInclVATExclDiscount(POSSalesLine);
                end;
            else
                exit;
        end;

        TemplateLine."Processing Value" := Format(Result, 0, StrSubstNo(FormadDecLbl, MinDecimals, MaxDecimals));
    end;
}

