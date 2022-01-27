page 6151195 "NPR NpCs Stores"
{
    Extensible = False;
    Caption = 'Collect Stores';
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Local Store"; Rec."Local Store")
                {

                    ToolTip = 'Specifies the value of the Local Store field';
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

                ToolTip = 'Executes the Show Address action';
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

                ToolTip = 'Executes the Show Geolocation action';
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

                ToolTip = 'Executes the Stores by Distance action';
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

                ToolTip = 'Executes the Store Stock Items action';
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

