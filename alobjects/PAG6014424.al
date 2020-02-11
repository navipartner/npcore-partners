page 6014424 "Retail Setup"
{
    // NPR4.10/MMV/20150520 CASE 205310 Added field "Gift/Credit Voucher Period"
    // NPR4.10/MMV/20150527 CASE 213523 Added field "Exchange Label Exchange Period" to page.
    // NPR4.11/MMV/20150617 CASE 205310 Replaced field "Gift/Credit Voucher Period" with new field "Gift and Credit Valid Period"
    // NPR4.11/JDH/20150626 CASE 217444 Removed app. 110 unused fields
    // NPR4.13/MMV/20150629 CASE 217476 Renamed Gift Voucher group to Gift/Credit voucher since the settings affect both.
    // NPR4.13/RA/20150724  CASE 210079 Added fields "Hotkey for Louislane", "Hotkey for Request Commando" and "Support Picture" to group General.
    // NPR4.14/TS/20150817 CASE 220787 Removed field on General Ledger and Allow Icomm ,Base of FIK-71,FIK No
    // NPR4.14/MMV/20150825 CASE 221045 Added fields "Faktura udskrifts valg" and "Receipt for Debit Sale".
    // NPR4.14/RMT/20150826 CASE 216519 Added field "Use Standard Order Document"
    // NPR4.15/MMV/20150925 CASE 217116 Added field "Print Total Item Quantity"
    // NPR4.15/JDH/20151001 CASE 223339 Added Action "Show License info"
    // NPR4.16/JDH/20151016 CASE 225285 Removed old NAS handler references
    // NPR4.16/MMV/20151028 CASE 225533 Added field 5007 "Print Attributes On Receipt"
    // NPR4.16/JDH/20151110 CASE 226327 Fixed Caption
    // NPR4.21/MMV/20151130 CASE 228454 Added field 50041
    // NPR4.21/MMV/20160217 CASE 232628 Removed deprecated fields.
    // NPR5.23/MMV /20160527 CASE 242202 Removed field "Get Customername at Discount"
    // NPR5.23/MMV /20160530 CASE 242921 Removed field "Print Ship. on SO Post+Print"
    // NPR5.23/MMV /20160530 CASE 241549 Removed field "Printer Selection Type"
    // NPR5.23/TJ/20160601 CASE 243117 Removed all fields from LogonInfo group, including the group
    //                                 Also removed variable EnvironRec (codeunit Environment Mgt.) which was used in the SourceExpr of these fields
    // NPR5.23/LS/20160603  CASE 226819 Set VISIBLE property to FALSE for field "Gen. Bus. Posting Group","Customer Posting Group", "Terms of Payment", "Price Group Code"
    //                                   "Interest Condition Code", "Combine Shipments", Rykkerbetingelser,"Vat Bus. Posting Group"
    // NPR5.23/TJ/20160608 CASE 242690 Added new field Customer Template Code under Customer tab, Finance group
    // NPR5.23/MMV /20160610 CASE 244050 Removed 6 deprecated fields (print delay, navibar, purchase line options)
    // NPR5.23/MMV /20160614 CASE 244163 Removed deprecated action "Update Blaster Printer".
    // NPR5.23.01/BR  /20160620 CASE 244575 Added field  "Use NAV Lookup in POS"
    // NPR5.26/LS  /20160817  CASE 246231 Set Visible to FALSE for field "Customer Template Code"
    // NPR5.27/BHR /20161018  CASE 253261 Add field "Not use Dim filter SerialNo" under Expedition/salesflow
    // NPR5.27/JDH /20161018  CASE 255575 Removed action Create item groups as item, since there was no code that did anything in the database
    // NPR5.29/MMV /20161216  CASE 241549 Removed deprecated print/report code.
    // NPR5.29/JDH /20170105  CASE 260472 Description Control is now possible on different types of documents
    // NPR5.29/BHR /20170109  CASE 262439 Field to define the Chart (sales by dimension)
    // NPR5.29/MMV /20170110  CASE 262678 Added field 6300
    // NPR5.29/TS  /20170116  CASE 244157 Removed reference to field "Pop-up (Color-Size)" (1011)
    // NPR5.30/MHA /20170201  CASE 264918 Caption changed for Action: From Photo Setup to Retail Contract Setup
    // NPR5.30/TS  /20170202  CASE 262303 Added Action HotKeys
    // NPR5.30/TS  /20170203  CASE 264917 Removed Support Picture Field
    // NPR5.30/TS  /20170203  CASE 264915 Removed field Mandatory Customer No.
    // NPR5.30/BHR /20170212  CASE 266279 Removed caption on field "Margin And Turnover by Shop"
    // NPR5.30/TJ  /20170223  CASE 264913 Removed fields Terms of Payment, Customer Posting Group and Gen. Bus. Posting Group
    //                                    Added Customer Config. Template
    // NPR5.30/JC  /20170228  CASE 267462 Added field "Automatic inventory posting" in section posting
    // NPR5.31/TSA /20170314  CASE 269105 Removed field 5103 "Prices incl. VAT" from page since it is a duplicate of field 3.
    // NPR5.31/MMV /20170411  CASe 271728 Removed deprecated field 5162 "Default Customer no."
    // NPR5.31/AP  /20170427 CASE 269105 Reversed removal of 5103 "Prices incl. VAT".
    // NPR5.38/BR  /20180118  CASE 302761 Added field "Create POS Entries Only"
    // NPR5.40/TJ  /20180303  CASE 301544 Removed fields not used anywhere else
    // NPR5.43/JC  /20180606 CASE 310534 Added field "Navision Creditnote" in Tab Prints - Documents
    // NPR5.46/TSA /20180914 CASE 314603 Moved field to Security Group
    // NPR5.46/MMV /20180918 CASE 290734 Removed deprecated fields
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.53/ALPO/20191024 CASE 371955 Removed field 13 "Amount Rounding Precision": rounding related fields moved to POS Posting Profiles
    // NPR5.53/BHR /20190810 CASE 369354 Removed Fields 'New Customer creation'
    // NPR5.53/BHR /20191007  CASE 369361 Removed the fields "Company Function" - 6325,"Hotline no." - 5148, "Hosting Type" - 82

    Caption = 'Retail Setup';
    Editable = true;
    PageType = Card;
    SourceTable = "Retail Setup";
    UsageCategory = Administration;

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
                    field("Company No.";"Company No.")
                    {
                    }
                }
                group(Security)
                {
                    Caption = 'Security';
                    field("Password on unblock discount";"Password on unblock discount")
                    {
                    }
                    field("Open Register Password";"Open Register Password")
                    {
                    }
                    field("Use WIN User Profile";"Use WIN User Profile")
                    {
                    }
                    field("Auto Changelog Level";"Auto Changelog Level")
                    {
                    }
                }
            }
            group(Nummerserie)
            {
                Caption = 'Number Series';
                group(Auxiliary)
                {
                    Caption = 'Diverse';
                    field("Posting No. Management";"Posting No. Management")
                    {
                    }
                    field("Variance No. Management";"Variance No. Management")
                    {
                    }
                    field("Credit Voucher No. Management";"Credit Voucher No. Management")
                    {
                    }
                    field("Gift Voucher No. Management";"Gift Voucher No. Management")
                    {
                    }
                    field("Period Discount Management";"Period Discount Management")
                    {
                    }
                    field("Mixed Discount No. Management";"Mixed Discount No. Management")
                    {
                    }
                    field("Customer Repair Management";"Customer Repair Management")
                    {
                    }
                    field("Variant No. Series";"Variant No. Series")
                    {
                    }
                    field("Internal EAN No. Management";"Internal EAN No. Management")
                    {
                    }
                    field("External EAN-No. Management";"External EAN-No. Management")
                    {
                    }
                    field("Exchange Label  No. Series";"Exchange Label  No. Series")
                    {
                    }
                    field("Used Goods No. Management";"Used Goods No. Management")
                    {
                    }
                    field("Cash Cust. No. Series";"Cash Cust. No. Series")
                    {
                    }
                    field("Foreign Gift Voucher no.Series";"Foreign Gift Voucher no.Series")
                    {
                    }
                    field("Foreign Credit Voucher No.Seri";"Foreign Credit Voucher No.Seri")
                    {
                    }
                    field("Quantity Discount Nos.";"Quantity Discount Nos.")
                    {
                    }
                    field("Retail Journal No. Management";"Retail Journal No. Management")
                    {
                    }
                    field("Selection No. Series";"Selection No. Series")
                    {
                    }
                    field("Order  No. Series";"Order  No. Series")
                    {
                    }
                    field("Rental Contract  No. Series";"Rental Contract  No. Series")
                    {
                    }
                    field("Purchase Contract  No. Series";"Purchase Contract  No. Series")
                    {
                    }
                    field("Customization  No. Series";"Customization  No. Series")
                    {
                    }
                    field("Quote  No. Series";"Quote  No. Series")
                    {
                    }
                    field("Reason Code No. Series";"Reason Code No. Series")
                    {
                    }
                }
                group("Item Group")
                {
                    Caption = 'Item Group';
                    field("Itemgroup Pre No. Serie";"Itemgroup Pre No. Serie")
                    {
                    }
                    field("Itemgroup No. Serie StartNo.";"Itemgroup No. Serie StartNo.")
                    {
                    }
                    field("Itemgroup No. Serie EndNo.";"Itemgroup No. Serie EndNo.")
                    {
                    }
                    field("Itemgroup No. Serie Warning";"Itemgroup No. Serie Warning")
                    {
                    }
                }
                group("Barcodes And Prefix")
                {
                    Caption = 'Barcodes and Prefix';
                    field("EAN-Internal";"EAN-Internal")
                    {
                    }
                    field("EAN-External";"EAN-External")
                    {
                    }
                    field("ISBN Bookland EAN";"ISBN Bookland EAN")
                    {
                    }
                    field("EAN Price Code";"EAN Price Code")
                    {
                    }
                    field("EAN Mgt. Gift voucher";"EAN Mgt. Gift voucher")
                    {
                    }
                    field("EAN Mgt. Credit voucher";"EAN Mgt. Credit voucher")
                    {
                    }
                    field("EAN Prefix Exhange Label";"EAN Prefix Exhange Label")
                    {
                    }
                    field("Shelve module";"Shelve module")
                    {
                    }
                }
            }
            group(Prints)
            {
                Caption = 'Prints';
                group(Exchange)
                {
                    Caption = 'Exchange';
                    field("Purchace Price Code";"Purchace Price Code")
                    {
                    }
                    field("Exchange label default date";"Exchange label default date")
                    {
                    }
                    field("Exchange Label Exchange Period";"Exchange Label Exchange Period")
                    {
                    }
                    field("Skip Warranty Voucher Dialog";"Skip Warranty Voucher Dialog")
                    {
                    }
                    field("Warranty Standard Date";"Warranty Standard Date")
                    {
                    }
                }
                group("Gift Voucher")
                {
                    Caption = 'Gift/Credit Voucher';
                    //The GridLayout property is only supported on controls of type Grid
                    //GridLayout = Columns;
                    field("Copy of Gift Voucher etc.";"Copy of Gift Voucher etc.")
                    {
                    }
                    field("Copy Sales Ticket on Giftvo.";"Copy Sales Ticket on Giftvo.")
                    {
                    }
                    field("Gift and Credit Valid Period";"Gift and Credit Valid Period")
                    {
                    }
                }
                group("Register Report")
                {
                    Caption = 'Register Report';
                    field("Show Counting on Counter Rep.";"Show Counting on Counter Rep.")
                    {
                    }
                    field("Print Register Report";"Print Register Report")
                    {
                    }
                }
                group(Documents)
                {
                    Caption = 'Documents';
                    field("Retail Debitnote";"Retail Debitnote")
                    {
                    }
                    field("Receipt for Debit Sale";"Receipt for Debit Sale")
                    {
                    }
                    field("Faktura udskrifts valg";"Faktura udskrifts valg")
                    {
                    }
                    field("Base for FIK-71";"Base for FIK-71")
                    {
                    }
                    field("FIK No.";"FIK No.")
                    {
                    }
                    field("Auto Print Retail Doc";"Auto Print Retail Doc")
                    {
                    }
                    field("Copies of Selection";"Copies of Selection")
                    {
                    }
                    field("No. of Copies of Selection";"No. of Copies of Selection")
                    {
                    }
                    field("Signature for Return 1";"Signature for Return")
                    {
                    }
                    field("Use Standard Order Document";"Use Standard Order Document")
                    {
                    }
                    field("Navision Creditnote";"Navision Creditnote")
                    {
                    }
                }
            }
            grid("Sales Ticket Layout")
            {
                Caption = 'Sales Ticket Layout';
                group(Text)
                {
                    Caption = 'Text';
                    field("Sales Ticket Line Text1";"Sales Ticket Line Text1")
                    {
                    }
                    field("Sales Ticket Line Text2";"Sales Ticket Line Text2")
                    {
                    }
                    field("Sales Ticket Line Text3";"Sales Ticket Line Text3")
                    {
                    }
                    field("Sales Ticket Line Text4";"Sales Ticket Line Text4")
                    {
                    }
                    field("Sales Ticket Line Text5";"Sales Ticket Line Text5")
                    {
                    }
                    field("Sales Ticket Line Text6";"Sales Ticket Line Text6")
                    {
                    }
                    field("Sales Ticket Line Text7";"Sales Ticket Line Text7")
                    {
                    }
                }
            }
            group(Kommunikation)
            {
                Caption = 'Communication';
                group(SMS)
                {
                    Caption = 'SMS';
                    field("Rental Msg.";"Rental Msg.")
                    {
                    }
                    field("Repair Msg.";"Repair Msg.")
                    {
                    }
                    field("Receive Register Turnover";"Receive Register Turnover")
                    {
                    }
                }
            }
            group(Ekspedition)
            {
                Caption = 'Expedition';
                group("Information And Popup")
                {
                    Caption = 'Information and Popup';
                    field("Popup Gift Voucher Quantity";"Popup Gift Voucher Quantity")
                    {
                    }
                    field("Show Create Giftcertificat";"Show Create Giftcertificat")
                    {
                    }
                    field("Show Create Credit Voucher";"Show Create Credit Voucher")
                    {
                    }
                    field("Finish Register Warning";"Finish Register Warning")
                    {
                    }
                    field("Item remarks";"Item remarks")
                    {
                    }
                    field("Ask for Reference";"Ask for Reference")
                    {
                    }
                    field("Ask for Attention Name";"Ask for Attention Name")
                    {
                    }
                    field("Reason for Return Mandatory";"Reason for Return Mandatory")
                    {
                    }
                    field("Overwrite Item No.";"Overwrite Item No.")
                    {
                    }
                    field("Sales Lines from Selection";"Sales Lines from Selection")
                    {
                    }
                    field("Auto edit debit sale";"Auto edit debit sale")
                    {
                    }
                    field("Editable eksp. reverse sale";"Editable eksp. reverse sale")
                    {
                    }
                    field("Warning - Sale with no lines";"Warning - Sale with no lines")
                    {
                    }
                    field("Use deposit in Retail Doc";"Use deposit in Retail Doc")
                    {
                    }
                    field("Customer Credit Level Warning";"Customer Credit Level Warning")
                    {
                    }
                    field("Global Sale POS";"Global Sale POS")
                    {
                    }
                    field("Use NAV Lookup in POS";"Use NAV Lookup in POS")
                    {
                    }
                }
                group("Buttons And Fields")
                {
                    Caption = 'Button and Fields';
                    field("POS - Show discount fields";"POS - Show discount fields")
                    {
                    }
                }
                group("Sales Flow")
                {
                    Caption = 'Sales Flow';
                    field("Reset unit price on neg. sale";"Reset unit price on neg. sale")
                    {
                    }
                    field("Show Stored Tickets";"Show Stored Tickets")
                    {
                    }
                    field("Unit Cost Control";"Unit Cost Control")
                    {
                    }
                    field("Serialno. (Itemno nonexist)";"Serialno. (Itemno nonexist)")
                    {
                    }
                    field("Not use Dim filter SerialNo";"Not use Dim filter SerialNo")
                    {
                    }
                    field("Show saved expeditions";"Show saved expeditions")
                    {
                    }
                    field("Get register no. using";"Get register no. using")
                    {
                    }
                    field("Path Filename to User Profile";"Path Filename to User Profile")
                    {
                    }
                    field("Profit on Gifvouchers";"Profit on Gifvouchers")
                    {
                    }
                    field("Description control";"Description control")
                    {
                    }
                }
                group(Discount)
                {
                    Caption = 'Discount';
                    field("Reason on Discount";"Reason on Discount")
                    {
                    }
                }
            }
            group(Auto)
            {
                Caption = 'Auto';
                group("GL,Customer,Vendor")
                {
                    Caption = 'GL,Customer,Vendor';
                    field("Auto Replication";"Auto Replication")
                    {
                    }
                }
                group("Item Reorder")
                {
                    Caption = 'Item Reorder';
                    field("Check Purchase Lines if vendor";"Check Purchase Lines if vendor")
                    {
                    }
                }
                group("Item Creation")
                {
                    Caption = 'Item Creation';
                    field("Item Group on Creation";"Item Group on Creation")
                    {
                    }
                    field("Item group in Item no.";"Item group in Item no.")
                    {
                    }
                    field("EAN-No. at Item Create";"EAN-No. at Item Create")
                    {
                    }
                    field("Autocreate EAN-Number";"Autocreate EAN-Number")
                    {
                    }
                    field("EAN No. at 1 star";"EAN No. at 1 star")
                    {
                    }
                    field("Item Description at 1 star";"Item Description at 1 star")
                    {
                    }
                    field("Item Description at 2 star";"Item Description at 2 star")
                    {
                    }
                    field("Vendor When Creation";"Vendor When Creation")
                    {
                    }
                    field("Prices Include VAT";"Prices Include VAT")
                    {
                    }
                    field("Costing Method Standard";"Costing Method Standard")
                    {
                    }
                }
                group("POS Sale")
                {
                    Caption = 'POS Sale';
                    field("Create retail order";"Create retail order")
                    {
                    }
                    field("Item No. Shipping";"Item No. Shipping")
                    {
                    }
                }
            }
            group(Debitor)
            {
                Caption = 'Customer';
                group("Security 2")
                {
                    Caption = 'Security';
                    field("Create New Customer";"Create New Customer")
                    {
                    }
                    field("Allow Customer Cash Sale";"Allow Customer Cash Sale")
                    {
                    }
                    field("Demand Cash Cust on Neg Sale";"Demand Cash Cust on Neg Sale")
                    {
                    }
                    field("Customer No.";"Customer No.")
                    {
                    }
                    field("Default Rental";"Default Rental")
                    {
                    }
                    field("Rep. Cust. Default";"Rep. Cust. Default")
                    {
                    }
                    field("Cash Customer Deposit rel.";"Cash Customer Deposit rel.")
                    {
                    }
                }
                group("G/L Details")
                {
                    Caption = 'G/L Details';
                    field("Customer Config. Template";"Customer Config. Template")
                    {
                    }
                    field("Prices incl. VAT";"Prices incl. VAT")
                    {
                    }
                    field("Customer type";"Customer type")
                    {
                    }
                }
                group(Employee)
                {
                    Caption = 'Employee';
                    field("Staff Disc. Group";"Staff Disc. Group")
                    {
                    }
                    field("Staff Price Group";"Staff Price Group")
                    {
                    }
                    field("Internal Unit Price";"Internal Unit Price")
                    {
                    }
                    field("Internal Dept. Code";"Internal Dept. Code")
                    {
                    }
                    field("Staff SalesPrice Calc Codeunit";"Staff SalesPrice Calc Codeunit")
                    {
                    }
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                group("Posting Group")
                {
                    Caption = 'Posting Group';
                    field("Poste Sales Ticket Immediately";"Poste Sales Ticket Immediately")
                    {
                    }
                    field("Post Customer Payment imme.";"Post Customer Payment imme.")
                    {
                    }
                    field("Post Payouts imme.";"Post Payouts imme.")
                    {
                    }
                    field("Immediate postings";"Immediate postings")
                    {
                    }
                    field("Appendix no. eq Sales Ticket";"Appendix no. eq Sales Ticket")
                    {
                    }
                    field("Create POS Entries Only";"Create POS Entries Only")
                    {

                        trigger OnValidate()
                        begin
                            //-NPR5.38 [302761]
                            CurrPage.Update;
                            //+NPR5.38 [302761]
                        end;
                    }
                    field("Post Sale";"Post Sale")
                    {
                    }
                    field("Posting Audit Roll";"Posting Audit Roll")
                    {
                    }
                    field("Posting When Balancing";"Posting When Balancing")
                    {
                    }
                    field("Debug Posting";"Debug Posting")
                    {
                    }
                    field("Post to Journal";"Post to Journal")
                    {
                    }
                    field("Journal Type";"Journal Type")
                    {
                    }
                    field("Journal Name";"Journal Name")
                    {
                    }
                    field("Salespersoncode on Salesdoc.";"Salespersoncode on Salesdoc.")
                    {
                    }
                    field("Posting Source Code";"Posting Source Code")
                    {
                    }
                    field("Post registers compressed";"Post registers compressed")
                    {
                    }
                    field("Automatic inventory posting";"Automatic inventory posting")
                    {
                    }
                }
                group(Currency)
                {
                    Caption = 'Currency';
                    field("Register Cnt. Units";"Register Cnt. Units")
                    {
                    }
                    field("Euro Exchange Rate";"Euro Exchange Rate")
                    {
                    }
                }
                group(Statistics)
                {
                    Caption = 'Statistics';
                    field("No. of Sales pr. Stat";"No. of Sales pr. Stat")
                    {
                    }
                    field("Dim Stat Method";"Dim Stat Method")
                    {
                    }
                    field("Dim Stat Value";"Dim Stat Value")
                    {
                    }
                    field("Stat. Dimension";"Stat. Dimension")
                    {
                    }
                    field("F9 Statistics When Login";"F9 Statistics When Login")
                    {
                    }
                    field("Use Adv. dimensions";"Use Adv. dimensions")
                    {
                    }
                }
                group(Chart)
                {
                    Caption = 'Chart on RoleCenter';
                    field("Margin and Turnover By Shop";"Margin and Turnover By Shop")
                    {
                    }
                }
                group(SalesDocuments)
                {
                    Caption = 'Sales Documents';
                    field("Sale Doc. Type On Post. Pstv.";"Sale Doc. Type On Post. Pstv.")
                    {
                    }
                    field("Sale Doc. Type On Post. Negt.";"Sale Doc. Type On Post. Negt.")
                    {
                    }
                    field("Sale Doc. Post. On Order";"Sale Doc. Post. On Order")
                    {
                    }
                    field("Sale Doc. Post. On Invoice";"Sale Doc. Post. On Invoice")
                    {
                    }
                    field("Sale Doc. Post. On Cred. Memo";"Sale Doc. Post. On Cred. Memo")
                    {
                    }
                    field("Sale Doc. Post. On Ret. Order";"Sale Doc. Post. On Ret. Order")
                    {
                    }
                    field("Sale Doc. Print On Post";"Sale Doc. Print On Post")
                    {
                    }
                }
            }
            group(Reparation)
            {
                Caption = 'Repair';
                group(Betaling)
                {
                    Caption = 'Payment';
                    field("Fixed Price of Mending";"Fixed Price of Mending")
                    {
                    }
                    field("Fixed Price of Denied Mending";"Fixed Price of Denied Mending")
                    {
                    }
                }
            }
            group("Document Description")
            {
                Caption = 'Document Description';
                field("Sales Line Description Code";"Sales Line Description Code")
                {
                }
                field("Purchase Line Description Code";"Purchase Line Description Code")
                {
                }
                field("Transfer Line Description Code";"Transfer Line Description Code")
                {
                }
                field("POS Line Description Code";"POS Line Description Code")
                {
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
                    RunObject = Page "E-mail Templates";
                }
            }
            group("&Setup")
            {
                Caption = '&Setup';
                action("I-Comm Settings")
                {
                    Caption = 'I-Comm Settings';
                    Image = Form;
                    RunObject = Page "I-Comm";
                }
                action("Scanner / weight setup")
                {
                    Caption = 'Scanner / weight setup';
                    Image = Form;
                    RunObject = Page "Scanner - Setup";
                }
                action(Insurance)
                {
                    Caption = 'Insurance';
                    Image = Form;
                    RunObject = Page "Insurrance Combination";
                }
                action("Retail Contract Setup")
                {
                    Caption = 'Retail Contract Setup';
                    Image = Form;
                    RunObject = Page "Retail Contract Setup";
                }
                action("User setup")
                {
                    Caption = 'User setup';
                    Image = Form;
                    RunObject = Page "User Setup";
                }
                action("Package Module configuration")
                {
                    Caption = 'Package Module configuration';
                    Image = Form;
                    RunObject = Page "Package Module Admin";
                }
                action(HotKeys)
                {
                    Caption = 'HotKeys';
                    Image = ShortcutToDesktop;
                    RunObject = Page Hotkeys;
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

                        trigger OnAction()
                        var
                            Nummerserie: Record "No. Series";
                        begin

                            TestField( "Posting No. Management" );
                            TestField( "Variance No. Management" );
                            TestField( "Credit Voucher No. Management");
                            TestField( "Gift Voucher No. Management");
                            TestField( "Period Discount Management" );
                            TestField( "Mixed Discount No. Management" );
                            TestField( "Customer Repair Management" );
                            TestField( "Used Goods No. Management" );
                            //TESTFIELD( Udlejningsnumre );
                            TestField( "Order  No. Series" );
                            TestField( "Cash Cust. No. Series" );
                            TestField( "Internal EAN No. Management" );
                            TestField( "External EAN-No. Management" );

                            if not Nummerserie.Get( "Posting No. Management" ) then
                              OpretNummerserie( "Posting No. Management", FieldName( "Posting No. Management" ), false );

                            if not Nummerserie.Get( "Variance No. Management" ) then
                              OpretNummerserie( "Variance No. Management", FieldName( "Variance No. Management" ), false );

                            if not Nummerserie.Get( "Credit Voucher No. Management" ) then
                              OpretNummerserie( "Credit Voucher No. Management", FieldName( "Credit Voucher No. Management" ), false );

                            if not Nummerserie.Get( "Gift Voucher No. Management" ) then
                              OpretNummerserie( "Gift Voucher No. Management", FieldName( "Gift Voucher No. Management" ), false );

                            if not Nummerserie.Get( "Period Discount Management" ) then
                              OpretNummerserie( "Period Discount Management", FieldName( "Period Discount Management" ), false );

                            if not Nummerserie.Get( "Mixed Discount No. Management" ) then
                              OpretNummerserie( "Mixed Discount No. Management", FieldName( "Mixed Discount No. Management" ), false );

                            if not Nummerserie.Get( "Customer Repair Management" ) then
                              OpretNummerserie( "Customer Repair Management", FieldName( "Customer Repair Management" ), false );

                            if not Nummerserie.Get( "Used Goods No. Management" ) then
                              OpretNummerserie( "Used Goods No. Management", FieldName( "Used Goods No. Management" ), false );

                            //IF NOT Nummerserie.GET( Udlejningsnumre ) THEN
                            //  OpretNummerserie( Udlejningsnumre, FIELDNAME( Udlejningsnumre ), FALSE );

                            if not Nummerserie.Get( "Order  No. Series" ) then
                              OpretNummerserie( "Order  No. Series", FieldName( "Order  No. Series" ), false );

                            if not Nummerserie.Get( "Cash Cust. No. Series" ) then
                              OpretNummerserie( "Cash Cust. No. Series", FieldName( "Cash Cust. No. Series" ), true );

                            if not Nummerserie.Get( "Internal EAN No. Management" ) then
                              OpretNummerserie( "Internal EAN No. Management", FieldName( "Internal EAN No. Management" ), false );

                            if not Nummerserie.Get( "External EAN-No. Management" ) then
                              OpretNummerserie( "External EAN-No. Management", FieldName( "External EAN-No. Management" ), false );
                        end;
                    }
                    action("View License Info")
                    {
                        Caption = 'Show License Range';
                        Image = View;
                        RunObject = Page "Permission Range";
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        RetailConfiguration: Record "Retail Setup";
    begin
        if not RetailConfiguration.Get then begin
          RetailConfiguration.Init;
          if RetailConfiguration.Insert( true ) then;
          Get;
        end;
    end;

    var
        BilledeFindes: Boolean;
        win: Dialog;
        sessionname: Text[100];
        LOngonServerText: Text[30];
        Txt0001: Label 'Error. Cancelling.';

    procedure OpretNummerserie(NummerKode: Code[10];FieldDescr: Text[50];Manuel: Boolean)
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

