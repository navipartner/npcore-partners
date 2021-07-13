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
    ApplicationArea = NPRRetail;

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

                        Caption = 'From Store Code';
                        TableRelation = "NPR NpCs Store";
                        Visible = (NOT ShowInventory);
                        ToolTip = 'Specifies the value of the From Store Code field';
                        ApplicationArea = NPRRetail;

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

                        Caption = 'Show In Stock only';
                        Visible = ShowInventory;
                        ToolTip = 'Specifies the value of the Show In Stock only field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            Rec.FilterGroup(2);
                            Rec.SetRange("In Stock");
                            if InStockOnly then
                                Rec.SetRange("In Stock", true);
                            Rec.FilterGroup(0);

                            CurrPage.Update(false);
                        end;
                    }
                }
                group(Control6014420)
                {
                    ShowCaption = false;
                    field("''"; '')
                    {

                        ShowCaption = false;
                        Visible = ShowInventory;
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    Editable = false;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {

                    Editable = false;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    Visible = false;
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("In Stock"; Rec."In Stock")
                {

                    Visible = ShowInventory;
                    ToolTip = 'Specifies the value of the In Stock field';
                    ApplicationArea = NPRRetail;
                }
                field("Requested Qty."; Rec."Requested Qty.")
                {

                    ToolTip = 'Specifies the value of the Requested Qty. field';
                    ApplicationArea = NPRRetail;
                }
                field("Fullfilled Qty."; Rec."Fullfilled Qty.")
                {

                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Fullfilled Qty. field';
                    ApplicationArea = NPRRetail;
                }
                field("Distance (km)"; Rec."Distance (km)")
                {

                    Editable = false;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the value of the Distance (km) field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Address"; Rec."Contact Address")
                {

                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Contact Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Post Code"; Rec."Contact Post Code")
                {

                    Editable = false;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Contact Post Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact City"; Rec."Contact City")
                {

                    Editable = false;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Contact City field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Country/Region Code"; Rec."Contact Country/Region Code")
                {

                    Editable = false;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Contact Country/Region Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Phone No."; Rec."Contact Phone No.")
                {

                    Editable = false;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Contact Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact E-mail"; Rec."Contact E-mail")
                {

                    Editable = false;
                    Style = Favorable;
                    StyleExpr = Rec."In Stock";
                    ToolTip = 'Specifies the value of the Contact E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Geolocation Latitude"; Rec."Geolocation Latitude")
                {

                    Editable = false;
                    Visible = (NOT ShowInventory);
                    ToolTip = 'Specifies the value of the Geolocation Latitude field';
                    ApplicationArea = NPRRetail;
                }
                field("Geolocation Longitude"; Rec."Geolocation Longitude")
                {

                    Editable = false;
                    Visible = (NOT ShowInventory);
                    ToolTip = 'Specifies the value of the Geolocation Longitude field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Lines; "NPR NpCs Store Inv. Buffer")
            {
                Caption = 'Inventory';
                SubPageLink = "Store Code" = FIELD(Code);
                Visible = ShowInventory;
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Card action';
                ApplicationArea = NPRRetail;
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
        if not Rec.IsTemporary then
            exit;

        if TempNpCsStore.FindFirst() then begin
            Rec.Copy(TempNpCsStore, true);
            exit;
        end;

        Rec.DeleteAll();

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

