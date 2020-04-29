page 6151446 "Magento Store Item Gr. Subform"
{
    // MAG1.16/TR/20150402  CASE 210548 Object created and modfied.
    // MAG1.17/TR/20150522 CASE 210548 Object modified for use.
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Magento Store Item Group';
    PageType = CardPart;
    ShowFilter = false;
    SourceTable = "Magento Store Item Group";

    layout
    {
        area(content)
        {
            field(StoreCode;StoreCode)
            {
                Caption = 'Store Code';

                trigger OnLookup(var Text: Text): Boolean
                var
                    MagentoStores: Page "Magento Stores";
                    MagentoStore: Record "Magento Store";
                begin
                    MagentoStores.LookupMode(true);
                    MagentoStores.SetTableView(MagentoStore);
                    if MagentoStores.RunModal = ACTION::LookupOK then begin
                      MagentoStores.GetRecord(MagentoStore);
                      StoreCode := MagentoStore.Code;
                    end;

                    SetRecFilters;
                end;
            }
            grid(Control6150615)
            {
                GridLayout = Columns;
                ShowCaption = false;
                group(Control6150616)
                {
                    ShowCaption = false;
                    field(Name;Name)
                    {
                    }
                    field("Is Active";"Is Active")
                    {
                    }
                    field("Show In Navigation Menu";"Show In Navigation Menu")
                    {
                    }
                    field(Picture;Picture)
                    {
                    }
                    field("FORMAT(Description.HASVALUE)";Format(Description.HasValue))
                    {
                        Caption = 'Description';

                        trigger OnAssistEdit()
                        var
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            RecRef.GetTable(Rec);
                            FieldRef := RecRef.Field(FieldNo(Description));
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                              RecRef.SetTable(Rec);
                              Modify(true);
                            end;
                        end;
                    }
                    field("Seo Link";"Seo Link")
                    {
                    }
                    field("Meta Title";"Meta Title")
                    {
                    }
                    field("Meta Keywords";"Meta Keywords")
                    {
                    }
                    field("Meta Description";"Meta Description")
                    {
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        StoreCode := "Store Code";
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec."Is Active" <> Rec."Is Active" then begin
            UpdateSubItemGroups("No.","Store Code");
        end;
    end;

    var
        StoreCode: Code[32];
        MagentoFunctions: Codeunit "Magento Functions";
        MagentoItemGroup: Record "Magento Item Group";

    procedure SetRecFilters()
    var
        MagentoStore: Record "Magento Store";
        MagentoStoreItemGroup: Record "Magento Store Item Group";
        MagentoStoreItemGroup2: Record "Magento Store Item Group";
    begin
        if not MagentoStore.Get(StoreCode) then
          exit;

        if MagentoStoreItemGroup.Get("No.",MagentoStore.Code) then begin
          Modify(true);
        end else begin
          MagentoStoreItemGroup2.Init;
          MagentoStoreItemGroup2."No." := "No.";
          MagentoStoreItemGroup2."Store Code" := MagentoStore.Code;
          MagentoStoreItemGroup2.Insert(true);
        end;

        SetRange("Store Code",MagentoStore.Code);
        CurrPage.Update(false);
    end;

    local procedure UpdateSubItemGroups(ItemGroupNo: Code[20];StoreCode: Code[20])
    var
        MagentoStoreItemGroup: Record "Magento Store Item Group";
    begin
        MagentoItemGroup.Get(ItemGroupNo);
        MagentoItemGroup.CalcFields("Has Child Groups");
        if not MagentoItemGroup."Has Child Groups" then
          exit;

        MagentoStoreItemGroup.SetRange("Parent Item Group No.",ItemGroupNo);
        MagentoStoreItemGroup.SetRange("Store Code",StoreCode);
        if MagentoStoreItemGroup.FindSet then repeat
          MagentoStoreItemGroup."Is Active" := "Is Active";
          MagentoStoreItemGroup.Modify(true);
          UpdateSubItemGroups(MagentoStoreItemGroup."No.",MagentoStoreItemGroup."Store Code");
        until MagentoStoreItemGroup.Next = 0;
    end;
}

