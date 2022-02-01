pageextension 6014452 "NPR Contact Card" extends "Contact Card"
{
    layout
    {
        addafter(Name)
        {
            field("NPR Name 2"; Rec."Name 2")
            {

                Importance = Additional;
                ToolTip = 'Specifies the second name of the contact and allows additional name details.';
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

                    ToolTip = 'Specifies if the contact will be a Magento Contact.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Customer Group"; Rec."NPR Magento Customer Group")
                {

                    ToolTip = 'Specifies the Customer Group for the Magento Contact.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Payment Methods"; Rec."NPR Magento Payment Methods")
                {

                    ToolTip = 'Specifies the payment method information of the Magento Contact.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Shipment Methods"; Rec."NPR Magento Shipment Methods")
                {

                    ToolTip = 'Specifies the Magento contact''s shipment method information.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Account Status"; Rec."NPR Magento Account Status")
                {

                    ToolTip = 'Allows you to activate or block a Magento Contact';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Price Visibility"; Rec."NPR Magento Price Visibility")
                {

                    ToolTip = 'Specifies whether Magento Prices will be visible for the contact';
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

                ToolTip = 'Allows the user to view POS entries.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
                begin
                    POSEntryNavigation.OpenPOSEntryListFromContact(Rec);
                end;
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

                    ToolTip = 'Allows users to send SMS messages to customers.';
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

                    ToolTip = 'Resets the password for Magento.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        M2AccountManager: Codeunit "NPR M2 Account Manager";
                        Contact: Record Contact;
                        ReasonText: Text;
                    begin
                        Contact := Rec;
                        if not (M2AccountManager.ResetMagentoPassword(Contact, ReasonText)) then
                            Error(ReasonText);
                    end;
                }
            }
        }
    }
}

