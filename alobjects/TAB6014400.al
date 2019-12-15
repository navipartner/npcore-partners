table 6014400 "Retail Setup"
{
    // NPR3.0m, NPK, DL, 05-03-07, Tilf�jet felt 50014 pakkelabel
    // 
    // NPR3.4n, NIES, 29-03-07, Rounding flyttet til kasserne.
    // NPR3.4o, NPK, DL, 02-04-07, Tilf�jet felt 50016
    // NPR3.4p, NPK, DL, 15-04-07, Tilf�jet felt 50017
    // NPR3.4q, NPK, DL, 19-04-07, Tilf�jet felt 50018
    // NPR3.4r, NPK, DL, 26-04-07, Tilf�jet felt 50019
    // PCM1.0 (NPR-Package1.0), NPK, DL, 18-03-08, Added fields 6500-6504
    //                                   19-03-08, Added fields 6505-6508
    //                                   04-04-08, Moved fields to table 6014550
    // 
    // NPR4.004.006, 07-07-09, MH - Tilf�jet felt, 50044 Receipt type, der definerer, hvordan bon skal udskrives fra kassen.
    // NPR6.001.005 20130313 LJJ - CASE 152082: Field 50050 - "Cust. Barcode Management" - added.
    //                                          Field 50051 - "Cust. Barcode Prefix" - added.
    // NPR6.001.006 20130702 LJJ - CASE 158804: Field 50052 - "Post Statement Per Journal" - added.
    // NPR4.10/MMV/20150508 CASE 205310 Renamed field 50043
    // NPR4.11/MMV/20150617 CASE 205310 Added field 90
    // NPR4.11/JDH/20150626 CASE 217444 Removed about 150 unused fields + variables + code that was outcommented
    // NPR4.12/MMV/20150702 CASE 217490 Changed captions on field Return Receipt Positive Amount to make it more clear what the button actually does on print.
    // NPR4.13/RA/20150724  CASE 210079 Added fields "Hotkey for Louislane", "Hotkey for Request Commando" and "Support Picture"
    // NPR4.14/RMT/20150826 CASE 216519 Added field 5035 "Use Standard Order Document"
    // NPR4.15/MMV/20150925 CASE 217116 Added field 5006 "Print Total Item Quantity"
    // NPR4.16/MMV/20151028 CASE 225533 Added field 5007 "Print Attributes On Receipt"
    // NPR5.20/TTH/20160303 CASE 235900 Removed extra blank space from the OptionCaption of field 5061 Unit Cost Control.
    // NPR5.23/MMV /20160527 CASE 242202 Removed deprecated field 5063 "Get Customername at Discount"
    // NPR5.23/MMV /20160530 CASE 242921 Removed deprecated field 6247 "Print Ship. on SO Post+Print"
    // NPR5.23/MMV /20160530 CASE 241549 Removed deprecated field 6166 "Printer Selection Type"
    // NPR5.23/TJ/20160608 CASE 242690 Added new field Customer Template Code
    // NPR5.23/MMV /20160610 CASE 244050 Removed 6 deprecated fields (print delay, navibar, purchase line options)
    // NPR5.23.01/BR  /20160620 CASE 244575 Added field  "Use NAV Lookup in POS"
    // NPR5.27/BHR/20161018 CASE 253261 Added field 'Not use Dim filter SerialNo'
    //                                  to Skip filtering in global Dimension when searching for SerialNo in ItemLedger
    // NPR5.29/MMV /20161216  CASE 241549 Removed deprecated print/report code.
    // NPR5.29/JDH /20170105  CASE 260472 Description Control is now possible on different types of documents
    // NPR5.29/BHR /20170105  CASE 262439 Field Query Sales By Shop
    // NPR5.29/MMV /20170106  CASE 262678 Added field 6300
    // NPR5.30/TS  /20170130  CASE 264914 Renamed fields an Captions
    // NPR5.30/TS  /20170130  CASE 264914 Removed field SportingPartner
    // NPR5.30/TJ  /20170202  CASE 264793 Removed unused fields
    // NPR5.30/TS  /20170203  CASE 264917 Removed unused fields
    // NPR5.30/TS  /20170203  CASE 264915 Removed field Mandatory Customer No.
    // NPR5.30/TJ  /20170215  CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.30/BHR /20170212  CASE 266279 Rename field "Query sales by Shop" to  "Margin And Turnover by Shop"
    // NPR5.30/TJ  /20170223  CASE 264913 Removed fields Terms of Payment, Customer Posting Group and Gen. Bus. Posting Group
    //                                    Added new field Customer Config. Template
    // NPR5.31/TSA /20170314  CASE 269105 Removed field 5103 "Prices incl. VAT" from page since it is a duplicate of field 3.
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.31/MMV /20170411  CASE 271728 Removed deprecated field 5162 "Default Customer no."
    // NPR5.31/AP  /20170427  CASE 269105 Recreated field 5103 "Prices incl. VAT" (since its not duplicate).
    // NPR5.32/JDH /20170525 CASE 278031  Changed fieldlengths for fields
    //                                    5034 Statement Journal Name
    //                                    5130 Cash Customer Deposit rel.
    //                                    5139 Journalname
    //                                    5141 Journal Type
    //                                    6230 Staff Disc. Group
    // NPR5.36/TJ  /20170904  CASE 286283 Renamed all the danish OptionString properties to english
    // NPR5.38/TJ  /20171218  CASE 225415 Renumbered fields from range 50xxx to range below 50000
    // NPR5.38/BR  /20180118  CASE 302761 Added field "Create POS Entries Only"
    // NPR5.40/THRO/20180326  CASE 302617 Changed Caption on field 356 to 'Send Document On Post'
    // NPR5.40/TJ  /20180303  CASE 301544 Removed fields not used: 5014 Poste when EAN Labe, 5034 Statement Journal Name, 6221 Password on General Ledger and 6252 Support Picture
    //                                    Removed fields used only on page 6014424 Retail Setup
    // NPR5.41/BHR /20180305  CASE 307094 Update all the captions accordingly.
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj
    // NPR5.46/BHR /20181005  CASE 324954 Removed Unused fields fron Retail Setup
    // NPR5.48/BHR /20190114  CASE 341974 Change field type of the fields 5116,5117 and 5118 from text30 to Code 20

    Caption = 'Retail Setup';

    fields
    {
        field(1;"Key";Code[20])
        {
            Caption = 'Key';
            Description = 'Prim�rn�gle';
        }
        field(3;"Prices Include VAT";Boolean)
        {
            Caption = 'Prices Include VAT';
            Description = 'Moms med i salgspriser';
        }
        field(5;"Posting When Balancing";Option)
        {
            Caption = 'Posting When Balancing';
            OptionCaption = 'Total,Per Register';
            OptionMembers = Total,"Per Register";
        }
        field(13;"Amount Rounding Precision";Decimal)
        {
            Caption = 'Amount Rounding Precision';
            Description = 'Afrundingspr�cision for �reafrunding';
            InitValue = 0.25;
            MaxValue = 1;
            MinValue = 0;

            trigger OnValidate()
            var
                "Integer": Integer;
                t001: Label '%1';
            begin
                if "Amount Rounding Precision" <> 0 then
                  if not Evaluate(Integer,StrSubstNo(t001,1/"Amount Rounding Precision")) then
                    Error(Text1060006+
                          Text1060007);
            end;
        }
        field(14;"Sales Ticket Line Text1";Code[50])
        {
            Caption = 'Sales Ticket Line Text1';
            Description = 'Ekstratekst til bon';
        }
        field(15;"Sales Ticket Line Text2";Code[50])
        {
            Caption = 'Sales Ticket Line Text2';
            Description = 'Ekstratekst til bon';
        }
        field(16;"Sales Ticket Line Text3";Code[50])
        {
            Caption = 'Sales Ticket Line Text3';
            Description = 'Ekstratekst til bon';
        }
        field(17;"Sales Ticket Line Text4";Code[50])
        {
            Caption = 'Sales Ticket Line Text4';
            Description = 'Ekstratekst til bon';
        }
        field(18;"Sales Ticket Line Text5";Code[50])
        {
            Caption = 'Sales Ticket Line Text5';
            Description = 'Ekstratekst til bon';
        }
        field(20;"Posting Source Code";Code[10])
        {
            Caption = 'Posting Source Code';
            Description = 'Kildespor til bogf�ring';
            TableRelation = "Source Code";
        }
        field(51;"Posting No. Management";Code[10])
        {
            Caption = 'Posting No. Management';
            Description = 'Nummerserie til kassebogf�ring';
            TableRelation = "No. Series";
        }
        field(52;"Used Goods No. Management";Code[10])
        {
            Caption = 'Used Goods No. Management';
            Description = 'Nummerserie til brugtvarer';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if xRec."Used Goods No. Management" <> '' then
                  Error(Text1060008);
            end;
        }
        field(53;"Internal EAN No. Management";Code[10])
        {
            Caption = 'Internal EAN No. Management';
            Description = 'Nummerserie til EAN numre';
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                if xRec."Internal EAN No. Management" <> '' then
                  Error(Text1060008);
            end;
        }
        field(54;"Credit Voucher No. Management";Code[10])
        {
            Caption = 'Credit Voucher No. Management';
            Description = 'Nummerserie til tilgodebevis';
            TableRelation = "No. Series";
        }
        field(55;"Gift Voucher No. Management";Code[10])
        {
            Caption = 'Gift Voucher No. Management';
            Description = 'Nummerserie til gavekort';
            TableRelation = "No. Series";
        }
        field(56;"External EAN-No. Management";Code[10])
        {
            Caption = 'External EAN-No. Management';
            Description = 'Nummerserie til eksterne EAN numre';
            TableRelation = "No. Series";
        }
        field(57;"EAN Prefix Exhange Label";Code[2])
        {
            Caption = 'EAN Prefix Exhange Label';
        }
        field(60;"EAN-Internal";Integer)
        {
            Caption = 'EAN-Internal';
            Description = 'Intern ean nummer start';
            MaxValue = 29;
            MinValue = 27;
        }
        field(61;"ISBN Bookland EAN";Boolean)
        {
            Caption = 'ISBN Bookland EAN';
        }
        field(70;"Payment Type By Register";Boolean)
        {
            Caption = 'Payment Type Managed By Cash Register';
            Description = 'Kassestyret betalingsvalg';

            trigger OnValidate()
            var
                Betalingsvalg: Record "Payment Type POS";
            begin
                if Betalingsvalg.Find('-') then
                  Error(Text1060009);
            end;
        }
        field(81;"EAN-External";Integer)
        {
            Caption = 'EAN-External';
            Description = 'ekstern eannummer';
        }
        field(82;"Hosting type";Option)
        {
            Caption = 'Hosting Type';
            Description = 'Ops�tter printervalg afh�ngig af hostingtype.';
            OptionCaption = 'Client,Citrix,Terminal Server,Terminal Server 2008';
            OptionMembers = Client,Citrix,"Terminal Server","Terminal Server 2008";
        }
        field(83;"Get register no. using";Option)
        {
            Caption = 'Get Register No. Using';
            OptionCaption = 'USERPROFILE,COMPUTERNAME,CLIENTNAME,SESSIONNAME,USERNAME,USERID,USERDOMAINID,USER SETUP TABLE,SALESPERSON TABLE';
            OptionMembers = USERPROFILE,COMPUTERNAME,CLIENTNAME,SESSIONNAME,USERNAME,USERID,USERDOMAINID,"USER SETUP TABLE",SALESPERSON;
        }
        field(90;"Gift and Credit Valid Period";Integer)
        {
            Caption = 'Gift And Credit Valid Period';
        }
        field(100;"Sales Line Description Code";Code[20])
        {
            Caption = 'Sales Line Description Code';
            TableRelation = "Description Control";
        }
        field(105;"Purchase Line Description Code";Code[20])
        {
            Caption = 'Purchase Line Description Code';
            TableRelation = "Description Control";
        }
        field(110;"Transfer Line Description Code";Code[20])
        {
            Caption = 'Transfer Line Description Code';
            TableRelation = "Description Control";
        }
        field(115;"POS Line Description Code";Code[20])
        {
            Caption = 'POS Line Description Code';
            TableRelation = "Description Control";
        }
        field(350;"Sale Doc. Type On Post. Pstv.";Option)
        {
            Caption = 'Sale Doc. Type On Post. Pstv.';
            OptionCaption = 'Invoice,Order';
            OptionMembers = Invoice,"Order";
        }
        field(351;"Sale Doc. Type On Post. Negt.";Option)
        {
            Caption = 'Sale Doc. Type On Post. Negt.';
            OptionCaption = 'Return Order,Credit Memo';
            OptionMembers = "Return Order","Credit Memo";
        }
        field(352;"Sale Doc. Post. On Order";Option)
        {
            Caption = 'Sale Doc. Post. On Order';
            OptionCaption = 'Ask,Ship,Ship and Invoice,Dont Post';
            OptionMembers = Ask,Ship,"Ship and Invoice","Dont Post";
        }
        field(353;"Sale Doc. Post. On Invoice";Option)
        {
            Caption = 'Sale Doc. Post. On Invoice';
            OptionCaption = 'Ask,Yes,No';
            OptionMembers = Ask,Yes,No;
        }
        field(354;"Sale Doc. Post. On Cred. Memo";Option)
        {
            Caption = 'Sale Doc. Post. On Cred. Memo';
            OptionCaption = 'Ask,Yes,No';
            OptionMembers = Ask,Yes,No;
        }
        field(355;"Sale Doc. Post. On Ret. Order";Option)
        {
            Caption = 'Sale Doc. Post. On Ret. Order';
            OptionCaption = 'Ask,Receive,Receive and Invoice,Dont Post';
            OptionMembers = Ask,Receive,"Receive and Invoice","Dont Post";
        }
        field(356;"Sale Doc. Print On Post";Boolean)
        {
            Caption = 'Send Document On Post';
        }
        field(450;"Use Adv. dimensions";Boolean)
        {
            Caption = 'Use Dimensioncontrol';
            InitValue = true;
        }
        field(501;"Variance No. Management";Code[10])
        {
            Caption = 'Variance No. Management';
            Description = 'nummerstyring til variation';
            InitValue = '0';
            TableRelation = "No. Series";
        }
        field(502;"Mixed Discount No. Management";Code[10])
        {
            Caption = 'Mixed Discount No. Management';
            Description = 'nummerstyring til miksrabat';
            TableRelation = "No. Series";
        }
        field(503;"Period Discount Management";Code[10])
        {
            Caption = 'Period Discount No. Management';
            Description = 'nummerstyring til perioderabat';
            TableRelation = "No. Series";
        }
        field(504;"Customer Repair Management";Code[10])
        {
            Caption = 'Customer Repair Management';
            Description = 'nummerstyring til  kunderep.';
            TableRelation = "No. Series";
        }
        field(505;"Quantity Discount Nos.";Code[10])
        {
            Caption = 'Quantity Discount Nos.';
            Description = 'Nummerstyring til flerstyksprishoveder';
            TableRelation = "No. Series";
        }
        field(550;"Use NAV Lookup in POS";Boolean)
        {
            Caption = 'Use NAV Lookup In POS';
            Description = 'NPR5.23.01';
        }
        field(655;"Posting Audit Roll";Option)
        {
            Caption = 'Posting Audit Roll';
            Description = 'Ops�tning for revisionsrulle bogf�ring';
            OptionCaption = 'Manual,Automatic';
            OptionMembers = Manual,Automatic;
        }
        field(700;"Selection No. Series";Code[10])
        {
            Caption = 'Selection Nos.';
            Description = 'Nummerserie til udlejning';
            TableRelation = "No. Series";
        }
        field(701;"Order  No. Series";Code[10])
        {
            Caption = 'Order No.';
            Description = 'Nummerserie til bestilling';
            TableRelation = "No. Series";
        }
        field(703;"Rental Contract  No. Series";Code[10])
        {
            Caption = 'Rental Contract Nos.';
            Description = 'Nummerserie til udk�rsel';
            TableRelation = "No. Series";
        }
        field(704;"Purchase Contract  No. Series";Code[10])
        {
            Caption = 'Purchase Contract Nos.';
            Description = 'Nummerserie til udk�rsel';
            TableRelation = "No. Series";
        }
        field(705;"Customization  No. Series";Code[10])
        {
            Caption = 'Customization Nos.';
            Description = 'Nummerserie til udk�rsel';
            TableRelation = "No. Series";
        }
        field(706;"Quote  No. Series";Code[10])
        {
            Caption = 'Quote Nos.';
            Description = 'Nummerserie til udk�rsel';
            TableRelation = "No. Series";
        }
        field(720;"Exchange Label  No. Series";Code[10])
        {
            Caption = 'Exchange Label Nos.';
            Description = 'Nummerserie Til Bytte M�rker';
            TableRelation = "No. Series";
        }
        field(750;"Variant No. Series";Code[10])
        {
            Caption = 'Variant Std. No. Serie';
            Description = 'Nummerserie til 10-code variantkode (ikke EAN)';
            TableRelation = "No. Series";
        }
        field(800;"Balancing Posting Type";Option)
        {
            Caption = 'Balancing';
            Description = 'Ops�tning til kasseafslutning';
            OptionCaption = 'PER REGISTER,TOTAL';
            OptionMembers = "PER REGISTER",TOTAL;
        }
        field(998;"Credit Card Extension";Text[50])
        {
            Caption = 'Credit Card Extension';
            Description = 'Parametre til dankortprogram';
        }
        field(999;"Credit Card Program";Text[50])
        {
            Caption = 'Credit Card Program';
            Description = 'Lokation af dankortprogram';
        }
        field(1000;"Credit Card Path";Text[50])
        {
            Caption = 'Credit Card Path';
            Description = 'Sti til dankortprogram';
        }
        field(1001;"Create New Customer";Boolean)
        {
            Caption = 'Create New Customer';

            trigger OnValidate()
            begin
                if not "Create New Customer" then
                  "New Customer Creation" := "New Customer Creation"::All;
            end;
        }
        field(1002;"New Customer Creation";Option)
        {
            Caption = 'New Customer Creation';
            Description = 'Ops�tning af hvem der kan oprette kunder';
            OptionCaption = 'All,User Managed,Cash Customer,Customer';
            OptionMembers = All,"User Managed","Cash Customer",Customer;

            trigger OnValidate()
            begin
                if "New Customer Creation" <> "New Customer Creation"::All then
                  TestField("Create New Customer",true);
            end;
        }
        field(1015;"Company No.";Code[20])
        {
            Caption = 'Company No.';
        }
        field(1016;"Use deposit in Retail Doc";Boolean)
        {
            Caption = 'Use Deposit In Retail Doc';
            Description = 'Benyt depositum ved reservation?';
        }
        field(1019;"Popup Gift Voucher Quantity";Boolean)
        {
            Caption = 'Pop-up (Gift Voucher Quantity And Discount)';
            Description = 'Show Quantity And Discount % for giftvoucher Sale';
        }
        field(2001;"Base for FIK-71";Option)
        {
            Caption = 'Base Of FIK-71';
            Description = 'Angiver om fakturanummer eller debitornummer bruges i fik.';
            OptionCaption = 'Invoice,Customer';
            OptionMembers = Invoice,Customer;
        }
        field(3009;"Item Group on Creation";Boolean)
        {
            Caption = 'Item Group On Creation';
            Description = 'Angiver om der skal sp�rges efter vgr. ved oprettelse';
        }
        field(4001;"Print Register Report";Boolean)
        {
            Caption = 'Print Cash Register Report';
            Description = 'Angiver om der skal printes en kasserapport ved afslutning';
        }
        field(4002;"Sales Ticket Item";Boolean)
        {
            Caption = 'Sales Ticket Item No.';
            Description = 'Angiver om varenummer skal med p� bon';
        }
        field(4003;"Recommended Price";Boolean)
        {
            Caption = 'Recommended Price On Sales Ticket';
            Description = 'Angiver om vejledende pris skal med p� bon';
        }
        field(4004;"Logo on Sales Ticket";Boolean)
        {
            Caption = 'Logo On Sales Ticket';
            Description = 'Angiver om der skal logo p� bon''erne';
        }
        field(4005;"Name on Sales Ticket";Boolean)
        {
            Caption = 'Name On Sales Ticket';
            Description = 'Angiver om der skal firma navn p� bon''erne';
        }
        field(4009;"Vendor When Creation";Boolean)
        {
            Caption = 'Vendor When Creation';
            Description = 'Angiver om der skal sp�rges om leverand�r ved opret';
        }
        field(4016;"Overwrite Item No.";Boolean)
        {
            Caption = 'Overwrite Item No.';
            Description = 'Angiver om det skal v�re muligt at overskrive varenummeret i en ekspeditionslinie.';
        }
        field(4019;"Item Description at 1 star";Boolean)
        {
            Caption = 'Item Description At *';
            Description = 'Overf�rer varebeskrivelse fra varegruppe ved autoopret';
        }
        field(4020;"Item Description at 2 star";Boolean)
        {
            Caption = 'Item Description At **';
            Description = 'Overf�rer varebeskrivelse fra varegruppe ved autoopret';
        }
        field(5005;"Salesperson on Sales Ticket";Boolean)
        {
            Caption = 'Salesperson On Sales Ticket';
            Description = 'Udskrift af ekspedientnavn p� bon';
        }
        field(5006;"Print Total Item Quantity";Boolean)
        {
            Caption = 'Print Total Quantity Items Sold';
        }
        field(5007;"Print Attributes On Receipt";Boolean)
        {
            Caption = 'Print Attributes On Receipt';
        }
        field(5008;"Euro Exchange Rate";Decimal)
        {
            Caption = 'Euro Exchange Rate';
            Description = 'Angiver eurokurs uden brug af valuta modul';
        }
        field(5011;"Create retail order";Option)
        {
            Caption = 'Selection System';
            Description = 'Skal der sp�rges om man k�rer med skr�ddersystem';
            OptionCaption = ' ,Before Payment,After Payment';
            OptionMembers = " ","Before payment","After payment";
        }
        field(5016;"Customer No.";Option)
        {
            Caption = 'Customer No.';
            Description = 'Om der skal sp�rges efter kundenummer ved login';
            OptionCaption = 'Standard,At login,Before payment';
            OptionMembers = Standard,"At login","Before payment";
        }
        field(5018;"Sales Lines from Selection";Boolean)
        {
            Caption = 'Sale Lines From Selection, -F4';
            Description = 'Mulighed for at slette ekspeditionslinier, hvis de er fra udlejning';
        }
        field(5019;"Euro on Sales Ticket";Boolean)
        {
            Caption = 'Euro On Sales Ticket';
            Description = 'Angiver om europris skal med p� bon';
        }
        field(5020;"Receipt for Debit Sale";Boolean)
        {
            Caption = 'Receipt For Debit Sale';
            Description = 'Afg�re om rapport valget under salg og faktura skal k�res ifm. at man laver en faktura';
        }
        field(5022;"Purchace Price Code";Text[10])
        {
            Caption = 'Purchase Price Code';
            Description = 'Angiver det ord k�bsprisen skal kodes efter p� prislabel';
        }
        field(5024;"Bar Code on Sales Ticket Print";Boolean)
        {
            Caption = 'Bar Code On Sales Ticket Print';
            Description = 'Stregkode p� bonudskrift';
        }
        field(5025;"Post Sale";Boolean)
        {
            Caption = 'Post Sale';
            Description = 'Umiddelbart ikke noget';
        }
        field(5026;"Auto Print Retail Doc";Boolean)
        {
            Caption = 'Auto Print Retail Document';
            Description = 'Automatisk udskrift af bestillingsseddel';
        }
        field(5029;"Copy of Gift Voucher etc.";Boolean)
        {
            Caption = 'Copy Of Gift Voucher etc.';
            Description = 'Udskriv kopi af gavekort';
        }
        field(5030;"FIK No.";Code[10])
        {
            Caption = 'FIK No.';
            Description = 'FIKnr af firma';
        }
        field(5031;"Ask for Reference";Boolean)
        {
            Caption = 'Ask For Reference';
            Description = 'Sp�rg efter reference ved debetsalg under ekspedition';
        }
        field(5033;"EAN No. at 1 star";Boolean)
        {
            Caption = 'EAN No. At *';
            Description = 'Lav EAN nummer ved vare autoopret';
        }
        field(5035;"Use Standard Order Document";Boolean)
        {
            Caption = 'Use Standard Order Document';
            Description = 'Toggles the use of retail versus sales docs for orders';
        }
        field(5040;"Poste Sales Ticket Immediately";Boolean)
        {
            Caption = 'Poste Sales Ticket Immediately';
            Description = 'Straksbogf�ring af bon';
        }
        field(5041;"Copies of Selection";Boolean)
        {
            Caption = 'Copies Of Selection';
            Description = 'Udskriv kopier af bestilling';

            trigger OnValidate()
            begin
                if not "Copies of Selection" then
                  "No. of Copies of Selection" := 0;
            end;
        }
        field(5042;"No. of Copies of Selection";Integer)
        {
            Caption = 'No. Of Copies Of Selection';
            Description = 'Antal bestillingskopier der skal udskrives';
        }
        field(5043;"Cash Cust. No. Series";Code[10])
        {
            Caption = 'Cash Cust. No. Series';
            Description = 'Nummerserie til kontantkunder';
            TableRelation = "No. Series";
        }
        field(5051;"Exchange Label Exchange Period";DateFormula)
        {
            Caption = 'Exchange Label Exchange Period';
            Description = 'Bytteperiode for Byttem�rker';
        }
        field(5056;"Use WIN User Profile";Boolean)
        {
            Caption = 'Use WIN User Profile';
            Description = 'Anvend std. Win brugerprofil til kassefil';
        }
        field(5057;"Path Filename to User Profile";Text[50])
        {
            Caption = 'Path + Filename To User Profile';
            Description = 'Alternativ sti til kassefil';
        }
        field(5058;"Open Register Password";Code[20])
        {
            Caption = 'Open Cash Register Password';
            Description = 'kode til at �bne kasseskuffen';
        }
        field(5061;"Unit Cost Control";Option)
        {
            Caption = 'Unit Cost Control';
            Description = 'Sp�rremuligheder til �ndring af � pris';
            OptionCaption = 'Enabled,Disabled,Disabled if Quantity > 0,Disabled if xUnit Cost > Unit Cost,Disabled if Quantity > 0 and xUnit Cost > Unit Cost';
            OptionMembers = Enabled,Disabled,"Disabled if Quantity > 0","Disabled if xUnit Cost > Unit Cost","Disabled if Quantity > 0 and xUnit Cost > Unit Cost";
        }
        field(5062;"Copy No. on Sales Ticket";Boolean)
        {
            Caption = 'Copy No. On Sales Ticket';
            Description = 'Udskriv kopinummeret p� bonen';
        }
        field(5068;"Transfer SeO Item Entry";Boolean)
        {
            Caption = 'Transfer Seo To Item Entry';
            Description = 'Overf�rsel af Serienummer ej oprettet til varepost';
        }
        field(5071;"Register Cnt. Units";Text[100])
        {
            Caption = 'Cash Register Cnt. Units';
            Description = 'Ops�tning af valutaopdeling til kassen';
            InitValue = '0,25:0,50:1:2:5:10:20:50:100:200:500:1000';
        }
        field(5073;"Post Customer Payment imme.";Boolean)
        {
            Caption = 'Post Customer Payment Imme.';
            Description = 'Straksbogf�r debitor indbetalinger';
        }
        field(5076;"Post Payouts imme.";Boolean)
        {
            Caption = 'Post Payouts Imme.';
            Description = 'Straksbogf�r udbetalinger';
        }
        field(5077;"Auto Replication";Boolean)
        {
            Caption = 'Auto Replication';
            Description = 'Aktiver replikering af flere regnskaber';
        }
        field(5092;"Post registers compressed";Boolean)
        {
            Caption = 'Post Registers Compressed';
        }
        field(5097;"Rental Msg.";Boolean)
        {
            Caption = 'Rental Msg.';
            Description = 'Send udlejnings SMS';
        }
        field(5099;"EAN-No. at Item Create";Boolean)
        {
            Caption = 'EAN-No. At Item Create';
            Description = 'Autoopret EAN nummer ved vareopret';
        }
        field(5100;"Default Rental";Option)
        {
            Caption = 'Default Rental';
            Description = 'Std. debitortype';
            OptionCaption = 'Ord. Customer,Cash Customer';
            OptionMembers = "Ord. Customer","Cash Customer";
        }
        field(5103;"Prices incl. VAT";Boolean)
        {
            Caption = 'Prices Incl. VAT';
            Description = 'Salgspriser inkl. moms';
        }
        field(5104;"Repair Msg.";Boolean)
        {
            Caption = 'Repair Msg.';
            Description = 'Send reparations SMS';
        }
        field(5105;"Receive Register Turnover";Option)
        {
            Caption = 'Receive Cash Register Turnover';
            Description = 'Send  SMS med kasseoms�tning ved kasseopt�lling';
            OptionCaption = 'None,Per Register,Total Turnover';
            OptionMembers = "None","Per Register","Total Turnover";
        }
        field(5106;"Autocreate EAN-Number";Boolean)
        {
            Caption = 'Autocreate EAN-Number';
            Description = 'Opret EAN nummer  ved ny vare';
        }
        field(5110;"Itemgroup Pre No. Serie";Code[5])
        {
            Caption = 'Itemgroup Pre No. Serie';
            Description = 'Code f�r automatisk oprettede varegruppe nr. serier';
        }
        field(5116;"Itemgroup No. Serie StartNo.";Code[20])
        {
            Caption = 'Itemgroup No. Serie StartNo.';
            Description = 'Startnummer til varegruppe nr. serie';
        }
        field(5117;"Itemgroup No. Serie EndNo.";Code[20])
        {
            Caption = 'Itemgroup No. Serie EndNo.';
            Description = 'Slutnummer til varegruppe nr. serie';
        }
        field(5118;"Itemgroup No. Serie Warning";Code[20])
        {
            Caption = 'Itemgroup No. Serie Warning';
            Description = 'Advarselsnummer til varegruppe nr. serie';
        }
        field(5120;"Sales Ticket Line Text6";Code[50])
        {
            Caption = 'Sales Ticket Line Text6';
            Description = 'Ekstralinier til bon';
        }
        field(5121;"Sales Ticket Line Text7";Code[50])
        {
            Caption = 'Sales Ticket Line Text7';
            Description = 'Ekstralinier til bon';
        }
        field(5122;"Unit Price on Sales Ticket";Boolean)
        {
            Caption = 'Unit Price On Sales Ticket';
            Description = 'Skriv �pris p� bon';
        }
        field(5124;"Show Stored Tickets";Boolean)
        {
            Caption = 'Show Stores Tickets';
            Description = 'Vis gemte bon''er ved login';
        }
        field(5125;"Reset unit price on neg. sale";Boolean)
        {
            Caption = 'Reset Unit Price On Neg. Sale';
            Description = 'nulstil apris ved neg. salg';
        }
        field(5126;"Navision Shipment Note";Boolean)
        {
            Caption = 'Navision Shipment Note';
            Description = 'Afg�re om rapport valget vedr. flgs. skal k�res n�r man laver en flgs. i retai l�sningen';
        }
        field(5129;"Show Create Giftcertificat";Boolean)
        {
            Caption = 'Show Create Gift Certificate';
            Description = 'Vis form til oprettelse af gavekort, n�r disse "k�bes"';
        }
        field(5130;"Cash Customer Deposit rel.";Code[20])
        {
            Caption = 'Cash Customer Deposit Rel.';
            Description = 'Depositumsrelation for e.g. bestilling til kontantkunder';
            TableRelation = Customer;
        }
        field(5134;"Immediate postings";Option)
        {
            Caption = 'Immediate Posting';
            Description = 'Straksbogf�ringskriterier ved inds�ttelse af vareposter';
            OptionCaption = ' ,Serial No.,Always';
            OptionMembers = " ","Serial No.",Always;
        }
        field(5138;"Post to Journal";Boolean)
        {
            Caption = 'Post To Journal';
            Description = 'Inds�t i finanskladde frem for fuldst�ndig bogf�ring';
        }
        field(5139;"Journal Name";Code[10])
        {
            Caption = 'Journal Name';
            Description = 'Kladdenavn til finanskladde';
            TableRelation = IF ("Journal Type"=FILTER(='')) "Gen. Journal Batch".Name
                            ELSE IF ("Journal Type"=FILTER(<>'')) "Gen. Journal Batch".Name WHERE ("Journal Template Name"=FIELD("Journal Type"));
        }
        field(5140;"Show saved expeditions";Option)
        {
            Caption = 'Show Saved Expeditions';
            Description = 'ops�tning for vis gemte bon';
            OptionCaption = 'All,Register,Salesperson,Register+Salesperson';
            OptionMembers = All,Register,Salesperson,"Register+Salesperson";
        }
        field(5141;"Journal Type";Code[10])
        {
            Caption = 'Journal Type';
            Description = 'Kladdetype for bogf�ring';
            TableRelation = "Gen. Journal Template".Name;
        }
        field(5144;"Show Create Credit Voucher";Boolean)
        {
            Caption = 'Show Create Credit Voucher Form';
            Description = 'Vis form til oprettelse af tilgodebevis, n�r disse laves';
        }
        field(5145;"Editable eksp. reverse sale";Boolean)
        {
            Caption = 'Editable Eksp. Reverse Sale';
            Description = 'Ved tilbagef�r bon, skal det v�re muligt at lave �ndringer';
        }
        field(5146;"Item Unit on Expeditions";Boolean)
        {
            Caption = 'Item Unit On Expeditions';
            Description = 'Udskriv vareenheder p� bon';
        }
        field(5148;"Hotline no.";Code[20])
        {
            Caption = 'Hotline No.';
            Description = 'Her angiver man det hotlinie kunden kan bruge';
        }
        field(5149;"Rep. Cust. Default";Option)
        {
            Caption = 'Rep. Cust. Default';
            Description = 'Std. debitortype ved reparation';
            OptionCaption = 'Ord. Customer,Cash Customer';
            OptionMembers = "Ord. Customer","Cash Customer";
        }
        field(5150;"Retail Debitnote";Boolean)
        {
            Caption = 'Retail Debitnote';
            Description = 'Afg�re om rapport valget debetkvittering skal k�res';
        }
        field(5151;"Navision Creditnote";Boolean)
        {
            Caption = 'Navision Creditnote';
            Description = 'Afg�re om rapport valget vedr. kreditnota skal k�res n�r man laver en flgs. i retai l�sningen';
        }
        field(5152;"Check Purchase Lines if vendor";Boolean)
        {
            Caption = 'Check Purchase Lines If Vendor';
            Description = 'Afg�re om man p� k�bslinie skal checke om vare man taster tilh�rer leverand�re som man laver ordre for.';
        }
        field(5154;"Salespersoncode on Salesdoc.";Option)
        {
            Caption = 'Salesperson Code On Sales Documents';
            Description = 'Ops�tning for s�lgerkode p� salgsbilag';
            OptionCaption = 'Forced,Free';
            OptionMembers = Forced,Free;
        }
        field(5155;"Finish Register Warning";Boolean)
        {
            Caption = 'Finish Cash Register Warning';
            Description = 'Vis advarsel ved afslut kasse for f.eks. flere �bne ekspeditioner';
        }
        field(5156;"Serialno. (Itemno nonexist)";Option)
        {
            Caption = 'Serial No. (Itemno. Does Not Exists)';
            Description = 'Hvis indtastet varenummer ikke findes, skal der s� ledes efter nummer som serienr?';
            OptionCaption = 'Search,Do not search';
            OptionMembers = Search,"Do Not Search";

            trigger OnValidate()
            begin
                if "Serialno. (Itemno nonexist)" = "Serialno. (Itemno nonexist)"::Search then
                  if not NFRetailCode.TR400SerialNoKeyExists then
                    if not Confirm(Text1060017) then
                      Error(Text1060018);
            end;
        }
        field(5159;"Item remarks";Boolean)
        {
            Caption = 'Item Remarks';
            Description = 'Automatisk popup med varebem�rkninger p� ekspeditionsform';
        }
        field(5160;"Show vendoe Itemno.";Boolean)
        {
            Caption = 'Show Vendor Item No.';
            Description = 'Vis Lev. Varenummer p� bon';
        }
        field(5163;"Profit on Gifvouchers";Decimal)
        {
            Caption = 'Profit On Gift Vouchers';
        }
        field(5165;"Copy Sales Ticket on Giftvo.";Boolean)
        {
            Caption = 'Copy Sales Ticket When Selling Gift Voucher';
            Description = 'Printer to bonner ved salg af gavekort';
        }
        field(5166;"Show Customer info on ticket";Boolean)
        {
            Caption = 'Show Customer Information On Sales Ticket';
            Description = 'Viser kunde detaljer (kontant- eller debitor) hvis kundenummer er udfyldt';
        }
        field(5167;"Show Counting on Counter Rep.";Boolean)
        {
            Caption = 'Show Counting On Counter Report';
            Description = 'Viser detaljer omkring kasseopt�lling p� kasse afslutningsrapporten';
        }
        field(5171;"F9 Statistics When Login";Option)
        {
            Caption = 'F9 Statistics When Login';
            Description = 'Hvilken statistik vises ved F9 i loginbelledet';
            OptionCaption = 'Show All Registers,Show Local Register';
            OptionMembers = "Show all registers","Show local register";
        }
        field(5185;"Item group in Item no.";Boolean)
        {
            Caption = 'Item Group In Item No.';
            Description = 'Skal varegruppe inds�ttes foran i et automatisk oprettet varenummer';
        }
        field(5186;"Foreign Gift Voucher no.Series";Code[10])
        {
            Caption = 'Foreign Gift Voucher No. Series';
            TableRelation = "No. Series";
        }
        field(5187;"Foreign Credit Voucher No.Seri";Code[10])
        {
            Caption = 'Foreign Credit Voucher No. Series';
            TableRelation = "No. Series";
        }
        field(5188;"Appendix no. eq Sales Ticket";Boolean)
        {
            Caption = 'Appendix No. Equals Sales Ticket No.';
        }
        field(5250;"Shelve module";Boolean)
        {
            Caption = 'Shelve Module';
            Description = 'Brug reolsystem';
        }
        field(6164;"Ask for Attention Name";Boolean)
        {
            Caption = 'Ask For Attention Name';
            Description = 'F� attention popup ved debetsalg';
        }
        field(6183;"Reason for Return Mandatory";Boolean)
        {
            Caption = 'Reason For Return Mandatory';
        }
        field(6184;"Fixed Price of Mending";Decimal)
        {
            Caption = 'Fixed Price Of Mending';
        }
        field(6185;"Fixed Price of Denied Mending";Decimal)
        {
            Caption = 'Fixed Price Of Denied Mending';
        }
        field(6187;"Internal Dept. Code";Code[20])
        {
            Caption = 'Internal Departement Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(6188;"Allow Customer Cash Sale";Boolean)
        {
            Caption = 'Allow Customer Cash Sale';
            InitValue = true;
        }
        field(6189;"Faktura udskrifts valg";Boolean)
        {
            Caption = 'Invoice Printout Option';
        }
        field(6190;"EAN Price Code";Code[2])
        {
            Caption = 'EAN Price Group';
        }
        field(6191;"Use VariaX module";Boolean)
        {
            Caption = 'Use Multi Dim Variant Module';
            Description = 'Der gives kun adgang til VariaX modulet hvis denne er sat';
        }
        field(6192;"Internal Unit Price";Option)
        {
            Caption = 'Internal Unit Price';
            OptionCaption = 'Unit Cost,Last Direct Cost';
            OptionMembers = "Unit Cost","Last Direct";
        }
        field(6193;"Stat. Dimension";Code[20])
        {
            Caption = 'Stat. Dimension';
            Description = 'Dimension som bruges til statistik';
            TableRelation = Dimension;
        }
        field(6194;"No. of Sales pr. Stat";Integer)
        {
            Caption = 'No. Of Sales Pr. Stat';
            Description = 'Antal ekspeditioner pr. statistik popup';
        }
        field(6195;"EAN Mgt. Gift voucher";Code[2])
        {
            Caption = 'Gift Voucher Prefix';
            Description = 'Nummerserie til EAN numre for gavekort';
        }
        field(6196;"EAN Mgt. Credit voucher";Code[2])
        {
            Caption = 'Credit Voucher Prefix';
            Description = 'Nummerserie til EAN numre for tilgodebeviser';
        }
        field(6198;"Dim Stat Method";Option)
        {
            Caption = 'Dim. Stat. Method';
            OptionCaption = 'Global Dim List,Global Dim Dialog,Post Code On Audit roll';
            OptionMembers = "Global Dim List","Global Dim Dialog","Post Code";
        }
        field(6199;"Dim Stat Value";Option)
        {
            Caption = 'Dim Stat Value';
            OptionCaption = 'Check,Create';
            OptionMembers = Check,Create;
        }
        field(6209;"Demand Cash Cust on Neg Sale";Boolean)
        {
            Caption = 'Demand Cash Customer On Neg Sale';
        }
        field(6211;"Password on unblock discount";Text[4])
        {
            Caption = 'Administrator Password';
        }
        field(6214;"Auto edit debit sale";Boolean)
        {
            Caption = 'Auto Edit Debit Sale';
        }
        field(6215;"Retail Journal No. Management";Code[10])
        {
            Caption = 'Credit Voucher No. Management';
            TableRelation = "No. Series";
        }
        field(6216;"Receipt - Show zero accessory";Boolean)
        {
            Caption = 'Receipt - Show Zero Accessory';
        }
        field(6217;"Description control";Option)
        {
            Caption = 'Description Control';
            OptionCaption = '<Description>,<Description 2>,<Vendor Name><Item Group><Vendor Item No.>,<Description 2><Item Group Name>,<Description><Variant Info>,<Description Item>:<Description 2 Variant>';
            OptionMembers = "<Description>","<Description 2>","<Vendor Name><Item Group><Vendor Item No.>","<Description 2><Item group name>","<Description><Variant Info>","<Desc Item>:<Desc2 Variant>";
        }
        field(6222;"Exchange label default date";Code[10])
        {
            Caption = 'Exchange Label Default Date';
        }
        field(6224;"Skip Warranty Voucher Dialog";Text[30])
        {
            Caption = 'Warranty Voucher Dialog';

            trigger OnValidate()
            var
                DateTable: Record Date;
            begin
                DateTable.SetFilter("Period Start","Skip Warranty Voucher Dialog");
                "Skip Warranty Voucher Dialog" := DateTable.GetFilter("Period Start");
            end;
        }
        field(6225;"Warranty Standard Date";Date)
        {
            Caption = 'Warranty Standard Date';
        }
        field(6228;"Item No. Shipping";Code[20])
        {
            Caption = 'Item No. Deposit';
        }
        field(6229;"Receipt - Show Variant code";Boolean)
        {
            Caption = 'Show Variant Code ';
        }
        field(6230;"Staff Disc. Group";Code[20])
        {
            Caption = 'Staff Disc. Group';
            TableRelation = "Customer Discount Group";
        }
        field(6231;"Staff Price Group";Code[10])
        {
            Caption = 'Staff Price Group';
            TableRelation = "Customer Price Group";
        }
        field(6232;"POS - Show discount fields";Boolean)
        {
            Caption = 'Show Discount';
        }
        field(6233;"Costing Method Standard";Option)
        {
            Caption = 'Costing Method Std.';
            InitValue = Standard;
            OptionCaption = 'FIFO,LIFO,Specific,Average,Standard';
            OptionMembers = FIFO,LIFO,Specific,"Average",Standard;
        }
        field(6235;"Staff SalesPrice Calc Codeunit";Integer)
        {
            Caption = 'Staff SalesPrice Calc Codeunit';
            TableRelation = Object.ID WHERE (Type=CONST(Codeunit));

            trigger OnLookup()
            begin
                //-NPR5.46 [322752]
                // Objects.RESET;
                // Objects.SETRANGE(Type, Objects.Type::Codeunit);
                // Objects.SETRANGE(Compiled, TRUE);
                // //Objects.setrange(Regnskabsnavn, companyname);
                //
                // IF PAGE.RUNMODAL(358, Objects) = ACTION::LookupOK THEN BEGIN
                //  "Staff SalesPrice Calc Codeunit" := Objects.ID;
                //  MODIFY;
                // END;

                 AllObj.Reset;
                 AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);

                 if PAGE.RunModal(696, AllObj) = ACTION::LookupOK then begin
                  "Staff SalesPrice Calc Codeunit" := AllObj."Object ID";
                  Modify;
                 end;
                //+NPR5.46 [322752]
            end;
        }
        field(6237;"Customer type";Option)
        {
            Caption = 'Customer Type';
            OptionCaption = 'Customer,Cash';
            OptionMembers = Customer,Cash;
        }
        field(6238;"Warning - Sale with no lines";Boolean)
        {
            Caption = 'Warning - Sale With No Lines';
        }
        field(6243;"Reason on Discount";Option)
        {
            Caption = 'Reason On Discount';
            OptionCaption = ' ,Check,Create';
            OptionMembers = " ",Check,Create;
        }
        field(6244;"Reason Code No. Series";Code[10])
        {
            Caption = 'Reason Code No. Series';
            TableRelation = "No. Series";
        }
        field(6245;"Customer Credit Level Warning";Boolean)
        {
            Caption = 'Customer Credit Level Warning';
        }
        field(6246;"Global Sale POS";Boolean)
        {
            Caption = 'Global Sale POS';
        }
        field(6250;"Hotkey for Louislane";Code[20])
        {
            Caption = 'Hotkey For Louislane';
            Description = 'Ctrl+Alt+Shift+I';
            TableRelation = Hotkey.Code;
        }
        field(6251;"Hotkey for Request Commando";Code[20])
        {
            Caption = 'Hotkey For Request Commando';
            Description = 'Ctrl+Alt+Shift+S';
            TableRelation = Hotkey.Code;
        }
        field(6260;"Not use Dim filter SerialNo";Boolean)
        {
            Caption = 'Dont Use Dim Filter Serial No.';
            Description = 'Skip filtering in global Dimension when searching for SerialNo in ItemLedger';
        }
        field(6270;"Margin and Turnover By Shop";Option)
        {
            Caption = 'Margin And Turnover By Shop';
            OptionCaption = ' ,Dimension1,Dimension2';
            OptionMembers = " ",Dimension1,Dimension2;
        }
        field(6300;"Auto Changelog Level";Option)
        {
            Caption = 'Auto Changelog Level';
            OptionCaption = 'Core,Extended,None';
            OptionMembers = Core,Extended,"None";

            trigger OnValidate()
            var
                ChangeLogAutoEnabler: Codeunit "Change Log Auto Enabler";
            begin
                //-NPR5.29 [262678]
                ChangeLogAutoEnabler.ValidateChangeLogLevel(Rec, xRec);
                //+NPR5.29 [262678]
            end;
        }
        field(6310;"Customer Config. Template";Code[10])
        {
            Caption = 'Customer Config. Template';
            Description = 'NPR5.30';
            TableRelation = "Config. Template Header";
        }
        field(6320;"Use I-Comm";Boolean)
        {
            Caption = 'Allow I-Comm';
            Description = 'Tillad brugen af I-Comm tabellen og lignende kommunikationstabeller';
        }
        field(6325;"Company - Function";Option)
        {
            Caption = 'Company Function';
            OptionCaption = 'Hosted Solution,Offline Local Client,Demo Company,Template Company,Offline Server,Common Company,Concern Company';
            OptionMembers = Server,Offline,Demo,Template,"Offline server","Common Company",Concern;
        }
        field(6330;SamletBonRabat;Boolean)
        {
            Caption = 'Combined Discount';
            Description = 'Akkumulerer rabatten i bunden, istedet for at printe for hverlinje';
        }
        field(6335;"Automatic inventory posting";Boolean)
        {
            Caption = 'Automatic Inventory Posting';
            Description = 'Til automatisk lagerbogf�ring';
        }
        field(6340;"Automatic Cost Adjustment";Boolean)
        {
            Caption = 'Automatic Cost Adjustment';
            Description = 'Til automatisk k�rsel af kostprisefterberegning';
        }
        field(6345;"Signature for Return";Boolean)
        {
            Caption = 'Signature For Return';
            Description = 'Underskrift ved Returvarer';
        }
        field(6350;"Description 2 on receipt";Boolean)
        {
            Caption = 'Description 2 On Receipt';
            Description = 'Beskrivelse 2 p� Bon';
        }
        field(6355;"Return Receipt Positive Amount";Boolean)
        {
            Caption = 'Return Receipt When Positive Total Amount';
            Description = 'Udskrift af returbon ved positiv amount. sag 57937';
        }
        field(6360;"Show Discount Percent";Boolean)
        {
            Caption = 'Show Discount Percent';
            Description = 'Vis Rabat %, sag 62801, bruges p� rapport 6014419 og 6060104';
        }
        field(6370;"Create POS Entries Only";Boolean)
        {
            Caption = 'Create POS Entries Only';
            Description = 'NPR5.38';

            trigger OnValidate()
            var
                NPRetailSetup: Record "NP Retail Setup";
            begin
                //-NPR5.38 [302761]
                if "Create POS Entries Only" then begin
                  NPRetailSetup.Get;
                  NPRetailSetup.TestField("Advanced Posting Activated");
                  NPRetailSetup.TestField("Advanced POS Entries Activated");
                  if GuiAllowed then
                    if not Confirm(TextAuditRollWillBeDisabled) then
                      "Create POS Entries Only" := false;
                end;
                //+NPR5.38 [302761]
            end;
        }
        field(10000;"Debug Posting";Boolean)
        {
            Caption = 'Debug Posting';
            Description = 'Ingen bogf�ring, men inds�tning i kladder';
        }
    }

    keys
    {
        key(Key1;"Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        recRef.GetTable(Rec);
        syncCU.OnDelete(recRef);
    end;

    trigger OnInsert()
    var
        IComm: Record "I-Comm";
        FotoOps: Record "Retail Contract Setup";
    begin
        if "Register Cnt. Units" = '' then
          "Register Cnt. Units" := '0,25:0,50:1:2:5:10:20:50:100:200:500:1000';

        if IComm.ReadPermission then
          if not IComm.Get then begin
            IComm.Init;
            IComm.Insert( true );
          end;

        if FotoOps.ReadPermission then
          if not FotoOps.Get then begin
            FotoOps.Init;
            FotoOps.Insert( true );
          end;

        recRef.GetTable(Rec);
        syncCU.OnInsert(recRef);
    end;

    trigger OnModify()
    begin
        recRef.GetTable(Rec);
        syncCU.OnModify(recRef);
    end;

    var
        Text1060006: Label 'Rounding precision must be divisible by 1.';
        Text1060007: Label 'Example: 0,25 * 4 = 1';
        Text1060008: Label 'No. Series cannot be changed!';
        Text1060009: Label 'The field cannot be modified when there is payment choise.';
        NFRetailCode: Codeunit "NF Retail Code";
        Text1060017: Label 'Due to missing index, this option can delay the sales. Accept?';
        Text1060018: Label 'The update was cancelled by the user.';
        syncCU: Codeunit CompanySyncManagement;
        recRef: RecordRef;
        TextAuditRollWillBeDisabled: Label 'Warning: this will disable the creation of Audit Roll records. Do you want to continue?';
        AllObj: Record AllObj;

    procedure CheckOffline()
    var
        t001: Label 'This company is not an OFFLINE company';
    begin
        //checkoffline

        Get;
        if not ("Company - Function" in ["Company - Function"::Offline,
                                         "Company - Function"::"Offline server"]) then
          Error(t001);
    end;

    procedure CheckOnline()
    var
        t001: Label 'This company is not an ONLINE company';
    begin
        //checkonline

        Get;
        if ("Company - Function" in ["Company - Function"::Offline,
                                         "Company - Function"::"Offline server"]) then
          Error(t001);
    end;
}

