codeunit 85603 "NPR NpIa Relative Mix Tests"
{
    // [FEATURE] Relative add-on unit prices combined with a mixed discount on a POS sale

    Subtype = Test;

    var
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Assert: Codeunit "Assert";
        _LibraryPOSDiscount: Codeunit "NPR Library - POS Discount";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OneAddOnWithThreeLines_RelativePricesTakeTheMixedDiscount()
    var
        ItemA: Record Item;
        ItemB: Record Item;
        ItemC: Record Item;
        ParentItem: Record Item;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] One add-on brings 3 A, 3 B and 3 C onto the sale, A and B priced relative to their normal price, and buying the set gives 12.5%

        // [GIVEN] A at its normal price of 157 less 21, B at 83 plus 61, C at its normal price of 152, and 12.5% off when all three are bought three each
        InitializeSale(SalePOS);
        CreateItemsAndMixedDiscount(ItemA, ItemB, ItemC);
        CreateSaleItem(ParentItem, 13);
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);

        AddOnNo := CreateAddOn();
        AddAddOnLine(AddOnNo, ItemA, ItemAddOnLine."Use Unit Price"::Relative, -21);
        AddAddOnLine(AddOnNo, ItemB, ItemAddOnLine."Use Unit Price"::Relative, 61);
        AddAddOnLine(AddOnNo, ItemC, ItemAddOnLine."Use Unit Price"::"Non-Zero", 0);

        // [WHEN] The add-on is applied to the parent line
        RunItemAddOn(ParentSaleLine, AddOnNo);

        // [THEN] Each add-on line costs its own price and takes the 12.5%: 3 x 136, 3 x 144 and 3 x 152
        VerifyAddOnLine(SalePOS, ItemA, 136, 357);
        VerifyAddOnLine(SalePOS, ItemB, 144, 378);
        VerifyAddOnLine(SalePOS, ItemC, 152, 399);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ThreeAddOnsWithOneLineEach_RelativePricesTakeTheMixedDiscountOnceTheSetIsComplete()
    var
        ItemA: Record Item;
        ItemB: Record Item;
        ItemC: Record Item;
        ParentItem: Record Item;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ParentSaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnANo: Code[20];
        AddOnBNo: Code[20];
        AddOnCNo: Code[20];
    begin
        // [SCENARIO] Three separate add-ons each bring three of A, B or C onto the sale, and the set they make together gives 12.5%

        // [GIVEN] A at its normal price of 157 less 21, B at 83 plus 61, C at its normal price of 152, and 12.5% off when all three are bought three each
        InitializeSale(SalePOS);
        CreateItemsAndMixedDiscount(ItemA, ItemB, ItemC);
        CreateSaleItem(ParentItem, 13);
        AddParentItemLine(ParentItem, 1, SalePOS, ParentSaleLine);

        AddOnANo := CreateAddOn();
        AddAddOnLine(AddOnANo, ItemA, ItemAddOnLine."Use Unit Price"::Relative, -21);
        AddOnBNo := CreateAddOn();
        AddAddOnLine(AddOnBNo, ItemB, ItemAddOnLine."Use Unit Price"::Relative, 61);
        AddOnCNo := CreateAddOn();
        AddAddOnLine(AddOnCNo, ItemC, ItemAddOnLine."Use Unit Price"::"Non-Zero", 0);

        // [WHEN] The three add-ons are applied to the parent line one after another
        RunItemAddOn(ParentSaleLine, AddOnANo);
        RunItemAddOn(ParentSaleLine, AddOnBNo);
        RunItemAddOn(ParentSaleLine, AddOnCNo);

        // [THEN] Each add-on line costs its own price and takes the 12.5%: 3 x 136, 3 x 144 and 3 x 152
        VerifyAddOnLine(SalePOS, ItemA, 136, 357);
        VerifyAddOnLine(SalePOS, ItemB, 144, 378);
        VerifyAddOnLine(SalePOS, ItemC, 152, 399);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MixedDiscountCapThroughAPackageLine_LeavesThePackageUndiscounted()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        FirstPackageLine: Record "NPR POS Sale Line";
        SecondPackageLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] A capped mixed discount that would cover only part of a package line's entries leaves that package out, as a package is discounted whole or not at all

        // [GIVEN] A package of one entry and one ride pass per unit, and 12.5% off at most 3 entries
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateEntryDiscount(EntryItem, 12.5, 1, 3);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [GIVEN] A first package line of 1, whose entry takes 1 of the 3 discounted entries
        AddParentItemLine(PackageItem, 1, SalePOS, FirstPackageLine);
        RunItemAddOn(FirstPackageLine, AddOnNo);
        AddParentItemLine(PackageItem, 5, SalePOS, SecondPackageLine);

        // [WHEN] The second package line of 5 gets its entries, of which only 2 fit under the cap
        RunItemAddOn(SecondPackageLine, AddOnNo);

        // [THEN] The first package keeps the 12.5%
        FindPackageEntryLine(FirstPackageLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(119, EntrySaleLine."Amount Including VAT", 'The entry of the first package should keep the 12.5%, 136 less 12.5%.');

        // [THEN] The 5 entries of the second package stay one line at their normal price
        FindPackageEntryLine(SecondPackageLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(5, EntrySaleLine.Quantity, 'The entries of the second package should not be split.');
        _Assert.AreEqual(680, EntrySaleLine."Amount Including VAT", 'The 5 entries of the second package should come to 5 x 136.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MixedDiscountCapOnWholePackageLines_DiscountsWithoutSplitting()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        FirstPackageLine: Record "NPR POS Sale Line";
        SecondPackageLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Packages entered as lines of 3 and 2 let a cap of 3 fall on a whole line, so the discount applies without splitting a package

        // [GIVEN] A package of one entry and one ride pass per unit, and 12.5% off at most 3 entries
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateEntryDiscount(EntryItem, 12.5, 1, 3);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [WHEN] The packages are entered as a line of 3 followed by a line of 2
        AddParentItemLine(PackageItem, 3, SalePOS, FirstPackageLine);
        RunItemAddOn(FirstPackageLine, AddOnNo);
        AddParentItemLine(PackageItem, 2, SalePOS, SecondPackageLine);
        RunItemAddOn(SecondPackageLine, AddOnNo);

        // [THEN] No entry line was split off
        EntrySaleLine.SetRange("Register No.", SalePOS."Register No.");
        EntrySaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        EntrySaleLine.SetRange("No.", EntryItem."No.");
        _Assert.AreEqual(2, EntrySaleLine.Count(), 'Each package line should keep exactly one entry line.');

        // [THEN] The 3 entries of the first package take the 12.5% and the 2 of the second keep their normal price
        EntrySaleLine.SetRange(Quantity, 3);
        EntrySaleLine.FindFirst();
        _Assert.IsTrue(EntrySaleLine."Discount Type" = EntrySaleLine."Discount Type"::Mix, 'The entries of the first package should take the mixed discount.');
        _Assert.AreEqual(357, EntrySaleLine."Amount Including VAT", 'The 3 entries of the first package should come to 3 x 136 less 12.5%.');

        EntrySaleLine.SetRange(Quantity, 2);
        EntrySaleLine.FindFirst();
        _Assert.AreEqual(272, EntrySaleLine."Amount Including VAT", 'The 2 entries of the second package should keep their normal price.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MixedDiscountCapOnAPlainLine_SplitsTheLine()
    var
        EntryItem: Record Item;
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] Outside a package, a capped mixed discount still splits the line, so the entries under the cap are discounted and the rest are not

        // [GIVEN] An entry sold on its own, and 12.5% off at most 3 entries
        InitializeSale(SalePOS);
        CreateNamedSaleItem(EntryItem, 'Entry', 136);
        CreateEntryDiscount(EntryItem, 12.5, 1, 3);

        // [WHEN] A line of 5 entries is entered
        AddParentItemLine(EntryItem, 5, SalePOS, EntrySaleLine);

        // [THEN] The line is split in two
        EntrySaleLine.SetRange("Register No.", SalePOS."Register No.");
        EntrySaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        EntrySaleLine.SetRange("No.", EntryItem."No.");
        _Assert.AreEqual(2, EntrySaleLine.Count(), 'The capped discount should split the entry line in two.');

        // [THEN] The 3 entries under the cap take the 12.5% and the 2 over it keep their normal price
        EntrySaleLine.SetRange(Quantity, 3);
        EntrySaleLine.FindFirst();
        _Assert.IsTrue(EntrySaleLine."Discount Type" = EntrySaleLine."Discount Type"::Mix, 'The 3 entries under the cap should take the mixed discount.');
        _Assert.AreEqual(357, EntrySaleLine."Amount Including VAT", 'The 3 entries under the cap should come to 3 x 136 less 12.5%.');

        EntrySaleLine.SetRange(Quantity, 2);
        EntrySaleLine.FindFirst();
        _Assert.AreEqual(272, EntrySaleLine."Amount Including VAT", 'The 2 entries over the cap should keep their normal price.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangingPackageQuantity_RecalculatesTheMixedDiscountOnItsAddOns()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        PackageSaleLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Raising a package's quantity raises its entries with it, and a discount that needs at least 3 entries applies as soon as they qualify

        // [GIVEN] A package of one entry and one ride pass per unit, and 12.5% off entries bought at least 3 at a time
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateEntryDiscount(EntryItem, 12.5, 3, 0);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [GIVEN] One package on the sale, whose single entry does not qualify yet
        AddParentItemLine(PackageItem, 1, SalePOS, PackageSaleLine);
        RunItemAddOn(PackageSaleLine, AddOnNo);

        // [WHEN] The package quantity is changed to 4
        SetSaleLineQuantity(PackageSaleLine, 4);

        // [THEN] The 4 entries take the 12.5%
        FindSaleLine(SalePOS, EntryItem."No.", EntrySaleLine);
        _Assert.AreEqual(4, EntrySaleLine.Quantity, 'The entries should follow the package quantity.');
        _Assert.IsTrue(EntrySaleLine."Discount Type" = EntrySaleLine."Discount Type"::Mix, 'The entries should take the mixed discount once they qualify.');
        _Assert.AreEqual(476, EntrySaleLine."Amount Including VAT", 'The 4 entries should come to 4 x 136 less 12.5%.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangingPackageQuantityThroughTheCap_LeavesThePackageUndiscounted()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        PackageSaleLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Raising a package's quantity past a discount cap leaves the package out of the discount, as a package is discounted whole or not at all

        // [GIVEN] A package of one entry and one ride pass per unit, and 12.5% off at most 3 entries
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateEntryDiscount(EntryItem, 12.5, 1, 3);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [GIVEN] One package on the sale, whose entry takes the 12.5%
        AddParentItemLine(PackageItem, 1, SalePOS, PackageSaleLine);
        RunItemAddOn(PackageSaleLine, AddOnNo);

        FindPackageEntryLine(PackageSaleLine, EntryItem, EntrySaleLine);
        _Assert.IsTrue(EntrySaleLine."Discount Type" = EntrySaleLine."Discount Type"::Mix, 'The entry should take the mixed discount before the change.');

        // [WHEN] The package quantity is changed to 5, of which only 3 entries fit under the cap
        SetSaleLineQuantity(PackageSaleLine, 5);

        // [THEN] The 5 entries stay one line at their normal price
        FindPackageEntryLine(PackageSaleLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(5, EntrySaleLine.Quantity, 'The entries should follow the package quantity without being split.');
        _Assert.AreEqual(680, EntrySaleLine."Amount Including VAT", 'The 5 entries should come to 5 x 136.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompetingMixedDiscounts_TheBetterDiscountTakesThePackageWhole()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        PackageSaleLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] A capped discount that would split a package is only weighed against a better one, so the better one applies and the package stays whole

        // [GIVEN] A package of one entry and one ride pass per unit, 12.5% off at most 3 entries, and 25% off all entries
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateEntryDiscount(EntryItem, 12.5, 1, 3);
        CreateEntryDiscount(EntryItem, 25, 1, 0);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [WHEN] A package line of 5 gets its entries
        AddParentItemLine(PackageItem, 5, SalePOS, PackageSaleLine);
        RunItemAddOn(PackageSaleLine, AddOnNo);

        // [THEN] The 5 entries stay on one line and take the 25%
        FindSaleLine(SalePOS, EntryItem."No.", EntrySaleLine);
        _Assert.AreEqual(5, EntrySaleLine.Quantity, 'The entry line should not be split.');
        _Assert.AreEqual(510, EntrySaleLine."Amount Including VAT", 'The 5 entries should come to 5 x 136 less 25%.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeletingAPackageUnderACap_RemovesTheDiscountTheRemainingWholePackagesDoNotQualifyFor()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        FirstPackageLine: Record "NPR POS Sale Line";
        SecondPackageLine: Record "NPR POS Sale Line";
        ThirdPackageLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] After a package is deleted, the packages left only reach the minimum of a capped discount by counting part of a package, so they lose the discount

        // [GIVEN] A package of one entry and one ride pass per unit, and 12.5% off 3 entries: at least 3 and at most 3
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateEntryDiscount(EntryItem, 12.5, 3, 3);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [GIVEN] Package lines of 1, 2 and 2, where the first two fill the 3 discounted entries and the third falls outside the cap
        AddParentItemLine(PackageItem, 1, SalePOS, FirstPackageLine);
        RunItemAddOn(FirstPackageLine, AddOnNo);
        AddParentItemLine(PackageItem, 2, SalePOS, SecondPackageLine);
        RunItemAddOn(SecondPackageLine, AddOnNo);
        AddParentItemLine(PackageItem, 2, SalePOS, ThirdPackageLine);
        RunItemAddOn(ThirdPackageLine, AddOnNo);

        FindPackageEntryLine(FirstPackageLine, EntryItem, EntrySaleLine);
        _Assert.IsTrue(EntrySaleLine."Discount Type" = EntrySaleLine."Discount Type"::Mix, 'The entry of the first package should take the discount before the delete.');
        FindPackageEntryLine(SecondPackageLine, EntryItem, EntrySaleLine);
        _Assert.IsTrue(EntrySaleLine."Discount Type" = EntrySaleLine."Discount Type"::Mix, 'The entries of the second package should take the discount before the delete.');
        FindPackageEntryLine(ThirdPackageLine, EntryItem, EntrySaleLine);
        _Assert.IsFalse(EntrySaleLine."Discount Type" = EntrySaleLine."Discount Type"::Mix, 'The entries of the third package should fall outside the cap before the delete.');

        // [WHEN] The package line of 1 is deleted
        DeleteSaleLine(FirstPackageLine);

        // [THEN] The 2 entries of the second package do not reach the minimum on their own and lose the discount
        FindPackageEntryLine(SecondPackageLine, EntryItem, EntrySaleLine);
        _Assert.IsFalse(EntrySaleLine."Discount Type" = EntrySaleLine."Discount Type"::Mix, 'The entries of the second package should lose the discount, as they do not reach the minimum of 3 on their own.');
        _Assert.AreEqual(272, EntrySaleLine."Amount Including VAT", 'The 2 entries of the second package should come to 2 x 136.');

        // [THEN] The entries of the third package are not split to make up the 3
        FindPackageEntryLine(ThirdPackageLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(2, EntrySaleLine.Quantity, 'The entries of the third package should not be split.');
        _Assert.AreEqual(272, EntrySaleLine."Amount Including VAT", 'The 2 entries of the third package should come to 2 x 136.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PackagesUnderACap_TheDiscountFollowsTheWholePackagesThatFit()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        FirstPackageLine: Record "NPR POS Sale Line";
        SecondPackageLine: Record "NPR POS Sale Line";
        ThirdPackageLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] A discount on 3 to 5 entries goes to the whole packages that fit under the cap, so it moves between packages as lines are added, changed and deleted

        // [GIVEN] A package of one entry and one ride pass per unit, and 12.5% off 3 to 5 entries
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateEntryDiscount(EntryItem, 12.5, 3, 5);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [WHEN] A first package of 1 is added
        AddParentItemLine(PackageItem, 1, SalePOS, FirstPackageLine);
        RunItemAddOn(FirstPackageLine, AddOnNo);

        // [THEN] Its single entry is below the minimum
        VerifyPackageEntriesDiscounted(FirstPackageLine, EntryItem, false, 'A single entry should be below the minimum of 3.');

        // [WHEN] The first package is raised to 4
        SetSaleLineQuantity(FirstPackageLine, 4);

        // [THEN] Its 4 entries qualify
        VerifyPackageEntriesDiscounted(FirstPackageLine, EntryItem, true, 'The 4 entries of the first package should qualify.');

        // [WHEN] A second package of 1 is added
        AddParentItemLine(PackageItem, 1, SalePOS, SecondPackageLine);
        RunItemAddOn(SecondPackageLine, AddOnNo);

        // [THEN] It fills the cap of 5
        VerifyPackageEntriesDiscounted(SecondPackageLine, EntryItem, true, 'The second package should fill the cap of 5.');

        // [WHEN] A third package of 1 is added
        AddParentItemLine(PackageItem, 1, SalePOS, ThirdPackageLine);
        RunItemAddOn(ThirdPackageLine, AddOnNo);

        // [THEN] The first two keep the discount and the third falls outside the full cap
        VerifyPackageEntriesDiscounted(FirstPackageLine, EntryItem, true, 'The first package should keep the discount when the third is added.');
        VerifyPackageEntriesDiscounted(SecondPackageLine, EntryItem, true, 'The second package should keep the discount when the third is added.');
        VerifyPackageEntriesDiscounted(ThirdPackageLine, EntryItem, false, 'The third package should fall outside the full cap.');

        // [WHEN] The second package is raised to 2, so 4 + 2 no longer fits under the cap
        SetSaleLineQuantity(SecondPackageLine, 2);

        // [THEN] The second package is passed over and the third takes the room it left
        VerifyPackageEntriesDiscounted(FirstPackageLine, EntryItem, true, 'The first package should keep the discount when the second grows.');
        VerifyPackageEntriesDiscounted(SecondPackageLine, EntryItem, false, 'The second package should no longer fit whole under the cap.');
        VerifyPackageEntriesDiscounted(ThirdPackageLine, EntryItem, true, 'The third package should take the room the second one left.');

        // [WHEN] The first package is deleted
        DeleteSaleLine(FirstPackageLine);

        // [THEN] The 2 + 1 entries left reach the minimum, so both remaining packages take the discount
        VerifyPackageEntriesDiscounted(SecondPackageLine, EntryItem, true, 'The second package should fit again once the first is deleted.');
        VerifyPackageEntriesDiscounted(ThirdPackageLine, EntryItem, true, 'The third package should keep the discount once the first is deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PackagesUnderACap_ALaterPackageThatFillsMoreOfTheCapTakesTheDiscount()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        FirstPackageLine: Record "NPR POS Sale Line";
        SecondPackageLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Under a cap, the discount goes to the whole packages that fill the most of it, whatever order they were entered in

        // [GIVEN] A package of one entry and one ride pass per unit, and 12.5% off 3 to 5 entries
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateEntryDiscount(EntryItem, 12.5, 3, 5);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [GIVEN] A first package of 2, below the minimum on its own
        AddParentItemLine(PackageItem, 2, SalePOS, FirstPackageLine);
        RunItemAddOn(FirstPackageLine, AddOnNo);

        // [WHEN] A second package of 4 is added, which does not fit under the cap together with the first
        AddParentItemLine(PackageItem, 4, SalePOS, SecondPackageLine);
        RunItemAddOn(SecondPackageLine, AddOnNo);

        // [THEN] The 4 entries of the second package take the 12.5%
        FindPackageEntryLine(SecondPackageLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(476, EntrySaleLine."Amount Including VAT", 'The 4 entries of the second package should come to 4 x 136 less 12.5%.');

        // [THEN] The 2 entries of the first package stay whole at their normal price
        FindPackageEntryLine(FirstPackageLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(2, EntrySaleLine.Quantity, 'The entries of the first package should not be split.');
        _Assert.AreEqual(272, EntrySaleLine."Amount Including VAT", 'The 2 entries of the first package should come to 2 x 136.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PackageAndSeparateEntriesUnderACap_OnlyTheSeparateEntriesAreSplit()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        PackageSaleLine: Record "NPR POS Sale Line";
        SeparateEntrySaleLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] Under a cap, a package goes in whole and entries bought on their own make up the rest, so only their line is split

        // [GIVEN] A package of one entry and one ride pass per unit, and 12.5% off at most 5 entries
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateEntryDiscount(EntryItem, 12.5, 1, 5);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [GIVEN] 3 entries bought on their own
        AddParentItemLine(EntryItem, 3, SalePOS, SeparateEntrySaleLine);

        // [WHEN] A package of 4 is added, which goes over the cap together with the 3
        AddParentItemLine(PackageItem, 4, SalePOS, PackageSaleLine);
        RunItemAddOn(PackageSaleLine, AddOnNo);

        // [THEN] The 4 package entries take the 12.5%, still on one line
        FindPackageEntryLine(PackageSaleLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(4, EntrySaleLine.Quantity, 'The package entries should stay on one line.');
        _Assert.AreEqual(476, EntrySaleLine."Amount Including VAT", 'The 4 package entries should come to 4 x 136 less 12.5%.');

        // [THEN] Of the entries bought on their own, 1 fills the cap and 2 keep their normal price
        EntrySaleLine.Reset();
        EntrySaleLine.SetRange("Register No.", SalePOS."Register No.");
        EntrySaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        EntrySaleLine.SetRange("No.", EntryItem."No.");
        EntrySaleLine.SetRange(Quantity, 1);
        EntrySaleLine.FindFirst();
        _Assert.AreEqual(119, EntrySaleLine."Amount Including VAT", 'The entry that fills the cap should come to 136 less 12.5%.');

        EntrySaleLine.SetRange(Quantity, 2);
        EntrySaleLine.FindFirst();
        _Assert.AreEqual(272, EntrySaleLine."Amount Including VAT", 'The 2 entries over the cap should come to 2 x 136.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LotMixOnAPackageLine_FillsTheSetsWithTheWholePackageLine()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        PackageSaleLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SeparateEntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] A lot never cuts through a package line: package entries that do not make whole sets are passed over without an error, and an entry bought on its own can make up the set

        // [GIVEN] A package of one entry and one ride pass per unit, and 12.5% off entries bought in sets of 2
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateLotDiscount(EntryItem, 12.5, 2);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [WHEN] A package line of 3 gets its entries, which make one set of 2 and one entry over
        AddParentItemLine(PackageItem, 3, SalePOS, PackageSaleLine);
        RunItemAddOn(PackageSaleLine, AddOnNo);

        // [THEN] The entries stay whole and undiscounted
        FindPackageEntryLine(PackageSaleLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(3, EntrySaleLine.Quantity, 'The package entries should stay on one line.');
        VerifyPackageEntriesDiscounted(PackageSaleLine, EntryItem, false, 'Entries that do not make whole sets should not take the lot.');

        // [WHEN] An entry is bought on its own, which makes 4 entries: 2 whole sets with the package entries
        AddParentItemLine(EntryItem, 1, SalePOS, SeparateEntrySaleLine);

        // [THEN] The package entries take the 12.5%, still on one line
        FindPackageEntryLine(PackageSaleLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(3, EntrySaleLine.Quantity, 'The package entries should stay on one line.');
        _Assert.AreEqual(357, EntrySaleLine."Amount Including VAT", 'The 3 package entries should come to 3 x 136 less 12.5%.');

        // [THEN] The separate entry takes the 12.5% too
        SeparateEntrySaleLine.Find();
        _Assert.AreEqual(119, SeparateEntrySaleLine."Amount Including VAT", 'The separate entry should come to 136 less 12.5%.');

        // [WHEN] The package quantity is changed to 4, so the package entries fill both sets on their own
        SetSaleLineQuantity(PackageSaleLine, 4);

        // [THEN] All 4 package entries take the 12.5%, and the separate entry is left over without it
        FindPackageEntryLine(PackageSaleLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(476, EntrySaleLine."Amount Including VAT", 'The 4 entries should come to 4 x 136 less 12.5%.');
        SeparateEntrySaleLine.Find();
        _Assert.IsTrue(SeparateEntrySaleLine."Discount Type" <> SeparateEntrySaleLine."Discount Type"::Mix, 'An entry bought on its own should not take the lot alone.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LotMixOnPackageLines_FindsTheWholeLinesThatFillTheSets()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        FirstPackageLine: Record "NPR POS Sale Line";
        SecondPackageLine: Record "NPR POS Sale Line";
        ThirdPackageLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] A lot looks past a package line that does not fit, even when it comes first, and takes the package lines that fill whole sets together

        // [GIVEN] A package of one entry and one ride pass per unit, and 12.5% off entries bought in sets of 2
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        CreateLotDiscount(EntryItem, 12.5, 2);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [WHEN] Package lines of 3, 2 and 2 are entered in that order
        AddParentItemLine(PackageItem, 3, SalePOS, FirstPackageLine);
        RunItemAddOn(FirstPackageLine, AddOnNo);
        AddParentItemLine(PackageItem, 2, SalePOS, SecondPackageLine);
        RunItemAddOn(SecondPackageLine, AddOnNo);
        AddParentItemLine(PackageItem, 2, SalePOS, ThirdPackageLine);
        RunItemAddOn(ThirdPackageLine, AddOnNo);

        // [THEN] The two packages of 2 make 2 sets and take the 12.5%
        FindPackageEntryLine(SecondPackageLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(238, EntrySaleLine."Amount Including VAT", 'The 2 entries of the second package should come to 2 x 136 less 12.5%.');
        FindPackageEntryLine(ThirdPackageLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(238, EntrySaleLine."Amount Including VAT", 'The 2 entries of the third package should come to 2 x 136 less 12.5%.');

        // [THEN] The package of 3 stays whole at its normal price
        FindPackageEntryLine(FirstPackageLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(3, EntrySaleLine.Quantity, 'The entries of the first package should not be split.');
        _Assert.AreEqual(408, EntrySaleLine."Amount Including VAT", 'The 3 entries of the first package should come to 3 x 136.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MixedDiscountThatWouldCutAPackageLine_IsIgnoredUntilThePackageLineFits()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        PackageSaleLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] A discount that can only apply by cutting through a package line is passed over without an error, and applies once the package line fits it whole

        // [GIVEN] A package of one entry and one ride pass per unit, and a discount on entries bought 5 or 11 at a time
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        EnableMixedDiscount();
        _LibraryPOSDiscount.CreateMultipleDiscountLevels(EntryItem, 5, 11, 37, 83, false);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);

        // [WHEN] A package line of 7 gets its entries, of which the discount would take 5
        AddParentItemLine(PackageItem, 7, SalePOS, PackageSaleLine);
        RunItemAddOn(PackageSaleLine, AddOnNo);

        // [THEN] The entries stay whole and undiscounted
        FindPackageEntryLine(PackageSaleLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(7, EntrySaleLine.Quantity, 'The package entries should stay on one line.');
        VerifyPackageEntriesDiscounted(PackageSaleLine, EntryItem, false, 'A discount that would cut the package entries should not apply.');

        // [WHEN] The package quantity is changed to 5
        SetSaleLineQuantity(PackageSaleLine, 5);

        // [THEN] The 5 entries take the discount, still on one line
        FindPackageEntryLine(PackageSaleLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(5, EntrySaleLine.Quantity, 'The package entries should stay on one line.');
        VerifyPackageEntriesDiscounted(PackageSaleLine, EntryItem, true, 'A discount the package entries fit whole should apply.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MixedDiscountThatWouldCutAPackageLine_StillDiscountsTheEntriesBoughtOnTheirOwn()
    var
        EntryItem: Record Item;
        RideItem: Record Item;
        PackageItem: Record Item;
        PackageSaleLine: Record "NPR POS Sale Line";
        EntrySaleLine: Record "NPR POS Sale Line";
        SeparateEntrySaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        // [SCENARIO] A discount that would cut through a package line leaves that package line out, so entries bought on their own that fill the discount keep it

        // [GIVEN] A package of one entry and one ride pass per unit, its entry at the normal price of 136 less 17, and a discount of 37 on entries bought 5 at a time (83 on 13)
        InitializeSale(SalePOS);
        CreatePackageItems(EntryItem, RideItem, PackageItem);
        EnableMixedDiscount();
        _LibraryPOSDiscount.CreateMultipleDiscountLevels(EntryItem, 5, 13, 37, 83, false);
        AddOnNo := CreatePerUnitPackage(EntryItem, RideItem);
        SetRelativeUnitPrice(AddOnNo, EntryItem, -17);

        // [GIVEN] 5 entries bought on their own, which take the discount of 37
        AddParentItemLine(EntryItem, 5, SalePOS, SeparateEntrySaleLine);

        // [WHEN] A package line of 7 gets its entries, which are cheaper, so the discount meets them first and would take 5 of the 7
        AddParentItemLine(PackageItem, 7, SalePOS, PackageSaleLine);
        RunItemAddOn(PackageSaleLine, AddOnNo);

        // [THEN] The package entries stay whole and undiscounted
        FindPackageEntryLine(PackageSaleLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(7, EntrySaleLine.Quantity, 'The package entries should stay on one line.');
        VerifyPackageEntriesDiscounted(PackageSaleLine, EntryItem, false, 'A discount that would cut the package entries should leave them out.');

        // [THEN] The 5 entries bought on their own keep the discount
        SeparateEntrySaleLine.Find();
        _Assert.IsTrue(SeparateEntrySaleLine."Discount Type" = SeparateEntrySaleLine."Discount Type"::Mix, 'The entries bought on their own should keep the discount.');
        _Assert.AreEqual(643, SeparateEntrySaleLine."Amount Including VAT", 'The 5 entries bought on their own should come to 5 x 136 less 37.');
    end;

    local procedure VerifyAddOnLine(SalePOS: Record "NPR POS Sale"; Item: Record Item; UnitPrice: Decimal; AmountInclVat: Decimal)
    var
        SaleLine: Record "NPR POS Sale Line";
    begin
        FindSaleLine(SalePOS, Item."No.", SaleLine);
        _Assert.AreEqual(UnitPrice, SaleLine."Unit Price", StrSubstNo('Add-on line %1 should cost %2 before the mixed discount.', Item."No.", UnitPrice));
        _Assert.IsTrue(SaleLine."Discount Type" = SaleLine."Discount Type"::Mix, StrSubstNo('Add-on line %1 should take the mixed discount.', Item."No."));
        _Assert.AreEqual(AmountInclVat, SaleLine."Amount Including VAT", StrSubstNo('Add-on line %1 should come to %2 after the mixed discount.', Item."No.", AmountInclVat));
    end;

    local procedure CreateItemsAndMixedDiscount(var ItemA: Record Item; var ItemB: Record Item; var ItemC: Record Item)
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        CreateSaleItem(ItemA, 157);
        CreateSaleItem(ItemB, 83);
        CreateSaleItem(ItemC, 152);

        EnableMixedDiscount();
        _LibraryPOSDiscount.CreateTotalDiscountPctHeader(MixedDiscount, 12.5, false);
        _LibraryPOSDiscount.CreateDiscountLineWithQty(MixedDiscount, ItemA, "NPR Disc. Grouping Type"::Item, 3);
        _LibraryPOSDiscount.CreateDiscountLineWithQty(MixedDiscount, ItemB, "NPR Disc. Grouping Type"::Item, 3);
        _LibraryPOSDiscount.CreateDiscountLineWithQty(MixedDiscount, ItemC, "NPR Disc. Grouping Type"::Item, 3);
        MixedDiscount.Lot := true;
        MixedDiscount.Modify();
    end;

    local procedure CreatePackageItems(var EntryItem: Record Item; var RideItem: Record Item; var PackageItem: Record Item)
    begin
        CreateNamedSaleItem(EntryItem, 'Entry', 136);
        CreateNamedSaleItem(RideItem, 'Ride pass', 47);
        CreateNamedSaleItem(PackageItem, 'Package', 13);
    end;

    local procedure CreateEntryDiscount(EntryItem: Record Item; DiscountPct: Decimal; MinQuantity: Decimal; MaxQuantity: Decimal)
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        EnableMixedDiscount();
        _LibraryPOSDiscount.CreateTotalDiscountPctHeader(MixedDiscount, DiscountPct, false);
        _LibraryPOSDiscount.CreateDiscountLine(MixedDiscount, EntryItem, "NPR Disc. Grouping Type"::Item);
        MixedDiscount."Min. Quantity" := MinQuantity;
        MixedDiscount."Max. Quantity" := MaxQuantity;
        MixedDiscount.Modify();
    end;

    local procedure CreateLotDiscount(Item: Record Item; DiscountPct: Decimal; QuantityPerSet: Decimal)
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        EnableMixedDiscount();
        _LibraryPOSDiscount.CreateTotalDiscountPctHeader(MixedDiscount, DiscountPct, false);
        _LibraryPOSDiscount.CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, QuantityPerSet);
        MixedDiscount.Lot := true;
        MixedDiscount.Modify();
    end;

    local procedure SetSaleLineQuantity(SaleLine: Record "NPR POS Sale Line"; Quantity: Decimal)
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLine.GetPosition());
        POSSaleLine.SetQuantity(Quantity);
    end;

    local procedure DeleteSaleLine(SaleLine: Record "NPR POS Sale Line")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLine.GetPosition());
        POSSaleLine.DeleteLine();
    end;

    local procedure FindPackageEntryLine(PackageSaleLine: Record "NPR POS Sale Line"; EntryItem: Record Item; var EntrySaleLine: Record "NPR POS Sale Line")
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        SaleLinePOSAddOn.SetRange("Register No.", PackageSaleLine."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", PackageSaleLine."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Applies-to Line No.", PackageSaleLine."Line No.");
        SaleLinePOSAddOn.SetRange(AddOnItemNo, EntryItem."No.");
        SaleLinePOSAddOn.FindFirst();
        EntrySaleLine.Get(SaleLinePOSAddOn."Register No.", SaleLinePOSAddOn."Sales Ticket No.", SaleLinePOSAddOn."Sale Date", SaleLinePOSAddOn."Sale Type", SaleLinePOSAddOn."Sale Line No.");
    end;

    local procedure VerifyPackageEntriesDiscounted(PackageSaleLine: Record "NPR POS Sale Line"; EntryItem: Record Item; Discounted: Boolean; Message: Text)
    var
        EntrySaleLine: Record "NPR POS Sale Line";
    begin
        FindPackageEntryLine(PackageSaleLine, EntryItem, EntrySaleLine);
        _Assert.AreEqual(Discounted, EntrySaleLine."Discount Type" = EntrySaleLine."Discount Type"::Mix, Message);
    end;

    local procedure CreatePerUnitPackage(EntryItem: Record Item; RideItem: Record Item) AddOnNo: Code[20]
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
    begin
        AddOnNo := CreateAddOn();
        ItemAddOn.Get(AddOnNo);
        ItemAddOn.WalletTemplate := true;
        ItemAddOn.Modify();
        AddPerUnitAddOnLine(AddOnNo, EntryItem);
        AddPerUnitAddOnLine(AddOnNo, RideItem);
    end;

    local procedure SetRelativeUnitPrice(AddOnNo: Code[20]; Item: Record Item; RelativeUnitPrice: Decimal)
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
    begin
        ItemAddOnLine.SetFilter("AddOn No.", '=%1', AddOnNo);
        ItemAddOnLine.SetFilter("Item No.", '=%1', Item."No.");
        ItemAddOnLine.FindFirst();
        ItemAddOnLine.Validate("Use Unit Price", ItemAddOnLine."Use Unit Price"::Relative);
        ItemAddOnLine.Validate("Unit Price", RelativeUnitPrice);
        ItemAddOnLine.Modify(true);
    end;

    local procedure AddPerUnitAddOnLine(AddOnNo: Code[20]; Item: Record Item)
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        LineNo: Integer;
    begin
        ItemAddOnLine.SetRange("AddOn No.", AddOnNo);
        LineNo := (ItemAddOnLine.Count() + 1) * 10000;

        ItemAddOnLine.Init();
        ItemAddOnLine.Validate("AddOn No.", AddOnNo);
        ItemAddOnLine.Validate("Line No.", LineNo);
        ItemAddOnLine.Validate(Type, ItemAddOnLine.Type::Quantity);
        ItemAddOnLine.Validate("Item No.", Item."No.");
        ItemAddOnLine.Validate(Quantity, 1);
        ItemAddOnLine.Validate("Per Unit", true);
        ItemAddOnLine.Validate(Mandatory, true);
        ItemAddOnLine.Validate("Unit Price", 0);
        ItemAddOnLine.Insert(true);
    end;

    local procedure CreateNamedSaleItem(var Item: Record Item; Name: Text; UnitPrice: Decimal)
    begin
        CreateSaleItem(Item, UnitPrice);
        Item.Description := CopyStr(StrSubstNo('%1 %2', Name, Item."No."), 1, MaxStrLen(Item.Description));
        Item.Modify();
    end;

    local procedure EnableMixedDiscount()
    var
        DiscountPriority: Record "NPR Discount Priority";
        DiscountPriorityList: TestPage "NPR Discount Priority List";
    begin
        DiscountPriority.DeleteAll();

        DiscountPriorityList.OpenView();
        DiscountPriorityList.Close();

        DiscountPriority.SetFilter("Table ID", '<>%1', _LibraryPOSDiscount.MixDiscountSourceTableId());
        DiscountPriority.ModifyAll(Disabled, true);
    end;

    local procedure CreateAddOn(): Code[20]
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        LibraryRandom: Codeunit "Library - Random";
    begin
        ItemAddOn.Init();
        ItemAddOn.Validate("No.", LibraryRandom.RandText(20));
        ItemAddOn.Enabled := true;
        ItemAddOn.Insert(true);
        exit(ItemAddOn."No.");
    end;

    local procedure AddAddOnLine(AddOnNo: Code[20]; Item: Record Item; UseUnitPrice: Option "Non-Zero",Always,Relative; UnitPrice: Decimal)
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        LineNo: Integer;
    begin
        ItemAddOnLine.SetRange("AddOn No.", AddOnNo);
        LineNo := (ItemAddOnLine.Count() + 1) * 10000;

        ItemAddOnLine.Init();
        ItemAddOnLine.Validate("AddOn No.", AddOnNo);
        ItemAddOnLine.Validate("Line No.", LineNo);
        ItemAddOnLine.Validate(Type, ItemAddOnLine.Type::Quantity);
        ItemAddOnLine.Validate("Item No.", Item."No.");
        ItemAddOnLine.Validate(Quantity, 3);
        ItemAddOnLine.Validate("Fixed Quantity", true);
        ItemAddOnLine.Validate(Mandatory, true);
        ItemAddOnLine.Validate("Use Unit Price", UseUnitPrice);
        ItemAddOnLine.Validate("Unit Price", UnitPrice);
        ItemAddOnLine.Insert(true);
    end;

    local procedure InitializeSale(var SalePOS: Record "NPR POS Sale")
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore, _POSPaymentMethod);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
    end;

    local procedure CreateSaleItem(var Item: Record Item; UnitPrice: Decimal)
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := UnitPrice;
        Item.Modify();
    end;

    local procedure AddParentItemLine(ParentItem: Record Item; Quantity: Decimal; SalePOS: Record "NPR POS Sale"; var ParentSaleLine: Record "NPR POS Sale Line")
    var
        ItemReference: Record "Item Reference";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item B";
    begin
        POSActionInsertItem.AddItemLine(ParentItem, ItemReference, 0, Quantity, 0, '', '', '', _POSSession, FrontEnd, '');
        ParentSaleLine.Get(SalePOS."Register No.", SalePOS."Sales Ticket No.", SalePOS.Date, ParentSaleLine."Sale Type"::Sale, POSActionInsertItem.GetLineNo());
    end;

    local procedure RunItemAddOn(ParentSaleLine: Record "NPR POS Sale Line"; AddOnNo: Code[20])
    var
        POSActionRunItemAddOn: Codeunit "NPR POS Action: RunItemAddOn B";
        UserSelectionJToken: JsonToken;
    begin
        POSActionRunItemAddOn.RunItemAddOns(ParentSaleLine."Line No.", AddOnNo, false, true, false, UserSelectionJToken);
    end;

    local procedure FindSaleLine(SalePOS: Record "NPR POS Sale"; ItemNo: Code[20]; var SaleLine: Record "NPR POS Sale Line")
    begin
        SaleLine.SetRange("Register No.", SalePOS."Register No.");
        SaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLine.SetRange("Line Type", SaleLine."Line Type"::Item);
        SaleLine.SetRange("No.", ItemNo);
        SaleLine.FindFirst();
    end;
}
