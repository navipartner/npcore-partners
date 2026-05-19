#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248186 "NPR Ecom Subpages Sync"
{
    // Bridges actions on subpages of the Ecom Sales Document page (e.g. EcomSalesDocSub's
    // "Process Virtual Item") to the parent page's subpages PBT cache. AL doesn't expose a
    // subpage->parent call path, so the subpage marks the doc dirty here and the parent's
    // OnAfterGetCurrRecord consumes the flag and forces a refresh.
    //
    // Only ever holds a transient "needs refresh" hint. Page-local caches on the parent still
    // own the actual loaded/pending state, so a stale flag in this singleton can only ever
    // cause one extra harmless PBT run — never a missed refresh or wrong data.
    SingleInstance = true;
    Access = Internal;

    var
        _DirtyDocSystemId: Guid;

    internal procedure MarkDirty(DocSystemId: Guid)
    begin
        _DirtyDocSystemId := DocSystemId;
    end;

    /// <summary>
    /// Returns true and clears the flag if the doc was marked dirty. The parent page calls
    /// this in OnAfterGetCurrRecord so the consumption is one-shot.
    /// </summary>
    internal procedure ConsumeDirty(DocSystemId: Guid) WasDirty: Boolean
    begin
        WasDirty := _DirtyDocSystemId = DocSystemId;
        if WasDirty then
            System.Clear(_DirtyDocSystemId);
    end;
}
#endif
