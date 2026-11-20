codeunit 6184587 "NPR NPRE Order Notes Mgt."
{
    Access = Internal;

    internal procedure IsOrderNote(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"): Boolean
    begin
        exit((WaiterPadLine."Line Type" = WaiterPadLine."Line Type"::Comment) and (WaiterPadLine."Attached to Line No." = 0) and (WaiterPadLine."No." = OrderNoteMarker()));
    end;

    internal procedure OrderNoteMarker(): Code[20]
    var
        OrderNoteMarkerTok: Label '*', Locked = true;
    begin
        exit(OrderNoteMarkerTok);
    end;

    local procedure FilterOrderNotes(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; WaiterPadNo: Code[20])
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Comment);
        WaiterPadLine.SetRange("Attached to Line No.", 0);
        WaiterPadLine.SetRange("No.", OrderNoteMarker());
    end;

    internal procedure NoteKey(Description: Text): Text
    begin
        exit(DelChr(Description, '<>', ' ').ToLower());
    end;

    internal procedure GetOrderNotes(OrderId: BigInteger; var Notes: List of [Text])
    var
        PadNotesCache: Dictionary of [Code[20], List of [Text]];
    begin
        GetOrderNotes(OrderId, PadNotesCache, Notes);
    end;

    internal procedure GetOrderNotes(OrderId: BigInteger; var PadNotesCache: Dictionary of [Code[20], List of [Text]]; var Notes: List of [Text])
    var
        KitchOrdSrcbyDoc: Query "NPR NPRE Kitch.Ord.Src. by Doc";
        SeenPads: List of [Code[20]];
        PadNotes: List of [Text];
        Note: Text;
    begin
        Clear(Notes);
        if OrderId = 0 then
            exit;

        KitchOrdSrcbyDoc.SetRange(Order_ID, OrderId);
        KitchOrdSrcbyDoc.SetFilter(Line_Status, '<>%1', "NPR NPRE K.Request Line Status"::Cancelled);
        KitchOrdSrcbyDoc.SetRange(Source_Document_Type, KitchOrdSrcbyDoc.Source_Document_Type::"Waiter Pad");
        KitchOrdSrcbyDoc.SetFilter(QuantityBase, '<>%1', 0);
        KitchOrdSrcbyDoc.Open();
        while KitchOrdSrcbyDoc.Read() do
            if not SeenPads.Contains(KitchOrdSrcbyDoc.Source_Document_No_) then begin
                SeenPads.Add(KitchOrdSrcbyDoc.Source_Document_No_);
                if not PadNotesCache.Get(KitchOrdSrcbyDoc.Source_Document_No_, PadNotes) then begin
                    PadNotes := NewWaiterPadNotes(KitchOrdSrcbyDoc.Source_Document_No_);
                    PadNotesCache.Add(KitchOrdSrcbyDoc.Source_Document_No_, PadNotes);
                end;
                foreach Note in PadNotes do
                    if not ContainsNote(Notes, NoteKey(Note)) then
                        Notes.Add(Note);
            end;
        KitchOrdSrcbyDoc.Close();
    end;

    local procedure NewWaiterPadNotes(WaiterPadNo: Code[20]) PadNotes: List of [Text]
    begin
        AddWaiterPadNotes(WaiterPadNo, PadNotes);
    end;

    internal procedure GetWaiterPadNotes(WaiterPadNo: Code[20]; var Notes: List of [Text])
    begin
        Clear(Notes);
        AddWaiterPadNotes(WaiterPadNo, Notes);
    end;

    local procedure AddWaiterPadNotes(WaiterPadNo: Code[20]; var Notes: List of [Text])
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        NoteKeyText: Text;
    begin
        FilterOrderNotes(WaiterPadLine, WaiterPadNo);
        WaiterPadLine.SetLoadFields(Description);
        if WaiterPadLine.FindSet() then
            repeat
                NoteKeyText := NoteKey(WaiterPadLine.Description);
                if NoteKeyText <> '' then
                    if not ContainsNote(Notes, NoteKeyText) then
                        Notes.Add(WaiterPadLine.Description);
            until WaiterPadLine.Next() = 0;
    end;

    local procedure ContainsNote(Notes: List of [Text]; NoteKeyText: Text): Boolean
    var
        Note: Text;
    begin
        foreach Note in Notes do
            if NoteKey(Note) = NoteKeyText then
                exit(true);
        exit(false);
    end;

    internal procedure HeaderNotesEnabled(): Boolean
    var
        OrderNotesFeature: Codeunit "NPR NPRE Order Notes Feature";
    begin
        exit(OrderNotesFeature.IsFeatureEnabled());
    end;

    internal procedure RemoveOrderNotesFromBody(var TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary)
    begin
        TempWPadLineOutBuffer.SetRange("Line Type", TempWPadLineOutBuffer."Line Type"::Comment);
        TempWPadLineOutBuffer.SetRange("Attached to Line No.", 0);
        TempWPadLineOutBuffer.SetRange("No.", OrderNoteMarker());
        TempWPadLineOutBuffer.DeleteAll();
        TempWPadLineOutBuffer.Reset();
    end;

    internal procedure SnapshotOrderNotes(WaiterPadNo: Code[20]; var TempSourceNote: Record "NPR NPRE Waiter Pad Line" temporary)
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        FilterOrderNotes(WaiterPadLine, WaiterPadNo);
        if WaiterPadLine.FindSet() then
            repeat
                TempSourceNote := WaiterPadLine;
                TempSourceNote.Insert();
            until WaiterPadLine.Next() = 0;
        TempSourceNote.Reset();
    end;

    internal procedure CopyOrderNotes(var TempSourceNote: Record "NPR NPRE Waiter Pad Line" temporary; FromWaiterPadNo: Code[20]; ToWaiterPadNo: Code[20])
    var
        NewLine: Record "NPR NPRE Waiter Pad Line";
        TargetNotes: List of [Text];
        NoteKeyText: Text;
    begin
        GetWaiterPadNotes(ToWaiterPadNo, TargetNotes);
        TempSourceNote.Reset();
        TempSourceNote.SetRange("Waiter Pad No.", FromWaiterPadNo);
        if TempSourceNote.FindSet() then
            repeat
                NoteKeyText := NoteKey(TempSourceNote.Description);
                if (NoteKeyText <> '') and not ContainsNote(TargetNotes, NoteKeyText) then begin
                    NewLine := TempSourceNote;
                    NewLine."Waiter Pad No." := ToWaiterPadNo;
                    NewLine."Line No." := 0;
                    Clear(NewLine."Sale Retail ID");
                    Clear(NewLine."Sale Line Retail ID");
                    NewLine."Attached to Line No." := 0;
                    NewLine.Indentation := 0;
                    NewLine.Insert(true);
                    TargetNotes.Add(NewLine.Description);
                end;
            until TempSourceNote.Next() = 0;
        TempSourceNote.Reset();
    end;
}
