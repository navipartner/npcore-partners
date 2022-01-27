table 6151251 "NPR Restaurant Cue"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Restaurant Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Waiter Pads - Open"; Integer)
        {
            Caption = 'Waiter Pads - Open';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR NPRE Waiter Pad" where(Closed = const(false)));
        }
        field(11; "Kitchen Requests - Open"; Integer)
        {
            Caption = 'Kitchen Requests - Open';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR NPRE Kitchen Request" where("Line Status" = filter("Ready for Serving" | "Serving Requested" | Planned)));
        }
        field(20; "Turnover (LCY)"; Decimal)
        {
            Caption = 'Turnover';
            DataClassification = CustomerContent;
        }
        field(21; "No. of Sales"; Integer)
        {
            Caption = 'No. of Sales';
            DataClassification = CustomerContent;
        }
        field(22; "Total No. of Guests"; Integer)
        {
            Caption = 'Total No. of Guests';
            DataClassification = CustomerContent;
        }
        field(23; "Average per Sale (LCY)"; Decimal)
        {
            Caption = 'Average per Sale';
            DataClassification = CustomerContent;
        }
        field(24; "Average per Guest (LCY)"; Decimal)
        {
            Caption = 'Average per Guest';
            DataClassification = CustomerContent;
        }
        field(30; "Seatings: Ready"; Integer)
        {
            Caption = 'Available';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR NPRE Seating" where("Seating Location" = field("Seating Location Filter"), Status = field("Ready Seating Status Filter")));
        }
        field(31; "Seatings: Occupied"; Integer)
        {
            Caption = 'Occupied';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR NPRE Seating" where("Seating Location" = field("Seating Location Filter"), Status = field("Occupied Seating Status Filter")));
        }
        field(32; "Seatings: Cleaning Required"; Integer)
        {
            Caption = 'Cleaning Required';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR NPRE Seating" where("Seating Location" = field("Seating Location Filter"), Status = field("Cleaning R. Seat.Status Filter")));
        }
        field(33; "Seatings: Reserved"; Integer)
        {
            Caption = 'Reserved';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NPR NPRE Seating" where("Seating Location" = field("Seating Location Filter"), Status = field("Reserved Seating Status Filter")));
        }
        field(40; "Inhouse Guests"; Integer)
        {
            Caption = 'Inhouse Guests';
            DataClassification = CustomerContent;
        }
        field(41; "Available Seats"; Integer)
        {
            Caption = 'Available Seats';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("NPR NPRE Seating".Capacity where("Seating Location" = field("Seating Location Filter"), Status = field("Ready Seating Status Filter")));
        }
        field(50; "Pending Reservations"; Integer)
        {
            Caption = 'Pending';
            DataClassification = CustomerContent;
        }
        field(51; "Completed Reservations"; Integer)
        {
            Caption = 'Completed';
            DataClassification = CustomerContent;
        }
        field(52; "No-Shows"; Integer)
        {
            Caption = 'No-Shows';
            DataClassification = CustomerContent;
        }
        field(53; "Cancelled Reservations"; Integer)
        {
            Caption = 'Cancelled';
            DataClassification = CustomerContent;
        }
        field(100; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }
        field(101; "Restaurant Filter"; Code[20])
        {
            Caption = 'Restaurant Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(102; "Seating Location Filter"; Code[10])
        {
            Caption = 'Seating Location Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Seating Location";
        }
        field(103; "POS Unit Filter"; Code[10])
        {
            Caption = 'POS Unit Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR POS Unit";
        }
        field(104; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(110; "Ready Seating Status Filter"; Code[10])
        {
            Caption = 'Ready Seating Status Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(111; "Occupied Seating Status Filter"; Code[10])
        {
            Caption = 'Occupied Seating Status Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(112; "Reserved Seating Status Filter"; Code[10])
        {
            Caption = 'Reserved Seating Status Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(113; "Cleaning R. Seat.Status Filter"; Code[10])
        {
            Caption = 'Cleaning R. Seat.Status Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
    }
}
