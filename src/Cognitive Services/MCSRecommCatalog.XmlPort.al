xmlport 6060080 "NPR MCS Recomm. Catalog"
{
    // NPR5.30/BR  /20170215  CASE 252646 Object Created
    // NPR5.34/BR  /20170725  CASE 275206 Only export no's that match MCS criteria
    // NPR5.48/TJ  /20190102  CASE 340615 Commented out usages of field Item."Product Group Code"

    Caption = 'MCS Recommendations Catalog';
    FieldDelimiter = '<None>';
    FieldSeparator = ',';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement(Item; Item)
            {
                XmlName = 'item';
                fieldelement(ItemID; Item."No.")
                {
                }
                textelement(itemnametext)
                {
                    XmlName = 'ItemName';

                    trigger OnBeforePassVariable()
                    begin
                        ItemNameText := GetItemName;
                    end;
                }
                textelement(itemcategorytext)
                {
                    XmlName = 'ItemCategory';

                    trigger OnBeforePassVariable()
                    begin
                        ItemCategoryText := GetCategory;
                    end;
                }
                textelement(descriptiontext)
                {
                    XmlName = 'Description';

                    trigger OnBeforePassVariable()
                    begin
                        DescriptionText := GetExtendedText(Item);
                    end;
                }
                textelement(featurelisttext)
                {
                    XmlName = 'FeatureList';

                    trigger OnBeforePassVariable()
                    begin
                        FeaturelistText := GetFeatureList(Item);
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    MCSRecommendationsHandler: Codeunit "NPR MCS Recomm. Handler";
                begin
                    //-NPR5.34 [275206]
                    if not MCSRecommendationsHandler.IsValidMCSNo(Item."No.") then
                        currXMLport.Skip;
                    //+NPR5.34 [275206]
                end;

                trigger OnPreXmlItem()
                begin
                    if MCSRecommendationsModel."Item View" <> '' then
                        Item.SetView(MCSRecommendationsModel."Item View");
                    if LastModifiedDate <> 0D then
                        Item.SetFilter("Last Date Modified", '%1..', LastModifiedDate);
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        MCSRecommendationsModel: Record "NPR MCS Recomm. Model";
        LanguageCode: Code[10];
        LastModifiedDate: Date;

    procedure SetModel(ParMCSRecommendationsModel: Record "NPR MCS Recomm. Model")
    begin
        MCSRecommendationsModel := ParMCSRecommendationsModel;
    end;

    procedure SetLanguageCode(ParLanguageCode: Code[10])
    begin
        LanguageCode := ParLanguageCode;
    end;

    procedure SetLastModifiedDate(ParLastModifiedDate: Date)
    begin
        LastModifiedDate := ParLastModifiedDate;
    end;

    local procedure GetItemName() DescrText: Text
    var
        ItemTranslation: Record "Item Translation";
    begin
        DescrText := Item.Description;
        if Item."Description 2" <> '' then
            DescrText := DescrText + ' ' + Item."Description 2";
        if LanguageCode <> '' then begin
            if ItemTranslation.Get(Item."No.", '', LanguageCode) then begin
                DescrText := ItemTranslation.Description;
                if ItemTranslation."Description 2" <> '' then
                    DescrText := DescrText + ' ' + ItemTranslation."Description 2";
            end;
        end;
    end;

    local procedure GetExtendedText(ExtTextItem: Record Item) ExtendedText: Text
    var
        ExtendedTextHeader: Record "Extended Text Header";
        ExtendedTextLine: Record "Extended Text Line";
    begin
        Clear(ExtendedText);
        ExtendedTextHeader.SetRange("Table Name", ExtendedTextHeader."Table Name"::Item);
        ExtendedTextHeader.SetRange("No.", ExtTextItem."No.");
        ExtendedTextHeader.SetRange("All Language Codes", true);
        if not ExtendedTextHeader.FindFirst then begin
            ExtendedTextHeader.SetRange("All Language Codes");
            ExtendedTextHeader.SetRange("Language Code", LanguageCode);
            if not ExtendedTextHeader.FindFirst then begin
                ExtendedTextHeader.SetRange("Language Code");
                if not ExtendedTextHeader.FindFirst then
                    exit('');
            end;
        end;

        ExtendedTextLine.SetRange("Table Name", ExtendedTextLine."Table Name"::Item);
        ExtendedTextLine.SetRange("No.", ExtendedTextHeader."No.");
        ExtendedTextLine.SetRange("Language Code", ExtendedTextHeader."Language Code");
        ExtendedTextLine.SetRange("Text No.", ExtendedTextHeader."Text No.");
        if ExtendedTextLine.FindFirst then
            repeat
                if ExtendedText <> '' then
                    ExtendedText := ExtendedText + ' ';
                ExtendedText := ExtendedText + ExtendedTextLine.Text;
            until ExtendedTextLine.Next = 0;
    end;

    local procedure GetCategory() CatText: Text
    var
        ItemGroup: Record "NPR Item Group";
        ItemCategory: Record "Item Category";
    begin
        case MCSRecommendationsModel.Categories of
            MCSRecommendationsModel.Categories::"Item Category":
                begin
                    if Item."Item Category Code" <> '' then
                        if ItemCategory.Get(Item."Item Category Code") then
                            if ItemCategory.Description <> '' then
                                exit(ItemCategory.Description)
                            else
                                exit(ItemCategory.Code);
                end;
            MCSRecommendationsModel.Categories::"Product Group":
                begin
                    //-NPR5.48 [340615]
                    /*
                    IF Item."Product Group Code" <> '' THEN
                      IF ProductGroup.GET(Item."Item Category Code",Item."Product Group Code") THEN
                        IF ProductGroup.Description <> '' THEN
                          EXIT(ProductGroup.Description)
                        ELSE
                          EXIT(ProductGroup.Code);
                    */
                    //+NPR5.48 [340615]
                end;
            MCSRecommendationsModel.Categories::"Item Category - Product Group":
                begin
                    //-NPR5.48 [340615]
                    /*
                    IF Item."Product Group Code" <> '' THEN BEGIN
                      IF ItemCategory.GET(Item."Item Category Code") AND ProductGroup.GET(Item."Item Category Code",Item."Product Group Code") THEN
                        IF ProductGroup.Description <> '' THEN
                          EXIT(ItemCategory.Description + ' - ' + ProductGroup.Description)
                        ELSE
                          EXIT(ItemCategory.Code + ' - ' + ProductGroup.Code);
                    END ELSE BEGIN
                    */
                    //+NPR5.48 [340615]
                    if Item."Item Category Code" <> '' then
                        if ItemCategory.Get(Item."Item Category Code") then
                            if ItemCategory.Description <> '' then
                                exit(ItemCategory.Description)
                            else
                                exit(ItemCategory.Code);
                    //-NPR5.48 [340615]
                    //END;
                    //+NPR5.48 [340615]
                end;
            MCSRecommendationsModel.Categories::"Item Group":
                begin
                    if Item."NPR Item Group" <> '' then
                        if ItemGroup.Get(Item."NPR Item Group") then
                            if ItemGroup.Description <> '' then
                                exit(ItemGroup.Description)
                            else
                                exit(ItemGroup."No.");
                end;
        end;

    end;

    local procedure GetFeatureList(var AttribItem: Record Item) ListText: Text
    var
        NPRAttribute: Record "NPR Attribute";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
        NPRAttributeKey: Record "NPR Attribute Key";
        AttribValueText: Text;
    begin
        Clear(ListText);

        if MCSRecommendationsModel."Attribute View" <> '' then
            NPRAttribute.SetView(MCSRecommendationsModel."Attribute View");
        NPRAttribute.SetRange(Blocked, false);
        if NPRAttribute.FindFirst then
            repeat
                AttribValueText := 'UNKNOWN';
                NPRAttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
                NPRAttributeKey.SetRange("Table ID", DATABASE::Item);
                NPRAttributeKey.SetRange("MDR Code PK", Item."No.");
                if NPRAttributeKey.FindFirst then begin
                    if NPRAttributeValueSet.Get(NPRAttributeKey."Attribute Set ID", NPRAttribute.Code) then begin
                        AttribValueText := NPRAttributeValueSet."Text Value";
                    end;
                end;
                if ListText <> '' then
                    ListText := ListText + ',';
                ListText := ListText + NPRAttribute.Code + '=' + AttribValueText;
            until NPRAttribute.Next = 0;
    end;
}

