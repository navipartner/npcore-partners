page 6151420 "Magento Brands"
{
    // MAG1.01/MH/20150201  CASE 199932 Refactored Object from Web Integration
    // MAG1.05/TR/20150217  CASE 206156 Added function GetSelectionFilter
    // MAG1.20/TS/20151005 CASE 224193  Added field Sorting
    // MAG1.21/TR/20151028  CASE 225601 Shortcut to Display Config added
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.09/TS  /20180108  CASE 300893 Removed Caption on Action Container

    Caption = 'Brands';
    CardPageID = "Magento Brand Card";
    PageType = List;
    SourceTable = "Magento Brand";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                }
                field(Name;Name)
                {
                }
                field(Picture;Picture)
                {
                }
                field(Sorting;Sorting)
                {
                }
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
                RunObject = Page "Magento Brand Card";
                ShortCutKey = 'Shift+F5';
            }
            action("Display Config")
            {
                Caption = 'Display Config';
                Image = ViewPage;
                Visible = DisplayConfigVisible;

                trigger OnAction()
                var
                    MagentoDisplayConfigPage: Page "Magento Display Config";
                    MagentoDisplayConfig: Record "Magento Display Config";
                begin
                    //-MAG1.21
                    MagentoDisplayConfig.SetRange(Type,MagentoDisplayConfig.Type::Brand);
                    MagentoDisplayConfigPage.SetTableView(MagentoDisplayConfig);
                    MagentoDisplayConfigPage.Run;
                    //+MAG1.21
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        //-MAG1.21
        SetDisplayConfigVisible;
        //+MAG1.21
    end;

    var
        DisplayConfigVisible: Boolean;

    procedure GetSelectionFilter(): Text
    var
        Brand: Record "Magento Brand";
        MagentoSelectionFilterMgt: Codeunit "Magento Selection Filter Mgt.";
    begin
        CurrPage.SetSelectionFilter(Brand);
        //-MAG2.00
        //EXIT(MagentoFunctions.GetSelectionFilterForManufacturer(Manufacturer));
        exit(MagentoSelectionFilterMgt.GetSelectionFilterForBrand(Brand));
        //+MAG2.00
    end;

    local procedure SetDisplayConfigVisible()
    var
        MagentoSetup: Record "Magento Setup";
        MagentoWebsite: Record "Magento Website";
    begin
        //-MAG1.21
        DisplayConfigVisible := MagentoSetup.Get and MagentoSetup."Magento Enabled" and MagentoSetup."Customers Enabled";
        //+MAG1.21
    end;
}

