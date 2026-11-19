codeunit 85604 "NPR Spfy Cust Lookup Tests"
{
    // [FEATURE] Shopify customer lookup by e-mail: only a Shopify customer with exactly the customer's address is linked, updated or deleted, and one Shopify customer is never linked to two BC customers
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _FindCustomerTok: Label 'FindCustomerByEmail', Locked = true;
        _CustomerCreateTok: Label 'customerCreate', Locked = true;
        _CustomerUpdateTok: Label 'customerUpdate', Locked = true;
        _CustomerDeleteTok: Label 'customerDelete', Locked = true;
        _GetCustomerTok: Label 'GetCustomer', Locked = true;
        _MetafieldDefinitionsTok: Label 'metafieldDefinitions', Locked = true;

    local procedure Initialize()
    begin
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
    end;

    [Test]
    procedure CustomerSync_ShopifyCustomerWhoseAddressContainsTheCustomers_IsNotUpdated()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] Syncing a customer Shopify does not know creates a new Shopify customer rather than updating one whose address merely contains the customer's.
        Initialize();

        // [GIVEN] A sync-enabled customer with no Shopify id, and a modify task for it
        CreateCustomer('test@npretail.test', true, true, Customer, SpfyStoreCustomerLink);
        CreateNcTask(Customer, SpfyStoreCustomerLink."Shopify Store Code", NcTask.Type::Modify, NcTask);

        // [GIVEN] Shopify answering the lookup with a different customer whose address contains the customer's
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5001', 'b-test@npretail.test'));
        AddCustomerWriteResponses(MockClient, '5002', '5001', 'test@npretail.test');

        // [WHEN] The customer sync runs
        SendCustomers.SetGraphQLClient(MockClient);
        SendCustomers.Run(NcTask);

        // [THEN] The other Shopify customer is left alone and a new one is created
        _Assert.AreEqual(0, MockClient.CountRequestsContaining(_CustomerUpdateTok), 'A Shopify customer with a different address must not be updated');
        _Assert.AreEqual(1, MockClient.CountRequestsContaining(_CustomerCreateTok), 'A customer Shopify does not know must be created');
    end;

    [Test]
    procedure TaskListCustomerSync_ShopifyCustomerWhoseAddressContainsTheCustomers_IsNotUpdated()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Task Send Customers";
    begin
        // [SCENARIO] On the Task List, syncing a customer Shopify does not know creates a new Shopify customer rather than updating one whose address merely contains the customer's.
        Initialize();

        // [GIVEN] A sync-enabled customer with no Shopify id, and a modify task for it
        CreateCustomer('test@npretail.test', true, true, Customer, SpfyStoreCustomerLink);
        EnqueueCustomerTask(Customer, SpfyStoreCustomerLink."Shopify Store Code", "NPR Spfy Task Op"::Modify, SpfyTask);

        // [GIVEN] Shopify answering the lookup with a different customer whose address contains the customer's
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5001', 'b-test@npretail.test'));
        AddCustomerWriteResponses(MockClient, '5002', '5001', 'test@npretail.test');

        // [WHEN] The Task List customer sync runs
        SendCustomers.SetGraphQLClient(MockClient);
        SendCustomers.Run(SpfyTask);

        // [THEN] The other Shopify customer is left alone and a new one is created
        _Assert.AreEqual(0, MockClient.CountRequestsContaining(_CustomerUpdateTok), 'A Shopify customer with a different address must not be updated');
        _Assert.AreEqual(1, MockClient.CountRequestsContaining(_CustomerCreateTok), 'A customer Shopify does not know must be created');
    end;

    [Test]
    procedure UpdateSyncStatus_ShopifyCustomerWhoseAddressContainsTheCustomers_IsNotLinked()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] Update Sync. Status does not link a customer to a Shopify customer whose address merely contains the customer's, nor copy that customer's data.
        Initialize();

        // [GIVEN] A customer not linked to Shopify yet
        CreateCustomer('test@npretail.test', false, false, Customer, SpfyStoreCustomerLink);

        // [GIVEN] Shopify answering the lookup with a different customer whose address contains the customer's
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5001', 'b-test@npretail.test'));
        MockClient.AddResponse(_GetCustomerTok, CustomerDataResponse('5001', 'b-test@npretail.test'));

        // [WHEN] Update Sync. Status runs for the customer
        SendCustomers.SetGraphQLClient(MockClient);
        ShopifyStore.SetRange(Code, SpfyStoreCustomerLink."Shopify Store Code");
        SendCustomers.MarkCustomerAlreadyOnShopify(Customer, ShopifyStore, false, false, false);

        // [THEN] The link carries no Shopify id and keeps the customer's own address
        _Assert.AreEqual('', AssignedCustomerId(SpfyStoreCustomerLink), 'The customer must not be linked to a Shopify customer with a different address');
        SpfyStoreCustomerLink.Find();
        _Assert.AreEqual('test@npretail.test', SpfyStoreCustomerLink."E-Mail", 'The link must not take over the other Shopify customer''s address');
    end;

    [Test]
    procedure TaskListUpdateSyncStatus_ShopifyCustomerWhoseAddressContainsTheCustomers_IsNotLinked()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Task Send Customers";
    begin
        // [SCENARIO] On the Task List, Update Sync. Status does not link a customer to a Shopify customer whose address merely contains the customer's.
        Initialize();

        // [GIVEN] A customer not linked to Shopify yet
        CreateCustomer('test@npretail.test', false, false, Customer, SpfyStoreCustomerLink);

        // [GIVEN] Shopify answering the lookup with a different customer whose address contains the customer's
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5001', 'b-test@npretail.test'));
        MockClient.AddResponse(_GetCustomerTok, CustomerDataResponse('5001', 'b-test@npretail.test'));

        // [WHEN] Update Sync. Status runs for the customer
        SendCustomers.SetGraphQLClient(MockClient);
        ShopifyStore.SetRange(Code, SpfyStoreCustomerLink."Shopify Store Code");
        SendCustomers.MarkCustomerAlreadyOnShopify(Customer, ShopifyStore, false, false, false);

        // [THEN] The link carries no Shopify id and keeps the customer's own address
        _Assert.AreEqual('', AssignedCustomerId(SpfyStoreCustomerLink), 'The customer must not be linked to a Shopify customer with a different address');
        SpfyStoreCustomerLink.Find();
        _Assert.AreEqual('test@npretail.test', SpfyStoreCustomerLink."E-Mail", 'The link must not take over the other Shopify customer''s address');
    end;

    [Test]
    procedure UpdateSyncStatus_SameAddressInAnotherCase_IsLinked()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] Update Sync. Status still links a customer to the Shopify customer with the same address, whatever the letter case.
        Initialize();

        // [GIVEN] A customer not linked to Shopify yet
        CreateCustomer('test@npretail.test', false, false, Customer, SpfyStoreCustomerLink);

        // [GIVEN] Shopify holding that address in another letter case
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5003', 'Test@NPRetail.test'));
        MockClient.AddResponse(_GetCustomerTok, CustomerDataResponse('5003', 'Test@NPRetail.test'));

        // [WHEN] Update Sync. Status runs for the customer
        SendCustomers.SetGraphQLClient(MockClient);
        ShopifyStore.SetRange(Code, SpfyStoreCustomerLink."Shopify Store Code");
        SendCustomers.MarkCustomerAlreadyOnShopify(Customer, ShopifyStore, false, false, false);

        // [THEN] The link carries that Shopify customer's id
        _Assert.AreEqual('5003', AssignedCustomerId(SpfyStoreCustomerLink), 'A Shopify customer with the same address must be linked');
    end;

    [Test]
    procedure UpdateSyncStatus_AddressWithSurroundingSpaces_IsLookedUpWithoutThem()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] Update Sync. Status looks up an address typed with surrounding spaces without them, and links the Shopify customer that has it.
        Initialize();

        // [GIVEN] A customer not linked to Shopify yet, whose address was typed with surrounding spaces
        CreateCustomer(' padded@npretail.test ', false, false, Customer, SpfyStoreCustomerLink);

        // [GIVEN] Shopify answering only a lookup of the bare address
        MockClient.AddResponse(_FindCustomerTok, '"padded@npretail.test"', CustomerFoundResponse('5008', 'padded@npretail.test'));
        MockClient.AddResponse(_GetCustomerTok, CustomerDataResponse('5008', 'padded@npretail.test'));

        // [WHEN] Update Sync. Status runs for the customer
        SendCustomers.SetGraphQLClient(MockClient);
        ShopifyStore.SetRange(Code, SpfyStoreCustomerLink."Shopify Store Code");
        SendCustomers.MarkCustomerAlreadyOnShopify(Customer, ShopifyStore, false, false, false);

        // [THEN] The link carries that Shopify customer's id
        _Assert.AreEqual('5008', AssignedCustomerId(SpfyStoreCustomerLink), 'The Shopify customer with the bare address must be linked');
    end;

    [Test]
    procedure UpdateSyncStatus_ShopifyCustomerLinkedToAnotherCustomer_FailsNamingBoth()
    var
        Customer: Record Customer;
        LinkedCustomer: Record Customer;
        LinkedSpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] Update Sync. Status refuses to link a customer to a Shopify customer already linked to another BC customer, and names both.
        Initialize();

        // [GIVEN] A customer linked to Shopify customer 5004
        CreateCustomer('shared@npretail.test', true, true, LinkedCustomer, LinkedSpfyStoreCustomerLink);
        _Lib.AssignEntryID(LinkedSpfyStoreCustomerLink.RecordId(), '5004');

        // [GIVEN] A second customer in the same store with the same address and no Shopify id
        CreateCustomer('shared@npretail.test', LinkedSpfyStoreCustomerLink."Shopify Store Code", false, false, Customer, SpfyStoreCustomerLink);

        // [GIVEN] Shopify answering the lookup with Shopify customer 5004
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5004', 'shared@npretail.test'));
        MockClient.AddResponse(_GetCustomerTok, CustomerDataResponse('5004', 'shared@npretail.test'));

        // [WHEN] Update Sync. Status runs for the second customer
        SendCustomers.SetGraphQLClient(MockClient);
        ShopifyStore.SetRange(Code, SpfyStoreCustomerLink."Shopify Store Code");
        asserterror SendCustomers.MarkCustomerAlreadyOnShopify(Customer, ShopifyStore, false, false, false);

        // [THEN] The error names the customer already linked and the one being linked
        _Assert.ExpectedError(LinkedCustomer."No." + ',');
        _Assert.ExpectedError(Customer."No." + '.');

        // [THEN] The error came before the Shopify customer was read back to link it
        _Assert.AreEqual(0, MockClient.CountRequestsContaining(_GetCustomerTok), 'A Shopify customer must not be linked to a second BC customer');
    end;

    [Test]
    procedure UpdateSyncStatus_CustomerAlreadyHoldingASharedShopifyId_IsRefreshed()
    var
        Customer: Record Customer;
        OtherCustomer: Record Customer;
        OtherSpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] Update Sync. Status refreshes a customer already linked to a Shopify customer that order import also linked to another BC customer.
        Initialize();

        // [GIVEN] Two customers in the same store with the same address, both linked to Shopify customer 5009
        CreateCustomer('shared@npretail.test', true, true, OtherCustomer, OtherSpfyStoreCustomerLink);
        CreateCustomer('shared@npretail.test', OtherSpfyStoreCustomerLink."Shopify Store Code", true, true, Customer, SpfyStoreCustomerLink);
        _Lib.AssignEntryID(SpfyStoreCustomerLink.RecordId(), '5009');
        _Lib.AssignEntryID(OtherSpfyStoreCustomerLink.RecordId(), '5009');

        // [GIVEN] Shopify answering the lookup with Shopify customer 5009
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5009', 'shared@npretail.test'));
        MockClient.AddResponse(_GetCustomerTok, CustomerDataResponse('5009', 'shared@npretail.test'));

        // [WHEN] Update Sync. Status runs for the second customer
        SendCustomers.SetGraphQLClient(MockClient);
        ShopifyStore.SetRange(Code, SpfyStoreCustomerLink."Shopify Store Code");
        SendCustomers.MarkCustomerAlreadyOnShopify(Customer, ShopifyStore, false, false, false);

        // [THEN] The customer was refreshed from Shopify customer 5009 and keeps its link
        _Assert.AreEqual(1, MockClient.CountRequestsContaining(_GetCustomerTok), 'The customer must be refreshed from its Shopify customer');
        _Assert.AreEqual('5009', AssignedCustomerId(SpfyStoreCustomerLink), 'The customer must keep its link');
    end;

    [Test]
    procedure TaskListUpdateSyncStatus_CustomerAlreadyHoldingASharedShopifyId_IsRefreshed()
    var
        Customer: Record Customer;
        OtherCustomer: Record Customer;
        OtherSpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Task Send Customers";
    begin
        // [SCENARIO] On the Task List, Update Sync. Status refreshes a customer already linked to a Shopify customer that order import also linked to another BC customer.
        Initialize();

        // [GIVEN] Two customers in the same store with the same address, both linked to Shopify customer 5009
        CreateCustomer('shared@npretail.test', true, true, OtherCustomer, OtherSpfyStoreCustomerLink);
        CreateCustomer('shared@npretail.test', OtherSpfyStoreCustomerLink."Shopify Store Code", true, true, Customer, SpfyStoreCustomerLink);
        _Lib.AssignEntryID(SpfyStoreCustomerLink.RecordId(), '5009');
        _Lib.AssignEntryID(OtherSpfyStoreCustomerLink.RecordId(), '5009');

        // [GIVEN] Shopify answering the lookup with Shopify customer 5009
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5009', 'shared@npretail.test'));
        MockClient.AddResponse(_GetCustomerTok, CustomerDataResponse('5009', 'shared@npretail.test'));

        // [WHEN] Update Sync. Status runs for the second customer
        SendCustomers.SetGraphQLClient(MockClient);
        ShopifyStore.SetRange(Code, SpfyStoreCustomerLink."Shopify Store Code");
        SendCustomers.MarkCustomerAlreadyOnShopify(Customer, ShopifyStore, false, false, false);

        // [THEN] The customer was refreshed from Shopify customer 5009 and keeps its link
        _Assert.AreEqual(1, MockClient.CountRequestsContaining(_GetCustomerTok), 'The customer must be refreshed from its Shopify customer');
        _Assert.AreEqual('5009', AssignedCustomerId(SpfyStoreCustomerLink), 'The customer must keep its link');
    end;

    [Test]
    procedure FindCustomerByShopifyId_SeveralCustomersLinked_FindsEveryOneInTheStore()
    var
        CustomerA: Record Customer;
        CustomerB: Record Customer;
        CustomerC: Record Customer;
        FoundSpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreCustomerLinkA: Record "NPR Spfy Store-Customer Link";
        SpfyStoreCustomerLinkB: Record "NPR Spfy Store-Customer Link";
        SpfyStoreCustomerLinkC: Record "NPR Spfy Store-Customer Link";
        SpfyCustomerMgt: Codeunit "NPR Spfy Customer Mgt.";
    begin
        // [SCENARIO] Finding the BC customers linked to a Shopify customer returns every one linked in the store, whatever order the links were made in.
        Initialize();

        // [GIVEN] Customers A and C in one store and customer B in another, all linked to Shopify customer 5010, B's link made last
        CreateCustomer('a@npretail.test', true, true, CustomerA, SpfyStoreCustomerLinkA);
        CreateCustomer('c@npretail.test', SpfyStoreCustomerLinkA."Shopify Store Code", true, true, CustomerC, SpfyStoreCustomerLinkC);
        CreateCustomer('b@npretail.test', true, true, CustomerB, SpfyStoreCustomerLinkB);
        _Lib.AssignEntryID(SpfyStoreCustomerLinkA.RecordId(), '5010');
        _Lib.AssignEntryID(SpfyStoreCustomerLinkC.RecordId(), '5010');
        _Lib.AssignEntryID(SpfyStoreCustomerLinkB.RecordId(), '5010');

        // [WHEN] The customers linked to Shopify customer 5010 in A's store are looked up
        SpfyCustomerMgt.FindCustomerByShopifyID(SpfyStoreCustomerLinkA."Shopify Store Code", '5010', FoundSpfyStoreCustomerLink);

        // [THEN] A and C are found, and B from the other store is not
        _Assert.AreEqual(2, FoundSpfyStoreCustomerLink.Count(), 'Every customer linked in the store must be found, and only those');
        FoundSpfyStoreCustomerLink.SetRange("No.", CustomerA."No.");
        _Assert.IsFalse(FoundSpfyStoreCustomerLink.IsEmpty(), 'Customer A must be found');
        FoundSpfyStoreCustomerLink.SetRange("No.", CustomerC."No.");
        _Assert.IsFalse(FoundSpfyStoreCustomerLink.IsEmpty(), 'Customer C must be found');
    end;

    [Test]
    procedure CustomerSync_ShopifyCustomerLinkedToAnotherCustomer_FailsWithoutUpdatingIt()
    var
        Customer: Record Customer;
        LinkedCustomer: Record Customer;
        NcTask: Record "NPR Nc Task";
        LinkedSpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] Syncing a customer whose address belongs to a Shopify customer already linked to another BC customer fails before Shopify is updated.
        Initialize();

        // [GIVEN] A customer linked to Shopify customer 5004
        CreateCustomer('shared@npretail.test', true, true, LinkedCustomer, LinkedSpfyStoreCustomerLink);
        _Lib.AssignEntryID(LinkedSpfyStoreCustomerLink.RecordId(), '5004');

        // [GIVEN] A second sync-enabled customer in the same store with the same address, no Shopify id, and a modify task
        CreateCustomer('shared@npretail.test', LinkedSpfyStoreCustomerLink."Shopify Store Code", true, true, Customer, SpfyStoreCustomerLink);
        CreateNcTask(Customer, SpfyStoreCustomerLink."Shopify Store Code", NcTask.Type::Modify, NcTask);

        // [GIVEN] Shopify answering the lookup with Shopify customer 5004
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5004', 'shared@npretail.test'));
        AddCustomerWriteResponses(MockClient, '5005', '5004', 'shared@npretail.test');

        // [WHEN] The customer sync runs for the second customer
        SendCustomers.SetGraphQLClient(MockClient);
        asserterror SendCustomers.Run(NcTask);

        // [THEN] The error names the customer already linked
        _Assert.ExpectedError(LinkedCustomer."No." + ',');

        // [THEN] Shopify customer 5004 was not updated with the second customer's data
        _Assert.AreEqual(0, MockClient.CountRequestsContaining(_CustomerUpdateTok), 'A Shopify customer linked to another BC customer must not be updated');
    end;

    [Test]
    procedure TaskListCustomerSync_ShopifyCustomerLinkedToAnotherCustomer_FailsWithoutUpdatingIt()
    var
        Customer: Record Customer;
        LinkedCustomer: Record Customer;
        LinkedSpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Task Send Customers";
    begin
        // [SCENARIO] On the Task List, syncing a customer whose address belongs to a Shopify customer already linked to another BC customer fails before Shopify is updated.
        Initialize();

        // [GIVEN] A customer linked to Shopify customer 5004
        CreateCustomer('shared@npretail.test', true, true, LinkedCustomer, LinkedSpfyStoreCustomerLink);
        _Lib.AssignEntryID(LinkedSpfyStoreCustomerLink.RecordId(), '5004');

        // [GIVEN] A second sync-enabled customer in the same store with the same address, no Shopify id, and a modify task
        CreateCustomer('shared@npretail.test', LinkedSpfyStoreCustomerLink."Shopify Store Code", true, true, Customer, SpfyStoreCustomerLink);
        EnqueueCustomerTask(Customer, SpfyStoreCustomerLink."Shopify Store Code", "NPR Spfy Task Op"::Modify, SpfyTask);

        // [GIVEN] Shopify answering the lookup with Shopify customer 5004
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5004', 'shared@npretail.test'));
        AddCustomerWriteResponses(MockClient, '5005', '5004', 'shared@npretail.test');

        // [WHEN] The Task List customer sync runs for the second customer
        SendCustomers.SetGraphQLClient(MockClient);
        asserterror SendCustomers.Run(SpfyTask);

        // [THEN] The error names the customer already linked
        _Assert.ExpectedError(LinkedCustomer."No." + ',');

        // [THEN] Shopify customer 5004 was not updated with the second customer's data
        _Assert.AreEqual(0, MockClient.CountRequestsContaining(_CustomerUpdateTok), 'A Shopify customer linked to another BC customer must not be updated');
    end;

    [Test]
    procedure DisablingSync_CustomerWithoutShopifyId_DeletesNothingInShopify()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] Turning off sync for a customer that was never linked to a Shopify customer deletes nothing in Shopify and just disables the link.
        Initialize();

        // [GIVEN] A customer whose sync was switched off before it ever got a Shopify id, and the delete task that follows
        CreateCustomer('test@npretail.test', false, true, Customer, SpfyStoreCustomerLink);
        CreateNcTask(Customer, SpfyStoreCustomerLink."Shopify Store Code", NcTask.Type::Delete, NcTask);

        // [GIVEN] Shopify holding a customer with the same address, ready to be deleted
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5006', 'test@npretail.test'));
        MockClient.AddResponse(_CustomerDeleteTok, '{"data":{"customerDelete":{"deletedCustomerId":"gid://shopify/Customer/5006","userErrors":[]}}}');

        // [WHEN] The customer sync runs the delete task
        SendCustomers.SetGraphQLClient(MockClient);
        SendCustomers.Run(NcTask);

        // [THEN] Shopify was not contacted at all
        _Assert.AreEqual(0, MockClient.RequestCount(), 'A customer never linked to Shopify must not be looked up or deleted there');

        // [THEN] The link is disabled
        SpfyStoreCustomerLink.Find();
        _Assert.IsFalse(SpfyStoreCustomerLink."Synchronization Is Enabled", 'The link must be disabled');
    end;

    [Test]
    procedure TaskListDisablingSync_CustomerWithoutShopifyId_DeletesNothingInShopify()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Task Send Customers";
    begin
        // [SCENARIO] On the Task List, turning off sync for a customer that was never linked to a Shopify customer deletes nothing in Shopify and just disables the link.
        Initialize();

        // [GIVEN] A customer whose sync was switched off before it ever got a Shopify id, and the delete task that follows
        CreateCustomer('test@npretail.test', false, true, Customer, SpfyStoreCustomerLink);
        EnqueueCustomerTask(Customer, SpfyStoreCustomerLink."Shopify Store Code", "NPR Spfy Task Op"::Delete, SpfyTask);

        // [GIVEN] Shopify holding a customer with the same address, ready to be deleted
        MockClient.AddResponse(_FindCustomerTok, CustomerFoundResponse('5006', 'test@npretail.test'));
        MockClient.AddResponse(_CustomerDeleteTok, '{"data":{"customerDelete":{"deletedCustomerId":"gid://shopify/Customer/5006","userErrors":[]}}}');

        // [WHEN] The Task List customer sync runs the delete task
        SendCustomers.SetGraphQLClient(MockClient);
        SendCustomers.Run(SpfyTask);

        // [THEN] Shopify was not contacted at all
        _Assert.AreEqual(0, MockClient.RequestCount(), 'A customer never linked to Shopify must not be looked up or deleted there');

        // [THEN] The link is disabled
        SpfyStoreCustomerLink.Find();
        _Assert.IsFalse(SpfyStoreCustomerLink."Synchronization Is Enabled", 'The link must be disabled');
    end;

    [Test]
    procedure DisablingSync_CustomerWithShopifyId_DeletesThatShopifyCustomer()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] Turning off sync for a customer linked to a Shopify customer still deletes that Shopify customer by its id, without a lookup by e-mail.
        Initialize();

        // [GIVEN] A customer linked to Shopify customer 5007 whose sync was switched off, and the delete task that follows
        CreateCustomer('test@npretail.test', false, true, Customer, SpfyStoreCustomerLink);
        _Lib.AssignEntryID(SpfyStoreCustomerLink.RecordId(), '5007');
        CreateNcTask(Customer, SpfyStoreCustomerLink."Shopify Store Code", NcTask.Type::Delete, NcTask);

        // [GIVEN] Shopify accepting the delete of customer 5007 only
        MockClient.AddResponse(_CustomerDeleteTok, 'gid://shopify/Customer/5007', '{"data":{"customerDelete":{"deletedCustomerId":"gid://shopify/Customer/5007","userErrors":[]}}}');

        // [WHEN] The customer sync runs the delete task
        SendCustomers.SetGraphQLClient(MockClient);
        SendCustomers.Run(NcTask);

        // [THEN] Shopify customer 5007 was deleted, and nobody was looked up by e-mail
        _Assert.AreEqual(1, MockClient.CountRequestsContaining(_CustomerDeleteTok), 'The linked Shopify customer must be deleted');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining(_FindCustomerTok), 'A linked customer must be deleted by its id, not looked up by e-mail');

        // [THEN] The link is disabled
        SpfyStoreCustomerLink.Find();
        _Assert.IsFalse(SpfyStoreCustomerLink."Synchronization Is Enabled", 'The link must be disabled');
    end;

    [Test]
    procedure TaskListDisablingSync_CustomerWithShopifyId_DeletesThatShopifyCustomer()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendCustomers: Codeunit "NPR Spfy Task Send Customers";
    begin
        // [SCENARIO] On the Task List, turning off sync for a customer linked to a Shopify customer still deletes that Shopify customer by its id, without a lookup by e-mail.
        Initialize();

        // [GIVEN] A customer linked to Shopify customer 5007 whose sync was switched off, and the delete task that follows
        CreateCustomer('test@npretail.test', false, true, Customer, SpfyStoreCustomerLink);
        _Lib.AssignEntryID(SpfyStoreCustomerLink.RecordId(), '5007');
        EnqueueCustomerTask(Customer, SpfyStoreCustomerLink."Shopify Store Code", "NPR Spfy Task Op"::Delete, SpfyTask);

        // [GIVEN] Shopify accepting the delete of customer 5007 only
        MockClient.AddResponse(_CustomerDeleteTok, 'gid://shopify/Customer/5007', '{"data":{"customerDelete":{"deletedCustomerId":"gid://shopify/Customer/5007","userErrors":[]}}}');

        // [WHEN] The Task List customer sync runs the delete task
        SendCustomers.SetGraphQLClient(MockClient);
        SendCustomers.Run(SpfyTask);

        // [THEN] Shopify customer 5007 was deleted, and nobody was looked up by e-mail
        _Assert.AreEqual(1, MockClient.CountRequestsContaining(_CustomerDeleteTok), 'The linked Shopify customer must be deleted');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining(_FindCustomerTok), 'A linked customer must be deleted by its id, not looked up by e-mail');

        // [THEN] The link is disabled
        SpfyStoreCustomerLink.Find();
        _Assert.IsFalse(SpfyStoreCustomerLink."Synchronization Is Enabled", 'The link must be disabled');
    end;

    local procedure CreateCustomer(Email: Text[80]; SyncToStore: Boolean; SyncEnabled: Boolean; var Customer: Record Customer; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    begin
        CreateCustomer(Email, _Lib.CreateStore(false, false, false, true, false), SyncToStore, SyncEnabled, Customer, SpfyStoreCustomerLink);
    end;

    local procedure CreateCustomer(Email: Text[80]; StoreCode: Code[20]; SyncToStore: Boolean; SyncEnabled: Boolean; var Customer: Record Customer; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    begin
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, SyncToStore, SyncEnabled);
        Customer."E-Mail" := Email;
        Customer.Modify(false);
        SpfyStoreCustomerLink."E-Mail" := Email;
        SpfyStoreCustomerLink.Modify(false);
    end;

    local procedure CreateNcTask(Customer: Record Customer; StoreCode: Code[20]; TaskType: Option; var NcTask: Record "NPR Nc Task")
    begin
        NcTask.Init();
        NcTask."Table No." := Database::Customer;
        NcTask."Record ID" := Customer.RecordId();
        NcTask."Record Value" := Customer."No.";
        NcTask."Store Code" := StoreCode;
        NcTask.Type := TaskType;
        NcTask.Insert(true);
    end;

    local procedure EnqueueCustomerTask(Customer: Record Customer; StoreCode: Code[20]; Op: Enum "NPR Spfy Task Op"; var SpfyTask: Record "NPR Spfy Task")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Customer);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, Customer.RecordId(), Customer."No.", Op, 0DT, 0DT,
            "NPR Spfy Reuse Delayed NC Task"::Any, CurrentDateTime(), SpfyTask);
    end;

    local procedure AssignedCustomerId(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"): Text
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreCustomerLink.RecordId(), "NPR Spfy ID Type"::"Entry ID"));
    end;

    /// <summary>
    /// Answers every request a customer sync can send after the lookup: a create returning CreatedID, an update of
    /// UpdatedID, and the read-back. The update answer is there so that code which wrongly updates UpdatedID runs to
    /// the end and fails on the test's assertion rather than on a missing canned response.
    /// </summary>
    local procedure AddCustomerWriteResponses(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; CreatedID: Text; UpdatedID: Text; Email: Text)
    begin
        MockClient.AddResponse(_MetafieldDefinitionsTok, '{"data":{"metafieldDefinitions":{"edges":[],"pageInfo":{"hasNextPage":false,"endCursor":""}}}}');
        MockClient.AddResponse(_CustomerCreateTok, '{"data":{"customerCreate":{"customer":{"id":"gid://shopify/Customer/' + CreatedID + '","defaultAddress":null},"userErrors":[]}}}');
        MockClient.AddResponse(_CustomerUpdateTok, '{"data":{"customerUpdate":{"customer":{"id":"gid://shopify/Customer/' + UpdatedID + '"},"userErrors":[]}}}');
        MockClient.AddResponse(_GetCustomerTok, CustomerDataResponse(CreatedID, Email));
    end;

    local procedure CustomerFoundResponse(ShopifyCustomerID: Text; Email: Text): Text
    begin
        exit('{"data":{"customer":{"id":"gid://shopify/Customer/' + ShopifyCustomerID + '","defaultEmailAddress":{"emailAddress":"' + Email + '"}}}}');
    end;

    local procedure CustomerDataResponse(ShopifyCustomerID: Text; Email: Text): Text
    begin
        exit('{"data":{"customer":{"id":"gid://shopify/Customer/' + ShopifyCustomerID + '","firstName":"First","lastName":"Last","defaultEmailAddress":{"emailAddress":"' + Email + '","marketingState":"NOT_SUBSCRIBED"},"defaultPhoneNumber":null,"defaultAddress":null}}}');
    end;
}
