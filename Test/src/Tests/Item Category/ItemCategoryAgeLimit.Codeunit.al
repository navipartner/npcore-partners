codeunit 85657 "NPR Item Category Age Limit"
{
    // [FEATURE] "NPR Age Limit" on Item Category is pushed down to child categories like "NPR Blocked".

    Subtype = Test;

    [Test]
    [HandlerFunctions('ConfirmYes')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateAgeLimit_PushesLimitDownTheTree()
    var
        Assert: Codeunit Assert;
        Parent: Record "Item Category";
        Child: Record "Item Category";
        Grandchild: Record "Item Category";
    begin
        // [SCENARIO] Setting the age limit on a parent, and confirming, sets it on every category below.
        CreateCategoryTree(Parent, Child, Grandchild);

        Parent.Validate("NPR Age Limit", 18);
        Parent.Modify(true);

        Child.Find();
        Grandchild.Find();
        Assert.AreEqual(18, Child."NPR Age Limit", 'Child should inherit the age limit');
        Assert.AreEqual(18, Grandchild."NPR Age Limit", 'Grandchild should inherit the age limit');
    end;

    [Test]
    [HandlerFunctions('ConfirmNo')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateAgeLimit_Declined_LeavesChildrenUnchanged()
    var
        Assert: Codeunit Assert;
        Parent: Record "Item Category";
        Child: Record "Item Category";
        Grandchild: Record "Item Category";
    begin
        // [SCENARIO] Declining the confirmation keeps the limit on the parent only.
        CreateCategoryTree(Parent, Child, Grandchild);

        Parent.Validate("NPR Age Limit", 18);
        Parent.Modify(true);

        Child.Find();
        Grandchild.Find();
        Assert.AreEqual(18, Parent."NPR Age Limit", 'Parent should keep its own limit');
        Assert.AreEqual(0, Child."NPR Age Limit", 'Child should stay unrestricted');
        Assert.AreEqual(0, Grandchild."NPR Age Limit", 'Grandchild should stay unrestricted');
    end;

    [Test]
    [HandlerFunctions('ConfirmYes')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateAgeLimit_DoesNotLowerStricterChild()
    var
        Assert: Codeunit Assert;
        Parent: Record "Item Category";
        Child: Record "Item Category";
        Grandchild: Record "Item Category";
    begin
        // [SCENARIO] Pushing a limit down raises lower limits below it and leaves a stricter child limit untouched.
        CreateCategoryTree(Parent, Child, Grandchild);
        Child."NPR Age Limit" := 20;
        Child.Modify();

        Parent.Validate("NPR Age Limit", 18);
        Parent.Modify(true);

        Child.Find();
        Grandchild.Find();
        Assert.AreEqual(20, Child."NPR Age Limit", 'A stricter child limit must not be lowered');
        Assert.AreEqual(18, Grandchild."NPR Age Limit", 'The grandchild should be raised to the pushed limit');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NewChildCategory_InheritsParentAgeLimit()
    var
        Assert: Codeunit Assert;
        NPRLibraryInventory: Codeunit "NPR Library - Inventory";
        Parent: Record "Item Category";
        Child: Record "Item Category";
    begin
        // [SCENARIO] A category that gets a parent assigned takes over the parent's age limit with the other setup.
        NPRLibraryInventory.CreateItemCategory(Parent);
        Parent."NPR Age Limit" := 16;
        Parent.Modify();

        NPRLibraryInventory.CreateItemCategory(Child);
        Child.Validate("Parent Category", Parent.Code);
        Child.Modify(true);

        Child.Find();
        Assert.AreEqual(16, Child."NPR Age Limit", 'Child should inherit the parent age limit');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NewParentWithLowerLimit_KeepsChildLimit()
    var
        Assert: Codeunit Assert;
        NPRLibraryInventory: Codeunit "NPR Library - Inventory";
        Parent: Record "Item Category";
        Child: Record "Item Category";
    begin
        // [SCENARIO] Moving a restricted category under an unrestricted parent does not drop its limit.
        NPRLibraryInventory.CreateItemCategory(Parent);
        NPRLibraryInventory.CreateItemCategory(Child);
        Child."NPR Age Limit" := 18;
        Child.Modify();

        Child.Validate("Parent Category", Parent.Code);
        Child.Modify(true);

        Child.Find();
        Assert.AreEqual(18, Child."NPR Age Limit", 'Child should keep its own, higher limit');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CopySetupToChildren_RaisesButNeverLowersLimit()
    var
        Assert: Codeunit Assert;
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
        Parent: Record "Item Category";
        Child: Record "Item Category";
        Grandchild: Record "Item Category";
    begin
        // [SCENARIO] Pushing the parent setup down raises a lower child limit and leaves a higher one alone.
        CreateCategoryTree(Parent, Child, Grandchild);
        Parent."NPR Age Limit" := 16;
        Parent.Modify();
        Child."NPR Age Limit" := 18;
        Child.Modify();

        ItemCategoryMgt.CopySetupToChildren(Parent, true);

        Child.Find();
        Grandchild.Find();
        Assert.AreEqual(18, Child."NPR Age Limit", 'A higher child limit must not be lowered');
        Assert.AreEqual(18, Grandchild."NPR Age Limit", 'The grandchild should be raised to its parent limit');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateAgeLimit_NothingToRaise_AsksNoConfirmation()
    var
        Assert: Codeunit Assert;
        Parent: Record "Item Category";
        Child: Record "Item Category";
        Grandchild: Record "Item Category";
    begin
        // [SCENARIO] Setting a limit that cannot raise any category below asks for no confirmation and changes nothing below.
        CreateCategoryTree(Parent, Child, Grandchild);
        Child."NPR Age Limit" := 18;
        Child.Modify();
        Grandchild."NPR Age Limit" := 18;
        Grandchild.Modify();

        Parent.Validate("NPR Age Limit", 0);
        Parent.Modify(true);
        Parent.Validate("NPR Age Limit", 16);
        Parent.Modify(true);

        Child.Find();
        Grandchild.Find();
        Assert.AreEqual(16, Parent."NPR Age Limit", 'Parent should take the new limit');
        Assert.AreEqual(18, Child."NPR Age Limit", 'Child with a higher limit must be left alone');
        Assert.AreEqual(18, Grandchild."NPR Age Limit", 'Grandchild with a higher limit must be left alone');
    end;

    local procedure CreateCategoryTree(var Parent: Record "Item Category"; var Child: Record "Item Category"; var Grandchild: Record "Item Category")
    var
        NPRLibraryInventory: Codeunit "NPR Library - Inventory";
    begin
        NPRLibraryInventory.CreateItemCategory(Parent);
        NPRLibraryInventory.CreateItemCategory(Child);
        Child."Parent Category" := Parent.Code;
        Child.Modify();
        NPRLibraryInventory.CreateItemCategory(Grandchild);
        Grandchild."Parent Category" := Child.Code;
        Grandchild.Modify();
    end;

    [ConfirmHandler]
    procedure ConfirmYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmNo(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;
}
