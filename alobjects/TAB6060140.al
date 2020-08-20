table 6060140 "MM Loyalty Setup"
{
    // MM1.17/TSA/20161214  CASE 243075 Member Point System
    // MM1.23/TSA /20171006 CASE 257011 Added Amount Factor and Point Rate, both these were implictly 1
    // MM1.23/TSA /20171006 CASE 257011 Extended Description to 50
    // MM1.32/TSA /20180712 CASE 321176 Voucher Creation, new option "Prompt"
    // MM1.40/TSA /20190816 CASE 361664 Added field 80
    // MM1.45/TSA /20200709 CASE 411768 When unchecking expire points, expire transactiona are deleted

    Caption = 'Loyalty Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Collection Period"; Option)
        {
            Caption = 'Collection Period';
            DataClassification = CustomerContent;
            OptionCaption = 'Fixed,As You Go';
            OptionMembers = "FIXED",AS_YOU_GO;
        }
        field(21; "Fixed Period Start"; DateFormula)
        {
            Caption = 'Fixed Period Start';
            DataClassification = CustomerContent;
            InitValue = 'CM';
        }
        field(22; "Collection Period Length"; DateFormula)
        {
            Caption = 'Collection Period Length';
            DataClassification = CustomerContent;
            InitValue = '+1M';
        }
        field(30; "Expire Uncollected Points"; Boolean)
        {
            Caption = 'Expire Uncollected Points';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MembershipPointsEntry: Record "MM Membership Points Entry";
            begin
                //-MM1.45 [411768]
                if ((not "Expire Uncollected Points") and (xRec."Expire Uncollected Points")) then begin
                    if (not Confirm(REMOVE_EXPIRE, false)) then
                        exit;
                    MembershipPointsEntry.SetFilter("Loyalty Code", '=%1', Code);
                    MembershipPointsEntry.SetFilter("Entry Type", '=%1', MembershipPointsEntry."Entry Type"::EXPIRED);
                    MembershipPointsEntry.DeleteAll(false);
                end;
                //+MM1.45 [411768]
            end;
        }
        field(31; "Expire Uncollected After"; DateFormula)
        {
            Caption = 'Expire Uncollected After';
            DataClassification = CustomerContent;
            InitValue = '6M';
        }
        field(40; "Voucher Point Source"; Option)
        {
            Caption = 'Voucher Point Source';
            DataClassification = CustomerContent;
            OptionCaption = 'Uncollected Points,Previous Period';
            OptionMembers = UNCOLLECTED,PREVIOUS_PERIOD;
        }
        field(41; "Voucher Point Threshold"; Integer)
        {
            Caption = 'Voucher Point Threshold';
            DataClassification = CustomerContent;
        }
        field(42; "Voucher Creation"; Option)
        {
            Caption = 'Voucher Creation';
            DataClassification = CustomerContent;
            OptionCaption = 'Single Voucher - Max Points - Lowest Voucher Code,Single Voucher - Max Points - Highest Voucher Code,Single Voucher - Highest Voucher Code Only,Multiple Vouchers - Individual Voucher Codes,Prompt';
            OptionMembers = SV_MP_LVC,SV_MP_HVC,SV_HVC,MV_IVC,PROMPT;
        }
        field(50; "Point Base"; Option)
        {
            Caption = 'Point Base';
            DataClassification = CustomerContent;
            InitValue = AMOUNT_ITEM_SETUP;
            OptionCaption = 'Amount,Amount and Item Point Setup,Item Point Setup';
            OptionMembers = AMOUNT,AMOUNT_ITEM_SETUP,ITEM_SETUP;
        }
        field(51; "Amount Base"; Option)
        {
            Caption = 'Amount Base';
            DataClassification = CustomerContent;
            OptionCaption = 'Including VAT,Excluding VAT';
            OptionMembers = INCL_VAT,EXCL_VAT;
        }
        field(52; "Points On Discounted Sales"; Boolean)
        {
            Caption = 'Points On Discounted Sales';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(60; "Amount Factor"; Decimal)
        {
            Caption = 'Amount Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
            InitValue = 1;
        }
        field(65; "Point Rate"; Decimal)
        {
            Caption = 'Point Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
            InitValue = 1;
        }
        field(80; "Auto Upgrade Point Source"; Option)
        {
            Caption = 'Auto Upgrade Point Source';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Uncollected,Previous Period';
            OptionMembers = NA,UNCOLLECTED,PREVIOUS_PERIOD;
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
        REMOVE_EXPIRE: Label 'Unchecking this option will also remove all expire transaction for this loyalty program.';
}

