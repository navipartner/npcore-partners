table 6184495 "NPR EFT Transaction Request"
{
    Caption = 'EFT Transaction Request';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR EFT Transaction Requests";
    LookupPageID = "NPR EFT Transaction Requests";

    fields
    {
        field(10; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(12; Token; Guid)
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
        }
        field(15; "Integration Type"; Code[20])
        {
            Caption = 'Integration Type';
            DataClassification = CustomerContent;
        }
        field(20; "Pepper Terminal Code"; Code[10])
        {
            Caption = 'Pepper Terminal Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pepper Terminal";
        }
        field(30; "Pepper Transaction Type Code"; Code[10])
        {
            Caption = 'Pepper Transaction Type Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pepper EFT Trx Type".Code WHERE("Integration Type" = FIELD("Integration Type"));
        }
        field(35; "Pepper Trans. Subtype Code"; Code[10])
        {
            Caption = 'Pepper Transaction Subtype Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pepper EFT Trx Subtype" WHERE("Integration Type Code" = FIELD("Integration Type"),
                                                                    "Transaction Type Code" = FIELD("Pepper Transaction Type Code"));
        }
        field(40; Started; DateTime)
        {
            Caption = 'Started';
            DataClassification = CustomerContent;
        }
        field(50; Finished; DateTime)
        {
            Caption = 'Finished';
            DataClassification = CustomerContent;
        }
        field(60; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(70; "Integration Version Code"; Code[10])
        {
            Caption = 'Integration Version Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pepper Version";
        }
        field(80; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(81; "Sales ID"; Guid)
        {
            Caption = 'Sales ID';
            DataClassification = CustomerContent;
        }
        field(83; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(84; "Sales Line ID"; Guid)
        {
            Caption = 'Sales Line ID';
            DataClassification = CustomerContent;
        }
        field(85; "POS Description"; Text[100])
        {
            Caption = 'POS Description';
            DataClassification = CustomerContent;
        }
        field(90; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(95; "POS Payment Type Code"; Code[10])
        {
            Caption = 'POS Payment Type Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(96; "Original POS Payment Type Code"; Code[10])
        {
            Caption = 'Original POS Payment Type Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(100; "Result Code"; Integer)
        {
            Caption = 'Result Code';
            DataClassification = CustomerContent;
        }
        field(110; "Card Type"; Text[4])
        {
            Caption = 'Card Type';
            DataClassification = CustomerContent;
        }
        field(120; "Card Name"; Text[24])
        {
            Caption = 'Card Name';
            DataClassification = CustomerContent;
        }
        field(130; "Card Number"; Text[30])
        {
            Caption = 'Card Number';
            DataClassification = CustomerContent;
        }
        field(131; "Card Issuer ID"; Text[30])
        {
            Caption = 'Card Issuer ID';
            DataClassification = CustomerContent;
        }
        field(132; "Card Application ID"; Text[30])
        {
            Caption = 'Card Application ID';
            DataClassification = CustomerContent;
        }
        field(135; "Track Presence Input"; Option)
        {
            Caption = 'Track Presence Input';
            DataClassification = CustomerContent;
            OptionCaption = 'Read From EFT,Manually Entered,Track 2 Data,Barcode,Any Track,Manully Entered On Pinpad';
            OptionMembers = "From EFT","Manually Entered","Track 2 Data",Barcode,"Any Track","Manully Entered On Pinpad";
        }
        field(136; "Card Information Input"; Text[40])
        {
            Caption = 'Card Information Input';
            DataClassification = CustomerContent;
        }
        field(140; "Card Expiry Date"; Text[4])
        {
            Caption = 'Card Expiry Date';
            DataClassification = CustomerContent;
        }
        field(150; "Reference Number Input"; Text[50])
        {
            Caption = 'Reference Number Input';
            DataClassification = CustomerContent;
        }
        field(160; "Reference Number Output"; Text[50])
        {
            Caption = 'Reference Number Output';
            DataClassification = CustomerContent;
        }
        field(165; "Acquirer ID"; Text[50])
        {
            Caption = 'Acquirer ID';
            DataClassification = CustomerContent;
        }
        field(166; "Reconciliation ID"; Text[50])
        {
            Caption = 'Reconciliation ID';
            DataClassification = CustomerContent;
        }
        field(170; "Authorisation Number"; Text[50])
        {
            Caption = 'Authorisation Number';
            DataClassification = CustomerContent;
        }
        field(180; "Hardware ID"; Text[200])
        {
            Caption = 'Hardware ID';
            DataClassification = CustomerContent;
        }
        field(190; "Transaction Date"; Date)
        {
            Caption = 'Transaction Date';
            DataClassification = CustomerContent;
        }
        field(200; "Transaction Time"; Time)
        {
            Caption = 'Transaction Time';
            DataClassification = CustomerContent;
        }
        field(205; "Payment Instrument Type"; Text[30])
        {
            Caption = 'Payment Instrument Type';
            DataClassification = CustomerContent;
        }
        field(210; "Authentication Method"; Option)
        {
            Caption = 'Authentication Method';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Signature,PIN,Loyalty,Consumer Device';
            OptionMembers = "None",Signature,PIN,Loyalty,ConsumerDevice;
        }
        field(215; "Signature Type"; Option)
        {
            Caption = 'Signature Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,On Receipt,On Terminal,On POS';
            OptionMembers = " ","On Receipt","On Terminal","On POS";
        }
        field(220; "Financial Impact"; Boolean)
        {
            Caption = 'Financial Impact';
            DataClassification = CustomerContent;
        }
        field(230; Mode; Option)
        {
            Caption = 'Mode';
            DataClassification = CustomerContent;
            OptionCaption = 'Production,TEST Local,TEST Remote';
            OptionMembers = Production,"TEST Local","TEST Remote";
        }
        field(240; Successful; Boolean)
        {
            Caption = 'Successful';
            DataClassification = CustomerContent;
        }
        field(250; "Result Description"; Text[50])
        {
            Caption = 'Result Description';
            DataClassification = CustomerContent;
        }
        field(260; "Bookkeeping Period"; Text[4])
        {
            Caption = 'Bookkeeping Period';
            DataClassification = CustomerContent;
        }
        field(270; "Result Display Text"; Text[100])
        {
            Caption = 'Result Display Text';
            DataClassification = CustomerContent;
        }
        field(300; "Amount Input"; Decimal)
        {
            Caption = 'Amount Input';
            DataClassification = CustomerContent;
        }
        field(310; "Amount Output"; Decimal)
        {
            Caption = 'Amount Output';
            DataClassification = CustomerContent;
        }
        field(315; "Result Amount"; Decimal)
        {
            Caption = 'Result Amount';
            DataClassification = CustomerContent;
        }
        field(320; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(330; "Cashback Amount"; Decimal)
        {
            Caption = 'Cashback Amount';
            DataClassification = CustomerContent;
        }
        field(340; "Fee Amount"; Decimal)
        {
            Caption = 'Fee Amount';
            DataClassification = CustomerContent;
        }
        field(341; "Fee Line ID"; Guid)
        {
            Caption = 'Fee Line ID';
            DataClassification = CustomerContent;
        }
        field(345; "Tip Amount"; Decimal)
        {
            Caption = 'Tip Amount';
            DataClassification = CustomerContent;
        }
        field(346; "Tip Line ID"; Guid)
        {
            Caption = 'Tip Line ID';
            DataClassification = CustomerContent;
        }
        field(350; "Offline mode"; Boolean)
        {
            Caption = 'Offline mode';
            DataClassification = CustomerContent;
        }
        field(360; "Client Assembly Version"; Text[50])
        {
            Caption = 'Client Assembly Version';
            DataClassification = CustomerContent;
        }
        field(370; "No. of Reprints"; Integer)
        {
            Caption = 'No. of Reprints';
            DataClassification = CustomerContent;
        }
        field(400; "Receipt 1"; BLOB)
        {
            Caption = 'Receipt 1';
            DataClassification = CustomerContent;
        }
        field(410; "Receipt 2"; BLOB)
        {
            Caption = 'Receipt 2';
            DataClassification = CustomerContent;
        }
        field(420; Logs; BLOB)
        {
            Caption = 'Logs';
            DataClassification = CustomerContent;
        }
        field(450; "Processing Type"; Option)
        {
            Caption = 'Processing Type';
            DataClassification = CustomerContent;
            OptionCaption = ',Payment,Refund,Open,Close,Auxiliary,Other,Void,Lookup,Setup,Gift Card Load';
            OptionMembers = ,PAYMENT,REFUND,OPEN,CLOSE,AUXILIARY,OTHER,VOID,LOOK_UP,SETUP,GIFTCARD_LOAD;
        }
        field(460; "Processed Entry No."; Integer)
        {
            Caption = 'Processed Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Transaction Request"."Entry No.";
        }
        field(470; "NST Error"; Text[250])
        {
            Caption = 'NST Error';
            DataClassification = CustomerContent;
        }
        field(480; "Client Error"; Text[250])
        {
            Caption = 'Client Error';
            DataClassification = CustomerContent;
        }
        field(490; "Force Closed"; Boolean)
        {
            Caption = 'Force Closed';
            DataClassification = CustomerContent;
        }
        field(500; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = CustomerContent;
        }
        field(510; "Reversed by Entry No."; Integer)
        {
            Caption = 'Reversed by Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Transaction Request"."Entry No.";
        }
        field(520; "Number of Attempts"; Integer)
        {
            Caption = 'Number of Attempts';
            DataClassification = CustomerContent;
        }
        field(530; "Initiated from Entry No."; Integer)
        {
            Caption = 'Initiated from Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Transaction Request";
        }
        field(540; "External Result Known"; Boolean)
        {
            Caption = 'External Result Known';
            DataClassification = CustomerContent;
        }
        field(550; "Auto Voidable"; Boolean)
        {
            Caption = 'Auto Voidable';
            DataClassification = CustomerContent;
        }
        field(555; "Manual Voidable"; Boolean)
        {
            Caption = 'Manual Voidable';
            DataClassification = CustomerContent;
        }
        field(560; Recoverable; Boolean)
        {
            Caption = 'Recoverable';
            DataClassification = CustomerContent;
        }
        field(570; Recovered; Boolean)
        {
            Caption = 'Recovered';
            DataClassification = CustomerContent;
        }
        field(580; "Recovered by Entry No."; Integer)
        {
            Caption = 'Recovered by Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Transaction Request"."Entry No.";
        }
        field(590; "Auxiliary Operation ID"; Integer)
        {
            Caption = 'Auxiliary Operation ID';
            DataClassification = CustomerContent;
        }
        field(595; "Auxiliary Operation Desc."; Text[50])
        {
            Caption = 'Auxiliary Operation Desc.';
            DataClassification = CustomerContent;
        }
        field(625; "External Transaction ID"; Text[50])
        {
            Caption = 'External Transaction ID';
            DataClassification = CustomerContent;
        }
        field(630; "External Customer ID"; Text[50])
        {
            Caption = 'External Customer ID';
            DataClassification = CustomerContent;
        }
        field(635; "External Payment Token"; Text[50])
        {
            Caption = 'External Payment Token';
            DataClassification = CustomerContent;
        }
        field(650; "Additional Info"; BLOB)
        {
            Caption = 'Additional Info';
            DataClassification = CustomerContent;
        }
        field(660; "DCC Used"; Boolean)
        {
            Caption = 'DCC Used';
            DataClassification = CustomerContent;
        }
        field(670; "DCC Currency Code"; Code[10])
        {
            Caption = 'DCC Currency Code';
            DataClassification = CustomerContent;
        }
        field(675; "DCC Amount"; Decimal)
        {
            Caption = 'DCC Amount';
            DataClassification = CustomerContent;
        }
        field(680; "Self Service"; Boolean)
        {
            Caption = 'Self Service';
            DataClassification = CustomerContent;
        }
        field(690; "Stored Value Account Type"; Text[50])
        {
            Caption = 'Stored Value Account Type';
            DataClassification = CustomerContent;
        }
        field(700; "Stored Value Provider"; Text[50])
        {
            Caption = 'Stored Value Provider';
            DataClassification = CustomerContent;
        }
        field(710; "Stored Value ID"; Text[50])
        {
            Caption = 'Stored Value ID';
            DataClassification = CustomerContent;
        }
        field(720; "Internal Customer ID"; Text[50])
        {
            Caption = 'Internal Customer ID';
            DataClassification = CustomerContent;
        }
        field(730; "Result Processed"; Boolean)
        {
            Caption = 'Result Processed';
            DataClassification = CustomerContent;
        }
        field(740; "Access Token"; BLOB)
        {
            Caption = 'Access Token';
            DataClassification = CustomerContent;
        }
        field(10000; "FF Moved to POS Entry"; Boolean)
        {
            CalcFormula = Exist("NPR POS Entry" WHERE("Document No." = FIELD("Sales Ticket No.")));
            Caption = 'Moved to POS Entry';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Sales Ticket No.")
        {
        }
        key(Key3; "Reference Number Output")
        {
        }
        key(Key4; "Initiated from Entry No.")
        {
        }
        key(Key5; "Register No.", "Integration Type", "Processing Type")
        {
        }
        key(Key6; "Hardware ID")
        {
        }
        key(key7; "Integration Type", "Processing Type", "External Result Known")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if IsNullGuid(Token) then
            Token := CreateGuid();
    end;


    procedure PrintReceipts(IsReprint: Boolean)
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        ReceiptNo: Integer;
        EntryNo: Integer;
        CreditCardTransaction2: Record "NPR EFT Receipt";
        First: Boolean;
        EFTInterface: Codeunit "NPR EFT Interface";
        Handled: Boolean;
    begin
        if "Entry No." = 0 then
            exit;

        if IsReprint then begin
            "No. of Reprints" += 1;
            Modify();
        end;

        EFTInterface.OnPrintReceipt(Rec, Handled);
        if Handled then
            exit;

        CreditCardTransaction.SetCurrentKey("EFT Trans. Request Entry No.", "Receipt No.");
        CreditCardTransaction.SetFilter("EFT Trans. Request Entry No.", '=%1', "Entry No.");
        if not CreditCardTransaction.FindSet() then
            exit;

        First := true;
        repeat
            if (ReceiptNo <> CreditCardTransaction."Receipt No.") or (EntryNo <> CreditCardTransaction."EFT Trans. Request Entry No.") or (First) then begin
                CreditCardTransaction2.SetRange("EFT Trans. Request Entry No.", CreditCardTransaction."EFT Trans. Request Entry No.");
                CreditCardTransaction2.SetRange("Receipt No.", CreditCardTransaction."Receipt No.");
                CreditCardTransaction2.PrintTerminalReceipt();
            end;
            ReceiptNo := CreditCardTransaction."Receipt No.";
            EntryNo := CreditCardTransaction."EFT Trans. Request Entry No.";
            First := false;
        until CreditCardTransaction.Next() = 0;
    end;

    procedure IsType(Type: Code[20]): Boolean
    begin
        exit(Type = "Integration Type");
    end;
}

