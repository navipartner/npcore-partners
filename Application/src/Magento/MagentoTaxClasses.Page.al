page 6151407 "NPR Magento Tax Classes"
{
    Extensible = False;
    Caption = 'Tax Classes';
    PageType = List;
    SourceTable = "NPR Magento Tax Class";
    UsageCategory = Administration;
    ApplicationArea = NPRMagento;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRMagento;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRMagento;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {

                    Enabled = Rec."Type" = Rec."Type"::Customer;
                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Magento Tax Classes")
            {
                Caption = 'Setup Tax Classes';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Setup Tax Classes action';
                ApplicationArea = NPRMagento;

                trigger OnAction()
                begin
                    MagentoSetupMgt.TriggerSetupMagentoTaxClasses();
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}
