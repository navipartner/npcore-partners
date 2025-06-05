page 6151438 "NPR Magento Store List"
{
    Extensible = False;
    Caption = 'Magento Store List';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Manage';
    SourceTable = "NPR Magento Store";
    UsageCategory = Lists;
    ApplicationArea = NPRMagento;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMagento;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRMagento;
                }
                field("Website Code"; Rec."Website Code")
                {

                    ToolTip = 'Specifies the value of the Website Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Language Code"; Rec."Language Code")
                {

                    ToolTip = 'Specifies the value of the Language Code field';
                    ApplicationArea = NPRMagento;
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
                ApplicationArea = NPRMagento;
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
