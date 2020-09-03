page 6151438 "NPR Magento Store List"
{
    // MAG1.21/MHA/20151118  CASE 227354 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.07/TS  /20170830  CASE 262530  Added Field 1024 Language Code

    Caption = 'Webshops';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Manage';
    SourceTable = "NPR Magento Store";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Website Code"; "Website Code")
                {
                    ApplicationArea = All;
                }
                field("Language Code"; "Language Code")
                {
                    ApplicationArea = All;
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
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "NPR Magento Store Item List";
                RunPageLink = "Store Code" = FIELD(Code);
                Visible = MultiStore;
            }
        }
    }

    trigger OnInit()
    begin
        MultiStore := Count > 1;
    end;

    var
        MultiStore: Boolean;
}

