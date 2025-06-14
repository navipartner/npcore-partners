﻿page 6014425 "NPR Magento Store Items Card"
{
    Extensible = true;
    Caption = 'Magento Store Items Card';
    PageType = Card;
    UsageCategory = None;
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
                field(Webshop; Rec.Webshop)
                {

                    ToolTip = 'Specifies the value of the Webshop field';
                    ApplicationArea = NPRMagento;
                }
                field("Store Code"; Rec."Store Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Website Code"; Rec."Website Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Website Code field';
                    ApplicationArea = NPRMagento;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRMagento;

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
                    ApplicationArea = NPRMagento;
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
                        ApplicationArea = NPRMagento;
                    }
                    field("Unit Price Enabled"; Rec."Unit Price Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Unit Price Enabled field';
                        ApplicationArea = NPRMagento;
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
                            ApplicationArea = NPRMagento;
                        }
                        field("Product New From Enabled"; Rec."Product New From Enabled")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Product New From Enabled field';
                            ApplicationArea = NPRMagento;
                        }
                    }
                    grid(ProductNewToGrid)
                    {
                        field("Product New To"; Rec."Product New To")
                        {

                            ToolTip = 'Specifies the value of the Product New To field';
                            ApplicationArea = NPRMagento;
                        }
                        field("Product New To Enabled"; Rec."Product New To Enabled")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Product New To Enabled field';
                            ApplicationArea = NPRMagento;
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
                            ApplicationArea = NPRMagento;
                        }
                        field("Special Price Enabled"; Rec."Special Price Enabled")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Special Price Enabled field';
                            ApplicationArea = NPRMagento;
                        }
                    }
                    grid(SpecialPriceFromGrid)
                    {
                        field("Special Price From"; Rec."Special Price From")
                        {

                            ToolTip = 'Specifies the value of the Special Price From field';
                            ApplicationArea = NPRMagento;
                        }
                        field("Special Price From Enabled"; Rec."Special Price From Enabled")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Special Price From Enabled field';
                            ApplicationArea = NPRMagento;
                        }
                    }
                    grid(SpecialPriceToGrid)
                    {
                        field("Special Price To"; Rec."Special Price To")
                        {

                            ToolTip = 'Specifies the value of the Special Price To field';
                            ApplicationArea = NPRMagento;
                        }
                        field("Special Price To Enabled"; Rec."Special Price To Enabled")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Special Price To Enabled field';
                            ApplicationArea = NPRMagento;
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
                        ApplicationArea = NPRMagento;
                    }
                    field("Webshop Name Enabled"; Rec."Webshop Name Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Webshop Name Enabled field';
                        ApplicationArea = NPRMagento;
                    }
                }
                grid(WebshopDescriptionGrid)
                {
                    field("Webshop Description"; Format(Rec."Webshop Description".HasValue()))
                    {

                        Caption = 'Description';
                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRMagento;

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            TempBlob: Codeunit "Temp Blob";
                            OutStr: OutStream;
                            InStr: InStream;
                        begin
                            TempBlob.CreateOutStream(OutStr);
                            Rec.CalcFields(Rec."Webshop Description");
                            Rec."Webshop Description".CreateInStream(InStr);
                            CopyStream(OutStr, InStr);
                            if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                                if TempBlob.HasValue() then begin
                                    TempBlob.CreateInStream(InStr);
                                    Rec."Webshop Description".CreateOutStream(OutStr);
                                    CopyStream(OutStr, InStr);
                                end else
                                    Clear(Rec."Webshop Description");
                                Rec.Modify(true);
                            end;
                        end;
                    }

                    field("Webshop Description Enabled"; Rec."Webshop Description Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Webshop Description Enabled field';
                        ApplicationArea = NPRMagento;
                    }
                }

                grid(WebshopShortDescGrid)
                {
                    field("Webshop Short Description"; Format(Rec."Webshop Short Desc.".HasValue()))
                    {

                        Caption = 'Short Description';
                        ToolTip = 'Specifies the value of the Short Description field';
                        ApplicationArea = NPRMagento;

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            TempBlob: Codeunit "Temp Blob";
                            OutStr: OutStream;
                            InStr: InStream;
                        begin
                            TempBlob.CreateOutStream(OutStr);
                            Rec.CalcFields("Webshop Short Desc.");
                            Rec."Webshop Short Desc.".CreateInStream(InStr);
                            CopyStream(OutStr, InStr);
                            if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                                if TempBlob.HasValue() then begin
                                    TempBlob.CreateInStream(InStr);
                                    Rec."Webshop Short Desc.".CreateOutStream(OutStr);
                                    CopyStream(OutStr, InStr);
                                end else
                                    Clear(Rec."Webshop Short Desc.");
                                Rec.Modify(true);
                            end;
                        end;
                    }
                    field("Webshop Short Desc. Enabled"; Rec."Webshop Short Desc. Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Webshop Short Description Enabled field';
                        ApplicationArea = NPRMagento;
                    }
                }
                field(Visibility; Rec.Visibility)
                {

                    ToolTip = 'Specifies the value of the Visibility field';
                    ApplicationArea = NPRMagento;
                }
                grid(DisplayOnlyGrid)
                {
                    field("Display Only"; Rec."Display Only")
                    {

                        ToolTip = 'Specifies the value of the Display Only field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Display Only Enabled"; Rec."Display Only Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Display Only Enabled field';
                        ApplicationArea = NPRMagento;
                    }
                }
                grid(DisplayOnlyTextGrid)
                {
                    field("Display Only Text"; Rec."Display Only Text")
                    {

                        ToolTip = 'Specifies the value of the Display Only Text field';
                        ApplicationArea = NPRMagento;
                    }
                }
                grid(SeoLinkGrid)
                {
                    field("Seo Link"; Rec."Seo Link")
                    {

                        ToolTip = 'Specifies the value of the Seo Link field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Seo Link Enabled"; Rec."Seo Link Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Seo Link Enabled field';
                        ApplicationArea = NPRMagento;
                    }
                }
                grid(MetaTitleGrid)
                {
                    field("Meta Title"; Rec."Meta Title")
                    {

                        ToolTip = 'Specifies the value of the Meta Title field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Meta Title Enabled"; Rec."Meta Title Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Meta Title Enabled field';
                        ApplicationArea = NPRMagento;
                    }
                }
                grid(MetaDescriptionGrid)
                {
                    field("Meta Description"; Rec."Meta Description")
                    {

                        ToolTip = 'Specifies the value of the Meta Description field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Meta Description Enabled"; Rec."Meta Description Enabled")
                    {

                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Meta Description Enabled field';
                        ApplicationArea = NPRMagento;
                    }
                }
                grid(MetaKeywordsGrid)
                {
                    field("Meta Keywords"; Rec."Meta Keywords")
                    {
                        ToolTip = 'Specifies the value of the Meta Keywords field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Meta Keywords Enabled"; Rec."Meta Keywords Enabled")
                    {
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Meta Keywords Enabled field';
                        ApplicationArea = NPRMagento;
                    }
                }
            }
            group(MagentoCategoryLinks)
            {
                Caption = 'Category Links';
                part(MagentoItemGroupLinks; "NPR Magento Category Links")
                {
                    SubPageLink = "Item No." = FIELD("Item No.");
                    ApplicationArea = NPRMagento;

                }
            }
        }
    }
}
