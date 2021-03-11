pageextension 6014452 "NPR Contact Card" extends "Contact Card"
{
    layout
    {
        addafter(Name)
        {
            field("NPR Name 2"; "Name 2")
            {
                ApplicationArea = All;
                Importance = Additional;
                ToolTip = 'Specifies the value of the Name 2 field';
            }
        }
        addafter("Foreign Trade")
        {
            group("NPR Magento")
            {
                Caption = 'Magento';
                field("NPR Magento Contact"; "NPR Magento Contact")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Contact field';
                }
                field("NPR Magento Customer Group"; "NPR Magento Customer Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Customer Group field';
                }
                field("NPR Magento Payment Methods"; "NPR Magento Payment Methods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Payment Methods field';
                }
                field("NPR Magento Shipment Methods"; "NPR Magento Shipment Methods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Shipment Methods field';
                }
                field("NPR Magento Account Status"; "NPR Magento Account Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Account Status field';
                }
                field("NPR Magento Price Visibility"; "NPR Magento Price Visibility")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Price Visibility field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entries action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send SMS action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Reset Magento Password action';
                }
            }
        }
    }
}

