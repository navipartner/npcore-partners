page 6151247 "NPR Setup Act - Scenarios"
{
    Caption = 'NP Retail - POS Scenarios Setups';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR NP Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup("POS Scenarios")
            {
                Caption = 'Pos Scenarios';
                field("NPR POS Scenarios"; Rec."NPR POS Sales Workflow")
                {
                    ApplicationArea = All;
                    Caption = 'POS Scenarios';
                    ShowCaption = true;
                    ToolTip = 'Specifies the value of the POS Sales Scenarios field';
                }

                field("POS Input BOX Setup"; Rec."EAN SETUP")
                {
                    ApplicationArea = All;
                    Caption = 'POS Input BOX SETUP';
                    ShowCaption = true;
                    ToolTip = 'Specifies the value of the POS Input BOX SETUP field';
                }

            }
            cuegroup("Product Videos")
            {
                Caption = 'Product Videos';
                Visible = ShowProductVideosActivities;

                actions
                {
                    action(ProductVideos)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Product Videos';
                        Image = TileVideo;
                        RunObject = Page "Product Videos";
                        ToolTip = 'Open a list of videos that showcase some of the product capabilities.';
                    }
                }
            }
            cuegroup("Get Started")
            {
                actions
                {
                    action(GetStartedVideo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Replay Getting Started';
                        Image = TileVideo;
                        Tooltip = 'Show the Getting Started guide again';

                        trigger OnAction()
                        begin  
                            PAGE.RunModal(PAGE::"NPR Getting Started");
                        end;
                    }
                }
            }

        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;

        ShowProductVideosActivities := ClientTypeManagement.GetCurrentClientType() <> CLIENTTYPE::Phone;
    end;

    var 
    ClientTypeManagement: Codeunit "Client Type Management";
    ShowProductVideosActivities: Boolean;
}

