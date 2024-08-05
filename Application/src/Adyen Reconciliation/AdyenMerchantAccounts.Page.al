page 6184552 "NPR Adyen Merchant Accounts"
{
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Caption = 'NP Pay Merchant Accounts';
    RefreshOnActivate = true;
    PageType = List;
    SourceTable = "NPR Adyen Merchant Account";
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Company ID"; Rec."Company ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Company ID.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the NP Pay Merchant Account Name.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Update List")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Update List';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Refresh;
                ToolTip = 'Running this action will refresh Merchant Account List.';

                trigger OnAction()
                begin
                    if _AdyenManagement.UpdateMerchantList(0) then
                        CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if _AdyenManagement.UpdateMerchantList(0) then
            CurrPage.Update(false);
    end;

    var
        _AdyenManagement: Codeunit "NPR Adyen Management";
}
