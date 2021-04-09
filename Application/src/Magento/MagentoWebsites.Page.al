page 6151403 "NPR Magento Websites"
{
    Caption = 'Websites';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Website";
    UsageCategory = Administration;
    ApplicationArea = All;

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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field(Name; Rec.Name)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name field';
                    }
                    field("Default Website"; Rec."Default Website")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Std. Website field';
                    }
                    field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    }
                    field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    }
                    field("Location Code"; Rec."Location Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Location Code field';
                    }
                    field("Sales Order No. Series"; Rec."Sales Order No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Order No. Series field';
                    }
                }
                group(Control6150620)
                {
                    ShowCaption = false;
                    part(Stores; "NPR Magento Store Subform")
                    {
                        Caption = 'Stores';
                        SubPageLink = "Website Code" = FIELD(Code);
                        ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Websites action';

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