table 6150653 "NPR POS Posting Profile"
{
    Caption = 'POS Posting Profile';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Posting Profiles";
    LookupPageID = "NPR POS Posting Profiles";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Default POS Entry No. Series"; Code[20])
        {
            Caption = 'Default POS Entry No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ObsoleteState = Removed;
            ObsoleteReason = 'It''s not used anywhere';
        }
        field(30; "Max. POS Posting Diff. (LCY)"; Decimal)
        {
            Caption = 'Max. POS Posting Diff. (LCY)';
            DataClassification = CustomerContent;
        }
        field(40; "POS Posting Diff. Account"; Code[20])
        {
            Caption = 'Differences Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(41; "Posting Diff. Account (Neg.)"; Code[20])
        {
            Caption = 'Differences Account - Neg.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(50; "Automatic Item Posting"; Option)
        {
            Caption = 'Automatic Item Posting';
            DataClassification = CustomerContent;
            OptionCaption = 'No,After Sale,After End Of Day,After Last End Of Day in Store,After Last End Of Day Companywide';
            OptionMembers = No,AfterSale,AfterEndOfDay,AfterLastEndofDayStore,AfterLastEndofDayCompany;
            ObsoleteState = Removed;
            ObsoleteReason = 'Auto posting done only via job queue.';
        }
        field(60; "Automatic POS Posting"; Option)
        {
            Caption = 'Automatic POS Posting';
            DataClassification = CustomerContent;
            OptionCaption = 'No,After Sale,After End Of Day,After Last End Of Day in Store,After Last End Of Day Companywide';
            OptionMembers = No,AfterSale,AfterEndOfDay,AfterLastEndofDayStore,AfterLastEndofDayCompany;
            ObsoleteState = Removed;
            ObsoleteReason = 'Auto posting done only via job queue.';
        }
        field(70; "Automatic Posting Method"; Option)
        {
            Caption = 'Automatic Posting Method';
            DataClassification = CustomerContent;
            OptionCaption = 'Start New Session,Direct';
            OptionMembers = StartNewSession,Direct;
            ObsoleteState = Removed;
            ObsoleteReason = 'Auto posting done only via job queue.';
        }

        field(80; "Adj. Cost after Item Posting"; Boolean)
        {
            Caption = 'Adj. Cost after Item Posting';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Related code moved to job queue instead of direct execution';

        }
        field(90; "Post to G/L after Item Posting"; Boolean)
        {
            Caption = 'Post to G/L after Item Posting';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Related code moved to job queue instead of direct execution';
        }
        field(100; "POS Sales Rounding Account"; Code[20])
        {
            Caption = 'POS Sales Rounding Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." WHERE(Blocked = CONST(false));
        }
        field(110; "POS Sales Amt. Rndng Precision"; Decimal)
        {
            Caption = 'POS Sales Amt. Rndng Precision';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            InitValue = 0.25;
            MinValue = 0;
        }
        field(120; "Rounding Type"; Option)
        {
            Caption = 'Rounding Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
        }
        field(130; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(140; "POS Payment Bin"; Code[10])
        {
            Caption = 'POS Payment Bin';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Bin";
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to POS Unit';
            ObsoleteTag = 'POS Posting Profile -> POS Unit';
        }
        field(150; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group".Code where("NPR Restricted on POS" = const(false));

            trigger OnValidate()
            var
                GenBusPostingGrp: Record "Gen. Business Posting Group";
                VatBusPostingGrp: Record "VAT Business Posting Group";
            begin
                if xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" then
                    if GenBusPostingGrp.ValidateVatBusPostingGroup(GenBusPostingGrp, "Gen. Bus. Posting Group") then begin
                        if GenBusPostingGrp."Def. VAT Bus. Posting Group" <> '' then
                            if VatBusPostingGrp.Get(GenBusPostingGrp."Def. VAT Bus. Posting Group") and VatBusPostingGrp."NPR Restricted on POS" then
                                GenBusPostingGrp."Def. VAT Bus. Posting Group" := '';
                        Validate("VAT Bus. Posting Group", GenBusPostingGrp."Def. VAT Bus. Posting Group");
                    end;
            end;
        }
        field(151; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group".Code where("NPR Restricted on POS" = const(false));
        }
        field(152; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(153; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
        }
        field(154; "Default POS Posting Setup"; Option)
        {
            Caption = 'Default POS Posting Setup';
            DataClassification = CustomerContent;
            OptionCaption = 'Store,Customer';
            OptionMembers = Store,Customer;
        }
        field(155; "VAT Customer No."; Code[20])
        {
            Caption = 'VAT Customer No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = Customer;
        }
        field(156; "Posting Compression"; Option)
        {
            Caption = 'Posting Compression';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
            InitValue = "Per POS Entry";
            OptionCaption = 'Uncompressed,Per POS Entry,Per POS Period';
            OptionMembers = Uncompressed,"Per POS Entry","Per POS Period";

            trigger OnValidate()
            var
                POSEntry: Record "NPR POS Entry";
                POSStore: Record "NPR POS Store";
            begin
                POSStore.SetRange("POS Posting Profile", Rec.Code);
                if POSStore.FindSet() then
                    repeat
                        POSEntry.SetCurrentKey("POS Store Code", "Post Entry Status");
                        POSEntry.SetRange("POS Store Code", POSStore.Code);
                        POSEntry.SetFilter("Post Entry Status", '%1|%2',
                            POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting");
                        if not POSEntry.IsEmpty() then
                            Error(PostingCompressionErr,
                                POSStore.Code, FieldCaption("Posting Compression"));
                    until POSStore.Next() = 0;
            end;
        }
        field(160; "POS Period Register No. Series"; Code[20])
        {
            Caption = 'POS Period Register No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }

        field(170; "Auto Process Ext. POS Sales"; Boolean)
        {
            Caption = 'Auto Process External POS Sales';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                ExtPOSSaleProcessor: Codeunit "NPR Ext. POS Sale Processor";
                PosPostingProfile: Record "NPR POS Posting Profile";
            begin
                IF Rec."Auto Process Ext. POS Sales" then
                    ExtPOSSaleProcessor.RegisterNcImportType('EXTPOSSALES')
                else begin
                    PosPostingProfile.SetFilter(Code, '<>%1', Rec.Code);
                    PosPostingProfile.SetRange("Auto Process Ext. POS Sales", true);
                    IF PosPostingProfile.IsEmpty() then
                        ExtPOSSaleProcessor.DeleteNCImportType('EXTPOSSALES');
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PostingCompressionErr: Label 'There are unposted entries in POS Entry table in POS Store %1. Please post then before updating %2.';

    procedure RoundingDirection(): Text[1]
    begin
        case "Rounding Type" of
            "Rounding Type"::Nearest:
                exit('=');
            "Rounding Type"::Up:
                exit('>');
            "Rounding Type"::Down:
                exit('<');
        end;
    end;

    procedure CheckPostingDateAllowed(TestDate: Date): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        PostingAllowedFrom: Date;
        PostingAllowedTo: Date;
    begin
        GeneralLedgerSetup.Get();
        if UserId <> '' then
            if UserSetup.Get(UserId) then begin
                PostingAllowedFrom := UserSetup."Allow Posting From";
                PostingAllowedTo := UserSetup."Allow Posting To";
            end;
        if (PostingAllowedFrom = 0D) and (PostingAllowedTo = 0D) then begin
            PostingAllowedFrom := GeneralLedgerSetup."Allow Posting From";
            PostingAllowedTo := GeneralLedgerSetup."Allow Posting To";
        end;
        if PostingAllowedTo = 0D then
            PostingAllowedTo := DMY2Date(31, 12, 9999);
        if (TestDate < PostingAllowedFrom) or (TestDate > PostingAllowedTo) then
            exit(false)
        else
            exit(true);
    end;

    procedure EditPostingDateAllowed(UserIDCode: Code[20]; Date2: Date)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
    begin
        if UserIDCode <> '' then begin
            if UserSetup.Get(UserIDCode) then begin
                if UserSetup."Allow Posting From" > Date2 then begin
                    UserSetup."Allow Posting From" := Date2;
                    UserSetup.Modify(true);
                end;
                if UserSetup."Allow Posting To" < Date2 then begin
                    UserSetup."Allow Posting To" := Date2;
                    UserSetup.Modify(true);
                end;
            end;
        end;

        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Allow Posting From" > Date2 then begin
            GeneralLedgerSetup."Allow Posting From" := Date2;
            GeneralLedgerSetup.Modify(true);
        end;
        if GeneralLedgerSetup."Allow Posting To" < Date2 then begin
            GeneralLedgerSetup."Allow Posting To" := Date2;
            GeneralLedgerSetup.Modify(true);
        end;
    end;
}

