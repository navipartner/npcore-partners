page 6151247 "NPR Retail - Setups"
{
    Caption = 'NP Retail - Setups';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR NP Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {

            cuegroup("Product Videos")
            {
                Caption = 'Product Videos';
                Visible = ShowProductVideosActivities;

                actions
                {
                    action(ProductVideos)
                    {

                        Caption = 'Product Videos';
                        Image = TileVideo;
                        RunObject = Page "Product Videos";
                        ToolTip = 'Open a list of videos that showcase some of the product capabilities.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            cuegroup("Get Started")
            {
                actions
                {
                    action(GetStartedVideo)
                    {

                        Caption = 'Replay Getting Started';
                        Image = TileVideo;
                        Tooltip = 'Show the Getting Started guide again';
                        ApplicationArea = NPRRetail;

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
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        ShowProductVideosActivities := ClientTypeManagement.GetCurrentClientType() <> CLIENTTYPE::Phone;
    end;

    var
        ClientTypeManagement: Codeunit "Client Type Management";
        ShowProductVideosActivities: Boolean;

}

