page 6151426 "NPR Magento Custom Option List"
{
    Caption = 'Custom Options';
    CardPageID = "NPR Magento Custom Option Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Magento Custom Option";
    UsageCategory = Lists;
    ApplicationArea = NPRMagento;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRMagento;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMagento;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRMagento;
                }
                field(Required; Rec.Required)
                {

                    ToolTip = 'Specifies the value of the Required field';
                    ApplicationArea = NPRMagento;
                }
                field("Max Length"; Rec."Max Length")
                {

                    ToolTip = 'Specifies the value of the Max Length field';
                    ApplicationArea = NPRMagento;
                }
                field(Position; Rec.Position)
                {

                    ToolTip = 'Specifies the value of the Position field';
                    ApplicationArea = NPRMagento;
                }
                field(Price; Rec.Price)
                {

                    ToolTip = 'Specifies the value of the Price field';
                    ApplicationArea = NPRMagento;
                }
                field("Price Type"; Rec."Price Type")
                {

                    ToolTip = 'Specifies the value of the Price Type field';
                    ApplicationArea = NPRMagento;
                }
                field("Sales Type"; Rec."Sales Type")
                {

                    ToolTip = 'Specifies the value of the Sales Type field';
                    ApplicationArea = NPRMagento;
                }
                field("Sales No."; Rec."Sales No.")
                {

                    ToolTip = 'Specifies the value of the Sales No. field';
                    ApplicationArea = NPRMagento;
                }
                field("No. Series"; Rec."No. Series")
                {

                    ToolTip = 'Specifies the value of the No. Series field';
                    ApplicationArea = NPRMagento;
                }
                field("Item Count"; Rec."Item Count")
                {

                    ToolTip = 'Specifies the value of the Item Count field';
                    ApplicationArea = NPRMagento;

                    trigger OnDrillDown()
                    begin
                        ShowItemsWithMagentoCustomOption(Rec."No.");
                    end;
                }
            }
        }
    }

    local procedure ShowItemsWithMagentoCustomOption(CustomOptionNo: Code[20])
    var
        MagentoItemCustomOption: Record "NPR Magento Item Custom Option";
    begin
        MagentoItemCustomOption.FilterGroup(2);
        MagentoItemCustomOption.SetRange("Custom Option No.", CustomOptionNo);
        MagentoItemCustomOption.SetRange(Enabled, true);
        MagentoItemCustomOption.FilterGroup(0);
        Page.Run(Page::"NPR Magento Item CO Preview", MagentoItemCustomOption);
    end;
}