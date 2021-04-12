codeunit 6059977 "NPR Variety Setup Wizard"
{
    // NPR5.36/JDH /20170922 CASE 288696 Wizard created


    trigger OnRun()
    begin
        if not Step1_ChooseBusinessType then
            exit;

        if not Step2_ChooseProducts then
            exit;

        Step3_SelectWhichToCreate;
    end;

    var
        TMPBusinessChoiceSelectionBuffer: Record "Dimension Selection Buffer" temporary;
        TMPProductChoiceSelectionBuffer: Record "Dimension Selection Buffer" temporary;

    local procedure Step1_ChooseBusinessType(): Boolean
    begin
        InsertBusinessChoices('SHOES', 'Shoe shops');
        InsertBusinessChoices('CLOTHES', 'Clothes shops');
        InsertBusinessChoices('JEWELERY', 'Jewelery shops');
        exit(PAGE.RunModal(PAGE::"Dimension Selection-Multiple", TMPBusinessChoiceSelectionBuffer) = ACTION::LookupOK);
    end;

    local procedure Step2_ChooseProducts(): Boolean
    begin
        TMPBusinessChoiceSelectionBuffer.SetRange(Selected, true);
        if TMPBusinessChoiceSelectionBuffer.FindSet() then
            repeat
                if TMPBusinessChoiceSelectionBuffer.Code = 'SHOES' then begin
                    InsertProductChoices('FR_MEN', 'Shoes for men French Sizes');
                    InsertProductChoices('US_MEN', 'Shoes for men american Sizes');
                    InsertProductChoices('UK_MEN', 'Shoes for men UK Sizes');
                    InsertProductChoices('IT_MEN', 'Shoes for men IT Sizes');
                    InsertProductChoices('FR_WOMEN', 'Shoes for women French Sizes');
                    InsertProductChoices('US_WOMEN', 'Shoes for women american Sizes');
                    InsertProductChoices('UK_WOMEN', 'Shoes for women UK Sizes');
                    InsertProductChoices('IT_WOMEN', 'Shoes for women IT Sizes');
                end;
                if TMPBusinessChoiceSelectionBuffer.Code = 'CLOTHES' then begin
                    InsertProductChoices('SHIRT', 'Color/size (xs...xxl)');
                    InsertProductChoices('PANTS2', 'Color/Size');
                    InsertProductChoices('PANTS3', 'Color/Waist/Lenght');
                    InsertProductChoices('T-SHIRT', 'Color/Size');
                end;
                if TMPBusinessChoiceSelectionBuffer.Code = 'JEWELERY' then begin
                    InsertProductChoices('RINGS', 'Ring Sizes');
                end;
            until TMPBusinessChoiceSelectionBuffer.Next() = 0;
        exit(PAGE.RunModal(PAGE::"Dimension Selection-Multiple", TMPProductChoiceSelectionBuffer) = ACTION::LookupOK);
    end;

    local procedure Step3_SelectWhichToCreate()
    begin
        TMPProductChoiceSelectionBuffer.SetRange(Selected, true);
        if TMPProductChoiceSelectionBuffer.FindSet() then
            repeat
                case TMPProductChoiceSelectionBuffer.Code of
                    //Shoes
                    'FR_MEN':
                        InsertShoe_FRMen;
                    'US_MEN':
                        InsertShoe_USMen;
                    'UK_MEN':
                        InsertShoe_UKMen;
                    'IT_MEN':
                        InsertShoe_ITMen;
                    'FR_WOMEN':
                        InsertShoe_FRWomen;
                    'US_WOMEN':
                        InsertShoe_USWomen;
                    'UK_WOMEN':
                        InsertShoe_UKWomen;
                    'IT_WOMEN':
                        InsertShoe_ITWomen;

                    //Clothes
                    'SHIRT':
                        InsertShirts;
                    'PANTS2':
                        InsertPants2;
                    'PANTS3':
                        InsertPants3;
                    'T-SHIRT':
                        InsertTShirts;

                    //Jewelry
                    'RINGS':
                        InsertRings;
                end;
            until TMPProductChoiceSelectionBuffer.Next() = 0;
        //EXIT(PAGE.RUNMODAL(PAGE::"Dimension Selection-Multiple", TMPProductChoiceSelectionBuffer) = ACTION::LookupOK);
    end;

    local procedure InsertBusinessChoices(BusinessCode: Code[10]; BusinessDescription: Text)
    begin
        TMPBusinessChoiceSelectionBuffer.Init();
        TMPBusinessChoiceSelectionBuffer.Code := BusinessCode;
        TMPBusinessChoiceSelectionBuffer.Description := BusinessDescription;
        TMPBusinessChoiceSelectionBuffer.Insert();
    end;

    local procedure InsertProductChoices(ProductCode: Code[10]; ProductDescription: Text)
    begin
        TMPProductChoiceSelectionBuffer.Init();
        TMPProductChoiceSelectionBuffer.Code := ProductCode;
        TMPProductChoiceSelectionBuffer.Description := ProductDescription;
        TMPProductChoiceSelectionBuffer.Insert();
    end;

    local procedure InsertVarietyGroups(GroupCode: Code[20]; GroupDescription: Text; V1Type: Code[10]; V1Table: Code[20]; V1CreateCopy: Boolean; V2Type: Code[10]; V2Table: Code[20]; V2CreateCopy: Boolean; V3Type: Code[10]; V3Table: Code[20]; V3CreateCopy: Boolean)
    var
        VarietyGroup: Record "NPR Variety Group";
    begin
        if VarietyGroup.Get(GroupCode) then
            exit;
        VarietyGroup.Init();
        VarietyGroup.Code := GroupCode;
        VarietyGroup.Description := GroupDescription;
        VarietyGroup."Variety 1" := V1Type;
        VarietyGroup."Variety 1 Table" := V1Table;
        VarietyGroup."Create Copy of Variety 1 Table" := V1CreateCopy;
        if VarietyGroup."Create Copy of Variety 1 Table" then
            VarietyGroup."Copy Naming Variety 1" := VarietyGroup."Copy Naming Variety 1"::TableCodeAndItemNo;

        VarietyGroup."Variety 2" := V2Type;
        VarietyGroup."Variety 2 Table" := V2Table;
        VarietyGroup."Create Copy of Variety 2 Table" := V2CreateCopy;
        if VarietyGroup."Create Copy of Variety 2 Table" then
            VarietyGroup."Copy Naming Variety 2" := VarietyGroup."Copy Naming Variety 2"::TableCodeAndItemNo;

        VarietyGroup."Variety 3" := V3Type;
        VarietyGroup."Variety 3 Table" := V3Table;
        VarietyGroup."Create Copy of Variety 3 Table" := V3CreateCopy;
        if VarietyGroup."Create Copy of Variety 3 Table" then
            VarietyGroup."Copy Naming Variety 3" := VarietyGroup."Copy Naming Variety 3"::TableCodeAndItemNo;

        VarietyGroup."Cross Variety No." := VarietyGroup."Cross Variety No."::Variety1;
        VarietyGroup.Insert();
    end;

    local procedure CreateVarietyType(VrtType: Code[10]; Desc: Text; PreTag: Text)
    var
        Variety: Record "NPR Variety";
    begin
        if Variety.Get(VrtType) then
            exit;

        Variety.Init();
        Variety.Code := VrtType;
        Variety.Description := Desc;
        Variety."Use in Variant Description" := true;
        Variety."Pre tag In Variant Description" := PreTag;
        Variety.Insert();
    end;

    local procedure CreateVarietyTable(VrtType: Code[10]; VrtTable: Code[20]; Desc: Text; LockTableParm: Boolean)
    var
        VarietyTable: Record "NPR Variety Table";
    begin
        if VarietyTable.Get(VrtType, VrtTable) then
            exit;
        VarietyTable.Init();
        VarietyTable.SetRange(Type, VrtType);
        VarietyTable.SetupNewLine;
        VarietyTable.Type := VrtType;
        VarietyTable.Code := VrtTable;
        VarietyTable.Description := Desc;
        VarietyTable."Lock Table" := LockTableParm;
        VarietyTable.Insert();
    end;

    local procedure CreateVarietyValue(VrtType: Code[10]; VrtTable: Code[20]; VrtValue: Code[20]; Desc: Text)
    var
        VarietyValue: Record "NPR Variety Value";
    begin
        if VarietyValue.Get(VrtType, VrtTable, VrtValue) then
            exit;
        VarietyValue.Init();
        VarietyValue.Type := VrtType;
        VarietyValue.Table := VrtTable;
        VarietyValue.Value := VrtValue;
        VarietyValue.Description := Desc;
        VarietyValue.AssignSortOrder;
        VarietyValue.Insert(false);
    end;

    local procedure InsertShoe_FRMen()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'SHOE';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Shoes', false);

        TypeCode2 := 'SIZE';
        TableCode2 := 'FR_MEN';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes FR Men', true);
        CreateVarietyValue(TypeCode2, TableCode2, '38', 'Size 38');
        CreateVarietyValue(TypeCode2, TableCode2, '39', 'Size 39');
        CreateVarietyValue(TypeCode2, TableCode2, '40', 'Size 40');
        CreateVarietyValue(TypeCode2, TableCode2, '41', 'Size 41');
        CreateVarietyValue(TypeCode2, TableCode2, '42', 'Size 42');
        CreateVarietyValue(TypeCode2, TableCode2, '43', 'Size 43');
        CreateVarietyValue(TypeCode2, TableCode2, '44', 'Size 44');
        CreateVarietyValue(TypeCode2, TableCode2, '45', 'Size 45');
        CreateVarietyValue(TypeCode2, TableCode2, '46', 'Size 46');
        CreateVarietyValue(TypeCode2, TableCode2, '47', 'Size 47');
        CreateVarietyValue(TypeCode2, TableCode2, '48', 'Size 48');
        CreateVarietyValue(TypeCode2, TableCode2, '49', 'Size 49');
        CreateVarietyValue(TypeCode2, TableCode2, '50', 'Size 50');

        InsertVarietyGroups('SHOE_FR_MEN', 'Default group for FR Shoes Men', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertShoe_UKMen()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'SHOE';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Shoes', false);

        TypeCode2 := 'SIZE';
        TableCode2 := 'UK_MEN';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes FR Men', true);
        CreateVarietyValue(TypeCode2, TableCode2, '5', 'Size 5');
        CreateVarietyValue(TypeCode2, TableCode2, '6', 'Size 6');
        CreateVarietyValue(TypeCode2, TableCode2, '7', 'Size 7');
        CreateVarietyValue(TypeCode2, TableCode2, '8', 'Size 8');
        CreateVarietyValue(TypeCode2, TableCode2, '9', 'Size 9');
        CreateVarietyValue(TypeCode2, TableCode2, '10', 'Size 10');
        CreateVarietyValue(TypeCode2, TableCode2, '11', 'Size 11');
        CreateVarietyValue(TypeCode2, TableCode2, '12', 'Size 12');
        CreateVarietyValue(TypeCode2, TableCode2, '13', 'Size 13');
        CreateVarietyValue(TypeCode2, TableCode2, '14', 'Size 14');
        CreateVarietyValue(TypeCode2, TableCode2, '15', 'Size 15');
        InsertVarietyGroups('SHOE_UK_MEN', 'Default group for UK Shoes Men', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertShoe_USMen()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'SHOE';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Shoes', false);

        TypeCode2 := 'SIZE';
        TableCode2 := 'US_MEN';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes US Men', true);
        CreateVarietyValue(TypeCode2, TableCode2, '6', 'Size 6');
        CreateVarietyValue(TypeCode2, TableCode2, '7', 'Size 7');
        CreateVarietyValue(TypeCode2, TableCode2, '8', 'Size 8');
        CreateVarietyValue(TypeCode2, TableCode2, '9', 'Size 9');
        CreateVarietyValue(TypeCode2, TableCode2, '10', 'Size 10');
        CreateVarietyValue(TypeCode2, TableCode2, '11', 'Size 11');
        CreateVarietyValue(TypeCode2, TableCode2, '12', 'Size 12');
        CreateVarietyValue(TypeCode2, TableCode2, '13', 'Size 13');
        CreateVarietyValue(TypeCode2, TableCode2, '14', 'Size 14');
        CreateVarietyValue(TypeCode2, TableCode2, '15', 'Size 15');

        InsertVarietyGroups('SHOE_US_MEN', 'Default group for US Shoes Men', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertShoe_ITMen()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'SHOE';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Shoes', false);

        TypeCode2 := 'SIZE';
        TableCode2 := 'IT_MEN';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes IT Men', true);
        CreateVarietyValue(TypeCode2, TableCode2, '37', 'Size 37');
        CreateVarietyValue(TypeCode2, TableCode2, '38', 'Size 38');
        CreateVarietyValue(TypeCode2, TableCode2, '39', 'Size 39');
        CreateVarietyValue(TypeCode2, TableCode2, '40', 'Size 40');
        CreateVarietyValue(TypeCode2, TableCode2, '41', 'Size 41');
        CreateVarietyValue(TypeCode2, TableCode2, '42', 'Size 42');
        CreateVarietyValue(TypeCode2, TableCode2, '43', 'Size 43');
        CreateVarietyValue(TypeCode2, TableCode2, '44', 'Size 44');
        CreateVarietyValue(TypeCode2, TableCode2, '45', 'Size 45');
        CreateVarietyValue(TypeCode2, TableCode2, '46', 'Size 46');
        CreateVarietyValue(TypeCode2, TableCode2, '47', 'Size 47');
        CreateVarietyValue(TypeCode2, TableCode2, '48', 'Size 48');
        CreateVarietyValue(TypeCode2, TableCode2, '49', 'Size 49');


        InsertVarietyGroups('SHOE_IT_MEN', 'Default group for IT Shoes Men', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertShoe_FRWomen()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'SHOE';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Shoes', false);

        TypeCode2 := 'SIZE';
        TableCode2 := 'FR_WOMEN';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes FR Men', true);
        CreateVarietyValue(TypeCode2, TableCode2, '35', 'Size 35');
        CreateVarietyValue(TypeCode2, TableCode2, '36', 'Size 36');
        CreateVarietyValue(TypeCode2, TableCode2, '37', 'Size 37');
        CreateVarietyValue(TypeCode2, TableCode2, '38', 'Size 38');
        CreateVarietyValue(TypeCode2, TableCode2, '39', 'Size 39');
        CreateVarietyValue(TypeCode2, TableCode2, '40', 'Size 40');
        CreateVarietyValue(TypeCode2, TableCode2, '41', 'Size 41');
        CreateVarietyValue(TypeCode2, TableCode2, '42', 'Size 42');
        CreateVarietyValue(TypeCode2, TableCode2, '43', 'Size 43');

        InsertVarietyGroups('SHOE_FR_WOMEN', 'Default group - FR Shoes Women', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertShoe_UKWomen()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'SHOE';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Shoes', false);

        TypeCode2 := 'SIZE';
        TableCode2 := 'UK_WOMEN';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes FR Women', true);
        CreateVarietyValue(TypeCode2, TableCode2, '3', 'Size 3');
        CreateVarietyValue(TypeCode2, TableCode2, '4', 'Size 4');
        CreateVarietyValue(TypeCode2, TableCode2, '5', 'Size 5');
        CreateVarietyValue(TypeCode2, TableCode2, '6', 'Size 6');
        CreateVarietyValue(TypeCode2, TableCode2, '7', 'Size 7');
        CreateVarietyValue(TypeCode2, TableCode2, '8', 'Size 8');
        CreateVarietyValue(TypeCode2, TableCode2, '9', 'Size 9');
        InsertVarietyGroups('SHOE_UK_WOMEN', 'Default group - UK Shoes Women', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertShoe_USWomen()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'SHOE';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Shoes', false);

        TypeCode2 := 'SIZE';
        TableCode2 := 'US_WOMEN';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes US Women', true);
        CreateVarietyValue(TypeCode2, TableCode2, '4', 'Size 4');
        CreateVarietyValue(TypeCode2, TableCode2, '5', 'Size 5');
        CreateVarietyValue(TypeCode2, TableCode2, '6', 'Size 6');
        CreateVarietyValue(TypeCode2, TableCode2, '7', 'Size 7');
        CreateVarietyValue(TypeCode2, TableCode2, '8', 'Size 8');
        CreateVarietyValue(TypeCode2, TableCode2, '9', 'Size 9');
        CreateVarietyValue(TypeCode2, TableCode2, '10', 'Size 10');

        InsertVarietyGroups('SHOE_US_WOMEN', 'Default group - US Shoes Women', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertShoe_ITWomen()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'SHOE';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Shoes', false);

        TypeCode2 := 'SIZE';
        TableCode2 := 'IT_WOMEN';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes IT Women', true);
        CreateVarietyValue(TypeCode2, TableCode2, '34', 'Size 34');
        CreateVarietyValue(TypeCode2, TableCode2, '35', 'Size 35');
        CreateVarietyValue(TypeCode2, TableCode2, '36', 'Size 36');
        CreateVarietyValue(TypeCode2, TableCode2, '37', 'Size 37');
        CreateVarietyValue(TypeCode2, TableCode2, '38', 'Size 38');
        CreateVarietyValue(TypeCode2, TableCode2, '39', 'Size 39');
        CreateVarietyValue(TypeCode2, TableCode2, '40', 'Size 40');
        CreateVarietyValue(TypeCode2, TableCode2, '41', 'Size 41');
        CreateVarietyValue(TypeCode2, TableCode2, '42', 'Size 42');

        InsertVarietyGroups('SHOE_IT_WOMEN', 'Default group - IT Shoes Women', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertShirts()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'SHIRT';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Shirts', false);

        TypeCode2 := 'SIZE';
        TableCode2 := '37-48';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes 37 48', true);

        CreateVarietyValue(TypeCode2, TableCode2, '37', 'Size 37');
        CreateVarietyValue(TypeCode2, TableCode2, '38', 'Size 38');
        CreateVarietyValue(TypeCode2, TableCode2, '39', 'Size 39');
        CreateVarietyValue(TypeCode2, TableCode2, '40', 'Size 40');
        CreateVarietyValue(TypeCode2, TableCode2, '41', 'Size 41');
        CreateVarietyValue(TypeCode2, TableCode2, '42', 'Size 42');
        CreateVarietyValue(TypeCode2, TableCode2, '43', 'Size 43');
        CreateVarietyValue(TypeCode2, TableCode2, '44', 'Size 44');
        CreateVarietyValue(TypeCode2, TableCode2, '45', 'Size 45');
        CreateVarietyValue(TypeCode2, TableCode2, '46', 'Size 46');
        CreateVarietyValue(TypeCode2, TableCode2, '48', 'Size 48');

        InsertVarietyGroups('SHIRT_37_48', 'Default group shirts 37 - 48', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertPants2()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'PANTS';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Pants', false);

        TypeCode2 := 'SIZE';
        TableCode2 := '28-40';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes 28 - 40', true);
        CreateVarietyValue(TypeCode2, TableCode2, '28', 'Size 28');
        CreateVarietyValue(TypeCode2, TableCode2, '30', 'Size 30');
        CreateVarietyValue(TypeCode2, TableCode2, '32', 'Size 32');
        CreateVarietyValue(TypeCode2, TableCode2, '34', 'Size 34');
        CreateVarietyValue(TypeCode2, TableCode2, '36', 'Size 36');
        CreateVarietyValue(TypeCode2, TableCode2, '38', 'Size 38');
        CreateVarietyValue(TypeCode2, TableCode2, '40', 'Size 40');

        InsertVarietyGroups('PANTS_SIZES', 'Default group pants 28 - 40', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertPants3()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
        TypeCode3: Code[10];
        TableCode3: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'PANTS';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Pants', false);

        TypeCode2 := 'WAIST';
        TableCode2 := '28-40';
        CreateVarietyType(TypeCode2, 'Waist', 'W:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Waist 28 - 40', true);
        CreateVarietyValue(TypeCode2, TableCode2, '28', 'Waist 28');
        CreateVarietyValue(TypeCode2, TableCode2, '30', 'Waist 30');
        CreateVarietyValue(TypeCode2, TableCode2, '32', 'Waist 32');
        CreateVarietyValue(TypeCode2, TableCode2, '34', 'Waist 34');
        CreateVarietyValue(TypeCode2, TableCode2, '36', 'Waist 36');
        CreateVarietyValue(TypeCode2, TableCode2, '38', 'Waist 38');
        CreateVarietyValue(TypeCode2, TableCode2, '40', 'Waist 40');

        TypeCode3 := 'LENGTH';
        TableCode3 := '30-36';
        CreateVarietyType(TypeCode3, 'Length', 'L:');
        CreateVarietyTable(TypeCode3, TableCode3, 'Length 30 - 36', true);
        CreateVarietyValue(TypeCode3, TableCode3, '30', 'Length 30');
        CreateVarietyValue(TypeCode3, TableCode3, '32', 'Length 32');
        CreateVarietyValue(TypeCode3, TableCode3, '34', 'Length 34');
        CreateVarietyValue(TypeCode3, TableCode3, '36', 'Length 36');

        InsertVarietyGroups('PANTS_WAIST_LENGTH', 'Default group pants W - L', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, TypeCode3, TableCode3, false);
    end;

    local procedure InsertTShirts()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
        TypeCode2: Code[10];
        TableCode2: Code[20];
    begin
        TypeCode1 := 'COLOR';
        TableCode1 := 'TSHIRT';
        CreateVarietyType(TypeCode1, 'Color', 'CO:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Colors Shirts', false);

        TypeCode2 := 'SIZE';
        TableCode2 := 'XS-XXL';
        CreateVarietyType(TypeCode2, 'Sizes', 'SZ:');
        CreateVarietyTable(TypeCode2, TableCode2, 'Sizes XS XXL', true);
        CreateVarietyValue(TypeCode2, TableCode2, 'XS', 'Size xs');
        CreateVarietyValue(TypeCode2, TableCode2, 'S', 'Size s');
        CreateVarietyValue(TypeCode2, TableCode2, 'M', 'Size m');
        CreateVarietyValue(TypeCode2, TableCode2, 'L', 'Size l');
        CreateVarietyValue(TypeCode2, TableCode2, 'XL', 'Size xl');
        CreateVarietyValue(TypeCode2, TableCode2, 'XXL', 'Size xxl');

        InsertVarietyGroups('TSHIRT_XS_XXL', 'Default group tshirts XL - XXL', TypeCode1, TableCode1, true, TypeCode2, TableCode2, false, '', '', false);
    end;

    local procedure InsertRings()
    var
        TypeCode1: Code[10];
        TableCode1: Code[20];
    begin
        TypeCode1 := 'DIAMETER';
        TableCode1 := '47-70';
        CreateVarietyType(TypeCode1, 'Diameter', 'DIA:');
        CreateVarietyTable(TypeCode1, TableCode1, 'Diameter 47 - 70', true);
        CreateVarietyValue(TypeCode1, TableCode1, '47', 'Diameter 14,9');
        CreateVarietyValue(TypeCode1, TableCode1, '48', 'Diameter 15,2');
        CreateVarietyValue(TypeCode1, TableCode1, '49', 'Diameter 15,6');
        CreateVarietyValue(TypeCode1, TableCode1, '50', 'Diameter 15,9');
        CreateVarietyValue(TypeCode1, TableCode1, '51', 'Diameter 16,2');
        CreateVarietyValue(TypeCode1, TableCode1, '52', 'Diameter 16,5');
        CreateVarietyValue(TypeCode1, TableCode1, '53', 'Diameter 16,8');
        CreateVarietyValue(TypeCode1, TableCode1, '54', 'Diameter 17,2');
        CreateVarietyValue(TypeCode1, TableCode1, '55', 'Diameter 17,5');
        CreateVarietyValue(TypeCode1, TableCode1, '56', 'Diameter 17,8');
        CreateVarietyValue(TypeCode1, TableCode1, '57', 'Diameter 18,1');
        CreateVarietyValue(TypeCode1, TableCode1, '58', 'Diameter 18,4');
        CreateVarietyValue(TypeCode1, TableCode1, '59', 'Diameter 18,7');
        CreateVarietyValue(TypeCode1, TableCode1, '60', 'Diameter 19,1');
        CreateVarietyValue(TypeCode1, TableCode1, '61', 'Diameter 19,4');
        CreateVarietyValue(TypeCode1, TableCode1, '62', 'Diameter 19,7');
        CreateVarietyValue(TypeCode1, TableCode1, '63', 'Diameter 20,0');
        CreateVarietyValue(TypeCode1, TableCode1, '64', 'Diameter 20,3');
        CreateVarietyValue(TypeCode1, TableCode1, '65', 'Diameter 20,7');
        CreateVarietyValue(TypeCode1, TableCode1, '66', 'Diameter 21,0');
        CreateVarietyValue(TypeCode1, TableCode1, '67', 'Diameter 21,3');
        CreateVarietyValue(TypeCode1, TableCode1, '68', 'Diameter 21,6');
        CreateVarietyValue(TypeCode1, TableCode1, '69', 'Diameter 21,9');
        CreateVarietyValue(TypeCode1, TableCode1, '70', 'Diameter 22,2');
        InsertVarietyGroups('RINGS_47_70', 'Default group Rings 47 - 70', TypeCode1, TableCode1, false, '', '', false, '', '', false);
    end;
}

