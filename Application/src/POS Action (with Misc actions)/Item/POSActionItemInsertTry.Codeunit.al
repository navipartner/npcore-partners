codeunit 6151037 "NPR POS Action Item Insert Try"
{
    Access = Internal;

    var
        _SaleLinePOS: Record "NPR POS Sale Line";
        _Setup: Codeunit "NPR POS Setup";
        _SerialSelectionFromList: Boolean;
        _FunctionToExecute: Text;
        _SerialNoInput: Text[50];


    trigger OnRun()
    begin
        case UpperCase(_FunctionToExecute) of
            UpperCase('AssignSerialNo'):
                AssingSerialNo();

        end;
    end;

    #region SetSaleLine
    internal procedure SetSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        _SaleLinePOS := SaleLinePOS;
    end;
    #endregion SetSaleLine

    #region GetSaleLine
    internal procedure GetSaleLine(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS := _SaleLinePOS;
    end;
    #endregion GetSaleLine

    #region SetSerialNoInput
    internal procedure SetSerialNoInput(SerialNoInput: Text[50])
    begin
        _SerialNoInput := SerialNoInput;
    end;
    #endregion SetSerialNoInput

    #region GetSerialNoInput
    internal procedure GetSerialNoInput(var SerialNoInput: Text[50])
    begin
        SerialNoInput := _SerialNoInput;
    end;
    #endregion GetSerialNoInput

    #region SetSerialSelectionFromList
    internal procedure SetSerialSelectionFromList(SerialSelectionFromList: Boolean)
    begin
        _SerialSelectionFromList := SerialSelectionFromList;
    end;
    #endregion SetSerialSelectionFromList

    #region GetSerialSelectionFromList
    internal procedure GetSerialSelectionFromList(var SerialSelectionFromList: Boolean)
    begin
        SerialSelectionFromList := _SerialSelectionFromList;
    end;
    #endregion GetSerialSelectionFromList

    #region SetSetup
    internal procedure SetSetup(Setup: Codeunit "NPR POS Setup")
    begin
        _Setup := Setup;
    end;
    #endregion SetSetup

    #region GetSetup
    internal procedure GetSetup(var Setup: Codeunit "NPR POS Setup")
    begin
        Setup := _Setup;
    end;
    #endregion GetSetup

    #region SetFunctionToExecute
    internal procedure SetFunctionToExecute(FunctionToExecute: Text)
    begin
        _FunctionToExecute := FunctionToExecute;
    end;
    #endregion SetFunctionToExecute

    #region GetFunctionToExecute
    internal procedure GetFunctionToExecute(var FunctionToExecute: Text)
    begin
        FunctionToExecute := _FunctionToExecute;
    end;
    #endregion GetFunctionToExecute

    #region AssingSerialNo
    local procedure AssingSerialNo()
    var
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
    begin
        POSActionInsertItemB.AssingSerialNo(_SaleLinePOS,
                                            _SerialNoInput,
                                            _SerialSelectionFromList,
                                            _Setup);

    end;
    #endregion AssingSerialNo

}