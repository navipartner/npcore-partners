page 6151407 "NPR Magento Tax Classes"
{
    Caption = 'Tax Classes';
    PageType = List;
    SourceTable = "NPR Magento Tax Class";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Type" = Rec."Type"::Customer;
                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Tax Classes action';

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