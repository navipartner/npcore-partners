pageextension 6014452 "NPR Contact Card" extends "Contact Card"
{
    // MAG1.05/MHA /20150220  CASE 206395 Added Webshop Group
    // MAG1.07/MHA /20150309  CASE 206395 Added Field 6059825 "Webshop Display Group"
    // MAG1.08/MHA /20150311  CASE 206395 Removed Field 6059825 "Webshop Display Group" and added function SetMagentoVisible();
    // MAG1.17/MHA /20150622  CASE 215533 Magento related NaviConnect Setup moved to Magento Setup
    // NPR5.22/TJ  /20160411  CASE 238601 Setting danish captions to page and actions which are missing
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA /20160525  CASE 240005 Magento function removed to better support extensions: SetMagentoVisible()
    // NPR5.30/THRO/20170203  CASE 263182 Added action SendSMS
    // NPR5.34/TR  /20170721  CASE 282454 Added "Name 2" to General group.
    // NPR5.38/BR  /20171117  CASE 295255 Added Action POS Entries
    // NPR5.48/TSA /20181219 CASE 320424 Added "Magento Account Status" and "Magento Price Visibility" to Magento section
    // MAG2.21/TSA /20190502 CASE 320424 Added Reset Magento Password button
    layout
    {
        addafter(Name)
        {
            field("NPR Name 2"; "Name 2")
            {
                ApplicationArea = All;
                Importance = Additional;
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
                }
                field("NPR Magento Customer Group"; "NPR Magento Customer Group")
                {
                    ApplicationArea = All;
                }
                field("NPR Magento Administrator"; "NPR Magento Administrator")
                {
                    ApplicationArea = All;
                }
                field("NPR Magento Payment Methods"; "NPR Magento Payment Methods")
                {
                    ApplicationArea = All;
                }
                field("NPR Magento Shipment Methods"; "NPR Magento Shipment Methods")
                {
                    ApplicationArea = All;
                }
                field("NPR Magento Account Status"; "NPR Magento Account Status")
                {
                    ApplicationArea = All;
                }
                field("NPR Magento Price Visibility"; "NPR Magento Price Visibility")
                {
                    ApplicationArea = All;
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
                }
            }
            group("NPR ResetPassword")
            {
                Caption = 'Magento';
                action("NPR ResetMagentoPassword")
                {
                    Caption = 'Reset Magento Password';
                    Image = UserCertificate;
                }
            }
        }
    }
}

