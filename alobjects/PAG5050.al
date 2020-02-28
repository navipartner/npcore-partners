pageextension 6014447 pageextension6014447 extends "Contact Card" 
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
            field("Name 2";"Name 2")
            {
                Importance = Additional;
            }
        }
        addafter("Foreign Trade")
        {
            group(Magento)
            {
                Caption = 'Magento';
                field("Magento Contact";"Magento Contact")
                {
                }
                field("Magento Customer Group";"Magento Customer Group")
                {
                }
                field("Magento Administrator";"Magento Administrator")
                {
                }
                field("Magento Payment Methods";"Magento Payment Methods")
                {
                }
                field("Magento Shipment Methods";"Magento Shipment Methods")
                {
                }
                field("Magento Account Status";"Magento Account Status")
                {
                }
                field("Magento Price Visibility";"Magento Price Visibility")
                {
                }
            }
        }
    }
    actions
    {
        addafter(Statistics)
        {
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;
            }
        }
        addafter("Create &Interaction")
        {
            group(SMS)
            {
                Caption = 'SMS';
                action(SendSMS)
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;
                }
            }
            group(ActionGroup6151408)
            {
                Caption = 'Magento';
                action(ResetMagentoPassword)
                {
                    Caption = 'Reset Magento Password';
                    Image = UserCertificate;
                }
            }
        }
    }
}

