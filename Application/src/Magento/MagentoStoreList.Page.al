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
                field("Website Code"; "Website Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Website Code field';
                }
                field("Language Code"; "Language Code")
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
        MultiStore := Count > 1;
    end;

    var
        MultiStore: Boolean;
}

