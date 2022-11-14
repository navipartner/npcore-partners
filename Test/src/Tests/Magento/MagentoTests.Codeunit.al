codeunit 85055 "NPR MagentoTests"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryValidateParrentCategoryId()
    var
        MagentoCategory: Record "NPR Magento Category";
        RootMagentoCategoryId: Code[20];
        FirstChildMagentoCategoryId: Code[20];
        SecondChildMagentoCategoryId: Code[20];
    begin
        // [Scenario] Check if it is possible to create Magento Category with the same Parrent Id (Expected is to fail on "Parent Category Id" validation)

        // [Given] Create root category
        InitMagentoCategory(RootMagentoCategoryId, MagentoCategory);
        MagentoCategory.Validate("Parent Category Id", '');
        MagentoCategory.Insert();

        // [Given] Create first child category
        InitMagentoCategory(FirstChildMagentoCategoryId, MagentoCategory);
        MagentoCategory.Validate("Parent Category Id", RootMagentoCategoryId);
        MagentoCategory.Insert();

        // [When] Try to Create second child category
        InitMagentoCategory(SecondChildMagentoCategoryId, MagentoCategory);

        // [Then] Confirm Parent Category Id validation failed.
        asserterror MagentoCategory.Validate("Parent Category Id", SecondChildMagentoCategoryId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TryGetPathWithSameParrentCategory()
    var
        RootMagentoCategory: Record "NPR Magento Category";
        RootMagentoCategoryId: Code[20];
        FirstChildMagentoCategoryId: Code[20];
        SecondChildMagentoCategoryId: Code[20];
    begin
        // [Scenario] Check if it is possible to create Magento Category with the same Parrent Id (Expected is to fail in GetPath procedure)

        // [Given] Create root category
        InitMagentoCategory(RootMagentoCategoryId, RootMagentoCategory);
        RootMagentoCategory.Validate("Parent Category Id", '');
        RootMagentoCategory.Insert();

        // [When] Create first child category
        InitMagentoCategory(FirstChildMagentoCategoryId, RootMagentoCategory);
        RootMagentoCategory."Parent Category Id" := FirstChildMagentoCategoryId;
        RootMagentoCategory.Insert();

        // [When] Try to Create second child category but with parrent category id from first child
        InitMagentoCategory(SecondChildMagentoCategoryId, RootMagentoCategory);
        RootMagentoCategory."Parent Category Id" := FirstChildMagentoCategoryId;

        // [Then] Confirm that GetParent Category Id validation failed.
        asserterror RootMagentoCategory.Path := RootMagentoCategory.GetPath();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InsertRootAndChildCategories()
    var
        MagentoCategory: Record "NPR Magento Category";
        RootMagentoCategoryId: Code[20];
        FirstChildMagentoCategoryId: Code[20];
        SecondChildMagentoCategoryId: Code[20];
    begin
        // [Scenario] Check if it is possible to create Magento Category with different Parrent Id (Expected is to go without error)

        // [Given] Create root category
        InitMagentoCategory(RootMagentoCategoryId, MagentoCategory);
        MagentoCategory.Validate("Parent Category Id", '');
        MagentoCategory.Insert();

        // [Given] Create first child category
        InitMagentoCategory(FirstChildMagentoCategoryId, MagentoCategory);
        MagentoCategory.Validate("Parent Category Id", RootMagentoCategoryId);
        MagentoCategory.Insert();

        // [When] Try to Create second child category
        InitMagentoCategory(SecondChildMagentoCategoryId, MagentoCategory);
        MagentoCategory.Validate("Parent Category Id", FirstChildMagentoCategoryId);

        // [Then] Confirm insertion of second child category
        MagentoCategory.Insert();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetPathWithDifferentParrentCategory()
    var
        MagentoCategory: Record "NPR Magento Category";
        RootMagentoCategoryId: Code[20];
        FirstChildMagentoCategoryId: Code[20];
        SecondChildMagentoCategoryId: Code[20];
    begin
        // [Scenario] Check if it is possible to create Magento Category with different Parrent Id but with GetPath (Expected is to go without error)

        // [Given] Create root category
        InitMagentoCategory(RootMagentoCategoryId, MagentoCategory);
        MagentoCategory.Validate("Parent Category Id", '');
        MagentoCategory.Insert();

        // [Given] Create first child category
        InitMagentoCategory(FirstChildMagentoCategoryId, MagentoCategory);
        MagentoCategory.Validate("Parent Category Id", RootMagentoCategoryId);
        MagentoCategory.Insert();

        // [When] Try to Create second child category
        InitMagentoCategory(SecondChildMagentoCategoryId, MagentoCategory);
        MagentoCategory.Validate("Parent Category Id", FirstChildMagentoCategoryId);

        // [Then] Confirm insertion of second child category
        MagentoCategory.Path := MagentoCategory.GetPath();
    end;

    local procedure InitMagentoCategory(var CategoryId: Code[20]; var MagentoCategory: Record "NPR Magento Category")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        Clear(MagentoCategory);
        CategoryId := LibraryUtility.GenerateRandomCode20(MagentoCategory.FieldNo(Id), Database::"NPR Magento Category");
        MagentoCategory.Init();
        MagentoCategory.Id := CategoryId;
    end;
}
