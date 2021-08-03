table 6151247 "NPR POS Entry Cue."
{
    DataClassification = CustomerContent;
    Caption = 'POS Entry Cue.';
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Failed G/L Posting Trans."; Integer)
        {
            CalcFormula = Count("NPR POS Entry" WHERE("Post Entry Status" = FILTER("Error while Posting")));
            FieldClass = FlowField;
        }
        field(3; "Unposted Item Trans."; Integer)
        {
            CalcFormula = Count("NPR POS Entry" WHERE("Post Item Entry Status" = FILTER(Unposted),
             "Entry Type" = FILTER('Direct Sale' | 'Other' | 'Credit Sale')));
            FieldClass = FlowField;
        }
        field(4; "Unposted G/L Trans."; Integer)
        {
            CalcFormula = Count("NPR POS Entry" WHERE("Post Entry Status" = FILTER(Unposted)
            , "Entry Type" = FILTER('Direct Sale' | 'Other' | 'Credit Sale')));
            FieldClass = FlowField;
        }
        field(5; "Failed Item Transaction."; Integer)
        {
            CalcFormula = Count("NPR POS Entry" WHERE("Post Item Entry Status" = FILTER("Error while Posting")));
            FieldClass = FlowField;
        }
        field(6; "POS Entry List"; Integer)
        {
            CalcFormula = count("NPR POS Entry");
            FieldClass = FlowField;
        }
        field(7; "Campaign Discount List"; Integer)
        {
            CalcFormula = Count("NPR Period Discount");
            FieldClass = FlowField;
        }
        field(8; "Mix Discount List"; Integer)
        {
            CalcFormula = Count("NPR Mixed Discount" WHERE("Mix Type" = FILTER(Standard | Combination)));
            FieldClass = FlowField;
        }
        field(9; "Voucher List"; Integer)
        {
            CalcFormula = Count("NPR NpRv Voucher");
            FieldClass = FlowField;
        }
        field(10; "Coupon List"; Integer)
        {
            CalcFormula = Count("NPR NpDc Coupon");
            FieldClass = FlowField;
        }
        field(11; "EFT Reconciliation Errors"; Integer)
        {
            CalcFormula = Count("NPR EFT Transaction Request" where("Result Amount" = Filter(<> 0),
                                                                    "Transaction Date" = Field("EFT Errors Date Filter"),
                                                                    "FF Moved to POS Entry" = Filter(false)));
            FieldClass = FlowField;
        }
        field(12; "Unfinished EFT Requests"; Integer)
        {
            CalcFormula = Count("NPR EFT Transaction Request" where(Finished = Filter(0DT),
                                                                    "Transaction Date" = Field("EFT Errors Date Filter"),
                                                                    "Amount Input" = Filter(<> 0)));
            FieldClass = FlowField;
        }
        field(13; "EFT Req. with Unknown Result"; Integer)
        {
            CalcFormula = Count("NPR EFT Transaction Request" where("External Result Known" = Filter(false),
                                                                    "Transaction Date" = Field("EFT Errors Date Filter"),
                                                                    "Amount Input" = Filter(<> 0)));
            FieldClass = FlowField;
        }
        field(14; "EFT Errors Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }

    }
    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

