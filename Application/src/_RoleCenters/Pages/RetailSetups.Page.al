page 6151247 "NPR Retail - Setups"
{
    Extensible = False;
    Caption = 'Videos';
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
                        ToolTip = 'Open a list of videos that showcase some of the product capabilities.';
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        var
                            Video: Codeunit Video;
                        begin
                            Video.Show("Video Category"::NPR);
                        end;
                    }
                }
            }
            cuegroup("Get Started")
            {
                Caption = 'Get Started';
                ShowCaption = true;

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
#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
            usercontrol(Logo; "NPR Welcome Logo")
            {
                ApplicationArea = NPRRetail;
                trigger InsertLogoEvent()
                begin
                end;
            }
#endif
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

