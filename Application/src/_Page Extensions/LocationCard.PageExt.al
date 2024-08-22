pageextension 6014460 "NPR Location Card" extends "Location Card"
{
    layout
    {
        addafter("Use As In-Transit")
        {
            field("NPR Retail Location"; Rec."NPR Retail Location")
            {
                ToolTip = 'Specifies whether location is Retail or Warehouse. This field is affecting logic for POS Compilance.';
                ApplicationArea = NPRRetail;
                Visible = RetailLocalizationEnabled;
            }
            field("NPR Store Group Code"; Rec."NPR Store Group Code")
            {
                ToolTip = 'Specifies a Group Code that a set of POS Stores can be grouped into for BI purposes.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Directed Put-away and Pick")
        {
            field("NPR No Whse. Entr. for POS"; Rec."NPR No Whse. Entr. for POS")
            {
                ToolTip = 'Specifies whether you want to disable creating warehouse entries during POS entry item posting.';
                ApplicationArea = NPRRetail;
                Importance = Additional;
                Enabled = NoWhseEntrForPOSEnabled;
            }
        }
#if not BC17
        addlast(content)
        {
#endif
#if not (BC17 or BC18 or BC19 or BC20)
            group("NPR Magento")
            {
                Caption = 'Magento';

                field("NPR Magento 2 Source"; Rec."NPR Magento 2 Source")
                {
                    ToolTip = 'Specifies the Magento 2 Source that this Location maps to';
                    ApplicationArea = NPRRetail;
                }
            }
#endif
#if not BC17
            group("NPR Shopify")
            {
                Caption = 'Shopify';
                Visible = ShopifyIntegrationIsEnabled;

                field("NPR Spfy Location ID"; SpfyStoreLinkMgt.GetFirstAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Location ID';
                    Editable = false;
                    AssistEdit = true;
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the Shopify ID assigned to the location.';

                    trigger OnAssistEdit()
                    begin
                        Rec.TestField("Code");
                        Rec.TestField("Use As In-Transit", false);
                        CurrPage.SaveRecord();
                        Commit();

                        SpfyStoreLinkMgt.OpenStoreLinks(Rec.RecordId());
                        CurrPage.Update(false);
                    end;
                }
            }
        }
#endif

        modify("Bin Mandatory")
        {
            trigger OnAfterValidate()
            begin
                NPRUpdateEnabled();
            end;
        }
        modify("Directed Put-away and Pick")
        {
            trigger OnAfterValidate()
            begin
                NPRUpdateEnabled();
            end;
        }
    }
    trigger OnOpenPage()
    var
        RetailLocalizationMgt: Codeunit "NPR Retail Localization Mgt.";
#if not BC17
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
#endif
    begin
        RetailLocalizationEnabled := RetailLocalizationMgt.IsRetailLocalizationEnabled();
#if not BC17
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels");
        SpfyIntegrationEvents.LocationCardOnCheckIfShopifyIntegrationIsEnabled(Rec, ShopifyIntegrationIsEnabled);
#endif
    end;

    trigger OnAfterGetRecord()
    begin
        NPRUpdateEnabled();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        NoWhseEntrForPOSEnabled := false;
    end;

    local procedure NPRUpdateEnabled()
    begin
        NoWhseEntrForPOSEnabled := Rec."Bin Mandatory" or Rec."Directed Put-away and Pick";
    end;

    var
#if not BC17
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
#endif
        NoWhseEntrForPOSEnabled: Boolean;
        RetailLocalizationEnabled: Boolean;
#if not BC17
        ShopifyIntegrationIsEnabled: Boolean;
#endif
}