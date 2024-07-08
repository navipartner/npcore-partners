table 6150652 "NPR POS End of Day Profile"
{
    Caption = 'POS End of Day/Bin Tr. Profile';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS End of Day Profiles";
    LookupPageID = "NPR POS End of Day Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "End of Day Type"; Option)
        {
            Caption = 'End of Day Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Individual,Master & Slave';
            OptionMembers = INDIVIDUAL,MASTER_SLAVE;

            trigger OnValidate()
            var
                POSUnit: Record "NPR POS Unit";
            begin

                if ("End of Day Type" = "End of Day Type"::MASTER_SLAVE) then begin
                    TestField("Master POS Unit No.");

                    POSUnit.Get("Master POS Unit No.");
                    if (POSUnit."POS End of Day Profile" <> Rec.Code) then
                        Error(PROFILE_MISSMATCH);
                end;
            end;
        }
        field(21; "Master POS Unit No."; Code[10])
        {
            Caption = 'Master POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(30; "Z-Report UI"; Option)
        {
            Caption = 'Z-Report UI';
            DataClassification = CustomerContent;
            OptionCaption = 'Summary+Balancing,Balancing Only';
            OptionMembers = SUMMARY_BALANCING,BALANCING;
        }
        field(35; "X-Report UI"; Option)
        {
            Caption = 'X-Report UI';
            DataClassification = CustomerContent;
            OptionCaption = 'Summary+Printing,Printing Only';
            OptionMembers = SUMMARY_PRINT,PRINT;
        }
        field(36; "Close Workshift UI"; Option)
        {
            Caption = 'Close Workshift UI';
            DataClassification = CustomerContent;
            OptionCaption = 'Print,No print';
            OptionMembers = PRINT,NO_PRINT;
        }
        field(38; "User Experience"; Option)
        {
            Caption = 'User Experience';
            DataClassification = CustomerContent;
            OptionCaption = 'Business Central,Point of Sale';
            OptionMembers = BC,POS;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used anymore.';
        }
        field(40; "Force Blind Counting"; Boolean)
        {
            Caption = 'Force Blind Counting';
            DataClassification = CustomerContent;
        }
        field(41; "SMS Profile"; Code[20])
        {
            Caption = 'SMS Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            TableRelation = "NPR SMS Template Header";
        }
        field(50; "Z-Report Number Series"; Code[20])
        {
            Caption = 'Z-Report Number Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(51; "X-Report Number Series"; Code[20])
        {
            Caption = 'X-Report Number Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(60; "Show Zero Amount Lines"; Boolean)
        {
            Caption = 'Show Zero Amount Lines';
            DataClassification = CustomerContent;
        }
        field(70; "Posting Error Handling"; Option)
        {
            Caption = 'Posting Error Handling';
            DataClassification = CustomerContent;
            OptionCaption = 'With Message,With Error,Silent';
            OptionMembers = WITH_MESSAGE,WITH_ERROR,SILENT;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Auto posting done only via job queue.';
        }
        field(75; "End of Day Frequency"; Option)
        {
            Caption = 'End of Day Frequency';
            DataClassification = CustomerContent;
            OptionCaption = 'Never,Daily';
            OptionMembers = NEVER,DAILY;
            InitValue = DAILY;
        }
        field(80; "Hide Turnover Section"; Boolean)
        {
            Caption = 'Hide Turnover Section';
            DataClassification = CustomerContent;
        }
        field(85; DisableDifferenceField; Boolean)
        {
            Caption = 'Disable Difference Field';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not DisableDifferenceField then
                    TestField("Require Denomin.(Counted Amt.)", false);
            end;
        }
        field(90; "Require Denomin.(Counted Amt.)"; Boolean)
        {
            Caption = 'Require Denomin.(Counted Amt.)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Require Denomin.(Counted Amt.)" then
                    Validate(DisableDifferenceField, true);
            end;
        }
        field(91; "Require Denomin.(Bank Deposit)"; Boolean)
        {
            Caption = 'Require Denomin.(Bank Deposit)';
            DataClassification = CustomerContent;
        }
        field(92; "Require Denomin. (Move to Bin)"; Boolean)
        {
            Caption = 'Require Denomin. (Move to Bin)';
            DataClassification = CustomerContent;
        }
        field(100; "Bin Transfer: Require Journal"; Boolean)
        {
            Caption = 'Bin Transfer: Require Journal';
            DataClassification = CustomerContent;
        }
        field(110; "Bank Deposit Ref. Asgmt."; Enum "NPR Ref.No. Assignment Method")
        {
            Caption = 'Bank Deposit Ref. Asgmt. Method';
            DataClassification = CustomerContent;
        }
        field(111; "Move to Bin Ref. Asgmt."; Enum "NPR Ref.No. Assignment Method")
        {
            Caption = 'Move to Bin Ref. Asgmt. Method';
            DataClassification = CustomerContent;
        }
        field(120; "BT OUT: Bank Dep. Ref. Asgmt."; Enum "NPR Ref.No. Assignment Method")
        {
            Caption = 'BT: Bank Deposit Ref. Asgmt. Method';
            DataClassification = CustomerContent;
        }
        field(121; "BT OUT: Move to Bin Ref.Asgmt."; Enum "NPR Ref.No. Assignment Method")
        {
            Caption = 'BT: Move to Bin Ref. Asgmt. Method';
            DataClassification = CustomerContent;
        }
        field(130; "BT IN: Tr.from Bank Ref.Asgmt."; Enum "NPR Ref.No. Assignment Method")
        {
            Caption = 'BT: Tr.from Bank Ref. Asgmt. Method';
            DataClassification = CustomerContent;
        }
        field(131; "BT IN: Move fr. Bin Ref.Asgmt."; Enum "NPR Ref.No. Assignment Method")
        {
            Caption = 'BT: Move fr. Bin Ref. Asgmt. Method';
            DataClassification = CustomerContent;
        }
        field(140; "Bank Deposit Ref. Nos."; Code[20])
        {
            Caption = 'Bank Deposit Ref. Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                ValidateNoSeries("Bank Deposit Ref. Nos.");
            end;
        }
        field(141; "Move to Bin Ref. Nos."; Code[20])
        {
            Caption = 'Move to Bin Ref. Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                ValidateNoSeries("Move to Bin Ref. Nos.");
            end;
        }
        field(150; "BT OUT: Bank Deposit Ref. Nos."; Code[20])
        {
            Caption = 'BT: Bank Deposit Ref. Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                ValidateNoSeries("BT OUT: Bank Deposit Ref. Nos.");
            end;
        }
        field(151; "BT OUT: Move to Bin Ref. Nos."; Code[20])
        {
            Caption = 'BT: Move to Bin Ref. Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                ValidateNoSeries("BT OUT: Move to Bin Ref. Nos.");
            end;
        }
        field(160; "BT IN: Tr.from Bank Ref. Nos."; Code[20])
        {
            Caption = 'BT Tr. from Bank Ref. Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                ValidateNoSeries("BT IN: Tr.from Bank Ref. Nos.");
            end;
        }
        field(161; "BT IN: Move fr. Bin Ref. Nos."; Code[20])
        {
            Caption = 'BT: Move fr. Bin Ref. Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            begin
                ValidateNoSeries("BT IN: Move fr. Bin Ref. Nos.");
            end;
        }
        field(170; "NO General Info Output Type"; Enum "NPR NO Gen. Info Output Type")
        {
            Caption = 'General Info Output Type';
            DataClassification = CustomerContent;
        }
        field(180; "In-Transit Bin Code"; Code[10])
        {
            Caption = 'In-Transit Bin Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin" where("Bin Type" = const(SAFE));
        }
        field(190; "Bin Transfer Number Series"; Code[20])
        {
            Caption = 'Bin Transfer Number Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    var
        PROFILE_MISSMATCH: Label 'The master POS Unit must have the same profile as this unit.';

    internal procedure ValidateNoSeries(NoSeriesCode: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if NoSeriesCode = '' then
            exit;
        NoSeries.Get(NoSeriesCode);
        NoSeriesMgt.SetNoSeriesLineFilter(NoSeriesLine, NoSeriesCode, 0D);
        NoSeriesLine.FindFirst();
        NoSeriesLine.TestField("Allow Gaps in Nos.", true);
    end;
}
