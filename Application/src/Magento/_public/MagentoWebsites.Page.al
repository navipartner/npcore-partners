page 6151403 "NPR Magento Websites"
{
    Caption = 'Magento Websites';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Website";
    UsageCategory = Administration;
    ApplicationArea = NPRMagento;

    layout
    {
        area(content)
        {
            group("Websites List")
            {
                Caption = 'Websites';
                ShowCaption = true;
                repeater(Control6150613)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {

                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRMagento;
                    }
                    field(Name; Rec.Name)
                    {

                        ToolTip = 'Specifies the value of the Name field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Default Website"; Rec."Default Website")
                    {

                        ToolTip = 'Specifies the value of the Std. Website field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                    {

                        ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                    {

                        ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Location Code"; Rec."Location Code")
                    {

                        ToolTip = 'Specifies the value of the Location Code field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Responsibility Center"; Rec."Responsibility Center")
                    {

                        ToolTip = 'Specifies the code of the responsibility center, such as a distribution hub, that is associated with the involved user, company, customer, or vendor. When webshop order is created and imported to Business Central, if Code of this Website is named, then value from this field will be passed to the Sales Header.';
                        ApplicationArea = NPRMagento;
                    }
                    field("Sales Order No. Series"; Rec."Sales Order No. Series")
                    {

                        ToolTip = 'Specifies the value of the Sales Order No. Series field';
                        ApplicationArea = NPRMagento;
                    }
                    field("Customer No. Series"; Rec."Customer No. Series")
                    {

                        ToolTip = 'Specify a different number series to be used when creating customer during order import';
                        ApplicationArea = NPRMagento;
                    }
                }
            }
            group(Control6150620)
            {
                ShowCaption = false;
                part(Stores; "NPR Magento Store Subform")
                {
                    Caption = 'Stores';
                    SubPageLink = "Website Code" = FIELD(Code);
                    ApplicationArea = NPRMagento;

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
                ApplicationArea = NPRMagento;

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
