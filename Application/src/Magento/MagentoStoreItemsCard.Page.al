page 6014425 "NPR Magento Store Items Card"
{
    Caption = 'Magento Store Items Card';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Store Item";
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Webshop; Webshop)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Webshop field';
                }
                field("Store Code"; "Store Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Store Code field';
                }
                field("Website Code"; "Website Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Website Code field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(GetEnabledFieldsCaption; GetEnabledFieldsCaption)
                {
                    ApplicationArea = All;
                    Caption = 'Fields Enabled';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Fields Enabled field';
                }

            }
            group(MagentoStoreItemGroupWebsite)
            {
                Caption = 'Website';

                grid(UnitPriceGrid)
                {
                    field("Unit Price"; "Unit Price")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Unit Price field';
                    }
                    field("Unit Price Enabled"; "Unit Price Enabled")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Unit Price Enabled field';
                    }
                }
                group(ProductNewGroup)
                {
                    Caption = 'Product New';
                    grid(ProductNewFromGrid)
                    {
                        field("Product New From"; "Product New From")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Product New From field';
                        }
                        field("Product New From Enabled"; "Product New From Enabled")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Product New From Enabled field';
                        }
                    }
                    grid(ProductNewToGrid)
                    {
                        field("Product New To"; "Product New To")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Product New To field';
                        }
                        field("Product New To Enabled"; "Product New To Enabled")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Product New To Enabled field';
                        }
                    }
                }
                group(SpecialPriceGroup)
                {
                    Caption = 'Special Price';

                    grid(SpecialPriceGrid)
                    {
                        field("Special Price"; "Special Price")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Special Price field';
                        }
                        field("Special Price Enabled"; "Special Price Enabled")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Special Price Enabled field';
                        }
                    }
                    grid(SpecialPriceFromGrid)
                    {
                        field("Special Price From"; "Special Price From")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Special Price From field';
                        }
                        field("Special Price From Enabled"; "Special Price From Enabled")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Special Price From Enabled field';
                        }
                    }
                    grid(SpecialPriceToGrid)
                    {
                        field("Special Price To"; "Special Price To")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Special Price To field';
                        }
                        field("Special Price To Enabled"; "Special Price To Enabled")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Special Price To Enabled field';
                        }
                    }
                }
            }
            group(MagentoStoreItemStore)
            {
                Caption = 'Store';

                grid(WebshopNameGrid)
                {
                    field("Webshop Name"; "Webshop Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        ToolTip = 'Specifies the value of the Name field';
                    }
                    field("Webshop Name Enabled"; "Webshop Name Enabled")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Webshop Name Enabled field';
                    }
                }
                grid(WebshopDescriptionGrid)
                {
                    field("FORMAT(""Webshop Description"".HASVALUE)"; Format("Webshop Description".HasValue))
                    {
                        ApplicationArea = All;
                        Caption = 'Description';
                        ToolTip = 'Specifies the value of the Description field';

                        trigger OnAssistEdit()
                        var
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                        begin
                            RecRef.GetTable(Rec);
                            FieldRef := RecRef.Field(FieldNo("Webshop Description"));
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Modify(true);
                            end;
                        end;
                    }

                    field("Webshop Description Enabled"; "Webshop Description Enabled")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Webshop Description Enabled field';
                    }
                }

                grid(WebshopShortDescGrid)
                {
                    field("FORMAT(""Webshop Short Desc."".HASVALUE)"; Format("Webshop Short Desc.".HasValue))
                    {
                        ApplicationArea = All;
                        Caption = 'Short Description';
                        ToolTip = 'Specifies the value of the Short Description field';

                        trigger OnAssistEdit()
                        var
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                        begin
                            RecRef.GetTable(Rec);
                            FieldRef := RecRef.Field(FieldNo("Webshop Short Desc."));
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Modify(true);
                            end;
                        end;
                    }
                    field("Webshop Short Desc. Enabled"; "Webshop Short Desc. Enabled")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Webshop Short Description Enabled field';
                    }
                }
                field(Visibility; Visibility)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Visibility field';
                }
                grid(DisplayOnlyGrid)
                {
                    field("Display Only"; "Display Only")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Display Only field';
                    }
                    field("Display Only Enabled"; "Display Only Enabled")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Display Only Enabled field';
                    }
                }
                grid(SeoLinkGrid)
                {
                    field("Seo Link"; "Seo Link")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Seo Link field';
                    }
                    field("Seo Link Enabled"; "Seo Link Enabled")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Seo Link Enabled field';
                    }
                }
                grid(MetaTitleGrid)
                {
                    field("Meta Title"; "Meta Title")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Meta Title field';
                    }
                    field("Meta Title Enabled"; "Meta Title Enabled")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Meta Title Enabled field';
                    }
                }
                grid(MetaDescriptionGrid)
                {
                    field("Meta Description"; "Meta Description")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Meta Description field';
                    }
                    field("Meta Description Enabled"; "Meta Description Enabled")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Meta Description Enabled field';
                    }
                }
            }
            group(MagentoCategoryLinks)
            {
                Caption = 'Category Links';
                part(MagentoItemGroupLinks; "NPR Magento Category Links")
                {
                    SubPageLink = "Item No." = FIELD("Item No.");
                    ApplicationArea = All;
                }
            }
        }
    }
}
