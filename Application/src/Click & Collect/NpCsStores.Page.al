page 6151195 "NPR NpCs Stores"
{
    Extensible = False;
    Caption = 'Collect Stores';
    ContextSensitiveHelpPage = 'docs/retail/click_and_collect/intro/';
    CardPageID = "NPR NpCs Store Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpCs Store";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the Code for the Collect Store.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the Collect Store''s Name.';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the Company Name associated with the Collect Store.';
                    ApplicationArea = NPRRetail;
                }
                field("Local Store"; Rec."Local Store")
                {

                    ToolTip = 'Specifies that the Collect Store belongs to the current company.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Address")
            {
                Caption = 'Show Address';
                Image = Map;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Displays the address of the Collect Store.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
                begin
                    NpCsStoreMgt.ShowAddress(Rec);
                end;
            }
            action("Show Geolocation")
            {
                Caption = 'Show Geolocation';
                Image = Map;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Displays the geolocation of the Collect Store';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
                begin
                    NpCsStoreMgt.ShowGeolocation(Rec);
                end;
            }
        }
        area(navigation)
        {
            action("Stores by Distance")
            {
                Caption = 'Stores by Distance';
                Image = List;

                ToolTip = 'Displays the nearby stores based on distance from the current Collect Store';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpCsStoresbyDistance: Page "NPR NpCs Stores by Distance";
                begin
                    Clear(NpCsStoresbyDistance);
                    NpCsStoresbyDistance.SetFromStoreCode(Rec.Code);
                    NpCsStoresbyDistance.Run();
                end;
            }
            action("Store Stock Items")
            {
                Caption = 'Store Stock Items';
                Image = List;
                RunObject = Page "NPR NpCs Store Stock Items";
                RunPageLink = "Store Code" = FIELD(Code);

                ToolTip = 'Displays the stock items available in the Collect Store';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnOpenPage()
    var
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
    begin
        NpCsCollectMgt.InitCollectInStoreService();
    end;
}