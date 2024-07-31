codeunit 6151037 "NPR POS Action Item Insert Try"
{
    Access = Internal;

    var
        _SaleLinePOS: Record "NPR POS Sale Line";
        _SerialSelectionFromList: Boolean;
        _LotSelectionFromList: Boolean;
        _FunctionToExecute: Text;
        _SerialNoInput: Text[50];
        _LotNoInput: Text[50];
        _POSStore: Record "NPR POS Store";


    trigger OnRun()
    begin
        case UpperCase(_FunctionToExecute) of
            UpperCase('AssignSerialNo'):
                AssingSerialNo();
            UpperCase('AssignLotNo'):
                AssignLotNo();

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

    #region SetLotSelectionFromList
    internal procedure SetLotSelectionFromList(LotSelectionFromList: Boolean)
    begin
        _LotSelectionFromList := LotSelectionFromList;
    end;
    #endregion SetLotSelectionFromList

    #region GetLotSelectionFromList
    internal procedure GetLotSelectionFromList(var LotSelectionFromList: Boolean)
    begin
        LotSelectionFromList := _LotSelectionFromList;
    end;
    #endregion GetLotSelectionFromList

    #region SetPOSStore
    internal procedure SetPOSStore(POSStore: Record "NPR POS Store")
    begin
        _POSStore := POSStore;
    end;
    #endregion SetPOSStore

    #region GetPOSStore
    internal procedure GetPOSStore(var POSStore: Record "NPR POS Store")
    begin
        POSStore := _POSStore;
    end;
    #endregion GetPOSStore
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
                                            _POSStore);

    end;
    #endregion AssingSerialNo

    #region AssignLotNo
    local procedure AssignLotNo()
    var
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
    begin
        POSActionInsertItemB.AssignLotNo(_SaleLinePOS,
                                            _LotNoInput,
                                            _POSStore,
                                            _LotSelectionFromList);

    end;
    #endregion AssignLot
    #region SetLotNoInput
    internal procedure SetLotNoInput(LotNoInput: Text[50])
    begin
        _LotNoInput := LotNoInput;
    end;
    #endregion SetLotNoInput

    #region GetLotNoInput
    internal procedure GetLotNoInput(var LotNoInput: Text[50])
    begin
        LotNoInput := _LotNoInput;
    end;
    #endregion GetLotNoInput

}