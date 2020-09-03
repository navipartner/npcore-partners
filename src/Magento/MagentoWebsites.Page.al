page 6151403 "NPR Magento Websites"
{
    // MAG1.01/MH/20150201  CASE 199932 Refactored Object from Web Integration
    // MAG1.17/MH/20150622  CASE 216851 Magento Setup functions moved to new codeunit
    // MAG1.21/TS/20151016 CASE 225180  Added Website Code Filter to Page Part
    // MAG1.22/TS/20150107  CASE 228446 Added Global Dimension 1 Code and Global Dimension 2 Code
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.01/TS/20161014 CASE 254886 Added Location Code
    // MAG2.07/MHA /20170830  CASE 286943 Updated Magento Setup Actions to support Setup Event Subscription
    // MAG2.26/MHA /20200505  CASE 402828 Added field 40 "Sales Order No. Series"

    Caption = 'Websites';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento Website";
    UsageCategory = Administration;

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
                    field("Code"; Code)
                    {
                        ApplicationArea = All;
                    }
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                    }
                    field("Default Website"; "Default Website")
                    {
                        ApplicationArea = All;
                    }
                    field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                    {
                        ApplicationArea = All;
                        Visible = false;
                    }
                    field("Location Code"; "Location Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Sales Order No. Series"; "Sales Order No. Series")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6150620)
                {
                    ShowCaption = false;
                    part(Stores; "NPR Magento Store Subform")
                    {
                        Caption = 'Stores';
                        SubPageLink = "Website Code" = FIELD(Code);
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //-MAG2.07 [286943]
                    //MagentoSetupMgt.SetupMagentoWebsites();
                    MagentoSetupMgt.TriggerSetupMagentoWebsites();
                    //+MAG2.07 [286943]
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}

