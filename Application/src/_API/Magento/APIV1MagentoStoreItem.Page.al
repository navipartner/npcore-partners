page 6150790 "NPR APIV1 - Magento Store Item"
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoStoreItem';
    EntitySetName = 'magentoStoreItems';
    EntityCaption = 'Magento Store Item';
    EntitySetCaption = 'Magento Store Items';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Store Item";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(storeCode; Rec."Store Code")
                {
                    Caption = 'Store Code', Locked = true;
                }
                field(websiteCode; Rec."Website Code")
                {
                    Caption = 'Website Code', Locked = true;
                }
                field(webshopShortDescEnabled; Rec."Webshop Short Desc. Enabled")
                {
                    Caption = 'Webshop Short Description Enabled', Locked = true;
                }
                field(webshopShortDesc; Rec."Webshop Short Desc.")
                {
                    Caption = 'Webshop Short Description', Locked = true;
                }
                field(webshopNameEnabled; Rec."Webshop Name Enabled")
                {
                    Caption = 'Webshop Name Enabled', Locked = true;
                }
                field(webshopName; Rec."Webshop Name")
                {
                    Caption = 'Webshop name', Locked = true;
                }
                field(webshopDescription; Rec."Webshop Description")
                {
                    Caption = 'Webshop Description', Locked = true;
                }
                field(webshopDescriptionEnabled; Rec."Webshop Description Enabled")
                {
                    Caption = 'Webshop Description Enabled', Locked = true;
                }
                field(visibility; Rec.Visibility)
                {
                    Caption = 'Visibility', Locked = true;
                }
                field(displayOnly; Rec."Display Only")
                {
                    Caption = 'Display Only', Locked = true;
                }
                field(displayOnlyEnabled; Rec."Display Only Enabled")
                {
                    Caption = 'Display Only Enabled', Locked = true;
                }
                field(displayOnlyText; Rec."Display Only Text")
                {
                    Caption = 'Display Only Text', Locked = true;
                }
                field(enabled; Rec.Enabled)
                {
                    Caption = 'Enabled', Locked = true;
                }
                field(metaDescription; Rec."Meta Description")
                {
                    Caption = 'Meta Description', Locked = true;
                }
                field(metaDescriptionEnabled; Rec."Meta Description Enabled")
                {
                    Caption = 'Meta Description Enabled', Locked = true;
                }
                field(metaTitle; Rec."Meta Title")
                {
                    Caption = 'Meta Title', Locked = true;
                }
                field(metaTitleEnabled; Rec."Meta Title Enabled")
                {
                    Caption = 'Meta Title Enabled', Locked = true;
                }
                field(metaKeywords; Rec."Meta Keywords")
                {
                    Caption = 'Meta Keywords', Locked = true;
                }
                field(metaKeywordsEnabled; Rec."Meta Keywords Enabled")
                {
                    Caption = 'Meta Keywords Enabled', Locked = true;
                }
                field(productNewFrom; Rec."Product New From")
                {
                    Caption = 'Product New From', Locked = true;
                }
                field(productNewFromEnabled; Rec."Product New From Enabled")
                {
                    Caption = 'Product New From Enabled', Locked = true;
                }
                field(productNewTo; Rec."Product New To")
                {
                    Caption = 'Product New To', Locked = true;
                }
                field(productNewToEnabled; Rec."Product New To Enabled")
                {
                    Caption = 'Product New To Enabled', Locked = true;
                }
                field(rootItemGroupNo; Rec."Root Item Group No.")
                {
                    Caption = 'Root Item Group No.', Locked = true;
                }
                field(seoLink; Rec."Seo Link")
                {
                    Caption = 'Seo Link', Locked = true;
                }
                field(seoLinkEnabled; Rec."Seo Link Enabled")
                {
                    Caption = 'Seo Link Enabled', Locked = true;
                }
                field(specialPrice; Rec."Special Price")
                {
                    Caption = 'Special Price', Locked = true;
                }
                field(specialPriceEnabled; Rec."Special Price Enabled")
                {
                    Caption = 'Special Price Enabled', Locked = true;
                }
                field(specialPriceFrom; Rec."Special Price From")
                {
                    Caption = 'Special Price From', Locked = true;
                }
                field(specialPriceFromEnabled; Rec."Special Price From Enabled")
                {
                    Caption = 'Special Price From Enabled', Locked = true;
                }
                field(specialPriceTo; Rec."Special Price To")
                {
                    Caption = 'Special Price To', Locked = true;
                }
                field(specialPriceToEnabled; Rec."Special Price To Enabled")
                {
                    Caption = 'Special Price To Enabled', Locked = true;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price', Locked = true;
                }
                field(unitPriceEnabled; Rec."Unit Price Enabled")
                {
                    Caption = 'Unit Price Enabled', Locked = true;
                }
                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR23.0';
                    ObsoleteReason = 'Replaced by SystemRowVersion';
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'systemRowVersion', Locked = true;
                }
#ENDIF
            }
        }
    }

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
    end;
}
