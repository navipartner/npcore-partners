page 6014425 "NPR Magento Store Items Card"
{
    Caption = 'Magento Store Items Card';
    PageType = Card;

    UsageCategory = Administration;
    SourceTable = "NPR Magento Store Item";
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Webshop; Rec.Webshop)
                {

                    ToolTip = 'Specifies the value of the Webshop field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Code"; Rec."Store Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Website Code"; Rec."Website Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Website Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(GetEnabledFieldsCaption; Rec.GetEnabledFieldsCaption())
                {

                    Caption = 'Fields Enabled';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Fields Enabled field';
                    ApplicationArea = NPRRetail;
                }

            }
            group(MagentoStoreItemGroupWebsite)
            {
                Caption = 'Website';

                grid(UnitPriceGrid)
                {
                    field("Unit Price"; Rec."Unit Price")
                    {

                        ToolTip = 'Specifies the value of the Unit Price field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Unit Price Enabled"; Rec."Unit Price Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Unit Price Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(ProductNewGroup)
                {
                    Caption = 'Product New';
                    grid(ProductNewFromGrid)
                    {
                        field("Product New From"; Rec."Product New From")
                        {

                            ToolTip = 'Specifies the value of the Product New From field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Product New From Enabled"; Rec."Product New From Enabled")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Product New From Enabled field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    grid(ProductNewToGrid)
                    {
                        field("Product New To"; Rec."Product New To")
                        {

                            ToolTip = 'Specifies the value of the Product New To field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Product New To Enabled"; Rec."Product New To Enabled")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Product New To Enabled field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                group(SpecialPriceGroup)
                {
                    Caption = 'Special Price';

                    grid(SpecialPriceGrid)
                    {
                        field("Special Price"; Rec."Special Price")
                        {

                            ToolTip = 'Specifies the value of the Special Price field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Special Price Enabled"; Rec."Special Price Enabled")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Special Price Enabled field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    grid(SpecialPriceFromGrid)
                    {
                        field("Special Price From"; Rec."Special Price From")
                        {

                            ToolTip = 'Specifies the value of the Special Price From field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Special Price From Enabled"; Rec."Special Price From Enabled")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Special Price From Enabled field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    grid(SpecialPriceToGrid)
                    {
                        field("Special Price To"; Rec."Special Price To")
                        {

                            ToolTip = 'Specifies the value of the Special Price To field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Special Price To Enabled"; Rec."Special Price To Enabled")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Special Price To Enabled field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
            group(MagentoStoreItemStore)
            {
                Caption = 'Store';

                grid(WebshopNameGrid)
                {
                    field("Webshop Name"; Rec."Webshop Name")
                    {

                        Caption = 'Name';
                        ToolTip = 'Specifies the value of the Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Webshop Name Enabled"; Rec."Webshop Name Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Webshop Name Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                }
                grid(WebshopDescriptionGrid)
                {
                    field("Webshop Description"; Format(Rec."Webshop Description".HasValue()))
                    {

                        Caption = 'Description';
                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            RecRef.GetTable(Rec);
                            FieldRef := RecRef.Field(Rec.FieldNo("Webshop Description"));
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Rec.Modify(true);
                            end;
                        end;
                    }

                    field("Webshop Description Enabled"; Rec."Webshop Description Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Webshop Description Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                }

                grid(WebshopShortDescGrid)
                {
                    field("Webshop Short Description"; Format(Rec."Webshop Short Desc.".HasValue()))
                    {

                        Caption = 'Short Description';
                        ToolTip = 'Specifies the value of the Short Description field';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            RecRef.GetTable(Rec);
                            FieldRef := RecRef.Field(Rec.FieldNo("Webshop Short Desc."));
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Rec.Modify(true);
                            end;
                        end;
                    }
                    field("Webshop Short Desc. Enabled"; Rec."Webshop Short Desc. Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Webshop Short Description Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field(Visibility; Rec.Visibility)
                {

                    ToolTip = 'Specifies the value of the Visibility field';
                    ApplicationArea = NPRRetail;
                }
                grid(DisplayOnlyGrid)
                {
                    field("Display Only"; Rec."Display Only")
                    {

                        ToolTip = 'Specifies the value of the Display Only field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Display Only Enabled"; Rec."Display Only Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Display Only Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                }
                grid(DisplayOnlyTextGrid)
                {
                    field("Display Only Text"; Rec."Display Only Text")
                    {

                        ToolTip = 'Specifies the value of the Display Only Text field';
                        ApplicationArea = NPRRetail;
                    }
                }
                grid(SeoLinkGrid)
                {
                    field("Seo Link"; Rec."Seo Link")
                    {

                        ToolTip = 'Specifies the value of the Seo Link field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Seo Link Enabled"; Rec."Seo Link Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Seo Link Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                }
                grid(MetaTitleGrid)
                {
                    field("Meta Title"; Rec."Meta Title")
                    {

                        ToolTip = 'Specifies the value of the Meta Title field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Meta Title Enabled"; Rec."Meta Title Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Meta Title Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                }
                grid(MetaDescriptionGrid)
                {
                    field("Meta Description"; Rec."Meta Description")
                    {

                        ToolTip = 'Specifies the value of the Meta Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Meta Description Enabled"; Rec."Meta Description Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Meta Description Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(MagentoCategoryLinks)
            {
                Caption = 'Category Links';
                part(MagentoItemGroupLinks; "NPR Magento Category Links")
                {
                    SubPageLink = "Item No." = FIELD("Item No.");
                    ApplicationArea = NPRRetail;

                }
            }
        }
    }
}
