page 6151443 "Magento Display Config"
{
    // MAG1.05/TR/20150217 CASE 206395 Object created - controls visibility in Magento
    // MAG1.06/MH/20150225  CASE 206395 Added (Hidden) Option to Field 40 Sales Type: Contact
    // MAG1.21/TR/20151023  CASE 225294 ItemGroups local variabel changed from 6059855 Magento Item Groups to 6059854 "Magento Item Group List" page - NumberFilterCtrl-OnLookup()
    // MAG1.21/TR/20151104  CASE 225601 GetRecFilters has been modified such that it is possible to run the page even if no records exist
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.09/TS  /20180108  CASE 300893 Removed Caption on Control Container

    Caption = 'Display Config';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Magento Display Config";
    SourceTableView = SORTING("No.",Type,"Sales Code","Sales Type","Starting Date","Starting Time","Ending Date","Ending Time")
                      WHERE("Sales Type"=FILTER(<>"3"));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            group(Control6150616)
            {
                ShowCaption = false;
                field(ItemTypeFilter;ItemTypeFilter)
                {
                    Caption = 'Type Filter';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        NumberFilter := '';
                        SetRecFilters;
                    end;
                }
                field(NumberFilterCtrl;NumberFilter)
                {
                    Caption = 'Code Filter';
                    Editable = NumberFilterCtrlEnabled;
                    Enabled = NumberFilterCtrlEnabled;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                        ItemGroups: Page "Magento Item Group List";
                        Brands: Page "Magento Brands";
                    begin
                        case Type of
                          Type::Item:
                            begin
                              ItemList.LookupMode := true;
                              if ItemList.RunModal = ACTION::LookupOK then
                                Text := ItemList.GetSelectionFilter
                              else
                                exit(false);
                            end;
                          Type::"Item Group":
                            begin
                              ItemGroups.LookupMode := true;
                              if ItemGroups.RunModal = ACTION::LookupOK then
                                Text := ItemGroups.GetSelectionFilter
                              else
                                exit(false);
                            end;
                          Type::Brand:
                            begin
                              Brands.LookupMode := true;
                              if Brands.RunModal = ACTION::LookupOK then
                                Text := Brands.GetSelectionFilter
                              else
                                exit(false);
                            end;
                        end;

                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        SetRecFilters;
                    end;
                }
            }
            repeater(Control6150617)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Type;Type)
                {
                }
                field("Sales Type";"Sales Type")
                {
                }
                field("Sales Code";"Sales Code")
                {
                }
                field("Is Visible";"Is Visible")
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Ending Date";"Ending Date")
                {
                }
                field("Ending Time";"Ending Time")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        GetRecFilters;
        SetRecFilters;
    end;

    var
        ItemGroup: Record "Magento Item Group";
        Manufactur: Record "Magento Brand";
        Item: Record Item;
        ItemTypeFilter: Option Item,"Item Group",Brand,"None";
        NumberFilter: Text[250];
        NumberFilterCtrlEnabled: Boolean;
        SalesCodeEnabled: Boolean;

    procedure GetRecFilters()
    var
        TempTypeFilter: Text;
    begin
        if GetFilters <> '' then begin
          //-MAG1.21
          //IF GETFILTER("No.") <> '' THEN
          TempTypeFilter := GetFilter(Type);
          if TempTypeFilter <> '' then begin
            Evaluate(Type,TempTypeFilter);
          //+MAG1.21
            ItemTypeFilter := Type;
          end else
            ItemTypeFilter := ItemTypeFilter::None;

          NumberFilter := GetFilter("No.");
        end;
    end;

    procedure SetRecFilters()
    begin
        NumberFilterCtrlEnabled := true;

        SetRange(Type);
        case ItemTypeFilter of
          ItemTypeFilter::Item : SetRange(Type,Type::Item);
          ItemTypeFilter::"Item Group" : SetRange(Type,Type::"Item Group");
          ItemTypeFilter::Brand : SetRange(Type,Type::Brand);
        end;

        if ItemTypeFilter = ItemTypeFilter::None then begin
          NumberFilterCtrlEnabled := false;
          NumberFilter := '';
        end;

        //-MAG1.21
        //IF NumberFilter <> '' THEN BEGIN
        //  SETFILTER(Type, NumberFilter);
        //END;// ELSE
        //  SETRANGE(Type);
        //+MAG1.21

        CurrPage.Update(false);
    end;

    procedure GetCaption(): Text[250]
    var
        ObjTransl: Record "Object Translation";
        SourceTableName: Text[100];
        SalesSrcTableName: Text[100];
        Description: Text[250];
    begin
        GetRecFilters;

        if "Sales Type" <> "Sales Type"::"All Customers" then
          SalesCodeEnabled := true
        else
          SalesCodeEnabled := false;

        SourceTableName := '';
        case ItemTypeFilter of
          ItemTypeFilter::Item:
            begin
              SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table,27);
              Item."No." := NumberFilter;
            end;
          ItemTypeFilter::"Item Group":
            begin
              SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table,6059852);
              ItemGroup."No." := NumberFilter;
            end;
        end;

        exit(StrSubstNo('%1 %2 %3 %4',SalesSrcTableName,Description,SourceTableName,NumberFilter));
    end;
}

