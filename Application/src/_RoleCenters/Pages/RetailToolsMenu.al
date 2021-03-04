page 6014405 "NPR Retail Tools Menu"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Retail Tools Menu';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {

            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Upgrade)
            {
                Caption = 'Upgrade';
                Image = MoveUp;
                action(UpgradeBalV3Setup)
                {
                    Caption = 'Upgrade Audit Roll to POS Entry';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Upgrade Audit Roll to POS Entry action';
                    Image = Action;

                    trigger OnAction()
                    var
                        RetailDataModelARUpgrade: Codeunit "NPR RetailDataModel AR Upgr.";
                    begin
                        RetailDataModelARUpgrade.UpgradeSetupsBalancingV3;
                    end;
                }
            }
        }
    }
}