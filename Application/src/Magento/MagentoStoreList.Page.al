page 6151438 "NPR Magento Store List"
{
    Extensible = False;
    Caption = 'Webshops';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Manage';
    SourceTable = "NPR Magento Store";
    UsageCategory = Lists;
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
                field("Website Code"; Rec."Website Code")
                {

                    ToolTip = 'Specifies the value of the Website Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Language Code"; Rec."Language Code")
                {

                    ToolTip = 'Specifies the value of the Language Code field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Items action';
                ApplicationArea = NPRRetail;
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
