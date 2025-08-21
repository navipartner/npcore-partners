codeunit 85139 "NPR API Module Tests"
{
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    // [FEATURE] API module from NP Retail

    Subtype = Test;

    var
        _Initialized: Boolean;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetPageKeyPKTest()
    var
        APIRequest: Codeunit "NPR API Request";
        Assert: Codeunit Assert;
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
        RecRef2: RecordRef;
        Base64Convert: Codeunit "Base64 Convert";
        PageKey: Text;
        PageKeyJson: JsonObject;
    begin
        // [GIVEN] Given a table with: PK key, key filters and ascending and some data.
        InitializeData();

        // [WHEN] When the page key is requested

        SalesHeader.SetFilter(SalesHeader."Document Type", '=%1', SalesHeader."Document Type"::Order);
        SalesHeader.FindSet();
        SalesHeader.Next();
        RecRef.GetTable(SalesHeader);
        PageKey := APIRequest.GetPageKey(RecRef);
        PageKeyJson.ReadFrom(Base64Convert.FromBase64(PageKey));

        // [THEN] The next record in RecRef is equal to first in new record after applying pagination filter
        RecRef2.Open(Database::"Sales Header");
        APIRequest.ApplyPageKey(PageKey, RecRef2);
        RecRef2.Find('>');
        RecRef.Next();
        Assert.AreEqual(Format(RecRef, 0, 9), Format(RecRef2, 0, 9), 'Broken pagination filter');
        RecRef.Next();
        RecRef2.Next();
        Assert.AreEqual(Format(RecRef, 0, 9), Format(RecRef2, 0, 9), 'Broken pagination filter');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetPageKeyNonPKTest()
    var
        APIRequest: Codeunit "NPR API Request";
        Assert: Codeunit Assert;
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
        Base64Convert: Codeunit "Base64 Convert";
        PageKey: Text;
        RecRef2: RecordRef;
    begin
        // [GIVEN] Given a table with: Non-PK key that contains all PK fields, key filters and ascending.
        InitializeData();

        // [WHEN] When the page key is requested
        SalesHeader.SetCurrentKey("No.", "Document Type");
        SalesHeader.SetFilter(SalesHeader."Document Type", '=%1', SalesHeader."Document Type"::Order);
        SalesHeader.FindSet();
        RecRef.GetTable(SalesHeader);
        PageKey := APIRequest.GetPageKey(RecRef);

        // [THEN] The next record in RecRef is equal to first in new record after applying pagination filter
        RecRef2.Open(Database::"Sales Header");
        APIRequest.ApplyPageKey(PageKey, RecRef2);
        RecRef2.Find('>');
        RecRef.Next();
        Assert.AreEqual(Format(RecRef, 0, 9), Format(RecRef2, 0, 9), 'Broken pagination filter');
        RecRef.Next();
        RecRef2.Next();
        Assert.AreEqual(Format(RecRef, 0, 9), Format(RecRef2, 0, 9), 'Broken pagination filter');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetPageKeyMixPKTest()
    var
        APIRequest: Codeunit "NPR API Request";
        Assert: Codeunit Assert;
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
        Base64Convert: Codeunit "Base64 Convert";
        PageKey: Text;
        PageKeyJson: JsonObject;
        RecRef2: REcordRef;
    begin
        // [GIVEN] Given a table with: Non-PK key that contains some PK fields, key filters and ascending.
        InitializeData();

        // [WHEN] When the page key is requested

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23 OR BC24 OR BC25 OR BC26)
        SalesHeader.SetCurrentKey("Document Type", "Combine Shipments", "Sell-to Customer No.", "Bill-to Customer No.", "Currency Code", "EU 3-Party Trade", "Dimension Set ID", "Journal Templ. Name");
#ELSE
        SalesHeader.SetCurrentKey("Document Type", "Combine Shipments", "Bill-to Customer No.", "Currency Code", "EU 3-Party Trade", "Dimension Set ID", "Journal Templ. Name");
#ENDIF
        SalesHeader.SetFilter(SalesHeader."Document Type", '=%1', SalesHeader."Document Type"::Order);
        SalesHeader.FindSet();
        SalesHeader.SetFilter("Customer Price Group", '=%1', SalesHeader."Customer Price Group");
        SalesHeader.Next();
        RecRef.GetTable(SalesHeader);
        PageKey := APIRequest.GetPageKey(RecRef);
        PageKeyJson.ReadFrom(Base64Convert.FromBase64(PageKey));

        // [THEN] The next record in RecRef is equal to first in new record after applying pagination filter
        RecRef2.Open(Database::"Sales Header");
        APIRequest.ApplyPageKey(PageKey, RecRef2);
        RecRef2.Find('>');
        RecRef.Next();
        Assert.AreEqual(Format(RecRef, 0, 9), Format(RecRef2, 0, 9), 'Broken pagination filter');
        RecRef.Next();
        RecRef2.Next();
        Assert.AreEqual(Format(RecRef, 0, 9), Format(RecRef2, 0, 9), 'Broken pagination filter');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetPageKeyMixPKDescendingTest()
    var
        APIRequest: Codeunit "NPR API Request";
        Assert: Codeunit Assert;
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
        Base64Convert: Codeunit "Base64 Convert";
        PageKey: Text;
        RecRef2: REcordRef;
    begin
        // [GIVEN] Given a table with: Non-PK key that contains some PK fields, key filters and descending. 
        InitializeData();

        // [WHEN] When the page key is requested
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23 OR BC24 OR BC25 OR BC26)
        SalesHeader.SetCurrentKey("Document Type", "Combine Shipments", "Sell-to Customer No.", "Bill-to Customer No.", "Currency Code", "EU 3-Party Trade", "Dimension Set ID", "Journal Templ. Name");
#ELSE
        SalesHeader.SetCurrentKey("Document Type", "Combine Shipments", "Bill-to Customer No.", "Currency Code", "EU 3-Party Trade", "Dimension Set ID", "Journal Templ. Name");
#ENDIF
        SalesHeader.SetFilter(SalesHeader."Document Type", '=%1', SalesHeader."Document Type"::Order);
        SalesHeader.Ascending(false);
        SalesHeader.FindSet();
        SalesHeader.SetFilter("Customer Price Group", '=%1', SalesHeader."Customer Price Group");
        SalesHeader.Next();
        RecRef.GetTable(SalesHeader);
        PageKey := APIRequest.GetPageKey(RecRef);

        // [THEN] The next record in RecRef is equal to first in new record after applying pagination filter
        RecRef2.Open(Database::"Sales Header");
        APIRequest.ApplyPageKey(PageKey, RecRef2);
        RecRef2.Find('>');
        RecRef.Next();
        Assert.AreEqual(Format(RecRef, 0, 9), Format(RecRef2, 0, 9), 'Broken pagination filter');
        RecRef.Next();
        RecRef2.Next();
        Assert.AreEqual(Format(RecRef, 0, 9), Format(RecRef2, 0, 9), 'Broken pagination filter');
    end;

    local procedure InitializeData()
    var
        LibrarySales: Codeunit "Library - Sales";
        SalesHeader: REcord "Sales Header";
    begin
        if _Initialized then
            exit;

        _Initialized := true;

        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Order", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::Invoice, '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Credit Memo", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Return Order", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Return Order", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Return Order", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Credit Memo", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Credit Memo", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Order", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Order", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Order", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Order", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Order", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Credit Memo", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::"Credit Memo", '');
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, Enum::"Sales Document Type"::Invoice, '');
        Clear(SalesHeader);
    end;
#endif
}
