page 6151248 "NPR Setup Act - POS"
{
    Extensible = False;
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

                    ToolTip = 'Specifies the number of the User Setups. By clicking you can view the list of User Setups.';
                    ApplicationArea = NPRRetail;
                }
                field(Salespersons; SalesPersonCountAsDec)
                {
                    Caption = 'Salespersons';
                    ToolTip = 'Specifies the number of the Salespersons. By clicking you can view the list of Salespersons.';
                    ApplicationArea = NPRRetail;
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    var
                        SalespersonsPurchasers: Page "Salespersons/Purchasers";
                    begin
                        SalespersonsPurchasers.Run()
                    end;
                }
            }
            cuegroup(stores)
            {
                Caption = 'Stores';
                field("POS Stores"; Rec."POS Stores")
                {

                    ToolTip = 'Specifies the number of the POS Stores. By clicking you can view the list of POS Stores.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Units"; Rec."POS Units")
                {

                    ToolTip = 'Specifies the number of the POS Units. By clicking you can view the list of POS Units.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Posting Setups"; Rec."POS Posting Setups")
                {

                    ToolTip = 'View or edit the POS Posting Setup';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(payments)
            {
                Caption = 'Payments';
                field("POS Payment Methods"; Rec."POS Payment Methods")
                {

                    ToolTip = 'Specifies the number of the POS Payment Methods. By clicking you can view the list of POS Payment Methods.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bins"; Rec."POS Payment Bins")
                {

                    ToolTip = 'Specifies the number of the POS Payment Bins. By clicking you can view the list of POS Payment Bins.';
                    ApplicationArea = NPRRetail;
                }
                field("EFT Setups"; Rec."EFT Setups")
                {

                    ToolTip = 'Specifies the number of the EFT Setups.';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup(Downloads)
            {
                Caption = 'Downloads';
                actions
                {
                    action("Download Minor Tom")
                    {
                        Caption = 'Download Minor Tom';
                        ToolTip = 'Download Minor Tom';
                        Image = TileCloud;
                        ApplicationArea = NPRRetail;

                        trigger OnAction()
                        begin
                            System.Hyperlink('https://npminortom.blob.core.windows.net/prod/Setup.exe');
                        end;
                    }
                    action("Download HW Connector")
                    {
                        Caption = 'Download HW Connector';
                        ToolTip = 'Download the setup wizard for the Hardware Connector Setup.';
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
                        ToolTip = 'Download and import the template which contains data to base and NPR tables.';
                        Image = TileCloud;
                        RunObject = page "NPR RapidStart Base Data Imp.";
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(Salespersons);
        SalesPersonCountAsDec := Rec.Salespersons;
    end;

    var
        SalesPersonCountAsDec: Decimal;
}

