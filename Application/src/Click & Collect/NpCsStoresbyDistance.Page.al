page 6151208 "NPR NpCs Stores by Distance"
{
    Caption = 'Collect Stores by Distance';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpCs Store";
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
                    field(FromStoreCode; FromStoreCode)
                    {
                        ApplicationArea = All;
                        Caption = 'From Store Code';
                        TableRelation = "NPR NpCs Store";
                        Visible = (NOT ShowInventory);
                        ToolTip = 'Specifies the value of the From Store Code field';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            NpCsStore: Record "NPR NpCs Store";
                        begin
                            if PAGE.RunModal(0, NpCsStore) = ACTION::LookupOK then begin
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
                    field("Show In Stock only"; InStockOnly)
                    {
                        ApplicationArea = All;
                        Caption = 'Show In Stock only';
                        Visible = ShowInventory;
                        ToolTip = 'Specifies the value of the Show In Stock only field';

                        trigger OnValidate()
                        begin
                            FilterGroup(2);
                            SetRange("In Stock");
                            if InStockOnly then
                                SetRange("In Stock", true);
                            FilterGroup(0);

                            CurrPage.Update(false);
                        end;
                    }
                }
                group(Control6014420)
                {
                    ShowCaption = false;
                    field("''"; '')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Visible = ShowInventory;
                        ToolTip = 'Specifies the value of the '''' field';
                    }
                }
            }
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("In Stock"; "In Stock")
                {
                    ApplicationArea = All;
                    Visible = ShowInventory;
                    ToolTip = 'Specifies the value of the In Stock field';
                }
                field("Requested Qty."; "Requested Qty.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Requested Qty. field';
                }
                field("Fullfilled Qty."; "Fullfilled Qty.")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Fullfilled Qty. field';
                }
                field("Distance (km)"; "Distance (km)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the value of the Distance (km) field';
                }
                field("Contact Address"; "Contact Address")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Contact Address field';
                }
                field("Contact Post Code"; "Contact Post Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Contact Post Code field';
                }
                field("Contact City"; "Contact City")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Contact City field';
                }
                field("Contact Country/Region Code"; "Contact Country/Region Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Contact Country/Region Code field';
                }
                field("Contact Phone No."; "Contact Phone No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Contact Phone No. field';
                }
                field("Contact E-mail"; "Contact E-mail")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = "In Stock";
                    ToolTip = 'Specifies the value of the Contact E-mail field';
                }
                field("Geolocation Latitude"; "Geolocation Latitude")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = (NOT ShowInventory);
                    ToolTip = 'Specifies the value of the Geolocation Latitude field';
                }
                field("Geolocation Longitude"; "Geolocation Longitude")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = (NOT ShowInventory);
                    ToolTip = 'Specifies the value of the Geolocation Longitude field';
                }
            }
            part(Lines; "NPR NpCs Store Inv. Buffer")
            {
                Caption = 'Inventory';
                SubPageLink = "Store Code" = FIELD(Code);
                Visible = ShowInventory;
                ApplicationArea = All;
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
                RunObject = Page "NPR NpCs Store Card";
                RunPageLink = Code = FIELD(Code);
                ShortCutKey = 'Shift+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Card action';
            }
        }
    }

    trigger OnOpenPage()
    var
        NpCsStore: Record "NPR NpCs Store";
    begin
        if not NpCsStore.Get(FromStoreCode) then begin
            NpCsStoreMgt.FindLocalStore(NpCsStore);
            FromStoreCode := NpCsStore.Code;
        end;

        InitSourceTable();
    end;

    var
        TempNpCsStore: Record "NPR NpCs Store" temporary;
        NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
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
        NpCsStore: Record "NPR NpCs Store";
    begin
        if not IsTemporary then
            exit;

        if TempNpCsStore.FindFirst then begin
            Copy(TempNpCsStore, true);
            exit;
        end;

        DeleteAll;

        if not NpCsStore.Get(FromStoreCode) then
            exit;

        NpCsStoreMgt.InitStoresWithDistance(NpCsStore, Rec);
    end;

    procedure SetSourceTables(var TempNpCsStore2: Record "NPR NpCs Store" temporary; var NpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary)
    begin
        TempNpCsStore.Copy(TempNpCsStore2, true);
        CurrPage.Lines.PAGE.SetSourceTable(NpCsStoreInventoryBuffer);
    end;

    procedure SetShowInventory(NewShowInventory: Boolean)
    begin
        ShowInventory := NewShowInventory;
    end;
}

