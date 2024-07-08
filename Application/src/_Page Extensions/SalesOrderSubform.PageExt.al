pageextension 6014447 "NPR Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
                NPRVarietySetup: Record "NPR Variety Setup";
                VRTWrapper: Codeunit "NPR Variety Wrapper";
            begin
                if not NPRVarietySetup.Get() then
                    exit;
                if not NPRVarietySetup."Pop up Variety Matrix" then
                    exit;
                if not NPRVarietySetup."Pop up on Sales Order" then
                    exit;
                if (Rec.Type = Rec.Type::Item) and Item.Get(Rec."No.") then begin
                    Item.CalcFields("NPR Has Variants");
                    if Item."NPR Has Variants" then
                        VRTWrapper.SalesLineShowVariety(Rec, 0);
                end;
            end;
        }
        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {

                Visible = false;
                ToolTip = 'Specifies an extended description of the product entry to be sold. To add a non-transactional text line, fill in the Description field only.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Unit Cost (LCY)")
        {
            field("NPR Units per Parcel"; Rec."Units per Parcel")
            {

                Visible = false;
                ToolTip = 'Specifies how many units are packed in one parcel.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Inv. Discount Amount")
        {
            field("NPR Net Weight"; Rec."Net Weight")
            {

                Importance = Additional;
                ToolTip = 'Specifies the Net Weight of the item to be sold.';
                ApplicationArea = NPRRetail;
            }
        }
#if not BC17
        addlast(Control1)
        {
            field("NPR Spfy Order Line ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
            {
                Caption = 'Shopify Order Line ID';
                Editable = false;
                Visible = ShopifyIntegrationIsEnabled;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify Order Line ID assigned to the document line.';
            }
        }
#endif
    }
    actions
    {
        addafter(DocAttach)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';

                ToolTip = 'View the variety matrix for the item used on the Purchase Order Line.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    VarietyWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VarietyWrapper.SalesLineShowVariety(Rec, 0);
                    ForceTotalsCalculation();
                end;
            }
        }
    }

#if not BC17
    trigger OnOpenPage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders");
    end;
#endif

#if BC17 or BC18
    trigger OnAfterGetCurrRecord()
    begin
        if TotalsCalculationForced then begin
            UnbindSubscription(VarietyTotals);
            TotalsCalculationForced := false;
        end;
    end;

    local procedure ForceTotalsCalculation()
    begin
        TotalsCalculationForced := BindSubscription(VarietyTotals);
    end;
#endif

    var
#if BC17 or BC18
        VarietyTotals: Codeunit "NPR Variety Totals Calculation";
        TotalsCalculationForced: Boolean;
#endif
#if not BC17
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyIntegrationIsEnabled: Boolean;
#endif
}