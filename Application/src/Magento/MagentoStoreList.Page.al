page 6151438 "NPR Magento Store List"
{
    Caption = 'Webshops';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Manage';
    SourceTable = "NPR Magento Store";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Website Code"; Rec."Website Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Website Code field';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language Code field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Items)
            {
                Caption = 'Items';
                Image = ViewPage;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "NPR Magento Store Item List";
                RunPageLink = "Store Code" = FIELD(Code);
                Visible = MultiStore;
                ApplicationArea = All;
                ToolTip = 'Executes the Items action';
            }
        }
    }

    trigger OnInit()
    begin
        MultiStore := Rec.Count() > 1;
    end;

    var
        MultiStore: Boolean;
}