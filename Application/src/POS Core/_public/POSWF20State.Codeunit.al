﻿codeunit 6150734 "NPR POS WF 2.0: State"
{
    // NPR5.50/JAKUBV/20190603  CASE 338666 Transport NPR5.50 - 3 June 2019

    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'No-cross invocation state in actions going forward, apart from the database! Delete when last workflow v2 is gone';

    var
        FrontEnd: Codeunit "NPR POS Front End Management";
        Text003: Label 'Action %1 has attempted to store an object into action state, which failed due to following error:\\%2';
        ActionCode: Text;
        ActionState: Dictionary of [Text, Text];
        ActionStateRecRef: array[1024] of RecordRef;
        ActionStateRecRefCounter: Integer;

    procedure Constructor(FrontEndIn: Codeunit "NPR POS Front End Management"; ActionCodeIn: Text)
    begin
        FrontEnd := FrontEndIn;
        ActionCode := ActionCodeIn;
    end;

    procedure StoreActionState("Key": Text; "Object": Variant)
    begin
        if Object.IsRecord then
            Object := StoreActionStateRecRef(Object);

        if not TryStoreActionState(ActionCode + '.' + Key, Object) then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text003, ActionCode, GetLastErrorText));
    end;

    procedure RetrieveActionState("Key": Text; var "Object": Variant)
    begin
        Object := ActionState.Get(ActionCode + '.' + Key);
    end;

    procedure RetrieveActionStateSafe("Key": Text; var "Object": Variant): Boolean
    begin
        if ActionState.ContainsKey(ActionCode + '.' + Key) then begin
            RetrieveActionState(Key, Object);
            exit(true);
        end;
    end;

    procedure RetrieveActionStateRecordRef("Key": Text; var RecRef: RecordRef)
    var
        Index: Integer;
    begin
        Evaluate(Index, ActionState.Get(ActionCode + '.' + Key));
        RecRef := ActionStateRecRef[Index];
    end;

    local procedure StoreActionStateRecRef("Object": Variant) StoredIndex: Integer
    begin
        StoredIndex := ActionStateRecRefCounter;
        ActionStateRecRef[StoredIndex].GetTable(Object);
        ActionStateRecRefCounter += 1;
    end;

    [TryFunction]
    local procedure TryStoreActionState("Key": Text; "Object": Variant)
    begin
        if ActionState.ContainsKey(Key) then
            ActionState.Remove(Key);

        ActionState.Add(Key, Object);
    end;
}

