table 6151248 "NPR NP Retail Admin Cue"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Primary key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(20; "User Setups"; Integer)
        {
            CalcFormula = Count("User Setup");
            Caption = 'User Setup';
            FieldClass = FlowField;
        }
        field(30; Salespersons; Integer)
        {
            CalcFormula = Count("Salesperson/Purchaser");
            Caption = 'Salesperson Setup';
            FieldClass = FlowField;
        }
        field(40; "POS Stores"; Integer)
        {
            CalcFormula = Count("NPR POS Store");
            Caption = 'POS Stores';
            FieldClass = FlowField;
        }
        field(50; "POS Units"; Integer)
        {
            CalcFormula = Count("NPR POS Unit");
            Caption = 'POS Units';
            FieldClass = FlowField;
        }
        field(60; "Cash Registers"; Integer)
        {
            CalcFormula = Count("NPR Register");
            Caption = 'Cash Registers';
            FieldClass = FlowField;
        }
        field(70; "POS Payment Bins"; Integer)
        {
            CalcFormula = Count("NPR POS Payment Bin");
            Caption = 'POS Payment Bins';
            FieldClass = FlowField;
        }
        field(80; "POS Payment Methods"; Integer)
        {
            CalcFormula = Count("NPR POS Payment Method");
            Caption = 'POS Payment Methods';
            FieldClass = FlowField;
        }
        field(81; "POS Posting Setups"; Integer)
        {
            CalcFormula = Count("NPR POS Posting Setup");
            Caption = 'POS Posting Setup';
            FieldClass = FlowField;
        }
        field(82; "Ticket Types"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Type");
            Caption = 'Ticket Types';
            FieldClass = FlowField;
        }
        field(83; "Ticket Admission BOMs"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Admission BOM");
            Caption = 'Admission BOMs';
            FieldClass = FlowField;
        }
        field(84; "Ticket Schedules"; Integer)
        {
            CalcFormula = Count("NPR TM Admis. Schedule");
            Caption = 'Ticket Schedules';
            FieldClass = FlowField;
        }
        field(85; "Ticket Admissions"; Integer)
        {
            CalcFormula = Count("NPR TM Admission");
            Caption = 'Ticket Admissions';
            FieldClass = FlowField;
        }
        field(86; "Membership Setup"; Integer)
        {
            CalcFormula = Count("NPR MM Membership Setup");
            Caption = 'MM Setup';
            FieldClass = FlowField;
        }
        field(87; "Membership Sales Setup"; Integer)
        {
            CalcFormula = Count("NPR MM Members. Sales Setup");
            Caption = 'MM Sales Setup';
            FieldClass = FlowField;
        }
        field(88; "Member Alteration"; Integer)
        {
            CalcFormula = Count("NPR MM Members. Alter. Setup");
            Caption = 'Member Alteration';
            FieldClass = FlowField;
        }
        field(89; "Member Community"; Integer)
        {
            CalcFormula = Count("NPR MM Member Community");
            Caption = 'Member Community';
            FieldClass = FlowField;
        }
        field(90; "Workflow Steps Enabled"; Integer)
        {
            CalcFormula = Count("NPR POS Sales Workflow Step" WHERE(Enabled = CONST(true)));
            Caption = 'Enabled';
            FieldClass = FlowField;
        }
        field(91; "Workflow Steps Not Enabled"; Integer)
        {
            CalcFormula = Count("NPR POS Sales Workflow Step" WHERE(Enabled = CONST(false)));
            Caption = 'Not Enabled';
            FieldClass = FlowField;
        }

        field(92; "EAN SETUP"; Integer)
        {
            CalcFormula = Count("NPR Ean Box Setup");
            Caption = 'Not Enabled';
            FieldClass = FlowField;
        }

        field(93; "Biggest Sales Today"; Decimal)
        {
            CalcFormula = Max("NPR POS Entry"."Item Sales (LCY)");
            Caption = 'Not Enabled';
            FieldClass = FlowField;
        }

        field(94; "Top Sales Person Today"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(95; "NPR POS Sales Workflow"; Integer)
        {
            CalcFormula = Count("NPR POS Sales Workflow");
            Caption = 'Not Enabled';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Primary key")
        {
        }
    }
    Procedure GetAmountFormat(): Text

    var
        GeneralLegerSetup: Record "General Ledger Setup";
        UserPersonalization: Record "User Personalization";
        CurrencySymbol: text[10];

    begin
        GeneralLegerSetup.GET;
        CurrencySymbol := GeneralLegerSetup.GetCurrencySymbol;

        IF UserPersonalization.GET(USERSECURITYID) AND (CurrencySymbol <> '') THEN
            CASE UserPersonalization."Locale ID" OF
                1030, // da-DK
                1053, // sv-Se
                1044: // no-no
                    EXIT('<Precision,0:0><Standard Format,0>' + CurrencySymbol);
                2057, // en-gb
                1033, // en-us
                4108, // fr-ch
                1031, // de-de
                2055, // de-ch
                1040, // it-it
                2064, // it-ch
                1043, // nl-nl
                2067, // nl-be
                2060, // fr-be
                3079, // de-at
                1035, // fi
                1034: // es-es
                    EXIT(CurrencySymbol + '<Precision,0:0><Standard Format,0>');
            END;

        EXIT(GetDefaultAmountFormat);

    end;

    Procedure GetDefaultAmountFormat(): Text

    begin
        exit('<Precision,0:0><Standard Format,0>');
    end;
}

