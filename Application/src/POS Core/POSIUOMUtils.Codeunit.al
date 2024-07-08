codeunit 6151063 "NPR POS IUOM Utils"
{
    Access = Internal;

    internal procedure CheckIfBlockingBaseUOM(ItemUnitofMeasure: Record "Item Unit of Measure")
    var
        Item: Record Item;
    begin
        if not Item.Get(ItemUnitofMeasure."Item No.") then
            exit;

        if Item."Base Unit of Measure" <> ItemUnitofMeasure.Code then
            exit;

        ItemUnitofMeasure.TestField("NPR Block on POS Sale", false);
    end;

    internal procedure CheckIfBaseUnitOfMeasureBlocked(Item: Record Item)
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        if Item."Base Unit of Measure" = '' then
            exit;

        if not ItemUnitofMeasure.Get(Item."No.",
                                     Item."Base Unit of Measure")
        then
            exit;

        ItemUnitofMeasure.TestField("NPR Block on POS Sale", false);
    end;

    internal procedure CheckIfUnitOfMeasureBlocked(NPRPOSSaleLine: Record "NPR POS Sale Line")
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if (NPRPOSSaleLine."Line Type" <> NPRPOSSaleLine."Line Type"::Item) and
           (NPRPOSSaleLine."Line Type" <> NPRPOSSaleLine."Line Type"::"BOM List")
        then
            exit;

        if NPRPOSSaleLine."No." = '' then
            exit;

        if NPRPOSSaleLine."Unit of Measure Code" = '' then
            exit;

        if not ItemUnitOfMeasure.Get(NPRPOSSaleLine."No.",
                                     NPRPOSSaleLine."Unit of Measure Code")
        then
            exit;

        ItemUnitOfMeasure.TestField("NPR Block on POS Sale", false);
    end;
}