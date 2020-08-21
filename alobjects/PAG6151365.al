page 6151365 "CS Upd. Unknown Entries"
{
    // NPR5.55/ALST/20200727 CASE 415521 created for manually updating the unknown entries created by the RFID scanner

    Caption = 'Update Unknown Entries';
    PageType = List;
    SourceTable = "CS Stock-Takes Data";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tag Id"; "Tag Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(AssociateLines)
            {
                Caption = 'Associate Selected Lines to Item/Variant';
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ItemCrossReference: Record "Item Cross Reference";
                    CSStockTakesData: Record "CS Stock-Takes Data";
                    CSStockTakesData2: Record "CS Stock-Takes Data";
                    TempCSStockTakesData: Record "CS Stock-Takes Data" temporary;
                    CSRfidData: Record "CS Rfid Data";
                    Item: Record Item;
                    CSHelperFunctions: Codeunit "CS Helper Functions";
                    CSSelectEntries: Page "CS Select Entries";
                begin
                    CurrPage.SetSelectionFilter(CSStockTakesData);
                    if CSStockTakesData.GetFilters = '' then
                        Error(NoSelectionErr);

                    CSSelectEntries.Caption(StrSubstNo(SelectItemVariantCapt, CSStockTakesData.FieldCaption("Item No."), CSStockTakesData.FieldCaption("Variant Code")));
                    CSSelectEntries.LookupMode(true);

                    if CSSelectEntries.RunModal <> ACTION::Yes then
                        exit;

                    CSSelectEntries.GetRecord(TempCSStockTakesData);

                    if TempCSStockTakesData."Item No." = '' then
                        Error(NoItemNumberErr, CSStockTakesData.FieldCaption("Item No."), ItemCrossReference.TableCaption);

                    Item.Get(TempCSStockTakesData."Item No.");
                    Item.CalcFields("Has Variants");
                    if Item."Has Variants" and (TempCSStockTakesData."Variant Code" = '') then
                        Error(NoVariantSelectedErr, TempCSStockTakesData."Item No.");

                    if not Confirm(ConfirmUpdateMsg, true, CSStockTakesData.Count,
                      CSStockTakesData.FieldCaption("Item No."), TempCSStockTakesData."Item No.",
                      CSStockTakesData.FieldCaption("Variant Code"), TempCSStockTakesData."Variant Code")
                    then
                        exit;


                    if CSStockTakesData.FindSet then
                        repeat
                            ItemCrossReference.Init;
                            ItemCrossReference.Validate("Item No.", TempCSStockTakesData."Item No.");
                            ItemCrossReference.Validate("Variant Code", TempCSStockTakesData."Variant Code");
                            ItemCrossReference."Cross-Reference No." := CopyStr(CSStockTakesData."Tag Id", 5);
                            ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::"Bar Code";
                            ItemCrossReference."Is Retail Serial No." := true;
                            if ItemCrossReference.Insert(true) then begin
                                CSHelperFunctions.UpdateItemCrossRefFromRecord(ItemCrossReference);
                                CSStockTakesData.Validate("Item No.", TempCSStockTakesData."Item No.");
                                CSStockTakesData."Variant Code" := TempCSStockTakesData."Variant Code";
                                CSStockTakesData.Modify(false);
                            end;
                        until CSStockTakesData.Next = 0;

                    CurrPage.Update;
                end;
            }
        }
    }

    var
        ConfirmUpdateMsg: Label 'Please confirm you wish to update changes for %1 line(s) with "%2" : "%3" and "%4": "%5"';
        SelectItemVariantCapt: Label 'Select %1 and %2';
        NoItemNumberErr: Label 'You must select a valid %1 before associating them with %2';
        NoSelectionErr: Label 'Please select at least one entry before proceeding';
        NoVariantSelectedErr: Label 'Item "%1" has variants, please choose a varinat code as well';
}

