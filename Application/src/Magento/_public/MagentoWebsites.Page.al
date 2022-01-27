page 6151403 "NPR Magento Websites"
{
    Caption = 'Websites';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Website";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            grid(Control6150619)
            {
                ShowCaption = false;
                repeater(Control6150613)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {

                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Name; Rec.Name)
                    {

                        ToolTip = 'Specifies the value of the Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Default Website"; Rec."Default Website")
                    {

                        ToolTip = 'Specifies the value of the Std. Website field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                    {

                        ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                    {

                        ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Location Code"; Rec."Location Code")
                    {

                        ToolTip = 'Specifies the value of the Location Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales Order No. Series"; Rec."Sales Order No. Series")
                    {

                        ToolTip = 'Specifies the value of the Sales Order No. Series field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Customer No. Series"; Rec."Customer No. Series")
                    {

                        ToolTip = 'Specify a different number series to be used when creating customer during order import';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6150620)
                {
                    ShowCaption = false;
                    part(Stores; "NPR Magento Store Subform")
                    {
                        Caption = 'Stores';
                        SubPageLink = "Website Code" = FIELD(Code);
                        ApplicationArea = NPRRetail;

                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Magento Websites")
            {
                Caption = 'Setup Websites';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Setup Websites action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    MagentoSetupMgt.TriggerSetupMagentoWebsites();
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}
