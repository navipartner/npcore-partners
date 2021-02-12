page 6151195 "NPR NpCs Stores"
{
    Caption = 'Collect Stores';
    CardPageID = "NPR NpCs Store Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpCs Store";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Local Store"; "Local Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Local Store field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Address action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Geolocation action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Stores by Distance action';

                trigger OnAction()
                var
                    NpCsStoresbyDistance: Page "NPR NpCs Stores by Distance";
                begin
                    Clear(NpCsStoresbyDistance);
                    NpCsStoresbyDistance.SetFromStoreCode(Code);
                    NpCsStoresbyDistance.Run;
                end;
            }
            action("Store Stock Items")
            {
                Caption = 'Store Stock Items';
                Image = List;
                RunObject = Page "NPR NpCs Store Stock Items";
                RunPageLink = "Store Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Store Stock Items action';
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

