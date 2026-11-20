page 6151202 "NPR NpCs Store Card Workflows"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    Caption = 'Store Workflow Relations';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR NpCs Store Workflow Rel.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code"; Rec."Store Code")
                {

                    Visible = StoreCodeVisible;
                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Code"; Rec."Workflow Code")
                {

                    Visible = (NOT StoreCodeVisible);
                    ToolTip = 'Specifies the value of the Workflow Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Description"; Rec."Workflow Description")
                {

                    Visible = (NOT StoreCodeVisible);
                    ToolTip = 'Specifies the value of the Workflow Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Notification from Store"; Rec."Send Notification from Store")
                {

                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                    ApplicationArea = NPRRetail;
                }
                field("Notify Store via E-mail"; Rec."Notify Store via E-mail")
                {

                    ToolTip = 'Specifies the value of the Notify Store via E-mail field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Store E-mail Temp. (Pending)"; Rec."Store E-mail Temp. (Pending)")
                {
                    Visible = not _NPEmailFeatureEnabled;
                    Editable = not _NPEmailFeatureEnabled;

                    ToolTip = 'Specifies the value of the Store E-mail Template (Pending) field';
                    ApplicationArea = NPRRetail;
                }
                field("Store NP Email Templ (Pending)"; Rec."Store NP Email Templ (Pending)")
                {
                    ApplicationArea = NPRRetail;
                    Visible = _NPEmailFeatureEnabled;
                    Editable = _NPEmailFeatureEnabled;
                    ToolTip = 'Specifies the NP E-mail Template used to notify the store for the Pending state.';
                }
                field("Store E-mail Temp. (Expired)"; Rec."Store E-mail Temp. (Expired)")
                {
                    Visible = not _NPEmailFeatureEnabled;
                    Editable = not _NPEmailFeatureEnabled;

                    ToolTip = 'Specifies the value of the Store E-mail Template (Expired) field';
                    ApplicationArea = NPRRetail;
                }
                field("Store NP Email Templ (Expired)"; Rec."Store NP Email Templ (Expired)")
                {
                    ApplicationArea = NPRRetail;
                    Visible = _NPEmailFeatureEnabled;
                    Editable = _NPEmailFeatureEnabled;
                    ToolTip = 'Specifies the NP E-mail Template used to notify the store for the Expired state.';
                }
                field("Notify Store via Sms"; Rec."Notify Store via Sms")
                {

                    ToolTip = 'Specifies the value of the Notify Store via Sms field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Sms Template (Pending)"; Rec."Store Sms Template (Pending)")
                {

                    ToolTip = 'Specifies the value of the Store Sms Template (Pending) field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Sms Template (Expired)"; Rec."Store Sms Template (Expired)")
                {

                    ToolTip = 'Specifies the value of the Store Sms Template (Expired) field';
                    ApplicationArea = NPRRetail;
                }
                field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                {

                    ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Enable NP Email"; Rec."Enable NP Email")
                {
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    ToolTip = 'Specifies the existing customer NP Email opt-in. New configurations use NP Email for Click & Collect in NaviPartner Feature Management.';
                }
                field("E-mail Template (Pending)"; Rec."E-mail Template (Pending)")
                {
                    ApplicationArea = NPRRetail;
                    Visible = not _NPEmailFeatureEnabled;
                    Editable = not (_CustomerNPEmailAvailable and (Rec."Enable NP Email" or _NPEmailFeatureEnabled));
                    ToolTip = 'Specifies the value of the E-mail Template (Pending) field';
                }
                field("E-mail Template (Confirmed)"; Rec."E-mail Template (Confirmed)")
                {
                    ApplicationArea = NPRRetail;
                    Visible = not _NPEmailFeatureEnabled;
                    Editable = not (_CustomerNPEmailAvailable and (Rec."Enable NP Email" or _NPEmailFeatureEnabled));
                    ToolTip = 'Specifies the value of the E-mail Template (Confirmed) field';
                }
                field("E-mail Template (Rejected)"; Rec."E-mail Template (Rejected)")
                {
                    ApplicationArea = NPRRetail;
                    Visible = not _NPEmailFeatureEnabled;
                    Editable = not (_CustomerNPEmailAvailable and (Rec."Enable NP Email" or _NPEmailFeatureEnabled));
                    ToolTip = 'Specifies the value of the E-mail Template (Rejected) field';
                }
                field("E-mail Template (Expired)"; Rec."E-mail Template (Expired)")
                {
                    ApplicationArea = NPRRetail;
                    Visible = not _NPEmailFeatureEnabled;
                    Editable = not (_CustomerNPEmailAvailable and (Rec."Enable NP Email" or _NPEmailFeatureEnabled));
                    ToolTip = 'Specifies the value of the E-mail Template (Expired) field';
                }
                field("NP E-mail Template (Pending)"; Rec."NP E-mail Template (Pending)")
                {
                    ApplicationArea = NPRRetail;
                    Visible = _CustomerNPEmailAvailable;
                    Editable = _CustomerNPEmailAvailable and (Rec."Enable NP Email" or _NPEmailFeatureEnabled);
                    ToolTip = 'Specifies the NP E-mail Template used for the Pending state.';
                }
                field("NP E-mail Template (Confirmed)"; Rec."NP E-mail Template (Confirmed)")
                {
                    ApplicationArea = NPRRetail;
                    Visible = _CustomerNPEmailAvailable;
                    Editable = _CustomerNPEmailAvailable and (Rec."Enable NP Email" or _NPEmailFeatureEnabled);
                    ToolTip = 'Specifies the NP E-mail Template used for the Confirmed state.';
                }
                field("NP E-mail Template (Rejected)"; Rec."NP E-mail Template (Rejected)")
                {
                    ApplicationArea = NPRRetail;
                    Visible = _CustomerNPEmailAvailable;
                    Editable = _CustomerNPEmailAvailable and (Rec."Enable NP Email" or _NPEmailFeatureEnabled);
                    ToolTip = 'Specifies the NP E-mail Template used for the Rejected state.';
                }
                field("NP E-mail Template (Expired)"; Rec."NP E-mail Template (Expired)")
                {
                    ApplicationArea = NPRRetail;
                    Visible = _CustomerNPEmailAvailable;
                    Editable = _CustomerNPEmailAvailable and (Rec."Enable NP Email" or _NPEmailFeatureEnabled);
                    ToolTip = 'Specifies the NP E-mail Template used for the Expired state.';
                }
                field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                {

                    ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                    ApplicationArea = NPRRetail;
                }
                field("Sms Template (Pending)"; Rec."Sms Template (Pending)")
                {

                    ToolTip = 'Specifies the value of the Sms Template (Pending) field';
                    ApplicationArea = NPRRetail;
                }
                field("Sms Template (Confirmed)"; Rec."Sms Template (Confirmed)")
                {

                    ToolTip = 'Specifies the value of the Sms Template (Confirmed) field';
                    ApplicationArea = NPRRetail;
                }
                field("Sms Template (Rejected)"; Rec."Sms Template (Rejected)")
                {

                    ToolTip = 'Specifies the value of the Sms Template (Rejected) field';
                    ApplicationArea = NPRRetail;
                }
                field("Sms Template (Expired)"; Rec."Sms Template (Expired)")
                {

                    ToolTip = 'Specifies the value of the Sms Template (Expired) field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Print Template"; Rec."Processing Print Template")
                {

                    ToolTip = 'Specifies the value of the Processing Print Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Print Template (POS)"; Rec."Delivery Print Template (POS)")
                {

                    ToolTip = 'Specifies the value of the Delivery Print Template (POS) field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Print Template (S.)"; Rec."Delivery Print Template (S.)")
                {

                    ToolTip = 'Specifies the value of the Delivery Template (Sales Document) field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Columns are shared by all rows; allow mixed customer routing and control editing per row.
        _CustomerNPEmailAvailable := _NPEmailFeature.IsFeatureEnabled() and _NewEmailExpFeature.IsFeatureEnabled();
        _NPEmailFeatureEnabled := _NPEmailFeature.IsFeatureEnabled() and _ClickCollectNPEmailFeature.IsFeatureEnabled() and _NewEmailExpFeature.IsFeatureEnabled();
    end;

    var
        StoreCodeVisible: Boolean;
        _NPEmailFeatureEnabled: Boolean;
        _CustomerNPEmailAvailable: Boolean;
        _NPEmailFeature: Codeunit "NPR NP Email Feature";
        _NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        _ClickCollectNPEmailFeature: Codeunit "NPR CnC NP Email Feature";

    internal procedure SetStoreCodeVisible(NewStoreCodeVisible: Boolean)
    begin
        StoreCodeVisible := NewStoreCodeVisible;
    end;
}

