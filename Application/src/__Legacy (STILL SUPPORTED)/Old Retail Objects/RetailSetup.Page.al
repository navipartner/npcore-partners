page 6014424 "NPR Retail Setup"
{
    Caption = 'Retail Setup';
    Editable = true;
    PageType = Card;
    SourceTable = "NPR Retail Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(Generelt)
            {
                Caption = 'General';
                group("Company Infomation")
                {
                    Caption = 'Company Information';
                    field("Company No."; "Company No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Company No. field';
                    }
                }
                group(Security)
                {
                    Caption = 'Security';
                    field("Password on unblock discount"; "Password on unblock discount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Administrator Password field';
                    }
                    field("Open Register Password"; "Open Register Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Open Cash Register Password field';
                    }
                    field("Use WIN User Profile"; "Use WIN User Profile")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Use WIN User Profile field';
                    }
                }
            }
            group(Nummerserie)
            {
                Caption = 'Number Series';
                group(Auxiliary)
                {
                    Caption = 'Diverse';
                    field("Variance No. Management"; "Variance No. Management")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Variance No. Management field';
                    }
                    field("Period Discount Management"; "Period Discount Management")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Period Discount No. Management field';
                    }
                    field("Mixed Discount No. Management"; "Mixed Discount No. Management")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Mixed Discount No. Management field';
                    }
                    field("Customer Repair Management"; "Customer Repair Management")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Repair Management field';
                    }
                    field("Variant No. Series"; "Variant No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Variant Std. No. Serie field';
                    }
                    field("Internal EAN No. Management"; "Internal EAN No. Management")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Internal EAN No. Management field';
                    }
                    field("External EAN-No. Management"; "External EAN-No. Management")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the External EAN-No. Management field';
                    }
                    field("Exchange Label  No. Series"; "Exchange Label  No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Exchange Label Nos. field';
                    }
                    field("Used Goods No. Management"; "Used Goods No. Management")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Used Goods No. Management field';
                    }
                    field("Cash Cust. No. Series"; "Cash Cust. No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Cust. No. Series field';
                    }
                    field("Quantity Discount Nos."; "Quantity Discount Nos.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Quantity Discount Nos. field';
                    }
                    field("Selection No. Series"; "Selection No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Selection Nos. field';
                    }
                    field("Order  No. Series"; "Order  No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Order No. field';
                    }
                    field("Rental Contract  No. Series"; "Rental Contract  No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Rental Contract Nos. field';
                    }
                    field("Purchase Contract  No. Series"; "Purchase Contract  No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Purchase Contract Nos. field';
                    }
                    field("Customization  No. Series"; "Customization  No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customization Nos. field';
                    }
                    field("Quote  No. Series"; "Quote  No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Quote Nos. field';
                    }
                    field("Reason Code No. Series"; "Reason Code No. Series")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reason Code No. Series field';
                    }
                }
                group("Item Group")
                {
                    Caption = 'Item Group';
                    field("Itemgroup Pre No. Serie"; "Itemgroup Pre No. Serie")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Itemgroup Pre No. Serie field';
                    }
                    field("Itemgroup No. Serie StartNo."; "Itemgroup No. Serie StartNo.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Itemgroup No. Serie StartNo. field';
                    }
                    field("Itemgroup No. Serie EndNo."; "Itemgroup No. Serie EndNo.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Itemgroup No. Serie EndNo. field';
                    }
                    field("Itemgroup No. Serie Warning"; "Itemgroup No. Serie Warning")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Itemgroup No. Serie Warning field';
                    }
                }
                group("Barcodes And Prefix")
                {
                    Caption = 'Barcodes and Prefix';
                    field("EAN-Internal"; "EAN-Internal")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EAN-Internal field';
                    }
                    field("EAN-External"; "EAN-External")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EAN-External field';
                    }
                    field("ISBN Bookland EAN"; "ISBN Bookland EAN")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the ISBN Bookland EAN field';
                    }
                    field("EAN Price Code"; "EAN Price Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EAN Price Group field';
                    }
                    field("EAN Prefix Exhange Label"; "EAN Prefix Exhange Label")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EAN Prefix Exhange Label field';
                    }
                    field("Shelve module"; "Shelve module")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Shelve Module field';
                    }
                }
            }
            group(Prints)
            {
                Caption = 'Prints';
                group(Exchange)
                {
                    Caption = 'Exchange';
                    field("Purchace Price Code"; "Purchace Price Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Purchase Price Code field';
                    }
                    field("Exchange label default date"; "Exchange label default date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Exchange Label Default Date field';
                    }
                    field("Exchange Label Exchange Period"; "Exchange Label Exchange Period")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Exchange Label Exchange Period field';
                    }
                    field("Skip Warranty Voucher Dialog"; "Skip Warranty Voucher Dialog")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Warranty Voucher Dialog field';
                    }
                    field("Warranty Standard Date"; "Warranty Standard Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Warranty Standard Date field';
                    }
                }
                group("Register Report")
                {
                    Caption = 'Register Report';
                    field("Show Counting on Counter Rep."; "Show Counting on Counter Rep.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Counting On Counter Report field';
                    }
                    field("Print Register Report"; "Print Register Report")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print Cash Register Report field';
                    }
                }
                group(Documents)
                {
                    Caption = 'Documents';
                    field("Retail Debitnote"; "Retail Debitnote")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Retail Debitnote field';
                    }
                    field("Receipt for Debit Sale"; "Receipt for Debit Sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Receipt For Debit Sale field';
                    }
                    field("Faktura udskrifts valg"; "Faktura udskrifts valg")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Invoice Printout Option field';
                    }
                    field("Base for FIK-71"; "Base for FIK-71")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Base Of FIK-71 field';
                    }
                    field("FIK No."; "FIK No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the FIK No. field';
                    }
                    field("Auto Print Retail Doc"; "Auto Print Retail Doc")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Auto Print Retail Document field';
                    }
                    field("Copies of Selection"; "Copies of Selection")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Copies Of Selection field';
                    }
                    field("No. of Copies of Selection"; "No. of Copies of Selection")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the No. Of Copies Of Selection field';
                    }
                    field("Signature for Return 1"; "Signature for Return")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Signature For Return field';
                    }
                    field("Use Standard Order Document"; "Use Standard Order Document")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Use Standard Order Document field';
                    }
                    field("Navision Creditnote"; "Navision Creditnote")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Navision Creditnote field';
                    }
                }
            }
            grid("Sales Ticket Layout")
            {
                Caption = 'Sales Ticket Layout';

                group("Text")
                {
                    Caption = 'Text';

                    field("Sales Ticket Line Text6"; "Sales Ticket Line Text6")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Ticket Line Text6 field';
                    }
                    field("Sales Ticket Line Text7"; "Sales Ticket Line Text7")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Ticket Line Text7 field';
                    }
                }
            }
            group(Kommunikation)
            {
                Caption = 'Communication';
                group(SMS)
                {
                    Caption = 'SMS';
                    field("Rental Msg."; "Rental Msg.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Rental Msg. field';
                    }
                    field("Repair Msg."; "Repair Msg.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Repair Msg. field';
                    }
                    field("Receive Register Turnover"; "Receive Register Turnover")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Receive Cash Register Turnover field';
                    }
                }
            }
            group(Ekspedition)
            {
                Caption = 'Expedition';
                group("Information And Popup")
                {
                    Caption = 'Information and Popup';
                    field("Show Create Giftcertificat"; "Show Create Giftcertificat")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Create Gift Certificate field';
                    }
                    field("Ask for Reference"; "Ask for Reference")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ask For Reference field';
                    }
                    field("Ask for Attention Name"; "Ask for Attention Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ask For Attention Name field';
                    }
                    field("Reason for Return Mandatory"; "Reason for Return Mandatory")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reason For Return Mandatory field';
                    }
                    field("Sales Lines from Selection"; "Sales Lines from Selection")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Lines From Selection, -F4 field';
                    }
                    field("Auto edit debit sale"; "Auto edit debit sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Auto Edit Debit Sale field';
                    }
                    field("Editable eksp. reverse sale"; "Editable eksp. reverse sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Editable Eksp. Reverse Sale field';
                    }
                    field("Warning - Sale with no lines"; "Warning - Sale with no lines")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Warning - Sale With No Lines field';
                    }
                    field("Use deposit in Retail Doc"; "Use deposit in Retail Doc")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Use Deposit In Retail Doc field';
                    }
                    field("Customer Credit Level Warning"; "Customer Credit Level Warning")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Credit Level Warning field';
                    }
                    field("Global Sale POS"; "Global Sale POS")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Global Sale POS field';
                    }
                    field("Use NAV Lookup in POS"; "Use NAV Lookup in POS")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Use NAV Lookup In POS field';
                    }
                }
                group("Buttons And Fields")
                {
                    Caption = 'Button and Fields';
                    field("POS - Show discount fields"; "POS - Show discount fields")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Discount field';
                    }
                }
                group("Sales Flow")
                {
                    Caption = 'Sales Flow';
                    field("Reset unit price on neg. sale"; "Reset unit price on neg. sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reset Unit Price On Neg. Sale field';
                    }
                    field("Show Stored Tickets"; "Show Stored Tickets")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Stores Tickets field';
                    }
                    field("Unit Cost Control"; "Unit Cost Control")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Unit Cost Control field';
                    }
                    field("Serialno. (Itemno nonexist)"; "Serialno. (Itemno nonexist)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Serial No. (Itemno. Does Not Exists) field';
                    }
                    field("Not use Dim filter SerialNo"; "Not use Dim filter SerialNo")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Dont Use Dim Filter Serial No. field';
                    }
                    field("Show saved expeditions"; "Show saved expeditions")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Saved Expeditions field';
                    }
                    field("Get register no. using"; "Get register no. using")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Get Register No. Using field';
                    }
                    field("Path Filename to User Profile"; "Path Filename to User Profile")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Path + Filename To User Profile field';
                    }
                    field("Description control"; "Description control")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Description Control field';
                    }
                }
                group(Discount)
                {
                    Caption = 'Discount';
                    field("Reason on Discount"; "Reason on Discount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reason On Discount field';
                    }
                }
            }
            group(Auto)
            {
                Caption = 'Auto';
                group("GL,Customer,Vendor")
                {
                    Caption = 'GL,Customer,Vendor';
                    field("Auto Replication"; "Auto Replication")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Auto Replication field';
                    }
                }
                group("Item Reorder")
                {
                    Caption = 'Item Reorder';
                    field("Check Purchase Lines if vendor"; "Check Purchase Lines if vendor")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Check Purchase Lines If Vendor field';
                    }
                }
                group("Item Creation")
                {
                    Caption = 'Item Creation';
                    field("Item Group on Creation"; "Item Group on Creation")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Item Group On Creation field';
                    }
                    field("Item group in Item no."; "Item group in Item no.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Item Group In Item No. field';
                    }
                    field("EAN-No. at Item Create"; "EAN-No. at Item Create")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EAN-No. At Item Create field';
                    }
                    field("Autocreate EAN-Number"; "Autocreate EAN-Number")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Autocreate EAN-Number field';
                    }
                    field("EAN No. at 1 star"; "EAN No. at 1 star")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EAN No. At * field';
                    }
                    field("Item Description at 1 star"; "Item Description at 1 star")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Item Description At * field';
                    }
                    field("Item Description at 2 star"; "Item Description at 2 star")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Item Description At ** field';
                    }
                    field("Vendor When Creation"; "Vendor When Creation")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Vendor When Creation field';
                    }
                    field("Costing Method Standard"; "Costing Method Standard")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Costing Method Std. field';
                    }
                }
                group("POS Sale")
                {
                    Caption = 'POS Sale';
                    field("Create retail order"; "Create retail order")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Selection System field';
                    }
                    field("Item No. Shipping"; "Item No. Shipping")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Item No. Deposit field';
                    }
                }
            }
            group(Debitor)
            {
                Caption = 'Customer';
                group("Security 2")
                {
                    Caption = 'Security';
                    field("Create New Customer"; "Create New Customer")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Create New Customer field';
                    }
                    field("Allow Customer Cash Sale"; "Allow Customer Cash Sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Allow Customer Cash Sale field';
                    }
                    field("Demand Cash Cust on Neg Sale"; "Demand Cash Cust on Neg Sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Demand Cash Customer On Neg Sale field';
                    }
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer No. field';
                    }
                    field("Default Rental"; "Default Rental")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Default Rental field';
                    }
                    field("Rep. Cust. Default"; "Rep. Cust. Default")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Rep. Cust. Default field';
                    }
                    field("Cash Customer Deposit rel."; "Cash Customer Deposit rel.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Customer Deposit Rel. field';
                    }
                }
                group("G/L Details")
                {
                    Caption = 'G/L Details';
                    field("Customer Config. Template"; "Customer Config. Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Config. Template field';
                    }
                    field("Prices incl. VAT"; "Prices incl. VAT")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Prices Incl. VAT field';
                    }
                    field("Customer type"; "Customer type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer Type field';
                    }
                }
                group(Employee)
                {
                    Caption = 'Employee';
                    field("Staff Disc. Group"; "Staff Disc. Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Staff Disc. Group field';
                    }
                    field("Staff Price Group"; "Staff Price Group")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Staff Price Group field';
                    }
                    field("Internal Unit Price"; "Internal Unit Price")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Internal Unit Price field';
                    }
                    field("Internal Dept. Code"; "Internal Dept. Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Internal Departement Code field';
                    }
                    field("Staff SalesPrice Calc Codeunit"; "Staff SalesPrice Calc Codeunit")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Staff SalesPrice Calc Codeunit field';
                    }
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                group("Posting Group")
                {
                    Caption = 'Posting Group';
                    field("Poste Sales Ticket Immediately"; "Poste Sales Ticket Immediately")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Poste Sales Ticket Immediately field';
                    }
                    field("Post Customer Payment imme."; "Post Customer Payment imme.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Customer Payment Imme. field';
                    }
                    field("Post Payouts imme."; "Post Payouts imme.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Payouts Imme. field';
                    }
                    field("Immediate postings"; "Immediate postings")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Immediate Posting field';
                    }
                    field("Appendix no. eq Sales Ticket"; "Appendix no. eq Sales Ticket")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Appendix No. Equals Sales Ticket No. field';
                    }
                    field("Create POS Entries Only"; "Create POS Entries Only")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Create POS Entries Only field';

                        trigger OnValidate()
                        begin
                            //-NPR5.38 [302761]
                            CurrPage.Update;
                            //+NPR5.38 [302761]
                        end;
                    }
                    field("Post Sale"; "Post Sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Sale field';
                    }
                    field("Posting Audit Roll"; "Posting Audit Roll")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Posting Audit Roll field';
                    }
                    field("Debug Posting"; "Debug Posting")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Debug Posting field';
                    }
                    field("Post to Journal"; "Post to Journal")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post To Journal field';
                    }
                    field("Journal Type"; "Journal Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Journal Type field';
                    }
                    field("Journal Name"; "Journal Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Journal Name field';
                    }
                    field("Salespersoncode on Salesdoc."; "Salespersoncode on Salesdoc.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Salesperson Code On Sales Documents field';
                    }
                    field("Posting Source Code"; "Posting Source Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Posting Source Code field';
                    }
                    field("Post registers compressed"; "Post registers compressed")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Registers Compressed field';
                    }
                    field("Automatic inventory posting"; "Automatic inventory posting")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Automatic Inventory Posting field';
                    }
                }
                group(Currency)
                {
                    Caption = 'Currency';
                    field("Register Cnt. Units"; "Register Cnt. Units")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Register Cnt. Units field';
                    }
                    field("Euro Exchange Rate"; "Euro Exchange Rate")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Euro Exchange Rate field';
                    }
                }
                group(Statistics)
                {
                    Caption = 'Statistics';
                    field("No. of Sales pr. Stat"; "No. of Sales pr. Stat")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the No. Of Sales Pr. Stat field';
                    }
                    field("Dim Stat Method"; "Dim Stat Method")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Dim. Stat. Method field';
                    }
                    field("Dim Stat Value"; "Dim Stat Value")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Dim Stat Value field';
                    }
                    field("Stat. Dimension"; "Stat. Dimension")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Stat. Dimension field';
                    }
                    field("F9 Statistics When Login"; "F9 Statistics When Login")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the F9 Statistics When Login field';
                    }
                    field("Use Adv. dimensions"; "Use Adv. dimensions")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Use Dimensioncontrol field';
                    }
                }
                group(Chart)
                {
                    Caption = 'Chart on RoleCenter';
                    field("Margin and Turnover By Shop"; "Margin and Turnover By Shop")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Margin And Turnover By Shop field';
                    }
                }
                group(SalesDocuments)
                {
                    Caption = 'Sales Documents';
                    field("Sale Doc. Type On Post. Pstv."; "Sale Doc. Type On Post. Pstv.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Doc. Type On Post. Pstv. field';
                    }
                    field("Sale Doc. Type On Post. Negt."; "Sale Doc. Type On Post. Negt.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Doc. Type On Post. Negt. field';
                    }
                    field("Sale Doc. Post. On Order"; "Sale Doc. Post. On Order")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Doc. Post. On Order field';
                    }
                    field("Sale Doc. Post. On Invoice"; "Sale Doc. Post. On Invoice")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Doc. Post. On Invoice field';
                    }
                    field("Sale Doc. Post. On Cred. Memo"; "Sale Doc. Post. On Cred. Memo")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Doc. Post. On Cred. Memo field';
                    }
                    field("Sale Doc. Post. On Ret. Order"; "Sale Doc. Post. On Ret. Order")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sale Doc. Post. On Ret. Order field';
                    }
                    field("Sale Doc. Print On Post"; "Sale Doc. Print On Post")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Send Document On Post field';
                    }
                }
            }
            group(Reparation)
            {
                Caption = 'Repair';
                group(Betaling)
                {
                    Caption = 'Payment';
                    field("Fixed Price of Mending"; "Fixed Price of Mending")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Fixed Price Of Mending field';
                    }
                    field("Fixed Price of Denied Mending"; "Fixed Price of Denied Mending")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Fixed Price Of Denied Mending field';
                    }
                }
            }
            group("Document Description")
            {
                Caption = 'Document Description';
                field("Sales Line Description Code"; "Sales Line Description Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line Description Code field';
                }
                field("Purchase Line Description Code"; "Purchase Line Description Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Line Description Code field';
                }
                field("Transfer Line Description Code"; "Transfer Line Description Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer Line Description Code field';
                }
                field("POS Line Description Code"; "POS Line Description Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Line Description Code field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Email)
            {
                Caption = 'Email';
                Image = Journals;
                action("E-mail")
                {
                    Caption = '&E-Mail';
                    Image = Email;
                    RunObject = Page "NPR E-mail Templates";
                    ApplicationArea = All;
                    ToolTip = 'Executes the &E-Mail action';
                }
            }
            group("&Setup")
            {
                Caption = '&Setup';
                action("I-Comm Settings")
                {
                    Caption = 'I-Comm Settings';
                    Image = Form;
                    RunObject = Page "NPR I-Comm";
                    ApplicationArea = All;
                    ToolTip = 'Executes the I-Comm Settings action';
                }
                action("Scanner / weight setup")
                {
                    Caption = 'Scanner / weight setup';
                    Image = Form;
                    RunObject = Page "NPR Scanner - Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Scanner / weight setup action';
                }
                action(Insurance)
                {
                    Caption = 'Insurance';
                    Image = Form;
                    RunObject = Page "NPR Insurrance Combination";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Insurance action';
                }
                action("Retail Contract Setup")
                {
                    Caption = 'Retail Contract Setup';
                    Image = Form;
                    RunObject = Page "NPR Retail Contr. Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Contract Setup action';
                }
                action("User setup")
                {
                    Caption = 'User setup';
                    Image = Form;
                    RunObject = Page "User Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the User setup action';
                }
                action("Package Module configuration")
                {
                    Caption = 'Package Module configuration';
                    Image = Form;
                    RunObject = Page "NPR Package Module Admin";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Package Module configuration action';
                }
            }
            group(Routines)
            {
                Caption = 'Routines';
                Image = ExecuteBatch;
                group(Company)
                {
                    Caption = 'Company';
                    Image = Departments;
                }
                group(Advanced)
                {
                    Caption = 'Advanced';
                    Image = Administration;
                    action("Create NPR No. Series")
                    {
                        Caption = 'Create NPR No. Series';
                        Image = "Action";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Create NPR No. Series action';

                        trigger OnAction()
                        var
                            Nummerserie: Record "No. Series";
                        begin

                            TestField("Variance No. Management");
                            TestField("Period Discount Management");
                            TestField("Mixed Discount No. Management");
                            TestField("Customer Repair Management");
                            TestField("Used Goods No. Management");
                            //TESTFIELD( Udlejningsnumre );
                            TestField("Order  No. Series");
                            TestField("Cash Cust. No. Series");
                            TestField("Internal EAN No. Management");
                            TestField("External EAN-No. Management");

                            if not Nummerserie.Get("Variance No. Management") then
                                OpretNummerserie("Variance No. Management", FieldName("Variance No. Management"), false);

                            if not Nummerserie.Get("Period Discount Management") then
                                OpretNummerserie("Period Discount Management", FieldName("Period Discount Management"), false);

                            if not Nummerserie.Get("Mixed Discount No. Management") then
                                OpretNummerserie("Mixed Discount No. Management", FieldName("Mixed Discount No. Management"), false);

                            if not Nummerserie.Get("Customer Repair Management") then
                                OpretNummerserie("Customer Repair Management", FieldName("Customer Repair Management"), false);

                            if not Nummerserie.Get("Used Goods No. Management") then
                                OpretNummerserie("Used Goods No. Management", FieldName("Used Goods No. Management"), false);

                            //IF NOT Nummerserie.GET( Udlejningsnumre ) THEN
                            //  OpretNummerserie( Udlejningsnumre, FIELDNAME( Udlejningsnumre ), FALSE );

                            if not Nummerserie.Get("Order  No. Series") then
                                OpretNummerserie("Order  No. Series", FieldName("Order  No. Series"), false);

                            if not Nummerserie.Get("Cash Cust. No. Series") then
                                OpretNummerserie("Cash Cust. No. Series", FieldName("Cash Cust. No. Series"), true);

                            if not Nummerserie.Get("Internal EAN No. Management") then
                                OpretNummerserie("Internal EAN No. Management", FieldName("Internal EAN No. Management"), false);

                            if not Nummerserie.Get("External EAN-No. Management") then
                                OpretNummerserie("External EAN-No. Management", FieldName("External EAN-No. Management"), false);
                        end;
                    }
                    action("View License Info")
                    {
                        Caption = 'Show License Range';
                        Image = View;
                        RunObject = Page "NPR Permission Range";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Show License Range action';
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        RetailConfiguration: Record "NPR Retail Setup";
    begin
        if not RetailConfiguration.Get then begin
            RetailConfiguration.Init;
            if RetailConfiguration.Insert(true) then;
            Get;
        end;
    end;

    var
        BilledeFindes: Boolean;
        win: Dialog;
        sessionname: Text[100];
        LOngonServerText: Text[30];
        Txt0001: Label 'Error. Cancelling.';

    procedure OpretNummerserie(NummerKode: Code[10]; FieldDescr: Text[50]; Manuel: Boolean)
    var
        Nummerserie: Record "No. Series";
        SerieLinie: Record "No. Series Line";
    begin
        //OpretNummerserie()
        Nummerserie.Init;
        Nummerserie.Code := NummerKode;
        Nummerserie.Description := FieldDescr;
        Nummerserie."Default Nos." := true;
        Nummerserie."Manual Nos." := Manuel;
        Nummerserie.Insert;
        SerieLinie.Init;
        SerieLinie."Series Code" := NummerKode;
        SerieLinie."Line No." := 10000;
        SerieLinie."Starting Date" := Today;
        SerieLinie."Last Date Used" := Today;
        SerieLinie."Starting No." := '1';
        SerieLinie."Last No. Used" := '1';
        SerieLinie.Open := true;
        SerieLinie.Insert;
    end;

    procedure "Enable/DisableFields"()
    begin
        //CurrPage."Warranty Standard Date".EDITABLE("Skip Warranty Voucher Dialog" <> '')
    end;
}

