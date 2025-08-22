table 6151250 "NPR Retail Entertainment Cue"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Retail Entertainment Cue';
    fields
    {
        field(1; No; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'No';
        }
        field(2; "Issued Tickets"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket");
            FieldClass = FlowField;
            Caption = 'Issued Tickets';
        }
        field(3; "Ticket Requests"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Reservation Req.");
            FieldClass = FlowField;
            Caption = 'Ticket Requests';
        }
        field(4; "Ticket Schedules"; Integer)
        {
            CalcFormula = Count("NPR TM Admis. Schedule");
            FieldClass = FlowField;
            Caption = 'Ticket Schedules';
        }
        field(5; "Ticket Admissions"; Integer)
        {
            CalcFormula = Count("NPR TM Admission");
            FieldClass = FlowField;
            Caption = 'Ticket Admissions';
        }
        field(6; Items; Integer)
        {
            CalcFormula = Count(Item);
            FieldClass = FlowField;
            Caption = 'Items';
        }
        field(7; Contacts; Integer)
        {
            CalcFormula = Count(Contact);
            FieldClass = FlowField;
            Caption = 'Contacts';
        }
        field(8; Customers; Integer)
        {
            CalcFormula = Count(Customer);
            FieldClass = FlowField;
            Caption = 'Customers';
        }
        field(9; Members; Integer)
        {
            CalcFormula = Count("NPR MM Member");
            FieldClass = FlowField;
            Caption = 'Members';
        }
        field(10; Memberships; Integer)
        {
            CalcFormula = Count("NPR MM Membership");
            FieldClass = FlowField;
            Caption = 'Memberships';
        }
        field(11; Membercards; Integer)
        {
            CalcFormula = Count("NPR MM Member Card");
            FieldClass = FlowField;
            Caption = 'Membercards';
        }
        field(12; "Ticket Types"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Type");
            FieldClass = FlowField;
            Caption = 'Ticket Types';
        }
        field(13; "Ticket Admission BOM"; Integer)
        {
            CalcFormula = Count("NPR TM Ticket Admission BOM");
            FieldClass = FlowField;
            Caption = 'Ticket BOM';
        }
        field(14; TicketItems; integer)
        {
            Caption = 'Ticket Items';
            FieldClass = FlowField;
            CalcFormula = count("Item" where("NPR Ticket Type" = filter(<> '')));
        }
        field(15; "No. of Sub Req Error"; integer)
        {
            Caption = 'No. of Subscription Requests with With Error';
            FieldClass = FlowField;
            CalcFormula = count("NPR MM Subscr. Request" where("Processing Status" = filter('Error')));
        }
        field(16; "No. of Sub Req Pending"; integer)
        {
            Caption = 'No. of Pending Subscription Requests';
            FieldClass = FlowField;
            CalcFormula = count("NPR MM Subscr. Request" where("Processing Status" = filter('Pending')));
        }
        field(17; "No. of Sub Req Confirmed"; integer)
        {
            Caption = 'No. of Confirmed Subscription Requests';
            FieldClass = FlowField;
            CalcFormula = count("NPR MM Subscr. Request" where("Processing Status" = filter('Success'), "Processing Status Change Date" = field("Subs. Date Filter"), "Status" = filter('Confirmed')));
        }
        field(18; "No. of Sub Req Rejected"; integer)
        {
            Caption = 'No. of Rejected Subscription Requests';
            FieldClass = FlowField;
            CalcFormula = count("NPR MM Subscr. Request" where("Processing Status" = filter('Success'), "Processing Status Change Date" = field("Subs. Date Filter"), "Status" = filter('Rejected')));
        }
        field(19; "No. of Sub Pay Req Error"; integer)
        {
            Caption = 'No. of Subscription Payment Requests with Error';
            FieldClass = FlowField;
            CalcFormula = count("NPR MM Subscr. Payment Request" where("Status" = filter('Error')));
        }
        field(20; "No. of Sub Pay Req New"; integer)
        {
            Caption = 'No. of New Subscription Payment Requests';
            FieldClass = FlowField;
            CalcFormula = count("NPR MM Subscr. Payment Request" where("Status" = filter('New')));
        }
        field(21; "No. of Sub Pay Req Captured"; integer)
        {
            Caption = 'No. of Captured Subscription Payment Requests';
            FieldClass = FlowField;
            CalcFormula = count("NPR MM Subscr. Payment Request" where("Status" = filter('Captured'), "Status Change Date" = field("Subs. Date Filter")));
        }
        field(22; "No. of Sub Pay Req Rejected"; integer)
        {
            Caption = 'No. of Rejected Subscription Payment Requests';
            FieldClass = FlowField;
            CalcFormula = count("NPR MM Subscr. Payment Request" where("Status" = filter('Rejected'), "Status Change Date" = field("Subs. Date Filter")));
        }
        field(30; Coupons; Integer)
        {
            Caption = 'Coupons';
            FieldClass = FlowField;
            CalcFormula = Count("NPR NpDc Coupon");
        }

        field(41; Vouchers; integer)
        {
            Caption = 'Vouchers';
            FieldClass = FlowField;
            CalcFormula = count("NPR NpRv Voucher");
        }

        field(100; IssuedAttractionWalletsCount; Integer)
        {
            Caption = 'Issued Attraction Wallets';
            FieldClass = FlowField;
            CalcFormula = Count("NPR AttractionWallet");
        }
        field(110; AttractionPackageTemplateCount; Integer)
        {
            Caption = 'Attraction Package Templates';
            FieldClass = FlowField;
            CalcFormula = Count("NPR NpIa Item AddOn" where(WalletTemplate = const(true)));
        }

        field(1000; "Subs. Date Filter"; Date)
        {
            Caption = 'Subscriptions Date Filter';
            FieldClass = Flowfilter;
        }
    }

    keys
    {
        key(Key1; No)
        {
        }
    }

}

