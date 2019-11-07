page 6151208 "NpCs Stores by Distance"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.52/MHA /20191002  CASE 369476 PageType changed from Worksheet to List to enabled RunModal from Phone

    Caption = 'Collect Stores by Distance';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NpCs Store";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Distance (km)");

    layout
    {
        area(content)
        {
            grid(Control6014417)
            {
                ShowCaption = false;
                group(Control6014413)
                {
                    ShowCaption = false;
                    field(FromStoreCode;FromStoreCode)
                    {
                        Caption = 'From Store Code';
                        TableRelation = "NpCs Store";
                        Visible = (NOT ShowInventory);

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            NpCsStore: Record "NpCs Store";
                        begin
                            if PAGE.RunModal(0,NpCsStore) = ACTION::LookupOK then begin
                              FromStoreCode := NpCsStore.Code;
                              InitSourceTable();
                              CurrPage.Update(false);
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            InitSourceTable();
                            CurrPage.Update(false);
                        end;
                    }
                    field("Show In Stock only";InStockOnly)
                    {
                        Caption = 'Show In Stock only';
                        Visible = ShowInventory;

                        trigger OnValidate()
                        begin
                            FilterGroup(2);
                            SetRange("In Stock");
                            if InStockOnly then
                              SetRange("In Stock",true);
                            FilterGroup(0);

                            CurrPage.Update(false);
                        end;
                    }
                }
                group(Control6014420)
                {
                    ShowCaption = false;
                    field("''";'')
                    {
                        ShowCaption = false;
                        Visible = ShowInventory;
                    }
                }
            }
            repeater(Group)
            {
                field("Code";Code)
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field(Name;Name)
                {
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("Company Name";"Company Name")
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    Visible = false;
                }
                field("In Stock";"In Stock")
                {
                    Visible = ShowInventory;
                }
                field("Requested Qty.";"Requested Qty.")
                {
                }
                field("Fullfilled Qty.";"Fullfilled Qty.")
                {
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("Distance (km)";"Distance (km)")
                {
                    Editable = false;
                    StyleExpr = TRUE;
                }
                field("Contact Address";"Contact Address")
                {
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("Contact Post Code";"Contact Post Code")
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("Contact City";"Contact City")
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("Contact Country/Region Code";"Contact Country/Region Code")
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("Contact Phone No.";"Contact Phone No.")
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("Contact E-mail";"Contact E-mail")
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                }
                field("Geolocation Latitude";"Geolocation Latitude")
                {
                    Editable = false;
                    Visible = (NOT ShowInventory);
                }
                field("Geolocation Longitude";"Geolocation Longitude")
                {
                    Editable = false;
                    Visible = (NOT ShowInventory);
                }
            }
            part(Lines;"NpCs Store Inventory Buffer")
            {
                Caption = 'Inventory';
                SubPageLink = "Store Code"=FIELD(Code);
                Visible = ShowInventory;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Card)
            {
                Caption = 'Card';
                Image = Card;
                RunObject = Page "NpCs Store Card";
                RunPageLink = Code=FIELD(Code);
                ShortCutKey = 'Shift+F7';
            }
        }
    }

    trigger OnOpenPage()
    var
        NpCsStore: Record "NpCs Store";
    begin
        if not NpCsStore.Get(FromStoreCode) then begin
          NpCsStoreMgt.FindLocalStore(NpCsStore);
          FromStoreCode := NpCsStore.Code;
        end;

        //-NPR5.52 [369476]
        InitSourceTable();
        //+NPR5.52 [369476]
    end;

    var
        TempNpCsStore: Record "NpCs Store" temporary;
        NpCsStoreMgt: Codeunit "NpCs Store Mgt.";
        FromStoreCode: Code[20];
        ShowInventory: Boolean;
        InStockOnly: Boolean;

    procedure SetFromStoreCode(NewFromStoreCode: Code[20])
    begin
        FromStoreCode := NewFromStoreCode;
        InitSourceTable();
    end;

    local procedure InitSourceTable()
    var
        NpCsStore: Record "NpCs Store";
    begin
        if not IsTemporary then
          exit;

        //-NPR5.52 [369476]
        if TempNpCsStore.FindFirst then begin
          Copy(TempNpCsStore,true);
          exit;
        end;
        //+NPR5.52 [369476]

        DeleteAll;

        if not NpCsStore.Get(FromStoreCode) then
          exit;

        NpCsStoreMgt.InitStoresWithDistance(NpCsStore,Rec);
    end;

    procedure SetSourceTables(var TempNpCsStore2: Record "NpCs Store" temporary;var NpCsStoreInventoryBuffer: Record "NpCs Store Inventory Buffer" temporary)
    begin
        //-NPR5.52 [369476]
        TempNpCsStore.Copy(TempNpCsStore2,true);
        //+NPR5.52 [369476]
        CurrPage.Lines.PAGE.SetSourceTable(NpCsStoreInventoryBuffer);
    end;

    procedure SetShowInventory(NewShowInventory: Boolean)
    begin
        ShowInventory := NewShowInventory;
    end;
}

