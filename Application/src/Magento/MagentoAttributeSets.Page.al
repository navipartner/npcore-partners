page 6151434 "NPR Magento Attribute Sets"
{
    AutoSplitKey = true;
    Caption = 'Attribute Sets';
    MultipleNewLines = false;
    PageType = List;
    SourceTable = "NPR Magento Attribute Set";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


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
                        field(Description; Rec.Description)
                        {

                            ToolTip = 'Specifies the value of the Description field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Used by Items"; Rec."Used by Items")
                        {

                            ToolTip = 'Specifies the value of the Used by Items field';
                            ApplicationArea = NPRRetail;

                            trigger OnDrillDown()
                            begin
                                UsedByItemDrillDown();
                            end;
                        }
                    }
                    field(WidthControl; '')
                    {

                        Caption = '                                                                                                                                                             ';
                        ToolTip = 'Specifies the value of the '''' field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6151400)
                {
                    ShowCaption = false;
                    part(Control6151401; "NPR Magento Attribute Group")
                    {
                        SubPageLink = "Attribute Set ID" = FIELD("Attribute Set ID");
                        ApplicationArea = NPRRetail;

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
                        ApplicationArea = NPRRetail;

                    }
                }
            }
        }
    }

    procedure UsedByItemDrillDown()
    var
        Item: Record Item;
        TempItem: Record Item temporary;
    begin
        TempItem.DeleteAll();
        Item.SetRange("NPR Attribute Set ID", Rec."Attribute Set ID");
        if Item.FindSet() then
            repeat
                TempItem.Init();
                TempItem := Item;
                TempItem.Insert();
            until Item.Next() = 0;
        PAGE.Run(PAGE::"Item List", TempItem);
    end;
}