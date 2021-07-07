page 6014462 "NPR Input Item"
{

    Caption = 'Input Item';
    PageType = StandardDialog;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                ShowCaption = false;
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    TableRelation = Item."No.";
                    ToolTip = 'Specifies the value of the Item No. field';
                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        VariantCode := '';
                        Item.Get(ItemNo);
                        ItemUOM := Item."Base Unit of Measure";
                    end;
                }
                field(VariantCode; VariantCode)
                {
                    ApplicationArea = All;
                    Caption = 'Variant Code';
                    ToolTip = 'Specifies the value of the Variant Code field';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if ItemNo = '' then
                            exit(false);
                        ItemVariant.FilterGroup(2);
                        ItemVariant.SetRange("Item No.", ItemNo);
                        ItemVariant.FilterGroup(0);
                        if Page.RunModal(0, ItemVariant) = Action::LookupOK then begin
                            Text := ItemVariant.Code;
                            exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        if VariantCode = '' then
                            exit;
                        ItemVariant.Get(ItemNo, VariantCode);
                    end;
                }
                field(ItemUOM; ItemUOM)
                {
                    ApplicationArea = All;
                    Caption = 'Item Unit of Measure';
                    ToolTip = 'Specifies the value of the Item Unit of Measure field';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if ItemNo = '' then
                            exit(false);
                        ItemUnitOfMeasure.FilterGroup(2);
                        ItemUnitOfMeasure.SetRange("Item No.", ItemNo);
                        ItemUnitOfMeasure.FilterGroup(0);
                        if Page.RunModal(0, ItemUnitOfMeasure) = Action::LookupOK then begin
                            Text := ItemUnitOfMeasure.Code;
                            exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        if ItemUOM = '' then
                            exit;
                        ItemUnitOfMeasure.Get(ItemNo, ItemUOM);
                    end;
                }
            }
        }
    }
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemVariant: Record "Item Variant";
        ItemNo: Code[20];
        ItemUOM: Code[10];
        VariantCode: Code[10];

    procedure GetValues(var ItemNoPrm: Code[20]; var VariantCodePrm: Code[10]; var ItemUOMPrm: Code[10])
    begin
        ItemNoPrm := ItemNo;
        ItemUOMPrm := ItemUOM;
        VariantCodePrm := VariantCode;
    end;
}
