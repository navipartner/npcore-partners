page 6151248 "NPR Setup Act - POS"
{
    Caption = 'NP Retail Setup - POS';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup("Users&Salespersons")
            {
                Caption = 'Salespersons';
                field("User Setups"; Rec."User Setups")
                {

                    ToolTip = 'Specifies the value of the User Setups field';
                    ApplicationArea = NPRRetail;
                }
                field(Salespersons; Rec.Salespersons)
                {

                    DrillDownPageID = "Salespersons/Purchasers";
                    ToolTip = 'Specifies the value of the Salespersons field';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(stores)
            {
                Caption = 'Stores';
                field("POS Stores"; Rec."POS Stores")
                {

                    ToolTip = 'Specifies the value of the POS Stores field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Units"; Rec."POS Units")
                {

                    ToolTip = 'Specifies the value of the POS Units field';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(payments)
            {
                Caption = 'Payments';
                field("POS Payment Methods"; Rec."POS Payment Methods")
                {

                    ToolTip = 'Specifies the value of the POS Payment Methods field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bins"; Rec."POS Payment Bins")
                {

                    ToolTip = 'Specifies the value of the POS Payment Bins field';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(Downloads)
            {
                Caption = 'Downloads';
                actions
                {
                    action("Download Major Tom")
                    {
                        Caption = 'Download Major Tom';

                        ToolTip = 'Specifies download URL for Major Tom Setup';
                        Image = TileCloud;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            System.Hyperlink('https://clickonce.dynamics-retail.com/ClickOnce/Majortom/6.3/install.html');
                        end;
                    }
                    action("Download HW Connector")
                    {
                        Caption = 'Download HW Connector';

                        ToolTip = 'Specifies download URL for Hardware Connector Setup';
                        Image = TileCloud;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            System.Hyperlink('https://nphardwareconnector.blob.core.windows.net/production/Setup.exe');
                        end;
                    }
                    action("Download Template Data")
                    {
                        Caption = 'Download Template Data';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies download URL for Template Data Setup';
                        Image = TileCloud;

                        RunObject = page "NPR RapidStart Base Data Imp.";
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
    end;
}

