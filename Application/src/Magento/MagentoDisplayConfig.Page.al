page 6151443 "NPR Magento Display Config"
{
    Caption = 'Display Config';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Magento Display Config";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(Control6150616)
            {
                ShowCaption = false;
                field(ItemTypeFilter; ItemTypeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Type Filter';
                    ToolTip = 'Specifies the value of the Type Filter field';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                        NumberFilter := '';
                        SetRecFilters();
                    end;
                }
                field(NumberFilterCtrl; NumberFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Code Filter';
                    Editable = NumberFilterCtrlEnabled;
                    Enabled = NumberFilterCtrlEnabled;
                    ToolTip = 'Specifies the value of the Code Filter field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                        ItemGroups: Page "NPR Magento Category List";
                        Brands: Page "NPR Magento Brands";
                    begin
                        case Rec.Type of
                            Rec.Type::Item:
                                begin
                                    ItemList.LookupMode := true;
                                    if ItemList.RunModal() = ACTION::LookupOK then
                                        Text := ItemList.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                            Rec.Type::"Item Group":
                                begin
                                    ItemGroups.LookupMode := true;
                                    if ItemGroups.RunModal() = ACTION::LookupOK then
                                        Text := ItemGroups.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                            Rec.Type::Brand:
                                begin
                                    Brands.LookupMode := true;
                                    if Brands.RunModal() = ACTION::LookupOK then
                                        Text := Brands.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                        end;

                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                        SetRecFilters();
                    end;
                }
            }
            repeater(Control6150617)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Type field';
                }
                field("Sales Code"; Rec."Sales Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Code field';
                }
                field("Is Visible"; Rec."Is Visible")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Is Visible field';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Time field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        GetRecFilters();
        SetRecFilters();
    end;

    var
        ItemGroup: Record "NPR Magento Category";
        Item: Record Item;
        ItemTypeFilter: Enum "NPR Mag. Display Config Type";
        NumberFilter: Text[250];
        NumberFilterCtrlEnabled: Boolean;

    procedure GetRecFilters()
    var
        TempTypeFilter: Text;
    begin
        if Rec.GetFilters <> '' then begin
            TempTypeFilter := Rec.GetFilter(Type);
            if TempTypeFilter <> '' then begin
                Evaluate(Rec.Type, TempTypeFilter);
                ItemTypeFilter := Rec.Type;
            end else
                ItemTypeFilter := ItemTypeFilter::None;

            NumberFilter := Rec.GetFilter("No.");
        end;
    end;

    procedure SetRecFilters()
    begin
        NumberFilterCtrlEnabled := true;

        Rec.SetRange(Type);
        case ItemTypeFilter of
            ItemTypeFilter::Item:
                Rec.SetRange(Type, Rec.Type::Item);
            ItemTypeFilter::"Item Group":
                Rec.SetRange(Type, Rec.Type::"Item Group");
            ItemTypeFilter::Brand:
                Rec.SetRange(Type, Rec.Type::Brand);
        end;

        if ItemTypeFilter = ItemTypeFilter::None then begin
            NumberFilterCtrlEnabled := false;
            NumberFilter := '';
        end;
        CurrPage.Update(false);
    end;

    procedure GetCaption(): Text[250]
    var
        ObjTransl: Record "Object Translation";
        SourceTableName: Text[100];
        SalesSrcTableName: Text[100];
        Description: Text[250];
    begin
        GetRecFilters();



        SourceTableName := '';
        case ItemTypeFilter of
            ItemTypeFilter::Item:
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 27);
                    Item."No." := NumberFilter;
                end;
            ItemTypeFilter::"Item Group":
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 6059852);
                    ItemGroup.Id := NumberFilter;
                end;
        end;

        exit(StrSubstNo('%1 %2 %3 %4', SalesSrcTableName, Description, SourceTableName, NumberFilter));
    end;
}