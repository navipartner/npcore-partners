codeunit 85518 "NPR Spfy Cust Change Tests"
{
    // [FEATURE] Shopify customer change subscriber: xRec is left for later subscribers, Microsoft's credit limit approval completes, edits still propagate to store links, and changes pulled from Shopify reach the customer's contact
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";

    local procedure Initialize()
    var
        Workflow: Record Workflow;
    begin
        _Lib.EnsureIntegrationEnabled();
        Workflow.SetRange(Enabled, true);
        Workflow.ModifyAll(Enabled, false, false);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ApprovedCreditLimitChangeIsAppliedWithoutANewApprovalRequest()
    var
        ApprovalEntry: Record "Approval Entry";
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        CustomerCard: TestPage "Customer Card";
    begin
        // [SCENARIO] Approving a credit limit change applies the new value once instead of sending the change for approval again.
        Initialize();

        // [GIVEN] An enabled credit limit change approval workflow and the current user with an approver
        CreateEnabledCreditLimitWorkflow();
        SetupCurrentUserWithApprover();

        // [GIVEN] A customer linked to a Shopify store with no credit limit
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);

        // [GIVEN] The credit limit raised on the customer card, which the workflow reverts and sends for approval
        CustomerCard.OpenEdit();
        CustomerCard.GoToRecord(Customer);
        CustomerCard."Credit Limit (LCY)".SetValue(1000);
        CustomerCard.Close();
        Customer.Get(Customer."No.");
        _Assert.AreEqual(0, Customer."Credit Limit (LCY)", 'The workflow must hold the credit limit back until approval');
        _Assert.AreEqual(1, OpenApprovalEntryCount(Customer.RecordId()), 'One approval request must be open before approval');

        // [WHEN] The request is approved
        ApprovalEntry.SetRange("Record ID to Approve", Customer.RecordId());
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        ApprovalEntry.FindFirst();
        // Approve this one entry by its key: approving the filtered set would re-read any request the approval itself spawns.
        ApprovalEntry.SetRecFilter();
        ApprovalsMgmt.ApproveApprovalRequests(ApprovalEntry);

        // [THEN] The customer holds the approved credit limit
        Customer.Get(Customer."No.");
        _Assert.AreEqual(1000, Customer."Credit Limit (LCY)", 'The approved credit limit must be applied');

        // [THEN] No new approval request was created and the only one is approved
        _Assert.AreEqual(0, OpenApprovalEntryCount(Customer.RecordId()), 'Applying the approved value must not send the change for approval again');
        ApprovalEntry.Reset();
        ApprovalEntry.SetRange("Record ID to Approve", Customer.RecordId());
        _Assert.AreEqual(1, ApprovalEntry.Count(), 'Exactly one approval entry must exist for the customer');
        ApprovalEntry.FindFirst();
        _Assert.AreEqual(ApprovalEntry.Status::Approved, ApprovalEntry.Status, 'The approval entry must be approved');
    end;

    [Test]
    procedure CodeDrivenCustomerModifyLeavesXRecUntouchedForLaterSubscribers()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        TestXRecProbe: Codeunit "NPR Test xRec Probe";
    begin
        // [SCENARIO] A code-driven modify of a Shopify-linked customer reaches later subscribers with the xRec the platform supplied, which carries the name being written rather than the name on disk.
        Initialize();

        // [GIVEN] A customer linked to a Shopify store
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);

        // [GIVEN] A probe subscriber observing the modify event
        BindSubscription(TestXRecProbe);

        // [WHEN] The customer's name is changed from code
        Customer.Name := 'Renamed from code';
        Customer.Modify(true);

        // [THEN] The probe saw the modify with xRec still carrying the new name
        _Assert.IsTrue(TestXRecProbe.ModifySeen(Database::Customer), 'The probe must observe the customer modify');
        _Assert.IsTrue(TestXRecProbe.XRecCarriesRecValue(Database::Customer), 'A Shopify subscriber must not replace xRec on a customer modify');
    end;

    [Test]
    procedure CodeDrivenEmailChangePropagatesOnlyToLinksStillHoldingTheOldEmail()
    var
        Customer: Record Customer;
        MatchingLink: Record "NPR Spfy Store-Customer Link";
        DivergedLink: Record "NPR Spfy Store-Customer Link";
    begin
        // [SCENARIO] Changing a customer's e-mail from code updates the store links that still hold the previous e-mail and leaves a link with its own e-mail alone.
        Initialize();

        // [GIVEN] A customer linked to two stores, one link holding the customer's e-mail and one holding a different e-mail
        _Lib.CreateCustomerWithLink(Customer, MatchingLink, _Lib.CreateStore(false, false, false, true, false), true, true);
        CreateSecondLink(Customer, DivergedLink, 'own@example.com');

        // [WHEN] The e-mail is changed from code
        Customer."E-Mail" := 'new@example.com';
        Customer.Modify(true);

        // [THEN] The matching link carries the new e-mail
        MatchingLink.Get(MatchingLink.Type, MatchingLink."No.", MatchingLink."Shopify Store Code");
        _Assert.AreEqual('new@example.com', MatchingLink."E-Mail", 'A link that matched the old e-mail must follow the customer');

        // [THEN] The diverged link keeps its own e-mail
        DivergedLink.Get(DivergedLink.Type, DivergedLink."No.", DivergedLink."Shopify Store Code");
        _Assert.AreEqual('own@example.com', DivergedLink."E-Mail", 'A link with its own e-mail must not be overwritten');
    end;

    [Test]
    procedure LinkSubscribersSeeTheCustomerAsWrittenWhenAnEmailChangePropagates()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        TestSpfyLinkObserver: Codeunit "NPR Test Spfy Link Observer";
    begin
        // [SCENARIO] When a customer e-mail change reaches a store link, a subscriber on the link finds the new e-mail already saved on the customer.
        Initialize();

        // [GIVEN] A customer linked to a Shopify store, the link holding the customer's e-mail
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);

        // [GIVEN] An observer of link modifies
        BindSubscription(TestSpfyLinkObserver);

        // [WHEN] The e-mail is changed from code
        Customer."E-Mail" := 'saved@example.com';
        Customer.Modify(true);

        // [THEN] The observer saw the link change and read the new e-mail from the customer on disk
        _Assert.IsTrue(TestSpfyLinkObserver.LinkModifySeen(), 'The e-mail change must reach the store link');
        _Assert.AreEqual('saved@example.com', TestSpfyLinkObserver.CustomerEmailOnDisk(), 'A link subscriber must find the customer change already saved');
    end;

    [Test]
    procedure BeforeImagesOfNestedModifiesComeBackInnermostFirst()
    var
        OuterImage: Record Customer;
        NestedImage: Record Customer;
        TakenImage: Record Customer;
        SpfyCustomerBeforeImage: Codeunit "NPR Spfy Customer Before Image";
        NestedTaken: Boolean;
        OuterTaken: Boolean;
        ThirdTaken: Boolean;
        NestedEmail: Text;
        OuterEmail: Text;
    begin
        // [SCENARIO] The before-images of an outer and a nested modify of one customer come back nested first, so the nested modify cannot consume the image of the outer one.
        Initialize();

        // [GIVEN] The outer modify's before-image and then the nested modify's before-image remembered for one customer
        OuterImage."No." := _Lib.NextCode('CU', MaxStrLen(OuterImage."No."));
        OuterImage."E-Mail" := 'outer@example.com';
        SpfyCustomerBeforeImage.Remember(OuterImage);
        NestedImage := OuterImage;
        NestedImage."E-Mail" := 'nested@example.com';
        SpfyCustomerBeforeImage.Remember(NestedImage);

        // [WHEN] The images are taken back three times
        NestedTaken := SpfyCustomerBeforeImage.Take(OuterImage."No.", TakenImage);
        NestedEmail := TakenImage."E-Mail";
        OuterTaken := SpfyCustomerBeforeImage.Take(OuterImage."No.", TakenImage);
        OuterEmail := TakenImage."E-Mail";
        ThirdTaken := SpfyCustomerBeforeImage.Take(OuterImage."No.", TakenImage);

        // [THEN] The nested image comes first, then the outer one, carrying the customer's number
        _Assert.IsTrue(NestedTaken, 'The nested image must be handed out');
        _Assert.AreEqual('nested@example.com', NestedEmail, 'The nested modify must get its own image first');
        _Assert.IsTrue(OuterTaken, 'The outer image must still be there after the nested one');
        _Assert.AreEqual('outer@example.com', OuterEmail, 'The outer modify must get the image remembered for it');
        _Assert.AreEqual(OuterImage."No.", TakenImage."No.", 'The image must carry the customer number');

        // [THEN] Nothing is left once both are taken
        _Assert.IsFalse(ThirdTaken, 'No image may be left after both were taken');
    end;

    [Test]
    procedure BeforeImageStackFullDropsTheOldestImage()
    var
        Images: array[21] of Record Customer;
        TakenImage: Record Customer;
        SpfyCustomerBeforeImage: Codeunit "NPR Spfy Customer Before Image";
        i: Integer;
        OldestTaken: Boolean;
        SecondTaken: Boolean;
        NewestTaken: Boolean;
        NewestEmail: Text;
    begin
        // [SCENARIO] Remembering one image more than the stack holds drops the oldest image and keeps the rest.
        Initialize();

        // [GIVEN] Twenty images remembered for twenty different customers, the most the stack holds
        for i := 1 to ArrayLen(Images) do begin
            Images[i]."No." := _Lib.NextCode('CU', MaxStrLen(Images[i]."No."));
            Images[i]."E-Mail" := CopyStr('image' + Format(i) + '@example.com', 1, MaxStrLen(Images[i]."E-Mail"));
        end;
        for i := 1 to ArrayLen(Images) - 1 do
            SpfyCustomerBeforeImage.Remember(Images[i]);

        // [WHEN] One more image is remembered
        SpfyCustomerBeforeImage.Remember(Images[ArrayLen(Images)]);

        // [THEN] The oldest image is gone, the second oldest and the newest are still there
        NewestTaken := SpfyCustomerBeforeImage.Take(Images[ArrayLen(Images)]."No.", TakenImage);
        NewestEmail := TakenImage."E-Mail";
        SecondTaken := SpfyCustomerBeforeImage.Take(Images[2]."No.", TakenImage);
        OldestTaken := SpfyCustomerBeforeImage.Take(Images[1]."No.", TakenImage);
        for i := 3 to ArrayLen(Images) - 1 do
            SpfyCustomerBeforeImage.Take(Images[i]."No.", TakenImage);
        _Assert.IsTrue(NewestTaken, 'The newest image must be kept');
        _Assert.AreEqual(Images[ArrayLen(Images)]."E-Mail", NewestEmail, 'The newest image must keep its values');
        _Assert.IsTrue(SecondTaken, 'The second oldest image must be kept');
        _Assert.IsFalse(OldestTaken, 'The oldest image must be dropped when the stack is full');
    end;

    [Test]
    procedure CodeDrivenAddressChangePropagatesToLinkAndFlagsItForSync()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        // [SCENARIO] Changing a customer's address from code copies the address to a store link with no address of its own and marks it as updated in BC.
        Initialize();

        // [GIVEN] A customer linked to a Shopify store with a blank link address
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);

        // [WHEN] The address is changed from code
        Customer.Address := 'Main Street 1';
        Customer.City := 'Copenhagen';
        Customer."Post Code" := '1000';
        Customer.Modify(true);

        // [THEN] The link carries the new address and is flagged for sync
        SpfyStoreCustomerLink.Get(SpfyStoreCustomerLink.Type, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code");
        _Assert.AreEqual('Main Street 1', SpfyStoreCustomerLink.Address, 'The link must receive the address');
        _Assert.AreEqual('Copenhagen', SpfyStoreCustomerLink.City, 'The link must receive the city');
        _Assert.AreEqual('1000', SpfyStoreCustomerLink."Post Code", 'The link must receive the post code');
        _Assert.IsTrue(SpfyStoreCustomerLink."Address Updated in BC", 'The link must be flagged as updated in BC');
    end;

    [Test]
    procedure CodeDrivenNameChangePropagatesToLinkWithoutANameOfItsOwn()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        // [SCENARIO] Changing a customer's name from code writes the parsed first and last name to a store link that holds no name of its own.
        Initialize();

        // [GIVEN] A customer linked to a Shopify store with blank link names
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);
        SpfyStoreCustomerLink."First Name" := '';
        SpfyStoreCustomerLink."Last Name" := '';
        SpfyStoreCustomerLink.Modify(false);

        // [WHEN] The name is changed from code
        Customer.Name := 'Anna Larsen';
        Customer.Modify(true);

        // [THEN] The link carries the parsed first and last name
        SpfyStoreCustomerLink.Get(SpfyStoreCustomerLink.Type, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code");
        _Assert.AreEqual('Anna', SpfyStoreCustomerLink."First Name", 'The link must receive the first name');
        _Assert.AreEqual('Larsen', SpfyStoreCustomerLink."Last Name", 'The link must receive the last name');
    end;

    [Test]
    procedure CodeDrivenNameAndAddressChangePropagateToLinkStillHoldingTheOldValues()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        // [SCENARIO] Changing a customer's name and address from code updates a store link that still holds the previous parsed name and address.
        Initialize();

        // [GIVEN] A customer named Test Customer at Old Street 1, linked to a Shopify store whose link holds the same name and address
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);
        Customer.Address := 'Old Street 1';
        Customer.Modify(false);
        SpfyStoreCustomerLink.Get(SpfyStoreCustomerLink.Type, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code");
        SpfyStoreCustomerLink."First Name" := 'Test';
        SpfyStoreCustomerLink."Last Name" := 'Customer';
        SpfyStoreCustomerLink.Address := 'Old Street 1';
        SpfyStoreCustomerLink."Address Updated in BC" := false;
        SpfyStoreCustomerLink.Modify(false);

        // [WHEN] The name and the address are changed from code
        Customer.Name := 'Anna Larsen';
        Customer.Address := 'New Street 2';
        Customer.Modify(true);

        // [THEN] The link carries the new parsed name and the new address, flagged for sync
        SpfyStoreCustomerLink.Get(SpfyStoreCustomerLink.Type, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code");
        _Assert.AreEqual('Anna', SpfyStoreCustomerLink."First Name", 'A link that held the old first name must follow the customer');
        _Assert.AreEqual('Larsen', SpfyStoreCustomerLink."Last Name", 'A link that held the old last name must follow the customer');
        _Assert.AreEqual('New Street 2', SpfyStoreCustomerLink.Address, 'A link that held the old address must follow the customer');
        _Assert.IsTrue(SpfyStoreCustomerLink."Address Updated in BC", 'The link must be flagged as updated in BC');
    end;

    [Test]
    procedure CodeDrivenPhoneChangePropagatesToLinkStillHoldingTheOldPhone()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        // [SCENARIO] Changing a customer's phone number from code updates a store link that still holds the previous phone number.
        Initialize();

        // [GIVEN] A customer with a phone number, linked to a Shopify store whose link holds the same phone number
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);
        Customer."Phone No." := '+4511111111';
        Customer.Modify(false);
        SpfyStoreCustomerLink.Get(SpfyStoreCustomerLink.Type, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code");
        SpfyStoreCustomerLink."Phone No." := '+4511111111';
        SpfyStoreCustomerLink.Modify(false);

        // [WHEN] The phone number is changed from code
        Customer."Phone No." := '+4522222222';
        Customer.Modify(true);

        // [THEN] The link carries the new phone number
        SpfyStoreCustomerLink.Get(SpfyStoreCustomerLink.Type, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code");
        _Assert.AreEqual('+4522222222', SpfyStoreCustomerLink."Phone No.", 'A link that matched the old phone number must follow the customer');
    end;

    [Test]
    procedure PartialRecordModifyAssigningAnUnloadedFieldStillPropagates()
    var
        Customer: Record Customer;
        PartialCustomer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        // [SCENARIO] An e-mail assigned on a partial record that never loaded the e-mail field still reaches a store link that held the old e-mail.
        Initialize();

        // [GIVEN] A customer linked to a Shopify store
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);

        // [WHEN] The e-mail is assigned through a record that loaded only the last statement number
        PartialCustomer.SetLoadFields("Last Statement No.");
        PartialCustomer.Get(Customer."No.");
        PartialCustomer."E-Mail" := 'partial@example.com';
        PartialCustomer.Modify();

        // [THEN] The link carries the new e-mail
        SpfyStoreCustomerLink.Get(SpfyStoreCustomerLink.Type, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code");
        _Assert.AreEqual('partial@example.com', SpfyStoreCustomerLink."E-Mail", 'A field assigned on a partial record must still propagate');
    end;

    [Test]
    procedure PartialRecordModifyLoadingOnlyTheNameStillPropagatesTheName()
    var
        Customer: Record Customer;
        PartialCustomer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        // [SCENARIO] A name changed on a partial record that loaded the name but not its second line still reaches a store link without a name of its own.
        Initialize();

        // [GIVEN] A customer linked to a Shopify store with blank link names
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);
        SpfyStoreCustomerLink."First Name" := '';
        SpfyStoreCustomerLink."Last Name" := '';
        SpfyStoreCustomerLink.Modify(false);

        // [WHEN] The name is changed through a record that loaded only the name
        PartialCustomer.SetLoadFields(Name);
        PartialCustomer.Get(Customer."No.");
        PartialCustomer.Name := 'Bo Berg';
        PartialCustomer.Modify();

        // [THEN] The link carries the parsed first and last name
        SpfyStoreCustomerLink.Get(SpfyStoreCustomerLink.Type, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code");
        _Assert.AreEqual('Bo', SpfyStoreCustomerLink."First Name", 'The link must receive the first name');
        _Assert.AreEqual('Berg', SpfyStoreCustomerLink."Last Name", 'The link must receive the last name');
    end;

    [Test]
    procedure PartialRecordModifyOfLinkedCustomerSucceedsAndLeavesLinksUnchanged()
    var
        Customer: Record Customer;
        PartialCustomer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        TestSpfyLinkObserver: Codeunit "NPR Test Spfy Link Observer";
    begin
        // [SCENARIO] Modifying a linked customer through a partial record, as the Customer Statement report does, succeeds and leaves the store link untouched.
        Initialize();

        // [GIVEN] A customer linked to a Shopify store
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);

        // [GIVEN] An observer of link modifies
        BindSubscription(TestSpfyLinkObserver);

        // [WHEN] The last statement number is changed through a record that loads only that field
        PartialCustomer.SetLoadFields("Last Statement No.");
        PartialCustomer.Get(Customer."No.");
        PartialCustomer."Last Statement No." += 1;
        PartialCustomer.Modify();

        // [THEN] No store link was modified
        _Assert.IsFalse(TestSpfyLinkObserver.LinkModifySeen(), 'A partial-record modify of an unrelated field must not touch the store link');
    end;

    [Test]
    procedure EmailPulledFromShopifyReachesTheCustomersContact()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyMockGraphQLClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfySendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] An e-mail changed in Shopify and pulled in by the customer sync updates the customer's contact as well as the customer.
        Initialize();

        // [GIVEN] A customer with a contact, linked to a Shopify store that holds the same e-mail
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);
        CreateContactForCustomer(Customer, Contact);

        // [GIVEN] Shopify answering the customer query with a new e-mail
        SpfyMockGraphQLClient.AddResponse('GetCustomer', ShopifyCustomerResponse('new@example.com'));
        SpfySendCustomers.SetGraphQLClient(SpfyMockGraphQLClient);

        // [WHEN] The customer sync pulls the customer from Shopify
        SpfySendCustomers.RetrieveShopifyCustomerAndUpdateBCCustomerWithDataFromShopify(SpfyStoreCustomerLink, '1001', false, false, false);

        // [THEN] The customer and its contact carry the new e-mail
        Customer.Get(Customer."No.");
        _Assert.AreEqual('new@example.com', Customer."E-Mail", 'The customer must take the e-mail from Shopify');
        Contact.Get(Contact."No.");
        _Assert.AreEqual('new@example.com', Contact."E-Mail", 'The customer''s contact must follow the e-mail from Shopify');
    end;

    [Test]
    procedure EmailPulledFromShopifyByTheTaskListReachesTheCustomersContact()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyMockGraphQLClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyTaskSendCustomers: Codeunit "NPR Spfy Task Send Customers";
    begin
        // [SCENARIO] An e-mail changed in Shopify and pulled in by the Task List customer sync updates the customer's contact as well as the customer.
        Initialize();

        // [GIVEN] A customer with a contact, linked to a Shopify store that holds the same e-mail
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);
        CreateContactForCustomer(Customer, Contact);

        // [GIVEN] Shopify answering the customer query with a new e-mail
        SpfyMockGraphQLClient.AddResponse('GetCustomer', ShopifyCustomerResponse('new@example.com'));
        SpfyTaskSendCustomers.SetGraphQLClient(SpfyMockGraphQLClient);

        // [WHEN] The Task List customer sync pulls the customer from Shopify
        SpfyTaskSendCustomers.RetrieveShopifyCustomerAndUpdateBCCustomerWithDataFromShopify(SpfyStoreCustomerLink, '1001', false, false, false);

        // [THEN] The customer and its contact carry the new e-mail
        Customer.Get(Customer."No.");
        _Assert.AreEqual('new@example.com', Customer."E-Mail", 'The customer must take the e-mail from Shopify');
        Contact.Get(Contact."No.");
        _Assert.AreEqual('new@example.com', Contact."E-Mail", 'The customer''s contact must follow the e-mail from Shopify');
    end;

    [Test]
    procedure UnchangedPullFromShopifyLeavesTheContactAlone()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyMockGraphQLClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfySendCustomers: Codeunit "NPR Spfy Send Customers";
    begin
        // [SCENARIO] A customer sync pull that brings back the values the customer already has leaves its contact untouched.
        Initialize();

        // [GIVEN] A customer linked to a Shopify store that holds the same e-mail, with a person contact whose first name was set by hand
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);
        CreateContactForCustomer(Customer, Contact);
        Contact.Type := Contact.Type::Person;
        Contact."Company No." := '';
        Contact."First Name" := 'Set by hand';
        Contact.Modify(false);

        // [GIVEN] Shopify answering the customer query with the e-mail the customer already has
        SpfyMockGraphQLClient.AddResponse('GetCustomer', ShopifyCustomerResponse(Customer."E-Mail"));
        SpfySendCustomers.SetGraphQLClient(SpfyMockGraphQLClient);

        // [WHEN] The customer sync pulls the customer from Shopify
        SpfySendCustomers.RetrieveShopifyCustomerAndUpdateBCCustomerWithDataFromShopify(SpfyStoreCustomerLink, '1001', false, false, false);

        // [THEN] The contact keeps the first name set by hand
        Contact.Get(Contact."No.");
        _Assert.AreEqual('Set by hand', Contact."First Name", 'A pull that changes nothing must leave the contact alone');
    end;

    [Test]
    procedure UnchangedPullFromShopifyByTheTaskListLeavesTheContactAlone()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyMockGraphQLClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyTaskSendCustomers: Codeunit "NPR Spfy Task Send Customers";
    begin
        // [SCENARIO] A Task List customer sync pull that brings back the values the customer already has leaves its contact untouched.
        Initialize();

        // [GIVEN] A customer linked to a Shopify store that holds the same e-mail, with a person contact whose first name was set by hand
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, _Lib.CreateStore(false, false, false, true, false), true, true);
        CreateContactForCustomer(Customer, Contact);
        Contact.Type := Contact.Type::Person;
        Contact."Company No." := '';
        Contact."First Name" := 'Set by hand';
        Contact.Modify(false);

        // [GIVEN] Shopify answering the customer query with the e-mail the customer already has
        SpfyMockGraphQLClient.AddResponse('GetCustomer', ShopifyCustomerResponse(Customer."E-Mail"));
        SpfyTaskSendCustomers.SetGraphQLClient(SpfyMockGraphQLClient);

        // [WHEN] The Task List customer sync pulls the customer from Shopify
        SpfyTaskSendCustomers.RetrieveShopifyCustomerAndUpdateBCCustomerWithDataFromShopify(SpfyStoreCustomerLink, '1001', false, false, false);

        // [THEN] The contact keeps the first name set by hand
        Contact.Get(Contact."No.");
        _Assert.AreEqual('Set by hand', Contact."First Name", 'A pull that changes nothing must leave the contact alone');
    end;

    local procedure CreateContactForCustomer(Customer: Record Customer; var Contact: Record Contact)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        Contact.Init();
        Contact."No." := _Lib.NextCode('CT', MaxStrLen(Contact."No."));
        Contact.Type := Contact.Type::Company;
        Contact."Company No." := Contact."No.";
        Contact.Name := Customer.Name;
        Contact."E-Mail" := Customer."E-Mail";
        Contact.Insert(false);

        ContactBusinessRelation.Init();
        ContactBusinessRelation."Contact No." := Contact."No.";
        ContactBusinessRelation."Business Relation Code" := 'CUST';
        ContactBusinessRelation."Link to Table" := ContactBusinessRelation."Link to Table"::Customer;
        ContactBusinessRelation."No." := Customer."No.";
        ContactBusinessRelation.Insert(false);
    end;

    local procedure ShopifyCustomerResponse(Email: Text): Text
    begin
        exit('{"data":{"customer":{"id":"gid://shopify/Customer/1001","firstName":"First","lastName":"Last","defaultEmailAddress":{"emailAddress":"' + Email + '"}}}}');
    end;

    local procedure CreateEnabledCreditLimitWorkflow()
    var
        Customer: Record Customer;
        Workflow: Record Workflow;
        WorkflowRule: Record "Workflow Rule";
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowSetup: Codeunit "Workflow Setup";
        BlankDateFormula: DateFormula;
    begin
        WorkflowSetup.InitWorkflow();
        Workflow.Init();
        Workflow.Code := _Lib.NextCode('WF', MaxStrLen(Workflow.Code));
        Workflow.Description := 'Credit limit change approval';
        Workflow.Insert(true);
        WorkflowSetup.InitWorkflowStepArgument(
            WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver, WorkflowStepArgument."Approver Limit Type"::"Direct Approver",
            0, '', BlankDateFormula, false);
        WorkflowSetup.InsertRecChangedApprovalWorkflowSteps(
            Workflow, WorkflowRule.Operator::Increased,
            WorkflowEventHandling.RunWorkflowOnCustomerChangedCode(),
            WorkflowResponseHandling.CreateApprovalRequestsCode(),
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode(),
            WorkflowStepArgument, Database::Customer, Customer.FieldNo("Credit Limit (LCY)"),
            'The credit limit change was sent for approval.');
        Workflow.Validate(Enabled, true);
        Workflow.Modify(true);
    end;

    local procedure SetupCurrentUserWithApprover()
    var
        ApproverUserSetup: Record "User Setup";
        UserSetup: Record "User Setup";
        LibraryDocumentApprovals: Codeunit "Library - Document Approvals";
    begin
        LibraryDocumentApprovals.CreateMockupUserSetup(ApproverUserSetup);
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert(true);
        end;
        UserSetup."Approver ID" := ApproverUserSetup."User ID";
        UserSetup."Approval Administrator" := true;
        UserSetup.Modify(true);
    end;

    local procedure CreateSecondLink(Customer: Record Customer; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; LinkEmail: Text[80])
    begin
        SpfyStoreCustomerLink.Init();
        SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
        SpfyStoreCustomerLink."No." := Customer."No.";
        SpfyStoreCustomerLink."Shopify Store Code" := _Lib.CreateStore(false, false, false, true, false);
        SpfyStoreCustomerLink."E-Mail" := LinkEmail;
        SpfyStoreCustomerLink."Sync. to this Store" := true;
        SpfyStoreCustomerLink."Synchronization Is Enabled" := true;
        SpfyStoreCustomerLink.Insert(false);
    end;

    local procedure OpenApprovalEntryCount(RecordID: RecordId): Integer
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Record ID to Approve", RecordID);
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        exit(ApprovalEntry.Count());
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}
