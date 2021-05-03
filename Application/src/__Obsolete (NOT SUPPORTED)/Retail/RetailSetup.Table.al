table 6014400 "NPR Retail Setup"
{
    Caption = 'Retail Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Fields will be spread out to more module specific areas';

    fields
    {
        field(1; "Key"; Code[20])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
            Description = 'Primærn¢gle';
        }
        field(3; "Prices Include VAT"; Boolean)
        {
            Caption = 'Prices Include VAT';
            DataClassification = CustomerContent;
            Description = 'Moms med i salgspriser';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5; "Posting When Balancing"; Option)
        {
            Caption = 'Posting When Balancing';
            DataClassification = CustomerContent;
            OptionCaption = 'Total,Per Register';
            OptionMembers = Total,"Per Register";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(14; "Sales Ticket Line Text1"; Code[50])
        {
            Caption = 'Sales Ticket Line Text1';
            DataClassification = CustomerContent;
            Description = 'Ekstratekst til bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(15; "Sales Ticket Line Text2"; Code[50])
        {
            Caption = 'Sales Ticket Line Text2';
            DataClassification = CustomerContent;
            Description = 'Ekstratekst til bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(16; "Sales Ticket Line Text3"; Code[50])
        {
            Caption = 'Sales Ticket Line Text3';
            DataClassification = CustomerContent;
            Description = 'Ekstratekst til bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(17; "Sales Ticket Line Text4"; Code[50])
        {
            Caption = 'Sales Ticket Line Text4';
            DataClassification = CustomerContent;
            Description = 'Ekstratekst til bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(18; "Sales Ticket Line Text5"; Code[50])
        {
            Caption = 'Sales Ticket Line Text5';
            DataClassification = CustomerContent;
            Description = 'Ekstratekst til bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(20; "Posting Source Code"; Code[10])
        {
            Caption = 'Posting Source Code';
            DataClassification = CustomerContent;
            Description = 'Kildespor til bogf¢ring';
            TableRelation = "Source Code";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore. "NPR NP Retail Setup"."Source Code" used instead.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(51; "Posting No. Management"; Code[20])
        {
            Caption = 'Posting No. Management';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til kassebogf¢ring';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(52; "Used Goods No. Management"; Code[20])
        {
            Caption = 'Used Goods No. Management';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til brugtvarer';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(53; "Internal EAN No. Management"; Code[20])
        {
            Caption = 'Internal EAN No. Management';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til EAN numre';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Variety Setup"."Internal EAN No. Series".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(54; "Credit Voucher No. Management"; Code[20])
        {
            Caption = 'Credit Voucher No. Management';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til tilgodebevis';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Credit voucher won''t be used anymore';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(55; "Gift Voucher No. Management"; Code[20])
        {
            Caption = 'Gift Voucher No. Management';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til gavekort';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(56; "External EAN-No. Management"; Code[20])
        {
            Caption = 'External EAN-No. Management';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til eksterne EAN numre';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Variety Setup"."External EAN No. Series';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(57; "EAN Prefix Exhange Label"; Code[2])
        {
            Caption = 'EAN Prefix Exhange Label';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Exchange Label Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(60; "EAN-Internal"; Integer)
        {
            Caption = 'EAN-Internal';
            DataClassification = CustomerContent;
            Description = 'Intern ean nummer start';
            MaxValue = 29;
            MinValue = 27;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Variety Setup"."EAN-Internal';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(61; "ISBN Bookland EAN"; Boolean)
        {
            Caption = 'ISBN Bookland EAN';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(70; "Payment Type By Register"; Boolean)
        {
            Caption = 'Payment Type Managed By Cash Register';
            DataClassification = CustomerContent;
            Description = 'Kassestyret betalingsvalg';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(81; "EAN-External"; Integer)
        {
            Caption = 'EAN-External';
            DataClassification = CustomerContent;
            Description = 'ekstern eannummer';
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Variety Setup"."EAN-External';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(83; "Get register no. using"; Option)
        {
            Caption = 'Get Register No. Using';
            DataClassification = CustomerContent;
            OptionCaption = 'USERPROFILE,COMPUTERNAME,CLIENTNAME,SESSIONNAME,USERNAME,USERID,USERDOMAINID,USER SETUP TABLE,SALESPERSON TABLE';
            OptionMembers = USERPROFILE,COMPUTERNAME,CLIENTNAME,SESSIONNAME,USERNAME,USERID,USERDOMAINID,"USER SETUP TABLE",SALESPERSON;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore. "User Setup"."NPR Backoffice Register No." is used allways.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(90; "Gift and Credit Valid Period"; Integer)
        {
            Caption = 'Gift And Credit Valid Period';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift and credit voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher and NPR Credit Voucher';
        }
        field(100; "Sales Line Description Code"; Code[20])
        {
            Caption = 'Sales Line Description Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Description Control";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(105; "Purchase Line Description Code"; Code[20])
        {
            Caption = 'Purchase Line Description Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Description Control";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(110; "Transfer Line Description Code"; Code[20])
        {
            Caption = 'Transfer Line Description Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Description Control";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(115; "POS Line Description Code"; Code[20])
        {
            Caption = 'POS Line Description Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Description Control";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(350; "Sale Doc. Type On Post. Pstv."; Option)
        {
            Caption = 'Sale Doc. Type On Post. Pstv.';
            DataClassification = CustomerContent;
            OptionCaption = 'Invoice,Order';
            OptionMembers = Invoice,"Order";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore. Only order is supported.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(351; "Sale Doc. Type On Post. Negt."; Option)
        {
            Caption = 'Sale Doc. Type On Post. Negt.';
            DataClassification = CustomerContent;
            OptionCaption = 'Return Order,Credit Memo';
            OptionMembers = "Return Order","Credit Memo";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore. Only order is supported.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(352; "Sale Doc. Post. On Order"; Option)
        {
            Caption = 'Sale Doc. Post. On Order';
            DataClassification = CustomerContent;
            OptionCaption = 'Ask,Ship,Ship and Invoice,Dont Post';
            OptionMembers = Ask,Ship,"Ship and Invoice","Dont Post";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(353; "Sale Doc. Post. On Invoice"; Option)
        {
            Caption = 'Sale Doc. Post. On Invoice';
            DataClassification = CustomerContent;
            OptionCaption = 'Ask,Yes,No';
            OptionMembers = Ask,Yes,No;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(354; "Sale Doc. Post. On Cred. Memo"; Option)
        {
            Caption = 'Sale Doc. Post. On Cred. Memo';
            DataClassification = CustomerContent;
            OptionCaption = 'Ask,Yes,No';
            OptionMembers = Ask,Yes,No;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(355; "Sale Doc. Post. On Ret. Order"; Option)
        {
            Caption = 'Sale Doc. Post. On Ret. Order';
            DataClassification = CustomerContent;
            OptionCaption = 'Ask,Receive,Receive and Invoice,Dont Post';
            OptionMembers = Ask,Receive,"Receive and Invoice","Dont Post";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(356; "Sale Doc. Print On Post"; Boolean)
        {
            Caption = 'Send Document On Post';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore. Defaults to true.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(450; "Use Adv. dimensions"; Boolean)
        {
            Caption = 'Use Dimensioncontrol';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore. Defaults to true.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(501; "Variance No. Management"; Code[20])
        {
            Caption = 'Variance No. Management';
            DataClassification = CustomerContent;
            Description = 'nummerstyring til variation';
            InitValue = '0';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(502; "Mixed Discount No. Management"; Code[20])
        {
            Caption = 'Mixed Discount No. Management';
            DataClassification = CustomerContent;
            Description = 'nummerstyring til miksrabat';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Discount Priority"."Discount No. Series';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(503; "Period Discount Management"; Code[20])
        {
            Caption = 'Period Discount No. Management';
            DataClassification = CustomerContent;
            Description = 'nummerstyring til perioderabat';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Discount Priority"."Discount No. Series';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(504; "Customer Repair Management"; Code[20])
        {
            Caption = 'Customer Repair Management';
            DataClassification = CustomerContent;
            Description = 'nummerstyring til  kunderep.';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Retail Customer Repair Setup"."Customer Repair No. Series"';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(505; "Quantity Discount Nos."; Code[20])
        {
            Caption = 'Quantity Discount Nos.';
            DataClassification = CustomerContent;
            Description = 'Nummerstyring til flerstyksprishoveder';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Discount Priority"."Discount No. Series';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(550; "Use NAV Lookup in POS"; Boolean)
        {
            Caption = 'Use NAV Lookup In POS';
            DataClassification = CustomerContent;
            Description = 'NPR5.23.01';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(655; "Posting Audit Roll"; Option)
        {
            Caption = 'Posting Audit Roll';
            DataClassification = CustomerContent;
            Description = 'Opsætning for revisionsrulle bogf¢ring';
            OptionCaption = 'Manual,Automatic';
            OptionMembers = Manual,Automatic;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(700; "Selection No. Series"; Code[20])
        {
            Caption = 'Selection Nos.';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til udlejning';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(701; "Order  No. Series"; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til bestilling';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(703; "Rental Contract  No. Series"; Code[20])
        {
            Caption = 'Rental Contract Nos.';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til udk¢rsel';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(704; "Purchase Contract  No. Series"; Code[20])
        {
            Caption = 'Purchase Contract Nos.';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til udk¢rsel';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(705; "Customization  No. Series"; Code[20])
        {
            Caption = 'Customization Nos.';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til udk¢rsel';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(706; "Quote  No. Series"; Code[20])
        {
            Caption = 'Quote Nos.';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til udk¢rsel';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(720; "Exchange Label  No. Series"; Code[20])
        {
            Caption = 'Exchange Label Nos.';
            DataClassification = CustomerContent;
            Description = 'Nummerserie Til Bytte Mærker';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Exchange Label Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(750; "Variant No. Series"; Code[20])
        {
            Caption = 'Variant Std. No. Serie';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til 10-code variantkode (ikke EAN)';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Variety Setup"."EAN-External';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(800; "Balancing Posting Type"; Option)
        {
            Caption = 'Balancing';
            DataClassification = CustomerContent;
            Description = 'Opsætning til kasseafslutning';
            OptionCaption = 'PER REGISTER,TOTAL';
            OptionMembers = "PER REGISTER",TOTAL;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(998; "Credit Card Extension"; Text[50])
        {
            Caption = 'Credit Card Extension';
            DataClassification = CustomerContent;
            Description = 'Parametre til dankortprogram';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(999; "Credit Card Program"; Text[50])
        {
            Caption = 'Credit Card Program';
            DataClassification = CustomerContent;
            Description = 'Lokation af dankortprogram';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(1000; "Credit Card Path"; Text[50])
        {
            Caption = 'Credit Card Path';
            DataClassification = CustomerContent;
            Description = 'Sti til dankortprogram';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(1001; "Create New Customer"; Boolean)
        {
            Caption = 'Create New Customer';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(1015; "Company No."; Code[20])
        {
            Caption = 'Company No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(1016; "Use deposit in Retail Doc"; Boolean)
        {
            Caption = 'Use Deposit In Retail Doc';
            DataClassification = CustomerContent;
            Description = 'Benyt depositum ved reservation?';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(1019; "Popup Gift Voucher Quantity"; Boolean)
        {
            Caption = 'Pop-up (Gift Voucher Quantity And Discount)';
            DataClassification = CustomerContent;
            Description = 'Show Quantity And Discount % for giftvoucher Sale';
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(2001; "Base for FIK-71"; Option)
        {
            Caption = 'Base Of FIK-71';
            DataClassification = CustomerContent;
            Description = 'Angiver om fakturanummer eller debitornummer bruges i fik.';
            OptionCaption = 'Invoice,Customer';
            OptionMembers = Invoice,Customer;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(3009; "Item Group on Creation"; Boolean)
        {
            Caption = 'Item Group On Creation';
            DataClassification = CustomerContent;
            Description = 'Angiver om der skal sp¢rges efter vgr. ved oprettelse';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(4001; "Print Register Report"; Boolean)
        {
            Caption = 'Print Cash Register Report';
            DataClassification = CustomerContent;
            Description = 'Angiver om der skal printes en kasserapport ved afslutning';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(4002; "Sales Ticket Item"; Boolean)
        {
            Caption = 'Sales Ticket Item No.';
            DataClassification = CustomerContent;
            Description = 'Angiver om varenummer skal med på bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(4003; "Recommended Price"; Boolean)
        {
            Caption = 'Recommended Price On Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'Angiver om vejledende pris skal med på bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(4004; "Logo on Sales Ticket"; Boolean)
        {
            Caption = 'Logo On Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'Angiver om der skal logo på bon''erne';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(4005; "Name on Sales Ticket"; Boolean)
        {
            Caption = 'Name On Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'Angiver om der skal firma navn på bon''erne';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(4009; "Vendor When Creation"; Boolean)
        {
            Caption = 'Vendor When Creation';
            DataClassification = CustomerContent;
            Description = 'Angiver om der skal sp¢rges om leverand¢r ved opret';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(4019; "Item Description at 1 star"; Boolean)
        {
            Caption = 'Item Description At *';
            DataClassification = CustomerContent;
            Description = 'Overf¢rer varebeskrivelse fra varegruppe ved autoopret';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(4020; "Item Description at 2 star"; Boolean)
        {
            Caption = 'Item Description At **';
            DataClassification = CustomerContent;
            Description = 'Overf¢rer varebeskrivelse fra varegruppe ved autoopret';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5005; "Salesperson on Sales Ticket"; Boolean)
        {
            Caption = 'Salesperson On Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'Udskrift af ekspedientnavn på bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5006; "Print Total Item Quantity"; Boolean)
        {
            Caption = 'Print Total Quantity Items Sold';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5007; "Print Attributes On Receipt"; Boolean)
        {
            Caption = 'Print Attributes On Receipt';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5008; "Euro Exchange Rate"; Decimal)
        {
            Caption = 'Euro Exchange Rate';
            DataClassification = CustomerContent;
            Description = 'Angiver eurokurs uden brug af valuta modul';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5011; "Create retail order"; Option)
        {
            Caption = 'Selection System';
            DataClassification = CustomerContent;
            Description = 'Skal der sp¢rges om man k¢rer med skræddersystem';
            OptionCaption = ' ,Before Payment,After Payment';
            OptionMembers = " ","Before payment","After payment";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5016; "Customer No."; Option)
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            Description = 'Om der skal sp¢rges efter kundenummer ved login';
            OptionCaption = 'Standard,At login,Before payment';
            OptionMembers = Standard,"At login","Before payment";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5018; "Sales Lines from Selection"; Boolean)
        {
            Caption = 'Sale Lines From Selection, -F4';
            DataClassification = CustomerContent;
            Description = 'Mulighed for at slette ekspeditionslinier, hvis de er fra udlejning';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5019; "Euro on Sales Ticket"; Boolean)
        {
            Caption = 'Euro On Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'Angiver om europris skal med på bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5020; "Receipt for Debit Sale"; Boolean)
        {
            Caption = 'Receipt For Debit Sale';
            DataClassification = CustomerContent;
            Description = 'Afg¢re om rapport valget under salg og faktura skal k¢res ifm. at man laver en faktura';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5022; "Purchace Price Code"; Text[10])
        {
            Caption = 'Purchase Price Code';
            DataClassification = CustomerContent;
            Description = 'Angiver det ord k¢bsprisen skal kodes efter på prislabel';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Exchange Label Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5024; "Bar Code on Sales Ticket Print"; Boolean)
        {
            Caption = 'Bar Code On Sales Ticket Print';
            DataClassification = CustomerContent;
            Description = 'Stregkode på bonudskrift';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5025; "Post Sale"; Boolean)
        {
            Caption = 'Post Sale';
            DataClassification = CustomerContent;
            Description = 'Umiddelbart ikke noget';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5026; "Auto Print Retail Doc"; Boolean)
        {
            Caption = 'Auto Print Retail Document';
            DataClassification = CustomerContent;
            Description = 'Automatisk udskrift af bestillingsseddel';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5029; "Copy of Gift Voucher etc."; Boolean)
        {
            Caption = 'Copy Of Gift Voucher etc.';
            DataClassification = CustomerContent;
            Description = 'Udskriv kopi af gavekort';
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(5030; "FIK No."; Code[10])
        {
            Caption = 'FIK No.';
            DataClassification = CustomerContent;
            Description = 'FIKnr af firma';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, it is in standard DK version.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5031; "Ask for Reference"; Boolean)
        {
            Caption = 'Ask For Reference';
            DataClassification = CustomerContent;
            Description = 'Sp¢rg efter reference ved debetsalg under ekspedition';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5033; "EAN No. at 1 star"; Boolean)
        {
            Caption = 'EAN No. At *';
            DataClassification = CustomerContent;
            Description = 'Lav EAN nummer ved vare autoopret';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5035; "Use Standard Order Document"; Boolean)
        {
            Caption = 'Use Standard Order Document';
            DataClassification = CustomerContent;
            Description = 'Toggles the use of retail versus sales docs for orders';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5040; "Poste Sales Ticket Immediately"; Boolean)
        {
            Caption = 'Poste Sales Ticket Immediately';
            DataClassification = CustomerContent;
            Description = 'Straksbogf¢ring af bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5041; "Copies of Selection"; Boolean)
        {
            Caption = 'Copies Of Selection';
            DataClassification = CustomerContent;
            Description = 'Udskriv kopier af bestilling';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5042; "No. of Copies of Selection"; Integer)
        {
            Caption = 'No. Of Copies Of Selection';
            DataClassification = CustomerContent;
            Description = 'Antal bestillingskopier der skal udskrives';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5043; "Cash Cust. No. Series"; Code[20])
        {
            Caption = 'Cash Cust. No. Series';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til kontantkunder';
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5051; "Exchange Label Exchange Period"; DateFormula)
        {
            Caption = 'Exchange Label Exchange Period';
            DataClassification = CustomerContent;
            Description = 'Bytteperiode for Byttemærker';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Exchange Label Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5056; "Use WIN User Profile"; Boolean)
        {
            Caption = 'Use WIN User Profile';
            DataClassification = CustomerContent;
            Description = 'Anvend std. Win brugerprofil til kassefil';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5057; "Path Filename to User Profile"; Text[50])
        {
            Caption = 'Path + Filename To User Profile';
            DataClassification = CustomerContent;
            Description = 'Alternativ sti til kassefil';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5058; "Open Register Password"; Code[20])
        {
            Caption = 'Open Cash Register Password';
            DataClassification = CustomerContent;
            Description = 'kode til at åbne kasseskuffen';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR NP Retail Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5061; "Unit Cost Control"; Option)
        {
            Caption = 'Unit Cost Control';
            DataClassification = CustomerContent;
            Description = 'Spærremuligheder til ændring af á pris';
            OptionCaption = 'Enabled,Disabled,Disabled if Quantity > 0,Disabled if xUnit Cost > Unit Cost,Disabled if Quantity > 0 and xUnit Cost > Unit Cost';
            OptionMembers = Enabled,Disabled,"Disabled if Quantity > 0","Disabled if xUnit Cost > Unit Cost","Disabled if Quantity > 0 and xUnit Cost > Unit Cost";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR NP Retail Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5062; "Copy No. on Sales Ticket"; Boolean)
        {
            Caption = 'Copy No. On Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'Udskriv kopinummeret på bonen';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5068; "Transfer SeO Item Entry"; Boolean)
        {
            Caption = 'Transfer Seo To Item Entry';
            DataClassification = CustomerContent;
            Description = 'Overf¢rsel af Serienummer ej oprettet til varepost';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5071; "Register Cnt. Units"; Text[100])
        {
            Caption = 'Cash Register Cnt. Units';
            DataClassification = CustomerContent;
            Description = 'Opsætning af valutaopdeling til kassen';
            InitValue = '0,25:0,50:1:2:5:10:20:50:100:200:500:1000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5073; "Post Customer Payment imme."; Boolean)
        {
            Caption = 'Post Customer Payment Imme.';
            DataClassification = CustomerContent;
            Description = 'Straksbogf¢r debitor indbetalinger';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5076; "Post Payouts imme."; Boolean)
        {
            Caption = 'Post Payouts Imme.';
            DataClassification = CustomerContent;
            Description = 'Straksbogf¢r udbetalinger';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5077; "Auto Replication"; Boolean)
        {
            Caption = 'Auto Replication';
            DataClassification = CustomerContent;
            Description = 'Aktiver replikering af flere regnskaber';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5092; "Post registers compressed"; Boolean)
        {
            Caption = 'Post Registers Compressed';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5097; "Rental Msg."; Boolean)
        {
            Caption = 'Rental Msg.';
            DataClassification = CustomerContent;
            Description = 'Send udlejnings SMS';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5099; "EAN-No. at Item Create"; Boolean)
        {
            Caption = 'EAN-No. At Item Create';
            DataClassification = CustomerContent;
            Description = 'Autoopret EAN nummer ved vareopret';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5100; "Default Rental"; Option)
        {
            Caption = 'Default Rental';
            DataClassification = CustomerContent;
            Description = 'Std. debitortype';
            OptionCaption = 'Ord. Customer,Cash Customer';
            OptionMembers = "Ord. Customer","Cash Customer";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5103; "Prices incl. VAT"; Boolean)
        {
            Caption = 'Prices Incl. VAT';
            DataClassification = CustomerContent;
            Description = 'Salgspriser inkl. moms';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5104; "Repair Msg."; Boolean)
        {
            Caption = 'Repair Msg.';
            DataClassification = CustomerContent;
            Description = 'Send reparations SMS';
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Customer Repair Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5105; "Receive Register Turnover"; Option)
        {
            Caption = 'Receive Cash Register Turnover';
            DataClassification = CustomerContent;
            Description = 'Send  SMS med kasseomsætning ved kasseoptælling';
            OptionCaption = 'None,Per Register,Total Turnover';
            OptionMembers = "None","Per Register","Total Turnover";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5106; "Autocreate EAN-Number"; Boolean)
        {
            Caption = 'Autocreate EAN-Number';
            DataClassification = CustomerContent;
            Description = 'Opret EAN nummer  ved ny vare';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5110; "Itemgroup Pre No. Serie"; Code[5])
        {
            Caption = 'Itemgroup Pre No. Serie';
            DataClassification = CustomerContent;
            Description = 'Code f¢r automatisk oprettede varegruppe nr. serier';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5116; "Itemgroup No. Serie StartNo."; Code[20])
        {
            Caption = 'Itemgroup No. Serie StartNo.';
            DataClassification = CustomerContent;
            Description = 'Startnummer til varegruppe nr. serie';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5117; "Itemgroup No. Serie EndNo."; Code[20])
        {
            Caption = 'Itemgroup No. Serie EndNo.';
            DataClassification = CustomerContent;
            Description = 'Slutnummer til varegruppe nr. serie';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5118; "Itemgroup No. Serie Warning"; Code[20])
        {
            Caption = 'Itemgroup No. Serie Warning';
            DataClassification = CustomerContent;
            Description = 'Advarselsnummer til varegruppe nr. serie';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5120; "Sales Ticket Line Text6"; Code[50])
        {
            Caption = 'Sales Ticket Line Text6';
            DataClassification = CustomerContent;
            Description = 'Ekstralinier til bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5121; "Sales Ticket Line Text7"; Code[50])
        {
            Caption = 'Sales Ticket Line Text7';
            DataClassification = CustomerContent;
            Description = 'Ekstralinier til bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5122; "Unit Price on Sales Ticket"; Boolean)
        {
            Caption = 'Unit Price On Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'Skriv ápris på bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5124; "Show Stored Tickets"; Boolean)
        {
            Caption = 'Show Stores Tickets';
            DataClassification = CustomerContent;
            Description = 'Vis gemte bon''er ved login';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5125; "Reset unit price on neg. sale"; Boolean)
        {
            Caption = 'Reset Unit Price On Neg. Sale';
            DataClassification = CustomerContent;
            Description = 'nulstil apris ved neg. salg';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, defaults to false.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5126; "Navision Shipment Note"; Boolean)
        {
            Caption = 'Navision Shipment Note';
            DataClassification = CustomerContent;
            Description = 'Afg¢re om rapport valget vedr. flgs. skal k¢res når man laver en flgs. i retai l¢sningen';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5129; "Show Create Giftcertificat"; Boolean)
        {
            Caption = 'Show Create Gift Certificate';
            DataClassification = CustomerContent;
            Description = 'Vis form til oprettelse af gavekort, når disse "k¢bes"';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5130; "Cash Customer Deposit rel."; Code[20])
        {
            Caption = 'Cash Customer Deposit Rel.';
            DataClassification = CustomerContent;
            Description = 'Depositumsrelation for e.g. bestilling til kontantkunder';
            TableRelation = Customer;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5134; "Immediate postings"; Option)
        {
            Caption = 'Immediate Posting';
            DataClassification = CustomerContent;
            Description = 'Straksbogf¢ringskriterier ved indsættelse af vareposter';
            OptionCaption = ' ,Serial No.,Always';
            OptionMembers = " ","Serial No.",Always;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5138; "Post to Journal"; Boolean)
        {
            Caption = 'Post To Journal';
            DataClassification = CustomerContent;
            Description = 'Indsæt i finanskladde frem for fuldstændig bogf¢ring';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5139; "Journal Name"; Code[10])
        {
            Caption = 'Journal Name';
            DataClassification = CustomerContent;
            Description = 'Kladdenavn til finanskladde';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5140; "Show saved expeditions"; Option)
        {
            Caption = 'Show Saved Expeditions';
            DataClassification = CustomerContent;
            Description = 'opsætning for vis gemte bon';
            OptionCaption = 'All,Register,Salesperson,Register+Salesperson';
            OptionMembers = All,Register,Salesperson,"Register+Salesperson";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5141; "Journal Type"; Code[10])
        {
            Caption = 'Journal Type';
            DataClassification = CustomerContent;
            Description = 'Kladdetype for bogf¢ring';
            TableRelation = "Gen. Journal Template".Name;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5144; "Show Create Credit Voucher"; Boolean)
        {
            Caption = 'Show Create Credit Voucher Form';
            DataClassification = CustomerContent;
            Description = 'Vis form til oprettelse af tilgodebevis, når disse laves';
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift and credit voucher won''t be used anymore';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(5145; "Editable eksp. reverse sale"; Boolean)
        {
            Caption = 'Editable Eksp. Reverse Sale';
            DataClassification = CustomerContent;
            Description = 'Ved tilbagef¢r bon, skal det være muligt at lave ændringer';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5146; "Item Unit on Expeditions"; Boolean)
        {
            Caption = 'Item Unit On Expeditions';
            DataClassification = CustomerContent;
            Description = 'Udskriv vareenheder på bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5149; "Rep. Cust. Default"; Option)
        {
            Caption = 'Rep. Cust. Default';
            DataClassification = CustomerContent;
            Description = 'Std. debitortype ved reparation';
            OptionCaption = 'Ord. Customer,Cash Customer';
            OptionMembers = "Ord. Customer","Cash Customer";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Customer Repair Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5150; "Retail Debitnote"; Boolean)
        {
            Caption = 'Retail Debitnote';
            DataClassification = CustomerContent;
            Description = 'Afg¢re om rapport valget debetkvittering skal k¢res';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5151; "Navision Creditnote"; Boolean)
        {
            Caption = 'Navision Creditnote';
            DataClassification = CustomerContent;
            Description = 'Afg¢re om rapport valget vedr. kreditnota skal k¢res når man laver en flgs. i retai l¢sningen';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5152; "Check Purchase Lines if vendor"; Boolean)
        {
            Caption = 'Check Purchase Lines If Vendor';
            DataClassification = CustomerContent;
            Description = 'Afg¢re om man på k¢bslinie skal checke om vare man taster tilh¢rer leverand¢re som man laver ordre for.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR NP Retail Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5154; "Salespersoncode on Salesdoc."; Option)
        {
            Caption = 'Salesperson Code On Sales Documents';
            DataClassification = CustomerContent;
            Description = 'Opsætning for sælgerkode på salgsbilag';
            OptionCaption = 'Forced,Free';
            OptionMembers = Forced,Free;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR NP Retail Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5156; "Serialno. (Itemno nonexist)"; Option)
        {
            Caption = 'Serial No. (Itemno. Does Not Exists)';
            DataClassification = CustomerContent;
            Description = 'Hvis indtastet varenummer ikke findes, skal der så ledes efter nummer som serienr?';
            OptionCaption = 'Search,Do not search';
            OptionMembers = Search,"Do Not Search";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5160; "Show vendoe Itemno."; Boolean)
        {
            Caption = 'Show Vendor Item No.';
            DataClassification = CustomerContent;
            Description = 'Vis Lev. Varenummer på bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5163; "Profit on Gifvouchers"; Decimal)
        {
            Caption = 'Profit On Gift Vouchers';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(5165; "Copy Sales Ticket on Giftvo."; Boolean)
        {
            Caption = 'Copy Sales Ticket When Selling Gift Voucher';
            DataClassification = CustomerContent;
            Description = 'Printer to bonner ved salg af gavekort';
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(5166; "Show Customer info on ticket"; Boolean)
        {
            Caption = 'Show Customer Information On Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'Viser kunde detaljer (kontant- eller debitor) hvis kundenummer er udfyldt';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5167; "Show Counting on Counter Rep."; Boolean)
        {
            Caption = 'Show Counting On Counter Report';
            DataClassification = CustomerContent;
            Description = 'Viser detaljer omkring kasseoptælling på kasse afslutningsrapporten';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5171; "F9 Statistics When Login"; Option)
        {
            Caption = 'F9 Statistics When Login';
            DataClassification = CustomerContent;
            Description = 'Hvilken statistik vises ved F9 i loginbelledet';
            OptionCaption = 'Show All Registers,Show Local Register';
            OptionMembers = "Show all registers","Show local register";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5185; "Item group in Item no."; Boolean)
        {
            Caption = 'Item Group In Item No.';
            DataClassification = CustomerContent;
            Description = 'Skal varegruppe indsættes foran i et automatisk oprettet varenummer';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5186; "Foreign Gift Voucher no.Series"; Code[10])
        {
            Caption = 'Foreign Gift Voucher No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(5187; "Foreign Credit Voucher No.Seri"; Code[10])
        {
            Caption = 'Foreign Credit Voucher No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Credit voucher won''t be used anymore';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(5188; "Appendix no. eq Sales Ticket"; Boolean)
        {
            Caption = 'Appendix No. Equals Sales Ticket No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(5250; "Shelve module"; Boolean)
        {
            Caption = 'Shelve Module';
            DataClassification = CustomerContent;
            Description = 'Brug reolsystem';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6164; "Ask for Attention Name"; Boolean)
        {
            Caption = 'Ask For Attention Name';
            DataClassification = CustomerContent;
            Description = 'Få attention popup ved debetsalg';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6183; "Reason for Return Mandatory"; Boolean)
        {
            Caption = 'Reason For Return Mandatory';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6184; "Fixed Price of Mending"; Decimal)
        {
            Caption = 'Fixed Price Of Mending';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Customer Repair Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6185; "Fixed Price of Denied Mending"; Decimal)
        {
            Caption = 'Fixed Price Of Denied Mending';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Customer Repair Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6187; "Internal Dept. Code"; Code[20])
        {
            Caption = 'Internal Departement Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6188; "Allow Customer Cash Sale"; Boolean)
        {
            Caption = 'Allow Customer Cash Sale';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6189; "Faktura udskrifts valg"; Boolean)
        {
            Caption = 'Invoice Printout Option';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6190; "EAN Price Code"; Code[2])
        {
            Caption = 'EAN Price Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6191; "Use VariaX module"; Boolean)
        {
            Caption = 'Use Multi Dim Variant Module';
            DataClassification = CustomerContent;
            Description = 'Der gives kun adgang til VariaX modulet hvis denne er sat';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6192; "Internal Unit Price"; Option)
        {
            Caption = 'Internal Unit Price';
            DataClassification = CustomerContent;
            OptionCaption = 'Unit Cost,Last Direct Cost';
            OptionMembers = "Unit Cost","Last Direct";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Staff Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6193; "Stat. Dimension"; Code[20])
        {
            Caption = 'Stat. Dimension';
            DataClassification = CustomerContent;
            Description = 'Dimension som bruges til statistik';
            TableRelation = Dimension;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6194; "No. of Sales pr. Stat"; Integer)
        {
            Caption = 'No. Of Sales Pr. Stat';
            DataClassification = CustomerContent;
            Description = 'Antal ekspeditioner pr. statistik popup';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6195; "EAN Mgt. Gift voucher"; Code[2])
        {
            Caption = 'Gift Voucher Prefix';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til EAN numre for gavekort';
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher won''t be used anymore';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(6196; "EAN Mgt. Credit voucher"; Code[2])
        {
            Caption = 'Credit Voucher Prefix';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til EAN numre for tilgodebeviser';
            ObsoleteState = Removed;
            ObsoleteReason = 'Credit voucher won''t be used anymore';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(6198; "Dim Stat Method"; Option)
        {
            Caption = 'Dim. Stat. Method';
            DataClassification = CustomerContent;
            OptionCaption = 'Global Dim List,Global Dim Dialog,Post Code On Audit roll';
            OptionMembers = "Global Dim List","Global Dim Dialog","Post Code";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6199; "Dim Stat Value"; Option)
        {
            Caption = 'Dim Stat Value';
            DataClassification = CustomerContent;
            OptionCaption = 'Check,Create';
            OptionMembers = Check,Create;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6209; "Demand Cash Cust on Neg Sale"; Boolean)
        {
            Caption = 'Demand Cash Customer On Neg Sale';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6211; "Password on unblock discount"; Text[4])
        {
            Caption = 'Administrator Password';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR NP Retail Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6214; "Auto edit debit sale"; Boolean)
        {
            Caption = 'Auto Edit Debit Sale';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6215; "Retail Journal No. Management"; Code[20])
        {
            Caption = 'Credit Voucher No. Management';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR NP Retail Setup"."Retail Journal No. Series"';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6216; "Receipt - Show zero accessory"; Boolean)
        {
            Caption = 'Receipt - Show Zero Accessory';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6217; "Description control"; Option)
        {
            Caption = 'Description Control';
            DataClassification = CustomerContent;
            OptionCaption = '<Description>,<Description 2>,<Vendor Name><Item Group><Vendor Item No.>,<Description 2><Item Group Name>,<Description><Variant Info>,<Description Item>:<Description 2 Variant>';
            OptionMembers = "<Description>","<Description 2>","<Vendor Name><Item Group><Vendor Item No.>","<Description 2><Item group name>","<Description><Variant Info>","<Desc Item>:<Desc2 Variant>";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6222; "Exchange label default date"; Code[10])
        {
            Caption = 'Exchange Label Default Date';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Exchange Label Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6224; "Skip Warranty Voucher Dialog"; Text[30])
        {
            Caption = 'Warranty Voucher Dialog';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6225; "Warranty Standard Date"; Date)
        {
            Caption = 'Warranty Standard Date';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6228; "Item No. Shipping"; Code[20])
        {
            Caption = 'Item No. Deposit';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6229; "Receipt - Show Variant code"; Boolean)
        {
            Caption = 'Show Variant Code ';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6230; "Staff Disc. Group"; Code[20])
        {
            Caption = 'Staff Disc. Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Discount Group";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Staff Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6231; "Staff Price Group"; Code[10])
        {
            Caption = 'Staff Price Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Staff Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6232; "POS - Show discount fields"; Boolean)
        {
            Caption = 'Show Discount';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to DEFAULT "NPR POS View Profile"';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6233; "Costing Method Standard"; Enum "Costing Method")
        {
            Caption = 'Costing Method Std.';
            DataClassification = CustomerContent;
            InitValue = Standard;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR NP Retail Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6235; "Staff SalesPrice Calc Codeunit"; Integer)
        {
            Caption = 'Staff SalesPrice Calc Codeunit';
            DataClassification = CustomerContent;
            TableRelation = Object.ID WHERE(Type = CONST(Codeunit));
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Staff Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6237; "Customer type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Customer,Cash';
            OptionMembers = Customer,Cash;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6238; "Warning - Sale with no lines"; Boolean)
        {
            Caption = 'Warning - Sale With No Lines';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6243; "Reason on Discount"; Option)
        {
            Caption = 'Reason On Discount';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Check,Create';
            OptionMembers = " ",Check,Create;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6244; "Reason Code No. Series"; Code[20])
        {
            Caption = 'Reason Code No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6245; "Customer Credit Level Warning"; Boolean)
        {
            Caption = 'Customer Credit Level Warning';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6246; "Global Sale POS"; Boolean)
        {
            Caption = 'Global Sale POS';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6260; "Not use Dim filter SerialNo"; Boolean)
        {
            Caption = 'Dont Use Dim Filter Serial No.';
            DataClassification = CustomerContent;
            Description = 'Skip filtering in global Dimension when searching for SerialNo in ItemLedger';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR Retail Item Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6270; "Margin and Turnover By Shop"; Option)
        {
            Caption = 'Margin And Turnover By Shop';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Dimension1,Dimension2';
            OptionMembers = " ",Dimension1,Dimension2;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, moved to "NPR NP Retail Setup".';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6300; "Auto Changelog Level"; Option)
        {
            Caption = 'Auto Changelog Level';
            DataClassification = CustomerContent;
            OptionCaption = 'Core,Extended,None';
            OptionMembers = Core,Extended,"None";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(6310; "Customer Config. Template"; Code[10])
        {
            Caption = 'Customer Config. Template';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            TableRelation = "Config. Template Header";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6320; "Use I-Comm"; Boolean)
        {
            Caption = 'Allow I-Comm';
            DataClassification = CustomerContent;
            Description = 'Tillad brugen af I-Comm tabellen og lignende kommunikationstabeller';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore, defaults to false.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6330; SamletBonRabat; Boolean)
        {
            Caption = 'Combined Discount';
            DataClassification = CustomerContent;
            Description = 'Akkumulerer rabatten i bunden, istedet for at printe for hverlinje';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6335; "Automatic inventory posting"; Boolean)
        {
            Caption = 'Automatic Inventory Posting';
            DataClassification = CustomerContent;
            Description = 'Til automatisk lagerbogf¢ring';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6340; "Automatic Cost Adjustment"; Boolean)
        {
            Caption = 'Automatic Cost Adjustment';
            DataClassification = CustomerContent;
            Description = 'Til automatisk k¢rsel af kostprisefterberegning';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6345; "Signature for Return"; Boolean)
        {
            Caption = 'Signature For Return';
            DataClassification = CustomerContent;
            Description = 'Underskrift ved Returvarer';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6350; "Description 2 on receipt"; Boolean)
        {
            Caption = 'Description 2 On Receipt';
            DataClassification = CustomerContent;
            Description = 'Beskrivelse 2 på Bon';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6355; "Return Receipt Positive Amount"; Boolean)
        {
            Caption = 'Return Receipt When Positive Total Amount';
            DataClassification = CustomerContent;
            Description = 'Udskrift af returbon ved positiv amount. sag 57937';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6360; "Show Discount Percent"; Boolean)
        {
            Caption = 'Show Discount Percent';
            DataClassification = CustomerContent;
            Description = 'Vis Rabat %, sag 62801, bruges på rapport 6014419 og 6060104';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(6370; "Create POS Entries Only"; Boolean)
        {
            Caption = 'Create POS Entries Only';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
        field(10000; "Debug Posting"; Boolean)
        {
            Caption = 'Debug Posting';
            DataClassification = CustomerContent;
            Description = 'Ingen bogf¢ring, men indsætning i kladder';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
            ObsoleteTag = 'Cleanup NPR Retail Setup table';
        }
    }

    keys
    {
        key(Key1; "Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        recRef.GetTable(Rec);
    end;

    trigger OnInsert()
    var
        IComm: Record "NPR I-Comm";
    begin
        if IComm.ReadPermission then
            if not IComm.Get() then begin
                IComm.Init();
                IComm.Insert(true);
            end;

        recRef.GetTable(Rec);
    end;

    trigger OnModify()
    begin
        recRef.GetTable(Rec);
    end;

    var
        recRef: RecordRef;
}