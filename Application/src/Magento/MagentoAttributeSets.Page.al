page 6151434 "NPR Magento Attribute Sets"
{
    // MAG1.00/MH  /20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.02/MH  /20150204  CASE 199932 Added UsedByItemDrillDown() and changed layout by adding Blank Text Field to control width of the Repeater Group
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.18/TS  /20180910  CASE 323934 Added Page Part Attribute Group

    AutoSplitKey = true;
    Caption = 'Attribute Sets';
    MultipleNewLines = false;
    PageType = List;
    SourceTable = "NPR Magento Attribute Set";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            grid("Attribute Sets")
            {
                Caption = 'Attribute Sets';
                group(Control6150620)
                {
                    ShowCaption = false;
                    repeater(Control6150613)
                    {
                        ShowCaption = false;
                        field(Description; Description)
                        {
                            ApplicationArea = All;
                        }
                        field("Used by Items"; "Used by Items")
                        {
                            ApplicationArea = All;

                            trigger OnDrillDown()
                            begin
                                //-MAG1.02
                                UsedByItemDrillDown();
                                //+MAG1.02
                            end;
                        }
                    }
                    field(WidthControl; '')
                    {
                        ApplicationArea = All;
                        Caption = '                                                                                                                                                             ';
                    }
                }
                group(Control6151400)
                {
                    ShowCaption = false;
                    part(Control6151401; "NPR Magento Attribute Group")
                    {
                        SubPageLink = "Attribute Set ID" = FIELD("Attribute Set ID");
                        ApplicationArea = All;
                    }
                }
                group(Control6150619)
                {
                    ShowCaption = false;
                    part(Attributes; "NPR Magento Attr. Set Values")
                    {
                        Caption = 'Attributes';
                        Provider = Control6151401;
                        SubPageLink = "Attribute Set ID" = FIELD("Attribute Set ID"),
                                      "Attribute Group ID" = FIELD("Attribute Group ID");
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnClosePage()
    var
        MagentoAttributeGroups: Page "NPR Magento Attribute Group";
    begin
    end;

    procedure UsedByItemDrillDown()
    var
        Item: Record Item;
        TempItem: Record Item temporary;
    begin
        //-MAG1.02
        TempItem.DeleteAll;
        Item.SetRange("NPR Attribute Set ID", "Attribute Set ID");
        if Item.FindSet then
            repeat
                TempItem.Init;
                TempItem := Item;
                TempItem.Insert;
            until Item.Next = 0;
        PAGE.Run(PAGE::"Item List", TempItem);
        //+MAG1.02
    end;
}

