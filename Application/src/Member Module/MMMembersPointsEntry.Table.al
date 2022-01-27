table 6060130 "NPR MM Members. Points Entry"
{
    Access = Internal;

    Caption = 'Membership Points Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MM Members. Point Entry";
    LookupPageID = "NPR MM Members. Point Entry";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Refund,Withdrawal,Deposit,Expired,Synchronization,Reserve,Capture';
            OptionMembers = SALE,REFUND,POINT_WITHDRAW,POINT_DEPOSIT,EXPIRED,SYNCHRONIZATION,RESERVE,CAPTURE;
        }
        field(11; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(12; "Value Entry No."; Integer)
        {
            Caption = 'Value Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Value Entry";
        }
        field(13; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(14; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership";
        }
        field(18; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(19; "POS Unit Code"; Code[10])
        {
            Caption = 'POS Unit Code';
            DataClassification = CustomerContent;
        }
        field(20; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(21; "Loyalty Code"; Code[20])
        {
            Caption = 'Loyalty Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Setup";
        }
        field(22; "Loyalty Item Point Line No."; Integer)
        {
            Caption = 'Loyalty Item Point Line No.';
            DataClassification = CustomerContent;
        }
        field(23; "Point Constraint"; Option)
        {
            Caption = 'Point Constraint';
            DataClassification = CustomerContent;
            OptionCaption = 'Include,Exclude';
            OptionMembers = INCLUDE,EXCLUDE;
        }
        field(25; Adjustment; Boolean)
        {
            Caption = 'Adjustment';
            DataClassification = CustomerContent;
        }
        field(30; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(31; "Awarded Amount (LCY)"; Decimal)
        {
            Caption = 'Awarded Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(32; "Awarded Points"; Integer)
        {
            Caption = 'Awarded Points';
            DataClassification = CustomerContent;
        }
        field(33; "Redeemed Points"; Integer)
        {
            Caption = 'Redeemed Points';
            DataClassification = CustomerContent;
        }
        field(34; Points; Integer)
        {
            Caption = 'Points';
            DataClassification = CustomerContent;
        }
        field(40; "Period Start"; Date)
        {
            Caption = 'Period Start';
            DataClassification = CustomerContent;
        }
        field(41; "Period End"; Date)
        {
            Caption = 'Period End';
            DataClassification = CustomerContent;
        }
        field(50; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(51; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(52; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(55; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(60; "Redeem Ref. Type"; Option)
        {
            Caption = 'Redeem Ref. Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Coupon';
            OptionMembers = NA,COUPON;
        }
        field(65; "Redeem Reference No."; Code[20])
        {
            Caption = 'Redeem Reference No.';
            DataClassification = CustomerContent;
        }
        field(70; "Authorization Code"; Text[40])
        {
            Caption = 'Authorization Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Membership Entry No.", "Entry Type", "Posting Date")
        {
        }
        key(Key3; "Membership Entry No.", "Posting Date", "Entry Type")
        {
        }
        key(Key4; "Loyalty Code", "Membership Entry No.", "Entry Type", "Point Constraint", "Loyalty Item Point Line No.", "Period Start")
        {
        }
        key(Key5; "Authorization Code", "Entry Type")
        {
        }
    }

    fieldgroups
    {
    }
}

