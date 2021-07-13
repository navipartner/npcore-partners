pageextension 6014452 "NPR Contact Card" extends "Contact Card"
{
    layout
    {
        addafter(Name)
        {
            field("NPR Name 2"; Rec."Name 2")
            {

                Importance = Additional;
                ToolTip = 'Specifies the value of the Name 2 field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Foreign Trade")
        {
            group("NPR Magento")
            {
                Caption = 'Magento';
                field("NPR Magento Contact"; Rec."NPR Magento Contact")
                {

                    ToolTip = 'Specifies the value of the NPR Magento Contact field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Customer Group"; Rec."NPR Magento Customer Group")
                {

                    ToolTip = 'Specifies the value of the NPR Magento Customer Group field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Payment Methods"; Rec."NPR Magento Payment Methods")
                {

                    ToolTip = 'Specifies the value of the NPR Magento Payment Methods field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Shipment Methods"; Rec."NPR Magento Shipment Methods")
                {

                    ToolTip = 'Specifies the value of the NPR Magento Shipment Methods field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Account Status"; Rec."NPR Magento Account Status")
                {

                    ToolTip = 'Specifies the value of the NPR Magento Account Status field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Price Visibility"; Rec."NPR Magento Price Visibility")
                {

                    ToolTip = 'Specifies the value of the NPR Magento Price Visibility field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    actions
    {
        addafter(Statistics)
        {
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;

                ToolTip = 'Executes the POS Entries action';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Create &Interaction")
        {
            group("NPR SMS")
            {
                Caption = 'SMS';
                action("NPR SendSMS")
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;

                    ToolTip = 'Executes the Send SMS action';
                    ApplicationArea = NPRRetail;
                    trigger OnAction()
                    var
                        SMSMgt: Codeunit "NPR SMS Management";
                    begin
                        SMSMgt.EditAndSendSMS(Rec);
                    end;
                }
            }
            group("NPR ResetPassword")
            {
                Caption = 'Magento';
                action("NPR ResetMagentoPassword")
                {
                    Caption = 'Reset Magento Password';
                    Image = UserCertificate;

                    ToolTip = 'Executes the Reset Magento Password action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

