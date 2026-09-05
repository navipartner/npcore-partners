codeunit 85419 "NPR Spfy Metafield Def. Tests"
{
    // [Feature] Shopify Metafield Definitions
    // Paging tests for "NPR Spfy Metafield Mgt.", driven against the reusable mock GraphQL client.
    // Shopify returns metafield definitions one page at a time; the whole connection must be walked
    // and accumulated before the definitions are usable in BC, and a walk that cannot be completed
    // must fail rather than hand back a partial list.
    //
    // Continuation responses are keyed on the cursor they are requested with, and the initial request
    // is whatever is left over - see GivenInitialPage. Nothing here keys on the query text, so changing
    // the GraphQL document - the page size above all - cannot make these tests fail spuriously.
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _StoreCodeLbl: Label 'SPFYTEST', Locked = true;
        _Page1CursorLbl: Label 'PAGE1END', Locked = true;
        _Page2CursorLbl: Label 'PAGE2END', Locked = true;
        _BrandGIDLbl: Label 'gid://shopify/MetaobjectDefinition/9001', Locked = true;
        _CategoryGIDLbl: Label 'gid://shopify/MetaobjectDefinition/9002', Locked = true;
        _SupplierGIDLbl: Label 'gid://shopify/MetaobjectDefinition/9003', Locked = true;
        _PartialListErrLbl: Label 'Could not read the metafield definition list returned by Shopify.', Locked = true;
        _RetrievalFailedErrLbl: Label 'Could not get metafield definitions from Shopify', Locked = true;
        _TooManyPagesErrLbl: Label 'Shopify is still reporting more metafield definitions after', Locked = true;

    [Test]
    procedure DefinitionBeyondFirstPage_IsRetrieved()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] A metafield definition that Shopify returns on the second page is still resolvable in BC.

        // [Given] Shopify holds two pages of definitions, and only the second page carries the brand reference
        MockClient.AddResponse(_Page1CursorLbl, LastPageResponse());
        GivenInitialPage(MockClient, FirstPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The metaobject-related metafield definition is looked up
        MetafieldID := '';
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] The definition from the second page is found, so paging did not stop after the first response
        _Assert.AreEqual('103', MetafieldID, 'The metafield definition returned on the second Shopify page must be retrieved.');
    end;

    [Test]
    procedure DefinitionOnEarlierPage_SurvivesTheWalk()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] Definitions accumulate across pages instead of each page replacing the last.
        // This does not reproduce the original truncation bug - a first-page definition was always
        // reachable. It pins the accumulation, so that clearing the buffer per iteration rather than
        // once per walk cannot pass unnoticed.

        // [Given] Two pages, where the category reference is on the FIRST page
        MockClient.AddResponse(_Page1CursorLbl, LastPageResponse());
        GivenInitialPage(MockClient, FirstPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The first page's definition is looked up after the whole connection has been walked
        MetafieldID := '';
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _CategoryGIDLbl, MetafieldID);

        // [Then] It is still present, so later pages did not displace it
        _Assert.AreEqual('101', MetafieldID, 'A definition from an earlier page must still be present once paging completes.');
    end;

    [Test]
    procedure ThreePageWalk_AdvancesThroughEveryPage()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] The cursor keeps advancing for as long as Shopify reports more pages.
        // A two-page walk only ever exercises the first hop, so the repeated advance is pinned here.

        // [Given] Three pages, each continuation keyed on the cursor the previous page reported
        MockClient.AddResponse(_Page1CursorLbl, MiddlePageResponse());
        MockClient.AddResponse(_Page2CursorLbl, LastPageResponse());
        GivenInitialPage(MockClient, FirstPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definition on the LAST page is looked up
        MetafieldID := '';
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] All three pages were walked, each after the cursor the one before it reported
        _Assert.AreEqual(3, MockClient.RequestCount(), 'A three-page connection must produce exactly three Shopify requests.');
        _Assert.AreEqual('103', MetafieldID, 'The definition on the third page must be retrieved.');
        _Assert.AreNotEqual('', MockClient.GetRequestContaining(_Page2CursorLbl), 'The third request must page after the second page''s endCursor.');
    end;

    [Test]
    procedure DuplicateDefinitionAcrossPages_KeepsFirstOccurrence()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] The same definition returned twice keeps the values read the first time.
        // Shopify can shift pagination when definitions are created mid-walk, so an ID can repeat.

        // [Given] The second page repeats definition 101, but pointing at a different metaobject
        MockClient.AddResponse(_Page1CursorLbl, PageResponse(
            Edge('101', 'supplier_ref', 'Supplier', 'list.metaobject_reference', _SupplierGIDLbl), false, ''));
        GivenInitialPage(MockClient, FirstPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definition is looked up by the metaobject the FIRST occurrence pointed at
        MetafieldID := '';
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _CategoryGIDLbl, MetafieldID);

        // [Then] The first occurrence won, so the later duplicate did not overwrite it
        _Assert.AreEqual('101', MetafieldID, 'A definition repeated on a later page must not overwrite the first occurrence.');
    end;

    [Test]
    procedure Request_CarriesOwnerTypeAndQueryFilters()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        InitialRequest: Text;
        MetafieldID: Text[30];
    begin
        // [Scenario] The outgoing request actually asks for what the caller wanted. The cursor-keyed rules
        // would catch a broken afterCursor, but nothing else here observes ownerType or the query filter.

        // [Given] A single page of definitions
        GivenInitialPage(MockClient, LastPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The metaobject-related definition is looked up, which asks for PRODUCT metaobject references
        MetafieldID := '';
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] Both variables reached Shopify
        InitialRequest := MockClient.GetRequestContaining('');
        _Assert.IsTrue(InitialRequest.Contains('PRODUCT'), 'The request must carry the owner type it was called with.');
        _Assert.IsTrue(InitialRequest.Contains('type:list.metaobject_reference'), 'The request must carry the query filter it was called with.');
    end;

    [Test]
    procedure ConfiguredIDBeyondFirstPage_IsNotBlanked()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] A mapping already pointing at a definition on a later page keeps its ID.
        // While the walk stopped after the first page this ID could not be found, so it was blanked -
        // and the caller reacts to a blank ID by creating a duplicate definition in the live store.

        // [Given] Two pages, where the already-configured definition sits on the second
        MockClient.AddResponse(_Page1CursorLbl, LastPageResponse());
        GivenInitialPage(MockClient, FirstPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] That configured ID is revalidated
        MetafieldID := '103';
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] It is confirmed rather than blanked
        _Assert.AreEqual('103', MetafieldID, 'An already-configured definition ID from a later page must be confirmed, not blanked.');
    end;

    [Test]
    procedure SubsequentPage_IsRequestedWithEndCursorOfPreviousPage()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] While hasNextPage is true, the next page is requested after the connection's own endCursor.

        // [Given] A first page whose pageInfo ends at PAGE1END, followed by a final page
        MockClient.AddResponse(_Page1CursorLbl, LastPageResponse());
        GivenInitialPage(MockClient, FirstPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definitions are retrieved
        MetafieldID := '';
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] Exactly two requests were sent, the second paging after the endCursor the first page reported
        _Assert.AreEqual(2, MockClient.RequestCount(), 'Two pages of definitions must produce exactly two Shopify requests.');
        _Assert.AreNotEqual('', MockClient.GetRequestContaining(_Page1CursorLbl), 'The continuation must page after the endCursor reported by the previous page.');
    end;

    [Test]
    procedure LastPage_StopsRequesting()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] A single page of definitions is not followed by a pointless extra request.

        // [Given] Shopify returns one page with hasNextPage false. The catch-all would answer a continuation
        // too, so it is the request count below that pins the walk stopping here
        GivenInitialPage(MockClient, LastPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definitions are retrieved
        MetafieldID := '';
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] Only the first page was requested, and the definition on it was found
        _Assert.AreEqual(1, MockClient.RequestCount(), 'A single page of definitions must produce exactly one Shopify request.');
        _Assert.AreEqual('103', MetafieldID, 'The definition on the only page must be retrieved.');
    end;

    [Test]
    procedure StoreWithoutDefinitions_CompletesWithoutError()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] An empty connection is a legitimate answer, not a malformed response.
        // Pins the boundary between "no definitions" and the failure cases below.

        // [Given] Shopify returns no edges and does not claim another page
        GivenInitialPage(MockClient, PageResponse('', false, ''));
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definitions are retrieved
        MetafieldID := '';
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] The walk completes quietly with nothing found
        _Assert.AreEqual(1, MockClient.RequestCount(), 'An empty definition list must produce exactly one Shopify request.');
        _Assert.AreEqual('', MetafieldID, 'A store with no definitions must resolve to a blank ID without erroring.');
    end;

    [Test]
    procedure PageClaimingMoreWithoutCursor_Errors()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] Shopify claims another page but reports no endCursor to continue from.
        // The walk cannot be completed, so the partial list must not be handed back as if it were whole.

        // [Given] A first page advertising more, and a continuation that claims more with no cursor
        MockClient.AddResponse(_Page1CursorLbl, PageResponse('', true, ''));
        GivenInitialPage(MockClient, FirstPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definitions are retrieved
        MetafieldID := '';
        asserterror SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _CategoryGIDLbl, MetafieldID);

        // [Then] The incomplete walk is reported rather than silently truncated, and stops there
        _Assert.ExpectedError(_PartialListErrLbl);
        _Assert.AreEqual(2, MockClient.RequestCount(), 'The walk must stop at the offending page rather than keep requesting.');
    end;

    [Test]
    procedure PageRepeatingItsCursor_Errors()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] A continuation that claims another page but returns the cursor we just paged from
        // would re-issue the identical request. It must be caught at once, not after the page cap.

        // [Given] The continuation echoes the first page's endCursor and still claims another page
        MockClient.AddResponse(_Page1CursorLbl, PageResponse('', true, _Page1CursorLbl));
        GivenInitialPage(MockClient, FirstPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definitions are retrieved
        MetafieldID := '';
        asserterror SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _CategoryGIDLbl, MetafieldID);

        // [Then] The repeat is caught on the spot rather than hammering Shopify up to the page cap
        _Assert.ExpectedError(_PartialListErrLbl);
        _Assert.AreEqual(2, MockClient.RequestCount(), 'A repeated cursor must fail immediately, not after the page cap.');
    end;

    [Test]
    procedure WalkExceedingThePageCap_Errors()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
        PageNo: Integer;
    begin
        // [Scenario] A connection that never ends is bounded by the page cap. The cursor-repeat check cannot
        // catch this: every page reports a genuinely new cursor, so only the cap stops it - and this runs
        // inside a queued task, once per synced entity.

        // [Given] Every page advertises another page and hands back a fresh cursor, forever
        for PageNo := 1 to MaxPagesUnderTest() + 10 do
            MockClient.AddResponse(PageCursor(PageNo), PageResponse('', true, PageCursor(PageNo + 1)));
        GivenInitialPage(MockClient, PageResponse('', true, PageCursor(1)));
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definitions are retrieved
        MetafieldID := '';
        asserterror SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] The walk gives up at the cap, reported as our own bound rather than a malformed response
        _Assert.ExpectedError(_TooManyPagesErrLbl);
        _Assert.AreEqual(MaxPagesUnderTest(), MockClient.RequestCount(), 'The walk must stop at the page cap.');
    end;

    [Test]
    procedure WalkOfExactlyThePageCap_Completes()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
        PageNo: Integer;
    begin
        // [Scenario] A legitimate walk of exactly the cap still succeeds. Pins the off-by-one: tightening the
        // check, or hoisting it out of the "more pages" branch, would silently truncate the largest stores.

        // [Given] The cap is reached exactly, and the final page reports no further pages
        for PageNo := 1 to MaxPagesUnderTest() - 2 do
            MockClient.AddResponse(PageCursor(PageNo), PageResponse('', true, PageCursor(PageNo + 1)));
        MockClient.AddResponse(PageCursor(MaxPagesUnderTest() - 1), LastPageResponse());
        GivenInitialPage(MockClient, PageResponse('', true, PageCursor(1)));
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definitions are retrieved
        MetafieldID := '';
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] The whole walk completed and the definition on the final page resolved
        _Assert.AreEqual(MaxPagesUnderTest(), MockClient.RequestCount(), 'A walk of exactly the cap must complete.');
        _Assert.AreEqual('103', MetafieldID, 'The definition on the final page must be retrieved.');
    end;

    [Test]
    procedure TransportFailureOnSubsequentPage_Errors()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] Losing the connection midway through the walk fails loudly rather than
        // quietly reporting the definitions gathered so far as the complete list.

        // [Given] The first page succeeds and advertises another page, but the continuation fails
        MockClient.AddFailure(_Page1CursorLbl);
        GivenInitialPage(MockClient, FirstPageResponse());
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definitions are retrieved
        MetafieldID := '';
        asserterror SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] The transport failure surfaces instead of being swallowed into a partial result
        _Assert.ExpectedError(_RetrievalFailedErrLbl);
    end;

    [Test]
    procedure ResponseWithoutEdges_Errors()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] A 2xx response that does not carry the expected definition list is a hard failure.
        // Returning an empty list instead would read as "this store has no definitions", and the caller
        // reacts to that by creating a definition that already exists in the merchant's store.

        // [Given] Shopify answers successfully, but without data.metafieldDefinitions.edges
        GivenInitialPage(MockClient, '{"data":{"metafieldDefinitions":{"pageInfo":{"hasNextPage":false}}}}');
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definitions are retrieved
        MetafieldID := '';
        asserterror SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _BrandGIDLbl, MetafieldID);

        // [Then] The unexpected shape is reported rather than treated as an empty store
        _Assert.ExpectedError(_PartialListErrLbl);
    end;

    [Test]
    procedure ResponseWithoutPageInfo_Errors()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        MetafieldID: Text[30];
    begin
        // [Scenario] hasNextPage is non-nullable in Shopify's schema and is explicitly requested, so a
        // response without it is malformed. Defaulting it to false would read as "walk complete" and
        // hand back whatever had been collected so far - the silent truncation this fix removes.

        // [Given] A page of definitions with no pageInfo at all
        GivenInitialPage(MockClient, '{"data":{"metafieldDefinitions":{"edges":[' +
            Edge('101', 'category_ref', 'Category', 'list.metaobject_reference', _CategoryGIDLbl) + ']}}}');
        SpfyMetafieldMgt.SetGraphQLClient(MockClient);

        // [When] The definitions are retrieved
        MetafieldID := '';
        asserterror SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(_StoreCodeLbl, _CategoryGIDLbl, MetafieldID);

        // [Then] The missing page information is reported rather than assumed to mean "no more pages"
        _Assert.ExpectedError(_PartialListErrLbl);
    end;

    /// <summary>
    /// Registers the response for the initial request. Must be called AFTER any continuation rules: the mock
    /// matches in registration order, so cursor-keyed rules win first and this empty pattern takes the rest.
    /// Keying on what is left over rather than on the query text keeps these tests independent of the GraphQL
    /// document - including the page size, which is a pure throughput setting.
    /// </summary>
    local procedure GivenInitialPage(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; ResponseBody: Text)
    begin
        MockClient.AddResponse('', ResponseBody);
    end;

    /// <summary>Mirrors MaxPagesPerWalk in "NPR Spfy Metafield Mgt.". If that changes, these two tests fail loudly on the request count.</summary>
    local procedure MaxPagesUnderTest(): Integer
    begin
        exit(100);
    end;

    /// <summary>Fixed-width so that no cursor is a substring of another - the mock matches on substrings.</summary>
    local procedure PageCursor(PageNo: Integer): Text
    begin
        exit('CUR' + Format(1000 + PageNo));
    end;

    local procedure FirstPageResponse(): Text
    begin
        exit(PageResponse(
            Edge('101', 'category_ref', 'Category', 'list.metaobject_reference', _CategoryGIDLbl) + ',' +
            Edge('102', 'size', 'Size', 'single_line_text_field', ''), true, _Page1CursorLbl));
    end;

    local procedure MiddlePageResponse(): Text
    begin
        exit(PageResponse(
            Edge('104', 'colour', 'Colour', 'single_line_text_field', ''), true, _Page2CursorLbl));
    end;

    local procedure LastPageResponse(): Text
    begin
        exit(PageResponse(
            Edge('103', 'brand_ref', 'Brand', 'list.metaobject_reference', _BrandGIDLbl), false, ''));
    end;

    local procedure PageResponse(Edges: Text; HasNextPage: Boolean; EndCursor: Text): Text
    var
        EndCursorTxt: Text;
        HasNextPageTxt: Text;
    begin
        HasNextPageTxt := 'false';
        if HasNextPage then
            HasNextPageTxt := 'true';
        EndCursorTxt := 'null';
        if EndCursor <> '' then
            EndCursorTxt := '"' + EndCursor + '"';
        exit('{"data":{"metafieldDefinitions":{"edges":[' + Edges +
            '],"pageInfo":{"hasNextPage":' + HasNextPageTxt + ',"endCursor":' + EndCursorTxt + '}}}}');
    end;

    local procedure Edge(DefinitionID: Text; MetafieldKey: Text; MetafieldName: Text; MetafieldType: Text; MetaobjectDefinitionGID: Text): Text
    var
        Validations: Text;
    begin
        Validations := '[]';
        if MetaobjectDefinitionGID <> '' then
            Validations := '[{"name":"metaobject_definition_id","type":"metaobject_definition_id","value":"' + MetaobjectDefinitionGID + '"}]';
        exit('{"node":{"id":"gid://shopify/MetafieldDefinition/' + DefinitionID + '",' +
            '"key":"' + MetafieldKey + '","type":{"name":"' + MetafieldType + '","category":"TEXT"},' +
            '"name":"' + MetafieldName + '","description":"","namespace":"custom","validations":' + Validations + '}}');
    end;
}
