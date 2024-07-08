codeunit 6184680 "NPR Ref.No. Assignment Helper"
{
    Access = Public;

    procedure PosUnitNoParam(): Text
    var
        ParamTok: Label 'POSUnitCode', Locked = true;
    begin
        exit(ParamTok);
    end;

    procedure PosPmtMethodCodeParam(): Text
    var
        ParamTok: Label 'POSPmtMethodCode', Locked = true;
    begin
        exit(ParamTok);
    end;

    procedure CheckpointEntryNoParam(): Text
    var
        ParamTok: Label 'CheckpointEntryNo', Locked = true;
    begin
        exit(ParamTok);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGenerateParameterDictionary(var RefNoTarget: Enum "NPR Reference No. Target"; EndOfDayProfile: Record "NPR POS End of Day Profile"; AssignmentMethod: Enum "NPR Ref.No. Assignment Method"; var Parameters: Dictionary of [Text, Text])
    begin
    end;
}